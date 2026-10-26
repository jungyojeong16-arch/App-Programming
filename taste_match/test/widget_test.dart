// =============================================================================
//  test/widget_test.dart - 실제 화면을 띄워서 사용자처럼 눌러 보는 테스트
// =============================================================================
//
//  확인하는 내용
//    1) 처음 실행하면 취향 설정 화면 → 슬라이더 조절 → [추천 받기] → 홈 화면
//    2) 홈 화면에서 [전체 평점순]을 누르면 1위가 바뀐다
//    3) 카테고리 칩으로 거를 수 있다
//    4) 리뷰를 쓰면 상세 화면과 홈 화면이 함께 바뀐다
//
//  실행 방법:  flutter test
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_match/data/sample_data.dart';
import 'package:taste_match/main.dart';
import 'package:taste_match/models/taste.dart';
import 'package:taste_match/state/taste_store.dart';
import 'package:taste_match/widgets/place_card.dart';

const quietTaste =
    TasteProfile(crowd: 1, decor: 1, priority: 4, mood: 1, company: 1);

/// 화면에 보이는 첫 번째 가게 카드의 이름.
String firstCardName(WidgetTester tester) =>
    tester.widget<PlaceCard>(find.byType(PlaceCard).first).stats.place.name;

void main() {
  testWidgets('처음 실행하면 취향을 고른 뒤 홈 화면으로 간다', (tester) async {
    final store = TasteStore.withSamples(); // 취향을 아직 안 정한 상태
    await tester.pumpWidget(TasteMatchApp(store: store));

    expect(find.text('취향 알려주기'), findsOneWidget);
    expect(find.text('지금 취향: 아직 뚜렷한 취향이 없어요'), findsOneWidget);

    // 첫 번째 슬라이더(붐빔)를 왼쪽 끝까지 밀기
    await tester.drag(find.byType(Slider).first, const Offset(-1000, 0));
    await tester.pumpAndSettle();

    expect(find.text('무조건 한적함'), findsOneWidget);
    expect(find.text('지금 취향: 한적함'), findsOneWidget);

    await tester.tap(find.text('이 취향으로 추천 받기'));
    await tester.pumpAndSettle();

    // 홈 화면으로 바뀌고, 고른 취향이 저장소에 들어갔다
    expect(find.text('결'), findsOneWidget);
    expect(find.byType(PlaceCard), findsWidgets);
    expect(store.profile?[TasteTrait.crowd], 1);
  });

  testWidgets('정렬 방식을 바꾸면 1위가 달라진다', (tester) async {
    final store = TasteStore(
      places: samplePlaces,
      reviews: sampleReviews,
      profile: quietTaste,
    );
    await tester.pumpWidget(TasteMatchApp(store: store));

    // 취향 맞춤순: 조용·미니멀 카페가 1위
    expect(firstCardName(tester), '카페 여백');
    expect(find.text('취향 98%'), findsOneWidget);
    expect(find.text('비슷한 사람 ★ 4.8 (5명)'), findsOneWidget);
    expect(find.text('전체 ★ 3.8 (9명)'), findsOneWidget);

    // 전체 평점순: 다른 앱처럼 핫플이 1위
    await tester.tap(find.text('전체 평점순'));
    await tester.pumpAndSettle();
    expect(firstCardName(tester), '플라워가든');
  });

  testWidgets('카테고리 칩으로 술집만 볼 수 있다', (tester) async {
    final store = TasteStore(
      places: samplePlaces,
      reviews: sampleReviews,
      profile: quietTaste,
    );
    await tester.pumpWidget(TasteMatchApp(store: store));

    await tester.tap(find.text('술집'));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceCard), findsNWidgets(2));
    expect(firstCardName(tester), '와인바 잔');
  });

  testWidgets('리뷰를 쓰면 상세 화면과 홈 화면이 함께 바뀐다', (tester) async {
    final store = TasteStore(
      places: samplePlaces,
      reviews: sampleReviews,
      profile: quietTaste,
    );
    await tester.pumpWidget(TasteMatchApp(store: store));

    // 카페만 보이게 한 뒤, 새로 생겨서 비슷한 취향 리뷰가 없는 '카페 틈' 열기
    await tester.tap(find.text('카페'));
    await tester.pumpAndSettle();
    expect(find.text('비슷한 취향 리뷰 없음 · 분위기로 추천'), findsOneWidget);

    await tester.ensureVisible(find.text('카페 틈'));
    await tester.tap(find.text('카페 틈'));
    await tester.pumpAndSettle();

    expect(find.text('리뷰 0개'), findsOneWidget);
    expect(find.textContaining('아직 나와 비슷한 취향의 리뷰가 없어요'), findsOneWidget);

    // [리뷰 쓰기] → 아무것도 안 고르고 [등록] → 안내 문구
    await tester.tap(find.text('리뷰 쓰기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('등록'));
    await tester.pump();
    expect(find.text('별점을 골라 주세요'), findsOneWidget);
    expect(find.text('코멘트를 적어 주세요'), findsOneWidget);

    // 별 5개 + 코멘트 → [등록]
    await tester.tap(find.byTooltip('별 5개'));
    await tester.enterText(find.byType(TextFormField), '조용해서 좋아요');
    await tester.tap(find.text('등록'));
    await tester.pumpAndSettle();

    // 상세 화면: 내 리뷰가 보인다
    expect(find.text('리뷰 1개'), findsOneWidget);
    expect(find.text('내 리뷰'), findsOneWidget);
    expect(find.text('조용해서 좋아요'), findsOneWidget);

    // 홈 화면으로 돌아가면 카드도 바뀌어 있다
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('비슷한 사람 ★ 5.0 (1명)'), findsOneWidget);
    expect(find.text('비슷한 취향 리뷰 없음 · 분위기로 추천'), findsNothing);
  });
}
