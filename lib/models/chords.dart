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

  int distanceFrom(Note n) {
    int distance = index - n.index;
    return distance >= 0 ? distance : 12 + distance;
  }
}

class Chord {
  late String name;
  late Note root;
  late Type type;
  List<Note> tuning = [Note.e, Note.a, Note.d, Note.g, Note.b, Note.e];

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

  factory Chord.fromName(String name) {
    assert(name.isNotEmpty, "Chord name is empty");
    final rootString = name[0].toUpperCase();
    Note? root;
    int index = 0;

    // assert("CDEFGAB".contains(rootString), "Root must be a valid note");

    switch (rootString) {
      case "C":
        root = Note.c;
        index++;
        break;
      case "D":
        root = Note.d;
        index++;
        break;
      case "E":
        root = Note.e;
        index++;
        break;
      case "F":
        root = Note.f;
        index++;
        break;
      case "G":
        root = Note.g;
        index++;
        break;
      case "A":
        root = Note.a;
        index++;
        break;
      case "B":
        root = Note.b;
        index++;
        break;
      default:
        throw const FormatException("Root must be a valid note");
    }
    if (name.length > 1) {
      index++;
      switch (name[1].toLowerCase()) {
        case "#":
        case "♯":
          root += 1;
          break;
        case "b":
        case "♭":
          root -= 1;
          break;
      }
    }
    String extensions = name.substring(index);
    if (extensions.isEmpty) {
      print("No extensions!");
      return Chord(root);
    } else {
      print(">>>>$extensions");
    }

    return Chord(root);
  }
  List<int> getFingering() {
    List<int> fingering =
        List<int>.filled(tuning.length, -100, growable: false);
    fingering[0] = root.distanceFrom(tuning[0]);
    for (Note note in (notes + [root])) {
      for (var index = 1; index < tuning.length; ++index) {
        int fret = note.distanceFrom(tuning[index]);
        int oldDistanceFromRoot = (fingering[0] - fingering[index]).abs();
        int newDistanceFromRoot = (fingering[0] - fret).abs();
        if (fret == 0) {
          newDistanceFromRoot = 0;
        }
        if (fingering[index] == 0) {
          oldDistanceFromRoot = 0;
        }
        print(
            "note=$note, string=${index + 1}, fret=$fret old distance=$oldDistanceFromRoot, new distance=$newDistanceFromRoot");
        if (newDistanceFromRoot < oldDistanceFromRoot &&
            newDistanceFromRoot < 4) {
          fingering[index] = fret;
        }
      }
      print(fingering);
    }
    return fingering;
  }
}

void main() {
  Chord C = Chord.fromName("C");
  Note n1 = Note.g;
  Note n2 = Note.e;
  int dist = n1.distanceFrom(n2);
  // print("$n1 , $n2 + $dist -> ${n2 + dist}");
  print(C.getFingering());
}
