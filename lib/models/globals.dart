import 'package:flutter/material.dart';
import '../widgets/custom_expansion_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

// preferences
// SharedPreferences? preferences;



Set<GlobalKey<CustomExpansionTileState>> tiles = {};
final TextEditingController controller = TextEditingController(text: _rawText);

Future<void> clearPreferences() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
   preferences.clear();
}


Future<void> getPreferences() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  // theme
  bool darkTheme = preferences.getBool('darkTheme') ?? true;
  if (darkTheme) {
    themeMode = ThemeMode.dark;
  } else {
    themeMode = ThemeMode.light;
  }

  // rawText
  _rawText = preferences.getString('rawText') ?? _rawText;

  // ratio
  ratio = preferences.getDouble('ratio') ?? 0.4;
  oldRatio = preferences.getDouble('oldRatio') ?? 0.4;
  buildTextInput = preferences.getBool("buildTextInput") ?? true;
  buildTextOutput = preferences.getBool("buildTextOutput") ?? true;

  // line start
  showLineStart = preferences.getBool("showLineStart") ?? true;

  // font
  inputfontSize = preferences.getDouble('inputfontSize') ?? 16.0;
  outputFontSize = preferences.getDouble('outputFontSize') ?? 16.0;

  // Chord panel size
  chordPanelSize = preferences.getDouble('chordPanelSize') ?? 15.0;

  // App bar title
  appBarTitle = preferences.getString('appBarTitle') ?? "mark book";
}

// App bar title
String appBarTitle = "mark book";
Future<void> saveAppBarTitle()async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('appBarTitle', appBarTitle);
}

// Chord panel size
double chordPanelSize = 15.0;
Future<void> saveChordPanelSize()async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setDouble('chordPanelSize', chordPanelSize);
}

// font
double inputfontSize = 16.0;
double outputFontSize = 16.0;
Future<void> saveFont()async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setDouble('inputfontSize', inputfontSize);
  preferences.setDouble('outputFontSize', outputFontSize);
}

// line start
bool showLineStart = true;
Future<void> saveShowLineStart()async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool('showLineStart', showLineStart);
}

// ratio
double ratio = 0.4;
double oldRatio = 0.4;
bool buildTextInput = true;
bool buildTextOutput = true;
Future<void> saveRatio() async{
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  preferences.setDouble('ratio', ratio);
  preferences.setDouble('oldRatio', oldRatio);
  preferences.setBool('buildTextInput', buildTextInput);
  preferences.setBool('buildTextOutput', buildTextOutput);
}

// themeMode
ThemeMode themeMode = ThemeMode.system;

Future<void> savethemeMode(ThemeMode themeMode) async{
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  if (themeMode == ThemeMode.dark) {
    preferences.setBool('darkTheme', true);
  } else {
    preferences.setBool('darkTheme', false);
  }
}

// rawText
Future<void> saveRawText() async{
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('rawText', controller.text);
}

String _rawText = '''
! Instructions

# Welcome to Mark Book! This is an implementation of a minimal markup language intended for the elaboration of songbooks.

# The language is very simple, consisting of four markers ( ! , # ,  >  and  [ ) used at the beginning of special lines. The rendered markup can be seen in the right panel. The purpose of each marker is as follows:

# ! - The exclamation mark begins a new song, as seen in the first line.

# # - As you probably noticed, lines starting with a hash are rendered as visible comments.

# | - Lines starting with a pipe won't be rendered. They are invisible comments intended to be seen only in the source file, as the example below:

| This line won't be rendered, and thus can't be seen in the right panel

# [ - Lines starting with square brackets are lines that define a chord to be used in the current song. They have to adhere to one of the following patterns:

[x 0 2 2 2 0] A
[x,2,4,4,4,2] B
[0;3;2;0;1;0] C

#     That is, six integers separated by spaces, semicolons or commas (or a combination of them) inside square brackets, followed by the name of the chord. Those chords can be subsequently used in chord lines, our last marker. An extensive list of chords in this format can be found in https://en.wikibooks.org/wiki/Guitar/Chords/Full_List_Standard_Tuning

# > - Lines starting with a greater than sign are chord lines. The implementation provides a very rudimentary chord detection engine, so the chords will likely appear even if not defined beforehand. Defined chords,  however, have priority over auto-generated ones.

>A     C                                        B

Example of chord plus lyrics line


# The chords can be hovered or clicked in the rendered panel to the right to expose a diagram of the chord. Also, chords above a line of normal text (that is, text starting without any marker) keep their original position in the rendered output. This allows precision in the placing of chords in relation to the lyrics.

# Normal text can be divided into lines in the markup source (here), but will appear side by side in the rendered output, wrapped as necessary. This is the main motivation of this app: present songbooks compactly and gracefully in a wide range of available spaces, on different screens. 

# Per default, a marker is inserted at the beginning of each verse, to facilitate the reading. This marker can be disabled in the settings, however. Font size for both input and output can be changed in the setting, as well as the chord panel size. Also, all songs can be collapsed and expanded uses the buttons in the upper bar. Files can be loaded and saved, in the Mark Book (.mb) format. Below is an example of a real song. Details about the settings shown in the drawer (accessible through the hamburger menu) can be seen by hovering over the items or long-pressing in mobile.

      
! The Rising Sun Blues

# Clarence Ashley, Gwen Foster (VOCALION Records, 1933)

| The "E" chord wasn't defined; Em also inferred automatically
[x 0 2 2 2 0] A
[0 3 2 0 1 0] C
[x 0 2 2 1 0] Am
[x 2 4 4 4 2] B
[x 0 0 2 3 2] D
[x x 2 1 2 0] Dbm

# verse 2:
>E                                    A    E   C      E
They are a house in New Orleans they call the Rising Sun.
>      A         Am      E                         B
Where many poor boys to destruction has gone, and me, oh,
>         E    E B E
God, for one.
 
 
# verse 2:
> E                                           A         C
Just fill the glass up to the brim, let the drinks go merrily 
>E
around.
>      A     C      E                                B
We'll drink to the life of a rounder, poor boy, who goes from 
        E     E B E
town to town.
 
 
# verse 3:
>       Em         E      A       E          A        C   B E
All in this world does a rambler want, is a suitcase and a trunk.
>    A    Am        E             B              E     E B E
The only time he's satisfied, is when he's on a drunk.
 
 
# verse 4:
>E                              A                E            A
Now, boys don't believe what a young girl tells you, let her eyes 
>           E
be blue or brown.
>A            C       A   E                   B
Unless she's on some scaffold high, saying, 'Boys, I can't come 
> E    E B E Dbm E
down.'
 
 
# verse 5:
>E               Em   E  A   E               A       C B    E
I'm going back, back to New Orleans, for my race is almost run.
>   A     D   Dbm        E              B                E
to spend the rest of my wicked life, beneath the Rising Sun.
''';
