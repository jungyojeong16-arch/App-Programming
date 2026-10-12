// =============================================================================
//  utils/format.dart - 금액과 날짜를 화면에 보여 줄 글자로 바꾸는 함수들
// =============================================================================
//
//  intl 같은 외부 패키지 없이 직접 만들어서, 동작 원리를 눈으로 볼 수 있게 했습니다.
//    formatWon(1234567)            → '1,234,567원'
//    formatWon(-9000)              → '-9,000원'
//    formatMonth(2026년 10월 1일)   → '2026년 10월'
//    formatDay(2026년 10월 12일)    → '10월 12일 (월)'
// =============================================================================

/// 금액에 세 자리마다 쉼표를 넣고 '원'을 붙입니다.
String formatWon(int amount) {
  final digits = amount.abs().toString(); // 부호를 뗀 숫자 글자. 예) '1234567'
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    // 남은 자릿수가 3의 배수가 되는 위치 앞에 쉼표를 넣습니다. (맨 앞 제외)
    //   1,234,567 → i=1 앞(남은 6자리), i=4 앞(남은 3자리)
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}$buffer원';
}

/// '2026년 10월' 형식.
String formatMonth(DateTime month) => '${month.year}년 ${month.month}월';

/// '10월 12일 (월)' 형식.
String formatDay(DateTime date) {
  // DateTime.weekday 는 월요일=1 … 일요일=7 입니다.
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
}
