// =============================================================================
//  screens/add_entry_screen.dart - 수입/지출 입력 화면
// =============================================================================
//
//  ■ 이 화면의 상태는 "지역 상태(임시 상태)" 입니다.
//    입력 중인 값(종류, 카테고리, 날짜, 금액, 내용)은 [저장]을 누르기 전까지
//    다른 화면이 알 필요가 없습니다. 그래서 공유 저장소(LedgerStore)에 넣지 않고
//    이 화면의 State 안에 두고 setState 로 관리합니다.
//
//      공유 상태(LedgerStore) : 여러 화면이 함께 보는 데이터 → notifyListeners
//      지역 상태(이 화면)      : 이 화면만 쓰는 임시 데이터   → setState
//
//  ■ 결과는 어떻게 홈 화면으로 전달되나요?
//    이 화면은 저장소를 전혀 모릅니다! [저장]을 누르면
//      Navigator.pop(context, 새 기록);
//    으로 화면을 닫으면서 "새 기록"을 돌려줄 뿐입니다.
//    그걸 받아서 저장소에 넣는 일은 이 화면을 연 HomeScreen 이 합니다.
//    → 입력 화면은 "기록 만들기"만, 홈 화면은 "저장소 관리"만 책임집니다.
//
//  ■ 글자 입력칸(TextFormField)의 값은 TextEditingController 가 들고 있습니다.
//    컨트롤러는 화면이 사라질 때 dispose() 로 꼭 정리해 줘야 합니다.
//
//  ■ Form + validator
//    [저장]을 누르면 _formKey.currentState!.validate() 가 모든 입력칸의
//    validator 를 실행합니다. 하나라도 문제가 있으면 빨간 안내 문구가 나오고
//    저장되지 않습니다.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/ledger_entry.dart';
import '../utils/format.dart';

/// 수입/지출을 입력하는 화면.
class AddEntryScreen extends StatefulWidget {
  /// 날짜 칸에 처음 채워 둘 날짜.
  final DateTime initialDate;

  const AddEntryScreen({super.key, required this.initialDate});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  // ---------------------------------------------------------------------------
  // 지역 상태 - 이 화면에서만 쓰는 입력 중인 값들
  // ---------------------------------------------------------------------------

  /// Form 전체를 가리키는 열쇠. 한꺼번에 검사(validate)할 때 사용합니다.
  final _formKey = GlobalKey<FormState>();

  /// 금액 입력칸의 글자를 들고 있는 컨트롤러.
  final _amountController = TextEditingController();

  /// 내용 입력칸의 글자를 들고 있는 컨트롤러.
  final _titleController = TextEditingController();

  /// 수입/지출 중 무엇을 골랐는지. 가계부는 지출 기록이 많으니 지출로 시작합니다.
  EntryType _type = EntryType.expense;

  /// 고른 카테고리. 처음에는 지출 카테고리 중 첫 번째(식비).
  EntryCategory _category = EntryCategory.of(EntryType.expense).first;

  /// 고른 날짜. initState 에서 widget.initialDate 로 채웁니다.
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    // State 안에서는 widget.xxx 로 위젯(AddEntryScreen)의 값을 읽을 수 있습니다.
    _date = widget.initialDate;
  }

  @override
  void dispose() {
    // 컨트롤러가 쓰던 자원을 정리합니다. (안 하면 메모리가 새어 나갑니다)
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 지역 상태를 바꾸는 함수들 - 모두 setState 안에서 바꿉니다
  // ---------------------------------------------------------------------------

  /// 수입/지출을 바꾸면, 카테고리도 그 종류의 첫 번째 카테고리로 바꿉니다.
  /// (지출을 고른 상태에서 '용돈' 카테고리가 남아 있으면 이상하니까요)
  void _changeType(EntryType type) {
    setState(() {
      _type = type;
      _category = EntryCategory.of(type).first;
    });
  }

  /// 달력을 띄워 날짜를 고릅니다.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    // 달력에서 [취소]를 누르면 null 이 돌아오므로, 골랐을 때만 바꿉니다.
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  /// [저장] 버튼: 입력값을 검사하고, 문제가 없으면 새 기록을 돌려주며 닫습니다.
  void _save() {
    // 모든 validator 실행. 하나라도 실패하면 여기서 멈춤.
    if (!_formKey.currentState!.validate()) return;

    final entry = LedgerEntry(
      title: _titleController.text.trim(),
      amount: int.parse(_amountController.text),
      category: _category,
      date: _date,
    );

    // 화면을 닫으면서 새 기록을 돌려줍니다. → HomeScreen 의 await 가 이 값을 받음
    Navigator.of(context).pop(entry);
  }

  // ---------------------------------------------------------------------------
  // 화면 그리기 - 지역 상태(_type, _category, _date)를 보고 그립니다
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // 지금 고른 종류에 맞는 카테고리 목록
    final categories = EntryCategory.of(_type);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('기록하기', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── 수입 / 지출 선택 ────────────────────────────────────────────
            SegmentedButton<EntryType>(
              segments: const [
                ButtonSegment(
                  value: EntryType.expense,
                  label: Text('지출'),
                  icon: Icon(Icons.remove_circle_outline),
                ),
                ButtonSegment(
                  value: EntryType.income,
                  label: Text('수입'),
                  icon: Icon(Icons.add_circle_outline),
                ),
              ],
              selected: {_type}, // 지금 선택된 값 (Set 으로 전달)
              onSelectionChanged: (selected) => _changeType(selected.first),
            ),
            const SizedBox(height: 24),

            // ── 금액 ───────────────────────────────────────────────────────
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number, // 숫자 키보드
              // 숫자 이외의 글자는 아예 입력되지 않게 막습니다.
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                labelText: '금액',
                suffixText: '원',
                border: OutlineInputBorder(),
              ),
              // 검사: 비어 있거나 0 이면 안내 문구를 돌려줌 (null 이면 통과)
              validator: (value) {
                final amount = int.tryParse(value ?? '');
                if (amount == null || amount <= 0) return '금액을 입력해 주세요';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── 내용 ───────────────────────────────────────────────────────
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '내용',
                hintText: _type == EntryType.expense ? '예) 점심 식사' : '예) 용돈',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '내용을 입력해 주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── 카테고리 ───────────────────────────────────────────────────
            const Text('카테고리', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            // Wrap: 가로 공간이 부족하면 다음 줄로 자동 줄바꿈
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in categories)
                  ChoiceChip(
                    // 선택 표시는 체크(✓) 대신 칩 배경색으로만 (아이콘이 가려지지 않게)
                    showCheckmark: false,
                    avatar:
                        Icon(category.icon, size: 18, color: category.color),
                    label: Text(category.label),
                    selected: category == _category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 날짜 ───────────────────────────────────────────────────────
            const Text('날짜', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(formatDay(_date)),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // ── 저장 ───────────────────────────────────────────────────────
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF14967F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('저장', style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
