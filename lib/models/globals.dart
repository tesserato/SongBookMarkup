import 'package:flutter/material.dart';
import '../widgets/custom_expansion_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

Set<GlobalKey<CustomExpansionTileState>> tiles = {};

final TextEditingController controller = TextEditingController(text: _rawText);

// preferences

Future<void> clearPreferences() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
}

Future<void> getPreferences() async {
  // theme
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool darkTheme = prefs.getBool('darkTheme') ?? true;
  if (darkTheme) {
    themeMode = ThemeMode.dark;
  } else {
    themeMode = ThemeMode.light;
  }

  // rawText
  _rawText = prefs.getString('rawText') ?? _rawText;

  // ratio
  ratio = prefs.getDouble('ratio') ?? 0.4;
  oldRatio = prefs.getDouble('oldRatio') ?? 0.4;
  buildTextInput = prefs.getBool("buildTextInput") ?? true;
  buildTextOutput = prefs.getBool("buildTextOutput") ?? true;

  // line start
  showLineStart = prefs.getBool("showLineStart") ?? true;

  // font
  inputfontSize = prefs.getDouble('inputfontSize') ?? 16.0;
  outputFontSize = prefs.getDouble('outputFontSize') ?? 16.0;

  // Chord panel size
  chordPanelSize = prefs.getDouble('chordPanelSize') ?? 20.0;

  // App bar title
  appBarTitle = prefs.getString('appBarTitle') ?? "mark book";
}

// App bar title
String appBarTitle = "mark book";
Future<void> saveAppBarTitle() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('appBarTitle', appBarTitle);
}

// Chord panel size
double chordPanelSize = 20;
Future<void> saveChordPanelSize() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('chordPanelSize', chordPanelSize);
}

// font
double inputfontSize = 16.0;
double outputFontSize = 16.0;
Future<void> saveFont() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('inputfontSize', inputfontSize);
  prefs.setDouble('outputFontSize', outputFontSize);
}

// line start
bool showLineStart = true;
Future<void> saveShowLineStart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('showLineStart', showLineStart);
}

// ratio
double ratio = 0.4;
double oldRatio = 0.4;
bool buildTextInput = true;
bool buildTextOutput = true;
Future<void> saveRatio() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('ratio', ratio);
  prefs.setDouble('oldRatio', oldRatio);
  prefs.setBool('buildTextInput', buildTextInput);
  prefs.setBool('buildTextOutput', buildTextOutput);
}

// themeMode
ThemeMode themeMode = ThemeMode.dark;

Future<void> savethemeMode(ThemeMode themeMode) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (themeMode == ThemeMode.dark) {
    prefs.setBool('darkTheme', true);
  } else {
    prefs.setBool('darkTheme', false);
  }
}

// rawText
Future<void> saveRawText() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('rawText', _rawText);
}

String _rawText = '''
! 1 Song's title (Start a new song with "!")

# Artist's name ("Start a visible comment with "#")
# Composer's name 

|comment (Lines starting with "|" won't be rendered)

|chord definitions
[0 4 x 2 5 0] A
       [x;x,2 2  2 2]      A6
| OR
[002420]A/B

|chord line, (line starting with ">")
>A       A/B          A6        D7 
|text line
There is a house down in New Orleans 
There is a house down in New Orleans 
>    G               D 
They call the Rising Sun  
>D                           G 
And it's been the ruin of a many poor boy 
>     D       A          D 
And me, oh God , for one 
 
>D                        D7 
>D                        D7 
Then fill the glasses to the brim 
>        G                   D 
Let the drinks go merrily around 
>D                                  G 
And we'll drink to the health of a rounder poor boy 
>    D         A7       D 
Who goes from town to town 

! 2 Song's title (Start a new song with "!")

# Artist's name ("Start a visible comment with "#")
# Composer's name 

|comment (Lines starting with "|" won't be rendered)

|chord definitions
[0 4 x 2 5 0] A
       [x;x,2 2  2 2]      A6
| OR
[002420]A/B

|chord line, (line starting with ">")
>A       A/B          A6        D7 
|text line
There is a house down in New Orleans 
There is a house down in New Orleans 
>    G               D 
They call the Rising Sun  
>D                           G 
And it's been the ruin of a many poor boy 
>     D       A          D 
And me, oh God , for one 
 
>D                        D7 
>D                        D7 
Then fill the glasses to the brim 
>        G                   D 
Let the drinks go merrily around 
>D                                  G 
And we'll drink to the health of a rounder poor boy 
>    D         A7       D 
Who goes from town to town 
''';
