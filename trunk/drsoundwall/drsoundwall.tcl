#! /usr/bin/wish -f

# drsoundwall.tcl
# taking runabc.tcl (public domain) as a starting point
# Copyright 2006, drew Roberts

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.

#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

# contact drew Roberts - zotz@100jamz.com

package require snack
package require snackogg


wm protocol . WM_DELETE_WINDOW {write_drswconf_ini; exit}
wm resizable . 0 0
global df

proc messages {msg} {
    if {[winfo exists .msg] != 0} {destroy .msg}
    toplevel .msg
    message .msg.out -text $msg
    pack .msg.out
}

proc platform {} {
global tcl_platform

    set plat $tcl_platform(platform)
    set os $tcl_platform(os)
    set osver $tcl_platform(osVersion)
    set machine $tcl_platform(machine)
    set welcome [format "Evidently you are running drsoundwall.tcl for the first \
    time. You are running the script on %s with %s version %s on a \
    %s. After closing this window you should click the config button and \
    indicate the path to the other executables called by this script.\
    See the readme file and drsoundwall.txt for more information." \
     $plat $os $osver $machine]
    messages $welcome
}

proc new_version {} {
    set new "IMPORTANT. This message will appear only once, so you \
should read it carefully. If you want to read it again, you will have \
to search for the string IMPORTANT in the drsoundwall.tcl script using any \
editor.\n\n This version of drsoundwall has  several new features."
   messages $new
}



# default values for options
proc drswconf_init {} {
global drswconf df

    set drswconf(version) 0.01
    set drswconf(font_family) [font actual . -family]
    set drswconf(font_family_toc) Terminal
    set drswconf(font_size) [font actual . -size] 
    set drswconf(font_weight) [font actual . -weight]
    set df [font create -family $drswconf(font_family) -size $drswconf(font_size) \
     -weight $drswconf(font_weight)] 
    set drswconf(path_gs) c:/gstools/gsview/gsview32
    set drswconf(drswconfplay_options) ""
    set drswconf(drswconf_dir) "tmp"
    set drswconf(path_editor) ""


    # open/save parameters
    
	# the real parameters by dR
	foreach c {0 1 2 3 4 5  6 7 8 9} {
		foreach r {0 1 2 3 4 5  6 7 8 9} {
			set drswconf(sndf$c$r) ./1.mp3
			set drswconf(sndt$c$r) Cut:C$c:R$r
			set drswconf(playb$c$r) 1
			# set drswconf(fg$c$r) Black
			switch -- $c {
				0 {set drswconf(bg$c$r) LightBlue}
				1 {set drswconf(bg$c$r) Red}
				2 {set drswconf(bg$c$r) Green}
				3 {set drswconf(bg$c$r) Yellow}
				4 {set drswconf(bg$c$r) LightBlue}
				5 {set drswconf(bg$c$r) Red}
				6 {set drswconf(bg$c$r) Green}
				7 {set drswconf(bg$c$r) Yellow}
				8 {set drswconf(bg$c$r) LightBlue}
				9 {set drswconf(bg$c$r) Red}
			}
			switch -- $c {
				0 {set drswconf(fg$c$r) Yellow}
				1 {set drswconf(fg$c$r) Black}
				2 {set drswconf(fg$c$r) Black}
				3 {set drswconf(fg$c$r) Black}
				4 {set drswconf(fg$c$r) Yellow}
				5 {set drswconf(fg$c$r) Black}
				6 {set drswconf(fg$c$r) Black}
				7 {set drswconf(fg$c$r) Black}
				8 {set drswconf(fg$c$r) Yellow}
				9 {set drswconf(fg$c$r) Black}
			}
		}	
	}

	set drswconf(play_mode) 1
	set drswconf(edit_mode) 0    
    
}


# save all options, current soundwall file
proc write_drswconf_ini {} {
global drswconf df

    set handle [open drswconf.ini w]
    foreach item [lsort [array names drswconf]] {
	puts $handle "$item $drswconf($item)"
    }
    close $handle
}

# read all options
proc read_drswconf_ini {} {
global drswconf df
    set handle [open drswconf.ini r]
    while {[gets $handle line] >= 0} {
	set n [llength $line]
	set contents "" 
	set param [lindex $line 0]
	for {set i 1} {$i < $n} {incr i} {
	  set contents [concat $contents [lindex $line $i]]
	}
#if param is not already a member of the midi array (set by midi_init),
#then we ignore it. This prevents midi array filling up with obsolete
#parameters used in older versions of the program.
        set member [array names drswconf $param]
        if [llength $member] { set drswconf($param) $contents }
        if {$param == "font"} {new_version}
    }
font configure $df -family $drswconf(font_family) -size $drswconf(font_size) \
     -weight $drswconf(font_weight) 
}

