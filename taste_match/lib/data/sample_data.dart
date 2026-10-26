// =============================================================================
//  data/sample_data.dart - 프로토타입용 예시 데이터 (가짜 데이터)
// =============================================================================
//
//  서버 없이도 앱을 시연할 수 있도록 리뷰어, 가게, 리뷰를 코드에 넣어 두었습니다.
//  나중에 서버나 Firebase 를 붙이면 이 파일 대신 거기서 불러오면 됩니다.
//
//  ■ 데이터를 이렇게 짠 이유 (시연 시나리오)
//    리뷰어는 두 무리로 나뉩니다.
//      - 조용·미니멀 파 5명 : 고요한산책, 미니멀리스트, 혼밥러, 책읽는곰, 조용한커피
//      - 북적·화려 파 7명   : 파티피플, 인스타감성, 맛집헌터, 가성비왕,
//                            주말나들이, 핫플수집가, 친구랑맛집
//    북적·화려 파가 더 많아서 "전체 평점"은 플라워가든 같은 핫플이 높습니다.
//    하지만 내 취향을 "한적함·미니멀"로 정하면 카페 여백이 1위로 올라옵니다.
// =============================================================================

import '../models/place.dart';
import '../models/review.dart';
import '../models/taste.dart';

// ── 리뷰어 ──────────────────────────────────────────────────────────────────
//  TasteProfile(붐빔, 인테리어, 중요한 것, 소리, 누구와)  1 = 왼쪽, 5 = 오른쪽

// 조용·미니멀 파
const _quietWalker = Reviewer(
  id: 'r1',
  nickname: '고요한산책',
  taste: TasteProfile(crowd: 1, decor: 1, priority: 4, mood: 1, company: 1),
);
const _minimalist = Reviewer(
  id: 'r2',
  nickname: '미니멀리스트',
  taste: TasteProfile(crowd: 1, decor: 1, priority: 3, mood: 2, company: 1),
);
const _soloDiner = Reviewer(
  id: 'r3',
  nickname: '혼밥러',
  taste: TasteProfile(crowd: 1, decor: 2, priority: 2, mood: 1, company: 1),
);
const _bookBear = Reviewer(
  id: 'r4',
  nickname: '책읽는곰',
  taste: TasteProfile(crowd: 2, decor: 1, priority: 4, mood: 1, company: 2),
);
const _quietCoffee = Reviewer(
  id: 'r5',
  nickname: '조용한커피',
  taste: TasteProfile(crowd: 2, decor: 2, priority: 3, mood: 2, company: 2),
);

// 북적·화려 파
const _partyPeople = Reviewer(
  id: 'r6',
  nickname: '파티피플',
  taste: TasteProfile(crowd: 5, decor: 5, priority: 4, mood: 5, company: 5),
);
const _instaMood = Reviewer(
  id: 'r7',
  nickname: '인스타감성',
  taste: TasteProfile(crowd: 4, decor: 5, priority: 5, mood: 3, company: 3),
);
const _foodHunter = Reviewer(
  id: 'r8',
  nickname: '맛집헌터',
  taste: TasteProfile(crowd: 4, decor: 3, priority: 1, mood: 4, company: 4),
);
const _bargainKing = Reviewer(
  id: 'r9',
  nickname: '가성비왕',
  taste: TasteProfile(crowd: 3, decor: 2, priority: 1, mood: 3, company: 3),
);
const _weekender = Reviewer(
  id: 'r10',
  nickname: '주말나들이',
  taste: TasteProfile(crowd: 4, decor: 4, priority: 4, mood: 4, company: 4),
);
const _hotplace = Reviewer(
  id: 'r11',
  nickname: '핫플수집가',
  taste: TasteProfile(crowd: 5, decor: 4, priority: 4, mood: 4, company: 4),
);
const _withFriends = Reviewer(
  id: 'r12',
  nickname: '친구랑맛집',
  taste: TasteProfile(crowd: 4, decor: 3, priority: 2, mood: 4, company: 5),
);

/// 예시 리뷰어 전체.
const List<Reviewer> sampleReviewers = [
  _quietWalker,
  _minimalist,
  _soloDiner,
  _bookBear,
  _quietCoffee,
  _partyPeople,
  _instaMood,
  _foodHunter,
  _bargainKing,
  _weekender,
  _hotplace,
  _withFriends,
];

// ── 가게 ────────────────────────────────────────────────────────────────────

