use leptos::prelude::*;

use crate::api::{featured_products, ProductCard};
use crate::auth::AuthContext;
use crate::components::loading::Loading;
use crate::i18n::use_i18n;

#[component]
pub fn HomePage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let i18n = use_i18n();
    let featured = LocalResource::new(|| async move { featured_products(8).await });

    view! {
        <div class="p-6">
            <section class="relative overflow-hidden bg-gradient-to-b from-[var(--bg)] to-[var(--bg-secondary)] py-16 lg:py-24">
                <div class="max-w-6xl mx-auto px-4">
                    <div class="text-center space-y-6">
                        <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[var(--accent)]/10 border border-[var(--accent)]/20 text-[var(--accent)] text-sm font-medium">
                            <span class="relative flex h-2 w-2">
                                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-[var(--accent)] opacity-75"></span>
                                <span class="relative inline-flex rounded-full h-2 w-2 bg-[var(--accent)]"></span>
                            </span>
                            {move || i18n.t("home.badge")}
                        </div>
                        <h1 class="text-4xl lg:text-6xl font-bold tracking-tight bg-gradient-to-r from-[var(--fg-primary)] via-[var(--fg-primary)] to-[var(--accent)] bg-clip-text text-transparent">
                            "KernelStore"
                        </h1>
                        <p class="text-lg lg:text-xl text-[var(--fg-muted)] max-w-2xl mx-auto leading-relaxed">
                            {move || i18n.t("home.tagline")}
                        </p>
                        <div class="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
                            <a href="/products" class="term-btn px-8 py-3 text-base font-medium">
                                {move || i18n.t("home.cta.explore")}
                            </a>
                            <a href="/seller" class="term-btn px-8 py-3 text-base font-medium border border-[var(--border)] bg-transparent">
                                {move || i18n.t("home.cta.become_seller")}
                            </a>
                        </div>
                        <div class="flex items-center justify-center gap-8 pt-8 text-sm text-[var(--fg-muted)]">
                            <div class="flex items-center gap-2">
                                <svg class="h-5 w-5 text-[var(--accent)]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                                {move || i18n.t("home.stat.modules")}
                            </div>
                            <div class="flex items-center gap-2">
                                <svg class="h-5 w-5 text-[var(--accent)]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                                </svg>
                                {move || i18n.t("home.stat.latency")}
                            </div>
                            <div class="flex items-center gap-2">
                                <svg class="h-5 w-5 text-[var(--accent)]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                                </svg>
                                {move || i18n.t("home.stat.security")}
                            </div>
                        </div>
                    </div>
                </div>
                <div class="absolute inset-0 -z-10 overflow-hidden">
                    <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-[var(--accent)]/5 rounded-full blur-3xl"></div>
                    <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-[var(--accent-secondary)]/5 rounded-full blur-3xl"></div>
                </div>
            </section>

            <section class="py-12 lg:py-16">
                <div class="max-w-6xl mx-auto px-4">
                    <div class="text-center mb-8">
                        <h2 class="text-2xl lg:text-3xl font-bold">{move || i18n.t("home.domains.title")}</h2>
                        <p class="text-[var(--fg-muted)] mt-1">{move || i18n.t("home.domains.subtitle")}</p>
                    </div>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                        <DomainCard slug="iot" name="IoT & Embedded" glyph="[#]" color="#00ccff" desc_key="home.domains.iot"/>
                        <DomainCard slug="ai-ml" name="AI & Machine Learning" glyph="<*>" color="#b26bff" desc_key="home.domains.ai"/>
                        <DomainCard slug="security" name="Cybersecurity" glyph="(K)" color="#ff0040" desc_key="home.domains.sec"/>
                        <DomainCard slug="sysadmin" name="SysAdmin & DevOps" glyph="[=]" color="#ffaa00" desc_key="home.domains.ops"/>
                        <DomainCard slug="developer" name="Developer Tools" glyph="</>" color="#00ff41" desc_key="home.domains.dev"/>
                        <a href="/products" class="term-card flex flex-col items-center justify-center text-center p-6 gap-2 group">
                            <span class="text-3xl font-bold text-[var(--fg-muted)] group-hover:text-[var(--accent)] transition-colors">"++"</span>
                            <span class="font-semibold">{move || i18n.t("home.featured.view_all")}</span>
                        </a>
                    </div>
                </div>
            </section>

            <section class="py-12 lg:py-16 bg-[var(--bg-secondary)]">
                <div class="max-w-6xl mx-auto px-4">
                    <div class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4 mb-8">
                        <div>
                            <h2 class="text-2xl lg:text-3xl font-bold">{move || i18n.t("home.featured.title")}</h2>
                            <p class="text-[var(--fg-muted)] mt-1">{move || i18n.t("home.featured.subtitle")}</p>
                        </div>
                        <a href="/products" class="term-btn px-4 py-2 text-sm">
                            {move || i18n.t("home.featured.view_all")}
                        </a>
                    </div>

                    <Transition
                        fallback=move || view! {
                            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                                <FeaturedCardSkeleton/>
                                <FeaturedCardSkeleton/>
                                <FeaturedCardSkeleton/>
                                <FeaturedCardSkeleton/>
                            </div>
                        }
                    >
                        {move || match featured.get().map(|p| p.take()) {
                            None => view! { <p class="text-center py-12"><Loading text="loading"/></p> }.into_any(),
                            Some(Err(err)) => view! { <p class="text-center term-error py-12">{i18n.t("home.featured.failed")} {err.to_string()}</p> }.into_any(),
                            Some(Ok(products)) if products.is_empty() => view! {
                                <div class="text-center py-12">
                                    <p class="text-[var(--fg-muted)]">{i18n.t("home.featured.empty")}</p>
                                    <a href="/seller" class="term-btn mt-4 inline-block">{i18n.t("home.featured.add_first")}</a>
                                </div>
                            }.into_any(),
                            Some(Ok(products)) => view! {
                                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                                    {products.into_iter().map(|product| view! { <FeaturedCard product=product/> }).collect_view()}
                                </div>
                            }.into_any(),
                        }}
                    </Transition>
                </div>
            </section>

            <section class="py-12 lg:py-16">
                <div class="max-w-6xl mx-auto px-4 text-center">
                    <h2 class="text-2xl lg:text-3xl font-bold mb-4">{move || i18n.t("home.cta2.title")}</h2>
                    <p class="text-[var(--fg-muted)] mb-8 max-w-2xl mx-auto">
                        {move || i18n.t("home.cta2.subtitle")}
                    </p>
                    <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
                        <a href="/products" class="term-btn px-8 py-3 text-base font-medium">
                            {move || i18n.t("home.cta2.browse")}
                        </a>
                        {move || auth.user.get().is_none().then(|| view! {
                            <a href="/auth/register" class="term-btn px-8 py-3 text-base font-medium border border-[var(--border)] bg-transparent">
                                {i18n.t("home.cta2.create_account")}
                            </a>
                        })}
                    </div>
                </div>
            </section>
        </div>
    }
}

