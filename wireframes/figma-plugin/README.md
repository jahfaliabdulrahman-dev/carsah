# CarSah Figma Wireframe Plugin

## How to Import

1. Open **Figma Desktop** (already installed on your Mac)
2. Go to **Plugins** → **Development** → **Import plugin from manifest...**
3. Navigate to: `~/maintlogic/wireframes/figma-plugin/`
4. Select `manifest.json`
5. Click **Open**

## How to Run

1. Create a **new Figma file** (or open an existing one)
2. Go to **Plugins** → **Development** → **CarSah Wireframe Generator**
3. The plugin will create:
   - **Dashboard — Dark Mode** (390×844, MD3)
   - **Dashboard — Light Mode** (auto-converted colors)
   - **Dashboard — RTL (Arabic)** (cloned for RTL layout)

## What Gets Created

### Dashboard Screen (2.1)
- Status Bar (44dp)
- App Bar with Vehicle Switcher + Bell + Settings (64dp)
- Odometer Status Card (140dp, rounded 16dp)
- "Upcoming Services" section header
- 3 Task Cards (88dp each, rounded 12dp):
  - 🔴 URGENT — Engine Oil Change
  - 🟡 DUE — Air Filter
  - 🟢 SCHEDULED — Coolant Flush
- Analytics Preview placeholder (dashed border — Reserved Slot)
- FAB button (56×56dp, pill shape)
- Bottom Navigation Bar (80dp) — Home | Insights | History | Settings

### Design Tokens Used
- Colors: MD3 Dark/Light tonal palette
- Font: Inter (closest to Cairo in Figma — change to Cairo manually if needed)
- Spacing: 4dp grid system
- Corner radius: 12dp (cards), 16dp (large cards), 20dp (buttons), 28dp (FAB)

## Changing Font to Cairo

1. Select all text elements (Cmd+A → Filter by Text)
2. Change font family to **Cairo**
3. Match weights: Regular, Medium, SemiBold, Bold

## Files

- `manifest.json` — Plugin manifest
- `code.js` — Plugin source code
- `README.md` — This file
