use leptos::prelude::*;
use leptos::task::spawn_local;
use std::rc::Rc;

use crate::api::{
    create_product, create_shop, delete_product, get_my_shop, get_seller_dashboard,
    list_categories, list_my_products, list_seller_sales, update_product, update_shop, CategoryNode,
    CreateShopPayload, Order, ProductInfo, ProductPayload, SellerDashboard, ShopInfo,
};
use crate::auth::AuthContext;
use crate::components::input::TermInput;
use crate::components::loading::Loading;

async fn load_shop(token: String) -> Result<Option<ShopInfo>, String> {
    get_my_shop(&token).await.map_err(|e| e.to_string())
}

fn slugify(raw: &str) -> String {
    let mut out = String::new();
    let mut prev_dash = false;
    for c in raw.to_lowercase().chars() {
        if c.is_alphanumeric() {
            out.push(c);
            prev_dash = false;
        } else if !out.is_empty() && !prev_dash {
            out.push('-');
            prev_dash = true;
        }
    }
    while out.ends_with('-') {
        out.pop();
    }
    out
}

/// Flattens the category tree into `(id, indented_label)` pairs for a `<select>`.
fn flatten_categories(nodes: &[CategoryNode], depth: usize, out: &mut Vec<(String, String)>) {
    for n in nodes {
        let prefix = "  ".repeat(depth);
        out.push((n.id.clone(), format!("{prefix}{}", n.name)));
        if let Some(children) = &n.children {
            flatten_categories(children, depth + 1, out);
        }
    }
}

#[component]
pub fn SellerPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");

    let shop = RwSignal::new(None::<ShopInfo>);
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());
    let section = RwSignal::new("dashboard".to_string());
    let created = RwSignal::new(None::<ShopInfo>);
    let flash = RwSignal::new(String::new());

    {
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            match load_shop(token).await {
                Ok(s) => shop.set(s),
                Err(e) => error.set(e),
            }
            loading.set(false);
        });
    }

    Effect::new(move |_| {
        if let Some(s) = created.get() {
            shop.set(Some(s));
            section.set("dashboard".to_string());
            created.set(None);
        }
    });

    view! {
        <div class="max-w-4xl mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --seller"</p>
            <h1 class="text-lg font-bold mb-4">"> seller dashboard"</h1>

            {move || {
                if loading.get() {
                    view! { <p><Loading text="loading shop"/></p> }.into_any()
                } else if !error.get().is_empty() {
                    view! { <p class="term-error">"[ERROR] " {error.get()}</p> }.into_any()
                } else if shop.get().is_none() {
                    view! { <CreateShopForm auth=auth on_created=created/> }.into_any()
                } else {
                    view! {
                        <div class="flex flex-col sm:flex-row gap-4 sm:items-start">
                            <SellerSidebar shop=shop.get().unwrap() section=section/>
                            <div class="flex-1 min-w-0">
                                <SellerContent shop=shop auth=auth section=section flash=flash/>
                            </div>
                        </div>
                    }.into_any()
                }
            }}
        </div>
    }
}

#[component]
fn SellerSidebar(shop: ShopInfo, section: RwSignal<String>) -> impl IntoView {
    let approved = shop.status == "Approved";
    let items = vec!["dashboard", "sales", "products", "settings"];

    view! {
        <aside class="term-box p-3 w-full sm:w-44 shrink-0">
            <p class="term-muted text-xs mb-2">"~ menu"</p>
            <nav class="flex flex-row sm:flex-col gap-1">
                {items.into_iter().map(|label| {
                    let label = label.to_string();
                    let label_active = label.clone();
                    let label_active_cls = label.clone();
                    let label_active_txt = label.clone();
                    let label_click = label.clone();
                    let enabled = (label != "products" && label != "sales") || approved;
                    view! {
                        <button
                            class="term-menu-item px-2 py-1.5 text-sm text-left"
                            class:term-active=move || section.get() == label_active
                            class:term-disabled=move || !enabled
                            on:click=move |_| if enabled { section.set(label_click.clone()) }
                        >
                            {move || {
                                let cur = section.get();
                                if cur == label_active_txt {
                                    format!("> {label_active_cls}")
                                } else {
                                    format!("  {label_active_cls}")
                                }
                            }}
                        </button>
                    }
                }).collect_view()}
            </nav>
        </aside>
    }
}