# init global variables
#set types {{{abc files} {*.abc}}
#           {{all} {*}}}
#set miditype {{{midi files} {*.mid}}}
#set exec_out "This window show messages produced by play and display commands."

drswconf_init


if [file exists drswconf.ini] {
    read_drswconf_ini
} else {
    platform
}

    #######################
    #     Tk Interface    #
    #######################

###     Control Functions    ######

frame .drsw
frame .drsw.file
frame .drsw.functions -borderwidth 2
frame .drsw.auxfunc   -borderwidth 2
foreach l {0 1 2 3 4 5  6 7 8 9} {
	frame .drsw.l$l   -borderwidth 2
}
#frame .drsw.l0   -borderwidth 2
frame .drsw.titles

wm title . "drew's SoundWall"

#set play and edit button colors
switch $drswconf(play_mode) {
	0 {set playcolor red}
	1 {set playcolor green}
}

switch $drswconf(edit_mode) {
	0 {set editcolor red}
	1 {set editcolor green}
}

# first row of buttons
button .drsw.functions.quit  -text quit     -command {write_drswconf_ini; exit} -font $df
button .drsw.functions.play  -text "play mode"    -command play_action              -font $df	-background $playcolor
button .drsw.functions.edit  -text "edit mode"  -command edit_action           -font $df	-background $editcolor
#button .drsw.functions.help     -text help   -command contexthelp -font $df
button .drsw.functions.help     -text help   -command hlpovershow -font $df


foreach c {0 1 2 3 4 5  6 7 8 9} {
	foreach r {0 1 2 3 4 5  6 7 8 9} {
		button .drsw.l$c.$r	-width 12 -text $drswconf(sndt$c$r)	-command "play$c$r $c $r"	-font $df
		.drsw.l$c.$r configure -background $drswconf(bg$c$r)
		.drsw.l$c.$r configure -foreground $drswconf(fg$c$r)
		snack::sound snd$c$r -file $drswconf(sndf$c$r)
	}
}


pack .drsw.functions.quit .drsw.functions.play  \
 .drsw.functions.edit -side left -fill y
pack .drsw.functions.help  -side left 

foreach c {0 1 2 3 4 5  6 7 8 9} {
	foreach r {0 1 2 3 4 5  6 7 8 9} {
		pack .drsw.l$c.$r -side top -fill y
	}
}

pack .drsw.functions -side top
foreach c {0 1 2 3 4 5  6 7 8 9} {
	pack .drsw.l$c   -side left
}
pack .drsw


foreach c {0 1 2 3 4 5  6 7 8 9} {
	foreach r {0 1 2 3 4 5  6 7 8 9} {
		proc play$c$r {c r} {
		global drswconf df
			switch -- $drswconf(play_mode) {
				1 {playstop $c $r}
				0 {butn_edit $c $r}
			}
		}
	}
}






set hlp_overview "This is you help file \
Do you like it?\n\n"


proc hlpovershow {} {
	puts $hlp_overview
}

proc play_action {} {
global drswconf df
	set drswconf(play_mode) 1
	set drswconf(edit_mode) 0
	set playcolor green
	set editcolor red
	.drsw.functions.play configure -background $playcolor
	.drsw.functions.edit configure -background $editcolor
}

proc edit_action {} {
global drswconf df
	set drswconf(play_mode) 0
	set drswconf(edit_mode) 1
	set playcolor red
	set editcolor green
	.drsw.functions.play configure -background $playcolor
	.drsw.functions.edit configure -background $editcolor
}



proc butn_edit {c r} {
global drswconf df
    if {[winfo exists .bedt] != 0} {destroy .bedt}
    toplevel .bedt
	wm title .bedt "Button Edit"
	puts "butn_edit - "
	puts $c$r
	puts "\n"
	frame .bedt.b
	button .bedt.b.fg -text "Change Button Forground" -command "get_fg $c $r"
	button .bedt.b.bg -text "Change Button Background" -command "get_bg $c $r"
	button .bedt.b.file -text "Choose Button Cut" -command "get_cut $c $r"
	button .bedt.b.labl -text "Set Button Label" -command "set_labl $c $r"
	# button .bedt.b.done -text "Quit" -command exit
    #message .msg.out -text $msg
    pack .bedt.b .bedt.b.fg .bedt.b.bg .bedt.b.file .bedt.b.labl

}

