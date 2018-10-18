#define MAX_LINES		6

new Text: BoxMessage[MAX_LINES], BoxMessages[MAX_LINES][128];
new Text:BoxMsg;

stock LoadBox()
{
	BoxMsg = TextDrawCreate(641.531494, 386.500000, "usebox");
	TextDrawLetterSize(BoxMsg, 0.000000, 6.618518);
	TextDrawTextSize(BoxMsg, 457.619323, 0.000000);
	TextDrawAlignment(BoxMsg, 1);
	TextDrawColor(BoxMsg, 0);
	TextDrawUseBox(BoxMsg, true);
	TextDrawBoxColor(BoxMsg, 1684300900);
	TextDrawSetShadow(BoxMsg, 0);
	TextDrawSetOutline(BoxMsg, 0);
	TextDrawFont(BoxMsg, 0);

	for(new i; i <= (MAX_LINES - 1); i++)
	{
		BoxMessage[i] = TextDrawCreate(463.836120, 436.333374- (10 * i), "_");
		TextDrawBackgroundColor(BoxMessage[i], 170);
		TextDrawFont(BoxMessage[i], 1);
		TextDrawLetterSize(BoxMessage[i],0.297730, 0.999166);
		TextDrawColor(BoxMessage[i], -1);
		TextDrawSetOutline(BoxMessage[i], 1);
		TextDrawSetProportional(BoxMessage[i], 1);
		TextDrawSetShadow(BoxMessage[i], 1);
		TextDrawSetSelectable(BoxMessage[i], 0);
	}	
}

stock SendBoxMessage(message[])
{
	for(new i = (MAX_LINES - 1); i >= 0; i--)
	{
		if(i != 0) format(BoxMessages[i], 128, BoxMessages[i - 1]);
		else format(BoxMessages[i], 128, message);
	}
	for(new i; i <= (MAX_LINES - 1); i++) TextDrawSetString(BoxMessage[i], BoxMessages[i]);
}

stock ShowPlayerBox(playerid)
{
	for(new i; i < MAX_LINES; i++) TextDrawShowForPlayer(playerid, BoxMessage[i]);
	TextDrawShowForPlayer(playerid, BoxMsg);
}

stock HidePlayerBox(playerid)
{
	for(new i; i < MAX_LINES; i++) TextDrawHideForPlayer(playerid, BoxMessage[i]);
	TextDrawHideForPlayer(playerid, BoxMsg);
}

