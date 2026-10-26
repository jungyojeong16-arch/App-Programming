// =============================================================================
//  screens/place_detail_screen.dart - 가게 상세 화면
// =============================================================================
//
//  ■ 화면 구성 (위에서 아래로)
//      카페 · 성수동                     [취향 98%]
//      흰 벽과 나무 테이블 몇 개뿐인 작은 카페
//      ┌ 나와 비슷한 사람 ┬ 전체 ────────┐
//      │      4.8        │     3.8       │   ← 이 앱의 핵심 비교
//      │   5명의 리뷰     │   9명의 리뷰   │
//      └─────────────────┴───────────────┘
//      분위기 비교  (● 이 가게  ◎ 내 취향)    ← TraitCompareRow × 5
//      리뷰 5개            [✓ 나와 비슷한 사람만]
//      ReviewTile × N
//                                         [리뷰 쓰기]
//
//  ■ 두 종류의 상태
//    - 리뷰 목록(공유 상태): 저장소에 있음 → ListenableBuilder 로 구독
//      리뷰를 쓰면 이 화면도, 홈 화면의 카드도 함께 바뀝니다.
//    - "나와 비슷한 사람만" 체크(지역 상태): 이 화면만 씀 → setState
// =============================================================================

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/place_stats.dart';
import '../models/review.dart';
import '../models/taste.dart';
import '../state/taste_store.dart';
import '../utils/format.dart';
import '../widgets/match_badge.dart';
import '../widgets/review_tile.dart';
import '../widgets/trait_compare_row.dart';
import 'write_review_screen.dart';

/// 가게 상세 화면.
class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({
    super.key,
    required this.store,
    required this.place,
  });

  final TasteStore store;
  final Place place;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  /// 나와 비슷한 사람의 리뷰만 볼지 (지역 상태). 처음엔 켜 둡니다.
  bool _similarOnly = true;

  /// [리뷰 쓰기]: 작성 화면을 열고, 돌려받은 리뷰를 저장소에 추가합니다.
  Future<void> _openWriteReview() async {
    final Review? review = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WriteReviewScreen(
          place: widget.place,
          author: widget.store.me,
        ),
      ),
    );

    // await 하는 동안 화면이 닫혔을 수도 있으니 확인합니다.
    if (review == null || !mounted) return;

    widget.store.addReview(review); // → 이 화면과 홈 화면이 함께 다시 그려짐
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('리뷰를 남겼어요')));
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final place = widget.place;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWriteReview,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('리뷰 쓰기'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final stats = store.statsOf(place);
          final reviews = store.reviewsOf(place, similarOnly: _similarOnly);
          final myTaste = store.profile ?? const TasteProfile();

          return ListView(
            // 아래쪽 여백: 마지막 리뷰가 [리뷰 쓰기] 버튼에 가려지지 않게
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
            children: [
              // ── 가게 정보 ──
              Row(
                children: [
                  Icon(place.category.icon,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${place.category.label} · ${place.area}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  MatchBadge(percent: stats.matchScore),
                ],
              ),
              const SizedBox(height: 8),
              Text(place.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),

              // ── 평점 비교 ──
              _RatingCompareCard(stats: stats),
              const SizedBox(height: 24),

              // ── 분위기 비교 ──
              _SectionTitle(
                title: '분위기 비교',
                trailing: MatchBadge(
                  percent: stats.vibeMatch,
                  prefix: '분위기 일치',
                ),
              ),
              Text(
                '● 채운 칸 = 이 가게 분위기     ◎ 테두리 칸 = 내 취향',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              for (final trait in TasteTrait.values)
                TraitCompareRow(
                  trait: trait,
                  placeValue: place.vibe[trait],
                  myValue: myTaste[trait],
                ),
              const SizedBox(height: 24),

              // ── 리뷰 ──
              _SectionTitle(
                title: '리뷰 ${reviews.length}개',
                trailing: FilterChip(
                  label: const Text('나와 비슷한 사람만'),
                  selected: _similarOnly,
                  onSelected: (value) => setState(() => _similarOnly = value),
                ),
              ),
              if (reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    '아직 나와 비슷한 취향의 리뷰가 없어요.\n첫 리뷰를 남겨 보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              for (final review in reviews) ...[
                ReviewTile(
                  review: review,
                  similarity: store.similarityTo(review.author),
                ),
                const Divider(height: 1),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// "나와 비슷한 사람 평점 | 전체 평점" 큰 비교 카드.
class _RatingCompareCard extends StatelessWidget {
  const _RatingCompareCard({required this.stats});

  final PlaceStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _RatingColumn(
                label: '나와 비슷한 사람',
                rating: stats.similarRating,
                count: stats.similarCount,
                color: scheme.primary,
              ),
            ),
            VerticalDivider(color: scheme.outlineVariant, width: 1),
            Expanded(
              child: _RatingColumn(
                label: '전체',
                rating: stats.overallRating,
                count: stats.reviewCount,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingColumn extends StatelessWidget {
  const _RatingColumn({
    required this.label,
    required this.rating,
    required this.count,
    required this.color,
  });

  final String label;
  final double? rating;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          '★ ${formatRating(rating)}',
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          count == 0 ? '아직 없어요' : '$count명의 리뷰',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

/// 구역 제목 + 오른쪽 부가 요소.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
  }
}
