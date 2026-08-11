use leptos::prelude::*;
use leptos::task::spawn_local;

use crate::api::{delete_cart_item, get_cart, update_cart_item, Cart, CartItem};
use crate::auth::AuthContext;
use crate::components::loading::Loading;
use crate::components::toast::ToastContext;
use crate::i18n::use_i18n;

#[component]
pub fn CartPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let i18n = use_i18n();

    let cart = RwSignal::new(None::<Cart>);
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());
    let busy = RwSignal::new(false);
    let toasts = use_context::<ToastContext>().expect("ToastContext must be provided");

    // Initial load
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

    // Set quantity for a product (backend removes when quantity <= 0).
    let set_qty = move |product_id: String, qty: i32| {
        if busy.get() {
            return;
        }
        busy.set(true);
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            match update_cart_item(&token, &product_id, qty).await {
                Ok(c) => {
                    cart.set(Some(c));
                    error.set(String::new());
                }
                Err(e) => {
                    error.set(e.to_string());
                    toasts.error(e.to_string());
                }
            }
            busy.set(false);
        });
    };

    let remove = move |product_id: String| {
        if busy.get() {
            return;
        }
        busy.set(true);
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            match delete_cart_item(&token, &product_id).await {
                Ok(c) => {
                    cart.set(Some(c));
                    error.set(String::new());
                    toasts.info(i18n.t("cart.removed"));
                }
                Err(e) => {
                    error.set(e.to_string());
                    toasts.error(e.to_string());
                }
            }
            busy.set(false);
        });
    };

    view! {
        <div class="max-w-4xl mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --cart"</p>
            <h1 class="text-lg font-bold mb-4">{move || i18n.t("cart.title")}</h1>

            <Show when=move || !error.get().is_empty()>
                <p class="term-error text-sm mb-3">"[ERROR] " {move || error.get()}</p>
            </Show>

            {move || {
                if loading.get() {
                    return view! {
                        <p><Loading text=i18n.t("cart.loading")/></p>
                    }.into_any();
                }

                let Some(c) = cart.get() else {
                    return view! { <p class="term-error">{i18n.t("cart.load_failed")}</p> }.into_any();
                };

                if c.items.is_empty() {
                    return view! {
                        <div class="term-box p-8 text-center">
                            <p class="term-muted text-sm mb-1">{i18n.t("cart.empty")}</p>
                            <pre class="term-muted text-xs mb-4">{i18n.t("cart.empty_hint")}</pre>
                            <a href="/products" class="term-btn inline-block px-4 py-2 text-sm">{i18n.t("cart.browse")}</a>
                        </div>
                    }.into_any();
                }

                view! {
                    <div class="term-box overflow-hidden">
                        // header row
                        <div class="grid grid-cols-[1fr_auto_auto_auto] gap-3 px-4 py-2 text-xs term-muted border-b border-[var(--border)]">
                            <span>{i18n.t("cart.col_product")}</span>
                            <span class="text-center w-28">{i18n.t("cart.col_qty")}</span>
                            <span class="text-right w-24">{i18n.t("cart.col_total")}</span>
                            <span class="w-8"></span>
                        </div>

                        {c.items.into_iter().map(|item| {
                            view! {
                                <CartRow item=item busy=busy set_qty=set_qty remove=remove/>
                            }
                        }).collect_view()}
                    </div>

                    // ── Summary ──────────────────────────────────────────────
                    <div class="flex justify-end mt-4">
                        <div class="term-sub p-4 w-full sm:w-72">
                            <div class="flex justify-between text-sm mb-1">
                                <span class="term-muted">{i18n.t("cart.items")}</span>
                                <span>{c.total_items}</span>
                            </div>
                            <div class="flex justify-between text-sm mb-3">
                                <span class="term-muted">{i18n.t("cart.subtotal")}</span>
                                <span class="text-[var(--fg-primary)] font-bold">{format!("${:.2}", c.subtotal)}</span>
                            </div>
                            <a
                                href="/checkout"
                                class="term-btn block text-center px-4 py-2 text-sm"
                            >{i18n.t("cart.checkout")}</a>
                        </div>
                    </div>
                }.into_any()
            }}
        </div>
    }
}

#[component]
fn CartRow(
    item: CartItem,
    busy: RwSignal<bool>,
    set_qty: impl Fn(String, i32) + Copy + 'static,
    remove: impl Fn(String) + Copy + 'static,
) -> impl IntoView {
    let i18n = use_i18n();
    let pid = item.product_id.clone();
    let qty = item.quantity;
    let stock = item.stock_quantity;
    let at_max = qty >= stock;
    let has_sale = item.sale_price.is_some();

    let dec_id = pid.clone();
    let inc_id = pid.clone();
    let rm_id = pid.clone();

    let image = item.image_url.clone().unwrap_or_default();

    view! {
        <div class="grid grid-cols-[1fr_auto_auto_auto] gap-3 px-4 py-3 items-center border-b border-[var(--border)] last:border-0">
            // product
            <div class="flex items-center gap-3 min-w-0">
                <div class="term-box w-14 h-14 shrink-0 overflow-hidden flex items-center justify-center bg-[var(--bg-tertiary)]">
                    {if image.is_empty() {
                        view! { <span class="term-muted text-xl">"[ ]"</span> }.into_any()
                    } else {
                        view! { <img src=image class="w-full h-full object-cover"/> }.into_any()
                    }}
                </div>
                <div class="min-w-0">
                    <a href=format!("/products/{}", item.slug) class="text-sm text-[var(--fg-primary)] hover:underline truncate block">
                        {item.name.clone()}
                    </a>
                    <div class="flex items-center gap-2 text-xs">
                        <span class="term-muted">{format!("${:.2}", item.unit_price)}</span>
                        {has_sale.then(|| view! {
                            <span class="line-through term-muted">{format!("${:.2}", item.price)}</span>
                        })}
                        {item.shop_name.clone().map(|s| view! {
                            <span class="term-info">{format!("· {s}")}</span>
                        })}
                    </div>
                    {(qty >= stock).then(|| view! {
                        <p class="term-warn text-xs mt-0.5">{format!("{}{stock}", i18n.t("cart.max_stock"))}</p>
                    })}
                </div>
            </div>

            // qty stepper
            <div class="flex items-center gap-1 w-28 justify-center">
                <button
                    class="term-btn px-2 py-0.5 text-sm"
                    disabled=move || busy.get()
                    on:click=move |_| set_qty(dec_id.clone(), qty - 1)
                >"−"</button>
                <span class="w-8 text-center text-sm">{qty}</span>
                <button
                    class="term-btn px-2 py-0.5 text-sm"
                    disabled=move || busy.get() || at_max
                    on:click=move |_| set_qty(inc_id.clone(), qty + 1)
                >"+"</button>
            </div>

            // line total
            <span class="text-right w-24 text-sm text-[var(--fg-primary)]">{format!("${:.2}", item.line_total)}</span>

            // remove
            <button
                class="term-btn px-2 py-0.5 text-xs text-[var(--fg-error)] w-8"
                title=i18n.t("cart.remove")
                disabled=move || busy.get()
                on:click=move |_| remove(rm_id.clone())
            >"x"</button>
        </div>
    }
}
