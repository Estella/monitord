tclmon-module ircdtools {

proc disabled {} {
	foreach v {n uh h c t} {upvar 1 $v} 
	if {![istrue [mgetconf enabled]]} {
		putprivmsg $c ircdtools "The module this command comes from is disabled." $n
		return 1
	}	{ return 0 }
}

func m_rehash {
	if {[disabled]} {return}
	putprivmsg $c ircdtools::rehash "Reloading ircd.conf." $n
	putnow "REHASH"
}

func m_mkill {
	if {[disabled]} {return}
	if {![istrue [mgetconf abuse enabled]]} {return}
	set parv [split $t " "]
	switch -exact -- [format {_%s} [llength $parv]] {
		_0 - _1 {
			putprivmsg $c ircdtools::mkill "Not enough parameters." $n
      return
		}
	}
	set target [split [lindex $parv 0] ","]
	set message [join [lrange $parv 1 end] " "]
	foreach victim $target {
		puthelp [format {KILL %s :%s (%s)} $victim $n $message]
	}
	putprivmsg $c ircdtools::mkill "I ask that you now reflect on what you have done. Was it the right choice? Did you need to disconnect so many people?" $n
}

}
