import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/core/services/cloud_sync_consent.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CloudSyncConsent.resetForTesting();
  });

  test('Cloud Sync consent is disabled by default', () async {
    await CloudSyncConsent.initialize();

    expect(CloudSyncConsent.isEnabled, isFalse);
  });

  test('Cloud Sync consent is restored from local preferences', () async {
    SharedPreferences.setMockInitialValues({
      'cloud_sync_consent': true,
    });

    await CloudSyncConsent.initialize();

    expect(CloudSyncConsent.isEnabled, isTrue);
  });

  test('Cloud Sync consent can be disabled and persisted', () async {
    await CloudSyncConsent.initialize();
    await CloudSyncConsent.setEnabled(true);

    expect(CloudSyncConsent.isEnabled, isTrue);

    await CloudSyncConsent.setEnabled(false);

    expect(CloudSyncConsent.isEnabled, isFalse);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('cloud_sync_consent'), isFalse);
  });
}
