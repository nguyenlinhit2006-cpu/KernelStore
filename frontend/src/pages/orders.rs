use leptos::prelude::*;
use leptos::task::spawn_local;
use leptos_router::hooks::use_params_map;

use crate::api::{create_review, get_order, list_orders, update_order_status, ApiError, Order};
use crate::auth::AuthContext;
use crate::components::error::KernelPanic;
use crate::components::loading::Loading;
use crate::components::toast::ToastContext;

/// Order statuses a seller/admin can transition an order to.
const ORDER_STATUSES: &[&str] = &[
    "Pending", "Confirmed", "Processing", "Shipped", "Delivered", "Cancelled",
];

/// Terminal color class for an order status.
fn status_class(status: &str) -> &'static str {
    match status {
        "Delivered" => "term-info",
        "Cancelled" => "term-error",
        "Shipped" | "Processing" | "Confirmed" => "term-warn",
        _ => "term-muted", // Pending
    }
}

fn short_date(raw: &str) -> String {
    raw.chars().take(10).collect()
}

#[component]
pub fn OrdersPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");

    let orders = RwSignal::new(None::<Vec<Order>>);
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());

    {
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            match list_orders(&token).await {
                Ok(list) => orders.set(Some(list)),
                Err(e) => error.set(e.to_string()),
            }
            loading.set(false);
        });
    }

    view! {
        <div class="max-w-4xl mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --orders"</p>
            <h1 class="text-lg font-bold mb-4">"> order history"</h1>

            <Show when=move || !error.get().is_empty()>
                <p class="term-error text-sm mb-3">"[ERROR] " {move || error.get()}</p>
            </Show>

            {move || {
                if loading.get() {
                    return view! {
                        <p><Loading text="loading orders"/></p>
                    }.into_any();
                }

                let Some(list) = orders.get() else {
                    return view! { <p class="term-error">"failed to load orders"</p> }.into_any();
                };

                if list.is_empty() {
                    return view! {
                        <div class="term-box p-8 text-center">
                            <p class="term-muted text-sm mb-4">"// no orders yet"</p>
                            <a href="/products" class="term-btn inline-block px-4 py-2 text-sm">"$ browse products →"</a>
                        </div>
                    }.into_any();
                }

                view! {
                    <div class="space-y-2">
                        {list.into_iter().map(|o| view! { <OrderRow order=o/> }).collect_view()}
                    </div>
                }.into_any()
            }}
        </div>
    }
}

#[component]
fn OrderRow(order: Order) -> impl IntoView {
    let href = format!("/orders/{}", order.id);
    let sclass = status_class(&order.status);
    view! {
        <a href=href class="term-row block p-3 hover:term-active">
            <div class="flex items-center justify-between gap-3">
                <div class="min-w-0">
                    <span class="text-[var(--fg-primary)] text-sm font-bold">{order.order_code}</span>
                    <span class="term-muted text-xs ml-2">{short_date(&order.created_at)}</span>
                </div>
                <span class=format!("text-xs {sclass}")>{order.status}</span>
            </div>
            <div class="flex items-center justify-between gap-3 mt-1 text-xs term-muted">
                <span>{format!("{} item(s)", order.item_count)}</span>
                <span class="text-[var(--fg-primary)]">{format!("${:.2}", order.total_amount)}</span>
            </div>
        </a>
    }
}

#[component]
pub fn OrderDetailPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let params = use_params_map();
    let id = move || params.get().get("id").unwrap_or_default();

    let order = RwSignal::new(None::<Order>);
    let loading = RwSignal::new(true);
    let error = RwSignal::new(None::<ApiError>);

    Effect::new(move |_| {
        let oid = id();
        let token = auth.token.get().unwrap_or_default();
        loading.set(true);
        spawn_local(async move {
            match get_order(&token, &oid).await {
                Ok(o) => {
                    order.set(Some(o));
                    error.set(None);
                }
                Err(e) => error.set(Some(e)),
            }
            loading.set(false);
        });
    });

    view! {
        <div class="max-w-3xl mx-auto p-6">
            <a href="/orders" class="term-muted text-xs hover:underline">"< back to /orders"</a>

            {move || {
                if loading.get() {
                    return view! {
                        <p class="py-8"><Loading text="loading order"/></p>
                    }.into_any();
                }

                if let Some(err) = error.get() {
                    return match err {
                        ApiError::NotFound => view! {
                            <KernelPanic
                                code="404"
                                title="order not found"
                                detail="no such order, or you don't have access to it"
                                back_href="/orders"
                                back_label="< back to /orders"
                            />
                        }.into_any(),
                        other => view! {
                            <KernelPanic
                                code="500"
                                title="failed to load order"
                                detail=other.to_string()
                                back_href="/orders"
                                back_label="< back to /orders"
                            />
                        }.into_any(),
                    };
                }

                let Some(o) = order.get() else {
                    return view! { <p class="term-error">"failed to load order"</p> }.into_any();
                };

                let role = auth.user.get().map(|u| u.role).unwrap_or_default();
                // Seller/Admin can manage the order status.
                let can_manage = role == "Seller" || role == "Admin";
                // Customers can review products once the order is delivered.
                let can_review = role == "Customer" && o.status == "Delivered";

                view! {
                    <OrderDetailView order=o can_review=can_review/>
                    <Show when=move || can_manage>
                        <StatusManager order_signal=order/>
                    </Show>
                }.into_any()
            }}
        </div>
    }
}

