local _, ns = ...; -- ns is shared by every file in this addon

ns.L = {
	CLEARED="Assist Cleared",
	ASSIST_SET="Assist set",
	ASSIST_PENDING="Assist will change when you leave combat. \nQueuing:",
	CLEAR_PENDING="Assist will be cleared when you leave combat. ",
	CANNOT_ASSIST_SELF="You can't set yourself as the player to assist"
}

-- Key Bindings panel text (must be globals):
BINDING_NAME_QUICKASSIST_LEARN = "Set Player to Assist"
BINDING_NAME_QUICKASSIST_ASSIST = "Assist Learned Player"
