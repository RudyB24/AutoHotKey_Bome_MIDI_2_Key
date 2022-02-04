# AHK_XTouchOne_DaVinciResolve

This is an AutoHotKey script that translates MIDI messages into keystrokes
 - reads incoming MIDI messages and displays them in a small desktop window
 - sends out a keystroke, dependent on which MIDI message was received
 - the currently open app receives these as if they were typed on the keyboard
 
 This way any MIDI device with its pushbuttons and knobs and sliders can be used as a hardware
 console to operate any Windows app.
 
 This particular AHK script contains shortcuts to operate the DaVinci Resolve
 video editor with the Behringer X Touch One.
 
 Also included is a Bome MIDI Translator configuration file in case you prefer to use the Bome app.
 
 Keystrokes can be changed to your liking via the 'if' statements from line 40 onwards.
 
 I like to mention I didn't program the MIDI tranlation part of this script.
 I found it here: https://github.com/genmce/AHK_Midi2Keypress ... author unknown
 What I added are the X Touch One > DaVinci shortcuts.
 
 Have fun.
 Rudy Boer, February 2022
 
