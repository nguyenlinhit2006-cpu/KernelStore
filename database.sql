--
-- PostgreSQL database dump
--

\restrict vUEdWbOJDhZ00etsDvjwjND1BLVpREHVLwsKWA0j9QTPZH5mHyDJaJFxDxvZwBr

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
    "ShopId" uuid NOT NULL
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
7630b706-620e-4059-84b3-05958ddf5d4a	test	033294339	34	ggf	trrt	ho chi minh	f	019fed47-a234-7522-8c07-9cca377d0c0b
a2dea5c0-a067-4a6f-89e6-7bcb995c4451	linh	3034345354	g43	rrf	rê	rger	f	019fed4a-f8b7-7627-af59-5e0159895d52
4d806e41-ceee-4ed8-96b4-b5aa61a61df2	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b11f-7d7a-b34d-d5f10f5c28d7
afd6f0f8-baa3-4860-82bb-771c0d0e9b06	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b1ca-74cf-9f27-57842af4b017
c5a6a284-4c54-4b79-8f6c-5a9a5df9dd56	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b240-7f57-8289-c4bc58356187
4095ba48-cd8f-4773-939d-36df7dab1edb	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b2b6-7c03-9166-314cacf776a4
46305254-9e5b-4527-a5f6-f324460fd488	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b32b-7b05-b034-e2e3f61af42c
6e4f3986-95ae-4667-9eac-b8eaaf97ae34	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b3a5-7ae7-b66b-d46aea0484a6
e13ad32e-21ea-42be-9a8f-3e390816c42a	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b11f-7d7a-b34d-d5f10f5c28d7
a388fe72-d7dc-4cd5-80ef-d34e854a385f	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b1ca-74cf-9f27-57842af4b017
f68da728-9332-45c1-a8f0-7e3d432a728f	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b240-7f57-8289-c4bc58356187
f150a7a3-2e3c-40fe-9f79-f5237f76e543	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b2b6-7c03-9166-314cacf776a4
5c1ca007-5acf-4bf1-a1c6-2cce5758d55f	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b32b-7b05-b034-e2e3f61af42c
29fbfd51-7c8b-4498-9c94-ebfc950f9cc9	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b3a5-7ae7-b66b-d46aea0484a6
90f3b648-f260-4a40-b5ba-f198472b3ebd	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b11f-7d7a-b34d-d5f10f5c28d7
7c6c0559-83a5-4a92-b4f0-ea89cffe67ed	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b1ca-74cf-9f27-57842af4b017
9b7ab2d7-1993-4cbb-8164-5491079fc0a9	Demo Buyer	0900000000	12 Nguyen Trai	Ward 1	District 1	Ho Chi Minh City	f	019fed6c-b240-7f57-8289-c4bc58356187
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
019fec69-ee4c-700a-927c-b3744303fa7a	Customer	CUSTOMER	34b779bf-cabd-4e64-abd7-211bba5f33e9
019fec69-eed4-79f0-9ce4-676ef7cd27f4	Seller	SELLER	0427e20d-b27e-4b76-9561-b7fda356363e
019fec69-eed9-78f5-b9a6-d1be3bca6ad6	Admin	ADMIN	cc871209-e8b2-4a83-9074-76eff88077ae
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
019fec69-ef3b-7700-b360-b39eb230827d	019fec69-eed9-78f5-b9a6-d1be3bca6ad6
019fec69-f09e-7b2f-92cd-74ca128c3dd0	019fec69-eed4-79f0-9ce4-676ef7cd27f4
019fec69-f0da-7aac-b148-e1abfb5ec992	019fec69-eed4-79f0-9ce4-676ef7cd27f4
019fed47-a234-7522-8c07-9cca377d0c0b	019fec69-ee4c-700a-927c-b3744303fa7a
019fed4a-f8b7-7627-af59-5e0159895d52	019fec69-ee4c-700a-927c-b3744303fa7a
019fed4d-9cfa-7f08-847c-56ce4c7b650e	019fec69-ee4c-700a-927c-b3744303fa7a
019fed6c-b11f-7d7a-b34d-d5f10f5c28d7	019fec69-ee4c-700a-927c-b3744303fa7a
019fed6c-b1ca-74cf-9f27-57842af4b017	019fec69-ee4c-700a-927c-b3744303fa7a
019fed6c-b240-7f57-8289-c4bc58356187	019fec69-ee4c-700a-927c-b3744303fa7a
019fed6c-b2b6-7c03-9166-314cacf776a4	019fec69-ee4c-700a-927c-b3744303fa7a
019fed6c-b32b-7b05-b034-e2e3f61af42c	019fec69-ee4c-700a-927c-b3744303fa7a
019fed6c-b3a5-7ae7-b66b-d46aea0484a6	019fec69-ee4c-700a-927c-b3744303fa7a
019ffff0-0000-7000-8000-000000000001	019fec69-eed4-79f0-9ce4-676ef7cd27f4
019ffff0-0000-7000-8000-000000000002	019fec69-eed4-79f0-9ce4-676ef7cd27f4
019ffff0-0000-7000-8000-000000000003	019fec69-eed4-79f0-9ce4-676ef7cd27f4
019ffff0-0000-7000-8000-000000000004	019fec69-eed4-79f0-9ce4-676ef7cd27f4
019ffff0-0000-7000-8000-000000000005	019fec69-eed4-79f0-9ce4-676ef7cd27f4
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
019fec69-ef3b-7700-b360-b39eb230827d	System Admin		2026-08-10 16:03:13.261102+00	t	2	admin	ADMIN	admin@ks.com	ADMIN@KS.COM	f	AQAAAAIAAYagAAAAEMW7wq0H+kGWWl3sbZx3MqGAdk7LDX1atXClm71fIAxN/6N9phsVSU7R6ph6+5A7aA==	LFZV3NIG556RYS3FLH7775QXDSE6SGIO	80c8b747-7775-4ba1-9c1a-517f46963fd6	\N	f	f	\N	t	0
019fec69-f09e-7b2f-92cd-74ca128c3dd0	Alice Nguyen		2026-08-10 16:03:13.644505+00	t	1	demo_alice	DEMO_ALICE	seller1@demo.ks	SELLER1@DEMO.KS	f	AQAAAAIAAYagAAAAEMqS5/HhhoXaZVSqQTZ2Px9gRhy9b4/nykplBkw2r8Hhb43XpZCsrXUCOMwjdPf98w==	MUV6QRZOP2UM3BH5GCGELRKKALJEB5J3	1953ddae-8cbf-4d86-b442-9967e5225df6	\N	f	f	\N	t	0
019fec69-f0da-7aac-b148-e1abfb5ec992	Bob Tran		2026-08-10 16:03:13.705251+00	t	1	demo_bob	DEMO_BOB	seller2@demo.ks	SELLER2@DEMO.KS	f	AQAAAAIAAYagAAAAEGkqFQ+lMczyK07FHr4R/MlY+KWqciG4a02BSHXuNA92U6FZ4+fWzHgnOcHM/qc8/Q==	5DJLUGU3QAYAPJZHATOFFKR2AELBXGC3	e47b9207-fa29-4e79-b6aa-0b2dfbc7f534	\N	f	f	\N	t	0
019fed47-a234-7522-8c07-9cca377d0c0b	test		2026-08-10 20:05:22.456394+00	t	0	12te	12TE	test@gmail.com	TEST@GMAIL.COM	f	AQAAAAIAAYagAAAAEGHkoSVKM0JFTIigFzYvEGUkIbWeRnuKB3mTlN86g1jX4HEhZTssFXCBfJZZOJRPfQ==	PPWMQM4WNPXSOPMOMSGONIVPAHVFGSCI	a83c5e6b-37cb-48c6-bc48-4dde71b2a523	\N	f	f	\N	t	0
019fed4a-f8b7-7627-af59-5e0159895d52	linh		2026-08-10 20:09:01.266202+00	t	0	linh	LINH	linhcute123@gmail.com	LINHCUTE123@GMAIL.COM	f	AQAAAAIAAYagAAAAEJuUGz0DaLhnTpe1wakpixGb4gW56h8IfQXqNCu+cl3z5vO01+pcaCOCKRKiM+ePDw==	UKWO4CSRLOS52NR73JDJ7R2GI6XJDFVA	fc53bb7a-c05d-49f2-a12b-ae77628bd274	\N	f	f	\N	t	0
019fed4d-9cfa-7f08-847c-56ce4c7b650e	linh		2026-08-10 20:11:54.379763+00	t	0	123442r	123442R	linhtest2@gmail.com	LINHTEST2@GMAIL.COM	f	AQAAAAIAAYagAAAAENFeenAWZcagir08DM/GD8mNeDQaq3rs/Yl74BHF+FrqjDrsP61FAXTctEuZFT5Fvg==	EPUJT2XYIR7SZNJ3WMIELDZDV7DNZQGG	1d52c6b4-6182-4e90-8f70-e260d5314114	\N	f	f	\N	t	0
019fed6c-b11f-7d7a-b34d-d5f10f5c28d7	Demo Buyer 1		2026-08-10 20:45:51.192454+00	t	0	buyer1	BUYER1	buyer1@demo.ks	BUYER1@DEMO.KS	f	AQAAAAIAAYagAAAAEBNvMKq1UihKD9P3ydxkDqMAtESQr9rJzypy8UJxaLE8bAszqNHpdrnRnT9NobjRJA==	OHS6ZAOQTUEAJTOY2HTKHDYUGOWEZ3QD	847d5080-ae5f-43cb-a66d-c2f1a4763b51	\N	f	f	\N	t	0
019fed6c-b1ca-74cf-9f27-57842af4b017	Demo Buyer 2		2026-08-10 20:45:51.38654+00	t	0	buyer2	BUYER2	buyer2@demo.ks	BUYER2@DEMO.KS	f	AQAAAAIAAYagAAAAEHT1l6k0xqp/AkBMYJ/Wf2PlAQzbUq3aRn+NKreEqC59oMVu9qYOJB6sS1QvY97K3Q==	G6SPUMWFZ2RGYJG35OJMVYDFRP3LPHHL	b6a556ea-4836-45a4-aec5-a65fa602cdaf	\N	f	f	\N	t	0
019fed6c-b240-7f57-8289-c4bc58356187	Demo Buyer 3		2026-08-10 20:45:51.502021+00	t	0	buyer3	BUYER3	buyer3@demo.ks	BUYER3@DEMO.KS	f	AQAAAAIAAYagAAAAEEGNs2gAxBJyvgtXUNdXGPvFphJDjnxNrCfwZ5zJpFeGr0vLuLT/1aXXZSrFLmCuuQ==	HUR5N5TJHBT4BO33KERYNVHCPA5BPEXL	2701c667-4d3d-4c3e-895a-092d76fc0ae8	\N	f	f	\N	t	0
019fed6c-b2b6-7c03-9166-314cacf776a4	Demo Buyer 4		2026-08-10 20:45:51.621128+00	t	0	buyer4	BUYER4	buyer4@demo.ks	BUYER4@DEMO.KS	f	AQAAAAIAAYagAAAAEBEuxJAbTET0Qkv33bCbsf71m7rUuvLAfsDXbT+7nLuZ6fTLBcc+AD/H65/+kpcc/A==	YQ5BXTQMJAMJY52TBZRN7SDR2Q2NDDXZ	578862d5-27c5-499d-8b8c-598105bc0f3b	\N	f	f	\N	t	0
019fed6c-b32b-7b05-b034-e2e3f61af42c	Demo Buyer 5		2026-08-10 20:45:51.738294+00	t	0	buyer5	BUYER5	buyer5@demo.ks	BUYER5@DEMO.KS	f	AQAAAAIAAYagAAAAEAV0zNrprvZ43A9xzyg/kyy250Gi5ZXuCJ5RmCZIvIDiODOLH9of44bNxxbQz587Sw==	UIQW5JLDPHWCZ3J27RIMTDFQDNTBZ3NG	b7ea508d-8fbe-413b-bf97-6ff50639fce4	\N	f	f	\N	t	0
019fed6c-b3a5-7ae7-b66b-d46aea0484a6	Demo Buyer 6		2026-08-10 20:45:51.860146+00	t	0	buyer6	BUYER6	buyer6@demo.ks	BUYER6@DEMO.KS	f	AQAAAAIAAYagAAAAEEXJp/QpsQEK3X9iusfdB+xff7yVh977H79QXUZ4lI2DfixwfxPwdaQ2DPaEGlv6PA==	CXQ36OMHTZE45KYINCEOXHGPA3BPJDLK	05af2cf2-0a36-403e-a82e-973a3b69263e	\N	f	f	\N	t	0
019ffff0-0000-7000-8000-000000000001	Carol Pham		2026-08-11 00:00:00+00	t	1	demo_iot	DEMO_IOT	iot@demo.ks	IOT@DEMO.KS	f	AQAAAAIAAYagAAAAEMqS5/HhhoXaZVSqQTZ2Px9gRhy9b4/nykplBkw2r8Hhb43XpZCsrXUCOMwjdPf98w==	e5000000-0000-4000-8000-000000000001	c5000000-0000-4000-8000-000000000001	\N	f	f	\N	t	0
019ffff0-0000-7000-8000-000000000002	David Le		2026-08-11 00:00:00+00	t	1	demo_ai	DEMO_AI	ai@demo.ks	AI@DEMO.KS	f	AQAAAAIAAYagAAAAEMqS5/HhhoXaZVSqQTZ2Px9gRhy9b4/nykplBkw2r8Hhb43XpZCsrXUCOMwjdPf98w==	e5000000-0000-4000-8000-000000000002	c5000000-0000-4000-8000-000000000002	\N	f	f	\N	t	0
019ffff0-0000-7000-8000-000000000003	Emma Vo		2026-08-11 00:00:00+00	t	1	demo_sec	DEMO_SEC	security@demo.ks	SECURITY@DEMO.KS	f	AQAAAAIAAYagAAAAEMqS5/HhhoXaZVSqQTZ2Px9gRhy9b4/nykplBkw2r8Hhb43XpZCsrXUCOMwjdPf98w==	e5000000-0000-4000-8000-000000000003	c5000000-0000-4000-8000-000000000003	\N	f	f	\N	t	0
019ffff0-0000-7000-8000-000000000004	Frank Do		2026-08-11 00:00:00+00	t	1	demo_ops	DEMO_OPS	sysadmin@demo.ks	SYSADMIN@DEMO.KS	f	AQAAAAIAAYagAAAAEMqS5/HhhoXaZVSqQTZ2Px9gRhy9b4/nykplBkw2r8Hhb43XpZCsrXUCOMwjdPf98w==	e5000000-0000-4000-8000-000000000004	c5000000-0000-4000-8000-000000000004	\N	f	f	\N	t	0
019ffff0-0000-7000-8000-000000000005	Grace Ha		2026-08-11 00:00:00+00	t	1	demo_dev	DEMO_DEV	developer@demo.ks	DEVELOPER@DEMO.KS	f	AQAAAAIAAYagAAAAEMqS5/HhhoXaZVSqQTZ2Px9gRhy9b4/nykplBkw2r8Hhb43XpZCsrXUCOMwjdPf98w==	e5000000-0000-4000-8000-000000000005	c5000000-0000-4000-8000-000000000005	\N	f	f	\N	t	0
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
c7b80786-959b-4d03-aa66-f0aeb8eac383	Accessories	accessories		\N	\N
c9b92d7e-cd95-4120-ae4a-a1e0dff952dd	Electronics	electronics		\N	\N
1f7eef1c-edd0-4664-8afb-f15a9c442e28	Laptops	laptops		c9b92d7e-cd95-4120-ae4a-a1e0dff952dd	\N
b0fb2314-f33a-4421-a085-6708c77283ba	Phones	phones		c9b92d7e-cd95-4120-ae4a-a1e0dff952dd	\N
ee5ea3c2-79c5-4cbf-a9d0-8d551bde5574	Tablets	tablets		c9b92d7e-cd95-4120-ae4a-a1e0dff952dd	\N
c0000000-0000-4000-8000-000000000001	IoT & Embedded	iot		\N	\N
c0000000-0000-4000-8000-000000000002	AI & Machine Learning	ai-ml		\N	\N
c0000000-0000-4000-8000-000000000003	Cybersecurity	security		\N	\N
c0000000-0000-4000-8000-000000000004	SysAdmin & DevOps	sysadmin		\N	\N
c0000000-0000-4000-8000-000000000005	Developer Tools	developer		\N	\N
\.


