use gloo_net::http::Request;
use serde::{Deserialize, Serialize};

pub const API_BASE: &str = "http://localhost:5000/api";

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RegisterPayload {
    pub full_name: String,
    pub email: String,
    pub user_name: String,
    pub password: String,
}

#[derive(Debug, Clone, Serialize)]
pub struct LoginPayload {
    pub email: String,
    pub password: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthData {
    pub access_token: String,
    pub refresh_token: String,
    pub expires_at: String,
    pub user: UserInfo,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UserInfo {
    pub id: String,
    pub user_name: String,
    pub email: String,
    pub full_name: String,
    pub avatar_url: String,
    pub role: String,
    pub is_active: bool,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ApiEnvelope<T> {
    pub success: bool,
    pub data: Option<T>,
    pub message: String,
    pub errors: Vec<String>,
}

#[derive(Debug, Clone)]
pub enum ApiError {
    Server(String),
    Network(String),
    Unauthorized,
    NotFound,
}

impl std::fmt::Display for ApiError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ApiError::Server(msg) => write!(f, "{msg}"),
            ApiError::Network(msg) => write!(f, "network error: {msg}"),
            ApiError::Unauthorized => write!(f, "unauthorized"),
            ApiError::NotFound => write!(f, "not found"),
        }
    }
}

pub async fn register(payload: &RegisterPayload) -> Result<AuthData, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/auth/register"))
        .header("Content-Type", "application/json")
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<AuthData> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn login(payload: &LoginPayload) -> Result<AuthData, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/auth/login"))
        .header("Content-Type", "application/json")
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<AuthData> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RefreshPayload {
    pub refresh_token: String,
}

