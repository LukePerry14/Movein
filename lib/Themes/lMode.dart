import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LAppTheme{
  static TextStyle header = GoogleFonts.sourceCodePro(color: Colors.black54);
  static TextStyle sHeader = GoogleFonts.sourceCodePro(color: Colors.black45, fontWeight: FontWeight.bold);
  static TextStyle body = GoogleFonts.roboto(color: Colors.black87);


  static TextStyle d_header = GoogleFonts.sourceCodePro(color: Colors.white);
  static TextStyle d_sHeader = GoogleFonts.sourceCodePro(color: Colors.white);
  static TextStyle d_body = GoogleFonts.roboto(color: Colors.white70);

  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: const MaterialColor(0xFFEFCE14, <int, Color>{
        50: Color(0xFFFDF9E3),
        100: Color(0xFFFAF0B9),
        200: Color(0xFFF7E78A),
        300: Color(0xFFF4DD5B),
        400: Color(0xFFF1D537),
        500: Color(0xFFEFCE14),
        600: Color(0xFFEDC912),
        700: Color(0xFFEBC20E),
        800: Color(0xFFE8BC0B),
        900: Color(0xFFE4B006),
      }
      ),
    textTheme: TextTheme(
      headlineMedium: header,
      headlineSmall: sHeader,
      bodyMedium: body,
    ),

  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: const MaterialColor(0xFFEFCE14, <int, Color>{
      50: Color(0xFFFDF9E3),
      100: Color(0xFFFAF0B9),
      200: Color(0xFFF7E78A),
      300: Color(0xFFF4DD5B),
      400: Color(0xFFF1D537),
      500: Color(0xFFEFCE14),
      600: Color(0xFFEDC912),
      700: Color(0xFFEBC20E),
      800: Color(0xFFE8BC0B),
      900: Color(0xFFE4B006),
    }
    ),
    textTheme: TextTheme(
      headlineMedium: d_header,
      headlineSmall: d_sHeader,
      bodyMedium: d_body,
    ),
  );
}