--
-- Data for Name: ChatMessages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ChatMessages" ("Id", "ConversationId", "SenderId", "Content", "IsRead", "CreatedAt") FROM stdin;
e18b61f4-13ce-475b-800c-5c38934693d1	92e5bf35-5844-4265-893f-2ea8de2b3e9d	019fed4a-f8b7-7627-af59-5e0159895d52	test	t	2026-08-10 20:09:12.678437+00
\.


--
-- Data for Name: Conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Conversations" ("Id", "BuyerId", "ShopId", "CreatedAt", "LastMessageAt") FROM stdin;
92e5bf35-5844-4265-893f-2ea8de2b3e9d	019fed4a-f8b7-7627-af59-5e0159895d52	977648dd-cda6-4c57-84cf-86e0069ecb2f	2026-08-10 20:09:09.029985+00	2026-08-10 20:09:12.678437+00
\.


--
-- Data for Name: OrderDetails; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OrderDetails" ("Id", "Quantity", "UnitPrice", "TotalPrice", "OrderId", "ProductId") FROM stdin;
0d950890-e51c-4fdf-9270-b1e563ccca59	1	81.89	81.89	2218a6de-49d9-4de0-9bbf-72f8315d5db1	670c0a92-00ca-4b9c-be41-69b7692d19f7
2710da91-8b5a-4f00-be8b-4df310f00dbc	1	286.29	286.29	0daf8334-3597-458d-9ac3-d9b10451091a	133ead3f-3480-40f2-814f-9f19b628c659
2b86fe55-0f5b-45a4-a157-589a2eae8420	1	16.29	16.29	c986d453-ccb3-4c68-a164-267d4a8d1be7	3e57dab6-91f9-4e0c-af54-4273238b7845
8572312a-087d-4b80-be78-b0c34fae00a6	1	87.92	87.92	c986d453-ccb3-4c68-a164-267d4a8d1be7	a93fc4ad-7a77-4d95-a415-52a953a5566d
9a7267ff-b223-40bc-8f78-8fc27980171f	1	76.41	76.41	c986d453-ccb3-4c68-a164-267d4a8d1be7	5e1d2eef-2bdd-4c9d-863d-b15bce200541
0740fe02-eee8-424c-ac4f-7ed3b434634c	1	723.68	723.68	0f03169d-7fc4-4264-8733-9c1f7794b90a	a63c6805-7917-444c-b62c-cad321a10bd5
c02901ca-6bea-4593-bff2-e1d593c09895	2	286.29	572.58	0f03169d-7fc4-4264-8733-9c1f7794b90a	133ead3f-3480-40f2-814f-9f19b628c659
ff48863c-40f5-4d06-b633-3de7b5cbfe2c	1	249.99	249.99	0f03169d-7fc4-4264-8733-9c1f7794b90a	85617635-c1f5-4984-9ca4-1b87809990d7
79d90184-dc9d-40cf-85b6-a69b3c8a0c3e	1	520.13	520.13	962eca97-d11b-455f-a529-21d02c2997ee	6e0e1354-b1a2-4731-9611-e65e86b4ac59
18ced5da-ebd1-4121-a457-8538e7df8969	1	16.29	16.29	001faa5a-5da9-4dd4-97a1-85e0b1d39997	3e57dab6-91f9-4e0c-af54-4273238b7845
e100a7b7-adb2-4f39-960c-1b7a73d356eb	2	109.79	219.58	001faa5a-5da9-4dd4-97a1-85e0b1d39997	20fa2eee-3536-4f2d-a785-aabac57873d3
fdd2aa68-a139-41de-aa91-6bf944623618	2	81.89	163.78	001faa5a-5da9-4dd4-97a1-85e0b1d39997	670c0a92-00ca-4b9c-be41-69b7692d19f7
5b50963b-9f6e-4caf-b5d5-104d8afcd039	2	520.13	1040.26	d4d98ad2-41d8-4395-8656-d3ef7947184e	6e0e1354-b1a2-4731-9611-e65e86b4ac59
d9e121ac-11d8-49a5-a725-8d745b823744	2	286.29	572.58	d4d98ad2-41d8-4395-8656-d3ef7947184e	133ead3f-3480-40f2-814f-9f19b628c659
f6a5b70d-f9df-4c05-95ed-f2b869704a58	2	481.79	963.58	d4d98ad2-41d8-4395-8656-d3ef7947184e	8457e253-8e47-4da7-a6b6-bf27f3e2a062
1f9b3ec2-391a-4d7c-8b98-8344d0589628	2	520.13	1040.26	c0410375-3341-43dd-b509-30796abd4c24	6e0e1354-b1a2-4731-9611-e65e86b4ac59
b3abda19-b18e-49ba-89c6-0de146876152	2	16.29	32.58	8d24eea9-b19d-4003-8981-63c0bd89d82b	3e57dab6-91f9-4e0c-af54-4273238b7845
32b97e45-54e5-4339-b636-79800e90a3e2	2	481.79	963.58	be804f16-fffb-4d41-a5a0-d5e56d371d6b	8457e253-8e47-4da7-a6b6-bf27f3e2a062
01dfc4fe-974c-41b6-804e-69d1a3073092	2	286.29	572.58	ea7fc2e8-168b-4bb0-91c6-ae07ba1fb259	133ead3f-3480-40f2-814f-9f19b628c659
09b6be9e-13f4-468a-89d0-96cab7c211b7	1	325.43	325.43	ea7fc2e8-168b-4bb0-91c6-ae07ba1fb259	d331d383-c3d7-459f-94b9-862a0e650cc1
2ab21743-59a1-412a-9d2c-739cce42969b	1	481.79	481.79	ea7fc2e8-168b-4bb0-91c6-ae07ba1fb259	8457e253-8e47-4da7-a6b6-bf27f3e2a062
37a0eef6-bd9b-4112-8a26-f8ccda4342bc	1	87.92	87.92	663cebcf-66ff-4888-a9e7-fc97cb8270b8	a93fc4ad-7a77-4d95-a415-52a953a5566d
b8d6b734-9c30-4f20-b9b0-569ff282a94a	1	109.79	109.79	663cebcf-66ff-4888-a9e7-fc97cb8270b8	20fa2eee-3536-4f2d-a785-aabac57873d3
113cdcb6-1b89-4db8-9bd4-c0acede0b40b	2	286.29	572.58	c55ef0fc-8651-40f7-84d0-a4c1327a89d9	133ead3f-3480-40f2-814f-9f19b628c659
2de6a621-705e-4f38-a4c5-62ff8036221b	1	520.13	520.13	c55ef0fc-8651-40f7-84d0-a4c1327a89d9	6e0e1354-b1a2-4731-9611-e65e86b4ac59
4aeb09b6-c6c7-4b53-8eb7-e252c5e41eec	1	481.79	481.79	c55ef0fc-8651-40f7-84d0-a4c1327a89d9	8457e253-8e47-4da7-a6b6-bf27f3e2a062
0aeb2fd2-9d35-4b9d-961b-f81474161c1c	1	325.43	325.43	aef0cca5-de9e-4b38-9f06-64511b344216	d331d383-c3d7-459f-94b9-862a0e650cc1
91049a33-3a2f-4740-af22-45e8cdc3b6fc	2	481.79	963.58	aef0cca5-de9e-4b38-9f06-64511b344216	8457e253-8e47-4da7-a6b6-bf27f3e2a062
4d1ac7f9-f5f4-4872-93f1-a2a080e579fe	1	81.89	81.89	30ef35de-3f30-45d4-9394-08591dd8d2f2	670c0a92-00ca-4b9c-be41-69b7692d19f7
90b0af46-fcef-4fd4-997f-84411d889d27	2	520.13	1040.26	b383344f-27b9-4576-9db0-878e17cedfed	6e0e1354-b1a2-4731-9611-e65e86b4ac59
ad0eada1-cb9a-4138-810a-02670de6ec27	2	723.68	1447.36	b383344f-27b9-4576-9db0-878e17cedfed	a63c6805-7917-444c-b62c-cad321a10bd5
f4d13f35-aece-4f0f-a7d7-d51ec895656c	2	249.99	499.98	b383344f-27b9-4576-9db0-878e17cedfed	85617635-c1f5-4984-9ca4-1b87809990d7
013ddd07-1c92-4fbd-b654-177b28e1441d	2	723.68	1447.36	8930ab87-cdab-41cd-8e8a-df958aec8adc	a63c6805-7917-444c-b62c-cad321a10bd5
448e7260-d340-49af-a97a-0ff46ce32534	1	520.13	520.13	8930ab87-cdab-41cd-8e8a-df958aec8adc	6e0e1354-b1a2-4731-9611-e65e86b4ac59
6fdbbfca-3f60-4583-bf5e-06a5e5be7ddb	1	249.99	249.99	8930ab87-cdab-41cd-8e8a-df958aec8adc	85617635-c1f5-4984-9ca4-1b87809990d7
\.


