// =============================================================================
//  utils/format.dart - 화면에 보여 줄 글자 형식
// =============================================================================

/// 별점 평균을 소수점 한 자리로.  예) 4.777… → '4.8',  null → '-'
String formatRating(double? rating) =>
    rating == null ? '-' : rating.toStringAsFixed(1);

/// 날짜를 짧게.  예) 2026-10-03 → '10월 3일'
String formatDate(DateTime date) => '${date.month}월 ${date.day}일';
