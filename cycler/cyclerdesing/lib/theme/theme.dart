import 'package:flutter/material.dart';


//METRICAS

//SPACING
class AppSpacing {
  static const double space050 = 2;
  static const double space100 = 4;
  static const double space200 = 8;
  static const double space300 = 12;
  static const double space400 = 16;
  static const double space500 = 20;
  static const double space600 = 24;
  static const double space700 = 32;
  static const double space800 = 40;
  static const double space900 = 48;
  static const double space1000 = 56;
  static const double space1100 = 64;
  static const double space1200 = 72;
}

//PADDING
class AppPadding {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 48;
}

//MARGIN
class AppMargin {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 48;
}

//GAP
class AppGap {
  static const double tight = 4;
  static const double related = 8;
  static const double component = 16;
  static const double group = 20;
  static const double section = 32;
  static const double nav = 40;
  static const double container = 48;
}

//CORNER RADIUS
class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 72;
}

//ELEVACIONES
class AppElevation {
  static const BoxShadow elevation1 = BoxShadow(
    color: Color(0x140A0A0B), // #0A0A0B con 8% opacidad
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
  );

  static const BoxShadow elevation2 = BoxShadow(
    color: Color(0x1F0A0A0B), // #0A0A0B con 12% opacidad
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );

  static const BoxShadow elevation3 = BoxShadow(
    color: Color(0x290A0A0B), // #0A0A0B con 16% opacidad
    offset: Offset(0, 8),
    blurRadius: 24,
    spreadRadius: 0,
  );

  static const BoxShadow elevation4 = BoxShadow(
    color: Color(0x330A0A0B), // #0A0A0B con 20% opacidad
    offset: Offset(0, 16),
    blurRadius: 48,
    spreadRadius: 0,
  );
}

// COLORES
class AppColors {
  // BRAND
  static const Color brand50 = Color(0xFFF0F2E8);
  static const Color brand100 = Color(0xFFD5DAB8);
  static const Color brand200 = Color(0xFFBAC28A);
  static const Color brand300 = Color(0xFF9EAA5D);
  static const Color brand400 = Color(0xFF7D8E3A);
  static const Color brand500 = Color(0xFF5E6D28);
  static const Color brand600 = Color(0xFF40481F);
  static const Color brand700 = Color(0xFF2E3416);
  static const Color brand800 = Color(0xFF1E220E);
  static const Color brand900 = Color(0xFF101208);

  // SECONDARY
  static const Color secondary50 = Color(0xFFFAF7F2);
  static const Color secondary100 = Color(0xFFF5EEE0);
  static const Color secondary200 = Color(0xFFEDE0C6);
  static const Color secondary300 = Color(0xFFE3D284);
  static const Color secondary400 = Color(0xFFD4BC94);
  static const Color secondary500 = Color(0xFFBFA078);
  static const Color secondary600 = Color(0xFFA87E4E);
  static const Color secondary700 = Color(0xFF7A5E35);
  static const Color secondary800 = Color(0xFF523E22);
  static const Color secondary900 = Color(0xFF2C2010);

