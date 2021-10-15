import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/output.dart';
import 'models/globals.dart' as Globals;
import 'theme/custom_theme.dart';

const _url = "https://github.com/tesserato/Mark-Book";
final ValueNotifier<bool> _rebuildAppBar = ValueNotifier(false);
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

Future<void> main() async {  
  // LicenseRegistry.addLicense(() async* {
  //   final license = await rootBundle.loadString('fonts/OFL.txt');
  //   yield LicenseEntryWithLineBreaks(['Fira_Mono'], license);
  // });
  await Globals.getPreferences();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: CustomTheme.light,
        darkTheme: CustomTheme.dark,
        themeMode: Globals.themeMode,
        title: "MarkBook",
        home: Scaffold(
            key: _scaffoldKey,
            drawer: Drawer(
              child: ListView(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("settings:", style: drawer, textAlign: TextAlign.center),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Return to app',
                      onPressed: () {
                        BuildContext? context =
                            _scaffoldKey.currentState?.context;
                        Navigator.of(context!).pop();
                        // _scaffoldKey.currentState?.context;
                      },
                    ),
                    IconButton(
                        tooltip: "Dark / Light theme",
                        icon: Globals.themeMode == ThemeMode.dark
                            ? const Icon(Icons.light_mode)
                            : const Icon(Icons.dark_mode),
                        onPressed: () {
                          if (Globals.themeMode == ThemeMode.dark) {
                            Globals.themeMode = ThemeMode.light;
                            // themeIcon = const Icon(Icons.dark_mode);
                          } else {
                            Globals.themeMode = ThemeMode.dark;
                            // themeIcon = const Icon(Icons.light_mode);
                          }
                          Globals.savethemeMode(Globals.themeMode);
                          setState(() {});
                        }),
                    IconButton(
                        tooltip: "Toggle line start markers",
                        icon: Globals.showLineStart
                            ? const Icon(Icons.toggle_off)
                            : const Icon(Icons.toggle_on),
                        onPressed: () {
                          Globals.showLineStart = !Globals.showLineStart;
                          Globals.saveShowLineStart();
                          setState(() {});
                        }),
                    Text("input font", style: drawer, textAlign: TextAlign.center),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            tooltip: "Decrease input font",
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {
                              Globals.inputfontSize -= .5;
                              Globals.saveFont();
                              setState(() {});
                            }),
                        IconButton(
                            tooltip: "Increase input font",
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              Globals.inputfontSize += .5;
                              Globals.saveFont();
                              setState(() {});
                            })
                      ],
                    ),
                    Text("output font", style: drawer, textAlign: TextAlign.center),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            tooltip: "Decrease output font",
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {
                              Globals.outputFontSize -= .5;
                              Globals.saveFont();
                              setState(() {});
                            }),
                        IconButton(
                            tooltip: "Increase output font",
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              Globals.outputFontSize += .5;
                              Globals.saveFont();
                              setState(() {});
                            })
                      ],
                    ),
                    Text("chord panel size", style: drawer, textAlign: TextAlign.center),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            tooltip: "Decrease chord panel size",
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {
                              Globals.chordPanelSize -= .5;
                              Globals.saveChordPanelSize();
                              setState(() {});
                            }),
                        IconButton(
                            tooltip: "Increase chord panel size",
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              Globals.chordPanelSize += .5;
                              Globals.saveChordPanelSize();
                              setState(() {});
                            })
                      ],
                    ),

                    IconButton(
                      icon: const Icon(Icons.dangerous),
                      tooltip: 'Reset settings',
                      onPressed: () {
                        Globals.clearPreferences();
                        Globals.getPreferences();
                        setState(() {});
                      },
                    ),
                                        IconButton(
                      icon: Image.asset('assets/images/icon.png'),
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
              toolbarHeight: 40,
              centerTitle: true,
              elevation: 0,
              automaticallyImplyLeading: true,

              title: Text(Globals.appBarTitle),
              actions: [
                IconButton(
                    icon: const Icon(Icons.folder),
                    tooltip: 'Open a mark book file (*.mb)',
                    onPressed: () async {
                      try {
                        FilePickerCross file =
                            await FilePickerCross.importFromStorage(
                                type: FileTypeCross.any);
                        Globals.controller.text = file.toString();
                        Globals.saveRawText();
                        Globals.saveAppBarTitle();
                        setState(() {
                          Globals.appBarTitle = file.fileName
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
                          if (Globals.buildTextOutput &&
                              Globals.buildTextInput) {
                            Globals.buildTextInput = false;
                            FocusScope.of(context).unfocus();
                            Globals.oldRatio = Globals.ratio;
                            Globals.ratio = 0;
                            // print("destroy");
                          } else {
                            Globals.buildTextInput = true;
                            if (Globals.buildTextOutput) {
                              Globals.ratio = Globals.oldRatio;
                            }
                            // print("build");
                          }
                        } else if (index == 1) {
                          if (Globals.buildTextOutput &&
                              Globals.buildTextInput) {
                            Globals.buildTextOutput = false;
                            Globals.oldRatio = Globals.ratio;
                            Globals.ratio = 1;
                            // print("destroy");
                          } else {
                            Globals.buildTextOutput = true;
                            if (Globals.buildTextInput) {
                              Globals.ratio = Globals.oldRatio;
                            }
                            // print("build");
                          }
                        }
                        Globals.saveRatio();
                        setState(() {});
                      },
                      isSelected: [
                        Globals.buildTextInput,
                        Globals.buildTextOutput
                      ],
                    );
                  },
                ),
                IconButton(
                  tooltip: "Expand all songs",
                  icon: const Icon(Icons.unfold_more),
                  onPressed: () {
                    for (var key in Globals.tiles) {
                      key.currentState?.expand();
                    }
                    setState(() {});
                  },
                ),
                IconButton(
                  tooltip: "Collapse all songs",
                  icon: const Icon(Icons.unfold_less),
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
  final double _dividerWidth = 20;
  @override
  Widget build(BuildContext context) {
    var _totalWidth = MediaQuery.of(context).size.width;
    return Row(children: <Widget>[
      // if (_buildTextInput)
      Visibility(
        // duration: const Duration(milliseconds: 300),
        visible: Globals.buildTextInput,
        maintainState: true,
        child: SizedBox(
          width: (_totalWidth - _dividerWidth) * Globals.ratio,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              enableSuggestions: false,
              autocorrect: false,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                  label: Text(Globals.appBarTitle),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true),
              // expands: true,
              controller: Globals.controller,
              autofocus: true,
              maxLines: null,
              // onc: ,
              onChanged: (text) {
                Globals.saveRawText();
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
            Globals.ratio = 0.4;
            Globals.buildTextOutput = true;
            Globals.buildTextInput = true;
            _rebuildAppBar.value ^= true;
            Globals.saveRatio();
            setState(() {});
          },
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              Globals.ratio += details.delta.dx / _totalWidth;
            });
            if (Globals.ratio > .9) {
              Globals.ratio = 1;
              Globals.buildTextOutput = false;
            } else if (Globals.ratio < 0.1) {
              Globals.ratio = 0.0;
              Globals.buildTextInput = false;
              FocusScope.of(context).unfocus();
            }
            _rebuildAppBar.value ^= true;
            Globals.saveRatio();
          },
        ),
      ),
      Visibility(
        // key: UniqueKey(),
        visible: Globals.buildTextOutput,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        maintainInteractivity: true,
        child: SizedBox(
          width: (_totalWidth - _dividerWidth) * (1 - Globals.ratio),
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