#[component]
fn SellerContent(shop: RwSignal<Option<ShopInfo>>, auth: AuthContext, section: RwSignal<String>, flash: RwSignal<String>) -> impl IntoView {
    Effect::new(move |_| {
        let _ = section.get();
        flash.set(String::new());
    });

    view! {
        <div>
            <p class="term-info text-sm mb-2" class:invisible=move || flash.get().is_empty()>
                "[OK] " {move || flash.get()}
            </p>
            {move || {
                let s = section.get();
                if s == "settings" {
                    view! { <ShopSettings shop=shop flash=flash/> }.into_any()
                } else if s == "products" {
                    let current = shop.get().clone().unwrap();
                    if current.status == "Approved" {
                        view! { <ProductManager auth=auth/> }.into_any()
                    } else {
                        view! {
                            <div class="term-box p-5">
                                <p class="term-warn text-sm">"Shop chưa được duyệt. Chưa thể quản lý sản phẩm."</p>
                            </div>
                        }.into_any()
                    }
                } else if s == "sales" {
                    let current = shop.get().clone().unwrap();
                    if current.status == "Approved" {
                        view! { <SalesManager auth=auth/> }.into_any()
                    } else {
                        view! {
                            <div class="term-box p-5">
                                <p class="term-warn text-sm">"Shop chưa được duyệt. Chưa có đơn bán."</p>
                            </div>
                        }.into_any()
                    }
                } else {
                    let current = shop.get().clone().unwrap();
                    view! {
                        <RevenueDashboard/>
                        <ShopStatus shop=current/>
                    }.into_any()
                }
            }}
        </div>
    }
}

/// ASCII bar for a value out of `max`, `width` chars wide.
fn meter(value: i32, max: i32, width: usize) -> String {
    let filled = if max <= 0 {
        0
    } else {
        ((value as f64 / max as f64) * width as f64).round() as usize
    }
    .min(width);
    format!("[{}{}]", "#".repeat(filled), " ".repeat(width - filled))
}

#[component]
fn StatCard(label: &'static str, value: String) -> impl IntoView {
    view! {
        <div class="term-box p-3">
            <p class="term-muted text-xs">{label}</p>
            <p class="text-xl font-bold text-[var(--fg-primary)]">{value}</p>
        </div>
    }
}

