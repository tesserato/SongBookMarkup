#include "classes.h"
#include <chrono>
#include <sstream>

using namespace std;

vector<string> help =
{
{"Chord start token      \"\|\" (pipe)"},
{"Chord end token        \" \" (space)"},
{"Hover over chord for shape"},
{"Pan view with middle mouse button"},
{"Zoom view with mouse wheel"},
{" "},
{"Select all                ctrl + a"},
{"Save as                   ctrl + s"},
{"Load .sb file             ctrl + o"},
{"Copy                      ctrl + c"},
{"Paste                     ctrl + v"},
{"Delete current line       ctrl + del"},
{ " " },
{"Move Chord                right|left keys inside chord"},
{"Select text via keyboard  ctrl + right|left keys"},
{"Select text via mouse     drag with left mouse button"},
{"Select word|chord         double click"},
{ " " },
{ "Refer to Readme for more info." },
{ "comments|bugs|donations → tesserato@hotmail.com" }
};

string PATH;
int init_pam_x = 0;
int init_pam_y = 0;

int CAMX;
int CAMY;

int SW = 800;
int SH = 600;

int font_size = 12;
int char_w = NULL;
int char_h = NULL;

bool Mshift = false;
bool Mctrl = false;
bool Malt = false;
bool Mmiddle_btn = false;
bool Mleft_btn = false;

map<string, vector<int>> name_positions;
Song s;
std::chrono::high_resolution_clock Clock;

Pos last_left_click_pos;
auto last_left_click_time = Clock.now();
bool selection = false;

ALLEGRO_EVENT ev;
//ALLEGRO_BITMAP *bkgrd = NULL;
ALLEGRO_DISPLAY *window = NULL;
ALLEGRO_FONT* font = NULL;
ALLEGRO_FONT* fontb = NULL;
ALLEGRO_EVENT_QUEUE *queue = NULL;
ALLEGRO_FILECHOOSER *fd;
ALLEGRO_BITMAP* icon = NULL;

#define white al_map_rgb(255, 255, 255)
//#define black al_map_rgb(0, 0, 0)
//#define red al_map_rgb(255, 0, 0)
//#define blue al_map_rgb(0, 0, 255)

#define cl_background al_map_rgb(31, 31, 46)
#define cl_selection al_map_rgb(71, 71, 107)

#define cl_helpback al_map_rgb(71, 71, 107)
#define cl_helpfont al_map_rgb(255, 255, 255)

#define cl_chordline al_map_rgb(255, 255, 255)
#define cl_chordtext al_map_rgb(31, 31, 46)

void save(bool saveas = false) {
	auto lines = s.getlines();
	string path = lines[0] + ".sb";
	string curr_cl;
	string txt;
	for (auto l : lines) {
		txt += l + '\n';
	}
	//cout << txt << endl;

	if (saveas) {
		fd = al_create_native_file_dialog(NULL, "Choose a file.", "*.*;*.sb;", ALLEGRO_FILECHOOSER_SAVE);
		al_show_native_file_dialog(window, fd);
		if (al_get_native_file_dialog_count(fd) > 0) {
			path = al_get_native_file_dialog_path(fd, 0);
			path += ".sb";
		}
	}
	ofstream out(path);
	out << txt;
	out.close();
}

void load(bool append = false) {
	//cout << PATH;
	ifstream File;
	string line;
	string path; // = PATH;
	string cname = "";
	int currl = 0;
	Mctrl = false;

	fd = al_create_native_file_dialog(PATH.c_str(), "Choose a file.", "*.*;*.sb;", ALLEGRO_FILECHOOSER_FILE_MUST_EXIST);
	al_show_native_file_dialog(window, fd);
	if (al_get_native_file_dialog_count(fd) > 0) {
		path = al_get_native_file_dialog_path(fd, 0);		
		File.open(path);
		if (!append) {
			getline(File, line);
			s = Song{ line };
		}
		while (!File.eof()) {
			getline(File, line);
			//cout << line << endl;
			s.insert_line(line);
		}
		File.close();
		s.parse();
	}
	else {
		return; 
	}	
}

void load_name_positions() {
	name_positions = {};
	vector<int> positions;
	ifstream File;
	string line;
	string name;
	stringstream ss;
	int fret;
	File.open("resources\\chords.cd");
	while (!File.eof()) {		
		std::getline(File, line);		
		if (!line.empty()) {
			ss.clear();
			ss << line;
			ss >> name;
			//cout << name << " ";
			while (!ss.eof()) {
				ss >> fret;
				//cout << fret << " "; //###
				positions.push_back(fret);
			}
		}
		name_positions[name] = positions;
		positions.clear();
		name.clear();
	}
	File.close();
}


