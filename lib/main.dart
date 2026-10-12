// =============================================================================
//  나의 할 일 (Todo State App) - 플러터 상태 관리(State) 학습용 예제
// =============================================================================
//
//  ■ 이 앱은 무엇을 보여주나요?
//    "버튼 한 번에 달라지는 두 곳"
//    할 일 카드의 [완료] 버튼을 누르면 화면에서 두 군데가 동시에 바뀝니다.
//
//      ① 카드 표시     : ○ 빈 원 + [완료]  →  ✓ 체크 + 연한 초록 배경 + [취소]
//      ② 남은 할 일 수 : 2  →  1
//
//      [누르기 전]                         [누른 뒤]
//      ┌──────────────────────┐           ┌──────────────────────┐
//      │ 나의 할 일            │           │ 나의 할 일            │
//      │ 남은 할 일 2          │  완료 버튼 │ 남은 할 일 1          │
//      │ ○ 5주차 강의 복습 [완료]│ ───────▶ │ ✓ 5주차 강의 복습 [취소]│
//      │ ○ 상태 흐름도 작성 [완료]│          │ ○ 상태 흐름도 작성 [완료]│
//      └──────────────────────┘           └──────────────────────┘
//
//  ■ 핵심 아이디어: "상태(State)는 한 곳에, 화면은 상태로부터 그린다"
//    - 할 일 목록(List<Todo>)이라는 '상태'는 TodoScreen 의 State 객체
//      (_TodoScreenState) 한 곳에만 저장됩니다.
//    - '남은 할 일 수'는 따로 저장하지 않고, 매번 목록에서 계산합니다.
//      (완료되지 않은 할 일의 개수 = 파생 데이터)
//    - 그래서 목록 하나만 바꾸면, 그 목록을 바라보는 두 위젯
//      (RemainingCount, TodoCard)이 함께 새로 그려집니다.
//
//  ■ 버튼을 눌렀을 때 일어나는 일 (상태 흐름)
//
//      [완료] 버튼 탭 (TodoCard)
//           │  onToggle 콜백 호출 (자식 → 부모로 "눌렸어요" 알림)
//           ▼
//      _TodoScreenState._toggleTodo(index)
//           │  setState(() { ...목록의 해당 할 일 isDone 뒤집기... })
//           ▼
//      플러터가 "상태가 바뀌었다"는 것을 알고 build() 를 다시 호출
//           │
//           ├──▶ RemainingCount(count: 1)      → 숫자 2 가 1 로 바뀜
//           └──▶ TodoCard(todo: isDone=true)  → ✓ 표시 + [취소] 버튼
//
//    * 데이터는 위(부모)에서 아래(자식)로 '생성자 매개변수'로 내려가고,
//      이벤트는 아래(자식)에서 위(부모)로 '콜백 함수'로 올라갑니다.
//      이것을 "상태 끌어올리기(Lifting State Up)"라고 부릅니다.
//
//  ■ 파일 구성
//    lib/main.dart                     앱 시작점 + 테마 설정 (이 파일)
//    lib/models/todo.dart              할 일 한 개를 표현하는 데이터 클래스
//    lib/screens/todo_screen.dart      상태를 가진 화면 (StatefulWidget)
//    lib/widgets/remaining_count.dart  "남은 할 일 N" 표시 (StatelessWidget)
//    lib/widgets/todo_card.dart        할 일 카드 한 장 (StatelessWidget)
//
//  ■ 실험해 보기
//    1) todo_screen.dart 의 _toggleTodo 에서 setState 를 빼고 값만 바꿔 보세요.
//       → 데이터는 바뀌지만 화면은 그대로입니다. (setState 의 역할 확인)
//    2) 초기 목록(_todos)에 할 일을 하나 더 추가해 보세요.
//       → 남은 할 일 수가 자동으로 3 이 됩니다. (파생 데이터의 장점)
// =============================================================================

import 'package:flutter/material.dart';

import 'screens/todo_screen.dart';

/// 앱의 진입점(entry point).
/// 플러터는 main() 에서 runApp() 에 전달된 위젯을 화면의 루트로 그립니다.
void main() {
  runApp(const TodoStateApp());
}

/// 앱 전체를 감싸는 루트 위젯.
///
/// 이 위젯 자체는 바뀌는 데이터(상태)가 없으므로 StatelessWidget 입니다.
/// 하는 일은 MaterialApp 으로 테마와 첫 화면(TodoScreen)을 지정하는 것뿐입니다.
class TodoStateApp extends StatelessWidget {
  const TodoStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '나의 할 일',
      // 오른쪽 위의 "DEBUG" 띠를 숨깁니다.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 앱의 기본 색(초록 계열)을 기준으로 머티리얼 색 구성을 만듭니다.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14967F)),
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        useMaterial3: true,
      ),
      // 첫 화면: 상태를 가지고 있는 TodoScreen
      home: const TodoScreen(),
    );
  }
}