/// Revenue + order statistics scoped to the seller's own shop.
#[component]
fn RevenueDashboard() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");

    let stats = RwSignal::new(None::<SellerDashboard>);
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());

    {
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            match get_seller_dashboard(&token).await {
                Ok(s) => stats.set(Some(s)),
                Err(e) => error.set(e.to_string()),
            }
            loading.set(false);
        });
    }

    view! {
        <div class="mb-4">
            <Show when=move || !error.get().is_empty()>
                <p class="term-error text-sm mb-3">"[ERROR] " {move || error.get()}</p>
            </Show>

            {move || {
                if loading.get() {
                    return view! { <p><Loading text="loading stats"/></p> }.into_any();
                }
                let Some(s) = stats.get() else {
                    return view! { <span></span> }.into_any();
                };

                let max_order = s.orders_by_status.iter().map(|o| o.count).max().unwrap_or(0);
                let top = s.top_products.clone();

                view! {
                    // ── revenue headline ─────────────────────────────────
                    <div class="term-box p-4 mb-4">
                        <p class="term-muted text-xs mb-1"># doanh thu (đơn chưa hủy)</p>
                        <p class="text-2xl font-bold text-[var(--fg-primary)]">
                            {format!("${:.2}", s.total_revenue)}
                        </p>
                    </div>

                    // ── stat cards ───────────────────────────────────────
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
                        <StatCard label="orders" value=s.total_orders.to_string()/>
                        <StatCard label="pending" value=s.pending_orders.to_string()/>
                        <StatCard label="items sold" value=s.items_sold.to_string()/>
                        <StatCard label="products" value=format!("{}/{}", s.active_products, s.total_products)/>
                    </div>

                    // ── orders by status ─────────────────────────────────
                    <div class="term-box p-4 mb-4 font-mono text-sm overflow-x-auto">
                        <p class="term-muted text-xs mb-3"># orders by status</p>
                        {s.orders_by_status.into_iter().map(|o| {
                            let label = format!("{:<10}", o.status);
                            view! {
                                <div class="flex items-center gap-2 mb-1">
                                    <span class="term-muted w-24">{label}</span>
                                    <span class="term-info">{meter(o.count, max_order, 16)}</span>
                                    <span class="term-muted w-8 text-right">{o.count}</span>
                                </div>
                            }
                        }).collect_view()}
                    </div>

                    // ── top products ─────────────────────────────────────
                    <div class="term-box p-4 mb-4">
                        <p class="term-muted text-xs mb-3"># top products (by revenue)</p>
                        {if top.is_empty() {
                            view! { <p class="term-muted text-sm">"// chưa có đơn hàng nào"</p> }.into_any()
                        } else {
                            view! {
                                <div class="flex flex-col gap-1">
                                    {top.into_iter().enumerate().map(|(i, p)| {
                                        view! {
                                            <div class="flex items-center justify-between gap-3 text-sm border-b border-[var(--border)] last:border-0 py-1">
                                                <span class="min-w-0 truncate">
                                                    <span class="term-muted">{format!("{}. ", i + 1)}</span>
                                                    {p.name}
                                                    <span class="term-muted text-xs">{format!(" ×{}", p.quantity_sold)}</span>
                                                </span>
                                                <span class="shrink-0 text-[var(--fg-primary)]">{format!("${:.2}", p.revenue)}</span>
                                            </div>
                                        }
                                    }).collect_view()}
                                </div>
                            }.into_any()
                        }}
                    </div>
                }.into_any()
            }}
        </div>
    }
}

/// Status options for the sales filter; "" means all statuses.
const SALES_STATUSES: &[&str] = &[
    "", "Pending", "Confirmed", "Processing", "Shipped", "Delivered",
    "ReturnRequested", "Returned", "Cancelled",
];

/// Terminal color class for an order status.
fn sales_status_class(status: &str) -> &'static str {
    match status {
        "Delivered" => "term-info",
        "Cancelled" | "Returned" => "term-error",
        "Shipped" | "Processing" | "Confirmed" | "ReturnRequested" => "term-warn",
        _ => "term-muted", // Pending
    }
}

/// Incoming orders for the seller's shop, with a status filter. Each row links to
/// the shared order detail page where the seller can advance the order status.
#[component]
fn SalesManager(auth: AuthContext) -> impl IntoView {
    let orders = RwSignal::new(Vec::<Order>::new());
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());
    let filter = RwSignal::new(String::new());

    Effect::new(move |_| {
        let status = filter.get();
        let token = auth.token.get().unwrap_or_default();
        loading.set(true);
        error.set(String::new());
        spawn_local(async move {
            match list_seller_sales(&token, &status).await {
                Ok(list) => orders.set(list),
                Err(e) => error.set(e.to_string()),
            }
            loading.set(false);
        });
    });

    view! {
        <div class="term-box p-5">
            <div class="flex justify-between items-center mb-3 gap-3 flex-wrap">
                <h3 class="font-bold text-[var(--fg-primary)]">"> sales"</h3>
                <select
                    class="term-input px-3 py-1.5 text-sm"
                    on:change=move |ev| filter.set(event_target_value(&ev))
                >
                    {SALES_STATUSES.iter().map(|s| {
                        let label = if s.is_empty() { "all statuses" } else { *s };
                        view! { <option value=*s>{label}</option> }
                    }).collect_view()}
                </select>
            </div>

            <p class="term-error text-sm mb-2" class:invisible=move || error.get().is_empty()>
                "[ERROR] " {move || error.get()}
            </p>

            {move || {
                if loading.get() {
                    return view! { <p><Loading text="loading sales"/></p> }.into_any();
                }
                let list = orders.get();
                if list.is_empty() {
                    return view! {
                        <p class="term-muted text-sm">"// chưa có đơn bán nào"</p>
                    }.into_any();
                }
                view! {
                    <div class="flex flex-col gap-2">
                        {list.into_iter().map(|o| view! { <SalesRow order=o/> }).collect_view()}
                    </div>
                }.into_any()
            }}
        </div>
    }
}

