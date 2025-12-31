import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/constant/colors.dart';
import 'package:flutter_application_1/shared/constant/textSize.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final theme = ThemeData(
    //cardColor: Colors.white,
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return appPrimaryColor;
      }),
    ),
    // fontFamily: 'NotoSans',
    // scaffoldBackgroundColor: appBackgroundColor,
    //appBarTheme: const AppBarTheme(elevation: 1),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.sourceSans3(
        textStyle: const TextStyle(color: mildBlack, fontSize: textSizeSmall2),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: blackColor),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: mildestblack, width: 0.5),
        //<-- SEE HERE
      ),

      //   activeIndicatorBorder: BorderSide(color: appPrimaryColor),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: appPrimaryColor),
      ),
    ),

    //   inputDecorationTheme: const InputDecorationTheme(
    //  //   activeIndicatorBorder: BorderSide(color: appPrimaryColor),
    //       focusedBorder: OutlineInputBorder(
    //     borderSide: BorderSide(
    //       color: appPrimaryColor,
    //       width: 2,
    //     ),

    //   ))
  );
}
