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

std::ostream& operator<<(std::ostream& os, const Note& n) { 
    return os << note_name[n].c_str();
    }

    

std::ostream& operator<<(std::ostream& os, Type t) { 
    return os << type_name[t].c_str();
    }

Chord::Chord(Note r, Type t, Alt a, Ext e ){
    root = r;
    type = t;
    alt = a;
    ext = e;
    intervals = type_intervals[t];
    for(int itv: intervals){
        notes.push_back(root + itv);
    }
    switch(alt){ // alterations
        case Alt::b5: notes[2] = root + 6; break;
        case Alt::s5: notes[2] = root + 8; break;
        case Alt::sus2: notes[1] = root + 5; break;
        case Alt::sus4: notes[1] = root + 2; break;
    }
    switch(ext){ // alterations
        case Ext::add2: notes.push_back(root + 2); break;
        case Ext::add4: notes.push_back(root + 5); break;
        case Ext::dom6: notes.push_back(root + 9); break;
        case Ext::min7: notes.push_back(root + 10); break;
        case Ext::maj7: notes.push_back(root + 11); break;
    }
}

Chord::Chord(std::string name){

}

void Chord::print(){
    std::cout << "Root: " << root << " Type: " << type << " Notes: ";
    for (Note n:notes){
        std::cout << n << ' ';
    }
    std::cout << '\n';
}


int parse(const std::string& name){    
    Note root;
    Type type;
    Alt alt = Alt::none;
    Ext ext = Ext::none;
    
    bool typefound = false;
    std::regex pattern;
    std::smatch matches;
    std::string parsing = name;
    //####################################### search for root #######################################
    if (parsing.size() > 0){ 
        
        pattern = std::regex("^[a-gA-G](b|#)?", std::regex::nosubs);
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            auto name = matches.str(0);
            name[0] = toupper(name[0]);
            root = name_note[name];
            parsing = std::regex_replace(parsing, pattern, "");     
            // std::cout << "Root = " << note_name[root] << '\n';
            // std::cout << "Rest = " << parsing << '\n';
        }
        else{
            std::cout << matches.size() << " match(es):" << '\n';
            std::cout << "Unable to Find Root \n";
            return 1;
        }
    }
    //####################################### search for type #######################################
    if (parsing.size() > 0){ // search for power chord
        pattern = std::regex("^5"); //nosubs
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            type = Type::pwr; 
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }

    if (parsing.size() > 0 && !typefound){ // search for minor
        pattern = std::regex("^((m|M)(i|I)(n|N)(o|O)?(r|R)?|m(?!(a|A)(j|J)))", std::regex::nosubs); //nosubs
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            type = Type::min; 
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }

    if (parsing.size() > 0 && !typefound){ // search for augmented
        pattern = std::regex("^(aug(mented)?)|^\\+", std::regex::icase);  
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            type = Type::aug; 
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }

    if (parsing.size() > 0 && !typefound){ // search for diminished
        pattern = std::regex("^(dim(inished)?)|^(o|º|°|-)", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            type = Type::dim;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    
    if (!typefound){ // must be major!
        pattern = std::regex("^((m|M)(a|A)(j|J)(o|O)?(r|R)?|M(?!(i|I)(n|N)))", std::regex::nosubs);
        type = Type::maj;
        std::regex_search(parsing, matches, pattern);
        if (matches.size() > 0){
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }    
    }
    //####################################### search for alteration #######################################
    if (parsing.size() > 0 ){ // search for suspended[4]
        pattern = std::regex("sus(4)?(?!2)(?!pended2)(pended)?(4)?", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            alt = Alt::sus4;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    if (parsing.size() > 0  && alt == Alt::none){ // search for suspended2
        pattern = std::regex("sus2|suspended2", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            alt = Alt::sus2;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    if (parsing.size() > 0  && alt == Alt::none){ // search for flat five
        pattern = std::regex("b5", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            alt = Alt::b5;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    if (parsing.size() > 0  && alt == Alt::none){ // search for sharp five
        pattern = std::regex("#5", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            alt = Alt::s5;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    //####################################### search for extention #######################################
    if (parsing.size() > 0 ){ // search for add2
        pattern = std::regex("add2", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            ext = Ext::add2;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    if (parsing.size() > 0  && ext == Ext::none){ // search for add4
        pattern = std::regex("add4", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            ext = Ext::add4;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    if (parsing.size() > 0  && ext == Ext::none){ // search for sixth
        pattern = std::regex("6", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            ext = Ext::dom6;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    if (parsing.size() > 0  && ext == Ext::none){ // search for [min]7
        pattern = std::regex("7", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            ext = Ext::min7;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }
    if (parsing.size() > 0  && ext == Ext::none){ // search for major 7
        pattern = std::regex("M7", std::regex::icase); 
        std::regex_search(parsing, matches, pattern);    
        if (matches.size() > 0){
            ext = Ext::maj7;
            parsing = std::regex_replace(parsing, pattern, "");
            typefound = true;
        }
    }


    Chord crd = Chord(root, type, alt, ext);
    crd.print();
    // std::cout << '\n';    
    // std::cout << "Type = " << type_name[type] << '\n';
    // std::cout << "Rest = " << parsing << '\n';

return 0;
}


int main(){
    bool repeat = true;
    std::string line;
    while (repeat){
        std::cout << "Enter Chord Name: (enter x to exit)\n";
        getline(std::cin, line);
        if (line == "x"){break;}
        else{parse(line);}
    }

    return 0;
    
}

