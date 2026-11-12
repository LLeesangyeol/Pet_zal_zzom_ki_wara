import 'package:flutter_test/flutter_test.dart';
import 'package:pet_exe/models/pet_state.dart';
import 'package:pet_exe/services/dialogue_bank.dart';
import 'package:pet_exe/services/inference_service.dart';

class FakeInference implements InferenceService {
  FakeInference(this.line, {this.fail = false});
  final String line;
  final bool fail;
  int calls = 0;
  @override
  Future<DialogueResult> generate(DialogueContext context,
      {Duration timeout = const Duration(seconds: 12)}) async {
    calls++;
    if (fail) throw StateError('native runtime unavailable');
    return DialogueResult(
        line: line, source: DialogueSource.qwen, latencyMs: 0);
  }
}

void main() {
  DialogueContext context(
          {Personality type = Personality.normal,
          List<String> recent = const []}) =>
      DialogueContext(
        petName: '만두',
        personality: type,
        stats: PetState.initial(DateTime.utc(2026)),
        lastAction: PetAction.talk,
        recentLines: recent,
        randomSeed: 12,
      );
  test('each personality has at least 20 unique validated original lines', () {
    for (final type in Personality.values) {
      final bank = dialogueBank[type]!;
      expect(bank.toSet().length, greaterThanOrEqualTo(20));
      for (final line in bank) {
        expect(DialogueCoordinator.valid(line), isTrue, reason: line);
      }
      final previous = bank.take(5).toList();
      expect(
          previous.contains(offlineLine(context(type: type, recent: previous))),
          isFalse);
    }
  });
  test('disabled AI never invokes runtime', () async {
    final service = FakeInference('안녕.');
    final result = await DialogueCoordinator(service).generate(context());
    expect(result.source, DialogueSource.mock);
    expect(service.calls, 0);
  });
  test('malformed output retries only once and falls back', () async {
    for (final line in [
      '{"line":"안녕"}',
      '<think>비밀</think>안녕',
      '죽어',
      'hello',
      '하' * 101,
      '하나. 둘. 셋.'
    ]) {
      final service = FakeInference(line);
      final result =
          await DialogueCoordinator(service).generate(context(), enabled: true);
      expect(result.source, DialogueSource.fallback);
      expect(service.calls, 2);
    }
  });
  test('runtime errors and exhausted deadlines fall back', () async {
    expect(
        (await DialogueCoordinator(FakeInference('', fail: true))
                .generate(context(), enabled: true))
            .source,
        DialogueSource.fallback);
    final service = FakeInference('안녕.');
    expect(
        (await DialogueCoordinator(service)
                .generate(context(), enabled: true, timeout: Duration.zero))
            .source,
        DialogueSource.fallback);
    expect(service.calls, 0);
  });
  test('validated output is accepted and recent context bounded to 5',
      () async {
    final ctx = context(recent: List.generate(10, (i) => '$i'));
    final result = await DialogueCoordinator(FakeInference('주인아 반가워.'))
        .generate(ctx, enabled: true);
    expect(result.source, DialogueSource.qwen);
    expect(ctx.recentLines.length, 5);
    expect(() => ctx.recentLines.add('no'), throwsUnsupportedError);
  });
}