/// 예시 가게 전체.
const List<Place> samplePlaces = [
  Place(
    id: 'yeobaek',
    name: '카페 여백',
    category: PlaceCategory.cafe,
    area: '성수동',
    description: '흰 벽과 나무 테이블 몇 개뿐인 작은 카페',
    vibe: TasteProfile(crowd: 1, decor: 1, priority: 4, mood: 1, company: 1),
  ),
  Place(
    id: 'flower',
    name: '플라워가든',
    category: PlaceCategory.cafe,
    area: '성수동',
    description: '천장까지 꽃으로 꾸민 요즘 가장 핫한 카페',
    vibe: TasteProfile(crowd: 5, decor: 5, priority: 5, mood: 4, company: 4),
  ),
  Place(
    id: 'seoga',
    name: '북카페 서가',
    category: PlaceCategory.cafe,
    area: '망원동',
    description: '책장으로 둘러싸인 조용한 북카페',
    vibe: TasteProfile(crowd: 1, decor: 2, priority: 3, mood: 1, company: 1),
  ),
  Place(
    id: 'teum',
    name: '카페 틈',
    category: PlaceCategory.cafe,
    area: '연남동',
    description: '문을 연 지 일주일 된 골목 안 작은 카페',
    vibe: TasteProfile(crowd: 2, decor: 1, priority: 3, mood: 2, company: 1),
  ),
  Place(
    id: 'noodle',
    name: '골목 국수집',
    category: PlaceCategory.restaurant,
    area: '망원동',
    description: '점심마다 줄 서는 6천 원 잔치국수',
    vibe: TasteProfile(crowd: 4, decor: 2, priority: 1, mood: 4, company: 3),
  ),
  Place(
    id: 'hangeureut',
    name: '한그릇 식당',
    category: PlaceCategory.restaurant,
    area: '연남동',
    description: '1인석 바 테이블만 있는 정갈한 한식 정식집',
    vibe: TasteProfile(crowd: 1, decor: 1, priority: 2, mood: 1, company: 1),
  ),
  Place(
    id: 'brunch',
    name: '브런치하우스',
    category: PlaceCategory.restaurant,
    area: '성수동',
    description: '주말이면 웨이팅이 긴 감성 브런치 맛집',
    vibe: TasteProfile(crowd: 4, decor: 4, priority: 4, mood: 3, company: 4),
  ),
  Place(
    id: 'noeul',
    name: '루프탑 노을',
    category: PlaceCategory.bar,
    area: '연남동',
    description: '노을 맛집 루프탑 펍, 금요일엔 DJ 공연',
    vibe: TasteProfile(crowd: 5, decor: 4, priority: 4, mood: 5, company: 5),
  ),
  Place(
    id: 'jan',
    name: '와인바 잔',
    category: PlaceCategory.bar,
    area: '망원동',
    description: '좌석 여덟 개, 잔잔한 재즈가 흐르는 와인바',
    vibe: TasteProfile(crowd: 2, decor: 1, priority: 4, mood: 1, company: 2),
  ),
];

// ── 리뷰 ────────────────────────────────────────────────────────────────────

/// 리뷰를 짧게 만드는 도우미. 날짜는 모두 2026년 10월입니다.
Review _review(
  String placeId,
  Reviewer author,
  int rating,
  String comment,
  int day,
) =>
    Review(
      placeId: placeId,
      author: author,
      rating: rating,
      comment: comment,
      date: DateTime(2026, 10, day),
    );

