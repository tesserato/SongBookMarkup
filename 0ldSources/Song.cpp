#include "classes.h"
#include <iostream>
#include <algorithm>

bool operator== (const Pos& a, const Pos& b) {
	if (a.l == b.l && a.c == b.c) {
		return true;
	}
	else {
		return false;
	}
}

bool operator!= (const Pos& a, const Pos& b) {
	if (a.l != b.l || a.c != b.c) {
		return true;
	}
	else {
		return false;
	}
}

bool operator<(const Pos& a, const Pos& b) {
	if (a.l < b.l) { return true; }
	if (a.l > b.l) { return false; }
	if (a.l == b.l) {
		if (a.c < b.c) {
			return true;
		}
		else {
			return false;
		}
	}
}

bool operator>(const Pos& a, const Pos& b) {
	if (a.l > b.l) { return true; }
	if (a.l < b.l) { return false; }
	if (a.l == b.l) {
		if (a.c > b.c) {
			return true;
		}
		else {
			return false;
		}
	}
}


// ############################
std::vector<std::string> d1 = { {"the one"},
{ "|D/C#                      |C " },
{ "I saw you dancing out the ocean" },
{ "|D/C                    |G " },
{ "Running fast along the sand" },
{ "|Gm                         |Eb " },
{ "A spirit born of earth and water" },
{ "|Eb                    |F " },
{ "Fire flying from your hands" } };

Song::Song(std::string t) {
	lines = {t};
	p0.l = 0;
	p0.c = 0;
	p1.l = 0;
	p1.c = 0;
}

void Song::insert_text(std::string text) {

	if (0 <= p0.l && p0.l < lines.size()) {
		if (p0.c >= lines[p0.l].size()) {
			std::string padding(p0.c - lines[p0.l].size(), ' ');
			lines[p0.l] += padding + text;
		}
		else {
			lines[p0.l].insert(p0.c, text);
		}
	}
	p0.c += text.size();
	p1 = p0;
}

std::string Song::get_text() {
	Pos start;
	Pos end;
	std::string text = "";
	if (p0 < p1) {
		start = p0;
		end = p1;
	}
	else {
		start = p1;
		end = p0;
	}
	if (start.l == end.l) {
		text = lines[start.l].substr(start.c, end.c - start.c);
	}
	else {
		text = lines[start.l].substr(start.c, std::string::npos) + '\n';
		
		for (int i = start.l + 1; i < end.l; i++) {
			text += lines[i] + '\n';
		}		
		text += lines[end.l].substr(0, end.c);
	}	
	return text;
}

void Song::remove_text(bool del) {
	Pos start;
	Pos end;
	if (p0 < p1) {
		start = p0;
		end = p1;
	}
	else {
		start = p1;
		end = p0;
	}
	if (start == end && del) {
		lines[start.l].erase(start.c, 1);
	}
	else {
		if (start.l == end.l) {
			lines[start.l].erase(std::min(start.c, end.c), abs(start.c - end.c));
		}
		else {
			lines[start.l].erase(start.c, std::string::npos);
			lines[end.l].erase(0, end.c);
			auto nt = lines[start.l] + lines[end.l];
			lines.erase(lines.begin() + start.l, lines.begin() + end.l);
			lines[start.l] = nt;
		}
	}
	p1 = start;
	p0 = start;
}

void Song::insert_line(std::string text, bool append) {
	if (append) {
		lines.push_back(text);
	}
	else {
		//text = lines[p0.l].substr(p0.c, std::string::npos); // "return behavior"
		//lines[p0.l].erase(p0.c, std::string::npos);		  // "return behavior"
		if (p0.l < lines.size()) {
			lines.insert(lines.begin() + p0.l + 1, text);
			//p0.l++;
			p0.c = lines[++p0.l].size();
			p1 = p0;
		}		
	}
}

void Song::remove_line(int line) {
	if (lines.size() > 1) {
		if (line < 0 || line >= lines.size()) {
			line = p0.l;
		}
		lines.erase(lines.begin() + line);
		setp0(p0);
	}
}

void Song::setp0(Pos pos) {
	int l = pos.l;
	int c = pos.c;
	if (l < 0) { l = 0; }
	if (l > lines.size() - 1) { l = lines.size() - 1; }
	if (c < 0) { c = 0; }
	p0 = { l,c };
	p1 = { l,c };
}

