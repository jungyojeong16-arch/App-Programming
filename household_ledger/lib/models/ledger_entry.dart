// =============================================================================
//  models/ledger_entry.dart - 가계부 기록 한 건을 표현하는 데이터(모델)
// =============================================================================
//
//  ■ 이 파일에 있는 것
//    - EntryType     : 수입인지 지출인지 (enum)
//    - EntryCategory : 식비, 교통, 용돈 … 같은 카테고리 (enum)
//    - LedgerEntry   : 기록 한 건 (내용, 금액, 카테고리, 날짜)
//
//  ■ enum 에 값(라벨, 아이콘, 색)을 붙이는 "향상된 enum"
//    Dart 의 enum 은 각 항목에 필드를 붙일 수 있습니다.
//      EntryCategory.food.label  → '식비'
//      EntryCategory.food.type   → EntryType.expense (지출)
//    화면에서 if/switch 로 "식비면 이 아이콘, 교통이면 저 아이콘…" 하고
//    일일이 나눌 필요가 없어집니다.
//
//  ■ 금액은 왜 int 인가요?
//    원화는 소수점이 없고, double 은 0.1 + 0.2 = 0.30000000000000004 처럼
//    계산 오차가 생길 수 있어서 돈 계산에는 정수(int)를 씁니다.
// =============================================================================

import 'package:flutter/material.dart';

/// 기록의 종류: 수입 또는 지출.
enum EntryType {
  income('수입'),
  expense('지출');

  const EntryType(this.label);

  /// 화면에 보여 줄 이름.
  final String label;
}

/// 기록의 카테고리.
/// 각 카테고리는 자신이 수입용인지 지출용인지(type)를 알고 있습니다.
enum EntryCategory {
  // ── 지출 카테고리 ──
  food('식비', Icons.restaurant, Color(0xFFF08C3A), EntryType.expense),
  transport('교통', Icons.directions_bus, Color(0xFF3B82F6), EntryType.expense),
  shopping('쇼핑', Icons.shopping_bag, Color(0xFFE5484D), EntryType.expense),
  culture('문화', Icons.movie, Color(0xFF8B5CF6), EntryType.expense),
  education('교육', Icons.menu_book, Color(0xFF0EA5A4), EntryType.expense),
  etcExpense('기타 지출', Icons.more_horiz, Color(0xFF7C8798), EntryType.expense),

  // ── 수입 카테고리 ──
  salary('급여', Icons.work, Color(0xFF14967F), EntryType.income),
  allowance('용돈', Icons.savings, Color(0xFF22A06B), EntryType.income),
  etcIncome('기타 수입', Icons.add_card, Color(0xFF5B9A8B), EntryType.income);

  const EntryCategory(this.label, this.icon, this.color, this.type);

  /// 화면에 보여 줄 이름. 예) '식비'
  final String label;

  /// 카테고리 아이콘.
  final IconData icon;

  /// 아이콘 배경, 지출 막대 등에 쓰는 색.
  final Color color;

  /// 이 카테고리가 수입용인지 지출용인지.
  final EntryType type;

  /// 주어진 종류(수입/지출)에 속한 카테고리만 골라 줍니다.
  /// 입력 화면에서 "지출"을 고르면 지출 카테고리만 보여 줄 때 사용합니다.
  static List<EntryCategory> of(EntryType type) =>
      values.where((category) => category.type == type).toList();
}

/// 가계부 기록 한 건.
///
/// 모든 필드가 final 인 불변(immutable) 객체입니다.
/// 기록을 "수정"하는 대신 지우고 새로 만드는 방식으로 다룹니다.
class LedgerEntry {
  /// 기록마다 붙는 고유 번호.
  /// 같은 내용·금액의 기록이 여러 개 있어도 서로 구분할 수 있게 해 줍니다.
  /// (홈 화면에서 밀어서 삭제할 때 Dismissible 의 key 로 사용)
  final int id;

  /// 내용. 예) '점심 식사'
  final String title;

  /// 금액(원). 수입·지출 모두 양수로 저장하고, 종류는 category 로 구분합니다.
  final int amount;

  /// 카테고리. 수입/지출 종류도 여기서 알 수 있습니다.
  final EntryCategory category;

  /// 날짜.
  final DateTime date;

  /// 지금까지 만든 기록 수. 새 기록의 id 로 사용합니다.
  static int _nextId = 0;

  /// 새 기록을 만듭니다. id 는 자동으로 1씩 증가하며 붙습니다.
  LedgerEntry({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  }) : id = _nextId++;

  /// 수입인지 지출인지 (카테고리로부터 계산하는 값).
  EntryType get type => category.type;

  /// 잔액 계산용 부호 붙은 금액. 수입은 +, 지출은 -.
  int get signedAmount => type == EntryType.income ? amount : -amount;
}
