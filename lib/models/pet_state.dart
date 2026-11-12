enum PetAction { feed, play, rest, talk }

enum Personality { angel, normal, rebel, memeGoblin, philosopher }

extension PersonalityLabel on Personality {
  String get label => switch (this) {
        Personality.angel => '천사',
        Personality.normal => '평범',
        Personality.rebel => '반항아',
        Personality.memeGoblin => '밈 중독',
        Personality.philosopher => '철학자'
      };
  String get emoji => switch (this) {
        Personality.angel => '🐣',
        Personality.normal => '🐹',
        Personality.rebel => '😾',
        Personality.memeGoblin => '👹',
        Personality.philosopher => '🦉'
      };
}

class PetState {
  const PetState(
      {required this.fullness,
      required this.affection,
      required this.mood,
      required this.energy,
      required this.lastUpdatedUtc,
      required this.createdUtc,
      required this.actions,
      required this.personality});
  final int fullness, affection, mood, energy, actions;
  final DateTime lastUpdatedUtc, createdUtc;
  final Personality personality;
  int get day => (DateTime.now().toUtc().difference(createdUtc).inDays + 1)
      .clamp(1, 2147483647);
  factory PetState.initial(DateTime now) => PetState(
      fullness: 70,
      affection: 60,
      mood: 70,
      energy: 80,
      lastUpdatedUtc: now,
      createdUtc: now,
      actions: 0,
      personality: Personality.normal);
  PetState copyWith(
          {int? fullness,
          int? affection,
          int? mood,
          int? energy,
          int? actions,
          DateTime? lastUpdatedUtc,
          Personality? personality}) =>
      PetState(
          fullness: fullness ?? this.fullness,
          affection: affection ?? this.affection,
          mood: mood ?? this.mood,
          energy: energy ?? this.energy,
          actions: actions ?? this.actions,
          lastUpdatedUtc: lastUpdatedUtc ?? this.lastUpdatedUtc,
          createdUtc: createdUtc,
          personality: personality ?? this.personality);
  Map<String, dynamic> toJson() => {
        'fullness': fullness,
        'affection': affection,
        'mood': mood,
        'energy': energy,
        'actions': actions,
        'lastUpdatedUtc': lastUpdatedUtc.toIso8601String(),
        'createdUtc': createdUtc.toIso8601String(),
        'personality': personality.name
      };
  factory PetState.fromJson(Map<String, dynamic> json) => PetState(
      fullness: (json['fullness'] as int).clamp(0, 100),
      affection: (json['affection'] as int).clamp(0, 100),
      mood: (json['mood'] as int).clamp(0, 100),
      energy: (json['energy'] as int).clamp(0, 100),
      actions: (json['actions'] as int).clamp(0, 2147483647),
      lastUpdatedUtc: DateTime.parse(json['lastUpdatedUtc'] as String).toUtc(),
      createdUtc: DateTime.parse(json['createdUtc'] as String).toUtc(),
      personality: Personality.values.byName(json['personality'] as String));
}
