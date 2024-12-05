import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatusChecker {
  Future<bool> isConnectedToWiFi() async {
    // Get the current connectivity state
    final ConnectivityResult connectivityResult =
        (await Connectivity().checkConnectivity()) as ConnectivityResult;

    // Check if the connection is Wi-Fi
    return connectivityResult == ConnectivityResult.wifi;
  }
}
