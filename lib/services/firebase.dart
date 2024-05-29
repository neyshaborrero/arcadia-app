import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseService {
  final FirebaseRemoteConfig _remoteConfig;

  FirebaseService({required FirebaseRemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  static FirebaseService createInstance() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    return FirebaseService(remoteConfig: remoteConfig);
  }

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();
  }

  String get xApiKey => _remoteConfig.getString('x_api_key');
}
