// =============================================================================
//  models/place.dart - 음식점·카페 한 곳을 표현하는 모델
// =============================================================================
//
//  ■ 가게의 분위기(vibe)도 TasteProfile 입니다
//    사람의 취향과 같은 5개 축으로 가게 분위기를 적어 두면,
//    "내 취향 ↔ 이 가게"가 얼마나 맞는지 바로 계산할 수 있습니다.
//
//    지금은 예시 데이터에 직접 적어 두었지만, 실제 서비스라면
//    리뷰를 쓸 때 "혼잡도·인테리어…"를 함께 입력받아 그 평균으로 정하면 됩니다.
// =============================================================================

import 'package:flutter/material.dart';

import 'taste.dart';

/// 가게 종류.
enum PlaceCategory {
  cafe('카페', Icons.local_cafe_outlined),
  restaurant('식당', Icons.restaurant_outlined),
  bar('술집', Icons.wine_bar_outlined);

  const PlaceCategory(this.label, this.icon);

  /// 화면에 보여 줄 이름. 예) '카페'
  final String label;

  /// 목록에 보여 줄 아이콘.
  final IconData icon;
}

/// 음식점·카페 한 곳.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.description,
    required this.vibe,
  });

  /// 가게를 구분하는 값. 리뷰가 어느 가게 것인지 이 값으로 찾습니다.
  final String id;

  /// 가게 이름. 예) '카페 여백'
  final String name;

  /// 가게 종류. 예) 카페
  final PlaceCategory category;

  /// 동네. 예) '성수동'
  final String area;

  /// 한 줄 소개.
  final String description;

  /// 가게 분위기 (사람 취향과 같은 5개 축).
  final TasteProfile vibe;
}
