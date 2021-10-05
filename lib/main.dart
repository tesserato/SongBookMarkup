import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/chords.dart';

String _rawText = '''RAW
! Song's title ("H1", generally for song title, line starting with "#")

## Artist's name ("H2, line starting with "##")
## Composer's name 

|comment (won't be rendered, line starting with "|")

|chord definitions
[0 4 x 2 5 0] A
[002420]A/B

|chord line, (line starting with ">")
>A                           D7 
|text line
There is a house down in New Orleans 
>    G               D 
They call the Rising Sun  
>D                           G 
And it's been the ruin of a many poor boy 
>     D       A          D 
And me, oh God , for one 
 
>D                        D7 
Then fill the glasses to the brim 
>        G                   D 
Let the drinks go merrily around 
>D                                  G 
And we'll drink to the health of a rounder poor boy 
>    D         A7       D 
Who goes from town to town 
''';

ValueNotifier<bool> _rebuildTextWidgets = ValueNotifier(false);
ValueNotifier<bool> _rebuildAppBar = ValueNotifier(false);

final _controller = TextEditingController(text: _rawText);

double _fontSize = 16.0;
double _fontFactor = 1.3;

var _inputStyle = TextStyle(fontFamily: GoogleFonts.firaCode().fontFamily,fontSize:_fontSize);

var _darkTheme = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  // primaryColor: Colors.red,

  // Define the default font family.
  fontFamily: GoogleFonts.cutiveMono().fontFamily,

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  // textTheme: GoogleFonts.firaMonoTextTheme() ,
  textTheme: TextTheme(
    headline1: TextStyle(fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w900),
    headline2: TextStyle(fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w500),
    bodyText1: TextStyle(fontSize: _fontFactor * _fontSize),
    bodyText2: TextStyle(fontSize: _fontFactor * _fontSize, fontWeight: FontWeight.w300),
  ),
);

bool _buildTextInput = true;
bool _buildTextOutput = true;

double _ratio = 0.5;

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

class _MyAppState extends State<MyApp> {
  var _oldRatio = 0.5;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: _darkTheme,
        title: "MarkBook",
        home: Scaffold(
            appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
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
                              _rebuildTextWidgets.value = true;
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
                                  _rebuildTextWidgets.value ^= true;
                                  _oldRatio = _ratio;
                                  _ratio = 0;
                                  print("destroy");
                                } else {
                                  _buildTextInput = true;
                                  _rebuildTextWidgets.value ^= true;
                                  _ratio = _oldRatio;
                                  print("build");
                                }
                              }

                              if (index == 1) {
                                if (_buildTextOutput && _buildTextInput) {
                                  _buildTextOutput = false;
                                  _rebuildTextWidgets.value ^= true;
                                  _oldRatio = _ratio;
                                  _ratio = 1;
                                  print("destroy");
                                } else {
                                  _buildTextOutput = true;
                                  _rebuildTextWidgets.value ^= true;
                                  _ratio = _oldRatio;
                                  print("build");
                                }
                              }
                              setState(() {});
                            },
                            isSelected: [_buildTextInput, _buildTextOutput],
                          );
                        },
                      ),
                    ]),
                actions: const []),
            body: ValueListenableBuilder(
                valueListenable: _rebuildTextWidgets,
                builder: (context, hasError, child) {
                  return Home();
                })));
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

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
      if (_buildTextInput)
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
            _buildTextOutput = true;
            _buildTextInput = true;
            _rebuildAppBar.value ^= true;
            setState(() {});
          },
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              _ratio += details.delta.dx / _totalWidth;
              if (_ratio > .9) {
                _ratio = 1;
                _buildTextOutput = false;
                setState(() {});
                _rebuildAppBar.value ^= true;
              } else if (_ratio < 0.1) {
                _ratio = 0.0;
                _buildTextInput = false;
                setState(() {});
                _rebuildAppBar.value ^= true;
              }
            });
          },
        ),
      ),
      if (_buildTextOutput)
        SizedBox(
          width: (_totalWidth - _dividerWidth) * (1 - _ratio),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: processText(_controller.text),
          ),
        ),
    ]);
  }
}

Widget processText(String rawText) {
  List<Widget> W = [];
  // int numberOfSongs = 0;
  Map<String, List<int>> chordNameToFingering = Map();

  for (var rawLine in rawText.split("\n")) {
    String rawLineTrimmed = rawLine.trim();

    if (rawLineTrimmed.isEmpty) {
      continue;
    }

    if (rawLineTrimmed.startsWith("|")) {
      continue;
    }

    if (rawLineTrimmed.startsWith("!")) {
      // new song
      W.add(Padding(
        // add song title text
        padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 18.0),
        child: RichText(
            overflow: TextOverflow.visible,
            text: TextSpan(
                text: rawLineTrimmed.substring(1),
                style: _darkTheme.textTheme.headline1)),
      ));
      continue;
    }

    if (rawLineTrimmed.startsWith("[")) {
      List<int> fingering = [];
      int i = 0;
      while (i < rawLineTrimmed.length && rawLineTrimmed[i] != "]") {
        i++;
        if (rawLineTrimmed[i].toLowerCase() == "x") {
          fingering.add(-1);
        } else {
          int? fret = int.tryParse(rawLineTrimmed[i]);
          if (fret != null) {
            fingering.add(fret);
          }
        }
      }
      String name = rawLineTrimmed.substring(i + 1).trim();
      chordNameToFingering[name] = fingering;
      print("$name  $fingering");
      continue;
    }

    if (rawLineTrimmed.startsWith("#")) {
      W.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 17.0, 0.0, 17.0),
        child: RichText(
            overflow: TextOverflow.visible,
            text: TextSpan(
                text: rawLineTrimmed.substring(2),
                style: _darkTheme.textTheme.headline2)),
      ));
      continue;
    }

    if (rawLineTrimmed.startsWith(">")) {
      List<Widget> R = [];
      bool insideChord = false;
      rawLineTrimmed += " ";
      int start = 0;
      int end = 0;
      for (var i = 1; i < rawLineTrimmed.length; i++) {
        if (rawLineTrimmed[i] == " ") {
          if (insideChord) {
            // left chord name
            end = i;
            final name = rawLine.substring(start, end);
            final fingering = chordNameToFingering[name];
            R.add(Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 1.0, 0.0),
              child: ChordWidget(name, fingering: fingering),
            ));
          }
          insideChord = false;
        } else {
          if (!insideChord) {
            //entered chord name
            start = i;
            R.add(RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: ''.padRight(start - end, ' '),
                    style: _darkTheme.textTheme.bodyText2)));
          }
          insideChord = true;
        }
      }
      W.add(Row(children: R));
      continue;
    }

    W.add(RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(text: rawLine, style: _darkTheme.textTheme.bodyText1)));
  }

  return ListView(
    // mainAxisSize: MainAxisSize.min,
    // crossAxisAlignment: CrossAxisAlignment.start,
    children: W,
  );
}

