use leptos::prelude::*;
use leptos::task::spawn_local;
use leptos_router::hooks::use_params_map;

use crate::api::{
    add_to_cart, get_product, get_reviews, start_conversation, ApiError, ProductDetail,
    ReviewInfo,
};
use crate::auth::AuthContext;
use crate::components::error::KernelPanic;
use crate::components::loading::Loading;
use crate::components::toast::ToastContext;
use crate::i18n::use_i18n;

/// Renders `count` filled stars out of 5.
fn stars(count: i32) -> String {
    let n = count.clamp(0, 5) as usize;
    format!("{}{}", "★".repeat(n), "☆".repeat(5 - n))
}

#[component]
pub fn ProductDetailPage() -> impl IntoView {
    let params = use_params_map();
    let i18n = use_i18n();
    let slug = move || params.get().get("slug").unwrap_or_default();

    let product = LocalResource::new(move || {
        let s = slug();
        async move { get_product(&s).await }
    });

    view! {
        <div class="p-6 max-w-6xl mx-auto">
            <Transition fallback=move || view! {
                <p class="py-16 text-center"><Loading text=i18n.t("pd.loading")/></p>
            }>
                {move || match product.get().map(|p| p.take()) {
                    None => view! { <p class="py-16 text-center"><Loading text=i18n.t("pd.loading")/></p> }.into_any(),
                    Some(Err(ApiError::NotFound)) => view! {
                        <KernelPanic
                            code="404"
                            title=i18n.t("pd.not_found")
                            detail=i18n.t("pd.not_found_detail")
                            back_href="/products"
                            back_label=i18n.t("pd.back_products")
                        />
                    }.into_any(),
                    Some(Err(err)) => view! {
                        <KernelPanic
                            code="500"
                            title=i18n.t("pd.load_failed")
                            detail=err.to_string()
                            back_href="/products"
                            back_label=i18n.t("pd.back_products")
                        />
                    }.into_any(),
                    Some(Ok(p)) => view! { <ProductView product=p/> }.into_any(),
                }}
            </Transition>
        </div>
    }
}