//void draw_chord() {
//	string name;
//	int x = ev.mouse.x;
//	int y = ev.mouse.y;
//	int c = (x + CAMX) / char_w;
//	int l = (y + CAMY) / char_h;
//	vector<int> positions = { -1,-1,-1,-1,-1,-1 };
//	if (s.pos_chord_info.find({ l,c }) == s.pos_chord_info.end()) {
//		return;
//	}
//	else {
//		name = s.pos_chord_info[{ l, c }].chord.get_name();
//		if (s.pos_chord_info[{ l, c }].chord.parsed) {
//			positions = name_positions[name];
//		}
//	}	
//	int lw = char_w / 4;
//	int ls = 2;
//	int x0 = ev.mouse.x;
//	int y0 = ev.mouse.y;
//	//int x = ev.mouse.x;
//	//int y = ev.mouse.y;
//	int m = 999;
//	for (auto e : positions) {
//		if (e >= 0 && e < m) {
//			m = e;
//		}
//	}	
//	name += "  " + to_string(m);
//	int tbx0;
//	int tby0;
//	
//	for (int i = 1; i <= 6; i++) {
//		al_draw_filled_rectangle(x, y0, x + lw, y0 + 5 * char_h * ls + lw, cl_chordline);
//		al_draw_filled_rectangle(x0, y, x0 + 5 * char_w * ls + lw, y + lw, cl_chordline);
//		x += char_w * ls;
//		y += char_h * ls;
//	}
//	tbx0 = x0 + lw / 2;
//	tby0 = y0 - 2 * (char_h + lw);
//	al_draw_filled_rectangle(tbx0, tby0, tbx0 + char_w * name.size(), tby0 + char_h, cl_chordline);
//	al_draw_text(fontb, cl_chordtext, x0 + lw / 2, y0 - 2 * (char_h + lw) , ALLEGRO_ALIGN_LEFT, name.c_str());
//	for (int p : positions) {
//		if (p != -1) {
//			al_draw_filled_circle(x0 + lw / 2 , y0 + p * char_h * ls - char_h / 2, char_h/2, cl_chordline);
//			
//		}
//		else {
//			al_draw_filled_rectangle(x0 + lw, y0 - char_h, x0 + lw + char_h, y0 - char_h / 2, cl_chordline);
//		}
//		x0 += char_w * ls;
//	}
//}

void draw_chord() {
	string name;
	int x = ev.mouse.x;
	int y = ev.mouse.y;

	int c = (x + CAMX) / char_w;
	int l = (y + CAMY) / char_h;

	vector<int> positions = { -1,-1,-1,-1,-1,-1 };

	if (s.pos_chord_info.find({ l,c }) == s.pos_chord_info.end()) {
		return;
	}
	else {
		name = s.pos_chord_info[{ l, c }].chord.get_name();
		if (s.pos_chord_info[{ l, c }].chord.parsed) {
			if (name_positions.find(name) == name_positions.end()) {
				name = "Add " + name + " to chords.cd";
			}
			else {
				positions = name_positions[name];
			}
			
		}
	}
	int lw = char_w / 5; // line width
	int vs = 2 * char_w; // vertical spacing
	int hs = 2 * char_w; // horizontal spacing
	int m = 999;
	for (auto e : positions) {
		if (e >= 0 && e < m) {
			m = e;
		}
	}
	if (m == 0) {
		name += "  " + to_string(m);
	}
	else {
		name += "  " + to_string(m - 1);
	}
	

	for (int i = 0; i <= 5; i++) { //draw lines
		al_draw_line(x + (i * hs), y - lw / 2, x + (i * hs), y + (5 * vs) + lw / 2, cl_chordline, lw); // vertical lines
		al_draw_line(x , y + (i * vs), x + (5 * hs), y + (i * vs), cl_chordline, lw); // horizontal lines
		//cout << positions[i] << endl;
		if (positions[i] != -1) {
			if (m == 0) {
				al_draw_filled_circle(x + (i * hs), y + (positions[i] * vs) - hs / 2, hs / 2, cl_chordline);
			}
			else {
				al_draw_filled_circle(x + (i * hs), y + ((positions[i] - m + 1) * vs) - hs/2, hs/2, cl_chordline);
			}
			
		}
		else {
			al_draw_line(x + (i * hs) - hs / 2, y - vs, x + (i * hs) + hs / 2, y, cl_chordline, hs / 4);
			al_draw_line(x + (i * hs) + hs / 2, y - vs, x + (i * hs) - hs / 2, y, cl_chordline, hs / 4);
		}
	}
	//cout << endl;
	al_draw_filled_rectangle(x , y - 2 * vs, x + char_w * name.size(), y - 2 * vs + char_h, cl_chordline);
	al_draw_text(fontb, cl_chordtext, x , y - 2 * vs, ALLEGRO_ALIGN_LEFT, name.c_str());
}

