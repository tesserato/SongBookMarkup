import 'package:flutter/material.dart';
import '../models/chords.dart';
import '../models/globals.dart' as Globals;
import '../widgets/custom_expansion_tile.dart';

class Output extends StatefulWidget {
  // Map<Key, bool> expand = {};
  Output({Key? key}) : super(key: key);

  @override
  _OutputState createState() => _OutputState();
}

class _OutputState extends State<Output> {
  List<Widget> currentWidgets = [];
  String? currentChordLine;
  Map<String, List<int>> chordNameToFingering = {};
  String currentSongTitle = "";
  // static Map<int, bool> isExpanded = {};

  @override
  Widget build(BuildContext context) {
    List<Widget> expansionPanels = [];
    int counter = 0;
    for (var rawLine in Globals.controller.text.split("\n") + ["!"]) {
      String rawLineTrimmed = rawLine.trim();

      if (rawLineTrimmed.isEmpty || rawLineTrimmed.startsWith("|")) {
        continue;
      }

      if (rawLineTrimmed.startsWith("!")) {
        if (currentWidgets.isEmpty) {
          currentSongTitle = rawLineTrimmed.substring(1);
        } else {
          expansionPanels
              .add(EpWrapper(counter, currentSongTitle, currentWidgets));
          counter++;
          currentWidgets = [];
          chordNameToFingering = {};
          currentSongTitle = rawLineTrimmed.substring(1);
        }
        continue;
      }

      if (rawLineTrimmed.startsWith("[")) {
        List<int> fingering = [];
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
          // color: Theme.of(context).colorScheme.primaryVariant,
          margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          width: double.infinity,
          child: RichText(
              // textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              text: TextSpan(
                text: rawLineTrimmed.substring(1),
                style: Theme.of(context).textTheme.headline2,
              )),
        ));
        continue;
      }

      if (rawLineTrimmed.startsWith(">")) {
        if (currentChordLine == null) {
          currentChordLine = " " + rawLineTrimmed.substring(1);
        } else {
          currentWidgets.addAll(makeChordsLine(context, chordNameToFingering,
              chords: currentChordLine));
          currentChordLine = " " + rawLineTrimmed.substring(1);
        }

        continue;
      }

      currentWidgets.addAll(makeChordsLine(context, chordNameToFingering,
          text: rawLine, chords: currentChordLine));
      currentChordLine = null;
    }

    return ListView(children: expansionPanels);
  }
}

class EpWrapper extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final int index;

  const EpWrapper(this.index, this.title, this.children, {Key? key})
      : super(key: key);

  @override
  _EpWrapperState createState() => _EpWrapperState();
}

class _EpWrapperState extends State<EpWrapper> {
  late GlobalKey<CustomExpansionTileState> _key;

  @override
  void initState() {
    _key = GlobalKey();
    Globals.tiles.add(_key);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomExpansionTile(
        index: widget.index,
        key: _key,
        initiallyExpanded: true,
        title: RichText(
            overflow: TextOverflow.visible,
            text: TextSpan(
                text: widget.title,
                style: Theme.of(context).textTheme.headline1)),
        children: [
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: widget.children)
        ]);
  }
}

List<Widget> makeChordsLine(
    BuildContext context, Map<String, List<int>> chordNameToFingering,
    {String? chords, String? text}) {
  List<Widget> W = [];
  if (chords == null) {
    final words = text!.split(" ") + [" "];
    for (var word in words) {
      Widget w = RichText(
          overflow: TextOverflow.visible,
          text: TextSpan(
            text: word,
            style: Theme.of(context).textTheme.bodyText2
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
                    style: Theme.of(context).textTheme.bodyText2))
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
                style: Theme.of(context).textTheme.bodyText2)));
      }
      insideChord = true;
    }
  }
  W.add(RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: text.substring(end, text.length),
        style: Theme.of(context).textTheme.bodyText2
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
                  style: Theme.of(context).textTheme.headline3),
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
                            MyPainter(context, widget.name, fingering: widget.fingering),
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
  BuildContext context;          
  MyPainter(this.context, this.name, {this.fingering});

  @override
  void paint(Canvas canvas, Size size) {
    TextStyle? textStyle = Theme.of(context).textTheme.headline4;
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

    TextSpan textSpan = TextSpan(
        text: minfret.toString(), style: textStyle);
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

        textSpan = TextSpan(
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
