// =============================================================================
//  widgets/month_selector.dart - 〈 2026년 10월 〉 월 이동 위젯
// =============================================================================
//
//  ■ 상태 없는(Stateless) 위젯입니다.
//    - 보여 줄 달(month)        : 부모에게서 값으로 받음        (데이터는 아래로)
//    - 화살표를 눌렀을 때 할 일  : 부모에게서 함수로 받음        (이벤트는 위로)
//    이 위젯은 달을 스스로 바꾸지 않습니다. 화살표를 누르면 받은 함수
//    (store.previousMonth / store.nextMonth)를 호출할 뿐이고, 저장소가
//    notifyListeners() 하면 홈 화면이 새 달(month)을 넣어 이 위젯을 다시 그립니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../utils/format.dart';

/// 보고 있는 달을 표시하고, 이전/다음 달로 이동하는 화살표를 제공합니다.
class MonthSelector extends StatelessWidget {
  /// 표시할 달.
  final DateTime month;

  /// 〈 버튼을 눌렀을 때 호출할 함수.
  final VoidCallback onPrevious;

  /// 〉 버튼을 눌렀을 때 호출할 함수.
  final VoidCallback onNext;

  const MonthSelector({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          tooltip: '이전 달',
        ),
        Text(
          formatMonth(month),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B2B45),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          tooltip: '다음 달',
        ),
      ],
    );
  }
}
