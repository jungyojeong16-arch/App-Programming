// =============================================================================
//  widgets/star_rating.dart - 별점을 ★★★★☆ 처럼 보여 주는 위젯 (읽기 전용)
// =============================================================================

import 'package:flutter/material.dart';

/// 별 5개 중 [rating] 개를 채워서 보여 줍니다.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16});

  /// 별점 1 ~ 5.
  final int rating;

  /// 별 하나의 크기.
  final double size;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFF5A524);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: color,
          ),
      ],
    );
  }
}
