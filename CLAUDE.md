# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter run -d <id>      # Run on specific device
flutter analyze          # Run Dart analyzer (linting via flutter_lints)
flutter test             # Run tests
flutter build apk        # Build Android
flutter build ipa        # Build iOS
```

## Architecture

**Layered feature-based structure** under `lib/`:

- `main.dart` — Entry point. Initializes SharedPreferences, runs legacy key migration, launches `IntroScreen`.
- `core/` — Shared infrastructure:
  - `config/` — `StageConfig` (maps diagnosis codes to day counts per stage), `DemoMode` (demo day skipping, paywall bypass)
  - `storage_keys.dart` — SharedPreferences key constants (`dx_code`, `current_day`, `current_stage`)
  - `utils/` — `StorageHelper` (reset diagnosis, advance day), `ProgressHelper` (stage progress calculation)
  - `theme/` — `AppTheme` with Material 3, mint green primary (#10B981)
  - `extensions/` — `context.colorScheme`, `context.textTheme` shortcuts
  - `ui/` — `SoftCard` reusable widget
- `features/diagnosis/` — Diagnosis feature module:
  - `data/` — Question trees (`shoulderQuestions`, `neckQuestions`), program exercise maps
  - `body_part.dart` — Enum for shoulder/neck/back
  - Diagnosis screens
- `screens/` — Main navigation screens (intro, login, home, program, result, paywall, stage complete)
- `red_flag/` — Medical warning screens per body part

## Navigation Flow

```
IntroScreen → LoginScreen → DiagnosisSelectScreen → RedFlag → DiagnosisScreen
→ ResultScreen → HomeScreen ↔ ProgramScreen → PaywallScreen (stage 2 unlock)
```

## Diagnosis Data

Question trees in `features/diagnosis/data/` use a map format:
```dart
{'Q01': {'title': ..., 'question': ..., 'options': [{'text': ..., 'next': 'Q02' or 'DX_CODE'}]}}
```
Diagnosis codes (50+) follow pattern: `DX_FROZEN_1`, `DX_NECK_1`, `DX_RCT_1`, etc. Programs map `diagnosisCode → stage → List<Exercise>`.

---

## Rekit Flutter Project Master Prompt [v6 - Noah's Ark]

### 1. Project Identity

- App Name: Rekit (Recover. Rebuild. Rekit.)
- Concept: Diagnosis-based personalized rehab (Shoulder focused for MVP)
- Tone: Daily Rehab (Not Medical)

### 2. Critical Technical Principles (DO NOT VIOLATE)

- **Stage System:** diagnosisCode -> stage -> day
- **Data Storage:** Use SharedPreferences for (diagnosisCode, stage, day) ONLY.
- **NO PROGRAM STORAGE:** Never save the full program/routine list to local storage. Always calculate from programs[dx]![stage].
- **State Management:** Pure Flutter (No Provider/Riverpod/Bloc). Use StatefulWidget or local state.
- **Navigation:** No pushReplacement (except for specific cases). Use pushAndRemoveUntil only for ResultScreen.

### 3. Sprint 6 Goals (Home Hub)

- **RootScreen:** Persistent BottomNavigationBar (Home, History, My - Placeholders).
- **HomeScreen:** Redesign as "Exercise Hub".
- **Today Program Card:** Large Hero Card at top. Tapping it leads to ProgramScreen.
- **Secondary CTA:** "Get New Recommendation" button. Logic: Clear (diagnosisCode, stage, day) from SharedPreferences and navigate to IntroScreen.
- **Discovery:** Hardcoded "Recommended Exercise" cards (UI only).

### 4. UI & Theme Rules

- Light Mode Only.
- **Theme Usage:** Use context.textTheme and context.colorScheme.
- No direct 'Colors.xxx' or 'withOpacity'. Use 'withValues'.
- WidgetsFlutterBinding.ensureInitialized() in main.dart is mandatory.

### 5. Senior Developer Rules for Claude

- **ALWAYS:** Say "I will git commit first" before any code changes.
- **ALWAYS:** Check for broken references in other files (main.dart, root_screen.dart) after refactoring.
- Keep business logic outside of build() methods.
- Prefer StatelessWidget where possible.
