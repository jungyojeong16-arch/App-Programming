// =============================================================================
//  test/taste_store_test.dart - 취향 계산과 추천 순서를 화면 없이 검사하는 테스트
// =============================================================================
//
//  실행 방법:  flutter test
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:taste_match/data/sample_data.dart';
import 'package:taste_match/models/place.dart';
import 'package:taste_match/models/review.dart';
import 'package:taste_match/models/taste.dart';
import 'package:taste_match/state/taste_store.dart';

/// 사람이 적고 미니멀한 곳을 좋아하는 취향 (아이디어를 낸 사람의 취향)
const quietTaste =
    TasteProfile(crowd: 1, decor: 1, priority: 4, mood: 1, company: 1);

/// 북적이고 화려한 곳을 좋아하는 취향
const partyTaste =
    TasteProfile(crowd: 5, decor: 5, priority: 4, mood: 5, company: 5);

TasteStore makeStore(TasteProfile profile) => TasteStore(
      places: samplePlaces,
      reviews: sampleReviews,
      profile: profile,
    );

void main() {
  group('취향 일치도', () {
    test('똑같으면 100%, 정반대면 0%', () {
      const allLow =
          TasteProfile(crowd: 1, decor: 1, priority: 1, mood: 1, company: 1);
      const allHigh =
          TasteProfile(crowd: 5, decor: 5, priority: 5, mood: 5, company: 5);

      expect(quietTaste.similarityTo(quietTaste), 100);
      expect(allLow.similarityTo(allHigh), 0);
    });

    test('점수 차이의 합이 2 이면 90%', () {
      // (1,1,4,1,1) vs (1,1,3,2,1) → 차이 0+0+1+1+0 = 2 → (1 - 2/20) × 100
      const other =
          TasteProfile(crowd: 1, decor: 1, priority: 3, mood: 2, company: 1);
      expect(quietTaste.similarityTo(other), 90);
    });

    test('요약은 가운데(3점)인 축을 빼고 보여 준다', () {
      expect(quietTaste.summary, '한적함 · 미니멀 · 분위기 · 조용함 · 혼자');
      expect(const TasteProfile(crowd: 5).summary, '북적임');
      expect(const TasteProfile().summary, '아직 뚜렷한 취향이 없어요');
    });

    test('withValue 는 한 축만 바꾼 새 취향을 만든다', () {
      final changed = const TasteProfile().withValue(TasteTrait.decor, 1);
      expect(changed, const TasteProfile(decor: 1));
      // 범위를 벗어난 값은 1 ~ 5 로 맞춰진다
      expect(changed.withValue(TasteTrait.crowd, 9)[TasteTrait.crowd], 5);
    });
  });

  group('가게 계산 (조용한 취향 기준)', () {
    test('카페 여백: 전체 평점은 낮지만 비슷한 사람 평점은 높다', () {
      final store = makeStore(quietTaste);
      final stats = store.statsOf(store.placeById('yeobaek'));

      expect(stats.vibeMatch, 100);
      expect(stats.reviewCount, 9);
      expect(stats.overallRating, closeTo(3.78, 0.01)); // 9명 평균
      expect(stats.similarCount, 5); // 조용·미니멀 파 5명
      expect(stats.similarRating, closeTo(4.8, 0.001));
      expect(stats.matchScore, 98); // (100 + 4.8 × 20) ÷ 2
    });

    test('비슷한 사람 리뷰가 없으면 분위기 일치도만으로 추천한다 (콜드 스타트)', () {
      final store = makeStore(quietTaste);
      final stats = store.statsOf(store.placeById('teum'));

      expect(stats.reviewCount, 1);
      expect(stats.hasSimilarReviews, isFalse);
      expect(stats.similarRating, isNull);
      expect(stats.matchScore, stats.vibeMatch);
    });

    test('비슷한 사람만 고르면 그 사람들의 리뷰만 남는다', () {
      final store = makeStore(quietTaste);
      final place = store.placeById('yeobaek');

      final similar = store.reviewsOf(place, similarOnly: true);
      expect(similar, hasLength(5));
      expect(similar.every((r) => store.isSimilar(r.author)), isTrue);
      // 가장 비슷한 사람(고요한산책, 100%)의 리뷰가 맨 위
      expect(similar.first.author.nickname, '고요한산책');
    });
  });

  group('추천 순서', () {
    test('같은 데이터라도 취향에 따라 1위가 달라진다', () {
      expect(makeStore(quietTaste).recommendations.first.place.name, '카페 여백');
      expect(makeStore(partyTaste).recommendations.first.place.name, '루프탑 노을');
    });

    test('전체 평점순으로 바꾸면 핫플이 1위가 된다', () {
      final store = makeStore(quietTaste)..setSortMode(SortMode.rating);
      expect(store.recommendations.first.place.name, '플라워가든');
    });

    test('취향 맞춤순에서는 핫플이 아래로 내려간다', () {
      final names =
          makeStore(quietTaste).recommendations.map((s) => s.place.name);
      expect(names.take(4).toList(), ['카페 여백', '와인바 잔', '한그릇 식당', '북카페 서가']);
      expect(names.toList().indexOf('플라워가든'), greaterThan(5));
    });

    test('카테고리를 고르면 그 종류만 남는다', () {
      final store = makeStore(quietTaste)..selectCategory(PlaceCategory.bar);
      expect(
        store.recommendations.map((s) => s.place.name).toList(),
        ['와인바 잔', '루프탑 노을'],
      );
    });
  });

  group('상태 변경', () {
    test('내 리뷰는 언제나 비슷한 사람 리뷰로 계산되고, 화면에 알린다', () {
      final store = makeStore(quietTaste);
      var notified = 0;
      store.addListener(() => notified++);

      store.addReview(Review(
        placeId: 'teum',
        author: store.me,
        rating: 5,
        comment: '조용해서 좋아요',
        date: DateTime(2026, 10, 26),
      ));

      final stats = store.statsOf(store.placeById('teum'));
      expect(notified, 1);
      expect(stats.reviewCount, 2);
      expect(stats.similarCount, 1);
      expect(stats.similarRating, 5.0);
    });

    test('취향을 바꾸면 추천 순서가 다시 계산된다', () {
      final store = makeStore(quietTaste);
      expect(store.recommendations.first.place.name, '카페 여백');

      store.setProfile(partyTaste);
      expect(store.recommendations.first.place.name, '루프탑 노을');
    });
  });
}
