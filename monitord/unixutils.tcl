# Unlike the other modules, this one has to be heavily documented, as it'll be
# the tour de force of the German part of this program, and an example-setter.

tclmon-module unixutils {
# tclmon-module is a class generator of sorts. it generates a namespace, that
# this comment is inside, that contains the commands:
# m, alias func
# arguments: proc name, script
# convenience generator. creates a proc taking arguments n uh h c t
# meaning: nickname, user-host, eggdrop handle, channel, text
# under the current module.
# also creates a convenience proc under tclmon::modules_pv for the privmsg binds.
# you can and should use plain procs if they will never be directly called in IRC.
# the module name specified as the first argument of tclmon-module
# is stored in this namespace as variable modname; in procs and funcs, use
# variable modname to get the module name into your proc.

# you are using tcldrop or eggdrop as your runtime, right?
# if so, you can use any command manipulating users and so on that you would
# in eggdrop, even checking matchattrs.

# you can bind preinits, inits, etc. The monitord framework only really exists
# to enable the kind of flexibility seen in action in basename.monitord.conf.

# a naming convention ellenor has taken to using in her "factory" modules for
# monitord is m_xxx for functions that will wind up bound in the config file
# ([database-basename].monitord.conf)
func m_uptime {
	# our job is relatively simple here. Put to the channel or user calling this
	# the output of [exec uptime]. ::perl is just our namespace with the
	# weird exec doohickeys. We don't use perl in this script.
	if {$c != $n} {
		putprivmsg $c unixutils::uptime [::perl::exec uptime] $n
	} {
		putprivmsg $c unixutils::uptime [::perl::exec uptime]
	}
}

func m_uname {
	set arg [split $t " "]
	# bit of magic there, often done with eggdrop scripts with fantasia commands
	if {[llength $arg] == 0} {
		# we don't know what they want, just give em -a
		set wanted "-a"
	} else {
		set wanted "-"
		foreach uc [split [lindex $arg 0] {}] {
			if {[lsearch -exact [split "asnrvmo" {}] $uc] != -1} {
				append wanted $uc
			}
		}
	}
	if {$c != $n} {
		putprivmsg $c unixutils::uname [::perl::exec uname $wanted] $n
	} {
		putprivmsg $c unixutils::uname [::perl::exec uname $wanted]
	}
}

}