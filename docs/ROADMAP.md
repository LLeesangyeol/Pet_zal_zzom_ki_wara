# Implementation milestones
## M0 Bootstrap (existing starter)
Generate android/ios directories; dependencies; analyze/test/run; document environment limitations. Acceptance: app opens, four actions update stats, persistence survives restart.
## M1 Gameplay quality
Extract controller/state management; fix elapsed-time reconciliation and saving on initial resume; deterministic personality/evolution; pet naming; tutorial; event history; reset; full unit/widget tests. Acceptance: 100% stat bounds, app restart and offline time tested.
## M2 Pixel character
Use original pixel art sprites (or temporary programmatic pixel art), 5 personality variants, idle/blink/eat/play/sleep animations, expression bubbles, accessible UI. Acceptance: smooth on representative midrange device; no unlicensed assets.
## M3 Dialogue interface
InferenceService, MockInferenceService, DialogueCoordinator, personality prompt templates, output validation, fallback bank (>=20 unique lines per personality), repetition avoidance. Acceptance: game works with AI disabled; malformed AI output safe.
## M4 On-device Qwen proof of concept
Evaluate and pin compatible runtime, verify Qwen3 1.7B GGUF Q4, test Android arm64 and iOS arm64 real devices, measure speed/RAM/battery; optional model download with user consent. Acceptance: streamed Korean response on BOTH OSes, no backend; otherwise report blocker and keep mock mode.
## M5 Content / virality
Seeded mutations, unlockable collection, local dialogue history, original meme share card, sound/haptics settings, safe content moderation. Acceptance: shareable image works offline, no external copyrighted assets.
## M6 Release readiness
Crash handling, performance tuning, accessibility, privacy policy, permissions audit, app icons/splash, Android AAB, iOS archive, TestFlight/internal test. Acceptance: no blocking defects, license compliance and release checklist complete.

## Execution rules
Complete one milestone at a time, report files changed/tests/build and blockers. Do not skip real-device AI validation. Do not call a stub a completed AI integration.
