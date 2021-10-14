import 'package:flutter/material.dart';
import 'package:mark_book/theme/custom_theme.dart';
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
          currentChordLine = rawLine.replaceFirst(">", " ");
        } else {
          currentWidgets.addAll(makeChordsLine(context, chordNameToFingering,
              chords: currentChordLine));
          currentChordLine = rawLine.replaceFirst(">", " ");
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
              // runSpacing: outputFontSize,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: widget.children)
        ]);
  }
}

List<Widget> makeChordsLine(
    BuildContext context, Map<String, List<int>> chordNameToFingering,
    {String? chords, String? text}) {
  // final chords = rawChords?.codeUnits;
  // final text = rawChords?.codeUnits;

  List<Widget> W = [];

  // var t = Theme.of(context).textTheme.headline1?.copyWith(color: Theme.of(context).colorScheme.primary);

  if (Globals.showLineStart) {
    var txt =
        Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary);

    // Text("❯",
    //     style: Theme.of(context)
    //         .textTheme
    //         .headline1
    //         ?.copyWith(color: Theme.of(context).colorScheme.primary));
    W.add(Container(
        alignment: Alignment.centerRight,
        // color: Colors.amber.withOpacity(.5),
        width: 1.5 * Globals.outputFontSize,
        height: Globals.outputFontSize * 2.5,
        padding: EdgeInsets.fromLTRB(0, 0, Globals.outputFontSize / 3, 0),
        child: txt));
  }

  if (chords == null) {
    final words = text!.split(" ");
    for (var word in words) {
      Widget w = RichText(
          overflow: TextOverflow.visible,
          text: TextSpan(
              text: word.trim(), style: Theme.of(context).textTheme.bodyText2));
      W.add(w);

      W.add(SizedBox(
        width: Globals.outputFontSize / 2,
      ));
    }
    return W;
  }
  if (text == null) {
    final chordNames = chords.split(" ");
    for (var name in chordNames) {
      final trimmedName = name.trim();
      if (trimmedName.isNotEmpty) {
        final fingering = chordNameToFingering[trimmedName];
        W.add(
          ChordWidget("  ".padRight(trimmedName.length), trimmedName,
              fingering: fingering),
        );
        W.add(SizedBox(
          width: Globals.outputFontSize,
        ));
      }
    }
    return W;
  }
  // chords + text

  chords += " ";
  if (text.length < chords.length) {
    text = text.padRight(chords.length + 1, ' ');
  }

  bool insideChord = false;
  int start = 0;
  int end = 0;
  for (var i = 0; i < chords.length; i++) {
    if (chords[i] == " ") {
      if (insideChord) {
        // left chord name
        insideChord = false;
        end = i;
        final name = chords.substring(start, end);
        final fingering = chordNameToFingering[name];
        W.add(ChordWidget(text.substring(start, end), name,
            fingering: fingering));
      }
    } else {
      if (!insideChord) {
        //entered chord name
        insideChord = true;
        start = i;
        var words = text.substring(end, start).split(" ");
        if (words.isNotEmpty) {
          for (var word in words) {
            if (word != " ") {
              W.add(Text(word, style: Theme.of(context).textTheme.bodyText2));
              W.add(SizedBox(
                width: Globals.outputFontSize / 2,
              ));
            }
          }
          W.removeLast();
        }
      }
    }
  }
  // W.add(RichText(
  //     overflow: TextOverflow.ellipsis,
  //     text: TextSpan(
  //         text: text.substring(end, text.length),
  //         style: Theme.of(context).textTheme.bodyText2)));

  var words = text.substring(end, text.length).split(" ");
  if (words.isNotEmpty) {
    for (var word in words) {
      if (word != " ") {
        W.add(RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                text: word, style: Theme.of(context).textTheme.bodyText2)));
        W.add(SizedBox(
          width: Globals.outputFontSize / 2,
        ));
      }
    }
    W.removeLast();
  }

  return W;
}

class ChordWidget extends StatefulWidget {
  String text = "";
  String name = "";
  List<int>? fingering;
  ChordWidget(this.text, this.name, {Key? key, this.fingering})
      : super(key: key);

  @override
  State<ChordWidget> createState() => _ChordWidgetState();
}

