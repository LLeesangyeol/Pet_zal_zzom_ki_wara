# Product requirements (MVP -> v1)
## Pitch
PET.exe — 주인 잘못 만난 죄. Korean-first, absurdist offline virtual pet that evolves in appearance and personality based on care. Not a general-purpose assistant.
## Audience / tone
Teen+ broad audience, dry Korean internet-style jokes, affectionate roast of player choices; avoid harassment/hate and overly repetitive profanity. Original meme-inspired jokes rather than copying existing memes/images.
## Core loop
Open -> see pet and status -> feed/play/rest/talk -> stats update instantly -> pet reacts -> close -> elapsed-time decay on next launch -> evolution thresholds -> optional shareable dialogue card.
## Stats
Fullness, affection, mood, energy in [0,100]. Persist lastUpdatedUtc. Decay on elapsed whole hours, capped to 72 hours per reconciliation to avoid absurd punishment; do not advance while app in foreground twice. Feed +24 fullness/+5 mood; play +14 affection/+18 mood/-12 energy/-6 fullness; rest +28 energy/+3 mood; talk +5 affection. Tune through playtesting.
## Personality branches
normal; angel (mood >85, affection >75); rebel (affection <35); memeGoblin (affection <20 and fullness <25); philosopher (30+ actions and mood <50). Branch ordering matters. Future evolution can add seed-based mutations, persistent trait scores and pixel sprite variants.
## UX screens
Home: pet sprite, emotion animation, bubble, meters, actions, day/personality. History: last 30 dialogue/events. Collection: unlocked evolution variants. Settings: sound, haptics, AI on/off, download size/status, delete local data, privacy. Share: image card with original generated text and original sprite (no third-party meme image).
## First-run
Name pet; choose starter appearance; explain offline AI model is optional download and approximate device storage. Without model, all gameplay works using curated dialogue.
## Failure states
No model, low storage, inference timeout, model load failure, app backgrounded mid-inference, locale changes, clock rollback, corrupt saves. All preserve game and fallback dialogue.
## Accessibility
Touch targets >=44 logical px, text scaling, contrast, motion reduction, screen reader labels.
## Non-goals for MVP
Accounts, cloud sync, multiplayer, purchases, scraped internet images, live meme feed, push notifications, generative images.
## Metrics (local manual testing)
Cold start, action latency, crash-free sessions, average dialogue latency, memory high-water mark, battery drain over 10 minutes, return sessions.
