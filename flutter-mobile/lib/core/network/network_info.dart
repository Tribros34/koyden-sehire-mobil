import 'package:connectivity_plus/connectivity_plus.dart';

bool _isOnline(List<ConnectivityResult> results) {
  return results.any((r) => r != ConnectivityResult.none);
}

Future<bool> checkOnlineNow() async {
  final results = await Connectivity().checkConnectivity();
  return _isOnline(results);
}