#[component]
fn SalesRow(order: Order) -> impl IntoView {
    let href = format!("/orders/{}", order.id);
    let sclass = sales_status_class(&order.status);
    let date: String = order.created_at.chars().take(10).collect();
    view! {
        <a href=href class="term-row block p-3">
            <div class="flex items-center justify-between gap-3">
                <div class="min-w-0">
                    <span class="text-[var(--fg-primary)] text-sm font-bold">{order.order_code}</span>
                    <span class="term-muted text-xs ml-2">{date}</span>
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
fn ShopStatus(shop: ShopInfo) -> impl IntoView {
    let status = shop.status.clone();
    let badge = match status.as_str() {
        "Approved" => "term-info",
        "Pending" => "term-warn",
        "Rejected" => "term-error",
        "Banned" => "term-error",
        _ => "term-muted",
    };

    view! {
        <div class="term-box p-5">
            <h2 class="font-bold text-[var(--fg-primary)]">{shop.name.clone()}</h2>
            <p class="term-muted text-sm mt-1">"slug: " {shop.slug.clone()}</p>
            <p class="text-sm mt-2">{shop.description.clone()}</p>
            <p class="mt-3 text-sm"><span class=badge>"[" {status.clone()} "]"</span></p>
            {move || {
                let status = status.clone();
                if status == "Pending" {
                    view! {
                        <p class="term-warn text-sm mt-3">
                            "Đang chờ admin duyệt. Kiểm tra lại sau."
                        </p>
                    }.into_any()
                } else if status == "Rejected" {
                    view! {
                        <p class="term-error text-sm mt-3">
                            "Shop bị từ chối. Liên hệ admin để biết chi tiết."
                        </p>
                    }.into_any()
                } else {
                    view! { <p></p> }.into_any()
                }
            }}
        </div>
    }
}

#[component]
fn ShopSettings(shop: RwSignal<Option<ShopInfo>>, flash: RwSignal<String>) -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let current = shop.get().unwrap();
    let name = RwSignal::new(current.name.clone());
    let slug = RwSignal::new(current.slug.clone());
    let description = RwSignal::new(current.description.clone());
    let submitting = RwSignal::new(false);
    let error = RwSignal::new(String::new());

    let on_slug = move |raw: String| slug.set(raw);

    let on_submit = move |_| {
        error.set(String::new());
        let payload = CreateShopPayload {
            name: name.get(),
            slug: slug.get(),
            description: description.get(),
        };

        if payload.name.trim().is_empty() || payload.slug.trim().is_empty() {
            error.set("name and slug are required".to_string());
            return;
        }

        let token = auth.token.get().unwrap_or_default();
        submitting.set(true);
        spawn_local(async move {
            match update_shop(&token, &payload).await {
                Ok(updated) => {
                    shop.set(Some(updated));
                    flash.set("Đã lưu thay đổi.".to_string());
                }
                Err(e) => error.set(e.to_string()),
            }
            submitting.set(false);
        });
    };

    view! {
        <div class="term-box p-5">
            <h3 class="font-bold text-[var(--fg-primary)] mb-4">"> shop settings"</h3>

            <TermInput id="set-name" label="shop name" value=name/>
            <TermInput id="set-slug" label="slug" value=slug on_input=Box::new(on_slug)/>
            <TermInput id="set-desc" label="description" value=description/>

            <p class="term-error text-sm mb-2" class:invisible=move || error.get().is_empty()>
                "[ERROR] " {move || error.get()}
            </p>

            <button
                class="term-btn w-full mt-2 px-3 py-2 text-sm"
                on:click=move |_| on_submit(())
                prop:disabled=move || submitting.get()
            >
                {move || if submitting.get() {
                    "saving..._".to_string()
                } else {
                    "$ save settings".to_string()
                }}
            </button>
        </div>
    }
}

#[component]
fn CreateShopForm(auth: AuthContext, on_created: RwSignal<Option<ShopInfo>>) -> impl IntoView {
    let name = RwSignal::new(String::new());
    let slug = RwSignal::new(String::new());
    let description = RwSignal::new(String::new());
    let slug_edited = RwSignal::new(false);
    let submitting = RwSignal::new(false);
    let error = RwSignal::new(String::new());

    let on_name = move |_name: String| {
        if !slug_edited.get() {
            slug.set(slugify(&name.get()));
        }
    };

    let on_slug = move |raw: String| {
        slug_edited.set(true);
        slug.set(raw);
    };

    let on_submit = move |_| {
        error.set(String::new());
        let payload = CreateShopPayload {
            name: name.get(),
            slug: slug.get(),
            description: description.get(),
        };

        if payload.name.trim().is_empty() || payload.slug.trim().is_empty() {
            error.set("name and slug are required".to_string());
            return;
        }

        let token = auth.token.get().unwrap_or_default();
        submitting.set(true);
        spawn_local(async move {
            match create_shop(&token, &payload).await {
                Ok(shop) => {
                    // Opening a shop promotes the user to Seller server-side; refresh
                    // the token so the new role takes effect without a manual re-login.
                    let _ = auth.refresh_session().await;
                    on_created.set(Some(shop));
                }
                Err(e) => error.set(e.to_string()),
            }
            submitting.set(false);
        });
    };

    view! {
        <div class="term-box p-5">
            <p class="text-sm mb-4 term-muted">
                "Bạn chưa có shop. Đăng ký để trở thành seller:"
            </p>

            <TermInput id="shop-name" label="shop name" placeholder="Tech Hub Vietnam" value=name
                on_input=Box::new(on_name)/>
            <TermInput id="shop-slug" label="slug" placeholder="tech-hub-vn" value=slug
                on_input=Box::new(on_slug)/>
            <TermInput id="shop-desc" label="description" placeholder="Gadgets and electronics" value=description/>

            <p class="term-error text-sm mb-2" class:invisible=move || error.get().is_empty()>
                "[ERROR] " {move || error.get()}
            </p>

            <button
                class="term-btn w-full mt-2 px-3 py-2 text-sm"
                on:click=move |_| on_submit(())
                prop:disabled=move || submitting.get()
            >
                {move || if submitting.get() {
                    "submitting..._".to_string()
                } else {
                    "$ create shop".to_string()
                }}
            </button>
        </div>
    }
}

#[component]
fn ProductManager(auth: AuthContext) -> impl IntoView {
    let products = RwSignal::new(Vec::<ProductInfo>::new());
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());
    let refresh = RwSignal::new(());
    let show_form = RwSignal::new(false);
    let categories = RwSignal::new(Vec::<(String, String)>::new());

    spawn_local(async move {
        if let Ok(tree) = list_categories().await {
            let mut flat = Vec::new();
            flatten_categories(&tree, 0, &mut flat);
            categories.set(flat);
        }
    });

    let load = move || {
        let token = auth.token.get().unwrap_or_default();
        let rx = refresh.get();
        spawn_local(async move {
            loading.set(true);
            match list_my_products(&token).await {
                Ok(list) => products.set(list),
                Err(e) => error.set(e.to_string()),
            }
            loading.set(false);
            let _ = rx;
        });
    };

    Effect::new(move |_| {
        refresh.get();
        load();
    });

    let on_created = move |_p: ProductInfo| {
        show_form.set(false);
        refresh.set(());
    };

    view! {
        <div class="term-box p-5">
            <div class="flex justify-between items-center mb-3">
                <h3 class="font-bold text-[var(--fg-primary)]">"> products"</h3>
                <button
                    class="term-btn px-3 py-1 text-xs"
                    on:click=move |_| show_form.set(!show_form.get())
                >
                    {move || if show_form.get() { "- cancel" } else { "+ new product" }}
                </button>
            </div>

            <p class="term-error text-sm mb-2" class:invisible=move || error.get().is_empty()>
                "[ERROR] " {move || error.get()}
            </p>

            {move || if show_form.get() {
                view! {
                    <ProductForm auth=auth categories=categories on_saved=Box::new(on_created)/>
                }.into_any()
            } else {
                view! { <p></p> }.into_any()
            }}

            {move || {
                if loading.get() {
                    view! { <p><Loading text="loading products"/></p> }.into_any()
                } else if products.get().is_empty() {
                    view! { <p class="term-muted">"no products yet. use + new product to add one."</p> }.into_any()
                } else {
                    let list = products.get();
                    view! {
                        <div class="flex flex-col gap-2">
                            {list.into_iter().map(|p| view! {
                                <ProductRow product=p auth=auth categories=categories refresh=refresh/>
                            }).collect_view()}
                        </div>
                    }.into_any()
                }
            }}
        </div>
    }
}