--
-- Data for Name: Orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Orders" ("Id", "OrderCode", "Status", "TotalAmount", "ShippingFee", "Note", "CreatedAt", "PaidAt", "UserId", "AddressId") FROM stdin;
2218a6de-49d9-4de0-9bbf-72f8315d5db1	KS-20260810-2466	1	81.89	0.00		2026-08-10 20:05:57.561965+00	\N	019fed47-a234-7522-8c07-9cca377d0c0b	7630b706-620e-4059-84b3-05958ddf5d4a
0daf8334-3597-458d-9ac3-d9b10451091a	KS-20260810-3573	1	286.29	0.00		2026-08-10 20:09:46.509466+00	\N	019fed4a-f8b7-7627-af59-5e0159895d52	a2dea5c0-a067-4a6f-89e6-7bcb995c4451
aef0cca5-de9e-4b38-9f06-64511b344216	KS-20260810-6548	0	1289.01	0.00		2026-08-10 20:45:52.38039+00	\N	019fed6c-b3a5-7ae7-b66b-d46aea0484a6	29fbfd51-7c8b-4498-9c94-ebfc950f9cc9
30ef35de-3f30-45d4-9394-08591dd8d2f2	KS-20260810-3680	0	81.89	0.00		2026-08-10 20:45:52.394965+00	\N	019fed6c-b11f-7d7a-b34d-d5f10f5c28d7	90f3b648-f260-4a40-b5ba-f198472b3ebd
b383344f-27b9-4576-9db0-878e17cedfed	KS-20260810-6716	0	2987.60	0.00		2026-08-10 20:45:52.414895+00	\N	019fed6c-b1ca-74cf-9f27-57842af4b017	7c6c0559-83a5-4a92-b4f0-ea89cffe67ed
8930ab87-cdab-41cd-8e8a-df958aec8adc	KS-20260810-3356	0	2217.48	0.00		2026-08-10 20:45:52.435492+00	\N	019fed6c-b240-7f57-8289-c4bc58356187	9b7ab2d7-1993-4cbb-8164-5491079fc0a9
c986d453-ccb3-4c68-a164-267d4a8d1be7	KS-20260810-9990	1	180.62	0.00		2026-08-10 20:45:52.107263+00	\N	019fed6c-b11f-7d7a-b34d-d5f10f5c28d7	4d806e41-ceee-4ed8-96b4-b5aa61a61df2
0f03169d-7fc4-4264-8733-9c1f7794b90a	KS-20260810-7053	1	1546.25	0.00		2026-08-10 20:45:52.224123+00	\N	019fed6c-b1ca-74cf-9f27-57842af4b017	afd6f0f8-baa3-4860-82bb-771c0d0e9b06
962eca97-d11b-455f-a529-21d02c2997ee	KS-20260810-6853	1	520.13	0.00		2026-08-10 20:45:52.237736+00	\N	019fed6c-b240-7f57-8289-c4bc58356187	c5a6a284-4c54-4b79-8f6c-5a9a5df9dd56
001faa5a-5da9-4dd4-97a1-85e0b1d39997	KS-20260810-7915	2	399.65	0.00		2026-08-10 20:45:52.256484+00	\N	019fed6c-b2b6-7c03-9166-314cacf776a4	4095ba48-cd8f-4773-939d-36df7dab1edb
d4d98ad2-41d8-4395-8656-d3ef7947184e	KS-20260810-9195	2	2576.42	0.00		2026-08-10 20:45:52.278448+00	\N	019fed6c-b32b-7b05-b034-e2e3f61af42c	46305254-9e5b-4527-a5f6-f324460fd488
c0410375-3341-43dd-b509-30796abd4c24	KS-20260810-9827	3	1040.26	0.00		2026-08-10 20:45:52.290896+00	\N	019fed6c-b3a5-7ae7-b66b-d46aea0484a6	6e4f3986-95ae-4667-9eac-b8eaaf97ae34
8d24eea9-b19d-4003-8981-63c0bd89d82b	KS-20260810-6513	3	32.58	0.00		2026-08-10 20:45:52.301333+00	\N	019fed6c-b11f-7d7a-b34d-d5f10f5c28d7	e13ad32e-21ea-42be-9a8f-3e390816c42a
be804f16-fffb-4d41-a5a0-d5e56d371d6b	KS-20260810-4423	4	963.58	0.00		2026-08-10 20:45:52.311334+00	\N	019fed6c-b1ca-74cf-9f27-57842af4b017	a388fe72-d7dc-4cd5-80ef-d34e854a385f
ea7fc2e8-168b-4bb0-91c6-ae07ba1fb259	KS-20260810-1937	4	1379.80	0.00		2026-08-10 20:45:52.330141+00	\N	019fed6c-b240-7f57-8289-c4bc58356187	f68da728-9332-45c1-a8f0-7e3d432a728f
663cebcf-66ff-4888-a9e7-fc97cb8270b8	KS-20260810-9715	4	197.71	0.00		2026-08-10 20:45:52.346919+00	\N	019fed6c-b2b6-7c03-9166-314cacf776a4	f150a7a3-2e3c-40fe-9f79-f5237f76e543
c55ef0fc-8651-40f7-84d0-a4c1327a89d9	KS-20260810-5905	5	1574.50	0.00		2026-08-10 20:45:52.36592+00	\N	019fed6c-b32b-7b05-b034-e2e3f61af42c	5c1ca007-5acf-4bf1-a1c6-2cce5758d55f
\.


