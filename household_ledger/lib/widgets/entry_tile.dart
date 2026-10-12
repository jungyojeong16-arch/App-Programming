// =============================================================================
//  widgets/entry_tile.dart - 내역 한 줄
// =============================================================================
//
//      (🍴)  저녁 식사                 -12,000원
//            식비 · 10월 11일 (일)
//
//  ■ 기록(LedgerEntry) 하나를 받아서 그리기만 하는 Stateless 위젯입니다.
//    - 수입이면 초록색 "+금액", 지출이면 진한 글자 "-금액"
//    - 삭제(밀기)는 이 위젯이 아니라 바깥의 Dismissible(홈 화면)이 담당합니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/ledger_entry.dart';
import '../utils/format.dart';

/// 가계부 내역 한 줄.
class EntryTile extends StatelessWidget {
  /// 그릴 기록.
  final LedgerEntry entry;

  const EntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == EntryType.income;
    final category = entry.category;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3E8EF)),
        ),
        child: Row(
          children: [
            // 카테고리 아이콘 (카테고리 색의 연한 원 배경)
            CircleAvatar(
              radius: 20,
              backgroundColor: category.color.withAlpha(36),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            const SizedBox(width: 12),

            // 내용 + (카테고리 · 날짜)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2B45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.label} · ${formatDay(entry.date)}',
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF7C8798)),
                  ),
                ],
              ),
            ),

            // 금액: signedAmount 는 수입이면 +, 지출이면 - 값
            Text(
              '${isIncome ? '+' : ''}${formatWon(entry.signedAmount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isIncome
                    ? const Color(0xFF14967F)
                    : const Color(0xFF1B2B45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
