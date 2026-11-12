# M4 AI integration evaluation / delivery design

Research date: 2026-11-12 KST. No model weights downloaded, no model license accepted, no native inference dependency added. The running app uses curated offline dialogue only.

## Primary-source findings

- Official model repository labels Qwen3-1.7B-GGUF Apache-2.0 and supplies a license file. Its model page documents llama.cpp usage. This confirms the model family/format path, not this app's Q4 mobile performance. Exact immutable revision, Q4 filename, byte length and SHA-256 are not verified; no URL/hash is hardcoded.
  - https://huggingface.co/Qwen/Qwen3-1.7B-GGUF/tree/main
  - https://huggingface.co/Qwen/Qwen3-1.7B-GGUF/blob/main/LICENSE
- llama.cpp upstream is MIT. Official Android documentation describes Android builds. A C ABI adapter would need one pinned upstream revision and matching Dart bindings, Android NDK/CMake and iOS arm64/Xcode builds. We have not built this native inference runtime.
  - https://github.com/ggml-org/llama.cpp
  - https://github.com/ggml-org/llama.cpp/blob/master/docs/android.md
- llama_cpp_dart: source page reports stable 0.2.2 and prerelease 0.9.0-dev.12; MIT; Android/iOS tagged, managed isolate wrapper available, compiled llama.cpp library required. Platform badges are not evidence of compatible Qwen3 arm64 native binaries.
  - https://pub.dev/packages/llama_cpp_dart
  - https://pub.dev/packages/llama_cpp_dart/license
- llm_llamacpp: source page reports 0.7.0; Android/iOS, streaming and isolates advertised. Documentation describes ABI-fingerprinted native assets and warns published packages rely on release prebuilts when vendored source is absent. License page is MIT but its fetched metadata showed an older 0.3.2; exact archive/license/native assets need direct revision checks before selection. Qwen3-1.7B Q4 on both mobile OSes is not demonstrated by these docs.
  - https://pub.dev/packages/llm_llamacpp
  - https://pub.dev/packages/llm_llamacpp/license

Decision: no runtime pinned until source archive, license notices, arm64 native asset availability and two-device smoke tests pass. No fabricated OnDeviceQwenService stub.

## Optional model delivery design (not implemented)

Policy enum: disabled (default), downloadWithConsent, bundled (future opt-in build configuration). Core gameplay has no model dependency. Bundling stays unavailable until redistribution notices, store size policy and user choice are resolved.

Verified ModelManifest must contain immutable source revision, HTTPS URL, exact bytes, SHA-256, quantization, minimum supported runtime revision, model license link and required notices. Missing fields disable download; never guess URLs or hashes.

State machine: notInstalled -> awaitingConsent -> checkingStorage -> downloading -> paused -> verifying -> ready; failed allows retry; deletion returns to notInstalled. Consent shows exact download size, estimated temporary disk budget and that runtime RAM exceeds the file size. Offer Wi-Fi preference and cancel. Native adapter reports available disk space before starting.

Write to app-private .part file. Persist manifest revision, ETag, received length and consent. Pause/background cancels active requests and checkpoints bytes. Resume uses Range + If-Range; require matching Content-Range, ETag and manifest. If server ignores Range or changes object, restart safely. Retry transient errors with bounded backoff and a manual retry control. Stream SHA-256 verification off the UI thread, confirm exact byte count, then atomic same-volume rename. Only ready/verified files may reach inference. Integrity mismatch discards the partial artifact. Removal cancels download, unloads runtime, deletes model and download metadata. Reset must also delete model data once delivery exists.

Runtime: background isolate/native worker, bounded context, Korean non-thinking generation template, capped tokens, one active request, cancellable native generation. Timeout/background/low-memory cancels generation and selects curated fallback. Model output has no PetController/Repository write capability. Never merely hide a late response while allowing unlimited native jobs to accumulate.

## Benchmarks required before M4 acceptance

Android arm64 and iOS arm64 physical devices: cold/warm load, Korean first-token and total latency, tokens/sec, RAM peak, 10-minute thermal/battery trend, background cancellation, low storage, corrupt file, airplane-mode response, retry/resume and model removal. Record exact OS, device, model hash, runtime commit and build mode. No measurements are available yet.
