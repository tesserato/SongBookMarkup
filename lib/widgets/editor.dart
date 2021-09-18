import 'package:clairvoyant/models/song.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

var rawText =
    "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget.";

class Editor extends StatelessWidget {
  const Editor({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Song song = Provider.of<Song>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Book'),
      ),
      body: SongWidget(song),
    );
  }
}

class SongWidget extends StatelessWidget {
  final Song song;
  // var ctr = TextEditingController(text: "");

  const SongWidget(this.song, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> W = [];
    for (var line in song.lines) {
      switch (line.type) {
        case LineType.h1:
          W.add(TextFormField(
            initialValue: line.text,
            autofocus: true,
            maxLines: 1,
            onChanged: (txt) {
              song.parseLine(line, txt);
            },
          ));
          break;
        case LineType.h2:
          W.add(TextFormField(
            initialValue: line.text,
            autofocus: true,
            maxLines: 1,
            onChanged: (txt) {
              song.parseLine(line, txt);
            },
          ));
          break;
      }
    }
    return Column(
      children: W,
    );
  }
}

class ChordNtext extends ChangeNotifier {
  var chordController = TextEditingController(text: "");
  var textController = TextEditingController(text: "");
  late Widget W;

  ChordNtext(text, {String? chordName}) {
    chordController.text = chordName ?? "";
    textController.text = text;

    W = IntrinsicWidth(
        child: Column(children: [
      TextFormField(
        controller: chordController,
        autofocus: true,
        maxLines: 1,
        onChanged: (txt) {
          chordController.text = txt;
          chordController.selection = TextSelection.fromPosition(
              TextPosition(offset: chordController.text.length));
        },
      ),
      TextFormField(
        controller: textController,
        autofocus: true,
        maxLines: 1,
        onChanged: (txt) {
          print(txt);
        },
      )
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return W;
  }
}

List<Widget> processRawText(String text) {
  return text.split(" ").map((i) => toText(i)).toList();
}

Widget toText(String t) {
  var chordController = TextEditingController(text: "");
  var textController = TextEditingController(text: t);
  return IntrinsicWidth(
      child: Column(children: [
    TextFormField(
      controller: chordController,
      autofocus: true,
      maxLines: 1,
      onChanged: (txt) {
        chordController.text = txt;
        chordController.selection = TextSelection.fromPosition(
            TextPosition(offset: chordController.text.length));
      },
    ),
    TextFormField(
      controller: textController,
      autofocus: true,
      maxLines: 1,
      onChanged: (txt) {
        print(txt);
      },
    )
  ]));
}
