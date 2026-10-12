# 나의 할 일 — 플러터 상태 관리(State) 학습용 앱

> **버튼 한 번에 달라지는 두 곳**
> 첫 할 일을 완료하면 **카드 표시**와 **남은 할 일 수**가 함께 바뀝니다.

| 누르기 전 | 누른 뒤 |
| --- | --- |
| 남은 할 일 **2**<br>○ 5주차 강의 복습 `완료`<br>○ 상태 흐름도 작성 `완료` | 남은 할 일 **1**<br>✓ 5주차 강의 복습 `취소` (연한 초록 배경)<br>○ 상태 흐름도 작성 `완료` |

## 핵심 개념

1. **상태는 한 곳에** — 할 일 목록(`List<Todo>`)은 `TodoScreen`의 State 객체에만 있습니다.
2. **남은 할 일 수는 저장하지 않고 계산** — `완료되지 않은 할 일의 개수`를 getter로 매번 계산합니다.
   그래서 카드와 숫자가 절대 어긋나지 않습니다.
3. **setState로 다시 그리기** — 버튼을 누르면 `setState()` 안에서 목록을 바꾸고,
   플러터가 `build()`를 다시 호출해 두 곳을 함께 새로 그립니다.
4. **데이터는 아래로, 이벤트는 위로** — 부모가 자식에게 값(`todo`, `count`)을 넘기고,
   자식은 콜백(`onToggle`)으로 "눌렸어요"만 알립니다. (상태 끌어올리기, Lifting State Up)

```
[완료] 버튼 탭 (TodoCard)
     │  onToggle()  ── 자식 → 부모
     ▼
_TodoScreenState._toggleTodo(index)
     │  setState(() { isDone 뒤집기 })
     ▼
build() 다시 실행
     ├─▶ RemainingCount(count: 1)      남은 할 일 2 → 1
     └─▶ TodoCard(todo: isDone=true)   ○ [완료] → ✓ [취소]
```

## 소스 코드

| 파일 | 설명 |
| --- | --- |
| [`lib/main.dart`](lib/main.dart) | 앱 시작점, 테마. **파일 상단에 앱 전체 동작 설명** |
| [`lib/models/todo.dart`](lib/models/todo.dart) | 할 일 데이터 클래스 (불변 객체 + `copyWith`) |
| [`lib/screens/todo_screen.dart`](lib/screens/todo_screen.dart) | 상태를 가진 화면 (`StatefulWidget`, `setState`) |
| [`lib/widgets/remaining_count.dart`](lib/widgets/remaining_count.dart) | "남은 할 일 N" 표시 (`StatelessWidget`) |
| [`lib/widgets/todo_card.dart`](lib/widgets/todo_card.dart) | 할 일 카드 한 장 (`StatelessWidget`) |
| [`test/widget_test.dart`](test/widget_test.dart) | 버튼을 누르면 두 곳이 함께 바뀌는지 확인하는 테스트 |

## 실행 방법

```bash
flutter pub get
flutter run          # 에뮬레이터 / 기기 / 크롬에서 실행
flutter test         # 동작 테스트
```

이미 가지고 있는 플러터 프로젝트에 넣고 싶다면 `lib/` 폴더만 복사한 뒤
`test/widget_test.dart`의 `package:todo_state_app/...`을 내 프로젝트 이름으로 바꾸면 됩니다.

## 실험해 보기

- `todo_screen.dart`의 `_toggleTodo`에서 `setState`를 빼고 값만 바꿔 보세요.
  → 데이터는 바뀌지만 화면은 그대로입니다.
- 초기 목록 `_todos`에 할 일을 하나 더 추가해 보세요.
  → 남은 할 일 수가 자동으로 3이 됩니다.
