# AutoHotKey 2 MIDI

This is an AutoHotKey script that translates MIDI messages into keystrokes.
 - AHK reads incoming MIDI messages and displays them in a small desktop window
 - AHK sends out a keystroke, dependent on which MIDI message was received
 - The currently open app receives these as if they were typed on the keyboard
 
This way any MIDI device with pushbuttons, knobs and sliders can be used as a hardware console to operate any Windows app.
 
Included are
 - AHK script with shortcuts to operate the DaVinci Resolve video editor via the Behringer X Touch One.
 - A Bome MIDI Translator configuration file in case you prefer to use the [Bome app](https://www.bome.com/products/miditranslator).
 - AHK script to control Magix Video Pro X, added by Erich Grubmüller.
 
Keystrokes can be changed to your liking via the 'if' statements from line 40 onwards.
 
YouTube videos with further explanation:
<ol>
 <li>https://www.youtube.com/watch?v=Y3gow1TlL78</li>
 <li>https://www.youtube.com/watch?v=D-Wvf4HNBnU</li>
 <li>https://www.youtube.com/watch?v=h0IZiYEkvLg</li>
</ol>
 
I like to mention I didn't program the MIDI tranlation part of the AutoHotKey script.
I found it [here]{https://github.com/genmce/AHK_Midi2Keypress}. Author unknown.
What I added are the X Touch One > DaVinci shortcuts.
 
Have fun.

Rudy Boer, February 2022
 
