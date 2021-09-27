#include<iostream>
#include<string>
#include<vector>
#include<map>
#include <regex>
#include "Chord.h"

Note operator++ (Note& n){ //prefix
    n = (n==Note::Gs) ? Note::A : Note(int(n) + 1); // “wrap around” 
    return n; 
}

Note operator++ (Note& n, int){ 
    Note orig = n;
    n = (n==Note::Gs) ? Note::A : Note(int(n) + 1); // “wrap around” 
    return orig; 
}

Note operator-- (Note& n){ 
    n = (n==Note::A) ? Note::Gs : Note(int(n) - 1); // “wrap around” 
    return n; 
}

Note operator-- (Note& n, int){ 
    Note orig = n;
    n = (n==Note::A) ? Note::Gs : Note(int(n) - 1); // “wrap around” 
    return orig; 
}

Note operator+= (Note& n, int add){ 
    for (unsigned i=0; i < add; i++){
        n++;
    }
    return n; 
}

Note operator-= (Note& n, int add){ 
    for (unsigned i=0; i < add; i++){
        n--;
    }
    return n; 
}

Note operator+ (Note n, int add){ 
    for (unsigned i=0; i < add; i++){
        n++;
    }
    return n; 
}

Note operator- (Note n, int add){ 
    for (unsigned i=0; i < add; i++){
        n--;
    }
    return n; 
} 

int operator- (Note a, Note b){
    int n = 0;
    while  (b != a) {
        b++;
        n++;
    }
    return n;
} 



std::ostream& operator<<(std::ostream& os, const Note& n) { // Note cout overload
    return os << note_name[n].c_str();
    }    

std::ostream& operator<<(std::ostream& os, const Type& t) { // Type cout overload 
    return os << type_name[t].c_str();
    }

std::ostream& operator<<(std::ostream& os, const Ext& e) { // Ext cout overload 
    return os << ext_name[e].c_str();
    }

std::ostream& operator<<(std::ostream& os, const Alt& a) { // Alt cout overload 
    return os << alt_name[a].c_str();
    }


void Chord::init(Note r, Note b, Type t, Ext e, Alt a){
    // std::cout << "INIT\n"; // ######################
    root = r;
    bass = b;
    type = t;
    ext = e;
    alt = a;

    for(int itv :  type_intervals[t]){
        notes.push_back(root + itv);
    } 

    if (e != Ext::none){
        for(int itv :  ext_intervals[e]){
            notes.push_back(root + itv);
        } 
    }

    if (a != Alt::none){
        notes[alt_ip_interval[a]["loc"]] = root + alt_ip_interval[a]["itv"];
    }
    note_from_position = {{},{},{},{},{},{}};
    for(int i = 0; i <= max_number_of_frets; i++){
        note_from_position[0].push_back(tuning[0] + i);
        note_from_position[1].push_back(tuning[1] + i);
        note_from_position[2].push_back(tuning[2] + i);
        note_from_position[3].push_back(tuning[3] + i);
        note_from_position[4].push_back(tuning[4] + i);
        note_from_position[5].push_back(tuning[5] + i);
    }
}

Chord::Chord(Note r, Note b, Type t, Ext e, Alt a){
    // std::cout << "Parameters Constructor\n"; // ######################
    init(r, b, t, e, a);
}

