import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/output.dart';
import '../models/globals.dart' as Globals;

var mainWhiteColor = Colors.blueGrey;
var mainBlackColor = Colors.grey;


var mainFontFamily = GoogleFonts.nunito().fontFamily;

ColorScheme lightColorScheme = ThemeData.light().colorScheme.copyWith(
    primary: mainWhiteColor.shade500,
    primaryVariant: mainWhiteColor.shade600,
    secondary: mainWhiteColor.shade700,
    secondaryVariant: mainWhiteColor.shade800);

ColorScheme darkColorScheme = ThemeData.light().colorScheme.copyWith(
    primary: mainBlackColor.shade600,
    primaryVariant: mainBlackColor.shade700,
    secondary: mainBlackColor.shade800,
    secondaryVariant: mainBlackColor.shade900);

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
              color: Colors.white,
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
                fontSize: Globals.outputFontSize,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontFamily: mainFontFamily),
            headline2: TextStyle(
                fontSize: Globals.outputFontSize,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: mainFontFamily),
            // chord name
            headline3: TextStyle(
                fontSize: Globals.outputFontSize,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontFamily: mainFontFamily),
            // chord panel annotations
            headline4: TextStyle(
                fontSize: Globals.chordPanelSize * .8,
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontFamily: mainFontFamily),
            //input
            bodyText1: TextStyle(
                fontFamily: GoogleFonts.firaCode().fontFamily,
                fontSize: Globals.inputfontSize,
                color: Colors.black,
                fontWeight: FontWeight.w500),
            //output
            bodyText2: TextStyle(
                fontSize: Globals.outputFontSize,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontFamily: mainFontFamily),
          ),
    );
  }

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          titleTextStyle: TextStyle(
              fontFamily: GoogleFonts.majorMonoDisplay().fontFamily,
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold)),
      colorScheme: darkColorScheme,
      toggleButtonsTheme: ThemeData.dark().toggleButtonsTheme.copyWith(
            borderRadius: BorderRadius.circular(10),
            color: darkColorScheme.onBackground,
            selectedColor: darkColorScheme.onPrimary,
            fillColor: darkColorScheme.primaryVariant,
            hoverColor: darkColorScheme.secondary,
          ),
      textTheme: ThemeData.dark().textTheme.copyWith(
            // header
            headline1: TextStyle(
                fontSize: Globals.outputFontSize,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: mainFontFamily),
            headline2: TextStyle(
                fontSize: Globals.outputFontSize,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: mainFontFamily),
            // chord name
            headline3: TextStyle(
                fontSize: Globals.outputFontSize,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: mainFontFamily),
            // chord panel annotations
            headline4: TextStyle(
                fontSize: Globals.chordPanelSize * .8,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontFamily: mainFontFamily),
            //input
            bodyText1: TextStyle(
                fontFamily: GoogleFonts.firaCode().fontFamily,
                fontSize: Globals.inputfontSize,
                color: Colors.white,
                fontWeight: FontWeight.w500),
            //output
            bodyText2: TextStyle(
                fontSize: Globals.outputFontSize,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: mainFontFamily),
          ),
    );
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