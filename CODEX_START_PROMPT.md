너는 PET.exe 프로젝트의 수석 Flutter/온디바이스 AI 엔지니어다.

먼저 AGENTS.md, README.md, docs/PRODUCT.md, docs/ARCHITECTURE.md, docs/ROADMAP.md, docs/CONTENT.md를 모두 읽어라. 현재 프로젝트는 Flutter 기본 UI와 룰 기반 대사 엔진이 있는 스캐폴드이며, Qwen이 연결된 상태가 아니다.

목표: Flutter 단일 코드베이스로 Android+iOS에서 실행되는 한국어 병맛 AI 반려동물 육성 앱 개발. 게임 로직은 결정적이고 오프라인이어야 하며, Qwen3 1.7B는 오직 캐릭터 대사/반응 생성에 사용한다. 캐릭터는 잘 키우면 귀여워지고, 방치하면 반항·밈 중독·철학자 등으로 진화한다. 픽셀아트, 애니메이션, 공유 카드, 성격별 드립을 추가한다.

즉시 수행:
1) 환경을 확인하고 Flutter 플랫폼 프로젝트를 생성한다.
2) `flutter pub get`, `flutter analyze`, `flutter test`를 실행하고 문제를 수정한다.
3) ROADMAP의 M1부터 순서대로 구현한다. 매 단계 작동하는 빌드를 유지한다.
4) AI 통합 전에는 InferenceService 인터페이스와 MockInferenceService를 먼저 만든다.
5) 실제 llama.cpp 또는 검증된 Flutter 연동 패키지의 최신 호환성, iOS/Android 네이티브 빌드 지원, GGUF Qwen3 1.7B 지원, 라이선스를 확인한 뒤 구현한다. 검증되지 않으면 구현을 꾸며내지 말고 blocker로 보고한다.
6) 모델 다운로드/앱 번들 정책은 선택 가능하게 만들고, 초기에는 사용자 동의 후 다운로드 방식으로 설계한다. 다운로드 중단/재시도/무결성 확인/용량 안내를 넣는다.
7) 테스트, 빌드 결과, 변경 파일, 다음 단계, 남은 위험을 매 마일스톤 보고한다.

가능한 작업은 질문 없이 진행하되, 모델 라이선스 수락, 유료 서비스, 스토어 계정, 저작권 콘텐츠 사용, 외부 배포 등 승인이 필요한 작업은 먼저 물어라.
