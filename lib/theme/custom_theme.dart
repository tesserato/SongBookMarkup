import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/output.dart';

double inputfontSize = 20.0;
double outputFontSize = 20.0;
var mainWhiteColor = Colors.blueGrey;

ColorScheme lightColorScheme = ThemeData.light().colorScheme.copyWith(
    primary: mainWhiteColor.shade500,
    primaryVariant: mainWhiteColor.shade600,
    secondary: mainWhiteColor.shade700,
    secondaryVariant: mainWhiteColor.shade800);

TextStyle drawer = TextStyle(
    fontFamily: GoogleFonts.majorMonoDisplay().fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w900);

class CustomTheme {
  static ThemeData get light {
    return ThemeData.light().copyWith(
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
          titleTextStyle: TextStyle(
              fontFamily: GoogleFonts.majorMonoDisplay().fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.bold)),
      colorScheme: lightColorScheme,
      toggleButtonsTheme: ThemeData.light().toggleButtonsTheme.copyWith(
            borderRadius: BorderRadius.circular(10),
            color: lightColorScheme.onBackground,
            selectedColor: lightColorScheme.onPrimary,
            fillColor: lightColorScheme.primaryVariant,
            hoverColor: lightColorScheme.secondary,
          ),
      textTheme: ThemeData.light().textTheme.copyWith(
            // header
            headline1: TextStyle(
                fontSize: outputFontSize,
                color: Colors.black,
                fontWeight: FontWeight.w700),
            headline2: TextStyle(
                fontSize: outputFontSize,
                color: Colors.black,
                fontWeight: FontWeight.w600),
            // chord name
            headline3: TextStyle(
                fontSize: outputFontSize,
                color: Colors.black,
                fontWeight: FontWeight.w700),
            // chord panel annotations
            headline4: TextStyle(
                fontSize: chordPanelSize * .8,
                color: Colors.black,
                fontWeight: FontWeight.w800),
            //input
            bodyText1: TextStyle(
              fontFamily: GoogleFonts.firaCode().fontFamily,
                fontSize: inputfontSize,
                color: Colors.black,
                fontWeight: FontWeight.w500),
            //output
            bodyText2: TextStyle(
                fontSize: outputFontSize,
                color: Colors.black,
                fontWeight: FontWeight.w500),
          ),
    );
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