#[component]
fn ProductView(product: ProductDetail) -> impl IntoView {
    let i18n = use_i18n();
    let price = product.sale_price.unwrap_or(product.price);
    let has_sale = product.sale_price.is_some();
    let in_stock = product.stock_quantity > 0;
    let category = product.category_name.clone().unwrap_or_else(|| i18n.t("products.uncategorized").to_string());

    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let navigate = leptos_router::hooks::use_navigate();
    let adding = RwSignal::new(false);
    let product_id = product.id.clone();

    // Gallery: currently-selected main image.
    let initial = product.primary_image().unwrap_or_default();
    let selected = RwSignal::new(initial.clone());
    let images = product.images.clone();

    // Cart flash message.
    let flash = RwSignal::new(String::new());
    let toasts = use_context::<ToastContext>().expect("ToastContext must be provided");

    let nav_cart = navigate.clone();
    let on_add = move |_| {
        if adding.get() {
            return;
        }
        // Must be logged in to have a cart.
        let Some(token) = auth.token.get().filter(|t| !t.is_empty()) else {
            nav_cart("/auth/login", Default::default());
            return;
        };
        adding.set(true);
        flash.set(String::new());
        let pid = product_id.clone();
        spawn_local(async move {
            match add_to_cart(&token, &pid, 1).await {
                Ok(cart) => {
                    flash.set(format!("{} ({} {})", i18n.t("pd.added_flash"), cart.total_items, i18n.t("common.items")));
                    toasts.success(format!("{} — {} {}", i18n.t("pd.added_flash"), cart.total_items, i18n.t("common.items")));
                }
                Err(e) => {
                    flash.set(format!("{}{e}", i18n.t("products.error")));
                    toasts.error(e.to_string());
                }
            }
            adding.set(false);
        });
    };

    let shop_id = product.shop.id.clone();
    let on_chat = move |_| {
        let Some(token) = auth.token.get().filter(|t| !t.is_empty()) else {
            navigate("/auth/login", Default::default());
            return;
        };
        let toasts = toasts.clone();
        let navigate = navigate.clone();
        let sid = shop_id.clone();
        spawn_local(async move {
            match start_conversation(&token, &sid).await {
                Ok(convo) => {
                    navigate(&format!("/chat?c={}", convo.id), Default::default());
                }
                Err(e) => {
                    toasts.error(format!("{}{e}", i18n.t("pd.chat_failed")));
                }
            }
        });
    };

    let shop_href = format!("/products?shop={}", product.shop.slug);
    let cat_slug = product.category_id.clone();
    let _ = cat_slug; // category filter link is keyed by slug on the list page

    view! {
        <p class="term-muted text-xs mb-4">
            "~/products/" {category.clone()} "/" {product.slug.clone()}
            <span class="caret">"_"</span>
        </p>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            // ── Gallery ──────────────────────────────────────────────────
            <div>
                <div class="term-box aspect-square overflow-hidden flex items-center justify-center bg-[var(--bg-tertiary)]">
                    {move || {
                        let url = selected.get();
                        if url.is_empty() {
                            view! { <span class="term-muted text-6xl">"[ ]"</span> }.into_any()
                        } else {
                            view! { <img src=url class="w-full h-full object-cover"/> }.into_any()
                        }
                    }}
                </div>
                <Show when={let n = images.len(); move || n > 1}>
                    <div class="flex gap-2 mt-3 flex-wrap">
                        {images.iter().map(|img| {
                            let url = img.url.clone();
                            let url_click = url.clone();
                            view! {
                                <button
                                    class=move || format!(
                                        "term-box w-16 h-16 overflow-hidden {}",
                                        if selected.get() == url { "term-active" } else { "" }
                                    )
                                    on:click=move |_| selected.set(url_click.clone())
                                >
                                    <img src=img.url.clone() class="w-full h-full object-cover"/>
                                </button>
                            }
                        }).collect_view()}
                    </div>
                </Show>
            </div>

            // ── Info ─────────────────────────────────────────────────────
            <div class="space-y-4">
                <p class="term-info text-xs">{category}</p>
                <h1 class="text-2xl font-bold text-[var(--fg-primary)]">{product.name.clone()}</h1>

                <div class="flex items-center gap-2 text-sm">
                    <span class="term-warn">{stars(product.average_rating.round() as i32)}</span>
                    <span class="term-muted">
                        {format!("{:.1} ({} {})", product.average_rating, product.review_count,
                            if product.review_count == 1 { i18n.t("pd.reviews_word") } else { i18n.t("pd.reviews_word_plural") })}
                    </span>
                </div>

                <div class="flex items-baseline gap-3">
                    <span class="text-3xl font-bold text-[var(--fg-primary)]">{format!("${:.2}", price)}</span>
                    {has_sale.then(|| view! {
                        <span class="text-lg line-through term-muted">{format!("${:.2}", product.price)}</span>
                    })}
                    {has_sale.then(|| view! {
                        <span class="term-active px-2 py-0.5 text-xs">"SALE"</span>
                    })}
                </div>

                <div class="text-sm space-y-1">
                    <p>
                        <span class="term-muted">{i18n.t("pd.stock")}</span>
                        {if in_stock {
                            view! { <span class="text-[var(--fg-primary)]">{format!("{} {}", product.stock_quantity, i18n.t("pd.available"))}</span> }.into_any()
                        } else {
                            view! { <span class="term-error">{i18n.t("pd.out_of_stock")}</span> }.into_any()
                        }}
                    </p>
                    <p><span class="term-muted">{i18n.t("pd.sku")}</span><span>{product.sku.clone()}</span></p>
                    <p>
                        <span class="term-muted">{i18n.t("pd.sold_by")}</span>
                        <a href=shop_href.clone() class="term-info hover:underline">{product.shop.name.clone()}</a>
                    </p>
                </div>

                <div class="pt-2">
                    <button
                        class="term-btn px-6 py-2 text-sm"
                        disabled=move || !in_stock || adding.get()
                        on:click=on_add
                    >
                        {move || if !in_stock {
                            i18n.t("pd.unavailable").to_string()
                        } else if adding.get() {
                            i18n.t("pd.adding").to_string()
                        } else {
                            i18n.t("pd.add_to_cart").to_string()
                        }}
                    </button>
                    <Show when=move || !flash.get().is_empty()>
                        <p class="term-warn text-xs mt-2">{move || flash.get()}</p>
                    </Show>
                </div>

                <div class="term-sub p-3 mt-4">
                    <p class="term-muted text-xs mb-1">{i18n.t("pd.description")}</p>
                    <p class="text-sm whitespace-pre-wrap">{product.description.clone()}</p>
                </div>
            </div>
        </div>

        // ── Shop summary ────────────────────────────────────────────────
        <div class="term-box p-4 mt-8 flex items-center justify-between gap-4">
            <div>
                <p class="text-xs term-muted mb-1">{i18n.t("pd.shop")}</p>
                <p class="text-[var(--fg-primary)] font-bold">{product.shop.name.clone()}</p>
                <p class="term-muted text-xs mt-1">
                    {format!("{} {}", product.shop.product_count, i18n.t("common.products"))}
                    {(!product.shop.description.is_empty()).then(|| format!(" · {}", product.shop.description))}
                </p>
            </div>
            <div class="flex gap-2">
                <button class="term-btn px-4 py-2 text-sm shrink-0" on:click=on_chat>
                    {i18n.t("pd.chat_seller")}
                </button>
                <a href=format!("/products?shop={}", product.shop.slug) class="term-btn px-4 py-2 text-sm shrink-0">
                    {i18n.t("pd.view_shop")}
                </a>
            </div>
        </div>

        // ── Reviews ─────────────────────────────────────────────────────
        <Reviews product_id=product.id.clone()/>
    }
}

