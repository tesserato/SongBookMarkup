#include<iostream>
#include<string>
#include<vector>

enum class Note{
    A=0, As=1, Bb=1, B=2, C=3, Cs=4, Db=4, D=5, Ds=6, Eb=6, E=7, F=8, Fs=9, Gb=9, G=10, Gs=11, Ab=11
};

const std::string note_tbl[12] = {"A","A#","B","C","C#","D","D#","E","F","F#","G","G#"};

Note operator++ (Note& n){ //prefix
    n = (n==Note::Ab) ? Note::A : Note(int(n) + 1); // “wrap around” 
    return n; 
}

Note operator++ (Note& n, int){ 
    Note orig = n;
    n = (n==Note::Ab) ? Note::A : Note(int(n) + 1); // “wrap around” 
    return orig; 
}

Note operator-- (Note& n){ 
    n = (n==Note::A) ? Note::Ab : Note(int(n) - 1); // “wrap around” 
    return n; 
}

Note operator-- (Note& n, int){ 
    Note orig = n;
    n = (n==Note::A) ? Note::Ab : Note(int(n) - 1); // “wrap around” 
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

std::ostream& operator<<(std::ostream& os, Note n) { 
    return os << note_tbl[int(n)]; 
    }
// Note class definition

void parse (std::string name){
    unsigned idx = 1;
    std::cout << '\n' << name << '\n'; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    std::string root_name;
    Note root_note;
    std::vector<Note> chord;
    root_name = toupper(name[0]);
    if (name[1] == '#' || name[1] == 'b'){
        root_name += name[1];
        idx ++;
    }
    std::cout << "Root: " << root_name << '\n'; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    for (unsigned i=0; i < 12; i++){
        if(root_name == note_tbl[i]){
            root_note = static_cast<Note>(i);
            chord = {root_note, root_note+4, root_note+7};
            break;
        }
    }
    if (name[idx] == 'M'){
        idx ++;
    }
    if (name[idx] == 'm'){
        chord[1]--;
        idx ++;
    }
    if (name[idx] == '+'){
        chord[2]++;
        idx ++;
    }
    if (name[idx] == 'o'){
        chord[1]--;
        chord[2]--;
        idx ++;
    } 
    if (name[idx] == '5'){
        chord[1]+=3;
        chord[2]-=7;
        idx ++;
    }   
    

    name.erase(0, idx);

    auto pos = name.find("b5");
    if (pos != std::string::npos){
        name.erase(pos, 2);
        chord[2] = chord[0] + 6;
    }    

    pos = name.find("#5");
    if (pos != std::string::npos){
        name.erase(pos, 4);
        chord[2] = chord[0] + 8;
    }

    pos = name.find("sus2");
    if (pos != std::string::npos){
        name.erase(pos, 3);
        chord[1] = chord[0] + 2;
    }

    pos = name.find("sus"); // sus4???
    if (pos != std::string::npos){
        name.erase(pos, 3);
        chord[1] = chord[0] + 5;
    }

    // end of triad
    pos = name.find("add4");
    if (pos != std::string::npos){
        name.erase(pos, 4);
        chord.push_back(chord[0] + 5);
    }

    pos = name.find("add2");
    if (pos != std::string::npos){
        name.erase(pos, 4);
        chord.push_back(chord[0] + 2);
    }

    pos = name.find("6");
    if (pos != std::string::npos){
        name.erase(pos, 1);
        chord.push_back(chord[0] + 9);
    }

    pos = name.find("M7");
    if (pos != std::string::npos){
        name.erase(pos, 2);
        chord.push_back(chord[0] + 11);
    }

    pos = name.find("7");
    if (pos != std::string::npos){
        name.erase(pos, 1);
        chord.push_back(chord[0] + 10);
    }



    for (auto note:chord){
        std::cout << note << ' ';
    }
    std::cout << '\n';
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

