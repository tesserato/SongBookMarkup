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

# Welcome to Mark Book! This is an implementation of a minimal markup language intended to the elaboration of songbooks.

# The language is in fact very simple, and consists of four markers ( ! , # ,  >  and  [ ) used in the beggining of special lines. The rendered markup can be seen in the right panel. The function of each marker is as follows:

# ! - The exclamation mark begging a new song, as seen in the first line.

# # - As you probably noticed, lines starting with a hash are rendered as visible comments.

# | - Lines starting with a pipe won't be rendered. They are invisible comments intended to be seen only in the source file, as the example below:

| This line won't be rendered, and thus can't be seen in the right panel

# [ - Lines starting with square brackets are lines that define a chord, to be used in the current song. They have to adhere to one of the following pattern:

[0 4 x 2 5 0] A
[x;x,2 2  2 2]      A6

#     That is, six integers separated by spaces, semi colons or commas (or a combination of them) inside square brackets, followed by the name of the chord. Those chords can be subsequently used in chord lines, our last marker. An extensive list of chords in this format can be found in https://en.wikibooks.org/wiki/Guitar/Chords/Full_List_Standard_Tuning

# > - Lines starting with a greater than sign are chord lines. The implementation provides a very rudimentary chord detection engine, so the chords will likely appear even if not defined beforehand. Defined chords,  however, have priority over auto generated ones.

>A     A6

carlos


# The chords can be hovered or clicked in the rendered panel to the right wo expose a diagram of the chord. Also, chords above a line of normal text (that is, text starting without any marker) keep their original position in the rendered output. This allows precision in the placing of a chord in relation to the lirics.

# Normal text can be divided in lines in the markup source (here), but will appear side by side in the redered output, wrapped as necessary. This is the main reason that motivated this app: presenting songbooks compactly and gracefully in a wide range of available spaces, in diffent screens. 

# A marker is inserted in the beggining of each verse, to facilitate the reading. This marker can be disabled in the settings, however. Font size for both input and output can be changed in the setting, as well as the chord panel size. Below is an example of a real song.

       





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
