use leptos::prelude::*;

/// Terminal "kernel panic" error panel — used for 404 (route/resource not
/// found) and 500-style (server/network) failures across the app.
#[component]
pub fn KernelPanic(
    /// Short code shown in the header, e.g. "404" or "500".
    #[prop(into)] code: String,
    /// One-line summary, e.g. "route not found".
    #[prop(into)] title: String,
    /// Optional longer explanation.
    #[prop(into, optional)] detail: String,
    /// Where the recovery link points (defaults to "/").
    #[prop(into, optional)] back_href: Option<String>,
    /// Label for the recovery link (defaults to "$ cd /").
    #[prop(into, optional)] back_label: Option<String>,
) -> impl IntoView {
    let href = back_href.unwrap_or_else(|| "/".to_string());
    let label = back_label.unwrap_or_else(|| "$ cd /".to_string());
    let detail = if detail.is_empty() {
        "the requested module is not present in the registry".to_string()
    } else {
        detail
    };

    view! {
        <div class="max-w-2xl mx-auto p-6">
            <div class="term-box p-6">
                <p class="term-error text-sm mb-3">
                    {format!("--- KERNEL PANIC: {code} ---")}
                </p>
                <p class="text-[var(--fg-primary)] font-bold mb-3">{title}</p>
                <pre class="term-muted text-xs whitespace-pre-wrap leading-relaxed">
{format!(
"  [ 0.000000] segfault at 0x{code} ip pc:store
  [ 0.000001] {detail}
  [ 0.000002] Call Trace:
  [ 0.000003]   kernelstore_render+0x1f
  [ 0.000004]   route_dispatch+0x0
  [ 0.000005] ---[ end trace ]---")}
                </pre>
                <a href=href class="term-btn inline-block mt-4 px-4 py-2 text-sm">{label}</a>
            </div>
        </div>
    }
}
