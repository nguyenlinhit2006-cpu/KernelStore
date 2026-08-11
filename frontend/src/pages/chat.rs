use leptos::prelude::*;
use leptos::task::spawn_local;
use leptos_router::hooks::use_query_map;

use crate::api::{
    get_messages, list_conversations, open_chat_socket, send_message, ChatMessageInfo,
    ConversationInfo,
};
use crate::auth::AuthContext;
use crate::components::loading::Loading;
use crate::components::toast::ToastContext;
use crate::i18n::use_i18n;

fn short_time(raw: &str) -> String {
    // "2026-08-09T08:51:43Z" → "08-09 08:51"
    let date = raw.get(5..10).unwrap_or("");
    let time = raw.get(11..16).unwrap_or("");
    format!("{date} {time}")
}

#[component]
pub fn ChatPage() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let toasts = use_context::<ToastContext>().expect("ToastContext must be provided");
    let i18n = use_i18n();
    let query = use_query_map();

    let conversations = RwSignal::new(Vec::<ConversationInfo>::new());
    let selected = RwSignal::new(None::<String>);
    let messages = RwSignal::new(Vec::<ChatMessageInfo>::new());
    let input = RwSignal::new(String::new());
    let loading = RwSignal::new(true);
    // Bumped to force a conversation-list reload (new message / read state changed).
    let refresh = RwSignal::new(0u32);

    let messages_container = NodeRef::<leptos::html::Div>::new();

    // Load the conversation list (re-runs when `refresh` changes).
    Effect::new(move |_| {
        refresh.get();
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            if let Ok(list) = list_conversations(&token).await {
                conversations.set(list);
            }
            loading.set(false);
        });
    });

    // Select a conversation → load its history (server marks it read).
    let select_conv = move |id: String| {
        selected.set(Some(id.clone()));
        messages.set(Vec::new());
        let token = auth.token.get().unwrap_or_default();
        spawn_local(async move {
            if let Ok(msgs) = get_messages(&token, &id).await {
                messages.set(msgs);
            }
            refresh.update(|n| *n += 1);
        });
    };

    // Open the realtime socket in an effect tracking `auth.token`.
    let ws_store = StoredValue::new(None::<web_sys::WebSocket>);
    Effect::new(move |_| {
        if let Some(ws) = ws_store.get_value() {
            let _ = ws.close();
            ws_store.set_value(None);
        }

        let token = auth.token.get().unwrap_or_default();
        if !token.is_empty() {
            let on_msg = move |m: ChatMessageInfo| {
                if selected.get_untracked().as_deref() == Some(m.conversation_id.as_str()) {
                    messages.update(|v| {
                        if !v.iter().any(|x| x.id == m.id) {
                            v.push(m);
                        }
                    });
                }
                refresh.update(|n| *n += 1);
            };
            if let Ok(ws) = open_chat_socket(&token, on_msg) {
                ws_store.set_value(Some(ws));
            }
        }
    });

    on_cleanup(move || {
        if let Some(ws) = ws_store.get_value() {
            let _ = ws.close();
        }
    });

    // Auto-open a conversation passed via ?c=<id> (e.g. from a product page).
    {
        if let Some(c) = query.get_untracked().get("c") {
            if !c.is_empty() {
                select_conv(c.to_string());
            }
        }
    }

    let send = move |_| {
        let content = input.get().trim().to_string();
        let Some(cid) = selected.get() else { return };
        if content.is_empty() {
            return;
        }
        input.set(String::new());
        let token = auth.token.get().unwrap_or_default();
        let toasts = toasts.clone();
        spawn_local(async move {
            match send_message(&token, &cid, &content).await {
                Ok(msg) => {
                    messages.update(|v| v.push(msg));
                    refresh.update(|n| *n += 1);
                }
                Err(e) => {
                    toasts.error(format!("{}{e}", i18n.t("chat.send_failed")));
                    input.set(content); // Restore input on failure
                }
            }
        });
    };

    let scroll_to_bottom = move || {
        request_animation_frame(move || {
            if let Some(el) = messages_container.get() {
                el.set_scroll_top(el.scroll_height());
            }
        });
    };

    Effect::new(move |_| {
        messages.get();
        scroll_to_bottom();
    });

    let active_conversation = move || {
        let sel_id = selected.get()?;
        conversations.get().into_iter().find(|c| c.id == sel_id)
    };

    view! {
        <div class="max-w-5xl mx-auto p-6">
            <p class="term-muted text-sm mb-1">"$ kernelstore --chat"</p>
            <h1 class="text-lg font-bold mb-4">{move || i18n.t("chat.title")}</h1>

            <div class="grid grid-cols-1 sm:grid-cols-[16rem_1fr] gap-4">
                // ── Conversation list ────────────────────────────────────
                <aside class="term-box p-2 h-[28rem] overflow-y-auto">
                    {move || {
                        if loading.get() {
                            return view! { <p class="p-2"><Loading text=i18n.t("chat.loading")/></p> }.into_any();
                        }
                        let list = conversations.get();
                        if list.is_empty() {
                            return view! {
                                <p class="term-muted text-xs p-2">{i18n.t("chat.no_convos")}</p>
                            }.into_any();
                        }
                        view! {
                            <div class="flex flex-col gap-1">
                                {list.into_iter().map(|c| {
                                    let cid = c.id.clone();
                                    let active = move || selected.get().as_deref() == Some(cid.as_str());
                                    let open_id = c.id.clone();
                                    view! {
                                        <button
                                            class="term-menu-item text-left px-2 py-2"
                                            class:term-active=active
                                            on:click=move |_| select_conv(open_id.clone())
                                        >
                                            <div class="flex justify-between items-center gap-2">
                                                <span class="text-sm text-[var(--fg-primary)] truncate">{c.other_name}</span>
                                                {(c.unread_count > 0).then(|| view! {
                                                    <span class="term-warn text-xs shrink-0">{format!("({})", c.unread_count)}</span>
                                                })}
                                            </div>
                                            <p class="term-muted text-xs truncate">
                                                {c.last_message.unwrap_or_else(|| "—".to_string())}
                                            </p>
                                        </button>
                                    }
                                }).collect_view()}
                            </div>
                        }.into_any()
                    }}
                </aside>

                // ── Thread ───────────────────────────────────────────────
                <section class="term-box flex flex-col h-[28rem]">
                    {move || {
                        if selected.get().is_none() {
                            return view! {
                                <div class="flex-1 flex items-center justify-center">
                                    <p class="term-muted text-sm">{i18n.t("chat.pick_convo")}</p>
                                </div>
                            }.into_any();
                        }
                        let convo = active_conversation();
                        let title = convo.map(|c| c.other_name).unwrap_or_else(|| i18n.t("chat.convo").to_string());
                        view! {
                            <div class="border-b border-[var(--border)] p-2 bg-[var(--bg-secondary)] flex justify-between items-center shrink-0">
                                <span class="text-sm font-bold text-[var(--fg-primary)]">{format!("{}{title}", i18n.t("chat.with"))}</span>
                            </div>
                            <div class="flex-1 overflow-y-auto p-3 flex flex-col gap-2" node_ref=messages_container>
                                {move || {
                                    let my_id = auth.user.get().map(|u| u.id).unwrap_or_default();
                                    messages.get().into_iter().map(|m| {
                                        let mine = m.sender_id == my_id;
                                        let row = if mine { "justify-end" } else { "justify-start" };
                                        let bubble = if mine {
                                            "bg-[var(--bg-tertiary)] text-[var(--fg-primary)]"
                                        } else {
                                            "term-sub"
                                        };
                                        view! {
                                            <div class=format!("flex {row}")>
                                                <div class=format!("max-w-[75%] px-3 py-2 rounded text-sm {bubble}")>
                                                    <p class="whitespace-pre-wrap break-words">{m.content}</p>
                                                    <p class="term-muted text-[10px] mt-1">{short_time(&m.created_at)}</p>
                                                </div>
                                            </div>
                                        }
                                    }).collect_view()
                                }}
                            </div>
                            <div class="border-t border-[var(--border)] p-2 flex items-center gap-2">
                                <input
                                    class="term-input flex-1 px-3 py-2 text-sm"
                                    placeholder=i18n.t("chat.input_ph")
                                    prop:value=move || input.get()
                                    on:input=move |ev| input.set(event_target_value(&ev))
                                    on:keydown=move |ev| if ev.key() == "Enter" { send(()) }
                                />
                                <button class="term-btn px-4 py-2 text-sm" on:click=move |_| send(())>
                                    {i18n.t("chat.send")}
                                </button>
                            </div>
                        }.into_any()
                    }}
                </section>
            </div>
        </div>
    }
}
