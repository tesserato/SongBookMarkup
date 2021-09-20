import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String _rawText = '''RAW
    # Song's title ("H1", generally for song title, line starting with "#")

## Artist's name ("H2, line starting with "##")
## Composer's name 

|comment (won't be rendered, line starting with "|")

|chord definitions
[0 4 x 2 5 0] A
[002420]A/B

|chord line, (line starting with ">")
>D                           D7 
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

final _controller = TextEditingController(text: _rawText);

var _darkTheme = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  // primaryColor: Colors.red,

  // Define the default font family.
  fontFamily: GoogleFonts.firaMono().fontFamily,

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  // textTheme: GoogleFonts.firaMonoTextTheme() ,
  textTheme: const TextTheme(
    headline1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    headline2: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
    bodyText1: TextStyle(fontSize: 16.0),
    bodyText2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
  ),
);

bool _buildTextInput = true;
bool _buildTextOutput = true;

double _ratio = 0.5;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: _darkTheme,
        title: "Mark Book",
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
                      ToggleButtons(
                        children: const <Widget>[
                          Icon(Icons.text_fields),
                          Icon(Icons.text_snippet),
                        ],
                        onPressed: (int index) {
                          if (index == 0) {
                            if (_buildTextOutput && _buildTextInput) {
                              _buildTextInput = false;
                              _rebuildTextWidgets.value ^= true;
                              print("destroy");
                            } else {
                              _buildTextInput = true;
                              _rebuildTextWidgets.value ^= true;
                              print("build");
                            }
                          }

                          if (index == 1) {
                            if (_buildTextOutput && _buildTextInput) {
                              _buildTextOutput = false;
                              _rebuildTextWidgets.value ^= true;
                              _ratio = 1;
                              print("destroy");
                            } else {
                              _buildTextOutput = true;
                              _rebuildTextWidgets.value ^= true;
                              _ratio = .5;
                              print("build");
                            }
                          }
                        },
                        isSelected: [_buildTextInput, _buildTextOutput],
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
  // String text = rawText;

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
      GestureDetector(
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
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            _ratio += details.delta.dx / _totalWidth;
            if (_ratio > 1) {
              _ratio = 1;
            } else if (_ratio < 0.0) {
              _ratio = 0.0;
            }
          });
        },
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

  for (var rawLine in rawText.split("\n")) {
    String rawLineTrimmed = rawLine.trim();

    if (rawLineTrimmed.isEmpty) {
      continue;
    }

    if (rawLineTrimmed.startsWith("|")) {
      continue;
    }

    if (rawLineTrimmed.startsWith("#")) {
      if (rawLineTrimmed.length > 1 && rawLineTrimmed[1] == "#") {
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
      W.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 18.0),
        child: RichText(
            overflow: TextOverflow.visible,
            text: TextSpan(
                text: rawLineTrimmed.substring(1),
                style: _darkTheme.textTheme.headline1)),
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
            // left chord
            // print("$i]");
            end = i;
            R.add(Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 1.0, 0.0),
              child: ChordWidget(rawLine.substring(start, end)),
            ));
          }
          insideChord = false;
        } else {
          if (!insideChord) {
            //entered chord
            // print("[$i");
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
  ChordWidget(this.name, {Key? key}) : super(key: key);

  @override
  State<ChordWidget> createState() => _ChordWidgetState();
}

class _ChordWidgetState extends State<ChordWidget> {
  bool _hovering = false;
  bool _toggle = false;

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
                    width: 60,
                    height: 80,
                    color: Colors.yellow,
                    child: CustomPaint(
                      // size: Size(20, 30),
                      painter: MyPainter(),
                      // child: const SizedBox(width: 60, height: 80)
                    ),
                  ),
                ))
          ],
        ));
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.butt;
    for (var i = 0; i < 6; i++) {
      var x = i * size.width / 5;
      Offset startingPoint = Offset(x, 0);
      Offset endingPoint = Offset(x, size.height);
      canvas.drawLine(startingPoint, endingPoint, paint);
    }

    for (var i = 0; i < 6; i++) {
      var y = i * size.height / 5;
      Offset startingPoint = Offset(0, y);
      Offset endingPoint = Offset(size.width, y);
      canvas.drawLine(startingPoint, endingPoint, paint);
    }
    // canvas.drawCircle(Offset(size.width, size.height), 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
