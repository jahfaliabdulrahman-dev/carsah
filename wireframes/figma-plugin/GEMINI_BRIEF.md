# CarSah Figma Plugin — Context Brief for Gemini

## Project Overview

**CarSah** is a car maintenance tracking app built with Flutter + Isar (local DB) + Riverpod (state management). The architecture follows Clean Architecture principles. The app tracks vehicle odometer readings, maintenance schedules, service records, and invoice images.

**Tech Stack:**
- Flutter (Dart) — mobile app
- Isar DB — local NoSQL database
- Riverpod — state management
- Material Design 3 (MD3) — design system
- Target device: iPhone 14 (390 × 844 dp)
- Bilingual: Arabic (RTL, default) + English (LTR)
- Theme: Light (default) + Dark

**Current Phase:** v75+ — UI/UX Wireframing Epoch

Backend is complete (data models, Isar schemas, input sanitization, image lifecycle, invoice archive, all 16 CRUD operations). We are now designing wireframes in Figma BEFORE writing Flutter UI code. This is intentional — we learned the hard way that coding UI without wireframes leads to endless rework.

---

## The Triad Flow Architecture

All 16 screens are organized into 3 flows:

### Flow 1: Onboarding & Acquisition (4 screens)
1.1 Splash / Language & Theme Selection
1.2 Onboarding Carousel (3 slides + skip)
1.3 Authentication (Guest, Google/Apple [reserved], Email/Password)
1.4 Setup Wizard (vehicle → odometer → task audit)

### Flow 2: Core Operations (6 screens)
2.1 Dashboard (main screen)
2.2 Add Record Dialog
2.3 History Page
2.4 Record Detail Page
2.5 Invoice Viewer
2.6 Vehicle Switcher [P10 reserved]

### Flow 3: Intelligence & Growth (6 screens)
3.1 Settings
3.2 Insights Tab [Phase C reserved]
3.3 Notification Settings [Feature III reserved]
3.4 Profile & Cloud Sync [P10 reserved]
3.5 Report Generation [Feature IV reserved]
3.6 Onboarding Walkthrough Overlay [Feature VII reserved]

---

## 9 Feature Modules with Reserved Slots

Each future feature has a pre-designed "Reserved Slot" container in wireframes. No retroactive UI insertion (Zero-Patch Policy).

- I: Auth & Security
- II: Advanced Analytics
- III: Proactive Notifications
- IV: Report Export
- V: Search & Filtering
- VI: Settings & Customization
- VII: Onboarding Walkthrough
- VIII: Multi-Vehicle & Cloud Sync
- IX: Crowdsourced Pricing

---

## Mandatory Protocols

1. **Slotting Strategy** — every future module has a Reserved Slot
2. **RTL/LTR Mirroring** — both layouts validated before Flutter
3. **Zero-Patch Policy** — no UI added later without pre-designed container
4. **MD3 Compliance** — 4dp grid, Cairo font, elevation 0–5
5. **Default State** — AR locale, Light theme

---

## What We Have So Far

A Figma plugin (`code.js`) that generates the **Dashboard screen** (screen 2.1) in 3 variants:
1. Dark theme (LTR)
2. Light theme (LTR)
3. Dark theme (RTL — placeholder, not yet mirrored)

The plugin uses:
- 100% absolute positioning (no auto-layout — Figma plugin API is unreliable with auto-layout)
- MD3 color tokens (dark + light palettes)
- Cairo font with Inter fallback
- Helper functions: `rect()`, `circ()`, `txt()`, `col()`

---

## Dashboard Screen Elements (Current code.js)

The Dashboard contains:
- Status bar (time, signal icons)
- App bar (vehicle name, dropdown, notification bell with badge, settings gear)
- Odometer card (current km reading, last updated, "UPDATE" button)
- Section header: "Upcoming Services"
- 3 task cards with urgency levels:
  - URGENT (red) — Engine Oil Change, overdue by 6,807 km
  - DUE (amber) — Air Filter, due at 110,000 km
  - SCHEDULED (green) — Coolant Flush, at 120,000 km
- Analytics Preview placeholder (reserved — Phase C)
- Bottom navigation (Home, Insights, History, Settings)
- FAB (+) button for adding records

---

## What We Need From Gemini

We're asking Gemini to review the current `code.js` and provide:

1. **Architecture review** — is the plugin structure sound? Any anti-patterns?
2. **Visual quality assessment** — does the pixel layout follow MD3 spacing/sizing conventions?
3. **Missing elements** — what should be on the Dashboard that we missed?
4. **Scalability** — how should we structure code.js to add the remaining 15 screens without it becoming unmaintainable?
5. **RTL implementation** — best approach for mirroring layouts in Figma plugin API (since there's no native RTL support)
6. **Component reuse** — should we extract repeated patterns (task cards, nav items) into factory functions?
7. **Dark/Light conversion** — is our dual-theme approach (separate frames + separate color objects) the right pattern, or is there a better way?

---

## Code follows below (code.js — 204 lines)
