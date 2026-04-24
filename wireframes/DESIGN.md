---
version: alpha
name: CarSah
description: Vehicle maintenance tracking app — MD3 dark theme, bilingual Arabic/English, Saudi market

colors:
  # Dark mode (primary)
  surface: "#1B1B1F"
  surface-container: "#211F26"
  surface-container-low: "#1D1B20"
  on-surface: "#E6E1E5"
  on-surface-variant: "#938F99"
  primary: "#D0BCFF"
  primary-container: "#4F378B"
  on-primary-container: "#EADDFF"
  error: "#F2B8B5"
  error-container: "#8C1D18"
  warning: "#E8C77A"
  warning-container: "#4A3B00"
  success: "#A8DAB5"
  success-container: "#1B3A24"
  outline: "#49454F"
  # Light mode
  surface-light: "#FAFAFA"
  surface-container-light: "#F3EDF7"
  surface-container-low-light: "#F7F2FA"
  on-surface-light: "#1B1B1F"
  on-surface-variant-light: "#79747E"
  primary-light: "#5835B0"
  primary-container-light: "#EADDFF"
  on-primary-container-light: "#4F378B"
  error-light: "#BA1A1A"
  error-container-light: "#F2B8B5"
  warning-light: "#7D5700"
  warning-container-light: "#E8C77A"
  success-light: "#1B5E20"
  success-container-light: "#A8DAB5"
  outline-light: "#CAC4D0"

typography:
  display:
    fontFamily: Cairo
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.25
  headline:
    fontFamily: Cairo
    fontSize: 24px
    fontWeight: 600
    lineHeight: 1.33
  title:
    fontFamily: Cairo
    fontSize: 18px
    fontWeight: 500
    lineHeight: 1.33
  body:
    fontFamily: Cairo
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.43
  label:
    fontFamily: Cairo
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.33
  label-bold:
    fontFamily: Cairo
    fontSize: 10px
    fontWeight: 700
    lineHeight: 1.4

rounded:
  xs: 8px
  sm: 10px
  md: 12px
  lg: 16px
  xl: 20px
  pill: 28px

spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 32px

components:
  card:
    backgroundColor: "{colors.surface-container}"
    rounded: "{rounded.lg}"
    padding: 16px
  card-task:
    backgroundColor: "{colors.surface-container-low}"
    rounded: "{rounded.md}"
    padding: 16px
    height: 88px
  button-primary:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary-container}"
    typography: "{typography.body}"
    rounded: "{rounded.xl}"
    height: 36px
    padding: 16px
  fab:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary-container}"
    typography: "{typography.display}"
    size: 56px
    rounded: 28px
  bottom-nav:
    backgroundColor: "{colors.surface-container}"
    height: 80px
  status-dot:
    size: 8px
  badge:
    rounded: "{rounded.sm}"
    padding: 8px
    typography: "{typography.label-bold}"
  odometer-card:
    backgroundColor: "{colors.surface-container}"
    rounded: "{rounded.lg}"
    padding: 16px
    height: 140px
---

# CarSah

## Overview

CarSah is a vehicle maintenance tracking app for the Saudi market. It follows Material Design 3 standards with a dark-primary theme and full Arabic/English bilingual support (RTL/LTR mirroring). The aesthetic is industrial and clean — designed for quick data entry in garages and at roadside, not visual decoration. Users check maintenance status primarily at night or in low-light conditions, which is why dark mode is the primary theme.

## Colors

The palette uses MD3 tonal system with a deep dark foundation and purple accents.

- **Surface (#1B1B1F):** Deep charcoal background — reduces eye strain in low-light use.
- **Surface Container (#211F26):** Elevated card backgrounds — subtle contrast against surface.
- **Primary (#D0BCFF):** Soft lavender — active states, interactive elements.
- **Primary Container (#4F378B):** Deep purple — button fills, active indicators.
- **On Surface (#E6E1E5):** Near-white — primary text, high contrast on dark surfaces.
- **Error (#F2B8B5):** Muted red — urgency indicators (overdue tasks).
- **Warning (#E8C77A):** Amber — due-soon indicators.
- **Success (#A8DAB5):** Muted green — scheduled/completed indicators.
- **Outline (#49454F):** Dark gray — borders, dividers, dashed placeholders.

Light mode tokens are suffixed with `-light` and provide the same semantic mapping for light theme support.

## Typography

Cairo is the primary font — it renders cleanly in both Arabic and English. All text follows the MD3 type scale.

- **Display (32px, Bold):** Odometer readings, primary numerical data.
- **Headline (24px, SemiBold):** Page titles.
- **Title (18px, Medium):** Section headers.
- **Body (14px, Regular):** Subtitles, descriptions, form labels.
- **Label (12px, Regular):** Captions, timestamps, secondary info.
- **Label Bold (10px, Bold):** Status badges (URGENT, DUE, SCHEDULED).

## Layout

Frame: 390×844 dp (iPhone 14). 4dp base grid. Screen edge padding: 16dp.

Components use absolute positioning for pixel-perfect control. The dashboard is structured top-to-bottom: Status Bar (44dp) → App Bar (64dp) → Odometer Card (140dp) → Section Header (32dp) → Task Cards (88dp each) → Chart Placeholder (120dp) → Flex Space → Bottom Navigation (80dp) → FAB (56×56dp, overlapping nav).

## Shapes

Cards use 16dp corner radius. Task cards use 12dp. Buttons use 20dp (pill shape). FAB uses 28dp (near-circle). Status badges use 10dp. All radii are multiples of 4dp per MD3 standards.

## Components

- **Card:** Surface container background, 16dp radius, 16dp padding.
- **Task Card:** Surface container low background, 12dp radius, 88dp height, contains urgency dot + task name + subtitle + status badge.
- **Button:** Primary container background, pill shape (20dp radius), 36dp height.
- **FAB:** 56dp circle, primary container fill, "+" icon centered.
- **Bottom Nav:** Surface container background, 80dp height, top border only, 4 items with active indicator.
- **Status Dot:** 8dp circle, color-coded by urgency (error/warning/success).
- **Badge:** 10dp radius pill, 10sp bold text, color matches urgency level.

## Do's and Don'ts

**Do:**
- Use dark mode colors by default
- Maintain 4dp grid alignment
- Color-code urgency consistently (red/amber/green)
- Support both RTL and LTR layouts
- Keep touch targets minimum 44×44dp

**Don't:**
- Use pure black (#000000) — use surface (#1B1B1F) instead
- Mix urgency colors (red badge = urgent, never due)
- Place text below 10sp — too small for Arabic readability
- Skip the status dot — always show color-coded urgency indicator
- Use hard shadows in dark mode — use tonal elevation instead
