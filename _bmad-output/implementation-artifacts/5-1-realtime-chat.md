# Story 5.1: Real-Time Chat Linked to Vehicle

Status: ready-for-dev

## Story

As a buyer,
I want to chat in real time with a seller about a specific vehicle,
so that I can ask questions and negotiate directly without leaving the platform.

## Acceptance Criteria (BDD)

**Given** a registered buyer views a listing detail page
**When** they click "Contacter le vendeur" (FR30)
**Then** a chat window opens linked to the specific listing (vehicle context visible in chat header)
**And** if a conversation already exists for this buyer-seller-listing combination, it is resumed

**Given** a buyer sends a message
**When** the message is transmitted via the SignalR `/chat` hub
**Then** the seller receives the message in real time (< 1 second delivery, NFR4)
**And** a `ChatMessage` CDS record is created with: sender, receiver, listing, content, timestamp
**And** the message appears with a delivery indicator

**Given** a seller is not online
**When** a buyer sends a message
**Then** the message is stored and delivered when the seller reconnects
**And** the seller receives a notification (in-app and push)

**Given** a seller accesses their conversations (`(dashboard)/seller/chat/`)
**When** the conversation list loads
**Then** conversations are grouped by listing with: vehicle photo, buyer name, last message preview, unread badge, timestamp
**And** clicking a conversation opens the full thread with the vehicle context

## Tasks / Subtasks

### Task 1: CDS Entity Modeling for Chat (AC1, AC2)
1.1. Define `Conversation` entity in `srv/chat-service.cds` with fields: ID, buyerID (Association to User), sellerID (Association to User), listingID (Association to Listing), createdAt, updatedAt, lastMessageAt
1.2. Define `ChatMessage` entity in `srv/chat-service.cds` with fields: ID, conversationID (Association to Conversation), senderID (Association to User), content (String), timestamp, deliveryStatus (enum: sent, delivered, read)
1.3. Define CDS service `ChatService` exposing Conversation and ChatMessage with appropriate read/write projections
1.4. Add unique constraint on (buyerID, sellerID, listingID) for Conversation to ensure resume behavior
1.5. Write unit tests for CDS model validation and entity relationships

### Task 2: Chat Service Backend Logic (AC1, AC2, AC3)
2.1. Implement `srv/chat-service.ts` with action `startOrResumeConversation(listingID, buyerID)` that returns existing conversation or creates new one
2.2. Implement action `sendMessage(conversationID, content)` that creates a ChatMessage record, updates conversation lastMessageAt, and emits SignalR event
2.3. Implement query handler for fetching conversation list with aggregated data (last message preview, unread count)
2.4. Implement query handler for fetching message thread for a given conversation, with pagination (cursor-based)
2.5. Add authorization checks: only buyer/seller in the conversation can read/write messages
2.6. Write integration tests for all service actions and queries

### Task 3: SignalR Chat Hub (AC2, AC3)
3.1. Implement `srv/signalr/chat-hub.ts` connecting to Azure SignalR Service `/chat` hub
3.2. Implement connection management: on connect, join user to their conversation rooms (based on active conversations)
3.3. Implement `chat:message-sent` event emission when a new message is persisted, targeting the conversation room
3.4. Implement `chat:message-delivered` event when recipient's client acknowledges receipt
3.5. Implement `chat:message-read` event when recipient opens the conversation
3.6. Handle offline detection: if recipient is not connected, trigger notification flow (delegate to notification-hub)
3.7. Implement reconnection logic: on reconnect, deliver all undelivered messages for the user
3.8. Write integration tests for SignalR hub events and connection lifecycle

### Task 4: Frontend Chat Components (AC1, AC4)
4.1. Create `src/components/chat/chat-window.tsx` — main chat panel with message list, input area, vehicle context header
4.2. Create `src/components/chat/chat-message-bubble.tsx` — individual message bubble with sender avatar, content, timestamp, delivery indicator
4.3. Create `src/components/chat/chat-input.tsx` — message input with send button, character limit, disabled state during send
4.4. Create `src/components/chat/chat-header.tsx` — vehicle context bar showing photo thumbnail, title, price, link to listing
4.5. Create `src/components/chat/conversation-list.tsx` — list of conversations grouped by listing with unread badges
4.6. Create `src/components/chat/conversation-item.tsx` — individual conversation row with vehicle photo, buyer/seller name, last message preview, timestamp, unread badge
4.7. Write component tests for all chat components

### Task 5: Chat Hooks and State Management (AC1, AC2, AC3)
5.1. Implement `src/hooks/useSignalR.ts` — generic hook for establishing and managing SignalR connection (if not already created)
5.2. Implement `src/hooks/useChat.ts` — hook wrapping chat-specific SignalR events, message sending, and conversation management
5.3. Implement `src/stores/chat-store.ts` — Zustand store for chat state: active conversation, messages, unread counts, connection status
5.4. Handle optimistic updates: show message immediately in UI, update delivery status on server confirmation
5.5. Handle reconnection: re-fetch undelivered messages on reconnect
5.6. Write unit tests for hooks and store logic

### Task 6: Listing Detail Page Integration (AC1)
6.1. Add "Contacter le vendeur" button to listing detail page (only visible to authenticated buyers, not the listing owner)
6.2. On click, call `startOrResumeConversation` and open chat window (slide-in panel or modal)
6.3. Pre-populate chat header with vehicle context from the listing
6.4. Write integration test for the full flow: click button -> open chat -> send message

### Task 7: Seller Conversation List Page (AC4)
7.1. Create page `src/app/(dashboard)/seller/chat/page.tsx` displaying all seller conversations
7.2. Fetch conversations from ChatService with last message preview and unread counts
7.3. Implement real-time updates: new messages update the list in real time via SignalR
7.4. Implement click navigation: clicking a conversation opens the full thread
7.5. Create `src/app/(dashboard)/seller/chat/[conversationId]/page.tsx` for full thread view with vehicle context
7.6. Write page-level integration tests

## Dev Notes

### Architecture & Patterns
- **CDS-first approach:** Define entities and service in CDS, implement handlers in TypeScript
- **SignalR room pattern:** Each conversation maps to a SignalR room; both buyer and seller join the room
- **Optimistic UI:** Messages appear instantly in sender's UI; delivery status updates asynchronously via SignalR events
- **Offline-first:** Messages are always persisted server-side first, then pushed via SignalR; offline users receive messages on reconnect
- **Cursor-based pagination:** Use message timestamp as cursor for loading older messages in a thread

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
- [Source: _bmad-output/planning-artifacts/stories/epic-5/story-5.1-realtime-chat.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
