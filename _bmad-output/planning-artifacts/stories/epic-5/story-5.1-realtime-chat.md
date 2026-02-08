# Story 5.1: Real-Time Chat Linked to Vehicle

**Epic:** 5 - Communication Temps Réel & Notifications
**FRs:** FR30
**NFRs:** NFR4 (chat delivery < 1s), NFR21 (chat scalability)

## User Story

As a buyer,
I want to chat in real time with a seller about a specific vehicle,
So that I can ask questions and negotiate directly without leaving the platform.

## Acceptance Criteria

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
