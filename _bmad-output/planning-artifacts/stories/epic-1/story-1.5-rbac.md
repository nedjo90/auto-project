# Story 1.5: Role-Based Access Control (RBAC)

**Epic:** 1 - Authentification & Gestion des Comptes
**FRs:** FR23, FR24, FR25
**NFRs:** NFR14 (audit trail for sensitive ops), NFR16 (access logging)

## User Story

As an administrator,
I want the system to assign roles to users and control access to features based on their role,
So that each user accesses only the functionalities appropriate to their role.

## Acceptance Criteria

**Given** the system defines 5 roles: Visitor (anonymous), Buyer, Seller, Moderator, Administrator
**When** a user is created
**Then** a default role (Buyer) is assigned in the `UserRole` CDS table
**And** an administrator can change user roles via the admin interface

**Given** a user with role Buyer attempts to access the seller cockpit (`(dashboard)/seller/`)
**When** the `RoleGuard` component checks the role
**Then** the user is redirected to an unauthorized page with a clear message

**Given** a user with role Seller accesses the seller cockpit
**When** the `RoleGuard` component checks the role
**Then** access is granted and the cockpit renders

**Given** configurable auth-required features exist in `ConfigFeature` table
**When** an anonymous visitor accesses a feature flagged as requiring authentication (FR25)
**Then** the registration wall is displayed with calibrated teasing (skeleton visible, details blurred)
**And** the features requiring auth are driven by config, not hardcoded

**Given** the backend receives a request to a protected endpoint
**When** the RBAC middleware checks permissions
**Then** access is granted only if the user's role has the required permission
**And** a 403 Forbidden (RFC 7807) is returned for unauthorized access
**And** the attempt is logged in the audit trail
