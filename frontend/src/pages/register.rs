use leptos::prelude::*;
use leptos::task::spawn_local;
use leptos_router::components::A;
use leptos_router::hooks::use_navigate;

use crate::api::RegisterPayload;
use crate::auth::AuthContext;
use crate::components::input::TermInput;

#[component]
pub fn RegisterPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let navigate = use_navigate();

    let full_name = RwSignal::new(String::new());
    let user_name = RwSignal::new(String::new());
    let email = RwSignal::new(String::new());
    let password = RwSignal::new(String::new());
    let error = RwSignal::new(String::new());

    let on_submit = move |_| {
        error.set(String::new());
        let payload = RegisterPayload {
            full_name: full_name.get(),
            user_name: user_name.get(),
            email: email.get(),
            password: password.get(),
        };

        if payload.full_name.is_empty()
            || payload.user_name.is_empty()
            || payload.email.is_empty()
            || payload.password.is_empty()
        {
            error.set("all fields are required".to_string());
            return;
        }

        let nav = navigate.clone();
        spawn_local(async move {
            if let Err(e) = auth.register(payload).await {
                error.set(e);
            } else {
                nav("/", Default::default());
            }
        });
    };

    view! {
        <div class="max-w-md mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --register"</p>
            <h1 class="text-lg font-bold mb-4">"> authentication :: register"</h1>

            <div class="term-box p-5">
                <TermInput id="reg-fullname" label="full name" placeholder="Nguyen Van A" value=full_name/>
                <TermInput id="reg-username" label="username" placeholder="nguyenvana" value=user_name/>
                <TermInput id="reg-email" label="email" input_type="email" placeholder="you@example.com" value=email/>
                <TermInput id="reg-password" label="password" input_type="password" placeholder="********" value=password/>

                <p class="term-error text-sm mb-2" class:invisible=move || error.get().is_empty()>
                    "[ERROR] " {move || error.get()}
                </p>

                <button
                    class="term-btn w-full mt-2 px-3 py-2 text-sm"
                    on:click=on_submit
                    prop:disabled=move || auth.is_loading.get()
                >
                    {move || if auth.is_loading.get() {
                        "loading..._".to_string()
                    } else {
                        "$ create account".to_string()
                    }}
                </button>

                <p class="mt-4 text-sm term-muted">
                    "Already have an account? "
                    <A href="/auth/login" attr:class="text-[var(--fg-primary)] underline">"login ->"</A>
                </p>
            </div>
        </div>
    }
}
