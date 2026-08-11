use leptos::prelude::*;
use leptos::task::spawn_local;
use leptos_router::components::A;
use leptos_router::hooks::use_navigate;

use crate::auth::AuthContext;
use crate::components::input::TermInput;
use crate::i18n::use_i18n;

#[component]
pub fn LoginPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let i18n = use_i18n();
    let navigate = use_navigate();

    let email = RwSignal::new(String::new());
    let password = RwSignal::new(String::new());
    let error = RwSignal::new(String::new());

    let on_submit = move |_| {
        error.set(String::new());
        let email_val = email.get();
        let pass_val = password.get();

        if email_val.is_empty() || pass_val.is_empty() {
            error.set(i18n.t("login.required").to_string());
            return;
        }

        let nav = navigate.clone();
        spawn_local(async move {
            if let Err(e) = auth.login(email_val, pass_val).await {
                error.set(e);
            } else {
                nav("/", Default::default());
            }
        });
    };

    view! {
        <div class="max-w-md mx-auto p-6">
            <p class="term-muted text-sm mb-1">{move || i18n.t("login.cmd")}</p>
            <h1 class="text-lg font-bold mb-4">{move || i18n.t("login.title")}</h1>

            <div class="term-box p-5">
                <TermInput id="login-email" label=i18n.t("login.email") input_type="email" placeholder="you@example.com" value=email/>
                <TermInput id="login-password" label=i18n.t("login.password") input_type="password" placeholder="********" value=password/>

                <p class="term-error text-sm mb-2" class:invisible=move || error.get().is_empty()>
                    "[ERROR] " {move || error.get()}
                </p>

                <button
                    class="term-btn w-full mt-2 px-3 py-2 text-sm"
                    on:click=on_submit
                    prop:disabled=move || auth.is_loading.get()
                >
                    {move || if auth.is_loading.get() {
                        i18n.t("login.loading")
                    } else {
                        i18n.t("login.submit")
                    }}
                </button>

                <p class="mt-4 text-sm term-muted">
                    {move || i18n.t("login.no_account")}
                    <A href="/auth/register" attr:class="text-[var(--fg-primary)] underline">{move || i18n.t("login.register_link")}</A>
                </p>
            </div>
        </div>
    }
}
