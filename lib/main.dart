import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:mark_book/widgets/editor.dart';
// import 'package:rich_text_controller/rich_text_controller.dart';
// import 'package:clairvoyant/widgets/editor.dart';
// import 'package:provider/provider.dart';
// import 'package:clairvoyant/models/song.dart';

// final _rawText = ValueNotifier('''hardcoded
// # Song's title ("H1", generally for song title, line starting with "#")

// ## Artist's name ("H2, line starting with "##")
// ## Composer's name

// |comment (won't be rendered, line starting with "|")

// |chord definitions
// [0 4 x 2 5 0] A
// [002420]A/B

// |chord line, (line starting with ">")
// >D                           D7''');
String _rawText = "ini";

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Mark Book",
        home: Scaffold(
            appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.folder_open_outlined),
                    tooltip: 'Open song book (*.sb)',
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['mb'],
                      );
                      // String? path = result;

                      if (result != null) {
                        // var fileBytes = result.files.first.bytes;
                        var fileName = result.files.first.name;
                        Future<String> _read() async {
                          String text = "";
                          try {
                            // final Directory directory =
                            // await getApplicationDocumentsDirectory();
                            final File file = File(fileName);
                            text = await file.readAsString();
                          } catch (e) {
                            print("Couldn't read file");
                          }
                          return text;
                        }

                        _rawText = await _read();

                        setState(() {});
                      } else {
                        // User canceled the picker
                      }
                    }),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.add_alert),
                    tooltip: 'Show Snackbar',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('This is a snackbar')));
                    },
                  ),
                ]),
            body: const Home()));
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

// var t =

class HomeState extends State<Home> {
  // String text = rawText;
  double _ratio = 0.5;
  final double _dividerWidth = 10;

  @override
  Widget build(BuildContext context) {
    var _totalWidth = MediaQuery.of(context).size.width;
    final _controller = TextEditingController(text: _rawText);

    return Row(children: <Widget>[
      SizedBox(
        width: (_totalWidth - _dividerWidth) * _ratio,
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
          onChanged: (text) {
            setState(() {
              
            });
            // _rawText = text;
          },
        ),
      ),
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.yellow,
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
      SizedBox(
        width: (_totalWidth - _dividerWidth) * (1 - _ratio),
        child: Container(
            // decoration: Decoration(),
            child: processText(_controller.text)),
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
      /// comment
      // W.add(RichText(
      //     text: const TextSpan(
      //         text: '\n',
      //         style:
      //             TextStyle(fontWeight: FontWeight.bold, color: Colors.red))));
      continue;
    }

    if (rawLineTrimmed.startsWith("#")) {
      if (rawLineTrimmed.length > 1 && rawLineTrimmed[1] == "#") {
        W.add(RichText(
            text: TextSpan(
                text: rawLineTrimmed.substring(2),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green))));
        continue;
      }
      W.add(RichText(
          text: TextSpan(
              text: rawLineTrimmed.substring(1),
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.red))));
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
            R.add(ChordWidget(rawLine.substring(start, end)));
          }
          insideChord = false;
        } else {
          if (!insideChord) {
            //entered chord
            // print("[$i");
            start = i;
            R.add(
                RichText(text: TextSpan(text: ''.padRight(start - end, ' '))));
          }
          insideChord = true;
        }
      }
      W.add(Row(children: R));
      continue;
    }

    W.add(RichText(
        text: TextSpan(
      text: rawLine,
      // style: TextStyle(
      //     fontWeight: FontWeight.bold, color: Colors.red)
    )));
  }

  return ListView(
    children: W,
    // crossAxisAlignment: CrossAxisAlignment.start,
  );
}

class ChordWidget extends StatefulWidget {
  String name = "";
  ChordWidget(this.name, {Key? key}) : super(key: key);

  @override
  State<ChordWidget> createState() => _ChordWidgetState();
}

class _ChordWidgetState extends State<ChordWidget> {
  var _overText = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (value) {
          setState(() {
            _overText = true;
          });
        },
        onExit: (value) {
          setState(() {
            _overText = false;
          });
        },
        child: Stack(
          fit: StackFit.passthrough,
          alignment: AlignmentDirectional.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Text(
              widget.name,
              textWidthBasis: TextWidthBasis.longestLine,
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
                  visible: _overText,
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// String rawText = '''hardcoded
// # Song's title ("H1", generally for song title, line starting with "#")

// ## Artist's name ("H2, line starting with "##")
// ## Composer's name

// |comment (won't be rendered, line starting with "|")

// |chord definitions
// [0 4 x 2 5 0] A
// [002420]A/B

// |chord line, (line starting with ">")
// >D                           D7
// |text line
// There is a house down in New Orleans
// >    G               D
// They call the Rising Sun
// >D                           G
// And it's been the ruin of a many poor boy
// >     D       A          D
// And me, oh God , for one

// >D                        D7
// Then fill the glasses to the brim
// >        G                   D
// Let the drinks go merrily around
// >D                                  G
// And we'll drink to the health of a rounder poor boy
// >    D         A7       D
// Who goes from town to town
// ''';
