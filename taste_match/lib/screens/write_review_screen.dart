// =============================================================================
//  screens/write_review_screen.dart - 리뷰 쓰기 화면
// =============================================================================
//
//  ■ 화면 구성
//      카페 여백, 어떠셨어요?
//      ☆ ☆ ☆ ☆ ☆                 ← 별을 눌러 별점 고르기
//      [ 코멘트                 ]
//      이 리뷰는 내 취향(…)과 함께 저장돼요.
//      [ 등록 ]
//
//  ■ 가계부 앱의 입력 화면과 같은 방식
//    - 입력 중인 별점과 코멘트는 이 화면의 지역 상태(setState)
//    - [등록]을 누르면 Navigator.pop(context, 새 리뷰) 로 결과만 돌려줍니다.
//      이 화면은 저장소를 모릅니다.
//
//  ■ 리뷰에 "내 취향"이 함께 저장되는 이유
//    작성자(author)에 지금 내 취향이 들어 있어서, 다른 사람이 이 리뷰를 볼 때
//    "나와 몇 % 비슷한 사람이 쓴 리뷰인지" 계산할 수 있습니다.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/review.dart';

/// 리뷰 쓰기 화면. [등록]을 누르면 새 [Review] 를 돌려줍니다.
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({
    super.key,
    required this.place,
    required this.author,
  });

  /// 리뷰를 쓸 가게.
  final Place place;

  /// 리뷰 작성자 (나).
  final Reviewer author;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  /// 고른 별점. 0 이면 아직 안 고름.
  int _rating = 0;

  /// 별점을 고르지 않고 [등록]을 눌렀는지 (안내 문구 표시용).
  bool _showRatingError = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final commentOk = _formKey.currentState!.validate();
    setState(() => _showRatingError = _rating == 0);
    if (!commentOk || _rating == 0) return;

    Navigator.of(context).pop(
      Review(
        placeId: widget.place.id,
        author: widget.author,
        rating: _rating,
        comment: _commentController.text.trim(),
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 쓰기'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${widget.place.name}, 어떠셨어요?',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            // ── 별점 ──
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    tooltip: '별 $i개',
                    iconSize: 36,
                    onPressed: () => setState(() {
                      _rating = i;
                      _showRatingError = false;
                    }),
                    icon: Icon(
                      i <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFF5A524),
                    ),
                  ),
              ],
            ),
            if (_showRatingError)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  '별점을 골라 주세요',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),

            // ── 코멘트 ──
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '코멘트',
                hintText: '분위기, 맛, 좋았던 점을 자유롭게 적어 주세요',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? '코멘트를 적어 주세요'
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              '이 리뷰는 내 취향(${widget.author.taste.summary})과 함께 저장돼서, '
              '취향이 비슷한 사람들에게 먼저 보여요.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('등록'),
          ),
        ),
      ),
    );
  }
}
