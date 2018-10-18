/*
	Warfield - Textdraws

	Author: KaryM711
	Language: Pawn
*/

new Text: TeamTXD[MAX_PLAYERS], Text: CountText[MAX_PLAYERS];

new Text:WF_WEBSITE;
new Text:PlayerStatsText[MAX_PLAYERS],Text:TeamStats[MAX_PLAYERS], Text:Star[MAX_RANKS], Text:pStatsTD[MAX_PLAYERS];
new Text:WF_TXD[4];
LoadTextDraws()
{
	WF_TXD[0] = TextDrawCreate(641.531494, 1.500000, "usebox_background");
	TextDrawLetterSize(WF_TXD[0], 0.000000, 14.914815);
	TextDrawTextSize(WF_TXD[0], -2.000000, 0.000000);
	TextDrawAlignment(WF_TXD[0], 1);
	TextDrawColor(WF_TXD[0], 0);
	TextDrawUseBox(WF_TXD[0], true);
	TextDrawBoxColor(WF_TXD[0], 160);
	TextDrawSetShadow(WF_TXD[0], 0);
	TextDrawSetOutline(WF_TXD[0], 0);
	TextDrawBackgroundColor(WF_TXD[0], 180);
	TextDrawFont(WF_TXD[0], 0);

	WF_TXD[1] = TextDrawCreate(178.506576, 100.333358, "~y~Warfield - Call of duty");
	TextDrawLetterSize(WF_TXD[1], 0.449999, 1.600000);
	TextDrawAlignment(WF_TXD[1], 1);
	TextDrawColor(WF_TXD[1], -1);
	TextDrawSetShadow(WF_TXD[1], 0);
	TextDrawSetOutline(WF_TXD[1], 1);
	TextDrawBackgroundColor(WF_TXD[1], 51);
	TextDrawFont(WF_TXD[1], 2);
	TextDrawSetProportional(WF_TXD[1], 1);

	WF_TXD[2] = TextDrawCreate(641.531494, 344.500000, "usebox");
	TextDrawLetterSize(WF_TXD[2], 0.000000, 11.220368);
	TextDrawTextSize(WF_TXD[2], -2.000000, 0.000000);
	TextDrawAlignment(WF_TXD[2], 1);
	TextDrawColor(WF_TXD[2], 0);
	TextDrawUseBox(WF_TXD[2], true);
	TextDrawBoxColor(WF_TXD[2], 102);
	TextDrawSetShadow(WF_TXD[2], 0);
	TextDrawSetOutline(WF_TXD[2], 0);
	TextDrawFont(WF_TXD[2], 0);


	WF_TXD[3] = TextDrawCreate(130.248901, 58.916675, "The original call of duty experience");
	TextDrawLetterSize(WF_TXD[3], 0.398931, 3.011667);
	TextDrawAlignment(WF_TXD[3], 1);
	TextDrawColor(WF_TXD[3], -1);
	TextDrawSetShadow(WF_TXD[3], 0);
	TextDrawSetOutline(WF_TXD[3], 1);
	TextDrawBackgroundColor(WF_TXD[3], 51);
	TextDrawFont(WF_TXD[3], 2);
	TextDrawSetProportional(WF_TXD[3], 1);


	WF_WEBSITE = TextDrawCreate(514.436401, 5.833314, ""#WEBSITE_LINK);
	TextDrawLetterSize(WF_WEBSITE, 0.402678, 1.553333);
	TextDrawAlignment(WF_WEBSITE, 1);
	TextDrawColor(WF_WEBSITE, -1);
	TextDrawSetShadow(WF_WEBSITE, 0);
	TextDrawSetOutline(WF_WEBSITE, 1);
	TextDrawBackgroundColor(WF_WEBSITE, 51);
	TextDrawFont(WF_WEBSITE, 2);
	TextDrawSetProportional(WF_WEBSITE, 1);

	for(new i; i < MAX_PLAYERS; i++)
	{
		TeamTXD[i] = TextDrawCreate(382.781829, 155.166656, "TEAM Name");
		TextDrawLetterSize(TeamTXD[i],0.243382, 2.340833);
		TextDrawAlignment(TeamTXD[i], 1);
		TextDrawColor(TeamTXD[i], -1);
		TextDrawSetShadow(TeamTXD[i], 0);
		TextDrawSetOutline(TeamTXD[i], 1);
		TextDrawBackgroundColor(TeamTXD[i], 51);
		TextDrawFont(TeamTXD[i], 2);
		TextDrawSetProportional(TeamTXD[i], 1);
	
		CountText[i] = TextDrawCreate(87.000000, 300.000000, "~r~Capturing...~n~~g~100%");
		TextDrawAlignment(CountText[i], 2);
		TextDrawBackgroundColor(CountText[i], 255);
		TextDrawFont(CountText[i], 2);
		TextDrawLetterSize(CountText[i], 0.250000, 1.400000);
		TextDrawColor(CountText[i], -1);
		TextDrawSetOutline(CountText[i], 1);
		TextDrawSetProportional(CountText[i], 1);
		TextDrawUseBox(CountText[i], 1);
		TextDrawBoxColor(CountText[i], 125);
		TextDrawTextSize(CountText[i], 0.000000, 70.000000);
		TextDrawSetSelectable(CountText[i], 0);
		
		TeamStats[i] = TextDrawCreate(14.524188, 428.166687, "~r~Mercenaries: ~w~0 ~b~Task force 141: ~w~0");
		TextDrawLetterSize(TeamStats[i], 0.211989, 1.716665);
		TextDrawAlignment(TeamStats[i], 1);
		TextDrawColor(TeamStats[i], -1);
		TextDrawSetShadow(TeamStats[i], 0);
		TextDrawSetOutline(TeamStats[i], 1);
		TextDrawBackgroundColor(TeamStats[i], 51);
		TextDrawFont(TeamStats[i], 2);
		TextDrawSetProportional(TeamStats[i], 1);
		
		pStatsTD[i] = pStatsTD[i] = TextDrawCreate(498.975097, 96.250000, "___");
		TextDrawLetterSize(pStatsTD[i], 0.213394, 1.506667);
		TextDrawAlignment(pStatsTD[i], 1);
		TextDrawColor(pStatsTD[i], -1);
		TextDrawSetShadow(pStatsTD[i], 0);
		TextDrawSetOutline(pStatsTD[i], 1);
		TextDrawBackgroundColor(pStatsTD[i], 51);
		TextDrawFont(pStatsTD[i], 2);
		TextDrawSetProportional(pStatsTD[i], 1);
	}
	for(new i; i < MAX_RANKS; i++)
	{
		Star[i] = TextDrawCreate(457.276794 + (8 * i), 369.833343, "~y~]");
		TextDrawLetterSize(Star[i], 0.449999, 1.600000);
		TextDrawAlignment(Star[i], 1);
		TextDrawColor(Star[i], -1);
		TextDrawSetShadow(Star[i], 0);
		TextDrawSetOutline(Star[i], 1);
		TextDrawBackgroundColor(Star[i], 51);
		TextDrawFont(Star[i], 2);
		TextDrawSetProportional(Star[i], 1);
	}
	return 1;
}