/// 예시 리뷰 전체.
final List<Review> sampleReviews = [
  // 카페 여백: 조용·미니멀 파는 극찬, 북적·화려 파는 심심하다는 평
  _review('yeobaek', _quietWalker, 5, '손님이 두세 팀뿐이라 책 한 권 다 읽고 왔어요.', 3),
  _review('yeobaek', _minimalist, 5, '군더더기 없는 인테리어. 딱 제 스타일입니다.', 5),
  _review('yeobaek', _bookBear, 5, '음악도 작게 틀어 줘서 집중이 잘 돼요.', 8),
  _review('yeobaek', _quietCoffee, 4, '커피 맛은 평범한데 분위기가 다 했어요.', 11),
  _review('yeobaek', _soloDiner, 5, '혼자 가도 전혀 눈치 안 보이는 곳.', 14),
  _review('yeobaek', _partyPeople, 2, '너무 조용해서 대화하기 눈치 보였어요.', 6),
  _review('yeobaek', _foodHunter, 2, '사진 찍을 게 별로 없고 메뉴도 적어요.', 9),
  _review('yeobaek', _hotplace, 3, '깔끔하긴 한데 특별한 건 없네요.', 12),
  _review('yeobaek', _instaMood, 3, '흰 벽이라 사진은 잘 나오는데 좀 심심해요.', 15),

  // 플라워가든: 전체 평점 1위 핫플
  _review('flower', _partyPeople, 5, '들어가자마자 와! 소리 나와요. 친구들이랑 최고.', 2),
  _review('flower', _instaMood, 5, '어디서 찍어도 인생샷. 웨이팅할 가치 있어요.', 4),
  _review('flower', _weekender, 5, '주말 나들이 코스로 완벽했어요.', 6),
  _review('flower', _hotplace, 5, '요즘 성수 핫플 중 원픽.', 9),
  _review('flower', _withFriends, 5, '넷이서 갔는데 자리도 넓고 신났어요.', 12),
  _review('flower', _foodHunter, 4, '디저트는 무난, 분위기 점수가 큼.', 15),
  _review('flower', _bargainKing, 4, '비싸지만 한 번쯤은 가 볼 만해요.', 17),
  _review('flower', _quietWalker, 2, '사람이 너무 많아서 30분 만에 나왔어요.', 10),
  _review('flower', _quietCoffee, 3, '예쁘긴 한데 정신이 없어요.', 18),

  // 북카페 서가
  _review('seoga', _bookBear, 5, '책 고르는 재미가 있어요. 오래 앉아 있어도 편해요.', 4),
  _review('seoga', _quietCoffee, 4, '평일 오후가 특히 한적해요.', 7),
  _review('seoga', _quietWalker, 4, '조용해서 좋은데 의자가 조금 딱딱해요.', 13),
  _review('seoga', _instaMood, 2, '어둡고 사진이 안 나와요.', 8),
  _review('seoga', _hotplace, 2, '좀 지루했어요.', 16),

  // 카페 틈: 새로 생겨서 리뷰가 거의 없는 곳 (콜드 스타트 예시)
  _review('teum', _partyPeople, 3, '작고 조용해요. 저는 좀 심심했어요.', 20),

  // 골목 국수집
  _review('noodle', _foodHunter, 5, '이 가격에 이 맛이면 줄 설 만합니다.', 3),
  _review('noodle', _bargainKing, 5, '6천 원에 배 터지게 먹었어요.', 6),
  _review('noodle', _withFriends, 4, '시끌벅적한 게 오히려 정겨워요.', 9),
  _review('noodle', _weekender, 4, '웨이팅이 있지만 회전이 빨라요.', 12),
  _review('noodle', _partyPeople, 4, '친구들이랑 후루룩 먹기 좋아요.', 15),
  _review('noodle', _soloDiner, 3, '맛은 좋은데 합석이 부담스러웠어요.', 18),

  // 한그릇 식당
  _review('hangeureut', _soloDiner, 5, '혼밥 성지. 1인 바 좌석이 정말 편해요.', 2),
  _review('hangeureut', _quietWalker, 5, '조용히 정갈한 한 끼 먹고 싶을 때 와요.', 7),
  _review('hangeureut', _minimalist, 4, '반찬 하나하나 깔끔해요.', 11),
  _review('hangeureut', _bargainKing, 4, '정식 가격 생각하면 괜찮아요.', 14),
  _review('hangeureut', _partyPeople, 2, '여럿이 앉을 자리가 없어요.', 17),

  // 브런치하우스
  _review('brunch', _instaMood, 5, '플레이팅이 예뻐서 사진 찍기 바빴어요.', 4),
  _review('brunch', _hotplace, 5, '주말 브런치는 여기죠.', 8),
  _review('brunch', _weekender, 4, '웨이팅 1시간, 그래도 맛있어요.', 11),
  _review('brunch', _withFriends, 4, '단체석이 있어서 좋았어요.', 14),
  _review('brunch', _minimalist, 3, '음식은 괜찮은데 너무 붐벼요.', 16),
  _review('brunch', _bargainKing, 2, '양에 비해 비싸요.', 19),

  // 루프탑 노을
  _review('noeul', _partyPeople, 5, '금요일 DJ 타임 최고! 또 갈 거예요.', 5),
  _review('noeul', _weekender, 5, '노을 질 때 맞춰 가면 분위기 미쳤어요.', 9),
  _review('noeul', _hotplace, 5, '연남 루프탑 중 제일 신나요.', 13),
  _review('noeul', _instaMood, 4, '노을 사진 맛집.', 16),
  _review('noeul', _withFriends, 4, '생일 파티 하기 좋아요.', 19),
  _review('noeul', _quietWalker, 1, '음악이 너무 커서 대화가 안 돼요.', 21),

  // 와인바 잔
  _review('jan', _bookBear, 5, '좌석이 적어서 늘 조용해요. 혼술하기 최고.', 6),
  _review('jan', _minimalist, 5, '인테리어가 단정하고 와인 설명도 친절해요.', 10),
  _review('jan', _quietCoffee, 5, '잔잔한 재즈와 와인 한 잔. 완벽한 저녁.', 13),
  _review('jan', _partyPeople, 2, '너무 조용해서 떠들기 미안했어요.', 17),
  _review('jan', _withFriends, 2, '여럿이 가기엔 자리가 좁아요.', 20),
];
