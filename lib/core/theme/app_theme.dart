import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const mainColor = Color(0xFF2F80ED);
  static final inputBorder = BorderRadius.circular(10);
  ThemeData getThemeData() => ThemeData(
        colorSchemeSeed: mainColor,
        
       
        fontFamily: GoogleFonts.nunito().fontFamily,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: inputBorder,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: inputBorder,
            borderSide: const BorderSide(
              color: mainColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: inputBorder,
            borderSide: const BorderSide(
              color: mainColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: inputBorder,
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: inputBorder,
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
        ),
      );

  static customTitle() => const TextStyle(
        color: mainColor,
        fontSize: 36,
        fontWeight: FontWeight.w700,
      );

  static buttonStyleLogin() => FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
      );

     static   TextStyle titleStyleOp() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      color: mainColor,
      fontSize: 20,
    );
  }

  static final drawerTextStyle = GoogleFonts.poppins(
    fontSize: 15,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
  );

  static final drawerTitleStyle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: mainColor,
    letterSpacing: -0.5,
  );

  static const drawerIconSize = 22.0;
  static const drawerBorderRadius = 12.0;
}
