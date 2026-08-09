use leptos::prelude::*;
use leptos::task::spawn_local;

use crate::api::{
    admin_approve_shop, admin_reject_shop, create_category, delete_category, get_admin_dashboard,
    list_categories, list_shops, update_category, CategoryNode, CategoryPayload, DashboardStats,
    ShopInfo,
};
use crate::auth::AuthContext;
use crate::components::loading::Loading;

/// Converts a display name to a URL slug (lowercase, dashes).
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

/// Flattens the category tree into `(id, name, slug, description, parent_id, product_count, depth)`.
fn flatten(nodes: &[CategoryNode], depth: usize, out: &mut Vec<(CategoryNode, usize)>) {
    for n in nodes {
        out.push((n.clone(), depth));
        if let Some(children) = &n.children {
            flatten(children, depth + 1, out);
        }
    }
}

async fn load_shops(token: String, status: Option<String>) -> Result<Vec<ShopInfo>, String> {
    list_shops(&token, status.as_deref()).await.map_err(|e| e.to_string())
}

#[component]
pub fn AdminPage() -> impl IntoView {
    let section = RwSignal::new("dashboard".to_string());

    let tabs = ["dashboard", "shops", "categories"];

    view! {
        <div class="max-w-4xl mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --admin"</p>
            <h1 class="text-lg font-bold mb-4">"> admin :: control panel"</h1>

            <div class="flex gap-2 mb-6 text-sm border-b border-[var(--border)] pb-2">
                {tabs.into_iter().map(|t| {
                    let t = t.to_string();
                    let t_active = t.clone();
                    let t_click = t.clone();
                    view! {
                        <button
                            class="term-btn px-3 py-1 text-xs"
                            class:term-active=move || section.get() == t_active
                            on:click=move |_| section.set(t_click.clone())
                        >{t}</button>
                    }
                }).collect_view()}
            </div>

            {move || match section.get().as_str() {
                "shops" => view! { <ShopModeration/> }.into_any(),
                "categories" => view! { <CategoryManagement/> }.into_any(),
                _ => view! { <AdminDashboard/> }.into_any(),
            }}
        </div>
    }
}

/// Renders a fixed-width ASCII bar `[####      ]` scaled to `max`.
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
fn AdminDashboard() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");

    let stats = RwSignal::new(None::<DashboardStats>);
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());

    {
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            match get_admin_dashboard(&token).await {
                Ok(s) => stats.set(Some(s)),
                Err(e) => error.set(e.to_string()),
            }
            loading.set(false);
        });
    }

    view! {
        <Show when=move || !error.get().is_empty()>
            <p class="term-error text-sm mb-3">"[ERROR] " {move || error.get()}</p>
        </Show>

        {move || {
            if loading.get() {
                return view! {
                    <p><Loading text="loading stats"/></p>
                }.into_any();
            }
            let Some(s) = stats.get() else {
                return view! { <p class="term-error">"failed to load dashboard"</p> }.into_any();
            };

            let max_order = s.orders_by_status.iter().map(|o| o.count).max().unwrap_or(0);

            view! {
                // ── stat cards ────────────────────────────────────────────
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
                    <StatCard label="users" value=s.total_users.to_string()/>
                    <StatCard label="shops" value=s.total_shops.to_string()/>
                    <StatCard label="products" value=s.total_products.to_string()/>
                    <StatCard label="orders" value=s.total_orders.to_string()/>
                </div>

                <div class="term-box p-4 mb-6">
                    <p class="term-muted text-xs mb-1"># revenue (non-cancelled)</p>
                    <p class="text-2xl font-bold text-[var(--fg-primary)]">{format!("${:.2}", s.total_revenue)}</p>
                </div>

                // ── system monitor ───────────────────────────────────────
                <div class="term-box p-4 mb-6 font-mono text-sm overflow-x-auto">
                    <p class="term-muted text-xs mb-3"># system monitor</p>
                    <MeterRow label="shops approved" value=s.approved_shops max=s.total_shops/>
                    <MeterRow label="shops pending " value=s.pending_shops max=s.total_shops/>
                    <MeterRow label="products live " value=s.active_products max=s.total_products/>
                </div>

                // ── orders by status ─────────────────────────────────────
                <div class="term-box p-4 font-mono text-sm overflow-x-auto">
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
            }.into_any()
        }}
    }
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

