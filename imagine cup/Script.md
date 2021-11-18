# Intro

Hello, how are you doing?

My name is Carlos, I'm a phd candidate at the Fluminense Federal University here in Rio de Janeiro, Brazil.

I love music, and my research is in leveraging artificial intelligence for sound synthesis. 

But, for the last couple of weeks, I've been working in something else. When I heard that this Imagine Cup would be the twentieth

By now you must be curious to actually see the app in action

# Voiceover

The first thing you wanna do is grab a version of the app


github.com/tesserato/Mark-Book


Now I'll show you a quick overview of the functionalities of the program. For that we will be using the Windows version of the app. Just click the link, download and run the installer, and you are good to go. All versions behave in the same way.




So, as you can see, in the left panel we have the raw markup that we can edit. This is automatically rendered in the right panel.

The first time you run the app, a readme text shows, with instructions and a sample songbook


you can change the theme, 
collapse each song, 
resize or hide the panels,
resize the fonts of each panel 
and enable or disable the line markers. 

hovering over a chord shows its diagram. You can also change the size of this diagram in the settings. 



As the installer isn't signed, you can see security prompts during installation.



Now, the markup language. It is very simple:

The exclamation mark begins a new song.

lines beginning with a hash are visible comments.

Lines that start are invisible comments and won't be rendered.

Lines starting with square brackets are chord definitions. You can read more about the format in the github repository
##
Lines starting with a greater than sign are chord lines. The app interprets each word in those lines as chord names

lines without a marker are lyrics lines