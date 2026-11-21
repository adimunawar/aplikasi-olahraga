import 'package:flutter/widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// Memformat durasi latihan (menit) menjadi teks yang sudah dilokalkan.
String formatProgressDuration(BuildContext context, int minutes) {
  final safeMinutes = minutes < 0 ? 0 : minutes;
  final hours = safeMinutes ~/ 60;
  final remaining = safeMinutes % 60;
  if (hours == 0) {
    return context.t.core.progress.duration.minutes(minutes: safeMinutes);
  }
  if (remaining == 0) {
    return context.t.core.progress.duration.hours(hours: hours);
  }
  return context.t.core.progress.duration.hoursMinutes(
    hours: hours,
    minutes: remaining,
  );
}
