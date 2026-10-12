// =============================================================================
//  screens/todo_screen.dart - 상태(State)를 가지고 있는 화면
// =============================================================================
//
//  ■ 이 파일이 이 앱의 "심장"입니다.
//    할 일 목록이라는 상태(State)를 저장하고, 바꾸고, 화면에 나눠 줍니다.
//
//  ■ StatefulWidget 은 왜 클래스가 두 개인가요?
//    - TodoScreen         : 위젯 "설정" 부분. 자주 새로 만들어지고 버려집니다.
//    - _TodoScreenState   : 실제 "상태" 를 담는 부분. 화면이 다시 그려져도
//                           플러터가 이 객체를 계속 유지하므로 데이터가 사라지지 않습니다.
//
//  ■ 이 화면이 하는 일 3가지
//    1) 상태 보관   : List<Todo> _todos
//    2) 상태 변경   : _toggleTodo() 안에서 setState() 호출
//    3) 상태 전달   : build() 에서 자식 위젯들에게 값과 콜백을 넘겨줌
//         - RemainingCount ← 남은 개수(int)
//         - TodoCard       ← 할 일(Todo) + 버튼을 눌렀을 때 부를 함수(onToggle)
//
//  ■ 자식 위젯(RemainingCount, TodoCard)은 모두 StatelessWidget 입니다.
//    자식들은 상태를 직접 갖지 않고 "받은 값을 그리기만" 합니다.
//    그래서 상태가 바뀌는 곳은 오직 이 파일의 setState 한 곳뿐입니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../widgets/remaining_count.dart';
import '../widgets/todo_card.dart';

/// 할 일 목록 화면 (상태를 가진 위젯).
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  /// 플러터가 이 위젯을 처음 화면에 붙일 때 한 번 호출하여
  /// 상태 객체(_TodoScreenState)를 만듭니다.
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // ---------------------------------------------------------------------------
  // 1) 상태(State): 이 앱에서 "바뀌는 데이터"는 이 목록 하나뿐입니다.
  // ---------------------------------------------------------------------------
  //  앞의 밑줄(_)은 "이 파일 밖에서는 접근 불가(private)"라는 뜻입니다.
  //  → 바깥에서 목록을 마음대로 바꿀 수 없고, 반드시 _toggleTodo 를 거쳐야 합니다.
  List<Todo> _todos = const [
    Todo(title: '5주차 강의 복습'),
    Todo(title: '상태 흐름도 작성'),
  ];

  // ---------------------------------------------------------------------------
  // 파생 데이터(Derived Data): 상태로부터 "계산"해서 얻는 값
  // ---------------------------------------------------------------------------
  //  남은 할 일 수를 별도 변수(int _remaining)로 저장하지 않는 것이 포인트!
  //  만약 따로 저장하면 목록을 바꿀 때마다 숫자도 직접 맞춰 줘야 하고,
  //  하나라도 빠뜨리면 "카드는 완료인데 숫자는 그대로" 같은 버그가 생깁니다.
  //  getter 로 매번 계산하면 목록과 숫자가 절대 어긋나지 않습니다.
  int get _remainingCount => _todos.where((todo) => !todo.isDone).length;

  // ---------------------------------------------------------------------------
  // 2) 상태 변경: [완료] / [취소] 버튼이 눌렸을 때 호출되는 함수
  // ---------------------------------------------------------------------------
  //  index 번째 할 일의 완료 여부를 뒤집습니다. (false ↔ true)
  void _toggleTodo(int index) {
    // setState() 는 플러터에게 "상태가 바뀌었으니 build() 를 다시 불러 줘!"
    // 라고 알리는 함수입니다. 값 변경은 반드시 이 안에서 합니다.
    //
    // ※ setState 없이 _todos 만 바꾸면 데이터는 바뀌지만
    //    build() 가 다시 호출되지 않아 화면은 그대로 남습니다. (직접 실험해 보세요!)
    setState(() {
      // 기존 목록을 직접 수정하지 않고, 바뀐 항목만 교체한 "새 목록"을 만듭니다.
      //  - i == index 인 항목 : copyWith 로 isDone 을 뒤집은 새 Todo
      //  - 나머지 항목        : 그대로 사용
      _todos = [
        for (int i = 0; i < _todos.length; i++)
          i == index
              ? _todos[i].copyWith(isDone: !_todos[i].isDone)
              : _todos[i],
      ];
    });
  }

  // ---------------------------------------------------------------------------
  // 3) 화면 그리기: 현재 상태(_todos)를 보고 화면을 "처음부터" 다시 설명합니다.
  // ---------------------------------------------------------------------------
  //  build() 는 처음 한 번 + setState() 가 호출될 때마다 다시 실행됩니다.
  //  플러터는 이전 화면과 비교해서 실제로 달라진 부분만 효율적으로 갱신합니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 제목 "나의 할 일" ─────────────────────────────────────────
              const Text(
                '나의 할 일',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B2B45),
                ),
              ),
              const SizedBox(height: 16),
              // 제목 아래 얇은 구분선
              const Divider(
                  height: 1, thickness: 1.5, color: Color(0xFFDCE3EC)),
              const SizedBox(height: 28),

              // ── 바뀌는 곳 ①: 남은 할 일 수 ────────────────────────────────
              //  상태에서 계산한 숫자를 생성자 매개변수로 내려줍니다.
              //  setState 후 build() 가 다시 실행되면 새 숫자로 다시 만들어집니다.
              RemainingCount(count: _remainingCount),
              const SizedBox(height: 24),

              // ── 바뀌는 곳 ②: 할 일 카드 목록 ──────────────────────────────
              //  ListView.separated : 항목 사이에 간격(separator)을 넣어 주는 목록
              Expanded(
                child: ListView.separated(
                  itemCount: _todos.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return TodoCard(
                      // 데이터는 아래로: 이 카드가 그릴 할 일
                      todo: _todos[index],
                      // 이벤트는 위로: 버튼이 눌리면 부모의 _toggleTodo 를 호출
                      //  → 자식은 "눌렸다"는 사실만 알리고,
                      //    실제 상태 변경은 상태 주인인 이 화면이 담당합니다.
                      onToggle: () => _toggleTodo(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
