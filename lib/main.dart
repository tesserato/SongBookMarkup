import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'assets/custom_icons.dart';
import 'widgets/output.dart';
import 'models/globals.dart' as Globals;

String _rawText = '''
! Song's title (Start a new song with "!")

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

const _url = "https://github.com/tesserato/Mark-Book";
// void _launchURL() async =>
//     await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

// ValueNotifier<bool> _rebuildTextWidgets = ValueNotifier(false);
// bool _expandedTiles = true;

double _fontSize = 16.0;
double _fontFactor = 1.2;

var _inputStyle = TextStyle(
    fontFamily: GoogleFonts.firaCode().fontFamily, fontSize: _fontSize);

var _darkTheme = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  // primaryColor: Colors.red,

  // Define the default font family.
  fontFamily: GoogleFonts.inconsolata().fontFamily,

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  // textTheme: GoogleFonts.firaMonoTextTheme() ,
  textTheme: TextTheme(
    headline1: TextStyle(
        fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w900),
    headline2: TextStyle(
        fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w500),
    bodyText1: TextStyle(
        fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w100),
    bodyText2: TextStyle(
        fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w300),
  ),
);

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Fira_Mono'], license);
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

final TextEditingController _controller = TextEditingController(text: _rawText);
final ValueNotifier<bool> _rebuildAppBar = ValueNotifier(false);
// Map<Key, bool> expanded = {};
double _ratio = 0.5;
double _oldRatio = 0.5;

class _MyAppState extends State<MyApp> {
  bool _buildTextInput = true;
  bool _buildTextOutput = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: _darkTheme,
        title: "MarkBook",
        home: Scaffold(
            appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: true,
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(CustomIcons.icon),
                        tooltip:
                            'Instructions, info, apps for other platforms ▶ $_url',
                        onPressed: () {
                          print("launch");
                          launch(_url);
                        },
                      ),
                      IconButton(
                          icon: const Icon(Icons.folder_open_outlined),
                          tooltip: 'Open a mark book file (*.mb)',
                          onPressed: () async {
                            try {
                              FilePickerCross file =
                                  await FilePickerCross.importFromStorage(
                                      type: FileTypeCross.custom,
                                      fileExtension: '.mb');
                              _controller.text = file.toString();
                              // _rebuildTextWidgets.value = true;
                              setState(() {});
                            } catch (e) {
                              print(e);
                            }
                          }),
                      IconButton(
                        icon: const Icon(Icons.save_outlined),
                        tooltip: 'Save as',
                        onPressed: () {
                          // print("here");
                          Uint8List bytes =
                              Uint8List.fromList(utf8.encode(_controller.text));
                          // print(bytes);
                          var file = FilePickerCross(bytes,
                              type: FileTypeCross.custom, fileExtension: '.mb');
                          file.exportToStorage(
                              fileName: "Mark Book.mb", text: "Test");
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _rebuildAppBar,
                        builder: (context, value, child) {
                          return ToggleButtons(
                            borderRadius: BorderRadius.circular(10),
                            children: const <Widget>[
                              Tooltip(
                                child: Icon(Icons.text_fields),
                                message: "Toggle input field",
                              ),
                              Tooltip(
                                child: Icon(Icons.text_snippet),
                                message: "Toggle rendered output",
                              ),
                            ],
                            onPressed: (int index) {
                              if (index == 0) {
                                if (_buildTextOutput && _buildTextInput) {
                                  _buildTextInput = false;
                                  // _rebuildTextWidgets.value ^= true;
                                  _oldRatio = _ratio;
                                  _ratio = 0;
                                  print("destroy");
                                } else {
                                  _buildTextInput = true;
                                  // _rebuildTextWidgets.value ^= true;
                                  _ratio = _oldRatio;
                                  print("build");
                                }
                              }

                              if (index == 1) {
                                if (_buildTextOutput && _buildTextInput) {
                                  _buildTextOutput = false;
                                  // _rebuildTextWidgets.value ^= true;
                                  _oldRatio = _ratio;
                                  _ratio = 1;
                                  print("destroy");
                                } else {
                                  _buildTextOutput = true;
                                  // _rebuildTextWidgets.value ^= true;
                                  _ratio = _oldRatio;
                                  print("build");
                                }
                              }
                              setState(() {
                                // _buildTextOutput = _buildTextOutput;
                              });
                            },
                            isSelected: [_buildTextInput, _buildTextOutput],
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_full),
                        onPressed: () {
                          // _expandedTiles = true;
                          // _rebuildTextWidgets.value ^= true;
                          for (var key in Globals.expanded.keys) {
                            Globals.expanded[key] = true;
                          }
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_fullscreen),
                        onPressed: () {
                          // _expandedTiles = false;
                          // _rebuildTextWidgets.value ^= true;
                          for (var key in Globals.expanded.keys) {
                            Globals.expanded[key] = false;
                          }
                          setState(() {});
                        },
                      )
                    ]),
                actions: const []),
            body: Home(_buildTextInput, _buildTextOutput)));
  }
}

class Home extends StatefulWidget {
  bool _buildTextInput = true;
  bool _buildTextOutput = true;
  Home(this._buildTextInput, this._buildTextOutput, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  final double _dividerWidth = 10;
  @override
  Widget build(BuildContext context) {
    var _totalWidth = MediaQuery.of(context).size.width;
    return Row(children: <Widget>[
      if (widget._buildTextInput)
        SizedBox(
          width: (_totalWidth - _dividerWidth) * _ratio,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: _inputStyle,
              enableSuggestions: false,
              decoration: const InputDecoration(
                  label: Text("Mark Book"),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true),
              expands: true,
              controller: _controller,
              autofocus: true,
              maxLines: null,
              // onc: ,
              onChanged: (text) {
                setState(() {});
              },
            ),
          ),
        ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            width: _dividerWidth,
            // height: constraints.maxHeight,
            // child: const RotationTransition(
            //   child: Icon(Icons.drag_handle),
            //   turns: AlwaysStoppedAnimation(0.25),
            // ),
          ),
          onDoubleTap: () {
            _ratio = 0.5;
            widget._buildTextOutput = true;
            widget._buildTextInput = true;
            _rebuildAppBar.value ^= true;
            setState(() {});
          },
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              _ratio += details.delta.dx / _totalWidth;
              if (_ratio > .9) {
                _ratio = 1;
                widget._buildTextOutput = false;
                setState(() {});
                _rebuildAppBar.value ^= true;
              } else if (_ratio < 0.1) {
                _ratio = 0.0;
                widget._buildTextInput = false;
                setState(() {});
                _rebuildAppBar.value ^= true;
              }
            });
          },
        ),
      ),
      if (widget._buildTextOutput)
        SizedBox(
          width: (_totalWidth - _dividerWidth) * (1 - _ratio),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 10, 5),
            child: Output(_controller.text, key: UniqueKey()),
          ),
        ),
    ]);
  }
}



// Widget processTextOld(String rawText) {
//   List<Widget> W = [];
//   // int numberOfSongs = 0;
//   Map<String, List<int>> chordNameToFingering = {};

//   for (var rawLine in rawText.split("\n")) {
//     String rawLineTrimmed = rawLine.trim();

//     if (rawLineTrimmed.isEmpty) {
//       continue;
//     }

//     if (rawLineTrimmed.startsWith("|")) {
//       continue;
//     }

//     if (rawLineTrimmed.startsWith("!")) {
//       // new song
//       W.add(Padding(
//         // add song title text
//         padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 18.0),
//         child: RichText(
//             overflow: TextOverflow.visible,
//             text: TextSpan(
//                 text: rawLineTrimmed.substring(1),
//                 style: _darkTheme.textTheme.headline1)),
//       ));
//       continue;
//     }

//     if (rawLineTrimmed.startsWith("[")) {
//       List<int> fingering = [];
//       // int i = 0;
//       List<String> rawFingering = rawLineTrimmed.split("]");
//       String name = rawFingering.last.trim();
//       rawFingering = rawFingering.first
//           .replaceAll("[", "")
//           .replaceAll(",", " ")
//           .replaceAll(";", " ")
//           .split(" ");
//       if (rawFingering.length <= 1) {
//         rawFingering = rawLineTrimmed.split("");
//       }
//       for (var item in rawFingering) {
//         if (item.toLowerCase() == "x") {
//           fingering.add(-1);
//         } else {
//           int? fret = int.tryParse(item);
//           if (fret != null) {
//             fingering.add(fret);
//           }
//         }
//       }
//       // while (i < rawLineTrimmed.length && rawLineTrimmed[i] != "]") {
//       //   i++;
//       //   if (rawLineTrimmed[i].toLowerCase() == "x") {
//       //     fingering.add(-1);
//       //   } else {
//       //     int? fret = int.tryParse(rawLineTrimmed[i]);
//       //     if (fret != null) {
//       //       fingering.add(fret);
//       //     }
//       //   }
//       // }

//       chordNameToFingering[name] = fingering;
//       // print("$name  $fingering");
//       continue;
//     }

//     if (rawLineTrimmed.startsWith("#")) {
//       W.add(Padding(
//         padding: const EdgeInsets.fromLTRB(0.0, 17.0, 0.0, 17.0),
//         child: RichText(
//             overflow: TextOverflow.visible,
//             text: TextSpan(
//                 text: rawLineTrimmed.substring(2),
//                 style: _darkTheme.textTheme.headline2)),
//       ));
//       continue;
//     }

//     if (rawLineTrimmed.startsWith(">")) {
//       List<Widget> R = [];
//       bool insideChord = false;
//       rawLineTrimmed += " ";
//       int start = 0;
//       int end = 0;
//       for (var i = 1; i < rawLineTrimmed.length; i++) {
//         if (rawLineTrimmed[i] == " ") {
//           if (insideChord) {
//             // left chord name
//             end = i;
//             final name = rawLine.substring(start, end);
//             final fingering = chordNameToFingering[name];
//             R.add(Padding(
//               padding: const EdgeInsets.fromLTRB(0.0, 10.0, 1.0, 0.0),
//               child: ChordWidget(name, fingering: fingering),
//             ));
//           }
//           insideChord = false;
//         } else {
//           if (!insideChord) {
//             //entered chord name
//             start = i;
//             R.add(RichText(
//                 overflow: TextOverflow.ellipsis,
//                 text: TextSpan(
//                     text: ''.padRight(start - end, ' '),
//                     style: _darkTheme.textTheme.bodyText2)));
//           }
//           insideChord = true;
//         }
//       }
//       W.add(Row(children: R));
//       continue;
//     }

//     W.add(RichText(
//         overflow: TextOverflow.ellipsis,
//         text: TextSpan(text: rawLine, style: _darkTheme.textTheme.bodyText1)));
//   }

//   return ListView(
//     // mainAxisSize: MainAxisSize.min,
//     // crossAxisAlignment: CrossAxisAlignment.start,
//     children: W,
//   );
// }


