# Story 1.4: User Authentication (Login, Logout, Session, 2FA)

**Epic:** 1 - Authentification & Gestion des Comptes
**FRs:** —
**NFRs:** NFR8 (HTTPS), NFR10 (2FA), NFR13 (session expiry), NFR31 (external auth)

## User Story

As a registered user,
I want to log in securely via Azure AD B2C, manage my session, and enable 2FA if I have a professional account,
So that my account is protected and I can access role-specific features.

## Acceptance Criteria

**Given** a registered user navigates to the login page
**When** they click "Se connecter"
**Then** they are redirected to Azure AD B2C Authorization Code Flow with PKCE
**And** upon successful authentication, an access token (JWT) and refresh token are obtained via MSAL.js
**And** the user is redirected back to the platform as authenticated

**Given** an authenticated user's access token expires
**When** a new API request is made
**Then** MSAL.js silently acquires a new token using the refresh token
**And** if the refresh token is also expired, the user is redirected to login

**Given** an authenticated user clicks "Se déconnecter"
**When** the logout is processed
**Then** the MSAL session is cleared, tokens are removed, and the user is redirected to the public homepage

**Given** a user with a professional account (role Seller)
**When** they access their security settings
**Then** they can enable/disable 2FA via Azure AD B2C MFA policy (NFR10)

**Given** a user's session has been inactive for a configurable duration (from `ConfigParameter`)
**When** the inactivity timeout is reached
**Then** the session expires and the user must re-authenticate (NFR13)

**Given** the backend receives a request with a JWT token
**When** the auth middleware processes it
**Then** the JWT is validated against the Azure AD B2C JWKS endpoint
**And** the user context (`req.user`) is injected with user ID, email, and roles from the `UserRole` table