Chord::Chord(const std::string& name){
    // std::cout << "String Constructor\n"; // ######################
    Note root;
    Note bass;
    Type type = Type::maj;
    Ext ext = Ext::none;
    Alt alt = Alt::none;    
    std::string root_name;
    std::string bass_name;
    std::smatch matches;
    //####################################### search for root #######################################
    std::regex_search(name, matches, std::regex("^[a-gA-G](b|#)?", std::regex::nosubs));    
    if (matches.size() > 0){
        root_name = matches.str(0);
        root_name[0] = toupper(root_name[0]);
        root = name_note[root_name];
        bass = root;
    }
    else{
        std::cout << matches.size() << " match(es):" << '\n';
        std::cout << "Unable to Specify Root \n";
        return;
    }
    //####################################### search for bass #######################################
        std::regex_search(name, matches, std::regex("/[a-gA-G](b|#)?")); 
        if (matches.size() > 0){
            bass_name = matches.str(0).substr(1, std::string::npos);
            bass_name[0] = toupper(bass_name[0]);
            bass = name_note[bass_name];
            }  
    //####################################### search for type #######################################
        std::regex_search(name, matches, std::regex("^[a-gA-g](b|#)?5"));    // power
        if (matches.size() > 0){type = Type::pwr;}
        std::regex_search(name, matches, std::regex("m"));    // minor
        if (matches.size() > 0){type = Type::min;}
        std::regex_search(name, matches, std::regex("\\+|aug"));    // aug
        if (matches.size() > 0){type = Type::aug;}
        std::regex_search(name, matches, std::regex("o|-|dim"));    // dim
        if (matches.size() > 0){type = Type::dim;}
    //####################################### search for extention #######################################
        std::regex_search(name, matches, std::regex("add2"));    // add2
        if (matches.size() > 0){ext = Ext::add2;}
        std::regex_search(name, matches, std::regex("add4"));    // add4
        if (matches.size() > 0){ext = Ext::add4;}        
        std::regex_search(name, matches, std::regex("(m)?7"));    // [m]7
        if (matches.size() > 0){ext = Ext::min7;}
        std::regex_search(name, matches, std::regex("M7|(M|m)aj7"));    // M7
        if (matches.size() > 0){ext = Ext::maj7;}
        std::regex_search(name, matches, std::regex("6|dim7|o7"));    // 6
        if (matches.size() > 0){ext = Ext::dom6;}
    //####################################### search for alteration #######################################
        std::regex_search(name, matches, std::regex("[^a-g#]b5"));    // b5
        if (matches.size() > 0){alt = Alt::b5;}
        std::regex_search(name, matches, std::regex("[^a-g#]#5"));    // #5
        if (matches.size() > 0){alt = Alt::s5;}
        std::regex_search(name, matches, std::regex("sus(4)?(?!2)"));    // sus[4]
        if (matches.size() > 0){alt = Alt::sus4;}
        std::regex_search(name, matches, std::regex("sus2"));    // sus2
        if (matches.size() > 0){alt = Alt::sus2;}
        init(root, bass, type, ext, alt);
return;
}

void Chord::print(){
    if (bass != root){std::cout << "Bass: " << bass << " ";}
    std::cout << "Root: " << root << " Type: " << type << " Ext: " << ext << " Alt: " << alt << " Notes: ";
    for (Note n : notes){
        std::cout << n << ' ';
    }
    std::cout << '\n';
}

std::vector<std::vector<int>> Chord::get_positions(Note n){        
    int curr_fret;
    int curr_string;
    Pos curr_position;  
    std::vector<std::vector<int>> positions = {{},{},{},{},{},{}};
    curr_string = 0; 
    // std::cout << "N:" << n << '\n'; // #############   
    for (Note t : tuning){
        curr_fret = n - t;
        positions[curr_string].push_back(curr_fret);
        // std::cout << " S:" << curr_string << " F:" << curr_fret << '\n'; // #############
        if (curr_fret + 12 <= max_number_of_frets) {
            positions[curr_string].push_back(curr_fret + 12);
            // std::cout << " S:" << curr_string << " F:" << curr_fret + 12 << '\n'; // #############
        }        
        curr_string++;            
    }
    return positions;
};

void Chord::get_fingerings(){
    int curr_fret;
    int curr_string;
    Pos curr_position;
    std::vector<int> curr_fingering;
    std::map<Note, bool> hasnote;
    std::vector<std::vector<int>> root_positions = get_positions(root);
    std::vector<std::vector<int>> notes_positions = get_positions(root);
    std::vector<std::vector<int>> curr_n_p;

    std::cout << "Root:" << root << "\n";
    for (int i = 0; i <= 2; i++){ 
        std::cout << "String " << i << ": ";  
        for (int j = 0; j < root_positions[i].size(); j++){
            std::cout << root_positions[i][j] << ' ';
        }
        std::cout << "\n";
    }

    for (Note n : notes){
        std::cout << "Note:" << n << "\n";
        curr_n_p = get_positions(n);
        for (int i = 0; i < curr_n_p.size(); i++){
            std::cout << "String " << i << ": ";
            for (int p : curr_n_p[i]){
                std::cout << p << ' ';               
            }
            std::cout << "\n";
        }       
    }
}

std::string Chord::get_name(){
    std::string name = note_name[root] + type_name[type] + ext_name[ext] + alt_name[alt];
    if(root != bass){
        name += "/" + note_name[bass];
    }
    return name;
}

int main(){
// testing



// testing
    bool repeat = true;
    std::string line;
    while (repeat){
        std::cout << "Enter Chord Name: (enter x to exit)\n";
        getline(std::cin, line);
        if (line == "x"){break;}
        else{
            Chord chord{line};
            std::cout << chord.get_name() << '\n';
            chord.print();
            chord.get_fingerings();
        }
    }
    return 0;    
}

