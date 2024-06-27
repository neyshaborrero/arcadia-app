import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseService {
  final FirebaseRemoteConfig _remoteConfig;
  final firebaseMessaging = FirebaseMessaging.instance;

  FirebaseService({required FirebaseRemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  static FirebaseService createInstance() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    return FirebaseService(remoteConfig: remoteConfig);
  }

  Future<void> initFirebaseNotifications() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<bool> isNotificationEnabled() async {
    NotificationSettings settings =
        await firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<bool> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(seconds: 1),
    ));

    try {
      // Fetch remote configurations with a timeout
      bool updated = await _remoteConfig.fetchAndActivate().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Handle timeout scenario
          return false;
        },
      );

      if (!updated) {
        // Handle the case where fetching and activation did not succeed
        print('Remote config not updated');
        return true;
      }
    } catch (e) {
      // Handle the error scenario
      print('Error fetching remote config: $e');
      return false;
    }
    return true;
  }

  String get xApiKey => _remoteConfig.getString('x_api_key');
  String get arcadiaCloudAddress =>
      _remoteConfig.getString('arcadia_cloud_address');
}
