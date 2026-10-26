// =============================================================================
//  widgets/review_tile.dart - 상세 화면의 리뷰 한 건
// =============================================================================
//
//      고요한산책  [나와 100%]               10월 3일
//      ★★★★★
//      손님이 두세 팀뿐이라 책 한 권 다 읽고 왔어요.
//
//  리뷰마다 "나와 취향이 몇 % 비슷한 사람이 쓴 리뷰인지"를 보여 줍니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/review.dart';
import '../utils/format.dart';
import 'match_badge.dart';
import 'star_rating.dart';

/// 리뷰 한 건.
class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review, required this.similarity});

  final Review review;

  /// 이 리뷰를 쓴 사람과 나의 취향 일치도 (0 ~ 100).
  final int similarity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.author.nickname,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              // 내가 쓴 리뷰에는 일치도 대신 '내 리뷰' 표시
              review.author.isMe
                  ? const _MyReviewLabel()
                  : MatchBadge(percent: similarity, prefix: '나와'),
              const Spacer(),
              Text(
                formatDate(review.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          StarRating(rating: review.rating),
          const SizedBox(height: 6),
          Text(review.comment),
        ],
      ),
    );
  }
}

class _MyReviewLabel extends StatelessWidget {
  const _MyReviewLabel();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '내 리뷰',
        style: TextStyle(
          color: scheme.onTertiaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