/// Exchange a refresh token for a fresh access token (picks up any role change).
pub async fn refresh(refresh_token: &str) -> Result<AuthData, ApiError> {
    let payload = RefreshPayload { refresh_token: refresh_token.to_string() };
    let resp = Request::post(&format!("{API_BASE}/auth/refresh"))
        .header("Content-Type", "application/json")
        .body(serde_json::to_string(&payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<AuthData> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

#[derive(Debug, Clone, Deserialize)]
pub struct MeData {
    pub info: UserInfo,
    pub roles: Vec<String>,
}

pub async fn me(token: &str) -> Result<UserInfo, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/auth/me"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<MeData> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.map(|d| d.info).ok_or_else(|| ApiError::Server("no data".into()))
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CreateShopPayload {
    pub name: String,
    pub slug: String,
    pub description: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ShopInfo {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub description: String,
    pub logo_url: String,
    pub status: String,
    pub created_at: String,
    pub owner_id: String,
    pub owner_name: String,
}

pub async fn create_shop(token: &str, payload: &CreateShopPayload) -> Result<ShopInfo, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/shops"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ShopInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn get_my_shop(token: &str) -> Result<Option<ShopInfo>, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/shops/me"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<Option<ShopInfo>> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    Ok(envelope.data.flatten())
}

pub async fn update_shop(token: &str, payload: &CreateShopPayload) -> Result<ShopInfo, ApiError> {
    let resp = Request::put(&format!("{API_BASE}/shops/me"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ShopInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn list_shops(token: &str, status: Option<&str>) -> Result<Vec<ShopInfo>, ApiError> {
    let mut url = format!("{API_BASE}/admin/shops");
    if let Some(s) = status {
        url.push_str(&format!("?status={s}"));
    }

    let resp = Request::get(&url)
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<Vec<ShopInfo>> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

// ── Admin dashboard ───────────────────────────────────────────────────────

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OrderStatusCount {
    pub status: String,
    pub count: i32,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DashboardStats {
    pub total_users: i32,
    pub total_shops: i32,
    pub pending_shops: i32,
    pub approved_shops: i32,
    pub total_products: i32,
    pub active_products: i32,
    pub total_orders: i32,
    pub total_revenue: f64,
    pub orders_by_status: Vec<OrderStatusCount>,
}

pub async fn get_admin_dashboard(token: &str) -> Result<DashboardStats, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/admin/dashboard"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<DashboardStats> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TopProductStat {
    pub product_id: String,
    pub name: String,
    pub quantity_sold: i32,
    pub revenue: f64,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SellerDashboard {
    pub total_revenue: f64,
    pub total_orders: i32,
    pub pending_orders: i32,
    pub items_sold: i32,
    pub total_products: i32,
    pub active_products: i32,
    pub orders_by_status: Vec<OrderStatusCount>,
    pub top_products: Vec<TopProductStat>,
}

pub async fn get_seller_dashboard(token: &str) -> Result<SellerDashboard, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/seller/dashboard"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    if resp.status() == 404 {
        return Err(ApiError::NotFound);
    }

    let envelope: ApiEnvelope<SellerDashboard> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn admin_approve_shop(token: &str, id: &str) -> Result<ShopInfo, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/admin/shops/{id}/approve"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ShopInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn admin_reject_shop(token: &str, id: &str) -> Result<ShopInfo, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/admin/shops/{id}/reject"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ShopInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Admin temporarily bans a shop for violations (products hidden).
pub async fn admin_ban_shop(token: &str, id: &str) -> Result<ShopInfo, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/admin/shops/{id}/ban"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ShopInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Admin lifts a temporary ban (products shown again).
pub async fn admin_unban_shop(token: &str, id: &str) -> Result<ShopInfo, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/admin/shops/{id}/unban"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ShopInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Admin permanently bans (deletes) a shop. Returns the server's message
/// (hard delete vs soft delete depending on whether the shop has order history).
pub async fn admin_delete_shop(token: &str, id: &str) -> Result<String, ApiError> {
    let resp = Request::delete(&format!("{API_BASE}/admin/shops/{id}"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<serde_json::Value> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }
    Ok(envelope.message)
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ProductPayload {
    pub name: String,
    pub slug: String,
    pub description: String,
    pub price: f64,
    pub sale_price: Option<f64>,
    pub stock_quantity: i32,
    pub sku: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub category_id: Option<String>,
    pub is_active: bool,
    pub images: Vec<String>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProductInfo {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub description: String,
    pub price: f64,
    pub sale_price: Option<f64>,
    pub stock_quantity: i32,
    pub sku: String,
    pub is_active: bool,
    pub created_at: String,
    pub shop_id: String,
    pub category_id: Option<String>,
    #[serde(default)]
    pub category_name: Option<String>,
    #[serde(default)]
    pub images: Vec<ProductImageInfo>,
}

pub async fn create_product(token: &str, payload: &ProductPayload) -> Result<ProductInfo, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/products"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ProductInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn list_my_products(token: &str) -> Result<Vec<ProductInfo>, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/products/my"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<Vec<ProductInfo>> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn update_product(token: &str, id: &str, payload: &ProductPayload) -> Result<ProductInfo, ApiError> {
    let resp = Request::put(&format!("{API_BASE}/products/{id}"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ProductInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProductImageInfo {
    pub id: String,
    pub url: String,
    pub alt_text: String,
    pub is_primary: bool,
    pub display_order: i32,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProductCard {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub description: String,
    pub price: f64,
    pub sale_price: Option<f64>,
    pub stock_quantity: i32,
    pub sku: String,
    pub is_active: bool,
    pub created_at: String,
    pub shop_id: String,
    pub shop_name: Option<String>,
    pub category_id: Option<String>,
    pub category_name: Option<String>,
    pub images: Vec<ProductImageInfo>,
}

impl ProductCard {
    /// URL of the primary image (falls back to the first image, if any).
    pub fn primary_image(&self) -> Option<String> {
        self.images
            .iter()
            .find(|i| i.is_primary)
            .or_else(|| self.images.first())
            .map(|i| i.url.clone())
    }
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PagedResult<T> {
    pub page: i32,
    pub page_size: i32,
    pub total: i32,
    pub total_pages: i32,
    pub items: Vec<T>,
}

/// Filters for the public product listing (`GET /api/products`).
#[derive(Debug, Clone, Default)]
pub struct ProductQuery {
    pub category: Option<String>,
    pub shop: Option<String>,
    pub min_price: Option<f64>,
    pub max_price: Option<f64>,
    pub search: Option<String>,
    pub sort: Option<String>,
    pub page: u32,
    pub page_size: u32,
}

fn push_param(parts: &mut Vec<String>, key: &str, value: &str) {
    if value.is_empty() {
        return;
    }
    let enc = String::from(js_sys::encode_uri_component(value));
    parts.push(format!("{key}={enc}"));
}

/// Public: paginated + filtered product listing (no auth required).
pub async fn list_products(q: &ProductQuery) -> Result<PagedResult<ProductCard>, ApiError> {
    let mut parts: Vec<String> = Vec::new();
    if let Some(c) = &q.category {
        push_param(&mut parts, "category", c);
    }
    if let Some(s) = &q.shop {
        push_param(&mut parts, "shop", s);
    }
    if let Some(v) = q.min_price {
        push_param(&mut parts, "minPrice", &v.to_string());
    }
    if let Some(v) = q.max_price {
        push_param(&mut parts, "maxPrice", &v.to_string());
    }
    if let Some(s) = &q.search {
        push_param(&mut parts, "search", s);
    }
    if let Some(s) = &q.sort {
        push_param(&mut parts, "sort", s);
    }
    if q.page > 0 {
        push_param(&mut parts, "page", &q.page.to_string());
    }
    if q.page_size > 0 {
        push_param(&mut parts, "pageSize", &q.page_size.to_string());
    }

    let query_string = if parts.is_empty() {
        String::new()
    } else {
        format!("?{}", parts.join("&"))
    };

    let resp = Request::get(&format!("{API_BASE}/products{query_string}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<PagedResult<ProductCard>> =
        resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CategoryNode {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub description: String,
    pub parent_id: Option<String>,
    pub product_count: i32,
    pub children: Option<Vec<CategoryNode>>,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CategoryPayload {
    pub name: String,
    pub slug: String,
    pub description: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub parent_id: Option<String>,
}

pub async fn create_category(token: &str, payload: &CategoryPayload) -> Result<CategoryNode, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/categories"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<CategoryNode> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn update_category(token: &str, id: &str, payload: &CategoryPayload) -> Result<CategoryNode, ApiError> {
    let resp = Request::put(&format!("{API_BASE}/categories/{id}"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<CategoryNode> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn delete_category(token: &str, id: &str) -> Result<(), ApiError> {
    let resp = Request::delete(&format!("{API_BASE}/categories/{id}"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<serde_json::Value> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }
    Ok(())
}

/// Public: category tree (no auth required).
pub async fn list_categories() -> Result<Vec<CategoryNode>, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/categories"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<Vec<CategoryNode>> =
        resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ReviewInfo {
    pub id: String,
    pub rating: i32,
    pub comment: String,
    pub created_at: String,
    pub user_id: String,
    pub user_name: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ShopSummary {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub description: String,
    pub logo_url: String,
    pub product_count: i32,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProductDetail {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub description: String,
    pub price: f64,
    pub sale_price: Option<f64>,
    pub stock_quantity: i32,
    pub sku: String,
    pub created_at: String,
    pub shop_id: String,
    pub shop_name: Option<String>,
    pub category_id: Option<String>,
    pub category_name: Option<String>,
    pub images: Vec<ProductImageInfo>,
    pub reviews: Vec<ReviewInfo>,
    pub shop: ShopSummary,
    pub average_rating: f64,
    pub review_count: i32,
}

impl ProductDetail {
    /// URL of the primary image (falls back to the first image, if any).
    pub fn primary_image(&self) -> Option<String> {
        self.images
            .iter()
            .find(|i| i.is_primary)
            .or_else(|| self.images.first())
            .map(|i| i.url.clone())
    }
}

/// Public: product detail by slug or id (no auth required).
/// Maps a 404 response to `ApiError::NotFound`.
pub async fn get_product(slug: &str) -> Result<ProductDetail, ApiError> {
    let enc = String::from(js_sys::encode_uri_component(slug));
    let resp = Request::get(&format!("{API_BASE}/products/{enc}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 404 {
        return Err(ApiError::NotFound);
    }

    let envelope: ApiEnvelope<ProductDetail> =
        resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProductReviews {
    pub reviews: Vec<ReviewInfo>,
    pub average_rating: f64,
    pub review_count: i32,
}

/// Create a review for a product (login required; API enforces purchase).
pub async fn create_review(token: &str, product_id: &str, rating: i32, comment: &str) -> Result<ReviewInfo, ApiError> {
    #[derive(Serialize)]
    #[serde(rename_all = "camelCase")]
    struct Payload<'a> {
        product_id: &'a str,
        rating: i32,
        comment: &'a str,
    }
    let resp = Request::post(&format!("{API_BASE}/reviews"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(&Payload { product_id, rating, comment }).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<ReviewInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Public: reviews for a product (no auth required).
pub async fn get_reviews(product_id: &str) -> Result<ProductReviews, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/reviews?productId={product_id}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<ProductReviews> =
        resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Public: featured products for the home page (no auth required).
pub async fn featured_products(take: u32) -> Result<Vec<ProductCard>, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/products/featured?take={take}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<Vec<ProductCard>> =
        resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

// ── Cart ────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CartItem {
    pub id: String,
    pub product_id: String,
    pub name: String,
    pub slug: String,
    pub price: f64,
    pub sale_price: Option<f64>,
    pub unit_price: f64,
    pub quantity: i32,
    pub stock_quantity: i32,
    pub line_total: f64,
    pub image_url: Option<String>,
    pub shop_id: String,
    pub shop_name: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Cart {
    pub items: Vec<CartItem>,
    pub total_items: i32,
    pub subtotal: f64,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
struct AddToCartPayload {
    product_id: String,
    quantity: i32,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateCartPayload {
    quantity: i32,
}

async fn cart_envelope(resp: gloo_net::http::Response) -> Result<Cart, ApiError> {
    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    let envelope: ApiEnvelope<Cart> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn get_cart(token: &str) -> Result<Cart, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/cart"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;
    cart_envelope(resp).await
}

pub async fn add_to_cart(token: &str, product_id: &str, quantity: i32) -> Result<Cart, ApiError> {
    let payload = AddToCartPayload { product_id: product_id.to_string(), quantity };
    let resp = Request::post(&format!("{API_BASE}/cart"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(&payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;
    cart_envelope(resp).await
}

pub async fn update_cart_item(token: &str, product_id: &str, quantity: i32) -> Result<Cart, ApiError> {
    let payload = UpdateCartPayload { quantity };
    let resp = Request::put(&format!("{API_BASE}/cart/{product_id}"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(&payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;
    cart_envelope(resp).await
}

pub async fn delete_cart_item(token: &str, product_id: &str) -> Result<Cart, ApiError> {
    let resp = Request::delete(&format!("{API_BASE}/cart/{product_id}"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;
    cart_envelope(resp).await
}

// ── Orders ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CreateOrderPayload {
    pub full_name: String,
    pub phone: String,
    pub street: String,
    pub ward: String,
    pub district: String,
    pub city: String,
    pub note: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OrderAddress {
    pub full_name: String,
    pub phone: String,
    pub street: String,
    pub ward: String,
    pub district: String,
    pub city: String,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OrderItem {
    pub id: String,
    pub product_id: String,
    pub product_name: String,
    pub product_slug: String,
    pub image_url: Option<String>,
    pub unit_price: f64,
    pub quantity: i32,
    pub total_price: f64,
    pub shop_id: String,
    pub shop_name: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Order {
    pub id: String,
    pub order_code: String,
    pub status: String,
    pub total_amount: f64,
    pub shipping_fee: f64,
    pub note: String,
    pub created_at: String,
    pub paid_at: Option<String>,
    pub address: OrderAddress,
    pub items: Vec<OrderItem>,
    pub item_count: i32,
    /// Viewer may manage this order's status (seller who owns items, or admin).
    #[serde(default)]
    pub can_manage: bool,
}

pub async fn create_order(token: &str, payload: &CreateOrderPayload) -> Result<Order, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/orders"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(payload).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<Order> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn list_orders(token: &str) -> Result<Vec<Order>, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/orders"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }

    let envelope: ApiEnvelope<Vec<Order>> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Đơn BÁN của shop (seller). `status` rỗng = tất cả trạng thái.
pub async fn list_seller_sales(token: &str, status: &str) -> Result<Vec<Order>, ApiError> {
    let url = if status.is_empty() {
        format!("{API_BASE}/orders/sales")
    } else {
        format!("{API_BASE}/orders/sales?status={status}")
    };
    let resp = Request::get(&url)
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    if resp.status() == 404 {
        return Err(ApiError::NotFound);
    }

    let envelope: ApiEnvelope<Vec<Order>> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn get_order(token: &str, id: &str) -> Result<Order, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/orders/{id}"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    if resp.status() == 404 {
        return Err(ApiError::NotFound);
    }

    let envelope: ApiEnvelope<Order> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn update_order_status(token: &str, id: &str, status: &str) -> Result<Order, ApiError> {
    #[derive(Serialize)]
    struct Payload<'a> {
        status: &'a str,
    }
    let resp = Request::put(&format!("{API_BASE}/orders/{id}/status"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(&Payload { status }).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    if resp.status() == 404 {
        return Err(ApiError::NotFound);
    }

    let envelope: ApiEnvelope<Order> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Buyer confirms they received the order (Shipped → Delivered).
pub async fn confirm_received(token: &str, id: &str) -> Result<Order, ApiError> {
    let resp = Request::post(&format!("{API_BASE}/orders/{id}/confirm-received"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    if resp.status() == 404 {
        return Err(ApiError::NotFound);
    }

    let envelope: ApiEnvelope<Order> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Shared helper for the simple POST /orders/{id}/{action} endpoints that return an Order.
async fn order_action(token: &str, path: String) -> Result<Order, ApiError> {
    let resp = Request::post(&format!("{API_BASE}{path}"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    if resp.status() == 404 {
        return Err(ApiError::NotFound);
    }

    let envelope: ApiEnvelope<Order> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Buyer cancels their own order (only before it ships). Restores stock server-side.
pub async fn cancel_order(token: &str, id: &str) -> Result<Order, ApiError> {
    order_action(token, format!("/orders/{id}/cancel")).await
}

/// Buyer requests a return after receiving the order (Delivered → ReturnRequested).
pub async fn request_return(token: &str, id: &str) -> Result<Order, ApiError> {
    order_action(token, format!("/orders/{id}/return")).await
}

/// Seller/admin resolves a return request. `approve=true` → Returned, else back to Delivered.
pub async fn resolve_return(token: &str, id: &str, approve: bool) -> Result<Order, ApiError> {
    let action = if approve { "approve" } else { "reject" };
    order_action(token, format!("/orders/{id}/return/{action}")).await
}

pub async fn delete_product(token: &str, id: &str) -> Result<(), ApiError> {
    let resp = Request::delete(&format!("{API_BASE}/products/{id}"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;

    let envelope: ApiEnvelope<serde_json::Value> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        let msg = envelope.errors.first().cloned().unwrap_or(envelope.message);
        return Err(ApiError::Server(msg));
    }

    Ok(())
}

// ─────────────────────────── Chat ───────────────────────────

/// WebSocket endpoint for realtime chat (server pushes incoming messages).
pub const CHAT_WS_BASE: &str = "ws://localhost:5000/ws/chat";

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ConversationInfo {
    pub id: String,
    pub shop_id: String,
    pub shop_name: String,
    pub buyer_id: String,
    pub buyer_name: String,
    pub other_name: String,
    pub last_message: Option<String>,
    pub last_message_at: String,
    pub unread_count: i32,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ChatMessageInfo {
    pub id: String,
    pub conversation_id: String,
    pub sender_id: String,
    pub content: String,
    pub created_at: String,
}

pub async fn list_conversations(token: &str) -> Result<Vec<ConversationInfo>, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/chat/conversations"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;
    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    let envelope: ApiEnvelope<Vec<ConversationInfo>> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        return Err(ApiError::Server(envelope.errors.first().cloned().unwrap_or(envelope.message)));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Buyer starts (or re-opens) a conversation with a shop.
pub async fn start_conversation(token: &str, shop_id: &str) -> Result<ConversationInfo, ApiError> {
    #[derive(Serialize)]
    #[serde(rename_all = "camelCase")]
    struct Body<'a> { shop_id: &'a str }
    let resp = Request::post(&format!("{API_BASE}/chat/conversations"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(&Body { shop_id }).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;
    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    let envelope: ApiEnvelope<ConversationInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        return Err(ApiError::Server(envelope.errors.first().cloned().unwrap_or(envelope.message)));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn get_messages(token: &str, conversation_id: &str) -> Result<Vec<ChatMessageInfo>, ApiError> {
    let resp = Request::get(&format!("{API_BASE}/chat/conversations/{conversation_id}/messages"))
        .header("Authorization", &format!("Bearer {token}"))
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;
    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    let envelope: ApiEnvelope<Vec<ChatMessageInfo>> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        return Err(ApiError::Server(envelope.errors.first().cloned().unwrap_or(envelope.message)));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

pub async fn send_message(token: &str, conversation_id: &str, content: &str) -> Result<ChatMessageInfo, ApiError> {
    #[derive(Serialize)]
    struct Body<'a> { content: &'a str }
    let resp = Request::post(&format!("{API_BASE}/chat/conversations/{conversation_id}/messages"))
        .header("Content-Type", "application/json")
        .header("Authorization", &format!("Bearer {token}"))
        .body(serde_json::to_string(&Body { content }).unwrap_or_default())
        .map_err(|e| ApiError::Network(e.to_string()))?
        .send()
        .await
        .map_err(|e| ApiError::Network(e.to_string()))?;
    if resp.status() == 401 {
        return Err(ApiError::Unauthorized);
    }
    let envelope: ApiEnvelope<ChatMessageInfo> = resp.json().await.map_err(|e| ApiError::Network(e.to_string()))?;
    if !envelope.success {
        return Err(ApiError::Server(envelope.errors.first().cloned().unwrap_or(envelope.message)));
    }
    envelope.data.ok_or_else(|| ApiError::Server("no data".into()))
}

/// Opens a chat WebSocket. `on_message` fires for each pushed message.
/// Returns the socket (keep it alive for the connection to stay open).
pub fn open_chat_socket(
    token: &str,
    on_message: impl Fn(ChatMessageInfo) + 'static,
) -> Result<web_sys::WebSocket, String> {
    use wasm_bindgen::closure::Closure;
    use wasm_bindgen::JsCast;

    let url = format!("{CHAT_WS_BASE}?access_token={token}");
    let ws = web_sys::WebSocket::new(&url).map_err(|e| format!("{e:?}"))?;

    let onmessage = Closure::<dyn FnMut(web_sys::MessageEvent)>::new(move |e: web_sys::MessageEvent| {
        if let Some(txt) = e.data().as_string() {
            if let Ok(msg) = serde_json::from_str::<ChatMessageInfo>(&txt) {
                on_message(msg);
            }
        }
    });
    ws.set_onmessage(Some(onmessage.as_ref().unchecked_ref()));
    onmessage.forget(); // keep the callback alive for the socket's lifetime

    Ok(ws)
}
