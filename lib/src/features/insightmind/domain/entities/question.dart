// lib/src/features/insightmind/domain/entities/question.dart

class AnswerOption {
  final String label;
  final int score;

  const AnswerOption({
    required this.label,
    required this.score,
  });
}

class Question {
  final String id;
  final String text;
  final List<AnswerOption> options;
  final int minAge;
  final int maxAge;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    this.minAge = 17,
    this.maxAge = 27,
  });

  bool isApplicableForAge(int age) =>
      age >= minAge && age <= maxAge;
}

// ===================================================
// OPSI JAWABAN
// ===================================================

const _defaultOptions = [
  AnswerOption(
    label: 'Tidak Pernah',
    score: 0,
  ),
  AnswerOption(
    label: 'Beberapa Hari',
    score: 1,
  ),
  AnswerOption(
    label: 'Lebih dari Separuh Hari',
    score: 2,
  ),
  AnswerOption(
    label: 'Hampir Setiap Hari',
    score: 3,
  ),
];

// ===================================================
// USIA 17 - 20
// ===================================================

const questionsAge17_20 = <Question>[

  // STRES (Q1-Q4)

  Question(
    id: 'a1',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu merasa kewalahan dengan tugas kuliah yang menumpuk?',
    options: _defaultOptions,
  ),

  Question(
    id: 'a2',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu merasa kesulitan membagi waktu antara kuliah dan kehidupan pribadi?',
    options: _defaultOptions,
  ),

  Question(
    id: 'a3',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu merasa tertekan oleh nilai atau prestasi akademik?',
    options: _defaultOptions,
  ),

  Question(
    id: 'a4',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu merasa tidak memiliki cukup waktu untuk beristirahat?',
    options: _defaultOptions,
  ),

  // KECEMASAN (Q5-Q7)

  Question(
    id: 'a5',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu merasa khawatir terhadap hasil belajar atau nilai kuliah?',
    options: _defaultOptions,
  ),

  Question(
    id: 'a6',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu merasa gelisah ketika menghadapi ujian atau presentasi?',
    options: _defaultOptions,
  ),

  Question(
    id: 'a7',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu merasa takut mengecewakan orang tua atau keluarga?',
    options: _defaultOptions,
  ),

  // KUALITAS TIDUR (Q8-Q10)

  Question(
    id: 'a8',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu mengalami kesulitan untuk mulai tidur?',
    options: _defaultOptions,
  ),

  Question(
    id: 'a9',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu terbangun di malam hari dan sulit tidur kembali?',
    options: _defaultOptions,
  ),

  Question(
    id: 'a10',
    minAge: 17,
    maxAge: 20,
    text:
        'Seberapa sering kamu bangun dalam keadaan lelah atau tidak segar?',
    options: _defaultOptions,
  ),
];

// ===================================================
// USIA 21 - 23
// ===================================================

const questionsAge21_23 = <Question>[

  // STRES (Q1-Q4)

  Question(
    id: 'b1',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu merasa stres karena skripsi, tugas akhir, atau pekerjaan?',
    options: _defaultOptions,
  ),

  Question(
    id: 'b2',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu merasa kesulitan menyeimbangkan kuliah, pekerjaan, dan kehidupan pribadi?',
    options: _defaultOptions,
  ),

  Question(
    id: 'b3',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu merasa tertekan oleh target akademik atau pekerjaan yang harus dicapai?',
    options: _defaultOptions,
  ),

  Question(
    id: 'b4',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu merasa terbebani oleh kondisi keuangan atau kebutuhan hidup?',
    options: _defaultOptions,
  ),

  // KECEMASAN (Q5-Q7)

  Question(
    id: 'b5',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu merasa cemas mengenai karier atau pekerjaan setelah lulus?',
    options: _defaultOptions,
  ),

  Question(
    id: 'b6',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu merasa khawatir tidak mampu mencapai tujuan hidup yang diharapkan?',
    options: _defaultOptions,
  ),

  Question(
    id: 'b7',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu merasa gelisah ketika membandingkan pencapaian diri dengan teman sebaya?',
    options: _defaultOptions,
  ),

  // KUALITAS TIDUR (Q8-Q10)

  Question(
    id: 'b8',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu mengalami kesulitan tidur karena memikirkan kuliah atau pekerjaan?',
    options: _defaultOptions,
  ),

  Question(
    id: 'b9',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kualitas tidurmu terganggu akibat stres atau kecemasan?',
    options: _defaultOptions,
  ),

  Question(
    id: 'b10',
    minAge: 21,
    maxAge: 23,
    text:
        'Seberapa sering kamu merasa mengantuk atau kelelahan saat beraktivitas di siang hari?',
    options: _defaultOptions,
  ),
];

// ===================================================
// USIA 24 - 27
// ===================================================

const questionsAge24_27 = <Question>[

  // STRES (Q1-Q4)

  Question(
    id: 'c1',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu merasa tertekan oleh tanggung jawab pekerjaan yang semakin besar?',
    options: _defaultOptions,
  ),

  Question(
    id: 'c2',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu merasa kesulitan menyeimbangkan pekerjaan dan kehidupan keluarga?',
    options: _defaultOptions,
  ),

  Question(
    id: 'c3',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu merasa terbebani oleh kebutuhan ekonomi atau keuangan rumah tangga?',
    options: _defaultOptions,
  ),

  Question(
    id: 'c4',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu merasa kelelahan karena banyaknya tanggung jawab yang harus dijalankan?',
    options: _defaultOptions,
  ),

  // KECEMASAN (Q5-Q7)

  Question(
    id: 'c5',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu merasa khawatir terhadap masa depan karier atau kondisi ekonomi keluarga?',
    options: _defaultOptions,
  ),

  Question(
    id: 'c6',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu merasa cemas terhadap kemampuan memenuhi kebutuhan keluarga atau orang yang bergantung padamu?',
    options: _defaultOptions,
  ),

  Question(
    id: 'c7',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu merasa gelisah ketika menghadapi keputusan penting terkait pekerjaan atau keluarga?',
    options: _defaultOptions,
  ),

  // KUALITAS TIDUR (Q8-Q10)

  Question(
    id: 'c8',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu mengalami kesulitan tidur karena memikirkan pekerjaan atau masalah keluarga?',
    options: _defaultOptions,
  ),

  Question(
    id: 'c9',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering tidurmu terganggu akibat tekanan pekerjaan atau tanggung jawab rumah tangga?',
    options: _defaultOptions,
  ),

  Question(
    id: 'c10',
    minAge: 24,
    maxAge: 27,
    text:
        'Seberapa sering kamu merasa kurang segar atau tetap lelah setelah bangun tidur?',
    options: _defaultOptions,
  ),
];

// ===================================================
// GET QUESTIONS BY AGE
// ===================================================

List<Question> getQuestionsByAge(int age) {
  if (age >= 17 && age <= 20) {
    return questionsAge17_20;
  }

  if (age >= 21 && age <= 23) {
    return questionsAge21_23;
  }

  if (age >= 24 && age <= 27) {
    return questionsAge24_27;
  }

  return questionsAge21_23;
}
