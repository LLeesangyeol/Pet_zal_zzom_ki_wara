import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_exe/models/pet_state.dart';
import 'package:pet_exe/services/pet_controller.dart';
import 'package:pet_exe/services/pet_engine.dart';
import 'package:pet_exe/services/pet_repository.dart';

void main() {
  final start = DateTime.utc(2026, 11, 12);
  test('fractional hours survive frequent actions and repeated resume', () {
    var pet = PetState.initial(start);
    pet = PetEngine.act(
        pet, PetAction.talk, start.add(const Duration(minutes: 40)));
    pet = PetEngine.act(
        pet, PetAction.talk, start.add(const Duration(minutes: 80)));
    expect(pet.fullness, 67);
    expect(pet.lastUpdatedUtc, start.add(const Duration(hours: 1)));
    expect(
        PetEngine.applyElapsed(pet, start.add(const Duration(minutes: 80)))
            .toJson(),
        pet.toJson());
  });
  test('rollback cannot grant time and absence is capped', () {
    final pet = PetState.initial(start);
    expect(
        PetEngine.applyElapsed(pet, start.subtract(const Duration(days: 1)))
            .toJson(),
        pet.toJson());
    final future = start.add(const Duration(days: 100));
    final decayed = PetEngine.applyElapsed(pet, future);
    expect(decayed.affection, 0);
    expect(decayed.lastUpdatedUtc, future);
    expect(PetEngine.applyElapsed(decayed, future).toJson(), decayed.toJson());
  });
  test('all stats stay bounded across long deterministic action sequence', () {
    var pet = PetState.initial(start);
    for (var i = 0; i < 2000; i++) {
      pet = PetEngine.act(
          pet, PetAction.values[i % 4], start.add(Duration(minutes: i * 31)));
      for (final stat in [pet.fullness, pet.affection, pet.mood, pet.energy]) {
        expect(stat, inInclusiveRange(0, 100));
      }
    }
  });
  test('evolution priority and strict boundaries', () {
    final pet = PetState.initial(start);
    Personality evolve(PetState state) =>
        PetEngine.act(state, PetAction.rest, start).personality;
    expect(evolve(pet.copyWith(affection: 19, fullness: 24)),
        Personality.memeGoblin);
    expect(
        evolve(pet.copyWith(affection: 20, fullness: 24)), Personality.rebel);
    expect(evolve(pet.copyWith(affection: 35)), Personality.normal);
    expect(evolve(pet.copyWith(affection: 76, mood: 83)), Personality.angel);
    expect(evolve(pet.copyWith(affection: 75, mood: 83)), Personality.normal);
    expect(
        evolve(pet.copyWith(actions: 29, mood: 46)), Personality.philosopher);
  });
  test('resume immediately persists decay, rapid saves retain final action',
      () async {
    SharedPreferences.setMockInitialValues(
        {PetRepository.key: jsonEncode(PetState.initial(start).toJson())});
    final repository = PetRepository();
    final controller = PetController(repository, await repository.load(),
        clock: () => start.add(const Duration(hours: 3)));
    await controller.initialize();
    expect((await repository.load()).fullness, 61);
    await controller.adopt('만두');
    final writes = [
      for (var i = 0; i < 50; i++) controller.act(PetAction.talk)
    ];
    await Future.wait(writes);
    expect((await repository.load()).actions, 50);
    expect((await repository.loadProfile()).history, hasLength(30));
    await controller.reset();
    expect((await repository.loadProfile()).name, '');
    expect((await repository.load()).actions, 0);
  });
  test('corrupt saves recover; legacy out of bounds stats clamp', () async {
    SharedPreferences.setMockInitialValues(
        {PetRepository.snapshotKey: 'broken'});
    expect((await PetRepository().load()).fullness, 70);
    final json = PetState.initial(start).toJson()..['energy'] = 10000;
    expect(PetState.fromJson(json).energy, 100);
    expect(PetState.fromJson(PetState.initial(start).toJson()).toJson(),
        PetState.initial(start).toJson());
  });
}
