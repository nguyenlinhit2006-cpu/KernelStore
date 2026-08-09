use leptos::prelude::*;
use leptos::task::spawn_local;
use web_sys::window;

use crate::api::{AuthData, LoginPayload, RegisterPayload, UserInfo};

const TOKEN_KEY: &str = "ks_access_token";
const REFRESH_KEY: &str = "ks_refresh_token";

#[derive(Clone, Copy)]
pub struct AuthContext {
    pub user: RwSignal<Option<UserInfo>>,
    pub token: RwSignal<Option<String>>,
    pub is_loading: RwSignal<bool>,
}

impl AuthContext {
    fn save_tokens(&self, access_token: &str, refresh_token: &str) {
        if let Some(storage) = window().and_then(|w| w.local_storage().ok().flatten()) {
            let _ = storage.set_item(TOKEN_KEY, access_token);
            let _ = storage.set_item(REFRESH_KEY, refresh_token);
        }
    }

    fn clear_tokens(&self) {
        if let Some(storage) = window().and_then(|w| w.local_storage().ok().flatten()) {
            let _ = storage.remove_item(TOKEN_KEY);
            let _ = storage.remove_item(REFRESH_KEY);
        }
    }

    pub fn load_from_storage(&self) {
        let storage = window().and_then(|w| w.local_storage().ok().flatten());
        let token = storage.as_ref().and_then(|s| s.get_item(TOKEN_KEY).ok().flatten());
        self.token.set(token);
    }

    pub async fn restore_user(&self) {
        if let Some(token) = self.token.get() {
            match crate::api::me(&token).await {
                Ok(user) => self.user.set(Some(user)),
                Err(_) => self.logout(),
            }
        }
    }

    pub fn set_auth(&self, auth: AuthData) {
        let AuthData {
            access_token,
            refresh_token,
            user,
            ..
        } = auth;
        self.token.set(Some(access_token.clone()));
        self.user.set(Some(user));
        self.save_tokens(&access_token, &refresh_token);
    }

    pub fn logout(&self) {
        self.token.set(None);
        self.user.set(None);
        self.clear_tokens();
    }

    pub async fn login(&self, email: String, password: String) -> Result<(), String> {
        self.is_loading.set(true);
        let result = crate::api::login(&LoginPayload { email, password }).await;
        self.is_loading.set(false);
        match result {
            Ok(auth) => {
                self.set_auth(auth);
                Ok(())
            }
            Err(e) => Err(e.to_string()),
        }
    }

    pub async fn register(&self, payload: RegisterPayload) -> Result<(), String> {
        self.is_loading.set(true);
        let result = crate::api::register(&payload).await;
        self.is_loading.set(false);
        match result {
            Ok(auth) => {
                self.set_auth(auth);
                Ok(())
            }
            Err(e) => Err(e.to_string()),
        }
    }
}

pub fn provide_auth() -> AuthContext {
    let ctx = AuthContext {
        user: RwSignal::new(None),
        token: RwSignal::new(None),
        is_loading: RwSignal::new(false),
    };
    ctx.load_from_storage();
    if ctx.token.get().is_some() {
        spawn_local({
            let ctx = ctx;
            async move {
                ctx.restore_user().await;
            }
        });
    }
    provide_context(ctx);
    ctx
}
