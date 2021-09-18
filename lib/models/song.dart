import 'package:flutter/material.dart';

class ChordNtext extends ChangeNotifier {
  String? chordName;
  String? text;

  ChordNtext(this.text, {this.chordName});

  void setChordName(String name) {
    chordName = name;
  }

  void setText(String? t) {
    if (t == "" || t == null) {
      text = t;
      notifyListeners();
    } else if (t.contains(' ')) {
      text = t;
      notifyListeners();
    } else {
      text = t;
    }
  }
}

enum LineType { h1, h2, text, chords }

class Line {
  String? text;
  List<ChordNtext> chords = [];
  LineType type = LineType.h1;

  Line();

  Line.ofText(this.text, {this.type = LineType.text});

  Line.ofChords(this.chords) {
    // Chords and text
    type = LineType.chords;
  }

  // void insertChordNtext(ChordNtext cnt, {int? idx}) {
  //   if (idx == null) {
  //     chords.add(cnt);
  //   } else {
  //     chords.insert(idx, cnt);
  //   }
  //   lType = LineType.chords;
  // }

  // void setText(String txt) {
  //   var l = _parseLine(txt);
  //   text = l?.text;
  //   lType = l!.lType;
  //   print(text);
  // }
}

class Song extends ChangeNotifier {
  List<Line> lines = [];

  void parseLine(Line? line, String rawLine) {
    final rawLineTrimmed = rawLine.trim();
    if (rawLineTrimmed.startsWith('|')) {
      // comment
      line = null;
    }
    if (rawLineTrimmed.startsWith('#')) {
      if (rawLineTrimmed[1] == '#') {
        // H2 line
        line?.text = rawLineTrimmed.substring(2).trim();
        line?.type = LineType.h2;
      } else {
        // H1 line
        line?.text = rawLineTrimmed.substring(1).trim();
        line?.type = LineType.h1;
      }
    } else if (rawLineTrimmed.startsWith('>')) {
      // chords line
      line = null; // Line.ofChords(); // TODO
    } else if (rawLineTrimmed.startsWith('[')) {
      // chords definition
      line = null; // Line.ofChords(); // TODO
    } else {
      line?.text = rawLine;
      line?.type = LineType.text;
    }
    notifyListeners();
  }

  Song(String rawText) {
    for (var rawLine in rawText.split("\n")) {
      Line? blankLine = Line();
      parseLine(blankLine, rawLine);
      if (blankLine != null) {
        lines.add(blankLine);
      }
    }
  }
}
