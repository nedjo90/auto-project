# Story 5.2: Event Notifications & Push

Status: ready-for-dev

## Story

As a user,
I want to receive notifications for relevant platform events, including push notifications on my devices,
so that I stay informed about activity on my listings, messages, and account.

## Acceptance Criteria (BDD)

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

## Tasks / Subtasks

### Task 1: CDS Entity Modeling for Notifications (AC1, AC3)
1.1. Define `Notification` entity in `srv/notification-service.cds` with fields: ID, userID (Association to User), type (enum: message, view, sold, report, favorite, system), title, body, actionUrl, isRead (Boolean, default false), createdAt
1.2. Define `NotificationPreference` entity with fields: ID, userID (Association to User), type (same enum), enabled (Boolean, default true)
1.3. Define `PushSubscription` entity with fields: ID, userID (Association to User), endpoint, p256dhKey, authKey, deviceLabel, createdAt
1.4. Define CDS service `NotificationService` exposing entities with appropriate projections and actions
1.5. Write unit tests for CDS model validation

### Task 2: Notification Service Backend Logic (AC1, AC2, AC3)
2.1. Implement `srv/notification-service.ts` with action `createNotification(userID, type, title, body, actionUrl)` that persists the notification and emits SignalR event
2.2. Implement action `markAsRead(notificationID)` and `markAllAsRead(userID)` for read status management
2.3. Implement query handler for fetching user notifications with pagination and unread count
2.4. Implement action `updatePreference(type, enabled)` for managing notification preferences per user
2.5. Implement action `registerPushSubscription(subscription)` to store PWA push subscription details
2.6. Implement action `unregisterPushSubscription(subscriptionID)` for removing push subscriptions
2.7. Add preference check logic: before creating a notification, verify user has not disabled that type
2.8. Write integration tests for all service actions

### Task 3: SignalR Notification Hub (AC1)
3.1. Implement `srv/signalr/notification-hub.ts` connecting to Azure SignalR Service `/notifications` hub
3.2. Implement connection management: on connect, join user to their personal notification channel
3.3. Implement event emission for each notification type using domain:action naming:
  - `notification:new-message` — new chat message received
  - `notification:new-view` — listing received a new view
  - `notification:listing-sold` — listing status changed to sold
  - `notification:report-handled` — report on listing was treated
  - `notification:new-contact` — new contact request on listing
  - `notification:favorite-update` — favorited listing changed
  - `notification:system` — system-wide announcements
3.4. Implement unread count broadcast: emit updated unread count after each new notification
3.5. Write integration tests for SignalR notification events

### Task 4: Push Notification Service (AC2)
4.1. Implement push notification sending logic using Web Push protocol (web-push npm package)
4.2. Generate and store VAPID keys for push authentication (via environment config, not hardcoded)
4.3. Implement push payload construction: title, body, icon (app icon), badge, action URL, tag (for notification grouping)
4.4. Implement multi-device delivery: send push to all registered subscriptions for a user
4.5. Handle push delivery failures: remove invalid/expired subscriptions automatically
4.6. Implement online detection: only send push when user has no active SignalR connection on `/notifications` hub
4.7. Write integration tests for push notification delivery

### Task 5: PWA Service Worker for Push (AC2)
5.1. Configure serwist service worker to handle push events in `src/sw.ts` or equivalent
5.2. Implement `push` event handler: parse push payload, display native notification with title, body, icon, action
5.3. Implement `notificationclick` event handler: on click, focus existing app window or open new one, navigate to action URL
5.4. Implement `notificationclose` event handler for analytics tracking (optional)
5.5. Handle notification badge updates on the app icon
5.6. Write tests for service worker push handling

### Task 6: Frontend Notification Components (AC1)
6.1. Create `src/components/notifications/notification-bell.tsx` — bell icon with unread count badge, click to open dropdown
6.2. Create `src/components/notifications/notification-dropdown.tsx` — dropdown panel listing recent notifications with type icons, title, time, read/unread styling
6.3. Create `src/components/notifications/notification-item.tsx` — individual notification row with icon, title, body preview, timestamp, click to navigate
6.4. Create `src/components/notifications/notification-settings.tsx` — toggle switches for each notification type preference
6.5. Integrate notification bell into the app header/navbar (visible to authenticated users)
6.6. Write component tests for all notification components

