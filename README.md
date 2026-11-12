# PET.exe — 주인 잘못 만난 죄
Flutter Android+iOS offline-first comedic AI virtual pet. The starter app is **working-rule-engine scaffolding, NOT an integrated Qwen model**. Codex should implement milestones, test on devices, and integrate Qwen only after validating inference/runtime and licenses.

## Quick start
1. Install Flutter stable and Android Studio. For iOS build, macOS + Xcode + Apple signing are required.
2. Unzip, open folder in Codex/IDE.
3. Run `flutter create --platforms=android,ios .` to generate missing native platform projects. If prompted, retain existing `lib/`, `test/`, `pubspec.yaml`.
4. Run `flutter pub get && flutter analyze && flutter test && flutter run`.
5. Give Codex the prompt in `CODEX_START_PROMPT.md`.

## Contents
- `AGENTS.md`: persistent Codex instructions
- `CODEX_START_PROMPT.md`: paste into Codex
- `docs/PRODUCT.md`: product spec, mechanics, UX
- `docs/ARCHITECTURE.md`: runtime/AI contract and mobile constraints
- `docs/ROADMAP.md`: milestones and acceptance criteria
- `docs/CONTENT.md`: personality, dialogue and safety
- `lib/`: runnable Flutter MVP UI with deterministic pet logic, local persistence, mock dialogue
- `test/`: initial game logic tests

## Important
- iOS/Android binaries and model weights are NOT included.
- Device performance, compatibility and exact inference plugin are not yet verified.
- `shared_preferences` is used only for the initial MVP; migrate to SQLite/Drift if structured event logs grow.

## Current development status (2026-11-12)

Gameplay controller, naming/tutorial, local history/reset, fractional-hour offline reconciliation, five original pixel personalities, action animation and a validated mock/fallback dialogue pipeline are implemented. All gameplay and 100 curated Korean lines work without a model. Qwen native inference is not integrated.

Android/iOS native projects are generated. Android debug build output: `build/app/outputs/flutter-apk/app-debug.apk`. On this Windows host run `flutter run -d emulator-5554` after starting an Android emulator. iOS requires macOS/Xcode. Release signing and store deployment are not configured.

See [development report](docs/DEVELOPMENT_REPORT.md) for test results, changed files and milestone acceptance gaps, and [AI integration evaluation](docs/AI_INTEGRATION.md) for runtime sources, blockers and the opt-in model delivery design.
