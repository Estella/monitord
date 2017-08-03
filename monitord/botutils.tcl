namespace eval ::tclmon::botutils {
	proc m_rehash {n uh h c t} {
		tclmon putprivmsg $c botutils::rehash "As you wish, Master." $n
		rehash
	}
	proc m_shutdown {n uh h c t} {
		tclmon putprivmsg $c botutils::rehash "I'm sorry I couldn't serve you effectively, Master." $n
		shutdown [format {Told to go to sleep by my Master :( (%s)} $t]
	}
}