use leptos::prelude::*;
use leptos_router::components::{ProtectedRoute, Route, Router, Routes};
use leptos_router::path;

use crate::auth::provide_auth;
use crate::pages::admin::AdminPage;
use crate::pages::cart::CartPage;
use crate::pages::chat::ChatPage;
use crate::pages::checkout::CheckoutPage;
use crate::pages::home::HomePage;
use crate::pages::login::LoginPage;
use crate::pages::orders::{OrderDetailPage, OrdersPage};
use crate::pages::product_detail::ProductDetailPage;
use crate::pages::products::ProductsPage;
use crate::pages::register::RegisterPage;
use crate::pages::seller::SellerPage;
use crate::pages::warranty::{WarrantyManagePage, WarrantyPage};

pub mod api;
pub mod auth;
pub mod components;
pub mod i18n;
pub mod pages;

use crate::i18n::{provide_i18n, use_i18n};

/// Compact EN/VI toggle shown in the header. Clicking flips the active language
/// for the whole app; the choice is persisted to localStorage.
#[component]
fn LangSwitcher() -> impl IntoView {
    let i18n = use_i18n();
    view! {
        <button
            class="term-btn px-2 py-0.5 text-xs"
            title="switch language / đổi ngôn ngữ"
            on:click=move |_| i18n.toggle()
        >
            {move || i18n.lang.get().label()}
        </button>
    }
}

#[component]
fn Header() -> impl IntoView {
    let auth = use_context::<crate::auth::AuthContext>().expect("AuthContext must be provided");
    let i18n = use_i18n();
    let navigate = leptos_router::hooks::use_navigate();

    view! {
        <header class="glass sticky top-0 z-40 border-b border-[var(--border)] px-4 py-3 flex flex-wrap justify-between items-center gap-2 text-sm relative">
            <a href="/" class="font-extrabold text-base tracking-tight flex items-center gap-1.5">
                <span class="text-[var(--accent)] neon">"\u{276f}"</span>
                <span class="glow-text">"KernelStore"</span>
                <span class="text-[var(--fg-muted)] font-medium text-xs">"v0.1.0"</span>
                <span class="caret text-[var(--accent)] font-normal">"_"</span>
            </a>
            <div class="hairline-accent absolute left-0 bottom-0 h-px w-full"></div>
            <div class="flex flex-wrap items-center gap-2 sm:gap-3">
                <LangSwitcher/>
                {move || match auth.user.get() {
                    Some(u) => {
                        let nav = navigate.clone();
                        view! {
                            <span class="hidden sm:inline text-[var(--fg-muted)]">{format!("{} ({}):", u.user_name, u.role)}</span>
                            <button
                                class="term-btn px-2 py-0.5 text-xs"
                                on:click=move |_| {
                                    auth.logout();
                                    nav("/", Default::default());
                                }
                            >{move || i18n.t("header.logout")}</button>
                        }.into_any()
                    }
                    None => view! {
                        <div class="flex items-center gap-2 sm:gap-3">
                            <span class="hidden sm:inline text-[var(--fg-muted)]">{move || i18n.t("header.guest")}</span>
                            <a href="/products" class="term-btn px-2 py-0.5 text-xs">{move || i18n.t("header.browse")}</a>
                            <a href="/auth/login" class="term-btn px-2 py-0.5 text-xs">{move || i18n.t("header.login")}</a>
                            <a href="/auth/register" class="term-btn px-2 py-0.5 text-xs">{move || i18n.t("header.register")}</a>
                        </div>
                    }.into_any(),
                }}
            </div>
        </header>
    }
}

#[component]
pub fn App() -> impl IntoView {
    let auth = provide_auth();
    provide_i18n();
    crate::components::toast::provide_toasts();

    view! {
        <Router>
            <div class="min-h-screen flex flex-col">
                <Header/>
                <crate::components::nav::NavMenu/>
                <crate::components::toast::ToastHost/>
                <main class="flex-1">
                    <Routes fallback=|| { let i18n = use_i18n(); view! {
                        <crate::components::error::KernelPanic
                            code="404"
                            title=i18n.t("panic.route_not_found")
                            detail=i18n.t("panic.route_detail")
                        />
                    }}>
                        <ProtectedRoute
                            path=path!("/")
                            view=HomePage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                            fallback=|| { let i18n = use_i18n(); view! { <p class="p-6"><crate::components::loading::Loading text=i18n.t("panic.checking_session")/></p> } }
                        />
                        <Route path=path!("/products") view=ProductsPage/>
                        <Route path=path!("/products/:slug") view=ProductDetailPage/>
                        <Route path=path!("/auth/login") view=LoginPage/>
                        <Route path=path!("/auth/register") view=RegisterPage/>
                        <ProtectedRoute
                            path=path!("/cart")
                            view=CartPage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                        />
                        <ProtectedRoute
                            path=path!("/chat")
                            view=ChatPage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                        />
                        <ProtectedRoute
                            path=path!("/orders")
                            view=OrdersPage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                        />
                        <ProtectedRoute
                            path=path!("/orders/:id")
                            view=OrderDetailPage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                        />
                        <ProtectedRoute
                            path=path!("/checkout")
                            view=CheckoutPage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                        />
                        <ProtectedRoute
                            path=path!("/warranty")
                            view=WarrantyPage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                        />
                        <ProtectedRoute
                            path=path!("/warranty/manage")
                            view=WarrantyManagePage
                            condition=move || Some(auth.user.get().is_some_and(|u| u.role == "Seller" || u.role == "Admin"))
                            redirect_path=|| "/auth/login"
                        />
                        <ProtectedRoute
                            path=path!("/seller")
                            view=SellerPage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                        />
                        <ProtectedRoute
                            path=path!("/admin")
                            view=AdminPage
                            condition=move || Some(auth.user.get().is_some_and(|u| u.role == "Admin"))
                            redirect_path=|| "/auth/login"
                        />
                    </Routes>
                </main>
            </div>
        </Router>
    }
}
