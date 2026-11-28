///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsId = Translations; // ignore: unused_element

class Translations with BaseTranslations<AppLocale, Translations> {
  /// Returns the current translations of the given [context].
  ///
  /// Usage:
  /// final t = Translations.of(context);
  static Translations of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, Translations>(context).translations;

  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  Translations({
    Map<String, Node>? overrides,
    PluralResolver? cardinalResolver,
    PluralResolver? ordinalResolver,
    TranslationMetadata<AppLocale, Translations>? meta,
  }) : assert(
         overrides == null,
         'Set "translation_overrides: true" in order to enable this feature.',
       ),
       _meta =
           meta ??
           TranslationMetadata(
             locale: AppLocale.id,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           ) {
    _meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <id>.
  final TranslationMetadata<AppLocale, Translations> _meta;
  @override
  TranslationMetadata<AppLocale, Translations> get $meta => _meta;

  /// Access flat map
  dynamic operator [](String key) => _meta.getTranslation(key);

  late final Translations _root = this; // ignore: unused_field

  Translations $copyWith({
    TranslationMetadata<AppLocale, Translations>? meta,
  }) => Translations(meta: meta ?? this.$meta);

  // Translations
  late final Translations$core$id core = Translations$core$id.internal(_root);
  late final Translations$home$id home = Translations$home$id.internal(_root);
  late final Translations$onboarding$id onboarding =
      Translations$onboarding$id.internal(_root);
  late final Translations$profile$id profile = Translations$profile$id.internal(
    _root,
  );
  late final Translations$workoutSession$id workoutSession =
      Translations$workoutSession$id.internal(_root);
  late final Translations$workouts$id workouts =
      Translations$workouts$id.internal(_root);
}

// Path: core
class Translations$core$id {
  Translations$core$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Home Bulking Coach'
  String get appName => 'Home Bulking Coach';

  late final Translations$core$actions$id actions =
      Translations$core$actions$id.internal(_root);
  late final Translations$core$state$id state =
      Translations$core$state$id.internal(_root);
  late final Translations$core$badge$id badge =
      Translations$core$badge$id.internal(_root);
  late final Translations$core$language$id language =
      Translations$core$language$id.internal(_root);
  late final Translations$core$units$id units =
      Translations$core$units$id.internal(_root);
  late final Translations$core$streak$id streak =
      Translations$core$streak$id.internal(_root);
  late final Translations$core$progress$id progress =
      Translations$core$progress$id.internal(_root);
}

// Path: home
class Translations$home$id {
  Translations$home$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$home$greeting$id greeting =
      Translations$home$greeting$id.internal(_root);
  late final Translations$home$goalCard$id goalCard =
      Translations$home$goalCard$id.internal(_root);
  late final Translations$home$todayWorkout$id todayWorkout =
      Translations$home$todayWorkout$id.internal(_root);
  late final Translations$home$restDay$id restDay =
      Translations$home$restDay$id.internal(_root);
  late final Translations$home$noProgram$id noProgram =
      Translations$home$noProgram$id.internal(_root);
  late final Translations$home$weeklyProgress$id weeklyProgress =
      Translations$home$weeklyProgress$id.internal(_root);
  late final Translations$home$supportGoal$id supportGoal =
      Translations$home$supportGoal$id.internal(_root);
  late final Translations$home$error$id error =
      Translations$home$error$id.internal(_root);
}

// Path: onboarding
class Translations$onboarding$id {
  Translations$onboarding$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$onboarding$nav$id nav =
      Translations$onboarding$nav$id.internal(_root);
  late final Translations$onboarding$welcome$id welcome =
      Translations$onboarding$welcome$id.internal(_root);
  late final Translations$onboarding$goal$id goal =
      Translations$onboarding$goal$id.internal(_root);
  late final Translations$onboarding$about$id about =
      Translations$onboarding$about$id.internal(_root);
  late final Translations$onboarding$bodyTarget$id bodyTarget =
      Translations$onboarding$bodyTarget$id.internal(_root);
  late final Translations$onboarding$experience$id experience =
      Translations$onboarding$experience$id.internal(_root);
  late final Translations$onboarding$schedule$id schedule =
      Translations$onboarding$schedule$id.internal(_root);
  late final Translations$onboarding$equipment$id equipment =
      Translations$onboarding$equipment$id.internal(_root);
  late final Translations$onboarding$limitations$id limitations =
      Translations$onboarding$limitations$id.internal(_root);
  late final Translations$onboarding$creating$id creating =
      Translations$onboarding$creating$id.internal(_root);
  late final Translations$onboarding$ready$id ready =
      Translations$onboarding$ready$id.internal(_root);
  late final Translations$onboarding$preview$id preview =
      Translations$onboarding$preview$id.internal(_root);
}

// Path: profile
class Translations$profile$id {
  Translations$profile$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$profile$appSettings$id appSettings =
      Translations$profile$appSettings$id.internal(_root);
}

// Path: workoutSession
class Translations$workoutSession$id {
  Translations$workoutSession$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Latihan $current dari $total'
  String exerciseProgress({required Object current, required Object total}) =>
      'Latihan ${current} dari ${total}';

  /// id: 'Set $current dari $total · $target'
  String setProgress({
    required Object current,
    required Object total,
    required Object target,
  }) => 'Set ${current} dari ${total} · ${target}';

  /// id: 'repetisi'
  String get repsUnit => 'repetisi';

  /// id: 'detik'
  String get durationUnit => 'detik';

  /// id: '$value repetisi'
  String repsValue({required Object value}) => '${value} repetisi';

  /// id: '$value detik'
  String durationValue({required Object value}) => '${value} detik';

  /// id: 'Selesaikan Set'
  String get completeSet => 'Selesaikan Set';

  /// id: 'Istirahat berikutnya'
  String get nextRest => 'Istirahat berikutnya';

  /// id: 'Menyiapkan sesi latihan...'
  String get preparingSession => 'Menyiapkan sesi latihan...';

  /// id: 'Coba Lagi'
  String get retry => 'Coba Lagi';

  /// id: 'Gagal menyimpan set. Periksa koneksi lalu coba lagi.'
  String get saveSetFailed =>
      'Gagal menyimpan set. Periksa koneksi lalu coba lagi.';

  /// id: 'Ada latihan yang belum selesai'
  String get sessionConflictTitle => 'Ada latihan yang belum selesai';

  /// id: 'Kamu masih punya sesi "$program" (Hari $day) yang sedang berlangsung. Lanjutkan sesi itu dulu, atau akhiri untuk mulai latihan ini.'
  String sessionConflictMessage({
    required Object program,
    required Object day,
  }) =>
      'Kamu masih punya sesi "${program}" (Hari ${day}) yang sedang berlangsung. Lanjutkan sesi itu dulu, atau akhiri untuk mulai latihan ini.';

  /// id: 'Lanjutkan Sesi Lama'
  String get resumePreviousSession => 'Lanjutkan Sesi Lama';

  /// id: 'Akhiri Sesi Lama'
  String get endPreviousSession => 'Akhiri Sesi Lama';

  /// id: 'Latihan Hari Ini Tuntas! 🎉'
  String get completionTitle => 'Latihan Hari Ini Tuntas! 🎉';

  /// id: 'Semua set dan gerakan telah berhasil kamu selesaikan. Istirahatlah dengan baik untuk pemulihan otot.'
  String get completionDescription =>
      'Semua set dan gerakan telah berhasil kamu selesaikan. Istirahatlah dengan baik untuk pemulihan otot.';

  /// id: 'Durasi'
  String get durationLabel => 'Durasi';

  /// id: 'Gerakan'
  String get exerciseLabel => 'Gerakan';

  /// id: '$count gerakan'
  String exerciseCount({required Object count}) => '${count} gerakan';

  /// id: 'Total Set'
  String get totalSetsLabel => 'Total Set';

  /// id: '$count set'
  String totalSetsCount({required Object count}) => '${count} set';

  /// id: 'Lihat Ringkasan & Evaluasi ➔'
  String get viewSummary => 'Lihat Ringkasan & Evaluasi ➔';

  /// id: 'Mulai Ulang Timer Istirahat'
  String get restartRestTimer => 'Mulai Ulang Timer Istirahat';

  /// id: 'Selesaikan Sesi Sekarang'
  String get finishSessionNow => 'Selesaikan Sesi Sekarang';

  /// id: 'Keluar Tanpa Menyimpan'
  String get exitWithoutSaving => 'Keluar Tanpa Menyimpan';

  /// id: 'Istirahat'
  String get restTitle => 'Istirahat';

  /// id: 'Berikutnya: $exercise'
  String restNextExercise({required Object exercise}) =>
      'Berikutnya: ${exercise}';

  /// id: 'Set $current dari $total'
  String restSetProgress({required Object current, required Object total}) =>
      'Set ${current} dari ${total}';

  /// id: 'DIJEDA'
  String get restPaused => 'DIJEDA';

  /// id: '-10 dtk'
  String get restMinusTenSeconds => '-10 dtk';

  /// id: '+10 dtk'
  String get restPlusTenSeconds => '+10 dtk';

  /// id: 'Tips'
  String get restTipTitle => 'Tips';

  /// id: 'Tetap bernapas dan jangan lupa minum air.'
  String get restTipDescription => 'Tetap bernapas dan jangan lupa minum air.';

  /// id: 'Lewati Istirahat'
  String get skipRest => 'Lewati Istirahat';

  /// id: 'Set $current dari $total selesai! 🎉'
  String setCompleteTitle({required Object current, required Object total}) =>
      'Set ${current} dari ${total} selesai! 🎉';

  /// id: 'Target: $seconds detik'
  String targetDuration({required Object seconds}) =>
      'Target: ${seconds} detik';

  /// id: 'Target: $reps repetisi'
  String targetReps({required Object reps}) => 'Target: ${reps} repetisi';

  /// id: 'Durasi Selesai'
  String get durationCompleted => 'Durasi Selesai';

  /// id: 'Repetisi Selesai'
  String get repsCompleted => 'Repetisi Selesai';

  /// id: 'Berapa detik kamu bertahan?'
  String get durationQuestion => 'Berapa detik kamu bertahan?';

  /// id: 'Berapa kali kamu berhasil?'
  String get repsQuestion => 'Berapa kali kamu berhasil?';

  /// id: 'Sisa Tenaga Kamu (RIR - Reps in Reserve)'
  String get rirTitle => 'Sisa Tenaga Kamu (RIR - Reps in Reserve)';

  /// id: 'Berapa repetisi lagi yang sanggup kamu lakukan sebelum benar-benar gagal?'
  String get rirQuestion =>
      'Berapa repetisi lagi yang sanggup kamu lakukan sebelum benar-benar gagal?';

  /// id: '0 — Habis Total (Max Failure)'
  String get rirFailureTitle => '0 — Habis Total (Max Failure)';

  /// id: 'Tenaga habis total, tidak sanggup menambah 1 repetisi lagi dengan teknik rapi.'
  String get rirFailureDescription =>
      'Tenaga habis total, tidak sanggup menambah 1 repetisi lagi dengan teknik rapi.';

  /// id: '1 — Sangat Berat'
  String get rirVeryHardTitle => '1 — Sangat Berat';

  /// id: 'Hanya sanggup 1 repetisi lagi sebelum gagal.'
  String get rirVeryHardDescription =>
      'Hanya sanggup 1 repetisi lagi sebelum gagal.';

  /// id: '2 — Zona Ideal (Target)'
  String get rirIdealTitle => '2 — Zona Ideal (Target)';

  /// id: 'Cukup menantang, masih bisa 2 repetisi lagi jika dipaksa.'
  String get rirIdealDescription =>
      'Cukup menantang, masih bisa 2 repetisi lagi jika dipaksa.';

  /// id: '3 — Cukup Ringan'
  String get rirModerateTitle => '3 — Cukup Ringan';

  /// id: 'Masih tersisa 3 repetisi di dalam tangki tenaga.'
  String get rirModerateDescription =>
      'Masih tersisa 3 repetisi di dalam tangki tenaga.';

  /// id: '4+ — Terlalu Mudah'
  String get rirEasyTitle => '4+ — Terlalu Mudah';

  /// id: 'Sangat enteng, masih sanggup melakukan 4 repetisi atau lebih.'
  String get rirEasyDescription =>
      'Sangat enteng, masih sanggup melakukan 4 repetisi atau lebih.';

  /// id: 'Maksimal'
  String get rirBadgeMax => 'Maksimal';

  /// id: 'Tinggi'
  String get rirBadgeHigh => 'Tinggi';

  /// id: 'Optimal ⭐'
  String get rirBadgeOptimal => 'Optimal ⭐';

  /// id: 'Sedang'
  String get rirBadgeModerate => 'Sedang';

  /// id: 'Ringan'
  String get rirBadgeEasy => 'Ringan';

  /// id: 'Simpan & Mulai Istirahat'
  String get saveAndStartRest => 'Simpan & Mulai Istirahat';

  /// id: '$seconds dtk'
  String restSecondsValue({required Object seconds}) => '${seconds} dtk';

  /// id: '$value menit'
  String durationMinutesValue({required Object value}) => '${value} menit';

  /// id: 'Menyimpan sesi latihan...'
  String get savingSession => 'Menyimpan sesi latihan...';

  /// id: 'Daftar latihan untuk sesi ini tidak ditemukan. Silakan kembali untuk memuat ulang program latihan Anda.'
  String get emptySessionDescription =>
      'Daftar latihan untuk sesi ini tidak ditemukan. Silakan kembali untuk memuat ulang program latihan Anda.';

