import 'package:flutter/material.dart';
import '../models/chords.dart';
import '../models/globals.dart' as Globals;

class Output extends StatefulWidget {
  final String rawText;
  // Map<Key, bool> expand = {};
  Output(this.rawText, {Key? key}) : super(key: key);

  @override
  _OutputState createState() => _OutputState();
}

class _OutputState extends State<Output> {
  List<Widget> expansionPanels = [];
  List<Widget> currentWidgets = [];
  String? currentChordLine;
  Map<String, List<int>> chordNameToFingering = {};
  String currentSongTitle = "";

  @override
  Widget build(BuildContext context) {
    for (var rawLine in widget.rawText.split("\n") + ["!"]) {
      String rawLineTrimmed = rawLine.trim();

      if (rawLineTrimmed.isEmpty || rawLineTrimmed.startsWith("|")) {
        continue;
      }

      if (rawLineTrimmed.startsWith("!")) {
        if (currentWidgets.isEmpty) {
          currentSongTitle = rawLineTrimmed.substring(1);
        } else {
          final e = SongTile(currentSongTitle, currentWidgets);
          currentWidgets = [];
          chordNameToFingering = {};
          expansionPanels.add(e);
        }
        continue;
      }

      if (rawLineTrimmed.startsWith("[")) {
        List<int> fingering = [];
        // int i = 0;
        List<String> rawFingering = rawLineTrimmed.split("]");
        String name = rawFingering.last.trim();
        rawFingering = rawFingering.first
            .replaceAll("[", "")
            .replaceAll(",", " ")
            .replaceAll(";", " ")
            .split(" ");
        if (rawFingering.length <= 1) {
          rawFingering = rawLineTrimmed.split("");
        }
        for (var item in rawFingering) {
          if (item.toLowerCase() == "x") {
            fingering.add(-1);
          } else {
            int? fret = int.tryParse(item);
            if (fret != null) {
              fingering.add(fret);
            }
          }
        }
        chordNameToFingering[name] = fingering;
        continue;
      }

      if (rawLineTrimmed.startsWith("#")) {
        currentWidgets.add(Container(
          color: Colors.black,
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
          width: double.infinity,
          child: RichText(
              overflow: TextOverflow.visible,
              text: TextSpan(
                text: rawLineTrimmed.substring(1),
                // style: _darkTheme.textTheme.headline2
              )),
        ));
        continue;
      }

      if (rawLineTrimmed.startsWith(">")) {
        if (currentChordLine == null) {
          currentChordLine = " " + rawLineTrimmed.substring(1);
        } else {
          currentWidgets.addAll(
              makeChordsLine(chordNameToFingering, chords: currentChordLine));
          currentChordLine = " " + rawLineTrimmed.substring(1);
          ;
        }

        continue;
      }

      currentWidgets.addAll(makeChordsLine(chordNameToFingering,
          text: rawLine, chords: currentChordLine));
      currentChordLine = null;
    }
    return ListView(
      // mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: expansionPanels,
    );
  }
}

class SongTile extends StatefulWidget {
  String title = "";
  List<Widget> children = [];
  // Map<Key, bool> expanded = {};
  SongTile(this.title, this.children, {Key? key})
      : super(key: key);

  @override
  _SongTileState createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      // key: UniqueKey(),
      initiallyExpanded: Globals.expanded[widget.key] ?? true,
      title: RichText(
          overflow: TextOverflow.visible,
          text: TextSpan(
            text: widget.title,
            // style: context._darkTheme.textTheme.headline1
          )),
      children: [
        Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: widget.children)
      ],
      onExpansionChanged: (e) {
        Globals.expanded[widget.key ?? UniqueKey()] = e;
      },
    );
  }
}

// Widget processText(String rawText) {
//   List<ExpansionTile> expansionPanels = [];
//   List<Widget> currentWidgets = [];
//   String? currentChordLine;
//   Map<String, List<int>> chordNameToFingering = {};
//   String currentSongTitle = "";
//   for (var rawLine in rawText.split("\n") + ["!"]) {
//     String rawLineTrimmed = rawLine.trim();

