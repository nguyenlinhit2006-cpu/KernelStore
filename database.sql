--
-- PostgreSQL database dump
--
/*ApplicationUser  — người dùng
2. 
 Shop  — gian hàng
3. 
 Category  — danh mục (cây cha-con)
4. 
 Product  — sản phẩm
5. 
 ProductImage  — ảnh sản phẩm (gallery)
6. 
 Order  — đơn hàng
7. 
 OrderDetail  — chi tiết đơn hàng
8. 
 Review  — đánh giá
9. 
 WarrantyClaim  — yêu cầu bảo hành
10. 
 Conversation  — hội thoại chat
11. 
 ChatMessage  — tin nhắn
12. 
 RefreshToken  — token làm mới (JWT rotation)
\restrict 1MV3MAGmhnaQUfccfjJfZwIpLNXY1KgmhN2DgSpczjuGWLx4Ugmg2mt97DGq6ne
*/
-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public."WarrantyClaims" DROP CONSTRAINT IF EXISTS "FK_WarrantyClaims_Shops_ShopId";
ALTER TABLE IF EXISTS ONLY public."WarrantyClaims" DROP CONSTRAINT IF EXISTS "FK_WarrantyClaims_Products_ProductId";
ALTER TABLE IF EXISTS ONLY public."WarrantyClaims" DROP CONSTRAINT IF EXISTS "FK_WarrantyClaims_OrderDetails_OrderDetailId";
ALTER TABLE IF EXISTS ONLY public."WarrantyClaims" DROP CONSTRAINT IF EXISTS "FK_WarrantyClaims_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."Shops" DROP CONSTRAINT IF EXISTS "FK_Shops_AspNetUsers_OwnerId";
ALTER TABLE IF EXISTS ONLY public."Reviews" DROP CONSTRAINT IF EXISTS "FK_Reviews_Products_ProductId";
ALTER TABLE IF EXISTS ONLY public."Reviews" DROP CONSTRAINT IF EXISTS "FK_Reviews_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."RefreshTokens" DROP CONSTRAINT IF EXISTS "FK_RefreshTokens_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."Products" DROP CONSTRAINT IF EXISTS "FK_Products_Shops_ShopId";
ALTER TABLE IF EXISTS ONLY public."Products" DROP CONSTRAINT IF EXISTS "FK_Products_Categories_CategoryId";
ALTER TABLE IF EXISTS ONLY public."ProductImages" DROP CONSTRAINT IF EXISTS "FK_ProductImages_Products_ProductId";
ALTER TABLE IF EXISTS ONLY public."Orders" DROP CONSTRAINT IF EXISTS "FK_Orders_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."Orders" DROP CONSTRAINT IF EXISTS "FK_Orders_Addresses_AddressId";
ALTER TABLE IF EXISTS ONLY public."OrderDetails" DROP CONSTRAINT IF EXISTS "FK_OrderDetails_Products_ProductId";
ALTER TABLE IF EXISTS ONLY public."OrderDetails" DROP CONSTRAINT IF EXISTS "FK_OrderDetails_Orders_OrderId";
ALTER TABLE IF EXISTS ONLY public."Conversations" DROP CONSTRAINT IF EXISTS "FK_Conversations_Shops_ShopId";
ALTER TABLE IF EXISTS ONLY public."Conversations" DROP CONSTRAINT IF EXISTS "FK_Conversations_AspNetUsers_BuyerId";
ALTER TABLE IF EXISTS ONLY public."ChatMessages" DROP CONSTRAINT IF EXISTS "FK_ChatMessages_Conversations_ConversationId";
ALTER TABLE IF EXISTS ONLY public."ChatMessages" DROP CONSTRAINT IF EXISTS "FK_ChatMessages_AspNetUsers_SenderId";
ALTER TABLE IF EXISTS ONLY public."Categories" DROP CONSTRAINT IF EXISTS "FK_Categories_Categories_ParentId";
ALTER TABLE IF EXISTS ONLY public."CartItems" DROP CONSTRAINT IF EXISTS "FK_CartItems_Products_ProductId";
ALTER TABLE IF EXISTS ONLY public."CartItems" DROP CONSTRAINT IF EXISTS "FK_CartItems_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."AspNetUserTokens" DROP CONSTRAINT IF EXISTS "FK_AspNetUserTokens_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."AspNetUserRoles" DROP CONSTRAINT IF EXISTS "FK_AspNetUserRoles_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."AspNetUserRoles" DROP CONSTRAINT IF EXISTS "FK_AspNetUserRoles_AspNetRoles_RoleId";
ALTER TABLE IF EXISTS ONLY public."AspNetUserLogins" DROP CONSTRAINT IF EXISTS "FK_AspNetUserLogins_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."AspNetUserClaims" DROP CONSTRAINT IF EXISTS "FK_AspNetUserClaims_AspNetUsers_UserId";
ALTER TABLE IF EXISTS ONLY public."AspNetRoleClaims" DROP CONSTRAINT IF EXISTS "FK_AspNetRoleClaims_AspNetRoles_RoleId";
ALTER TABLE IF EXISTS ONLY public."Addresses" DROP CONSTRAINT IF EXISTS "FK_Addresses_AspNetUsers_UserId";
DROP INDEX IF EXISTS public."UserNameIndex";
DROP INDEX IF EXISTS public."RoleNameIndex";
DROP INDEX IF EXISTS public."IX_WarrantyClaims_UserId";
DROP INDEX IF EXISTS public."IX_WarrantyClaims_ShopId";
DROP INDEX IF EXISTS public."IX_WarrantyClaims_ProductId";
DROP INDEX IF EXISTS public."IX_WarrantyClaims_OrderDetailId";
DROP INDEX IF EXISTS public."IX_WarrantyClaims_ClaimCode";
DROP INDEX IF EXISTS public."IX_Shops_Slug";
DROP INDEX IF EXISTS public."IX_Shops_OwnerId";
DROP INDEX IF EXISTS public."IX_Reviews_UserId";
DROP INDEX IF EXISTS public."IX_Reviews_ProductId";
DROP INDEX IF EXISTS public."IX_RefreshTokens_UserId";
DROP INDEX IF EXISTS public."IX_RefreshTokens_Token";
DROP INDEX IF EXISTS public."IX_Products_Slug";
DROP INDEX IF EXISTS public."IX_Products_ShopId";
DROP INDEX IF EXISTS public."IX_Products_CategoryId";
DROP INDEX IF EXISTS public."IX_ProductImages_ProductId";
DROP INDEX IF EXISTS public."IX_Orders_UserId";
DROP INDEX IF EXISTS public."IX_Orders_OrderCode";
DROP INDEX IF EXISTS public."IX_Orders_AddressId";
DROP INDEX IF EXISTS public."IX_OrderDetails_ProductId";
DROP INDEX IF EXISTS public."IX_OrderDetails_OrderId";
DROP INDEX IF EXISTS public."IX_Conversations_ShopId";
DROP INDEX IF EXISTS public."IX_Conversations_BuyerId_ShopId";
DROP INDEX IF EXISTS public."IX_ChatMessages_SenderId";
DROP INDEX IF EXISTS public."IX_ChatMessages_ConversationId_CreatedAt";
DROP INDEX IF EXISTS public."IX_Categories_Slug";
DROP INDEX IF EXISTS public."IX_Categories_ParentId";
DROP INDEX IF EXISTS public."IX_CartItems_UserId_ProductId";
DROP INDEX IF EXISTS public."IX_CartItems_ProductId";
DROP INDEX IF EXISTS public."IX_AspNetUserRoles_RoleId";
DROP INDEX IF EXISTS public."IX_AspNetUserLogins_UserId";
DROP INDEX IF EXISTS public."IX_AspNetUserClaims_UserId";
DROP INDEX IF EXISTS public."IX_AspNetRoleClaims_RoleId";
DROP INDEX IF EXISTS public."IX_Addresses_UserId";
DROP INDEX IF EXISTS public."EmailIndex";
ALTER TABLE IF EXISTS ONLY public."__EFMigrationsHistory" DROP CONSTRAINT IF EXISTS "PK___EFMigrationsHistory";
ALTER TABLE IF EXISTS ONLY public."WarrantyClaims" DROP CONSTRAINT IF EXISTS "PK_WarrantyClaims";
ALTER TABLE IF EXISTS ONLY public."Shops" DROP CONSTRAINT IF EXISTS "PK_Shops";
ALTER TABLE IF EXISTS ONLY public."Reviews" DROP CONSTRAINT IF EXISTS "PK_Reviews";
ALTER TABLE IF EXISTS ONLY public."RefreshTokens" DROP CONSTRAINT IF EXISTS "PK_RefreshTokens";
ALTER TABLE IF EXISTS ONLY public."Products" DROP CONSTRAINT IF EXISTS "PK_Products";
ALTER TABLE IF EXISTS ONLY public."ProductImages" DROP CONSTRAINT IF EXISTS "PK_ProductImages";
ALTER TABLE IF EXISTS ONLY public."Orders" DROP CONSTRAINT IF EXISTS "PK_Orders";
ALTER TABLE IF EXISTS ONLY public."OrderDetails" DROP CONSTRAINT IF EXISTS "PK_OrderDetails";
ALTER TABLE IF EXISTS ONLY public."Conversations" DROP CONSTRAINT IF EXISTS "PK_Conversations";
ALTER TABLE IF EXISTS ONLY public."ChatMessages" DROP CONSTRAINT IF EXISTS "PK_ChatMessages";
ALTER TABLE IF EXISTS ONLY public."Categories" DROP CONSTRAINT IF EXISTS "PK_Categories";
ALTER TABLE IF EXISTS ONLY public."CartItems" DROP CONSTRAINT IF EXISTS "PK_CartItems";
ALTER TABLE IF EXISTS ONLY public."AspNetUsers" DROP CONSTRAINT IF EXISTS "PK_AspNetUsers";
ALTER TABLE IF EXISTS ONLY public."AspNetUserTokens" DROP CONSTRAINT IF EXISTS "PK_AspNetUserTokens";
ALTER TABLE IF EXISTS ONLY public."AspNetUserRoles" DROP CONSTRAINT IF EXISTS "PK_AspNetUserRoles";
ALTER TABLE IF EXISTS ONLY public."AspNetUserLogins" DROP CONSTRAINT IF EXISTS "PK_AspNetUserLogins";
ALTER TABLE IF EXISTS ONLY public."AspNetUserClaims" DROP CONSTRAINT IF EXISTS "PK_AspNetUserClaims";
ALTER TABLE IF EXISTS ONLY public."AspNetRoles" DROP CONSTRAINT IF EXISTS "PK_AspNetRoles";
ALTER TABLE IF EXISTS ONLY public."AspNetRoleClaims" DROP CONSTRAINT IF EXISTS "PK_AspNetRoleClaims";
ALTER TABLE IF EXISTS ONLY public."Addresses" DROP CONSTRAINT IF EXISTS "PK_Addresses";
DROP TABLE IF EXISTS public."__EFMigrationsHistory";
DROP TABLE IF EXISTS public."WarrantyClaims";
DROP TABLE IF EXISTS public."Shops";
DROP TABLE IF EXISTS public."Reviews";
DROP TABLE IF EXISTS public."RefreshTokens";
DROP TABLE IF EXISTS public."Products";
DROP TABLE IF EXISTS public."ProductImages";
DROP TABLE IF EXISTS public."Orders";
DROP TABLE IF EXISTS public."OrderDetails";
DROP TABLE IF EXISTS public."Conversations";
DROP TABLE IF EXISTS public."ChatMessages";
DROP TABLE IF EXISTS public."Categories";
DROP TABLE IF EXISTS public."CartItems";
DROP TABLE IF EXISTS public."AspNetUsers";
DROP TABLE IF EXISTS public."AspNetUserTokens";
DROP TABLE IF EXISTS public."AspNetUserRoles";
DROP TABLE IF EXISTS public."AspNetUserLogins";
DROP TABLE IF EXISTS public."AspNetUserClaims";
DROP TABLE IF EXISTS public."AspNetRoles";
DROP TABLE IF EXISTS public."AspNetRoleClaims";
DROP TABLE IF EXISTS public."Addresses";
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Addresses" (
    "Id" uuid NOT NULL,
    "FullName" text NOT NULL,
    "Phone" text NOT NULL,
    "Street" text NOT NULL,
    "Ward" text NOT NULL,
    "District" text NOT NULL,
    "City" text NOT NULL,
    "IsDefault" boolean NOT NULL,
    "UserId" uuid NOT NULL
);


