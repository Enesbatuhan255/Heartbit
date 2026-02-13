import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_bank.freezed.dart';
part 'question_bank.g.dart';

/// Single question definition
@freezed
class Question with _$Question {
  const factory Question({
    required String id,    // "q_001"
    required String text,  // Question text
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

/// Hardcoded question bank (50+ Turkish questions for couples)
class QuestionBank {
  QuestionBank._();

  static const List<Question> questions = [
    Question(id: 'q_001', text: 'Bugün seni en çok mutlu eden şey neydi?'),
    Question(id: 'q_002', text: 'Benim hakkımda en çok neyi seviyorsun?'),
    Question(id: 'q_003', text: 'Bu hafta birlikte ne yapmak istersin?'),
    Question(id: 'q_004', text: 'Hayalindeki tatil nerede olurdu?'),
    Question(id: 'q_005', text: 'En sevdiğin ortak anımız hangisi?'),
    Question(id: 'q_006', text: 'Bugün kafanda ne var?'),
    Question(id: 'q_007', text: 'Seni en çok ne strese sokuyor?'),
    Question(id: 'q_008', text: 'Birlikte izlemek istediğin bir film var mı?'),
    Question(id: 'q_009', text: 'Bu ay için bir hedefin var mı?'),
    Question(id: 'q_010', text: 'En son ne zaman çok güldün?'),
    Question(id: 'q_011', text: 'Hangi süper güce sahip olmak isterdin?'),
    Question(id: 'q_012', text: 'Bugün kendine nasıl bir not verirsin?'),
    Question(id: 'q_013', text: 'En sevdiğin yemek hangisi?'),
    Question(id: 'q_014', text: 'Birlikte daha çok ne yapmak istersin?'),
    Question(id: 'q_015', text: 'Sana ilham veren biri var mı?'),
    Question(id: 'q_016', text: 'Bu yıl öğrenmek istediğin bir şey var mı?'),
    Question(id: 'q_017', text: 'En son ne için minnettar hissettin?'),
    Question(id: 'q_018', text: 'Childhood dream\'in neydi?'),
    Question(id: 'q_019', text: 'Bugün en çok neye güldün?'),
    Question(id: 'q_020', text: 'Birlikte yaşlanmak hakkında ne düşünüyorsun?'),
    Question(id: 'q_021', text: 'En sevdiğin mevsim hangisi ve neden?'),
    Question(id: 'q_022', text: 'Partnerine bugün söylemek istediğin bir şey var mı?'),
    Question(id: 'q_023', text: 'Hayatta en çok neyi değer veriyorsun?'),
    Question(id: 'q_024', text: 'Birlikte yeni bir hobi denemek ister misin?'),
    Question(id: 'q_025', text: 'Seni en çok ne rahatlatiyor?'),
    Question(id: 'q_026', text: 'Bugün enerjin nasıl?'),
    Question(id: 'q_027', text: 'Hayalindeki ev nasıl olurdu?'),
    Question(id: 'q_028', text: 'En sevdiğin şarkı hangisi şu an?'),
    Question(id: 'q_029', text: 'Birlikte öğrenmek istediğin bir beceri var mı?'),
    Question(id: 'q_030', text: 'En özlediğin yer neresi?'),
    Question(id: 'q_031', text: 'Bugün kendine biraz zaman ayırdın mı?'),
    Question(id: 'q_032', text: 'Seni en çok ne motive ediyor?'),
    Question(id: 'q_033', text: 'En sevdiğin hafta sonu aktivitesi ne?'),
    Question(id: 'q_034', text: 'Partnerine teşekkür etmek istediğin bir şey var mı?'),
    Question(id: 'q_035', text: 'En rahat hissettiğin an ne zaman?'),
    Question(id: 'q_036', text: 'Birlikte pişirmek istediğin bir yemek var mı?'),
    Question(id: 'q_037', text: 'Bugün aklına gelen ilk kelime ne?'),
    Question(id: 'q_038', text: 'En sevdiğin çocukluk hatırası ne?'),
    Question(id: 'q_039', text: 'Partnerinle paylaşmak istediğin bir sır var mı?'),
    Question(id: 'q_040', text: 'Hayatta en çok neyi başarmak istiyorsun?'),
    Question(id: 'q_041', text: 'Birlikte gitmek istediğin bir konser var mı?'),
    Question(id: 'q_042', text: 'En son ne zaman ağladın ve neden?'),
    Question(id: 'q_043', text: 'Seni en çok güldüren şey ne?'),
    Question(id: 'q_044', text: 'Partnerine vermek istediğin bir tavsiye var mı?'),
    Question(id: 'q_045', text: 'Bugün en çok neyi beğendin?'),
    Question(id: 'q_046', text: 'Hayalindeki meslek ne olurdu?'),
    Question(id: 'q_047', text: 'Birlikte bir proje yapmak ister misin?'),
    Question(id: 'q_048', text: 'En son ne zaman spontan bir şey yaptın?'),
    Question(id: 'q_049', text: 'Seni en çok korkutan şey ne?'),
    Question(id: 'q_051', text: 'Partnerinin en sevdiği şarkı ne?'),
    Question(id: 'q_052', text: 'Partnerinin çocukken olmak istediği meslek neydi?'),
    Question(id: 'q_053', text: 'Partnerinin en sevdiği yemek hangisi?'),
    Question(id: 'q_054', text: 'Partnerinin hayattaki en büyük korkusu ne?'),
    Question(id: 'q_055', text: 'Partnerinin şu an en çok gitmek istediği yer neresi?'),
  ];

  /// Get question for a specific date (deterministic based on date hash)
  static Question getForDate(String dateKey) {
    final index = dateKey.hashCode.abs() % questions.length;
    return questions[index];
  }

  /// Get question by ID
  static Question? getById(String questionId) {
    try {
      return questions.firstWhere((q) => q.id == questionId);
    } catch (_) {
      return null;
    }
  }
}
