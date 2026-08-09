use leptos::prelude::*;
use std::time::Duration;

#[derive(Clone, Copy, PartialEq)]
pub enum ToastLevel {
    Info,
    Warn,
    Error,
    Success,
}

impl ToastLevel {
    fn tag(self) -> &'static str {
        match self {
            ToastLevel::Info => "INFO",
            ToastLevel::Warn => "WARN",
            ToastLevel::Error => "ERROR",
            ToastLevel::Success => "OK",
        }
    }
    fn class(self) -> &'static str {
        match self {
            ToastLevel::Info => "term-info",
            ToastLevel::Warn => "term-warn",
            ToastLevel::Error => "term-error",
            ToastLevel::Success => "text-[var(--fg-primary)]",
        }
    }
}

#[derive(Clone)]
pub struct Toast {
    pub id: u32,
    pub level: ToastLevel,
    pub message: String,
}

/// Global toast bus. Cloneable/Copy — grab it via `use_context`.
#[derive(Clone, Copy)]
pub struct ToastContext {
    toasts: RwSignal<Vec<Toast>>,
    next_id: RwSignal<u32>,
}

impl ToastContext {
    pub fn push(&self, level: ToastLevel, message: impl Into<String>) {
        let id = self.next_id.get_untracked();
        self.next_id.set(id.wrapping_add(1));
        self.toasts.update(|v| v.push(Toast { id, level, message: message.into() }));

        // Auto-dismiss after 4s.
        let toasts = self.toasts;
        set_timeout(
            move || toasts.update(|v| v.retain(|t| t.id != id)),
            Duration::from_millis(4000),
        );
    }

    pub fn info(&self, m: impl Into<String>) { self.push(ToastLevel::Info, m); }
    pub fn warn(&self, m: impl Into<String>) { self.push(ToastLevel::Warn, m); }
    pub fn error(&self, m: impl Into<String>) { self.push(ToastLevel::Error, m); }
    pub fn success(&self, m: impl Into<String>) { self.push(ToastLevel::Success, m); }

    pub fn remove(&self, id: u32) {
        self.toasts.update(|v| v.retain(|t| t.id != id));
    }
}

/// Creates the toast context and provides it to the component tree.
pub fn provide_toasts() -> ToastContext {
    let ctx = ToastContext {
        toasts: RwSignal::new(Vec::new()),
        next_id: RwSignal::new(0),
    };
    provide_context(ctx);
    ctx
}

/// Renders the stacked toasts in the bottom-right corner.
#[component]
pub fn ToastHost() -> impl IntoView {
    let ctx = use_context::<ToastContext>().expect("ToastContext must be provided");
    view! {
        <div class="fixed bottom-4 right-4 z-50 flex flex-col gap-2 w-80 max-w-[calc(100vw-2rem)]">
            <For each=move || ctx.toasts.get() key=|t| t.id children=move |t| {
                let id = t.id;
                view! {
                    <div class="term-box p-2 text-xs font-mono flex items-start gap-2">
                        <span class=t.level.class()>{format!("[{}]", t.level.tag())}</span>
                        <span class="flex-1 break-words">{t.message.clone()}</span>
                        <button
                            class="term-muted hover:text-[var(--fg-primary)] shrink-0"
                            on:click=move |_| ctx.remove(id)
                        >"x"</button>
                    </div>
                }
            }/>
        </div>
    }
}
