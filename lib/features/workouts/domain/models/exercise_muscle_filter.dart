import '../../../exercises/domain/models/exercise.dart';

/// Filter kelompok otot untuk tab All Workouts.
///
/// Kategori ini sengaja dipisahkan dari [ExerciseCategory] karena model
/// exercise memakai kategori pola gerak (push/pull/legs/core/fullBody),
/// sedangkan UI memfilter berdasarkan kelompok otot (dada, punggung, dst).
enum ExerciseMuscleFilter {
  all('All'),
  chest('Chest'),
  back('Back'),
  legs('Legs'),
  core('Core'),
  arms('Arms'),
  shoulders('Shoulders');

  final String label;

  const ExerciseMuscleFilter(this.label);

  /// Alias token otot (Inggris & Indonesia) yang termasuk kelompok ini.
  Set<String> get aliases => switch (this) {
    ExerciseMuscleFilter.all => const {},
    ExerciseMuscleFilter.chest => const {
      'chest',
      'pectoral',
      'pectorals',
      'pectoralis',
      'pecs',
      'dada',
    },
    ExerciseMuscleFilter.back => const {
      'back',
      'lat',
      'lats',
      'latissimus',
      'dorsi',
      'trapezius',
      'trap',
      'traps',
      'rhomboid',
      'rhomboids',
      'erector',
      'spinae',
      'punggung',
    },
    ExerciseMuscleFilter.legs => const {
      'leg',
      'legs',
      'quad',
      'quads',
      'quadriceps',
      'hamstring',
      'hamstrings',
      'glute',
      'glutes',
      'gluteus',
      'calf',
      'calves',
      'gastrocnemius',
      'soleus',
      'hip',
      'flexor',
      'flexors',
      'adductor',
      'abductor',
      'kaki',
      'paha',
      'betis',
    },
    ExerciseMuscleFilter.core => const {
      'core',
      'abs',
      'ab',
      'abdominal',
      'abdominals',
      'abdominis',
      'oblique',
      'obliques',
      'rectus',
      'transverse',
      'transversus',
      'perut',
    },
    ExerciseMuscleFilter.arms => const {
      'arm',
      'arms',
      'bicep',
      'biceps',
      'tricep',
      'triceps',
      'forearm',
      'forearms',
      'brachialis',
      'lengan',
      'bisep',
      'trisep',
    },
    ExerciseMuscleFilter.shoulders => const {
      'shoulder',
      'shoulders',
      'deltoid',
      'deltoids',
      'delt',
      'delts',
      'rotator',
      'cuff',
      'bahu',
    },
  };

  static final RegExp _separator = RegExp(r'[^a-z0-9]+');

  /// True jika salah satu otot utama exercise termasuk kelompok ini.
  ///
  /// Pencocokan dilakukan per token, bukan `String.contains` pada seluruh
  /// kalimat otot, supaya "lower chest" tidak ikut cocok ke filter Core.
  bool matches(Exercise exercise) {
    if (this == ExerciseMuscleFilter.all) return true;

    final muscles = [
      for (final muscle in exercise.primaryMuscles) ...[
        muscle.en,
        muscle.id,
      ],
    ];

    if (muscles.isNotEmpty) {
      for (final muscle in muscles) {
        for (final token in _tokens(muscle)) {
          if (aliases.contains(token)) return true;
        }
      }
      return false;
    }

    // Fallback hanya jika data otot tidak tersedia.
    return switch (this) {
      ExerciseMuscleFilter.legs =>
        exercise.category == ExerciseCategory.legs,
      ExerciseMuscleFilter.core =>
        exercise.category == ExerciseCategory.core,
      _ => false,
    };
  }

  static Iterable<String> _tokens(String value) {
    return value
        .toLowerCase()
        .replaceAll(_separator, ' ')
        .trim()
        .split(' ')
        .where((token) => token.isNotEmpty);
  }
}
