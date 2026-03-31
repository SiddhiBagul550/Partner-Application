import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const black = Color(0xFF0A0A0A);
  static const black2 = Color(0xFF111111);
  static const black3 = Color(0xFF181818);
  static const black4 = Color(0xFF222222);
  static const black5 = Color(0xFF2A2A2A);

  static const gold = Color(0xFFC9A84C);
  static const goldLight = Color(0xFFE8C96A);
  static const goldPale = Color(0xFFF5E6B8);

  static const white = Color(0xFFF5F0E8);
  static const whiteDim = Color(0x99F5F0E8);
  static const whiteFaint = Color(0x1FF5F0E8);

  static const goldGlow = Color(0x33C9A84C);
  static const goldBorder = Color(0x59C9A84C);

  static const green = Color(0xFF6DCA6D);
  static const red = Color(0xFFE06060);

  static const Gradient goldGradient = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGoldGradient = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.goldLight,
          surface: AppColors.black3,
          error: AppColors.red,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          bodyMedium: GoogleFonts.dmSans(color: AppColors.white),
          bodySmall: GoogleFonts.dmSans(color: AppColors.whiteDim),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.black2,
          elevation: 0,
          titleTextStyle: GoogleFonts.cormorantGaramond(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        dividerColor: AppColors.goldBorder,
        cardColor: AppColors.black3,
        useMaterial3: true,
      );
}
