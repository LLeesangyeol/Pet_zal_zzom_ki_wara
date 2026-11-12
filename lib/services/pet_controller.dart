import 'package:flutter/foundation.dart';
import '../models/pet_state.dart';
import 'pet_engine.dart';
import 'pet_repository.dart';
import 'inference_service.dart';

/// Owns game transitions. Writes are serialized so rapid taps cannot reorder saves.
class PetController extends ChangeNotifier {
  PetController(this.repository, this.pet, {DateTime Function()? clock})
      : clock = clock ?? (() => DateTime.now().toUtc());
  final DialogueCoordinator dialogue =
      DialogueCoordinator(MockInferenceService());
  int _epoch = 0;
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  final PetRepository repository;
  final DateTime Function() clock;
  PetState pet;
  PetAction? lastAction;
  String name = '';
  List<String> history = [];
  String message = '주인아. 나 밥은 주는 거지?';
  String? saveError;
  Future<void> _writes = Future.value();

  Future<void> initialize() async {
    final profile = await repository.loadProfile();
    name = profile.name;
    history = profile.history;
    await resume();
  }

  Future<void> resume() {
    pet = PetEngine.applyElapsed(pet, clock());
    notifyListeners();
    return _save();
  }

  Future<void> adopt(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty || cleaned.runes.length > 12) {
      throw ArgumentError('이름은 1~12자로 입력해 주세요.');
    }
    name = cleaned;
    notifyListeners();
    return _save();
  }

  Future<void> act(PetAction action) async {
    pet = PetEngine.act(pet, action, clock());
    lastAction = action;
    final epoch = _epoch;
    final count = pet.actions;
    final context = DialogueContext(
        petName: name,
        personality: pet.personality,
        stats: pet,
        lastAction: action,
        recentLines: history,
        randomSeed: count);
    notifyListeners();
    await _save();
    final result = await dialogue.generate(context);
    if (epoch != _epoch) return;
    if (count == pet.actions) message = result.line;
    history = [result.line, ...history].take(30).toList();
    notifyListeners();
    return _save();
  }

  Future<void> setTestStat(String stat, int value) {
    final v = value.clamp(0, 100);
    pet = PetEngine.evolve(switch (stat) {
      '포만감' => pet.copyWith(fullness: v),
      '애정' => pet.copyWith(affection: v),
      '기분' => pet.copyWith(mood: v),
      '에너지' => pet.copyWith(energy: v),
      _ => throw ArgumentError('Unknown stat'),
    });
    notifyListeners();
    return _save();
  }

  Future<void> chat(String input) async {
    final text = input.trim();
    if (text.isEmpty || text.runes.length > 200) return;
    pet = PetEngine.act(pet, PetAction.talk, clock());
    lastAction = PetAction.talk;
    final tone = switch (pet.personality) {
      Personality.angel => '주인님, ',
      Personality.rebel => '야 주인, ',
      Personality.memeGoblin => '주인 접속 확인. ',
      Personality.philosopher => '생각해 보니, ',
      Personality.normal => '주인아, ',
    };
    final reply = text.contains('안녕') ? '반가워! 오늘도 같이 놀자.'
      : RegExp('밥|배고|간식').hasMatch(text) ? '밥 얘기하니까 귀가 번쩍 뜨이네. 밥 주기 버튼도 잊지 마.'
      : RegExp('자자|잘 자|졸려|잠').hasMatch(text) ? '낮잠 동아리에 온 걸 환영해. 재우기를 누르면 더 푹 쉴게.'
      : RegExp('사랑|좋아|귀여').hasMatch(text) ? '그 말 저장했어. 간식과 함께 오래 기억할게.'
      : RegExp('놀자|놀아').hasMatch(text) ? '좋아! 놀아주기를 누르면 준비 운동부터 시작이야.'
      : RegExp('기분|어때').hasMatch(text) ? '지금 기분은 ${pet.mood}점이야. 내 표정에도 써 있어.'
      : offlineLine(DialogueContext(petName: name, personality: pet.personality, stats: pet,
          lastAction: PetAction.talk, recentLines: history, randomSeed: pet.actions));
    message = '$tone$reply';
    history = ['나: $text\n$name: $message', ...history].take(30).toList();
    notifyListeners();
    await _save();
  }

  Future<void> reset() {
    _epoch++;
    pet = PetState.initial(clock());
    name = '';
    lastAction = null;
    history = [];
    message = '새로운 인생. 이번 주인은 어떨까?';
    notifyListeners();
    return _save();
  }

  Future<void> _save() {
    final snapshot = pet;
    final profile = PetProfile(name, List.of(history));
    _writes = _writes.then((_) async {
      try {
        await repository.saveSnapshot(snapshot, profile);
        saveError = null;
      } catch (_) {
        saveError = '저장하지 못했어요. 다음 행동에서 다시 시도합니다.';
      }
      notifyListeners();
    });
    return _writes;
  }
}
