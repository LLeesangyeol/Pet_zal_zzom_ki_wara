import '../models/pet_state.dart';

class PetEngine {
  static int clamp(int x) => x.clamp(0, 100);
  static PetState applyElapsed(PetState p, DateTime now) {
    final hours = now.difference(p.lastUpdatedUtc).inHours.clamp(0, 72);
    if (hours == 0) return p;
    final checkpoint = now.difference(p.lastUpdatedUtc).inHours > 72
        ? now.toUtc()
        : p.lastUpdatedUtc.add(Duration(hours: hours));
    return evolve(p.copyWith(
        fullness: clamp(p.fullness - hours * 3),
        affection: clamp(p.affection - hours * 2),
        mood: clamp(p.mood - hours),
        energy: clamp(p.energy + hours * 2),
        lastUpdatedUtc: checkpoint));
  }

  static PetState act(PetState old, PetAction action, DateTime now) {
    final p = applyElapsed(old, now);
    final next = switch (action) {
      PetAction.feed => p.copyWith(
          fullness: clamp(p.fullness + 24),
          mood: clamp(p.mood + 5),
          actions: p.actions + 1),
      PetAction.play => p.copyWith(
          affection: clamp(p.affection + 14),
          mood: clamp(p.mood + 18),
          energy: clamp(p.energy - 12),
          fullness: clamp(p.fullness - 6),
          actions: p.actions + 1),
      PetAction.rest => p.copyWith(
          energy: clamp(p.energy + 28),
          mood: clamp(p.mood + 3),
          actions: p.actions + 1),
      PetAction.talk =>
        p.copyWith(affection: clamp(p.affection + 5), actions: p.actions + 1),
    };
    return evolve(next);
  }

  static PetState evolve(PetState p) {
    final type = p.affection < 20 && p.fullness < 25
        ? Personality.memeGoblin
        : p.affection < 35
            ? Personality.rebel
            : p.mood > 85 && p.affection > 75
                ? Personality.angel
                : p.actions >= 30 && p.mood < 50
                    ? Personality.philosopher
                    : Personality.normal;
    return p.copyWith(personality: type);
  }

  static String mockDialogue(PetState p, PetAction action) {
    if (p.personality == Personality.memeGoblin) {
      return '이 집에서 제일 지능 높은 건 와이파이 공유기임.';
    }
    if (p.personality == Personality.rebel) return '이게 최선이냐 주인아?';
    if (p.personality == Personality.angel) return '주인님 최고야! 오늘도 행복해 🥹';
    return switch (action) {
      PetAction.feed => '오 밥이다. 오늘은 살아남았다.',
      PetAction.play => '또 놀자. 근데 월급은?',
      PetAction.rest => '잘게. 깨우면 삐짐.',
      PetAction.talk => '왜 불렀어? 할 말 있으면 간식으로 해.'
    };
  }
}