void draw_lines() {	
	auto lines = s.getlines();
	auto p0 = s.getp0();
	auto p1 = s.getp1();
	int x0 = p0.c * char_w - CAMX;
	int y0 = p0.l * char_h - CAMY;
	if (p0 == p1) {
		al_draw_filled_rectangle(x0 - char_w / 5 , y0 , x0 + char_w / 5 , y0 + char_h, cl_selection);
	}
	else {
		Pos pp0;
		Pos pp1;
		if (p0 < p1) {
			pp0 = p0;
			pp1 = p1;
		}
		else {
			pp0 = p1;
			pp1 = p0;
		}
		x0 = pp0.c * char_w - CAMX;
		y0 = pp0.l * char_h - CAMY;

		if (pp0.l == pp1.l) {
			int x1 = (pp1.c -1) * char_w - CAMX;
			//int y1 = p1.l * char_h - CAMY;
			al_draw_filled_rectangle(x0, y0, x1 + char_w, y0 + char_h, cl_selection);
		}
		else {
			int x1 = (lines[pp0.l].size() - 1) * char_w - CAMX + char_w;
			al_draw_filled_rectangle(x0, y0, x1, y0 + char_h, cl_selection);
			al_draw_filled_rectangle(-CAMX, pp1.l * char_h - CAMY, pp1.c * char_w - CAMX, pp1.l * char_h - CAMY + char_h, cl_selection);
			for (int i = pp0.l + 1; i < pp1.l; i++) {
				al_draw_filled_rectangle(-CAMX, i * char_h - CAMY, (lines[i].size() - 1) * char_w - CAMX + char_w, i * char_h - CAMY + char_h, cl_selection);
			}
		}
	}

	//al_draw_text(font, white, (p0.c - .5) * char_w - CAMX, char_h * (p0.l) - CAMY, ALLEGRO_ALIGN_LEFT, "|");
	//al_draw_text(font, blue, (p1.c - .5) * char_w - CAMX, char_h * (p1.l) - CAMY, ALLEGRO_ALIGN_LEFT, "|");

	for (unsigned i = 0; i < lines.size(); i++) {
		al_draw_text(font, white, -CAMX, char_h * i - CAMY, ALLEGRO_ALIGN_LEFT, lines[i].c_str());
	}
}

void draw_help() {
	int x = ev.mouse.x;
	int y = ev.mouse.y;
	int c = (x + CAMX) / char_w;
	int l = (y + CAMY) / char_h;
	//if (s.pos_chord_info.find({ l,c }) != s.pos_chord_info.end()) {
	//	string chordn = s.pos_chord_info[{ l, c }].chord.get_name();
	//	draw_chord(chordn);
	//	return;
	//}
	if (y <= 2 * char_h) {
		al_draw_filled_rectangle(0, 0, SW, char_h * (help.size() + 2), cl_helpback);

		al_draw_text(fontb, cl_helpfont, 2 * char_w, char_h, 0, "Shortcuts & commands:" );
		int i = 2;
		for (auto l : help) {
			al_draw_text(font, cl_helpfont, 2 * char_w, char_h * i++, 0, l.c_str());
		}
	}
}


Pos xy_to_pos() {	
	int x = ev.mouse.x;
	int y = ev.mouse.y;
	int c = (x + CAMX) / char_w;
	int l = (y + CAMY) / char_h ;

	// helper
	//auto cl = "  " + to_string(l) + " " + to_string(c) + " | " + to_string(y);
	//al_draw_text(font, red, x + 10, y - 10, ALLEGRO_ALIGN_LEFT, cl.c_str());	
	//al_draw_text(font, red, CAMX, CAMY, ALLEGRO_ALIGN_LEFT, ".CAM");
	return { l,c };
}

void change_font(int size = 20, string path = "resources\\FiraCode-Light.ttf", string pathb = "resources\\FiraCode-Medium.ttf") {
	if (size < 8) { size = 8; }
	if (size > 40) { size = 40; }
	font_size = size;
	font  = al_load_font(path.c_str(), size, 0);
	fontb = al_load_font(pathb.c_str(), size, 0);
	char_w = al_get_text_width(font, "m");
	char_h = al_get_font_ascent(font);
	char_h *= 1.2;
}

