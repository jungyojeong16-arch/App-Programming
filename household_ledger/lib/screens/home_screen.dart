// =============================================================================
//  screens/home_screen.dart - 홈 화면 (저장소를 "구독"해서 그리는 화면)
// =============================================================================
//
//  ■ 화면 구성 (위에서 아래로)
//      〈 2026년 10월 〉          MonthSelector     - 월 이동
//      ┌ 10월 잔액 ──────────┐
//      │ 1,050,500원          │   SummaryCard       - 잔액 / 수입 / 지출
//      │ 수입 +820,000 지출 … │
//      └──────────────────────┘
//      지출 분석 ▇▇▇▅▃           CategoryBreakdown - 카테고리별 막대
//      내역 9건
//      🍴 저녁 식사   -12,000원  EntryTile × N      - 내역 목록 (밀어서 삭제)
//                                [+ 기록하기]       - 입력 화면 열기
//
//  ■ 이 화면은 StatelessWidget 입니다. 그런데 어떻게 바뀌나요?
//    화면 내용 전체를 ListenableBuilder 로 감쌌습니다.
//
//      ListenableBuilder(
//        listenable: store,            ← 이 저장소를 구독(listen)하다가
//        builder: (context, _) { … },  ← notifyListeners() 가 오면 이 함수를 다시 실행
//      )
//
//    즉, "언제 다시 그릴지"는 저장소가 알려 주고, 이 화면은 "어떻게 그릴지"만
//    설명합니다. 이 화면 안에는 setState 가 하나도 없습니다.
//
//  ■ 화면 → 저장소 방향 (이벤트)
//    버튼을 누르면 store.previousMonth(), store.add(...), store.remove(...) 처럼
//    저장소의 메서드를 호출할 뿐, 화면이 직접 데이터를 고치지 않습니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/ledger_entry.dart';
import '../state/ledger_store.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/entry_tile.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_card.dart';
import 'add_entry_screen.dart';

/// 가계부 홈 화면.
class HomeScreen extends StatelessWidget {
  /// 앱 전체가 공유하는 상태 저장소 (main.dart 에서 만들어 전달받음).
  final LedgerStore store;

  const HomeScreen({super.key, required this.store});

  /// [기록하기] 버튼: 입력 화면을 열고, 저장된 기록을 받아 저장소에 추가합니다.
  Future<void> _openAddScreen(BuildContext context) async {
    // 처음 입력 화면에 채워 둘 날짜:
    // 이번 달을 보고 있으면 "오늘", 다른 달을 보고 있으면 "그 달 1일".
    final now = DateTime.now();
    final viewingThisMonth =
        store.month.year == now.year && store.month.month == now.month;
    final initialDate = viewingThisMonth ? now : store.month;

    // Navigator.push 는 새 화면을 띄우고, 그 화면이 닫힐 때(pop) 돌려준 값을
    // Future 로 받습니다. await 로 입력 화면이 닫힐 때까지 기다립니다.
    //   - [저장]을 누르면 → 새 LedgerEntry
    //   - 뒤로 가기를 누르면 → null
    final LedgerEntry? newEntry = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(initialDate: initialDate),
      ),
    );

    // 저장했을 때만 저장소에 추가 → notifyListeners() → 이 화면이 다시 그려짐
    if (newEntry != null) {
      store.add(newEntry);
    }
  }

  /// 내역을 밀어서 삭제했을 때: 저장소에서 지우고 [되돌리기] 알림을 띄웁니다.
  void _deleteEntry(BuildContext context, LedgerEntry entry) {
    store.remove(entry);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // 이전 알림이 남아 있으면 먼저 닫기
      ..showSnackBar(
        SnackBar(
          content: Text("'${entry.title}' 기록을 삭제했어요"),
          action: SnackBarAction(
            label: '되돌리기',
            // 지운 기록 객체를 그대로 다시 추가하면 복구됩니다.
            onPressed: () => store.add(entry),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '나의 가계부',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF7F9FB),
      ),

      // ── 저장소를 구독하는 부분 ───────────────────────────────────────────
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          // builder 가 실행될 때마다 저장소에서 "지금" 값을 새로 읽어 옵니다.
          final entries = store.monthEntries;

          return ListView(
            // 아래쪽 여백: 마지막 내역이 [기록하기] 버튼에 가려지지 않게
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
            children: [
              // 월 이동: 화살표를 누르면 저장소의 메서드를 호출
              MonthSelector(
                month: store.month,
                onPrevious: store.previousMonth,
                onNext: store.nextMonth,
              ),
              const SizedBox(height: 12),

              // 잔액 / 수입 / 지출 - 저장소가 계산한 값을 그대로 전달
              SummaryCard(
                month: store.month,
                income: store.incomeTotal,
                expense: store.expenseTotal,
                balance: store.balance,
              ),
              const SizedBox(height: 16),

              // 카테고리별 지출 막대
              CategoryBreakdown(
                items: store.expenseByCategory,
                total: store.expenseTotal,
              ),
              const SizedBox(height: 24),

              // 내역 제목
              Text(
                '내역 ${entries.length}건',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B2B45),
                ),
              ),
              const SizedBox(height: 8),

              // 이번 달 기록이 없을 때 안내 문구
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    '이 달의 기록이 없어요.\n아래 [기록하기] 버튼으로 첫 기록을 남겨 보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7C8798), height: 1.6),
                  ),
                ),

              // 내역 목록 - 각 줄을 Dismissible 로 감싸서 "밀어서 삭제"
              for (final entry in entries)
                Dismissible(
                  // key: 플러터가 "어떤 줄이 사라졌는지" 정확히 알 수 있도록
                  //      기록마다 다른 값(id)을 붙여 줍니다.
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart, // 오른쪽 → 왼쪽으로만
                  background: const _DeleteBackground(),
                  onDismissed: (_) => _deleteEntry(context, entry),
                  child: EntryTile(entry: entry),
                ),
            ],
          );
        },
      ),

      // ── 기록하기 버튼 ─────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddScreen(context),
        icon: const Icon(Icons.add),
        label: const Text('기록하기'),
        backgroundColor: const Color(0xFF14967F),
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// 내역을 왼쪽으로 밀 때 뒤에 보이는 빨간 "삭제" 배경.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5484D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white),
          SizedBox(width: 4),
          Text('삭제', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
