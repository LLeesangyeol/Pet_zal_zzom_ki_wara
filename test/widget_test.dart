import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_exe/main.dart';
import 'package:pet_exe/models/pet_state.dart';
import 'package:pet_exe/services/pet_repository.dart';

void main() {
  testWidgets('adopt, feed, history and restart preserve the pet',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = PetRepository();
    await tester.pumpWidget(
        PetApp(repository: repository, initialPet: await repository.load()));
    await tester.pumpAndSettle();
    expect(find.text('함께 살기'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '만두');
    await tester.pump();
    await tester.tap(find.text('함께 살기'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('밥 주기'), 200);
    await tester.tap(find.text('밥 주기'));
    await tester.pumpAndSettle();
    expect((await repository.load()).fullness, 94);
    for (final label in ['놀아주기', '재우기', '말 걸기']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    final saved = await repository.load();
    expect(saved.actions, 4);
    expect(saved.fullness, 88);
    expect(saved.energy, 96);
    expect(saved.affection, 79);
    expect((await repository.loadProfile()).history, hasLength(4));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
        PetApp(repository: repository, initialPet: await repository.load()));
    await tester.pumpAndSettle();
    expect(find.textContaining('만두 · DAY'), findsOneWidget);
    expect(find.text('88'), findsOneWidget);
    await tester.tap(find.byTooltip('로컬 데이터 초기화'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('초기화'));
    await tester.pumpAndSettle();
    expect(find.text('함께 살기'), findsOneWidget);
    expect((await repository.loadProfile()).history, isEmpty);
  });
  testWidgets('large text keeps adoption scrollable', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: PetHome(
          repository: PetRepository(),
          initialPet: PetState.initial(DateTime.now().toUtc())),
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}


