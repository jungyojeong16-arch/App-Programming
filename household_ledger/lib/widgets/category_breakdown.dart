// =============================================================================
//  widgets/category_breakdown.dart - 카테고리별 지출 분석 막대
// =============================================================================
//
//      지출 분석
//      🚌 교통   ▇▇▇▇▇▇▇▇▇▇      30%   30,000원
//      🛍 쇼핑   ▇▇▇▇▇▇▇▇▇▇      29%   29,000원
//      🍴 식비   ▇▇▇▇▇▇▇▇        27%   26,500원
//
//  ■ 막대 길이 = 그 카테고리 금액 ÷ 전체 지출
//    기록을 추가하거나 지우면 저장소가 다시 계산한 items/total 이 들어오므로
//    막대 길이와 비율이 자동으로 바뀝니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/ledger_entry.dart';
import '../utils/format.dart';

/// 카테고리별 지출 금액과 비율을 막대로 보여 주는 카드.
class CategoryBreakdown extends StatelessWidget {
  /// (카테고리, 금액) 목록. 금액이 큰 순서로 정렬되어 들어옵니다.
  final List<MapEntry<EntryCategory, int>> items;

  /// 전체 지출 합계 (비율 계산용).
  final int total;

  const CategoryBreakdown(
      {super.key, required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지출 분석',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B2B45),
            ),
          ),
          const SizedBox(height: 12),

          // 지출이 없으면 막대 대신 안내 문구
          if (items.isEmpty)
            const Text('이 달의 지출이 없어요',
                style: TextStyle(color: Color(0xFF7C8798)))
          else
            for (final item in items)
              _CategoryBar(
                  category: item.key, amount: item.value, total: total),
        ],
      ),
    );
  }
}

/// 카테고리 한 줄: 아이콘, 이름, 막대, 비율, 금액.
class _CategoryBar extends StatelessWidget {
  final EntryCategory category;
  final int amount;
  final int total;

  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    // 0.0 ~ 1.0 사이의 비율. total 이 0 이면 0 으로 나누지 않도록 0 처리.
    final ratio = total == 0 ? 0.0 : amount / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(category.icon, size: 18, color: category.color),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(category.label, style: const TextStyle(fontSize: 14)),
          ),
          // 남은 가로 공간을 막대가 차지
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                color: category.color,
                backgroundColor: const Color(0xFFEFF2F6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '${(ratio * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7C8798)),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              formatWon(amount),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