--
-- Data for Name: ProductImages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ProductImages" ("Id", "Url", "AltText", "IsPrimary", "DisplayOrder", "ProductId") FROM stdin;
40954dac-5dec-43ca-94d9-c314304666a9	http://localhost:5000/uploads/new-dell-xps-13-9300-laptop.jpg	New DELL XPS 13 9300 Laptop	t	0	9852d867-c7f0-4b48-871b-a6b3c65e8dc1
435b2bea-8fe5-4028-b555-8c3a0618d902	http://localhost:5000/uploads/huawei-matebook-x-pro.jpg	Huawei Matebook X Pro	t	0	185840fc-8742-44fb-892c-1ee9fa44500a
537270ca-c91e-444a-9d05-1deaf548c503	http://localhost:5000/uploads/samsung-galaxy-tab-s8-plus-grey.jpg	Samsung Galaxy Tab S8 Plus Grey	t	0	6e0e1354-b1a2-4731-9611-e65e86b4ac59
5b331f25-abee-45a6-bfe5-8d9c8b25c350	http://localhost:5000/uploads/apple-airpods-max-silver.jpg	Apple AirPods Max Silver	t	0	fcec98fb-80e8-4148-9d16-dead4c14215a
66d4eec1-c34d-4f54-9274-17faa138f5fd	http://localhost:5000/uploads/amazon-echo-plus.jpg	Amazon Echo Plus	t	0	a93fc4ad-7a77-4d95-a415-52a953a5566d
7600aedf-20b4-451c-ad6e-6dc5e62d525c	http://localhost:5000/uploads/ipad-mini-2021-starlight.jpg	iPad Mini 2021 Starlight	t	0	8457e253-8e47-4da7-a6b6-bf27f3e2a062
794b8c6c-7c8f-4dde-a340-9326f1c04f73	http://localhost:5000/uploads/samsung-galaxy-tab-white.jpg	Samsung Galaxy Tab White	t	0	133ead3f-3480-40f2-814f-9f19b628c659
7e7e6b2e-3a09-468c-9f60-5c033be9f28e	http://localhost:5000/uploads/asus-zenbook-pro-dual-screen-laptop.jpg	Asus Zenbook Pro Dual Screen Laptop	t	0	4f2c2fe8-ad30-48d6-8ae8-fcb55cfca52d
898044e2-8472-4d96-b00c-7e740894c038	http://localhost:5000/uploads/iphone-x.jpg	iPhone X	t	0	a63c6805-7917-444c-b62c-cad321a10bd5
8a58a5e9-b907-43aa-a157-c0dfb9e40a9e	http://localhost:5000/uploads/lenovo-yoga-920.jpg	Lenovo Yoga 920	t	0	e359c739-2956-45cd-8078-05c12569fed5
90f7ba1e-e84b-406f-aa02-1efc1969e88a	http://localhost:5000/uploads/iphone-5s.jpg	iPhone 5s	t	0	7c0a5429-3f52-4741-8f76-97bcd115eeff
92e2300e-ec6d-41dd-b86c-c832865c2a2d	http://localhost:5000/uploads/iphone-6.jpg	iPhone 6	t	0	37c92d0d-f9ff-47f9-89d7-98586b1a3db7
9367c154-aaa5-4137-8265-f8faaf8ca030	http://localhost:5000/uploads/apple-iphone-charger.jpg	Apple iPhone Charger	t	0	3e57dab6-91f9-4e0c-af54-4273238b7845
9814a440-2543-4a1b-8f6b-bd28cfdd52db	http://localhost:5000/uploads/iphone-13-pro.jpg	iPhone 13 Pro	t	0	e49868b6-5d2a-47be-818b-6fed52f314bd
a56d6882-e582-4991-a5a9-1728b66d88aa	http://localhost:5000/uploads/apple-macbook-pro-14-inch-space-grey.jpg	Apple MacBook Pro 14 Inch Space Grey	t	0	c3a87094-8e6a-4c95-a9b1-48f68c5c46bb
dea67802-694c-4273-b8a0-e84a88134e15	http://localhost:5000/uploads/apple-homepod-mini-cosmic-grey.jpg	Apple HomePod Mini Cosmic Grey	t	0	670c0a92-00ca-4b9c-be41-69b7692d19f7
e077c91e-e17c-4574-ae65-65ecf66c90b2	http://localhost:5000/uploads/apple-airpods.jpg	Apple Airpods	t	0	20fa2eee-3536-4f2d-a785-aabac57873d3
e97cea66-359f-49f3-a5f7-5721530ae927	http://localhost:5000/uploads/oppo-a57.jpg	Oppo A57	t	0	85617635-c1f5-4984-9ca4-1b87809990d7
f293cb43-8e3f-4eca-b1ad-99867cf4cb48	http://localhost:5000/uploads/oppo-f19-pro-plus.jpg	Oppo F19 Pro Plus	t	0	d331d383-c3d7-459f-94b9-862a0e650cc1
f379e2c6-f104-432f-8f10-7d71b3324aec	http://localhost:5000/uploads/apple-airpower-wireless-charger.jpg	Apple Airpower Wireless Charger	t	0	5e1d2eef-2bdd-4c9d-863d-b15bce200541
b0000000-0000-4000-8000-000000000001	http://localhost:5000/uploads/raspberry-pi-5-8gb.jpg	Raspberry Pi 5 8GB	t	0	a0000000-0000-4000-8000-000000000001
b0000000-0000-4000-8000-000000000002	http://localhost:5000/uploads/esp32-devkit-v1.jpg	ESP32 DevKit V1	t	0	a0000000-0000-4000-8000-000000000002
b0000000-0000-4000-8000-000000000003	http://localhost:5000/uploads/arduino-uno-r4-wifi.jpg	Arduino Uno R4 WiFi	t	0	a0000000-0000-4000-8000-000000000003
b0000000-0000-4000-8000-000000000004	http://localhost:5000/uploads/raspberry-pi-pico-w.jpg	Raspberry Pi Pico W	t	0	a0000000-0000-4000-8000-000000000004
b0000000-0000-4000-8000-000000000005	http://localhost:5000/uploads/lora-gateway-8-channel.jpg	LoRa Gateway 8-Channel	t	0	a0000000-0000-4000-8000-000000000005
b0000000-0000-4000-8000-000000000006	http://localhost:5000/uploads/zigbee-smart-hub.jpg	Zigbee Smart Hub	t	0	a0000000-0000-4000-8000-000000000006
b0000000-0000-4000-8000-000000000007	http://localhost:5000/uploads/dht22-sensor-kit.jpg	DHT22 Sensor Kit	t	0	a0000000-0000-4000-8000-000000000007
b0000000-0000-4000-8000-000000000008	http://localhost:5000/uploads/mmwave-radar-sensor.jpg	mmWave Radar Sensor	t	0	a0000000-0000-4000-8000-000000000008
b0000000-0000-4000-8000-000000000009	http://localhost:5000/uploads/nvidia-rtx-4090-24gb.jpg	NVIDIA RTX 4090 24GB	t	0	a0000000-0000-4000-8000-000000000009
b0000000-0000-4000-8000-000000000010	http://localhost:5000/uploads/nvidia-jetson-orin-nano.jpg	NVIDIA Jetson Orin Nano	t	0	a0000000-0000-4000-8000-000000000010
b0000000-0000-4000-8000-000000000011	http://localhost:5000/uploads/google-coral-usb-accelerator.jpg	Google Coral USB Accelerator	t	0	a0000000-0000-4000-8000-000000000011
b0000000-0000-4000-8000-000000000012	http://localhost:5000/uploads/hailo-8-ai-accelerator.jpg	Hailo-8 AI Accelerator	t	0	a0000000-0000-4000-8000-000000000012
b0000000-0000-4000-8000-000000000013	http://localhost:5000/uploads/intel-neural-compute-stick-2.jpg	Intel Neural Compute Stick 2	t	0	a0000000-0000-4000-8000-000000000013
b0000000-0000-4000-8000-000000000014	http://localhost:5000/uploads/ai-workstation-threadripper.jpg	AI Workstation Threadripper	t	0	a0000000-0000-4000-8000-000000000014
b0000000-0000-4000-8000-000000000015	http://localhost:5000/uploads/nvidia-a100-80gb.jpg	NVIDIA A100 80GB Tensor Core	t	0	a0000000-0000-4000-8000-000000000015
b0000000-0000-4000-8000-000000000016	http://localhost:5000/uploads/yubikey-5-nfc.jpg	YubiKey 5 NFC	t	0	a0000000-0000-4000-8000-000000000016
b0000000-0000-4000-8000-000000000017	http://localhost:5000/uploads/flipper-zero.jpg	Flipper Zero	t	0	a0000000-0000-4000-8000-000000000017
b0000000-0000-4000-8000-000000000018	http://localhost:5000/uploads/hak5-wifi-pineapple.jpg	Hak5 WiFi Pineapple	t	0	a0000000-0000-4000-8000-000000000018
b0000000-0000-4000-8000-000000000019	http://localhost:5000/uploads/proxmark3-rdv4.jpg	Proxmark3 RDV4	t	0	a0000000-0000-4000-8000-000000000019
b0000000-0000-4000-8000-000000000020	http://localhost:5000/uploads/usb-rubber-ducky.jpg	USB Rubber Ducky	t	0	a0000000-0000-4000-8000-000000000020
b0000000-0000-4000-8000-000000000021	http://localhost:5000/uploads/nitrokey-hsm-2.jpg	Nitrokey HSM 2	t	0	a0000000-0000-4000-8000-000000000021
b0000000-0000-4000-8000-000000000022	http://localhost:5000/uploads/faraday-signal-blocking-bag.jpg	Faraday Signal-Blocking Bag	t	0	a0000000-0000-4000-8000-000000000022
b0000000-0000-4000-8000-000000000023	http://localhost:5000/uploads/ubiquiti-unifi-dream-machine.jpg	Ubiquiti UniFi Dream Machine	t	0	a0000000-0000-4000-8000-000000000023
b0000000-0000-4000-8000-000000000024	http://localhost:5000/uploads/24-port-managed-switch.jpg	24-Port Managed Switch	t	0	a0000000-0000-4000-8000-000000000024
b0000000-0000-4000-8000-000000000025	http://localhost:5000/uploads/1u-rackmount-server.jpg	1U Rackmount Server	t	0	a0000000-0000-4000-8000-000000000025
b0000000-0000-4000-8000-000000000026	http://localhost:5000/uploads/synology-4-bay-nas.jpg	Synology 4-Bay NAS	t	0	a0000000-0000-4000-8000-000000000026
b0000000-0000-4000-8000-000000000027	http://localhost:5000/uploads/kvm-over-ip-switch.jpg	KVM over IP Switch	t	0	a0000000-0000-4000-8000-000000000027
b0000000-0000-4000-8000-000000000028	http://localhost:5000/uploads/ups-1500va-rackmount.jpg	UPS 1500VA Rackmount	t	0	a0000000-0000-4000-8000-000000000028
b0000000-0000-4000-8000-000000000029	http://localhost:5000/uploads/managed-pdu-rack-strip.jpg	Managed PDU Rack Strip	t	0	a0000000-0000-4000-8000-000000000029
b0000000-0000-4000-8000-000000000030	http://localhost:5000/uploads/keychron-q1-mechanical-keyboard.jpg	Keychron Q1 Mechanical Keyboard	t	0	a0000000-0000-4000-8000-000000000030
b0000000-0000-4000-8000-000000000031	http://localhost:5000/uploads/dev-monitor-4k-27.jpg	4K Dev Monitor 27-inch	t	0	a0000000-0000-4000-8000-000000000031
b0000000-0000-4000-8000-000000000032	http://localhost:5000/uploads/usb-c-docking-station.jpg	USB-C Docking Station	t	0	a0000000-0000-4000-8000-000000000032
b0000000-0000-4000-8000-000000000033	http://localhost:5000/uploads/elgato-stream-deck-mk2.jpg	Elgato Stream Deck MK.2	t	0	a0000000-0000-4000-8000-000000000033
b0000000-0000-4000-8000-000000000034	http://localhost:5000/uploads/ergonomic-vertical-mouse.jpg	Ergonomic Vertical Mouse	t	0	a0000000-0000-4000-8000-000000000034
b0000000-0000-4000-8000-000000000035	http://localhost:5000/uploads/aluminum-laptop-stand.jpg	Aluminum Laptop Stand	t	0	a0000000-0000-4000-8000-000000000035
b0000000-0000-4000-8000-000000000036	http://localhost:5000/uploads/jetbrains-all-products-pack.jpg	JetBrains All Products Pack	t	0	a0000000-0000-4000-8000-000000000036
b0000000-0000-4000-8000-000000000037	http://localhost:5000/uploads/github-copilot-1-year.jpg	GitHub Copilot 1-Year	t	0	a0000000-0000-4000-8000-000000000037
\.


