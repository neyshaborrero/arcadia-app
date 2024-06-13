import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseService {
  final FirebaseRemoteConfig _remoteConfig;

  FirebaseService({required FirebaseRemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  static FirebaseService createInstance() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    return FirebaseService(remoteConfig: remoteConfig);
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
