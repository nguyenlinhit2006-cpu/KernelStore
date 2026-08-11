use leptos::prelude::*;
use leptos_router::hooks::use_location;

use crate::auth::AuthContext;
use crate::i18n::use_i18n;

/// One clickable entry: i18n label key + target href. The label is a
/// translation key resolved at render time so the menu re-localises live.
type Item = (&'static str, &'static str);

/// A labelled group of menu entries. `label` is an i18n key (e.g.
/// "nav.group.buyer").
struct Group {
    label: &'static str,
    items: Vec<Item>,
}

/// Functions available to a signed-in user, split into clearly separated
/// groups so shopping (buyer) and shop-management (seller) never blur together.
fn menu_groups(role: &str) -> Vec<Group> {
    let buyer = Group {
        label: "nav.group.buyer",
        items: vec![
            ("nav.browse", "/products"),
            ("nav.cart", "/cart"),
            ("nav.orders", "/orders"),
            ("nav.chat", "/chat"),
        ],
    };

    let mut groups = vec![buyer];

    match role {
        "Seller" => groups.push(Group {
            label: "nav.group.seller",
            items: vec![
                ("nav.dashboard", "/seller?tab=dashboard"),
                ("nav.products", "/seller?tab=products"),
                ("nav.categories", "/seller?tab=categories"),
                ("nav.sales", "/seller?tab=sales"),
                ("nav.settings", "/seller?tab=settings"),
            ],
        }),
        "Admin" => groups.push(Group {
            label: "nav.group.admin",
            items: vec![("nav.panel", "/admin")],
        }),
        _ => groups.push(Group {
            label: "nav.group.seller",
            items: vec![("nav.become_seller", "/seller")], // Customer: no shop yet
        }),
    }

    groups
}

/// Is `href` the currently-open page? Matches the path and, for `/seller?tab=`
/// links, the active tab (dashboard is the default when no tab is present).
fn is_active(href: &str, path: &str, tab: &str) -> bool {
    match href.split_once("?tab=") {
        Some((base, want_tab)) => {
            path == base && (tab == want_tab || (tab.is_empty() && want_tab == "dashboard"))
        }
        None => path == href || path.starts_with(&format!("{href}/")),
    }
}

/// A role-aware navigation panel rendered under the header on every page, with
/// buyer and seller functions in separate groups. Highlights the active entry.
#[component]
pub fn NavMenu() -> impl IntoView {
    let auth = use_context::<AuthContext>().expect("AuthContext must be provided");
    let i18n = use_i18n();
    let location = use_location();

    move || {
        auth.user.get().map(|u| {
            let path = location.pathname.get();
            let tab = location.query.get().get("tab").unwrap_or_default();
            let groups = menu_groups(&u.role);
            let last = groups.len().saturating_sub(1);
            let home_cls = if path == "/" {
                "term-menu-item term-active px-2 py-0.5 shrink-0"
            } else {
                "term-menu-item px-2 py-0.5 shrink-0"
            };

            view! {
                <nav class="border-b border-[var(--border)] px-4 py-1.5 flex items-center gap-1.5 text-xs overflow-x-auto whitespace-nowrap">
                    <a href="/" class=home_cls>{i18n.t("nav.home")}</a>

                    {groups.into_iter().enumerate().map(|(gi, g)| {
                        let items = g.items.into_iter().map(|(label, href)| {
                            let cls = if is_active(href, &path, &tab) {
                                "term-menu-item term-active px-2 py-0.5 shrink-0"
                            } else {
                                "term-menu-item px-2 py-0.5 shrink-0"
                            };
                            view! { <a href=href class=cls>{i18n.t(label)}</a> }
                        }).collect_view();
                        view! {
                            <span class="term-muted shrink-0 ml-2">{format!("{}:", i18n.t(g.label))}</span>
                            {items}
                            {(gi != last).then(|| view! {
                                <span class="term-muted shrink-0 mx-1">"│"</span>
                            })}
                        }
                    }).collect_view()}
                </nav>
            }
        })
    }
}
