;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; Ruud Boer, January 2022
;
; https://github.com/RudyB24/AHK_XTouchOne_DaVinciResolve.git 
; MIDI events received from the Behringer X Touch One are transferred into
; keyboard shortcuts for DaVinci Resolve (or any other app you'd wish to use)
; Based on https://github.com/genmce/AHK_Midi2Keypress ... author unknown
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#Persistent
#SingleInstance, force
SetTitleMatchMode, 2
SendMode Input              	; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% 	; Ensures a consistent starting directory.
; =============== 
  version = Midi2keypress_1.0 ; Change this title to suit you, will generate .ini file with port selection
; =============== 
readini()					            ; load midi port from .ini file 
gosub, MidiPortRefresh        ; used to refresh the input and output port lists - see label below 
port_test(numports)   		    ; test the ports - check for valid ports?
gosub, midiin_go              ; opens the midi input port listening routine
gosub, midiMon           	    ; see below - a midi monitor gui - for learning mostly - comment this line eventually.

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; MidiMsgDetect is called each time a MIDI message is received.
; The MIDI message is broken up into 5 variables: statusbyte, chan, data1, data2 ,pitchb.
; See http://www.midi.org/techspecs/midimessages.php (decimal values).
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

MidiMsgDetect(hInput, midiMsg, wMsg) ; !!!! Midi input section in calls this function each time a midi message is received. Then the midi message is broken up into parts for manipulation.  See http://www.midi.org/techspecs/midimessages.php (decimal values).
{
	global statusbyte, chan, note, cc, data1, data2, stb ;Make these vars global to be used in other functions
	statusbyte :=  midiMsg & 0xFF          ; Extract statusbyte = what type of MIDI message and what channel
	chan       := (statusbyte & 0x0f) + 1  ; The MIDI channel
	data1      := (midiMsg >> 8) & 0xFF    ; data1 is Note # or CC #
	data2      := (midiMsg >> 16) & 0xFF   ; data2 is Velocity or CC value
	pitchb     := (data2 << 7) | data1     ; (midiMsg >> 8) & 0x7F7F  masking to extract the pitchbends  

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; ADD YOUR OWN INSTRUCTIONS HERE USING: if (data1=... [and/or data2=...) Send ...
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	if statusbyte between 176 and 191  ;MIDI CC
  {
    stb := "CC" ;The stb variable is used for the MIDI Monitor display
    if (data1=60 and data2=65)
      Send +{Left} ; Jog wheel left = Left 1s
    if (data1=60 and data2=1)
      Send +{Right} ; Jog wheel right = Right 1s
    if (data1=16 and data2=65)
      Send {Left} ; Pan knob left = Left 1 frame
    if (data1=16 and data2=1)
      Send {Right} ; Pan knob right = Right 1 frame
  }
	if statusbyte between 144 and 159  ;MIDI NoteOn
  {
		stb := "NoteOn"
    if (data1=46 and data2=127) ; Bank Left = Clip In point
      Send i
    if (data1=47 and data2=127) ; Bank Right = Clip Out point
      Send o
    if (data1=54 and data2=127) ; F1 = Append at End
      Send +{F12}
    if (data1=55 and data2=127) ; F2 = Insert
      Send {F9}
    if (data1=56 and data2=127) ; F3 = Place on Top
      Send {F12}
    if (data1=57 and data2=127) ; F4 = Replace
      Send +{F11}
    if (data1=58 and data2=127) ; F5 = Overwrite
      Send {F10}
    if (data1=53 and data2=127) ; F6 = Ripple Overwrite
      Send +{F10}
    if (data1=84 and data2=127) ; Marker = place marker on timeline
      Send m
    if (data1=85 and data2=127) ; Nudge = Trim Edit Mode
      Send t
    if (data1=86 and data2=127) ; Cycle = Dynamic Trim Mode
      Send m
    if (data1=87 and data2=127) ; Drop = Cut Blade
      Send b
    if (data1=88 and data2=127) ; Replace = Magnet Snap Toggle
      Send n
    if (data1=89 and data2=127) ; Click = Undo
      Send ^z
    if (data1=90 and data2=127) ; Solo = Redo
      Send ^+z
    if (data1=96 and data2=127) ; Up = Zoom in
      Send ^{+}
    if (data1=97 and data2=127) ; Down = Zoom out
      Send ^-
    if (data1=98 and data2=127) ; Left = Cursor to previous edit
      Send {Up}
    if (data1=99 and data2=127) ; Down = Cursor to next edit
      Send {Down}
    if (data1=91 and data2=127) ; << = Fast rewind
      Send +j
    if (data1=92 and data2=127) ; >> = Fast forward
      Send +l
    if (data1=93 and data2=127) ; Stop = Stop
      Send k
    if (data1=94 and data2=127) ; Play = Play / Pause
      Send {Space}
    if (data1=101 and data2=127) ; Scrub = Audio scrub
      Send +s
    if (data1=100 and data2=127) ; Zoom = Zoom toggle
      Send +z
    if (data1=102 and data2=127) ; Foot switch Play / Pause
      Send {Space}
  }
	if statusbyte between 128 and 143 ;MIDI NoteOff
  {
		stb := "NoteOff"
  }
	if statusbyte between 192 and 208 ;MIDI Program Change
  {
		stb := "PC"
  }
	if statusbyte between 224 and 254 ;MIDI Pitch Bend
  {
    stb := "PitchB"
  }
	MidiInDisplay(stb, statusbyte, chan, data1, data2) ; midi display function called when message received
} ; end of MidiMsgDetect funciton
return

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; NO NEED TO EDIT ANYTHING BELOW HERE
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

MidiInDisplay(stb, statusbyte, chan, data1, data2) ; update the midimonitor gui
{
Gui,3:default
Gui,3:ListView, In1 					; see the first listview midi in monitor
  LV_Add("",stb,statusbyte,chan,data1,data2)
  LV_ModifyCol(1,"center")
  LV_ModifyCol(2,"center")
  LV_ModifyCol(3,"center")
  LV_ModifyCol(4,"center")
  LV_ModifyCol(5,"center")
  If (LV_GetCount() > 10)
    {
      LV_Delete(1)
    }
}
return

midiMon: ; midi monitor gui with listviews
gui,3:destroy
gui,3:default
Gui,3:Add, ListView, x5 r11 w220 Backgroundblack cyellow Count10 vIn1,  EventType|StatB|Ch|data1|data2| 
gui,3:Show, autosize xcenter y5, MidiMonitor

return

MidiPortRefresh: 				; get the list of ports !!!! nothing to edit here

MIlist := MidiInsList(NumPorts) 
Loop Parse, MIlist, | 
{
}
TheChoice := MidiInDevice + 1
return

;-----------------------------------------------------------------

ReadIni() ; also set up the tray Menu !!!! Nothing to edit here
{
	Menu, tray, add, MidiSet            ; set midi ports tray item 
	Menu, tray, add, ResetAll           ; Delete the ini file for testing --------------------------------
	
	global MidiInDevice, version ; version var is set at the beginning.
	IfExist, %version%.ini
	{
		IniRead, MidiInDevice, %version%.ini, Settings, MidiInDevice , %MidiInDevice%     ; read the midi In port from ini file
	}
	Else ; no ini exists and this is either the first run or reset settings.
	{
		MsgBox, 1, No ini file found, Select midi ports?
		IfMsgBox, Cancel
			ExitApp
		IfMsgBox, yes
			gosub, midiset
	}
}

;CALLED TO UPDATE INI WHENEVER SAVED PARAMETERS CHANGE - !!!! nothing to edit here
WriteIni()
{
	global MidiInDevice, version 		; global vars needed
	
	IfNotExist, %version%.ini 		; does .ini file exist? 
		FileAppend,, %version%.ini 	; make one with name of the .ahk file and the following entries.
	IniWrite, %MidiInDevice%, %version%.ini, Settings, MidiInDevice
}

;------------ port testing to make sure selected midi port is valid --------------------------------

port_test(numports) ; confirm selected ports exist - !!!!! nothing to edit here

{
	global midiInDevice, midiok ;midiOutDevice
	
	; ----- In port selection test based on numports
	If MidiInDevice not Between 0 and %numports% 
		{
			MidiIn := 0 ; this var is just to show if there is an error - set if the ports are valid = 1, invalid = 0
			;MsgBox, 0, , midi in port Error ; (this is left only for testing)
			If (MidiInDevice = "")              ; if there is no midi in device 
				MidiInerr = Midi In Port EMPTY. ; set this var = error message
			;MsgBox, 0, , midi in port EMPTY
			If (midiInDevice > %numports%)          ; if greater than the number of ports on the system.
				MidiInnerr = Midi In Port Invalid.  ; set this error message
			;MsgBox, 0, , midi in port out of range
		}
	Else
		{
			MidiIn := 1 ; setting var to non-error state or valid
		}

	If (%MidiIn% = 0)
	{
		MsgBox, 49, Midi Port Error!,%MidiInerr%`nLaunch Midi Port Selection!
		IfMsgBox, Cancel
			ExitApp
		midiok = 0 ; Not sure if this is really needed now....
		Gosub, MidiSet ;Gui, show Midi Port Selection
	}
	Else
	{
		midiok = 1
		Return ; DO NOTHING - PERHAPS DO THE NOT TEST INSTEAD ABOVE.
	}
}
return

; ------------------ end of port testing ---------------------------

MidiSet: ; midi port selection gui

; ------------- MIDI INPUT SELECTION -----------------------

Gui, 1: +LastFound +AlwaysOnTop   +Caption +ToolWindow ;-SysMenu
Gui, 1: Font, s12
Gui, 1: add, text, x10 y8 w200 cmaroon, Select Midi Input ; Text title
Gui, 1: Font, s9
Gui, 1: font, s9
Gui, 1: Add, ListBox, x10 w175 h100  Choose%TheChoice% vMidiInPort gDoneInChange AltSubmit, %MiList% ; --- midi in listing of ports

Gui, 1: add, Button, x10 w80 gSet_Done, Done - Reload
Gui, 1: add, Button, xp+80 w80 gCancel, Cancel
Gui, 1: show , , %version% Midi Input ; main window title and command to show it.

Return

;~ ------------------------------- methods to save midi port selection -----------------------------

DoneInChange:
Gui, 1: Submit, NoHide
Gui, 1: Flash
If %MidiInPort%
	UDPort:= MidiInPort - 1, MidiInDevice:= UDPort ; probably a much better way do this, I took this from JimF's qwmidi without out editing much.... it does work same with doneoutchange below.
GuiControl, 1:, UDPort, %MidiIndevice%
WriteIni()		; Write .ini file in same folder as ahk file 
Return

Set_Done: 		; aka reload program, called from midi selection gui
Gui, 1: Destroy
sleep, 100
Reload
Return

Cancel:
Gui, Destroy
Gui, 2: Destroy
Return

ResetAll: 		; for development only, leaving this in for a program reset if needed by user
MsgBox, 33, %version% - Reset All?, This will delete ALL settings`, and restart this program!
IfMsgBox, OK
{
	FileDelete, %version%.ini   ; delete the ini file to reset ports, probably a better way to do this ...
	Reload                      ; restart the app.
}
IfMsgBox, Cancel
	Return

GuiClose: 		; on x exit app
Suspend, Permit 	; allow Exit to work Paused. I just added this yesterday 3.16.09 Can now quit when Paused.

MsgBox, 4, Exit %version%, Exit %version% %ver%? ; 
IfMsgBox No
	Return
Else IfMsgBox Yes
Gui, 6: Destroy
Gui, 2: Destroy
Gui, 3: Destroy
Sleep 100

ExitApp


;~ -------------------------------------------------------------------------------------------------
;~ -----------------------        Original work by lots of ahk gurus        ------------------------
;~ ----------------------- DO NOT EDIT - unless you know what you are doing ------------------------
;~ -----------------------                                                  ------------------------
;~ -------------------------------------------------------------------------------------------------

;############################################## MIDI LIB from orbik and lazslo#############
;-------- orbiks midi input code --------------
; Set up midi input and callback_window based on the ini file above.
; This code copied from ahk forum Orbik's post on midi input

; nothing below here to edit. !!!!!!!!!!!!
; =============== midi in =====================

Midiin_go:
DeviceID := MidiInDevice      ; midiindevice from IniRead above assigned to deviceid
CALLBACK_WINDOW := 0x10000    ; from orbiks code for midi input

Gui, +LastFound 	; set up the window for midi data to arrive.
hWnd := WinExist()	;MsgBox, 32, , line 176 - mcu-input  is := %MidiInDevice% , 3 ; this is just a test to show midi device selection

hMidiIn =
VarSetCapacity(hMidiIn, 4, 0)
result := DllCall("winmm.dll\midiInOpen", UInt,&hMidiIn, UInt,DeviceID, UInt,hWnd, UInt,0, UInt,CALLBACK_WINDOW, "UInt")
If result
	{
		MsgBox, Error, midiInOpen Returned %result%`n
		;GoSub, sub_exit
	}

hMidiIn := NumGet(hMidiIn) ; because midiInOpen writes the value in 32 bit binary Number, AHK stores it as a string
result := DllCall("winmm.dll\midiInStart", UInt,hMidiIn)
If result
	{
		MsgBox, Error, midiInStart Returned %result%`nRight Click on the Tray Icon - Left click on MidiSet to select valid midi_in port.
		;GoSub, sub_exit
	}

OpenCloseMidiAPI()

; ----- the OnMessage listeners ----

; #define MM_MIM_OPEN 0x3C1 /* MIDI input */
; #define MM_MIM_CLOSE 0x3C2
; #define MM_MIM_DATA 0x3C3
; #define MM_MIM_LONGDATA 0x3C4
; #define MM_MIM_ERROR 0x3C5
; #define MM_MIM_LONGERROR 0x3C6

OnMessage(0x3C1, "MidiMsgDetect")  ; calling the function MidiMsgDetect in get_midi_in.ahk
OnMessage(0x3C2, "MidiMsgDetect")  
OnMessage(0x3C3, "MidiMsgDetect")
;OnMessage(0x3C4, "MidiMsgDetect")
;OnMessage(0x3C5, "MidiMsgDetect")
;OnMessage(0x3C6, "MidiMsgDetect")

Return

;*************************************************
;*          MIDI IN PORT HANDLING
;*************************************************

MidiInsList(ByRef NumPorts)                                             ; should work for unicode now... 
  { ; Returns a "|"-separated list of midi output devices
	local List, MidiInCaps, PortName, result, midisize
	(A_IsUnicode)? offsetWordStr := 64: offsetWordStr := 32
	midisize := offsetWordStr + 18
	VarSetCapacity(MidiInCaps, midisize, 0)
	VarSetCapacity(PortName, offsetWordStr)                       ; PortNameSize 32

	NumPorts := DllCall("winmm.dll\midiInGetNumDevs") ; #midi output devices on system, First device ID = 0

	Loop %NumPorts%
      {
        result := DllCall("winmm.dll\midiInGetDevCaps", "UInt",A_Index-1, "Ptr",&MidiInCaps, "UInt",midisize)
    
        If (result OR ErrorLevel) {
            List .= "|-Error-"
            Continue
          }
    PortName := StrGet(&MidiInCaps + 8, offsetWordStr)
        List .= "|" PortName
      }
    Return SubStr(List,2)
  }

MidiInGetNumDevs() { ; Get number of midi output devices on system, first device has an ID of 0
    Return DllCall("winmm.dll\midiInGetNumDevs")
  }
MidiInNameGet(uDeviceID = 0) {                  ; Get name of a midiOut device for a given ID

;MIDIOUTCAPS struct
;    WORD      wMid;
;    WORD      wPid;
;    MMVERSION vDriverVersion;
;    CHAR      szPname[MAXPNAMELEN];
;    WORD      wTechnology;
;    WORD      wVoices;
;    WORD      wNotes;
;    WORD      wChannelMask;
;    DWORD     dwSupport;

    VarSetCapacity(MidiInCaps, 50, 0)               ; allows for szPname to be 32 bytes
    OffsettoPortName := 8, PortNameSize := 32
    result := DllCall("winmm.dll\midiInGetDevCapsA", UInt,uDeviceID, UInt,&MidiInCaps, UInt,50, UInt)

    If (result OR ErrorLevel) {
        MsgBox Error %result% (ErrorLevel = %ErrorLevel%) in retrieving the name of midi Input %uDeviceID%
        Return -1
      }

    VarSetCapacity(PortName, PortNameSize)
    DllCall("RtlMoveMemory", Str,PortName, Uint,&MidiInCaps+OffsettoPortName, Uint,PortNameSize)
    Return PortName
  }

MidiInsEnumerate() { ; Returns number of midi output devices, creates global array MidiOutPortName with their names
    local NumPorts, PortID
    MidiInPortName =
    NumPorts := MidiInGetNumDevs()

    Loop %NumPorts% {
        PortID := A_Index -1
        MidiInPortName%PortID% := MidiInNameGet(PortID)
      }
    Return NumPorts
  }


OpenCloseMidiAPI() {  ; at the beginning to load, at the end to unload winmm.dll
	static hModule
	If hModule
		DllCall("FreeLibrary", UInt,hModule), hModule := ""
	If (0 = hModule := DllCall("LoadLibrary",Str,"winmm.dll")) {
		MsgBox Cannot load libray winmm.dll
		Exit
	}
}

