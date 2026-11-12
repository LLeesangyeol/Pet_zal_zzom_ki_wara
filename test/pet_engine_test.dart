import 'package:flutter_test/flutter_test.dart';
import 'package:pet_exe/models/pet_state.dart';
import 'package:pet_exe/services/pet_engine.dart';

void main() {
  test('feeding increases fullness without exceeding 100', () {
    final now = DateTime.utc(2026, 11, 12);
    final pet = PetState.initial(now).copyWith(fullness: 95);
    expect(PetEngine.act(pet, PetAction.feed, now).fullness, 100);
  });
  test('offline time reduces fullness', () {
    final now = DateTime.utc(2026, 11, 12);
    expect(
        PetEngine.applyElapsed(
                PetState.initial(now), now.add(const Duration(hours: 3)))
            .fullness,
        61);
  });
}