void Song::setp1(Pos pos) {
	int l = pos.l;
	int c = pos.c;
	if (l < 0) { l = 0; }
	if (l > lines.size() - 1) { l = lines.size() - 1; }
	if (c < 0) { c = 0; }
	p1 = { l,c };
}

void Song::movep0(Dir dir) {
	switch (dir)
	{
	case Dir::up:
		if (p0.l > 0) {
			p0.l--;
		}
		break;
	case Dir::down:
		if (p0.l < lines.size() - 1) {
			p0.l++;
		}
		break;
	case Dir::left:
		if (p0.c > 0) {
			if (pos_chord_info.find(p0) == pos_chord_info.end()) {
				p0.c--;
			}
			else {
				set_chord({ p0.l, p0.c - 1});
			}
		}
		else {
			if (p0.l > 0) {
				p0.l--;
				p0.c = lines[p0.l].size();
			}
		}
		break;
	case Dir::right:
		if (pos_chord_info.find(p0) == pos_chord_info.end()) {
			p0.c++;
		}
		else {
			set_chord({ p0.l, p0.c + 1 });
		}
	}
	p1 = p0;

}

void Song::set_chord(Pos pf) {
	int ci = pos_chord_info[p0].ci;
	int cf = pos_chord_info[p0].cf;
	std::string name = pos_chord_info[p0].chord.original_name;

	std::string& li = lines[p0.l];
	std::string& lf = lines[pf.l];
	
	std::cout << name << '\n';
	std::cout << ci << ' ' << cf << '\n';
			
	if (pf.c <= ci) {
		auto b = pos_chord_info.find({pf.l , pf.c});
		if (b == pos_chord_info.end() && pf.c >= 0) {
			li.erase(ci, cf - ci + 1);
			lf.insert(pf.c, name);
		}
	}
	else {
		auto b = pos_chord_info.find({ pf.l , pf.c });
		if (b == pos_chord_info.end()) {
			li.erase(ci, cf - ci + 1);
			while (pf.c - name.size() + 1 >= lf.size()) {
				lf.push_back(' ');
			}
			lf.insert(pf.c - name.size() + 1, name);
		}
	}		
	p0 = pf;
	parse();
}

void Song::movep1(Dir dir) {
	switch (dir)
	{
	case Dir::up:
		if (p1.l > 0) {
			p1.l--;
		}
		break;
	case Dir::down:
		if (p1.l < lines.size() - 1) {
			p1.l++;
		}
		break;
	case Dir::left:
		if (p1.c > 0) {
			p1.c--;
		}
		else {
			if (p1.l > 0) {
				p1.l--;
				p1.c = lines[p1.l].size();
			}
		}
		break;
	case Dir::right:
		p1.c++;
		break;
	}
}

std::vector<std::string> Song::getlines() {

	return lines;
}

Pos Song::getp0() {
	return p0;
}

Pos Song::getp1() {
	return p1;
}

void Song::parse(char itk, char ftk) {
	pos_chord_info.clear();
	chords.clear();
	itk = '|';
	ftk = ' ';
	//std::cout << "parsing \n";
	std::string chord_name = "";
	bool inside_chord = false;
	int ci;
	int cf;
	for (int i = 0; i < lines.size(); i++) {
		ci = 0;
		cf = 0;
		for (int j = 0; j < lines[i].size(); j++) {
			if (lines[i][j] == itk && !inside_chord) {
				inside_chord = true;
				ci = j;
			}
			if (inside_chord) {
				chord_name += lines[i][j];
				//std::cout << lines[i][j] << '\n';
			}
			if (lines[i][j] == ftk && inside_chord) {
				inside_chord = false;
				cf = j;
				Chord chord{ chord_name.substr(1, std::string::npos) };	
				chord.original_name = chord_name;
				ChordInfo CI{ chord, ci, cf };
				chords.push_back(CI);				
				for (int c = ci; c <= cf; c++) {
					pos_chord_info.insert({ { i, c } , CI });					
				}
				std::cout << "Chord " << chord.original_name << "at L:" << i << " Ci:" << ci << " Cf:" << cf << '\n';
				chord_name = "";
			}
		}
	}
}

