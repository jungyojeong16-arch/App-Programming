// =============================================================================
//  state/taste_store.dart - ★ 앱 전체가 함께 쓰는 상태 저장소
// =============================================================================
//
//  ■ 여기에 있는 상태
//    - 내 취향(profile)        : 취향 설정 화면에서 정함
//    - 가게 목록, 리뷰 목록     : 리뷰를 쓰면 늘어남
//    - 고른 카테고리, 정렬 방식 : 홈 화면의 칩과 버튼으로 바꿈
//
//    가계부 앱과 같은 ChangeNotifier 방식입니다. 상태를 바꾸는 메서드는
//    마지막에 notifyListeners() 를 불러서 구독 중인 화면을 다시 그리게 합니다.
//
//  ■ 이 앱의 핵심 계산 (모두 "파생 데이터" = 저장하지 않고 매번 계산)
//
//      내 취향 ──┬── 리뷰어 취향과 비교 → 일치도 75% 이상이면 "비슷한 사람"
//                │                         └─▶ 그 사람들 별점만 평균 = 비슷한 사람 평점
//                └── 가게 분위기와 비교 → 분위기 일치도
//                                          └─▶ 둘을 합쳐 추천 점수 (place_stats.dart)
//
//    내 취향을 바꾸면 이 값들이 전부 달라지고, 추천 순서도 바로 바뀝니다.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/place.dart';
import '../models/place_stats.dart';
import '../models/review.dart';
import '../models/taste.dart';

/// 홈 화면의 정렬 방식.
enum SortMode {
  taste('취향 맞춤순'),
  rating('전체 평점순');

  const SortMode(this.label);

  final String label;
}

/// 앱 전체가 공유하는 상태 저장소.
class TasteStore extends ChangeNotifier {
  /// 저장소를 만듭니다.
  /// [profile] 을 비워 두면 앱이 취향 설정 화면부터 시작합니다.
  TasteStore({
    required List<Place> places,
    required List<Review> reviews,
    TasteProfile? profile,
  })  : _places = List.of(places),
        _reviews = List.of(reviews),
        _profile = profile;

  /// 예시 데이터(sample_data.dart)로 저장소를 만듭니다.
  factory TasteStore.withSamples() =>
      TasteStore(places: samplePlaces, reviews: sampleReviews);

  /// 취향 일치도가 이 값(%) 이상이면 "나와 비슷한 사람"으로 봅니다.
  static const int similarThreshold = 75;

  // ---------------------------------------------------------------------------
  // 상태 - 바깥에서는 읽기만 하고, 바꿀 때는 아래 메서드를 사용
  // ---------------------------------------------------------------------------

  final List<Place> _places;
  final List<Review> _reviews;
  TasteProfile? _profile;
  PlaceCategory? _category; // null 이면 '전체'
  SortMode _sortMode = SortMode.taste;

  /// 내 취향. 아직 정하지 않았으면 null.
  TasteProfile? get profile => _profile;

  /// 취향을 정했는지. false 면 취향 설정 화면을 보여 줍니다.
  bool get hasProfile => _profile != null;

  /// 고른 카테고리. null 이면 전체.
  PlaceCategory? get category => _category;

  /// 정렬 방식.
  SortMode get sortMode => _sortMode;

  /// 계산에 쓸 내 취향. 아직 안 정했으면 가운데(3점) 취향으로 계산합니다.
  TasteProfile get _myTaste => _profile ?? const TasteProfile();

  /// 리뷰를 쓸 때 작성자로 넣을 "나".
  Reviewer get me =>
      Reviewer(id: Reviewer.meId, nickname: '나', taste: _myTaste);

  // ---------------------------------------------------------------------------
  // 파생 데이터 - 상태로부터 매번 계산
  // ---------------------------------------------------------------------------

  /// 리뷰어와 나의 취향 일치도 (0 ~ 100). 내가 쓴 리뷰는 100 입니다.
  int similarityTo(Reviewer reviewer) =>
      reviewer.isMe ? 100 : _myTaste.similarityTo(reviewer.taste);

  /// 나와 취향이 비슷한 사람인지.
  bool isSimilar(Reviewer reviewer) =>
      similarityTo(reviewer) >= similarThreshold;

  /// id 로 가게 찾기.
  Place placeById(String id) => _places.firstWhere((p) => p.id == id);

  /// 한 가게의 리뷰. 나와 취향이 비슷한 사람의 리뷰가 위로 오도록 정렬합니다.
  /// [similarOnly] 가 true 면 비슷한 사람의 리뷰만 돌려줍니다.
  List<Review> reviewsOf(Place place, {bool similarOnly = false}) {
    final list = _reviews
        .where((r) => r.placeId == place.id)
        .where((r) => !similarOnly || isSimilar(r.author))
        .toList();
    list.sort((a, b) {
      final bySimilarity =
          similarityTo(b.author).compareTo(similarityTo(a.author));
      return bySimilarity != 0 ? bySimilarity : b.date.compareTo(a.date);
    });
    return list;
  }

  /// 한 가게를 지금 내 취향 기준으로 계산합니다.
  PlaceStats statsOf(Place place) {
    final all = reviewsOf(place);
    final similar = all.where((r) => isSimilar(r.author)).toList();
    return PlaceStats(
      place: place,
      vibeMatch: _myTaste.similarityTo(place.vibe),
      reviewCount: all.length,
      overallRating: _average(all),
      similarCount: similar.length,
      similarRating: _average(similar),
    );
  }

  /// 홈 화면에 보여 줄 추천 목록. 고른 카테고리만, 고른 정렬 방식으로.
  List<PlaceStats> get recommendations {
    final list = _places
        .where((p) => _category == null || p.category == _category)
        .map(statsOf)
        .toList();

    switch (_sortMode) {
      case SortMode.taste:
        // 추천 점수가 높은 순 → 같으면 전체 평점이 높은 순
        list.sort((a, b) {
          final byScore = b.matchScore.compareTo(a.matchScore);
          return byScore != 0
              ? byScore
              : (b.overallRating ?? 0).compareTo(a.overallRating ?? 0);
        });
      case SortMode.rating:
        // 다른 앱처럼 전체 평점이 높은 순 → 같으면 추천 점수가 높은 순
        list.sort((a, b) {
          final byRating =
              (b.overallRating ?? 0).compareTo(a.overallRating ?? 0);
          return byRating != 0 ? byRating : b.matchScore.compareTo(a.matchScore);
        });
    }
    return list;
  }

  // ---------------------------------------------------------------------------
  // 상태를 바꾸는 메서드 - 바꾼 뒤에는 반드시 notifyListeners()!
  // ---------------------------------------------------------------------------

  /// 내 취향을 정합니다(바꿉니다). 추천 순서가 전부 다시 계산됩니다.
  void setProfile(TasteProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  /// 카테고리를 고릅니다. null 이면 전체.
  void selectCategory(PlaceCategory? category) {
    _category = category;
    notifyListeners();
  }

  /// 정렬 방식을 바꿉니다.
  void setSortMode(SortMode mode) {
    _sortMode = mode;
    notifyListeners();
  }

  /// 리뷰를 추가합니다.
  void addReview(Review review) {
    _reviews.add(review);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 내부 도우미
  // ---------------------------------------------------------------------------

  /// 별점 평균. 리뷰가 없으면 null.
  static double? _average(List<Review> reviews) {
    if (reviews.isEmpty) return null;
    final sum = reviews.fold(0, (total, r) => total + r.rating);
    return sum / reviews.length;
  }
}
