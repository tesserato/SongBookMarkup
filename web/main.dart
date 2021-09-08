import 'dart:html';

enum Note { c, cs, d, ds, e, f, fs, g, gs, a, as, b }
enum Type { major, minor, augmented, diminished, power }
enum Extension { none, add2, add4, dom6, min7, maj7 }
enum Alteration { none, b5, s5, sus4, sus2 }

class Chord {
  late String name;
  Note root;
  Type type;

  Extension? extension;
  Alteration? alteration;
  Note? bass;

  Chord(
    this.root, 
    {
      this.type = Type.major, 
      this.extension = null,
      this.alteration = null,
      this.bass = null,
    }
  )
  {

  }
}

void main() {
  querySelector('#output')?.text = 'Your Dart app is running.';
}
