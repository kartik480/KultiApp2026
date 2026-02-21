# Kultiv — Habit Tracker

A professional, innovative habit tracker mobile app built with Flutter. Build better habits one day at a time.

## Features

- **Today view** — See and check off habits due today; track daily progress.
- **Habits list** — Manage all habits; view current and longest streaks.
- **Add / edit habits** — Name, icon, color, and frequency (daily, weekdays, or custom days).
- **Stats** — 7-day bar chart, per-habit streaks, and completion rates.
- **Persistence** — Data saved locally with SharedPreferences.
- **Theme** — Light and dark mode with a refined green/amber palette and Outfit font.

## Getting started

1. **Install Flutter**  
   [Install Flutter](https://docs.flutter.dev/get-started/install) and ensure `flutter` is on your PATH.

2. **Generate platform files (if needed)**  
   If the project was created without running `flutter create`, run once in the project root:

   ```bash
   flutter create . --org com.kultiv --project-name kultiv --platforms=android,ios
   ```

   This adds Android/iOS folders and default launcher icons.

3. **Install dependencies and run**

   ```bash
   cd c:\Kultiv
   flutter pub get
   flutter run
   ```

   Use a connected device or an Android/iOS simulator.

## Project structure

- `lib/main.dart` — App entry, theme, and `HabitRepository` provider.
- `lib/app_theme.dart` — Light/dark theme and typography.
- `lib/data/` — `HabitModel` and `HabitRepository` (persistence).
- `lib/screens/` — Today, Habits list, Add/Edit habit, Stats.

## Tech stack

- Flutter 3.x, Dart 3
- Provider (state)
- SharedPreferences (local storage)
- google_fonts (Outfit), fl_chart (stats), intl, uuid
