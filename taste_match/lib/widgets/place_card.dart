// =============================================================================
//  widgets/place_card.dart - 홈 화면 추천 목록의 가게 카드 한 장
// =============================================================================
//
//      ┌────────────────────────────────────────────┐
//      │ ☕  카페 여백                    [취향 98%] │
//      │     카페 · 성수동                           │
//      │     흰 벽과 나무 테이블 몇 개뿐인 작은 카페  │
//      │  ┌──────────────────────┬────────────────┐  │
//      │  │ 비슷한 사람 ★ 4.8 (5명) │ 전체 ★ 3.8 (9명) │  │
//      │  └──────────────────────┴────────────────┘  │
//      └────────────────────────────────────────────┘
//
//  "비슷한 사람 평점"과 "전체 평점"을 나란히 보여 주는 것이 이 앱의 핵심 장면입니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/place_stats.dart';
import '../utils/format.dart';
import 'match_badge.dart';

/// 추천 목록의 가게 카드.
class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.stats, required this.onTap});

  /// 내 취향 기준으로 계산한 가게 정보.
  final PlaceStats stats;

  /// 카드를 눌렀을 때 (상세 화면 열기).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = stats.place;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    child: Icon(place.category.icon),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${place.category.label} · ${place.area}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MatchBadge(percent: stats.matchScore),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                place.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _RatingStrip(stats: stats),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 아래쪽: 비슷한 사람 평점 | 전체 평점
class _RatingStrip extends StatelessWidget {
  const _RatingStrip({required this.stats});

  final PlaceStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 비슷한 사람의 리뷰가 아직 없으면, 분위기만 보고 추천했다고 알려 줍니다.
    final similarText = stats.hasSimilarReviews
        ? '비슷한 사람 ★ ${formatRating(stats.similarRating)} '
            '(${stats.similarCount}명)'
        : '비슷한 취향 리뷰 없음 · 분위기로 추천';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              similarText,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: stats.hasSimilarReviews
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            '전체 ★ ${formatRating(stats.overallRating)} '
            '(${stats.reviewCount}명)',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
