import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static TextTheme _textTheme = const TextTheme();
  static const double _borderRadius = 10;
  static const _borderWidth = 3.0;
  static OutlineInputBorder get border {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
      borderSide: BorderSide(
        color: AppColors.borderColor,
        width: _borderWidth,
      ),
    );
  }

  static void init(BuildContext context) {
    _textTheme = Theme.of(context).textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black,
          fontFamily: GoogleFonts.getFont('Urbanist').fontFamily,
        );
  }

  static NeumorphicThemeData get theme {
    return const NeumorphicThemeData(
      baseColor: AppColors.backgroundColor,
      lightSource: LightSource.topLeft,
      depth: 10,
    );
  }

  static ThemeData get materialTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        background: AppColors.backgroundColor,
        surface: AppColors.backgroundColor,
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
      ),
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          color: TextColors.dark,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        shape: Border(
          bottom: BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(
            const Size.fromHeight(50)
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            TextColors.light,
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            AppColors.primaryColor,
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            _textTheme.bodyLarge!
          ),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.backgroundColor,
        shadowColor: AppColors.shadowColor,
        surfaceTintColor: AppColors.shadowColor,
        titleTextStyle: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        contentTextStyle: TextStyle(
          color: TextColors.dark,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: AppTheme.border,
        enabledBorder: AppTheme.border,
        focusedBorder: AppTheme.border.copyWith(
          borderSide: const BorderSide(
            width: _borderWidth,
            color: AppColors.primaryColor,
          ),
        ),
        errorBorder: AppTheme.border.copyWith(
          borderSide: const BorderSide(
            width: _borderWidth,
            color: Colors.red,
          ),
        ),
        focusedErrorBorder:  AppTheme.border.copyWith(
          borderSide: const BorderSide(
            width: _borderWidth,
            color: Colors.red,
          ),
        ),
        labelStyle: _textTheme.bodyLarge!.copyWith(
          color: AppColors.primaryColor,
        ),
        hintStyle: _textTheme.bodyLarge!.copyWith(
          color: Colors.grey,
        ),
        errorStyle: _textTheme.bodyLarge!.copyWith(
          color: Colors.red,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      textTheme: _textTheme,
    );
  }
}