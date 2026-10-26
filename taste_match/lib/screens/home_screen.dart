// =============================================================================
//  screens/home_screen.dart - 홈 화면 (내 취향 맞춤 추천 목록)
// =============================================================================
//
//  ■ 화면 구성 (위에서 아래로)
//      결                                     [취향 수정]
//      ┌ 내 취향 ─────────────────────────────┐
//      │ 한적함 · 미니멀 · 분위기 · 조용함 · 혼자 │
//      └──────────────────────────────────────┘
//      [전체] [카페] [식당] [술집]              카테고리 칩
//      [ 취향 맞춤순 | 전체 평점순 ]             정렬 방식
//      PlaceCard × N                           추천 목록
//
//  ■ [전체 평점순]을 눌러 보세요
//    다른 앱처럼 "모든 사람의 평균 별점"으로 정렬하면 순서가 완전히 달라집니다.
//    두 버튼을 번갈아 누르며 이 앱이 왜 필요한지 보여 줄 수 있습니다. (시연 포인트)
//
//  ■ 상태 흐름
//    칩·버튼을 누르면 store.selectCategory(), store.setSortMode() 를 부르고,
//    저장소가 notifyListeners() 하면 ListenableBuilder 가 목록을 다시 그립니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../state/taste_store.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';
import 'taste_setup_screen.dart';

/// 홈 화면.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  /// 앱 전체가 공유하는 상태 저장소.
  final TasteStore store;

  /// [취향 수정]: 취향 설정 화면을 열고, 저장하면 저장소에 반영합니다.
  void _openTasteEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => TasteSetupScreen(
          initial: store.profile,
          isEditing: true,
          onSubmit: (profile) {
            store.setProfile(profile); // → 추천 목록이 다시 계산됨
            Navigator.of(routeContext).pop();
          },
        ),
      ),
    );
  }

  /// 가게 카드를 누르면 상세 화면을 엽니다.
  void _openDetail(BuildContext context, Place place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceDetailScreen(store: store, place: place),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('결', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: '내 취향 수정',
            onPressed: () => _openTasteEditor(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final items = store.recommendations;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              _MyTasteCard(summary: store.profile?.summary ?? ''),
              const SizedBox(height: 16),

              // ── 카테고리 칩 ──
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('전체'),
                    selected: store.category == null,
                    onSelected: (_) => store.selectCategory(null),
                  ),
                  for (final category in PlaceCategory.values)
                    ChoiceChip(
                      label: Text(category.label),
                      selected: store.category == category,
                      onSelected: (_) => store.selectCategory(category),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ── 정렬 방식 ──
              SegmentedButton<SortMode>(
                segments: [
                  for (final mode in SortMode.values)
                    ButtonSegment(value: mode, label: Text(mode.label)),
                ],
                selected: {store.sortMode},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    store.setSortMode(selection.first),
              ),
              const SizedBox(height: 8),
              Text(
                store.sortMode == SortMode.taste
                    ? '나와 비슷한 사람들의 별점과 분위기 일치도로 골랐어요.'
                    : '다른 앱처럼 모든 사람의 평균 별점으로 줄 세웠어요.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // ── 추천 목록 ──
              for (final stats in items)
                PlaceCard(
                  stats: stats,
                  onTap: () => _openDetail(context, stats.place),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 맨 위 '내 취향' 카드.
class _MyTasteCard extends StatelessWidget {
  const _MyTasteCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 취향',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '취향이 ${TasteStore.similarThreshold}% 이상 비슷한 사람들의 '
            '리뷰를 모아 보여 드려요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