/// Renders a 10-wide ASCII progress bar, e.g. `[####      ]`.
fn bar(ratio: f64) -> String {
    let filled = (ratio * 10.0).round().clamp(0.0, 10.0) as usize;
    format!("[{}{}]", "#".repeat(filled), " ".repeat(10 - filled))
}

#[component]
fn Reviews(product_id: String) -> impl IntoView {
    let i18n = use_i18n();
    let data = LocalResource::new({
        let pid = product_id.clone();
        move || {
            let pid = pid.clone();
            async move { get_reviews(&pid).await }
        }
    });

    view! {
        <div class="mt-8">
            <Transition fallback=move || view! {
                <p class="text-sm py-4"><Loading text=i18n.t("pd.loading_reviews")/></p>
            }>
                {move || match data.get().map(|d| d.take()) {
                    Some(Ok(r)) => {
                        let count = r.review_count;
                        // Distribution 5★ → 1★
                        let mut dist = [0usize; 5];
                        for rv in &r.reviews {
                            let idx = (rv.rating.clamp(1, 5) - 1) as usize;
                            dist[idx] += 1;
                        }
                        let total = r.reviews.len().max(1);

                        view! {
                            <h2 class="text-lg font-bold mb-4">
                                {i18n.t("pd.reviews")}
                                <span class="term-muted text-sm">{format!("({count})")}</span>
                            </h2>

                            {(count > 0).then(|| {
                                let avg = r.average_rating;
                                view! {
                                    <div class="term-box p-4 mb-4 flex flex-col sm:flex-row gap-6">
                                        <div class="text-center shrink-0">
                                            <p class="text-3xl font-bold text-[var(--fg-primary)]">{format!("{avg:.1}")}</p>
                                            <p class="term-warn text-sm">{stars(avg.round() as i32)}</p>
                                            <p class="term-muted text-xs mt-1">{format!("{count} {}", i18n.t("pd.ratings"))}</p>
                                        </div>
                                        <div class="flex-1 space-y-1">
                                            {(1..=5).rev().map(|star| {
                                                let c = dist[(star - 1) as usize];
                                                let ratio = c as f64 / total as f64;
                                                view! {
                                                    <div class="flex items-center gap-2 text-xs">
                                                        <span class="term-muted w-6">{format!("{star}★")}</span>
                                                        <span class="term-info font-mono">{bar(ratio)}</span>
                                                        <span class="term-muted w-6 text-right">{c}</span>
                                                    </div>
                                                }
                                            }).collect_view()}
                                        </div>
                                    </div>
                                }
                            })}

                            {if r.reviews.is_empty() {
                                view! { <p class="term-muted text-sm">{i18n.t("pd.no_reviews")}</p> }.into_any()
                            } else {
                                view! {
                                    <div class="space-y-3">
                                        {r.reviews.into_iter().map(|rv| view! { <ReviewCard review=rv/> }).collect_view()}
                                    </div>
                                }.into_any()
                            }}
                        }.into_any()
                    }
                    Some(Err(e)) => view! {
                        <p class="term-error text-sm">{i18n.t("pd.reviews_failed")} {e.to_string()}</p>
                    }.into_any(),
                    None => view! { <p class="term-muted text-sm py-4">{i18n.t("products.loading_dots")}</p> }.into_any(),
                }}
            </Transition>
        </div>
    }
}

#[component]
fn ReviewCard(review: ReviewInfo) -> impl IntoView {
    let date = review.created_at.chars().take(10).collect::<String>();
    view! {
        <div class="term-row p-3">
            <div class="flex items-center justify-between mb-1">
                <div class="flex items-center gap-2">
                    <span class="text-[var(--fg-primary)] text-sm">{review.user_name}</span>
                    <span class="term-warn text-sm">{stars(review.rating)}</span>
                </div>
                <span class="term-muted text-xs">{date}</span>
            </div>
            <p class="text-sm term-muted">{review.comment}</p>
        </div>
    }
}