void init() {	
	al_init();
	al_init_font_addon();
	al_init_ttf_addon();	
	al_install_keyboard();
	al_install_mouse();
	al_init_primitives_addon();
	al_init_native_dialog_addon();	
	al_init_image_addon();

	queue = al_create_event_queue();

	al_set_new_display_flags(ALLEGRO_RESIZABLE);
	//al_set_new_display_flags(ALLEGRO_NOFRAME);
	window = al_create_display(SW, SH);
	icon = al_load_bitmap("resources\\icon.png");
	al_set_display_icon(window, icon);

	al_set_window_title(window, "SONG♭ 0.1.0-alpha");
	
	//al_draw_bitmap(bkgrd, 0, 0, 0);
	
	al_register_event_source(queue, al_get_display_event_source(window));
	al_register_event_source(queue, al_get_keyboard_event_source());
	al_register_event_source(queue, al_get_mouse_event_source());
	change_font();
	//cout << al_get_mouse_num_buttons() << endl;

	//int init_pam_x = 2 * char_w;
	//int init_pam_y = 2 * char_h;
}

void key_char() {
	// teste teste teste ############################################################
	//printf("%s", al_cstr(foo)); // to convert to a C string
	//ALLEGRO_USTR *foo = al_ustr_new("");
	//int unichar = ev.keyboard.unichar;
	//al_ustr_append_chr(foo, unichar);
	//char c = ev.keyboard.unichar;
	//c = 'ã';
	//const char* test_char = &c;
	//cout << al_cstr(foo) << endl;
	//al_clear_to_color(black);
	//al_draw_ustr(font, white, 50, 50, ALLEGRO_ALIGN_LEFT, foo);
	//al_flip_display();
	// teste teste teste ############################################################
	if (ev.keyboard.unichar >= 32 && ev.keyboard.unichar <= 126) {
		if (Mctrl) {
			switch (ev.keyboard.keycode)
			{
			case ALLEGRO_KEY_S:
				save(true);					
				break;
			case ALLEGRO_KEY_O:
				//cout << "load" << endl;
				load();
				break;
			case ALLEGRO_KEY_C:
				//cout << "load" << endl;
				al_set_clipboard_text(window, s.get_text().c_str());
				break;
			case ALLEGRO_KEY_V: {
				string text = al_get_clipboard_text(window);
				stringstream ss(text);
				string temp = "";
				s.remove_text(false);
				getline(ss, temp, '\n');
				s.insert_text(temp);
				//s.setp0({ s.getp0().l + 1, 0 });
				while (!ss.eof()) {
					getline(ss, temp, '\n');
					s.insert_line(temp, false);
					//cout << "temp: " << temp << endl;
				}
				s.parse();
				break;
			}
			case ALLEGRO_KEY_A:
				s.setp0({ 0,0 });
				auto lines = s.getlines();
				int el = lines.size() - 1;
				int ec = lines[el].size();
				s.setp1({ el, ec });
				break;
			}
			return;
		}
	char chr;
		s.remove_text(false);
		chr = ev.keyboard.unichar;
		s.insert_text({ chr });
		s.parse(); //##################
	}
	else {
		switch (ev.keyboard.keycode)
		{
		case ALLEGRO_KEY_DELETE:
			if (Mctrl) {
				s.remove_line();
			}
			else {
				s.remove_text();
			}			
			s.parse(); //##################
			break;
		case ALLEGRO_KEY_BACKSPACE:
			s.movep0(Dir::left);
			s.remove_text();
			s.parse(); //##################
			break;
		case ALLEGRO_KEY_UP:
			if (Mctrl) {
				s.movep1(Dir::up);
			}
			else {
				s.movep0(Dir::up);
			}			
			break;
		case ALLEGRO_KEY_DOWN:
			if (Mctrl) {
				s.movep1(Dir::down);
			}
			else {
				s.movep0(Dir::down);
			}
			break;
		case ALLEGRO_KEY_LEFT:
			if (Mctrl) {
				s.movep1(Dir::left);
			}
			else {
				s.movep0(Dir::left);
			}
			break;
		case ALLEGRO_KEY_RIGHT:
			if (Mctrl) {
				s.movep1(Dir::right);
			}
			else {
				s.movep0(Dir::right);
			}
			break;
		}
	}
}




