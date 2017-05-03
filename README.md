# Snek
Basic snake game written in COBOL.

## Building
### Installing Open COBOL
`sudo apt-get install open-cobol`
I used 1.1.0 while developing this.

### Compiling
`make`

## Playing
w/a/s/d are used to move the snake around.
Sadly due to ncurses not playing nice, I was unable to get non-blocking input
working.
q will exit the game.