#[component]
fn ProductRow(
    product: ProductInfo,
    auth: AuthContext,
    categories: RwSignal<Vec<(String, String)>>,
    refresh: RwSignal<()>,
) -> impl IntoView {
    let acting = RwSignal::new(false);
    let row_error = RwSignal::new(String::new());
    let editing = RwSignal::new(false);

    let delete_id = product.id.clone();
    let on_delete = move |_| {
        let token = auth.token.get().unwrap_or_default();
        let id = delete_id.clone();
        acting.set(true);
        row_error.set(String::new());
        spawn_local(async move {
            match delete_product(&token, &id).await {
                Ok(_) => refresh.set(()),
                Err(e) => row_error.set(e.to_string()),
            }
            acting.set(false);
        });
    };

    let price_text = format!("{:?}", product.price);
    let sale_text = product.sale_price.map(|v| format!("{:?}", v)).unwrap_or_default();
    let badge = if product.is_active { "term-info" } else { "term-muted" };
    let active_label = if product.is_active { "active" } else { "hidden" };
    let category_label = product.category_name.clone().unwrap_or_default();

    let product_for_edit = product.clone();
    let on_saved = move |_p: ProductInfo| {
        editing.set(false);
        refresh.set(());
    };

    view! {
        <div class="term-row p-3">
            <div class="flex justify-between items-start gap-3">
                <div class="min-w-0">
                    <h4 class="font-bold text-[var(--fg-primary)]">{product.name.clone()}</h4>
                    <p class="term-muted text-xs mt-0.5">"slug: " {product.slug.clone()} " | sku: " {product.sku.clone()}</p>
                    <p class="text-xs mt-1">
                        <span class=badge>"[" {active_label} "]"</span>
                        " " {price_text} " đ | stock: " {product.stock_quantity.to_string()}
                        {move || {
                            if sale_text.is_empty() {
                                "".to_string()
                            } else {
                                format!(" | sale: {sale_text} đ")
                            }
                        }}
                        {(!category_label.is_empty()).then(|| format!(" | cat: {category_label}"))}
                    </p>
                    <p class="term-error text-xs mt-1" class:invisible=move || row_error.get().is_empty()>
                        {move || row_error.get()}
                    </p>
                </div>
                <div class="flex gap-2 shrink-0">
                    <button
                        class="term-btn px-2 py-1 text-xs"
                        on:click=move |_| editing.set(!editing.get())
                    >
                        {move || if editing.get() { "cancel" } else { "edit" }}
                    </button>
                    <button
                        class="term-btn px-2 py-1 text-xs"
                        on:click=on_delete
                        prop:disabled=move || acting.get()
                    >
                        "delete"
                    </button>
                </div>
            </div>

            {move || if editing.get() {
                view! {
                    <div class="mt-3">
                        <ProductForm
                            auth=auth
                            categories=categories
                            edit=product_for_edit.clone()
                            on_saved=Box::new(on_saved)
                        />
                    </div>
                }.into_any()
            } else {
                view! { <span></span> }.into_any()
            }}
        </div>
    }
}

