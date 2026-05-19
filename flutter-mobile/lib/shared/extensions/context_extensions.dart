import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get text => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  MediaQueryData get mq => MediaQuery.of(this);

  void toast(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
