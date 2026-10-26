// =============================================================================
//  widgets/match_badge.dart - '취향 98%' 처럼 일치도를 보여 주는 작은 배지
// =============================================================================

import 'package:flutter/material.dart';

/// 취향 일치도 배지. 일치도가 높을수록 진한 색으로 보여 줍니다.
class MatchBadge extends StatelessWidget {
  const MatchBadge({super.key, required this.percent, this.prefix = '취향'});

  /// 일치도 (0 ~ 100).
  final int percent;

  /// 숫자 앞에 붙일 말. 예) '취향' → '취향 98%'
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 80% 이상: 진하게 / 60% 이상: 연하게 / 그 아래: 회색
    final (Color background, Color foreground) = percent >= 80
        ? (scheme.primary, scheme.onPrimary)
        : percent >= 60
            ? (scheme.primaryContainer, scheme.onPrimaryContainer)
            : (scheme.surfaceContainerHighest, scheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$prefix $percent%',
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
