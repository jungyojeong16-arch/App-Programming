// =============================================================================
//  state/ledger_store.dart - ★ 앱의 상태 저장소 (ChangeNotifier)
// =============================================================================
//
//  ■ 이 파일이 가계부 앱의 "심장"입니다.
//    앱에서 바뀌는 데이터(상태)는 이 클래스 안의 두 가지뿐입니다.
//      1) _entries : 지금까지의 모든 기록
//      2) _month   : 지금 화면에서 보고 있는 달
//    화면에 보이는 나머지 숫자(잔액, 합계, 카테고리별 금액)는 모두
//    이 두 값으로부터 "계산"하는 파생 데이터입니다.
//
//  ■ ChangeNotifier 란?
//    플러터에 기본으로 들어 있는 "변경 알림" 클래스입니다.
//      - addListener(함수)  : "바뀌면 나한테 알려 줘" 하고 구독
//      - notifyListeners()  : 구독한 모두에게 "바뀌었어요!" 알림
//    화면 쪽에서는 ListenableBuilder 가 이 알림을 받아 화면을 다시 그립니다.
//    (Provider, Riverpod 같은 유명 패키지도 내부적으로 같은 아이디어를 씁니다.)
//
//  ■ 규칙: "상태는 저장소의 메서드로만 바꾼다"
//    _entries, _month 는 밑줄(_)로 감춰져 있어서 화면 코드가 직접 바꿀 수 없습니다.
//    반드시 add(), remove(), previousMonth() 같은 메서드를 거치고,
//    각 메서드는 값을 바꾼 뒤 notifyListeners() 를 호출합니다.
//    → 상태가 바뀌는 곳이 이 파일 한 곳으로 모이므로, 버그를 찾기 쉽습니다.
//
//  ■ setState 와의 비교
//      setState(() { 값 변경 });    // 위젯 안: 바꾸고 → 이 위젯 다시 그림
//      값 변경; notifyListeners();  // 저장소 안: 바꾸고 → 구독자 모두 다시 그림
// =============================================================================

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/ledger_entry.dart';

/// 가계부 기록과 "보고 있는 달"을 관리하는 상태 저장소.
class LedgerStore extends ChangeNotifier {
  /// 저장소를 만듭니다.
  /// - entries : 처음부터 들어 있을 기록 (생략하면 빈 가계부)
  /// - month   : 처음 보여 줄 달 (생략하면 이번 달)
  LedgerStore({List<LedgerEntry>? entries, DateTime? month})
      : _entries = [...?entries],
        _month = _firstDayOfMonth(month ?? DateTime.now());

  /// 예시 기록이 들어 있는 저장소를 만듭니다. (앱을 처음 켰을 때 보여 줄 데이터)
  /// 날짜는 "오늘"을 기준으로 만들어서 언제 실행해도 이번 달에 기록이 보입니다.
  factory LedgerStore.withSamples() {
    final now = DateTime.now();
    // 이번 달 n일. 단, 오늘보다 미래 날짜는 만들지 않도록 오늘로 맞춥니다.
    DateTime day(int n) => DateTime(now.year, now.month, min(n, now.day));
    // 지난달 n일 (DateTime 은 month 가 0 이 되면 알아서 작년 12월로 바꿔 줍니다)
    DateTime lastMonth(int n) => DateTime(now.year, now.month - 1, n);

    return LedgerStore(entries: [
      // 지난달
      LedgerEntry(
          title: '용돈',
          amount: 500000,
          category: EntryCategory.allowance,
          date: lastMonth(1)),
      LedgerEntry(
          title: '전공 교재',
          amount: 32000,
          category: EntryCategory.education,
          date: lastMonth(5)),
      LedgerEntry(
          title: '친구 생일 선물',
          amount: 25000,
          category: EntryCategory.shopping,
          date: lastMonth(18)),
      // 이번 달
      LedgerEntry(
          title: '용돈',
          amount: 500000,
          category: EntryCategory.allowance,
          date: day(1)),
      LedgerEntry(
          title: '편의점 아르바이트',
          amount: 320000,
          category: EntryCategory.salary,
          date: day(5)),
      LedgerEntry(
          title: '교통카드 충전',
          amount: 30000,
          category: EntryCategory.transport,
          date: day(2)),
      LedgerEntry(
          title: '점심 식사',
          amount: 9000,
          category: EntryCategory.food,
          date: day(3)),
      LedgerEntry(
          title: '카페',
          amount: 5500,
          category: EntryCategory.food,
          date: day(6)),
      LedgerEntry(
          title: '영화 관람',
          amount: 14000,
          category: EntryCategory.culture,
          date: day(8)),
      LedgerEntry(
          title: '티셔츠',
          amount: 29000,
          category: EntryCategory.shopping,
          date: day(10)),
      LedgerEntry(
          title: '저녁 식사',
          amount: 12000,
          category: EntryCategory.food,
          date: day(11)),
    ]);
  }

