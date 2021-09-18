#pragma once
#include <string>
#include <vector>
#include <map>
#include <utility>
#include <regex>
#include <unordered_map>
//Allegro
#include <allegro5/allegro.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_native_dialog.h>

//#include <iostream>
#include <algorithm>
#include <fstream>
#include <cstdio>

//class SongBook {
//public:
//	SongBook();
//	void save(std::string path);
//	void load(std::string path);
//	void new_song(int position);
//	void del_song(int position);
//private:
//	std::vector<Song> songs;
//};


enum class Note { A, As, B, C, Cs, D, Ds, E, F, Fs, G, Gs };
enum class Type { maj, min, aug, dim, pwr };
enum class Ext { add2, add4, dom6, min7, maj7, none };
enum class Alt { b5, s5, sus4, sus2, none };

class Chord {
public:
	bool parsed = false;
	int max_fret_dist = 5;                                                               //make static as needed
	int max_number_of_frets = 12;                                                        //make static as needed
	std::vector<Note> tuning = { Note::E, Note::A, Note::D, Note::G, Note::B, Note::E }; //make static as needed

	Chord(std::string name = "Default");                                                    // Constructor
	Chord(Note r, Note b, Type t = Type::maj, Ext e = Ext::none, Alt a = Alt::none); // Constructor
	std::string original_name;	
	//void print();
	//std::vector<Note> get_notes();
	std::string get_name();
	void get_fingerings();	
private:
	void init(Note r, Note b, Type, Ext, Alt);          //to be called by constructors
	std::vector<std::vector<int>> get_positions(Note);  //to be called by get_fingerings()
		
	std::vector<std::vector<Note>> note_from_position; //manual update if tuning changes
	Note root;                //notes
	Note bass;                //notes
	std::vector<Note> notes;  //notes
	Type type;
	Ext ext;
	Alt alt;
	
};


struct Pos{
	int l; //line
	int c; //char	
};
bool operator== (const Pos& a, const Pos& b);
bool operator!= (const Pos& a, const Pos& b);
bool operator<(const Pos& a, const Pos& b);
bool operator>(const Pos& a, const Pos& b);

//class Cholder { // Chord Holder
//	Chord Ch;
//	Pos Pi;
//	Pos Pf;
//};

enum class Dir {up, down, left, right, none};

class ChordInfo {
public:
	Chord chord;
	int ci;
	int cf;
};

class Song {
public:
	Song(std::string title = "Hover here for Cheatsheet"); // Constructor
	bool active = false;
	
	void movep0(Dir);
	void movep1(Dir);
	void setp0(Pos);
	void setp1(Pos);
	Pos getp0();
	Pos getp1();
	std::vector<std::string> getlines();

	void insert_text(std::string text);	   // insert text after s_caret
	std::string get_text();                // gets "selected text"
	void remove_text(bool del = true);     // remove text between positions, = del if p0 == p1 && del
	
	void insert_line(std::string text = "", bool end = true);                      
	void remove_line(int = -1);           // default (-1): current line

	void parse(char itk = '[', char ftk = ']');
	void Song::set_chord(Pos pf);
	std::map<Pos, ChordInfo> pos_chord_info; // maps various positions to chord info
private:
	std::vector<std::string>lines;
	std::vector<ChordInfo>chords;
	Pos p0;
	Pos p1;

	
};

// Allegro



//enum class Mode { chord, text };
//
//class Caret {
//public:
//	Pos p0; // line & char initial position
//	Pos p1; // line & char final position
//	void set_p0(int, int);
//	void set_p1(int, int);
//	void draw();
//};