--
-- Data for Name: Products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Products" ("Id", "Name", "Slug", "Description", "Price", "SalePrice", "StockQuantity", "Sku", "IsActive", "CreatedAt", "CategoryId", "ShopId") FROM stdin;
185840fc-8742-44fb-892c-1ee9fa44500a	Huawei Matebook X Pro	huawei-matebook-x-pro	The Huawei Matebook X Pro is a slim and stylish laptop with a high-resolution touchscreen display, offering a premium experience for users on the go.	1399.99	1268.67	75	LAP-HUA-HUA-080	t	2026-08-10 16:03:13.866187+00	1f7eef1c-edd0-4664-8afb-f15a9c442e28	977648dd-cda6-4c57-84cf-86e0069ecb2f
37c92d0d-f9ff-47f9-89d7-98586b1a3db7	iPhone 6	iphone-6	The iPhone 6 is a stylish and capable smartphone with a larger display and improved performance. It introduced new features and design elements, making it a...	299.99	279.92	60	SMA-APP-IPH-122	t	2026-08-10 16:03:13.869211+00	b0fb2314-f33a-4421-a085-6708c77283ba	977648dd-cda6-4c57-84cf-86e0069ecb2f
4f2c2fe8-ad30-48d6-8ae8-fcb55cfca52d	Asus Zenbook Pro Dual Screen Laptop	asus-zenbook-pro-dual-screen-laptop	The Asus Zenbook Pro Dual Screen Laptop is a high-performance device with dual screens, providing productivity and versatility for creative professionals.	1799.99	1599.47	45	LAP-ASU-ASU-079	t	2026-08-10 16:03:13.864908+00	1f7eef1c-edd0-4664-8afb-f15a9c442e28	977648dd-cda6-4c57-84cf-86e0069ecb2f
7c0a5429-3f52-4741-8f76-97bcd115eeff	iPhone 5s	iphone-5s	The iPhone 5s is a classic smartphone known for its compact design and advanced features during its release. While it's an older model, it still provides a r...	199.99	174.17	25	SMA-APP-IPH-121	t	2026-08-10 16:03:13.868411+00	b0fb2314-f33a-4421-a085-6708c77283ba	977648dd-cda6-4c57-84cf-86e0069ecb2f
9852d867-c7f0-4b48-871b-a6b3c65e8dc1	New DELL XPS 13 9300 Laptop	new-dell-xps-13-9300-laptop	The New DELL XPS 13 9300 Laptop is a compact and powerful device, featuring a virtually borderless InfinityEdge display and high-end performance for various...	1499.99	1321.64	74	LAP-DEL-DEL-082	t	2026-08-10 16:03:13.867747+00	1f7eef1c-edd0-4664-8afb-f15a9c442e28	977648dd-cda6-4c57-84cf-86e0069ecb2f
c3a87094-8e6a-4c95-a9b1-48f68c5c46bb	Apple MacBook Pro 14 Inch Space Grey	apple-macbook-pro-14-inch-space-grey	The MacBook Pro 14 Inch in Space Grey is a powerful and sleek laptop, featuring Apple's M1 Pro chip for exceptional performance and a stunning Retina display.	1999.99	1906.19	24	LAP-APP-APP-078	t	2026-08-10 16:03:13.814224+00	1f7eef1c-edd0-4664-8afb-f15a9c442e28	977648dd-cda6-4c57-84cf-86e0069ecb2f
e359c739-2956-45cd-8078-05c12569fed5	Lenovo Yoga 920	lenovo-yoga-920	The Lenovo Yoga 920 is a 2-in-1 convertible laptop with a flexible hinge, allowing you to use it as a laptop or tablet, offering versatility and portability.	1099.99	1027.94	40	LAP-LEN-LEN-081	t	2026-08-10 16:03:13.86696+00	1f7eef1c-edd0-4664-8afb-f15a9c442e28	977648dd-cda6-4c57-84cf-86e0069ecb2f
e49868b6-5d2a-47be-818b-6fed52f314bd	iPhone 13 Pro	iphone-13-pro	The iPhone 13 Pro is a cutting-edge smartphone with a powerful camera system, high-performance chip, and stunning display. It offers advanced features for us...	1099.99	996.92	56	SMA-APP-IPH-123	t	2026-08-10 16:03:13.869985+00	b0fb2314-f33a-4421-a085-6708c77283ba	977648dd-cda6-4c57-84cf-86e0069ecb2f
fcec98fb-80e8-4148-9d16-dead4c14215a	Apple AirPods Max Silver	apple-airpods-max-silver	The Apple AirPods Max in Silver are premium over-ear headphones with high-fidelity audio, adaptive EQ, and active noise cancellation. Experience immersive so...	549.99	474.81	59	MOB-APP-APP-101	t	2026-08-10 16:03:13.876236+00	c7b80786-959b-4d03-aa66-f0aeb8eac383	5d76f670-7104-40ee-8817-07fef9d1f878
20fa2eee-3536-4f2d-a785-aabac57873d3	Apple Airpods	apple-airpods	The Apple Airpods offer a seamless wireless audio experience. With easy pairing, high-quality sound, and Siri integration, they are perfect for on-the-go lis...	129.99	109.79	64	MOB-APP-APP-100	t	2026-08-10 16:03:13.875528+00	c7b80786-959b-4d03-aa66-f0aeb8eac383	5d76f670-7104-40ee-8817-07fef9d1f878
a93fc4ad-7a77-4d95-a415-52a953a5566d	Amazon Echo Plus	amazon-echo-plus	The Amazon Echo Plus is a smart speaker with built-in Alexa voice control. It features premium sound quality and serves as a hub for controlling smart home d...	99.99	87.92	59	MOB-AMA-AMA-099	t	2026-08-10 16:03:13.874862+00	c7b80786-959b-4d03-aa66-f0aeb8eac383	5d76f670-7104-40ee-8817-07fef9d1f878
5e1d2eef-2bdd-4c9d-863d-b15bce200541	Apple Airpower Wireless Charger	apple-airpower-wireless-charger	The Apple AirPower Wireless Charger provides a convenient way to charge your compatible Apple devices wirelessly. Simply place your devices on the charging m...	79.99	76.41	0	MOB-APP-APP-102	t	2026-08-10 16:03:13.877037+00	c7b80786-959b-4d03-aa66-f0aeb8eac383	5d76f670-7104-40ee-8817-07fef9d1f878
3e57dab6-91f9-4e0c-af54-4273238b7845	Apple iPhone Charger	apple-iphone-charger	The Apple iPhone Charger is a high-quality charger designed for fast and efficient charging of your iPhone. Ensure your device stays powered up and ready to go.	19.99	16.29	27	MOB-APP-APP-104	t	2026-08-10 16:03:13.880212+00	c7b80786-959b-4d03-aa66-f0aeb8eac383	5d76f670-7104-40ee-8817-07fef9d1f878
85617635-c1f5-4984-9ca4-1b87809990d7	Oppo A57	oppo-a57	The Oppo A57 is a mid-range smartphone known for its sleek design and capable features. It offers a balance of performance and affordability, making it a pop...	249.99	\N	15	SMA-OPP-OPP-125	t	2026-08-10 16:03:13.871432+00	b0fb2314-f33a-4421-a085-6708c77283ba	977648dd-cda6-4c57-84cf-86e0069ecb2f
a63c6805-7917-444c-b62c-cad321a10bd5	iPhone X	iphone-x	The iPhone X is a flagship smartphone featuring a bezel-less OLED display, facial recognition technology (Face ID), and impressive performance. It represents...	899.99	723.68	32	SMA-APP-IPH-124	t	2026-08-10 16:03:13.870747+00	b0fb2314-f33a-4421-a085-6708c77283ba	977648dd-cda6-4c57-84cf-86e0069ecb2f
670c0a92-00ca-4b9c-be41-69b7692d19f7	Apple HomePod Mini Cosmic Grey	apple-homepod-mini-cosmic-grey	The Apple HomePod Mini in Cosmic Grey is a compact smart speaker that delivers impressive audio and integrates seamlessly with the Apple ecosystem for a smar...	99.99	81.89	23	MOB-APP-APP-103	t	2026-08-10 16:03:13.87784+00	c7b80786-959b-4d03-aa66-f0aeb8eac383	5d76f670-7104-40ee-8817-07fef9d1f878
d331d383-c3d7-459f-94b9-862a0e650cc1	Oppo F19 Pro Plus	oppo-f19-pro-plus	The Oppo F19 Pro Plus is a feature-rich smartphone with a focus on camera capabilities. It boasts advanced photography features and a powerful performance fo...	399.99	325.43	76	SMA-OPP-OPP-126	t	2026-08-10 16:03:13.872114+00	b0fb2314-f33a-4421-a085-6708c77283ba	977648dd-cda6-4c57-84cf-86e0069ecb2f
133ead3f-3480-40f2-814f-9f19b628c659	Samsung Galaxy Tab White	samsung-galaxy-tab-white	The Samsung Galaxy Tab in White is a sleek and versatile Android tablet. With a vibrant display, long-lasting battery, and a range of features, it offers a g...	349.99	286.29	85	TAB-SAM-SAM-161	t	2026-08-10 16:03:13.874196+00	ee5ea3c2-79c5-4cbf-a9d0-8d551bde5574	977648dd-cda6-4c57-84cf-86e0069ecb2f
6e0e1354-b1a2-4731-9611-e65e86b4ac59	Samsung Galaxy Tab S8 Plus Grey	samsung-galaxy-tab-s8-plus-grey	The Samsung Galaxy Tab S8 Plus in Grey is a high-performance Android tablet by Samsung. With a large AMOLED display, powerful processor, and S Pen support, i...	599.99	520.13	54	TAB-SAM-SAM-160	t	2026-08-10 16:03:13.873571+00	ee5ea3c2-79c5-4cbf-a9d0-8d551bde5574	977648dd-cda6-4c57-84cf-86e0069ecb2f
8457e253-8e47-4da7-a6b6-bf27f3e2a062	iPad Mini 2021 Starlight	ipad-mini-2021-starlight	The iPad Mini 2021 in Starlight is a compact and powerful tablet from Apple. Featuring a stunning Retina display, powerful A-series chip, and a sleek design,...	499.99	481.79	40	TAB-APP-IPA-159	t	2026-08-10 16:03:13.872911+00	ee5ea3c2-79c5-4cbf-a9d0-8d551bde5574	977648dd-cda6-4c57-84cf-86e0069ecb2f
a0000000-0000-4000-8000-000000000001	Raspberry Pi 5 8GB	raspberry-pi-5-8gb	The Raspberry Pi 5 with 8GB RAM is a credit-card sized computer powered by a quad-core Cortex-A76 CPU. Ideal for edge computing, home labs and IoT gateways.	89.99	82.99	120	IOT-RPI-RP5-201	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000001	5f000000-0000-4000-8000-000000000001
a0000000-0000-4000-8000-000000000002	ESP32 DevKit V1	esp32-devkit-v1	The ESP32 DevKit V1 is a low-cost Wi-Fi + Bluetooth microcontroller board, perfect for connected sensors, home automation and battery-powered IoT nodes.	12.99	9.99	300	IOT-ESP-E32-202	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000001	5f000000-0000-4000-8000-000000000001
a0000000-0000-4000-8000-000000000003	Arduino Uno R4 WiFi	arduino-uno-r4-wifi	The Arduino Uno R4 WiFi pairs a 32-bit Renesas MCU with an ESP32-S3 radio and a built-in LED matrix - a friendly board for learning embedded and IoT.	27.99	24.50	180	IOT-ARD-R4W-203	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000001	5f000000-0000-4000-8000-000000000001
a0000000-0000-4000-8000-000000000004	Raspberry Pi Pico W	raspberry-pi-pico-w	The Raspberry Pi Pico W is a tiny, ultra-affordable RP2040 microcontroller board with wireless connectivity for compact embedded projects.	6.99	\N	500	IOT-RPI-PCW-204	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000001	5f000000-0000-4000-8000-000000000001
a0000000-0000-4000-8000-000000000005	LoRa Gateway 8-Channel	lora-gateway-8-channel	An 8-channel LoRaWAN gateway that bridges long-range, low-power sensor networks to the internet - the backbone of city-scale and agricultural IoT.	159.99	139.99	45	IOT-LOR-8CH-205	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000001	5f000000-0000-4000-8000-000000000001
a0000000-0000-4000-8000-000000000006	Zigbee Smart Hub	zigbee-smart-hub	A Zigbee 3.0 smart home hub that locally controls lights, sensors and switches with low latency and no cloud dependency.	49.99	42.99	90	IOT-ZIG-HUB-206	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000001	5f000000-0000-4000-8000-000000000001
a0000000-0000-4000-8000-000000000007	DHT22 Sensor Kit	dht22-sensor-kit	A DHT22 temperature and humidity sensor kit with jumper wires and resistors - a classic starting point for environmental monitoring builds.	14.99	11.99	240	IOT-DHT-K22-207	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000001	5f000000-0000-4000-8000-000000000001
a0000000-0000-4000-8000-000000000008	mmWave Radar Sensor	mmwave-radar-sensor	A 60GHz mmWave presence-detection radar module that senses micro-movements for reliable room occupancy and fall detection in smart spaces.	19.99	\N	160	IOT-MMW-RAD-208	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000001	5f000000-0000-4000-8000-000000000001
a0000000-0000-4000-8000-000000000009	NVIDIA RTX 4090 24GB	nvidia-rtx-4090-24gb	The NVIDIA RTX 4090 with 24GB GDDR6X delivers massive throughput for training and fine-tuning deep learning models, plus blistering local inference.	1799.99	1699.99	20	AI-NVD-4090-301	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000002	5f000000-0000-4000-8000-000000000002
a0000000-0000-4000-8000-000000000010	NVIDIA Jetson Orin Nano	nvidia-jetson-orin-nano	The Jetson Orin Nano developer kit brings up to 40 TOPS of AI performance to the edge, running modern vision and robotics models in a tiny footprint.	499.99	469.99	55	AI-NVD-ORN-302	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000002	5f000000-0000-4000-8000-000000000002
a0000000-0000-4000-8000-000000000011	Google Coral USB Accelerator	google-coral-usb-accelerator	The Coral USB Accelerator adds an Edge TPU coprocessor over USB-C, running TensorFlow Lite models fast and efficiently on any host machine.	59.99	54.99	130	AI-GOO-COR-303	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000002	5f000000-0000-4000-8000-000000000002
a0000000-0000-4000-8000-000000000012	Hailo-8 AI Accelerator	hailo-8-ai-accelerator	The Hailo-8 M.2 module delivers up to 26 TOPS at remarkable power efficiency, ideal for embedding real-time neural inference into edge products.	219.99	\N	40	AI-HAI-H8A-304	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000002	5f000000-0000-4000-8000-000000000002
a0000000-0000-4000-8000-000000000013	Intel Neural Compute Stick 2	intel-neural-compute-stick-2	The Intel Neural Compute Stick 2 is a plug-and-play USB accelerator powered by the Movidius Myriad X VPU for prototyping deep-learning inference.	99.99	84.99	70	AI-INT-NCS-305	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000002	5f000000-0000-4000-8000-000000000002
a0000000-0000-4000-8000-000000000014	AI Workstation Threadripper	ai-workstation-threadripper	A pre-built AI workstation with an AMD Threadripper CPU, 128GB RAM and dual GPUs - ready for serious model training straight out of the box.	4999.99	4699.99	8	AI-WKS-TRX-306	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000002	5f000000-0000-4000-8000-000000000002
a0000000-0000-4000-8000-000000000015	NVIDIA A100 80GB Tensor Core	nvidia-a100-80gb	The NVIDIA A100 80GB is a data-center GPU engineered for large-scale training and high-throughput inference across demanding AI and HPC workloads.	15999.99	\N	5	AI-NVD-A100-307	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000002	5f000000-0000-4000-8000-000000000002
a0000000-0000-4000-8000-000000000016	YubiKey 5 NFC	yubikey-5-nfc	The YubiKey 5 NFC is a hardware security key supporting FIDO2, U2F, OTP and smart-card protocols for phishing-resistant multi-factor authentication.	55.00	49.00	200	SEC-YUB-5NF-401	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000003	5f000000-0000-4000-8000-000000000003
a0000000-0000-4000-8000-000000000017	Flipper Zero	flipper-zero	The Flipper Zero is a portable multi-tool for pentesters and hardware hackers - sub-GHz radio, RFID/NFC, infrared and GPIO in a pocket device.	169.99	159.99	60	SEC-FLP-ZRO-402	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000003	5f000000-0000-4000-8000-000000000003
a0000000-0000-4000-8000-000000000018	Hak5 WiFi Pineapple	hak5-wifi-pineapple	The Hak5 WiFi Pineapple is a purpose-built platform for authorized wireless auditing and rogue-AP assessments during red-team engagements.	119.99	\N	35	SEC-HAK-WPA-403	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000003	5f000000-0000-4000-8000-000000000003
a0000000-0000-4000-8000-000000000019	Proxmark3 RDV4	proxmark3-rdv4	The Proxmark3 RDV4 is the reference tool for RFID research, reading, emulating and analyzing LF and HF contactless cards and tags.	299.99	279.99	25	SEC-PXM-RV4-404	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000003	5f000000-0000-4000-8000-000000000003
a0000000-0000-4000-8000-000000000020	USB Rubber Ducky	usb-rubber-ducky	The USB Rubber Ducky is a keystroke-injection tool that a target sees as a keyboard - a staple for demonstrating HID attack payloads in labs.	79.99	69.99	80	SEC-HAK-DUK-405	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000003	5f000000-0000-4000-8000-000000000003
a0000000-0000-4000-8000-000000000021	Nitrokey HSM 2	nitrokey-hsm-2	The Nitrokey HSM 2 is an open-source hardware security module that securely generates and stores cryptographic keys for PKI and code signing.	109.00	\N	50	SEC-NTK-HS2-406	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000003	5f000000-0000-4000-8000-000000000003
a0000000-0000-4000-8000-000000000022	Faraday Signal-Blocking Bag	faraday-signal-blocking-bag	A Faraday bag that blocks cellular, Wi-Fi, GPS and RFID signals to preserve digital evidence and protect devices from remote wiping or tracking.	29.99	24.99	150	SEC-FRD-BAG-407	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000003	5f000000-0000-4000-8000-000000000003
a0000000-0000-4000-8000-000000000023	Ubiquiti UniFi Dream Machine	ubiquiti-unifi-dream-machine	The UniFi Dream Machine combines a security gateway, controller, switch and access point into one appliance for clean, manageable networks.	379.99	349.99	40	OPS-UBI-UDM-501	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000004	5f000000-0000-4000-8000-000000000004
a0000000-0000-4000-8000-000000000024	24-Port Managed Switch	24-port-managed-switch	A 24-port gigabit managed switch with VLANs, LACP and PoE budget - the workhorse of a well-segmented server rack.	219.99	199.99	55	OPS-NET-24S-502	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000004	5f000000-0000-4000-8000-000000000004
a0000000-0000-4000-8000-000000000025	1U Rackmount Server	1u-rackmount-server	A 1U rackmount server with a Xeon CPU, ECC memory and redundant PSUs - dense, reliable compute for virtualization and self-hosting.	1299.99	1199.99	18	OPS-SRV-1U-503	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000004	5f000000-0000-4000-8000-000000000004
a0000000-0000-4000-8000-000000000026	Synology 4-Bay NAS	synology-4-bay-nas	The Synology 4-Bay NAS delivers centralized storage, backups and Docker services with a polished DSM interface for homelabs and small teams.	449.99	419.99	30	OPS-SYN-4BN-504	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000004	5f000000-0000-4000-8000-000000000004
a0000000-0000-4000-8000-000000000027	KVM over IP Switch	kvm-over-ip-switch	A KVM-over-IP switch that gives BIOS-level remote keyboard, video and mouse access to headless servers from anywhere.	189.99	\N	42	OPS-KVM-IP-505	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000004	5f000000-0000-4000-8000-000000000004
a0000000-0000-4000-8000-000000000028	UPS 1500VA Rackmount	ups-1500va-rackmount	A 1500VA line-interactive rackmount UPS with pure sine-wave output and network monitoring to keep infrastructure alive through outages.	279.99	249.99	36	OPS-UPS-15R-506	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000004	5f000000-0000-4000-8000-000000000004
a0000000-0000-4000-8000-000000000029	Managed PDU Rack Strip	managed-pdu-rack-strip	A managed rack PDU with per-outlet metering and remote switching, so you can power-cycle any device in the rack over the network.	159.99	144.99	48	OPS-PDU-RCK-507	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000004	5f000000-0000-4000-8000-000000000004
a0000000-0000-4000-8000-000000000030	Keychron Q1 Mechanical Keyboard	keychron-q1-mechanical-keyboard	The Keychron Q1 is a gasket-mounted, hot-swappable mechanical keyboard with a CNC aluminum body - a favorite for long coding sessions.	179.99	164.99	90	DEV-KEY-Q1M-601	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000005	5f000000-0000-4000-8000-000000000005
a0000000-0000-4000-8000-000000000031	4K Dev Monitor 27-inch	dev-monitor-4k-27	A 27-inch 4K IPS monitor with USB-C power delivery and factory color calibration - crisp text and plenty of room for code and terminals.	399.99	359.99	60	DEV-MON-4K27-602	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000005	5f000000-0000-4000-8000-000000000005
a0000000-0000-4000-8000-000000000032	USB-C Docking Station	usb-c-docking-station	A single-cable USB-C dock that adds dual displays, gigabit Ethernet, USB-A ports and 100W passthrough charging to any laptop.	129.99	114.99	110	DEV-DOK-USC-603	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000005	5f000000-0000-4000-8000-000000000005
a0000000-0000-4000-8000-000000000033	Elgato Stream Deck MK.2	elgato-stream-deck-mk2	The Elgato Stream Deck MK.2 gives you 15 programmable LCD keys to trigger builds, run scripts and control your dev workflow at a tap.	149.99	139.99	75	DEV-ELG-SD2-604	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000005	5f000000-0000-4000-8000-000000000005
a0000000-0000-4000-8000-000000000034	Ergonomic Vertical Mouse	ergonomic-vertical-mouse	An ergonomic vertical mouse that keeps your wrist in a natural handshake position to reduce strain during all-day work.	39.99	34.99	200	DEV-MOU-VRT-605	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000005	5f000000-0000-4000-8000-000000000005
a0000000-0000-4000-8000-000000000035	Aluminum Laptop Stand	aluminum-laptop-stand	A sturdy aluminum laptop stand that raises your screen to eye level and improves airflow, keeping thermals and posture in check.	34.99	29.99	180	DEV-STD-ALU-606	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000005	5f000000-0000-4000-8000-000000000005
a0000000-0000-4000-8000-000000000036	JetBrains All Products Pack	jetbrains-all-products-pack	A one-year individual license for the JetBrains All Products Pack - IntelliJ IDEA, PyCharm, WebStorm, Rider and every other JetBrains IDE.	289.00	\N	999	DEV-JBR-APP-607	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000005	5f000000-0000-4000-8000-000000000005
a0000000-0000-4000-8000-000000000037	GitHub Copilot 1-Year	github-copilot-1-year	A one-year GitHub Copilot subscription - AI pair-programming that suggests whole lines and functions right inside your editor.	100.00	\N	999	DEV-GHC-1YR-608	t	2026-08-11 00:00:00+00	c0000000-0000-4000-8000-000000000005	5f000000-0000-4000-8000-000000000005
\.


