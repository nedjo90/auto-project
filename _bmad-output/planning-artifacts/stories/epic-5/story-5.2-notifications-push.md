# Story 5.2: Event Notifications & Push

**Epic:** 5 - Communication Temps Réel & Notifications
**FRs:** FR31, FR32
**NFRs:** —

## User Story

As a user,
I want to receive notifications for relevant platform events, including push notifications on my devices,
So that I stay informed about activity on my listings, messages, and account.

## Acceptance Criteria

**Given** a notification-triggering event occurs (new message, new view on listing, listing sold, report treated, etc.) (FR31)
**When** the event is processed
**Then** a notification is created via the SignalR `/notifications` hub
**And** the notification appears in-app (bell icon with unread count)
**And** clicking a notification navigates to the relevant context (listing, chat, report)

**Given** a user has granted push notification permission (FR32)
**When** a notification is triggered and the user is not active on the platform
**Then** a push notification is sent to their device(s) via the PWA service worker
**And** the push notification shows: title, brief description, action link

**Given** a user wants to manage notification preferences
**When** they access notification settings
**Then** they can enable/disable notification types (messages, views, favorites updates, system alerts)
**And** preferences are stored per user
