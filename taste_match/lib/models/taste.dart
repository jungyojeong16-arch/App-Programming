// =============================================================================
//  models/taste.dart - "취향"을 숫자로 표현하는 모델
// =============================================================================
//
//  ■ 취향을 어떻게 숫자로 바꾸나요?
//    취향을 5가지 축(TasteTrait)으로 나누고, 각 축을 1 ~ 5 점으로 표현합니다.
//
//        축          1점 쪽            5점 쪽
//        ─────────   ───────────       ───────────
//        붐빔        한적함      ◀───▶ 북적임
//        인테리어    미니멀      ◀───▶ 화려함
//        중요한 것   가성비      ◀───▶ 분위기
//        소리        조용함      ◀───▶ 활기참
//        누구와      혼자        ◀───▶ 여럿이
//
//    사람의 취향(TasteProfile)도, 가게의 분위기도 같은 5개 숫자로 표현합니다.
//    그래서 "사람 ↔ 사람", "사람 ↔ 가게"를 같은 방법으로 비교할 수 있습니다.
//
//  ■ 두 취향이 얼마나 비슷한지 계산하기 (similarityTo)
//    축마다 점수 차이를 구해서 모두 더합니다. (맨해튼 거리)
//
//        나        (1, 1, 4, 1, 1)
//        상대      (1, 1, 3, 2, 1)
//        차이       0 + 0 + 1 + 1 + 0 = 2
//
//    가장 많이 다를 때의 차이는 5축 × 4점 = 20 입니다.
//    그래서  일치도 = (1 - 차이 / 20) × 100  →  (1 - 2/20) × 100 = 90%
// =============================================================================

/// 취향을 나누는 5가지 축.
enum TasteTrait {
  crowd('붐빔', '한적함', '북적임', '사람이 얼마나 있는 곳이 좋아요?'),
  decor('인테리어', '미니멀', '화려함', '어떤 인테리어가 끌려요?'),
  priority('중요한 것', '가성비', '분위기', '가격과 분위기 중 무엇이 더 중요해요?'),
  mood('소리', '조용함', '활기참', '어느 정도 소리가 있는 곳이 편해요?'),
  company('누구와', '혼자', '여럿이', '주로 누구와 가나요?');

  const TasteTrait(this.label, this.low, this.high, this.question);

  /// 축 이름. 예) '붐빔'
  final String label;

  /// 1점 쪽 이름. 예) '한적함'
  final String low;

  /// 5점 쪽 이름. 예) '북적임'
  final String high;

  /// 취향 설정 화면에서 보여 줄 질문.
  final String question;

  /// 점수를 말로 바꿔 줍니다.
  /// 예) crowd 축에서 1 → '무조건 한적함', 2 → '한적함 쪽', 3 → '상관없어요'
  String describe(int value) => switch (value) {
        1 => '무조건 $low',
        2 => '$low 쪽',
        3 => '상관없어요',
        4 => '$high 쪽',
        _ => '무조건 $high',
      };
}

/// 한 사람의 취향 (또는 한 가게의 분위기).
///
/// 5개 축의 점수를 담는 "불변 객체"입니다. 점수를 바꾸고 싶으면
/// [withValue] 로 새 객체를 만듭니다. (할 일 앱의 copyWith 와 같은 방식)
class TasteProfile {
  /// 한 축의 가장 작은 점수.
  static const int minValue = 1;

  /// 한 축의 가장 큰 점수.
  static const int maxValue = 5;

  /// 아무것도 고르지 않았을 때의 점수 (가운데).
  static const int neutral = 3;

  const TasteProfile({
    this.crowd = neutral,
    this.decor = neutral,
    this.priority = neutral,
    this.mood = neutral,
    this.company = neutral,
  });

  final int crowd;
  final int decor;
  final int priority;
  final int mood;
  final int company;

  /// 축으로 점수 꺼내기.  예) profile[TasteTrait.crowd] → 1
  int operator [](TasteTrait trait) => switch (trait) {
        TasteTrait.crowd => crowd,
        TasteTrait.decor => decor,
        TasteTrait.priority => priority,
        TasteTrait.mood => mood,
        TasteTrait.company => company,
      };

  /// 한 축의 점수만 바꾼 "새" 취향을 돌려줍니다.
  TasteProfile withValue(TasteTrait trait, int value) {
    final v = value.clamp(minValue, maxValue);
    return TasteProfile(
      crowd: trait == TasteTrait.crowd ? v : crowd,
      decor: trait == TasteTrait.decor ? v : decor,
      priority: trait == TasteTrait.priority ? v : priority,
      mood: trait == TasteTrait.mood ? v : mood,
      company: trait == TasteTrait.company ? v : company,
    );
  }

  /// 다른 취향과 얼마나 비슷한지 0 ~ 100 (%) 으로 돌려줍니다.
  /// 계산 방법은 파일 맨 위 설명을 참고하세요.
  int similarityTo(TasteProfile other) {
    var diff = 0;
    for (final trait in TasteTrait.values) {
      diff += (this[trait] - other[trait]).abs();
    }
    final maxDiff = TasteTrait.values.length * (maxValue - minValue); // 20
    return (100 * (1 - diff / maxDiff)).round();
  }

  /// 취향을 짧은 말로 요약합니다. 가운데(3점)인 축은 빼고 보여 줍니다.
  /// 예) '한적함 · 미니멀 · 분위기 · 조용함 · 혼자'
  String get summary {
    final words = <String>[
      for (final trait in TasteTrait.values)
        if (this[trait] < neutral)
          trait.low
        else if (this[trait] > neutral)
          trait.high,
    ];
    return words.isEmpty ? '아직 뚜렷한 취향이 없어요' : words.join(' · ');
  }

  // 두 취향의 점수가 모두 같으면 같은 취향으로 봅니다. (테스트에서 비교할 때 사용)
  @override
  bool operator ==(Object other) =>
      other is TasteProfile &&
      TasteTrait.values.every((trait) => this[trait] == other[trait]);

  @override
  int get hashCode => Object.hash(crowd, decor, priority, mood, company);

  @override
  String toString() =>
      'TasteProfile($crowd, $decor, $priority, $mood, $company)';
}