--
-- Data for Name: RefreshTokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."RefreshTokens" ("Id", "Token", "ExpiresAt", "CreatedAt", "IsRevoked", "IsUsed", "UserId") FROM stdin;
ffa0e10b-b9b4-45c6-9ef6-bdcb34387a7b	OcmkaffjMLdskQYkKcuj0/m9LL0bNummbOxENgPDO0MIYmHR2tQl4XacLM/zFzb66bXgRr7P3Cm3Bds5coQrtw==	2026-08-17 19:58:32.289731+00	2026-08-10 19:58:32.289682+00	f	f	019fec69-ef3b-7700-b360-b39eb230827d
8733f10e-677e-444a-be39-3badec54de7b	IRq8o+Hq15BPgRSKb7SFbuca2yOjkwFMsB0FJAymFqtSCMUtTzR6WkVMEBNMOw5PwKXxgSSN5q4kg5tUc+02eA==	2026-08-17 20:00:38.68073+00	2026-08-10 20:00:38.68073+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
2b9b98a6-7c1b-416f-aa4a-fd16d1c5d885	Q8zEnMiwE1QhJswiAuK5qBtGOpFW7d1bR7vCsGIx65yFFTP0xOAO0lTjbEnjgtfScaOftw+yGmfCG4HuC1gXlw==	2026-08-17 20:01:58.709071+00	2026-08-10 20:01:58.709071+00	f	f	019fec69-f0da-7aac-b148-e1abfb5ec992
d091ec69-f47b-4144-9c4f-d90f001f7450	9ai99j2qIDGIQD/bJhlbol/zb7R1vbNWfiBpidJNBAD8AMQt6NHMITAHCNNf8fizeM4Gt6j96qKVXyQc5ZsjLg==	2026-08-17 20:05:22.765478+00	2026-08-10 20:05:22.765478+00	f	f	019fed47-a234-7522-8c07-9cca377d0c0b
b7b5a6b5-6b65-4620-b207-851b58940184	mu3uV/yb/WA+YKhSUByWy2KHHOSUMYXfR2tTcoL0xKzeFsUm8VIPjWM7zKaWhTtfN19Pc9wUCOntGC4+VanE8Q==	2026-08-17 20:07:12.652467+00	2026-08-10 20:07:12.652467+00	f	f	019fec69-f0da-7aac-b148-e1abfb5ec992
b3609273-e531-47e3-b728-5722302cf38c	7R4X+YjD7U6kp4fZaEjTZNJCtaOjZ+Tet57V3vn2FgnlCTXkcOIFDafQTqYaD+5RlG2RgnIgOpDxBANbWfZPTA==	2026-08-17 20:09:01.505105+00	2026-08-10 20:09:01.505105+00	f	f	019fed4a-f8b7-7627-af59-5e0159895d52
9df52901-eb56-44f0-8d50-4aef606e56b8	M/iKMI6nehqgzx6R+B9I4mhsKSu2tL7IniwwpiVd4VM4UAv4n6KySsWrFrxWoOqNZkthwMv2urJxAiUCp5R6OQ==	2026-08-17 20:10:34.06823+00	2026-08-10 20:10:34.06823+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
2e17d70b-67af-4967-9032-a10285d9faa5	61iY2diKoBfjM9vi0gdpi09+o0bRgPnHY/ddgHqAukCvKtUP+/ku7d6szv9DsV0XGb1UctG90dSOzgLQY2tfzQ==	2026-08-17 20:11:54.505825+00	2026-08-10 20:11:54.505825+00	f	f	019fed4d-9cfa-7f08-847c-56ce4c7b650e
72a558f7-59f1-441c-95ce-726b395556b0	Fgf+NFodhXojW/iOLq8BtNTNVKZQq58V2aOeFsftEqehWNbpFmtE2Eo2+3i3XIPhCw4Eg6CqN1IIhdC0HMp+ww==	2026-08-17 20:12:13.332915+00	2026-08-10 20:12:13.332915+00	f	f	019fed4d-9cfa-7f08-847c-56ce4c7b650e
acfb6017-f23e-4c4a-9982-41901bc37f4d	pVBmOcCjojrNOjXHrzh+dTU0TKt45+N3AYd135j+ScW/P/JUhWjmUStVthS5aY+5BF1vseYUUlk6E+cDJaOfMw==	2026-08-17 20:28:35.726166+00	2026-08-10 20:28:35.726141+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
f9c3d57c-b99e-4b84-b5a4-a2524f613670	+7Nk1TILn8NMAmmW7TJ/wAIZc6JppJox8ILbaSH3L5PId2eQXcUarLQ+ZUXzFqGlVNk04y6cfrj5ByJCHXwIeQ==	2026-08-17 20:37:18.71938+00	2026-08-10 20:37:18.719358+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
7570f9a4-d029-443e-a4d7-9b190dea0bb1	/zQyZ+C0F8DkhRgMbaPjmwd50NWZL+VS1fGaHewDzz6cPaQucp/fKpyR6p/ruy0VWMFHDB1WV6p18iFrmAgvlg==	2026-08-17 20:39:34.359604+00	2026-08-10 20:39:34.359604+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
10b0394b-5899-4b34-9417-89aecc15ec7d	JYmbUxQfQIOK5w8RRXEiwnP4uQxBOXLTl0jl+eN7r54XziMlCzNHYxfbbRyKB6q8d2wBLAFhVgfsoMzVOzCEQQ==	2026-08-17 20:40:46.784553+00	2026-08-10 20:40:46.784552+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
43a66226-87ee-4cca-aa82-91f5ee4726d9	qzAIz+zgWrli4P33zcF3Rh56cbBlOrKYNmPlhbLutToqXhMedt41q+loVijJ7cMMmWjKdO6MsePQBAlpZolGxw==	2026-08-17 20:42:19.107669+00	2026-08-10 20:42:19.107669+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
8edd246a-1b3a-4396-8293-57ea7afbcd9a	pJODEU3qDHfqn4aqBigDvEdPsnLra27zYpVvtPnU9AekZ0b3cwDctYMumHwn6z5WqQx0zPdCcMkJf3k3ahKaGA==	2026-08-17 20:43:13.131212+00	2026-08-10 20:43:13.131212+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
ffff82ed-3274-4dbc-b667-fc737be2492d	yKXaAQfnx6BVee7Eum/vyoBEZ0fTA1X6JBR1C3BR87wDMrgeVw53EqM7A7+eT31ZiEV/8RIFDP9H4aGmkjSPXw==	2026-08-17 20:44:22.734674+00	2026-08-10 20:44:22.734674+00	f	f	019fec69-f09e-7b2f-92cd-74ca128c3dd0
206481dd-16aa-4106-9bd1-b2c2c6a6ec51	1zklP/JtB8RyA3tbeeQMMg/P3+ekfPulcFn44y9qs5fs7GpRl7A8vhmHWRs4RgKWBR5bWXDrWgti/9hQFrDbpw==	2026-08-17 20:45:50.202818+00	2026-08-10 20:45:50.202818+00	f	f	019fec69-ef3b-7700-b360-b39eb230827d
fe89cc21-c2e3-458c-b635-2f9e81807c4c	Dv8ZP1+fiqOkpTjpiX8et2WWw3QG16aIvnZujMBPUjdzGCx+QhqCvrSTFVbHm+4wiBxn+LEoU4nHxNuiekhFEg==	2026-08-17 20:45:51.325632+00	2026-08-10 20:45:51.325632+00	f	f	019fed6c-b11f-7d7a-b34d-d5f10f5c28d7
28263b2d-6da3-44fe-9aea-bca6c87b9e81	45MqLpcplkXBZrE8/4qXrZzZQVYzoH7EeGKTg4iPb8/zNyaj0cWbQKTr766Xi+3pyLdwkOMbkWmpSkr6wk2FdQ==	2026-08-17 20:45:51.378528+00	2026-08-10 20:45:51.378528+00	f	f	019fed6c-b11f-7d7a-b34d-d5f10f5c28d7
ff2a569c-cc48-40d6-b2a6-ce9b838b5220	WobnW9KMg3pzE5E4BBpuG0VD/s6BgNKnVvrur/RVBPKgEozrXv7vejchPsS9zbGdsJKp+7MZnYW/Qj4IdEWGYA==	2026-08-17 20:45:51.44377+00	2026-08-10 20:45:51.44377+00	f	f	019fed6c-b1ca-74cf-9f27-57842af4b017
d04b39c8-b3c9-47fc-9870-446df64858fe	0odCk4JE9ibW/M5NcFaq3JCt0fXIIQ+0aMryvDJhVEsH0UZHNdDNQZY+ElNWQ35jqxuZrNf70zdXom0Vpg7ivQ==	2026-08-17 20:45:51.497343+00	2026-08-10 20:45:51.497342+00	f	f	019fed6c-b1ca-74cf-9f27-57842af4b017
51850dad-8d33-4e14-ad61-9ca71a04cb18	DYvbGN57VJHBqcUCFxn8rOZ5lYuZ1b/h/CjmHtc6cciQjlmC7hdEURRyTbf+ocqt7v1Lz80gOO0mvIVGGQi/ag==	2026-08-17 20:45:51.560925+00	2026-08-10 20:45:51.560925+00	f	f	019fed6c-b240-7f57-8289-c4bc58356187
43c0bf8c-73d8-4159-a66b-89e571c61999	IOi62NBad22zplu4RT0FS04KTVzKGBquZo3m5G/Q+N9Y4GRsfWrFlaH5Wn0KLwZ/RTHZzzUbnjFr6MRV5VjiWA==	2026-08-17 20:45:51.613487+00	2026-08-10 20:45:51.613487+00	f	f	019fed6c-b240-7f57-8289-c4bc58356187
9af3c2de-43b2-449d-b81f-27b46f366427	6dbX2iwL0TGXavDYLV6zIpCLjts8aAlM6dKCEQFI3LdcP2fyIdHuaJTe3vlykdrIE8I+C7x/g9WToZH1JZ+YUw==	2026-08-17 20:45:51.679175+00	2026-08-10 20:45:51.679175+00	f	f	019fed6c-b2b6-7c03-9166-314cacf776a4
8d3dcf99-09d4-45c5-bd98-301662dd0460	rjElZ3CBM5slYcNU/t+38KX4aRD9i12hS6NaiSIGo1GglPjmQy7uLGFMD8IUUt40WA1raA46jXIC6fOL67fR2Q==	2026-08-17 20:45:51.733444+00	2026-08-10 20:45:51.733444+00	f	f	019fed6c-b2b6-7c03-9166-314cacf776a4
7bfb8c97-441e-450f-be2c-2c1333f5eac5	84HgfcBgmNacH8p3lpWTcVkcBYcHjyxoIiv5YEjr/+XFxkk/Oo5XKVcxz2KVr7PJt/hlFL10S/rAivOrSj5HdA==	2026-08-17 20:45:51.795803+00	2026-08-10 20:45:51.795803+00	f	f	019fed6c-b32b-7b05-b034-e2e3f61af42c
a33bd6ee-2eaa-463d-91fe-b16fe0f7491c	Y328e8XfDZwwBOPrNxINs06b4AR0cs/fUIasOTwZ1p/8fk8oZjqqR0ERds2lpANJqW0CAYpBD8iBC9ne6YXO9Q==	2026-08-17 20:45:51.854168+00	2026-08-10 20:45:51.854168+00	f	f	019fed6c-b32b-7b05-b034-e2e3f61af42c
46f6c66a-f7da-4de8-a52b-a789cfc5c421	12soQQjDdIbuMCKzEYmZmKtcVpltNzqizWov00ZLRSPt7BDx6dozN+LNXgpjwzgJrqxsV9ybZhUMBQ0Ik1Wc7w==	2026-08-17 20:45:51.916016+00	2026-08-10 20:45:51.916016+00	f	f	019fed6c-b3a5-7ae7-b66b-d46aea0484a6
4de7c412-e5dd-4579-aa19-6d88a6d3c488	DRNzvC/jch3B2g/IP3Cjtza9cmfGbpCtsVK3CQayBY+/XeH1JTRNQWgLneVit5Ch7/3gHh4m1WaWmJjxXsGAsw==	2026-08-17 20:45:51.969966+00	2026-08-10 20:45:51.969966+00	f	f	019fed6c-b3a5-7ae7-b66b-d46aea0484a6
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
5d76f670-7104-40ee-8817-07fef9d1f878	GadgetHub	gadgethub	Audio, smart speakers, chargers and mobile accessories.		1	2026-08-10 16:03:13.797294+00	019fec69-f0da-7aac-b148-e1abfb5ec992
977648dd-cda6-4c57-84cf-86e0069ecb2f	TechWorld Store	techworld-store	Authentic laptops, smartphones and tablets from top brands.		1	2026-08-10 16:03:13.775394+00	019fec69-f09e-7b2f-92cd-74ca128c3dd0
5f000000-0000-4000-8000-000000000001	IoT Depot	iot-depot	Single-board computers, microcontrollers, sensors and gateways for makers and embedded engineers.		1	2026-08-11 00:00:00+00	019ffff0-0000-7000-8000-000000000001
5f000000-0000-4000-8000-000000000002	Neural Forge	neural-forge	GPUs, edge accelerators and workstations built for training and deploying AI models.		1	2026-08-11 00:00:00+00	019ffff0-0000-7000-8000-000000000002
5f000000-0000-4000-8000-000000000003	SecOps Armory	secops-armory	Hardware keys, pentest gadgets and security tooling for red and blue teams.		1	2026-08-11 00:00:00+00	019ffff0-0000-7000-8000-000000000003
5f000000-0000-4000-8000-000000000004	OpsCenter	opscenter	Networking, rackmount servers, NAS and power gear to run reliable infrastructure.		1	2026-08-11 00:00:00+00	019ffff0-0000-7000-8000-000000000004
5f000000-0000-4000-8000-000000000005	DevTools Hub	devtools-hub	Keyboards, monitors, docks and software licenses that power a developer's workflow.		1	2026-08-11 00:00:00+00	019ffff0-0000-7000-8000-000000000005
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20260808172656_InitialCreate	10.0.10
20260808182842_MakeProductCategoryNullable	10.0.10
20260809084525_AddChat	10.0.10
20260810202508_AddCategoryOwnerShop	10.0.10
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
-- PostgreSQL database dump complete
--

\unrestrict vUEdWbOJDhZ00etsDvjwjND1BLVpREHVLwsKWA0j9QTPZH5mHyDJaJFxDxvZwBr

