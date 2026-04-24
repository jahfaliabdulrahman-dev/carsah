# Project: CarSah (maintlogic)

CarSah is a smart vehicle maintenance tracker built with Flutter.

## Tech Stack
- **Framework**: Flutter 3.41+
- **State Management**: Riverpod (Standard AsyncNotifier)
- **Database**: Isar 3.1 (local-first)
- **Charts**: fl_chart
- **Icons**: font_awesome_flutter
- **Language**: Bilingual (Arabic/English)

## Key Commands
- `flutter pub get`: Install dependencies.
- `flutter run`: Run the application.
- `flutter build apk --release`: Build a release APK.

## Architecture
Clean Architecture:
- `lib/core`: Constants, utilities.
- `lib/data`: Models, repositories, datasources.
- `lib/domain`: Abstract repository contracts.
- `lib/presentation`: UI, providers, pages.

## AI Persona / Behavior
- Adhere to Clean Architecture principles.
- Use Riverpod for state management.
- Ensure all new features are bilingual (AR/EN).
- Maintain "Zero technical debt" standards.
- Respect "Fat-Finger Protection" and "Smart Deletion with Rollback Engine" logic.
