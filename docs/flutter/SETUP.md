# Winger Flutter App Setup & Developer Guide

## Prerequisites

- **Flutter SDK**: `>=3.3.0 <4.0.0`
- **Dart SDK**: `>=3.11.0`
- **IDE**: VS Code or Android Studio with Flutter/Dart plugins

## Step-by-Step Installation

1. **Clone Repository & Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Verify Environment Setup**:
   Copy `.env.example` to `.env.development`:
   ```bash
   cp .env.example .env.development
   ```

3. **Run Static Analysis & Tests**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Run Application**:
   ```bash
   flutter run -t lib/main.dart
   ```
