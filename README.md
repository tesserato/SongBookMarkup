# MarkBook
Carry your guitar songbook in your pocket

Mark Book is an app that implements a very simple markup language, akin to markdown, to generate songbooks.

Yet another songbook app (that's my third attempt). I've been pondering this concept for a long time now, and the idea now is to consolidate an opinionated app, with a minimalistic design and a concise set of features that just works, out of the box.

The field of app development went a long way since my last attempt, and now I chose to realize it in flutter.

The idea is to make operation as simple as possible, with the shallowest learning curve. Chords are generated on the fly, and the best possible fingering for each song is chosen automatically.

# features

# limitations

Flutter is a great library, and made it possible to make those 3 app with a single codebase. It was, however, initially designed with mobile in mind, and it shows.

- area of chords
- undo
- keyboard shortcuts
- textfield scrollbar


# links

## Web App

https://markbookapp.z13.web.core.windows.net/
https://markbookapp-secondary.z13.web.core.windows.net/
https://markbook-app.web.app/#/

## PWA
https://markbook-app.web.app/#/

# Symbols:

! - Starts a new song
\# - visible comment
| invisible comment
\> chord line

# Tips

- Defined chords fingerings have priority over inferred fingerings

# Tips

## Change windows bar name:
!window.CreateAndShow in runner/main.cpp


