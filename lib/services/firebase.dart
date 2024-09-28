import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FirebaseService {
  final FirebaseRemoteConfig _remoteConfig;
  final FirebaseMessaging firebaseMessaging;
  final FirebaseAnalytics firebaseAnalytics;

  FirebaseService(
      {required FirebaseRemoteConfig remoteConfig,
      required this.firebaseAnalytics})
      : _remoteConfig = remoteConfig,
        firebaseMessaging = FirebaseMessaging.instance;

  static FirebaseService createInstance() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final analytics = FirebaseAnalytics.instance;

    return FirebaseService(
      remoteConfig: remoteConfig,
      firebaseAnalytics: analytics,
    );
  }

  Future<void> initFirebaseNotifications(UserProfile profile) async {
    final NotificationSettings settings =
        await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      await _setUserProperty('notifications_enabled', 'false');
      print('User declined or has not accepted permission');
      return;
    }

    if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _setUserProperty('notifications_enabled', 'provisional');
      print('User granted provisional permission');
    }

    final String? fcmToken = await _handleFcmToken(profile);
    if (fcmToken != null && fcmToken.isNotEmpty) {
      await _updateUserInDatabase(fcmToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _updateUserInDatabase(newToken);
    }).onError((err) {
      print("Error refreshing token: $err");
    });

    await firebaseMessaging.setAutoInitEnabled(true);
  }

  Future<String?> _handleFcmToken(UserProfile profile) async {
    String? fcmToken = profile.fcmToken;

    if (fcmToken.isEmpty) {
      fcmToken = await firebaseMessaging.getToken();
      if (fcmToken != null) {
        profile.fcmToken = fcmToken;
        await _setUserProperty(profile.userType.toLowerCase(), 'true');
        await _setUserProperty('notifications_enabled', 'true');
        print('New FCM token generated: $fcmToken');
      } else {
        print("Failed to generate FCM token");
      }
    } else {
      print('Existing FCM token found: $fcmToken');
    }

    return fcmToken;
  }

  Future<void> _updateUserInDatabase(String fcmToken) async {
    final arcadiaCloud = ArcadiaCloud(createInstance());
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not authenticated");
      return;
    }

    final String? idToken = await user.getIdToken();
    if (idToken == null) {
      print("Failed to retrieve ID token");
      return;
    }

    try {
      await arcadiaCloud.updateUserToDB(
          null, null, null, null, null, null, idToken, null, fcmToken, null);
    } catch (e) {
      print("Failed to update user in database: $e");
    }
  }

  Future<void> _setUserProperty(String name, String value) async {
    try {
      await FirebaseAnalytics.instance
          .setUserProperty(name: name, value: value);
      print("User property $name set to $value");
    } catch (e) {
      print("Failed to set user property $name: $e");
    }
  }

  Future<bool> isNotificationEnabled() async {
    final NotificationSettings settings =
        await firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<bool> checkForUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await remoteConfig.fetchAndActivate();

    String latestVersion = remoteConfig.getString('latest_version');

    print("latest version, $latestVersion");

    // Get current app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    print("current version, $currentVersion");

    return !_isVersionLower(currentVersion, latestVersion);
  }

  bool _isVersionLower(String currentVersion, String latestVersion) {
    // Split versions into parts and compare each part
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> latestParts = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length; i++) {
      if (currentParts[i] < latestParts[i]) {
        return true;
      } else if (currentParts[i] > latestParts[i]) {
        return false;
      }
    }
    return false;
  }

  Future<bool> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 12),
    ));

    try {
      final bool updated = await _remoteConfig.fetchAndActivate().timeout(
            const Duration(seconds: 10),
            onTimeout: () => false,
          );

      if (!updated) {
        print('Remote config not updated');
      }

      // Optionally check if remote config contains critical values and return true if they are set, even if not updated
      if (_remoteConfig.getString('x-api-key') != null) {
        return true;
      }

      return updated;
    } catch (e) {
      print('Error fetching remote config: $e');
      return false;
    }
  }

  String get xApiKey => _remoteConfig.getString('x_api_key');
  String get arcadiaCloudAddress =>
      _remoteConfig.getString('arcadia_cloud_address');
}
