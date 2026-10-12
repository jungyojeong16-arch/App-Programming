// =============================================================================
//  models/todo.dart - 할 일 한 개를 표현하는 데이터(모델) 클래스
// =============================================================================
//
//  ■ 역할
//    화면(위젯)과 상관없이 "할 일" 데이터만 담습니다.
//      - title  : 할 일 제목 (예: "5주차 강의 복습")
//      - isDone : 완료 여부 (false = 아직, true = 완료)
//
//  ■ 왜 불변(immutable) 객체로 만들었나요?
//    모든 필드를 final 로 선언했기 때문에 한번 만든 Todo 의 값은 바꿀 수 없습니다.
//    값을 바꾸고 싶으면 copyWith() 로 "바뀐 값을 가진 새 Todo" 를 만듭니다.
//
//      기존: Todo(title: '5주차 강의 복습', isDone: false)
//      변경: todo.copyWith(isDone: true)
//      결과: Todo(title: '5주차 강의 복습', isDone: true)   ← 새 객체
//
//    이렇게 하면 "상태가 바뀌는 곳"이 setState 안의 한 줄로 분명해지고,
//    다른 곳에서 몰래 데이터를 바꾸는 실수를 막을 수 있습니다.
//    (Provider, Riverpod, Bloc 등 상태 관리 라이브러리에서도 같은 방식을 씁니다.)
// =============================================================================

/// 할 일 한 개.
class Todo {
  /// 할 일 제목. 화면의 카드에 그대로 표시됩니다.
  final String title;

  /// 완료 여부.
  /// - false : 카드에 ○ 와 [완료] 버튼이 보입니다.
  /// - true  : 카드에 ✓ 와 [취소] 버튼이 보이고, 배경이 연한 초록색이 됩니다.
  final bool isDone;

  /// 생성자. isDone 을 생략하면 기본값 false(아직 안 함)로 만들어집니다.
  const Todo({required this.title, this.isDone = false});

  /// 일부 값만 바꾼 "새" Todo 를 돌려줍니다.
  /// 전달하지 않은 값(null)은 기존 값을 그대로 사용합니다.
  Todo copyWith({String? title, bool? isDone}) {
    return Todo(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
