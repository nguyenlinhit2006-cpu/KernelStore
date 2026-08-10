use leptos::prelude::*;
use leptos::task::spawn_local;
use leptos_router::hooks::{use_navigate, use_query_map};

use crate::api::{list_categories, list_products, CategoryNode, ProductCard, ProductQuery};
use crate::components::loading::Loading;

const PAGE_SIZE: u32 = 12;

#[component]
pub fn ProductsPage() -> impl IntoView {
    let query = use_query_map();
    let navigate = use_navigate();

    // Controlled inputs for the free-text filters; kept in sync with the URL.
    let search = RwSignal::new(String::new());
    let min_price = RwSignal::new(String::new());
    let max_price = RwSignal::new(String::new());

    Effect::new(move |_| {
        let q = query.get();
        search.set(q.get("search").unwrap_or_default());
        min_price.set(q.get("minPrice").unwrap_or_default());
        max_price.set(q.get("maxPrice").unwrap_or_default());
    });

    // Single entry point for URL mutations. `updates` maps a query key to a new
    // value (`None` removes it); filter changes reset pagination back to page 1.
    let apply = Callback::new(move |(updates, reset_page): (Vec<(&'static str, Option<String>)>, bool)| {
        let mut map = query.get_untracked();
        for (k, v) in updates {
            match v {
                Some(val) if !val.trim().is_empty() => map.replace(k, val.trim().to_string()),
                _ => {
                    map.remove(k);
                }
            }
        }
        if reset_page {
            map.remove("page");
        }
        navigate(&format!("/products{}", map.to_query_string()), Default::default());
    });

    let products = LocalResource::new(move || {
        let q = query.get();
        let pq = ProductQuery {
            category: q.get("category"),
            shop: q.get("shop"),
            min_price: q.get("minPrice").and_then(|s| s.parse().ok()),
            max_price: q.get("maxPrice").and_then(|s| s.parse().ok()),
            search: q.get("search"),
            sort: q.get("sort"),
            page: q.get("page").and_then(|s| s.parse().ok()).unwrap_or(1),
            page_size: PAGE_SIZE,
        };
        async move { list_products(&pq).await }
    });

    let categories = LocalResource::new(|| async move { list_categories().await });

    let active_category = move || query.get().get("category").unwrap_or_default();
    let active_sort = move || query.get().get("sort").unwrap_or_default();
    let active_shop = move || query.get().get("shop").unwrap_or_default();

    // Applies the search + price inputs together.
    let submit_filters = move || {
        apply.run((
            vec![
                ("search", Some(search.get())),
                ("minPrice", Some(min_price.get())),
                ("maxPrice", Some(max_price.get())),
            ],
            true,
        ));
    };

    let has_filters = move || {
        let q = query.get();
        ["category", "shop", "minPrice", "maxPrice", "search", "sort"]
            .iter()
            .any(|k| q.get(k).is_some_and(|v| !v.is_empty()))
    };

    // ── Live search suggestions (type ≥2 chars → dropdown of matches) ──────
    let suggestions = RwSignal::new(Vec::<ProductCard>::new());
    let sugg_open = RwSignal::new(false);
    let nav_sugg = use_navigate();

    let fetch_suggestions = move |term: String| {
        if term.trim().len() < 2 {
            suggestions.set(Vec::new());
            sugg_open.set(false);
            return;
        }
        spawn_local(async move {
            let pq = ProductQuery {
                category: None,
                shop: None,
                min_price: None,
                max_price: None,
                search: Some(term.clone()),
                sort: None,
                page: 1,
                page_size: 6,
            };
            if let Ok(res) = list_products(&pq).await {
                // Only apply if the input still holds the same term (avoid stale results).
                if search.get_untracked() == term {
                    let empty = res.items.is_empty();
                    suggestions.set(res.items);
                    sugg_open.set(!empty);
                }
            }
        });
    };

    view! {
        <div class="p-6 max-w-7xl mx-auto">
            <div class="mb-6">
                <p class="term-muted text-xs mb-1">
                    "~/products"
                    {move || {
                        let c = active_category();
                        (!c.is_empty()).then(|| format!("/{c}"))
                    }}
                    <span class="caret">"_"</span>
                </p>
                <h1 class="text-xl font-bold text-[var(--fg-primary)]">"$ ls ./products"</h1>
            </div>

            <div class="flex flex-col lg:flex-row gap-6">
                // ── Filter sidebar ──────────────────────────────────────────
                <aside class="lg:w-64 shrink-0 space-y-4">
                    // search + price
                    <div class="term-box p-3">
                        <p class="text-xs term-info mb-2">"# filter"</p>
                        <label class="block text-xs term-muted mb-1">"search"</label>
                        <div class="flex items-center gap-2 mb-3">
                            <span class="term-info text-sm shrink-0">">"</span>
                            <div class="relative w-full">
                                <input
                                    class="term-input w-full px-2 py-1 text-sm"
                                    placeholder="grep name..."
                                    prop:value=move || search.get()
                                    on:input=move |ev| {
                                        let v = event_target_value(&ev);
                                        search.set(v.clone());
                                        fetch_suggestions(v);
                                    }
                                    on:focus=move |_| {
                                        if !suggestions.get().is_empty() { sugg_open.set(true); }
                                    }
                                    on:blur=move |_| sugg_open.set(false)
                                    on:keydown=move |ev| {
                                        if ev.key() == "Enter" {
                                            sugg_open.set(false);
                                            submit_filters();
                                        } else if ev.key() == "Escape" {
                                            sugg_open.set(false);
                                        }
                                    }
                                />
                                {move || sugg_open.get().then(|| {
                                    let items = suggestions.get();
                                    view! {
                                        <ul class="absolute z-30 left-0 right-0 mt-1 term-box p-1 max-h-72 overflow-y-auto shadow-lg">
                                            {items.into_iter().map(|p| {
                                                let slug = p.slug.clone();
                                                let nav = nav_sugg.clone();
                                                let price = p.sale_price.unwrap_or(p.price);
                                                view! {
                                                    <li
                                                        class="term-menu-item px-2 py-1.5 text-sm cursor-pointer flex justify-between gap-2"
                                                        on:mousedown=move |ev| {
                                                            ev.prevent_default();
                                                            sugg_open.set(false);
                                                            nav(&format!("/products/{slug}"), Default::default());
                                                        }
                                                    >
                                                        <span class="truncate">{p.name.clone()}</span>
                                                        <span class="term-muted text-xs shrink-0">{format!("${price:.2}")}</span>
                                                    </li>
                                                }
                                            }).collect_view()}
                                        </ul>
                                    }
                                })}
                            </div>
                        </div>
                        <label class="block text-xs term-muted mb-1">"price range"</label>
                        <div class="flex items-center gap-2 mb-3">
                            <input
                                class="term-input w-full px-2 py-1 text-sm"
                                type="number"
                                placeholder="min"
                                prop:value=move || min_price.get()
                                on:input=move |ev| min_price.set(event_target_value(&ev))
                            />
                            <span class="term-muted">"—"</span>
                            <input
                                class="term-input w-full px-2 py-1 text-sm"
                                type="number"
                                placeholder="max"
                                prop:value=move || max_price.get()
                                on:input=move |ev| max_price.set(event_target_value(&ev))
                            />
                        </div>
                        <button
                            class="term-btn w-full px-2 py-1 text-sm"
                            on:click=move |_| submit_filters()
                        >
                            "apply filters"
                        </button>
                        <Show when=move || has_filters()>
                            <button
                                class="term-btn w-full px-2 py-1 text-sm mt-2 term-warn"
                                on:click=move |_| apply.run((
                                    vec![
                                        ("category", None),
                                        ("shop", None),
                                        ("minPrice", None),
                                        ("maxPrice", None),
                                        ("search", None),
                                        ("sort", None),
                                    ],
                                    true,
                                ))
                            >
                                "clear all"
                            </button>
                        </Show>
                    </div>

                    // sort
                    <div class="term-box p-3">
                        <p class="text-xs term-info mb-2">"# sort"</p>
                        <select
                            class="term-input w-full px-2 py-1 text-sm"
                            prop:value=move || active_sort()
                            on:change=move |ev| {
                                apply.run((vec![("sort", Some(event_target_value(&ev)))], true));
                            }
                        >
                            <option value="">"newest"</option>
                            <option value="price_asc">"price ↑"</option>
                            <option value="price_desc">"price ↓"</option>
                            <option value="name">"name a-z"</option>
                        </select>
                    </div>

                    // categories
                    <div class="term-box p-3">
                        <p class="text-xs term-info mb-2">"# categories"</p>
                        <button
                            class=move || format!(
                                "term-menu-item block w-full text-left px-2 py-1 text-sm {}",
                                if active_category().is_empty() { "term-active" } else { "" }
                            )
                            on:click=move |_| apply.run((vec![("category", None)], true))
                        >
                            "all"
                        </button>
                        <Suspense fallback=move || view! { <p class="term-muted text-xs px-2 py-1">"loading..."</p> }>
                            {move || match categories.get().map(|c| c.take()) {
                                None => view! { <span></span> }.into_any(),
                                Some(Err(err)) => view! {
                                    <p class="term-error text-xs px-2 py-1">{err.to_string()}</p>
                                }.into_any(),
                                Some(Ok(cats)) if cats.is_empty() => view! {
                                    <p class="term-muted text-xs px-2 py-1">"(none)"</p>
                                }.into_any(),
                                Some(Ok(cats)) => view! {
                                    <div>
                                        {cats.into_iter().map(|cat| view! {
                                            <CategoryItem cat=cat depth=0 apply=apply active=Signal::derive(active_category)/>
                                        }).collect_view()}
                                    </div>
                                }.into_any(),
                            }}
                        </Suspense>
                    </div>
                </aside>

                // ── Product grid ────────────────────────────────────────────
                <section class="flex-1 min-w-0">
                    <Show when=move || !active_shop().is_empty()>
                        <p class="term-info text-xs mb-3">"filtered by shop: " {active_shop}</p>
                    </Show>
                    <Transition fallback=move || view! {
                        <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                            {(0..6).map(|_| view! { <CardSkeleton/> }).collect_view()}
                        </div>
                    }>
                        {move || match products.get().map(|p| p.take()) {
                            None => view! { <p class="py-12 text-center"><Loading text="loading products"/></p> }.into_any(),
                            Some(Err(err)) => view! {
                                <p class="term-error py-12 text-center">"error: " {err.to_string()}</p>
                            }.into_any(),
                            Some(Ok(result)) if result.items.is_empty() => view! {
                                <div class="term-box p-12 text-center">
                                    <p class="term-muted">"$ ls: no products match your filters"</p>
                                </div>
                            }.into_any(),
                            Some(Ok(result)) => {
                                let total = result.total;
                                let page = result.page;
                                let total_pages = result.total_pages;
                                view! {
                                    <div class="flex items-center justify-between mb-4 text-xs term-muted">
                                        <span>{format!("{total} result(s)")}</span>
                                        <span>{format!("page {page}/{}", total_pages.max(1))}</span>
                                    </div>
                                    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                                        {result.items.into_iter().map(|product| view! {
                                            <ProductGridCard product=product/>
                                        }).collect_view()}
                                    </div>
                                    <Pagination page=page total_pages=total_pages apply=apply/>
                                }.into_any()
                            }
                        }}
                    </Transition>
                </section>
            </div>
        </div>
    }
}

#[component]
fn CategoryItem(
    cat: CategoryNode,
    depth: usize,
    apply: Callback<(Vec<(&'static str, Option<String>)>, bool)>,
    active: Signal<String>,
) -> impl IntoView {
    let slug = cat.slug.clone();
    let slug_for_click = slug.clone();
    let is_active = move || active.get() == slug;
    let indent = format!("padding-left: {}rem", 0.5 + depth as f32 * 0.75);
    let children = cat.children.unwrap_or_default();
    let count = cat.product_count;

    // Type-erase the recursive children so the component's opaque return type
    // does not reference itself.
    let children_view = (!children.is_empty()).then(|| {
        children
            .into_iter()
            .map(|child| {
                view! { <CategoryItem cat=child depth=depth + 1 apply=apply active=active/> }
                    .into_any()
            })
            .collect_view()
    });

    view! {
        <button
            class=move || format!(
                "term-menu-item flex justify-between w-full text-left px-2 py-1 text-sm {}",
                if is_active() { "term-active" } else { "" }
            )
            style=indent
            on:click=move |_| apply.run((vec![("category", Some(slug_for_click.clone()))], true))
        >
            <span>{cat.name}</span>
            <span class="term-muted text-xs">{count}</span>
        </button>
        {children_view}
    }
}

#[component]
fn Pagination(
    page: i32,
    total_pages: i32,
    apply: Callback<(Vec<(&'static str, Option<String>)>, bool)>,
) -> impl IntoView {
    if total_pages <= 1 {
        return view! { <span></span> }.into_any();
    }

    let go = move |target: i32| {
        apply.run((vec![("page", Some(target.to_string()))], false));
    };

    view! {
        <div class="flex items-center justify-center gap-2 mt-6">
            <button
                class="term-btn px-3 py-1 text-sm"
                disabled=page <= 1
                on:click=move |_| go(page - 1)
            >
                "< prev"
            </button>
            <span class="term-muted text-sm px-2">
                {format!("{page} / {total_pages}")}
            </span>
            <button
                class="term-btn px-3 py-1 text-sm"
                disabled=page >= total_pages
                on:click=move |_| go(page + 1)
            >
                "next >"
            </button>
        </div>
    }.into_any()
}

#[component]
fn ProductGridCard(product: ProductCard) -> impl IntoView {
    let image = product.primary_image();
    let price = product.sale_price.unwrap_or(product.price);
    let has_sale = product.sale_price.is_some();
    let href = format!("/products/{}", product.slug);
    let out_of_stock = product.stock_quantity <= 0;

    view! {
        <a href=href class="term-box p-0 flex flex-col group">
            <div class="relative aspect-square overflow-hidden bg-[var(--bg-tertiary)] flex items-center justify-center">
                {match image {
                    Some(url) => view! {
                        <img src=url alt=product.name.clone()
                            class="w-full h-full object-cover" loading="lazy"/>
                    }.into_any(),
                    None => view! {
                        <span class="term-muted text-4xl">"[ ]"</span>
                    }.into_any(),
                }}
                {has_sale.then(|| view! {
                    <span class="absolute top-2 left-2 px-2 py-0.5 text-xs term-active">"SALE"</span>
                })}
                {out_of_stock.then(|| view! {
                    <span class="absolute top-2 right-2 px-2 py-0.5 text-xs term-warn border border-[var(--warning)]">"0 stock"</span>
                })}
            </div>
            <div class="p-3 flex flex-col flex-1">
                <p class="text-xs term-info mb-1">
                    {product.category_name.unwrap_or_else(|| "uncategorized".to_string())}
                </p>
                <h3 class="text-sm text-[var(--fg-primary)] mb-1 line-clamp-1 group-hover:underline">
                    {product.name}
                </h3>
                <p class="text-xs term-muted line-clamp-2 flex-1 mb-2">
                    {product.description}
                </p>
                <div class="flex items-center justify-between pt-2 border-t border-[var(--border)]">
                    <div class="flex items-baseline gap-1">
                        <span class="text-sm font-bold text-[var(--fg-primary)]">
                            {format!("${:.2}", price)}
                        </span>
                        {has_sale.then(|| view! {
                            <span class="text-xs line-through term-muted">
                                {format!("${:.2}", product.price)}
                            </span>
                        })}
                    </div>
                    <span class="text-xs term-muted truncate max-w-[8rem]">
                        {product.shop_name.unwrap_or_else(|| "unknown".to_string())}
                    </span>
                </div>
            </div>
        </a>
    }
}

#[component]
fn CardSkeleton() -> impl IntoView {
    view! {
        <div class="term-box p-0 animate-pulse">
            <div class="aspect-square bg-[var(--bg-tertiary)]"></div>
            <div class="p-3 space-y-2">
                <div class="h-3 w-1/4 bg-[var(--bg-tertiary)]"></div>
                <div class="h-4 w-3/4 bg-[var(--bg-tertiary)]"></div>
                <div class="h-3 w-full bg-[var(--bg-tertiary)]"></div>
                <div class="h-4 w-1/2 bg-[var(--bg-tertiary)] mt-3"></div>
            </div>
        </div>
    }
}