#[component]
fn ProductForm(
    auth: AuthContext,
    categories: RwSignal<Vec<(String, String)>>,
    #[prop(optional)] edit: Option<ProductInfo>,
    on_saved: Box<dyn Fn(ProductInfo)>,
) -> impl IntoView {
    let on_saved: Rc<dyn Fn(ProductInfo)> = Rc::from(on_saved);
    let is_edit = edit.is_some();
    let edit_id = edit.as_ref().map(|p| p.id.clone());

    let name = RwSignal::new(edit.as_ref().map(|p| p.name.clone()).unwrap_or_default());
    let slug = RwSignal::new(edit.as_ref().map(|p| p.slug.clone()).unwrap_or_default());
    let description = RwSignal::new(edit.as_ref().map(|p| p.description.clone()).unwrap_or_default());
    let price = RwSignal::new(edit.as_ref().map(|p| p.price.to_string()).unwrap_or_default());
    let sale = RwSignal::new(
        edit.as_ref()
            .and_then(|p| p.sale_price)
            .map(|v| v.to_string())
            .unwrap_or_default(),
    );
    let stock = RwSignal::new(edit.as_ref().map(|p| p.stock_quantity.to_string()).unwrap_or_default());
    let sku = RwSignal::new(edit.as_ref().map(|p| p.sku.clone()).unwrap_or_default());
    let category_id = RwSignal::new(edit.as_ref().and_then(|p| p.category_id.clone()).unwrap_or_default());
    let images = RwSignal::new(
        edit.as_ref()
            .map(|p| p.images.iter().map(|i| i.url.clone()).collect::<Vec<_>>().join("\n"))
            .unwrap_or_default(),
    );
    let is_active = RwSignal::new(edit.as_ref().map(|p| p.is_active).unwrap_or(true));
    // In edit mode the slug is pre-filled, so don't overwrite it from the name.
    let slug_edited = RwSignal::new(is_edit);
    let submitting = RwSignal::new(false);
    let error = RwSignal::new(String::new());

    let on_name = move |_v: String| {
        if !slug_edited.get() {
            slug.set(slugify(&name.get()));
        }
    };

    let on_slug = move |raw: String| {
        slug_edited.set(true);
        slug.set(raw);
    };

    let on_submit = move |_| {
        error.set(String::new());
        let price_val: f64 = price.get().trim().parse().unwrap_or(0.0);
        let stock_val: i32 = stock.get().trim().parse().unwrap_or(0);
        let sale_val: Option<f64> = {
            let s = sale.get();
            let s = s.trim();
            if s.is_empty() { None } else { s.parse().ok() }
        };
        let cat: Option<String> = {
            let c = category_id.get();
            if c.is_empty() { None } else { Some(c) }
        };
        let imgs: Vec<String> = images
            .get()
            .lines()
            .map(|l| l.trim().to_string())
            .filter(|l| !l.is_empty())
            .collect();

        if name.get().trim().is_empty() || slug.get().trim().is_empty() {
            error.set("name and slug are required".to_string());
            return;
        }

        let payload = ProductPayload {
            name: name.get(),
            slug: slug.get(),
            description: description.get(),
            price: price_val,
            sale_price: sale_val,
            stock_quantity: stock_val,
            sku: sku.get(),
            category_id: cat,
            is_active: is_active.get(),
            images: imgs,
        };

        let token = auth.token.get().unwrap_or_default();
        let on_saved = on_saved.clone();
        let edit_id = edit_id.clone();
        submitting.set(true);
        spawn_local(async move {
            let result = match &edit_id {
                Some(id) => update_product(&token, id, &payload).await,
                None => create_product(&token, &payload).await,
            };
            match result {
                Ok(p) => on_saved(p),
                Err(e) => error.set(e.to_string()),
            }
            submitting.set(false);
        });
    };

    view! {
        <div class="term-sub p-4 mb-3">
            <TermInput id="prod-name" label="name" placeholder="Mechanical Keyboard" value=name
                on_input=Box::new(on_name)/>
            <TermInput id="prod-slug" label="slug" placeholder="mechanical-keyboard" value=slug
                on_input=Box::new(on_slug)/>
            <TermInput id="prod-desc" label="description" placeholder="Cherry MX brown switches" value=description/>
            <div class="flex gap-3">
                <div class="flex-1">
                    <TermInput id="prod-price" label="price" input_type="number" placeholder="890000" value=price/>
                </div>
                <div class="flex-1">
                    <TermInput id="prod-sale" label="sale price" input_type="number" placeholder="(optional)" value=sale/>
                </div>
            </div>
            <div class="flex gap-3">
                <div class="flex-1">
                    <TermInput id="prod-stock" label="stock" input_type="number" placeholder="10" value=stock/>
                </div>
                <div class="flex-1">
                    <TermInput id="prod-sku" label="sku" placeholder="KB-001" value=sku/>
                </div>
            </div>

            <label class="block mb-1 text-xs term-muted">"category"</label>
            <div class="flex items-center gap-2 mb-3">
                <span class="term-info text-sm shrink-0">">"</span>
                <select
                    class="term-input w-full px-3 py-2 text-sm"
                    on:change=move |ev| category_id.set(event_target_value(&ev))
                >
                    <option value="" selected=move || category_id.get().is_empty()>"(no category)"</option>
                    {move || {
                        let cur = category_id.get();
                        categories.get().into_iter().map(|(id, label)| {
                            let sel = id == cur;
                            view! { <option value=id selected=sel>{label}</option> }
                        }).collect_view()
                    }}
                </select>
            </div>

            <label class="block mb-1 text-xs term-muted">"image urls (one per line)"</label>
            <div class="flex items-start gap-2 mb-3">
                <span class="term-info text-sm shrink-0">">"</span>
                <textarea
                    class="term-input w-full px-3 py-2 text-sm"
                    rows="3"
                    placeholder="https://img.ks.com/a.jpg"
                    prop:value=move || images.get()
                    on:input=move |ev| images.set(event_target_value(&ev))
                ></textarea>
            </div>

            {is_edit.then(|| view! {
                <label class="flex items-center gap-2 mb-3 text-sm cursor-pointer">
                    <input
                        type="checkbox"
                        prop:checked=move || is_active.get()
                        on:change=move |ev| is_active.set(event_target_checked(&ev))
                    />
                    <span class="term-muted">"active (visible in store)"</span>
                </label>
            })}

            <p class="term-error text-sm mb-2" class:invisible=move || error.get().is_empty()>
                "[ERROR] " {move || error.get()}
            </p>
            <button
                class="term-btn w-full mt-1 px-3 py-2 text-sm"
                on:click=on_submit
                prop:disabled=move || submitting.get()
            >
                {move || if submitting.get() {
                    "saving..._".to_string()
                } else if is_edit {
                    "$ update product".to_string()
                } else {
                    "$ save product".to_string()
                }}
            </button>
        </div>
    }
}
