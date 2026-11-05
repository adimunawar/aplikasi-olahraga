import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/domain/models/workout_program.dart';

/// Immutable State untuk halaman Plans
class PlansState {
  final WorkoutProgram? activeProgram;
  final List<WorkoutProgram> otherPrograms;
  final int currentWeek;
  final int selectedWeekNumber;
  final Set<int> completedDayNumbers;
  final double progressPercent;
  final bool isLoading;
  final String? errorMessage;

  const PlansState({
    this.activeProgram,
    this.otherPrograms = const [],
    this.currentWeek = 3,
    this.selectedWeekNumber = 3,
    this.completedDayNumbers = const {1, 2},
    this.progressPercent = 0.37,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Mengambil set nomor hari yang telah selesai khusus untuk minggu yang sedang dipilih
  Set<int> get completedDaysForSelectedWeek {
    if (selectedWeekNumber < currentWeek) {
      // Minggu lampau: semua sesi latihan (1, 2, 3, 4) sudah selesai
      return {1, 2, 3, 4};
    } else if (selectedWeekNumber == currentWeek) {
      // Minggu berjalan saat ini: sesuai progres latihan pengguna
      return completedDayNumbers;
    } else {
      // Minggu mendatang (e.g. Week 5 saat posisi masih di Week 3): belum ada sesi yang selesai
      return {};
    }
  }

  /// Mengambil data minggu yang sedang dipilih
  ProgramWeek? get currentSelectedWeek {
    if (activeProgram == null || activeProgram!.weeks.isEmpty) return null;
    try {
      return activeProgram!.weeks.firstWhere(
        (w) => w.weekNumber == selectedWeekNumber,
      );
    } catch (_) {
      return null;
    }
  }

  /// Daftar hari (7 hari) pada minggu yang sedang dipilih
  List<ProgramDay> get currentWeekDays {
    final week = currentSelectedWeek;
    if (week != null && week.days.isNotEmpty) {
      return week.days;
    }
    // Generate hari secara dinamis sesuai selectedWeekNumber
    return _generateWeekDays(selectedWeekNumber);
  }

  List<ProgramDay> _generateWeekDays(int w) {
    return [
      ProgramDay(
        day: 1,
        week: w,
        type: WorkoutTypeCode.p,
        focus: LocalizedString(
          id: 'Dada • Bahu • Triceps (Minggu $w)',
          en: 'Chest • Shoulders • Triceps (Week $w)',
        ),
        isRest: false,
        isRetestMilestone: false,
        items: const [],
      ),
      ProgramDay(
        day: 2,
        week: w,
        type: WorkoutTypeCode.p,
        focus: LocalizedString(
          id: 'Punggung • Biceps (Minggu $w)',
          en: 'Back • Biceps (Week $w)',
        ),
        isRest: false,
        isRetestMilestone: false,
        items: const [],
      ),
      ProgramDay(
        day: 3,
        week: w,
        type: WorkoutTypeCode.r,
        focus: const LocalizedString(
          id: 'Istirahat atau aktivitas ringan seperti stretching.',
          en: 'Rest, or light activity like stretching.',
        ),
        isRest: true,
        isRetestMilestone: false,
        items: const [],
      ),
      ProgramDay(
        day: 4,
        week: w,
        type: WorkoutTypeCode.f,
        focus: LocalizedString(
          id: 'Dada • Punggung • Bahu • Lengan (Minggu $w)',
          en: 'Chest • Back • Shoulders • Arms (Week $w)',
        ),
        isRest: false,
        isRetestMilestone: false,
        items: const [],
      ),
      ProgramDay(
        day: 5,
        week: w,
        type: WorkoutTypeCode.r,
        focus: const LocalizedString(id: 'Istirahat Total', en: 'Rest'),
        isRest: true,
        isRetestMilestone: false,
        items: const [],
      ),
      ProgramDay(
        day: 6,
        week: w,
        type: WorkoutTypeCode.r,
        focus: const LocalizedString(id: 'Istirahat Total', en: 'Rest'),
        isRest: true,
        isRetestMilestone: false,
        items: const [],
      ),
      ProgramDay(
        day: 7,
        week: w,
        type: WorkoutTypeCode.r,
        focus: const LocalizedString(id: 'Istirahat Total', en: 'Rest'),
        isRest: true,
        isRetestMilestone: false,
        items: const [],
      ),
    ];
  }

  PlansState copyWith({
    WorkoutProgram? activeProgram,
    List<WorkoutProgram>? otherPrograms,
    int? currentWeek,
    int? selectedWeekNumber,
    Set<int>? completedDayNumbers,
    double? progressPercent,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlansState(
      activeProgram: activeProgram ?? this.activeProgram,
      otherPrograms: otherPrograms ?? this.otherPrograms,
      currentWeek: currentWeek ?? this.currentWeek,
      selectedWeekNumber: selectedWeekNumber ?? this.selectedWeekNumber,
      completedDayNumbers: completedDayNumbers ?? this.completedDayNumbers,
      progressPercent: progressPercent ?? this.progressPercent,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
