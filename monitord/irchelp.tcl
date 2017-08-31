#simple help script, in response to abvnet getting kekked

#json file.
#objects are topics, can contain subtopics with names other than
# "ml" or "v" or "d"


tclmon-module irchelp {

  variable hfcache [list]
  setudef flag helpchan

  proc puthelpmsg {targ topic msg {tn {}}} {
    if {$tn == {}} {set targnick ""} {set targnick [format {%s%s%s } [getconf precomma] $tn [getconf comma]]}
    set line [string map [list %c "\x03" %b "\x02" %o "\x0f" %m $msg %t $topic %n $targnick] [mgetconf msgfmt]]
    if {![validchan $targ] && [getconf notice_pv] == 1} {set comd NOTICE} {set comd PRIVMSG}
    putnow [format "%s %s :%s" $comd $targ $line]
    
  }

  proc reloadhfcache {} {
    variable hfcache
    if {[mgetconf helpfile] == ""} {return}
    json2var [mgetconf helpfile] hfcache
  }

  proc loadhfcache {} {
    # loaded?
    variable hfcache
    if {[llength $hfcache] != 0} {return}
    reloadhfcache
  }
  func m_help {
    loadhfcache
    variable hfcache
    if {[validchan $c] && ![channel get $c helpchan]} {
			putloglev k * [format "%s!%s (!%s!) called irchelp/m_help in wrong channel %s (is not chanset +helpchan)" $n $uh $h $c]
			return
		}
    if {-1==[lsearch -exact [split $t {}] /]} {
      set topic [split [string tolower $t] {/ }]
    } {
      set topic [split [string tolower $t] { }]
    }
    if {-1!=[lsearch -exact $topic v]} {
      putprivmsg $c irchelp [format "Silly goose you, trying to break the bot! %s" [join $topic " "]] $n
      putloglev k * [format "%s!%s (!%s!) called irchelp/m_help with bogus argument %s" $n $uh $h $t]
      return
    }
    if {-1!=[lsearch -exact $topic ml]} {
      putprivmsg $c irchelp [format "Silly goose you, trying to break the bot! %s" [join $topic " "]] $n
      putloglev k * [format "%s!%s (!%s!) called irchelp/m_help with bogus argument %s" $n $uh $h $t]
      return
    }
    if {[llength $topic] == 0} {set topic [list start]}
    if {![dict exists $hfcache {*}$topic d]} {
			set desc ""
		} {set desc [dict get $hfcache {*}$topic d]}
    if {![dict exists $hfcache {*}$topic ml]} {set type 1} {set type [dict get $hfcache {*}$topic ml]}
    if {$desc == ""} {set desc [join $topic /]; append desc " help"}
    if {![istrue $type]} {}
    set destopic $topic
    lappend topic v
    set value [dict get $hfcache {*}$topic]
    if {![istrue $type]} {set value [list $value]}
    if {[string length $value] < 2} {
      puthelpmsg $n [join $destopic /] "Unable to find help topic."
      return
    }
    puthelpmsg $n [join $destopic /] [string map [list %c "\x03" %b "\x02" %o "\x0f" %t $desc %n $n] [mgetconf headerfmt]]
    foreach l $value {
      puthelpmsg $n [join $destopic /] $l
    }
  }
}
