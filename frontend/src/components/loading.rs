use leptos::prelude::*;

/// Terminal-style loading indicator: reveals `text` with a looping typewriter
/// effect and a blinking block caret. Width/steps are derived from the text
/// length so any message animates cleanly.
#[component]
pub fn Loading(#[prop(into)] text: String) -> impl IntoView {
    let n = text.chars().count().max(1);
    let style = format!("--tw: {n}ch; --steps: {n}");
    view! {
        <span class="term-typing term-muted" style=style>{text}</span>
    }
}
