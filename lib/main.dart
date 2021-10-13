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
import 'theme/custom_theme.dart';

const _url = "https://github.com/tesserato/Mark-Book";

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

final ValueNotifier<bool> _rebuildAppBar = ValueNotifier(false);
double _ratio = 0.4;
double _oldRatio = 0.4;
bool _buildTextInput = true;
bool _buildTextOutput = true;
String appBarTitle = "mark book";
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;
  Icon themeIcon = const Icon(Icons.dark_mode);
  Icon lineStartIcon = const Icon(Icons.toggle_on);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: CustomTheme.light,
        darkTheme: CustomTheme.dark,
        themeMode: themeMode,
        title: "MarkBook",
        home: Scaffold(
            key: _scaffoldKey,
            drawer: Drawer(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("settings:", style: drawer),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip:
                          'Return to app',
                      onPressed: () {
                        BuildContext? context =
                            _scaffoldKey.currentState?.context;
                        Navigator.of(context!).pop();
                        // _scaffoldKey.currentState?.context;
                      },
                    ),

                    IconButton(
                        tooltip: "Dark / Light theme",
                        icon: themeIcon,
                        onPressed: () {
                          if (themeMode == ThemeMode.dark) {
                            themeMode = ThemeMode.light;
                            themeIcon = const Icon(Icons.dark_mode);
                          } else {
                            themeMode = ThemeMode.dark;
                            themeIcon = const Icon(Icons.light_mode);
                          }
                          setState(() {});
                        }),
                                            IconButton(
                        tooltip: "Toggle line start markers",
                        icon: lineStartIcon,
                        onPressed: () {
                          showLineStart = !showLineStart; 
                          if (showLineStart == true) {
                            lineStartIcon = const Icon(Icons.toggle_on);
                          } else {
                            lineStartIcon = const Icon(Icons.toggle_off);
                          }
                          setState(() {});
                        }),
                        Text("input font", style: drawer),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            tooltip: "Decrease input font",
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {
                              inputfontSize -= .5;
                              setState(() {});
                            }),
                        IconButton(
                            tooltip: "Increase input font",
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              inputfontSize += .5;
                              setState(() {});
                            })
                      ],
                    ),
                    Text("output font", style: drawer),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            tooltip: "Decrease input font",
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {
                              outputFontSize -= .5;
                              setState(() {});
                            }),
                        IconButton(
                            tooltip: "Increase input font",
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              outputFontSize += .5;
                              setState(() {});
                            })
                      ],
                    ),
                                        IconButton(
                      icon: const Icon(CustomIcons.icon),
                      tooltip:
                          'Instructions, info, apps for other platforms ▶ $_url',
                      onPressed: () {
                        // print("launch");
                        launch(_url);
                      },
                    ),
                  ]),
            ),
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              automaticallyImplyLeading: true,

              title: Text(appBarTitle),
              actions: [
                IconButton(
                    icon: const Icon(Icons.folder),
                    tooltip: 'Open a mark book file (*.mb)',
                    onPressed: () async {
                      try {
                        FilePickerCross file =
                            await FilePickerCross.importFromStorage(
                                type: FileTypeCross.custom,
                                fileExtension: '.mb');
                        Globals.controller.text = file.toString();

                        setState(() {
                          appBarTitle = file.fileName
                                  ?.replaceAll(".mb", "")
                                  .toLowerCase() ??
                              "mark book";
                        });
                      } catch (e) {
                        print(e);
                      }
                    }),
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save as',
                  onPressed: () {
                    // print("here");
                    Uint8List bytes = Uint8List.fromList(
                        utf8.encode(Globals.controller.text));
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
                      // ho
                      // borderRadius: BorderRadius.circular(10),
                      // color: Theme.of(context).colorScheme.onBackground,
                      // selectedColor:Theme.of(context).colorScheme.onBackground ,
                      // highlightColor: ,
                      // hoverColor: Theme.of(context).colorScheme.primaryVariant,
                      children: const <Widget>[
                        Tooltip(
                          child: Icon(
                            Icons.subject,
                          ),
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
                            _oldRatio = _ratio;
                            _ratio = 0;
                            // print("destroy");
                          } else {
                            _buildTextInput = true;
                            if (_buildTextOutput) _ratio = _oldRatio;
                            // print("build");
                          }
                        } else if (index == 1) {
                          if (_buildTextOutput && _buildTextInput) {
                            _buildTextOutput = false;
                            _oldRatio = _ratio;
                            _ratio = 1;
                            // print("destroy");
                          } else {
                            _buildTextOutput = true;
                            if (_buildTextInput) _ratio = _oldRatio;
                            // print("build");
                          }
                        }
                        setState(() {});
                      },
                      isSelected: [_buildTextInput, _buildTextOutput],
                    );
                  },
                ),
                IconButton(
                  tooltip: "Expand all songs",
                  icon: const Icon(Icons.expand),
                  onPressed: () {
                    for (var key in Globals.tiles) {
                      key.currentState?.expand();
                    }
                    setState(() {});
                  },
                ),
                IconButton(
                  tooltip: "Collapse all songs",
                  icon: const Icon(Icons.compress),
                  onPressed: () {
                    for (var key in Globals.tiles) {
                      key.currentState?.collapse();
                    }
                  },
                ),
              ],
              // actions: const []
            ),
            body: Home()));
  }
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

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
      // if (_buildTextInput)
      Visibility(
        // duration: const Duration(milliseconds: 300),
        visible: _buildTextInput,
        maintainState: true,
        child: SizedBox(
          width: (_totalWidth - _dividerWidth) * _ratio,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: Theme.of(context).textTheme.bodyText1,
              enableSuggestions: false,
              decoration: InputDecoration(
                  label: Text(appBarTitle),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true),
              expands: true,
              controller: Globals.controller,
              autofocus: true,
              maxLines: null,
              // onc: ,
              onChanged: (text) {
                setState(() {});
              },
            ),
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
            _ratio = 0.4;
            _buildTextOutput = true;
            _buildTextInput = true;
            _rebuildAppBar.value ^= true;
            setState(() {});
          },
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              _ratio += details.delta.dx / _totalWidth;
            });
            if (_ratio > .9) {
              _ratio = 1;
              _buildTextOutput = false;
            } else if (_ratio < 0.1) {
              _ratio = 0.0;
              _buildTextInput = false;
            }
            _rebuildAppBar.value ^= true;
          },
        ),
      ),
      Visibility(
        // key: UniqueKey(),
        visible: _buildTextOutput,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        maintainInteractivity: true,
        child: SizedBox(
          width: (_totalWidth - _dividerWidth) * (1 - _ratio),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 10, 5),
            child: Output(),
          ),
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


