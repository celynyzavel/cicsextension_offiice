import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/login_page.dart';

class CicsExtensionApp extends StatelessWidget {
  const CicsExtensionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CICS Extension Projects and Technology Transfer',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: kBackground,
        splashFactory: InkSparkle.splashFactory,
        colorScheme: ColorScheme.light(
          primary: kPrimary,
          onPrimary: kWhite,
          secondary: kGold,
          onSecondary: kWhite,
          error: kDanger,
          surface: kCard,
          onSurface: kTextPrimary,
        ),

        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: kTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
          titleLarge: TextStyle(
            color: kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: kTextPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: kTextPrimary, fontSize: 15, height: 1.4),
          bodyMedium: TextStyle(color: kTextSecondary, fontSize: 13.5, height: 1.4),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: kSidebar,
          foregroundColor: kWhite,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: kWhite,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),

        cardTheme: CardThemeData(
          color: kCard,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: kCardBorder),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: kCard,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titleTextStyle: const TextStyle(
            color: kTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: const TextStyle(color: kTextSecondary, fontSize: 14, height: 1.4),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: kWhite,
            disabledBackgroundColor: kPrimary.withValues(alpha: 0.45),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            side: const BorderSide(color: kPrimary, width: 1.4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurfaceAlt,
          hintStyle: const TextStyle(color: kMuted, fontSize: 14),
          labelStyle: const TextStyle(color: kTextSecondary, fontSize: 14),
          floatingLabelStyle: const TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kCardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kDanger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kDanger, width: 1.8),
          ),
          errorStyle: const TextStyle(color: kDanger, fontSize: 12, fontWeight: FontWeight.w600),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: kSidebar,
          contentTextStyle: const TextStyle(color: kWhite, fontSize: 13.5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          insetPadding: const EdgeInsets.all(16),
        ),

        dividerTheme: const DividerThemeData(color: kCardBorder, thickness: 1, space: 1),

        iconTheme: const IconThemeData(color: kTextSecondary),

        chipTheme: ChipThemeData(
          backgroundColor: kSurfaceAlt,
          labelStyle: const TextStyle(color: kTextPrimary, fontSize: 12, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),

        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: kSidebar,
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(color: kWhite, fontSize: 12),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
