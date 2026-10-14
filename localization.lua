local _, ns = ...; -- ns is shared by every file in this addon

ns.L = {
	CLEARED="Assist Cleared",
	ASSIST_SET="Assist set",
	ASSIST_PENDING="Assist will change when you leave combat. \nQueuing:",
	CLEAR_PENDING="Assist will be cleared when you leave combat. ",
	CANNOT_ASSIST_SELF="You can't set yourself as the player to assist",
	-- |cffRRGGBB starts a color and |r ends it. The addon name is gold, the command light blue.
	KEYS_NOT_SET="|cffffd100QuickAssist:|r your keys aren't set yet. Type |cff66ccff/quickassist|r to open Key Bindings, then look for the QuickAssist section.",
	KEYS_CANNOT_OPEN="|cffffd100QuickAssist:|r couldn't open Key Bindings. Open it from the game menu and look for the QuickAssist section."
}

-- Key Bindings panel text (must be globals):
BINDING_NAME_QUICKASSIST_LEARN = "Set Player to Assist"
BINDING_NAME_QUICKASSIST_ASSIST = "Assist Learned Player"
