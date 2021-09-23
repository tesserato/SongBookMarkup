enum Note { c, cs, d, ds, e, f, fs, g, gs, a, as, b }
enum Type { major, minor, augmented, diminished, power }
enum Extension { add2, add4, dom6, min7, maj7 }
enum Alteration { b5, s5, sus4, sus2 }

extension NoteExtension on Note {
  Note operator +(int i) {
    final int index = (this.index + i) % Note.values.length;
    return Note.values[index];
  }

  Note operator -(int i) { // TODO
    final int index = (this.index - i) % Note.values.length;
    return Note.values[index];
  }
}

class Chord {
  late String name;
  Note root;
  Type type;

  Extension? extension;
  Alteration? alteration;
  Note? bass;
  List<Note> notes = [];

  Chord(this.root,
      {this.type = Type.major, this.extension, this.alteration, this.bass}) {
    switch (type) {
      case Type.major:
        notes.add(root + 4);
        notes.add(root + 7);
        break;
      case Type.minor:
        notes.add(root + 3);
        notes.add(root + 7);
        break;
      case Type.augmented:
        notes.add(root + 4);
        notes.add(root + 8);
        break;
      case Type.diminished:
        notes.add(root + 3);
        notes.add(root + 6);
        break;
      case Type.power:
        notes.add(root + 7);
        break;
    }
    switch (alteration) {
      case Alteration.b5:
        notes[0] -= 1;
        break;
      case Alteration.s5:
        notes[1] += 1;
        break;
      case Alteration.sus2:
        notes[0] += 1;
        notes[1] += 1;
        break;
    }
  }
}

void main() {
  const note = Note.c;
  print("${note + 4}, ${note + 7}");
}
