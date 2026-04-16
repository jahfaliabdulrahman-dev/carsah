# CarSah — Vehicle Maintenance Tracker

**TestSprite Hackathon Season 2 Submission**

## What We Built

CarSah is a bilingual (Arabic/English) vehicle maintenance tracking app built with Flutter. It helps car owners track maintenance schedules, predict costs, and never miss a service.

### Key Features
- **Vehicle Management** — Add, edit, and track multiple vehicles
- **Maintenance Scheduling** — Service tasks with mileage/time intervals
- **Cost Prediction** — Z-Score based cost trend analysis
- **Bilingual** — Full Arabic (RTL) and English support, zero hardcoded strings
- **Offline-First** — Local Isar database, no cloud dependency
- **Clean Architecture** — Domain/Data/Presentation separation with Riverpod

### Tech Stack
- **Flutter** (Dart)
- **Isar** — Local NoSQL database
- **Riverpod** — State management
- **fl_chart** — Cost trend visualizations
- **Google Fonts** — Typography

### Architecture
```
lib/
├── core/          — Constants, utilities (cost predictor, Z-score)
├── data/          — Isar models, repositories, data sources
├── domain/        — Abstract repository interfaces
├── presentation/  — Pages, providers, widgets
└── main.dart      — App entry point
```

## How We Used TestSprite

1. **Round 1**: TestSprite MCP auto-generated test cases covering core functionality
2. **Bug Fix**: Fixed issues discovered during Round 1 testing
3. **Round 2**: Re-ran tests to verify improvements

See `testsprite_tests/` for all generated test cases.

## Links
- **GitHub:** https://github.com/jahfaliabdulrahman-dev/carsah
- **Discord:** TestSprite Hackathon Season 2