--
-- Name: AspNetRoleClaims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AspNetRoleClaims" (
    "Id" integer NOT NULL,
    "RoleId" uuid NOT NULL,
    "ClaimType" text,
    "ClaimValue" text
);


--
-- Name: AspNetRoleClaims_Id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public."AspNetRoleClaims" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."AspNetRoleClaims_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: AspNetRoles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AspNetRoles" (
    "Id" uuid NOT NULL,
    "Name" character varying(256),
    "NormalizedName" character varying(256),
    "ConcurrencyStamp" text
);


--
-- Name: AspNetUserClaims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AspNetUserClaims" (
    "Id" integer NOT NULL,
    "UserId" uuid NOT NULL,
    "ClaimType" text,
    "ClaimValue" text
);


--
-- Name: AspNetUserClaims_Id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public."AspNetUserClaims" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."AspNetUserClaims_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: AspNetUserLogins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AspNetUserLogins" (
    "LoginProvider" text NOT NULL,
    "ProviderKey" text NOT NULL,
    "ProviderDisplayName" text,
    "UserId" uuid NOT NULL
);


--
-- Name: AspNetUserRoles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AspNetUserRoles" (
    "UserId" uuid NOT NULL,
    "RoleId" uuid NOT NULL
);


--
-- Name: AspNetUserTokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AspNetUserTokens" (
    "UserId" uuid NOT NULL,
    "LoginProvider" text NOT NULL,
    "Name" text NOT NULL,
    "Value" text
);


--
-- Name: AspNetUsers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AspNetUsers" (
    "Id" uuid NOT NULL,
    "FullName" character varying(200) NOT NULL,
    "AvatarUrl" character varying(500) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "IsActive" boolean NOT NULL,
    "Role" integer NOT NULL,
    "UserName" character varying(256),
    "NormalizedUserName" character varying(256),
    "Email" character varying(256),
    "NormalizedEmail" character varying(256),
    "EmailConfirmed" boolean NOT NULL,
    "PasswordHash" text,
    "SecurityStamp" text,
    "ConcurrencyStamp" text,
    "PhoneNumber" text,
    "PhoneNumberConfirmed" boolean NOT NULL,
    "TwoFactorEnabled" boolean NOT NULL,
    "LockoutEnd" timestamp with time zone,
    "LockoutEnabled" boolean NOT NULL,
    "AccessFailedCount" integer NOT NULL
);


--
-- Name: CartItems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CartItems" (
    "Id" uuid NOT NULL,
    "Quantity" integer NOT NULL,
    "UserId" uuid NOT NULL,
    "ProductId" uuid NOT NULL
);


--
-- Name: Categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Categories" (
    "Id" uuid NOT NULL,
    "Name" character varying(150) NOT NULL,
    "Slug" character varying(150) NOT NULL,
    "Description" text NOT NULL,
    "ParentId" uuid,
    "OwnerShopId" uuid
);


--
-- Name: ChatMessages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChatMessages" (
    "Id" uuid NOT NULL,
    "ConversationId" uuid NOT NULL,
    "SenderId" uuid NOT NULL,
    "Content" character varying(2000) NOT NULL,
    "IsRead" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL
);


--
-- Name: Conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Conversations" (
    "Id" uuid NOT NULL,
    "BuyerId" uuid NOT NULL,
    "ShopId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "LastMessageAt" timestamp with time zone NOT NULL
);


--
-- Name: OrderDetails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OrderDetails" (
    "Id" uuid NOT NULL,
    "Quantity" integer NOT NULL,
    "UnitPrice" numeric(18,2) NOT NULL,
    "TotalPrice" numeric(18,2) NOT NULL,
    "OrderId" uuid NOT NULL,
    "ProductId" uuid NOT NULL
);


--
-- Name: Orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Orders" (
    "Id" uuid NOT NULL,
    "OrderCode" character varying(50) NOT NULL,
    "Status" integer NOT NULL,
    "TotalAmount" numeric(18,2) NOT NULL,
    "ShippingFee" numeric(18,2) NOT NULL,
    "Note" text NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "PaidAt" timestamp with time zone,
    "UserId" uuid NOT NULL,
    "AddressId" uuid NOT NULL
);


--
-- Name: ProductImages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ProductImages" (
    "Id" uuid NOT NULL,
    "Url" character varying(500) NOT NULL,
    "AltText" text NOT NULL,
    "IsPrimary" boolean NOT NULL,
    "DisplayOrder" integer NOT NULL,
    "ProductId" uuid NOT NULL
);


--
-- Name: Products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Products" (
    "Id" uuid NOT NULL,
    "Name" character varying(300) NOT NULL,
    "Slug" character varying(300) NOT NULL,
    "Description" text NOT NULL,
    "Price" numeric(18,2) NOT NULL,
    "SalePrice" numeric(18,2),
    "StockQuantity" integer NOT NULL,
    "Sku" text NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "CategoryId" uuid,
    "ShopId" uuid NOT NULL,
    "WarrantyMonths" integer DEFAULT 0 NOT NULL
);


--
-- Name: RefreshTokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RefreshTokens" (
    "Id" uuid NOT NULL,
    "Token" character varying(500) NOT NULL,
    "ExpiresAt" timestamp with time zone NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "IsRevoked" boolean NOT NULL,
    "IsUsed" boolean NOT NULL,
    "UserId" uuid NOT NULL
);


--
-- Name: Reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Reviews" (
    "Id" uuid NOT NULL,
    "Rating" integer NOT NULL,
    "Comment" character varying(1000) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "ProductId" uuid NOT NULL,
    "UserId" uuid NOT NULL
);


--
-- Name: Shops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Shops" (
    "Id" uuid NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Slug" character varying(200) NOT NULL,
    "Description" text NOT NULL,
    "LogoUrl" text NOT NULL,
    "Status" integer NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "OwnerId" uuid NOT NULL
);


--
-- Name: WarrantyClaims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WarrantyClaims" (
    "Id" uuid NOT NULL,
    "ClaimCode" character varying(50) NOT NULL,
    "Description" character varying(2000) NOT NULL,
    "ImageUrl" character varying(500) NOT NULL,
    "Status" integer NOT NULL,
    "Resolution" integer NOT NULL,
    "ResolutionNote" character varying(1000) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "ResolvedAt" timestamp with time zone,
    "OrderDetailId" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "ShopId" uuid NOT NULL
);


--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


--
-- Data for Name: Addresses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Addresses" ("Id", "FullName", "Phone", "Street", "Ward", "District", "City", "IsDefault", "UserId") FROM stdin;
\.


--
-- Data for Name: AspNetRoleClaims; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."AspNetRoleClaims" ("Id", "RoleId", "ClaimType", "ClaimValue") FROM stdin;
\.


--
-- Data for Name: AspNetRoles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."AspNetRoles" ("Id", "Name", "NormalizedName", "ConcurrencyStamp") FROM stdin;
019ff6c1-7c46-7f5f-ad52-4a645fd423d6	Customer	CUSTOMER	f15bc28b-84d6-403e-af01-5f2226788819
019ff6c1-7cbd-7da7-8fce-0d931933912e	Seller	SELLER	6716f63b-0ef3-4024-8016-73368361fc68
019ff6c1-7cc2-7aee-8fc2-b55bf90f0ed7	Admin	ADMIN	5f5c8698-349f-4de4-8826-e3bfad592fa2
\.


--
-- Data for Name: AspNetUserClaims; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."AspNetUserClaims" ("Id", "UserId", "ClaimType", "ClaimValue") FROM stdin;
\.


--
-- Data for Name: AspNetUserLogins; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."AspNetUserLogins" ("LoginProvider", "ProviderKey", "ProviderDisplayName", "UserId") FROM stdin;
\.


--
-- Data for Name: AspNetUserRoles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."AspNetUserRoles" ("UserId", "RoleId") FROM stdin;
019ff6c1-7d21-7479-9325-962a9cdf6490	019ff6c1-7cc2-7aee-8fc2-b55bf90f0ed7
019ff6c1-7ea9-78d8-af73-53af1d0f8f4b	019ff6c1-7cbd-7da7-8fce-0d931933912e
019ff6c1-7ee8-72e7-9cb2-d39dc757d074	019ff6c1-7cbd-7da7-8fce-0d931933912e
019ff6c1-7f46-7b40-a2ca-979665f35f11	019ff6c1-7cbd-7da7-8fce-0d931933912e
019ff6c1-7f8d-7375-b945-9eb8462d51de	019ff6c1-7cbd-7da7-8fce-0d931933912e
019ff6c1-7fc9-71d6-8bcd-9b67fc76babd	019ff6c1-7cbd-7da7-8fce-0d931933912e
019ff6c1-8005-77dc-85c5-1eb010cea7db	019ff6c1-7cbd-7da7-8fce-0d931933912e
019ff6c1-8043-798a-b232-780a0bc5e339	019ff6c1-7cbd-7da7-8fce-0d931933912e
\.


--
-- Data for Name: AspNetUserTokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."AspNetUserTokens" ("UserId", "LoginProvider", "Name", "Value") FROM stdin;
\.


