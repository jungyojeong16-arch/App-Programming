// =============================================================================
//  widgets/trait_compare_row.dart - 한 축에서 "이 가게" 와 "내 취향" 을 비교
// =============================================================================
//
//      한적함   ●  ○  ○  ○  ○   북적임      ● = 이 가게 분위기
//      미니멀   ◉  ○  ○  ○  ○   화려함      ◎ = 내 취향 (테두리)
//                                           ◉ = 둘이 같은 칸
//
//  5칸 중 몇 번째 칸인지만 표시하면 되므로, 복잡한 그림 없이
//  동그라미 5개(Container)로 그렸습니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/taste.dart';

/// 한 축의 비교 줄.
class TraitCompareRow extends StatelessWidget {
  const TraitCompareRow({
    super.key,
    required this.trait,
    required this.placeValue,
    required this.myValue,
  });

  /// 어떤 축인지.
  final TasteTrait trait;

  /// 가게 분위기 점수 (1 ~ 5).
  final int placeValue;

  /// 내 취향 점수 (1 ~ 5).
  final int myValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const labelStyle = TextStyle(fontSize: 13);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(trait.low, style: labelStyle),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = TasteProfile.minValue;
                    i <= TasteProfile.maxValue;
                    i++)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // 가게 분위기 칸은 색을 채우고
                      color: i == placeValue
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      // 내 취향 칸은 진한 테두리를 그립니다.
                      border: i == myValue
                          ? Border.all(color: scheme.tertiary, width: 3)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              trait.high,
              style: labelStyle,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
