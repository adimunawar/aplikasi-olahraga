import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/user_settings_entity.dart';

void main() {
  test('parses Postgres booleans and SQLite integer flags', () {
    final settings = UserSettingsEntity.fromMap({
      'id': 'user-1',
      'workout_reminder': true,
      'rest_day_reminder': false,
      'progress_checkin': 1,
      'streak_reminder': 0,
      'haptic_feedback': true,
      'sound_effects': 0,
      'data_sync': false,
      'updated_at': '2026-11-14T00:00:00.000Z',
    });

    expect(settings.workoutReminder, isTrue);
    expect(settings.restDayReminder, isFalse);
    expect(settings.progressCheckin, isTrue);
    expect(settings.streakReminder, isFalse);
    expect(settings.hapticFeedback, isTrue);
    expect(settings.soundEffects, isFalse);
    expect(settings.dataSync, isFalse);
  });

  test('Cloud Sync setting defaults to disabled for a new profile', () {
    final settings = UserSettingsEntity.fromMap({
      'id': 'default_settings',
      'updated_at': '2026-11-14T00:00:00.000Z',
    });

    expect(settings.dataSync, isFalse);
  });
}
