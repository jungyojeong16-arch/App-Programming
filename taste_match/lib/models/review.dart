// =============================================================================
//  models/review.dart - 리뷰를 쓴 사람(Reviewer)과 리뷰(Review)
// =============================================================================
//
//  ■ 리뷰어에게도 취향이 있습니다
//    다른 앱은 "누가 썼는지"와 상관없이 별점을 평균 냅니다.
//    이 앱은 리뷰어의 취향(taste)을 함께 저장해 두고,
//    "나와 취향이 비슷한 사람"이 쓴 리뷰만 골라서 평균을 냅니다.
// =============================================================================

import 'taste.dart';

/// 리뷰를 쓴 사람.
class Reviewer {
  const Reviewer({
    required this.id,
    required this.nickname,
    required this.taste,
  });

  /// "나"를 뜻하는 id. 내가 쓴 리뷰는 언제나 취향 일치 100% 로 봅니다.
  static const String meId = 'me';

  final String id;

  /// 화면에 보여 줄 이름. 예) '고요한산책'
  final String nickname;

  /// 이 사람의 취향.
  final TasteProfile taste;

  /// 내가 쓴 리뷰인지.
  bool get isMe => id == meId;
}

/// 리뷰 한 건.
class Review {
  const Review({
    required this.placeId,
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });

  /// 어느 가게의 리뷰인지 (Place.id).
  final String placeId;

  /// 쓴 사람.
  final Reviewer author;

  /// 별점 1 ~ 5.
  final int rating;

  /// 코멘트.
  final String comment;

  /// 쓴 날짜.
  final DateTime date;
}