class ChordWidget extends StatefulWidget {
  String name = "";
  List<int>? fingering;
  ChordWidget(this.name, {Key? key, this.fingering}) : super(key: key);

  @override
  State<ChordWidget> createState() => _ChordWidgetState();
}

class _ChordWidgetState extends State<ChordWidget> {
  bool _hovering = false;
  bool _toggle = false;
  // Color backgroun =

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onHover: (value) {
          if (value) {
            setState(() {
              _hovering = true;
            });
          } else {
            setState(() {
              _hovering = false;
            });
          }
        },
        onTap: () {
          if (_toggle) {
            setState(() {
              _toggle = false;
            });
          } else {
            setState(() {
              _toggle = true;
            });
          }
        },
        child: Stack(
          fit: StackFit.passthrough,
          alignment: AlignmentDirectional.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            RichText(
              overflow: TextOverflow.clip,
              text: TextSpan(
                  text: widget.name, style: _darkTheme.textTheme.bodyText2),
            ),
            Positioned(
                top: -80,
                left: 0,
                // height: 80,
                // width: 60,
                child: Visibility(
                  // replacement: Text("chh"),
                  // maintainState: true,
                  // maintainAnimation: true,
                  // maintainSize: true,
                  // maintainInteractivity: true,
                  visible: _hovering || _toggle,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: const Color.fromARGB(200, 255, 255, 255),
                    padding: const EdgeInsets.fromLTRB(23, 12, 9, 6),
                    child: Container(
                      width: 60,
                      height: 80,
                      color: Colors.transparent,
                      child: CustomPaint(
                        // size: Size(20, 30),
                        painter:
                            MyPainter(widget.name, fingering: widget.fingering),
                        // child: const SizedBox(width: 60, height: 80)
                      ),
                    ),
                  ),
                ))
          ],
        ));
  }
}

class MyPainter extends CustomPainter {
  String name;
  List<int>? fingering;
  MyPainter(this.name, {this.fingering});

  @override
  void paint(Canvas canvas, Size size) {
    Chord chord = Chord.fromName(name);
    fingering ??= chord.getFingering();
    int minfret = 100;
    int maxfret = 0;
    int numberOfFrets = 6;
    int numberOfStrings = 6;

    for (var fret in fingering!) {
      if (fret > 0) {
        if (fret > maxfret) {
          maxfret = fret;
        }
        if (fret < minfret) {
          minfret = fret;
        }
      }
    }
    if ((maxfret - minfret) >= numberOfFrets) {
      numberOfFrets = maxfret - minfret + 1;
    }
    if (maxfret < numberOfFrets) {
      minfret = 0;
    }

    const textStyle = TextStyle(
        color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
    TextSpan textSpan = TextSpan(
      text: minfret.toString(),
      style: textStyle,
    );
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 20,
    );

    final offset = Offset(-22, -textPainter.height / 2);
    textPainter.paint(canvas, offset);

    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.butt;

    for (var i = 0; i < numberOfFrets; i++) {
      var y = i * size.height / (numberOfFrets - 1);
      Offset startingPoint = Offset(0, y);
      Offset endingPoint = Offset(size.width, y);
      canvas.drawLine(startingPoint, endingPoint, paint);
    }

    for (var i = 0; i < numberOfStrings; i++) {
      var x = i * size.width / (numberOfStrings - 1);
      Offset startingPoint = Offset(x, 0);
      Offset endingPoint = Offset(x, size.height);
      canvas.drawLine(startingPoint, endingPoint, paint);
      if (fingering![i] > 0) {
        canvas.drawCircle(
            Offset(
                i * size.width / (numberOfStrings - 1),
                (fingering![i] - minfret) * size.height / (numberOfFrets - 1) -
                    size.height / 15),
            size.width / 15,
            paint);
      } else if (fingering![i] < 0) {
        const textStyle = TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900);

        textSpan = const TextSpan(
          text: "x",
          style: textStyle,
        );
        TextPainter textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(
          // minWidth: size.width,
          maxWidth: 0,
        );

        final xCenter = i * size.width / (numberOfStrings - 1);
        final yCenter = -size.height / 15 - textPainter.height / 2;
        final offset = Offset(xCenter, yCenter);
        textPainter.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