  // NEUTRAL
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF2F3F5);
  static const Color neutral100 = Color(0xFFE2E4E8);
  static const Color neutral200 = Color(0xFFC8CCD4);
  static const Color neutral300 = Color(0xFFA8ADB8);
  static const Color neutral400 = Color(0xFF848A96);
  static const Color neutral500 = Color(0xFF606672);
  static const Color neutral600 = Color(0xFF404550);
  static const Color neutral700 = Color(0xFF2A2E36);
  static const Color neutral800 = Color(0xFF151516);
  static const Color neutral900 = Color(0xFF0A0A0B);
  static const Color neutral1000 = Color(0xFF000000);

  // ACCENT
  static const Color accent50 = Color(0xFFFFF2EA);
  static const Color accent100 = Color(0xFFFFD9BC);
  static const Color accent200 = Color(0xFFFFBC8C);
  static const Color accent300 = Color(0xFFFF9A5C);
  static const Color accent400 = Color(0xFFFF7A38);
  static const Color accent500 = Color(0xFFFF6400);
  static const Color accent600 = Color(0xFFCC5000);
  static const Color accent700 = Color(0xFF993C00);
  static const Color accent800 = Color(0xFF662800);
  static const Color accent900 = Color(0xFF331400);

  // PREMIUM
  static const Color premium50 = Color(0xFFF0ECFB);
  static const Color premium200 = Color(0xFFC4AEF0);
  static const Color premium500 = Color(0xFF7C3AED);
  static const Color premium600 = Color(0xFF5B21B6);
  static const Color premium800 = Color(0xFF2E1065);

  // RETROALIMENTACION
  static const Color success50 = Color(0xFFDCFCE7);
  static const Color success200 = Color(0xFF86EFAC);
  static const Color success500 = Color(0xFF16A34A);
  static const Color success600 = Color(0xFF15803D);
  static const Color success800 = Color(0xFF14532D);

  static const Color warning50 = Color(0xFFFEF9C3);
  static const Color warning200 = Color(0xFFFDE047);
  static const Color warning500 = Color(0xFFCABA04);
  static const Color warning600 = Color(0xFFA16207);
  static const Color warning800 = Color(0xFF713F12);

  static const Color error50 = Color(0xFFFEE2E2);
  static const Color error200 = Color(0xFFFCA5A5);
  static const Color error500 = Color(0xFFDC2626);
  static const Color error600 = Color(0xFFB91C1C);
  static const Color error800 = Color(0xFF7F1D1D);
}

//TIPOGRAFIA

// TYPOGRAPHY
class AppTypography {
  static const String fontFamily = 'Barlow';
  static const String fontFamilyMono = 'DMMono';

  // HEADLINES
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w600,
    height: 60 / 56,
    letterSpacing: -1,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w600,
    height: 48 / 44,
    letterSpacing: -0.5,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 38,
    fontWeight: FontWeight.w600,
    height: 44 / 38,
    letterSpacing: -0.88,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 38 / 32,
    letterSpacing: -0.5,
  );
  static const TextStyle h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 32 / 26,
    letterSpacing: 0,
  );
  static const TextStyle h6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: 0,
  );

  // SUBTITLES
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    letterSpacing: 0.4,
  );
  static const TextStyle subtitle2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    letterSpacing: 0,
  );

  // BODY
  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 20 / 16,
    letterSpacing: 0,
  );
  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: 0,
  );

  // OTROS
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 20 / 16,
    letterSpacing: 1.25,
  );
  static const TextStyle chip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 18 / 14,
    letterSpacing: 0,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    letterSpacing: 0,
  );

  // DATA
  static const TextStyle data1 = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 40,
    fontWeight: FontWeight.w500,
    height: 44 / 40,
    letterSpacing: -1,
  );
  static const TextStyle data2 = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 32 / 28,
    letterSpacing: 0,
  );
  static const TextStyle data3 = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 24 / 20,
    letterSpacing: 0,
  );
}

//MATERIAL TEXT THEME

final TextTheme appTextTheme = TextTheme(

  displayLarge: AppTypography.h1,
  displayMedium: AppTypography.h2,
  displaySmall: AppTypography.h3,

  headlineLarge: AppTypography.h4,
  headlineMedium: AppTypography.h5,
  headlineSmall: AppTypography.h6,

  titleLarge: AppTypography.subtitle1,
  titleMedium: AppTypography.subtitle2,

  bodyLarge: AppTypography.body1,
  bodyMedium: AppTypography.body2,

  labelLarge: AppTypography.button,
  bodySmall: AppTypography.caption,
  labelSmall: AppTypography.overline,
);

// APP THEMES

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      
      //primario
      primary: AppColors.brand500,
      onPrimary: AppColors.neutral0,
      primaryContainer: AppColors.neutral0,
      onPrimaryContainer: AppColors.brand900,

      //secundario
      secondary: AppColors.secondary500,
      onSecondary: AppColors.neutral0,
      secondaryContainer: AppColors.secondary100,
      onSecondaryContainer: AppColors.secondary900,

      error: AppColors.error500,
      onError: AppColors.neutral0,
      errorContainer: AppColors.error50,
      onErrorContainer: AppColors.error800,

      surface: AppColors.secondary100,
      onSurface: AppColors.neutral800,

      outline: AppColors.neutral300,
    ),
    textTheme: appTextTheme,
  );
}

