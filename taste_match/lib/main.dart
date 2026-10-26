// =============================================================================
//  결 (Gyeol) - 나와 결이 맞는 사람들의 리뷰로 음식점·카페 찾기 (프로토타입)
// =============================================================================
//
//  ■ 어떤 앱인가요?
//    요즘 앱은 광고나 "모든 사람의 평균 별점"으로 가게를 추천합니다.
//    그런데 사람이 적고 미니멀한 곳을 좋아하는 사람과,
//    북적이고 화려한 곳을 좋아하는 사람에게 좋은 가게는 다릅니다.
//
//    이 앱은 내 취향을 먼저 알려 주면,
//      ① 나와 취향이 비슷한 사람들을 찾고
//      ② 그 사람들이 직접 가 보고 남긴 별점과 리뷰만 모아서
//      ③ 나에게 맞는 가게를 추천합니다.
//
//  ■ 화면 흐름
//
//      TasteSetupScreen (처음 실행: 취향 5가지 고르기)
//           │ [이 취향으로 추천 받기]  → store.setProfile()
//           ▼
//      HomeScreen (추천 목록, 카테고리, 정렬)  ◀──── [취향 수정] 으로 다시 설정
//           │ 가게 카드 탭
//           ▼
//      PlaceDetailScreen (평점 비교, 분위기 비교, 리뷰)
//           │ [리뷰 쓰기]
//           ▼
//      WriteReviewScreen → Navigator.pop(새 리뷰) → store.addReview()
//
//  ■ 상태 관리: 가계부 앱과 같은 ChangeNotifier 방식
//    - 공유 상태 (TasteStore)    : 내 취향, 리뷰 목록, 카테고리, 정렬 방식
//    - 지역 상태 (각 화면 setState): 움직이는 중인 슬라이더 값, 입력 중인 리뷰,
//                                  "나와 비슷한 사람만" 체크
//
//  ■ 파일 구성
//    lib/main.dart                         앱 시작점 (이 파일)
//    lib/models/taste.dart                 ★ 취향 5개 축 + 일치도 계산
//    lib/models/place.dart                 가게
//    lib/models/review.dart                리뷰어, 리뷰
//    lib/models/place_stats.dart           ★ 가게별 계산 결과 + 추천 점수
//    lib/state/taste_store.dart            ★ 상태 저장소 (ChangeNotifier)
//    lib/data/sample_data.dart             예시 데이터 (리뷰어 12명, 가게 9곳)
//    lib/screens/taste_setup_screen.dart   취향 설정 화면
//    lib/screens/home_screen.dart          홈 (추천 목록)
//    lib/screens/place_detail_screen.dart  가게 상세
//    lib/screens/write_review_screen.dart  리뷰 쓰기
//    lib/widgets/…                         카드, 배지, 별점 등 화면 부품
//
//  ■ 지금은 프로토타입이라 없는 것 (다음 단계)
//    로그인, 서버/DB 저장(앱을 끄면 새 리뷰가 사라짐), 지도, 방문 인증
// =============================================================================

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/taste_setup_screen.dart';
import 'state/taste_store.dart';

/// 앱의 진입점.
void main() {
  // 앱 전체에서 함께 쓸 상태 저장소를 하나 만들어서 앱에 넘겨줍니다.
  runApp(TasteMatchApp(store: TasteStore.withSamples()));
}

/// 앱 전체를 감싸는 루트 위젯.
///
/// 저장소를 생성자로 받기 때문에, 테스트에서는 원하는 상태(예: 취향을 이미
/// 정한 상태)의 저장소를 넣어서 앱을 띄울 수 있습니다.
class TasteMatchApp extends StatelessWidget {
  const TasteMatchApp({super.key, required this.store});

  final TasteStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '결',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7A5C45)),
        scaffoldBackgroundColor: const Color(0xFFFBF9F7),
        useMaterial3: true,
      ),

      // 취향을 아직 안 정했으면 취향 설정 화면, 정했으면 홈 화면.
      // 취향 설정 화면에서 [추천 받기]를 누르면 store.setProfile() →
      // notifyListeners() → 이 builder 가 다시 실행되어 홈 화면으로 바뀝니다.
      home: ListenableBuilder(
        listenable: store,
        builder: (context, _) => store.hasProfile
            ? HomeScreen(store: store)
            : TasteSetupScreen(onSubmit: store.setProfile),
      ),
    );
  }
}
