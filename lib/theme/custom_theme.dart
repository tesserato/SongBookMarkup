import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'colors.dart';

var mainWhiteColor =Colors.blueGrey;

ColorScheme lightColorScheme =
    ThemeData.light().colorScheme.copyWith(
      primary: mainWhiteColor.shade500, 
      primaryVariant: mainWhiteColor.shade600,
      secondary: mainWhiteColor.shade700,
      secondaryVariant: mainWhiteColor.shade800
      );

class CustomTheme {
  static ThemeData get light {
    return ThemeData.light().copyWith(
        colorScheme: lightColorScheme,
        toggleButtonsTheme: ToggleButtonsThemeData(
          borderRadius: BorderRadius.circular(10),
          color: lightColorScheme.onBackground,
          selectedColor: lightColorScheme.onPrimary,
          fillColor: lightColorScheme.primaryVariant,
          hoverColor: lightColorScheme.secondary,

          // : ThemeData.light().colorScheme.secondaryVariant
        ));
  }

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
        toggleButtonsTheme:
            ToggleButtonsThemeData(borderRadius: BorderRadius.circular(10)));
  }
}

// var _darkTheme = ThemeData(
//   // Define the default brightness and colors.
//   brightness: Brightness.dark,
//   // primaryColor: Colors.red,

//   // Define the default font family.
//   fontFamily: GoogleFonts.inconsolata().fontFamily,

//   // Define the default `TextTheme`. Use this to specify the default
//   // text styling for headlines, titles, bodies of text, and more.
//   // textTheme: GoogleFonts.firaMonoTextTheme() ,
//   textTheme: TextTheme(
//     headline1: TextStyle(
//         fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w900),
//     headline2: TextStyle(
//         fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w500),
//     bodyText1: TextStyle(
//         fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w100),
//     bodyText2: TextStyle(
//         fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w300),
//   ),
// );