#[component]
fn StatusManager(order_signal: RwSignal<Option<Order>>) -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let toasts = use_context::<ToastContext>().expect("ToastContext must be provided");
    let busy = RwSignal::new(false);
    let msg = RwSignal::new(String::new());

    // Selected status, seeded from the current order.
    let current = order_signal.get().map(|o| o.status).unwrap_or_default();
    let selected = RwSignal::new(current);

    let terminal = move || {
        order_signal
            .get()
            .map(|o| o.status == "Delivered" || o.status == "Cancelled")
            .unwrap_or(false)
    };

    let apply = move |_| {
        if busy.get() {
            return;
        }
        let Some(o) = order_signal.get() else { return };
        let target = selected.get();
        if target == o.status {
            msg.set("status unchanged".to_string());
            return;
        }
        busy.set(true);
        msg.set(String::new());
        let token = auth.token.get().unwrap_or_default();
        let id = o.id.clone();
        spawn_local(async move {
            match update_order_status(&token, &id, &target).await {
                Ok(updated) => {
                    toasts.info(format!("status → {}", updated.status));
                    selected.set(updated.status.clone());
                    order_signal.set(Some(updated));
                    msg.set("status updated".to_string());
                }
                Err(e) => {
                    msg.set(format!("error: {e}"));
                    toasts.error(e.to_string());
                }
            }
            busy.set(false);
        });
    };

    view! {
        <div class="term-box p-4 mt-4">
            <p class="term-muted text-xs mb-2"># manage status (seller/admin)</p>
            <Show
                when=move || !terminal()
                fallback=|| view! {
                    <p class="term-muted text-sm">"order is finalized — status can no longer change."</p>
                }
            >
                <div class="flex items-center gap-2 flex-wrap">
                    <select
                        class="term-input px-3 py-1.5 text-sm"
                        prop:value=move || selected.get()
                        on:change=move |ev| selected.set(event_target_value(&ev))
                    >
                        {ORDER_STATUSES.iter().map(|s| {
                            view! { <option value=*s>{*s}</option> }
                        }).collect_view()}
                    </select>
                    <button
                        class="term-btn px-4 py-1.5 text-sm"
                        disabled=move || busy.get()
                        on:click=apply
                    >
                        {move || if busy.get() { "updating..." } else { "$ update status" }}
                    </button>
                </div>
            </Show>
            <Show when=move || !msg.get().is_empty()>
                <p class="term-warn text-xs mt-2">{move || msg.get()}</p>
            </Show>
        </div>
    }
}