#[component]
fn MeterRow(label: &'static str, value: i32, max: i32) -> impl IntoView {
    let pct = if max > 0 { (value as f64 / max as f64 * 100.0).round() as i32 } else { 0 };
    view! {
        <div class="flex items-center gap-2 mb-1">
            <span class="term-muted w-32">{label}</span>
            <span class="term-info">{meter(value, max, 16)}</span>
            <span class="term-muted w-20 text-right">{format!("{value}/{max} {pct}%")}</span>
        </div>
    }
}

#[component]
fn ShopModeration() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");

    let shops = RwSignal::new(Vec::<ShopInfo>::new());
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());
    let filter = RwSignal::new(Some("Pending".to_string()));
    let refresh = RwSignal::new(());
    let flash = RwSignal::new(String::new());

    let load = move || {
        let token = auth.token.get().unwrap_or_default();
        let f = filter.get();
        let rx = refresh.get();
        spawn_local(async move {
            loading.set(true);
            match load_shops(token, f).await {
                Ok(list) => shops.set(list),
                Err(e) => error.set(e),
            }
            loading.set(false);
            let _ = rx;
        });
    };

    Effect::new(move |_| {
        refresh.get();
        load();
    });

    let set_filter = move |name: &str| {
        filter.set(if name == "All" { None } else { Some(name.to_string()) });
        flash.set(String::new());
        refresh.set(());
    };

    view! {
        <h2 class="text-base font-bold mb-3">"# shop moderation"</h2>

        <div class="flex gap-2 mb-4 text-sm">
            {["All", "Pending", "Approved", "Rejected"].into_iter().map(|label| {
                let label = label.to_string();
                let label_active = label.clone();
                let label_click = label.clone();
                view! {
                    <button
                        class="term-btn px-3 py-1 text-xs"
                        class:term-active=move || match filter.get() {
                            None => label_active == "All",
                            Some(ref f) => *f == label_active,
                        }
                        on:click=move |_| set_filter(&label_click)
                    >{label}</button>
                }
            }).collect_view()}
        </div>

        <Show when=move || !flash.get().is_empty()>
            <p class="term-info text-sm mb-2">"[OK] " {move || flash.get()}</p>
        </Show>
        <p class="term-error text-sm mb-2" class:invisible=move || error.get().is_empty()>
            "[ERROR] " {move || error.get()}
        </p>

        <div>
            {move || {
                if loading.get() {
                    view! { <p><Loading text="loading shops"/></p> }.into_any()
                } else if shops.get().is_empty() {
                    view! { <p class="term-muted">"no shops in this filter"</p> }.into_any()
                } else {
                    let list = shops.get();
                    let count = list.len();
                    view! {
                        <p class="term-muted text-xs mb-2">{format!("// showing {count} shop(s)")}</p>
                        <div class="flex flex-col gap-3">
                            {list.into_iter().map(|shop| view! {
                                <AdminShopRow shop=shop auth=auth refresh=refresh flash=flash/>
                            }).collect_view()}
                        </div>
                    }.into_any()
                }
            }}
        </div>
    }
}

#[component]
fn AdminShopRow(
    shop: ShopInfo,
    auth: AuthContext,
    refresh: RwSignal<()>,
    flash: RwSignal<String>,
) -> impl IntoView {
    let shop_id = shop.id.clone();
    let acting = RwSignal::new(false);
    let row_error = RwSignal::new(String::new());
    let shop_name = shop.name.clone();

    let status = shop.status.clone();
    let status_display = status.clone();
    let status_badge = status.clone();
    let badge = match status_badge.as_str() {
        "Approved" => "term-info",
        "Pending" => "term-warn",
        "Rejected" | "Banned" => "term-error",
        _ => "term-muted",
    };

    let approve_id = shop_id.clone();
    let approve_name = shop_name.clone();
    let approve = move |_| {
        let token = auth.token.get().unwrap_or_default();
        let id = approve_id.clone();
        let name = approve_name.clone();
        acting.set(true);
        row_error.set(String::new());
        spawn_local(async move {
            match admin_approve_shop(&token, &id).await {
                Ok(_) => {
                    flash.set(format!("approved '{name}' — owner is now Seller"));
                    refresh.set(());
                }
                Err(e) => row_error.set(e.to_string()),
            }
            acting.set(false);
        });
    };

    let reject_id = shop_id.clone();
    let reject_name = shop_name.clone();
    let reject = move |_| {
        let token = auth.token.get().unwrap_or_default();
        let id = reject_id.clone();
        let name = reject_name.clone();
        acting.set(true);
        row_error.set(String::new());
        spawn_local(async move {
            match admin_reject_shop(&token, &id).await {
                Ok(_) => {
                    flash.set(format!("rejected '{name}'"));
                    refresh.set(());
                }
                Err(e) => row_error.set(e.to_string()),
            }
            acting.set(false);
        });
    };

    view! {
        <div class="term-box p-4 flex justify-between items-start gap-4">
            <div class="min-w-0">
                <h3 class="font-bold text-[var(--fg-primary)]">{shop.name.clone()}</h3>
                <p class="term-muted text-xs mt-0.5">"slug: " {shop.slug.clone()} " | owner: " {shop.owner_name.clone()}</p>
                <p class="text-sm mt-1 break-words">{shop.description.clone()}</p>
                <p class="mt-2 text-xs"><span class=badge>"[" {status_badge} "]"</span></p>
                <p class="term-error text-xs mt-1" class:invisible=move || row_error.get().is_empty()>
                    {move || row_error.get()}
                </p>
            </div>
            <div
                class="flex gap-2 shrink-0"
                style:display=move || if status_display == "Pending" { "flex" } else { "none" }
            >
                <button class="term-btn px-3 py-1 text-xs" prop:disabled=move || acting.get()
                    on:click=approve>"approve"</button>
                <button class="term-btn px-3 py-1 text-xs" prop:disabled=move || acting.get()
                    on:click=reject>"reject"</button>
            </div>
        </div>
    }
}

