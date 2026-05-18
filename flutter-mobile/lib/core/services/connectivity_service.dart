import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final RxBool isOnline = true.obs;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void onInit() {
    super.onInit();
    // Seed initial value, then listen.
    _connectivity.checkConnectivity().then((results) {
      isOnline.value = _isOnline(results);
    }).catchError((_) {});
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      isOnline.value = _isOnline(results);
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
