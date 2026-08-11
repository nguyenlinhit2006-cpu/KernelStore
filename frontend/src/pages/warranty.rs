use leptos::prelude::*;
use leptos::task::spawn_local;

use crate::api::{
    approve_warranty, cancel_warranty, complete_warranty, list_my_warranty, list_shop_warranty,
    process_warranty, reject_warranty, WarrantyClaim,
};
use crate::auth::AuthContext;
use crate::components::loading::Loading;
use crate::components::toast::ToastContext;
use crate::i18n::use_i18n;

/// Terminal color class for a warranty status.
fn status_class(status: &str) -> &'static str {
    match status {
        "Completed" | "Approved" => "term-info",
        "Rejected" | "Cancelled" => "term-error",
        "Pending" | "Processing" => "term-warn",
        _ => "term-muted",
    }
}

fn short_date(raw: &str) -> String {
    raw.chars().take(10).collect()
}

/// Status filters offered on the management view.
const STATUS_FILTERS: &[&str] = &[
    "", "Pending", "Approved", "Processing", "Completed", "Rejected",
];

// ── Customer view ─────────────────────────────────────────────────────────

#[component]
pub fn WarrantyPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let i18n = use_i18n();

    let claims = RwSignal::new(None::<Vec<WarrantyClaim>>);
    let error = RwSignal::new(String::new());
    // Bumped after a mutating action to trigger a reload.
    let reload = RwSignal::new(0u32);

    Effect::new(move |_| {
        reload.get();
        let token = auth.token.get().unwrap_or_default();
        claims.set(None);
        error.set(String::new());
        spawn_local(async move {
            match list_my_warranty(&token).await {
                Ok(list) => claims.set(Some(list)),
                Err(e) => error.set(e.to_string()),
            }
        });
    });

    view! {
        <div class="max-w-3xl mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --warranty"</p>
            <h1 class="text-lg font-bold mb-4">{move || i18n.t("warranty.title")}</h1>

            <Show when=move || !error.get().is_empty()>
                <p class="term-error text-sm mb-3">"[ERROR] " {move || error.get()}</p>
            </Show>

            {move || {
                let Some(list) = claims.get() else {
                    return view! { <p><Loading text=i18n.t("warranty.loading")/></p> }.into_any();
                };
                if list.is_empty() {
                    return view! {
                        <div class="term-box p-8 text-center">
                            <p class="term-muted text-sm">{i18n.t("warranty.none")}</p>
                        </div>
                    }.into_any();
                }
                view! {
                    <div class="space-y-3">
                        {list.into_iter().map(|c| view! {
                            <ClaimCard claim=c manage=false reload=reload/>
                        }).collect_view()}
                    </div>
                }.into_any()
            }}
        </div>
    }
}

// ── Seller / Admin management view ────────────────────────────────────────

#[component]
pub fn WarrantyManagePage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let i18n = use_i18n();

    let claims = RwSignal::new(None::<Vec<WarrantyClaim>>);
    let error = RwSignal::new(String::new());
    let filter = RwSignal::new(String::new());
    let reload = RwSignal::new(0u32);

    Effect::new(move |_| {
        reload.get();
        let status = filter.get();
        let token = auth.token.get().unwrap_or_default();
        claims.set(None);
        error.set(String::new());
        spawn_local(async move {
            match list_shop_warranty(&token, &status).await {
                Ok(list) => claims.set(Some(list)),
                Err(e) => error.set(e.to_string()),
            }
        });
    });

    view! {
        <div class="max-w-3xl mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --warranty --manage"</p>
            <h1 class="text-lg font-bold mb-4">{move || i18n.t("warranty.manage_title")}</h1>

            // ── Status filter ────────────────────────────────────────────
            <div class="flex flex-wrap gap-1.5 mb-4 text-xs">
                {STATUS_FILTERS.iter().map(|s| {
                    let s = *s;
                    let cls = move || {
                        if filter.get() == s {
                            "term-menu-item term-active px-2 py-0.5"
                        } else {
                            "term-menu-item px-2 py-0.5"
                        }
                    };
                    let label = if s.is_empty() { "warranty.filter_all" } else { status_label(s) };
                    view! {
                        <button class=cls on:click=move |_| filter.set(s.to_string())>
                            {move || i18n.t(label)}
                        </button>
                    }
                }).collect_view()}
            </div>

            <Show when=move || !error.get().is_empty()>
                <p class="term-error text-sm mb-3">"[ERROR] " {move || error.get()}</p>
            </Show>

            {move || {
                let Some(list) = claims.get() else {
                    return view! { <p><Loading text=i18n.t("warranty.loading")/></p> }.into_any();
                };
                if list.is_empty() {
                    return view! {
                        <div class="term-box p-8 text-center">
                            <p class="term-muted text-sm">{i18n.t("warranty.none_shop")}</p>
                        </div>
                    }.into_any();
                }
                view! {
                    <div class="space-y-3">
                        {list.into_iter().map(|c| view! {
                            <ClaimCard claim=c manage=true reload=reload/>
                        }).collect_view()}
                    </div>
                }.into_any()
            }}
        </div>
    }
}

