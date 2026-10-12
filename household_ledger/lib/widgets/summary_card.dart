// =============================================================================
//  widgets/summary_card.dart - 한 달 요약 카드 (잔액 / 수입 / 지출)
// =============================================================================
//
//      ┌──────────────────────────────┐
//      │ 10월 잔액                     │
//      │ 1,050,500원                   │
//      │ ─────────────────────────── │
//      │ 수입 +820,000원 │ 지출 -99,500원 │
//      └──────────────────────────────┘
//
//  ■ 이 위젯은 숫자를 직접 계산하지 않습니다.
//    잔액·수입·지출은 저장소(LedgerStore)가 계산한 값을 그대로 받아 그리기만 합니다.
//    계산은 한 곳(저장소)에, 그리기는 위젯에 → 역할이 나뉘어 있어 이해하기 쉽습니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../utils/format.dart';

/// 보고 있는 달의 잔액, 수입 합계, 지출 합계를 보여 주는 카드.
class SummaryCard extends StatelessWidget {
  /// 보고 있는 달 ("10월 잔액" 의 10월 표시용).
  final DateTime month;

  /// 수입 합계.
  final int income;

  /// 지출 합계.
  final int expense;

  /// 잔액 (수입 - 지출).
  final int balance;

  const SummaryCard({
    super.key,
    required this.month,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 진한 초록 → 조금 밝은 초록으로 바뀌는 배경
        gradient: const LinearGradient(
          colors: [Color(0xFF0F7F6B), Color(0xFF19A88F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${month.month}월 잔액',
            style: const TextStyle(color: Color(0xFFD5F2EB), fontSize: 15),
          ),
          const SizedBox(height: 6),
          // 잔액: 상태가 바뀌면 가장 먼저 눈에 띄는 숫자
          Text(
            formatWon(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0x40FFFFFF)),
          const SizedBox(height: 14),
          // 수입 / 지출을 가로로 반씩 나눠 표시
          Row(
            children: [
              Expanded(
                  child:
                      _AmountLabel(label: '수입', text: '+${formatWon(income)}')),
              Expanded(
                  child: _AmountLabel(
                      label: '지출', text: '-${formatWon(expense)}')),
            ],
          ),
        ],
      ),
    );
  }
}

/// "수입 / +820,000원" 처럼 작은 제목과 금액을 위아래로 보여 주는 내부 위젯.
class _AmountLabel extends StatelessWidget {
  final String label;
  final String text;

  const _AmountLabel({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFFD5F2EB), fontSize: 13)),
        const SizedBox(height: 2),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