#[component]
fn OrderDetailView(order: Order, #[prop(default = false)] can_review: bool) -> impl IntoView {
    let sclass = status_class(&order.status);
    let a = order.address.clone();
    let addr_line = [a.street, a.ward, a.district, a.city]
        .into_iter()
        .filter(|s| !s.is_empty())
        .collect::<Vec<_>>()
        .join(", ");

    view! {
        <div class="mt-4">
            <div class="flex items-center justify-between gap-3 mb-4">
                <div>
                    <h1 class="text-lg font-bold text-[var(--fg-primary)]">{order.order_code.clone()}</h1>
                    <p class="term-muted text-xs">{short_date(&order.created_at)}</p>
                </div>
                <span class=format!("text-sm {sclass}")>{order.status.clone()}</span>
            </div>

            // ── Items ────────────────────────────────────────────────────
            <div class="term-box overflow-hidden">
                <div class="grid grid-cols-[1fr_auto_auto] gap-3 px-4 py-2 text-xs term-muted border-b border-[var(--border)]">
                    <span>"product"</span>
                    <span class="text-center w-16">"qty"</span>
                    <span class="text-right w-24">"total"</span>
                </div>
                {order.items.into_iter().map(|item| {
                    let img = item.image_url.clone().unwrap_or_default();
                    let pid = item.product_id.clone();
                    let pname = item.product_name.clone();
                    view! {
                        <div class="border-b border-[var(--border)] last:border-0">
                            <div class="grid grid-cols-[1fr_auto_auto] gap-3 px-4 py-3 items-center">
                                <div class="flex items-center gap-3 min-w-0">
                                    <div class="term-box w-12 h-12 shrink-0 overflow-hidden flex items-center justify-center bg-[var(--bg-tertiary)]">
                                        {if img.is_empty() {
                                            view! { <span class="term-muted text-lg">"[ ]"</span> }.into_any()
                                        } else {
                                            view! { <img src=img class="w-full h-full object-cover"/> }.into_any()
                                        }}
                                    </div>
                                    <div class="min-w-0">
                                        <a href=format!("/products/{}", item.product_slug) class="text-sm text-[var(--fg-primary)] hover:underline truncate block">
                                            {item.product_name}
                                        </a>
                                        <div class="text-xs term-muted">
                                            {format!("${:.2}", item.unit_price)}
                                            {item.shop_name.map(|s| format!(" · {s}"))}
                                        </div>
                                    </div>
                                </div>
                                <span class="text-center w-16 text-sm">{item.quantity}</span>
                                <span class="text-right w-24 text-sm text-[var(--fg-primary)]">{format!("${:.2}", item.total_price)}</span>
                            </div>
                            {can_review.then(|| view! {
                                <ReviewForm product_id=pid product_name=pname/>
                            })}
                        </div>
                    }
                }).collect_view()}
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
                // ── Shipping address ─────────────────────────────────────
                <div class="term-sub p-4">
                    <p class="term-muted text-xs mb-2"># ship to</p>
                    <p class="text-sm text-[var(--fg-primary)]">{order.address.full_name.clone()}</p>
                    <p class="text-sm term-muted">{order.address.phone.clone()}</p>
                    <p class="text-sm term-muted">{addr_line}</p>
                    {(!order.note.is_empty()).then(|| view! {
                        <p class="text-xs term-muted mt-2">{format!("note: {}", order.note)}</p>
                    })}
                </div>

                // ── Totals ───────────────────────────────────────────────
                <div class="term-sub p-4">
                    <div class="flex justify-between text-sm mb-1">
                        <span class="term-muted">"items:"</span>
                        <span>{order.item_count}</span>
                    </div>
                    <div class="flex justify-between text-sm mb-1">
                        <span class="term-muted">"shipping:"</span>
                        <span>{format!("${:.2}", order.shipping_fee)}</span>
                    </div>
                    <div class="flex justify-between text-base border-t border-[var(--border)] pt-2 mt-2">
                        <span class="term-muted">"total:"</span>
                        <span class="text-[var(--fg-primary)] font-bold">{format!("${:.2}", order.total_amount)}</span>
                    </div>
                </div>
            </div>
        </div>
    }
}

/// Inline review form shown per product on a delivered order.
#[component]
fn ReviewForm(product_id: String, product_name: String) -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let toasts = use_context::<ToastContext>().expect("ToastContext must be provided");

    let product_id = StoredValue::new(product_id);
    let rating = RwSignal::new(5);
    let comment = RwSignal::new(String::new());
    let busy = RwSignal::new(false);
    let done = RwSignal::new(false);
    let msg = RwSignal::new(String::new());

    let submit = move |_| {
        if busy.get() {
            return;
        }
        busy.set(true);
        msg.set(String::new());
        let token = auth.token.get().unwrap_or_default();
        let pid = product_id.get_value();
        let r = rating.get();
        let c = comment.get().trim().to_string();
        spawn_local(async move {
            match create_review(&token, &pid, r, &c).await {
                Ok(_) => {
                    done.set(true);
                    msg.set("✓ thanks — your review was submitted".to_string());
                    toasts.success("review submitted");
                }
                Err(e) => {
                    msg.set(format!("error: {e}"));
                    toasts.error(e.to_string());
                }
            }
            busy.set(false);
        });
    };

    view! {
        <div class="px-4 pb-3">
            <Show
                when=move || !done.get()
                fallback=move || view! {
                    <p class="term-info text-xs">{move || msg.get()}</p>
                }
            >
                <div class="term-sub p-3">
                    <p class="term-muted text-xs mb-2">{format!("# review: {product_name}")}</p>
                    // ── star picker ──────────────────────────────────────
                    <div class="flex items-center gap-1 mb-2">
                        {(1..=5).map(|n| {
                            view! {
                                <button
                                    type="button"
                                    class="term-warn text-lg leading-none"
                                    on:click=move |_| rating.set(n)
                                >
                                    {move || if rating.get() >= n { "★" } else { "☆" }}
                                </button>
                            }
                        }).collect_view()}
                        <span class="term-muted text-xs ml-2">{move || format!("{}/5", rating.get())}</span>
                    </div>
                    <textarea
                        class="term-input w-full px-3 py-2 text-sm mb-2"
                        rows="2"
                        placeholder="write your review (optional)"
                        prop:value=move || comment.get()
                        on:input=move |ev| comment.set(event_target_value(&ev))
                    ></textarea>
                    <div class="flex items-center gap-3">
                        <button
                            class="term-btn px-4 py-1.5 text-sm"
                            disabled=move || busy.get()
                            on:click=submit
                        >
                            {move || if busy.get() { "submitting..." } else { "$ submit review" }}
                        </button>
                        <Show when=move || !msg.get().is_empty()>
                            <span class="term-warn text-xs">{move || msg.get()}</span>
                        </Show>
                    </div>
                </div>
            </Show>
        </div>
    }
}
