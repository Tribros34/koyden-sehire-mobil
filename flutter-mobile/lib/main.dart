import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/bindings/app_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  // Register all global services/repositories before runApp so screens can
  // resolve them synchronously via Get.find().
  AppBinding().dependencies();
  runApp(const KoydenSehireApp());
}