//     if (rawLineTrimmed.isEmpty || rawLineTrimmed.startsWith("|")) {
//       continue;
//     }

//     if (rawLineTrimmed.startsWith("!")) {
//       if (currentWidgets.isEmpty) {
//         currentSongTitle = rawLineTrimmed.substring(1);
//       } else {
//         final e = ExpansionTile(
//           // key: UniqueKey(),
//           initiallyExpanded: _expandedTiles,
//           maintainState: true,
//           title: RichText(
//               overflow: TextOverflow.visible,
//               text: TextSpan(
//                   text: currentSongTitle,
//                   style: _darkTheme.textTheme.headline1)),
//           children: [
//             Wrap(
//                 crossAxisAlignment: WrapCrossAlignment.end,
//                 children: currentWidgets)
//           ],
//         );
//         currentWidgets = [];
//         chordNameToFingering = {};
//         expansionPanels.add(e);
//       }
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
//       chordNameToFingering[name] = fingering;
//       continue;
//     }

//     if (rawLineTrimmed.startsWith("#")) {
//       currentWidgets.add(Container(
//         color: Colors.black,
//         margin: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
//         width: double.infinity,
//         child: RichText(
//             overflow: TextOverflow.visible,
//             text: TextSpan(
//                 text: rawLineTrimmed.substring(1),
//                 style: _darkTheme.textTheme.headline2)),
//       ));
//       continue;
//     }

//     if (rawLineTrimmed.startsWith(">")) {
//       if (currentChordLine == null) {
//         currentChordLine = " " + rawLineTrimmed.substring(1);
//       } else {
//         currentWidgets.addAll(
//             makeChordsLine(chordNameToFingering, chords: currentChordLine));
//         currentChordLine = " " + rawLineTrimmed.substring(1);
//         ;
//       }

//       continue;
//     }

//     currentWidgets.addAll(makeChordsLine(chordNameToFingering,
//         text: rawLine, chords: currentChordLine));
//     currentChordLine = null;
//   }

//   return ListView(
//     // mainAxisSize: MainAxisSize.min,
//     // crossAxisAlignment: CrossAxisAlignment.start,
//     children: expansionPanels,
//   );
// }

List<Widget> makeChordsLine(Map<String, List<int>> chordNameToFingering,
    {String? chords, String? text}) {
  List<Widget> W = [];
  if (chords == null) {
    final words = text!.split(" ") + [" "];
    for (var word in words) {
      Widget w = RichText(
          overflow: TextOverflow.visible,
          text: TextSpan(
            text: word,
            // style: _darkTheme.textTheme.headline1
          ));
      W.add(w);
    }
    return W;
  }
  if (text == null) {
    final chordNames = chords.split(" ") + [" "];
    for (var name in chordNames) {
      final fingering = chordNameToFingering[name];
      W.add(
        ChordWidget(name, fingering: fingering),
      );
    }
    return W;
  }

  if (text.length < chords.length) {
    text = text.padRight(chords.length, ' ');
  }

  chords += " ";
  bool insideChord = false;
  int start = 0;
  int end = 0;
  for (var i = 0; i < chords.length; i++) {
    if (chords[i] == " ") {
      if (insideChord) {
        // left chord name
        end = i;
        final name = chords.substring(start, end);
        final fingering = chordNameToFingering[name];
        var r = Column(
          children: [
            ChordWidget(name, fingering: fingering),
            RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: text.substring(start, end),
                  // style: _darkTheme.textTheme.bodyText2
                ))
          ],
        );
        W.add(r);
      }
      insideChord = false;
    } else {
      if (!insideChord) {
        //entered chord name
        start = i;
        W.add(RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: text.substring(end, start),
              // style: _darkTheme.textTheme.bodyText2
            )));
      }
      insideChord = true;
    }
  }
  W.add(RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: text.substring(end, text.length),
        // style: _darkTheme.textTheme.bodyText2
      )));
  return W;
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
                text: widget.name,
                // style: _darkTheme.textTheme.bodyText2
              ),
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
