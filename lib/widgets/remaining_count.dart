// =============================================================================
//  widgets/remaining_count.dart - "남은 할 일 N" 을 보여 주는 위젯
// =============================================================================
//
//  ■ 화면에서 "바뀌는 곳 ①" 입니다.  예) 남은 할 일 2  →  남은 할 일 1
//
//  ■ StatelessWidget 인데 숫자가 어떻게 바뀌나요?
//    이 위젯은 숫자를 스스로 저장하거나 바꾸지 않습니다.
//    부모(TodoScreen)가 setState 로 다시 build() 될 때
//    새 숫자(count)를 넣어 이 위젯을 "새로 만들어" 주기 때문에 화면이 바뀝니다.
//
//        부모 build() 1회차 : RemainingCount(count: 2)
//        [완료] 버튼 탭 → setState
//        부모 build() 2회차 : RemainingCount(count: 1)   ← 새 값으로 다시 생성
//
//    즉, "보여 주기만 하는 위젯"은 상태가 없어도(Stateless) 충분합니다.
// =============================================================================

import 'package:flutter/material.dart';

/// 남은(완료되지 않은) 할 일 개수를 표시합니다.
class RemainingCount extends StatelessWidget {
  /// 표시할 남은 할 일 수. 부모가 상태로부터 계산해서 넘겨줍니다.
  final int count;

  const RemainingCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    // Row : 가로로 나란히 배치
    // CrossAxisAlignment.baseline : 크기가 다른 두 글자의 "글자 밑선"을 맞춰 정렬
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Text(
          '남은 할 일 ',
          style: TextStyle(fontSize: 20, color: Color(0xFF33415C)),
        ),
        // 상태에 따라 바뀌는 숫자 부분 (크고 굵은 초록색)
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: Color(0xFF14967F),
          ),
        ),
      ],
    );
  }
}
