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
    view! {
        <label for=id class="block mb-1 text-xs term-muted">
            {label}
        </label>
        <div class="flex items-center gap-2 mb-3">
            <span class="term-info text-sm shrink-0">">"</span>
            <input
                id=id
                type=input_type
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
        </div>
    }
}