/// A clickable tile for one IT specialization on the home page. Links to the
/// catalog pre-filtered by that category, and tints its glyph/border with the
/// domain's accent colour so the five disciplines are visually distinct.
#[component]
fn DomainCard(
    slug: &'static str,
    name: &'static str,
    glyph: &'static str,
    color: &'static str,
    desc_key: &'static str,
) -> impl IntoView {
    let i18n = use_i18n();
    let href = format!("/products?category={slug}");
    view! {
        <a href=href class="term-card group flex items-start gap-4 p-5" style=format!("--card-accent:{color}")>
            <span
                class="text-2xl font-bold shrink-0 leading-none mt-0.5"
                style=format!("color:{color}")
            >{glyph}</span>
            <span class="flex flex-col">
                <span class="font-semibold text-[var(--fg-primary)] group-hover:text-[var(--accent)] transition-colors">{name}</span>
                <span class="text-sm text-[var(--fg-muted)] mt-1">{move || i18n.t(desc_key)}</span>
            </span>
        </a>
    }
}

#[component]
fn FeaturedCard(product: ProductCard) -> impl IntoView {
    let image = product.primary_image().unwrap_or_else(|| "/placeholder.svg".to_string());
    let price = product.sale_price.unwrap_or(product.price);
    let has_sale = product.sale_price.is_some();
    let href = format!("/products/{}", product.slug);

    view! {
        <a href=href class="block h-full">
        <article class="term-card group hover:border-[var(--accent)]/50 transition-all duration-300 flex flex-col h-full">
            <div class="relative aspect-square overflow-hidden rounded-t-lg bg-[var(--bg-tertiary)]">
                <img
                    src=image
                    alt=product.name.clone()
                    class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    loading="lazy"
                />
                <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                {has_sale.then(|| view! {
                    <span class="absolute top-3 left-3 px-2 py-1 text-xs font-bold bg-red-500 text-white rounded">
                        "Sale"
                    </span>
                })}
            </div>
            <div class="p-4 flex flex-col flex-1">
                <p class="text-xs text-[var(--accent)] font-medium mb-1">
                    {product.category_name.unwrap_or_else(|| "Kernel Module".to_string())}
                </p>
                <h3 class="font-semibold text-[var(--fg-primary)] mb-2 line-clamp-1 group-hover:text-[var(--accent)] transition-colors">
                    {product.name}
                </h3>
                <p class="text-sm text-[var(--fg-muted)] line-clamp-2 flex-1 mb-3">
                    {product.description}
                </p>
                <div class="flex items-center justify-between pt-3 border-t border-[var(--border)]">
                    <div class="flex items-baseline gap-2">
                        <span class="text-lg font-bold text-[var(--fg-primary)]">
                            {format!("${:.2}", price)}
                        </span>
                        {has_sale.then(|| view! {
                            <span class="text-sm line-through text-[var(--fg-muted)]">
                                {format!("${:.2}", product.price)}
                            </span>
                        })}
                    </div>
                    <span class="text-xs text-[var(--fg-muted)]">
                        {product.shop_name.unwrap_or_else(|| "Unknown Shop".to_string())}
                    </span>
                </div>
            </div>
        </article>
        </a>
    }
}

#[component]
fn FeaturedCardSkeleton() -> impl IntoView {
    view! {
        <article class="term-card animate-pulse">
            <div class="aspect-square bg-[var(--bg-tertiary)] rounded-t-lg"></div>
            <div class="p-4 space-y-3">
                <div class="h-4 w-1/4 bg-[var(--bg-tertiary)] rounded"></div>
                <div class="h-5 w-3/4 bg-[var(--bg-tertiary)] rounded"></div>
                <div class="h-4 w-full bg-[var(--bg-tertiary)] rounded"></div>
                <div class="h-4 w-2/3 bg-[var(--bg-tertiary)] rounded"></div>
                <div class="h-4 w-full bg-[var(--bg-tertiary)] rounded mt-4"></div>
                <div class="flex justify-between">
                    <div class="h-6 w-20 bg-[var(--bg-tertiary)] rounded"></div>
                    <div class="h-4 w-24 bg-[var(--bg-tertiary)] rounded"></div>
                </div>
            </div>
        </article>
    }
}