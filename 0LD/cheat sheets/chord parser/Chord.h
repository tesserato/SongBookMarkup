#include<map>
#include<vector>

enum class Note{A, As, B, C, Cs, D, Ds, E, F, Fs, G, Gs};
enum class Type{maj, min, aug, dim, pwr};
enum class Ext{add2, add4, dom6, min7, maj7, none};
enum class Alt{ b5, s5, sus4, sus2, none};

std::map<std::string, Note> name_note = {
    {"A", Note::A},
    {"A#", Note::As},
    {"Bb", Note::As},
    {"B", Note::B},
    {"Cb", Note::B},
    {"C", Note::C},
    {"C#", Note::Cs},
    {"Db", Note::Cs},
    {"D", Note::D},
    {"D#", Note::Ds},
    {"Eb", Note::Ds},
    {"E", Note::E},
    {"Fb", Note::E},
    {"F", Note::F},
    {"E#", Note::F},
    {"F#", Note::Fs},
    {"Gb", Note::Fs},
    {"G", Note::G},
    {"G#", Note::Gs},
    {"Ab", Note::Gs}
};
std::map<Note, std::string> note_name = {
    {Note::A, "A"},
    {Note::As, "A#|Bb"},
    {Note::B, "B"},
    {Note::C, "C"},
    {Note::Cs, "C#|Db"},
    {Note::D, "D"},
    {Note::Ds, "D#|Eb"},
    {Note::E, "E"},
    {Note::F, "F"},
    {Note::Fs, "F#|Gb"},
    {Note::G, "G"},
    {Note::Gs, "G#|Ab"}
};

std::map<Type, std::string> type_name ={
    {Type::maj, ""},
    {Type::min, "m"},
    {Type::aug, "+"},
    {Type::dim, "o"},
    {Type::pwr, "5"}
};
std::map<Type, std::vector<int>> type_intervals= {
    {Type::maj,{4,7}},
    {Type::min,{3,7}},
    {Type::aug,{4,8}},
    {Type::dim,{3,6}},
    {Type::pwr,{7,0}}
};

std::map<Ext, std::string> ext_name= {
    {Ext::add2, "add2"},
    {Ext::add4, "add4"},
    {Ext::dom6, "6"},
    {Ext::min7, "7"},
    {Ext::maj7, "M7"},
    {Ext::none, ""},
};
std::map<Ext, std::vector<int>> ext_intervals= {
    {Ext::add2, {2}},
    {Ext::add4, {5}},
    {Ext::dom6, {9}},
    {Ext::min7, {10}},
    {Ext::maj7, {11}},
    {Ext::none, {0}},
};

std::map<Alt, std::string> alt_name= {
    {Alt::b5, "b5"},
    {Alt::s5, "#5"},
    {Alt::sus4, "sus"},
    {Alt::none, ""},
    {Alt::sus2, "sus2"}
};
std::map<Alt, std::map<std::string,int>> alt_ip_interval{
    {Alt::b5, {{"loc", 1},{"itv",6}} },
    {Alt::s5, {{"loc", 1},{"itv",8}} },
    {Alt::sus4, {{"loc", 0},{"itv",5}} },
    {Alt::sus2, {{"loc", 0},{"itv",2}} }
};


struct Pos {
    int string;
    int fret;
};

class Chord{
public:
    Chord(Note r, Note b, Type t = Type::maj, Ext e = Ext::none, Alt a = Alt::none);
    Chord(const std::string&);
    void print();
    std::vector<Note> get_notes();
    std::string get_name();    
    void get_fingerings();
private:
    void init (Note r, Note b, Type, Ext, Alt); //to be called by constructors
    std::vector<std::vector<int>> get_positions(Note);
    const int max_fret_dist = 5;

    std::vector<Note> tuning = {Note::E, Note::A, Note::D, Note::G, Note::B, Note::E};
    const int max_number_of_frets = 12;
    std::vector<std::vector<Note>> note_from_position; //manual update if tuning changes

    Note root;
    Note bass;
    Type type;
    Ext ext;
    Alt alt;
    std::vector<Note> notes;
    
};

