// =============================================================================
//  screens/taste_setup_screen.dart - 취향 설정 화면 (처음 실행 / 취향 수정)
// =============================================================================
//
//  ■ 화면 구성
//      사람이 얼마나 있는 곳이 좋아요?
//      한적함 쪽
//      한적함 ──●──────────── 북적임        ← 슬라이더 (1 ~ 5)
//      … (5개 축 반복)
//      ─────────────────────────────
//      지금 취향: 한적함 · 미니멀 · 분위기
//      [ 이 취향으로 추천 받기 ]
//
//  ■ 지역 상태(setState)와 공유 상태(TasteStore)
//    슬라이더를 움직이는 동안의 값(_draft)은 이 화면만 알면 되므로
//    이 화면의 setState 로 관리합니다. (가계부 앱의 입력 화면과 같은 방식)
//    버튼을 눌렀을 때만 onSubmit 으로 바깥에 알려서 저장소에 반영합니다.
//
//  ■ 이 화면은 저장소를 모릅니다
//    onSubmit 콜백만 받기 때문에, 처음 실행(main.dart)과 취향 수정(home_screen.dart)
//    두 곳에서 같은 화면을 다르게 쓸 수 있습니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/taste.dart';

/// 취향 설정 화면.
class TasteSetupScreen extends StatefulWidget {
  const TasteSetupScreen({
    super.key,
    required this.onSubmit,
    this.initial,
    this.isEditing = false,
  });

  /// 버튼을 눌렀을 때 고른 취향을 넘겨받을 함수.
  final ValueChanged<TasteProfile> onSubmit;

  /// 처음에 채워 둘 취향. 없으면 모든 축이 가운데(3점).
  final TasteProfile? initial;

  /// 취향 수정 화면으로 열었는지. (제목과 버튼 글자가 달라짐)
  final bool isEditing;

  @override
  State<TasteSetupScreen> createState() => _TasteSetupScreenState();
}

class _TasteSetupScreenState extends State<TasteSetupScreen> {
  /// 슬라이더로 고르고 있는 취향 (지역 상태).
  late TasteProfile _draft = widget.initial ?? const TasteProfile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '내 취향 수정' : '취향 알려주기'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          if (!widget.isEditing) ...[
            Text(
              '광고도, 평균 별점도 아닌\n나와 결이 맞는 사람들의 추천',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              '좋아하는 분위기를 알려 주시면, 취향이 비슷한 사람들이 '
              '직접 가 보고 남긴 별점과 리뷰로 찾아 드려요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],
          for (final trait in TasteTrait.values)
            _TraitSlider(
              trait: trait,
              value: _draft[trait],
              // 슬라이더를 움직이면 새 취향 객체를 만들고 화면을 다시 그립니다.
              onChanged: (value) =>
                  setState(() => _draft = _draft.withValue(trait, value)),
            ),
        ],
      ),

      // 아래쪽에 고정: 지금 고른 취향 요약 + 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '지금 취향: ${_draft.summary}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => widget.onSubmit(_draft),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(widget.isEditing ? '저장' : '이 취향으로 추천 받기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 한 축의 질문 + 슬라이더.
class _TraitSlider extends StatelessWidget {
  const _TraitSlider({
    required this.trait,
    required this.value,
    required this.onChanged,
  });

  final TasteTrait trait;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trait.question,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              trait.describe(value),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Slider(
              value: value.toDouble(),
              min: TasteProfile.minValue.toDouble(),
              max: TasteProfile.maxValue.toDouble(),
              divisions: TasteProfile.maxValue - TasteProfile.minValue,
              label: trait.describe(value),
              onChanged: (v) => onChanged(v.round()),
            ),
            Row(
              children: [
                Text(trait.low, style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(trait.high, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