  /// id: 'Kembali'
  String get backButtonLabel => 'Kembali';

  /// id: 'Sesi latihan gagal disimpan. Progres yang sudah tercatat tetap tersedia. Silakan coba lagi.'
  String get finishSessionFailed =>
      'Sesi latihan gagal disimpan. Progres yang sudah tercatat tetap tersedia. Silakan coba lagi.';

  /// id: 'Latihan Kekuatan'
  String get defaultProgramTitle => 'Latihan Kekuatan';

  late final Translations$workoutSession$completedScreen$id completedScreen =
      Translations$workoutSession$completedScreen$id.internal(_root);
}

// Path: workouts
class Translations$workouts$id {
  Translations$workouts$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Latihan'
  String get title => 'Latihan';

  /// id: 'Cari latihan & gerakan...'
  String get searchHint => 'Cari latihan & gerakan...';

  late final Translations$workouts$tabs$id tabs =
      Translations$workouts$tabs$id.internal(_root);
  late final Translations$workouts$activeProgram$id activeProgram =
      Translations$workouts$activeProgram$id.internal(_root);
  late final Translations$workouts$weeklySchedule$id weeklySchedule =
      Translations$workouts$weeklySchedule$id.internal(_root);
  late final Translations$workouts$emptyState$id emptyState =
      Translations$workouts$emptyState$id.internal(_root);
  late final Translations$workouts$allWorkouts$id allWorkouts =
      Translations$workouts$allWorkouts$id.internal(_root);
  late final Translations$workouts$errorState$id errorState =
      Translations$workouts$errorState$id.internal(_root);
  late final Translations$workouts$session$id session =
      Translations$workouts$session$id.internal(_root);
  late final Translations$workouts$workoutDetail$id workoutDetail =
      Translations$workouts$workoutDetail$id.internal(_root);
  late final Translations$workouts$filter$id filter =
      Translations$workouts$filter$id.internal(_root);
  late final Translations$workouts$categories$id categories =
      Translations$workouts$categories$id.internal(_root);
}

// Path: core.actions
class Translations$core$actions$id {
  Translations$core$actions$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Simpan'
  String get save => 'Simpan';

  /// id: 'Batal'
  String get cancel => 'Batal';

  /// id: 'Kembali'
  String get back => 'Kembali';

  /// id: 'Lanjut'
  String get next => 'Lanjut';

  /// id: 'Lewati'
  String get skip => 'Lewati';

  /// id: 'Selesai'
  String get done => 'Selesai';

  /// id: 'Coba Lagi'
  String get retry => 'Coba Lagi';

  /// id: 'Tutup'
  String get close => 'Tutup';

  /// id: 'Ubah'
  String get edit => 'Ubah';

  /// id: 'Hapus'
  String get delete => 'Hapus';
}

// Path: core.state
class Translations$core$state$id {
  Translations$core$state$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Memuat...'
  String get loading => 'Memuat...';

  /// id: 'Belum ada data'
  String get empty => 'Belum ada data';

  /// id: 'Terjadi kesalahan'
  String get error => 'Terjadi kesalahan';
}

// Path: core.badge
class Translations$core$badge$id {
  Translations$core$badge$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program Aktif'
  String get currentPlan => 'Program Aktif';
}

// Path: core.language
class Translations$core$language$id {
  Translations$core$language$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Bahasa'
  String get label => 'Bahasa';

  /// id: 'Bahasa Indonesia'
  String get id => 'Bahasa Indonesia';

  /// id: 'English'
  String get en => 'English';
}

// Path: core.units
class Translations$core$units$id {
  Translations$core$units$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'repetisi'
  String get reps => 'repetisi';

  /// id: 'set'
  String get sets => 'set';

  /// id: 'detik'
  String get seconds => 'detik';

  /// id: 'kg'
  String get kg => 'kg';
}

// Path: core.streak
class Translations$core$streak$id {
  Translations$core$streak$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: '$count hari'
  String daySingular({required Object count}) => '${count} hari';

  /// id: '$count hari'
  String dayPlural({required Object count}) => '${count} hari';

  /// id: '$count hari aktif'
  String activeDaySingular({required Object count}) => '${count} hari aktif';

  /// id: '$count hari aktif'
  String activeDayPlural({required Object count}) => '${count} hari aktif';
}

// Path: core.progress
class Translations$core$progress$id {
  Translations$core$progress$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Progres'
  String get title => 'Progres';

  /// id: '$weeks Minggu Terakhir'
  String rangeWeeks({required Object weeks}) => '${weeks} Minggu Terakhir';

  late final Translations$core$progress$tabs$id tabs =
      Translations$core$progress$tabs$id.internal(_root);

  /// id: 'Progres Anda'
  String get overviewTitle => 'Progres Anda';

  /// id: 'Ringkasan latihan dan progres tubuh Anda.'
  String get overviewSubtitle => 'Ringkasan latihan dan progres tubuh Anda.';

  late final Translations$core$progress$metrics$id metrics =
      Translations$core$progress$metrics$id.internal(_root);

  /// id: 'Progres Program'
  String get programProgress => 'Progres Program';

  late final Translations$core$progress$noWorkoutData$id noWorkoutData =
      Translations$core$progress$noWorkoutData$id.internal(_root);
  late final Translations$core$progress$noActiveProgram$id noActiveProgram =
      Translations$core$progress$noActiveProgram$id.internal(_root);

  /// id: 'Sorotan Terbaru'
  String get recentHighlights => 'Sorotan Terbaru';

  /// id: 'Terus Semangat!'
  String get keepGoing => 'Terus Semangat!';

  /// id: 'Tetap konsisten. Setiap latihan membawa Anda lebih dekat ke tujuan.'
  String get keepGoingMessage =>
      'Tetap konsisten. Setiap latihan membawa Anda lebih dekat ke tujuan.';

  late final Translations$core$progress$weightTrend$id weightTrend =
      Translations$core$progress$weightTrend$id.internal(_root);
  late final Translations$core$progress$notTracked$id notTracked =
      Translations$core$progress$notTracked$id.internal(_root);
  late final Translations$core$progress$programCard$id programCard =
      Translations$core$progress$programCard$id.internal(_root);
  late final Translations$core$progress$highlights$id highlights =
      Translations$core$progress$highlights$id.internal(_root);
  late final Translations$core$progress$body$id body =
      Translations$core$progress$body$id.internal(_root);
  late final Translations$core$progress$workout$id workout =
      Translations$core$progress$workout$id.internal(_root);
  late final Translations$core$progress$history$id history =
      Translations$core$progress$history$id.internal(_root);
  late final Translations$core$progress$duration$id duration =
      Translations$core$progress$duration$id.internal(_root);
  late final Translations$core$progress$weightDialog$id weightDialog =
      Translations$core$progress$weightDialog$id.internal(_root);
  late final Translations$core$progress$error$id error =
      Translations$core$progress$error$id.internal(_root);
}

// Path: home.greeting
class Translations$home$greeting$id {
  Translations$home$greeting$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Selamat Pagi, $name 👋'
  String goodMorning({required Object name}) => 'Selamat Pagi, ${name} 👋';

  /// id: 'Selamat Siang, $name 👋'
  String goodAfternoon({required Object name}) => 'Selamat Siang, ${name} 👋';

  /// id: 'Selamat Malam, $name 👋'
  String goodEvening({required Object name}) => 'Selamat Malam, ${name} 👋';

  /// id: 'Tetap konsisten dan capai targetmu!'
  String get subtitle => 'Tetap konsisten dan capai targetmu!';
}

// Path: home.goalCard
class Translations$home$goalCard$id {
  Translations$home$goalCard$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Target:'
  String get goalPrefix => 'Target:';

  /// id: 'Naikkan Berat Badan & Bentuk Otot'
  String get gainWeight => 'Naikkan Berat Badan & Bentuk Otot';

  /// id: 'Turunkan Lemak & Badan Atletis'
  String get fatLoss => 'Turunkan Lemak & Badan Atletis';

  /// id: 'Jaga Berat Badan & Tetap Bugar'
  String get maintain => 'Jaga Berat Badan & Tetap Bugar';

  /// id: 'Target'
  String get target => 'Target';

  /// id: 'Saat Ini'
  String get current => 'Saat Ini';

  /// id: '$weeks Minggu Program'
  String programDuration({required Object weeks}) => '${weeks} Minggu Program';

  /// id: 'Minggu $current dari $total'
  String weekOf({required Object current, required Object total}) =>
      'Minggu ${current} dari ${total}';
}

// Path: home.todayWorkout
class Translations$home$todayWorkout$id {
  Translations$home$todayWorkout$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Latihan Hari Ini'
  String get title => 'Latihan Hari Ini';

  /// id: 'Lihat Jadwal →'
  String get viewPlan => 'Lihat Jadwal →';

  /// id: 'Mulai Latihan'
  String get startWorkout => 'Mulai Latihan';

  /// id: '≈ $min mnt'
  String approxMin({required Object min}) => '≈ ${min} mnt';

  /// id: '≈ $kcal kkal'
  String approxKcal({required Object kcal}) => '≈ ${kcal} kkal';
}

// Path: home.restDay
class Translations$home$restDay$id {
  Translations$home$restDay$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Hari Ini Istirahat'
  String get title => 'Hari Ini Istirahat';

  /// id: 'Waktunya pemulihan, biarkan ototmu pulih dan berkembang.'
  String get subtitle =>
      'Waktunya pemulihan, biarkan ototmu pulih dan berkembang.';

  /// id: 'Tips Pemulihan'
  String get recoveryTips => 'Tips Pemulihan';

  /// id: 'Cukupi kebutuhan cairan tubuh'
  String get hydrate => 'Cukupi kebutuhan cairan tubuh';

  /// id: 'Tidur cukup 7–9 jam'
  String get sleep => 'Tidur cukup 7–9 jam';

  /// id: 'Lakukan peregangan ringan atau mobilitas'
  String get stretch => 'Lakukan peregangan ringan atau mobilitas';
}

// Path: home.noProgram
class Translations$home$noProgram$id {
  Translations$home$noProgram$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Kamu belum memiliki program latihan'
  String get title => 'Kamu belum memiliki program latihan';

  /// id: 'Buat rencana latihan personal berdasarkan target, profil, dan preferensimu.'
  String get subtitle =>
      'Buat rencana latihan personal berdasarkan target, profil, dan preferensimu.';

  /// id: 'Buat Program Saya'
  String get createProgram => 'Buat Program Saya';
}

// Path: home.weeklyProgress
class Translations$home$weeklyProgress$id {
  Translations$home$weeklyProgress$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Kemajuan Minggu Ini'
  String get title => 'Kemajuan Minggu Ini';

  /// id: 'Lihat Detail →'
  String get seeDetails => 'Lihat Detail →';

  late final Translations$home$weeklyProgress$states$id states =
      Translations$home$weeklyProgress$states$id.internal(_root);
}

// Path: home.supportGoal
class Translations$home$supportGoal$id {
  Translations$home$supportGoal$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Dukung Targetmu'
  String get title => 'Dukung Targetmu';

  /// id: 'Dapatkan tips nutrisi sederhana untuk pembentukan otot.'
  String get subtitleGain =>
      'Dapatkan tips nutrisi sederhana untuk pembentukan otot.';

  /// id: 'Dapatkan tips nutrisi sederhana untuk pembakaran lemak.'
  String get subtitleLoss =>
      'Dapatkan tips nutrisi sederhana untuk pembakaran lemak.';

  /// id: 'Dapatkan tips pola makan sehat agar tetap fit.'
  String get subtitleMaintain =>
      'Dapatkan tips pola makan sehat agar tetap fit.';
}

// Path: home.error
class Translations$home$error$id {
  Translations$home$error$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Masalah koneksi'
  String get connectionIssue => 'Masalah koneksi';

  /// id: 'Sebagian data tidak dapat dimuat ulang. Menampilkan data terakhir yang tersimpan.'
  String get connectionDesc =>
      'Sebagian data tidak dapat dimuat ulang. Menampilkan data terakhir yang tersimpan.';

  /// id: 'Sinkronisasi terakhir: $time'
  String lastSynced({required Object time}) => 'Sinkronisasi terakhir: ${time}';

  /// id: 'Coba Lagi'
  String get retry => 'Coba Lagi';
}

// Path: onboarding.nav
class Translations$onboarding$nav$id {
  Translations$onboarding$nav$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: '$current dari $total'
  String progress({required Object current, required Object total}) =>
      '${current} dari ${total}';

  /// id: 'Mulai Sekarang ➔'
  String get getStarted => 'Mulai Sekarang ➔';

  /// id: 'Lanjut'
  String get continueCta => 'Lanjut';

  /// id: 'Buat Program Saya'
  String get createMyPlan => 'Buat Program Saya';

  /// id: 'Sudah punya akun?'
  String get alreadyHaveAccount => 'Sudah punya akun?';

  /// id: 'Masuk'
  String get signIn => 'Masuk';
}

// Path: onboarding.welcome
class Translations$onboarding$welcome$id {
  Translations$onboarding$welcome$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Workout Coach'
  String get brand => 'Workout\nCoach';

  /// id: 'Coach Latihan Pribadi Kamu'
  String get title => 'Coach Latihan\nPribadi Kamu';

  /// id: 'Dapatkan program latihan sesuai tujuan, kondisi tubuh, dan gaya hidup kamu.'
  String get subtitle =>
      'Dapatkan program latihan sesuai\ntujuan, kondisi tubuh,\ndan gaya hidup kamu.';
}

// Path: onboarding.goal
class Translations$onboarding$goal$id {
  Translations$onboarding$goal$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Apa tujuan utama kamu?'
  String get title => 'Apa tujuan utama kamu?';