  // ---------------------------------------------------------------------------
  // 상태(State) - 밖에서는 읽기만 가능, 바꾸는 것은 아래 메서드로만
  // ---------------------------------------------------------------------------

  /// 모든 기록 (모든 달).
  final List<LedgerEntry> _entries;

  /// 지금 보고 있는 달 (항상 그 달의 1일로 저장).
  DateTime _month;

  /// 지금 보고 있는 달. 화면 위쪽 "2026년 10월" 표시에 사용합니다.
  DateTime get month => _month;

  // ---------------------------------------------------------------------------
  // 파생 데이터(Derived Data) - 상태로부터 매번 계산하는 값
  // ---------------------------------------------------------------------------
  //  합계를 따로 변수에 저장해 두면 기록을 추가/삭제할 때마다 함께 고쳐야 하고,
  //  깜빡하면 숫자가 틀어집니다. getter 로 매번 계산하면 그럴 일이 없습니다.
  //  (기록이 수천 건이 되기 전까지는 매번 계산해도 충분히 빠릅니다.)

  /// 보고 있는 달의 기록. 최근 날짜가 위로 오도록 정렬합니다.
  List<LedgerEntry> get monthEntries {
    final list = _entries.where((e) => _isSameMonth(e.date, _month)).toList();
    // 날짜 내림차순. 날짜가 같으면 나중에 기록한 것(id 가 큰 것)이 위로.
    list.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
    return list;
  }

  /// 보고 있는 달의 수입 합계.
  int get incomeTotal => _sumOf(EntryType.income);

  /// 보고 있는 달의 지출 합계.
  int get expenseTotal => _sumOf(EntryType.expense);

  /// 보고 있는 달의 잔액 (수입 - 지출). 지출이 더 많으면 음수가 됩니다.
  int get balance => incomeTotal - expenseTotal;

  /// 보고 있는 달의 카테고리별 지출 합계. 금액이 큰 순서로 정렬합니다.
  /// 예) [교통 30,000원, 쇼핑 29,000원, 식비 26,500원, 문화 14,000원]
  List<MapEntry<EntryCategory, int>> get expenseByCategory {
    final totals = <EntryCategory, int>{};
    for (final entry in monthEntries) {
      if (entry.type == EntryType.expense) {
        // 처음 나온 카테고리면 0 에서 시작해서 금액을 더합니다.
        totals[entry.category] = (totals[entry.category] ?? 0) + entry.amount;
      }
    }
    return totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  // ---------------------------------------------------------------------------
  // 상태를 바꾸는 메서드 - 바꾼 뒤에는 반드시 notifyListeners()!
  // ---------------------------------------------------------------------------

  /// 기록을 추가합니다.
  /// 추가한 기록이 바로 보이도록, 그 기록의 달로 화면을 이동합니다.
  void add(LedgerEntry entry) {
    _entries.add(entry);
    _month = _firstDayOfMonth(entry.date);
    notifyListeners(); // ← 이 한 줄이 "화면아, 다시 그려!" 신호입니다.
  }

  /// 기록을 삭제합니다.
  void remove(LedgerEntry entry) {
    _entries.remove(entry);
    notifyListeners();
  }

  /// 이전 달로 이동합니다.
  void previousMonth() {
    // DateTime(2026, 0, 1) 은 자동으로 2025년 12월 1일이 됩니다.
    _month = DateTime(_month.year, _month.month - 1);
    notifyListeners();
  }

  /// 다음 달로 이동합니다.
  void nextMonth() {
    // DateTime(2026, 13, 1) 은 자동으로 2027년 1월 1일이 됩니다.
    _month = DateTime(_month.year, _month.month + 1);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 내부에서만 쓰는 도우미 함수
  // ---------------------------------------------------------------------------

  /// 보고 있는 달에서 주어진 종류(수입/지출)의 금액을 모두 더합니다.
  int _sumOf(EntryType type) => monthEntries
      .where((e) => e.type == type)
      .fold(0, (sum, e) => sum + e.amount);

  static DateTime _firstDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