### Task 7: Notification Hooks and State Management (AC1, AC2)
7.1. Implement `src/hooks/useNotifications.ts` — hook for notification SignalR events, fetching notifications, managing read state
7.2. Implement `src/stores/notification-store.ts` — Zustand store for notification state: notifications list, unread count, preferences, connection status
7.3. Handle real-time updates: new notifications from SignalR update the store and trigger UI re-render
7.4. Implement push permission request flow: prompt user for push notification permission, register subscription on grant
7.5. Write unit tests for hooks and store

### Task 8: Push Permission & Subscription Management UI (AC2, AC3)
8.1. Create push permission prompt component shown after first login or from notification settings
8.2. Implement permission request flow: call Notification.requestPermission(), on grant create PushSubscription via service worker, send to backend
8.3. Add "Manage devices" section in notification settings showing registered push subscriptions with option to remove
8.4. Write integration test for full push subscription flow

### Task 9: Event Integration Points (AC1)
9.1. Add notification trigger in chat-service.ts: on new message, call NotificationService.createNotification for recipient
9.2. Add notification trigger in listing-service: on listing view milestone (e.g., every 10 views), notify seller
9.3. Add notification trigger in listing-service: on listing status change to sold, notify favorited users
9.4. Add notification trigger in report-service: on report resolution, notify reporter
9.5. Write integration tests for each event trigger

## Dev Notes

### Architecture & Patterns
- **Event-driven notifications:** Platform events trigger notifications through the NotificationService; the service checks preferences, persists, emits SignalR, and conditionally sends push
- **Push vs. in-app:** In-app notifications always go through SignalR `/notifications` hub; push notifications are sent only when user has no active SignalR connection
- **Multi-device push:** A user can have multiple push subscriptions (one per device/browser); all receive push when user is offline
- **Preference-gated:** Every notification type is gated by user preferences; defaults are all enabled
- **Service worker:** serwist handles PWA service worker lifecycle; push events are handled in the service worker context

### Key Technical Context
- **Stack:** SAP CAP backend, Next.js 16 frontend, PostgreSQL, Azure SignalR Service
- **Real-time:** Azure SignalR Service with 4 separate hubs:
  - /chat — buyer<->seller messages linked to vehicle
  - /notifications — push events (new contact, new view, report handled, etc.)
  - /live-score — visibility score updates during listing creation
  - /admin — real-time KPIs
- **SignalR events:** domain:action naming (e.g., "chat:message-sent", "notification:new-contact")
- **Chat:** chat-service.cds + .ts, signalr/chat-hub.ts, ChatMessage entity in CDS
- **Notifications:** Push notifications via PWA service worker (serwist), notification-hub.ts
- **Seller cockpit:** src/app/(dashboard)/seller/* (SPA behind auth)
- **KPIs:** seller-service.cds + .ts, dashboard components (kpi-card.tsx, chart-wrapper.tsx, stat-trend.tsx)
- **Market price:** lib/market-price.ts, IValuationAdapter (mock V1)
- **Favorites/Watch:** Stored in PostgreSQL, accessible from seller cockpit
- **Empty states:** Engaging design when cockpit is empty, guide to first action
- **Testing:** Component tests for all dashboard components, SignalR integration tests

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- SignalR events: domain:action kebab-case
- All technical naming in English

### Anti-Patterns (FORBIDDEN)
- Hardcoded values
- Direct DB queries
- French in code
- Skipping tests

### Project Structure Notes
Backend: srv/chat-service.*, srv/signalr/ (chat-hub.ts, notification-hub.ts), srv/seller-service.*
Frontend: src/app/(dashboard)/seller/*, src/components/chat/*, src/components/dashboard/*, src/hooks/useChat.ts, src/hooks/useSignalR.ts, src/hooks/useNotifications.ts, src/stores/chat-store.ts, src/stores/notification-store.ts

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/stories/epic-5/story-5.2-notifications-push.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
