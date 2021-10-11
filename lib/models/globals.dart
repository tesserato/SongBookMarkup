import 'package:flutter/material.dart';
import '../widgets/custom_expansion_tile.dart';

Set<GlobalKey<CustomExpansionTileState>> tiles = {};

final TextEditingController controller = TextEditingController(text: _rawText);

String _rawText = '''
! 1 Song's title (Start a new song with "!")

# Artist's name ("Start a visible comment with "#")
# Composer's name 

|comment (Lines starting with "|" won't be rendered)

|chord definitions
[0 4 x 2 5 0] A
       [x;x,2 2  2 2]      A6
| OR
[002420]A/B

|chord line, (line starting with ">")
>A       A/B          A6        D7 
|text line
There is a house down in New Orleans 
There is a house down in New Orleans 
>    G               D 
They call the Rising Sun  
>D                           G 
And it's been the ruin of a many poor boy 
>     D       A          D 
And me, oh God , for one 
 
>D                        D7 
>D                        D7 
Then fill the glasses to the brim 
>        G                   D 
Let the drinks go merrily around 
>D                                  G 
And we'll drink to the health of a rounder poor boy 
>    D         A7       D 
Who goes from town to town 

! 2 Song's title (Start a new song with "!")

# Artist's name ("Start a visible comment with "#")
# Composer's name 

|comment (Lines starting with "|" won't be rendered)

|chord definitions
[0 4 x 2 5 0] A
       [x;x,2 2  2 2]      A6
| OR
[002420]A/B

|chord line, (line starting with ">")
>A       A/B          A6        D7 
|text line
There is a house down in New Orleans 
There is a house down in New Orleans 
>    G               D 
They call the Rising Sun  
>D                           G 
And it's been the ruin of a many poor boy 
>     D       A          D 
And me, oh God , for one 
 
>D                        D7 
>D                        D7 
Then fill the glasses to the brim 
>        G                   D 
Let the drinks go merrily around 
>D                                  G 
And we'll drink to the health of a rounder poor boy 
>    D         A7       D 
Who goes from town to town 
''';
