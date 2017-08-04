tclmon-module botutils {
	func m_rehash {
		putprivmsg $c botutils::rehash "As you wish, Master." $n
		rehash
	}
	func m_shutdown {
		putprivmsg $c botutils::rehash "I'm sorry I couldn't serve you effectively, Master." $n
		if {[string length $t] != 0} {set l " (";set r ")"} {set l ""; set r "")}
		shutdown [format {Told to go to sleep by my Master :(%s%s%s} $l $t $r]
	}
}