class _ChordWidgetState extends State<ChordWidget> {
  bool _hovering = false;
  bool _toggle = false;
  // Color backgroun =

  @override
  Widget build(BuildContext context) {
    var txt = Text(widget.text, style: Theme.of(context).textTheme.bodyText2);
    var crd = Text(widget.name, style: Theme.of(context).textTheme.headline3);

    var szb = InkWell(
      child: Container(
        // alignment: Alignment.bottomCenter,
        // color: Colors.green.withOpacity(.5),
        // width: .6*outputFontSize * max(widget.text.length, widget.name.length),
        height: Globals.outputFontSize * 2.3,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [txt]),
      ),
      onTap: () {
        setState(() {
          _toggle = !_toggle;
        });
      },
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
    );

    return Stack(
      fit: StackFit.loose,
      alignment: AlignmentDirectional.bottomStart,
      clipBehavior: Clip.none,
      children: [
        // txt,
        Positioned(
          top: -Globals.outputFontSize * .2,
          child: crd,
        ),
        szb,
        Positioned(
            top: -Globals.outputFontSize/4 - Globals.chordPanelSize * 5, // height
            left: 0,
            child: Visibility(
              visible: _hovering || _toggle,
              child: IgnorePointer(
                child: Container(
                  width: Globals.chordPanelSize * 5,
                  height: Globals.chordPanelSize * 5,
                  color: Globals.themeMode == ThemeMode.dark
                      ? Colors.black.withAlpha(200)
                      : Colors.white.withAlpha(200),
                  padding: EdgeInsets.fromLTRB(
                      Globals.chordPanelSize * 1.8,
                      Globals.chordPanelSize,
                      Globals.chordPanelSize / 4,
                      Globals.chordPanelSize / 6),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    // color: Colors.amber,
                    child: CustomPaint(
                      // size: Size(20, 30),
                      painter: MyPainter(context, widget.name,
                          fingering: widget.fingering),
                      // child: const SizedBox(width: 60, height: 80)
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
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

    TextSpan textSpan = TextSpan(text: minfret.toString(), style: textStyle);
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: Globals.chordPanelSize,
    );

    final offset = Offset(-textPainter.width * 1.6, -textPainter.height / 2);
    textPainter.paint(canvas, offset);

    var circlePaint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.butt
      ..color =
          Globals.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    var linePaint = Paint()
      ..strokeWidth = Globals.chordPanelSize / 10
      ..strokeCap = StrokeCap.round
      ..color =
          Globals.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    for (var i = 0; i < numberOfFrets; i++) {
      var y = i * size.height / (numberOfFrets - 1);
      Offset startingPoint = Offset(0, y);
      Offset endingPoint = Offset(size.width, y);
      canvas.drawLine(startingPoint, endingPoint, circlePaint);
    }

    for (var i = 0; i < numberOfStrings; i++) {
      final x = i * size.width / (numberOfStrings - 1);
      final r = size.width / 15;
      Offset startingPoint = Offset(x, 0);
      Offset endingPoint = Offset(x, size.height);
      canvas.drawLine(startingPoint, endingPoint, circlePaint);
      final y =
          (fingering![i] - minfret) * size.height / (numberOfFrets - 1) - r;
      if (fingering![i] > 0) {
        canvas.drawCircle(Offset(x, y), r, circlePaint);
      } else if (fingering![i] < 0) {
        var p1 = Offset(x - r, 0);
        var p2 = Offset(x + r, y + 2 * r);
        canvas.drawLine(p1, p2, linePaint);
        p1 = Offset(x + r, 0);
        p2 = Offset(x - r, y + 2 * r);
        canvas.drawLine(p1, p2, linePaint);
        // textSpan = TextSpan(
        //   text: "x",
        //   style: textStyle,
        // );
        // TextPainter textPainter = TextPainter(
        //   text: textSpan,
        //   textDirection: TextDirection.ltr,
        //   textAlign: TextAlign.center,
        // );
        // textPainter.layout(
        //   // minWidth: size.width,
        //   maxWidth: 0,
        // );

        // final xCenter = i * size.width / (numberOfStrings - 1);
        // final yCenter = -size.height / 15 - textPainter.height / 1.5;
        // final offset = Offset(xCenter, yCenter);
        // textPainter.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