  /// id: 'Pilih tujuan yang paling sesuai dengan fokus kamu saat ini.'
  String get subtitle =>
      'Pilih tujuan yang paling sesuai dengan fokus kamu saat ini.';

  List<GoalOption> get options => [
    Translations$onboarding$goal$options$0$id.internal(_root),
    Translations$onboarding$goal$options$1$id.internal(_root),
    Translations$onboarding$goal$options$2$id.internal(_root),
  ];
}

// Path: onboarding.about
class Translations$onboarding$about$id {
  Translations$onboarding$about$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Kenalan dulu, yuk'
  String get title => 'Kenalan dulu, yuk';

  /// id: 'Kami butuh info dasar untuk mempersonalisasi program kamu.'
  String get subtitle =>
      'Kami butuh info dasar untuk mempersonalisasi program kamu.';

  /// id: 'Jenis Kelamin'
  String get gender => 'Jenis Kelamin';

  /// id: 'Pria'
  String get male => 'Pria';

  /// id: 'Wanita'
  String get female => 'Wanita';

  /// id: 'Usia'
  String get age => 'Usia';

  /// id: 'tahun'
  String get ageUnit => 'tahun';

  /// id: 'Tinggi'
  String get height => 'Tinggi';

  /// id: 'cm'
  String get heightUnit => 'cm';
}

// Path: onboarding.bodyTarget
class Translations$onboarding$bodyTarget$id {
  Translations$onboarding$bodyTarget$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Tubuh & target kamu'
  String get title => 'Tubuh & target kamu';

  /// id: 'Atur berat badan saat ini dan target kamu.'
  String get subtitle => 'Atur berat badan saat ini dan target kamu.';

  /// id: 'Berat saat ini'
  String get currentWeight => 'Berat saat ini';

  /// id: 'Berat target'
  String get targetWeight => 'Berat target';

  /// id: 'kg'
  String get unit => 'kg';

  late final Translations$onboarding$bodyTarget$insight$id insight =
      Translations$onboarding$bodyTarget$insight$id.internal(_root);
}

// Path: onboarding.experience
class Translations$onboarding$experience$id {
  Translations$onboarding$experience$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Bagaimana level latihan kamu?'
  String get title => 'Bagaimana level latihan kamu?';

  /// id: 'Pilih yang paling menggambarkan kondisi kamu.'
  String get subtitle => 'Pilih yang paling menggambarkan kondisi kamu.';

  List<ExperienceOption> get options => [
    Translations$onboarding$experience$options$0$id.internal(_root),
    Translations$onboarding$experience$options$1$id.internal(_root),
    Translations$onboarding$experience$options$2$id.internal(_root),
  ];
}

// Path: onboarding.schedule
class Translations$onboarding$schedule$id {
  Translations$onboarding$schedule$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Seberapa sering kamu bisa latihan?'
  String get title => 'Seberapa sering kamu bisa latihan?';

  /// id: 'Pilih jadwal latihan mingguan yang cocok dengan gaya hidup kamu.'
  String get subtitle =>
      'Pilih jadwal latihan mingguan yang cocok dengan gaya hidup kamu.';

