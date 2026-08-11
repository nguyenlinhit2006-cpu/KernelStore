use leptos::prelude::*;
use leptos::task::spawn_local;

use crate::api::{create_order, get_cart, Cart, CreateOrderPayload, Order};
use crate::auth::AuthContext;
use crate::components::input::TermInput;
use crate::components::loading::Loading;
use crate::components::toast::ToastContext;
use crate::i18n::use_i18n;

#[component]
pub fn CheckoutPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let i18n = use_i18n();

    let cart = RwSignal::new(None::<Cart>);
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());
    let submitting = RwSignal::new(false);
    let placed = RwSignal::new(None::<Order>);
    let toasts = use_context::<ToastContext>().expect("ToastContext must be provided");

    // Address form fields
    let full_name = RwSignal::new(String::new());
    let phone = RwSignal::new(String::new());
    let street = RwSignal::new(String::new());
    let ward = RwSignal::new(String::new());
    let district = RwSignal::new(String::new());
    let city = RwSignal::new(String::new());
    let note = RwSignal::new(String::new());

    // Prefill recipient name from the logged-in user.
    if let Some(u) = auth.user.get() {
        full_name.set(u.full_name);
    }

    // Load cart for the summary.
    {
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            match get_cart(&token).await {
                Ok(c) => cart.set(Some(c)),
                Err(e) => error.set(e.to_string()),
            }
            loading.set(false);
        });
    }

    let place_order = move |_| {
        if submitting.get() {
            return;
        }
        // Client-side required checks mirror the API contract.
        if full_name.get().trim().is_empty()
            || phone.get().trim().is_empty()
            || street.get().trim().is_empty()
            || city.get().trim().is_empty()
        {
            error.set(i18n.t("checkout.missing").to_string());
            return;
        }

        submitting.set(true);
        error.set(String::new());
        let token = auth.token.get().unwrap_or_default();
        let payload = CreateOrderPayload {
            full_name: full_name.get().trim().to_string(),
            phone: phone.get().trim().to_string(),
            street: street.get().trim().to_string(),
            ward: ward.get().trim().to_string(),
            district: district.get().trim().to_string(),
            city: city.get().trim().to_string(),
            note: note.get().trim().to_string(),
        };
        spawn_local(async move {
            match create_order(&token, &payload).await {
                Ok(order) => {
                    toasts.success(i18n.t("checkout.placed_toast").replacen("{}", &order.order_code, 1));
                    placed.set(Some(order));
                }
                Err(e) => {
                    error.set(e.to_string());
                    toasts.error(e.to_string());
                }
            }
            submitting.set(false);
        });
    };

    view! {
        <div class="max-w-4xl mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --checkout"</p>
            <h1 class="text-lg font-bold mb-4">{move || i18n.t("checkout.title")}</h1>

            {move || {
                // ── Success ─────────────────────────────────────────────
                if let Some(order) = placed.get() {
                    return view! { <OrderPlaced order=order/> }.into_any();
                }

                if loading.get() {
                    return view! {
                        <p><Loading text=i18n.t("checkout.loading")/></p>
                    }.into_any();
                }

                let Some(c) = cart.get() else {
                    return view! { <p class="term-error">{i18n.t("checkout.load_failed")}</p> }.into_any();
                };

                if c.items.is_empty() {
                    return view! {
                        <div class="term-box p-8 text-center">
                            <p class="term-muted text-sm mb-4">{i18n.t("checkout.empty")}</p>
                            <a href="/products" class="term-btn inline-block px-4 py-2 text-sm">{i18n.t("checkout.browse")}</a>
                        </div>
                    }.into_any();
                }

                view! {
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        // ── Address form ─────────────────────────────────
                        <div class="term-box p-4">
                            <p class="term-muted text-xs mb-3">{i18n.t("checkout.address")}</p>
                            <TermInput id="co-name" label=i18n.t("checkout.full_name") value=full_name placeholder="Nguyen Van A"/>
                            <TermInput id="co-phone" label=i18n.t("checkout.phone") value=phone placeholder="0901234567"/>
                            <TermInput id="co-street" label=i18n.t("checkout.street") value=street placeholder="123 Le Loi"/>
                            <TermInput id="co-ward" label=i18n.t("checkout.ward") value=ward placeholder="Ben Nghe"/>
                            <TermInput id="co-district" label=i18n.t("checkout.district") value=district placeholder="Quan 1"/>
                            <TermInput id="co-city" label=i18n.t("checkout.city") value=city placeholder="Ho Chi Minh"/>
                            <TermInput id="co-note" label=i18n.t("checkout.note") value=note placeholder=i18n.t("checkout.note_ph")/>
                        </div>

                        // ── Order summary ────────────────────────────────
                        <div>
                            <div class="term-box overflow-hidden">
                                <p class="term-muted text-xs px-4 py-2 border-b border-[var(--border)]">{i18n.t("checkout.summary")}</p>
                                {c.items.into_iter().map(|item| {
                                    view! {
                                        <div class="flex justify-between items-center gap-2 px-4 py-2 text-sm border-b border-[var(--border)] last:border-0">
                                            <span class="truncate">
                                                {item.name}
                                                <span class="term-muted text-xs">{format!(" ×{}", item.quantity)}</span>
                                            </span>
                                            <span class="shrink-0">{format!("${:.2}", item.line_total)}</span>
                                        </div>
                                    }
                                }).collect_view()}
                            </div>

                            <div class="term-sub p-4 mt-4">
                                <div class="flex justify-between text-sm mb-1">
                                    <span class="term-muted">{i18n.t("checkout.items")}</span>
                                    <span>{c.total_items}</span>
                                </div>
                                <div class="flex justify-between text-sm mb-1">
                                    <span class="term-muted">{i18n.t("checkout.shipping")}</span>
                                    <span>"$0.00"</span>
                                </div>
                                <div class="flex justify-between text-base mb-3">
                                    <span class="term-muted">{i18n.t("checkout.total")}</span>
                                    <span class="text-[var(--fg-primary)] font-bold">{format!("${:.2}", c.subtotal)}</span>
                                </div>

                                <Show when=move || !error.get().is_empty()>
                                    <p class="term-error text-xs mb-2">"[ERROR] " {move || error.get()}</p>
                                </Show>

                                <button
                                    class="term-btn block w-full text-center px-4 py-2 text-sm"
                                    disabled=move || submitting.get()
                                    on:click=place_order
                                >
                                    {move || if submitting.get() { i18n.t("checkout.placing") } else { i18n.t("checkout.place") }}
                                </button>
                                <a href="/cart" class="term-muted text-xs block text-center mt-2 hover:underline">{i18n.t("checkout.back_cart")}</a>
                            </div>
                        </div>
                    </div>
                }.into_any()
            }}
        </div>
    }
}

#[component]
fn OrderPlaced(order: Order) -> impl IntoView {
    let i18n = use_i18n();
    view! {
        <div class="term-box p-8">
            <p class="term-info text-sm mb-2">{move || i18n.t("checkout.confirmed")}</p>
            <pre class="term-muted text-xs whitespace-pre-wrap mb-4">
{move || format!(
"  {} : {}
  {} : {}
  {} : {}
  {} : ${:.2}
  {} : {}, {}",
    i18n.t("checkout.order_code"), order.order_code,
    i18n.t("checkout.status"), order.status,
    i18n.t("checkout.r_items"), order.item_count,
    i18n.t("checkout.r_total"), order.total_amount,
    i18n.t("checkout.ship_to"), order.address.full_name, order.address.city)}
            </pre>
            <div class="flex gap-2 flex-wrap">
                <a href="/orders" class="term-btn inline-block px-4 py-2 text-sm">{move || i18n.t("checkout.history")}</a>
                <a href="/products" class="term-btn inline-block px-4 py-2 text-sm">{move || i18n.t("checkout.continue")}</a>
            </div>
        </div>
    }
}
