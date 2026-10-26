// =============================================================================
//  models/place_stats.dart - 한 가게를 "나" 기준으로 계산한 결과
// =============================================================================
//
//  ■ 왜 따로 만들었나요?
//    같은 가게라도 보는 사람의 취향에 따라 숫자가 달라집니다.
//      - 조용한 걸 좋아하는 사람에게 '카페 여백'은 취향 98%
//      - 북적이는 걸 좋아하는 사람에게는 취향 20%대
//    그래서 Place(가게 정보)에 저장하지 않고, 저장소(TasteStore)가
//    "지금 내 취향"으로 그때그때 계산해서 이 객체로 돌려줍니다.
//
//  ■ 추천 점수(matchScore) 계산
//    ① 분위기 일치도 : 내 취향 ↔ 가게 분위기 (0 ~ 100)
//    ② 비슷한 사람 평점: 나와 취향이 비슷한 사람들의 별점 평균 → 100점 만점으로 (× 20)
//
//      비슷한 사람 리뷰가 있으면  →  (① + ②) ÷ 2
//      아직 하나도 없으면         →  ① 만 사용
//
//    두 번째 경우가 "처음엔 리뷰가 부족한 문제(콜드 스타트)"에 대한 해결책입니다.
//    리뷰가 쌓이기 전에는 가게 분위기로 추천하고,
//    쌓이면 비슷한 사람들의 실제 경험을 함께 반영합니다.
// =============================================================================

import 'place.dart';

/// 한 가게를 지금 내 취향 기준으로 계산한 결과.
class PlaceStats {
  const PlaceStats({
    required this.place,
    required this.vibeMatch,
    required this.reviewCount,
    required this.overallRating,
    required this.similarCount,
    required this.similarRating,
  });

  /// 어느 가게인지.
  final Place place;

  /// 내 취향 ↔ 가게 분위기 일치도 (0 ~ 100).
  final int vibeMatch;

  /// 전체 리뷰 수.
  final int reviewCount;

  /// 전체 별점 평균. 리뷰가 없으면 null.
  final double? overallRating;

  /// 나와 취향이 비슷한 사람의 리뷰 수.
  final int similarCount;

  /// 나와 취향이 비슷한 사람의 별점 평균. 그런 리뷰가 없으면 null.
  final double? similarRating;

  /// 비슷한 사람의 리뷰가 하나라도 있는지.
  bool get hasSimilarReviews => similarRating != null;

  /// 추천 점수 (0 ~ 100). 계산 방법은 파일 맨 위 설명을 참고하세요.
  int get matchScore {
    final similar = similarRating;
    if (similar == null) return vibeMatch;
    return ((vibeMatch + similar * 20) / 2).round();
  }
}
