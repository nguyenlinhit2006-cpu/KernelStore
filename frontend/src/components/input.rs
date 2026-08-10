use leptos::prelude::*;

#[component]
pub fn TermInput(
    id: &'static str,
    label: &'static str,
    #[prop(default = "text")] input_type: &'static str,
    #[prop(default = "")] placeholder: &'static str,
    value: RwSignal<String>,
    #[prop(optional)] on_input: Option<Box<dyn Fn(String) + 'static>>,
) -> impl IntoView {
    let is_password = input_type == "password";
    // Toggles between hidden (password) and visible (text) for password fields.
    let revealed = RwSignal::new(false);
    let effective_type = move || {
        if is_password && revealed.get() { "text" } else { input_type }
    };

    view! {
        <label for=id class="block mb-1 text-xs term-muted">
            {label}
        </label>
        <div class="flex items-center gap-2 mb-3">
            <span class="term-info text-sm shrink-0">">"</span>
            <input
                id=id
                type=effective_type
                placeholder=placeholder
                class="term-input w-full px-3 py-2 text-sm"
                prop:value=move || value.get()
                on:input=move |ev| {
                    let v = event_target_value(&ev);
                    value.set(v.clone());
                    if let Some(cb) = on_input.as_ref() {
                        cb(v);
                    }
                }
            />
            {is_password.then(|| view! {
                <button
                    type="button"
                    class="term-btn px-2 py-2 shrink-0 flex items-center justify-center"
                    aria-label="toggle password visibility"
                    on:click=move |_| revealed.update(|r| *r = !*r)
                    title=move || if revealed.get() { "ẩn mật khẩu" } else { "hiện mật khẩu" }
                >
                    {move || if revealed.get() {
                        // eye-off (currently visible -> click to hide)
                        view! {
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        }.into_any()
                    } else {
                        // eye (currently hidden -> click to reveal)
                        view! {
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        }.into_any()
                    }}
                </button>
            })}
        </div>
    }
}