proc get_fg {c r} {
global drswconf df
	set initialColor $drswconf(fg$c$r)
	set color [tk_chooseColor -title "Choose a foreground color" \
	-initialcolor $initialColor]
	set drswconf(fg$c$r) $color
	.drsw.l$c.$r configure -foreground $drswconf(fg$c$r)
}

proc get_bg {c r} {
global drswconf df
	set initialColor $drswconf(bg$c$r)
	set color [tk_chooseColor -title "Choose a background color" \
	-initialcolor $initialColor]
	set drswconf(bg$c$r) $color
	.drsw.l$c.$r configure -background $drswconf(bg$c$r)
}

proc get_cut {c r} {
global drswconf df
    #   Type names		Extension(s)	Mac File Type(s)
    #
    #---------------------------------------------------------
    set types {
	{"Audio files"		{.wav .mp3 .ogg}	}
	{"WAV files"		{.wav}	}
	{"MP3 files"		{.mp3}	}
	{"OGG files"		{.ogg}	}
	{"All files"		*}
    }
	puts $drswconf(sndf$c$r)
	set drswconf(sndf$c$r) [tk_getOpenFile -filetypes $types]
	snd$c$r configure -file $drswconf(sndf$c$r)
	set gclablf [file tail $drswconf(sndf$c$r)]
	set gclable [string last . $gclablf]
	set gclabl [string range $gclablf 0 [expr $gclable - 1]]
	set drswconf(sndt$c$r) $gclabl
	.drsw.l$c.$r configure -text $drswconf(sndt$c$r)
	puts $drswconf(sndf$c$r)
	puts drswconf(sndt$c$r)
}


proc set_labl {c r} {
global drswconf df
    if {[winfo exists .tedt] != 0} {destroy .tedt}
    toplevel .tedt
	wm title .tedt "Cut Edit Label"
	puts "set_labl - "
	puts $c$r
	puts "\n"
	#set cc_labl "boo"
	frame .tedt.b
	entry .tedt.b.c_labl
	#button .tedt.b.setBtn -text "Set" -command {set cc_labl [.tedt.b.c_labl get]}
	button .tedt.b.setBtn -text "Set" -command "new_labl $c $r"
	pack .tedt.b .tedt.b.c_labl .tedt.b.setBtn
	.tedt.b.c_labl insert 0 $drswconf(sndt$c$r)
	#set drswconf(sndt$c$r) $cc_labl
	#.drsw.l$c.$r configure -text $drswconf(sndt$c$r)

}

proc new_labl {c r} {
global drswconf df
	set cc_labl [.tedt.b.c_labl get]
	set drswconf(sndt$c$r) $cc_labl
	.drsw.l$c.$r configure -text $drswconf(sndt$c$r)
}

proc playstop {c r} {
global drswconf df
	# this is working after a fashion, but I need to reset to 1 if sound plays all the way through
	# I need help with getting this to work right, can anyone give some hints?
	switch -- $drswconf(playb$c$r) {
		1 {puts "before play $drswconf(playb$c$r)"; snd$c$r play -command "playdone$c$r $c $r"; set drswconf(playb$c$r) 0; puts "right after play started $drswconf(playb$c$r)"; .drsw.l$c.$r configure -relief sunken}
		#1 {puts "before play $drswconf(playb$c$r)"; snd$c$r play -command "playdone$c$r $c $r"; set drswconf(playb$c$r) 0; puts "right after play started $drswconf(playb$c$r)"; .drsw.l$c.$r configure -relief sunken}
		0 {snd$c$r stop; set drswconf(playb$c$r) 1; .drsw.l$c.$r configure -relief raised; snd$c$r configure -file $drswconf(sndf$c$r)}
	}
	#update idletasks

}

#proc playdone {c r} {
#global drswconf df
#	#update idletasks
#	set drswconf(playb$c$r) 1
#	snd$c$r configure -file $drswconf(sndf$c$r)
#	.drsw.l$c.$r configure -relief raised
#	#update idletasks
#	puts "set playb$c$r back to $drswconf(playb$c$r) after play finished"
#}


foreach c {0 1 2 3 4 5  6 7 8 9} {
	foreach r {0 1 2 3 4 5  6 7 8 9} {
		proc playdone$c$r {c r} {
		global drswconf df
			set drswconf(playb$c$r) 1
			snd$c$r configure -file $drswconf(sndf$c$r)
			.drsw.l$c.$r configure -relief raised
			puts "set playb$c$r back to $drswconf(playb$c$r) after play finished"
		}
	}
}


#drswconf(sndf$c$r)
#set drswconf(playb$c$r) 1
#drswconf(sndt$c$r)
#drswconf(sndf$c$r)
# 	.drsw.l$c.$r configure -foreground $drswconf(fg$c$r)
