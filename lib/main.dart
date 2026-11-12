import 'package:flutter/material.dart';
import 'models/pet_state.dart';
import 'services/pet_repository.dart';
import 'services/pet_controller.dart';
import 'widgets/pixel_pet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = PetRepository();
  runApp(PetApp(repository: repository, initialPet: await repository.load()));
}

class PetApp extends StatelessWidget {
  const PetApp({super.key, required this.repository, required this.initialPet});
  final PetRepository repository;
  final PetState initialPet;
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PET.exe',
        theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFFB48A6B),
            scaffoldBackgroundColor: const Color(0xFFFFF8EB)),
        home: PetHome(repository: repository, initialPet: initialPet),
      );
}

class PetHome extends StatefulWidget {
  const PetHome(
      {super.key, required this.repository, required this.initialPet});
  final PetRepository repository;
  final PetState initialPet;
  @override
  State<PetHome> createState() => _PetHomeState();
}

class _PetHomeState extends State<PetHome> with WidgetsBindingObserver {
  late final PetController controller;
  bool ready = false;
  final chatInput = TextEditingController();
  bool testMode = false;
  void sendChat() {
    controller.chat(chatInput.text);
    chatInput.clear();
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = PetController(widget.repository, widget.initialPet);
    controller.initialize().then((_) {
      if (mounted) setState(() => ready = true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && ready) controller.resume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    chatInput.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> reset() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('새로 시작할까요?'),
              content: const Text('이름, 능력치와 대화 기록이 모두 삭제됩니다.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('초기화'))
              ],
            ));
    if (confirmed == true) await controller.reset();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!ready) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (controller.name.isEmpty) {
          return _Adoption(onAdopt: controller.adopt);
        }
        final pet = controller.pet;
        return Scaffold(
          appBar: AppBar(title: const Text('PET.exe'), actions: [
            IconButton(
                tooltip: '대화 기록',
                icon: const Icon(Icons.history),
                onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SafeArea(
                          child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .65,
                        child: controller.history.isEmpty
                            ? const Center(child: Text('첫 대화를 기다리는 중이에요.'))
                            : ListView(
                                children: [
                                  const ListTile(title: Text('최근 대화 · 최대 30개')),
                                  ...controller.history.map(
                                      (line) => ListTile(title: Text(line)))
                                ],
                              ),
                      )),
                    )),
            IconButton(
                tooltip: '로컬 데이터 초기화',
                onPressed: reset,
                icon: const Icon(Icons.restart_alt)),
          ]),
          body: SafeArea(
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(
                                '${controller.name} · DAY ${pet.day} · ${pet.personality.label}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 20),
                            Semantics(
                                label:
                                    '${pet.personality.label} 모습의 ${controller.name}',
                                child: Container(
                                    height: 210,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFFFE8C5),
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    alignment: Alignment.center,
                                    child: ExcludeSemantics(
                                        child: PixelPet(
                                            personality: pet.personality,
                                            action: controller.lastAction,
                                            actions: pet.actions)))),
                            const SizedBox(height: 12),
                            Semantics(
                                liveRegion: true,
                                child: Card(
                                    child: Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Text(controller.message,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 18))))),
                            const SizedBox(height: 12),
                            SwitchListTile(title: const Text('테스트: 능력치 조절'), subtitle: const Text('변경한 수치와 성격이 저장됩니다.'), value: testMode, onChanged: (v) => setState(() => testMode = v)),
                            _meter('포만감', pet.fullness),
                            _meter('애정', pet.affection),
                            _meter('기분', pet.mood),
                            _meter('에너지', pet.energy),
                            const SizedBox(height: 18),
                            Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (final entry in {
                                    PetAction.feed: '밥 주기',
                                    PetAction.play: '놀아주기',
                                    PetAction.rest: '재우기',
                                    PetAction.talk: '말 걸기'
                                  }.entries)
                                    FilledButton(
                                        style: FilledButton.styleFrom(
                                            minimumSize: const Size(96, 48)),
                                        onPressed: () =>
                                            controller.act(entry.key),
                                        child: Text(entry.value)),
                                ]),
                            const SizedBox(height: 16),
                            const Text('펫과 채팅 · 오프라인 반응'),
                            ...controller.history.take(4).toList().reversed.map((line) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(line)))),
                            TextField(controller: chatInput, maxLength: 200, textInputAction: TextInputAction.send,
                              decoration: const InputDecoration(labelText: '펫에게 메시지 보내기', hintText: '안녕! 오늘 기분 어때?'), onSubmitted: (_) => sendChat()),
                            FilledButton.icon(onPressed: sendChat, icon: const Icon(Icons.send), label: const Text('보내기')),
                            if (controller.saveError != null)
                              Text(controller.saveError!,
                                  semanticsLabel: controller.saveError),
                            const SizedBox(height: 20),
                            const Text('인터넷 없이 함께 살아요 · 현재 대사는 오프라인 대사입니다.',
                                textAlign: TextAlign.center),
                          ])))),
        );
      });
  Widget _meter(String label, int value) => testMode ? Column(children: [
    Text('$label $value / 100'),
    Slider(value: value.toDouble(), min: 0, max: 100, divisions: 100, label: '$value',
      semanticFormatterCallback: (v) => '$label ${v.round()}',
      onChanged: (v) => controller.setTestStat(label, v.round())),
  ]) : Semantics(
      label: '$label $value / 100',
      child: ExcludeSemantics(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                SizedBox(width: 64, child: Text(label)),
                Expanded(
                    child: LinearProgressIndicator(
                        value: value / 100,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 10),
                Text('$value')
              ]))));
}

class _Adoption extends StatefulWidget {
  const _Adoption({required this.onAdopt});
  final Future<void> Function(String) onAdopt;
  @override
  State<_Adoption> createState() => _AdoptionState();
}

class _AdoptionState extends State<_Adoption> {
  final input = TextEditingController();
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: Center(
                  child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Text('주인 잘못 만난 죄',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text(
                  '밥을 주고, 놀고, 쉬어 주세요. 돌보는 방식에 따라 성격이 달라져요.\n자리를 비우면 최대 72시간만큼 상태가 변해요.\n게임은 인터넷 없이 작동하고 데이터는 이 기기에 저장돼요. AI 모델은 선택 사항이며 자동으로 다운로드하지 않아요.'),
              const SizedBox(height: 24),
              TextField(
                  controller: input,
                  maxLength: 12,
                  decoration: const InputDecoration(labelText: '반려동물 이름'),
                  onChanged: (_) => setState(() {})),
              FilledButton(
                  onPressed: input.text.trim().isEmpty
                      ? null
                      : () => widget.onAdopt(input.text),
                  child: const Text('함께 살기')),
            ]),
      ))));
}
