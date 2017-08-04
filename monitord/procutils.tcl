tclmon-module procutils {

	switch -exact -- [dict get ${::tclmon::unixtype} o] {
		"FreeBSD" {
			proc ps {{wante {pid user uid pcpu ruid ruser args time}}} {
				if {[istrue [tclmon gmconf procutils sudops]]} {set ps {sudo ps}} {set ps {ps}}
				set command [list {*}$ps --libxo json -a]
				set comte 0
				foreach want $wante {
					if {[set want [string tolower $want]] == "arguments" || [set want [string tolower $want]] == "args" || [set want [string tolower $want]] == "command" || [set want [string tolower $want]] == "comm"} {
						set comte 1
						continue
					} {	set width 15
					}
					set wan [format {-o%s=%s} $want [string repeat " " $width]]
					lappend command $wan
				}
				if {$comte} {lappend command [format {-o%s=%s} "command" [string repeat " " 140]]}
				putlog $command
				dict get [::json::json2dict [::perl::exec {*}$command]] process-information process
			}
		}
		"Linux" {
			proc ps {{wanted {}}} {
				# Heavy thanks to StackOverflow here!
				::json::json2dict [::perl::apply {
					use JSON;
					use Proc::ProcessTable;

					print to_json ( [ map {{ %$_ }} @{ Proc::ProcessTable->new->table } ], { pretty => 0 } );
				}]
			}
		}
	}

	func m_ps {
		set arg [split $t " "]
		set action [lindex $arg 0]
		switch -exact -- [string tolower $action] {
			"search" {
				if {[llength [set aarg [lrange $arg 1 end]]] < 3} {
					# Screw it and run off.
					tclmon putprivmsg $c procutils::ps "You haven't given me enough details! (need: wanted ps details, detail to search on, process search string)" $n
					return
				}
				set searchon [lindex $aarg 1]
				set count 0
				set trunc 0
				tclmon putprivmsg $c procutils::ps "Here's what you asked for: " $n
				set dn [list]
				foreach dict [ps [split [string tolower [lindex $aarg 0]] ","]] {
					set display 0
					set dt [list]
				
					foreach {k v} $dict {
						if {$k == $searchon} {
							if {[regexp [lindex $aarg 2] $v]} {set display 1} {set display 0}
						} 
						lappend dt [format {%s="%s"} $k $v]
						# XXX dumb logic
						if {[string length [join $dn ", "]] >= 250} {
							incr count
							tclmon putprivmsg $c procutils::ps [format {%s} [join $dn ", "]]
							set dn [list]
							if {$count >= [tclmon gmconf procutils stopat]} {set trunc 1}
						}
					}
					if {$display} {foreach d $dt {lappend dn $d}; incr count} ;# {putlog "wasted $dt"}
					if {$trunc} {unset dt;break}
					if {[llength $dn]>0} {tclmon putprivmsg $c procutils::ps [format {%s} [join $dn ", "]]}
					set dn [list]
					if {$count >= [tclmon gmconf procutils stopat]} {set trunc 1; break}
				}
				if {[llength $dn]>0} {tclmon putprivmsg $c procutils::ps [format {%s} [join $dn ", "]]}	
				if {$trunc} {set tr [format "truncated at %s lines." $count]} {set tr "finished."}
				tclmon putprivmsg $c procutils::ps [format {-- Output %s} $tr] $n
			}
		}
	}

	#dict set ::tclmon::help procutils::ps

}