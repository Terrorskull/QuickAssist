local _, ns = ...; -- ns is shared by every file in this addon

ns.L = {
	CLEARED="Assist Cleared",
	ASSIST_SET="Assist set",
	ASSIST_PENDING="Assist will change when you leave combat. \nQueuing:",
	CLEAR_PENDING="Assist will be cleared when you leave combat. ",
	CANNOT_ASSIST_SELF="You can't set yourself as the player to assist",
	CANNOT_ASSIST_NOT_PLAYER="You can only set a friendly player to assist",
	-- |cffRRGGBB starts a color and |r ends it. The addon name is gold, the command light blue.
	KEYS_NOT_SET="|cffffd100QuickAssist:|r your keys aren't set yet. Type |cff66ccff/quickassist|r to open Key Bindings, then look for the QuickAssist section.",
	KEYS_CANNOT_OPEN="|cffffd100QuickAssist:|r couldn't open Key Bindings. Open it from the game menu and look for the QuickAssist section.",
	STATUS_ASSISTING="|cffffd100QuickAssist:|r assisting ",
	STATUS_NONE="|cffffd100QuickAssist:|r no player learned yet, the assist key assists your current target.",
	SOUND_ON="|cffffd100QuickAssist:|r sound is on. Type |cff66ccff/quickassist sound|r to turn it off.",
	SOUND_OFF="|cffffd100QuickAssist:|r sound is off. Type |cff66ccff/quickassist sound|r to turn it on.",
	USAGE="|cffffd100QuickAssist:|r type |cff66ccff/quickassist|r to open Key Bindings, |cff66ccff/quickassist status|r to see who you assist, or |cff66ccff/quickassist sound|r to turn the sound on or off."
}

-- Key Bindings panel text (must be globals):
BINDING_NAME_QUICKASSIST_LEARN = "Set Player to Assist"
BINDING_NAME_QUICKASSIST_ASSIST = "Assist Learned Player"