void mouse_axes() {
	if (ev.mouse.dz == -1) { // window zooming
		change_font(--font_size);
		return;
	}
	if (ev.mouse.dz == 1) {
		change_font(++font_size);
		return;
	}
	if (Mmiddle_btn) {
		CAMX = -ev.mouse.x + init_pam_x;
		CAMY = -ev.mouse.y + init_pam_y;
		return;
	}
	if (Mleft_btn && ! selection) {	
		s.setp1(xy_to_pos());
	}
}

void mouse_button_down() {
	switch (ev.mouse.button){
	case 1:
		Mleft_btn = true;
		auto click_pos = xy_to_pos();
		if ((s.getp0() < click_pos && click_pos < s.getp1()) || (s.getp0() > click_pos && click_pos > s.getp1())) {			
			last_left_click_pos = click_pos;
			selection = true;
		}
		else {
			s.setp0(click_pos);
			selection = false;
		}
		//draw_lines();
		break;
	case 2:
		break;
	case 3:
		init_pam_x = CAMX + ev.mouse.x;
		init_pam_y = CAMY + ev.mouse.y;
		Mmiddle_btn = true;
		break;
	default:
		break;
	}
}

void mouse_button_up() {
	switch (ev.mouse.button) {
	case 1: {
		Mleft_btn = false;
		auto click_pos = xy_to_pos();
		if (selection) {
			if (click_pos != last_left_click_pos) {
				selection = false;
				auto text = s.get_text();
				s.remove_text();
				s.setp0(click_pos);
				s.insert_text(text);
				s.setp1(click_pos);
			}
			else {
				selection = false;
				s.setp0(click_pos);
				s.setp1(click_pos);
			}
			//draw_lines();
			break;
		}	
		auto delta = std::chrono::duration_cast<std::chrono::nanoseconds>(Clock.now() - last_left_click_time).count();
		//std::cout << delta << "\n";
		if (delta <= 200000000) { // 151134982
			//std::cout << "It's happening, man!\n";
			auto line = s.getlines()[s.getp0().l];
			while (s.getp0().c > 0) {
				if (line[s.getp0().c - 1] == ' ') { break; }
				s.setp0({ s.getp0().l , s.getp0().c - 1 });
			}
			while (s.getp1().c < line.size()) {
				if (line[s.getp1().c] == ' ') { break; }
				s.setp1({ s.getp1().l , s.getp1().c + 1 });
			}
			//draw_lines();
			break;
		}
		s.setp1(click_pos);
		last_left_click_time = Clock.now();
		//draw_lines();
		break; 
	}
	case 2:
		break;
	case 3:
		Mmiddle_btn = false;
		break;
	default:
		break;
	}
}

void key_down() {
	switch (ev.keyboard.keycode)
	{
	case ALLEGRO_KEY_LCTRL:
		Mctrl = true;
		break;
	case ALLEGRO_KEY_ENTER:
		//s.remove_text(false);
		s.insert_line("",false);
		break;
	}
}

void key_up() {
	switch (ev.keyboard.keycode)
	{
	case ALLEGRO_KEY_LCTRL:
		Mctrl = false;
	}
}



int main(int argc, char **argv) {
	PATH = argv[0];
	bool help = false;
	load_name_positions();
	init();	
	s.parse();
	al_clear_to_color(cl_background);
	CAMX = -2 * char_w;
	CAMY = -1 * char_h;
	draw_lines();
	al_flip_display();
	bool quit = false;
	while (!quit) {		
		al_wait_for_event(queue, &ev);
		help = false;
		al_clear_to_color(cl_background);		
		switch (ev.type) {
		case ALLEGRO_EVENT_DISPLAY_CLOSE:
			quit = true;
			break;
		case ALLEGRO_EVENT_DISPLAY_RESIZE:
			SH = al_get_display_height(window);
			SW = al_get_display_width(window);
			al_acknowledge_resize(window);
			break;
		case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
			mouse_button_down();
			break;
		case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
			mouse_button_up();
			break;
		case ALLEGRO_EVENT_KEY_DOWN:
			key_down();
			break;
		case ALLEGRO_EVENT_KEY_UP:
			key_up();
			break;
		case ALLEGRO_EVENT_MOUSE_AXES:
			help = true;
			mouse_axes();
			break;
		case ALLEGRO_EVENT_KEY_CHAR:			
			key_char();
			break;
		}
		draw_lines();
		
		if (help) {
			draw_chord();
			draw_help();
		}		
		al_flip_display();
	}
	al_destroy_display(window);
}



