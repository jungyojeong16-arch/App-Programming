// =============================================================================
//  widgets/todo_card.dart - 할 일 카드 한 장
// =============================================================================
//
//  ■ 화면에서 "바뀌는 곳 ②" 입니다.
//
//      아직 안 함 (isDone = false)          완료함 (isDone = true)
//      ┌─────────────────────────┐        ┌─────────────────────────┐
//      │ ○  5주차 강의 복습  [완료] │  ───▶  │ ✓  5주차 강의 복습  [취소] │
//      └─────────────────────────┘        └─────────────────────────┘
//        흰 배경, 회색 테두리                 연한 초록 배경
//
//  ■ 이 위젯이 받는 두 가지
//    - todo     (데이터, 부모 → 자식) : 무엇을, 어떤 모양으로 그릴지 결정
//    - onToggle (콜백,   자식 → 부모) : 버튼이 눌렸다는 것을 부모에게 알림
//
//  ■ 중요: 이 카드는 isDone 을 직접 바꾸지 않습니다!
//    버튼을 누르면 onToggle() 만 호출합니다. 그러면 부모(TodoScreen)가
//    setState 로 목록을 바꾸고, 바뀐 todo 를 넣어 이 카드를 다시 그려 줍니다.
//    → 카드 모양과 "남은 할 일 수"가 항상 같은 상태(목록)를 보고 그려지므로
//      두 곳이 어긋나는 일이 없습니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/todo.dart';

/// 할 일 하나를 카드 형태로 보여 주고, [완료]/[취소] 버튼을 제공합니다.
class TodoCard extends StatelessWidget {
  /// 그릴 할 일 데이터.
  final Todo todo;

  /// 버튼이 눌렸을 때 호출할 함수.
  /// VoidCallback 은 "매개변수도 반환값도 없는 함수" 타입(void Function())입니다.
  final VoidCallback onToggle;

  const TodoCard({super.key, required this.todo, required this.onToggle});

  // 화면 디자인에 쓰이는 색상 모음
  static const Color _green = Color(0xFF14967F); // 강조색(아이콘, 버튼 글자)
  static const Color _doneBackground = Color(0xFFE6F4F0); // 완료된 카드 배경
  static const Color _buttonBackground = Color(0xFFDDF0EA); // 버튼 배경
  static const Color _border = Color(0xFFDCE3EC); // 카드 테두리
  static const Color _text = Color(0xFF1B2B45); // 제목 글자

  @override
  Widget build(BuildContext context) {
    // 모든 모양은 todo.isDone 하나로 결정됩니다. (상태 → 화면)
    final bool done = todo.isDone;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // 완료 여부에 따라 배경색을 다르게
        color: done ? _doneBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? _doneBackground : _border, width: 1.5),
      ),
      child: Row(
        children: [
          // ── 왼쪽 아이콘: 완료면 ✓, 아니면 ○ ──────────────────────────────
          Icon(
            done ? Icons.check : Icons.radio_button_unchecked,
            color: _green,
            size: 24,
          ),
          const SizedBox(width: 14),

          // ── 가운데 제목: Expanded 로 남은 가로 공간을 모두 차지 ───────────
          Expanded(
            child: Text(
              todo.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
          ),

          // ── 오른쪽 버튼: 완료면 [취소], 아니면 [완료] ─────────────────────
          //  onPressed 에 부모에게서 받은 onToggle 을 그대로 연결합니다.
          //  → 버튼 탭 = 부모의 _toggleTodo(index) 실행
          TextButton(
            onPressed: onToggle,
            style: TextButton.styleFrom(
              backgroundColor: _buttonBackground,
              foregroundColor: _green,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child:
                Text(done ? '취소' : '완료', style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