#[component]
fn CategoryManagement() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");

    let tree = RwSignal::new(Vec::<CategoryNode>::new());
    let loading = RwSignal::new(true);
    let error = RwSignal::new(String::new());
    let flash = RwSignal::new(String::new());
    let refresh = RwSignal::new(());

    // Form state (shared by create + edit).
    let editing_id = RwSignal::new(None::<String>);
    let name = RwSignal::new(String::new());
    let slug = RwSignal::new(String::new());
    let description = RwSignal::new(String::new());
    let parent_id = RwSignal::new(String::new()); // "" = root
    let auto_slug = RwSignal::new(true);
    let submitting = RwSignal::new(false);

    Effect::new(move |_| {
        refresh.get();
        let token = auth.token.get().unwrap_or_default();
        let _ = token; // list is public but keep symmetry
        spawn_local(async move {
            loading.set(true);
            match list_categories().await {
                Ok(list) => tree.set(list),
                Err(e) => error.set(e.to_string()),
            }
            loading.set(false);
        });
    });

    let reset_form = move || {
        editing_id.set(None);
        name.set(String::new());
        slug.set(String::new());
        description.set(String::new());
        parent_id.set(String::new());
        auto_slug.set(true);
    };

    let start_edit = move |c: CategoryNode| {
        editing_id.set(Some(c.id.clone()));
        name.set(c.name.clone());
        slug.set(c.slug.clone());
        description.set(c.description.clone());
        parent_id.set(c.parent_id.clone().unwrap_or_default());
        auto_slug.set(false);
        flash.set(String::new());
        error.set(String::new());
    };

    let submit = move |_| {
        if submitting.get() {
            return;
        }
        if name.get().trim().is_empty() || slug.get().trim().is_empty() {
            error.set("name và slug là bắt buộc".to_string());
            return;
        }
        submitting.set(true);
        error.set(String::new());
        let token = auth.token.get().unwrap_or_default();
        let pid = parent_id.get();
        let payload = CategoryPayload {
            name: name.get().trim().to_string(),
            slug: slug.get().trim().to_string(),
            description: description.get().trim().to_string(),
            parent_id: if pid.is_empty() { None } else { Some(pid) },
        };
        let edit = editing_id.get();
        spawn_local(async move {
            let result = match &edit {
                Some(id) => update_category(&token, id, &payload).await,
                None => create_category(&token, &payload).await,
            };
            match result {
                Ok(c) => {
                    flash.set(format!(
                        "{} '{}'",
                        if edit.is_some() { "updated" } else { "created" },
                        c.name
                    ));
                    reset_form();
                    refresh.set(());
                }
                Err(e) => error.set(e.to_string()),
            }
            submitting.set(false);
        });
    };

    let delete_cat = move |id: String, cname: String| {
        let token = auth.token.get().unwrap_or_default();
        error.set(String::new());
        spawn_local(async move {
            match delete_category(&token, &id).await {
                Ok(_) => {
                    flash.set(format!("deleted '{cname}'"));
                    refresh.set(());
                }
                Err(e) => error.set(e.to_string()),
            }
        });
    };

    // Rows + parent <select> options come from the flattened tree.
    let rows = move || {
        let mut out = Vec::new();
        flatten(&tree.get(), 0, &mut out);
        out
    };

    view! {
        <h2 class="text-base font-bold mb-3">"# category management"</h2>

        <Show when=move || !flash.get().is_empty()>
            <p class="term-info text-sm mb-2">"[OK] " {move || flash.get()}</p>
        </Show>
        <Show when=move || !error.get().is_empty()>
            <p class="term-error text-sm mb-2">"[ERROR] " {move || error.get()}</p>
        </Show>

        // ── Form ──────────────────────────────────────────────────────────
        <div class="term-box p-4 mb-6">
            <p class="term-muted text-xs mb-3">
                {move || if editing_id.get().is_some() { "# edit category" } else { "# new category" }}
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                    <label class="block mb-1 text-xs term-muted">"name"</label>
                    <input
                        class="term-input w-full px-3 py-2 text-sm"
                        prop:value=move || name.get()
                        on:input=move |ev| {
                            let v = event_target_value(&ev);
                            if auto_slug.get() { slug.set(slugify(&v)); }
                            name.set(v);
                        }
                    />
                </div>
                <div>
                    <label class="block mb-1 text-xs term-muted">"slug"</label>
                    <input
                        class="term-input w-full px-3 py-2 text-sm"
                        prop:value=move || slug.get()
                        on:input=move |ev| { auto_slug.set(false); slug.set(event_target_value(&ev)); }
                    />
                </div>
                <div>
                    <label class="block mb-1 text-xs term-muted">"parent"</label>
                    <select
                        class="term-input w-full px-3 py-2 text-sm"
                        prop:value=move || parent_id.get()
                        on:change=move |ev| parent_id.set(event_target_value(&ev))
                    >
                        <option value="">"— none (root) —"</option>
                        {move || {
                            let editing = editing_id.get();
                            rows().into_iter().filter_map(|(c, depth)| {
                                // A category cannot be its own parent.
                                if editing.as_deref() == Some(c.id.as_str()) {
                                    return None;
                                }
                                let label = format!("{}{}", "  ".repeat(depth), c.name);
                                Some(view! { <option value=c.id.clone()>{label}</option> })
                            }).collect_view()
                        }}
                    </select>
                </div>
                <div>
                    <label class="block mb-1 text-xs term-muted">"description"</label>
                    <input
                        class="term-input w-full px-3 py-2 text-sm"
                        prop:value=move || description.get()
                        on:input=move |ev| description.set(event_target_value(&ev))
                    />
                </div>
            </div>
            <div class="flex gap-2 mt-3">
                <button class="term-btn px-4 py-1.5 text-sm" disabled=move || submitting.get() on:click=submit>
                    {move || if submitting.get() {
                        "saving...".to_string()
                    } else if editing_id.get().is_some() {
                        "$ update".to_string()
                    } else {
                        "$ create".to_string()
                    }}
                </button>
                <Show when=move || editing_id.get().is_some()>
                    <button class="term-btn px-4 py-1.5 text-sm" on:click=move |_| reset_form()>"cancel"</button>
                </Show>
            </div>
        </div>

        // ── Tree list ─────────────────────────────────────────────────────
        <div>
            {move || {
                if loading.get() {
                    return view! { <p><Loading text="loading categories"/></p> }.into_any();
                }
                let list = rows();
                if list.is_empty() {
                    return view! { <p class="term-muted">"no categories yet"</p> }.into_any();
                }
                view! {
                    <div class="term-box overflow-hidden">
                        {list.into_iter().map(|(c, depth)| {
                            let indent = "  ".repeat(depth);
                            let c_edit = c.clone();
                            let del_id = c.id.clone();
                            let del_name = c.name.clone();
                            view! {
                                <div class="flex items-center justify-between gap-3 px-4 py-2 border-b border-[var(--border)] last:border-0">
                                    <div class="min-w-0 font-mono text-sm">
                                        <span class="term-muted">{format!("{indent}└ ")}</span>
                                        <span class="text-[var(--fg-primary)]">{c.name.clone()}</span>
                                        <span class="term-muted text-xs">{format!("  /{}  ({} products)", c.slug, c.product_count)}</span>
                                    </div>
                                    <div class="flex gap-2 shrink-0">
                                        <button class="term-btn px-2 py-0.5 text-xs" on:click=move |_| start_edit(c_edit.clone())>"edit"</button>
                                        <button class="term-btn px-2 py-0.5 text-xs text-[var(--fg-error)]"
                                            on:click=move |_| delete_cat(del_id.clone(), del_name.clone())>"del"</button>
                                    </div>
                                </div>
                            }
                        }).collect_view()}
                    </div>
                }.into_any()
            }}
        </div>
    }
}
