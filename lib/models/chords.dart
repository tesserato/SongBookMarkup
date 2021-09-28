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
enum Addition { added2nd, addeed4th, dom6, minor7th, major7th }
enum Alteration { flat5, sharp5 }

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
  late Note root;
  late Type type;

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
    switch (alteration) {
      case Alteration.flat5: // X(♭5)
        notes.add(notes[2] -= 1);
        break;
      case Alteration.sharp5: // X(♯5)
        notes.add(notes[2] += 1);
        break;
      default:
        break;
    }
    switch (addition) {
      case Addition.major7th: // X△
        notes.add(notes[1] + 4);
        break;
      case Addition.minor7th: // X7
        notes.add(notes[1] + 3);
        break;
      case Addition.added2nd: // Xadd2, X2, Xadd9
        notes.add(root + 2);
        break;
      case Addition.addeed4th: // Xadd4
        notes.add(root + 4);
        break;
      case Addition.dom6: // X6
        notes.add(root + 9);
        break;
      default:
        break;
    }
  }

  factory Chord.fromName(name) {
    assert(name.isNotEmpty, "Chord name is empty");
    final rootString = name[0].toUpperCase();
    Note? root;
    // assert("CDEFGAB".contains(rootString), "Root must be a valid note");

    switch (rootString) {
      case "C":
        root = Note.c;
        break;
      case "D":
        root = Note.d;
        break;
      case "E":
        root = Note.e;
        break;
      case "F":
        root = Note.f;
        break;
      case "G":
        root = Note.g;
        break;
      case "A":
        root = Note.a;
        break;
      case "B":
        root = Note.b;
        break;
      default:
      throw const FormatException("Root must be a valid note");
    }
    if (name.length > 1) {
      switch (name[1]) {
        case "#":
        case "♯":
          root += 1;
          break;
        case "b":
        case "♭":
          root -= 1;
          break;
      }
    }else{
      return Chord(root);
    }
    return Chord(root);
  }
}

void main() {
  Chord C = Chord.fromName("x");
  print("${C.root} ${C.notes}");
}