  /// id: '(other) {$n hari / minggu}'
  String daysPerWeek({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(
        n,
        other: '${n} hari / minggu',
      );

  /// id: 'Durasi sesi'
  String get sessionDuration => 'Durasi sesi';

  /// id: '$n menit'
  String minutes({required Object n}) => '${n} menit';
}

// Path: onboarding.equipment
class Translations$onboarding$equipment$id {
  Translations$onboarding$equipment$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Peralatan apa yang kamu punya?'
  String get title => 'Peralatan apa yang kamu punya?';

  /// id: 'Pilih semua yang sesuai.'
  String get subtitle => 'Pilih semua yang sesuai.';

  List<EquipmentOption> get options => [
    Translations$onboarding$equipment$options$0$id.internal(_root),
    Translations$onboarding$equipment$options$1$id.internal(_root),
    Translations$onboarding$equipment$options$2$id.internal(_root),
    Translations$onboarding$equipment$options$3$id.internal(_root),
    Translations$onboarding$equipment$options$4$id.internal(_root),
    Translations$onboarding$equipment$options$5$id.internal(_root),
  ];
}

// Path: onboarding.limitations
class Translations$onboarding$limitations$id {
  Translations$onboarding$limitations$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Ada batasan atau hal yang perlu diperhatikan?'
  String get title => 'Ada batasan atau hal yang perlu diperhatikan?';

  /// id: 'Beri tahu kami jika kamu punya kondisi kesehatan atau area yang perlu dihindari.'
  String get subtitle =>
      'Beri tahu kami jika kamu punya kondisi kesehatan atau area yang perlu dihindari.';

  List<LimitationOption> get options => [
    Translations$onboarding$limitations$options$0$id.internal(_root),
    Translations$onboarding$limitations$options$1$id.internal(_root),
    Translations$onboarding$limitations$options$2$id.internal(_root),
    Translations$onboarding$limitations$options$3$id.internal(_root),
    Translations$onboarding$limitations$options$4$id.internal(_root),
    Translations$onboarding$limitations$options$5$id.internal(_root),
  ];
}

// Path: onboarding.creating
class Translations$onboarding$creating$id {
  Translations$onboarding$creating$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Membuat program personal kamu...'
  String get title => 'Membuat\nprogram personal kamu...';

  /// id: 'Menganalisis tujuan, data tubuh, preferensi, dan ketersediaan kamu.'
  String get subtitle =>
      'Menganalisis tujuan, data tubuh,\npreferensi, dan ketersediaan kamu.';

  List<String> get steps => [
    'Menganalisis profil kamu',
    'Menghitung volume latihan',
    'Memilih latihan terbaik',
    'Menyusun rencana mingguan kamu',
  ];
}

// Path: onboarding.ready
class Translations$onboarding$ready$id {
  Translations$onboarding$ready$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program kamu siap! 🎉'
  String get title => 'Program kamu siap! 🎉';

  /// id: 'Program personal berdasarkan tujuan, profil, dan preferensi kamu.'
  String get subtitle =>
      'Program personal berdasarkan\ntujuan, profil, dan preferensi kamu.';

  /// id: '⭐ $weeks Minggu'
  String weeksBadge({required Object weeks}) => '⭐ ${weeks} Minggu';

  /// id: 'Hari / Minggu'
  String get daysPerWeek => 'Hari / Minggu';

  /// id: 'Menit / Sesi'
  String get minutesPerSession => 'Menit / Sesi';

  /// id: 'Level'
  String get level => 'Level';

  List<String> get features => [
    'Membangun otot dan menambah berat badan',
    'Progressive overload (beban naik bertahap)',
    'Dirancang untuk latihan di rumah',
    'Disesuaikan dengan jadwal dan alat kamu',
  ];

  /// id: 'Mulai Program Saya'
  String get viewMyPlan => 'Mulai Program Saya';

  late final Translations$onboarding$ready$program$id program =
      Translations$onboarding$ready$program$id.internal(_root);
}

// Path: onboarding.preview
class Translations$onboarding$preview$id {
  Translations$onboarding$preview$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program Latihan Kamu'
  String get title => 'Program Latihan Kamu';

  /// id: 'Ringkasan'
  String get tabOverview => 'Ringkasan';

  /// id: 'Pembagian Latihan'
  String get tabWorkoutSplit => 'Pembagian Latihan';

  /// id: 'Memuat pratinjau program kamu...'
  String get loading => 'Memuat pratinjau program kamu...';

  /// id: 'Aktifkan & Mulai Latihan ➔'
  String get activateStart => 'Aktifkan & Mulai Latihan ➔';

  /// id: 'Aktifkan & Buka Dashboard'
  String get activateDashboard => 'Aktifkan & Buka Dashboard';

  /// id: 'Sesi $n'
  String sessionFallbackName({required Object n}) => 'Sesi ${n}';

  /// id: '$n menit'
  String sessionDuration({required Object n}) => '${n} menit';

  /// id: 'LATIHAN DI SESI INI ($count)'
  String exercisesInSession({required Object count}) =>
      'LATIHAN DI SESI INI (${count})';

  /// id: '$sets set • $reps repetisi • istirahat $rests dtk'
  String prescription({
    required Object sets,
    required Object reps,
    required Object rests,
  }) => '${sets} set • ${reps} repetisi • istirahat ${rests} dtk';
}

// Path: profile.appSettings
class Translations$profile$appSettings$id {
  Translations$profile$appSettings$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Pengaturan Aplikasi'
  String get title => 'Pengaturan Aplikasi';

  /// id: 'Sesuaikan pengalaman aplikasi Anda.'
  String get subtitle => 'Sesuaikan pengalaman aplikasi Anda.';

  /// id: 'Bahasa'
  String get language => 'Bahasa';

  /// id: 'Pilih Bahasa'
  String get selectLanguage => 'Pilih Bahasa';

  /// id: 'English'
  String get languageEnglish => 'English';

  /// id: 'Bahasa Indonesia'
  String get languageIndonesian => 'Bahasa Indonesia';

  /// id: 'Tema'
  String get theme => 'Tema';

  /// id: 'Pilih Tema'
  String get selectTheme => 'Pilih Tema';

  /// id: 'Terang'
  String get themeLight => 'Terang';

  /// id: 'Gelap'
  String get themeDark => 'Gelap';

  /// id: 'Ikuti Sistem'
  String get themeSystem => 'Ikuti Sistem';

  /// id: 'Satuan'
  String get units => 'Satuan';

  /// id: 'Pilih Satuan'
  String get selectUnits => 'Pilih Satuan';

  /// id: 'Metrik (kg, cm)'
  String get unitsMetric => 'Metrik (kg, cm)';

  /// id: 'Imperial (lbs, in)'
  String get unitsImperial => 'Imperial (lbs, in)';

  /// id: 'Umpan Balik Haptik'
  String get hapticFeedback => 'Umpan Balik Haptik';

  /// id: 'Getar saat aksi (mulai, istirahat, selesai)'
  String get hapticFeedbackSubtitle =>
      'Getar saat aksi (mulai, istirahat, selesai)';

  /// id: 'Efek Suara'
  String get soundEffects => 'Efek Suara';

  /// id: 'Timer latihan dan transisi'
  String get soundEffectsSubtitle => 'Timer latihan dan transisi';

  /// id: 'Sinkronisasi Data'
  String get dataSync => 'Sinkronisasi Data';

  /// id: 'Cadangkan data Anda ke akun'
  String get dataSyncSubtitle => 'Cadangkan data Anda ke akun';

  /// id: 'Gagal menyimpan pengaturan. Silakan coba lagi.'
  String get saveError => 'Gagal menyimpan pengaturan. Silakan coba lagi.';

  /// id: 'Sinkronisasi Cloud dinonaktifkan untuk sesi ini, tetapi preferensinya gagal disimpan.'
  String get cloudSyncDisableError =>
      'Sinkronisasi Cloud dinonaktifkan untuk sesi ini, tetapi preferensinya gagal disimpan.';

  /// id: 'Masuk dengan akun terlebih dahulu sebelum mengaktifkan Sinkronisasi Cloud.'
  String get cloudSyncSignInRequired =>
      'Masuk dengan akun terlebih dahulu sebelum mengaktifkan Sinkronisasi Cloud.';

  /// id: 'Gagal mengaktifkan Sinkronisasi Cloud. Silakan coba lagi.'
  String get cloudSyncEnableError =>
      'Gagal mengaktifkan Sinkronisasi Cloud. Silakan coba lagi.';

  /// id: 'Aktifkan Sinkronisasi Cloud?'
  String get cloudSyncDialogTitle => 'Aktifkan Sinkronisasi Cloud?';

  /// id: 'Profil, pengaturan, riwayat latihan, dan data progres Anda akan disinkronkan ke akun Supabase Anda. Data SQLite lokal tetap tersimpan di perangkat ini. Anda dapat menonaktifkan Sinkronisasi Cloud kapan saja.'
  String get cloudSyncDialogBody =>
      'Profil, pengaturan, riwayat latihan, dan data progres Anda akan disinkronkan ke akun Supabase Anda. Data SQLite lokal tetap tersimpan di perangkat ini. Anda dapat menonaktifkan Sinkronisasi Cloud kapan saja.';

  /// id: 'Nanti saja'
  String get cloudSyncDialogCancel => 'Nanti saja';

  /// id: 'Setuju dan aktifkan'
  String get cloudSyncDialogConfirm => 'Setuju dan aktifkan';
}

// Path: workoutSession.completedScreen
class Translations$workoutSession$completedScreen$id {
  Translations$workoutSession$completedScreen$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Workout Selesai! 🎉'
  String get title => 'Workout Selesai! 🎉';

  /// id: 'Kerja bagus! Kamu telah menyelesaikan $focus.'
  String subtitle({required Object focus}) =>
      'Kerja bagus! Kamu telah menyelesaikan ${focus}.';

  /// id: 'Durasi'
  String get duration => 'Durasi';

  /// id: 'Latihan'
  String get exercises => 'Latihan';

  /// id: 'Est. Kalori'
  String get estCalories => 'Est. Kalori';

  /// id: 'menit'
  String get minUnit => 'menit';

  /// id: 'Bagaimana latihannya?'
  String get howWasWorkout => 'Bagaimana latihannya?';

  /// id: 'Terlalu Mudah'
  String get tooEasy => 'Terlalu Mudah';

  /// id: 'Mudah'
  String get easy => 'Mudah';

  /// id: 'Pas Banget'
  String get justRight => 'Pas Banget';

  /// id: 'Berat'
  String get hard => 'Berat';

  /// id: 'Terlalu Berat'
  String get tooHard => 'Terlalu Berat';

  /// id: 'Simpan & Lanjutkan'
  String get saveAndContinue => 'Simpan & Lanjutkan';

  /// id: 'Lihat Ringkasan Latihan'
  String get viewWorkoutSummary => 'Lihat Ringkasan Latihan';
}

// Path: workouts.tabs
class Translations$workouts$tabs$id {
  Translations$workouts$tabs$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program Saya'
  String get myProgram => 'Program Saya';

  /// id: 'Semua Latihan'
  String get allWorkouts => 'Semua Latihan';
}

// Path: workouts.activeProgram
class Translations$workouts$activeProgram$id {
  Translations$workouts$activeProgram$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program Aktif'
  String get title => 'Program Aktif';

  /// id: '$weeks minggu • Latihan di rumah'
  String weeksHomeWorkout({required Object weeks}) =>
      '${weeks} minggu • Latihan di rumah';

  /// id: 'Minggu $current dari $total'
  String weekOf({required Object current, required Object total}) =>
      'Minggu ${current} dari ${total}';

  late final Translations$workouts$activeProgram$status$id status =
      Translations$workouts$activeProgram$status$id.internal(_root);
}

// Path: workouts.weeklySchedule
class Translations$workouts$weeklySchedule$id {
  Translations$workouts$weeklySchedule$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Jadwal Mingguan'
  String get title => 'Jadwal Mingguan';

  /// id: '$completed/$total latihan'
  String workoutCount({required Object completed, required Object total}) =>
      '${completed}/${total} latihan';

  /// id: 'Saat Ini'
  String get current => 'Saat Ini';

  /// id: 'W$n'
  String weekShort({required Object n}) => 'W${n}';

  /// id: 'Minggu $n'
  String weekNumber({required Object n}) => 'Minggu ${n}';

  /// id: 'Tidak ada sesi latihan yang dijadwalkan untuk minggu ini.'
  String get empty =>
      'Tidak ada sesi latihan yang dijadwalkan untuk minggu ini.';

  /// id: 'Mode pratinjau'
  String get previewTitle => 'Mode pratinjau';

  /// id: 'Kamu bisa melihat rencana minggu ini, tapi latihan baru bisa dimulai sesuai jadwalnya.'
  String get previewNotice =>
      'Kamu bisa melihat rencana minggu ini, tapi latihan baru bisa dimulai sesuai jadwalnya.';

  /// id: 'Pratinjau minggu mendatang'
  String get previewTooltip => 'Pratinjau minggu mendatang';

  late final Translations$workouts$weeklySchedule$statusTooltip$id
  statusTooltip =
      Translations$workouts$weeklySchedule$statusTooltip$id.internal(_root);
}

// Path: workouts.emptyState
class Translations$workouts$emptyState$id {
  Translations$workouts$emptyState$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Belum ada program aktif'
  String get noProgramTitle => 'Belum ada program aktif';

  /// id: 'Buat program untuk melihat jadwal latihan mingguanmu di sini.'
  String get noProgramSubtitle =>
      'Buat program untuk melihat jadwal latihan mingguanmu di sini.';
}

// Path: workouts.allWorkouts
class Translations$workouts$allWorkouts$id {
  Translations$workouts$allWorkouts$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Tidak ada latihan ditemukan'
  String get emptyTitle => 'Tidak ada latihan ditemukan';

  /// id: 'Coba kata kunci lain atau ubah filter otot.'
  String get emptySubtitle => 'Coba kata kunci lain atau ubah filter otot.';

  /// id: 'Hapus pencarian & filter'
  String get clearFilters => 'Hapus pencarian & filter';
}

// Path: workouts.errorState
class Translations$workouts$errorState$id {
  Translations$workouts$errorState$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Gagal memuat data'
  String get title => 'Gagal memuat data';

  /// id: 'Terjadi kesalahan saat membaca data latihan. Coba lagi.'
  String get subtitle =>
      'Terjadi kesalahan saat membaca data latihan. Coba lagi.';

  /// id: 'Coba Lagi'
  String get retry => 'Coba Lagi';

  /// id: 'Gagal memperbarui data. Menampilkan data terakhir.'
  String get refreshFailed =>
      'Gagal memperbarui data. Menampilkan data terakhir.';
}

// Path: workouts.session
class Translations$workouts$session$id {
  Translations$workouts$session$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Hari $n'
  String day({required Object n}) => 'Hari ${n}';

  /// id: 'Hari $n • $date'
  String date({required Object n, required Object date}) =>
      'Hari ${n} • ${date}';

  /// id: '$min mnt'
  String min({required Object min}) => '${min} mnt';

  late final Translations$workouts$session$status$id status =
      Translations$workouts$session$status$id.internal(_root);
}

// Path: workouts.workoutDetail
class Translations$workouts$workoutDetail$id {
  Translations$workouts$workoutDetail$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Mode pratinjau'
  String get readOnlyTitle => 'Mode pratinjau';

  /// id: 'Rencana latihan ini hanya bisa dilihat. Tombol mulai aktif pada hari yang dijadwalkan.'
  String get readOnlyNotice =>
      'Rencana latihan ini hanya bisa dilihat. Tombol mulai aktif pada hari yang dijadwalkan.';

  /// id: 'Lanjutkan Latihan'
  String get resume => 'Lanjutkan Latihan';

  /// id: 'Salin detail latihan'
  String get shareTooltip => 'Salin detail latihan';

  /// id: 'Bookmark latihan'
  String get bookmarkAdd => 'Bookmark latihan';

  /// id: 'Hapus bookmark'
  String get bookmarkRemove => 'Hapus bookmark';

  /// id: 'Detail latihan berhasil disalin.'
  String get copiedMessage => 'Detail latihan berhasil disalin.';

  /// id: 'Tingkatkan kekuatan dan kebugaran tubuh dengan gerakan terpilih.'
  String get defaultDescription =>
      'Tingkatkan kekuatan dan kebugaran tubuh dengan gerakan terpilih.';

  /// id: '$count latihan'
  String exerciseCount({required Object count}) => '${count} latihan';

  /// id: 'Daftar Gerakan ($count)'
  String exerciseListTitle({required Object count}) =>
      'Daftar Gerakan (${count})';

  late final Translations$workouts$workoutDetail$stages$id stages =
      Translations$workouts$workoutDetail$stages$id.internal(_root);

  /// id: '$sets set × $reps'
  String setReps({required Object sets, required Object reps}) =>
      '${sets} set × ${reps}';

  /// id: 'repetisi'
  String get repsUnit => 'repetisi';
}

// Path: workouts.filter
class Translations$workouts$filter$id {
  Translations$workouts$filter$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Filter Berdasarkan Otot'
  String get title => 'Filter Berdasarkan Otot';
}

// Path: workouts.categories
class Translations$workouts$categories$id {
  Translations$workouts$categories$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Semua'
  String get all => 'Semua';

  /// id: 'Dada'
  String get chest => 'Dada';

  /// id: 'Punggung'
  String get back => 'Punggung';

  /// id: 'Kaki'
  String get legs => 'Kaki';

  /// id: 'Perut'
  String get core => 'Perut';

  /// id: 'Lengan'
  String get arms => 'Lengan';

  /// id: 'Bahu'
  String get shoulders => 'Bahu';
}

// Path: core.progress.tabs
class Translations$core$progress$tabs$id {
  Translations$core$progress$tabs$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Ringkasan'
  String get overview => 'Ringkasan';

  /// id: 'Tubuh'
  String get body => 'Tubuh';

  /// id: 'Latihan'
  String get workout => 'Latihan';

  /// id: 'Riwayat'
  String get history => 'Riwayat';
}

// Path: core.progress.metrics
class Translations$core$progress$metrics$id {
  Translations$core$progress$metrics$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Latihan'
  String get workouts => 'Latihan';

  /// id: 'Penyelesaian'
  String get completion => 'Penyelesaian';

  /// id: 'Waktu Latihan'
  String get trainingTime => 'Waktu Latihan';

  /// id: 'Konsistensi Saat Ini'
  String get currentStreak => 'Konsistensi Saat Ini';
}

// Path: core.progress.noWorkoutData
class Translations$core$progress$noWorkoutData$id {
  Translations$core$progress$noWorkoutData$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Belum ada data latihan'
  String get title => 'Belum ada data latihan';

  /// id: 'Selesaikan latihan pertama Anda untuk melihat progres di sini.'
  String get message =>
      'Selesaikan latihan pertama Anda untuk melihat progres di sini.';
}

// Path: core.progress.noActiveProgram
class Translations$core$progress$noActiveProgram$id {
  Translations$core$progress$noActiveProgram$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Belum ada program aktif'
  String get title => 'Belum ada program aktif';

  /// id: 'Pilih program latihan untuk melacak progres mingguan Anda.'
  String get message =>
      'Pilih program latihan untuk melacak progres mingguan Anda.';
}

// Path: core.progress.weightTrend
class Translations$core$progress$weightTrend$id {
  Translations$core$progress$weightTrend$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Berat Badan (kg)'
  String get title => 'Berat Badan (kg)';

  /// id: 'M$week · $value kg'
  String weekValue({required Object week, required Object value}) =>
      'M${week} · ${value} kg';

  /// id: 'M$week'
  String weekShort({required Object week}) => 'M${week}';

  /// id: 'Belum ada pengukuran berat badan pada periode ini.'
  String get empty => 'Belum ada pengukuran berat badan pada periode ini.';

  /// id: 'dibanding $weeks minggu lalu'
  String vsWeeksAgo({required Object weeks}) =>
      'dibanding ${weeks} minggu lalu';

  /// id: '↑ +$value kg'
  String increase({required Object value}) => '↑ +${value} kg';

  /// id: '↓ $value kg'
  String decrease({required Object value}) => '↓ ${value} kg';
}

// Path: core.progress.notTracked
class Translations$core$progress$notTracked$id {
  Translations$core$progress$notTracked$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Pelacakan $metric belum tersedia'
  String title({required Object metric}) =>
      'Pelacakan ${metric} belum tersedia';

  /// id: 'Metrik ini belum tersimpan dalam pengukuran Anda.'
  String get message => 'Metrik ini belum tersimpan dalam pengukuran Anda.';
}

// Path: core.progress.programCard
class Translations$core$progress$programCard$id {
  Translations$core$progress$programCard$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Minggu $week dari $total'
  String weekOf({required Object week, required Object total}) =>
      'Minggu ${week} dari ${total}';

  /// id: 'Aktif'
  String get active => 'Aktif';

  /// id: 'Penyelesaian program'
  String get completion => 'Penyelesaian program';
}

// Path: core.progress.highlights
class Translations$core$progress$highlights$id {
  Translations$core$progress$highlights$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Menyelesaikan $completed dari $target latihan minggu ini'
  String completed({required Object completed, required Object target}) =>
      'Menyelesaikan ${completed} dari ${target} latihan minggu ini';

  /// id: 'Berat badan naik $value kg'
  String weightIncrease({required Object value}) =>
      'Berat badan naik ${value} kg';

  /// id: 'Berat badan turun $value kg'
  String weightDecrease({required Object value}) =>
      'Berat badan turun ${value} kg';

  /// id: 'Belum ada sorotan'
  String get emptyTitle => 'Belum ada sorotan';

  /// id: 'Pencapaian Anda akan muncul saat Anda mencatat latihan dan pengukuran.'
  String get emptyMessage =>
      'Pencapaian Anda akan muncul saat Anda mencatat latihan dan pengukuran.';
}

// Path: core.progress.body
class Translations$core$progress$body$id {
  Translations$core$progress$body$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Progres Tubuh'
  String get title => 'Progres Tubuh';

  /// id: 'Pantau perubahan tubuh Anda dari waktu ke waktu.'
  String get subtitle => 'Pantau perubahan tubuh Anda dari waktu ke waktu.';

  /// id: 'Berat Badan'
  String get weight => 'Berat Badan';

  /// id: 'Massa Otot'
  String get muscleMass => 'Massa Otot';

  /// id: 'Lemak Tubuh'
  String get bodyFat => 'Lemak Tubuh';

  /// id: 'Catat Pengukuran'
  String get logMeasurement => 'Catat Pengukuran';

  /// id: 'Catat Berat Badan'
  String get recordWeight => 'Catat Berat Badan';

  /// id: 'Berat Badan Saat Ini'
  String get currentWeight => 'Berat Badan Saat Ini';
}

// Path: core.progress.workout
class Translations$core$progress$workout$id {
  Translations$core$progress$workout$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Performa Latihan'
  String get title => 'Performa Latihan';

  /// id: 'Progres dan konsistensi latihan Anda.'
  String get subtitle => 'Progres dan konsistensi latihan Anda.';

  late final Translations$core$progress$workout$noPerformance$id noPerformance =
      Translations$core$progress$workout$noPerformance$id.internal(_root);

  /// id: 'Aktivitas Mingguan'
  String get weeklyActivity => 'Aktivitas Mingguan';

  late final Translations$core$progress$workout$noActivity$id noActivity =
      Translations$core$progress$workout$noActivity$id.internal(_root);

  /// id: 'Volume Latihan'
  String get trainingVolume => 'Volume Latihan';

  late final Translations$core$progress$workout$noVolume$id noVolume =
      Translations$core$progress$workout$noVolume$id.internal(_root);

  /// id: 'Latihan Terbaru'
  String get recentWorkouts => 'Latihan Terbaru';

  late final Translations$core$progress$workout$noRecentWorkouts$id
  noRecentWorkouts =
      Translations$core$progress$workout$noRecentWorkouts$id.internal(_root);

  /// id: 'Menit per hari'
  String get minutesPerDay => 'Menit per hari';

  /// id: '$minutes menit total'
  String minutesTotal({required Object minutes}) => '${minutes} menit total';

  /// id: '$minutes menit latihan minggu ini'
  String trainingMinutesThisWeek({required Object minutes}) =>
      '${minutes} menit latihan minggu ini';

  /// id: 'Total Waktu'
  String get totalTime => 'Total Waktu';
}

// Path: core.progress.history
class Translations$core$progress$history$id {
  Translations$core$progress$history$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Semua'
  String get all => 'Semua';

  /// id: 'Latihan'
  String get workout => 'Latihan';

  /// id: 'Pengukuran'
  String get measurement => 'Pengukuran';

  /// id: 'Terlama dahulu'
  String get oldestFirst => 'Terlama dahulu';

  /// id: 'Terbaru dahulu'
  String get newestFirst => 'Terbaru dahulu';

  /// id: 'Catat berat badan'
  String get recordWeight => 'Catat berat badan';
}

// Path: core.progress.duration
class Translations$core$progress$duration$id {
  Translations$core$progress$duration$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: '${minutes} mnt'
  String minutes({required Object minutes}) => '${minutes} mnt';

  /// id: '${hours}j'
  String hours({required Object hours}) => '${hours}j';

  /// id: '${hours}j ${minutes}mnt'
  String hoursMinutes({required Object hours, required Object minutes}) =>
      '${hours}j ${minutes}mnt';
}

// Path: core.progress.weightDialog
class Translations$core$progress$weightDialog$id {
  Translations$core$progress$weightDialog$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Catat berat badan'
  String get title => 'Catat berat badan';

  /// id: 'Berat badan saat ini'
  String get currentWeight => 'Berat badan saat ini';

  /// id: 'Batal'
  String get cancel => 'Batal';

  /// id: 'Simpan'
  String get save => 'Simpan';
}

// Path: core.progress.error
class Translations$core$progress$error$id {
  Translations$core$progress$error$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Gagal memuat progres'
  String get title => 'Gagal memuat progres';

  /// id: 'Coba lagi'
  String get retry => 'Coba lagi';
}

// Path: home.weeklyProgress.states
class Translations$home$weeklyProgress$states$id {
  Translations$home$weeklyProgress$states$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Selesai (latihan tuntas)'
  String get completed => 'Selesai (latihan tuntas)';

  /// id: 'Hari Ini (jadwal latihan)'
  String get today => 'Hari Ini (jadwal latihan)';

  /// id: 'Hari istirahat'
  String get rest => 'Hari istirahat';

  /// id: 'Mendatang (belum)'
  String get upcoming => 'Mendatang (belum)';

  /// id: 'Terlewat'
  String get missed => 'Terlewat';
}

// Path: onboarding.goal.options.0
class Translations$onboarding$goal$options$0$id with GoalOption {
  Translations$onboarding$goal$options$0$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'muscle_gain';

  @override
  String get title => 'Naikkan Berat & Bangun Otot';

  @override
  String get description =>
      'Tambah berat badan sambil membangun massa otot (bulking).';
}

// Path: onboarding.goal.options.1
class Translations$onboarding$goal$options$1$id with GoalOption {
  Translations$onboarding$goal$options$1$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'fat_loss';

  @override
  String get title => 'Turunkan Berat & Kurangi Lemak';

  @override
  String get description =>
      'Kurangi lemak tubuh tanpa kehilangan otot (cutting).';
}

// Path: onboarding.goal.options.2
class Translations$onboarding$goal$options$2$id with GoalOption {
  Translations$onboarding$goal$options$2$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'maintenance';

  @override
  String get title => 'Jaga Berat & Tetap Bugar';

  @override
  String get description =>
      'Pertahankan berat badan dan kebugaran kamu saat ini.';
}

// Path: onboarding.bodyTarget.insight
class Translations$onboarding$bodyTarget$insight$id {
  Translations$onboarding$bodyTarget$insight$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Target naik: +$diff kg'
  String gainTitle({required Object diff}) => 'Target naik: +${diff} kg';

  /// id: 'Target turun: $diff kg'
  String lossTitle({required Object diff}) => 'Target turun: ${diff} kg';

  /// id: 'Target: Menjaga'
  String get maintainTitle => 'Target: Menjaga';

  /// id: 'Kenaikan yang sehat sekitar 0,25 - 0,5 kg per minggu ($minWeeks - $maxWeeks minggu).'
  String gainHint({required Object minWeeks, required Object maxWeeks}) =>
      'Kenaikan yang sehat sekitar 0,25 - 0,5 kg per minggu (${minWeeks} - ${maxWeeks} minggu).';

  /// id: 'Penurunan yang sehat sekitar 0,5 - 1,0 kg per minggu ($minWeeks - $maxWeeks minggu).'
  String lossHint({required Object minWeeks, required Object maxWeeks}) =>
      'Penurunan yang sehat sekitar 0,5 - 1,0 kg per minggu (${minWeeks} - ${maxWeeks} minggu).';

  /// id: 'Pertahankan berat badan kamu dan fokus pada kepadatan otot serta kekuatan.'
  String get maintainHint =>
      'Pertahankan berat badan kamu dan fokus pada kepadatan otot serta kekuatan.';
}

// Path: onboarding.experience.options.0
class Translations$onboarding$experience$options$0$id with ExperienceOption {
  Translations$onboarding$experience$options$0$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'beginner';

  @override
  String get title => 'Pemula';

  @override
  String get description => 'Baru mulai latihan atau masih belum konsisten.';
}

// Path: onboarding.experience.options.1
class Translations$onboarding$experience$options$1$id with ExperienceOption {
  Translations$onboarding$experience$options$1$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'intermediate';

  @override
  String get title => 'Menengah';

  @override
  String get description => 'Sudah punya pengalaman dan rutin latihan.';
}

// Path: onboarding.experience.options.2
class Translations$onboarding$experience$options$2$id with ExperienceOption {
  Translations$onboarding$experience$options$2$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'advanced';

  @override
  String get title => 'Lanjutan';

  @override
  String get description =>
      'Latihan konsisten, form sudah bagus, dan ingin tantangan lebih besar.';
}

// Path: onboarding.equipment.options.0
class Translations$onboarding$equipment$options$0$id with EquipmentOption {
  Translations$onboarding$equipment$options$0$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'bodyweight';

  @override
  String get label => 'Berat Tubuh\n(tanpa alat)';
}

// Path: onboarding.equipment.options.1
class Translations$onboarding$equipment$options$1$id with EquipmentOption {
  Translations$onboarding$equipment$options$1$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'dumbbell';

  @override
  String get label => 'Dumbbell';
}

// Path: onboarding.equipment.options.2
class Translations$onboarding$equipment$options$2$id with EquipmentOption {
  Translations$onboarding$equipment$options$2$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'resistance_band';

  @override
  String get label => 'Resistance\nBand';
}

// Path: onboarding.equipment.options.3
class Translations$onboarding$equipment$options$3$id with EquipmentOption {
  Translations$onboarding$equipment$options$3$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'kettlebell';

  @override
  String get label => 'Kettlebell';
}

// Path: onboarding.equipment.options.4
class Translations$onboarding$equipment$options$4$id with EquipmentOption {
  Translations$onboarding$equipment$options$4$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'pull_up_bar';

  @override
  String get label => 'Pull-up Bar';
}

// Path: onboarding.equipment.options.5
class Translations$onboarding$equipment$options$5$id with EquipmentOption {
  Translations$onboarding$equipment$options$5$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'barbell';

  @override
  String get label => 'Barbell';
}

// Path: onboarding.limitations.options.0
class Translations$onboarding$limitations$options$0$id with LimitationOption {
  Translations$onboarding$limitations$options$0$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'none';

  @override
  String get label => 'Tanpa batasan';
}

// Path: onboarding.limitations.options.1
class Translations$onboarding$limitations$options$1$id with LimitationOption {
  Translations$onboarding$limitations$options$1$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'knee';

  @override
  String get label => 'Lutut (mis. nyeri, cedera)';
}

// Path: onboarding.limitations.options.2
class Translations$onboarding$limitations$options$2$id with LimitationOption {
  Translations$onboarding$limitations$options$2$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'back';

  @override
  String get label => 'Punggung (mis. nyeri punggung bawah)';
}

// Path: onboarding.limitations.options.3
class Translations$onboarding$limitations$options$3$id with LimitationOption {
  Translations$onboarding$limitations$options$3$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'shoulder';

  @override
  String get label => 'Bahu';
}

// Path: onboarding.limitations.options.4
class Translations$onboarding$limitations$options$4$id with LimitationOption {
  Translations$onboarding$limitations$options$4$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'wrist';

  @override
  String get label => 'Pergelangan tangan';
}

// Path: onboarding.limitations.options.5
class Translations$onboarding$limitations$options$5$id with LimitationOption {
  Translations$onboarding$limitations$options$5$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  @override
  String get id => 'other';

  @override
  String get label => 'Lainnya';
}

// Path: onboarding.ready.program
class Translations$onboarding$ready$program$id {
  Translations$onboarding$ready$program$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$onboarding$ready$program$bulking$id bulking =
      Translations$onboarding$ready$program$bulking$id.internal(_root);
  late final Translations$onboarding$ready$program$cutting$id cutting =
      Translations$onboarding$ready$program$cutting$id.internal(_root);
  late final Translations$onboarding$ready$program$maintain$id maintain =
      Translations$onboarding$ready$program$maintain$id.internal(_root);
}

// Path: workouts.activeProgram.status
class Translations$workouts$activeProgram$status$id {
  Translations$workouts$activeProgram$status$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Dimulai $date'
  String notStarted({required Object date}) => 'Dimulai ${date}';

  /// id: 'Program selesai'
  String get completed => 'Program selesai';

  /// id: 'Program berakhir'
  String get expired => 'Program berakhir';
}

// Path: workouts.weeklySchedule.statusTooltip
class Translations$workouts$weeklySchedule$statusTooltip$id {
  Translations$workouts$weeklySchedule$statusTooltip$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Semua latihan selesai'
  String get completed => 'Semua latihan selesai';

  /// id: 'Sebagian latihan selesai'
  String get partial => 'Sebagian latihan selesai';

  /// id: 'Ada latihan yang terlewat'
  String get missed => 'Ada latihan yang terlewat';
}

// Path: workouts.session.status
class Translations$workouts$session$status$id {
  Translations$workouts$session$status$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Selesai'
  String get completed => 'Selesai';

  /// id: 'Sedang berlangsung'
  String get inProgress => 'Sedang berlangsung';

  /// id: 'Hari Ini • Siap dimulai'
  String get readyToStart => 'Hari Ini • Siap dimulai';

  /// id: 'Terlewat'
  String get missed => 'Terlewat';

  /// id: 'Terjadwal'
  String get scheduled => 'Terjadwal';
}

// Path: workouts.workoutDetail.stages
class Translations$workouts$workoutDetail$stages$id {
  Translations$workouts$workoutDetail$stages$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$workouts$workoutDetail$stages$warmup$id warmup =
      Translations$workouts$workoutDetail$stages$warmup$id.internal(_root);
  late final Translations$workouts$workoutDetail$stages$main$id main =
      Translations$workouts$workoutDetail$stages$main$id.internal(_root);
  late final Translations$workouts$workoutDetail$stages$cooldown$id cooldown =
      Translations$workouts$workoutDetail$stages$cooldown$id.internal(_root);
}

// Path: core.progress.workout.noPerformance
class Translations$core$progress$workout$noPerformance$id {
  Translations$core$progress$workout$noPerformance$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Belum ada performa latihan'
  String get title => 'Belum ada performa latihan';

  /// id: 'Aktivitas mingguan dan volume latihan akan muncul setelah Anda menyelesaikan latihan.'
  String get message =>
      'Aktivitas mingguan dan volume latihan akan muncul setelah Anda menyelesaikan latihan.';
}

// Path: core.progress.workout.noActivity
class Translations$core$progress$workout$noActivity$id {
  Translations$core$progress$workout$noActivity$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Belum ada aktivitas minggu ini'
  String get title => 'Belum ada aktivitas minggu ini';

  /// id: 'Durasi latihan yang selesai akan dirangkum di sini.'
  String get message => 'Durasi latihan yang selesai akan dirangkum di sini.';
}

// Path: core.progress.workout.noVolume
class Translations$core$progress$workout$noVolume$id {
  Translations$core$progress$workout$noVolume$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Belum ada volume latihan'
  String get title => 'Belum ada volume latihan';

  /// id: 'Total set dan repetisi akan muncul setelah Anda mencatat set yang selesai.'
  String get message =>
      'Total set dan repetisi akan muncul setelah Anda mencatat set yang selesai.';
}

// Path: core.progress.workout.noRecentWorkouts
class Translations$core$progress$workout$noRecentWorkouts$id {
  Translations$core$progress$workout$noRecentWorkouts$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Belum ada latihan terbaru'
  String get title => 'Belum ada latihan terbaru';

  /// id: 'Sesi yang telah Anda selesaikan akan muncul di sini.'
  String get message => 'Sesi yang telah Anda selesaikan akan muncul di sini.';
}

// Path: onboarding.ready.program.bulking
class Translations$onboarding$ready$program$bulking$id {
  Translations$onboarding$ready$program$bulking$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program Bulking'
  String get title => 'Program Bulking';

  /// id: 'Massa Otot & Kekuatan'
  String get subtitle => 'Massa Otot & Kekuatan';
}

// Path: onboarding.ready.program.cutting
class Translations$onboarding$ready$program$cutting$id {
  Translations$onboarding$ready$program$cutting$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program Turun Lemak'
  String get title => 'Program Turun Lemak';

  /// id: 'Turun Lemak & Tonus'
  String get subtitle => 'Turun Lemak & Tonus';
}

// Path: onboarding.ready.program.maintain
class Translations$onboarding$ready$program$maintain$id {
  Translations$onboarding$ready$program$maintain$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program Jaga Bugar'
  String get title => 'Program Jaga Bugar';

  /// id: 'Kekuatan & Kebugaran Umum'
  String get subtitle => 'Kekuatan & Kebugaran Umum';
}

// Path: workouts.workoutDetail.stages.warmup
class Translations$workouts$workoutDetail$stages$warmup$id {
  Translations$workouts$workoutDetail$stages$warmup$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Pemanasan'
  String get title => 'Pemanasan';

  /// id: 'Persiapan'
  String get subtitle => 'Persiapan';
}

// Path: workouts.workoutDetail.stages.main
class Translations$workouts$workoutDetail$stages$main$id {
  Translations$workouts$workoutDetail$stages$main$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Latihan Inti'
  String get title => 'Latihan Inti';

  /// id: 'Latihan Utama'
  String get subtitle => 'Latihan Utama';
}

// Path: workouts.workoutDetail.stages.cooldown
class Translations$workouts$workoutDetail$stages$cooldown$id {
  Translations$workouts$workoutDetail$stages$cooldown$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Pendinginan'
  String get title => 'Pendinginan';

  /// id: 'Pemulihan'
  String get subtitle => 'Pemulihan';
}

/// The flat map containing all translations for locale <id>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'core.appName' => 'Home Bulking Coach',
      'core.actions.save' => 'Simpan',
      'core.actions.cancel' => 'Batal',
      'core.actions.back' => 'Kembali',
      'core.actions.next' => 'Lanjut',
      'core.actions.skip' => 'Lewati',
      'core.actions.done' => 'Selesai',
      'core.actions.retry' => 'Coba Lagi',
      'core.actions.close' => 'Tutup',
      'core.actions.edit' => 'Ubah',
      'core.actions.delete' => 'Hapus',
      'core.state.loading' => 'Memuat...',
      'core.state.empty' => 'Belum ada data',
      'core.state.error' => 'Terjadi kesalahan',
      'core.badge.currentPlan' => 'Program Aktif',
      'core.language.label' => 'Bahasa',
      'core.language.id' => 'Bahasa Indonesia',
      'core.language.en' => 'English',
      'core.units.reps' => 'repetisi',
      'core.units.sets' => 'set',
      'core.units.seconds' => 'detik',
      'core.units.kg' => 'kg',
      'core.streak.daySingular' => ({required Object count}) => '${count} hari',
      'core.streak.dayPlural' => ({required Object count}) => '${count} hari',
      'core.streak.activeDaySingular' => ({
        required Object count,
      }) => '${count} hari aktif',
      'core.streak.activeDayPlural' => ({
        required Object count,
      }) => '${count} hari aktif',
      'core.progress.title' => 'Progres',
      'core.progress.rangeWeeks' => ({
        required Object weeks,
      }) => '${weeks} Minggu Terakhir',
      'core.progress.tabs.overview' => 'Ringkasan',
      'core.progress.tabs.body' => 'Tubuh',
      'core.progress.tabs.workout' => 'Latihan',
      'core.progress.tabs.history' => 'Riwayat',
      'core.progress.overviewTitle' => 'Progres Anda',
      'core.progress.overviewSubtitle' =>
        'Ringkasan latihan dan progres tubuh Anda.',
      'core.progress.metrics.workouts' => 'Latihan',
      'core.progress.metrics.completion' => 'Penyelesaian',
      'core.progress.metrics.trainingTime' => 'Waktu Latihan',
      'core.progress.metrics.currentStreak' => 'Konsistensi Saat Ini',
      'core.progress.programProgress' => 'Progres Program',
      'core.progress.noWorkoutData.title' => 'Belum ada data latihan',
      'core.progress.noWorkoutData.message' =>
        'Selesaikan latihan pertama Anda untuk melihat progres di sini.',
      'core.progress.noActiveProgram.title' => 'Belum ada program aktif',
      'core.progress.noActiveProgram.message' =>
        'Pilih program latihan untuk melacak progres mingguan Anda.',
      'core.progress.recentHighlights' => 'Sorotan Terbaru',
      'core.progress.keepGoing' => 'Terus Semangat!',
      'core.progress.keepGoingMessage' =>
        'Tetap konsisten. Setiap latihan membawa Anda lebih dekat ke tujuan.',
      'core.progress.weightTrend.title' => 'Berat Badan (kg)',
      'core.progress.weightTrend.weekValue' => ({
        required Object week,
        required Object value,
      }) => 'M${week} · ${value} kg',
      'core.progress.weightTrend.weekShort' => ({
        required Object week,
      }) => 'M${week}',
      'core.progress.weightTrend.empty' =>
        'Belum ada pengukuran berat badan pada periode ini.',
      'core.progress.weightTrend.vsWeeksAgo' => ({
        required Object weeks,
      }) => 'dibanding ${weeks} minggu lalu',
      'core.progress.weightTrend.increase' => ({
        required Object value,
      }) => '↑ +${value} kg',
      'core.progress.weightTrend.decrease' => ({
        required Object value,
      }) => '↓ ${value} kg',
      'core.progress.notTracked.title' => ({
        required Object metric,
      }) => 'Pelacakan ${metric} belum tersedia',
      'core.progress.notTracked.message' =>
        'Metrik ini belum tersimpan dalam pengukuran Anda.',
      'core.progress.programCard.weekOf' => ({
        required Object week,
        required Object total,
      }) => 'Minggu ${week} dari ${total}',
      'core.progress.programCard.active' => 'Aktif',
      'core.progress.programCard.completion' => 'Penyelesaian program',
      'core.progress.highlights.completed' => ({
        required Object completed,
        required Object target,
      }) => 'Menyelesaikan ${completed} dari ${target} latihan minggu ini',
      'core.progress.highlights.weightIncrease' => ({
        required Object value,
      }) => 'Berat badan naik ${value} kg',
      'core.progress.highlights.weightDecrease' => ({
        required Object value,
      }) => 'Berat badan turun ${value} kg',
      'core.progress.highlights.emptyTitle' => 'Belum ada sorotan',
      'core.progress.highlights.emptyMessage' => 'Pencapaian Anda akan muncul saat Anda mencatat latihan dan pengukuran.',
      'core.progress.body.title' => 'Progres Tubuh',
      'core.progress.body.subtitle' =>
        'Pantau perubahan tubuh Anda dari waktu ke waktu.',
      'core.progress.body.weight' => 'Berat Badan',
      'core.progress.body.muscleMass' => 'Massa Otot',
      'core.progress.body.bodyFat' => 'Lemak Tubuh',
      'core.progress.body.logMeasurement' => 'Catat Pengukuran',
      'core.progress.body.recordWeight' => 'Catat Berat Badan',
      'core.progress.body.currentWeight' => 'Berat Badan Saat Ini',
      'core.progress.workout.title' => 'Performa Latihan',
      'core.progress.workout.subtitle' =>
        'Progres dan konsistensi latihan Anda.',
      'core.progress.workout.noPerformance.title' =>
        'Belum ada performa latihan',
      'core.progress.workout.noPerformance.message' => 'Aktivitas mingguan dan volume latihan akan muncul setelah Anda menyelesaikan latihan.',
      'core.progress.workout.weeklyActivity' => 'Aktivitas Mingguan',
      'core.progress.workout.noActivity.title' =>
        'Belum ada aktivitas minggu ini',
      'core.progress.workout.noActivity.message' =>
        'Durasi latihan yang selesai akan dirangkum di sini.',
      'core.progress.workout.trainingVolume' => 'Volume Latihan',
      'core.progress.workout.noVolume.title' => 'Belum ada volume latihan',
      'core.progress.workout.noVolume.message' => 'Total set dan repetisi akan muncul setelah Anda mencatat set yang selesai.',
      'core.progress.workout.recentWorkouts' => 'Latihan Terbaru',
      'core.progress.workout.noRecentWorkouts.title' =>
        'Belum ada latihan terbaru',
      'core.progress.workout.noRecentWorkouts.message' =>
        'Sesi yang telah Anda selesaikan akan muncul di sini.',
      'core.progress.workout.minutesPerDay' => 'Menit per hari',
      'core.progress.workout.minutesTotal' => ({
        required Object minutes,
      }) => '${minutes} menit total',
      'core.progress.workout.trainingMinutesThisWeek' => ({
        required Object minutes,
      }) => '${minutes} menit latihan minggu ini',
      'core.progress.workout.totalTime' => 'Total Waktu',
      'core.progress.history.all' => 'Semua',
      'core.progress.history.workout' => 'Latihan',
      'core.progress.history.measurement' => 'Pengukuran',
      'core.progress.history.oldestFirst' => 'Terlama dahulu',
      'core.progress.history.newestFirst' => 'Terbaru dahulu',
      'core.progress.history.recordWeight' => 'Catat berat badan',
      'core.progress.duration.minutes' => ({
        required Object minutes,
      }) => '${minutes} mnt',
      'core.progress.duration.hours' => ({
        required Object hours,
      }) => '${hours}j',
      'core.progress.duration.hoursMinutes' => ({
        required Object hours,
        required Object minutes,
      }) => '${hours}j ${minutes}mnt',
      'core.progress.weightDialog.title' => 'Catat berat badan',
      'core.progress.weightDialog.currentWeight' => 'Berat badan saat ini',
      'core.progress.weightDialog.cancel' => 'Batal',
      'core.progress.weightDialog.save' => 'Simpan',
      'core.progress.error.title' => 'Gagal memuat progres',
      'core.progress.error.retry' => 'Coba lagi',
      'home.greeting.goodMorning' => ({
        required Object name,
      }) => 'Selamat Pagi, ${name} 👋',
      'home.greeting.goodAfternoon' => ({
        required Object name,
      }) => 'Selamat Siang, ${name} 👋',
      'home.greeting.goodEvening' => ({
        required Object name,
      }) => 'Selamat Malam, ${name} 👋',
      'home.greeting.subtitle' => 'Tetap konsisten dan capai targetmu!',
      'home.goalCard.goalPrefix' => 'Target:',
      'home.goalCard.gainWeight' => 'Naikkan Berat Badan & Bentuk Otot',
      'home.goalCard.fatLoss' => 'Turunkan Lemak & Badan Atletis',
      'home.goalCard.maintain' => 'Jaga Berat Badan & Tetap Bugar',
      'home.goalCard.target' => 'Target',
      'home.goalCard.current' => 'Saat Ini',
      'home.goalCard.programDuration' => ({
        required Object weeks,
      }) => '${weeks} Minggu Program',
      'home.goalCard.weekOf' => ({
        required Object current,
        required Object total,
      }) => 'Minggu ${current} dari ${total}',
      'home.todayWorkout.title' => 'Latihan Hari Ini',
      'home.todayWorkout.viewPlan' => 'Lihat Jadwal →',
      'home.todayWorkout.startWorkout' => 'Mulai Latihan',
      'home.todayWorkout.approxMin' => ({
        required Object min,
      }) => '≈ ${min} mnt',
      'home.todayWorkout.approxKcal' => ({
        required Object kcal,
      }) => '≈ ${kcal} kkal',
      'home.restDay.title' => 'Hari Ini Istirahat',
      'home.restDay.subtitle' =>
        'Waktunya pemulihan, biarkan ototmu pulih dan berkembang.',
      'home.restDay.recoveryTips' => 'Tips Pemulihan',
      'home.restDay.hydrate' => 'Cukupi kebutuhan cairan tubuh',
      'home.restDay.sleep' => 'Tidur cukup 7–9 jam',
      'home.restDay.stretch' => 'Lakukan peregangan ringan atau mobilitas',
      'home.noProgram.title' => 'Kamu belum memiliki program latihan',
      'home.noProgram.subtitle' => 'Buat rencana latihan personal berdasarkan target, profil, dan preferensimu.',
      'home.noProgram.createProgram' => 'Buat Program Saya',
      'home.weeklyProgress.title' => 'Kemajuan Minggu Ini',
      'home.weeklyProgress.seeDetails' => 'Lihat Detail →',
      'home.weeklyProgress.states.completed' => 'Selesai (latihan tuntas)',
      'home.weeklyProgress.states.today' => 'Hari Ini (jadwal latihan)',
      'home.weeklyProgress.states.rest' => 'Hari istirahat',
      'home.weeklyProgress.states.upcoming' => 'Mendatang (belum)',
      'home.weeklyProgress.states.missed' => 'Terlewat',
      'home.supportGoal.title' => 'Dukung Targetmu',
      'home.supportGoal.subtitleGain' =>
        'Dapatkan tips nutrisi sederhana untuk pembentukan otot.',
      'home.supportGoal.subtitleLoss' =>
        'Dapatkan tips nutrisi sederhana untuk pembakaran lemak.',
      'home.supportGoal.subtitleMaintain' =>
        'Dapatkan tips pola makan sehat agar tetap fit.',
      'home.error.connectionIssue' => 'Masalah koneksi',
      'home.error.connectionDesc' => 'Sebagian data tidak dapat dimuat ulang. Menampilkan data terakhir yang tersimpan.',
      'home.error.lastSynced' => ({
        required Object time,
      }) => 'Sinkronisasi terakhir: ${time}',
      'home.error.retry' => 'Coba Lagi',
      'onboarding.nav.progress' => ({
        required Object current,
        required Object total,
      }) => '${current} dari ${total}',
      'onboarding.nav.getStarted' => 'Mulai Sekarang ➔',
      'onboarding.nav.continueCta' => 'Lanjut',
      'onboarding.nav.createMyPlan' => 'Buat Program Saya',
      'onboarding.nav.alreadyHaveAccount' => 'Sudah punya akun?',
      'onboarding.nav.signIn' => 'Masuk',
      'onboarding.welcome.brand' => 'Workout\nCoach',
      'onboarding.welcome.title' => 'Coach Latihan\nPribadi Kamu',
      'onboarding.welcome.subtitle' => 'Dapatkan program latihan sesuai\ntujuan, kondisi tubuh,\ndan gaya hidup kamu.',
      'onboarding.goal.title' => 'Apa tujuan utama kamu?',
      'onboarding.goal.subtitle' =>
        'Pilih tujuan yang paling sesuai dengan fokus kamu saat ini.',
      'onboarding.goal.options.0.id' => 'muscle_gain',
      'onboarding.goal.options.0.title' => 'Naikkan Berat & Bangun Otot',
      'onboarding.goal.options.0.description' =>
        'Tambah berat badan sambil membangun massa otot (bulking).',
      'onboarding.goal.options.1.id' => 'fat_loss',
      'onboarding.goal.options.1.title' => 'Turunkan Berat & Kurangi Lemak',
      'onboarding.goal.options.1.description' =>
        'Kurangi lemak tubuh tanpa kehilangan otot (cutting).',
      'onboarding.goal.options.2.id' => 'maintenance',
      'onboarding.goal.options.2.title' => 'Jaga Berat & Tetap Bugar',
      'onboarding.goal.options.2.description' =>
        'Pertahankan berat badan dan kebugaran kamu saat ini.',
      'onboarding.about.title' => 'Kenalan dulu, yuk',
      'onboarding.about.subtitle' =>
        'Kami butuh info dasar untuk mempersonalisasi program kamu.',
      'onboarding.about.gender' => 'Jenis Kelamin',
      'onboarding.about.male' => 'Pria',
      'onboarding.about.female' => 'Wanita',
      'onboarding.about.age' => 'Usia',
      'onboarding.about.ageUnit' => 'tahun',
      'onboarding.about.height' => 'Tinggi',
      'onboarding.about.heightUnit' => 'cm',
      'onboarding.bodyTarget.title' => 'Tubuh & target kamu',
      'onboarding.bodyTarget.subtitle' =>
        'Atur berat badan saat ini dan target kamu.',
      'onboarding.bodyTarget.currentWeight' => 'Berat saat ini',
      'onboarding.bodyTarget.targetWeight' => 'Berat target',
      'onboarding.bodyTarget.unit' => 'kg',
      'onboarding.bodyTarget.insight.gainTitle' => ({
        required Object diff,
      }) => 'Target naik: +${diff} kg',
      'onboarding.bodyTarget.insight.lossTitle' => ({
        required Object diff,
      }) => 'Target turun: ${diff} kg',
      'onboarding.bodyTarget.insight.maintainTitle' => 'Target: Menjaga',
      'onboarding.bodyTarget.insight.gainHint' => ({
        required Object minWeeks,
        required Object maxWeeks,
      }) => 'Kenaikan yang sehat sekitar 0,25 - 0,5 kg per minggu (${minWeeks} - ${maxWeeks} minggu).',
      'onboarding.bodyTarget.insight.lossHint' => ({
        required Object minWeeks,
        required Object maxWeeks,
      }) => 'Penurunan yang sehat sekitar 0,5 - 1,0 kg per minggu (${minWeeks} - ${maxWeeks} minggu).',
      'onboarding.bodyTarget.insight.maintainHint' => 'Pertahankan berat badan kamu dan fokus pada kepadatan otot serta kekuatan.',
      'onboarding.experience.title' => 'Bagaimana level latihan kamu?',
      'onboarding.experience.subtitle' =>
        'Pilih yang paling menggambarkan kondisi kamu.',
      'onboarding.experience.options.0.id' => 'beginner',
      'onboarding.experience.options.0.title' => 'Pemula',
      'onboarding.experience.options.0.description' =>
        'Baru mulai latihan atau masih belum konsisten.',
      'onboarding.experience.options.1.id' => 'intermediate',
      'onboarding.experience.options.1.title' => 'Menengah',
      'onboarding.experience.options.1.description' =>
        'Sudah punya pengalaman dan rutin latihan.',
      'onboarding.experience.options.2.id' => 'advanced',
      'onboarding.experience.options.2.title' => 'Lanjutan',
      'onboarding.experience.options.2.description' =>
        'Latihan konsisten, form sudah bagus, dan ingin tantangan lebih besar.',
      'onboarding.schedule.title' => 'Seberapa sering kamu bisa latihan?',
      'onboarding.schedule.subtitle' =>
        'Pilih jadwal latihan mingguan yang cocok dengan gaya hidup kamu.',
      'onboarding.schedule.daysPerWeek' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(
              n,
              other: '${n} hari / minggu',
            ),
      'onboarding.schedule.sessionDuration' => 'Durasi sesi',
      'onboarding.schedule.minutes' => ({required Object n}) => '${n} menit',
      'onboarding.equipment.title' => 'Peralatan apa yang kamu punya?',
      'onboarding.equipment.subtitle' => 'Pilih semua yang sesuai.',
      'onboarding.equipment.options.0.id' => 'bodyweight',
      'onboarding.equipment.options.0.label' => 'Berat Tubuh\n(tanpa alat)',
      'onboarding.equipment.options.1.id' => 'dumbbell',
      'onboarding.equipment.options.1.label' => 'Dumbbell',
      'onboarding.equipment.options.2.id' => 'resistance_band',
      'onboarding.equipment.options.2.label' => 'Resistance\nBand',
      'onboarding.equipment.options.3.id' => 'kettlebell',
      'onboarding.equipment.options.3.label' => 'Kettlebell',
      'onboarding.equipment.options.4.id' => 'pull_up_bar',
      'onboarding.equipment.options.4.label' => 'Pull-up Bar',
      'onboarding.equipment.options.5.id' => 'barbell',
      'onboarding.equipment.options.5.label' => 'Barbell',
      'onboarding.limitations.title' =>
        'Ada batasan atau hal yang perlu diperhatikan?',
      'onboarding.limitations.subtitle' => 'Beri tahu kami jika kamu punya kondisi kesehatan atau area yang perlu dihindari.',
      'onboarding.limitations.options.0.id' => 'none',
      'onboarding.limitations.options.0.label' => 'Tanpa batasan',
      'onboarding.limitations.options.1.id' => 'knee',
      'onboarding.limitations.options.1.label' => 'Lutut (mis. nyeri, cedera)',
      'onboarding.limitations.options.2.id' => 'back',
      'onboarding.limitations.options.2.label' =>
        'Punggung (mis. nyeri punggung bawah)',
      'onboarding.limitations.options.3.id' => 'shoulder',
      'onboarding.limitations.options.3.label' => 'Bahu',
      'onboarding.limitations.options.4.id' => 'wrist',
      'onboarding.limitations.options.4.label' => 'Pergelangan tangan',
      'onboarding.limitations.options.5.id' => 'other',
      'onboarding.limitations.options.5.label' => 'Lainnya',
      'onboarding.creating.title' => 'Membuat\nprogram personal kamu...',
      'onboarding.creating.subtitle' =>
        'Menganalisis tujuan, data tubuh,\npreferensi, dan ketersediaan kamu.',
      'onboarding.creating.steps.0' => 'Menganalisis profil kamu',
      'onboarding.creating.steps.1' => 'Menghitung volume latihan',
      'onboarding.creating.steps.2' => 'Memilih latihan terbaik',
      'onboarding.creating.steps.3' => 'Menyusun rencana mingguan kamu',
      'onboarding.ready.title' => 'Program kamu siap! 🎉',
      'onboarding.ready.subtitle' =>
        'Program personal berdasarkan\ntujuan, profil, dan preferensi kamu.',
      'onboarding.ready.weeksBadge' => ({
        required Object weeks,
      }) => '⭐ ${weeks} Minggu',
      'onboarding.ready.daysPerWeek' => 'Hari / Minggu',
      'onboarding.ready.minutesPerSession' => 'Menit / Sesi',
      'onboarding.ready.level' => 'Level',
      'onboarding.ready.features.0' =>
        'Membangun otot dan menambah berat badan',
      'onboarding.ready.features.1' =>
        'Progressive overload (beban naik bertahap)',
      'onboarding.ready.features.2' => 'Dirancang untuk latihan di rumah',
      'onboarding.ready.features.3' =>
        'Disesuaikan dengan jadwal dan alat kamu',
      'onboarding.ready.viewMyPlan' => 'Mulai Program Saya',
      'onboarding.ready.program.bulking.title' => 'Program Bulking',
      'onboarding.ready.program.bulking.subtitle' => 'Massa Otot & Kekuatan',
      'onboarding.ready.program.cutting.title' => 'Program Turun Lemak',
      'onboarding.ready.program.cutting.subtitle' => 'Turun Lemak & Tonus',
      'onboarding.ready.program.maintain.title' => 'Program Jaga Bugar',
      'onboarding.ready.program.maintain.subtitle' =>
        'Kekuatan & Kebugaran Umum',
      'onboarding.preview.title' => 'Program Latihan Kamu',
      'onboarding.preview.tabOverview' => 'Ringkasan',
      'onboarding.preview.tabWorkoutSplit' => 'Pembagian Latihan',
      'onboarding.preview.loading' => 'Memuat pratinjau program kamu...',
      'onboarding.preview.activateStart' => 'Aktifkan & Mulai Latihan ➔',
      'onboarding.preview.activateDashboard' => 'Aktifkan & Buka Dashboard',
      'onboarding.preview.sessionFallbackName' => ({
        required Object n,
      }) => 'Sesi ${n}',
      'onboarding.preview.sessionDuration' => ({
        required Object n,
      }) => '${n} menit',
      'onboarding.preview.exercisesInSession' => ({
        required Object count,
      }) => 'LATIHAN DI SESI INI (${count})',
      'onboarding.preview.prescription' => ({
        required Object sets,
        required Object reps,
        required Object rests,
      }) => '${sets} set • ${reps} repetisi • istirahat ${rests} dtk',
      'profile.appSettings.title' => 'Pengaturan Aplikasi',
      'profile.appSettings.subtitle' => 'Sesuaikan pengalaman aplikasi Anda.',
      'profile.appSettings.language' => 'Bahasa',
      'profile.appSettings.selectLanguage' => 'Pilih Bahasa',
      'profile.appSettings.languageEnglish' => 'English',
      'profile.appSettings.languageIndonesian' => 'Bahasa Indonesia',
      'profile.appSettings.theme' => 'Tema',
      'profile.appSettings.selectTheme' => 'Pilih Tema',
      'profile.appSettings.themeLight' => 'Terang',
      'profile.appSettings.themeDark' => 'Gelap',
      'profile.appSettings.themeSystem' => 'Ikuti Sistem',
      'profile.appSettings.units' => 'Satuan',
      'profile.appSettings.selectUnits' => 'Pilih Satuan',
      'profile.appSettings.unitsMetric' => 'Metrik (kg, cm)',
      'profile.appSettings.unitsImperial' => 'Imperial (lbs, in)',
      'profile.appSettings.hapticFeedback' => 'Umpan Balik Haptik',
      'profile.appSettings.hapticFeedbackSubtitle' =>
        'Getar saat aksi (mulai, istirahat, selesai)',
      'profile.appSettings.soundEffects' => 'Efek Suara',
      'profile.appSettings.soundEffectsSubtitle' =>
        'Timer latihan dan transisi',
      'profile.appSettings.dataSync' => 'Sinkronisasi Data',
      'profile.appSettings.dataSyncSubtitle' => 'Cadangkan data Anda ke akun',
      'profile.appSettings.saveError' =>
        'Gagal menyimpan pengaturan. Silakan coba lagi.',
      'profile.appSettings.cloudSyncDisableError' => 'Sinkronisasi Cloud dinonaktifkan untuk sesi ini, tetapi preferensinya gagal disimpan.',
      'profile.appSettings.cloudSyncSignInRequired' => 'Masuk dengan akun terlebih dahulu sebelum mengaktifkan Sinkronisasi Cloud.',
      'profile.appSettings.cloudSyncEnableError' =>
        'Gagal mengaktifkan Sinkronisasi Cloud. Silakan coba lagi.',
      'profile.appSettings.cloudSyncDialogTitle' =>
        'Aktifkan Sinkronisasi Cloud?',
      'profile.appSettings.cloudSyncDialogBody' => 'Profil, pengaturan, riwayat latihan, dan data progres Anda akan disinkronkan ke akun Supabase Anda. Data SQLite lokal tetap tersimpan di perangkat ini. Anda dapat menonaktifkan Sinkronisasi Cloud kapan saja.',
      'profile.appSettings.cloudSyncDialogCancel' => 'Nanti saja',
      'profile.appSettings.cloudSyncDialogConfirm' => 'Setuju dan aktifkan',
      'workoutSession.exerciseProgress' => ({
        required Object current,
        required Object total,
      }) => 'Latihan ${current} dari ${total}',
      'workoutSession.setProgress' => ({
        required Object current,
        required Object total,
        required Object target,
      }) => 'Set ${current} dari ${total} · ${target}',
      'workoutSession.repsUnit' => 'repetisi',
      'workoutSession.durationUnit' => 'detik',
      'workoutSession.repsValue' => ({
        required Object value,
      }) => '${value} repetisi',
      'workoutSession.durationValue' => ({
        required Object value,
      }) => '${value} detik',
      'workoutSession.completeSet' => 'Selesaikan Set',
      'workoutSession.nextRest' => 'Istirahat berikutnya',
      'workoutSession.preparingSession' => 'Menyiapkan sesi latihan...',
      'workoutSession.retry' => 'Coba Lagi',
      'workoutSession.saveSetFailed' =>
        'Gagal menyimpan set. Periksa koneksi lalu coba lagi.',
      'workoutSession.sessionConflictTitle' => 'Ada latihan yang belum selesai',
      'workoutSession.sessionConflictMessage' => ({
        required Object program,
        required Object day,
      }) => 'Kamu masih punya sesi "${program}" (Hari ${day}) yang sedang berlangsung. Lanjutkan sesi itu dulu, atau akhiri untuk mulai latihan ini.',
      'workoutSession.resumePreviousSession' => 'Lanjutkan Sesi Lama',
      'workoutSession.endPreviousSession' => 'Akhiri Sesi Lama',
      'workoutSession.completionTitle' => 'Latihan Hari Ini Tuntas! 🎉',
      'workoutSession.completionDescription' => 'Semua set dan gerakan telah berhasil kamu selesaikan. Istirahatlah dengan baik untuk pemulihan otot.',
      'workoutSession.durationLabel' => 'Durasi',
      'workoutSession.exerciseLabel' => 'Gerakan',
      'workoutSession.exerciseCount' => ({
        required Object count,
      }) => '${count} gerakan',
      'workoutSession.totalSetsLabel' => 'Total Set',
      'workoutSession.totalSetsCount' => ({
        required Object count,
      }) => '${count} set',
      'workoutSession.viewSummary' => 'Lihat Ringkasan & Evaluasi ➔',
      'workoutSession.restartRestTimer' => 'Mulai Ulang Timer Istirahat',
      'workoutSession.finishSessionNow' => 'Selesaikan Sesi Sekarang',
      'workoutSession.exitWithoutSaving' => 'Keluar Tanpa Menyimpan',
      'workoutSession.restTitle' => 'Istirahat',
      'workoutSession.restNextExercise' => ({
        required Object exercise,
      }) => 'Berikutnya: ${exercise}',
      'workoutSession.restSetProgress' => ({
        required Object current,
        required Object total,
      }) => 'Set ${current} dari ${total}',
      'workoutSession.restPaused' => 'DIJEDA',
      'workoutSession.restMinusTenSeconds' => '-10 dtk',
      'workoutSession.restPlusTenSeconds' => '+10 dtk',
      'workoutSession.restTipTitle' => 'Tips',
      'workoutSession.restTipDescription' =>
        'Tetap bernapas dan jangan lupa minum air.',
      'workoutSession.skipRest' => 'Lewati Istirahat',
      'workoutSession.setCompleteTitle' => ({
        required Object current,
        required Object total,
      }) => 'Set ${current} dari ${total} selesai! 🎉',
      'workoutSession.targetDuration' => ({
        required Object seconds,
      }) => 'Target: ${seconds} detik',
      'workoutSession.targetReps' => ({
        required Object reps,
      }) => 'Target: ${reps} repetisi',
      'workoutSession.durationCompleted' => 'Durasi Selesai',
      'workoutSession.repsCompleted' => 'Repetisi Selesai',
      'workoutSession.durationQuestion' => 'Berapa detik kamu bertahan?',
      'workoutSession.repsQuestion' => 'Berapa kali kamu berhasil?',
      'workoutSession.rirTitle' => 'Sisa Tenaga Kamu (RIR - Reps in Reserve)',
      'workoutSession.rirQuestion' => 'Berapa repetisi lagi yang sanggup kamu lakukan sebelum benar-benar gagal?',
      'workoutSession.rirFailureTitle' => '0 — Habis Total (Max Failure)',
      'workoutSession.rirFailureDescription' => 'Tenaga habis total, tidak sanggup menambah 1 repetisi lagi dengan teknik rapi.',
      'workoutSession.rirVeryHardTitle' => '1 — Sangat Berat',
      'workoutSession.rirVeryHardDescription' =>
        'Hanya sanggup 1 repetisi lagi sebelum gagal.',
      'workoutSession.rirIdealTitle' => '2 — Zona Ideal (Target)',
      'workoutSession.rirIdealDescription' =>
        'Cukup menantang, masih bisa 2 repetisi lagi jika dipaksa.',
      'workoutSession.rirModerateTitle' => '3 — Cukup Ringan',
      'workoutSession.rirModerateDescription' =>
        'Masih tersisa 3 repetisi di dalam tangki tenaga.',
      'workoutSession.rirEasyTitle' => '4+ — Terlalu Mudah',
      'workoutSession.rirEasyDescription' =>
        'Sangat enteng, masih sanggup melakukan 4 repetisi atau lebih.',
      'workoutSession.rirBadgeMax' => 'Maksimal',
      'workoutSession.rirBadgeHigh' => 'Tinggi',
      'workoutSession.rirBadgeOptimal' => 'Optimal ⭐',
      'workoutSession.rirBadgeModerate' => 'Sedang',
      'workoutSession.rirBadgeEasy' => 'Ringan',
      'workoutSession.saveAndStartRest' => 'Simpan & Mulai Istirahat',
      'workoutSession.restSecondsValue' => ({
        required Object seconds,
      }) => '${seconds} dtk',
      'workoutSession.durationMinutesValue' => ({
        required Object value,
      }) => '${value} menit',
      'workoutSession.savingSession' => 'Menyimpan sesi latihan...',
      'workoutSession.emptySessionDescription' => 'Daftar latihan untuk sesi ini tidak ditemukan. Silakan kembali untuk memuat ulang program latihan Anda.',
      'workoutSession.backButtonLabel' => 'Kembali',
      'workoutSession.finishSessionFailed' => 'Sesi latihan gagal disimpan. Progres yang sudah tercatat tetap tersedia. Silakan coba lagi.',
      'workoutSession.defaultProgramTitle' => 'Latihan Kekuatan',
      'workoutSession.completedScreen.title' => 'Workout Selesai! 🎉',
      'workoutSession.completedScreen.subtitle' => ({
        required Object focus,
      }) => 'Kerja bagus! Kamu telah menyelesaikan ${focus}.',
      'workoutSession.completedScreen.duration' => 'Durasi',
      'workoutSession.completedScreen.exercises' => 'Latihan',
      'workoutSession.completedScreen.estCalories' => 'Est. Kalori',
      'workoutSession.completedScreen.minUnit' => 'menit',
      'workoutSession.completedScreen.howWasWorkout' => 'Bagaimana latihannya?',
      'workoutSession.completedScreen.tooEasy' => 'Terlalu Mudah',
      'workoutSession.completedScreen.easy' => 'Mudah',
      'workoutSession.completedScreen.justRight' => 'Pas Banget',
      'workoutSession.completedScreen.hard' => 'Berat',
      'workoutSession.completedScreen.tooHard' => 'Terlalu Berat',
      'workoutSession.completedScreen.saveAndContinue' => 'Simpan & Lanjutkan',
      'workoutSession.completedScreen.viewWorkoutSummary' =>
        'Lihat Ringkasan Latihan',
      'workouts.title' => 'Latihan',
      'workouts.searchHint' => 'Cari latihan & gerakan...',
      'workouts.tabs.myProgram' => 'Program Saya',
      'workouts.tabs.allWorkouts' => 'Semua Latihan',
      'workouts.activeProgram.title' => 'Program Aktif',
      'workouts.activeProgram.weeksHomeWorkout' => ({
        required Object weeks,
      }) => '${weeks} minggu • Latihan di rumah',
      'workouts.activeProgram.weekOf' => ({
        required Object current,
        required Object total,
      }) => 'Minggu ${current} dari ${total}',
      'workouts.activeProgram.status.notStarted' => ({
        required Object date,
      }) => 'Dimulai ${date}',
      'workouts.activeProgram.status.completed' => 'Program selesai',
      'workouts.activeProgram.status.expired' => 'Program berakhir',
      'workouts.weeklySchedule.title' => 'Jadwal Mingguan',
      'workouts.weeklySchedule.workoutCount' => ({
        required Object completed,
        required Object total,
      }) => '${completed}/${total} latihan',
      'workouts.weeklySchedule.current' => 'Saat Ini',
      'workouts.weeklySchedule.weekShort' => ({required Object n}) => 'W${n}',
      'workouts.weeklySchedule.weekNumber' => ({
        required Object n,
      }) => 'Minggu ${n}',
      'workouts.weeklySchedule.empty' =>
        'Tidak ada sesi latihan yang dijadwalkan untuk minggu ini.',
      'workouts.weeklySchedule.previewTitle' => 'Mode pratinjau',
      'workouts.weeklySchedule.previewNotice' => 'Kamu bisa melihat rencana minggu ini, tapi latihan baru bisa dimulai sesuai jadwalnya.',
      'workouts.weeklySchedule.previewTooltip' => 'Pratinjau minggu mendatang',
      'workouts.weeklySchedule.statusTooltip.completed' =>
        'Semua latihan selesai',
      'workouts.weeklySchedule.statusTooltip.partial' =>
        'Sebagian latihan selesai',
      'workouts.weeklySchedule.statusTooltip.missed' =>
        'Ada latihan yang terlewat',
      'workouts.emptyState.noProgramTitle' => 'Belum ada program aktif',
      'workouts.emptyState.noProgramSubtitle' =>
        'Buat program untuk melihat jadwal latihan mingguanmu di sini.',
      'workouts.allWorkouts.emptyTitle' => 'Tidak ada latihan ditemukan',
      'workouts.allWorkouts.emptySubtitle' =>
        'Coba kata kunci lain atau ubah filter otot.',
      'workouts.allWorkouts.clearFilters' => 'Hapus pencarian & filter',
      'workouts.errorState.title' => 'Gagal memuat data',
      'workouts.errorState.subtitle' =>
        'Terjadi kesalahan saat membaca data latihan. Coba lagi.',
      'workouts.errorState.retry' => 'Coba Lagi',
      'workouts.errorState.refreshFailed' =>
        'Gagal memperbarui data. Menampilkan data terakhir.',
      'workouts.session.day' => ({required Object n}) => 'Hari ${n}',
      'workouts.session.date' => ({
        required Object n,
        required Object date,
      }) => 'Hari ${n} • ${date}',
      'workouts.session.min' => ({required Object min}) => '${min} mnt',
      'workouts.session.status.completed' => 'Selesai',
      'workouts.session.status.inProgress' => 'Sedang berlangsung',
      'workouts.session.status.readyToStart' => 'Hari Ini • Siap dimulai',
      'workouts.session.status.missed' => 'Terlewat',
      'workouts.session.status.scheduled' => 'Terjadwal',
      'workouts.workoutDetail.readOnlyTitle' => 'Mode pratinjau',
      'workouts.workoutDetail.readOnlyNotice' => 'Rencana latihan ini hanya bisa dilihat. Tombol mulai aktif pada hari yang dijadwalkan.',
      'workouts.workoutDetail.resume' => 'Lanjutkan Latihan',
      'workouts.workoutDetail.shareTooltip' => 'Salin detail latihan',
      'workouts.workoutDetail.bookmarkAdd' => 'Bookmark latihan',
      'workouts.workoutDetail.bookmarkRemove' => 'Hapus bookmark',
      'workouts.workoutDetail.copiedMessage' =>
        'Detail latihan berhasil disalin.',
      'workouts.workoutDetail.defaultDescription' =>
        'Tingkatkan kekuatan dan kebugaran tubuh dengan gerakan terpilih.',
      'workouts.workoutDetail.exerciseCount' => ({
        required Object count,
      }) => '${count} latihan',
      'workouts.workoutDetail.exerciseListTitle' => ({
        required Object count,
      }) => 'Daftar Gerakan (${count})',
      'workouts.workoutDetail.stages.warmup.title' => 'Pemanasan',
      'workouts.workoutDetail.stages.warmup.subtitle' => 'Persiapan',
      'workouts.workoutDetail.stages.main.title' => 'Latihan Inti',
      'workouts.workoutDetail.stages.main.subtitle' => 'Latihan Utama',
      'workouts.workoutDetail.stages.cooldown.title' => 'Pendinginan',
      'workouts.workoutDetail.stages.cooldown.subtitle' => 'Pemulihan',
      'workouts.workoutDetail.setReps' => ({
        required Object sets,
        required Object reps,
      }) => '${sets} set × ${reps}',
      'workouts.workoutDetail.repsUnit' => 'repetisi',
      'workouts.filter.title' => 'Filter Berdasarkan Otot',
      'workouts.categories.all' => 'Semua',
      'workouts.categories.chest' => 'Dada',
      'workouts.categories.back' => 'Punggung',
      'workouts.categories.legs' => 'Kaki',
      'workouts.categories.core' => 'Perut',
      'workouts.categories.arms' => 'Lengan',
      'workouts.categories.shoulders' => 'Bahu',
      _ => null,
    };
  }
}