--
-- Data for Name: AspNetUsers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."AspNetUsers" ("Id", "FullName", "AvatarUrl", "CreatedAt", "IsActive", "Role", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp", "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", "LockoutEnd", "LockoutEnabled", "AccessFailedCount") FROM stdin;
019ff6c1-7d21-7479-9325-962a9cdf6490	System Admin		2026-08-12 16:15:03.383721+00	t	2	admin	ADMIN	admin@ks.com	ADMIN@KS.COM	f	AQAAAAIAAYagAAAAEGGnZj9QJ7GJNEw0RgDhcGYiEXX2FjCBWn3OLjIqf5AH6tUtKV8jpRALoQzAxDl+tA==	QZVA2LVRHZPXCE3Z2UJRWJNN5CGEXOIF	89c9c8df-d5e0-47f6-a85c-81cb349e8362	\N	f	f	\N	t	0
019ff6c1-7ea9-78d8-af73-53af1d0f8f4b	Alice Nguyen		2026-08-12 16:15:03.79714+00	t	1	demo_alice	DEMO_ALICE	seller1@demo.ks	SELLER1@DEMO.KS	f	AQAAAAIAAYagAAAAEPY4wE/qpd3UQgNLq5aEq4UkPM31MVbFvvCrrTKQiw7Khd+LfRhblLU2nYWfGirw+A==	PJTRZFK2K5M3NQC6FLIJ4QLH7GF3OPQS	6bc27ff0-72cc-4c2e-8d01-3183fee5de22	\N	f	f	\N	t	0
019ff6c1-7ee8-72e7-9cb2-d39dc757d074	Bob Tran		2026-08-12 16:15:03.860261+00	t	1	demo_bob	DEMO_BOB	seller2@demo.ks	SELLER2@DEMO.KS	f	AQAAAAIAAYagAAAAEIywkU2DBxrzF7MaW4hjW4noSJc7Lk+SZtgD22ugkqtvgbHP5xj9xYysqCXwxtesGw==	42N3KWS2EST35MWMEEFZ7PRFRVV3IEVQ	cb8e9a97-a2ca-4c15-8f82-ce7cdceb47ac	\N	f	f	\N	t	0
019ff6c1-7f46-7b40-a2ca-979665f35f11	Carol Pham		2026-08-12 16:15:03.954871+00	t	1	demo_iot	DEMO_IOT	iot@demo.ks	IOT@DEMO.KS	f	AQAAAAIAAYagAAAAEL+Ja13rOkZpFpv3Rexd90Sl3H4FgO6MqBmesnqOEUiVZTR93XiimDxQ2T/V8gJC8A==	BKIE6OXI4EJNIILSX6JYBHZDXQMFHUKT	75834f66-e1d3-438a-bcfb-6121bc04f2fb	\N	f	f	\N	t	0
019ff6c1-7f8d-7375-b945-9eb8462d51de	David Le		2026-08-12 16:15:04.02664+00	t	1	demo_ai	DEMO_AI	ai@demo.ks	AI@DEMO.KS	f	AQAAAAIAAYagAAAAEKfWl98r28Sp/gV/f8ulTfdElK+DEqWUqTJHk4Cj6x7lTDEgbd9FCkGDT/Zj9Uft0w==	37ADGZZIFFGKHPR7MXY26LLLLAFXGLJV	8ef8c773-569f-4a6b-bdb3-b654434eeca1	\N	f	f	\N	t	0
019ff6c1-7fc9-71d6-8bcd-9b67fc76babd	Emma Vo		2026-08-12 16:15:04.086899+00	t	1	demo_sec	DEMO_SEC	security@demo.ks	SECURITY@DEMO.KS	f	AQAAAAIAAYagAAAAEJtgaXfCDPRZEhGRpAmW9WxHJEPmmghqA3N/q1rfagG/OWR8wQ2otPFZTSZhqFqu4A==	BQNANC7TSCKMQJPEBCUGB4LWM236BNUO	0192d979-dea1-4c74-bb4a-e0506ae0b92b	\N	f	f	\N	t	0
019ff6c1-8005-77dc-85c5-1eb010cea7db	Frank Do		2026-08-12 16:15:04.147311+00	t	1	demo_ops	DEMO_OPS	sysadmin@demo.ks	SYSADMIN@DEMO.KS	f	AQAAAAIAAYagAAAAEHIysOvMKVcTlbeXwcQ0+pCzJOTzc1CArsmALrKjnzH8FsyVbKYsgrCnts6aGHuRMQ==	5PACCSJRW4MCMMV747ICNUR7VPTA5VXJ	2b42bd24-c9d1-4d05-8682-5e5b3f3d90b8	\N	f	f	\N	t	0
019ff6c1-8043-798a-b232-780a0bc5e339	Grace Ha		2026-08-12 16:15:04.206685+00	t	1	demo_dev	DEMO_DEV	developer@demo.ks	DEVELOPER@DEMO.KS	f	AQAAAAIAAYagAAAAEIe6CxIj2+SmuoWQAYeYY2C2cN7B++iD9Zed3TUz2Lw2S6Adz6ox9OkIUO45xEUCng==	J67XLPJQW3LELPJ76R4TAQOAYTSHO5TV	be1012a1-e4af-47a7-938f-003243136c14	\N	f	f	\N	t	0
\.


--
-- Data for Name: CartItems; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CartItems" ("Id", "Quantity", "UserId", "ProductId") FROM stdin;
\.


--
-- Data for Name: Categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Categories" ("Id", "Name", "Slug", "Description", "ParentId", "OwnerShopId") FROM stdin;
0f898ee6-0272-4d78-b006-42f0ce153fc9	Accessories	accessories		\N	\N
105fe8c5-abaa-4f73-ae44-e3b81aa09929	Developer Tools	developer		\N	\N
5d67cf24-bac3-4ebf-888e-e13755469c2c	IoT & Embedded	iot		\N	\N
608164cd-7934-4a25-9a24-c141a7e1baa9	SysAdmin & DevOps	sysadmin		\N	\N
6ff5de4d-6d74-4ca1-ba5d-8dcd69ff6de4	AI & Machine Learning	ai-ml		\N	\N
bea80972-6cef-400c-8528-7ef7101049cb	Electronics	electronics		\N	\N
ccd2e691-3551-4368-ac87-959d8c663deb	Cybersecurity	security		\N	\N
104a0951-1586-4ec1-96f5-c83aa36cee21	Tablets	tablets		bea80972-6cef-400c-8528-7ef7101049cb	\N
408a3234-b101-4e79-9f30-5a9d5bee185e	Laptops	laptops		bea80972-6cef-400c-8528-7ef7101049cb	\N
fac9200a-0421-472b-bea3-4e246b6508ff	Phones	phones		bea80972-6cef-400c-8528-7ef7101049cb	\N
\.


--
-- Data for Name: ChatMessages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ChatMessages" ("Id", "ConversationId", "SenderId", "Content", "IsRead", "CreatedAt") FROM stdin;
\.


--
-- Data for Name: Conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Conversations" ("Id", "BuyerId", "ShopId", "CreatedAt", "LastMessageAt") FROM stdin;
\.


--
-- Data for Name: OrderDetails; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OrderDetails" ("Id", "Quantity", "UnitPrice", "TotalPrice", "OrderId", "ProductId") FROM stdin;
\.


--
-- Data for Name: Orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Orders" ("Id", "OrderCode", "Status", "TotalAmount", "ShippingFee", "Note", "CreatedAt", "PaidAt", "UserId", "AddressId") FROM stdin;
\.


--
-- Data for Name: ProductImages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ProductImages" ("Id", "Url", "AltText", "IsPrimary", "DisplayOrder", "ProductId") FROM stdin;
02d298a9-7ac3-4fb9-ac89-2677201ba76a	http://localhost:5000/uploads/arduino-uno-r4-wifi.jpg	Arduino Uno R4 WiFi	t	0	faf8698e-4f55-43d9-afe4-13c041e5a1ee
034ff54e-c68c-41e6-ad7f-be1a069eb9ea	http://localhost:5000/uploads/apple-airpower-wireless-charger.jpg	Apple Airpower Wireless Charger	t	0	58c2209e-a47a-40df-b60b-4deddadc3324
0b6824dd-3a2f-40a6-8e65-bb42418646dd	http://localhost:5000/uploads/24-port-managed-switch.jpg	24-Port Managed Switch	t	0	eb4f15de-84e2-468a-b2b3-3656676aacc6
0e13f0ea-27a3-457a-b29e-bde90c483b96	http://localhost:5000/uploads/ubiquiti-unifi-dream-machine.jpg	Ubiquiti UniFi Dream Machine	t	0	8bf8aa4d-f5af-474d-bc82-3a7dd5bbbbba
113d762c-2690-41af-9645-f7d5637b0e39	http://localhost:5000/uploads/managed-pdu-rack-strip.jpg	Managed PDU Rack Strip	t	0	f78dddc2-7968-44ab-b3ee-38c5c9af6a4c
1862ae04-82ea-4b72-92de-8fd535cc3e6c	http://localhost:5000/uploads/amazon-echo-plus.jpg	Amazon Echo Plus	t	0	19d83c2f-2083-44bb-9284-5f7cb458218b
1c612c0c-54f6-43e8-9224-257573bbd713	http://localhost:5000/uploads/raspberry-pi-pico-w.jpg	Raspberry Pi Pico W	t	0	70d2e6d4-fbeb-4e4b-a62a-1f5930c353a4
26734384-2d0b-4b9e-a4f0-f735d1c7362f	http://localhost:5000/uploads/samsung-galaxy-tab-s8-plus-grey.jpg	Samsung Galaxy Tab S8 Plus Grey	t	0	2ed91664-d6da-4924-9fc6-0ab844a8bdb0
2d8008c9-ecfd-4fc7-9897-61892ebad4fc	http://localhost:5000/uploads/jetbrains-all-products-pack.jpg	JetBrains All Products Pack	t	0	6803c4e6-4c08-44d5-9e0c-97197e90c76a
2db86f49-8f9c-43aa-9628-4948a2d74652	http://localhost:5000/uploads/new-dell-xps-13-9300-laptop.jpg	New DELL XPS 13 9300 Laptop	t	0	ebf91787-b20a-464f-b7a3-ecdf06cb7e69
2fc37c53-8df6-4237-819d-11853b41ea44	http://localhost:5000/uploads/ups-1500va-rackmount.jpg	UPS 1500VA Rackmount	t	0	5c92d2c0-f072-45b6-88b2-a6aba3422ae5
351eef8d-20a5-45f1-900f-4dd18694d0a6	http://localhost:5000/uploads/nvidia-rtx-4090-24gb.jpg	NVIDIA RTX 4090 24GB	t	0	756d36ee-63af-428d-9c9f-51b13a105f3b
37ed2db2-af56-4a42-ae5b-7388adb6f68d	http://localhost:5000/uploads/huawei-matebook-x-pro.jpg	Huawei Matebook X Pro	t	0	069d1a06-175a-46bb-ba17-5f0a4a03f1b8
3d2f6ae5-8062-40e6-bb61-6041e6068cdf	http://localhost:5000/uploads/usb-c-docking-station.jpg	USB-C Docking Station	t	0	0bfa218a-d57b-4a5d-be67-6d0ea3db12c8
41954c29-d269-432b-a3a6-7e22e5f4c0b2	http://localhost:5000/uploads/oppo-f19-pro-plus.jpg	Oppo F19 Pro Plus	t	0	4b92f41b-bac9-44cc-b16c-1eb52ef9c8c8
44fb5a28-4b82-4a96-ac15-348b9f972883	http://localhost:5000/uploads/apple-airpods-max-silver.jpg	Apple AirPods Max Silver	t	0	af663f53-312e-4f63-9ccd-dfea8a1af9ed
45e7f189-4a9e-4575-8db1-a5d972fb32d0	http://localhost:5000/uploads/asus-zenbook-pro-dual-screen-laptop.jpg	Asus Zenbook Pro Dual Screen Laptop	t	0	e881884b-9094-4ee1-93e1-3080e99b9d5d
481e2d5d-3838-4f99-bcd0-db5fa6976662	http://localhost:5000/uploads/nitrokey-hsm-2.jpg	Nitrokey HSM 2	t	0	3f97518a-3a96-4ff2-b21b-a8d7bbafbd07
4fbec6fa-a722-4bef-8893-9550c8d619db	http://localhost:5000/uploads/hailo-8-ai-accelerator.jpg	Hailo-8 AI Accelerator	t	0	a502dcc6-bf74-4bb7-b01d-8c8efabea37c
58429ec4-338d-484d-a074-58125a503d5b	http://localhost:5000/uploads/nvidia-jetson-orin-nano.jpg	NVIDIA Jetson Orin Nano	t	0	c306bf39-38b1-4fca-93a8-97c66342a1f5
584b989b-ec25-4d2f-892f-22500b7c4416	http://localhost:5000/uploads/apple-homepod-mini-cosmic-grey.jpg	Apple HomePod Mini Cosmic Grey	t	0	e742efc3-dab1-4e76-a752-03a65405f311
6005a62e-4602-43b6-9fa6-9f91f02f406e	http://localhost:5000/uploads/google-coral-usb-accelerator.jpg	Google Coral USB Accelerator	t	0	f6e74975-ce1b-40de-94e2-f058d66d983e
6504042d-3cad-4242-9a86-c4a46f358e6b	http://localhost:5000/uploads/samsung-galaxy-tab-white.jpg	Samsung Galaxy Tab White	t	0	2131a8f9-23e3-4fcf-af9b-96f353079893
75224adb-2970-4f49-a2bb-6bff2416fbb2	http://localhost:5000/uploads/aluminum-laptop-stand.jpg	Aluminum Laptop Stand	t	0	948ef6ca-a646-440c-bdcf-e49b8fb378cd
7ac73fc5-214b-49cb-a10b-c3cc63042d42	http://localhost:5000/uploads/hak5-wifi-pineapple.jpg	Hak5 WiFi Pineapple	t	0	b2063c8f-ce05-4fc2-88ee-6a402d686b72
8c06544a-c8be-4ffd-94d3-cf159d40fb17	http://localhost:5000/uploads/iphone-13-pro.jpg	iPhone 13 Pro	t	0	25e350f6-d3bf-4a6e-b79b-62a9ce96d455
8d40f384-e407-47b3-82cd-7717003c5412	http://localhost:5000/uploads/synology-4-bay-nas.jpg	Synology 4-Bay NAS	t	0	b89fd485-a546-46fd-a685-472768b74aa5
8f3c1c5f-b91f-4f50-a33b-a6c9d7b12b81	http://localhost:5000/uploads/lenovo-yoga-920.jpg	Lenovo Yoga 920	t	0	c659b727-967c-469d-8246-d412873d7713
954cdd66-2937-4d49-89a7-f29babe2b02e	http://localhost:5000/uploads/github-copilot-1-year.jpg	GitHub Copilot 1-Year	t	0	75f31b2a-33cc-4c4e-a4c9-dad2a30d91dd
95caec65-4c9b-4fa9-a5b4-6e815c86ed18	http://localhost:5000/uploads/esp32-devkit-v1.jpg	ESP32 DevKit V1	t	0	a6c2e538-9d2f-45ee-8700-d8b75c1b4471
9cce2ea3-7bae-44be-bcb7-5773035430ee	http://localhost:5000/uploads/1u-rackmount-server.jpg	1U Rackmount Server	t	0	a19aebd8-e926-4a12-bfb4-6dde1d0e898e
9cfcb958-ab3e-4bd0-a2db-6fe2a966d306	http://localhost:5000/uploads/zigbee-smart-hub.jpg	Zigbee Smart Hub	t	0	c3255f0c-eb9a-4503-b7c9-127682da5b22
9fba0b05-d964-444b-b58d-1ee1df5e95a8	http://localhost:5000/uploads/oppo-a57.jpg	Oppo A57	t	0	da7b0fc0-9fe6-4972-a581-7833e3fe4f85
a2ec7624-2809-4290-a649-4e4abeaef02c	http://localhost:5000/uploads/intel-neural-compute-stick-2.jpg	Intel Neural Compute Stick 2	t	0	a4deef40-6e88-44e6-88bf-f40940289be0
a309dd12-9ecb-4892-ae19-5259ed7f8247	http://localhost:5000/uploads/iphone-5s.jpg	iPhone 5s	t	0	cef8907e-7f5c-4e97-8855-0736293d33cf
a765890b-1142-4cd4-8e7f-b7f2938db6e7	http://localhost:5000/uploads/lora-gateway-8-channel.jpg	LoRa Gateway 8-Channel	t	0	1c27c405-1dba-4651-997c-195631e49dd7
ab2a7578-f364-47bb-8019-0dc7419daab2	http://localhost:5000/uploads/ergonomic-vertical-mouse.jpg	Ergonomic Vertical Mouse	t	0	a94451bc-2b6f-4d4d-8740-324c88ef6840
afe3326d-78a1-45d0-a562-99441468d7f4	http://localhost:5000/uploads/proxmark3-rdv4.jpg	Proxmark3 RDV4	t	0	3a35bbae-5ce0-491b-ad69-ddd0d2dbb932
b84bf7f0-e77b-49f6-b49a-450782d20fc1	http://localhost:5000/uploads/apple-airpods.jpg	Apple Airpods	t	0	f021c506-a54f-4cce-91a5-4031cb3b31a9
bb78a56b-0644-4747-9e56-789b3b8cc54b	http://localhost:5000/uploads/dev-monitor-4k-27.jpg	4K Dev Monitor 27-inch	t	0	e9583e31-8c19-41b6-9cd7-5155d801f8ec
c33267b3-c5f2-41db-b328-f16da122c1f6	http://localhost:5000/uploads/apple-macbook-pro-14-inch-space-grey.jpg	Apple MacBook Pro 14 Inch Space Grey	t	0	aa9cdc43-0c4e-43a1-a762-6d34bd143fd1
c3cc060e-4bdb-4d2e-bb78-69f3ac8c1094	http://localhost:5000/uploads/elgato-stream-deck-mk2.jpg	Elgato Stream Deck MK.2	t	0	bd9f720b-5543-4c31-9683-c221016e5235
c456bffe-2607-46a2-bdac-3bb3d5f65985	http://localhost:5000/uploads/ipad-mini-2021-starlight.jpg	iPad Mini 2021 Starlight	t	0	e61749cc-aff0-4235-b4d0-89781b2630a2
c69404c3-8d1c-4ebc-adf6-080beeee1fc4	http://localhost:5000/uploads/flipper-zero.jpg	Flipper Zero	t	0	09c4d802-c3a7-4243-877a-33f76c085deb
c7b67a78-9789-4ac7-a9ce-0d80b80f31d2	http://localhost:5000/uploads/faraday-signal-blocking-bag.jpg	Faraday Signal-Blocking Bag	t	0	08d93017-dacc-4e5a-8d29-fa1e0a67c2ad
c7c80b89-a691-4312-8854-06163f2faaba	http://localhost:5000/uploads/nvidia-a100-80gb.jpg	NVIDIA A100 80GB Tensor Core	t	0	a623903e-d4bb-49fa-99e7-78afac0c81e9
c97b1c76-a819-4854-9853-6c222531a271	http://localhost:5000/uploads/iphone-x.jpg	iPhone X	t	0	26b1f331-8fa9-4cc3-9203-eabb9c3e2a8d
cb00c7ad-ea82-45e7-89b9-446e72f458ce	http://localhost:5000/uploads/mmwave-radar-sensor.jpg	mmWave Radar Sensor	t	0	e6f9dcaa-79fc-4e46-a92d-23de4ce78faf
cd5cdb3e-bd26-41db-8997-35691e39e852	http://localhost:5000/uploads/iphone-6.jpg	iPhone 6	t	0	b447f17b-6ce1-447b-9a7a-7079a74a087f
d278d267-0dc0-404a-99f2-18836dd15554	http://localhost:5000/uploads/ai-workstation-threadripper.jpg	AI Workstation Threadripper	t	0	679a266a-8400-43e1-aa9c-8b9f4d2e9655
d823b053-8742-42d3-b664-3c11b62bd77b	http://localhost:5000/uploads/raspberry-pi-5-8gb.jpg	Raspberry Pi 5 8GB	t	0	3baf2929-4de5-419f-aab5-5bfe2a042cc4
df430d77-b068-4fa4-be07-5d31c2082dba	http://localhost:5000/uploads/apple-iphone-charger.jpg	Apple iPhone Charger	t	0	91931d51-da80-4cd3-8c53-3ca8062e540e
e048a39f-4e3c-4473-9c8c-3eee0a8172e1	http://localhost:5000/uploads/dht22-sensor-kit.jpg	DHT22 Sensor Kit	t	0	70c3a6c4-538b-4426-8c98-177397124dd4
e7ad19e6-2605-4cbe-96da-21f8272a4075	http://localhost:5000/uploads/yubikey-5-nfc.jpg	YubiKey 5 NFC	t	0	c549a8ef-63a9-4825-937e-7779ced05c0a
ea5c6653-f5f3-4fd4-8339-4798e6929434	http://localhost:5000/uploads/keychron-q1-mechanical-keyboard.jpg	Keychron Q1 Mechanical Keyboard	t	0	af9965f2-64b8-42f8-85a3-99a50bf43b52
f711af73-444b-4782-8903-3e2f076030b2	http://localhost:5000/uploads/kvm-over-ip-switch.jpg	KVM over IP Switch	t	0	ca835981-cb9b-4bd2-8534-a0c13e53b5a4
fc2fc98b-38df-491a-a398-90a99bde93fe	http://localhost:5000/uploads/usb-rubber-ducky.jpg	USB Rubber Ducky	t	0	579e9803-6001-46c0-8bd3-575c608ddaae
\.


--
-- Data for Name: Products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Products" ("Id", "Name", "Slug", "Description", "Price", "SalePrice", "StockQuantity", "Sku", "IsActive", "CreatedAt", "CategoryId", "ShopId", "WarrantyMonths") FROM stdin;
069d1a06-175a-46bb-ba17-5f0a4a03f1b8	Huawei Matebook X Pro	huawei-matebook-x-pro	The Huawei Matebook X Pro is a slim and stylish laptop with a high-resolution touchscreen display, offering a premium experience for users on the go.	1399.99	1268.67	75	LAP-HUA-HUA-080	t	2026-08-12 16:15:04.352785+00	408a3234-b101-4e79-9f30-5a9d5bee185e	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
08d93017-dacc-4e5a-8d29-fa1e0a67c2ad	Faraday Signal-Blocking Bag	faraday-signal-blocking-bag	A Faraday bag that blocks cellular, Wi-Fi, GPS and RFID signals to preserve digital evidence and protect devices from remote wiping or tracking.	29.99	24.99	150	SEC-FRD-BAG-407	t	2026-08-12 16:15:04.383056+00	ccd2e691-3551-4368-ac87-959d8c663deb	8b6e2397-e445-4c48-8026-53ac0a892805	12
09c4d802-c3a7-4243-877a-33f76c085deb	Flipper Zero	flipper-zero	The Flipper Zero is a portable multi-tool for pentesters and hardware hackers — sub-GHz radio, RFID/NFC, infrared and GPIO in a pocket device.	169.99	159.99	60	SEC-FLP-ZRO-402	t	2026-08-12 16:15:04.380083+00	ccd2e691-3551-4368-ac87-959d8c663deb	8b6e2397-e445-4c48-8026-53ac0a892805	12
0bfa218a-d57b-4a5d-be67-6d0ea3db12c8	USB-C Docking Station	usb-c-docking-station	A single-cable USB-C dock that adds dual displays, gigabit Ethernet, USB-A ports and 100W passthrough charging to any laptop.	129.99	114.99	110	DEV-DOK-USC-603	t	2026-08-12 16:15:04.389435+00	105fe8c5-abaa-4f73-ae44-e3b81aa09929	23d41cb4-046a-4d34-bfe7-59b8dab15d97	12
19d83c2f-2083-44bb-9284-5f7cb458218b	Amazon Echo Plus	amazon-echo-plus	The Amazon Echo Plus is a smart speaker with built-in Alexa voice control. It features premium sound quality and serves as a hub for controlling smart home d...	99.99	87.92	61	MOB-AMA-AMA-099	t	2026-08-12 16:15:04.363437+00	0f898ee6-0272-4d78-b006-42f0ce153fc9	4731c52c-f8d0-4685-bdd2-f96d5bfbb801	12
1c27c405-1dba-4651-997c-195631e49dd7	LoRa Gateway 8-Channel	lora-gateway-8-channel	An 8-channel LoRaWAN gateway that bridges long-range, low-power sensor networks to the internet — the backbone of city-scale and agricultural IoT.	159.99	139.99	45	IOT-LOR-8CH-205	t	2026-08-12 16:15:04.371999+00	5d67cf24-bac3-4ebf-888e-e13755469c2c	f7538956-ad8f-478c-ae22-f0fcef55c2f3	12
2131a8f9-23e3-4fcf-af9b-96f353079893	Samsung Galaxy Tab White	samsung-galaxy-tab-white	The Samsung Galaxy Tab in White is a sleek and versatile Android tablet. With a vibrant display, long-lasting battery, and a range of features, it offers a g...	349.99	286.29	92	TAB-SAM-SAM-161	t	2026-08-12 16:15:04.362381+00	104a0951-1586-4ec1-96f5-c83aa36cee21	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
25e350f6-d3bf-4a6e-b79b-62a9ce96d455	iPhone 13 Pro	iphone-13-pro	The iPhone 13 Pro is a cutting-edge smartphone with a powerful camera system, high-performance chip, and stunning display. It offers advanced features for us...	1099.99	996.92	56	SMA-APP-IPH-123	t	2026-08-12 16:15:04.356949+00	fac9200a-0421-472b-bea3-4e246b6508ff	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
26b1f331-8fa9-4cc3-9203-eabb9c3e2a8d	iPhone X	iphone-x	The iPhone X is a flagship smartphone featuring a bezel-less OLED display, facial recognition technology (Face ID), and impressive performance. It represents...	899.99	723.68	37	SMA-APP-IPH-124	t	2026-08-12 16:15:04.357825+00	fac9200a-0421-472b-bea3-4e246b6508ff	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
2ed91664-d6da-4924-9fc6-0ab844a8bdb0	Samsung Galaxy Tab S8 Plus Grey	samsung-galaxy-tab-s8-plus-grey	The Samsung Galaxy Tab S8 Plus in Grey is a high-performance Android tablet by Samsung. With a large AMOLED display, powerful processor, and S Pen support, i...	599.99	520.13	62	TAB-SAM-SAM-160	t	2026-08-12 16:15:04.361519+00	104a0951-1586-4ec1-96f5-c83aa36cee21	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
3a35bbae-5ce0-491b-ad69-ddd0d2dbb932	Proxmark3 RDV4	proxmark3-rdv4	The Proxmark3 RDV4 is the reference tool for RFID research, reading, emulating and analyzing LF and HF contactless cards and tags.	299.99	279.99	25	SEC-PXM-RV4-404	t	2026-08-12 16:15:04.381286+00	ccd2e691-3551-4368-ac87-959d8c663deb	8b6e2397-e445-4c48-8026-53ac0a892805	12
3baf2929-4de5-419f-aab5-5bfe2a042cc4	Raspberry Pi 5 8GB	raspberry-pi-5-8gb	The Raspberry Pi 5 with 8GB RAM is a credit-card sized computer powered by a quad-core Cortex-A76 CPU. Ideal for edge computing, home labs and IoT gateways.	89.99	82.99	120	IOT-RPI-RP5-201	t	2026-08-12 16:15:04.368323+00	5d67cf24-bac3-4ebf-888e-e13755469c2c	f7538956-ad8f-478c-ae22-f0fcef55c2f3	12
3f97518a-3a96-4ff2-b21b-a8d7bbafbd07	Nitrokey HSM 2	nitrokey-hsm-2	The Nitrokey HSM 2 is an open-source hardware security module that securely generates and stores cryptographic keys for PKI and code signing.	109.00	\N	50	SEC-NTK-HS2-406	t	2026-08-12 16:15:04.382484+00	ccd2e691-3551-4368-ac87-959d8c663deb	8b6e2397-e445-4c48-8026-53ac0a892805	12
4b92f41b-bac9-44cc-b16c-1eb52ef9c8c8	Oppo F19 Pro Plus	oppo-f19-pro-plus	The Oppo F19 Pro Plus is a feature-rich smartphone with a focus on camera capabilities. It boasts advanced photography features and a powerful performance fo...	399.99	325.43	78	SMA-OPP-OPP-126	t	2026-08-12 16:15:04.359548+00	fac9200a-0421-472b-bea3-4e246b6508ff	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
579e9803-6001-46c0-8bd3-575c608ddaae	USB Rubber Ducky	usb-rubber-ducky	The USB Rubber Ducky is a keystroke-injection tool that a target sees as a keyboard — a staple for demonstrating HID attack payloads in labs.	79.99	69.99	80	SEC-HAK-DUK-405	t	2026-08-12 16:15:04.381899+00	ccd2e691-3551-4368-ac87-959d8c663deb	8b6e2397-e445-4c48-8026-53ac0a892805	12
58c2209e-a47a-40df-b60b-4deddadc3324	Apple Airpower Wireless Charger	apple-airpower-wireless-charger	The Apple AirPower Wireless Charger provides a convenient way to charge your compatible Apple devices wirelessly. Simply place your devices on the charging m...	79.99	76.41	1	MOB-APP-APP-102	t	2026-08-12 16:15:04.365899+00	0f898ee6-0272-4d78-b006-42f0ce153fc9	4731c52c-f8d0-4685-bdd2-f96d5bfbb801	12
5c92d2c0-f072-45b6-88b2-a6aba3422ae5	UPS 1500VA Rackmount	ups-1500va-rackmount	A 1500VA line-interactive rackmount UPS with pure sine-wave output and network monitoring to keep infrastructure alive through outages.	279.99	249.99	36	OPS-UPS-15R-506	t	2026-08-12 16:15:04.386843+00	608164cd-7934-4a25-9a24-c141a7e1baa9	732fcd8b-98e5-4ab5-9f77-340fc2d1e13e	12
679a266a-8400-43e1-aa9c-8b9f4d2e9655	AI Workstation Threadripper	ai-workstation-threadripper	A pre-built AI workstation with an AMD Threadripper CPU, 128GB RAM and dual GPUs — ready for serious model training straight out of the box.	4999.99	4699.99	8	AI-WKS-TRX-306	t	2026-08-12 16:15:04.377955+00	6ff5de4d-6d74-4ca1-ba5d-8dcd69ff6de4	3246a0e0-e72c-49b5-b3aa-4f2423ff2b20	12
6803c4e6-4c08-44d5-9e0c-97197e90c76a	JetBrains All Products Pack	jetbrains-all-products-pack	A one-year individual license for the JetBrains All Products Pack — IntelliJ IDEA, PyCharm, WebStorm, Rider and every other JetBrains IDE.	289.00	\N	999	DEV-JBR-APP-607	t	2026-08-12 16:15:04.392626+00	105fe8c5-abaa-4f73-ae44-e3b81aa09929	23d41cb4-046a-4d34-bfe7-59b8dab15d97	12
70c3a6c4-538b-4426-8c98-177397124dd4	DHT22 Sensor Kit	dht22-sensor-kit	A DHT22 temperature and humidity sensor kit with jumper wires and resistors — a classic starting point for environmental monitoring builds.	14.99	11.99	240	IOT-DHT-K22-207	t	2026-08-12 16:15:04.373308+00	5d67cf24-bac3-4ebf-888e-e13755469c2c	f7538956-ad8f-478c-ae22-f0fcef55c2f3	12
70d2e6d4-fbeb-4e4b-a62a-1f5930c353a4	Raspberry Pi Pico W	raspberry-pi-pico-w	The Raspberry Pi Pico W is a tiny, ultra-affordable RP2040 microcontroller board with wireless connectivity for compact embedded projects.	6.99	\N	500	IOT-RPI-PCW-204	t	2026-08-12 16:15:04.371262+00	5d67cf24-bac3-4ebf-888e-e13755469c2c	f7538956-ad8f-478c-ae22-f0fcef55c2f3	12
756d36ee-63af-428d-9c9f-51b13a105f3b	NVIDIA RTX 4090 24GB	nvidia-rtx-4090-24gb	The NVIDIA RTX 4090 with 24GB GDDR6X delivers massive throughput for training and fine-tuning deep learning models, plus blistering local inference.	1799.99	1699.99	20	AI-NVD-4090-301	t	2026-08-12 16:15:04.374615+00	6ff5de4d-6d74-4ca1-ba5d-8dcd69ff6de4	3246a0e0-e72c-49b5-b3aa-4f2423ff2b20	12
75f31b2a-33cc-4c4e-a4c9-dad2a30d91dd	GitHub Copilot 1-Year	github-copilot-1-year	A one-year GitHub Copilot subscription — AI pair-programming that suggests whole lines and functions right inside your editor.	100.00	\N	999	DEV-GHC-1YR-608	t	2026-08-12 16:15:04.393311+00	105fe8c5-abaa-4f73-ae44-e3b81aa09929	23d41cb4-046a-4d34-bfe7-59b8dab15d97	12
8bf8aa4d-f5af-474d-bc82-3a7dd5bbbbba	Ubiquiti UniFi Dream Machine	ubiquiti-unifi-dream-machine	The UniFi Dream Machine combines a security gateway, controller, switch and access point into one appliance for clean, manageable networks.	379.99	349.99	40	OPS-UBI-UDM-501	t	2026-08-12 16:15:04.383664+00	608164cd-7934-4a25-9a24-c141a7e1baa9	732fcd8b-98e5-4ab5-9f77-340fc2d1e13e	12
91931d51-da80-4cd3-8c53-3ca8062e540e	Apple iPhone Charger	apple-iphone-charger	The Apple iPhone Charger is a high-quality charger designed for fast and efficient charging of your iPhone. Ensure your device stays powered up and ready to go.	19.99	16.29	31	MOB-APP-APP-104	t	2026-08-12 16:15:04.367386+00	0f898ee6-0272-4d78-b006-42f0ce153fc9	4731c52c-f8d0-4685-bdd2-f96d5bfbb801	12
948ef6ca-a646-440c-bdcf-e49b8fb378cd	Aluminum Laptop Stand	aluminum-laptop-stand	A sturdy aluminum laptop stand that raises your screen to eye level and improves airflow, keeping thermals and posture in check.	34.99	29.99	180	DEV-STD-ALU-606	t	2026-08-12 16:15:04.391765+00	105fe8c5-abaa-4f73-ae44-e3b81aa09929	23d41cb4-046a-4d34-bfe7-59b8dab15d97	12
a19aebd8-e926-4a12-bfb4-6dde1d0e898e	1U Rackmount Server	1u-rackmount-server	A 1U rackmount server with a Xeon CPU, ECC memory and redundant PSUs — dense, reliable compute for virtualization and self-hosting.	1299.99	1199.99	18	OPS-SRV-1U-503	t	2026-08-12 16:15:04.384944+00	608164cd-7934-4a25-9a24-c141a7e1baa9	732fcd8b-98e5-4ab5-9f77-340fc2d1e13e	12
a4deef40-6e88-44e6-88bf-f40940289be0	Intel Neural Compute Stick 2	intel-neural-compute-stick-2	The Intel Neural Compute Stick 2 is a plug-and-play USB accelerator powered by the Movidius Myriad X VPU for prototyping deep-learning inference.	99.99	84.99	70	AI-INT-NCS-305	t	2026-08-12 16:15:04.3772+00	6ff5de4d-6d74-4ca1-ba5d-8dcd69ff6de4	3246a0e0-e72c-49b5-b3aa-4f2423ff2b20	12
a502dcc6-bf74-4bb7-b01d-8c8efabea37c	Hailo-8 AI Accelerator	hailo-8-ai-accelerator	The Hailo-8 M.2 module delivers up to 26 TOPS at remarkable power efficiency, ideal for embedding real-time neural inference into edge products.	219.99	\N	40	AI-HAI-H8A-304	t	2026-08-12 16:15:04.376619+00	6ff5de4d-6d74-4ca1-ba5d-8dcd69ff6de4	3246a0e0-e72c-49b5-b3aa-4f2423ff2b20	12
a623903e-d4bb-49fa-99e7-78afac0c81e9	NVIDIA A100 80GB Tensor Core	nvidia-a100-80gb	The NVIDIA A100 80GB is a data-center GPU engineered for large-scale training and high-throughput inference across demanding AI and HPC workloads.	15999.99	\N	5	AI-NVD-A100-307	t	2026-08-12 16:15:04.378767+00	6ff5de4d-6d74-4ca1-ba5d-8dcd69ff6de4	3246a0e0-e72c-49b5-b3aa-4f2423ff2b20	12
a6c2e538-9d2f-45ee-8700-d8b75c1b4471	ESP32 DevKit V1	esp32-devkit-v1	The ESP32 DevKit V1 is a low-cost Wi-Fi + Bluetooth microcontroller board, perfect for connected sensors, home automation and battery-powered IoT nodes.	12.99	9.99	300	IOT-ESP-E32-202	t	2026-08-12 16:15:04.369453+00	5d67cf24-bac3-4ebf-888e-e13755469c2c	f7538956-ad8f-478c-ae22-f0fcef55c2f3	12
a94451bc-2b6f-4d4d-8740-324c88ef6840	Ergonomic Vertical Mouse	ergonomic-vertical-mouse	An ergonomic vertical mouse that keeps your wrist in a natural handshake position to reduce strain during all-day work.	39.99	34.99	200	DEV-MOU-VRT-605	t	2026-08-12 16:15:04.390843+00	105fe8c5-abaa-4f73-ae44-e3b81aa09929	23d41cb4-046a-4d34-bfe7-59b8dab15d97	12
aa9cdc43-0c4e-43a1-a762-6d34bd143fd1	Apple MacBook Pro 14 Inch Space Grey	apple-macbook-pro-14-inch-space-grey	The MacBook Pro 14 Inch in Space Grey is a powerful and sleek laptop, featuring Apple's M1 Pro chip for exceptional performance and a stunning Retina display.	1999.99	1906.19	24	LAP-APP-APP-078	t	2026-08-12 16:15:04.288486+00	408a3234-b101-4e79-9f30-5a9d5bee185e	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
af663f53-312e-4f63-9ccd-dfea8a1af9ed	Apple AirPods Max Silver	apple-airpods-max-silver	The Apple AirPods Max in Silver are premium over-ear headphones with high-fidelity audio, adaptive EQ, and active noise cancellation. Experience immersive so...	549.99	474.81	59	MOB-APP-APP-101	t	2026-08-12 16:15:04.365059+00	0f898ee6-0272-4d78-b006-42f0ce153fc9	4731c52c-f8d0-4685-bdd2-f96d5bfbb801	12
af9965f2-64b8-42f8-85a3-99a50bf43b52	Keychron Q1 Mechanical Keyboard	keychron-q1-mechanical-keyboard	The Keychron Q1 is a gasket-mounted, hot-swappable mechanical keyboard with a CNC aluminum body — a favorite for long coding sessions.	179.99	164.99	90	DEV-KEY-Q1M-601	t	2026-08-12 16:15:04.388177+00	105fe8c5-abaa-4f73-ae44-e3b81aa09929	23d41cb4-046a-4d34-bfe7-59b8dab15d97	12
b2063c8f-ce05-4fc2-88ee-6a402d686b72	Hak5 WiFi Pineapple	hak5-wifi-pineapple	The Hak5 WiFi Pineapple is a purpose-built platform for authorized wireless auditing and rogue-AP assessments during red-team engagements.	119.99	\N	35	SEC-HAK-WPA-403	t	2026-08-12 16:15:04.380681+00	ccd2e691-3551-4368-ac87-959d8c663deb	8b6e2397-e445-4c48-8026-53ac0a892805	12
b447f17b-6ce1-447b-9a7a-7079a74a087f	iPhone 6	iphone-6	The iPhone 6 is a stylish and capable smartphone with a larger display and improved performance. It introduced new features and design elements, making it a...	299.99	279.92	60	SMA-APP-IPH-122	t	2026-08-12 16:15:04.35617+00	fac9200a-0421-472b-bea3-4e246b6508ff	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
b89fd485-a546-46fd-a685-472768b74aa5	Synology 4-Bay NAS	synology-4-bay-nas	The Synology 4-Bay NAS delivers centralized storage, backups and Docker services with a polished DSM interface for homelabs and small teams.	449.99	419.99	30	OPS-SYN-4BN-504	t	2026-08-12 16:15:04.385583+00	608164cd-7934-4a25-9a24-c141a7e1baa9	732fcd8b-98e5-4ab5-9f77-340fc2d1e13e	12
bd9f720b-5543-4c31-9683-c221016e5235	Elgato Stream Deck MK.2	elgato-stream-deck-mk2	The Elgato Stream Deck MK.2 gives you 15 programmable LCD keys to trigger builds, run scripts and control your dev workflow at a tap.	149.99	139.99	75	DEV-ELG-SD2-604	t	2026-08-12 16:15:04.390028+00	105fe8c5-abaa-4f73-ae44-e3b81aa09929	23d41cb4-046a-4d34-bfe7-59b8dab15d97	12
c306bf39-38b1-4fca-93a8-97c66342a1f5	NVIDIA Jetson Orin Nano	nvidia-jetson-orin-nano	The Jetson Orin Nano developer kit brings up to 40 TOPS of AI performance to the edge, running modern vision and robotics models in a tiny footprint.	499.99	469.99	55	AI-NVD-ORN-302	t	2026-08-12 16:15:04.375289+00	6ff5de4d-6d74-4ca1-ba5d-8dcd69ff6de4	3246a0e0-e72c-49b5-b3aa-4f2423ff2b20	12
c3255f0c-eb9a-4503-b7c9-127682da5b22	Zigbee Smart Hub	zigbee-smart-hub	A Zigbee 3.0 smart home hub that locally controls lights, sensors and switches with low latency and no cloud dependency.	49.99	42.99	90	IOT-ZIG-HUB-206	t	2026-08-12 16:15:04.372681+00	5d67cf24-bac3-4ebf-888e-e13755469c2c	f7538956-ad8f-478c-ae22-f0fcef55c2f3	12
c549a8ef-63a9-4825-937e-7779ced05c0a	YubiKey 5 NFC	yubikey-5-nfc	The YubiKey 5 NFC is a hardware security key supporting FIDO2, U2F, OTP and smart-card protocols for phishing-resistant multi-factor authentication.	55.00	49.00	200	SEC-YUB-5NF-401	t	2026-08-12 16:15:04.379482+00	ccd2e691-3551-4368-ac87-959d8c663deb	8b6e2397-e445-4c48-8026-53ac0a892805	12
c659b727-967c-469d-8246-d412873d7713	Lenovo Yoga 920	lenovo-yoga-920	The Lenovo Yoga 920 is a 2-in-1 convertible laptop with a flexible hinge, allowing you to use it as a laptop or tablet, offering versatility and portability.	1099.99	1027.94	40	LAP-LEN-LEN-081	t	2026-08-12 16:15:04.353821+00	408a3234-b101-4e79-9f30-5a9d5bee185e	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
ca835981-cb9b-4bd2-8534-a0c13e53b5a4	KVM over IP Switch	kvm-over-ip-switch	A KVM-over-IP switch that gives BIOS-level remote keyboard, video and mouse access to headless servers from anywhere.	189.99	\N	42	OPS-KVM-IP-505	t	2026-08-12 16:15:04.386198+00	608164cd-7934-4a25-9a24-c141a7e1baa9	732fcd8b-98e5-4ab5-9f77-340fc2d1e13e	12
cef8907e-7f5c-4e97-8855-0736293d33cf	iPhone 5s	iphone-5s	The iPhone 5s is a classic smartphone known for its compact design and advanced features during its release. While it's an older model, it still provides a r...	199.99	174.17	25	SMA-APP-IPH-121	t	2026-08-12 16:15:04.355438+00	fac9200a-0421-472b-bea3-4e246b6508ff	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
da7b0fc0-9fe6-4972-a581-7833e3fe4f85	Oppo A57	oppo-a57	The Oppo A57 is a mid-range smartphone known for its sleek design and capable features. It offers a balance of performance and affordability, making it a pop...	249.99	\N	19	SMA-OPP-OPP-125	t	2026-08-12 16:15:04.358583+00	fac9200a-0421-472b-bea3-4e246b6508ff	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
e61749cc-aff0-4235-b4d0-89781b2630a2	iPad Mini 2021 Starlight	ipad-mini-2021-starlight	The iPad Mini 2021 in Starlight is a compact and powerful tablet from Apple. Featuring a stunning Retina display, powerful A-series chip, and a sleek design,...	499.99	481.79	47	TAB-APP-IPA-159	t	2026-08-12 16:15:04.360533+00	104a0951-1586-4ec1-96f5-c83aa36cee21	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
e6f9dcaa-79fc-4e46-a92d-23de4ce78faf	mmWave Radar Sensor	mmwave-radar-sensor	A 60GHz mmWave presence-detection radar module that senses micro-movements for reliable room occupancy and fall detection in smart spaces.	19.99	\N	160	IOT-MMW-RAD-208	t	2026-08-12 16:15:04.37393+00	5d67cf24-bac3-4ebf-888e-e13755469c2c	f7538956-ad8f-478c-ae22-f0fcef55c2f3	12
e742efc3-dab1-4e76-a752-03a65405f311	Apple HomePod Mini Cosmic Grey	apple-homepod-mini-cosmic-grey	The Apple HomePod Mini in Cosmic Grey is a compact smart speaker that delivers impressive audio and integrates seamlessly with the Apple ecosystem for a smar...	99.99	81.89	27	MOB-APP-APP-103	t	2026-08-12 16:15:04.366631+00	0f898ee6-0272-4d78-b006-42f0ce153fc9	4731c52c-f8d0-4685-bdd2-f96d5bfbb801	12
e881884b-9094-4ee1-93e1-3080e99b9d5d	Asus Zenbook Pro Dual Screen Laptop	asus-zenbook-pro-dual-screen-laptop	The Asus Zenbook Pro Dual Screen Laptop is a high-performance device with dual screens, providing productivity and versatility for creative professionals.	1799.99	1599.47	45	LAP-ASU-ASU-079	t	2026-08-12 16:15:04.351291+00	408a3234-b101-4e79-9f30-5a9d5bee185e	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
e9583e31-8c19-41b6-9cd7-5155d801f8ec	4K Dev Monitor 27-inch	dev-monitor-4k-27	A 27-inch 4K IPS monitor with USB-C power delivery and factory color calibration — crisp text and plenty of room for code and terminals.	399.99	359.99	60	DEV-MON-4K27-602	t	2026-08-12 16:15:04.388795+00	105fe8c5-abaa-4f73-ae44-e3b81aa09929	23d41cb4-046a-4d34-bfe7-59b8dab15d97	12
eb4f15de-84e2-468a-b2b3-3656676aacc6	24-Port Managed Switch	24-port-managed-switch	A 24-port gigabit managed switch with VLANs, LACP and PoE budget — the workhorse of a well-segmented server rack.	219.99	199.99	55	OPS-NET-24S-502	t	2026-08-12 16:15:04.38428+00	608164cd-7934-4a25-9a24-c141a7e1baa9	732fcd8b-98e5-4ab5-9f77-340fc2d1e13e	12
ebf91787-b20a-464f-b7a3-ecdf06cb7e69	New DELL XPS 13 9300 Laptop	new-dell-xps-13-9300-laptop	The New DELL XPS 13 9300 Laptop is a compact and powerful device, featuring a virtually borderless InfinityEdge display and high-end performance for various...	1499.99	1321.64	74	LAP-DEL-DEL-082	t	2026-08-12 16:15:04.354682+00	408a3234-b101-4e79-9f30-5a9d5bee185e	abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	12
f021c506-a54f-4cce-91a5-4031cb3b31a9	Apple Airpods	apple-airpods	The Apple Airpods offer a seamless wireless audio experience. With easy pairing, high-quality sound, and Siri integration, they are perfect for on-the-go lis...	129.99	109.79	67	MOB-APP-APP-100	t	2026-08-12 16:15:04.364259+00	0f898ee6-0272-4d78-b006-42f0ce153fc9	4731c52c-f8d0-4685-bdd2-f96d5bfbb801	12
f6e74975-ce1b-40de-94e2-f058d66d983e	Google Coral USB Accelerator	google-coral-usb-accelerator	The Coral USB Accelerator adds an Edge TPU coprocessor over USB-C, running TensorFlow Lite models fast and efficiently on any host machine.	59.99	54.99	130	AI-GOO-COR-303	t	2026-08-12 16:15:04.375954+00	6ff5de4d-6d74-4ca1-ba5d-8dcd69ff6de4	3246a0e0-e72c-49b5-b3aa-4f2423ff2b20	12
f78dddc2-7968-44ab-b3ee-38c5c9af6a4c	Managed PDU Rack Strip	managed-pdu-rack-strip	A managed rack PDU with per-outlet metering and remote switching, so you can power-cycle any device in the rack over the network.	159.99	144.99	48	OPS-PDU-RCK-507	t	2026-08-12 16:15:04.387474+00	608164cd-7934-4a25-9a24-c141a7e1baa9	732fcd8b-98e5-4ab5-9f77-340fc2d1e13e	12
faf8698e-4f55-43d9-afe4-13c041e5a1ee	Arduino Uno R4 WiFi	arduino-uno-r4-wifi	The Arduino Uno R4 WiFi pairs a 32-bit Renesas MCU with an ESP32-S3 radio and a built-in LED matrix — a friendly board for learning embedded and IoT.	27.99	24.50	180	IOT-ARD-R4W-203	t	2026-08-12 16:15:04.370427+00	5d67cf24-bac3-4ebf-888e-e13755469c2c	f7538956-ad8f-478c-ae22-f0fcef55c2f3	12
\.


--
-- Data for Name: RefreshTokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."RefreshTokens" ("Id", "Token", "ExpiresAt", "CreatedAt", "IsRevoked", "IsUsed", "UserId") FROM stdin;
\.


--
-- Data for Name: Reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Reviews" ("Id", "Rating", "Comment", "CreatedAt", "ProductId", "UserId") FROM stdin;
\.


--
-- Data for Name: Shops; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Shops" ("Id", "Name", "Slug", "Description", "LogoUrl", "Status", "CreatedAt", "OwnerId") FROM stdin;
4731c52c-f8d0-4685-bdd2-f96d5bfbb801	GadgetHub	gadgethub	Audio, smart speakers, chargers and mobile accessories.		1	2026-08-12 16:15:03.953559+00	019ff6c1-7ee8-72e7-9cb2-d39dc757d074
abdb8312-ecd5-427b-9bdb-c9d3b63a1ce4	TechWorld Store	techworld-store	Authentic laptops, smartphones and tablets from top brands.		1	2026-08-12 16:15:03.929991+00	019ff6c1-7ea9-78d8-af73-53af1d0f8f4b
23d41cb4-046a-4d34-bfe7-59b8dab15d97	DevTools Hub	devtools-hub	Keyboards, monitors, docks and software licenses that power a developer's workflow.		1	2026-08-12 16:15:04.278765+00	019ff6c1-8043-798a-b232-780a0bc5e339
3246a0e0-e72c-49b5-b3aa-4f2423ff2b20	Neural Forge	neural-forge	GPUs, edge accelerators and workstations built for training and deploying AI models.		1	2026-08-12 16:15:04.275477+00	019ff6c1-7f8d-7375-b945-9eb8462d51de
732fcd8b-98e5-4ab5-9f77-340fc2d1e13e	OpsCenter	opscenter	Networking, rackmount servers, NAS and power gear to run reliable infrastructure.		1	2026-08-12 16:15:04.277768+00	019ff6c1-8005-77dc-85c5-1eb010cea7db
8b6e2397-e445-4c48-8026-53ac0a892805	SecOps Armory	secops-armory	Hardware keys, pentest gadgets and security tooling for red and blue teams.		1	2026-08-12 16:15:04.276739+00	019ff6c1-7fc9-71d6-8bcd-9b67fc76babd
f7538956-ad8f-478c-ae22-f0fcef55c2f3	IoT Depot	iot-depot	Single-board computers, microcontrollers, sensors and gateways for makers and embedded engineers.		1	2026-08-12 16:15:04.274424+00	019ff6c1-7f46-7b40-a2ca-979665f35f11
\.


--
-- Data for Name: WarrantyClaims; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."WarrantyClaims" ("Id", "ClaimCode", "Description", "ImageUrl", "Status", "Resolution", "ResolutionNote", "CreatedAt", "UpdatedAt", "ResolvedAt", "OrderDetailId", "UserId", "ProductId", "ShopId") FROM stdin;
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20260808172656_InitialCreate	10.0.10
20260808182842_MakeProductCategoryNullable	10.0.10
20260809084525_AddChat	10.0.10
20260810202508_AddCategoryOwnerShop	10.0.10
20260811151042_AddWarranty	10.0.10
\.


--
-- Name: AspNetRoleClaims_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."AspNetRoleClaims_Id_seq"', 1, false);


--
-- Name: AspNetUserClaims_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."AspNetUserClaims_Id_seq"', 1, false);


--
-- Name: Addresses PK_Addresses; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Addresses"
    ADD CONSTRAINT "PK_Addresses" PRIMARY KEY ("Id");


--
-- Name: AspNetRoleClaims PK_AspNetRoleClaims; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetRoleClaims"
    ADD CONSTRAINT "PK_AspNetRoleClaims" PRIMARY KEY ("Id");


--
-- Name: AspNetRoles PK_AspNetRoles; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetRoles"
    ADD CONSTRAINT "PK_AspNetRoles" PRIMARY KEY ("Id");


--
-- Name: AspNetUserClaims PK_AspNetUserClaims; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserClaims"
    ADD CONSTRAINT "PK_AspNetUserClaims" PRIMARY KEY ("Id");


--
-- Name: AspNetUserLogins PK_AspNetUserLogins; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserLogins"
    ADD CONSTRAINT "PK_AspNetUserLogins" PRIMARY KEY ("LoginProvider", "ProviderKey");


--
-- Name: AspNetUserRoles PK_AspNetUserRoles; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserRoles"
    ADD CONSTRAINT "PK_AspNetUserRoles" PRIMARY KEY ("UserId", "RoleId");


--
-- Name: AspNetUserTokens PK_AspNetUserTokens; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserTokens"
    ADD CONSTRAINT "PK_AspNetUserTokens" PRIMARY KEY ("UserId", "LoginProvider", "Name");


--
-- Name: AspNetUsers PK_AspNetUsers; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUsers"
    ADD CONSTRAINT "PK_AspNetUsers" PRIMARY KEY ("Id");


--
-- Name: CartItems PK_CartItems; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "PK_CartItems" PRIMARY KEY ("Id");


--
-- Name: Categories PK_Categories; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Categories"
    ADD CONSTRAINT "PK_Categories" PRIMARY KEY ("Id");


--
-- Name: ChatMessages PK_ChatMessages; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChatMessages"
    ADD CONSTRAINT "PK_ChatMessages" PRIMARY KEY ("Id");


--
-- Name: Conversations PK_Conversations; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Conversations"
    ADD CONSTRAINT "PK_Conversations" PRIMARY KEY ("Id");


--
-- Name: OrderDetails PK_OrderDetails; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "PK_OrderDetails" PRIMARY KEY ("Id");


--
-- Name: Orders PK_Orders; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "PK_Orders" PRIMARY KEY ("Id");


--
-- Name: ProductImages PK_ProductImages; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProductImages"
    ADD CONSTRAINT "PK_ProductImages" PRIMARY KEY ("Id");


--
-- Name: Products PK_Products; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "PK_Products" PRIMARY KEY ("Id");


--
-- Name: RefreshTokens PK_RefreshTokens; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RefreshTokens"
    ADD CONSTRAINT "PK_RefreshTokens" PRIMARY KEY ("Id");


--
-- Name: Reviews PK_Reviews; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Reviews"
    ADD CONSTRAINT "PK_Reviews" PRIMARY KEY ("Id");


--
-- Name: Shops PK_Shops; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Shops"
    ADD CONSTRAINT "PK_Shops" PRIMARY KEY ("Id");


--
-- Name: WarrantyClaims PK_WarrantyClaims; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WarrantyClaims"
    ADD CONSTRAINT "PK_WarrantyClaims" PRIMARY KEY ("Id");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: EmailIndex; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EmailIndex" ON public."AspNetUsers" USING btree ("NormalizedEmail");


--
-- Name: IX_Addresses_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Addresses_UserId" ON public."Addresses" USING btree ("UserId");


--
-- Name: IX_AspNetRoleClaims_RoleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_AspNetRoleClaims_RoleId" ON public."AspNetRoleClaims" USING btree ("RoleId");


--
-- Name: IX_AspNetUserClaims_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_AspNetUserClaims_UserId" ON public."AspNetUserClaims" USING btree ("UserId");


--
-- Name: IX_AspNetUserLogins_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_AspNetUserLogins_UserId" ON public."AspNetUserLogins" USING btree ("UserId");


--
-- Name: IX_AspNetUserRoles_RoleId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_AspNetUserRoles_RoleId" ON public."AspNetUserRoles" USING btree ("RoleId");


--
-- Name: IX_CartItems_ProductId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_CartItems_ProductId" ON public."CartItems" USING btree ("ProductId");


--
-- Name: IX_CartItems_UserId_ProductId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_CartItems_UserId_ProductId" ON public."CartItems" USING btree ("UserId", "ProductId");


--
-- Name: IX_Categories_ParentId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Categories_ParentId" ON public."Categories" USING btree ("ParentId");


--
-- Name: IX_Categories_Slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_Categories_Slug" ON public."Categories" USING btree ("Slug");


--
-- Name: IX_ChatMessages_ConversationId_CreatedAt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_ChatMessages_ConversationId_CreatedAt" ON public."ChatMessages" USING btree ("ConversationId", "CreatedAt");


--
-- Name: IX_ChatMessages_SenderId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_ChatMessages_SenderId" ON public."ChatMessages" USING btree ("SenderId");


--
-- Name: IX_Conversations_BuyerId_ShopId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_Conversations_BuyerId_ShopId" ON public."Conversations" USING btree ("BuyerId", "ShopId");


--
-- Name: IX_Conversations_ShopId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Conversations_ShopId" ON public."Conversations" USING btree ("ShopId");


--
-- Name: IX_OrderDetails_OrderId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_OrderDetails_OrderId" ON public."OrderDetails" USING btree ("OrderId");


--
-- Name: IX_OrderDetails_ProductId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_OrderDetails_ProductId" ON public."OrderDetails" USING btree ("ProductId");


--
-- Name: IX_Orders_AddressId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Orders_AddressId" ON public."Orders" USING btree ("AddressId");


--
-- Name: IX_Orders_OrderCode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_Orders_OrderCode" ON public."Orders" USING btree ("OrderCode");


--
-- Name: IX_Orders_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Orders_UserId" ON public."Orders" USING btree ("UserId");


--
-- Name: IX_ProductImages_ProductId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_ProductImages_ProductId" ON public."ProductImages" USING btree ("ProductId");


--
-- Name: IX_Products_CategoryId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Products_CategoryId" ON public."Products" USING btree ("CategoryId");


--
-- Name: IX_Products_ShopId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Products_ShopId" ON public."Products" USING btree ("ShopId");


--
-- Name: IX_Products_Slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_Products_Slug" ON public."Products" USING btree ("Slug");


--
-- Name: IX_RefreshTokens_Token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_RefreshTokens_Token" ON public."RefreshTokens" USING btree ("Token");


--
-- Name: IX_RefreshTokens_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_RefreshTokens_UserId" ON public."RefreshTokens" USING btree ("UserId");


--
-- Name: IX_Reviews_ProductId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Reviews_ProductId" ON public."Reviews" USING btree ("ProductId");


--
-- Name: IX_Reviews_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_Reviews_UserId" ON public."Reviews" USING btree ("UserId");


--
-- Name: IX_Shops_OwnerId; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_Shops_OwnerId" ON public."Shops" USING btree ("OwnerId");


--
-- Name: IX_Shops_Slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_Shops_Slug" ON public."Shops" USING btree ("Slug");


--
-- Name: IX_WarrantyClaims_ClaimCode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_WarrantyClaims_ClaimCode" ON public."WarrantyClaims" USING btree ("ClaimCode");


--
-- Name: IX_WarrantyClaims_OrderDetailId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_WarrantyClaims_OrderDetailId" ON public."WarrantyClaims" USING btree ("OrderDetailId");


--
-- Name: IX_WarrantyClaims_ProductId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_WarrantyClaims_ProductId" ON public."WarrantyClaims" USING btree ("ProductId");


--
-- Name: IX_WarrantyClaims_ShopId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_WarrantyClaims_ShopId" ON public."WarrantyClaims" USING btree ("ShopId");


--
-- Name: IX_WarrantyClaims_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_WarrantyClaims_UserId" ON public."WarrantyClaims" USING btree ("UserId");


--
-- Name: RoleNameIndex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "RoleNameIndex" ON public."AspNetRoles" USING btree ("NormalizedName");


--
-- Name: UserNameIndex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserNameIndex" ON public."AspNetUsers" USING btree ("NormalizedUserName");


--
-- Name: Addresses FK_Addresses_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Addresses"
    ADD CONSTRAINT "FK_Addresses_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: AspNetRoleClaims FK_AspNetRoleClaims_AspNetRoles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetRoleClaims"
    ADD CONSTRAINT "FK_AspNetRoleClaims_AspNetRoles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public."AspNetRoles"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserClaims FK_AspNetUserClaims_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserClaims"
    ADD CONSTRAINT "FK_AspNetUserClaims_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserLogins FK_AspNetUserLogins_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserLogins"
    ADD CONSTRAINT "FK_AspNetUserLogins_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserRoles FK_AspNetUserRoles_AspNetRoles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserRoles"
    ADD CONSTRAINT "FK_AspNetUserRoles_AspNetRoles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public."AspNetRoles"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserRoles FK_AspNetUserRoles_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserRoles"
    ADD CONSTRAINT "FK_AspNetUserRoles_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: AspNetUserTokens FK_AspNetUserTokens_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AspNetUserTokens"
    ADD CONSTRAINT "FK_AspNetUserTokens_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: CartItems FK_CartItems_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "FK_CartItems_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: CartItems FK_CartItems_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "FK_CartItems_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE CASCADE;


--
-- Name: Categories FK_Categories_Categories_ParentId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Categories"
    ADD CONSTRAINT "FK_Categories_Categories_ParentId" FOREIGN KEY ("ParentId") REFERENCES public."Categories"("Id") ON DELETE RESTRICT;


--
-- Name: ChatMessages FK_ChatMessages_AspNetUsers_SenderId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChatMessages"
    ADD CONSTRAINT "FK_ChatMessages_AspNetUsers_SenderId" FOREIGN KEY ("SenderId") REFERENCES public."AspNetUsers"("Id") ON DELETE RESTRICT;


--
-- Name: ChatMessages FK_ChatMessages_Conversations_ConversationId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChatMessages"
    ADD CONSTRAINT "FK_ChatMessages_Conversations_ConversationId" FOREIGN KEY ("ConversationId") REFERENCES public."Conversations"("Id") ON DELETE CASCADE;


--
-- Name: Conversations FK_Conversations_AspNetUsers_BuyerId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Conversations"
    ADD CONSTRAINT "FK_Conversations_AspNetUsers_BuyerId" FOREIGN KEY ("BuyerId") REFERENCES public."AspNetUsers"("Id") ON DELETE RESTRICT;


--
-- Name: Conversations FK_Conversations_Shops_ShopId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Conversations"
    ADD CONSTRAINT "FK_Conversations_Shops_ShopId" FOREIGN KEY ("ShopId") REFERENCES public."Shops"("Id") ON DELETE CASCADE;


--
-- Name: OrderDetails FK_OrderDetails_Orders_OrderId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "FK_OrderDetails_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES public."Orders"("Id") ON DELETE CASCADE;


--
-- Name: OrderDetails FK_OrderDetails_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "FK_OrderDetails_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE RESTRICT;


--
-- Name: Orders FK_Orders_Addresses_AddressId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "FK_Orders_Addresses_AddressId" FOREIGN KEY ("AddressId") REFERENCES public."Addresses"("Id") ON DELETE RESTRICT;


--
-- Name: Orders FK_Orders_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "FK_Orders_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE RESTRICT;


--
-- Name: ProductImages FK_ProductImages_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProductImages"
    ADD CONSTRAINT "FK_ProductImages_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE CASCADE;


--
-- Name: Products FK_Products_Categories_CategoryId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "FK_Products_Categories_CategoryId" FOREIGN KEY ("CategoryId") REFERENCES public."Categories"("Id") ON DELETE RESTRICT;


--
-- Name: Products FK_Products_Shops_ShopId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "FK_Products_Shops_ShopId" FOREIGN KEY ("ShopId") REFERENCES public."Shops"("Id") ON DELETE RESTRICT;


--
-- Name: RefreshTokens FK_RefreshTokens_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RefreshTokens"
    ADD CONSTRAINT "FK_RefreshTokens_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE CASCADE;


--
-- Name: Reviews FK_Reviews_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Reviews"
    ADD CONSTRAINT "FK_Reviews_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE RESTRICT;


--
-- Name: Reviews FK_Reviews_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Reviews"
    ADD CONSTRAINT "FK_Reviews_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE CASCADE;


--
-- Name: Shops FK_Shops_AspNetUsers_OwnerId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Shops"
    ADD CONSTRAINT "FK_Shops_AspNetUsers_OwnerId" FOREIGN KEY ("OwnerId") REFERENCES public."AspNetUsers"("Id") ON DELETE RESTRICT;


--
-- Name: WarrantyClaims FK_WarrantyClaims_AspNetUsers_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WarrantyClaims"
    ADD CONSTRAINT "FK_WarrantyClaims_AspNetUsers_UserId" FOREIGN KEY ("UserId") REFERENCES public."AspNetUsers"("Id") ON DELETE RESTRICT;


--
-- Name: WarrantyClaims FK_WarrantyClaims_OrderDetails_OrderDetailId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WarrantyClaims"
    ADD CONSTRAINT "FK_WarrantyClaims_OrderDetails_OrderDetailId" FOREIGN KEY ("OrderDetailId") REFERENCES public."OrderDetails"("Id") ON DELETE CASCADE;


--
-- Name: WarrantyClaims FK_WarrantyClaims_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WarrantyClaims"
    ADD CONSTRAINT "FK_WarrantyClaims_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE RESTRICT;


--
-- Name: WarrantyClaims FK_WarrantyClaims_Shops_ShopId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WarrantyClaims"
    ADD CONSTRAINT "FK_WarrantyClaims_Shops_ShopId" FOREIGN KEY ("ShopId") REFERENCES public."Shops"("Id") ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict 1MV3MAGmhnaQUfccfjJfZwIpLNXY1KgmhN2DgSpczjuGWLx4Ugmg2mt97DGq6ne

