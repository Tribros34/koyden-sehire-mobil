import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final c = Connectivity();
  return c.onConnectivityChanged.map(_isOnline).asBroadcastStream();
});

bool _isOnline(List<ConnectivityResult> results) {
  return results.any((r) => r != ConnectivityResult.none);
}

Future<bool> checkOnlineNow() async {
  final results = await Connectivity().checkConnectivity();
  return _isOnline(results);
}
