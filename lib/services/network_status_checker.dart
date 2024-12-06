import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatusChecker {
  final Connectivity _connectivity = Connectivity();

  // Stream to listen to connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  // Check if currently connected to Wi-Fi
  Future<bool> isConnectedToWiFi() async {
    // Get the current connectivity state
    final List<ConnectivityResult> connectivityResults =
        await _connectivity.checkConnectivity();

    // Check if the list contains Wi-Fi connectivity
    return connectivityResults.contains(ConnectivityResult.wifi);
  }
}