/// i18n key for a status label.
fn status_label(status: &str) -> &'static str {
    match status {
        "Pending" => "warranty.st.pending",
        "Approved" => "warranty.st.approved",
        "Rejected" => "warranty.st.rejected",
        "Processing" => "warranty.st.processing",
        "Completed" => "warranty.st.completed",
        "Cancelled" => "warranty.st.cancelled",
        _ => "warranty.st.pending",
    }
}

/// i18n key for a resolution label.
fn resolution_label(res: &str) -> &'static str {
    match res {
        "Repair" => "warranty.res.repair",
        "Replace" => "warranty.res.replace",
        "Refund" => "warranty.res.refund",
        _ => "warranty.res.none",
    }
}

// ── Shared claim card ─────────────────────────────────────────────────────

#[component]
fn ClaimCard(claim: WarrantyClaim, manage: bool, reload: RwSignal<u32>) -> impl IntoView {
    let i18n = use_i18n();
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let toasts = use_context::<ToastContext>().expect("ToastContext must be provided");

    let sclass = status_class(&claim.status);
    let status = claim.status.clone();
    let img = claim.product_image_url.clone().unwrap_or_default();
    let expires = claim.warranty_expires_at.clone();
    let resolution = claim.resolution.clone();
    let note = claim.resolution_note.clone();
    let claim_id = claim.id.clone();
    let is_pending = claim.status == "Pending";

    // Customer-side cancel of a pending claim.
    let busy = RwSignal::new(false);
    let cancel_id = claim_id.clone();
    let on_cancel = move |_| {
        if busy.get() { return; }
        busy.set(true);
        let token = auth.token.get().unwrap_or_default();
        let id = cancel_id.clone();
        spawn_local(async move {
            match cancel_warranty(&token, &id).await {
                Ok(_) => { toasts.success(i18n.t("warranty.cancelled_ok")); reload.set(reload.get_untracked() + 1); }
                Err(e) => toasts.error(e.to_string()),
            }
            busy.set(false);
        });
    };

    view! {
        <div class="term-box p-4">
            <div class="flex items-center justify-between gap-3 mb-2">
                <span class="text-[var(--fg-primary)] text-sm font-bold">{claim.claim_code.clone()}</span>
                <span class=format!("text-xs {sclass}")>{move || i18n.t(status_label(&status))}</span>
            </div>

            <div class="flex items-start gap-3">
                <div class="term-box w-12 h-12 shrink-0 overflow-hidden flex items-center justify-center bg-[var(--bg-tertiary)]">
                    {if img.is_empty() {
                        view! { <span class="term-muted text-lg">"[ ]"</span> }.into_any()
                    } else {
                        view! { <img src=img class="w-full h-full object-cover"/> }.into_any()
                    }}
                </div>
                <div class="min-w-0 flex-1">
                    <a href=format!("/products/{}", claim.product_slug) class="text-sm text-[var(--fg-primary)] hover:underline">
                        {claim.product_name.clone()}
                    </a>
                    <p class="text-xs term-muted">
                        {format!("{} · x{}", claim.order_code.clone(), claim.quantity)}
                    </p>
                    {manage.then(|| view! {
                        <p class="text-xs term-muted">{format!("{}{}", i18n.t("warranty.by"), claim.user_name.clone())}</p>
                    })}
                </div>
            </div>

            <p class="text-sm mt-2 whitespace-pre-wrap">{claim.description.clone()}</p>

            {expires.map(|e| view! {
                <p class="text-xs term-muted mt-1">{format!("{}{}", i18n.t("warranty.expires"), short_date(&e))}</p>
            })}

            {(resolution != "None").then(|| {
                let r = resolution.clone();
                view! {
                    <p class="text-xs term-info mt-1">
                        {move || i18n.t("warranty.resolution")}
                        {move || i18n.t(resolution_label(&r))}
                    </p>
                }
            })}

            {(!note.is_empty()).then(|| view! {
                <p class="text-xs term-muted mt-1">{format!("{}{note}", i18n.t("warranty.note_prefix"))}</p>
            })}

            <p class="text-xs term-muted mt-1">{short_date(&claim.created_at)}</p>

            // Customer: cancel a still-pending request.
            {(!manage && is_pending).then(|| view! {
                <div class="mt-3">
                    <button class="term-btn px-3 py-1 text-xs" disabled=move || busy.get() on:click=on_cancel>
                        {move || i18n.t("warranty.cancel_btn")}
                    </button>
                </div>
            })}

            // Seller/Admin: manage actions.
            {manage.then(|| view! {
                <ManageActions claim_id=claim_id.clone() status=claim.status.clone() reload=reload/>
            })}
        </div>
    }
}

