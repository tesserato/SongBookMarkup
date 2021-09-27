enum Note { c, cs, d, ds, e, f, fs, g, gs, a, as, b }
enum Type {
  major,
  minor,
  augmented,
  diminished,
  suspended4th,
  suspended2nd,
  power
}
enum Addition { add2, add4, dom6, minor7th, major7th }
enum Alteration { b5, s5 }

extension NoteExtension on Note {
  Note operator +(int i) {
    final int index = (this.index + i) % Note.values.length;
    return Note.values[index];
  }

  Note operator -(int i) {
    final int index =
        (this.index - i + Note.values.length) % Note.values.length;
    return Note.values[index];
  }
}

class Chord {
  late String name;
  Note root;
  Type type;

  Addition? addition;
  Alteration? alteration;
  Note? bass;
  List<Note> notes = [];

  Chord(this.root,
      {this.type = Type.major, this.addition, this.alteration, this.bass}) {
    switch (type) {
      case Type.major: // X
        notes.add(root + 4);
        notes.add(root + 7);
        break;
      case Type.minor: // Xm
        notes.add(root + 3);
        notes.add(root + 7);
        break;
      case Type.augmented: // X+
        notes.add(root + 4);
        notes.add(root + 8);
        break;
      case Type.diminished: // X⚬
        notes.add(root + 3);
        notes.add(root + 6);
        break;
      case Type.suspended2nd: // Xsus2
        notes.add(root + 2);
        notes.add(root + 7);
        break;
      case Type.suspended4th: // Xsus4
        notes.add(root + 5);
        notes.add(root + 7);
        break;
      case Type.power: // X5
        notes.add(root + 7);
        notes.add(root);
        break;
    }
    switch (addition) {
      case Addition.major7th: // X△
        notes.add(notes[1] + 4);
        break;
      case Addition.minor7th: // X7
        notes.add(notes[1] + 3);
        break;
    }
  }
}

void main() {
  const note = Note.c;
  print(
      "${note - 1}, ${note - 2}, ${note - 3}, ${note - 4}, ${note - 5}, ${note - 6}");
}
