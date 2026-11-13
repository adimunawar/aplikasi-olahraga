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
    expect(CloudSyncConsent.isEnabledFor('user-1'), isFalse);
  });

  test('consent is restored for the account that accepted it', () async {
    await CloudSyncConsent.initialize();
    await CloudSyncConsent.enableForUser('user-1');

    CloudSyncConsent.resetForTesting();
    await CloudSyncConsent.initialize();

    expect(CloudSyncConsent.isEnabledFor('user-1'), isTrue);
    expect(CloudSyncConsent.isEnabledFor('user-2'), isFalse);
  });

  test('disabling Cloud Sync clears persisted account consent', () async {
    await CloudSyncConsent.initialize();
    await CloudSyncConsent.enableForUser('user-1');

    await CloudSyncConsent.disable();

    expect(CloudSyncConsent.isEnabled, isFalse);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('cloud_sync_consent_user_id'), isNull);
  });
}
