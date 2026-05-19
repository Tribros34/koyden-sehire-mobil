// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

class AppColors {
  // Primary — forest green
  static const Color primary = Color(0xFF14422D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2D5A43);
  static const Color onPrimaryContainer = Color(0xFF9FCFB2);
  static const Color primaryFixed = Color(0xFFBCEECF);
  static const Color primaryFixedDim = Color(0xFFA1D1B4);
  static const Color inversePrimary = Color(0xFFA1D1B4);

  // Secondary — sage green
  static const Color secondary = Color(0xFF43664D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC2E9C9);
  static const Color onSecondaryContainer = Color(0xFF486A51);
  static const Color secondaryFixed = Color(0xFFC5ECCC);
  static const Color secondaryFixedDim = Color(0xFFAAD0B1);

  // Tertiary — warm neutral
  static const Color tertiary = Color(0xFF3C3B2E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF535244);
  static const Color onTertiaryContainer = Color(0xFFC8C5B3);

  // Surface / background — teal-tinted light
  static const Color background = Color(0xFFEAFDFF);
  static const Color onBackground = Color(0xFF031F22);
  static const Color surface = Color(0xFFEAFDFF);
  static const Color surfaceBright = Color(0xFFEAFDFF);
  static const Color surfaceDim = Color(0xFFC3DFE3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFDCF9FC);
  static const Color surfaceContainer = Color(0xFFD6F3F7);
  static const Color surfaceContainerHigh = Color(0xFFD1EDF1);
  static const Color surfaceContainerHighest = Color(0xFFCBE8EB);
  static const Color onSurface = Color(0xFF031F22);
  static const Color onSurfaceVariant = Color(0xFF414943);
  static const Color inverseSurface = Color(0xFF1A3437);
  static const Color inverseOnSurface = Color(0xFFD9F6F9);

  // Outline
  static const Color outline = Color(0xFF717973);
  static const Color outlineVariant = Color(0xFFC0C9C1);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Status helpers (keep for legacy badge use)
  static const Color success = Color(0xFF43664D); // sage
  static const Color warning = Color(0xFF717973); // outline-muted
}

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 9999;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double section = 64;
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    inversePrimary: AppColors.inversePrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
  );

  const String font = 'PlusJakartaSans';

  const textTheme = TextTheme(
    // display-lg: 48/56, w700, -0.02em (web hero; mobile unused)
    displayLarge: TextStyle(
      fontFamily: font,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 56 / 48,
      letterSpacing: -0.02 * 48,
    ),
    // headline-lg mobile: 28/36, w600
    headlineLarge: TextStyle(
      fontFamily: font,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 36 / 28,
      letterSpacing: -0.01 * 28,
    ),
    headlineMedium: TextStyle(
      fontFamily: font,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
    ),
    headlineSmall: TextStyle(
      fontFamily: font,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 28 / 20,
    ),
    // title-md: 20/28, w600
    titleLarge: TextStyle(
      fontFamily: font,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 28 / 20,
    ),
    titleMedium: TextStyle(
      fontFamily: font,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 26 / 18,
    ),
    titleSmall: TextStyle(
      fontFamily: font,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
    ),
    // body-lg: 18/28, w400
    bodyLarge: TextStyle(
      fontFamily: font,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 28 / 18,
    ),
    // body-md: 16/24, w400
    bodyMedium: TextStyle(
      fontFamily: font,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
    ),
    bodySmall: TextStyle(
      fontFamily: font,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
    ),
    // label-sm: 14/20, w500, 0.02em
    labelLarge: TextStyle(
      fontFamily: font,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
    ),
    labelMedium: TextStyle(
      fontFamily: font,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      letterSpacing: 0.02 * 14,
    ),
    labelSmall: TextStyle(
      fontFamily: font,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      letterSpacing: 0.02 * 12,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: font,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: font,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(
        fontFamily: font,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
      ),
      hintStyle: const TextStyle(
        fontFamily: font,
        fontSize: 16,
        color: AppColors.onSurfaceVariant,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 48),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: const TextStyle(
          fontFamily: font,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.02 * 14,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        foregroundColor: AppColors.primaryContainer,
        side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: const TextStyle(
          fontFamily: font,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.02 * 14,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryContainer,
        textStyle: const TextStyle(
          fontFamily: font,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color.fromRGBO(
        0x43,
        0x66,
        0x4D,
        0.15,
      ),
      selectedColor: AppColors.secondaryContainer,
      labelStyle: TextStyle(
        fontFamily: font,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
        letterSpacing: 0.02 * 14,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: font,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
      ),
      side: BorderSide.none,
      shape: StadiumBorder(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      selectedItemColor: AppColors.primaryContainer,
      unselectedItemColor: AppColors.onSurfaceVariant,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      indicatorColor: AppColors.secondaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryContainer);
        }
        return const IconThemeData(color: AppColors.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontFamily: font,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
          );
        }
        return const TextStyle(
          fontFamily: font,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        );
      }),
    ),
  );
}