/// Seller/Admin action controls, gated by the current claim status.
#[component]
fn ManageActions(claim_id: String, status: String, reload: RwSignal<u32>) -> impl IntoView {
    let i18n = use_i18n();
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let toasts = use_context::<ToastContext>().expect("ToastContext must be provided");

    let id = StoredValue::new(claim_id);
    let busy = RwSignal::new(false);
    let resolution = RwSignal::new("Repair".to_string());
    let note = RwSignal::new(String::new());

    // Generic runner: executes an async action then reloads the list on success.
    let run = move |fut: std::pin::Pin<Box<dyn std::future::Future<Output = Result<WarrantyClaim, crate::api::ApiError>>>>, ok_key: &'static str| {
        if busy.get_untracked() { return; }
        busy.set(true);
        spawn_local(async move {
            match fut.await {
                Ok(_) => { toasts.success(i18n.t(ok_key)); reload.set(reload.get_untracked() + 1); }
                Err(e) => toasts.error(e.to_string()),
            }
            busy.set(false);
        });
    };

    let approve = move |_| {
        let token = auth.token.get().unwrap_or_default();
        let cid = id.get_value();
        let res = resolution.get();
        let n = note.get();
        run(Box::pin(async move { approve_warranty(&token, &cid, &res, &n).await }), "warranty.approved_ok");
    };
    let reject = move |_| {
        let token = auth.token.get().unwrap_or_default();
        let cid = id.get_value();
        let n = note.get();
        run(Box::pin(async move { reject_warranty(&token, &cid, &n).await }), "warranty.rejected_ok");
    };
    let process = move |_| {
        let token = auth.token.get().unwrap_or_default();
        let cid = id.get_value();
        run(Box::pin(async move { process_warranty(&token, &cid).await }), "warranty.processing_ok");
    };
    let complete = move |_| {
        let token = auth.token.get().unwrap_or_default();
        let cid = id.get_value();
        let n = note.get();
        run(Box::pin(async move { complete_warranty(&token, &cid, &n).await }), "warranty.completed_ok");
    };

    let show_approve_form = status == "Pending";
    let show_process = status == "Approved";
    let show_complete = matches!(status.as_str(), "Approved" | "Processing");

    view! {
        <div class="mt-3 border-t border-[var(--border)] pt-3">
            {show_approve_form.then(|| view! {
                <div class="flex flex-wrap items-center gap-2 mb-2">
                    <span class="term-muted text-xs">{move || i18n.t("warranty.resolution_pick")}</span>
                    <select
                        class="term-input px-2 py-1 text-xs"
                        on:change=move |ev| resolution.set(event_target_value(&ev))
                    >
                        <option value="Repair">{move || i18n.t("warranty.res.repair")}</option>
                        <option value="Replace">{move || i18n.t("warranty.res.replace")}</option>
                        <option value="Refund">{move || i18n.t("warranty.res.refund")}</option>
                    </select>
                </div>
            })}

            {(show_approve_form || show_complete).then(|| view! {
                <input
                    class="term-input w-full px-3 py-2 text-xs mb-2"
                    placeholder=i18n.t("warranty.note_ph")
                    prop:value=move || note.get()
                    on:input=move |ev| note.set(event_target_value(&ev))
                />
            })}

            <div class="flex flex-wrap gap-2">
                {show_approve_form.then(|| view! {
                    <button class="term-btn px-3 py-1 text-xs" disabled=move || busy.get() on:click=approve>
                        {move || i18n.t("warranty.approve_btn")}
                    </button>
                    <button class="term-btn px-3 py-1 text-xs" disabled=move || busy.get() on:click=reject>
                        {move || i18n.t("warranty.reject_btn")}
                    </button>
                })}
                {show_process.then(|| view! {
                    <button class="term-btn px-3 py-1 text-xs" disabled=move || busy.get() on:click=process>
                        {move || i18n.t("warranty.process_btn")}
                    </button>
                })}
                {show_complete.then(|| view! {
                    <button class="term-btn px-3 py-1 text-xs" disabled=move || busy.get() on:click=complete>
                        {move || i18n.t("warranty.complete_btn")}
                    </button>
                })}
            </div>
        </div>
    }
}
