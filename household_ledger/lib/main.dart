// =============================================================================
//  나의 가계부 (Household Ledger) - ChangeNotifier 상태 관리 연습 앱
// =============================================================================
//
//  ■ 이 앱으로 할 수 있는 것
//    1) 수입·지출 기록하기   : 오른쪽 아래 [기록하기] 버튼 → 입력 화면 → [저장]
//    2) 한 달 요약 보기       : 잔액 / 수입 합계 / 지출 합계
//    3) 지출 분석 보기        : 카테고리별 지출 금액과 비율 막대
//    4) 월 이동               : 화면 위쪽 〈 2026년 10월 〉 의 화살표
//    5) 기록 삭제·되돌리기    : 내역을 왼쪽으로 밀면 삭제, 아래 알림의 [되돌리기]로 복구
//
//  ■ 할 일 앱(setState)과 무엇이 다른가요?
//    할 일 앱은 상태(할 일 목록)를 "화면 하나(StatefulWidget)" 안에 두고
//    setState() 로 그 화면을 다시 그렸습니다.
//
//    가계부는 같은 데이터(기록 목록)를 여러 곳에서 씁니다.
//      - 요약 카드, 지출 분석, 내역 목록이 모두 같은 기록을 보고 계산하고
//      - 입력 화면에서 만든 기록이 홈 화면에 반영돼야 합니다.
//    그래서 상태를 위젯 밖의 클래스 LedgerStore(ChangeNotifier)로 꺼냈습니다.
//
//        setState 방식           : 상태가 위젯 "안"에 있음 → 그 위젯만 다시 그림
//        ChangeNotifier 방식     : 상태가 위젯 "밖"에 있음 → 구독(listen)하는
//                                  위젯들에게 "바뀌었어요!" 하고 알림
//
//  ■ 상태 흐름: [저장] 버튼을 눌렀을 때
//
//      AddEntryScreen (입력 화면)
//           │  Navigator.pop(context, 새 기록)   ← 입력한 결과를 이전 화면에 돌려줌
//           ▼
//      HomeScreen._openAddScreen()
//           │  store.add(새 기록)
//           ▼
//      LedgerStore.add()
//           │  _entries 에 추가 → notifyListeners()   ← "상태가 바뀌었어요!"
//           ▼
//      ListenableBuilder 가 알림을 받고 builder 를 다시 실행
//           ├──▶ SummaryCard        잔액·수입·지출 다시 계산
//           ├──▶ CategoryBreakdown  카테고리별 막대 다시 계산
//           └──▶ EntryTile 목록     새 기록이 목록에 나타남
//
//  ■ 상태의 두 종류 (이 앱의 핵심 포인트)
//    - 공유 상태(앱 상태) : 기록 목록, 보고 있는 달  → LedgerStore (여러 화면이 공유)
//    - 지역 상태(임시 상태): 입력 중인 금액, 고른 카테고리 → AddEntryScreen 의 setState
//      입력 중인 값은 [저장]을 누르기 전까지 다른 화면이 알 필요가 없으므로
//      굳이 공유 상태에 넣지 않습니다.
//
//  ■ 파일 구성
//    lib/main.dart                         앱 시작점, 저장소(LedgerStore) 생성 (이 파일)
//    lib/models/ledger_entry.dart          기록 한 건 + 수입/지출 종류 + 카테고리
//    lib/state/ledger_store.dart           ★ 상태 저장소 (ChangeNotifier)
//    lib/screens/home_screen.dart          홈 화면: 저장소를 구독해서 그림
//    lib/screens/add_entry_screen.dart     입력 화면: 지역 상태(setState) + 결과 반환
//    lib/widgets/month_selector.dart       〈 2026년 10월 〉 월 이동
//    lib/widgets/summary_card.dart         잔액 / 수입 / 지출 요약
//    lib/widgets/category_breakdown.dart   카테고리별 지출 막대
//    lib/widgets/entry_tile.dart           내역 한 줄
//    lib/utils/format.dart                 금액(12,000원)·날짜 표시 형식
//
//  ■ 실험해 보기
//    1) ledger_store.dart 의 add() 에서 notifyListeners() 를 지워 보세요.
//       → [저장]을 눌러도 홈 화면이 바뀌지 않습니다. (월을 이동하면 그제야 보임)
//    2) home_screen.dart 에서 ListenableBuilder 를 빼고 내용만 남겨 보세요.
//       → 알림을 받는 위젯이 없으니 역시 화면이 바뀌지 않습니다.
//    3) 앱을 껐다 켜면 기록이 사라집니다. 기록을 기기에 저장하려면
//       shared_preferences 같은 패키지로 LedgerStore 에 저장/불러오기를 더하면 됩니다.
//       (화면 코드는 바꿀 필요가 없습니다. 상태를 분리해 둔 덕분입니다.)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_screen.dart';
import 'state/ledger_store.dart';

/// 앱의 진입점.
void main() {
  // 앱 전체에서 함께 쓸 상태 저장소를 "딱 하나" 만들어서 앱에 넘겨줍니다.
  // 처음 실행했을 때 화면이 비어 있지 않도록 예시 기록을 넣어 둡니다.
  final store = LedgerStore.withSamples();
  runApp(LedgerApp(store: store));
}

/// 앱 전체를 감싸는 루트 위젯.
///
/// 저장소(store)를 생성자로 받기 때문에, 테스트에서는 원하는 데이터를 담은
/// 저장소를 넣어서 앱을 띄울 수 있습니다. (test/widget_test.dart 참고)
class LedgerApp extends StatelessWidget {
  /// 앱 전체가 공유하는 상태 저장소.
  final LedgerStore store;

  const LedgerApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '나의 가계부',
      debugShowCheckedModeBanner: false,

      // ── 한국어 설정 ───────────────────────────────────────────────────────
      // 날짜 선택 창(showDatePicker)의 "2026년 10월", "취소/확인" 같은 글자가
      // 한국어로 나오도록 합니다.
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,

      // ── 테마 ──────────────────────────────────────────────────────────────
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14967F)),
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        useMaterial3: true,
      ),

      // 첫 화면에 저장소를 넘겨줍니다.
      home: HomeScreen(store: store),
    );
  }
}
