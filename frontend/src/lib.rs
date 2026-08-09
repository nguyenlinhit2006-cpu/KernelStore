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

pub mod api;
pub mod auth;
pub mod components;
pub mod pages;

#[component]
fn Header() -> impl IntoView {
    let auth = use_context::<crate::auth::AuthContext>().expect("AuthContext must be provided");
    let navigate = leptos_router::hooks::use_navigate();

    view! {
        <header class="border-b px-4 py-2 flex flex-wrap justify-between items-center gap-2 text-sm">
            <a href="/" class="text-[var(--fg-primary)] font-bold">"KernelStore v0.1.0"</a>
            <div class="flex flex-wrap items-center gap-2 sm:gap-3">
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
                            >"logout"</button>
                        }.into_any()
                    }
                    None => view! {
                        <div class="flex items-center gap-2 sm:gap-3">
                            <span class="hidden sm:inline text-[var(--fg-muted)]">"guest@kernelstore"</span>
                            <a href="/products" class="term-btn px-2 py-0.5 text-xs">"browse"</a>
                            <a href="/auth/login" class="term-btn px-2 py-0.5 text-xs">"login"</a>
                            <a href="/auth/register" class="term-btn px-2 py-0.5 text-xs">"register"</a>
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
    crate::components::toast::provide_toasts();

    view! {
        <Router>
            <div class="min-h-screen flex flex-col">
                <Header/>
                <crate::components::nav::NavMenu/>
                <crate::components::toast::ToastHost/>
                <main class="flex-1">
                    <Routes fallback=|| view! {
                        <crate::components::error::KernelPanic
                            code="404"
                            title="route not found"
                            detail="no such path in the routing table — check the URL or head home"
                        />
                    }>
                        <ProtectedRoute
                            path=path!("/")
                            view=HomePage
                            condition=move || Some(auth.token.get().is_some_and(|t| !t.is_empty()))
                            redirect_path=|| "/auth/login"
                            fallback=|| view! { <p class="p-6"><crate::components::loading::Loading text="checking session"/></p> }
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
