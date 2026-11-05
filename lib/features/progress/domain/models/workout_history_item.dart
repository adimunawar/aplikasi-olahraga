/// Immutable Domain Model untuk satu item riwayat sesi latihan yang telah selesai
class WorkoutHistoryItem {
  final String id;
  final String title;
  final String dateText;
  final String durationText;
  final String caloriesText;
  final String thumbnailAsset;

  const WorkoutHistoryItem({
    required this.id,
    required this.title,
    required this.dateText,
    required this.durationText,
    required this.caloriesText,
    this.thumbnailAsset = 'assets/images/Home Workout Push-Up Guide.png',
  });

  WorkoutHistoryItem copyWith({
    String? id,
    String? title,
    String? dateText,
    String? durationText,
    String? caloriesText,
    String? thumbnailAsset,
  }) {
    return WorkoutHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dateText: dateText ?? this.dateText,
      durationText: durationText ?? this.durationText,
      caloriesText: caloriesText ?? this.caloriesText,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
    );
  }
}

