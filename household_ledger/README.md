# 나의 가계부: ChangeNotifier 상태 관리 연습 앱

할 일 앱(`setState`) 다음 단계 예제입니다.
여러 화면과 위젯이 **같은 데이터(기록 목록)** 를 함께 쓸 때 상태를 어떻게 관리하는지 연습합니다.
외부 패키지 없이 플러터 기본 기능(`ChangeNotifier`, `ListenableBuilder`)만 사용합니다.

## 기능

- **수입·지출 기록**: [기록하기] → 금액, 내용, 카테고리, 날짜 입력 → [저장]
- **한 달 요약**: 잔액, 수입 합계, 지출 합계
- **지출 분석**: 카테고리별 지출 금액과 비율 막대
- **월 이동**: 〈 2026년 10월 〉 화살표
- **삭제와 되돌리기**: 내역을 왼쪽으로 밀어서 삭제하고, 알림의 [되돌리기]로 복구

## 핵심 개념

| | 할 일 앱 | 가계부 앱 |
|---|---|---|
| 상태 위치 | 위젯 **안** (`State`) | 위젯 **밖** (`LedgerStore`) |
| 변경 알림 | `setState()` | `notifyListeners()` |
| 다시 그리는 곳 | 그 위젯 | 구독 중인 `ListenableBuilder` |

```
AddEntryScreen ── Navigator.pop(새 기록) ──▶ HomeScreen
                                              │ store.add(새 기록)
                                              ▼
                                         LedgerStore
                                              │ notifyListeners()
                                              ▼
                                      ListenableBuilder
                       ┌──────────────────┼──────────────────┐
                  SummaryCard     CategoryBreakdown      내역 목록
```

- **공유 상태와 지역 상태 구분**
  - 기록 목록과 보고 있는 달은 여러 화면이 함께 쓰는 공유 상태라서 `LedgerStore`에 둡니다.
  - 입력 중인 금액과 고른 카테고리는 입력 화면만 쓰는 지역 상태라서 그 화면의 `setState`로 관리합니다.
- **파생 데이터**: 잔액과 합계는 저장해 두지 않고 기록 목록에서 매번 계산합니다.
- **화면 간 값 전달**: 입력 화면은 저장소를 모릅니다. `Navigator.pop(context, 결과)`로 결과만 돌려줍니다.

## 소스 코드

| 파일 | 설명 |
|---|---|
| [`lib/main.dart`](lib/main.dart) | 앱 시작점. **맨 위에 앱 전체 동작 설명** |
| [`lib/models/ledger_entry.dart`](lib/models/ledger_entry.dart) | 기록 한 건, 수입/지출, 카테고리 (향상된 enum) |
| [`lib/state/ledger_store.dart`](lib/state/ledger_store.dart) | ★ 상태 저장소 (`ChangeNotifier`) |
| [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart) | 홈 화면 (`ListenableBuilder`로 구독) |
| [`lib/screens/add_entry_screen.dart`](lib/screens/add_entry_screen.dart) | 입력 화면 (`Form`, 지역 상태, 결과 반환) |
| [`lib/widgets/month_selector.dart`](lib/widgets/month_selector.dart) | 월 이동 |
| [`lib/widgets/summary_card.dart`](lib/widgets/summary_card.dart) | 잔액 / 수입 / 지출 카드 |
| [`lib/widgets/category_breakdown.dart`](lib/widgets/category_breakdown.dart) | 카테고리별 지출 막대 |
| [`lib/widgets/entry_tile.dart`](lib/widgets/entry_tile.dart) | 내역 한 줄 |
| [`lib/utils/format.dart`](lib/utils/format.dart) | `12,000원`, `10월 12일 (월)` 형식 |
| [`test/ledger_store_test.dart`](test/ledger_store_test.dart) | 저장소 계산 테스트 (화면 없이) |
| [`test/widget_test.dart`](test/widget_test.dart) | 추가 / 삭제·되돌리기 / 입력 검사 화면 테스트 |

## 실행 방법

```bash
cd household_ledger
flutter pub get
flutter run
flutter test
```

## 실험해 보기

1. `ledger_store.dart`의 `add()`에서 `notifyListeners()`를 지워 보세요. [저장]을 눌러도 홈 화면이 바뀌지 않습니다.
2. `home_screen.dart`에서 `ListenableBuilder`를 빼 보세요. 알림을 받을 위젯이 없어서 화면이 그대로입니다.
3. 앱을 다시 켜면 기록이 사라집니다. `shared_preferences` 패키지로 `LedgerStore`에 저장과 불러오기를 더해 보세요. 화면 코드는 고칠 필요가 없습니다.
