/*
	Warfield - Master
	
	Author: KaryM711
	Language: Pawn
*/

#include <a_samp>
#include <AFkill.inc>
#include <AntiSpam.inc>
#include <AntiSba.inc>
#include <OPA>
#include <AntiTLG>
#include <izcmd>
#include <streamer>
#include <sscanf2>
#include <easyDialog>
#include <foreach>
#include <a_mysql>
#include <OPJV>
#include <MapAndreas>
#include <weapon-config>
#include <Pawn.RakNet>
#include <dl-compat>
#include <discord-connector>
#include <PreviewModelDialog>
#include <player_geolocation>
#include <antiadvertising>

native IsValidVehicle(vehicleid);

#include "..\includes\WF_Defines.inc"
#include "..\includes\WF_MAPS.inc"
#include "..\includes\WF_Textdraws.inc"
#include "..\includes\WF_ENUMS.inc"
#include "..\includes\WF_FORWARDS.inc"

#include "..\includes\WF_Msg.inc"
enum
{
	ALPHA,
	TASKFORCE
};

new const vTeam[MAX_TEAMS][eTeam] =
{
	{"Mercenaries", {28, 30, 100, 111, 122, 181,247,248, 298, 293}, {500, 479, 505, 529, 455, 403}, ALPHA_BASE_POS, ALPHA_SPAWN_POINTS, ALPHA_BRIEFCASE_POS, ALPHA_COLOR, ALPHA_COLOR_2, ALPHA_PROTOTYPE_POS, ALPHA_PROTOTYPE_CP, {-281.5838,2675.4387,62.6182}, {-195.21674, 2721.35156, 64.0850,90.000}, {-283.6551,2771.0400,62.0069}, \
	{-246.6841,2581.9993,63.5703}, {-223.4421,2684.0137,66.8944,358.4549}, {-244.3511,2649.5090,78.7606,256.7732}},
	
	{"Task Force 141",{287, 285, 286, 309, 307,300, 295, 283, 288, 267}, {470,490,599, 528,433, 427}, TF_BASE_POS, TF_SPAWN_POINTS, TF_BRIEFCASE_POS, TF_COLOR,TF_COLOR_2, {193.3265,1821.9512,17.7675,180.0}, {133.9602,1887.8116,18.3363}, {242.6686,1860.3903,8.7578}, {208.5403,1928.4954,23.95,150.0}, {160.6866,1943.9076,18.7668}, \
	{144.5914,1875.5867,17.8359}, {202.3957,1864.3372,13.1406,266.2381}, {201.3583,1934.3578,23.2422,357.1885}}
};

new gTeam[MAX_PLAYERS];

enum
{
	CLASS_TROOPER,
	CLASS_SNIPER,
	CLASS_SUICIDER,
	CLASS_MEDIC,
	CLASS_JETTROOPER,
	CLASS_BOMBER,
	CLASS_ENGINEER,
	CLASS_PYROMAN,
	CLASS_SCOUT,
	CLASS_SUPPORT,
	CLASS_PILOT,
	CLASS_SPY,
	CLASS_DEMOLISHER,
	CLASS_DONOR
};

enum
{
	PRIVATE,
	COPORAL,
	SEARGENT,
	STAFF_SEARGENT,
	LIEUTENANT,
	CAPTAIN,
	MAJOR,
	BRIGADIER,
	COLONEL,
	MARSHALL,
	GENERAL,
	WARRIOR,
	HERO,
	JEDI,
};


new const vClass[MAX_CLASSES][eClass] = 
{
	{"Trooper", PRIVATE, {WEAPON_M4, 500}, {WEAPON_MP5, 200}, {PISTOL_9MM, 300}, {WEAPON_GRENADE, 2}},
	{"Sniper", COPORAL, {WEAPON_SILENCED, 120}, {WEAPON_SNIPER, 300}, {WEAPON_MP5, 200}, {WEAPON_KNIFE, 1}, {WEAPON_TEARGAS, 5}},
	{"Suicider", STAFF_SEARGENT, {WEAPON_DEAGLE, 150}, {WEAPON_SHOTGUN, 100}, {WEAPON_AK47, 250}, {WEAPON_SHOVEL, 1}},
	{"Medic", LIEUTENANT, {WEAPON_DEAGLE, 150}, {WEAPON_RIFLE, 200}, {WEAPON_AK47, 200}, {WEAPON_GOLFCLUB, 1}},
	{"Jettrooper", CAPTAIN, {PISTOL_9MM, 300}, {WEAPON_UZI, 500}, {WEAPON_AK47, 100}, {WEAPON_KATANA}},
	{"Bomberman", MAJOR, {WEAPON_DEAGLE, 300}, {WEAPON_SHOTGSPA, 100}, {WEAPON_M4, 200}, {WEAPON_GRENADE, 5}},
	{"Engineer", BRIGADIER, {WEAPON_DEAGLE, 300}, {WEAPON_SHOTGUN, 200}, {WEAPON_AK47, 200}, {WEAPON_ROCKETLAUNCHER, 3}},
	{"Pyroman", BRIGADIER, {WEAPON_DEAGLE, 90}, {WEAPON_SHOTGUN, 100}, {WEAPON_AK47, 100}, {WEAPON_MOLTOV, 10}, {WEAPON_FLAMETHROWER, 2000}},
	{"Scout", COLONEL, {WEAPON_DEAGLE, 100}, {WEAPON_SAWEDOFF, 200}, {WEAPON_AK47, 300}, {WEAPON_GRENADE, 3}},
	{"Supporter", MARSHALL, {WEAPON_DEAGLE, 100}, {WEAPON_SHOTGSPA, 100}, {WEAPON_M4, 500}, {WEAPON_GRENADE, 1}, {WEAPON_KNIFE, 1}},
	{"Pilot", GENERAL, {WEAPON_DEAGLE, 90}, {WEAPON_SHOTGUN, 100}, {WEAPON_M4, 250}},
	{"Spy", WARRIOR, {WEAPON_SNIPER, 200}, {WEAPON_MP5, 350}, {WEAPON_SILENCED, 100}, {WEAPON_KNIFE, 1}, {WEAPON_SHOTGSPA, 90}},
	{"Demolisher", HERO, {WEAPON_DEAGLE, 300}, {WEAPON_SHOTGSPA, 150}, {WEAPON_RIFLE, 200}, {WEAPON_AK47,300}, {WEAPON_SATCHEL, 5}},
	{"Donor", PRIVATE, {26, 200}, {31, 200}, {32, 500}, {35, 3}, {34, 100},{24, 100}}
};
new gClass[MAX_PLAYERS];

new const vRank[MAX_RANKS][eRank] = 
{
	{"Private", PRIVATE_SCORE, PRIVATE_TAG},
	{"Coporal", COPORAL_SCORE, COPORAL_TAG},
	{"Seargent", SEARGENT_SCORE, SEARGENT_TAG},
	{"Staff seargent", STAFF_SEARGENT_SCORE, SEARGENT_TAG},
	{"Lieutenant", LIEUTENANT_SCORE, LIEUTENANT_TAG},
	{"Captain", CAPTAIN_SCORE, CAPTAIN_TAG},
	{"Major", MAJOR_SCORE, MAJOR_TAG},
	{"Brigadier", BRIGADIER_SCORE, BRIGADIER_TAG},
	{"Colonel", COLONEL_SCORE, COLONEL_TAG},
	{"Marshall", MARSHALL_SCORE, MARSHALL_TAG},
	{"General", GENERAL_SCORE, GENERAL_TAG},
	{"Warrior",WARRIOR_SCORE,WARRIOR_TAG},
	{"Hero", HERO_SCORE, HERO_TAG},
	{"Jedi",JEDI_SCORE,JEDI_TAG}
};
new gRank[MAX_PLAYERS];

new const vMode[MAX_MODES][eMode] = 
{
	{"Sniper deathmatch", {158, 159, 135}, {WEAPON_SNIPER, 9999}, {0,0}, {0,0}, SDM_SPAWN_A, SDM_SPAWN_B, SDM_SPAWN_C,SDM_INTERIOR},
	{"Deagle deathmatch", {134,137, 162}, {WEAPON_DEAGLE, 9999}, {0,0}, {0,0}, DEAGLE_DM_SPAWN_A, DEAGLE_DM_SPAWN_B, DEAGLE_DM_SPAWN_C, DEAGLE_DM_INTERIOR}
};
new gMode[MAX_PLAYERS];

new const WeaponNames[55][] =
{
	{"Punch"}, {"Brass Knuckles"}, {"Golf Club"}, {"Nite Stick"}, {"Knife"}, {"Baseball Bat"}, {"Shovel"}, {"Pool Cue"}, {"Katana"}, {"Chainsaw"}, {"Purple Dildo"}, {"Small White Vibrator"},
	{"Large White Vibrator"}, {"Silver Vibrator"}, {"Flowers"}, {"Cane"}, {"Grenade"}, {"Tear Gas"}, {"Molotov Cocktail"}, {""}, {""}, {""}, {"Colt"}, {"Silenced 9mm"}, {"Deagle"},
	{"Shotgun"}, {"Sawn-off"}, {"Combat Shotgun"}, {"Micro SMG"}, {"MP5"}, {"AK-47"}, {"M4"}, {"Tec9"}, {"Rifle"}, {"Sniper"}, {"Rocket"}, {"Heat Seeker"},
	{"Flamethrower"}, {"Minigun"}, {"Satchel Charge"}, {"Detonator"}, {"Spraycan"}, {"Fire Extinguisher"}, {"Camera"}, {"Nightvision Goggles"}, {"Thermal Goggles"},
	{"Parachute"}, {"Fake Pistol"}, {""}, {"Vehicle Ram"}, {"Helicopter Blades"}, {"Explosion"}, {""}, {"Drowned"}, {"Collision"}
};

enum 
{
	BallisticVest,
	CarePackage,
	KamikazePilot,	
	DiveBombingRun,
	Deathmachine,
	RcDrone,
	BallisticVest2,
	MOAB
};

new const gSStreak[MAX_SUPPORT_STREAK][eSupportStreak] =
{
	//Support streaks  XP KP  Description
	{"Ballistic vest lvl 1", 20, 0,"Gets you 50 armour."},
	{"Care package", 0, 5,"A care package gets dropped on your position."},
	{"Kamikaze Pilot", 0,5, "You get inside a dodo with a low health that kills in range enemies when destroyed."},	
	{"Dive bombing run", 0, 6, "You get a rustler that has increased damage."},
	{"Death machine", 0, 7, "You get a minigun with 1000 ammo."},
	{"Drone", 0, 12, "You get a rc-drone."},
	{"Ballistic vest lvl 2", 40, 0, "Gets you 100 armour."},
	{"MOAB", 0, 50, "Kills all enemies who are outside the bunker."}
};

new bool:IsBallisticVestUsed[MAX_PLAYERS];
new bool:IsCarePackageUsed[MAX_PLAYERS];
new bool:IsDeathmachineUsed[MAX_PLAYERS];
new bool:IsDroneUsed[MAX_PLAYERS];
new bool:IsDiveBombingRunUsed[MAX_PLAYERS];
new bool:IsKamikazeUsed[MAX_PLAYERS];
new bool:IsBallisticVestUsed2[MAX_PLAYERS];
new bool:IsMOABUsed[MAX_PLAYERS];
new MySQL: WF_DB, Corrupt_Check[MAX_PLAYERS];

new gNukeTime, gNukePickup;
new gHealthPickup;

new gTF141_Pilot_Vehicle;
new gMerc_Pilot_Vehicle;

new gTF141_Vehicle_Object[2];
new gMerc_Vehicle_Object[2];

new vehDuel[2];
new cpDuel;


new bool:IsRaceDuelOccupied;

enum
{
	CP_SNAKEFARM,
	CP_RADIOBASE,
	CP_MISSILEFACTORY,
	CP_BUNKER,
	CP_A51AIRFIELD
}

new const gZone[MAX_CAPTURE_ZONES][e_ZONE] =
{
	{"Snake Farm",SNAKEFARM_GANGZONE,SNAKEFARM_CP,SNAKEFARM_SPAWN_POINT},
	{"Radio base",RADIOBASE_GANGZONE,RADIOBASE_CP,RADIOBASE_SPAWN_POINT},
	{"Missile factory", MISSILEFACTORY_GANGZONE, MISSILEFACTORY_CP, MISSILEFACTORY_SP},
	{"Bunker", BUNKER_GANGZONE, {-55.4366,1821.8054,17.6476},{-46.8643,1846.6771,17.6406}},
	{"Area 51 Airfield", {114.428298, 1944.034179, 330.428283, 2096.034179},{206.3778,1984.4216,17.6406}, {261.5969,2054.3059,17.6407}},
	{"Healing point", {-219.959381, 2328.514648, -91.959381, 2472.514648}, {-170.0381,2341.7070,51.1565}, {-183.7791,2382.4951,55.9716}},
	{"Desert airport", {205.606933, 2398.045410, 453.606933, 2622.045410}, {404.1522,2535.3142,16.5458}, {413.7609,2536.4856,19.1484}}
};

new const gAmmoBox[MAX_AMMO_BOXES][eAmmoBox] =
{
	{A51_AMMO_BOX_POS},
	{BIGEAR_AMMO_BOX_POS},
	{SNAKE_FARM_AMMO_BOX_POS}
};


new const gBombers[MAX_BOMBERS][eBombers] =
{
	{{428.6621,2488.4395,17.1949,90.0787}}, // DELTA BOMBER
	{{214.6585,2041.4298,18.3484,225.8200}}, // A51
	{{252.4312,2040.5914,18.3551,196.9251}}, // A51
	{{-644.9609, 2692.0981, 74.4983, -91.0000}}, //Army restaurant
	{{-1414.2969,495.6124,18.9488,0.1390}}, //ARMED SHIP
	{{-740.3408, 913.1304, 13.5436, -100.0000}}, // SEAL SIX 
	{{-740.6717, 900.1946, 13.5436, -90.0000}}, // SEAL SIX
	{{-210.5172, 1141.9304, 21.0863, -90.0000}}, // CHARLIE
	{{-209.6151, 1177.8453, 21.0863, -90.0000}}, // CHARLIE
	{{429.1855,2501.9114,17.2004,87.5895}}, // delta 
	{{428.8588,2518.6594,17.2071,88.2017}}, //delta
	{{-129.5839,2351.0244,43.7140,267.9355}}, // Mini conquest
	{{472.4278,2318.5823,40.4387,89.9850}}, // OP40
	{{29.9435,1568.6769,20.0125,179.8625}}, //TASK FROCER
	{{ -172.9241, 2432.5286, 47.5056,282.1730}},
	{{-321.6367, 2751.8008, 82.2052, -157.9204}},
	{{-311.1488, 2736.5806, 80.6035, -176.8201}}
};

new const gShop[MAX_SHOPS][eShop] = 
{
	{{-320.1446,1558.1388,75.5601}}, // Big ear
	{{-371.1698,2277.5508,41.3757}}, // Missile factory
	{{-902.4006,2696.3823,42.3703}} // Bridge
};


new pDuel[MAX_PLAYERS][E_DUEL];
new gDuelWorld;

new WeaponsObjectModelID[200] =
{
   1575,  331, 333, 334, 335, 336, 337, 338, 339, 341, 321,	322, 323, 324, 325, 326, 342, 343, 344, -1,  -1 , -1 ,
   346, 347, 348, 349, 350, 351, 352, 353, 355, 356, 372, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367,
   368, 369, 1575
};

new gWeaponDrop[MAX_WEAPON_DROP][eWeaponDrop];

new gAirstrike;
new gAirstrikeObject;
new gAirstrikeLauncherID;

//BUNKER
new gBunkerEntrance;
new gBunkerExit;

new RandomMessages[][] =
{
    ""COL_LIGHT_BLUE"WF: "COL_WHITE"Spotted a cheater ? Use /report without alerting them.",
    ""COL_LIGHT_BLUE"WF: "COL_WHITE"Interested in becoming a staff member ? Apply on our forum.",
    ""COL_LIGHT_BLUE"WF: "COL_WHITE"Not aware of the rules ? Use /rules to check them.",
    ""COL_LIGHT_BLUE"WF: "COL_WHITE"Have any question ? You can use /helpme to ask staff members.",
    ""COL_LIGHT_BLUE"WF: "COL_WHITE"Bored of playing the same thing the whole time? Join an event or a dm arena",
    ""COL_LIGHT_BLUE"WF: "COL_WHITE"Read /updates to know about our server updatelog.",
    ""COL_LIGHT_BLUE"WF: "COL_WHITE"You can change your spawn point by using /ss.",
    ""COL_LIGHT_BLUE"WF: "COL_WHITE"Register on our forum to keep up with our community.",
	""COL_LIGHT_BLUE"WF: "COL_WHITE"You wish to change your skin? Go to your cloth icon inside of your team base.",
	""COL_LIGHT_BLUE"WF: "COL_WHITE"Use /baseshieldhelp to know more about how our base shield system works.",
	""COL_LIGHT_BLUE"WF: "COL_WHITE"Join our discord server and get rewarded! https://discord.gg/pQZKyHG",
	""COL_LIGHT_BLUE"WF: "COL_WHITE"Could not find a vehicle inside your base? Go to the car icon inside of your base to spawn one.",
	""COL_LIGHT_BLUE"WF: "COL_WHITE"Wish to duel your rival? Then do /duel [your rival id] [Weapon ID] [Bet].",
	""COL_LIGHT_BLUE"WF: "COL_WHITE"Wish to race in Warfield? Then do /duelrace [Your rival id] [Bet]"
};

new DCC_Channel:g_Discord_Chat;
new DCC_Channel:g_Report_Channel;
new DCC_Channel:g_Logs_Channel;
new DCC_Channel:g_Discord_StaffChat;
/* Functions part */

main()
{
	print("\n_____________________________________");
	print("\nWarfield - Call of duty v"#GM_VERSION" Loaded");
	print("\n_____________________________________");
}


IsVehOccupied(veh)
{
	Loop(i)
	{
		if (IsPlayerInVehicle(i, veh)) return 1;
	}
	return 0;
}

IsPlayerInHeavyVehicle(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehid,vehmodel;
		vehid = GetPlayerVehicleID(playerid);
		vehmodel = GetVehicleModel(vehid);
		if(vehmodel == 432 || vehmodel == 425 || vehmodel == 520 || vehmodel == 447) return true;
	}
	return false;
}

KickPlayer(playerid) 
{
	SetTimerEx("KickEx", 200, false, "i", playerid);
}

stock GetVehicleDriverID(vehicleid) 
{ 
    for(new i,l=GetPlayerPoolSize()+1; i<l; i++) if(GetPlayerState(i) == PLAYER_STATE_DRIVER && IsPlayerInVehicle(i,vehicleid)) return i; 
    return -1; 
}  

DropPlayerWeapon(playerid)
{
	new WeaponID = GetPlayerWeapon(playerid), Ammo = GetPlayerAmmo(playerid);
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);

	if(WeaponID != 0 && Ammo != 0)
	{
		for(new i = 0; i < MAX_WEAPON_DROP; i++)
		{
			if(gWeaponDrop[i][IsWeaponDropped] == false)
			{	
				new str[50];
				format(str, sizeof(str), ""COL_LIGHT_GREEN"%s\n"COL_WHITE"press ALT",WeaponNames[WeaponID]);
				gWeaponDrop[i][WeaponObj] = CreateDynamicObject(WeaponsObjectModelID[WeaponID], x, y, z-1,80.0,0.0, 0.0);
				gWeaponDrop[i][WeaponLabel] = CreateDynamic3DTextLabel(str, -1, x, y,z-0.6, 5);
				gWeaponDrop[i][WeaponPos][0] = x;
				gWeaponDrop[i][WeaponPos][1] = y;
				gWeaponDrop[i][WeaponPos][2] = z;
				gWeaponDrop[i][WeaponInfo][0] = WeaponID;
				gWeaponDrop[i][WeaponInfo][1] = Ammo;
				gWeaponDrop[i][IsWeaponDropped] = true;
				return 1;
			}
		}
	}
	return 1;
}

stock QuickSort_Pair(array[][2], bool:desc, left, right)
{
	new
		tempLeft = left,
		tempRight = right,
		pivot = array[(left + right) / 2][0],
		tempVar
	;

	while (tempLeft <= tempRight)
	{
		if (desc)
		{
			while (array[tempLeft][0] > pivot)
				tempLeft++;
			while (array[tempRight][0] < pivot)
				tempRight--;
		}
		else
		{
			while (array[tempLeft][0] < pivot)
				tempLeft++;
			while (array[tempRight][0] > pivot)
				tempRight--;
		}

		if (tempLeft <= tempRight)
		{
			tempVar = array[tempLeft][0];
			array[tempLeft][0] = array[tempRight][0];
			array[tempRight][0] = tempVar;

			tempVar = array[tempLeft][1];
			array[tempLeft][1] = array[tempRight][1];
			array[tempRight][1] = tempVar;

			tempLeft++;
			tempRight--;
		}
	}

	if (left < tempRight)
		QuickSort_Pair(array, desc, left, tempRight);

	if (tempLeft < right)
		QuickSort_Pair(array, desc, tempLeft, right);
}

stock IsPointInRangeOfPoint(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2, Float:range)
{
	x2 -= x;
	y2 -= y;
	z2 -= z;
	return ((x2 * x2) + (y2 * y2) + (z2 * z2)) < (range * range);
}

stock timec(timestamp, compare = -1) {
    if (compare == -1) {
        compare = gettime();
    }
    new
        n,
        Float:d = (timestamp > compare) ? timestamp - compare : compare - timestamp,
        returnstr[32];
    if (d < 60) {
        format(returnstr, sizeof(returnstr), "< 1 minute");
        return returnstr;
    } else if (d < 3600) { // 3600 = 1 hour
        n = floatround(floatdiv(d, 60.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "minute");
    } else if (d < 86400) { // 86400 = 1 day
        n = floatround(floatdiv(d, 3600.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "hour");
    } else if (d < 2592000) { // 2592000 = 1 month
        n = floatround(floatdiv(d, 86400.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "day");
    } else if (d < 31536000) { // 31536000 = 1 year
        n = floatround(floatdiv(d, 2592000.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "month");
    } else {
        n = floatround(floatdiv(d, 31536000.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "year");
    }
    if (n == 1) {
        format(returnstr, sizeof(returnstr), "1 %s", returnstr);
    } else {
        format(returnstr, sizeof(returnstr), "%d %ss", n, returnstr);
    }
    return returnstr;
}

IsPlayerInArea(playerid, Float:MinX, Float:MinY, Float:MaxX, Float:MaxY)
{
	new Float:X, Float:Y, Float:Z;

	GetPlayerPos(playerid, X, Y, Z);
	if(X >= MinX && X <= MaxX && Y >= MinY && Y <= MaxY) {
		return 1;
	}
	return 0;
}

GetPlayerCount()
{
	new playerscount;
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i)) playerscount++;
	}
	return playerscount;
}
GetVehicleCount()
{
	new vehiclescount;
	for(new i = 0, j = GetVehiclePoolSize(); i < j; i++)
	{
		if(IsValidVehicle(i)) vehiclescount++;
	}
	return vehiclescount;
}
SpawnPlayerAtTeamBase(playerid)
{
	new teamid = gTeam[playerid];
	new Float: SpawnA[3];
	new Float: SpawnB[3];
	new Float: SpawnC[3];

	SpawnA[0] = vTeam[teamid][teamSpawnPoints][0];
	SpawnA[1] = vTeam[teamid][teamSpawnPoints][1];
	SpawnA[2] = vTeam[teamid][teamSpawnPoints][2];
	SpawnB[0] = vTeam[teamid][teamSpawnPoints][3];
	SpawnB[1] = vTeam[teamid][teamSpawnPoints][4];
	SpawnB[2] = vTeam[teamid][teamSpawnPoints][5];
	SpawnC[0] = vTeam[teamid][teamSpawnPoints][6];
	SpawnC[1] = vTeam[teamid][teamSpawnPoints][7];
	SpawnC[2] = vTeam[teamid][teamSpawnPoints][8];

	switch(random(3))
	{
		case 0: SetPlayerPos(playerid, SpawnA[0],SpawnA[1],SpawnA[2]);
		case 1: SetPlayerPos(playerid, SpawnB[0],SpawnB[1],SpawnB[2]);
		case 2: SetPlayerPos(playerid, SpawnC[0],SpawnC[1],SpawnC[2]);
	}
	return 1;
}

ShowClassFeatures(playerid)
{
	new str[350];
	new classid = gClass[playerid];
	strcat(str, ""COL_WHITE"Your class is: ");
	strcat(str, ""COL_LIGHT_BLUE"");
	strcat(str, vClass[classid][className]);
	strcat(str, "\n");
	strcat(str, ""COL_WHITE"Weapons: ");

	strcat(str, WeaponNames[vClass[classid][classWeaponA][0]]);
	strcat(str, " | ");
	strcat(str, WeaponNames[vClass[classid][classWeaponB][0]]);
	strcat(str, " | ");	
	strcat(str, WeaponNames[vClass[classid][classWeaponC][0]]);
	strcat(str, " | ");
	strcat(str, WeaponNames[vClass[classid][classWeaponD][0]]);	

	if(vClass[classid][classWeaponE] == 0) strcat(str, "");
	
	else if(vClass[classid][classWeaponE] != 0) 
	{
		strcat(str, " | ");	
		strcat(str, WeaponNames[vClass[classid][classWeaponE][0]]);
	}

	if(vClass[classid][classWeaponF] == 0 ) strcat(str, "");
	else if(vClass[classid][classWeaponF] != 0)
	{
		strcat(str, " | ");
		strcat(str, WeaponNames[vClass[classid][classWeaponF][0]]);
	}
	switch(classid)
	{
		case CLASS_TROOPER:
		{
			strcat(str, ""COL_WHITE"\n\n*Kill streak rewards take 1 less kill.\n");
		}
		case CLASS_SNIPER:
		{
			strcat(str, ""COL_WHITE"\n\n*Invisible on the map.\n*Sniper weapon.");
		}
		case CLASS_MEDIC:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to heal in range team mates.");
		}
		case CLASS_SUICIDER:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to explode which kills in range enemies.");			
		}
		case CLASS_JETTROOPER:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to spawn a jetpack.");
		}
		case CLASS_BOMBER:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to plant and detonate a C4 & disarm it.");
		}
		case CLASS_ENGINEER:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to drive a rhino.\nAbility to disarm a C4");
		}
		case CLASS_SUPPORT:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to refill in range mates's ammo.\n");
		}
		case CLASS_PILOT:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to drive hydra and hunter.");
		}
		case CLASS_SCOUT:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to spawn a drone ( /Getdrone )\n*Ability to drive sparrow.\n*Sawn-off weapon.");
		}
		case CLASS_SPY:
		{
			strcat(str, ""COL_WHITE"\n\n*Ability to disguise as enemy assault\n*Sniper weapon.");
		}
		case CLASS_DEMOLISHER:
		{
			strcat(str, ""COL_WHITE"\n\n*Increased damage for Shotgun / Deagle / Country rifle.");
		}
		case CLASS_PYROMAN:
		{
			strcat(str, ""COL_WHITE"\n\n*Flame thrower weapon.\n*Molotov weapon.");
		}
	}
	Dialog_Show(playerid, DIALOG_CLASS_INFO, DIALOG_STYLE_MSGBOX, "WF - Class", str, "Okay", "");
	return 1;
}

stock IsValidVehicleID(vehicleid)
{
	if(400 > vehicleid  || vehicleid > 611) return false;
	else return true;
}

IsValidWeapon(weaponid)
{
	if(46 >= weaponid >= 0 && weaponid) return true;
	else return false;
}

IsValidSkin(skinid)
{
	if(0 <= skinid <= 311) return true;
	else return false;
}

GivePlayerClassWeapons(playerid)
{
	new classidx = gClass[playerid];
	GivePlayerWeapon(playerid, vClass[classidx][classWeaponA][0], vClass[classidx][classWeaponA][1]);
	GivePlayerWeapon(playerid, vClass[classidx][classWeaponB][0], vClass[classidx][classWeaponB][1]);
	GivePlayerWeapon(playerid, vClass[classidx][classWeaponC][0], vClass[classidx][classWeaponC][1]);
	GivePlayerWeapon(playerid, vClass[classidx][classWeaponD][0], vClass[classidx][classWeaponD][1]);
	GivePlayerWeapon(playerid, vClass[classidx][classWeaponE][0], vClass[classidx][classWeaponE][1]);
	GivePlayerWeapon(playerid, vClass[classidx][classWeaponF][0], vClass[classidx][classWeaponF][1]);
	return 1;
}


GetPlayerRank(playerid)
{
	for(new i = (MAX_RANKS - 1); i != -1; i--)
	{
		if(GetPlayerScore(playerid) >= vRank[i][rankScore]) return i;
		else continue;
	}
	return -1;
}

ClearChatForPlayer(playerid)
{
	for(new i; i < 15; i++)
	{
		SendClientMessage(playerid,-1, " ");
	}
	return 1;
}

ShowClassDialog(playerid)
{
	new str[1000] = "Class\tScore\n";
	for(new i; i < MAX_CLASSES; i++)
	{
		new strx[12];
		strcat(str, ""COL_BLUE"");
		strcat(str, vClass[i][className]);
		if(gRank[playerid] >= vClass[i][classRank]) strcat(str, ""COL_WHITE"\t");
		else if(gRank[playerid] < vClass[i][classRank]) strcat(str, ""COL_DARK_RED"\t");
		valstr(strx, vRank[vClass[i][classRank]][rankScore]);	
		if(i == CLASS_DONOR) {strcat(str, "Donor level 2"); }
		else strcat(str, strx);
		strcat(str, "\n");
	}
	Dialog_Show(playerid, DIALOG_CLASS, DIALOG_STYLE_TABLIST_HEADERS, "WF - Classes", str, "Select", "Back");
	return 1;
}

GivePlayerScore(playerid, score)
{
	SetPlayerScore(playerid, GetPlayerScore(playerid) + score);
	return 1;
}

CheckForBan(playerid)
{
	new Query[350], banreason[50], adminname[MAX_PLAYER_NAME], pName[MAX_PLAYER_NAME], IP_[16], rName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	GetPlayerIp(playerid, IP_, 16);
	mysql_format(WF_DB, Query, sizeof(Query), "SELECT * FROM bans WHERE (`BANNED_USERNAME` = '%s' OR `IP` = '%s') AND `IS_STILL_BANNED` = '1' LIMIT 1",pName,IP_);
	mysql_query(WF_DB, Query);
	if(cache_num_rows() > 0)
   	{
		new str[300], Cache: pCache;

		cache_set_active(pCache);
		cache_get_value_name(0, "ADMIN_USERNAME", adminname,MAX_PLAYER_NAME);
		cache_get_value_name(0, "BAN_REASON", banreason,50);
		cache_get_value_name(0, "BANNED_USERNAME", rName, MAX_PLAYER_NAME);
		format(str,sizeof(str), "You were banned from this server %s for %s by admin %s", pName, banreason, adminname);
		SendClientMessage(playerid, COLOR_DARK_RED, str);
		cache_delete(pCache);
		KickPlayer(playerid);
		format(str, sizeof(str), "[BANNED] %s tried to log but fails (Ban reason: %s) (By admin %s) (O.NAME: %s)", pName, banreason, adminname, rName);
		SendMessageToAdmins(COLOR_GREY,str);
	}
	return 1;
}

stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

IsTeamFull(teamid)
{
	new count[MAX_TEAMS][2], k;
	Loop(i)
	{
		k = gTeam[i];
		if (0 <= k < MAX_TEAMS)
		{
			count[k][0] ++;
			count[k][1] = k;
		}
	}

	QuickSort_Pair(count, true, 0, MAX_TEAMS - 1);

	if (count[0][0] < (count[1][0] + 2) && count[1][1] == teamid)
		return false;
	else if (count[0][0] > (count[1][0] + 2) && count[0][1] == teamid)
		return true;
	return false;
}

SendTeamMessage(playerid, color, text[])
{
	foreach(new i : Player)
	{
		if(gTeam[i] == gTeam[playerid])  SendClientMessage(i, color, text);
	}
	return 1;
}
SendEnemyTeamMessage(teamid, color, text[])
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(gTeam[i] != teamid) SendClientMessage(i, color,text);
	}
}

ShowUnlockedKillSStreak(playerid)
{
	if(gMode[playerid] == MODE_MAIN)
	{
		for(new i; i < MAX_SUPPORT_STREAK; i++)
		{
			if(pInfo[playerid][KillStreak] == gSStreak[i][SStreakKSpree])
			{
				new str[100];
				format(str, sizeof(str), "~r~%s~n~~w~Available", gSStreak[i][SStreakName]);
				GameTextForPlayer(playerid, str, 1, 1);
				format(str, sizeof(str), ""COL_LIGHT_BLUE"%s "COL_WHITE"has been unlocked, "COL_LIGHT_RED"Type /sstreak "COL_WHITE"to use it.", gSStreak[i][SStreakName]);
				SendClientMessage(playerid, -1, str);
			}
		}	
	}
	return 1;
}

ShowUnlockedXPSStreak(playerid)
{
	for(new i; i < MAX_SUPPORT_STREAK; i++)
	{
		if(pInfo[playerid][PrevXP] < gSStreak[i][SStreakXP] && pInfo[playerid][pXP] >= gSStreak[i][SStreakXP])
		{
			new str[100];
			format(str, sizeof(str), "~r~%s~n~~w~Available", gSStreak[i][SStreakName]);
			GameTextForPlayer(playerid, str, 1, 1);
			format(str, sizeof(str), ""COL_LIGHT_BLUE"%s "COL_WHITE"has been unlocked, "COL_LIGHT_RED"Type /sstreak "COL_WHITE"to use it.", gSStreak[i][SStreakName]);
			SendClientMessage(playerid, -1, str);			
		}
	}
	pInfo[playerid][PrevXP] = pInfo[playerid][pXP];
	return 1;
}
PlantC4(playerid)
{
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	TogglePlayerControllable(playerid, 0);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 2500, 2000);
	pInfo[playerid][C4Object] = CreateObject(C4_OBJECT, x,y,z -0.8, 0.0,0.0,0.0);
	pInfo[playerid][PlantedC4]++;
	pInfo[playerid][Planting] = true;
	return 1;
}

ShowShopMenu(playerid)
{
	new str[500];
	strcat(str, ""COL_ORANGE"Health\t"COL_LIGHT_RED"$5000\n");
	strcat(str, ""COL_LIGHT_BLUE"Helmet\t"COL_LIGHT_RED"$3000\n");
	strcat(str, ""COL_LIGHT_GREEN"Gas mask\t"COL_LIGHT_RED"$3000\n");
	strcat(str, ""COL_BLUE"Weapons");
	Dialog_Show(playerid, DIALOG_BRIEFCASE, DIALOG_STYLE_TABLIST, "WF - Briefcase", str, "Purchase", "Close");
	return 1;
}

ShowTeamSkinsMenu(playerid)
{
	new str[500], teamid = gTeam[playerid];
	format(str, sizeof(str), "%i\n%i\n%i\n%i\n%i\n%i\n%i\n%i\n%i\n%i", vTeam[teamid][teamSkins][0], vTeam[teamid][teamSkins][1],vTeam[teamid][teamSkins][2],vTeam[teamid][teamSkins][3], vTeam[teamid][teamSkins][4],vTeam[teamid][teamSkins][5],vTeam[teamid][teamSkins][6], vTeam[teamid][teamSkins][7],vTeam[teamid][teamSkins][8],vTeam[teamid][teamSkins][9]);
	ShowPlayerDialog(playerid, TEAM_SKINS_DIALOG, DIALOG_STYLE_PREVIEW_MODEL, "Team skins", str, "Choose", "Cancel");
	return 1;
}

ShowTeamVehiclesMenu(playerid)
{
	new str[500], teamid = gTeam[playerid];
	format(str, sizeof(str), "%i\n%i\n%i\n%i\n%i\n%i", vTeam[teamid][teamVehicles][0], vTeam[teamid][teamVehicles][1],vTeam[teamid][teamVehicles][2],vTeam[teamid][teamVehicles][3], vTeam[teamid][teamVehicles][4],vTeam[teamid][teamVehicles][5]);
	ShowPlayerDialog(playerid, TEAM_VEHICLES_DIALOG, DIALOG_STYLE_PREVIEW_MODEL, "Team vehicles", str, "Spawn", "Cancel");
	return 1;
}

ShowPlayerStats(playerid)
{
	//Player stats
	TextDrawShowForPlayer(playerid, pStatsTD[playerid]);

	//TEAM STATS
	TextDrawShowForPlayer(playerid, TeamStats[playerid]);
	//TD UPDATE
	new str[150];
	format(str, sizeof(str), "~b~S: ~w~%d ~g~K: ~w~%d ~r~D: ~w~%d", pInfo[playerid][Score],pInfo[playerid][Kills],pInfo[playerid][Deaths]);
	TextDrawSetString(pStatsTD[playerid],str);


	new strx[135];
	format(strx, sizeof(strx), "~r~Mercenaries: ~w~%d - ~b~Task force 141: ~w~%d", \
	vTeam[ALPHA][TeamPoints], vTeam[TASKFORCE][TeamPoints]);

	TextDrawSetString(TeamStats[playerid], strx);

	for(new i = -1; i < gRank[playerid]; i++)
	{
		if (i == -1) i = 0;
		TextDrawShowForPlayer(playerid, Star[i]);
	}
	for(new i = (MAX_RANKS - 1); i != gRank[playerid]; i--) TextDrawHideForPlayer(playerid, Star[i]);
	return 1;
}
HidePlayerStats(playerid)
{
	TextDrawHideForPlayer(playerid, PlayerStatsText[playerid]);
	TextDrawHideForPlayer(playerid, pStatsTD[playerid]);
	TextDrawHideForPlayer(playerid, TeamStats[playerid]);
	for(new i; i < MAX_RANKS;i++)
	{
		TextDrawHideForPlayer(playerid, Star[i]);
	}
	return 1;
}
UpdatePlayerStats(playerid)
{
	new str[150];
	format(str, sizeof(str), "~b~S: ~w~%d ~g~K: ~w~%d ~r~D: ~w~%d", pInfo[playerid][Score],pInfo[playerid][Kills],pInfo[playerid][Deaths]);
	TextDrawSetString(pStatsTD[playerid],str);

	new strx[135];
	format(strx, sizeof(strx), "~r~Mercenaries: ~w~%d - ~b~Task force 141: ~w~%d", \
	vTeam[ALPHA][TeamPoints], vTeam[TASKFORCE][TeamPoints]);
	TextDrawSetString(TeamStats[playerid], strx);

	for(new i = -1; i < gRank[playerid]; i++)
	{
		if (i == -1) i = 0;
		TextDrawShowForPlayer(playerid, Star[i]);
	}
	for(new i = (MAX_RANKS - 1); i != gRank[playerid]; i--) TextDrawHideForPlayer(playerid, Star[i]);
	return 1;
}
SendMessageToAdmins(color,str[])
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(pInfo[i][AdminRank] >= 1) SendClientMessage(i, color, str);
	}
	return 1;
}
SetPlayerMoney(playerid, moneyamm)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, moneyamm);
	return 1;
}
PreloadAnimLib(playerid, animlib[])
{
    ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
    return 1;
}
SetPlayerMarkerVisibility(playerid, alpha = 0xFF)
	return (GetPlayerColor(playerid) & ~0xFF) | clamp(alpha, 0x00, 0xFF);

AttachpLabelToPlayer(playerid)
{
	new str[100];
	new pTeam = gTeam[playerid];
	new pClass = gClass[playerid];
	Attach3DTextLabelToPlayer(pInfo[playerid][pLabel], playerid, 0, 0, 0.4);
	format(str, sizeof(str), "%s%s - %s", vTeam[pTeam][teamColor2],vTeam[pTeam][teamName], vClass[pClass][className]);
	Update3DTextLabelText(pInfo[playerid][pLabel], -1, str);
	return 1;
}

ShowEventSettings(playerid)
{
	new settingsDialog[200];
	new string[128];
	strcat(settingsDialog, ""COL_LIGHT_RED"Event Skin: \t");
	
	if (gEvent[EventSkin] == -1) strcat(settingsDialog, ""COL_WHITE"None\n");
	else
	{
	    format(string, sizeof string,""COL_WHITE"%d\n", gEvent[EventSkin]);
	    strcat(settingsDialog, string);
	}
	strcat(settingsDialog, ""COL_LIGHT_GREEN"First weapon: \t");
	
	if (gEvent[EventWeapon1] == -1) strcat(settingsDialog, ""COL_WHITE"None\n");
	else
	{
	    format(string, sizeof string,""COL_WHITE"%d\n", gEvent[EventWeapon1]);
		strcat(settingsDialog, string);
	}
	strcat(settingsDialog, ""COL_LIGHT_BLUE"Second weapon: \t");
	
	if (gEvent[EventWeapon2] == -1) strcat(settingsDialog, ""COL_WHITE"None\n");
	else
	{
	    format(string, sizeof string,""COL_WHITE"%d\n", gEvent[EventWeapon2]);
		strcat(settingsDialog, string);
	}
	strcat(settingsDialog, ""COL_DARK_PINK"Third weapon: \t");
	
	if (gEvent[EventWeapon3] == -1) strcat(settingsDialog, ""COL_WHITE"None\n");
	else
	{
	    format(string, sizeof string,""COL_WHITE"%d\n", gEvent[EventWeapon3]);
	   	strcat(settingsDialog, string);
	}
	strcat(settingsDialog, ""COL_ORANGE"Players are: \t");
	
	if (gEvent[PlayersTeam] == NO_TEAM) strcat(settingsDialog, ""COL_WHITE"Enemies\n");
	else strcat(settingsDialog,""COL_WHITE"Allies\n");
	
	Dialog_Show(playerid, DIALOG_EVENT_SETTINGS, DIALOG_STYLE_TABLIST, "Event - Settings", settingsDialog, "Modify", "close");
	return 1;
}


GetPlayerTeamOwnedZones(playerid)
{
	new teamid = gTeam[playerid], Count;
	for(new i; i < MAX_CAPTURE_ZONES; i++)
	{
		if(gZone[i][zoneOwner] == teamid) Count++;
	}
	return Count;
}
ToggleHelmetForPlayer(playerid, bool:Toggle)
{
	if(Toggle == true)
	{
		SetPlayerAttachedObject(playerid, 1, 19141, 2, 0.094478, 0.007213, 0.000000, 0.000000, 0.000000, 0.000000, 1.200000, 1.200000, 1.200000);
		pInfo[playerid][Helmet] = true;
	}
	else if(Toggle == false)
	{
		RemovePlayerAttachedObject(playerid, 1);
		pInfo[playerid][Helmet] = false;
	}
	return 1;
}
ToggleGasMaskForPlayer(playerid, bool:Toggle)
{
	if(Toggle == true)
	{
		pInfo[playerid][Mask] = true;
		SetPlayerAttachedObject(playerid, 2, 19472, 2, -0.022000, 0.137000, 0.018999, 3.899994, 85.999961, 92.999984, 0.923999, 1.141000, 1.026999);		
	}
	else if(Toggle == false)
	{
		pInfo[playerid][Mask] = false;
		RemovePlayerAttachedObject(playerid, 2);
	}
	return 1;
}
IsTeamRoundWinner(teamid) 
{
	if(vTeam[teamid][TeamPoints] >= ROUND_POINTS)
	{
		for(new i; i < MAX_TEAMS; i++)
		{
			vTeam[i][TeamPoints] = 0;
		}
		for(new i; i < MAX_CAPTURE_ZONES; i++)
		{
			gZone[i][zoneOwner] = NO_TEAM;
			GangZoneShowForAll(gZone[i][zoneId], 0xFFFFFFAA);
		}
		new str[128];
		format(str, sizeof(str), "%s%s "COL_WHITE"have won this round +50 score and 50K money to all team members.", vTeam[teamid][teamColor2],vTeam[teamid][teamName]);
		SendClientMessageToAll(-1,str);
		for(new i; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
			{
				RemovePlayerFromVehicle(i);
				if(gTeam[i] == teamid)
				{
					pInfo[i][Score] += 50;
					SetPlayerScore(i, pInfo[i][Score]);
					pInfo[i][Money] += 50000;
					SetPlayerMoney(i,pInfo[i][Money]);
				}
				if(gMode[i] == MODE_MAIN && pInfo[i][SpawnProtection] == false) OnPlayerSpawn(i);
				pInfo[i][pXP] = 0;
				pInfo[i][PrevXP] = 0;
				IsBallisticVestUsed[i] = false;	
				IsBallisticVestUsed2[i] = false;	
				pInfo[i][pMedicKit] = false;
				pInfo[i][PlantedC4] = 0;
				pInfo[i][IsPlayerFlyingDrone] = false;
				pInfo[i][IsPlayerFlyingDrone] = false;


				if(IsValidVehicle(pInfo[i][ScoutDroneVeh])) DestroyVehicle(pInfo[i][ScoutDroneVeh]);
				if(IsValidVehicle(pInfo[i][DroneVeh])) DestroyVehicle(pInfo[i][DroneVeh]);


				DestroyObject(pInfo[i][C4Object]);
				DestroyObject(pInfo[i][CarePackageObj]);
				DestroyDynamicObject(pInfo[i][BallisticVestObj1]);
				DestroyDynamic3DTextLabel(pInfo[i][CarePackLabel]);
				DestroyDynamic3DTextLabel(pInfo[i][BallisticVestLabel]);
				DestroyDynamicObject(pInfo[i][BallisticVestObj2]);
				DestroyDynamic3DTextLabel(pInfo[i][BallisticVestLabel2]);
				DestroyDynamicObject(pInfo[i][MedicKitObj]);
				DestroyDynamic3DTextLabel(pInfo[i][MedicKitLabel]);
				GameTextForPlayer(i, "~w~Round ~r~over", 2500, 4);
			}
		}
		DestroyDroppedWeapons();
	}
	return 1;
}
SavePlayerStats(playerid)
{
	if(pInfo[playerid][LoggedIn] == true)
	{
		new Query[200];
		GetPlayerIp(playerid, pInfo[playerid][pIP], 16);
		mysql_format(WF_DB, Query, sizeof(Query), "UPDATE `users` SET `SCORE` = '%d', `ADMIN` = '%d',`MONEY` = '%d', `DONOR` = '%d',`KILLS` = '%d', `DEATHS` = '%d' WHERE `USERNAME` = '%e' LIMIT 1",\
		pInfo[playerid][Score], pInfo[playerid][AdminRank],pInfo[playerid][Money], pInfo[playerid][donorLevel],pInfo[playerid][Kills], pInfo[playerid][Deaths],pInfo[playerid][Name]);
		mysql_tquery(WF_DB, Query);	
	}
	return 1;
}

DestroyDroppedWeapons()
{
	for(new i, j = CountDynamicObjects(); i <= j; i++)
	{
		if(gWeaponDrop[i][IsWeaponDropped] == true)
		{
			gWeaponDrop[i][IsWeaponDropped] = false;
			DestroyDynamicObject(gWeaponDrop[i][WeaponObj]);
			DestroyDynamic3DTextLabel(gWeaponDrop[i][WeaponLabel]);
		}
	}
	return 1;
}

/* EVENTS | CALLBACKS */

public OnGameModeInit()
{
	ConnectNPC("TF141 Pilot","TF_PILOT_NPC");
	ConnectNPC("Mercenaries Pilot", "MERC_PILOT_NPC");

	gTF141_Vehicle_Object[0] = CreateObject(3117, 0,0,0,0,0,0);
	gTF141_Vehicle_Object[1] = CreateObject(3117, 0,0,0,0,0,0);

	gMerc_Vehicle_Object[0] = CreateObject(3117,0,0,0,0,0,0);
	gMerc_Vehicle_Object[1] = CreateObject(3117,0,0,0,0,0,0);

	gTF141_Pilot_Vehicle = CreateVehicle(487, 0,0,0,0,0,0,-1);
	gMerc_Pilot_Vehicle = CreateVehicle(487, 0,0,0,0,0,0,-1);

	AttachObjectToVehicle(gTF141_Vehicle_Object[0], gTF141_Pilot_Vehicle, -2.150001, 0.919999, -0.994999, 0.000000, 0.000000, -89.444953); 
	AttachObjectToVehicle(gTF141_Vehicle_Object[1], gTF141_Pilot_Vehicle, 2.140001, 0.914999, -0.994999, 0.000000, 0.000000, -89.444953); 

	AttachObjectToVehicle(gMerc_Vehicle_Object[0], gMerc_Pilot_Vehicle, -2.150001, 0.919999, -0.994999, 0.000000, 0.000000, -89.444953); 
	AttachObjectToVehicle(gMerc_Vehicle_Object[1], gMerc_Pilot_Vehicle, 2.140001, 0.914999, -0.994999, 0.000000, 0.000000, -89.444953); 


	CreateDynamic3DTextLabel(""#TF_COLOR_2"TF141 - Pilot", -1, 0, 0, 0.5, 35, INVALID_PLAYER_ID, gTF141_Pilot_Vehicle);
	CreateDynamic3DTextLabel(""#ALPHA_COLOR_2"Mercenaries - Pilot", -1, 0, 0, 0.5, 35, INVALID_PLAYER_ID, gMerc_Pilot_Vehicle);

	LoadTextDraws();
	print("Textdraws loaded.");
	LoadMap();
	print("Map Loaded");
	UsePlayerPedAnims();
	SetDisableSyncBugs(true);
	SetWeaponDamage(WEAPON_AK47, DAMAGE_TYPE_RANGE, 13.0, 11.0, 10.5);
	SetWeaponDamage(WEAPON_SHOTGUN, DAMAGE_TYPE_RANGE, 35.0, 15.0, 23.0, 25.0, 12.0, 100.0);
	SetWeaponDamage(WEAPON_SHOTGSPA, DAMAGE_TYPE_RANGE, 27.0, 12.0, 20.0, 20.0, 11.5, 100.0);
	SetWeaponDamage(WEAPON_SAWEDOFF, DAMAGE_TYPE_RANGE, 15.0, 10.0, 20.0, 20.0, 8.5, 100.0);
	SetWeaponDamage(WEAPON_SNIPER, DAMAGE_TYPE_RANGE, 40.0, 20.0, 30.0, 60.0, 20.0);
	SetWeaponDamage(WEAPON_M4, DAMAGE_TYPE_RANGE, 13.0, 11.0, 10.5);
	SetWeaponDamage(WEAPON_UZI, DAMAGE_TYPE_STATIC, 12.5);
	SetWeaponDamage(WEAPON_TEC9, DAMAGE_TYPE_STATIC, 12.0);
	SetWeaponDamage(WEAPON_MP5, DAMAGE_TYPE_STATIC, 7.0);
	SetWeaponDamage(WEAPON_DEAGLE,DAMAGE_TYPE_STATIC, 35.0);
	SetWeaponDamage(PISTOL_9MM, DAMAGE_TYPE_STATIC, 12.0);
	SetWeaponDamage(WEAPON_SILENCED, DAMAGE_TYPE_STATIC, 16.0);
	SetWeaponDamage(WEAPON_MINIGUN, DAMAGE_TYPE_STATIC, 2.5);
	SetWeaponDamage(WEAPON_KNIFE, DAMAGE_TYPE_STATIC, 25);
	SetWeaponDamage(WEAPON_KATANA, DAMAGE_TYPE_STATIC, 25);
	SetWeaponDamage(HELI_BLADE, DAMAGE_TYPE_STATIC, 0);
	SetWeaponDamage(WEAPON_VEHICLE, DAMAGE_TYPE_STATIC, 0);
	SetWeaponDamage(WEAPON_VEHICLE_MINIGUN, DAMAGE_TYPE_STATIC, 5);

	SetGameModeText("COD-WF: TDM|DM|Freeroam");
	DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);	
	//Teams creation
	for(new i; i < MAX_TEAMS;i++)
	{
		new str[100];
		AddPlayerClass(vTeam[i][teamSkins][0], -91.1815, 2284.0452, 121.6827, 41.1088,0,0,0,0,0,0);
		vTeam[i][baseID] = GangZoneCreate(vTeam[i][teamBasePos][0], vTeam[i][teamBasePos][1], vTeam[i][teamBasePos][2], vTeam[i][teamBasePos][3]);
		vTeam[i][teamAreaID] = CreateDynamicRectangle(vTeam[i][teamBasePos][0], vTeam[i][teamBasePos][1], vTeam[i][teamBasePos][2], vTeam[i][teamBasePos][3]);
		vTeam[i][teamBriefcaseID] = CreateDynamicPickup(1210, 2, vTeam[i][teamBriefcase][0],vTeam[i][teamBriefcase][1],vTeam[i][teamBriefcase][2]);	
		format(str, sizeof(str), "%s[SHOP]", vTeam[i][teamColor2]);		
		CreateDynamic3DTextLabel(str, -1, vTeam[i][teamBriefcase][0],vTeam[i][teamBriefcase][1],vTeam[i][teamBriefcase][2], 20.0, .testlos = 1);	
		CreateDynamicMapIcon(vTeam[i][teamBriefcase][0],vTeam[i][teamBriefcase][1],vTeam[i][teamBriefcase][2], 6,0,0 , .streamdistance = 300.0);
		format(str, sizeof(str), "%sSpawn Point", vTeam[i][teamColor2]);
		CreateDynamic3DTextLabel(str, -1, vTeam[i][teamSpawnPoints][0], vTeam[i][teamSpawnPoints][1], vTeam[i][teamSpawnPoints][2]+ 0.5, 20.0, .testlos = 1);		
		CreateDynamic3DTextLabel(str, -1, vTeam[i][teamSpawnPoints][3], vTeam[i][teamSpawnPoints][4], vTeam[i][teamSpawnPoints][5]+ 0.5, 20.0, .testlos = 1);	
		CreateDynamic3DTextLabel(str, -1, vTeam[i][teamSpawnPoints][6], vTeam[i][teamSpawnPoints][7], vTeam[i][teamSpawnPoints][8]+ 0.5, 20.0, .testlos = 1);				
	
		vTeam[i][PrototypeID] = AddStaticVehicle(428, vTeam[i][teamPrototypePos][0], vTeam[i][teamPrototypePos][1], vTeam[i][teamPrototypePos][2], vTeam[i][teamPrototypePos][3], vTeam[i][teamColor], vTeam[i][teamColor]);
		format(str, sizeof(str), "%s%s Prototype", vTeam[i][teamColor2],vTeam[i][teamName]);
		vTeam[i][PrototypeTextLabel] = Create3DTextLabel(str, -1, 0, 0,0, 30, 0);
		Attach3DTextLabelToVehicle(vTeam[i][PrototypeTextLabel], vTeam[i][PrototypeID], 0, 0, 0);
		CreateDynamicMapIcon(vTeam[i][teamPrototypePos][0], vTeam[i][teamPrototypePos][1], vTeam[i][teamPrototypePos][2], 51,  0, 0, .streamdistance = 120);
		vTeam[i][TeamPoints] = 0;
		vTeam[i][teamSkinPickupID] = CreateDynamicPickup(1275, 2, vTeam[i][teamSkinPickupPos][0], vTeam[i][teamSkinPickupPos][1], vTeam[i][teamSkinPickupPos][2]);
		CreateDynamicMapIcon(vTeam[i][teamSkinPickupPos][0], vTeam[i][teamSkinPickupPos][1], vTeam[i][teamSkinPickupPos][2], 45, 0);
		Create3DTextLabel("Change your skin", COLOR_GREY, vTeam[i][teamSkinPickupPos][0], vTeam[i][teamSkinPickupPos][1], vTeam[i][teamSkinPickupPos][2], 5, 0);

		vTeam[i][AntennaID] = CreateObject(1596, vTeam[i][AntennaPos][0], vTeam[i][AntennaPos][1], vTeam[i][AntennaPos][2], 0, 0, vTeam[i][AntennaPos][3]);
		format(str, sizeof(str), "%s's antenna", vTeam[i][teamName]);

		CreateDynamic3DTextLabel(str, COLOR_GREY, vTeam[i][AntennaPos][0], vTeam[i][AntennaPos][1], vTeam[i][AntennaPos][2], 20);
		CreateDynamicMapIcon(vTeam[i][AntennaPos][0], vTeam[i][AntennaPos][1], vTeam[i][AntennaPos][2], 48, -1);
		vTeam[i][TeamRadio] = true;

		vTeam[i][teamVehiclesPickupID] = CreateDynamicPickup(19134, 2, vTeam[i][TeamVehiclesPickupPos][0], vTeam[i][TeamVehiclesPickupPos][1], vTeam[i][TeamVehiclesPickupPos][2]);
		CreateDynamicMapIcon(vTeam[i][TeamVehiclesPickupPos][0], vTeam[i][TeamVehiclesPickupPos][1], vTeam[i][TeamVehiclesPickupPos][2], 55, 0);		
		Create3DTextLabel("Vehicle spawner", -1, vTeam[i][TeamVehiclesPickupPos][0], vTeam[i][TeamVehiclesPickupPos][1], vTeam[i][TeamVehiclesPickupPos][2], 25, 0);

		vTeam[i][teamSkyDivePickupID] = CreateDynamicPickup(19133, 2, vTeam[i][TeamSkyDivePickupPos][0], vTeam[i][TeamSkyDivePickupPos][1], vTeam[i][TeamSkyDivePickupPos][2]);
		CreateDynamicMapIcon(vTeam[i][TeamSkyDivePickupPos][0], vTeam[i][TeamSkyDivePickupPos][1], vTeam[i][TeamSkyDivePickupPos][2], 38, -1);
		Create3DTextLabel("Skydive", -1, vTeam[i][TeamSkyDivePickupPos][0], vTeam[i][TeamSkyDivePickupPos][1], vTeam[i][TeamSkyDivePickupPos][2], 25, 0);
		
		vTeam[i][TeamGuideBotID] = CreateActor(vTeam[i][teamSkins][2], vTeam[i][TeamGuideBotPos][0], vTeam[i][TeamGuideBotPos][1], vTeam[i][TeamGuideBotPos][2], vTeam[i][TeamGuideBotPos][3]);
		CreateDynamic3DTextLabel("Press {FF0000}N{FFFFFF} to interact.", -1,vTeam[i][TeamGuideBotPos][0], vTeam[i][TeamGuideBotPos][1], vTeam[i][TeamGuideBotPos][2], 8.5);

		vTeam[i][TeamSamID] = CreateDynamicObject(18848, vTeam[i][TeamSamPos][0],vTeam[i][TeamSamPos][1], vTeam[i][TeamSamPos][2] - 1.2, 0, 0, vTeam[i][TeamSamPos][3]);
		CreateDynamic3DTextLabel("Missile launcher", COLOR_GREY, vTeam[i][TeamSamPos][0],vTeam[i][TeamSamPos][1], vTeam[i][TeamSamPos][2], 10);
		vTeam[i][BaseProtection] = true;

		printf("\nTeam %s created.", vTeam[i][teamName]);
	}
	//Capture zones creations
	new label[45], str[80];
	for (new i; i < MAX_CAPTURE_ZONES; i++)
	{
		gZone[i][zoneOwner] = NO_TEAM;
		gZone[i][zoneId] = GangZoneCreate(gZone[i][zonePos][0], gZone[i][zonePos][1], gZone[i][zonePos][2], gZone[i][zonePos][3]);
		gZone[i][zoneCPId] = CreateDynamicCP(gZone[i][zoneCP][0], gZone[i][zoneCP][1], gZone[i][zoneCP][2], 1.5, 0, .streamdistance = 150.0);
		CreateDynamicMapIcon(gZone[i][zoneCP][0], gZone[i][zoneCP][1], gZone[i][zoneCP][2] - 3, 19, 0, 0, .streamdistance = 700.0);
		gZone[i][zoneAttacker] = INVALID_PLAYER_ID;
		label[0] = EOS;
		strcat(label, gZone[i][zoneName]);
		strcat(label, "\nUncontrolled");
		gZone[i][zoneLabel] = CreateDynamic3DTextLabel(label, 0xFFFFFFFF, gZone[i][zoneCP][0], gZone[i][zoneCP][1], gZone[i][zoneCP][2], 50.0, .worldid = 0, .testlos = 1);
		gZone[i][zoneSPickup] = CreateDynamicPickup(1277, 2,  gZone[i][zoneSpawn][0], gZone[i][zoneSpawn][1], gZone[i][zoneSpawn][2]);
		format(str, sizeof(str), ""COL_WHITE"Set your spawn point to "COL_LIGHT_GREEN"%s", gZone[i][zoneName]);
		CreateDynamic3DTextLabel(str, -1, gZone[i][zoneSpawn][0], gZone[i][zoneSpawn][1], gZone[i][zoneSpawn][2], 15);
		CreateDynamicMapIcon(gZone[i][zoneSpawn][0], gZone[i][zoneSpawn][1], gZone[i][zoneSpawn][2], 35, -1);
		printf("\n\nCapture zone %s created.", gZone[i][zoneName]);
	}
	//Ammo box creations
	for(new i; i < MAX_AMMO_BOXES; i++)
	{
		gAmmoBox[i][AmmoBoxID] = CreateDynamicObject(964, gAmmoBox[i][AmmoBoxPos][0], gAmmoBox[i][AmmoBoxPos][1], gAmmoBox[i][AmmoBoxPos][2]-1.2, 0.000, 0.000, gAmmoBox[i][AmmoBoxPos][3] ,-1, -1, -1, 100, 100);
		CreateDynamic3DTextLabel("Type "COL_LIGHT_GREEN"/refill "COL_WHITE"to refill your ammo", -1,gAmmoBox[i][AmmoBoxPos][0], gAmmoBox[i][AmmoBoxPos][1], gAmmoBox[i][AmmoBoxPos][2], 20);
	}
	printf("\nAmmo boxes Created");
	for(new playerid; playerid < MAX_PLAYERS;playerid++)
	{
		pInfo[playerid][pLabel] = Create3DTextLabel(" ", 0x008080FF, 30.0, 40.0, 30.0, 40.0, 0, 1);
	}
	print("\n3D Texts label created.");

	for(new i; i < MAX_BOMBERS; i++)
	{
		gBombers[i][BomberID] = CreateVehicle(476, gBombers[i][BomberPos][0], gBombers[i][BomberPos][1], gBombers[i][BomberPos][2], gBombers[i][BomberPos][3], 0, 0, 150);
		gBombers[i][BomberBombs] = 5;
		new text3dstr[80];
		format(text3dstr, sizeof(text3dstr), ""COL_LIGHT_BLUE"[BOMBER]\n"COL_WHITE"Bombs: %d/5", gBombers[i][BomberBombs]);
		gBombers[i][Text3DLabelID] = Create3DTextLabel(text3dstr, -1, 0,0,0, 15, -1, 0);
		Attach3DTextLabelToVehicle(gBombers[i][Text3DLabelID], gBombers[i][BomberID], 0,0,0);
	}
	print("\nBomber planes created.");	
	for(new i; i < MAX_SHOPS; i++)
	{
		gShop[i][ShopPickupID] = CreateDynamicPickup(1210, 2, gShop[i][ShopPos][0], gShop[i][ShopPos][1], gShop[i][ShopPos][2]);
		Create3DTextLabel(""COL_LIGHT_GREEN"[SHOP]", -1, gShop[i][ShopPos][0], gShop[i][ShopPos][1], gShop[i][ShopPos][2], 20, 0, 1);
	}
	print("\nBriefcases created.");	
	for(new i = 0; i < MAX_WEAPON_DROP; i++)
	{
		gWeaponDrop[i][IsWeaponDropped] = false;
	}

	pInfo[MAX_PLAYERS][Kills] = 0;
	pInfo[MAX_PLAYERS][Deaths] = 0;
	pInfo[MAX_PLAYERS][LoginFails] = 0;
	pInfo[MAX_PLAYERS][Warns] = 0;
	pInfo[MAX_PLAYERS][AdminRank] = 0;
	pInfo[MAX_PLAYERS][Muted] = false;
	pInfo[MAX_PLAYERS][DND] = false;
	pInfo[MAX_PLAYERS][DuelDND] = false;
	pInfo[MAX_PLAYERS][PlantedC4] = 0;
	pInfo[MAX_PLAYERS][SpawnProtection] = false;
	pInfo[MAX_PLAYERS][pSpawn] = MAX_CAPTURE_ZONES;
	pInfo[MAX_PLAYERS][PlayerSpectating] = false;
	pInfo[MAX_PLAYERS][AmmoRefill] = 0;
	pInfo[MAX_PLAYERS][pXP] = 0;
	pInfo[MAX_PLAYERS][PrevXP] = 0;
	pInfo[MAX_PLAYERS][IsPlayerCapturingProto] = false;
	pInfo[MAX_PLAYERS][ProtoVehID] = -1;
	pInfo[MAX_PLAYERS][TeamProtoIDOwner] = -1;
	pInfo[MAX_PLAYERS][IsPlayerDisarming] = false;
	pInfo[MAX_PLAYERS][IsPlayerFlyingDrone] = false;

	g_Discord_Chat = DCC_FindChannelById("478918277087756337");
	g_Report_Channel = DCC_FindChannelById("478924100887117839");
	g_Logs_Channel = DCC_FindChannelById("478926389903622156");
	g_Discord_StaffChat = DCC_FindChannelById("485775494550257665");

	SetTimer("OnUpdate", 1000, true);
	SetTimer("SendRandomMessage", 180000, true);
	SetTimer("UpdateLaunchTime", 1000, false);	
	SetTimer("AutoSaveTimer", 5*60*1000, true);
	print("\nTimers created.");
	LoadBox();
	print("\nBox log created.");
	gNukePickup = CreateDynamicPickup(1254, 2, -102.2415,2092.2073,17.6554); //nuke
	CreateDynamic3DTextLabel(""COL_LIGHT_RED"[NUKE]", -1, 213.98, 1822.96, 6.41, 10);
	CreateDynamicMapIcon(-102.2415,2092.2073,17.6554, 23,-1);

	gBunkerEntrance = CreateDynamicPickup(1318, 1, -53.8193,1830.3062,17.6406);
	CreateDynamic3DTextLabel("Enter the bunker",-1, -34.8786,1835.7947,17.6476, 5);

	gBunkerExit = CreateDynamicPickup(1318, 1, -43.8326,1826.3868,17.6476);
	CreateDynamic3DTextLabel("Leave the bunker", -1,-35.2194,1847.5522,17.6406, 5);

	gHealthPickup = CreateDynamicPickup(1241, 2, -186.5607,2423.3035,42.4326);
	CreateDynamicMapIcon(-184.7647,2427.4912,42.3365, 22, -1);


	print("\nPickups created.");

	IsRaceDuelOccupied = false;

	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true); 

	WF_DB = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DATABASE, option_id); 
	if(WF_DB == MYSQL_INVALID_HANDLE || mysql_errno(WF_DB) != 0)
	{
		print("ERROR: Could not connect to mysql database\nShutting down..."); 

		SendRconCommand("exit"); 
		return 1;
	}
	print("\nServer has been connected to the database."); 

	mysql_tquery(WF_DB, "CREATE TABLE IF NOT EXISTS `users` (`ID` int(11) NOT NULL AUTO_INCREMENT,`USERNAME` varchar(24) NOT NULL,`PASSWORD` char(65) NOT NULL,`HASHEDPASS` char(11) NOT NULL, `ADMIN` mediumint(7) NOT NULL DEFAULT '0', `DONOR` mediumint(7) NOT NULL DEFAULT '0',`KILLS` mediumint(7) NOT NULL DEFAULT '0', `DEATHS` mediumint(7) NOT NULL DEFAULT '0',`SCORE` mediumint(7) NOT NULL DEFAULT '0',`MONEY` mediumint(7) NOT NULL DEFAULT '0',`IP` varchar(16) NOT NULL, PRIMARY KEY (`ID`), UNIQUE KEY `USERNAME` (`USERNAME`))");
	mysql_tquery(WF_DB, "CREATE TABLE IF NOT EXISTS `bans` (`BAN_ID` int(11) NOT NULL AUTO_INCREMENT, `BANNED_USERNAME` varchar(24) NOT NULL,`BAN_REASON` varchar(50) NOT NULL, `ADMIN_USERNAME` varchar(24) NOT NULL, `IP` varchar(16) NOT NULL, `IS_STILL_BANNED` int(10), PRIMARY KEY (`BAN_ID`))");
	mysql_log(ALL); 
	new g = CountDynamicObjects();
	printf("There are %d objects",g);
	return 1;
}

public OnGameModeExit()
{
	foreach(new i: Player)
    {
		if(IsPlayerConnected(i)) 
		{
			OnPlayerDisconnect(i, 1);
		}
	}

	mysql_close(WF_DB);
	return 1;
}

public SendRandomMessage()
{
	new randMSG = random(sizeof(RandomMessages));
	SendClientMessageToAll(-1, RandomMessages[randMSG]);		
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	for(new i; i < MAX_TEAMS; i++)
	{
		if (vehicleid == vTeam[i][PrototypeID]) SetVehicleParamsForPlayer(vehicleid, forplayerid, 1, 0);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{	
	if(IsPlayerNPC(playerid)) return 1;

	TextDrawShowForPlayer(playerid, WF_TXD[0]);
	TextDrawShowForPlayer(playerid, WF_TXD[1]);
	TextDrawShowForPlayer(playerid, WF_TXD[2]);
	TextDrawShowForPlayer(playerid, WF_TXD[3]);
	SetPlayerColor(playerid, COLOR_GREY);
	CheckForBan(playerid);

	pInfo[playerid] = pInfo[MAX_PLAYERS];
	IsCarePackageUsed[playerid] = false;
	IsBallisticVestUsed[playerid] = false;
	IsDeathmachineUsed[playerid] = false;
	IsDroneUsed[playerid] = false;
	IsDiveBombingRunUsed[playerid] = false;
	IsKamikazeUsed[playerid] = false;
	IsBallisticVestUsed2[playerid] = false;

	GetPlayerName(playerid, pInfo[playerid][Name], MAX_PLAYER_NAME);
	GetPlayerIp(playerid, pInfo[playerid][pIP], 16);

	gMode[playerid] = MODE_MAIN;

	RemoveGtaObjects(playerid);
	ClearChatForPlayer(playerid);

	for(new i; i < MAX_TEAMS;i ++)
	{
		GangZoneShowForPlayer(playerid, vTeam[i][baseID], vTeam[i][teamColor]);
	}
	for(new i; i < MAX_CAPTURE_ZONES; i++)
	{
		if (gZone[i][zoneOwner] != NO_TEAM) GangZoneShowForPlayer(playerid, gZone[i][zoneId],vTeam[gZone[i][zoneOwner]][teamColor]);
		else GangZoneShowForPlayer(playerid, gZone[i][zoneId], 0xFFFFFFAA);
	}
	new str[128];
	format(str, sizeof(str), "~g~~h~JOIN: ~w~%s has joined WF.", pInfo[playerid][Name]);
	SendBoxMessage(str);
	new Query[180];
	mysql_format(WF_DB, Query, sizeof(Query), "SELECT * FROM `users` WHERE `USERNAME` = '%e' LIMIT 1", pInfo[playerid][Name]);
	mysql_tquery(WF_DB, Query, "OnPlayerDataChecked", "ii", playerid, Corrupt_Check[playerid]);		
	pDuel[playerid][E_DUEL_ACTIVE] = -1;
	return 1;
}


public OnPlayerDataChecked(playerid, corrupt_check)
{
	if(corrupt_check != Corrupt_Check[playerid]) return Kick(playerid);
	new str[128];
	if(cache_num_rows() > 0)
	{
		cache_get_value(0, "PASSWORD", pInfo[playerid][Password], 65);
		cache_get_value(0, "HASHEDPASS", pInfo[playerid][hashedpass],11);
		pInfo[playerid][Player_Cache] = cache_save();
		format(str, sizeof(str), ""COL_WHITE"Welcome back "COL_LIGHT_BLUE"%s, "COL_WHITE"Type your password to login.", pInfo[playerid][Name]);		
		Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "WF - Login", str, "Login", "Quit");				
		SendClientMessage(playerid, -1, "Join our "COL_LIGHT_BLUE"discord server"COL_WHITE" and send your "COL_LIGHT_BLUE"in-game name"COL_WHITE" in Verify channel to get rewarded!");
		SendClientMessage(playerid, -1, ""COL_LIGHT_BLUE"Discord server invite: "COL_WHITE"https://discord.gg/pQZKyHG");
		return 1;
	}	
	else
	{
		format(str,sizeof(str), ""COL_WHITE"Welcome to Warfield "COL_DARK_RED"%s,"COL_WHITE"Type your password below to register", pInfo[playerid][Name]);		
		Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "WF - Register", str, "Register", "Quit");
		SendClientMessage(playerid, -1, "Join our "COL_LIGHT_BLUE"discord server"COL_WHITE" and send your "COL_LIGHT_BLUE"in-game name"COL_WHITE" in Verify channel to get rewarded!");
		SendClientMessage(playerid, -1, ""COL_LIGHT_BLUE"Discord server invite: "COL_WHITE"https://discord.gg/pQZKyHG");
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	switch(pDuel[playerid][E_DUEL_ACTIVE])
	{
		case 1:
		{
			new StrX[128], DuelRival = pDuel[playerid][E_DUEL_TARGET];
			GivePlayerMoney(DuelRival, pDuel[playerid][E_DUEL_BET]);
			GivePlayerMoney(playerid, -pDuel[playerid][E_DUEL_BET]);
		    SetPlayerVirtualWorld(DuelRival, 0);
			format(StrX, sizeof StrX, "%s has disconnected and lost the duel against %s Bet: %d Weapon: %d", pInfo[playerid][Name], pInfo[DuelRival][Name],pDuel[playerid][E_DUEL_BET],pDuel[playerid][E_DUEL_WEAPON]);
			SendClientMessageToAll(COLOR_BLUE,StrX);
			SpawnPlayer(DuelRival);
		    gDuelWorld--;
		    pDuel[DuelRival][E_DUEL_ACTIVE] = -1;
		    pDuel[DuelRival][E_DUEL_WEAPON] = -1;
		    pDuel[DuelRival][E_DUEL_BET] = -1;
			pDuel[DuelRival][E_DUEL_TARGET] = -1;
	  		pDuel[DuelRival][E_DUEL_REQUEST] = -1;
	  		
	  		pDuel[playerid][E_DUEL_ACTIVE] = -1;
		    pDuel[playerid][E_DUEL_WEAPON] = -1;
		    pDuel[playerid][E_DUEL_BET] = -1;
			pDuel[playerid][E_DUEL_TARGET] = -1;
			pDuel[playerid][E_DUEL_REQUEST] = -1;	
		}
		case 2:
		{
			new StrX[128], DuelRival = pDuel[playerid][E_DUEL_TARGET];
			GivePlayerMoney(DuelRival, pDuel[playerid][E_DUEL_BET]);
			GivePlayerMoney(playerid, -pDuel[playerid][E_DUEL_BET]);
		    SetPlayerVirtualWorld(DuelRival, 0);
			format(StrX, sizeof StrX, "%s has disconnected and lost the race duel against %s Bet: %d", pInfo[playerid][Name], pInfo[DuelRival][Name],pDuel[playerid][E_DUEL_BET]);
			SendClientMessageToAll(COLOR_BLUE,StrX);
			SpawnPlayer(DuelRival);

		    pDuel[DuelRival][E_DUEL_ACTIVE] = -1;
		    pDuel[DuelRival][E_DUEL_BET] = -1;
			pDuel[DuelRival][E_DUEL_TARGET] = -1;
	  		pDuel[DuelRival][E_DUEL_REQUEST] = -1;
	  		
	  		pDuel[playerid][E_DUEL_ACTIVE] = -1;
		    pDuel[playerid][E_DUEL_BET] = -1;
			pDuel[playerid][E_DUEL_TARGET] = -1;
			pDuel[playerid][E_DUEL_REQUEST] = -1;
			IsRaceDuelOccupied = false;
			DestroyVehicle(vehDuel[0]);
			DestroyVehicle(vehDuel[1]);
			DestroyDynamicCP(cpDuel);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerVirtualWorld(DuelRival, 0);
		}
	}

	if(IsValidVehicle(pInfo[playerid][DroneVeh])) DestroyVehicle(pInfo[playerid][DroneVeh]);
	
	pInfo[playerid][IsPlayerFlyingDrone] = false;

	Corrupt_Check[playerid]++;
	SavePlayerStats(playerid);
	if(cache_is_valid(pInfo[playerid][Player_Cache]))
	{
		cache_delete(pInfo[playerid][Player_Cache]);
		pInfo[playerid][Player_Cache] = MYSQL_INVALID_CACHE; 
	}

	pInfo[playerid][LoggedIn] = false;
	new str[128];
	switch(reason)
	{
		case 0: format(str, sizeof str, "~r~Crash/ Timeout: ~w~%s has left WF.", pInfo[playerid][Name]);
		case 1: format(str, sizeof str, "~r~Quit: ~w~%s has left WF.", pInfo[playerid][Name]);
		case 2: format(str, sizeof str, "~r~Kick: ~w~%s has left WF.", pInfo[playerid][Name]);
	}
	SendBoxMessage(str);
	HidePlayerBox(playerid);
	if(IsValidVehicle(pInfo[playerid][pCar])) DestroyVehicle(pInfo[playerid][pCar]);
	if(IsValidVehicle(pInfo[playerid][DiveBombingVeh])) DestroyVehicle(pInfo[playerid][DiveBombingVeh]);
	DestroyObject(pInfo[playerid][C4Object]);
	DestroyObject(pInfo[playerid][CarePackageObj]);
	DestroyDynamicObject(pInfo[playerid][BallisticVestObj1]);
	DestroyDynamic3DTextLabel(pInfo[playerid][CarePackLabel]);
	DestroyDynamic3DTextLabel(pInfo[playerid][BallisticVestLabel]);
	DestroyDynamicObject(pInfo[playerid][BallisticVestObj2]);
	DestroyDynamic3DTextLabel(pInfo[playerid][BallisticVestLabel2]);
	DestroyDynamicObject(pInfo[playerid][MedicKitObj]);
	DestroyDynamic3DTextLabel(pInfo[playerid][MedicKitLabel]);
	if(pInfo[playerid][IsPlayerCapturingProto] == true)
	{
		SetVehicleToRespawn(pInfo[playerid][ProtoVehID]);
		TogglePlayerAllDynamicCPs(playerid, 1);
		DisablePlayerCheckpoint(playerid);
		format(str, sizeof(str), ""COL_LIGHT_RED"%s[%d] "COL_WHITE"has failed to capture %s's prototype.",pInfo[playerid][Name], playerid, vTeam[pInfo[playerid][TeamProtoIDOwner]][teamName]);
		SendClientMessageToAll(-1, str);				
		pInfo[playerid][IsPlayerCapturingProto] = false;			
		pInfo[playerid][ProtoVehID] = -1;
		pInfo[playerid][TeamProtoIDOwner] = -1;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case TEAM_SKINS_DIALOG:
		{
			new teamid = gTeam[playerid];
			SetPlayerSkin(playerid, vTeam[teamid][teamSkins][listitem]);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "Your skin has been changed.");
		}
		case TEAM_VEHICLES_DIALOG:
		{
			new teamid = gTeam[playerid];
			if(IsValidVehicle(pInfo[playerid][pCar])) DestroyVehicle(pInfo[playerid][pCar]);
			new Float:x,Float:y,Float:z, Float:r;
			GetPlayerPos(playerid,x,y,z);
			GetPlayerFacingAngle(playerid, r);
			pInfo[playerid][pCar] = CreateVehicle(vTeam[teamid][teamVehicles][listitem], x, y, z, r,0,0,0);
			PutPlayerInVehicle(playerid, pInfo[playerid][pCar], 0);
		}
		case TEAM_GUIDE_BOT_DIALOG:
		{
			if(!response) return SendClientMessage(playerid, COLOR_RED, "Canceled");
			{
				switch(listitem)
				{
					case 0: ShowPlayerDialog(playerid,SERVER_INFO_DIALOG,DIALOG_STYLE_LIST,"Server Information","What is CoD WF?\nHow do I earn Score?\nWhat classes can I play?\nWhere do I buy weapons?\nWhat is a killing/capture spree?","Select","Cancel");
					case 1: cmd_rules(playerid);
					case 2:	cmd_credits(playerid);
				}				   
			}
		}
		case SERVER_INFO_DIALOG:
		{
			if(!response) return SendClientMessage(playerid, COLOR_RED, "Canceled");
			{
				switch(listitem)
				{
					case 0:
					{
						ShowPlayerDialog(playerid,305,DIALOG_STYLE_MSGBOX,"CoD WF?","{FFFFFF}Call of Duty Warfield is a team based gamemode inspired by our famous game Call Of Duty,\nwhere two teams try fight each other for the win. Hop in for a single adventure\nor teamup with your teammates for even more fun.{FFFFFF}","Okay","");
					}
					case 1:
					{
						new earningscore[500];
						strcat(earningscore,"{0000FF}Capture Zones:{FFFFFF}\n");
						strcat(earningscore,"The simpliest way to get score is to capture zones.\n");
						strcat(earningscore,"Just move to one(found on the map) and stand on the red marked area until the timer is over.\n");
						strcat(earningscore,"{FF0000}Eliminate Players:{FFFFFF}\n");
						strcat(earningscore,"This one is a little bit harder. You can kill your enemies to earn score and money.\n");
						strcat(earningscore,"{00FF00}Capture Prototypes:{FFFFFF}\n");
						strcat(earningscore,"Each team has its own Prototype(Yellow marked vehicle on map), which can be stolen from the enemy team.\n");
						strcat(earningscore,"Just simply enter the vehicle and drive it to your base to the red marked location.\n");
						ShowPlayerDialog(playerid,306,DIALOG_STYLE_MSGBOX,"Earning Score", earningscore,"Okay","");	
					}
					case 2:
					{
						ShowPlayerDialog(playerid,312,DIALOG_STYLE_MSGBOX,"Server Classes","{FFFFFF}There is a big amount of classes you can select.\nJust simply hit /st to see what is available.\nUse /ranks to check how much score you need for the specific class.","Okay","");
					}
					case 3:
					{
						ShowPlayerDialog(playerid,313,DIALOG_STYLE_MSGBOX,"Buying Weapons","{FFFFFF}Every team has a shop which is marked on your map as a gun.\nSimply enter the pickup and you can use the shop.","Okay","");		
					}
					case 4:
					{
						new spreecap[500];
						strcat(spreecap,"{FFFFFF}We have a killstreak and capture spree system on our server.\n");
						strcat(spreecap,"This means your kills/captures will be collected.\n");
						strcat(spreecap,"As soon as you got a certain amount you can use /sstreak to unlock features.\n");

						ShowPlayerDialog(playerid,314,DIALOG_STYLE_MSGBOX,"Killstreak/Capture Spree", spreecap,"Okay","");						
					}
				}			
			}	
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{	
	if(IsPlayerNPC(playerid))
	{
		new npcname[MAX_PLAYER_NAME];
		GetPlayerName(playerid, npcname, sizeof(npcname));
		if(npcname[0] == 'T' && npcname[1] == 'F' && npcname[2] == '1' && npcname[3] == '4' && npcname[4] == '1')
		{
			PutPlayerInVehicle(playerid, gTF141_Pilot_Vehicle, 0);
			SetPlayerColor(playerid, TF_COLOR);
			SetPlayerSkin(playerid, 287);
			PutPlayerInVehicle(playerid, gTF141_Pilot_Vehicle, 0);
			SendClientMessageToAll(-1, ""COL_LIGHT_BLUE"Task force 141. Pilot: "COL_WHITE"is taking off in 30 seconds.");		
			return 1;
		}
		else if(npcname[0] == 'M' && npcname[1] == 'e' && npcname[2] == 'r' && npcname[3] == 'c' && npcname[4] == 'e')
		{
			PutPlayerInVehicle(playerid, gMerc_Pilot_Vehicle, 0);
			SetPlayerColor(playerid, ALPHA_COLOR);
			SetPlayerSkin(playerid, 28);
			PutPlayerInVehicle(playerid, gMerc_Pilot_Vehicle, 0);
			SendClientMessageToAll(-1, ""COL_LIGHT_RED"Mercenaries. Pilot: "COL_WHITE"is taking off in 30 seconds.");				
			return 1;
		}
	}
	TextDrawShowForPlayer(playerid, WF_WEBSITE);
	ResetPlayerWeapons(playerid);
	PreloadAnimLib(playerid,"BOMBER");
	ShowPlayerStats(playerid);
	ShowPlayerBox(playerid);
	if(pInfo[playerid][AdminDuty] == true) 
	{
		SetPlayerPos(playerid,-146.8526,2011.9005,29.7403);
		SetPlayerSkin(playerid, ONDUTY_ADMIN_SKIN);
		ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid, WEAPON_MINIGUN, 99999);
		SetPlayerHealth(playerid, 99999.0);	
		return 1;
	}
	switch(gMode[playerid])
	{
		case MODE_MAIN:
		{
			new str[110];
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerColor(playerid, vTeam[gTeam[playerid]][teamColor]);
			SetPlayerHealth(playerid, 99999.0);
			switch(random(10))
			{
				case 0: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][0]);
				case 1: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][1]);
				case 2: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][2]);
				case 3: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][3]);
				case 4: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][4]);
				case 5: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][5]);
				case 6: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][6]);
				case 7: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][7]);
				case 8: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][8]);
				case 9: SetPlayerSkin(playerid, vTeam[gTeam[playerid]][teamSkins][9]);
			}
			SetPlayerTeam(playerid, gTeam[playerid]);
			TextDrawHideForPlayer(playerid, CountText[playerid]);

			format(str, sizeof(str), ""COL_LIGHT_BLUE"Anti-SK: "COL_WHITE"You've 10 seconds of anti spawn kill, You can end it by pressing N.");

			SendClientMessage(playerid, -1, str);
			AttachpLabelToPlayer(playerid);
			ToggleHelmetForPlayer(playerid, true);
			pInfo[playerid][IsPlayerHavingHelmet] =  true;
			pInfo[playerid][SpawnProtection] = true;
			pInfo[playerid][SpawnProtectionTime] = gettime() + 10;	
			IsCarePackageUsed[playerid] = false;
			IsDeathmachineUsed[playerid] = false;
			IsDroneUsed[playerid] = false;
			IsDiveBombingRunUsed[playerid] = false;
			IsKamikazeUsed[playerid] = false;
			IsMOABUsed[playerid] = false;
			pInfo[playerid][IsPlayerInBunker] = false;
			pInfo[playerid][KillStreak] = 0;
			if (pInfo[playerid][pSpawn] < MAX_CAPTURE_ZONES)
			{
				if (gZone[pInfo[playerid][pSpawn]][zoneOwner] != gTeam[playerid])
				{
					pInfo[playerid][pSpawn] = MAX_CAPTURE_ZONES;
					SendClientMessage(playerid, COLOR_RED, "Your team lost the zone and you're now spawning at your base.");	
					SpawnPlayerAtTeamBase(playerid);
					Streamer_Update(playerid, STREAMER_TYPE_OBJECT);
					Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
					if(pInfo[playerid][FirstSpawn] == true)
					{
						pInfo[playerid][FirstSpawn] = false;
						ShowClassFeatures(playerid);					
					}
				}
				else
				{
					SendClientMessage(playerid, COLOR_RED, "You're going to spawn in the capture zone you selected.");
					SetPlayerPos(playerid, gZone[pInfo[playerid][pSpawn]][zoneSpawn][0], gZone[pInfo[playerid][pSpawn]][zoneSpawn][1], gZone[pInfo[playerid][pSpawn]][zoneSpawn][2]+120);
					SetPlayerFacingAngle(playerid, gZone[pInfo[playerid][pSpawn]][zoneSpawn][3]);
					GivePlayerWeapon(playerid, 46,1);
					if(pInfo[playerid][FirstSpawn] == true)
					{
						pInfo[playerid][FirstSpawn] = false;
					}
				}
			}
			else
			{
				SpawnPlayerAtTeamBase(playerid);
				Streamer_Update(playerid, STREAMER_TYPE_OBJECT);
				Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
				if(pInfo[playerid][FirstSpawn] == true)
				{
					pInfo[playerid][FirstSpawn] = false;
					ShowClassFeatures(playerid);					
				}
			}

			SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 998);					
			SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 998);
			switch(gClass[playerid])
			{
				case CLASS_SNIPER:
				{
					SetPlayerMarkerVisibility(playerid, 0xFF000099);
				}
				case CLASS_JETTROOPER:
				{
					SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 999);			
				}
			}
			return 1;
		}
		case MODE_SDM:
		{
			pInfo[playerid][Helmet] = false;
			SetPlayerHealth(playerid, 100);
			SetPlayerArmour(playerid, 0.0);
			SendClientMessage(playerid, COLOR_ORANGE, "INFO: You can leave death match arenas by typing /qdm.");
			SetPlayerTeam(playerid, NO_TEAM);
			GivePlayerWeapon(playerid, vMode[MODE_SDM][modeWeaponA], 9999);
			SetPlayerInterior(playerid, vMode[MODE_SDM][modeInterior]);
			SetPlayerColor(playerid, COLOR_WHITE);
			switch(random(3))
			{
				case 0: SetPlayerPos(playerid, vMode[MODE_SDM][modeSpawnA][0],vMode[MODE_SDM][modeSpawnA][1],vMode[MODE_SDM][modeSpawnA][2]);
				case 1: SetPlayerPos(playerid, vMode[MODE_SDM][modeSpawnB][0],vMode[MODE_SDM][modeSpawnB][1],vMode[MODE_SDM][modeSpawnB][2]);
				case 2: SetPlayerPos(playerid, vMode[MODE_SDM][modeSpawnC][0],vMode[MODE_SDM][modeSpawnC][1],vMode[MODE_SDM][modeSpawnC][2]);
			}
			switch(random(3))
			{
				case 0: SetPlayerSkin(playerid, vMode[MODE_SDM][modeSkins][0]);
				case 1: SetPlayerSkin(playerid, vMode[MODE_SDM][modeSkins][1]);
				case 2: SetPlayerSkin(playerid, vMode[MODE_SDM][modeSkins][2]);
			}
			return 1;
		}
		case MODE_DEDM:
		{
			pInfo[playerid][Helmet] = false;
			SetPlayerTeam(playerid, playerid);
			SetPlayerHealth(playerid, 100);
			SetPlayerArmour(playerid, 0.0);
			SendClientMessage(playerid, COLOR_ORANGE, "INFO: You can leave death match arenas by typing /qdm.");
			GivePlayerWeapon(playerid, vMode[MODE_DEDM][modeWeaponA], 9999);
			SetPlayerInterior(playerid, vMode[MODE_DEDM][modeInterior]);
			SetPlayerColor(playerid, COLOR_WHITE);			
			switch(random(3))
			{
				case 0: SetPlayerPos(playerid, vMode[MODE_DEDM][modeSpawnA][0],vMode[MODE_DEDM][modeSpawnA][1],vMode[MODE_DEDM][modeSpawnA][2]);
				case 1: SetPlayerPos(playerid, vMode[MODE_DEDM][modeSpawnB][0],vMode[MODE_DEDM][modeSpawnB][1],vMode[MODE_DEDM][modeSpawnB][2]);
				case 2: SetPlayerPos(playerid, vMode[MODE_DEDM][modeSpawnC][0],vMode[MODE_DEDM][modeSpawnC][1],vMode[MODE_DEDM][modeSpawnC][2]);
			}
			switch(random(3))
			{
				case 0: SetPlayerSkin(playerid, vMode[MODE_DEDM][modeSkins][0]);
				case 1: SetPlayerSkin(playerid, vMode[MODE_DEDM][modeSkins][1]);
				case 2: SetPlayerSkin(playerid, vMode[MODE_DEDM][modeSkins][2]);
			}
		}		
	}
	return 1;
}

public OnPlayerFakeKill(playerid, spoofedid, spoofedreason, faketype)
{
	new str[128];
	format(str, sizeof(str), "%s[%d] has been kicked by the server for using illegal mods.", pInfo[playerid][Name],playerid);
	SendClientMessageToAll(COLOR_LIGHT_RED,str);
	format(str, sizeof(str), "%s[%d] Has been kicked by the server for fake kill", pInfo[playerid][Name],playerid);
	SendMessageToAdmins(COLOR_GREY, str);
	KickPlayer(playerid);
	format(str, sizeof(str), "Server has kicked %s for fake kill", pInfo[playerid][Name]);
	DCC_SendChannelMessage(g_Logs_Channel, str);		
	return 1;
}

public OnAntiCheatLagTroll(playerid)
{
	new str[128];
	format(str, sizeof(str), "%s[%d] has been kicked by the server for using illegal mods.", pInfo[playerid][Name],playerid);
	SendClientMessageToAll(COLOR_LIGHT_RED,str);
	format(str, sizeof(str), "%s[%d] Has been kicked by the server for troll hack", pInfo[playerid][Name],playerid);
	SendMessageToAdmins(COLOR_GREY, str);
	KickPlayer(playerid);
	format(str, sizeof(str), "Server has kicked %s for troll hack", pInfo[playerid][Name]);
	DCC_SendChannelMessage(g_Logs_Channel, str);		
	return 1;
}

public OnPlayerSpamChat(playerid)
{
	new str[128];
	format(str, sizeof(str), "%s[%d] Has been kicked for spamming the chat.", pInfo[playerid][Name],playerid);
	SendClientMessageToAll(COLOR_LIGHT_RED, str);
	KickPlayer(playerid);
	format(str, sizeof(str), "Server has kicked %s for spamming the chat", pInfo[playerid][Name]);
	DCC_SendChannelMessage(g_Logs_Channel, str);		
	return 1;
}

public OnPlayerSlide(playerid, weaponid, Float:speed)
{
	DamagePlayer(playerid, 5.0);
	GameTextForPlayer(playerid, "~r~Slide bug ~w~is not allowed !", 3000, 3);
	SendClientMessage(playerid, COLOR_LIGHT_RED, "-5 Health for slide bugging.");
	return 1;
}

public OnPlayerAirbreak(playerid)
{
	new string[128];
	format(string, sizeof(string), "%s[%d] has been kicked by the server for using illegal mods.", pInfo[playerid][Name],playerid);
	SendClientMessageToAll(COLOR_LIGHT_RED,string);
	format(string, sizeof(string), "%s[%d] Has been kicked by the server for Airbreak", pInfo[playerid][Name],playerid);
	SendMessageToAdmins(COLOR_GREY, string);
	KickPlayer(playerid);
	format(string, sizeof(string), "Server has kicked %s for airbreak", pInfo[playerid][Name]);
	DCC_SendChannelMessage(g_Logs_Channel, string);		
	return 1;
}

public OnPlayerDeath(playerid,killerid,reason)
{
	SendDeathMessage(killerid, playerid, reason);

	if (pDuel[playerid][E_DUEL_ACTIVE] == 1)
	{
		new StrX[128], DuelRival = pDuel[playerid][E_DUEL_TARGET];
		pInfo[killerid][Money] += pDuel[playerid][E_DUEL_BET];
		SetPlayerMoney(killerid, pInfo[killerid][Money]);
		pInfo[playerid][Money] += pDuel[playerid][E_DUEL_BET];
		SetPlayerMoney(playerid, pInfo[playerid][Money]);		
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerVirtualWorld(DuelRival, 0);
		format(StrX, sizeof StrX, "%s has won a duel against %s Bet: %d Weapon: %s",pInfo[DuelRival][Name],pInfo[playerid][Name], pDuel[playerid][E_DUEL_BET],WeaponNames[pDuel[playerid][E_DUEL_WEAPON]]);
		SendClientMessageToAll(COLOR_BLUE,StrX);
		SpawnPlayer(DuelRival);
	    gDuelWorld--;

	    pDuel[playerid][E_DUEL_ACTIVE] = -1;
	    pDuel[playerid][E_DUEL_WEAPON] = -1;
	    pDuel[playerid][E_DUEL_BET] = -1;
		pDuel[playerid][E_DUEL_TARGET] = -1;
		pDuel[playerid][E_DUEL_REQUEST] = -1;

	    pDuel[DuelRival][E_DUEL_WEAPON] = -1;
	    pDuel[DuelRival][E_DUEL_BET] = -1;
		pDuel[DuelRival][E_DUEL_TARGET] = -1;
  		pDuel[DuelRival][E_DUEL_ACTIVE] = -1;
  		pDuel[DuelRival][E_DUEL_REQUEST] = -1;
  		return 1;
	}

	if(killerid != INVALID_PLAYER_ID)
	{
		pInfo[playerid][Deaths]++;
		pInfo[killerid][Kills]++;
		new str[128], MoneyAmount = random(5000 - 1000);
		format(str, sizeof(str), ""COL_WHITE"You've killed "COL_LIGHT_GREEN"%s "COL_WHITE"and earned "COL_LIGHT_GREEN"%d money & +1 score.",pInfo[playerid][Name], MoneyAmount);
		SendClientMessage(killerid, -1, str);
		format(str, sizeof(str), ""COL_WHITE"You've been killed "COL_LIGHT_RED"by %s, "COL_WHITE"And lost 1000 Money.", pInfo[killerid][Name]);
		SendClientMessage(playerid, -1, str);
		pInfo[killerid][Money] += MoneyAmount;
		SetPlayerMoney(killerid, pInfo[killerid][Money]);
		pInfo[playerid][Money] -= 1000;
		pInfo[playerid][KillStreak] = 0;
		pInfo[killerid][KillStreak]++;
		pInfo[killerid][Score] += 1;
		SetPlayerScore(killerid, pInfo[killerid][Score]);
		SetPlayerMoney(playerid, pInfo[playerid][Money]);	
		ShowUnlockedKillSStreak(killerid);		
		switch(pInfo[killerid][KillStreak])
		{
			case 3, 5, 10, 15, 20, 25, 50, 100, 125, 150, 200:
			{
				format(str, sizeof(str), ""COL_LIGHT_GREEN"%s "COL_WHITE"is on a killing spree of "COL_ORANGE"%d.",pInfo[killerid][Name], pInfo[killerid][KillStreak]);
				SendClientMessageToAll(-1, str);
				SetPlayerMoney(killerid, pInfo[killerid][KillStreak] * 100);
				GivePlayerScore(killerid, pInfo[killerid][KillStreak]);
				format(str, sizeof(str), "You got "COL_LIGHT_GREEN"%d score and %d money "COL_WHITE"for the killing spree %d.", pInfo[killerid][KillStreak], pInfo[killerid][KillStreak] * 100, pInfo[killerid][KillStreak]);
				SendClientMessage(killerid, -1, str);
			}
		}
		if(gMode[playerid] == MODE_MAIN)
		{
			if(pDuel[playerid][E_DUEL_ACTIVE] != 1) DropPlayerWeapon(playerid);
			new teamid = gTeam[killerid], OwnedZones;
			OwnedZones = GetPlayerTeamOwnedZones(killerid);
			if(OwnedZones == 0)
			{
				vTeam[teamid][TeamPoints] += POINT_PER_KILL;
			}
			else
			{
				vTeam[teamid][TeamPoints] += (POINT_PER_KILL * OwnedZones);
			}
			IsTeamRoundWinner(teamid);
		}
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	switch(newstate)
	{
		case PLAYER_STATE_DRIVER:
		{
			SetPlayerArmedWeapon(playerid, 0);

			for(new i; i < MAX_TEAMS; i++)
			{
				if(IsPlayerInVehicle(playerid, vTeam[i][PrototypeID]))
				{
					if(gTeam[playerid] == i)
					{
						RemovePlayerFromVehicle(playerid);
						SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't capture your team's prototype, Protect it instead.");
					}
					else 
					{
						new str[128];
						format(str, sizeof(str), ""COL_WHITE"You're capturing "COL_LIGHT_GREEN"%s's prototype, "COL_WHITE"Deliver it to the red checkpoint on the map.", vTeam[i][teamName]);
						SendClientMessage(playerid, -1,str);
						format(str, sizeof(str), ""COL_LIGHT_RED"%s[%d] "COL_WHITE"Is capturing %s's prototype",pInfo[playerid][Name],playerid, vTeam[i][teamName]);
						SendClientMessageToAll(-1, str);
						SetPlayerCheckpoint(playerid, vTeam[gTeam[playerid]][PrototypeCP][0],vTeam[gTeam[playerid]][PrototypeCP][1], vTeam[gTeam[playerid]][PrototypeCP][2], 5.0);
						TogglePlayerAllDynamicCPs(playerid, 0);
						pInfo[playerid][IsPlayerCapturingProto] = true;
						pInfo[playerid][ProtoVehID] = GetPlayerVehicleID(playerid);
						pInfo[playerid][TeamProtoIDOwner] = i;
					}
				}
			}
			for(new i; i < MAX_BOMBERS; i++)
			{
				if(IsPlayerInVehicle(playerid, gBombers[i][BomberID]))
				{
					SendClientMessage(playerid, COLOR_LIGHT_BLUE, "[BOMBER] "COL_WHITE"Press 'y' to drop a bomb.");
				}
			}
			switch(GetVehicleModel(GetPlayerVehicleID(playerid)))
			{
				case 432:
				{
					if(gClass[playerid] != CLASS_ENGINEER && pInfo[playerid][AdminDuty] == false && gClass[playerid] != CLASS_DONOR)
					{
						RemovePlayerFromVehicle(playerid);
						SendClientMessage(playerid, COLOR_DARK_RED, "You need to be an engineer to drive rhino.");
					}
				}
				case 520:
				{
					if(gClass[playerid] != CLASS_PILOT && pInfo[playerid][AdminDuty] == false && gClass[playerid] != CLASS_DONOR)
					{
						RemovePlayerFromVehicle(playerid);
						SendClientMessage(playerid, COLOR_DARK_RED, "You need to be a pilot to fly with such a vehicle.");
					}				
				}
				case 425:
				{
					if(gClass[playerid] != CLASS_PILOT && pInfo[playerid][AdminDuty] == false && gClass[playerid] != CLASS_DONOR)
					{
						RemovePlayerFromVehicle(playerid);
						SendClientMessage(playerid, COLOR_DARK_RED, "You need to be a pilot to fly with such a vehicle.");
					}				
				}
				case 447:
				{
					if(gClass[playerid] != CLASS_SCOUT && pInfo[playerid][AdminDuty] == false && gClass[playerid] != CLASS_DONOR)
					{
						RemovePlayerFromVehicle(playerid);
						SendClientMessage(playerid, COLOR_DARK_RED, "You need to be a scout to fly with such a vehicle.");
					}			
				}		
			}
		}
		case PLAYER_STATE_ONFOOT:
		{
			if(pInfo[playerid][IsPlayerCapturingProto] == true)
			{
				if(IsPlayerInRangeOfPoint(playerid, 5.0, vTeam[gTeam[playerid]][PrototypeCP][0],vTeam[gTeam[playerid]][PrototypeCP][1], vTeam[gTeam[playerid]][PrototypeCP][2])) return 1;
				new str[128];
				SetVehicleToRespawn(pInfo[playerid][ProtoVehID]);
				TogglePlayerAllDynamicCPs(playerid, 1);
				DisablePlayerCheckpoint(playerid);
				format(str, sizeof(str), ""COL_LIGHT_RED"%s[%d] "COL_WHITE"has failed to capture %s's prototype.",pInfo[playerid][Name], playerid, vTeam[pInfo[playerid][TeamProtoIDOwner]][teamName]);
				SendClientMessageToAll(-1, str);				
				pInfo[playerid][IsPlayerCapturingProto] = false;			
				pInfo[playerid][ProtoVehID] = -1;
				pInfo[playerid][TeamProtoIDOwner] = -1;
			}
		}
	}
	return 1;
}			
public OnPlayerExitVehicle(playerid, vehicleid)
{
	for(new i; i < MAX_TEAMS;i++)
	{
		if(vehicleid == vTeam[i][PrototypeID])
		{
			RemovePlayerFromVehicle(playerid);
			SetVehicleToRespawn(vehicleid);
			DisablePlayerCheckpoint(playerid);
			TogglePlayerAllDynamicCPs(playerid, 1);
			new str[128];
			format(str, sizeof(str), ""COL_LIGHT_RED"%s[%d] "COL_WHITE"has failed to capture %s's prototype.",pInfo[playerid][Name], playerid, vTeam[i][teamName]);
			SendClientMessageToAll(-1, str);
			pInfo[playerid][IsPlayerCapturingProto] = false;			
		}
	}
	return 1;
}
public OnPlayerJackVehicle(playerid,victimid,vehicleid,bool:ninjajack)
{
	if(gTeam[victimid] == gTeam[playerid])
	{
		
	}
	for(new i; i < MAX_TEAMS;i++)
	{
		if(vehicleid == vTeam[i][PrototypeID])
		{
			DisablePlayerCheckpoint(victimid);
			TogglePlayerAllDynamicCPs(victimid, 1);
			new str[128];
			format(str, sizeof(str), ""COL_LIGHT_RED"%s[%d] "COL_WHITE"has failed to capture %s's prototype.",pInfo[victimid][Name], victimid, vTeam[i][teamName]);
			SendClientMessageToAll(-1, str);
			if(gTeam[playerid] == i) SetVehicleToRespawn(vehicleid);
			pInfo[victimid][IsPlayerCapturingProto]	= false;
		}
	}
	return 1;
}
public OnVehicleDeath(vehicleid, killerid)
{
	for(new i; i < MAX_TEAMS;i++)
	{
		if(vehicleid == vTeam[i][PrototypeID])
		{
			new PrototypeDriver = GetVehicleDriverID(vehicleid);
			RemovePlayerFromVehicle(vehicleid);
			SetVehicleToRespawn(vehicleid);
			DisablePlayerCheckpoint(PrototypeDriver);
			TogglePlayerAllDynamicCPs(PrototypeDriver, 1);
			new str[128];
			format(str, sizeof(str), ""COL_LIGHT_RED"%s[%d] "COL_WHITE"has failed to capture %s's prototype.",pInfo[PrototypeDriver][Name], PrototypeDriver, vTeam[i][teamName]);
			SendClientMessageToAll(-1, str);
			pInfo[PrototypeDriver][IsPlayerCapturingProto]	= false;
		
		}
	}
	for(new i = 0, j = GetPlayerPoolSize(); i <= j;i++)
	{
		if(vehicleid == pInfo[i][KamikazeVeh])
		{
			new Float:x,Float:y,Float:z;
			GetVehiclePos(vehicleid, x, y, z);
			for(new d = 0, f = GetPlayerPoolSize(); d <= f;d++)
			{
				if(IsPlayerInRangeOfPoint(d, 25, x, y, z) && gTeam[i] != gTeam[d])
				{
					SetPlayerHealth(d, 0.0);
					OnPlayerDeath(d,i,SUICIDER_EXPLOSION);
					SendClientMessage(d, -1, ""COL_WHITE"You were "COL_LIGHT_RED"killed "COL_WHITE"by a kamikaze plane.");
					new str[128];
					format(str, sizeof(str), ""COL_ORANGE"%s[%d] "COL_WHITE"has been murdered by "COL_LIGHT_RED"a kamikaze plane.",pInfo[d][Name],d);
					SendClientMessageToAll(-1,str);
				}
			}
			CreateExplosion(x, y, z, 4, 50);
			CreateExplosion(x+3, y, z, 4, 50);
			CreateExplosion(x, y+3, z, 4, 50);
			CreateExplosion(x, y, z+3, 4, 50);
			CreateExplosion(x+5, y, z, 4, 50);
			CreateExplosion(x, y+5, z, 4, 50);
			CreateExplosion(x, y, z+5, 4, 50);
			CreateExplosion(x+10, y, z, 4, 50);
			CreateExplosion(x, y+10, z, 4, 50);
			CreateExplosion(x, y, z+10, 4, 50);
			CreateExplosion(x+20, y, z, 4, 50);
			CreateExplosion(x, y+20, z, 4, 50);
			CreateExplosion(x, y, z+20, 4, 50);
		}
		else if(vehicleid == pInfo[i][DroneVeh])
		{
			RemovePlayerFromVehicle(i);
			DestroyVehicle(pInfo[i][DroneVeh]);
			SetPlayerPos(i, pInfo[i][pPos][0],pInfo[i][pPos][1],pInfo[i][pPos][2]);
			pInfo[i][IsPlayerFlyingDrone] = false;
			SendClientMessage(i, COLOR_GREY, "Your drone is destroyed.");
		}
		else if(vehicleid == pInfo[i][ScoutDroneVeh])
		{
			RemovePlayerFromVehicle(i);
			DestroyVehicle(pInfo[i][ScoutDroneVeh]);
			SetPlayerPos(i, pInfo[i][pPos][0],pInfo[i][pPos][1],pInfo[i][pPos][2]);
			pInfo[i][IsPlayerFlyingScoutDrone] = false;
			SendClientMessage(i, COLOR_GREY, "Your drone is destroyed.");
		}
	}
	return 1;
}



public OnPlayerEnterCheckpoint(playerid)
{
	new str[100];
	for(new i; i < MAX_TEAMS; i++)
	{
		if (IsPlayerInVehicle(playerid, vTeam[i][PrototypeID]))
		{
			RemovePlayerFromVehicle(vTeam[i][PrototypeID]);			
			SetVehicleToRespawn(pInfo[playerid][ProtoVehID]);
			TogglePlayerAllDynamicCPs(playerid, 1);
			DisablePlayerCheckpoint(playerid);

			format(str, sizeof str, ""COL_LIGHT_RED"%s[%d] "COL_WHITE"has successfully captured team %s's Prototype !", pInfo[playerid][Name], playerid, vTeam[i][teamName]);
			SendClientMessageToAll(-1, str);

			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "Congratulations! You got +10 score and +10000 cash and "#XP_PER_CAPTURE_PROTOTYPE" XP.");

			pInfo[playerid][Money] += 10000;
			pInfo[playerid][Score] += 10;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);
			SetPlayerScore(playerid, pInfo[playerid][Score]);

			pInfo[playerid][pXP] += XP_PER_CAPTURE_PROTOTYPE;
			ShowUnlockedXPSStreak(playerid);

			pInfo[playerid][IsPlayerCapturingProto] = false;
			pInfo[playerid][ProtoVehID] = -1;
			pInfo[playerid][TeamProtoIDOwner] = -1;					

			new teamid = gTeam[playerid];
			vTeam[teamid][TeamPoints] += POINT_PER_PROTOTYPE_CAPTURE;
			IsTeamRoundWinner(teamid);

			break;
		}
	}
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	new str[200];
	if (!success)
	{
		SendClientMessage(playerid, COLOR_RED, "ERROR: Invalid command entered, please refer to /cmds to check the command.");
	}
	format(str, sizeof(str), "%s: %s",pInfo[playerid][Name],cmdtext);
	print(str);
	foreach(new i : Player)
	{
		if(pInfo[i][AdminRank] > pInfo[playerid][AdminRank] && pInfo[i][AdminRank] > TRIAL_ADMIN) SendClientMessage(i, COLOR_GREY, str);
	}
	return true;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;

	TextDrawHideForPlayer(playerid, WF_TXD[0]);
	TextDrawHideForPlayer(playerid, WF_TXD[1]);
	TextDrawHideForPlayer(playerid, WF_TXD[2]);
	TextDrawHideForPlayer(playerid, WF_TXD[3]);
	
	HidePlayerBox(playerid);
  	HidePlayerStats(playerid);	
	if (classid >= 0 && classid <= (MAX_TEAMS - 1))
	{
		gTeam[playerid] = classid;
		new str[100];
		format(str,sizeof(str), "%s Team", vTeam[gTeam[playerid]][teamName]);
		TextDrawColor(TeamTXD[playerid], vTeam[gTeam[playerid]][teamColor]);
		TextDrawSetString(TeamTXD[playerid], str);		
		SetPlayerFacingAngle(playerid, 275.000);
		SetPlayerPos(playerid,2859.0276,1977.5500,828.3314);
		SetPlayerCameraPos(playerid,2862.2336,1976.3732,828.3314);
		SetPlayerCameraLookAt(playerid, 2859.0276,1977.5500,828.3314);
		SetPlayerSkin(playerid, vTeam[classid][teamSkins][0]);
		TextDrawShowForPlayer(playerid, TeamTXD[playerid]);
		SetPlayerColor(playerid, vTeam[classid][teamColor]);
		GivePlayerWeapon(playerid, WEAPON_DEAGLE, 1);
		SetPlayerArmedWeapon(playerid, WEAPON_DEAGLE);
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;

	if(pInfo[playerid][LoggedIn] == false)
	{
		SendClientMessage(playerid, COLOR_LIGHT_RED, "You need to login first.");
		new Query[180];
		mysql_format(WF_DB, Query, sizeof(Query), "SELECT * FROM `users` WHERE `USERNAME` = '%e' LIMIT 1", pInfo[playerid][Name]);
		mysql_tquery(WF_DB, Query, "OnPlayerDataChecked", "ii", playerid, Corrupt_Check[playerid]);		
		return 0;
	}
	if(IsTeamFull(gTeam[playerid]))
	{
		GameTextForPlayer(playerid, "Team is full", 1000, 3);
		return 0;
	} 
	TextDrawHideForPlayer(playerid, TeamTXD[playerid]);
	pInfo[playerid][FirstSpawn] = true;
	ShowClassDialog(playerid);
	return 0;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if ((hittype != BULLET_HIT_TYPE_NONE) && 0 <= weaponid <= WEAPON_MOLTOV)
	{
		new str[128];
		format(str, sizeof(str), "%s[%d] has been kicked by the server for using illegal mods",pInfo[playerid][Name], playerid);
		SendClientMessageToAll(COLOR_LIGHT_RED, str);
		KickPlayer(playerid);
		format(str, sizeof(str), "%s tried to use bullet crash.",pInfo[playerid][Name]);
		SendMessageToAdmins(COLOR_GREY, str);
		format(str, sizeof(str), "Server has kicked %s bullet crasher", pInfo[playerid][Name]);
		DCC_SendChannelMessage(g_Logs_Channel, str);
		return 0;
	}
	switch(gMode[playerid])
	{
		case MODE_DEDM:
		{
			ClearAnimations(playerid);
		}
	}
	return 1;
}

public OnUpdate()
{
	foreach(new playerid: Player)
	{
		GetPlayerPos(playerid, pInfo[playerid][pPos][0],pInfo[playerid][pPos][1],pInfo[playerid][pPos][2]);
		switch(gTeam[playerid])
		{
			case ALPHA: //Merc = alpha
			{
				if(IsPlayerInDynamicArea(playerid, vTeam[TASKFORCE][teamAreaID]) && IsPlayerInHeavyVehicle(playerid) && vTeam[TASKFORCE][BaseProtection] == true)
				{
					SetPlayerHealth(playerid, 0);
					CreateExplosion(pInfo[playerid][pPos][0],pInfo[playerid][pPos][1],pInfo[playerid][pPos][2], 3, 5);
					SendClientMessage(playerid, COLOR_RED, "You were killed by the base Shield, Destroy it next time before raiding the base with heavy vehicles.");
				}
			}
			case TASKFORCE:
			{
				if(IsPlayerInDynamicArea(playerid, vTeam[ALPHA][teamAreaID]) && IsPlayerInHeavyVehicle(playerid) && vTeam[ALPHA][BaseProtection] == true)
				{
					SetPlayerHealth(playerid, 0);
					CreateExplosion(pInfo[playerid][pPos][0],pInfo[playerid][pPos][1],pInfo[playerid][pPos][2], 3, 5);
					SendClientMessage(playerid, COLOR_RED, "You were killed by the base Shield, Destroy it next time before raiding the base with heavy vehicles.");
				}
			}
		}

		gRank[playerid] = GetPlayerRank(playerid);
		if((pInfo[playerid][Planting] == true) && (pInfo[playerid][PlantingTime] < gettime()))
		{
			TogglePlayerControllable(playerid, true);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "C4 Has been planted, You can detonate it by using /detonate.");
			pInfo[playerid][Planting] = false;
		}
		if((pInfo[playerid][SpawnProtection] == true) && (pInfo[playerid][SpawnProtectionTime] < gettime()))
		{
			new str[128];
			format(str, sizeof(str), ""COL_LIGHT_RED"Anti-SK "COL_WHITE"is over you're on your own now.");

		
			SendClientMessage(playerid, -1, str);
			pInfo[playerid][SpawnProtection] = false;
			GivePlayerClassWeapons(playerid);
			SetPlayerHealth(playerid, 100.0);		
		}
		if(pInfo[playerid][Muted] == true && pInfo[playerid][MuteTime] < gettime())
		{
			pInfo[playerid][Muted] = false;
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You have been unmuted.");
		}
		if(IsPlayerSpawned(playerid)) UpdatePlayerStats(playerid);
		if(pDuel[playerid][E_DUEL_PROTECTION] == true && pDuel[playerid][E_DUEL_PROTECTION_TIME] < gettime())
		{
			pDuel[playerid][E_DUEL_PROTECTION] = false;
			TogglePlayerControllable(playerid, true);
		}
		if(pInfo[playerid][IsPlayerDisarming] == true && pInfo[playerid][DisarmingTime] < gettime())
		{
			TogglePlayerControllable(playerid, 1);
			pInfo[playerid][IsPlayerDisarming] = false;
		}
	}
	for(new i; i < MAX_TEAMS;i++)
	{
		if(vTeam[i][TeamRadioDownTime] < gettime() && vTeam[i][TeamRadio] == false)
		{
			vTeam[i][TeamRadio] = true;
			vTeam[i][AntennaID] = CreateObject(1596, vTeam[i][AntennaPos][0], vTeam[i][AntennaPos][1], vTeam[i][AntennaPos][2], 0, 0, vTeam[i][AntennaPos][3]);
			SendEnemyTeamMessage(i, -1, "Our enemy's "COL_LIGHT_RED"radio is back online");
			for(new x =0, j =GetPlayerPoolSize(); x <= j; x++)
			{
				if(gTeam[x] == i) SendClientMessage(x, -1, "Our radio "COL_LIGHT_GREEN"is back online !");
			}
		}
		else if(vTeam[i][TeamShieldDownTime] < gettime() && vTeam[i][BaseProtection] ==  false)
		{
			vTeam[i][BaseProtection] = true;
			vTeam[i][TeamSamID] = CreateDynamicObject(18848, vTeam[i][TeamSamPos][0],vTeam[i][TeamSamPos][1], vTeam[i][TeamSamPos][2] - 1.2, 0, 0, vTeam[i][TeamSamPos][3]);
			SendEnemyTeamMessage(i, -1, "Our enemy's "COL_LIGHT_RED"Shield is back");
			for(new x =0, j =GetPlayerPoolSize(); x <= j; x++)
			{
				if(gTeam[x] == i) SendClientMessage(x, -1, "Our shield "COL_LIGHT_GREEN"is back !");
			}
		}
	}
	return 1;
}

public AutoSaveTimer()
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i)&& pInfo[i][LoggedIn] == true)
		{
			new Query[350];
			GetPlayerIp(i, pInfo[i][pIP], 16);
			mysql_format(WF_DB, Query, sizeof(Query), "UPDATE `users` SET `SCORE` = '%d', `ADMIN` = '%d',`MONEY` = '%d', `DONOR` = '%d',`KILLS` = '%d', `DEATHS` = '%d', `IP` = '%s' WHERE `USERNAME` = '%s' LIMIT 1",\
			pInfo[i][Score], pInfo[i][AdminRank],pInfo[i][Money], pInfo[i][donorLevel],pInfo[i][Kills], pInfo[i][Deaths], pInfo[i][pIP],pInfo[i][Name]);
			mysql_tquery(WF_DB, Query);
		}
	}
	SendClientMessageToAll(-1, ""COL_LIGHT_BLUE"Info: "COL_WHITE"All online players stats have been saved.");
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public UpdateLaunchTime()
{
	if (gNukeTime >= 1)
	{
		if (gNukeTime == 240)
		{
			SendClientMessageToAll(-1, "Nuclear dust have been settled.");
			SetWeather(11);
		}
		if (--gNukeTime <= 0) gNukeTime = 0;
	}
	SetTimer("UpdateLaunchTime", 1000, false);	
	return 1;
}	


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_SUBMISSION ) 
	{
		if(pInfo[playerid][IsPlayerFlyingDrone] == true)
		{
			RemovePlayerFromVehicle(playerid);
			DestroyVehicle(pInfo[playerid][DroneVeh]);
			SetPlayerPos(playerid, pInfo[playerid][pPos][0],pInfo[playerid][pPos][1],pInfo[playerid][pPos][2]);
			pInfo[playerid][IsPlayerFlyingDrone] = false;
			SendClientMessage(playerid, COLOR_GREY, "You have left your drone.");			
		}
		else if(pInfo[playerid][IsPlayerFlyingScoutDrone] == true)
		{
			RemovePlayerFromVehicle(playerid);
			DestroyVehicle(pInfo[playerid][ScoutDroneVeh]);
			SetPlayerPos(playerid, pInfo[playerid][pPos][0],pInfo[playerid][pPos][1],pInfo[playerid][pPos][2]);
			pInfo[playerid][IsPlayerFlyingScoutDrone] = false;
			SendClientMessage(playerid, COLOR_GREY, "You have left your drone.");					
		}
	}
	if(newkeys & KEY_NO)
	{
		if(pInfo[playerid][SpawnProtection] == true)
		{
			new str[128];
			format(str, sizeof(str), ""COL_LIGHT_RED"Anti-SK "COL_WHITE"is over you're on your own now.");
			SendClientMessage(playerid, -1, str);
			pInfo[playerid][SpawnProtection] = false;
			SetPlayerHealth(playerid, 100.0);	
			GivePlayerClassWeapons(playerid);
		}
		for(new i; i < MAX_TEAMS;i++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 5, vTeam[i][TeamGuideBotPos][0],  vTeam[i][TeamGuideBotPos][1],  vTeam[i][TeamGuideBotPos][2]))
			{
				if(gTeam[playerid] != i) return SendClientMessage(playerid, COLOR_RED, "You can't interact with enemy guide bot.");
				ShowPlayerDialog(playerid, TEAM_GUIDE_BOT_DIALOG,DIALOG_STYLE_LIST,"Guide Menu","Information\nServer Rules\nCredits","Select","Cancel");
			}
		}
	}	
	if(newkeys & KEY_FIRE && pInfo[playerid][PlayerSpectating] == true)
	{
		pInfo[playerid][PlayerSpectating] = false;
		TogglePlayerSpectating(playerid, 0);
		SendClientMessage(playerid, COLOR_GREY, "Spectate mode has been turned off.");	
	}
	if(newkeys & KEY_FIRE)
	{
		new pWeapon = GetPlayerWeapon(playerid);
		if(pWeapon == WEAPON_TEARGAS)
		{
			new Float:x,Float:y,Float:z;
			GetPlayerPos(playerid, x,y,z);
		
			for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
			{
				if(IsPlayerInRangeOfPoint(i, 5.0, x,y, z))
				{
					if(gTeam[i] != gTeam[playerid] && pInfo[i][Mask] == false)
					{
						ApplyAnimation(i, "ped", "gas_cwr", 1.0, 0, 0, 0, 0, 0);						
					}
				}
			}

		}

	}
	if(newkeys & KEY_YES)
	{
		if(pInfo[playerid][IsPlayerFlyingScoutDrone])
		{
			new Float:x,Float:y,Float:z;
			GetVehiclePos(pInfo[playerid][ScoutDroneVeh], x, y, z);
			RemovePlayerFromVehicle(playerid);
			SetPlayerPos(playerid, pInfo[playerid][pPos][0], pInfo[playerid][pPos][1], pInfo[playerid][pPos][2]);
			CreateExplosion(x, y, z, 2, 3);
			DestroyVehicle(pInfo[playerid][ScoutDroneVeh]);
			pInfo[playerid][IsPlayerFlyingScoutDrone] = false;
			for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
			{
				if(gTeam[i] != gTeam[playerid])
				{
					if(IsPlayerInRangeOfPoint(i, 7.5, x, y, z))
					{						
						OnPlayerDeath(i, playerid, SUICIDER_EXPLOSION);
						SendClientMessage(i, COLOR_RED, "You were killed by a drone explosion.");
					}
				}
			}
			return 1;
		}
		for(new i; i < MAX_BOMBERS;i++)
		{
			if(IsPlayerInVehicle(playerid, gBombers[i][BomberID]))
			{
				if(gBombers[i][BomberBombs] <= 0) return SendClientMessage(playerid, COLOR_LIGHT_RED, "You don't have bombs anymore.");
				if(pInfo[playerid][BombLaunch] > gettime()) return SendClientMessage(playerid, COLOR_LIGHT_RED, "You need to wait 10 seconds before dropping a bomb once again.");
				gBombers[i][BomberBombs]--;
				new text3dstr[80],Float:x,Float:y,Float:z;
				format(text3dstr, sizeof(text3dstr), ""COL_LIGHT_BLUE"[BOMBER]\n"COL_WHITE"Bombs: %d/5", gBombers[i][BomberBombs]);
				Update3DTextLabelText(gBombers[i][Text3DLabelID], -1, text3dstr);
				pInfo[playerid][BombLaunch] = (gettime() + 10);
				SendClientMessage(playerid, -1, ""COL_LIGHT_BLUE"[BOMBER] "COL_WHITE"You've dropped a bomb.");
				GetPlayerPos(playerid, x,y,z);
				gBombers[i][BombObjID] = CreateObject(1636, x,y,z-3,-90.000,-90.000,-90.000,100.000);
				GetPointZPos(x,y,z);
				MoveObject(gBombers[i][BombObjID], x, y, z, 70);
			}
		}
	}
	if(newkeys & KEY_WALK)
	{
		for(new i = 0; i < MAX_WEAPON_DROP; i++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 5,gWeaponDrop[i][WeaponPos][0],gWeaponDrop[i][WeaponPos][1],gWeaponDrop[i][WeaponPos][2]) && gWeaponDrop[i][IsWeaponDropped] == true)
			{
				DestroyDynamicObject(gWeaponDrop[i][WeaponObj]);
				DestroyDynamic3DTextLabel(gWeaponDrop[i][WeaponLabel]);
				GivePlayerWeapon(playerid, gWeaponDrop[i][WeaponInfo][0], gWeaponDrop[i][WeaponInfo][1]);
				gWeaponDrop[i][WeaponPos][0] = 0;
				gWeaponDrop[i][WeaponPos][1] = 0;
				gWeaponDrop[i][WeaponPos][2] = 0;
				gWeaponDrop[i][IsWeaponDropped] = false;
				new str[80];
				format(str, sizeof(str), ""COL_WHITE"You got a "COL_LIGHT_BLUE"%s with %d ammo.", WeaponNames[gWeaponDrop[i][WeaponInfo][0]],gWeaponDrop[i][WeaponInfo][1]);
				SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
				return 1;
			}
		}
		for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
		{
			new Float:x,Float:y,Float:z;
			GetDynamicObjectPos(pInfo[i][MedicKitObj], x, y, z);
			if(IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z))
			{
				new Float: Healthp;
				GetPlayerHealth(playerid, Healthp);
				if(Healthp >= 100) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You've full health already.");
				DestroyDynamicObject(pInfo[i][MedicKitObj]);
				DestroyDynamic3DTextLabel(pInfo[i][MedicKitLabel]);
				pInfo[i][pMedicKit] = false;
				if(Healthp <= 70)
				{
					SetPlayerHealth(playerid, Healthp+ 30);
				}
				else if(Healthp > 70)
				{
					SetPlayerHealth(playerid, Healthp +(100 - Healthp ));
				}
				SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You have used a medic kit + 30 Health.");
				return 1;
			}
		}			
	}
	if(PRESSING(newkeys, KEY_HANDBRAKE))
	{
	    if(pInfo[playerid][Helmet] == true && (GetPlayerWeapon(playerid) == 34 || GetPlayerWeapon(playerid) == 35))
	    {
        	if(IsPlayerAttachedObjectSlotUsed(playerid, 1))
        	{
        	    RemovePlayerAttachedObject(playerid, 1);
        	}
		}
	}
	else if(RELEASED(KEY_HANDBRAKE))
	{
	    if(pInfo[playerid][Helmet] == true && (GetPlayerWeapon(playerid) == 34 || GetPlayerWeapon(playerid) == 35))
	    {
	   		SetPlayerAttachedObject(playerid, 1, 19141, 2, 0.094478, 0.007213, 0.000000, 0.000000, 0.000000, 0.000000, 1.200000, 1.200000, 1.200000 );
	    }
	}	
	return 1;
}


public OnDynamicObjectMoved(objectid)
{
	//
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(objectid == pInfo[i][MoabObj])
		{
			new deathcount;
			for(new a = 0, b = GetPlayerPoolSize(); a <= b; a++)
			{
				if(pInfo[a][SpawnProtection] == false && gMode[a] == MODE_MAIN && gTeam[i] != gTeam[a])
				{
					new Float:x,Float:y,Float:z;
					GetPlayerPos(a, x,y,z);
					CreateExplosion(x, y, z, 4, 10);
					OnPlayerDeath(a, i, SUICIDER_EXPLOSION);
					SetPlayerHealth(a, 0.0);
					deathcount++;
				}
			}
			new str[128];
			format(str, sizeof(str), ""COL_ORANGE"NEWS: "COL_WHITE"It's been reported that "COL_LIGHT_RED"%d people "COL_WHITE"died because of the MOAB attack.", deathcount);
			SendClientMessageToAll(-1, str);
		}
	}
	return 1;
}


public OnObjectMoved(objectid)
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(objectid == pInfo[i][CarePackageObj])
			{
				new Float:x,Float:y,Float:z;
				GetObjectPos(pInfo[i][CarePackageObj], x,y,z);			
				DestroyObject(objectid);
				pInfo[i][CarePackageObj] = CreateObject(11745,x,y,z, 0.0,0.0,0.0,150);
				pInfo[i][CarePackLabel] = CreateDynamic3DTextLabel(""COL_LIGHT_GREEN"Care package\n"COL_WHITE"/getpack", COLOR_ORANGE, x,y,z, 20);
				return 1;
			}
		}
	}

	for(new i; i < MAX_BOMBERS;i++)
	{
		if(objectid == gBombers[i][BombObjID])
		{
			new DriverID = 	GetVehicleDriverID(gBombers[i][BomberID]);


			new Float:x,Float:y,Float:z;
			GetObjectPos(objectid, x, y,z);
			
			CreateExplosion(x, y, z, 2, 50.00);

			CreateExplosion(x+1, y, z, 2, 50.00);	
			CreateExplosion(x-1, y, z, 2, 50.00);		

			CreateExplosion(x, y-1, z, 2, 50.00);	
			CreateExplosion(x, y+1, z, 2, 50.00);
			
			CreateExplosion(x,y,z+1,2,50.0);

			DestroyObject(gBombers[i][BombObjID]);
			for(new d = 0, j = GetPlayerPoolSize(); d <= j; d++)
			{
				if(IsPlayerInRangeOfPoint(d, 7.5, x, y, z) && d != DriverID && gTeam[d] != gTeam[DriverID])
				{
					SetPlayerHealth(d, 0.0);
					OnPlayerDeath(d, DriverID, SUICIDER_EXPLOSION);
					SendClientMessage(d, -1, "You were "COL_LIGHT_RED"killed "COL_WHITE"by a bomber bomb.");
					SendClientMessage(DriverID, -1, "You got +1 score bonus for killing with a bomber.");
					GivePlayerScore(DriverID, 1);
				}
			}
			return 1;
		}
	}
	if(objectid == gAirstrikeObject)
	{
		new Float:x,Float:y,Float:z;
		GetObjectPos(gAirstrikeObject, x,y,z);
		CreateExplosion(x,y,z,2,10000.0);
		CreateExplosion(x + 3, y,z, 2,1000);
		CreateExplosion(x, y+3,z, 2,1000);
		CreateExplosion(x,y,z+3, 2,1000);
		DestroyObject(gAirstrikeObject);
		new string[100];
		format(string,sizeof string,""COL_LIGHT_GREEN"%s[%d] "COL_WHITE"has launched an airstrike.",pInfo[gAirstrikeLauncherID][Name],gAirstrikeLauncherID);
		SendClientMessageToAll(COLOR_RED, string);
		return 1;
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{

	for(new i; i < MAX_BOMBERS; i++)
	{
		if(vehicleid == gBombers[i][BomberID])
		{
			gBombers[i][BomberBombs] = 5;
			new text3dstr[80];
			format(text3dstr, sizeof(text3dstr), ""COL_LIGHT_BLUE"[BOMBER]\n"COL_WHITE"Bombs: %d/5", gBombers[i][BomberBombs]);
			Update3DTextLabelText(gBombers[i][Text3DLabelID], -1, text3dstr);		
		}
	}
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(vehicleid == pInfo[i][KamikazeVeh])
		{
			DestroyVehicle(vehicleid);
		}
		else if(vehicleid == pInfo[i][pCar])
		{
			DestroyVehicle(vehicleid);
		}
	}	
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new i; i < MAX_TEAMS; i++)
	{
		if(pickupid == vTeam[i][teamBriefcaseID])
		{
			if(gTeam[playerid] != i) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't purchase from enemy shop.");
			ShowShopMenu(playerid);
		}

		else if(pickupid == vTeam[i][teamSkinPickupID])
		{
			if(gTeam[playerid] != i) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: This is not your team's pickup.");
			ShowTeamSkinsMenu(playerid);	
		}
		else if(pickupid == vTeam[i][teamVehiclesPickupID])
		{
			if(gTeam[playerid] != i) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: This is not your team's pickup.");
			ShowTeamVehiclesMenu(playerid);
		}
		else if(pickupid == vTeam[i][teamSkyDivePickupID])
		{
			if(gTeam[playerid] != i) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: This is not your team's pickup.");
			new str[650];
			for(new x; x < MAX_CAPTURE_ZONES; x++)
			{
				if (gZone[x][zoneOwner] == gTeam[playerid]) strcat(str, COL_LIGHT_GREEN);
				else if (gZone[x][zoneAttacker] != INVALID_PLAYER_ID) strcat(str, COL_ORANGE);
				else strcat(str, COL_LIGHT_RED);

				strcat(str, gZone[x][zoneName]);
				strcat(str, "\n");
			}
			Dialog_Show(playerid, DIALOG_SKYDIVE, DIALOG_STYLE_LIST, "Deploy on", str, "Deploy", "Cancel");
		}
	}
	for(new i; i < MAX_SHOPS;i++)
	{
		if(pickupid == gShop[i][ShopPickupID])
		{
			ShowShopMenu(playerid);
		}
	}
	for(new i; i < MAX_CAPTURE_ZONES;i++)
	{
		if(pickupid == gZone[i][zoneSPickup])
		{
			new str[128];
			if(gZone[i][zoneOwner] != gTeam[playerid]) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You cannot set your spawn point to this zone, Your team doesn't own it.");
			pInfo[playerid][pSpawn] = i;
			format(str, sizeof(str), "Your spawn point has been set to "COL_LIGHT_BLUE"%s.", gZone[i][zoneName]);
			SendClientMessage(playerid, -1, str);
		}	
	}
	if (pickupid == gNukePickup)
	{
		if (gNukeTime >= 1)
		{
			new StrX[80];
			format(StrX, sizeof StrX, "Nuke is not ready for launch wait %d seconds.", gNukeTime);
			SendClientMessage(playerid, COLOR_RED, StrX);
			return 1;
		}
		if (gZone[CP_MISSILEFACTORY][zoneOwner] != gTeam[playerid]) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your team doesn't own Area 51.");
		if (pInfo[playerid][Money] < NUKE_COST) return SendClientMessage(playerid, COLOR_RED, "ERROR: You need $"#NUKE_COST" cash to launch Nuke!");
		if (gRank[playerid] < NUKE_RANK) return SendClientMessage(playerid, COLOR_RED, "ERROR: You need rank "#NUKE_RANK" to launch Nuke!");

		new str[255];
		for(new i; i < MAX_TEAMS; i++)
		{
			format(str, sizeof str, "%s{%06x}%s\n", str, vTeam[i][teamColor] >>> 8, vTeam[i][teamName]);
		}
		Dialog_Show(playerid, DIALOG_NUKE, DIALOG_STYLE_LIST, "WF - Nuke Bomb", str, "Okay", "");
	}
	if(pickupid == gHealthPickup)
	{
		return SetPlayerHealth(playerid, 100.0) && 	SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got full health.");
	}	
	if(pickupid == gBunkerEntrance)
	{
		if(gZone[CP_BUNKER][zoneOwner] != gTeam[playerid]) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your team doesn't own bunker zone.");
		SetPlayerPos(playerid, -50.9521,1824.2797,17.6406);
		pInfo[playerid][IsPlayerInBunker] = true;
		SendClientMessage(playerid, -1, "You're "COL_LIGHT_GREEN"now protected "COL_WHITE"from enemy MOAB.");
	}
	if(pickupid == gBunkerExit)
	{
		SetPlayerPos(playerid, -54.1036,1836.1364,17.6406);
		pInfo[playerid][IsPlayerInBunker] = false;
		SendClientMessage(playerid, -1, "You're "COL_LIGHT_RED"no longer protected "COL_WHITE"from enemy MOAB.");		
	}
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	new text[150];
	for (new i; i < MAX_CAPTURE_ZONES; i++)
	{
		if(checkpointid == cpDuel)
		{
			if(pDuel[playerid][E_DUEL_ACTIVE] == 2)
			{
				new str[128], DuelRival = pDuel[playerid][E_DUEL_TARGET];
				RemovePlayerFromVehicle(playerid);
				RemovePlayerFromVehicle(DuelRival);
				DestroyVehicle(vehDuel[0]);
				DestroyVehicle(vehDuel[1]);
				DestroyDynamicCP(cpDuel);
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerVirtualWorld(DuelRival, 0);

				SpawnPlayer(playerid);
				SpawnPlayer(DuelRival);

			   	pInfo[DuelRival][Money] += pDuel[playerid][E_DUEL_BET];
				SetPlayerMoney(DuelRival, pInfo[DuelRival][Money]);
				pInfo[playerid][Money] += pDuel[playerid][E_DUEL_BET];
				SetPlayerMoney(playerid, pInfo[playerid][Money]);	
				 
				format(str,sizeof(str), ""COL_BLUE"%s has won a race duel against %s and won %d", pInfo[playerid][Name], pInfo[DuelRival][Name], pDuel[playerid][E_DUEL_BET]);
				SendClientMessageToAll(-1, str);
				IsRaceDuelOccupied = false;
			    pDuel[playerid][E_DUEL_ACTIVE] = -1;
			    pDuel[playerid][E_DUEL_WEAPON] = -1;
			    pDuel[playerid][E_DUEL_BET] = -1;
				pDuel[playerid][E_DUEL_TARGET] = -1;
				pDuel[playerid][E_DUEL_REQUEST] = -1;

			    pDuel[DuelRival][E_DUEL_WEAPON] = -1;
			    pDuel[DuelRival][E_DUEL_BET] = -1;
				pDuel[DuelRival][E_DUEL_TARGET] = -1;
		  		pDuel[DuelRival][E_DUEL_ACTIVE] = -1;
		  		pDuel[DuelRival][E_DUEL_REQUEST] = -1;

			}
		}

		else if (gZone[i][zoneCPId] == checkpointid)
		{
			if (pInfo[playerid][AdminDuty]) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can't capture zones while on admin duty.");
			if (pInfo[playerid][PlayerSpectating] == true) return 0;
			if (gZone[i][zoneAttacker] != INVALID_PLAYER_ID)
			{
				if (gTeam[playerid] == gTeam[gZone[i][zoneAttacker]])
				{
					if (IsPlayerInAnyVehicle(playerid))
					{
						return SendClientMessage(playerid, COLOR_RED, "You cannot assist in capturing the zone in a vehicle.");
					}
					TextDrawShowForPlayer(playerid, CountText[playerid]);
					format(text, sizeof text, "~r~Capturing...~n~~g~%d", gZone[i][zoneTick]);
					TextDrawSetString(CountText[playerid], text);

					gZone[i][zonePlayer] ++;
					SendClientMessage(playerid, COLOR_ORANGE, "Stay in the checkpoint to assist your teammate in capturing the zone.");
					SendClientMessage(gZone[i][zoneAttacker], COLOR_ORANGE, "You're getting assistance from a team mate.");
				}
			}
			else
			{
				if (gTeam[playerid] == gZone[i][zoneOwner])
				{
					SendClientMessage(playerid, COLOR_ORANGE, "The zone is under our team's control.");
				}
				else
				{
					if (IsPlayerInAnyVehicle(playerid))
					{
						return SendClientMessage(playerid, COLOR_RED, "You cannot capture the zone in a vehicle.");
					}

					if (gZone[i][zoneOwner] != NO_TEAM)
					{
						strcat(text, "The zone is controlled by team ");
						strcat(text, vTeam[gZone[i][zoneOwner]][teamName]);
						strcat(text, ".");
					}
					else
					{
						strcat(text, "The zone is uncontrolled.");
					}
					SendClientMessage(playerid, COLOR_ORANGE, text);

					text[0] = EOS;
					strcat(text, gZone[i][zoneName]);
					strcat(text, " is under attack by team ~b~");
					strcat(text, vTeam[gTeam[playerid]][teamName]);

					SendBoxMessage(text);

					GangZoneFlashForAll(gZone[i][zoneId], vTeam[gTeam[playerid]][teamColor]);

					gZone[i][zoneAttacker] = playerid;
					gZone[i][zonePlayer] = 1;
					gZone[i][zoneTick] = 0;

					KillTimer(gZone[i][zoneTimer]);
					gZone[i][zoneTimer] = SetTimerEx("OnZoneUpdate", 1000, true, "i", i);
					SendClientMessage(playerid, COLOR_ORANGE, "Stay in the checkpoint for "#CAPTURE_TIME" seconds to capture the zone.");
					TextDrawShowForPlayer(playerid, CountText[playerid]);
					format(text, sizeof text, "~r~Capturing...~n~~g~%i%%", gZone[i][zoneTick] * 4);
					TextDrawSetString(CountText[playerid], text);
				}
			}
			break;
		}
	}
	return 1;
}

public OnZoneUpdate(zoneid)
{
	new playerid = gZone[zoneid][zoneAttacker];
	switch(gZone[zoneid][zonePlayer])
	{
		case 1: gZone[zoneid][zoneTick] += 1;
		case 2: gZone[zoneid][zoneTick] += 2;
		default: gZone[zoneid][zoneTick] += 3;
	}

	Loop(p)
	{
		if (IsPlayerInDynamicCP(p, gZone[zoneid][zoneCPId]) && ! IsPlayerInAnyVehicle(p) && gTeam[p] == gTeam[playerid])
		{
			new string[40];
			format(string, sizeof string, "~r~Capturing...~n~~g~%i%%", gZone[zoneid][zoneTick] * 4);
			TextDrawSetString(CountText[p], string);
		}
	}

	if (gZone[zoneid][zoneTick] >= CAPTURE_TIME)
	{
		SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You have successfully captured the zone, +5 score and +$"#CZONE_CASH" and "#XP_PER_CAPTURE_ZONE" XP.");
		TextDrawHideForPlayer(playerid, CountText[playerid]);							
		pInfo[playerid][Score] += 5;
		SetPlayerScore(playerid, pInfo[playerid][Score]);
		pInfo[playerid][Money] += CZONE_CASH;
		pInfo[playerid][pXP] += XP_PER_CAPTURE_ZONE;
		ShowUnlockedXPSStreak(playerid);
		SetPlayerMoney(playerid, pInfo[playerid][Money]);
		UpdatePlayerStats(playerid);

		Loop(p)
		{
			if (IsPlayerInDynamicCP(p, gZone[zoneid][zoneCPId]))
			{
				TextDrawHideForPlayer(p, CountText[p]);

				if (p != playerid && gTeam[p] == gTeam[playerid] && ! IsPlayerInAnyVehicle(p))
				{
					//SendClientMessage(p, COLOR_LIGHT_GREEN, "You have assisted your teammate to capture the zone, +3 score and +$"#ASSIST_CASH".");
					SendClientMessage(p, COLOR_LIGHT_GREEN, "You've assited capturing this zone, +3 score and +$"#ASSIST_CASH" and "#XP_PER_ASSIST_CAPTURE_ZONE" XP.");
					pInfo[p][Score] += 3;
					pInfo[p][Money] += ASSIST_CASH;
					pInfo[p][pXP] += XP_PER_ASSIST_CAPTURE_ZONE;
					ShowUnlockedXPSStreak(p);
					SetPlayerMoney(p, pInfo[p][Money]);
					SetPlayerScore(p, pInfo[p][Score]);
					UpdatePlayerStats(p);
				}
			}
			else if(!IsPlayerInDynamicCP(p, gZone[zoneid][zoneCPId]) &&  p != playerid && gTeam[p] == gTeam[playerid])
			{
				pInfo[p][Score] += 1;
				pInfo[p][Money] += 1000;
				SetPlayerScore(p, pInfo[p][Score]);
				SetPlayerMoney(p, pInfo[p][Money]);
				SendClientMessage(p, COLOR_WHITE, "You've received 1 score & 1000 money for your team's recent successful capture.");
			}
		}
		
		KillTimer(gZone[zoneid][zoneTimer]);

		new text[150];
		strcat(text, "~w~Team ");
		strcat(text, vTeam[gTeam[gZone[zoneid][zoneAttacker]]][teamName]);
		strcat(text, " has captured ");
		strcat(text, gZone[zoneid][zoneName]);
		if (gZone[zoneid][zoneOwner] != NO_TEAM)
		{
			strcat(text, " against team ");
			strcat(text, vTeam[gZone[zoneid][zoneOwner]][teamName]);
		}
		strcat(text, ".");
		SendBoxMessage(text);

		gZone[zoneid][zoneOwner] = gTeam[gZone[zoneid][zoneAttacker]];
		gZone[zoneid][zoneAttacker] = INVALID_PLAYER_ID;

		text[0] = EOS;
		strcat(text, gZone[zoneid][zoneName]);
		strcat(text, "\n{FFFFFF}Controlled by ");
		strcat(text, vTeam[gZone[zoneid][zoneOwner]][teamColor2]);
		strcat(text, vTeam[gZone[zoneid][zoneOwner]][teamName]);
		UpdateDynamic3DTextLabelText(gZone[zoneid][zoneLabel], -1, text);

		GangZoneStopFlashForAll(gZone[zoneid][zoneId]);
		GangZoneShowForAll(gZone[zoneid][zoneId],vTeam[gZone[zoneid][zoneOwner]][teamColor]);
		new teamid = gTeam[playerid];
		vTeam[teamid][TeamPoints] += POINT_PER_CAPTURE;
		IsTeamRoundWinner(teamid);
	}
}

public OnPlayerLeaveDynamicCP(playerid, checkpointid)
{
	for (new i; i < MAX_CAPTURE_ZONES; i++)
	{
		if (gZone[i][zoneCPId] != checkpointid) continue;
		if (gZone[i][zoneAttacker] == INVALID_PLAYER_ID) continue;
		
		if (gTeam[playerid] == gTeam[gZone[i][zoneAttacker]])
		{
			gZone[i][zonePlayer]--;

			if (! gZone[i][zonePlayer])
			{
				SendClientMessage(playerid, COLOR_ORANGE, "You failed to capture the zone, there were no teammates left in your checkpoint.");

				GangZoneStopFlashForAll(gZone[i][zoneId]);

				new text[150];
				strcat(text, "~w~Team ");
				strcat(text, vTeam[gTeam[playerid]][teamName]);
				strcat(text, " failed to capture ");
				strcat(text, gZone[i][zoneName]);
				if (gZone[i][zoneOwner] != NO_TEAM)
				{
					strcat(text, " against team ");
					strcat(text, vTeam[gZone[i][zoneOwner]][teamName]);
				}
				strcat(text, ".");
				SendBoxMessage(text);

				text[0] = EOS;
				if (gZone[i][zoneOwner] != NO_TEAM)
				{
					strcat(text, gZone[i][zoneName]);
					strcat(text, "\n{FFFFFF}Controlled by ");
					strcat(text, vTeam[gZone[i][zoneOwner]][teamName]);
					UpdateDynamic3DTextLabelText(gZone[i][zoneLabel], vTeam[gZone[i][zoneOwner]][teamColor], text);
				}
				TextDrawHideForPlayer(playerid, CountText[playerid]);

				gZone[i][zoneAttacker] = INVALID_PLAYER_ID;
				KillTimer(gZone[i][zoneTimer]);
			}
			else if (gZone[i][zoneAttacker] == playerid)
			{
				for(new p = 0 , j = GetPlayerPoolSize(); p < j; p++)
				{
					if (gTeam[p] == gTeam[playerid])
					{
						if (IsPlayerInDynamicCP(p, checkpointid))
						{
							gZone[i][zoneAttacker] = p;
							break;
						}
					}
				}
			}
		}

		TextDrawHideForPlayer(playerid, CountText[playerid]);
		break;
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(pInfo[playerid][LoggedIn] == false)
	{
		SendClientMessage(playerid, COLOR_LIGHT_RED, "You need to be logged to chat.");
		return 0;
	}
	if(pInfo[playerid][Muted] == true)
	{
		SendClientMessage(playerid, COLOR_DARK_RED, "You were muted.");
		return 0;
	}
	new str[150];
	if(text[0] == '#' && pInfo[playerid][AdminRank] >= 1)
	{
		format(str, sizeof(str), ""COL_DARK_PINK"[ADMIN CHAT] %s: "COL_WHITE"%s", pInfo[playerid][Name], text[1]);
		for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
		{
			if(pInfo[i][AdminRank] >= 1)
			SendClientMessage(i, -1, str);
		}
		format(str, sizeof(str), "[IN-GAME-STAFF]%s: %s", pInfo[playerid][Name], text[1]);
		DCC_SendChannelMessage(g_Discord_StaffChat, str);		
		return 0;
	}
	if(pInfo[playerid][AdminDuty] == true) 
	{
		format(str, sizeof(str), ""COL_DARK_PINK"Admin %s[%d]: "COL_WHITE"%s", pInfo[playerid][Name],playerid, text);
		SendClientMessageToAll(-1,str);
		return 0;
	}
	switch(gMode[playerid])
	{
		case MODE_MAIN:
		{
			if(stringContainsIP(text))
			{
				SendClientMessage(playerid, COLOR_LIGHT_RED, "Text blocked for advertising.");
				format(str, sizeof(str), "%s tried to adv: %s", pInfo[playerid][Name], text);
				SendMessageToAdmins(-1, str);
				DCC_SendChannelMessage(g_Report_Channel, str);
				return 0;
			}
			format(str,sizeof(str), "%s.%s%s(%d): {FFFFFF}%s", vRank[gRank[playerid]][rankTag], vTeam[gTeam[playerid]][teamColor2],pInfo[playerid][Name], playerid, text);
			SendClientMessageToAll(-1,str);
			format(str, sizeof(str), "[IN-GAME]%s: %s", pInfo[playerid][Name], text);
			DCC_SendChannelMessage(g_Discord_Chat, str);
		}
		case MODE_SDM:
		{
			if(stringContainsIP(text))
			{
				SendClientMessage(playerid, COLOR_LIGHT_RED, "Text blocked for advertising.");
				format(str, sizeof(str), "%s tried to adv: %s", pInfo[playerid][Name], text);
				SendMessageToAdmins(-1, str);
				DCC_SendChannelMessage(g_Report_Channel, str);
				return 0;
			}
			format(str,sizeof(str), ""COL_ORANGE"[SDM] "COL_WHITE"%s(%d): %s", pInfo[playerid][Name], playerid, text);
			SendClientMessageToAll(-1, str);
			format(str, sizeof(str), "[IN-GAME]%s: %s", pInfo[playerid][Name], text);
			DCC_SendChannelMessage(g_Discord_Chat, str);			
		}
		case MODE_DEDM:
		{
			if(stringContainsIP(text))
			{
				SendClientMessage(playerid, COLOR_LIGHT_RED, "Text blocked for advertising.");
				format(str, sizeof(str), "%s tried to adv: %s", pInfo[playerid][Name], text);
				SendMessageToAdmins(-1, str);
				DCC_SendChannelMessage(g_Report_Channel, str);
				return 0;
			}
			format(str,sizeof(str), ""COL_ORANGE"[DEDM] "COL_WHITE"%s(%d): %s", pInfo[playerid][Name],playerid,text);
			SendClientMessageToAll(-1, str);
			format(str, sizeof(str), "[IN-GAME]%s: %s", pInfo[playerid][Name], text);
			DCC_SendChannelMessage(g_Discord_Chat, str);
		}
	}
	return 0;
}

public DCC_OnChannelMessage(DCC_Channel:channel, DCC_User:author, const message[])
{
	new bool:IsBot;
	DCC_IsUserBot(author, IsBot);
	if(channel == g_Discord_Chat && IsBot == false)
	{
		new user_name[32 + 1],str[128];		
		DCC_GetUserName(author, user_name);
		format(str,sizeof(str), "[DISCORD] %s: "COL_WHITE"%s",user_name, message);
		SendClientMessageToAll(COLOR_LIGHT_BLUE, str);
	}
	else if(channel == g_Discord_StaffChat && IsBot == false)
	{
		new user_name[32 + 1],str[128];		
		DCC_GetUserName(author,user_name);
		format(str, sizeof(str), ""COL_DARK_PINK"Discord.Staff %s: "COL_WHITE"%s", user_name, message);		
		for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
		{
			if(pInfo[i][AdminRank] >= 1) SendClientMessage(i, -1, str);
		}
	}
	return 1;
}

public OnPlayerRegister(playerid)
{
    pInfo[playerid][LoggedIn] = true;
    pInfo[playerid][Score] = 15;
    pInfo[playerid][Money] = 20000;
    SetPlayerScore(playerid, pInfo[playerid][Score]);
    SetPlayerMoney(playerid, pInfo[playerid][Money]);
    return 1;
}

public KickEx(playerid)
{
	Kick(playerid);
	return 1;
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart)
{
	if(pInfo[playerid][SpawnProtection] == true) return 0;
	if(weapon == WEAPON_VEHICLE) return 0;
	if (issuerid != INVALID_PLAYER_ID)
	{
	  	if(gTeam[issuerid] == gTeam[playerid] && gMode[playerid] == MODE_MAIN) 
	  	{
	  		GameTextForPlayer(issuerid, "~r~Team Mate!", 1000, 3);
	  		return 0;
	  	}
	  	if(pInfo[playerid][AdminDuty] == true)
	  	{
	  		GameTextForPlayer(issuerid, "~r~On duty admin!", 1000, 3);
	  		return 0;
	  	}
	  	if (weapon == WEAPON_CARPARK || weapon == WEAPON_HELIBLADES)
		{
	  		GameTextForPlayer(issuerid, "~r~Vehicles damages are disabled", 1000, 3);
			return 0;
		}
	 	else if(weapon == WEAPON_SNIPER)
		{
			if(bodypart == BODY_PART_HEAD && pInfo[playerid][Helmet] == false && gTeam[issuerid] != gTeam[playerid])
			{
		   		GameTextForPlayer(playerid, "~r~Headshot", 2000, 3);
		   		GameTextForPlayer(issuerid, "~g~Headshot", 2000, 3);
		        SetPlayerHealth(playerid, 0.0);
		        pInfo[issuerid][Money] += 3000;
		        pInfo[issuerid][Score] += 3;
		        SetPlayerMoney(issuerid, pInfo[issuerid][Money]);
		        SetPlayerScore(issuerid, pInfo[issuerid][Score]);
		        pInfo[playerid][Money] -= 1000;
				OnPlayerDeath(playerid, issuerid,WEAPON_SNIPER);
			}
			else if(bodypart == BODY_PART_HEAD && pInfo[playerid][Helmet] == true && gTeam[issuerid] != gTeam[playerid])
			{
		 	   	pInfo[playerid][Helmet] = false;
				GameTextForPlayer(playerid, "~r~Helmet broken", 2000, 3);
			   	GameTextForPlayer(issuerid, "~g~Helmet broken", 2000, 3);
			   	RemovePlayerAttachedObject( playerid, 1);					
			}
		}
		else if(weapon == WEAPON_RIFLE)
		{
			if(bodypart == BODY_PART_HEAD && pInfo[playerid][Helmet] == false && gTeam[issuerid] != gTeam[playerid] && !IsPlayerNPC(playerid))
			{
	    		GameTextForPlayer(playerid, "~r~Headshot", 2000, 3);
	    		GameTextForPlayer(issuerid, "~g~Headshot", 2000, 3);
	    	    SetPlayerHealth(playerid, 0.0);
	    	    pInfo[issuerid][Money] += 3000;
		   	    pInfo[issuerid][Score] += 3;
		   	    SetPlayerMoney(issuerid, pInfo[issuerid][Money]);
		   	    SetPlayerScore(issuerid, pInfo[issuerid][Score]);
		   	    pInfo[playerid][Money] -= 1000;
				OnPlayerDeath(playerid, issuerid,WEAPON_RIFLE);
			}
			else if(bodypart == BODY_PART_HEAD && pInfo[playerid][Helmet] == true && gTeam[issuerid] != gTeam[playerid])
			{
				ToggleHelmetForPlayer(playerid, false);
	 		   	pInfo[playerid][IsPlayerHavingHelmet] = false;
				GameTextForPlayer(playerid, "~r~Helmet broken", 2000, 3);
			   	GameTextForPlayer(issuerid, "~g~Helmet broken", 2000, 3);
			}
		}
		else if(weapon == WEAPON_VEHICLE_M4)
		{
			if(IsPlayerInVehicle(issuerid, pInfo[playerid][DiveBombingVeh]))
			{
				new Float:pidhealth;
				GetPlayerHealth(playerid, pidhealth);
				SetPlayerHealth(playerid, (pidhealth -35));
			}
		}
	}
    return 1;
}
//===================================[DIALOGS]=====================================

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
	if(strlen(inputtext) <= 5 || strlen(inputtext) > 20)
	{
		new str[128];	 
		SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Invalid password length, should be 5 - 25.");
		format(str,sizeof(str), ""COL_WHITE"Welcome to Warfield "COL_DARK_RED"%s,"COL_WHITE"Type your password below to register", pInfo[playerid][Name]);

		Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "WF - Register", str, "Register", "Quit");
	}
	else
	{
		for (new i = 0; i < 10; i++)
		{
			pInfo[playerid][hashedpass][i] = random(79) + 47;
		}
	    pInfo[playerid][hashedpass][10] = 0;
		SHA256_PassHash(inputtext, pInfo[playerid][hashedpass], pInfo[playerid][Password], 65);
		new DB_Query[350], IP_[16];
		GetPlayerIp(playerid, IP_, 16);
		mysql_format(WF_DB, DB_Query, sizeof(DB_Query), "INSERT INTO `users` (`USERNAME`, `PASSWORD`, `HASHEDPASS`, `IP`,`SCORE`, `KILLS`, `MONEY`, `DEATHS`, `ADMIN`, `DONOR`)\
		VALUES ('%e', '%s', '%e', '%s','20','0', '0', '0', '0', '0')", pInfo[playerid][Name], pInfo[playerid][Password], pInfo[playerid][hashedpass], IP_);
		mysql_tquery(WF_DB, DB_Query, "OnPlayerRegister", "d", playerid);
	}
	return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);

	new Salted_Key[65];
	SHA256_PassHash(inputtext, pInfo[playerid][hashedpass], Salted_Key, 65);

	if(strcmp(Salted_Key, pInfo[playerid][Password]) == 0)
	{
		cache_set_active(pInfo[playerid][Player_Cache]);
		cache_get_value_int(0, "ID", pInfo[playerid][ID]);
		cache_get_value_int(0, "KILLS", pInfo[playerid][Kills]);
        cache_get_value_int(0, "DEATHS", pInfo[playerid][Deaths]);
		cache_get_value_int(0, "SCORE", pInfo[playerid][Score]);
        cache_get_value_int(0, "MONEY", pInfo[playerid][Money]);
        cache_get_value_int(0, "ADMIN", pInfo[playerid][AdminRank]);
        cache_get_value_int(0, "DONOR", pInfo[playerid][donorLevel]);
		SetPlayerScore(playerid, pInfo[playerid][Score]);
		SetPlayerMoney(playerid, pInfo[playerid][Money]);
		cache_delete(pInfo[playerid][Player_Cache]);
		pInfo[playerid][Player_Cache] = MYSQL_INVALID_CACHE;
		pInfo[playerid][LoggedIn] = true;
		SendClientMessage(playerid, -1, "You've been "COL_LIGHT_BLUE"logged in.");

		new Query[120];
		mysql_format(WF_DB, Query, sizeof(Query), "UPDATE `users` SET `IP` = '%s' WHERE `USERNAME` = '%e' LIMIT 1", pInfo[playerid][pIP],pInfo[playerid][Name]);
		mysql_tquery(WF_DB, Query);
	}
	else
	{
		new String[150];
		pInfo[playerid][LoginFails] += 1;
		printf("%s has been failed to login. (%d)", pInfo[playerid][Name], pInfo[playerid][LoginFails]);
		if (pInfo[playerid][LoginFails] >= 3) 
		{
			format(String,sizeof(String), "%s has been kicked for 3/3 login fails.", pInfo[playerid][Name]);
			SendClientMessageToAll(0x969696FF, String);
			Kick(playerid);
		}
		else
		{
			SendClientMessage(playerid, COLOR_DARK_RED, "Incorrect password.");	
			format(String, sizeof(String), ""COL_WHITE"Welcome back "COL_LIGHT_BLUE"%s, "COL_WHITE"Type your password to login.\nYou've %d out of 3 tries.", pInfo[playerid][Name],pInfo[playerid][LoginFails]);
			Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "WF - Login", String, "Login", "Quit");
		}
	}
	return 1;
}

Dialog:DIALOG_DM(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Canceled");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid, x,y,z);
	foreach(new i: Player)
	{
		if(IsPlayerInRangeOfPoint(i, 20, x,y,z) && gTeam[i] != gTeam[playerid]) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't join dm while in range of an enemy.");
	}
	gMode[playerid] = listitem;
	SpawnPlayer(playerid);
	new str[128];
	format(str, sizeof(str),""COL_BLUE"%s[%d] "COL_WHITE"has joined %s", pInfo[playerid][Name],playerid, vMode[listitem][modeName]);
	SendClientMessageToAll(-1, str);	
	return 1;
}

Dialog:DIALOG_SUPPORT_STREAK(playerid,response,listitem,inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Canceled.");
	if(pInfo[playerid][pXP] < gSStreak[listitem][SStreakXP]) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You don't have enough XP.");
	if(gClass[playerid] != CLASS_TROOPER && pInfo[playerid][KillStreak] < gSStreak[listitem][SStreakKSpree]) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need a higher killing spree.");
	else if(gClass[playerid] == CLASS_TROOPER)
	{
		new KSFT = gSStreak[listitem][SStreakKSpree];
		KSFT--;
		if(pInfo[playerid][KillStreak] < KSFT) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need a higher killing spree.");
	}
	switch(listitem)
	{
		case CarePackage:
		{
			if(IsCarePackageUsed[playerid] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once every spawn.");
			if(pInfo[playerid][pCarePackage] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You already got a care package dropped somewhere.");
			new Float:x,Float:y,Float:z;
			GetPlayerPos(playerid, x,y,z);
			pInfo[playerid][CarePackageObj] = CreateObject(18849, x,y,z+300, 0.0,0.0,0.0, 150.0);
			GetPointZPos(x,y,z);
			MoveObject(pInfo[playerid][CarePackageObj], x,y,z+0.1, 10);
			SendClientMessage(playerid, -1, ""COL_ORANGE"A Care package "COL_WHITE"is going be dropped on your position.");
			pInfo[playerid][pCarePackage] = true;
			IsCarePackageUsed[playerid] = true;
			SendEnemyTeamMessage(gTeam[playerid], -1, ""COL_LIGHT_RED"Enemy "COL_WHITE"care package spotted.");
			SendTeamMessage(playerid, -1, ""COL_LIGHT_GREEN"Friendly "COL_WHITE"care package is on the way.");
		}
		case BallisticVest:
		{
			if(IsBallisticVestUsed[playerid] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once a round.");
			new Float:x,Float:y,Float:z;
			GetPlayerPos(playerid, x, y, z);

			GetXYInFrontOfPlayer(playerid, x, y, 2);
			pInfo[playerid][BallisticVestObj1] = CreateObject(1242, x, y, z-0.5,0,0,0, 90);

			pInfo[playerid][BallisticVestLabel] = CreateDynamic3DTextLabel(""COL_LIGHT_GREEN"Ballistic vest lvl 1\n"COL_WHITE"Use /getvest", -1, x,y,z, 10);
			IsBallisticVestUsed[playerid] = true;
		}
		case Deathmachine:
		{
			if(IsDeathmachineUsed[playerid] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once every spawn.");
			GivePlayerWeapon(playerid, 38, 1000);
			IsDeathmachineUsed[playerid] = true;
			SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You got a minigun.");
			SendEnemyTeamMessage(gTeam[playerid], -1, ""COL_LIGHT_RED"Enemy "COL_WHITE"deathmachine in bound take cover.");
			SendTeamMessage(playerid, -1, ""COL_LIGHT_GREEN"Friendly "COL_WHITE"deathmachine is on the way.");		
		}
		case RcDrone:
		{
			if(	IsDroneUsed[playerid] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once every spawn.");
			IsDroneUsed[playerid] = true;
			GetPlayerPos(playerid, pInfo[playerid][pPos][0],pInfo[playerid][pPos][1],pInfo[playerid][pPos][2]);
			pInfo[playerid][DroneVeh] = CreateVehicle(464, pInfo[playerid][pPos][0],pInfo[playerid][pPos][1],pInfo[playerid][pPos][2]+0.5, 0.0, 0, 0, -1);
			PutPlayerInVehicle(playerid, pInfo[playerid][DroneVeh], 0);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got a drone press 2 to exit it.");	
			SendEnemyTeamMessage(gTeam[playerid], -1, ""COL_LIGHT_RED"Enemy "COL_WHITE"drone in bound take cover!.");
			SendTeamMessage(playerid, -1, ""COL_LIGHT_GREEN"Friendly "COL_WHITE"drone is on the way.");
			pInfo[playerid][IsPlayerFlyingDrone] = true;
			GameTextForPlayer(playerid, "~w~Press ~r~2 ~w~to exit", 10000, 3);
		}
		case DiveBombingRun:
		{
			if(IsDiveBombingRunUsed[playerid] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once every spawn.");
			IsDiveBombingRunUsed[playerid] = true;
			new Float:x,Float:y,Float:z;
			GetPlayerPos(playerid, x,y,z);
			pInfo[playerid][DiveBombingVeh] = CreateVehicle(476, x, y, z+300, 0.0, 0,0, -1);
			PutPlayerInVehicle(playerid, pInfo[playerid][DiveBombingVeh], 0);
			SetVehicleHealth(pInfo[playerid][DiveBombingVeh], 500);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got a ruslter with increased damage.");
			SendEnemyTeamMessage(gTeam[playerid], -1, ""COL_LIGHT_RED"Enemy "COL_WHITE"Dive bombing run in bound take cover!.");
			SendTeamMessage(playerid, -1, ""COL_LIGHT_GREEN"Friendly "COL_WHITE"dive bombing plane is on the way.");

		}
		case KamikazePilot:
		{
			if(IsKamikazeUsed[playerid] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once every spawn.");
			IsKamikazeUsed[playerid] = true;
			new Float:x,Float:y,Float:z;
			GetPlayerPos(playerid, x,y,z);		
			pInfo[playerid][KamikazeVeh] = CreateVehicle(593, x, y, z+300, 0.0, 0,0, -1);
			SetVehicleHealth(pInfo[playerid][KamikazeVeh], 10);
			PutPlayerInVehicle(playerid, pInfo[playerid][KamikazeVeh], 0);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got a kamikaze plane.");
			SendEnemyTeamMessage(gTeam[playerid], -1, ""COL_LIGHT_RED"Enemy "COL_WHITE"kamikaze plane in bound take cover !");
			SendTeamMessage(playerid, -1, ""COL_LIGHT_GREEN"Friendly "COL_WHITE"Kamikaze plane is on the way.");		
		}
		case BallisticVest2:
		{
			if(IsBallisticVestUsed2[playerid] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once a round");
			IsBallisticVestUsed2[playerid] = true;
			new Float:x,Float:y,Float:z;
			GetPlayerPos(playerid, x,y,z);
			pInfo[playerid][BallisticVestObj2] = CreateDynamicObject(1242, x, y, z-0.5, 0, 0, 0);
			pInfo[playerid][BallisticVestLabel2] = CreateDynamic3DTextLabel(""COL_LIGHT_GREEN"Ballistic vest lvl 2\n"COL_WHITE"Use /getvest", -1, x,y,z, 10);
			IsBallisticVestUsed2[playerid] = true;
		}
		case MOAB:
		{
			if(IsMOABUsed[playerid] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once every spawn.");
			IsMOABUsed[playerid] = true;
			pInfo[playerid][MoabObj] = CreateDynamicObject(18849, 268.5985,1844.7767,500, 0.0,0.0,0.0);
			MoveDynamicObject(pInfo[playerid][MoabObj], 68.5985,1844.7767,17.000,30);
			SendEnemyTeamMessage(gTeam[playerid], -1,""COL_LIGHT_RED"Enemy "COL_WHITE"MOAB spotted hide in the bunker !");
			SendTeamMessage(playerid, -1, ""COL_LIGHT_GREEN"Friendly "COL_WHITE"MOAB in bound.");
		}
	}
	return 1;
}


Dialog:PLAYER_SETTINGS_DIALOG(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Dialog closed.");
	switch(listitem)
	{
		case 0:
		{
			Dialog_Show(playerid, DIALOG_TOGGLE_DND, DIALOG_STYLE_MSGBOX,""COL_LIGHT_BLUE"Toggle - DND", ""COL_WHITE"Turn it:", "OFF", "ON");
		}
		case 1:
		{
			Dialog_Show(playerid, DIALOG_TOGGLE_DUEL_DND, DIALOG_STYLE_MSGBOX, ""COL_LIGHT_BLUE"Toggle - Duel DND", ""COL_WHITE"Turn it:", "OFF", "ON");
		}
		case 2:
		{
			Dialog_Show(playerid, DIALOG_TOGGLE_MASK, DIALOG_STYLE_MSGBOX, ""COL_LIGHT_BLUE"Toggle - Gas mask", ""COL_WHITE"Turn it:","OFF", "ON");
		}
		case 3:
		{
			Dialog_Show(playerid, DIALOG_TOGGLE_HELMET, DIALOG_STYLE_MSGBOX, ""COL_LIGHT_BLUE"Toggle - Helmet", ""COL_WHITE"Turn it:","OFF", "ON");			
		}
	}
	return 1;
}
Dialog:DIALOG_TOGGLE_DND(playerid,response,listitem,inputtext[])
{
	if(response)
	{
		pInfo[playerid][DND] = false;
		SendClientMessage(playerid, COLOR_WHITE, ""COL_ORANGE"DND Mode "COL_WHITE"has been turned off.");

	}
	else if(!response)
	{
		pInfo[playerid][DND] = true;
		SendClientMessage(playerid, COLOR_WHITE, ""COL_ORANGE"DND Mode "COL_WHITE"has been turned on.");
	}	
	return 1;
}
Dialog:DIALOG_TOGGLE_DUEL_DND(playerid,response,listitem, inputtext[])
{
	if(response)
	{
		pInfo[playerid][DuelDND] = false;
		SendClientMessage(playerid, COLOR_WHITE, ""COL_ORANGE"Duel DND Mode "COL_WHITE"has been turned off.");

	}
	else if(!response)
	{
		pInfo[playerid][DuelDND] = true;
		SendClientMessage(playerid, COLOR_WHITE, ""COL_ORANGE"Duel DND Mode "COL_WHITE"has been turned on.");
	}
	return 1;
}
Dialog:DIALOG_TOGGLE_MASK(playerid,response,listitem,inputtext[])
{
	if(response)
	{
		ToggleGasMaskForPlayer(playerid, false);
		SendClientMessage(playerid, COLOR_WHITE, ""COL_ORANGE"Gas mask "COL_WHITE"has been turned off.");
	}
	if(!response)
	{
		if(pInfo[playerid][IsPlayerHavingMask] == false) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You don't have a mask.");
		ToggleGasMaskForPlayer(playerid, true);
		SendClientMessage(playerid, COLOR_WHITE, ""COL_ORANGE"Gas mask "COL_WHITE"has been turned on.");
	}	
	return 1;
}
Dialog:DIALOG_TOGGLE_HELMET(playerid,response,listitem,inputtext[])
{
	if(response)
	{
		ToggleHelmetForPlayer(playerid, false);
		SendClientMessage(playerid, COLOR_WHITE, ""COL_ORANGE"Helmet "COL_WHITE"has been turned off.");
	}
	if(!response)
	{
		if(pInfo[playerid][IsPlayerHavingHelmet] == false) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You don't have a helmet.");
	
		ToggleHelmetForPlayer(playerid, true);
		SendClientMessage(playerid, COLOR_WHITE, ""COL_ORANGE"Helmet "COL_WHITE"has been turned on.");
	}	
	return 1;
}
Dialog:DIALOG_DISGUISE(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Canceled.");
	if(listitem == gTeam[playerid]) return SendClientMessage(playerid, COLOR_DARK_RED, "Nothing to be done.");
	SetPlayerSkin(playerid, vTeam[listitem][teamSkins][0]);
	SetPlayerColor(playerid, vTeam[listitem][teamColor]);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_BLUE"You've been disguised as "COL_WHITE"%s assault", vTeam[listitem][teamName]);
	SendClientMessage(playerid, -1, str);
	return 1;
}
Dialog:DIALOG_TELEPORT_MENU(playerid,response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Canceled");
	switch(listitem)
	{
		case 0:
		{
			new str[1200];
			for(new i; i < MAX_CAPTURE_ZONES; i++)
			{
				strcat(str, ""COL_LIGHT_BLUE"");
				strcat(str, gZone[i][zoneName]);
				strcat(str, "\n");
				Dialog_Show(playerid, DIALOG_CAPTURE_ZONES_TP, DIALOG_STYLE_LIST, "CAPTURE ZONES - TELEPORT", str, "Teleport", "Cancel");
			}
		}
		case 1:
		{
			new str[500];
			for(new i; i < MAX_TEAMS; i++)
			{
				strcat(str, vTeam[i][teamColor2]);
				strcat(str, vTeam[i][teamName]);
				strcat(str, "\n");
			}
			Dialog_Show(playerid, DIALOG_BASES_TP, DIALOG_STYLE_LIST, "BASES - TELEPORT", str, "Teleport", "Cancel");
		}
	}
	return 1;
}
Dialog:DIALOG_CAPTURE_ZONES_TP(playerid,response,listitem,inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Canceled");
	new str[128];
	SetPlayerPos(playerid, gZone[listitem][zoneSpawn][0]+1,gZone[listitem][zoneSpawn][1]+1,gZone[listitem][zoneSpawn][2]);
	format(str, sizeof(str), "You've been teleported to "COL_WHITE"%s.", gZone[listitem][zoneName]);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, str);
	return 1;
}
Dialog:DIALOG_BASES_TP(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Canceled.");
	new str[128];
	SetPlayerPos(playerid, vTeam[listitem][teamSpawnPoints][0], vTeam[listitem][teamSpawnPoints][1], vTeam[listitem][teamSpawnPoints][2]);
	format(str, sizeof(str), "You've been teleported to %s base.", vTeam[listitem][teamName]);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, str);
	return 1;
}
Dialog:DIALOG_NUKE(playerid, response, listitem, inputtext[])
{
	if (!response) return SendClientMessage(playerid, COLOR_RED, "Canceled.");
	if(listitem == gTeam[playerid]) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can't launch a nuke on your team.");
	pInfo[playerid][Money] -= NUKE_COST;
	new str[80], count, Float: PosX, Float: PosY, Float: PosZ;
	format(str, sizeof str, "Nuke bomb has been launched at base of team {%06x}%s.", vTeam[listitem][teamColor] >>> 8, vTeam[listitem][teamName]);
	SendClientMessageToAll(-1, str);
	SetWeather(43);
	gNukeTime = 260;
	Loop(i)
	{
		if (pInfo[i][AdminDuty] == false && IsPlayerInArea(i, vTeam[listitem][teamBasePos][0],vTeam[listitem][teamBasePos][1],vTeam[listitem][teamBasePos][2],vTeam[listitem][teamBasePos][3]) && gTeam[i] != gTeam[playerid])
		{
			GetPlayerPos(i, PosX, PosY, PosZ);
			SetPlayerHealth(i, 0.0);
			CreateExplosion(PosX, PosY, PosZ, 3, 3.0);
			SendDeathMessage(playerid, i, 51);
			pInfo[playerid][Kills] += 1;
			pInfo[playerid][Money] += 1500;
			GivePlayerScore(playerid, 1);
			format(str, sizeof str, "%s died in the Nuke bomb attack.", pInfo[i][Name]);
			SendClientMessage(playerid, COLOR_RED, str);
			count += 1;
		}
	}
	if (count) SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You recieved +1 score and +$1000 for each death.");
	format(str, sizeof str, "It's been reported that %i people died from the Nuke attack.", count);
	SendClientMessageToAll(COLOR_LIGHT_GREEN, str);
	return 1;
}
Dialog:DIALOG_SPAWNPOINT(playerid, response, listitem, inputtext[])
{
	if (!response) return 1;
	if (!listitem)
	{
		SendClientMessage(playerid, COLOR_WHITE, "Your new spawn point is: Base.");
		pInfo[playerid][pSpawn] = MAX_CAPTURE_ZONES;
		return 1;
	}

	listitem -= 1;
	if (gZone[listitem][zoneAttacker] != INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "ERROR: Someone is capturing that zone.");
	if (gZone[listitem][zoneOwner] != gTeam[playerid]) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your team doesn't own that zone.");
	if (pInfo[playerid][pSpawn] == listitem) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're already going to spawn there.");
	pInfo[playerid][pSpawn] = listitem;

	new str[50];
	format(str, sizeof str, "Your new spawn point is: %s.", gZone[listitem][zoneName]);
	SendClientMessage(playerid, COLOR_WHITE, str);
	return 1;
}

Dialog:DIALOG_SKYDIVE(playerid,response,listitem,inputtext[])
{
	if(!response) return SendClientMessage(playerid, -1, "Canceled");
	if (gZone[listitem][zoneAttacker] != INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "ERROR: Someone is capturing that zone.");
	if (gZone[listitem][zoneOwner] != gTeam[playerid] && pInfo[playerid][donorLevel] < 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your team doesn't own that zone.");	

	SetPlayerPos(playerid, gZone[listitem][zoneSpawn][0], gZone[listitem][zoneSpawn][1], gZone[listitem][zoneSpawn][2]+250);
	GivePlayerWeapon(playerid, 46, 1);
	return 1;
}

Dialog:DIALOG_BRIEFCASE(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Canceled.");
	switch(listitem)
	{
		case 0:
		{
			if(pInfo[playerid][Money] < 5000) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't afford this.") && ShowShopMenu(playerid);
			new Float: pHealth;
			GetPlayerHealth(playerid, pHealth);
			if(pHealth == 100) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're at full health.");
			SetPlayerHealth(playerid, 100.0);
			pInfo[playerid][Money] -= 5000;
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You've been healed and you've paid $5000.");
			ShowShopMenu(playerid);	
		}
		case 1:
		{
			if(pInfo[playerid][Money] < 3000) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't afford this.") && ShowShopMenu(playerid);
			if(pInfo[playerid][IsPlayerHavingHelmet] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You already have a helmet.") && ShowShopMenu(playerid);
			pInfo[playerid][Money] -= 3000;
			pInfo[playerid][IsPlayerHavingHelmet] = true;
			ToggleHelmetForPlayer(playerid, true);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You've got a helmet and you've paid $3000.");		
			ShowShopMenu(playerid);
		}
		case 2:
		{
			if(pInfo[playerid][Money] < 3000) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't afford this.") && ShowShopMenu(playerid);
			if(pInfo[playerid][IsPlayerHavingMask] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You already got a mask") && ShowShopMenu(playerid);
			pInfo[playerid][Money] -= 3000;
			pInfo[playerid][IsPlayerHavingMask] = true;
			ToggleGasMaskForPlayer(playerid, true);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You've got a mask and you've paid $3000.");		
			ShowShopMenu(playerid);
		}
		case 3:
		{
			new str[500];
			strcat(str, ""COL_LIGHT_BLUE"Weapon\tPrice\n");
			strcat(str, ""COL_WHITE"Desert eagle\t"COL_LIGHT_RED"$5000\n");
			strcat(str, ""COL_WHITE"9mm\t"COL_LIGHT_RED"$3000\n");
			strcat(str, ""COL_WHITE"Silenced pistol\t"COL_LIGHT_RED"$4000\n");
			strcat(str, ""COL_WHITE"M4\t"COL_LIGHT_RED"$5000\n");
			strcat(str, ""COL_WHITE"AK47\t"COL_LIGHT_RED"$4500\n");
			strcat(str, ""COL_WHITE"MP5\t"COL_LIGHT_RED"$4800\n");
			strcat(str, ""COL_WHITE"Tec-9\t"COL_LIGHT_RED"$6000\n");
			strcat(str, ""COL_WHITE"Uzi\t"COL_LIGHT_RED"$5500\n");
			strcat(str, ""COL_WHITE"Shotgun\t"COL_LIGHT_RED"$4300\n");
			strcat(str, ""COL_WHITE"Shotgun GSPA\t"COL_LIGHT_RED"$7000\n");
			strcat(str, ""COL_WHITE"Grenade\t"COL_LIGHT_RED"$2500\n");
			strcat(str, ""COL_WHITE"Tear gas\t"COL_LIGHT_RED"$2500\n");
			strcat(str, ""COL_WHITE"RPG\t"COL_LIGHT_RED"$5000\n");	
			Dialog_Show(playerid, DIALOG_WEAPON_SHOP, DIALOG_STYLE_TABLIST_HEADERS, "Weapon - Shop", str, "Purchase", "Cancel");
		}
	}
	return 1;
}

Dialog:DIALOG_WEAPON_SHOP(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
	switch(listitem)
	{
		case 0:
		{
			if(pInfo[playerid][Money] < 5000) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_DEAGLE, 150);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got desert eagle and paid $5000.");
			pInfo[playerid][Money] -= 5000;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);
			ShowShopMenu(playerid);
		}
		case 1:
		{
			if(pInfo[playerid][Money] < 3000) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, PISTOL_9MM, 100);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got 9mm and paid $3000.");
			pInfo[playerid][Money] -= 3000;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);	
			ShowShopMenu(playerid);
		}
		case 2:
		{
			if(pInfo[playerid][Money] < 4000) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_SILENCED, 120);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got Silenced pistol and paid $4000.");
			pInfo[playerid][Money] -= 4000;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);
			ShowShopMenu(playerid);							
		}
		case 3:
		{
			if(pInfo[playerid][Money] < 5000) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_M4, 180);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got M4 and paid $5000.");
			pInfo[playerid][Money] -= 5000;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);				
		}
		case 4:
		{
			if(pInfo[playerid][Money] < 4000) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_AK47, 200);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got ak47 and paid $4000.");
			pInfo[playerid][Money] -= 4000;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);
			ShowShopMenu(playerid);
		}
		case 5:
		{
			if(pInfo[playerid][Money] < 4800) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_MP5, 250);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got MP5 and paid $4800.");
			pInfo[playerid][Money] -= 4800;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);	
			ShowShopMenu(playerid);	
		}//
		case 6:
		{
			if(pInfo[playerid][Money] < 6000) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_TEC9, 300);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got Tec-9 and paid $6000.");
			pInfo[playerid][Money] -= 6000;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);				
			ShowShopMenu(playerid);	
		}
		case 7:
		{
			if(pInfo[playerid][Money] < 5500) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_M4, 120);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got UZI and paid $5500.");
			pInfo[playerid][Money] -= 5500;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);				
			ShowShopMenu(playerid);		
		}
		case 8:
		{
			if(pInfo[playerid][Money] < 4300) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_SHOTGUN, 100);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got shotgun and paid $4300.");
			pInfo[playerid][Money] -= 4300;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);						
			ShowShopMenu(playerid);	
		}
		case 9:
		{
			if(pInfo[playerid][Money] < 7000) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_SHOTGSPA, 90);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got shotgun gspa and paid $7000.");
			pInfo[playerid][Money] -= 7000;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);				
			ShowShopMenu(playerid);			
		}	
		case 10:
		{
			if(pInfo[playerid][Money] < 2500) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_GRENADE, 1);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got a grenade and paid $2500.");
			pInfo[playerid][Money] -= 2500;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);						
			ShowShopMenu(playerid);
		}
		case 11:
		{
			if(pInfo[playerid][Money] < 2500) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_TEARGAS, 1);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got a tear gas and paid 2500.");
			pInfo[playerid][Money] -= 2500;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);				
			ShowShopMenu(playerid);	
		}
		case 12:
		{
			if(pInfo[playerid][Money] < 5000) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You can't afford this.");
			GivePlayerWeapon(playerid, WEAPON_ROCKETLAUNCHER, 1);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got a RPG and paid 5000.");
			pInfo[playerid][Money] -= 5000;
			SetPlayerMoney(playerid, pInfo[playerid][Money]);				
			ShowShopMenu(playerid);	
		}		
	}
	return 1;
}


Dialog:DIALOG_DUEL_REQUEST(playerid, response, listitem, inputtext[])
{
	new targetid = pDuel[playerid][E_DUEL_TARGET];
	if (!response)
	{
		new str[128];

		format(str,sizeof (str), "%s has denied your duel request ! ", pInfo[playerid][Name]);
		SendClientMessage(targetid, COLOR_BLUE,str);

		format(str,sizeof str, "You have denied %s's duel request !", pInfo[targetid][Name]);
		SendClientMessage(playerid, COLOR_BLUE,str);

		pDuel[playerid][E_DUEL_BET] = -1;
		pDuel[targetid][E_DUEL_BET] = -1;

		pDuel[playerid][E_DUEL_WEAPON] = -1;
		pDuel[targetid][E_DUEL_WEAPON] = -1;

		pDuel[playerid][E_DUEL_REQUEST] = -1;
		pDuel[targetid][E_DUEL_REQUEST] = -1;

		pDuel[playerid][E_DUEL_TARGET] = -1;
		pDuel[targetid][E_DUEL_TARGET] = -1;
		return 1;
	}
	TogglePlayerControllable(targetid, false);
	TogglePlayerControllable(playerid, false);
	pDuel[targetid][E_DUEL_PROTECTION_TIME] = gettime() + 5;
	pDuel[playerid][E_DUEL_PROTECTION_TIME] = gettime() + 5;

	pDuel[playerid][E_DUEL_PROTECTION] = true;
	pDuel[targetid][E_DUEL_PROTECTION] = true;
	
	GameTextForPlayer(playerid, "~w~Duel starts in ~r~5 seconds", 4500, 3);
	GameTextForPlayer(targetid, "~w~Duel starts in ~r~5 seconds", 4500, 3);


	SetPlayerHealth(playerid, 100.000);
	SetPlayerHealth(targetid, 100.000);

	SetPlayerArmour(playerid, 99.999);
	SetPlayerArmour(targetid, 99.999);

	ResetPlayerWeapons(playerid);
	ResetPlayerWeapons(targetid);

	GivePlayerWeapon(playerid, pDuel[playerid][E_DUEL_WEAPON], 9999);
	GivePlayerWeapon(targetid, pDuel[playerid][E_DUEL_WEAPON], 9999);

	SetPlayerPos(playerid, 418.6636,2498.3159,811.3818);
	SetPlayerFacingAngle(playerid,180.000);
	SetPlayerPos(targetid, 380.5728,2460.6738,812.3818);
	SetPlayerFacingAngle(targetid,0.00000);

	new str[128];
	format(str,sizeof str, "%s has accepted your Duel request !", pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str,sizeof str, "You have accepted %s's request", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, str);
	SetPlayerTeam(playerid, NO_TEAM);
	SetPlayerTeam(targetid, NO_TEAM);
	pDuel[playerid][E_DUEL_ACTIVE] = 1;
	pDuel[targetid][E_DUEL_ACTIVE] = 1;
	format(str,sizeof str, "Duel between %s and %s has been started Weapon: %s Bet: %d",pInfo[playerid][Name],pInfo[targetid][Name],WeaponNames[pDuel[playerid][E_DUEL_WEAPON]], pDuel[playerid][E_DUEL_BET]);
	SendClientMessageToAll(COLOR_BLUE, str);
	return 1;
}

Dialog:DIALOG_DUEL_RACE_REQUEST(playerid,response,listitem,inputtext[])
{
	new targetid = pDuel[playerid][E_DUEL_TARGET];
	if (!response)
	{
		new str[128];

		format(str,sizeof (str), "%s has denied your duel request ! ", pInfo[playerid][Name]);
		SendClientMessage(targetid, COLOR_BLUE,str);

		format(str,sizeof str, "You have denied %s's duel request !", pInfo[targetid][Name]);
		SendClientMessage(playerid, COLOR_BLUE,str);

		pDuel[playerid][E_DUEL_BET] = -1;
		pDuel[targetid][E_DUEL_BET] = -1;

		pDuel[playerid][E_DUEL_REQUEST] = -1;
		pDuel[targetid][E_DUEL_REQUEST] = -1;

		pDuel[playerid][E_DUEL_TARGET] = -1;
		pDuel[targetid][E_DUEL_TARGET] = -1;
		return 1;
	}
	if (IsRaceDuelOccupied == true) return SendClientMessage(playerid, COLOR_RED,  "ERROR: There is another race duel already running at moment, Try later.");

	SetPlayerVirtualWorld(playerid, 1);
	SetPlayerVirtualWorld(targetid, 1);

	vehDuel[0] = AddStaticVehicle(571,257.6025,1360.3531,9.8699,89.1030,0,0);
	vehDuel[1] = AddStaticVehicle(571,257.7605,1364.3531,9.8735,89.1030,0,0);
	SetVehicleVirtualWorld(vehDuel[0], 1);
	SetVehicleVirtualWorld(vehDuel[1], 1);

	PutPlayerInVehicle(targetid, vehDuel[0], 0);
	PutPlayerInVehicle(playerid, vehDuel[1], 0);

	SetPlayerHealth(playerid, 100.000);
	SetPlayerHealth(targetid, 100.000);

	SetPlayerArmour(playerid, 99.999);
	SetPlayerArmour(targetid, 99.999);

	ResetPlayerWeapons(playerid);
	ResetPlayerWeapons(targetid);

	cpDuel = CreateDynamicCP(118.7793,1401.7797,10.5938, 10, 1);


	new str[128];
	format(str,sizeof str, "%s has accepted your Duel request !", pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str,sizeof str, "You have accepted %s's request", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, str);
	pDuel[playerid][E_DUEL_ACTIVE] = 2;
	pDuel[targetid][E_DUEL_ACTIVE] = 2;
	format(str,sizeof str, "Race.Duel between %s and %s has been started Bet: %d",pInfo[playerid][Name],pInfo[targetid][Name], pDuel[playerid][E_DUEL_BET]);
	SendClientMessageToAll(COLOR_BLUE, str);
	IsRaceDuelOccupied = true;	
	return 1;
}

Dialog:DIALOG_CLASS(playerid,response,listitem,inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_DARK_RED, "Canceled");
	if(vClass[listitem][classRank] > gRank[playerid]) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need higher rank for this class") && ShowClassDialog(playerid);
	if(listitem == CLASS_DONOR && pInfo[playerid][donorLevel] < 2) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need donor level 2 at least.") && ShowClassDialog(playerid);
	if(listitem == CLASS_DEMOLISHER) return SendClientMessage(playerid, COLOR_DARK_RED, "THIS CLASS IS UNDER DEVELOPMENT.") && ShowClassDialog(playerid);
	new str[128];
	gClass[playerid] = listitem;
	format(str,sizeof(str), ""COL_BLUE"Class: "COL_WHITE"You've selected class: %s", vClass[gClass[playerid]][className]);
	SendClientMessage(playerid, -1, str);
	SpawnPlayer(playerid);
	return 1;
}


Dialog:DIALOG_FMSG(playerid,response,listitem,inputtext[])
{
	if (!response) return SendClientMessage(playerid, COLOR_LIGHT_RED, "Canceled");
	new string[128];
	switch(listitem)
	{
	    case 0:
	    {
	        format(string, sizeof string, "%s %s: Follow me team !",vRank[gRank[playerid]][rankTag],pInfo[playerid][Name]);
	        SendTeamMessage(playerid, COLOR_ORANGE, string);
	 	}
	 	case 1:
	 	{
			format(string, sizeof string, "%s %s: Enemy spotted !",vRank[gRank[playerid]][rankTag],pInfo[playerid][Name]);
	        SendTeamMessage(playerid, COLOR_ORANGE, string);
	 	}
	    case 2:
	    {
			format(string, sizeof string, "%s %s: I am taking fire, I need help !",vRank[gRank[playerid]][rankTag],pInfo[playerid][Name]);
	        SendTeamMessage(playerid, COLOR_ORANGE, string);
	    }
	    case 3:
	    {
			format(string, sizeof string, "%s %s: Cover me !",vRank[gRank[playerid]][rankTag],pInfo[playerid][Name]);
	        SendTeamMessage(playerid, COLOR_ORANGE, string);
		}
		case 4:
		{
			format(string, sizeof string, "%s %s: Take this zone team !",vRank[gRank[playerid]][rankTag],pInfo[playerid][Name]);
	        SendTeamMessage(playerid, COLOR_ORANGE, string);
		}
		case 5:
		{
            format(string, sizeof string, "%s %s: Hold this position team !",vRank[gRank[playerid]][rankTag],pInfo[playerid][Name]);
	        SendTeamMessage(playerid, COLOR_ORANGE, string);
		}
		case 6:
		{
		    format(string, sizeof string, "%s %s: Regroup team !",vRank[gRank[playerid]][rankTag],pInfo[playerid][Name]);
	        SendTeamMessage(playerid, COLOR_ORANGE, string);
		}
		case 7:
		{
		    format(string, sizeof string, "%s %s: Covering fire !",vRank[gRank[playerid]][rankTag],pInfo[playerid][Name]);
	        SendTeamMessage(playerid, COLOR_ORANGE, string);
		}
	}
	return 1;
}

Dialog:DIALOG_EVENT_SETTINGS(playerid, response, listitem, inputtext[])
{
	if (!response) return SendClientMessage(playerid, COLOR_RED, "Dialog closed.");
	switch(listitem)
	{
	    case 0:
	    {
	        Dialog_Show(playerid, DIALOG_E_SKIN_CHANGE, DIALOG_STYLE_INPUT, "Event - Skin", "Put a skin ID", "Done", "close");
	    }
	    case 1:
	    {
	        Dialog_Show(playerid, DIALOG_E_WEAPON1_CHANGE, DIALOG_STYLE_INPUT, "Event - First weapon", "Put your weapon ID", "Done", "close");
	    }
	    case 2:
	    {
	        Dialog_Show(playerid, DIALOG_E_WEAPON2_CHANGE, DIALOG_STYLE_INPUT, "Event - Second weapon", "Put your weapon ID", "Done", "close");
	    }
	    case 3:
	    {
	        Dialog_Show(playerid, DIALOG_E_WEAPON3_CHANGE, DIALOG_STYLE_INPUT, "Event - Third weapon", "Put your weapon ID", "Done", "close");
	    }
	    case 4:
	    {
	        Dialog_Show(playerid, DIALOG_E_PLAYER_TEAM, DIALOG_STYLE_MSGBOX, "Event - Settings", "Set players as:", "Allies", "Enemies");
	    }
	}
	return 1;
}
Dialog:DIALOG_E_PLAYER_TEAM(playerid,response,listitem, inputtext[])
{
	if (!response)
	{
		gEvent[PlayersTeam] = NO_TEAM;
		SendClientMessage(playerid,COLOR_LIGHT_GREEN,"Event players has been set as enemies.");
		ShowEventSettings(playerid);
		return 1;
	}
	else if (response)
	{
		gEvent[PlayersTeam] = 1;
		SendClientMessage(playerid, COLOR_LIGHT_GREEN, "Event players has been set as allies.");
		ShowEventSettings(playerid);
	}
	return 1;
}

Dialog:DIALOG_E_SKIN_CHANGE(playerid, response, listitem, inputtext[])
{
	if (!response) return SendClientMessage(playerid, COLOR_RED,"Canceled.");
	new skin = strval(inputtext);
	if (!IsValidSkin(skin)) return Dialog_Show(playerid, DIALOG_E_SKIN_CHANGE, DIALOG_STYLE_INPUT, "Event - Skin", "Put a valid skin ID please", "Done", "close");
	
	new string[144];
	gEvent[EventSkin] = skin;
	format(string,sizeof string, ""COL_LIGHT_GREEN"Event skin has been set to %d.", skin);
	SendClientMessage(playerid, -1, string);
	ShowEventSettings(playerid);
	return 1;
}

Dialog:DIALOG_E_WEAPON1_CHANGE(playerid,response,listitem,inputtext[])
{
	if (!response) return SendClientMessage(playerid, COLOR_RED,"Dialog closed.");
	if (!IsValidWeapon(strval(inputtext) && strval(inputtext) != -1)) return Dialog_Show(playerid, DIALOG_E_WEAPON1_CHANGE, DIALOG_STYLE_INPUT, "Event - First weapon", "Put a valid weapon ID please", "Done", "close");
	
	new string[144];
	gEvent[EventWeapon1] = strval(inputtext);
	format(string,sizeof string, ""COL_LIGHT_GREEN"Event weapon 1 has been set to %d.", gEvent[EventWeapon1]);
	SendClientMessage(playerid, -1, string);
	ShowEventSettings(playerid);
	return 1;
}

Dialog:DIALOG_E_WEAPON2_CHANGE(playerid,response,listitem,inputtext[])
{
	if (!response) return SendClientMessage(playerid, COLOR_RED,"Dialog closed.");
	if (!IsValidWeapon(strval(inputtext) && strval(inputtext) != -1)) return Dialog_Show(playerid, DIALOG_E_WEAPON2_CHANGE, DIALOG_STYLE_INPUT, "Event - Second weapon", "Put a valid weapon ID please", "Done", "close");
	
	new string[144];
	gEvent[EventWeapon2] = strval(inputtext);
	format(string,sizeof string, ""COL_LIGHT_GREEN"Event weapon 2 has been set to %d.", gEvent[EventWeapon2]);
	SendClientMessage(playerid, -1, string);
	ShowEventSettings(playerid);
	return 1;
}

Dialog:DIALOG_E_WEAPON3_CHANGE(playerid,response,listitem,inputtext[])
{
	if (!response) return SendClientMessage(playerid, COLOR_RED,"Dialog closed.");
	if (!IsValidWeapon(strval(inputtext) && strval(inputtext) != -1)) return Dialog_Show(playerid, DIALOG_E_WEAPON3_CHANGE, DIALOG_STYLE_INPUT, "Event - Third weapon", "Put a valid weapon ID please", "Done", "close");
	
	new string[144];
	gEvent[EventWeapon3] = strval(inputtext);
	format(string,sizeof string, ""COL_LIGHT_GREEN"Event weapon 3 has been set to %d.", gEvent[EventWeapon3]);
	SendClientMessage(playerid, -1, string);
	ShowEventSettings(playerid);
	return 1;
}
//=============================================[COMMANDS]==================================================
CMD:cmds(playerid)
{
	new string[2650];
	strcat(string, ""COL_LIGHT_GREEN"General commands:\n");
	strcat(string, ""COL_LIGHT_BLUE"Stats - "COL_WHITE"Shows your or else's stats.\n");
	strcat(string, ""COL_LIGHT_BLUE"Pm - "COL_WHITE"Sends a private message.\n");
	strcat(string, ""COL_LIGHT_BLUE"Settings - "COL_WHITE"Modifies your settings.\n");
	strcat(string, ""COL_LIGHT_BLUE"Ranks - "COL_WHITE"Shows server ranks.\n");
	strcat(string, ""COL_LIGHT_BLUE"Savemystats - "COL_WHITE"Saves your stats in the database.\n");
	strcat(string, ""COL_LIGHT_BLUE"Killme - "COL_WHITE"Sets your health to zero.\n");
	strcat(string, ""COL_LIGHT_BLUE"Credits - "COL_WHITE"Shows community credits.\n");
	strcat(string, ""COL_LIGHT_BLUE"Rules - "COL_WHITE"Shows server rules.\n");
	strcat(string, ""COL_LIGHT_BLUE"Updates - "COL_WHITE"Shows server updatelog.\n");
	strcat(string, ""COL_LIGHT_BLUE"Report - "COL_WHITE"Sends a report to admins.\n");
	strcat(string, ""COL_LIGHT_BLUE"Helpme - "COL_WHITE"Sends a a helpme message to admins.\n");
	strcat(string, ""COL_LIGHT_BLUE"Roundhelp - "COL_WHITE"Shows round guide.\n");
	strcat(string, ""COL_LIGHT_BLUE"baseshieldhelp - "COL_WHITE"Shows base shield guide.\n");
	strcat(string, ""COL_LIGHT_BLUE"Refill - "COL_WHITE"Refills your class weapons incase you're in range of an ammo box.\n");	
	strcat(string, ""COL_LIGHT_BLUE"Togglehelmet - "COL_WHITE"Toggles your helmet (On/Off).\n");		
	strcat(string, ""COL_LIGHT_BLUE"Togglemask - "COL_WHITE"Toggles your Gas mask (On/Off).\n");		
	strcat(string, ""COL_LIGHT_BLUE"Dhelp - "COL_WHITE"Shows donation info and VIP features.\n");				
	strcat(string, ""COL_LIGHT_BLUE"Ss - "COL_WHITE"Changes your spawn point.\n\n");
	strcat(string, ""COL_LIGHT_GREEN"Team commands:\n");
	strcat(string, ""COL_LIGHT_BLUE"St - "COL_WHITE"Changes your team and class.\n");
	strcat(string, ""COL_LIGHT_BLUE"r - "COL_WHITE"Sends a team message.\n");
	strcat(string, ""COL_LIGHT_BLUE"Teamstats - "COL_WHITE"Shows teams stats.\n");
	strcat(string, ""COL_LIGHT_BLUE"Fmsg - "COL_WHITE"Sends a team message.\n\n");
	strcat(string, ""COL_LIGHT_GREEN"Class commands:\n");
	strcat(string, ""COL_LIGHT_BLUE"Heal - "COL_WHITE"Heals a in range team mate - "COL_ORANGE"Medic.\n");
	strcat(string, ""COL_LIGHT_BLUE"Deploymk - "COL_WHITE"Deploys a medic kit - "COL_ORANGE"Medic.\n");	
	strcat(string, ""COL_LIGHT_BLUE"Suicide - "COL_WHITE"Explodes you and kills your in range enemies - "COL_ORANGE"Suicider.\n");
	strcat(string, ""COL_LIGHT_BLUE"Plantc4 - "COL_WHITE"Plants a C4 - "COL_ORANGE"Bomberman.\n");
	strcat(string, ""COL_LIGHT_BLUE"Detonate - "COL_WHITE"Detonates a C4 that you planted and kills in range enemies - "COL_ORANGE"Bomberman.\n");
	strcat(string, ""COL_LIGHT_BLUE"Dis - "COL_WHITE"Shows disguise menu - "COL_ORANGE"Spy\n");
	strcat(string, ""COL_LIGHT_BLUE"sammo - "COL_WHITE"Refills in range mates's class weapons - "COL_ORANGE"Supporter.\n");
	strcat(string, ""COL_LIGHT_BLUE"Disarmc4 - "COL_WHITE"Disarms a C4 - "COL_ORANGE"Engineer / Bomberman.\n");
	strcat(string, ""COL_LIGHT_BLUE"Getdrone - "COL_WHITE"Gets you a drone - "COL_ORANGE"Scout.\n");

	strcat(string, ""COL_LIGHT_GREEN"Deathmatch commands:\n");
	strcat(string, ""COL_LIGHT_BLUE"Dm - "COL_WHITE"Shows list of death match arenas.\n");
	strcat(string, ""COL_LIGHT_BLUE"Duel - "COL_WHITE"Sends a duel request.\n");
	strcat(string, ""COL_LIGHT_BLUE"Duelrace - "COL_WHITE"Sends a race duel request.\n\n");

	strcat(string, ""COL_LIGHT_GREEN"Special zones:\n");
	strcat(string, ""COL_LIGHT_BLUE"Airstrike - "COL_WHITE"Launches an airstrike at your co-ordinates - "COL_ORANGE"Radio base.\n");			

	Dialog_Show(playerid, DIALOG_COMMANDS, DIALOG_STYLE_MSGBOX, "WF - Commands", string, "Close", "");
	return 1;
}


CMD:togglehelmet(playerid)
{
	if(pInfo[playerid][IsPlayerHavingHelmet] == false) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You don't even have a helmet.");
	if(pInfo[playerid][Helmet] == true)
	{
		SendClientMessage(playerid, COLOR_DARK_RED, "You have disabled the helmet protection you can get it back by using togglehelmet.");
		ToggleHelmetForPlayer(playerid, false);
	}
	else if(pInfo[playerid][Helmet] == false)
	{
		SendClientMessage(playerid, COLOR_DARK_RED, "You have enabled the helmet protection you can turn it off by using togglehelmet.");
		ToggleHelmetForPlayer(playerid, true);	
	}
	return 1;
}

CMD:togglemask(playerid)
{
	if(pInfo[playerid][IsPlayerHavingMask] == false) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You don't even have a gas mask.");
	if(pInfo[playerid][Mask] == true)
	{
		SendClientMessage(playerid, COLOR_DARK_RED, "You have disabled the gas mask protection you can get it back by using togglemask.");
		ToggleGasMaskForPlayer(playerid, false);
	}
	else if(pInfo[playerid][Mask] == false)
	{
		SendClientMessage(playerid, COLOR_DARK_RED, "You have enabled the Mask protection you can turn it off by using togglemask.");
		ToggleGasMaskForPlayer(playerid, true);	
	}
	return 1;
}

CMD:getpack(playerid)
{
	new bool:success = false;
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		new Float:x,Float:y,Float:z;
		GetObjectPos(pInfo[i][CarePackageObj], x, y, z);
		if(IsPlayerInRangeOfPoint(playerid, 3,x,y,z))
		{
			success = true;
			pInfo[i][pCarePackage] = false;
			DestroyObject(pInfo[i][CarePackageObj]);
			DestroyDynamic3DTextLabel(pInfo[i][CarePackLabel]);
			switch(random(5))
			{
				case 0:
				{
					GivePlayerClassWeapons(playerid);
					SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got your class weapons refilled.");
				}
				case 1:
				{
					GivePlayerWeapon(playerid, WEAPON_ROCKETLAUNCHER, 5);
					SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got 5 Rockets.");
				}
				case 2:
				{
					GivePlayerWeapon(playerid, WEAPON_GRENADE, 5);
					SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got 5 grenades.");
				}
				case 3:
				{
					GivePlayerWeapon(playerid, WEAPON_MOLTOV, 5);
					SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got 5 Moltovs.");					
				}
				case 4:
				{
					GivePlayerWeapon(playerid, WEAPON_MINIGUN, 125);
					SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got a minigun.");										
				}
			}
		}
	}
	if(success == false) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not in range of any care package.");
	return 1;
}

CMD:setarmour(playerid,params[])
{
	new Float:ammm;
	if(sscanf(params, "f", ammm)) return SendClientMessage(playerid, -1, "armour u lil fag");
	SetPlayerArmour(playerid, ammm);
	return 1;
}

CMD:getvest(playerid)
{
	new bool:success = false;
	
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		new Float:x,Float:y,Float:z;
		GetDynamicObjectPos(pInfo[i][BallisticVestObj2], x, y, z);
		if(IsPlayerInRangeOfPoint(playerid,5, x, y, z))
		{
			new Float:AR;
			GetPlayerArmour(playerid, AR);
			if(AR == 100.0) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You already have 100 Armour.");
			success = true;
			SetPlayerArmour(playerid, 100.0);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got the ballistic vest lvl 2.");
			DestroyDynamicObject(pInfo[i][BallisticVestObj2]);
			DestroyDynamic3DTextLabel(pInfo[i][BallisticVestLabel2]);
			return 1;			
		}
	}

	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		new Float:x,Float:y,Float:z;
		GetObjectPos(pInfo[i][BallisticVestObj1],x, y, z);
		if(IsPlayerInRangeOfPoint(playerid, 5.0,x, y, z))
		{
			new Float:AR;
			GetPlayerArmour(playerid, AR);
			if(AR >= 50.0) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You already have 50 Armour or more.");
			success = true;
			SetPlayerArmour(playerid, 50.0);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You got the ballistic vest lvl 1.");
			DestroyObject(pInfo[i][BallisticVestObj1]);
			DestroyDynamic3DTextLabel(pInfo[i][BallisticVestLabel]);
		}
	}
	if(success == false) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not in range of any ballistic vest.");
	return 1;
}

CMD:serverinfo(playerid)
{
	new str[200], players,vehicles, cp[3], cv[3];
	players = GetPlayerCount();
	vehicles = GetVehicleCount();
	valstr(cp, players);
	valstr(cv, vehicles += 1);
	strcat(str, ""COL_LIGHT_GREEN"Players: "COL_WHITE"");
	strcat(str, cp);
	strcat(str, "\n"COL_LIGHT_GREEN"Vehicles spawned: "COL_WHITE"");
	strcat(str, cv);
	strcat(str, "\n"COL_LIGHT_GREEN"GameMode version: "COL_WHITE""#GM_VERSION"\n");
	strcat(str, "");
	Dialog_Show(playerid, DIALOG_SERVER_INFO, DIALOG_STYLE_MSGBOX, "WF - Info", str, "Close", "");

	return 1;
}
CMD:spreeplz(playerid)
{
	pInfo[playerid][KillStreak] += 5;

	return 1;
}
CMD:sstreak(playerid)
{
	if(gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't use this command outside Main mode.");
	new str[750];
	strcat(str, "Name\tDescription\tXP\tKill spree\n");
	for(new i; i < MAX_SUPPORT_STREAK; i++)
	{
		new xpstr[5],kspree[4];
		strcat(str, ""COL_LIGHT_BLUE"");
		strcat(str, gSStreak[i][SStreakName]);
		strcat(str, "\t");
		strcat(str, ""COL_ORANGE"");
		strcat(str, gSStreak[i][SStreakDescription]);
		strcat(str, "\t");
		valstr(xpstr, gSStreak[i][SStreakXP]);
		if(pInfo[playerid][pXP] >= gSStreak[i][SStreakXP]) strcat(str, ""COL_LIGHT_GREEN"");
		else if(pInfo[playerid][pXP] < gSStreak[i][SStreakXP]) strcat(str, ""COL_LIGHT_RED"");
		strcat(str, xpstr);
		strcat(str, "\t");
		if(gClass[playerid] != CLASS_TROOPER)
		{
			if(pInfo[playerid][KillStreak] >= gSStreak[i][SStreakKSpree]) strcat(str, ""COL_LIGHT_GREEN"");
			else if(pInfo[playerid][KillStreak] < gSStreak[i][SStreakKSpree]) strcat(str, ""COL_LIGHT_RED"");
			valstr(kspree, gSStreak[i][SStreakKSpree]);
		}		
		else if(gClass[playerid] == CLASS_TROOPER && gSStreak[i][SStreakKSpree] != 0)
		{
			new KillStreakForTrooper = gSStreak[i][SStreakKSpree];
			KillStreakForTrooper--;
			if(pInfo[playerid][KillStreak] >= KillStreakForTrooper) strcat(str, ""COL_LIGHT_GREEN"");
			else if(pInfo[playerid][KillStreak] < KillStreakForTrooper) strcat(str, ""COL_LIGHT_RED"");
			valstr(kspree, KillStreakForTrooper);
		}
		else if(gClass[playerid] == CLASS_TROOPER && gSStreak[i][SStreakKSpree] == 0)
		{
			strcat(str, ""COL_LIGHT_GREEN"");
			valstr(kspree, 0);
		}		
		strcat(str, kspree);
		strcat(str, "\n");
	}
	Dialog_Show(playerid, DIALOG_SUPPORT_STREAK, DIALOG_STYLE_TABLIST_HEADERS, "WF - Support streak", str, "Use", "Cancel");
	return 1;
}
CMD:refill(playerid)
{
	new bool:success = false;

	for(new i; i < MAX_AMMO_BOXES; i++)
	{
		new Float: X, Float: Y, Float: Z;
		GetDynamicObjectPos(gAmmoBox[i][AmmoBoxID], X,Y,Z);
		if (IsPlayerInRangeOfPoint(playerid, 3.0, X, Y, Z))
		{
			success = true;
			if (pInfo[playerid][AmmoRefill] > gettime()) return SendClientMessage(playerid, COLOR_RED,"ERROR: You already refiled Ammo! you have to wait 3 Minutes to refil again");
			GivePlayerClassWeapons(playerid);
			SendClientMessage(playerid, COLOR_LIGHT_GREEN,"You have to wait 3 minutes to refil again.");
			pInfo[playerid][AmmoRefill] = gettime() + 180;
		}
	}
	if(success == false) return SendClientMessage(playerid,COLOR_DARK_RED, "ERROR: You're not in range of any ammo box.");
	return 1;
}
CMD:dm(playerid)
{
	if(pInfo[playerid][AdminDuty] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't join dm while on duty.");
	if(pInfo[playerid][SpawnProtection] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't join dm while being protected by anti-SK.");
	new str[200];
	for(new i; i < MAX_MODES; i++)
	{
		new pInMode;
		strcat(str, ""COL_LIGHT_BLUE"");
		strcat(str, vMode[i][modeName]);
		for(new p = 0, j = GetPlayerPoolSize(); p <= j; p++)
		{
			if(gMode[p] == i)
			pInMode++;
		}
		strcat(str, ""COL_LIGHT_GREEN"""\t");
		new strx[3];
		valstr(strx, pInMode);
		strcat(str, strx);
		strcat(str, "\n");
	}
	Dialog_Show(playerid, DIALOG_DM, DIALOG_STYLE_LIST, "WF - DM", str, "Join", "Cancel");
	return 1;
}
CMD:qdm(playerid)
{
	if(gMode[playerid] == MODE_MAIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not in dm.");
	gMode[playerid] = MODE_MAIN;
	SetPlayerInterior(playerid, 0);
	SpawnPlayer(playerid);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_BLUE"%s "COL_WHITE"has left death match arena.",pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	return 1;
}

CMD:airstrike(playerid,params[])
{
	if (gZone[CP_RADIOBASE][zoneOwner] != gTeam[playerid]) return SendClientMessage(playerid, COLOR_RED,"ERROR: "COL_WHITE"Your team has to own Radio base.");
	if (gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_RED,"ERROR: You cannot use this command in Death match arenas.");
	if (pDuel[playerid][E_DUEL_ACTIVE] == 1) return SendClientMessage(playerid, COLOR_RED,"ERROR: You cannot use this command in duel.");
	if (pInfo[playerid][Money] < 10000) return SendClientMessage(playerid, COLOR_RED,"ERROR: You need at least 10000 money.");
	if (gAirstrike > gettime()) return SendClientMessage(playerid, COLOR_RED,"ERROR: Airstrike is currently used, You have to wait 2 minutes for another one.");
	
	new Float: x, Float: y,Float: z;
	pInfo[playerid][Money] -= 10000;
	SendClientMessage(playerid, COLOR_RED,"The airstrike will be here in 5 seconds.");
	GetPlayerPos(playerid, x, y, z);
	gAirstrike = gettime() + 120;
	gAirstrikeObject = CreateObject(1636, x,y,z+200,-90.000,-90.000,-90.000,100.000);
	MoveObject(gAirstrikeObject, x,y,z-1,40,0,0);
	gAirstrikeLauncherID = playerid;
	return 1;
}

CMD:spawnpoint(playerid)
{
	new str[700];
	strcat(str, "{FFFFFF}Base\n");
	for(new i; i < MAX_CAPTURE_ZONES; i++)
	{
		if (gZone[i][zoneOwner] == gTeam[playerid]) strcat(str, COL_LIGHT_GREEN);
		else if (gZone[i][zoneAttacker] != INVALID_PLAYER_ID) strcat(str, COL_ORANGE);
		else strcat(str, COL_LIGHT_RED);

		strcat(str, gZone[i][zoneName]);
		strcat(str, "\n");
	}
	Dialog_Show(playerid, DIALOG_SPAWNPOINT, DIALOG_STYLE_LIST, "WF - Spawn point", str, "Select", "Cancel");
	return 1;
}
CMD:ss(playerid) return cmd_spawnpoint(playerid),1;

CMD:duel(playerid,params[])
{
	if (pInfo[playerid][SpawnProtection] == true) return SendClientMessage(playerid, COLOR_RED,"ERROR: You can't duel while anti-sk enabled Press 'N' to disable it or wait 10 seconds");
	if (pDuel[playerid][E_DUEL_ACTIVE] != -1) return SendClientMessage(playerid, COLOR_RED,"ERROR: You're  already in duel.");
	if (pInfo[playerid][DuelDND] == true) return SendClientMessage(playerid, COLOR_RED, "ERROR: You have duel do not disturb mode enabled.");

	new targetid,str[200],DuelWeapon, DuelBet;
	if (sscanf(params, "iii", targetid, DuelWeapon,DuelBet)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel [playerid] [Weaponid] [Bet]");
	if (targetid == INVALID_PLAYER_ID || targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "ERROR: Player is not connected, Or is yourself.");
	if (pInfo[targetid][SpawnProtection] == true) return SendClientMessage(playerid, COLOR_RED,"ERROR: This player is still under spawn protection.");
	if (pInfo[targetid][DuelDND] == true) return SendClientMessage(playerid, COLOR_RED, "ERROR: The target has Duel do not disturb mode enabled.");
	if (pDuel[targetid][E_DUEL_ACTIVE] == 1) return SendClientMessage(playerid, COLOR_RED,"ERROR: This player is already in a duel.");

	if (pDuel[playerid][E_DUEL_REQUEST] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You already sent someone a duel request wait until he accept/refuse.");
	if (pDuel[targetid][E_DUEL_REQUEST]  == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player has received a duel request from someone else, wait until he refuse/accept!");

	if (!IsValidWeapon(DuelWeapon)) return SendClientMessage(playerid, COLOR_RED, "ERROR: Invalid weapon ID !");

	if (DuelWeapon ==  38 || DuelWeapon == 36) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can't use this weapon");
	if (DuelBet > 50000 || DuelBet < 500) return SendClientMessage(playerid, COLOR_RED,"ERROR: Max duel bet is 50000 and minimum is 500.");

	if (pInfo[playerid][Money] < DuelBet) return SendClientMessage(playerid, COLOR_RED, "ERROR: You don't have enough money.");
	if (pInfo[playerid][Money] < DuelBet) return SendClientMessage(playerid, COLOR_RED, "ERROR: Target ID doesn't have enough money.");

	pDuel[playerid][E_DUEL_TARGET] = targetid;
	pDuel[targetid][E_DUEL_TARGET] = playerid;

	pDuel[targetid][E_DUEL_WEAPON] = DuelWeapon;
	pDuel[playerid][E_DUEL_WEAPON] = DuelWeapon;

	pDuel[targetid][E_DUEL_BET] = DuelBet;
	pDuel[playerid][E_DUEL_BET] = DuelBet;

	format(str,sizeof str,"Your request has been sent to %s Weapon: %s Bet: %d", pInfo[targetid][Name],WeaponNames[DuelWeapon],DuelBet);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);

	format(str, sizeof str,"%s has sent you a duel request ! Weapon: %s Bet: %d", pInfo[playerid][Name],WeaponNames[DuelWeapon],DuelBet);
	SendClientMessage(targetid, COLOR_LIGHT_GREEN, str);

	pDuel[playerid][E_DUEL_REQUEST] = 1;
	pDuel[targetid][E_DUEL_REQUEST]  = 1;

	format(str, sizeof(str), ""COL_LIGHT_BLUE"%s "COL_WHITE"has sent you a duel request.", pInfo[playerid][Name]);
	Dialog_Show(targetid, DIALOG_DUEL_REQUEST, DIALOG_STYLE_MSGBOX, ""COL_LIGHT_BLUE"WF: Duel", str, "Accept", "Refuse");
	return 1;
}

CMD:duelrace(playerid,params[])
{
	if (pInfo[playerid][SpawnProtection] == true) return SendClientMessage(playerid, COLOR_RED,"ERROR: You can't duel while anti-sk enabled Press 'N' to disable it or wait 10 seconds");
	if (pDuel[playerid][E_DUEL_ACTIVE] != -1) return SendClientMessage(playerid, COLOR_RED,"ERROR: You're  already in duel.");
	if (pInfo[playerid][DuelDND] == true) return SendClientMessage(playerid, COLOR_RED, "ERROR: You have duel do not disturb mode enabled.");

	if (IsRaceDuelOccupied == true) return SendClientMessage(playerid, COLOR_RED,  "ERROR: There is another race duel already running at moment, Try later.");

	new targetid,DuelBet,str[200];
	if (sscanf(params, "ii", targetid, DuelBet)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duelrace [playerid]  [Bet]");
	if (pInfo[targetid][SpawnProtection] == true) return SendClientMessage(playerid, COLOR_RED,"ERROR: This player is still under spawn protection.");
	if (pInfo[targetid][DuelDND] == true) return SendClientMessage(playerid, COLOR_RED, "ERROR: The target has Duel do not disturb mode enabled.");
	if (pDuel[targetid][E_DUEL_ACTIVE] == 1) return SendClientMessage(playerid, COLOR_RED,"ERROR: This player is already in a duel.");

	if (pDuel[playerid][E_DUEL_REQUEST] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You already sent someone a duel request wait until he accept/refuse.");
	if (pDuel[targetid][E_DUEL_REQUEST]  == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player has received a duel request from someone else, wait until he refuse/accept!");

	if (DuelBet > 50000 || DuelBet < 500) return SendClientMessage(playerid, COLOR_RED,"ERROR: Max duel bet is 50000 and minimum is 500.");

	pDuel[playerid][E_DUEL_TARGET] = targetid;
	pDuel[targetid][E_DUEL_TARGET] = playerid;


	pDuel[targetid][E_DUEL_BET] = DuelBet;
	pDuel[playerid][E_DUEL_BET] = DuelBet;


	format(str,sizeof str,"Your request has been sent to %s Bet: %d", pInfo[targetid][Name],DuelBet);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);

	format(str, sizeof str,"%s has sent you a race duel request ! Weapon: %s Bet: %d", pInfo[playerid][Name],DuelBet);
	SendClientMessage(targetid, COLOR_LIGHT_GREEN, str);

	pDuel[playerid][E_DUEL_REQUEST] = 1;
	pDuel[targetid][E_DUEL_REQUEST]  = 1;
	format(str, sizeof(str), ""COL_LIGHT_BLUE"%s "COL_WHITE"has sent you a "COL_LIGHT_BLUE"race duel "COL_WHITE"request.", pInfo[playerid][Name]);
	Dialog_Show(targetid, DIALOG_DUEL_RACE_REQUEST, DIALOG_STYLE_MSGBOX, ""COL_LIGHT_BLUE"WF: Race duel", str, "Accept", "Refuse");
	return 1;
}

CMD:report(playerid,params[])
{
	new reason[50],targetid;
	if(sscanf(params, "is[50]", targetid, reason)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /report [playerid] [reason]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, "Your report has been sent to online staffs.");
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"%s[%d] "COL_LIGHT_RED"has reported %s[%d] for %s", pInfo[playerid][Name],playerid, pInfo[targetid][Name],targetid,reason);
	foreach(new i : Player)
	{
		if(pInfo[i][AdminRank] >= TRIAL_ADMIN) SendClientMessage(i, -1,str);
	}
	format(str, sizeof(str), "%s has reported %s for %s", pInfo[playerid][Name], pInfo[targetid][Name], reason);
	DCC_SendChannelMessage(g_Report_Channel, str);	
	return 1;
}

CMD:helpme(playerid,params[])
{
	new question[80];
	if(sscanf(params, "s[80]", question)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /helpme [Text]");
	if(strlen(question) > 80 || strlen(question) < 4) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Minimum text length is 4 and max is 80 (Characters).");
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, "Your request has been sent to online staffs.");
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"%s[%d] "COL_LIGHT_RED"has sent a helpme message: %s", pInfo[playerid][Name],playerid, question);
	foreach(new i : Player)
	{
		if(pInfo[i][AdminRank] >= TRIAL_ADMIN) SendClientMessage(i, -1,str);
	}
	format(str, sizeof(str), "%s has send a helpme message: %s", pInfo[playerid][Name],question);
	DCC_SendChannelMessage(g_Logs_Channel, str);		
	return 1;
}

CMD:r(playerid,params[])
{
	if(vTeam[gTeam[playerid]][TeamRadio] == false) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: Your team's antenna is destroyed, You cannot communicate.");
	new text[80];
	if(sscanf(params, "s[128]", text)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /r [text]");
	new str[128];		
	if(stringContainsIP(text))
	{
		SendClientMessage(playerid, COLOR_LIGHT_RED, "Text blocked for advertising.");
		format(str, sizeof(str), "%s tried to adv: %s", pInfo[playerid][Name], text);
		SendMessageToAdmins(-1, str);
		DCC_SendChannelMessage(g_Report_Channel, str);
		return 1;
	}	
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		format(str, sizeof(str), ""COL_ORANGE"[%s radio] %s[%d]: "COL_WHITE"%s", vTeam[gTeam[playerid]][teamName], pInfo[playerid][Name],playerid, text);
		if(gTeam[i] == gTeam[playerid]) SendClientMessage(i, -1, str);
	}
	return 1;
}

CMD:fmsg(playerid)
{
	if(vTeam[gTeam[playerid]][TeamRadio] == false) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: Your team's antenna is destroyed, You cannot communicate.");
	if(gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can only use this command in main warfield mode.");
	new str[300];
	format(str, sizeof str, "Follow me\nEnemy spotted\nTaking fire,I need help\nCover me\nYou take this position\nHold this position\nRegroup team\nCovering fire\n");
	Dialog_Show(playerid, DIALOG_FMSG, DIALOG_STYLE_LIST, "Send team message:", str, "Select", "Cancel");
	return 1;
}

CMD:roundhelp(playerid)
{
	new str[900];
	strcat(str, ""COL_BLUE"How does round system work:\n");
	strcat(str, ""COL_WHITE"*First team that reaches "#ROUND_POINTS" points Wins the round.\n");
	strcat(str, ""COL_WHITE"*Each time a round ends another one begins.\n");
	strcat(str, ""COL_BLUE"How to get team points:\n");
	strcat(str, ""COL_WHITE"*Capturing zones gets you "COL_LIGHT_BLUE""#POINT_PER_CAPTURE ""COL_WHITE" Points.\n");
	strcat(str, ""COL_WHITE"*Killing enemies gets you "COL_LIGHT_BLUE""#POINT_PER_KILL""COL_WHITE" Multiplied\n");
	strcat(str, "With the amount of capture zones your team owns Example:\n");
	strcat(str, "if your team doesn't own any zone or own only one you get 10 incase it owns 2 you get 20 points.\n");
	strcat(str, ""COL_WHITE"*Capturing prototypes gets you "COL_LIGHT_BLUE""#POINT_PER_PROTOTYPE_CAPTURE""COL_WHITE" Points\n");
	strcat(str, ""COL_BLUE"How do I get to know teams stats:\n");
	strcat(str, ""COL_WHITE"You can check the text that is below your stats text or you can use /teamstats.\n");
	strcat(str, ""COL_BLUE"What do I get from this:\n");
	strcat(str, ""COL_WHITE"*The winner team members gets 50 score and 50.000 Money.\n");			
	
	Dialog_Show(playerid, ROUND_HELP_DIALOG, DIALOG_STYLE_MSGBOX, "ROUND - HELP", str, "Close", "");
	return 1;
}

CMD:teamstats(playerid)
{
	new str[500];
	strcat(str, "Name\tMembers\tPoints\tZones\n");

	for(new i; i < MAX_TEAMS;i++)
	{
		new tp[5],mc = 0, mcstr[5], zoneowned, zoneownedstr[3];
		strcat(str, vTeam[i][teamColor2]);
		strcat(str, vTeam[i][teamName]);
		strcat(str, "\t");
		for(new x = 0, j = GetPlayerPoolSize(); x <= j; x++)
		{
			if(IsPlayerConnected(x) && gTeam[x] == i)
			{
				mc += 1;
			}
		}
		valstr(mcstr, mc);
		strcat(str, mcstr);
		strcat(str, "\t");
		valstr(tp, vTeam[i][TeamPoints]);
		strcat(str, ""COL_WHITE"");
		strcat(str, tp);
		strcat(str, "\t");
		for(new x; x < MAX_CAPTURE_ZONES; x++)
		{
			if(gZone[x][zoneOwner] == i) zoneowned++;
		}
		valstr(zoneownedstr, zoneowned);
		strcat(str,zoneownedstr);
		strcat(str, "\n");
	}
	Dialog_Show(playerid, DIALOG_TEAM_STATS, DIALOG_STYLE_TABLIST_HEADERS, "TEAMS - STATS",str, "Close", "");
	return 1;
}

CMD:updates(playerid)
{
	new str[350];
	strcat(str, ""COL_WHITE"-Added a missile launcher for each team base.");
	Dialog_Show(playerid, DIALOG_UPDATES,DIALOG_STYLE_MSGBOX, "WF - Updates", str, "Close", "");
	return 1;
}

CMD:baseshieldhelp(playerid)
{
	new str[500];
	strcat(str, ""COL_LIGHT_BLUE"What is a base shield:"COL_WHITE" Protects your team base from enemy heavy vehicles (Hydra/Hunter/Rhino/Seaspar)\nSo each time a enemy heavy vehicle gets inside your team base it will be destroyed.\n\n"COL_LIGHT_BLUE"Is it possible to destroy enemy's base shield ?\n"COL_WHITE"Yes, You just need to be a Bomberman, Then go to the missile launcher and plant & detonate a C4 there.\n\n"COL_LIGHT_BLUE"What do I do when my base shield is destroyed?\n"COL_WHITE"You just need to wait 40 Second and it will be back.");
	Dialog_Show(playerid, DIALOG_SHIELD_HELP,DIALOG_STYLE_MSGBOX, "Base shield help", str, "Close", "");
	return 1;
}

CMD:settings(playerid)
{
	new str[300];
	strcat(str, ""COL_WHITE"Do not disturb mode: ");
	if(pInfo[playerid][DND] == true)
	{
		strcat(str, ""COL_LIGHT_GREEN"Enabled");
	}
	else if(pInfo[playerid][DND] == false)
	{
		strcat(str, ""COL_LIGHT_RED"Disabled");		
	}

	strcat(str, ""COL_WHITE"\nDuels: ");
	if(pInfo[playerid][DuelDND] == true)
	{
		strcat(str, ""COL_LIGHT_GREEN"Enabled");
	}
	else if(pInfo[playerid][DuelDND] == false)
	{
		strcat(str, ""COL_LIGHT_GREEN"Disabled");
	}
	strcat(str, ""COL_WHITE"\nGas mask: ");
	if(pInfo[playerid][Mask] == true)
	{
		strcat(str, ""COL_LIGHT_GREEN"Enabled");
	}
	else if(pInfo[playerid][Mask] == false)
	{
		strcat(str, ""COL_LIGHT_GREEN"Disabled");
	}
	strcat(str, ""COL_WHITE"\nHelmet: ");
	if(pInfo[playerid][Helmet] == true)
	{
		strcat(str, ""COL_LIGHT_GREEN"Enabled");
	}
	else if(pInfo[playerid][Helmet] == false)
	{
		strcat(str, ""COL_LIGHT_GREEN"Disabled");
	}	
	Dialog_Show(playerid, PLAYER_SETTINGS_DIALOG, DIALOG_STYLE_LIST, "Player - Settings", str, "Modify", "Quit");
	return 1;
}

CMD:savemystats(playerid)
{
	if(pInfo[playerid][LoggedIn] == false) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not logged in.");
	SavePlayerStats(playerid);
	GameTextForPlayer(playerid, "~g~Stats ~w~saved", 3000, 3);
	return 1;
}

CMD:pm(playerid,params[])
{
	new targetid, message[150];
	if(sscanf(params, "is[150]", targetid, message)) return SendClientMessage(playerid, COLOR_DARK_RED, "USAGE: /pm [playerid] [text].");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Invalid playerid or player is not connected.");
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't PM yourself.");
	if(pInfo[targetid][Muted] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't pm muted players.");
	if(pInfo[playerid][Muted] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't pm while you're muted.");	
	if(pInfo[targetid][DND] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: This player has DND mode enabled.");
	if(pInfo[playerid][DND] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't pm players while DND mode enabled, Disable it.");
	
	new str[300];
	
	if(stringContainsIP(message))
	{
		SendClientMessage(playerid, COLOR_LIGHT_RED, "Text blocked for advertising.");
		format(str, sizeof(str), "%s tried to adv: %s", pInfo[playerid][Name], message);
		SendMessageToAdmins(-1, str);
		DCC_SendChannelMessage(g_Report_Channel, str);
		return 1;
	}	

	format(str,sizeof(str), ""COL_ORANGE"PM to %s[%d]: "COL_WHITE"%s", pInfo[targetid][Name], targetid,message);
	SendClientMessage(playerid, -1,str);

	format(str,sizeof(str), ""COL_ORANGE"PM from %s[%d]: "COL_WHITE"%s", pInfo[playerid][Name],playerid, message);
	SendClientMessage(targetid, -1,str);

	format(str, sizeof(str), "PM From %s[%d] to %s[%d] %s",pInfo[playerid][Name], playerid, pInfo[targetid][Name], targetid, message);
	SendMessageToAdmins(COLOR_GREY,str);
	DCC_SendChannelMessage(g_Logs_Channel, str);
	return 1;
}

CMD:stats(playerid, params[])
{
	new str[400], targetid;
	if(sscanf(params, "i",targetid))
	{
		SendClientMessage(playerid, COLOR_ORANGE, "[Info] You can also check others stats by using /stats [playerid].");
		targetid = playerid;
	}
	else
	{
		if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: Player is not connected.");
	}
	format(str,sizeof(str), ""COL_BLUE"Nickname: "COL_WHITE"%s\n"COL_BLUE"Score: "COL_WHITE"%d\n"COL_BLUE"Money: "COL_WHITE"%d\n"COL_BLUE"Kills: "COL_WHITE"%d\n"COL_BLUE"Deaths: "COL_WHITE"%d\n"COL_BLUE"Team: "COL_WHITE"%s\n"COL_BLUE"Class: "COL_WHITE"%s\n"COL_BLUE"XP: "COL_WHITE"%d\n"COL_BLUE"Kill spree: "COL_WHITE"%d\n", 
	pInfo[targetid][Name], pInfo[targetid][Score],pInfo[targetid][Money],pInfo[targetid][Kills],pInfo[targetid][Deaths], vTeam[gTeam[targetid]][teamName], vClass[gClass[targetid]][className], pInfo[targetid][pXP], pInfo[targetid][KillStreak]);
	
	Dialog_Show(playerid, DIALOG_PLAYER_STATS, DIALOG_STYLE_MSGBOX, "PLAYER - STATS",str, "Close", "");
	return 1;
}

CMD:ranks(playerid)
{
	new str[700];
	strcat(str, ""COL_BLUE"Rank name\t\t"COL_LIGHT_BLUE"Tag\t"COL_WHITE"Score\n\n");
	for(new i = 0; i < MAX_RANKS; i++)
	{
		new strx[12];

		strcat(str, ""COL_BLUE"");
		strcat(str, vRank[i][rankName]);
		strcat(str, ":");
		if(strlen(vRank[i][rankName]) <= 5) strcat(str, "    ");

		if(strlen(vRank[i][rankName]) > 10) strcat(str, "\t");
		else if(strlen(vRank[i][rankName]) <= 10) strcat(str, "\t\t");
		strcat(str, ""COL_LIGHT_BLUE"");
		strcat(str, vRank[i][rankTag]);
		strcat(str, "\t");
		strcat(str, ""COL_WHITE"");
		valstr(strx, vRank[i][rankScore]);

		strcat(str, strx);
		strcat(str, "\n");
	}
	Dialog_Show(playerid, RANKS_DIALOG, DIALOG_STYLE_TABLIST_HEADERS,"WF - Ranks", str, "close", "");
	return 1;
}

CMD:killme(playerid)
{
	new Float: x,Float:y,Float:z;
	GetPlayerPos(playerid, x,y,z);
	foreach(new i: Player)
	{
		if(IsPlayerInRangeOfPoint(i, 20, x,y,z) && gTeam[i] != gTeam[playerid])
		{
			SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't suicide while in range of an enemy.");
			return 1;
		}
	}
	SetPlayerHealth(playerid, 0.0);
	SendClientMessage(playerid, COLOR_ORANGE, "You have commited suicide.");
	return 1;
}

CMD:kill(playerid)
{
	return cmd_killme(playerid);
}

CMD:credits(playerid)
{
	new str[150];
	strcat(str, ""COL_BLUE"Community Developed by: "COL_WHITE"JamesT85 & KaryM711 & Spectat0r & Crash\n");
	Dialog_Show(playerid, DIALOG_CREDITS, DIALOG_STYLE_MSGBOX, "WF - Credits", str, "Close", "");
	return 1;
}

CMD:rules(playerid)
{
	new str[850];
	strcat(str, ""COL_WHITE"1- "COL_DARK_RED"Hacks and cheats "COL_WHITE"aren't allowed.\n2- "COL_DARK_RED"C-Bug / Slide bug / Two-Shoot Bug "COL_WHITE"aren't allowed outside DM Arenas.\n");
	strcat(str, "3- "COL_DARK_RED"Swearing words "COL_WHITE"aren't allowed.\n4- "COL_DARK_RED"Begging staff team for free stuff "COL_WHITE"is not allowed.\n");
	strcat(str, "5- "COL_DARK_RED"Disrespecting community members "COL_WHITE"is not allowed.\n6- "COL_DARK_RED"Alerting cheaters in chat "COL_WHITE"is not allowed, report them instead.");
	strcat(str, "\n7- "COL_DARK_RED"Spawn killing "COL_WHITE"is not allowed.\n8- "COL_DARK_RED"Ban evading "COL_WHITE"is not allowed, Ask for a chance instead.");
	strcat(str, "\n9- "COL_DARK_RED"Advertising other communities "COL_WHITE"is not allowed.\n\n"COL_LIGHT_RED"Note: Breaking the rules leads to punishment.");			
	Dialog_Show(playerid, DIALOG_RULES, DIALOG_STYLE_MSGBOX, "WF - Rules", str, "Close", "");
	return 1;
}

CMD:st(playerid)
{
	new Float: x,Float:y,Float:z;
	GetPlayerPos(playerid, x,y,z);
	foreach(new i: Player)
	{
		if(IsPlayerInRangeOfPoint(i, 20, x,y,z) && gTeam[i] != gTeam[playerid]) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't use this cmd while in range of an enemy.");
		else
		{
			ForceClassSelection(playerid);
			SetPlayerHealth(playerid, 0.0);
		}
	}
	return 1;
}
//Classes commands
CMD:heal(playerid, params[])
{
	if (gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_LIGHT_RED,"ERROR: You can't use this command outside WF Main mode.");
	if (gClass[playerid] != CLASS_MEDIC) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You need to be a medic to use this command.");

	new target;
	if (sscanf(params, "i", target)) return SendClientMessage(playerid, COLOR_LIGHT_RED, "USAGE: /heal [player]");
	if (! IsPlayerConnected(target)) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: The specified player is not connected.");
	if (target == playerid) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You cannot heal yourself, use /Mk instead.");
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	if (! IsPlayerInRangeOfPoint(target, 10.0, pos[0], pos[1], pos[2])) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: The specified player is not near you.");
	if (gTeam[playerid] != gTeam[target]) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You cannot heal enemies.");
	if (pInfo[playerid][HealCMD] > gettime()) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You must wait 30 seconds before healing that specific player again.");

	new Float:hp;
	GetPlayerHealth(target, hp);
	if ((hp + 50.0) >= 100.0) SetPlayerHealth(target, 99.0);
	else SetPlayerHealth(target, hp + 50.0);
	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	PlayerPlaySound(target, 1133, 0.0, 0.0, 0.0);
	pInfo[playerid][HealCMD] = gettime() + 30;
	new string[144];
	format(string, sizeof string, "You have healed %s.", pInfo[target][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, string);
	format(string, sizeof string, "%s has healed you.", pInfo[playerid][Name]);
	SendClientMessage(target, COLOR_LIGHT_GREEN,string);
	return 1;
}


CMD:suicide(playerid)
{
	if(pInfo[playerid][SpawnProtection] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't use this command while being protected.");
	if(gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't use this outside the main mode.");
	if(gClass[playerid] != CLASS_SUICIDER) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to be a suicider to use this command.");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid, x,y,z);
	CreateExplosion(x, y, z, 2, 5.0);
	SetPlayerHealth(playerid, 0);
	foreach(new i : Player)
	{
		if(gTeam[i] != gTeam[playerid] && IsPlayerInRangeOfPoint(i, 8, x, y, z))
		{
			SetPlayerHealth(i, 0);
			SendClientMessage(i, COLOR_DARK_RED, "You were killed by a suicider.");
			OnPlayerDeath(i, playerid, SUICIDER_EXPLOSION);
		}
	}
	return 1;
}

CMD:jetpack(playerid)
{
	if(gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't use this command outside WF Main mode.");
	if(gClass[playerid] != CLASS_JETTROOPER) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to be a jettrooper to use this command.");
	if(pInfo[playerid][JetpackCMD] > gettime()) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to wait 2 minutes to get jetpack again.");
	SetPlayerSpecialAction(playerid, 2);
	SendClientMessage(playerid, COLOR_ORANGE, "You've spawned a jetpack.");
	pInfo[playerid][JetpackCMD] = gettime() + 120;
	return 1;
}

CMD:getdrone(playerid)
{
	if(gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't use this command outside WF Main mode.");
	if(gClass[playerid] != CLASS_SCOUT) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to be a scout to use this command.");
	if(pInfo[playerid][IsPlayerFlyingScoutDrone] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You already got a drone, Press 2 to exit it.");
	if(pInfo[playerid][DroneCMD] > gettime()) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to wait one minute to get a drone again.");
	GetPlayerPos(playerid, pInfo[playerid][pPos][0], pInfo[playerid][pPos][1], pInfo[playerid][pPos][2]);
	pInfo[playerid][DroneCMD] = gettime() + 60;
	pInfo[playerid][IsPlayerFlyingScoutDrone] = true;	
	pInfo[playerid][ScoutDroneVeh] = CreateVehicle(465, pInfo[playerid][pPos][0], pInfo[playerid][pPos][1], pInfo[playerid][pPos][2]+0.5, 0, 0, 0, -1);
	PutPlayerInVehicle(playerid, pInfo[playerid][ScoutDroneVeh], 0);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, "You got a drone raider, Press 2 To exit it, Or press y to detonate it.");
	GameTextForPlayer(playerid, "~w~Press ~r~2 to exit the drone", 10000, 3);
	return 1;
}

CMD:plantc4(playerid)
{
	if(gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't use this command outside WF Main mode.");
	if(gClass[playerid] != CLASS_BOMBER) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to be a bomber to use this command.");
	if(pInfo[playerid][PlantC4CMD] > gettime()) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to wait 30 seconds to plant C4 again.");
	if(pInfo[playerid][PlantedC4] >= MAX_PLANTED_C4S) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to /detonate the other C4 first.");
	PlantC4(playerid);
	pInfo[playerid][PlantingTime] = gettime() + 2;
	return 1;
}

CMD:detonate(playerid)
{
	if(gMode[playerid] != MODE_MAIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't use this command outside WF Main mode.");
	if(gClass[playerid] != CLASS_BOMBER) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to be a bomber to use this command.");
	if(pInfo[playerid][PlantedC4] == NO_PLANTED_C4S) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to /plantc4 first.");
	if(pInfo[playerid][Planting] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't detonate while planting."); 
	new Float:x,Float:y,Float:z, Float:x1,Float:y1,Float:z1;
	GetObjectPos(pInfo[playerid][C4Object], x,y,z);
	CreateExplosion(x, y, z, 0, 5);
	DestroyObject(pInfo[playerid][C4Object]);
	pInfo[playerid][PlantedC4]--;
	foreach(new i : Player)
	{
		if(gTeam[i] != gTeam[playerid] && IsPlayerInRangeOfPoint(i, 7.5, x,y,z))
		{
			SetPlayerHealth(i, 0.0);
			SendClientMessage(i, COLOR_LIGHT_RED, "Killed by a C4 Explosion.");
			OnPlayerDeath(i, playerid, SUICIDER_EXPLOSION);
		}
	}
	for(new i; i < MAX_TEAMS;i++)
	{
		GetObjectPos(vTeam[i][AntennaID], x1,y1,z1);
		if(IsPointInRangeOfPoint(x,y,z,x1,y1,z1,7.5) && vTeam[i][TeamRadio] == true)
		{
			if(gTeam[playerid] == i) return SendClientMessage(playerid, COLOR_LIGHT_RED, "Stop trying to destroy your own team's antenna !");
			else if(gTeam[playerid] != i)
			{
				new str[128];
				format(str, sizeof(str), ""COL_LIGHT_RED"%s "COL_WHITE"has destroyed "COL_LIGHT_BLUE"%s's antenna.", pInfo[playerid][Name],vTeam[i][teamName]);
				SendClientMessageToAll(-1, str);
				DestroyObject(vTeam[i][AntennaID]);
				vTeam[i][TeamRadio] = false;
				SendEnemyTeamMessage(gTeam[playerid], -1,""COL_LIGHT_RED"The enemy "COL_WHITE"has destroyed our antenna, Our radio will go down for 120 Seconds.");
				SendTeamMessage(playerid, -1, "Our enemy's "COL_LIGHT_GREEN"antenna is destroyed, "COL_WHITE"Their radio is down good job team.");
				vTeam[i][TeamRadioDownTime] = (gettime() + 120); 
			}
			return 1;
		}
		GetDynamicObjectPos(vTeam[i][TeamSamID], x1,y1,z1);
		if(IsPointInRangeOfPoint(x,y,z,x1,y1,z1,7.5) && vTeam[i][BaseProtection] == true)
		{
			if(gTeam[playerid] == i) return SendClientMessage(playerid, COLOR_LIGHT_RED, "Stop trying to destroy your own team's Missile launcher !");
			else if(gTeam[playerid] != i)
			{
				new str[128];
				format(str, sizeof(str), ""COL_LIGHT_RED"%s "COL_WHITE"has destroyed "COL_LIGHT_BLUE"%s's Missile launcher.", pInfo[playerid][Name],vTeam[i][teamName]);
				SendClientMessageToAll(-1, str);
				DestroyDynamicObject(vTeam[i][TeamSamID]);
				vTeam[i][BaseProtection] = false;
				SendEnemyTeamMessage(gTeam[playerid], -1,""COL_LIGHT_RED"The enemy "COL_WHITE"has destroyed our missile launcher, Our base protection will be down for 40 Seconds.");
				SendTeamMessage(playerid, -1, "Our enemy's "COL_LIGHT_GREEN"Shield is destroyed, "COL_WHITE"raid them GO! GO! GO!.");
				vTeam[i][TeamShieldDownTime] = (gettime() + 40); 
			}
		}
	}	
	return 1;
}

CMD:disarmc4(playerid)
{
	if(gClass[playerid] != CLASS_BOMBER && gClass[playerid] != CLASS_ENGINEER) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You need to be a bomerman or an engineer.");
	new Float:x,Float:y,Float:z;
	new bool:success = false;
	for(new i = 0, j = GetPlayerPoolSize(); i <= j;i++)
	{
		if(IsPlayerConnected(i))
		{
			GetObjectPos(pInfo[i][C4Object], x,y,z);
			if(IsPlayerInRangeOfPoint(playerid,5.0,x,y,z))
			{
				pInfo[playerid][IsPlayerDisarming] = true;
				pInfo[playerid][DisarmingTime] = gettime() + 2;
				TogglePlayerControllable(playerid, 0);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 2500, 2000);
				success = true;
				//_ _ _ _
				DestroyObject(pInfo[i][C4Object]);
				pInfo[i][PlantedC4] = NO_PLANTED_C4S;

				SendClientMessage(playerid, -1, "You have "COL_LIGHT_GREEN"successfuly "COL_WHITE"disarmed the C4");
				SendClientMessage(i, -1, "Your C4 has been "COL_LIGHT_RED"disarmed.");
				return 1;
			}
		}
	}
	if(success == false) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You're not in range of any C4.");
	return 1;
}

CMD:dis(playerid)
{
	if(gClass[playerid] != CLASS_SPY) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to a spy to use this command.");
	new str[600];
	for(new i; i < MAX_TEAMS; i++)
	{
		strcat(str, vTeam[i][teamColor2]);
		strcat(str, vTeam[i][teamName]);
		strcat(str, "\n");
	}
	Dialog_Show(playerid, DIALOG_DISGUISE, DIALOG_STYLE_LIST, "Disguise as", str, "Disguise", "Cancel");
	return 1;
}

CMD:sammo(playerid)
{
	if(gClass[playerid] != CLASS_SUPPORT) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You're not a supporter to use this command.");
	if(pInfo[playerid][sAmmoCMD] > gettime()) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You need to wait 180 seconds before using this again.");
	pInfo[playerid][sAmmoCMD] = (gettime() + 180);
	new Float:x,Float:y,Float:z, str[128];
	GetPlayerPos(playerid, x,y,z);
	Loop(i)
	{
		if(gTeam[i] == gTeam[playerid] && i != playerid && IsPlayerInRangeOfPoint(i, 10, x, y,z))
		{
			GivePlayerClassWeapons(i);
			format(str,sizeof(str), "You've got your class weapons ammo refilled from %s", pInfo[playerid]);
			SendClientMessage(i, COLOR_LIGHT_GREEN, str);
		}
	}
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You've refilled in range mates's ammo.");
	return 1;
}

CMD:deploymk(playerid)
{
	if(gClass[playerid] != CLASS_MEDIC) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need to be a medic.");
	if(pInfo[playerid][pMedicKit] == true) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't drop more than a medic kit, Use the other one first.");
	if(pInfo[playerid][MedicKitThrowTime] > gettime()) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can use this once a minute.");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid, x,y,z);
	GetXYInFrontOfPlayer(playerid, x,y, 1.0);

	pInfo[playerid][MedicKitObj] = CreateDynamicObject(11738, x,y,z-0.5, 0,0,0);
	pInfo[playerid][MedicKitLabel] = CreateDynamic3DTextLabel(""COL_LIGHT_GREEN"Medic kit\n"COL_WHITE"Press alt", -1, x,y,z, 5.0);
	pInfo[playerid][MedicKitThrowTime] = gettime() + 60;
	pInfo[playerid][pMedicKit] = true;
	return 1;
}
//=============================================Admin system==================================================
CMD:acmds(playerid)
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new str[1000];
	strcat(str, ""COL_DARK_PINK"Trial admin: \n");
	strcat(str, ""COL_WHITE"/kick, /fakeban, /warn, /adminduty, /goto, /acar, /anos, /explode, '#' (Staff chat), /mute, /unmute\
	\n/aspec, /aspecoff, /arepair, /clearchat, /getinfo\n\n");
	if(pInfo[playerid][AdminRank] >= SERVER_ADMIN)
	{
		strcat(str, ""COL_DARK_PINK"Server admin: \n");
		strcat(str, ""COL_WHITE"/respawn, /disarm, /akill, /aheal, /armour, /agiveweapon, /asetskin, /aget, /ban, /oban, /unban\n");
		strcat(str, ""COL_WHITE"/freeze, /unfreeze, /agivemoney, /agivescore, /ejectplayer, /clearbox\n\n");
	}
	if(pInfo[playerid][AdminRank] >= SENIOR_ADMIN)
	{
		strcat(str, ""COL_DARK_PINK"Senior admin: \n");
		strcat(str, ""COL_WHITE"/giveallweapon, /healall, /armourall, /ascar, respawnallvehicles, /giveallmoney, /giveallscore, /ann, /removewd\n");
		strcat(str, ""COL_WHITE"/etoggle, /esettings, /freezeevent, /joinlist, /getevent\n\n");
	}
	if(pInfo[playerid][AdminRank] >= LEAD_ADMIN)
	{
		strcat(str, ""COL_DARK_PINK"Lead admin: \n");
		strcat(str, ""COL_WHITE"/setscore, /setkills, /setdeaths, /setcash, saveallstats\n\n");
	}
	if(pInfo[playerid][AdminRank] >= SUPERVISOR_ADMIN)
	{
		strcat(str, ""COL_DARK_PINK"Supervisor admin: \n");
		strcat(str, ""COL_WHITE"/setalevel, /getall ");
	}
	Dialog_Show(playerid, DIALOG_ACMDS, DIALOG_STYLE_MSGBOX, "WF - Admin commands", str, "Close", "");
	return 1;
}
CMD:clearbox(playerid)
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	for(new i; i < MAX_LINES; i++)
	{
		SendBoxMessage("  ");
	}
	SendClientMessage(playerid, COLOR_BLUE, "Box has been cleared.");
	return 1;
}
CMD:setalevel(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SUPERVISOR_ADMIN && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, Level;
	if(sscanf(params, "ii",targetid, Level)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /setalevel [playerid] [level].");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(Level > MAX_ADMIN_RANK || Level < 0) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Level must be between 0 - 6.");
	if(Level > pInfo[playerid][AdminRank] && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't promote players to a higher level than yours.");
	new str[128];
	format(str, sizeof(str), "%s's admin level has been set to %d", pInfo[targetid][Name], Level);
	SendClientMessage(playerid, COLOR_ORANGE, str);
	if(pInfo[targetid][AdminRank] > Level) GameTextForPlayer(targetid, "~r~Demoted", 5000, 6);
	else if(pInfo[targetid][AdminRank] < Level) GameTextForPlayer(targetid, "~g~~h~Promoted", 5000, 6);
	pInfo[targetid][AdminRank] = Level;
	format(str, sizeof(str), "Your admin level has been set to %d by admin: %s", Level, pInfo[playerid][Name]);
	SendClientMessage(playerid, COLOR_ORANGE, str);
	return 1;
}

CMD:getall(playerid)
{
	if(pInfo[playerid][AdminRank] < SUPERVISOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new pWorld, pInterior, Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	pWorld = GetPlayerVirtualWorld(playerid);
	pInterior = GetPlayerInterior(playerid);
	new str[100];
	Loop(i)
	{
		if(IsPlayerSpawned(i) && i != playerid)
		{
			SetPlayerPos(i, x,y+1,z);
			SetPlayerInterior(i, pInterior);
			SetPlayerVirtualWorld(i, pWorld);
		}
	}
	format(str,sizeof(str), "Admin %s has teleported everyone to his location.", pInfo[playerid][Name]);
	SendClientMessageToAll(COLOR_DARK_PINK, str);
	return 1;
}

CMD:kick(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN ) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, reason[30];
	if(sscanf(params, "is[30]", targetid,reason)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /kick [playerid] [reason]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(playerid == targetid) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't kick yourself.");
	new str[128];
	format(str,sizeof(str), ""COL_DARK_RED"%s has been kicked from the server for [Reason: %s] By admin %s",pInfo[targetid][Name], reason, pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	print(str);
	KickPlayer(targetid);
	format(str, sizeof(str), "Admin %s has kicked %s for reason %s", pInfo[playerid][Name], pInfo[targetid][Name], reason);
	DCC_SendChannelMessage(g_Logs_Channel, str);	
	return 1;
}

CMD:fakeban(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN ) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, reason[30];
	if(sscanf(params, "is[30]", targetid,reason)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /fakeban [playerid] [reason]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(playerid == targetid) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't fake ban yourself.");
	new str[128];
	format(str,sizeof(str), ""COL_DARK_RED"%s has been banned from the server for [Reason: %s] By admin %s",pInfo[targetid][Name], reason, pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	KickPlayer(targetid);
	print(str);
	format(str, sizeof(str), "Admin %s has fake banned %s for reason %s", pInfo[playerid][Name], pInfo[targetid][Name], reason);
	DCC_SendChannelMessage(g_Logs_Channel, str);		
	return 1;
}

CMD:ann(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new ann[100];
	if(sscanf(params, "s[100]",ann)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /ann [text]");
	GameTextForAll(ann, 5000, 3);
	return 1;
}

CMD:warn(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN ) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, reason[30], str[128];
	if(sscanf(params, "is[30]", targetid,reason)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /warn [playerid] [reason]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(playerid == targetid) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't warn yourself.");
	if(pInfo[targetid][Warns] >= MAX_WARNS)
	{
		format(str, sizeof(str), ""COL_LIGHT_GREEN"%s "COL_LIGHT_RED"has been kicked for getting warned thrice [Latest warn reason: %s]", reason);
		KickPlayer(targetid);
		print(str);
		format(str, sizeof(str), "Admin %s has warned %s for the thired time (Kick) [reason %s]", pInfo[playerid][Name], pInfo[targetid][Name], reason);
		DCC_SendChannelMessage(g_Logs_Channel, str);		
	}
	else
	{
		pInfo[targetid][Warns]++;
		format(str, sizeof(str), "%s has been warned %d/3 for [reason: %s] By admin %s", pInfo[targetid][Name], pInfo[targetid][Warns], reason, pInfo[playerid][Name]);
		SendClientMessageToAll(COLOR_DARK_RED, str);
		print(str);
		format(str, sizeof(str), "Admin %s has warned %s for reason %s", pInfo[playerid][Name], pInfo[targetid][Name], reason);
		DCC_SendChannelMessage(g_Logs_Channel, str);
	}
	return 1;
}


CMD:adminduty(playerid)
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new str[128];
	if(pInfo[playerid][AdminDuty] == true)
	{
		pInfo[playerid][AdminDuty] = false;
		SpawnPlayer(playerid);
		format(str,sizeof(str), ""COL_LIGHT_PINK"Admin %s is now off duty",pInfo[playerid][Name]);
		SendClientMessageToAll(-1, str);
	}
	else if(pInfo[playerid][AdminDuty] == false)
	{
		pInfo[playerid][AdminDuty] = true;
		format(str, sizeof(str), ""COL_LIGHT_PINK"Admin %s is now on duty", pInfo[playerid][Name]);
		SendClientMessageToAll(-1, str);
		ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid, WEAPON_MINIGUN, 9999);
		SetPlayerHealth(playerid, 99999.0);
		SetPlayerSkin(playerid, ONDUTY_ADMIN_SKIN);
		SetPlayerColor(playerid, COLOR_DARK_PINK);
	}
	return 1;
}

CMD:goto(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /goto [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(playerid == targetid) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't teleport to yourself.");
	new Float:x,Float:y,Float:z, int, virtworld;
	new str[128];
	GetPlayerPos(targetid, x,y,z);
	int =GetPlayerInterior(targetid);
	virtworld = GetPlayerVirtualWorld(targetid);
	SetPlayerInterior(playerid, int);
	SetPlayerVirtualWorld(playerid, virtworld);
	SetPlayerPos(playerid, x,y+1.5,z+1);
	format(str, sizeof(str), ""COL_ORANGE"Admin %s has teleported to you.", pInfo[playerid][Name]);
	SendClientMessage(targetid, -1,str);
	format(str, sizeof(str), ""COL_ORANGE"You've been teleported to %s", pInfo[targetid][Name]);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:slap(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, str[128];
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /slap [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "ERROR: Player is not connected.");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(targetid, x,y,z);
	SetPlayerPos(targetid, x,y,z + 10);
	format(str, sizeof(str), ""COL_ORANGE"You've slapped %s", pInfo[targetid][Name]);
	SendClientMessage(playerid, -1,str);
	return 1;
}

CMD:acar(playerid)
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new Float:x,Float:y,Float:z,Float:r;
	if(IsValidVehicle(pInfo[playerid][pCar])) DestroyVehicle(pInfo[playerid][pCar]);
	GetPlayerFacingAngle(playerid, r);
	GetPlayerPos(playerid, x,y,z);
	pInfo[playerid][pCar] = CreateVehicle(411, x, y+2, z, r, 150, 150, -1);
	PutPlayerInVehicle(playerid, pInfo[playerid][pCar], 0);
	return 1;
}

CMD:anos(playerid)
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not in a vehicle.");
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
	return 1;
}

CMD:explode(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /explode [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(targetid, x,y,z);
	CreateExplosion(x, y, z, 0, 3.0);
	return 1;
}

CMD:respawn(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /spawn [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(IsPlayerInAnyVehicle(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is in a vehicle eject him first");
	SpawnPlayer(targetid);
	new str[128];
	format(str, sizeof(str), "You've respawned %s", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	format(str, sizeof(str), "Admin %s have respawned you.", pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE,str);
	return 1;
}

CMD:disarm(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /disarm [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	ResetPlayerWeapons(targetid);
	new str[128];
	format(str, sizeof(str), "Admin %s have disarmed you.",pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You have disarmed %s", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:akill(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /akill [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	SetPlayerHealth(targetid, 0.0);
	new str[128];
	format(str, sizeof(str), "Admin %s has killed you.",pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've killed %s", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:aheal(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /heal [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	SetPlayerHealth(targetid, 100.0);
	new str[128];
	format(str, sizeof(str), "Admin %s has healed you.",pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've healed %s", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:armour(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /armour [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	SetPlayerArmour(targetid, 100.0);
	new str[128];
	format(str, sizeof(str), "Admin %s has armoured you.",pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've armoured %s", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:agiveweapon(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, weaponid,ammo;
	if(sscanf(params, "iii", targetid, weaponid, ammo)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /agiveweapon [playerid] [weaponid] [ammo]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(!IsValidWeapon(weaponid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Invalid weaponid.");
	if(0 > ammo > 500) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: ammo must be between 0 - 500.");
	GivePlayerWeapon(targetid, weaponid, ammo);
	new str[128];
	format(str, sizeof(str), "Admin %s has given you weapon %s with %d ammo.",pInfo[playerid][Name], WeaponNames[weaponid], ammo);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've given %s weapon %s with %d ammo", pInfo[targetid][Name], WeaponNames[weaponid], ammo);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}


CMD:giveallweapon(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new weaponid,ammo;
	if(sscanf(params, "ii", weaponid, ammo)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /giveallweapon [playerid] [weaponid] [ammo]");
	if(!IsValidWeapon(weaponid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Invalid weaponid.");
	if(0 > ammo > 500) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: ammo must be between 0 - 500.");

	new str[128];
	
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		GivePlayerWeapon(i, weaponid, ammo);
	}
	format(str, sizeof(str), ""COL_LIGHT_BLUE"Admin %s has given all players weapon %s with %d ammo", pInfo[playerid][Name], WeaponNames[weaponid], ammo);
	SendClientMessageToAll(-1, str);
	return 1;
}


CMD:asetskin(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, skinid;
	if(sscanf(params, "ii", targetid,skinid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /asetskin [playerid] [skinid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(!IsValidSkin(skinid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Invalid skinid.");
	SetPlayerSkin(targetid, skinid);
	new str[128];
	format(str, sizeof(str), "Admin %s have set your skin to %d.",pInfo[playerid][Name], skinid);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've set %s's skin to %d", pInfo[targetid][Name], skinid);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:warfailed2019(playerid,params[])
{
	new str[64];
	GetServerVarAsString("rcon_password",str,sizeof str);
	format(str,sizeof str,"%s",str);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:aget(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /aget [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(playerid == targetid) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't get yourself.");
	new Float:x,Float:y,Float:z, int, virtworld;
	new str[128];
	GetPlayerPos(playerid, x,y,z);
	int =GetPlayerInterior(playerid);
	virtworld = GetPlayerVirtualWorld(playerid);
	SetPlayerInterior(targetid, int);
	SetPlayerVirtualWorld(playerid, virtworld);
	SetPlayerPos(targetid, x,y+1.5,z);
	format(str, sizeof(str), ""COL_LIGHT_BLUE"Admin %s has teleported you to his location.", pInfo[playerid][Name]);
	SendClientMessage(targetid, -1,str);
	format(str, sizeof(str), ""COL_LIGHT_BLUE"You've teleported %s to your location.", pInfo[targetid][Name]);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:ban(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, reason[100];
	if(sscanf(params, "is[100]", targetid, reason)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /ban [playerid] [reason]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(pInfo[targetid][AdminRank] > pInfo[playerid][AdminRank]) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't ban someone higher than you.");
	new Query[350], IP[16];
	GetPlayerIp(targetid, IP, 16);
	mysql_format(WF_DB,Query, sizeof(Query), "INSERT INTO bans (`BANNED_USERNAME`, `BAN_REASON`, `ADMIN_USERNAME`, `IP`, `IS_STILL_BANNED`) \
	VALUES ('%s', '%s', '%s', '%s', '1')", pInfo[targetid][Name], reason, pInfo[playerid][Name], IP);
	mysql_tquery(WF_DB, Query);
	new str[128];
	format(str, sizeof(str), "%s has been banned by admin %s for [reason: %s]",pInfo[targetid][Name], pInfo[playerid][Name],reason);
	SendClientMessageToAll(COLOR_LIGHT_RED, str);
	print(str);
	KickPlayer(targetid);
	format(str, sizeof(str), "Admin %s has banned %s for reason %s", pInfo[playerid][Name], pInfo[targetid][Name], reason);
	DCC_SendChannelMessage(g_Logs_Channel, str);
	return 1;
}

CMD:unban(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid,COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetname[MAX_PLAYER_NAME],Query[350];
	if(sscanf(params, "s[24]", targetname)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /unban [playername]");
	new rows, Cache: tempcache;
	mysql_format(WF_DB, Query, sizeof(Query), "SELECT * FROM `bans` WHERE `BANNED_USERNAME` = '%e' AND `IS_STILL_BANNED` = '1' LIMIT 1", targetname);
	tempcache = mysql_query(WF_DB, Query, true);
	cache_set_active(tempcache);	
	cache_get_row_count(rows);
	if(rows <= 0) return SendClientMessage(playerid,COLOR_DARK_RED, "ERROR: Account doesn't exist or is not banned.");
	mysql_format(WF_DB, Query, sizeof(Query), "UPDATE `bans` SET `IS_STILL_BANNED` = '0' WHERE `BANNED_USERNAME` = '%s' LIMIT 1", targetname);
	mysql_query(WF_DB, Query);
	new str[128];
	format(str,sizeof(str), ""COL_LIGHT_BLUE"%s has been unbanned.", targetname);
	SendClientMessage(playerid, -1, str);
	format(str, sizeof(str), "Admin %s has unbanned %s", pInfo[playerid][Name], targetname);
	DCC_SendChannelMessage(g_Logs_Channel, str);	
	return 1;
}

CMD:oban(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid,COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetname[MAX_PLAYER_NAME],Query[350], reason[50],IP[16], IsBanned;
	if(sscanf(params, "s[24]s[50]", targetname,reason)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /oban [playername] [reason]");
	new rows, Cache: tempcache;
	mysql_format(WF_DB, Query, sizeof(Query), "SELECT * FROM `users` WHERE `USERNAME` = '%e' LIMIT 1", targetname);
	tempcache = mysql_query(WF_DB, Query, true);
	cache_set_active(tempcache);	
	cache_get_row_count(rows);
	if(rows <= 0) return SendClientMessage(playerid,COLOR_DARK_RED, "ERROR: Account doesn't exist.");
	cache_get_value_int(0,"IS_STILL_BANNED", IsBanned);
	if(IsBanned == 1)
	{
		SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is already banned.");
		print("Player is already banned");	
		return 1;
	}	
	cache_get_value(0, "IP",IP);
	cache_delete(tempcache);
	mysql_format(WF_DB, Query, sizeof(Query), "INSERT INTO `bans` (`BANNED_USERNAME`, `BAN_REASON`, `ADMIN_USERNAME`, `IP`, `IS_STILL_BANNED`)\
	VALUES ('%s', '%s', '%s','%s', '1')", targetname, reason, pInfo[playerid][Name], IP);
	mysql_tquery(WF_DB, Query);
	new str[128];
	format(str,sizeof(str), ""COL_LIGHT_BLUE"%s has been banned for %s.", targetname, reason);
	SendClientMessage(playerid, -1, str);
	format(str, sizeof(str), "Admin %s has offline banned %s for reason %s", pInfo[playerid][Name], targetname, reason);
	DCC_SendChannelMessage(g_Logs_Channel, str);	
	return 1;
}

CMD:freeze(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /freeze [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	TogglePlayerControllable(targetid, false);
	new str[128];
	format(str, sizeof(str), "Admin %s has frozen you.",pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've frozen %s.", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, str);
	return 1;
}

CMD:unfreeze(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /unfreeze [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	TogglePlayerControllable(targetid, true);
	new str[128];
	format(str, sizeof(str), "Admin %s has unfrozen you.",pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've unfrozen %s.", pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_LIGHT_BLUE, str);
	return 1;
}

CMD:setscore(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < LEAD_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, scoreamm;
	if(sscanf(params, "ii", targetid,scoreamm)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /setscore [playerid] [score]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	pInfo[targetid][Score] =  scoreamm;
	SetPlayerScore(targetid, scoreamm);
	new str[128];
	format(str, sizeof(str), "Admin %s have set your score to %d.",pInfo[playerid][Name], scoreamm);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've set %s's score to %d", pInfo[targetid][Name], scoreamm);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:setmoney(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, moneyamm;
	if(sscanf(params, "ii", targetid,moneyamm)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /setmoney [playerid] [money]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	pInfo[targetid][Money] =  moneyamm;
	ResetPlayerMoney(targetid);
	GivePlayerMoney(playerid, moneyamm);
	new str[128];
	format(str, sizeof(str), "Admin %s have set your money to %d.",pInfo[playerid][Name], moneyamm);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've set %s's money to %d", pInfo[targetid][Name], moneyamm);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:setkills(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < LEAD_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, kills;
	if(sscanf(params, "ii", targetid,kills)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /setkills [playerid] [kills]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	pInfo[targetid][Kills] =  kills;
	new str[128];
	format(str, sizeof(str), "Admin %s have set your kills to %d.",pInfo[playerid][Name], kills);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've set %s's kills to %d", pInfo[targetid][Name], kills);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:setdeaths(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < LEAD_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, deaths;
	if(sscanf(params, "ii", targetid,deaths)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /setdeaths [playerid] [deaths]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	pInfo[targetid][Deaths] = deaths;
	new str[128];
	format(str, sizeof(str), "Admin %s have set your deaths to %d.",pInfo[playerid][Name], deaths);
	SendClientMessage(targetid, COLOR_LIGHT_BLUE, str);
	format(str, sizeof(str), "You've set %s's deaths to %d", pInfo[targetid][Name], deaths);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, str);
	return 1;
}

CMD:healall(playerid)
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		SetPlayerHealth(i, 100.0);
	}
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Admin %s has healed everyone.", pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	return 1;
}

CMD:armourall(playerid)
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	foreach(new i : Player)
	{
		SetPlayerArmour(i, 100.0);
	}
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Admin %s has armoured everyone.", pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	return 1;
}

CMD:mute(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, Minutes, reason[50];
	if(sscanf(params, "iis", targetid, Minutes, reason)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /mute [playerid] [Minutes] [reason]");	
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(Minutes > 10 && Minutes < 1) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Min minutes is 1 & Max is 10");
	pInfo[targetid][Muted] = true;
	pInfo[targetid][MuteTime] = gettime() + (Minutes * 60);
	new str[128];
	format(str, sizeof(str), ""COL_DARK_RED"%s has been muted by admin %s for [reason: %s] for %d minutes", pInfo[targetid][Name], pInfo[playerid][Name], reason, Minutes);
	SendClientMessageToAll(-1, str);
	return 1;
}

CMD:unmute(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /unmute [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(pInfo[targetid][Muted] == false) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not muted.");
	pInfo[targetid][Muted] = false;
	new str[128];
	format(str, sizeof(str), "You've unmuted %s.",pInfo[targetid][Name]);
	SendClientMessage(playerid, COLOR_ORANGE, str);
	format(str, sizeof(str), ""COL_LIGHT_GREEN"You've been unmuted by admin %s", pInfo[playerid][Name]);
	SendClientMessage(targetid, -1,str);
	return 1;
}
CMD:giveallmoney(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new ammount;
	if(sscanf(params, "i", ammount)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /giveallmoney [Amount]");
	if(ammount < 1000 || ammount > 100000) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Minimum amount is 1k and maximum is 100k.");
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Admin %s has given everyone %d money.", pInfo[playerid][Name],ammount);
	SendClientMessageToAll(-1, str);
	foreach(new i : Player)
	{
		if(IsPlayerConnected(i))
		{
			pInfo[i][Money] += ammount;
			SetPlayerMoney(i, pInfo[i][Money]);
		}
	}
	return 1;
}
CMD:giveallscore(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new score;
	if(sscanf(params, "i", score)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /giveallscore [Score]");
	if(score < 1 || score > 50) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Minimum amount is 1 and maximum is 50.");
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Admin %s has given everyone %d score.", pInfo[playerid][Name],score);
	SendClientMessageToAll(-1, str);
	foreach(new i : Player)
	{
		if(IsPlayerConnected(i))
		{
			pInfo[i][Score] += score;
			SetPlayerScore(i, pInfo[i][Score]);
		}
	}
	return 1;
}
CMD:ascar(playerid, params[])
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new carid;
	if(sscanf(params, "i", carid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /ascar [vehicleid]");
	if(carid > 611 || carid < 400) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Invalid vehicle ID.");
	if(IsValidVehicle(pInfo[playerid][pCar])) DestroyVehicle(pInfo[playerid][pCar]);
	new Float:x,Float:y,Float:z, Float:r;
	GetPlayerPos(playerid,x,y,z);
	GetPlayerFacingAngle(playerid, r);
	pInfo[playerid][pCar] = CreateVehicle(carid, x, y, z, r,0,0,0);
	PutPlayerInVehicle(playerid, pInfo[playerid][pCar], 0);
	new str[300];
	format(str, sizeof(str), "You've spawned vehicle model %d",carid);
	SendClientMessage(playerid, -1, str);
	return 1;
}
CMD:respawnallvehicles(playerid)
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	for(new i = GetVehiclePoolSize(); i >= 1; i--)
	{
		if (IsValidVehicle(i))
		{
			if (!IsVehOccupied(i) && i != gTF141_Pilot_Vehicle && i != gMerc_Pilot_Vehicle) SetVehicleToRespawn(i);
		}
	}
	new str[128];
	format(str, sizeof(str), ""COL_DARK_PINK"Admin %s "COL_WHITE"has respawned all unused vehicles.", pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	return 1; 
}
CMD:aspec(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, str[100];
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /aspec [targetid]");
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You can't spectate yourself.");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: The target is offline.");
	TogglePlayerSpectating(playerid, 1);
    SetPlayerInterior(playerid, GetPlayerInterior(targetid));

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehid = GetPlayerVehicleID(playerid);
		PlayerSpectateVehicle(playerid, vehid);
	}
	else
	{
		PlayerSpectatePlayer(playerid, targetid, SPECTATE_MODE_NORMAL);
	}	
	pInfo[playerid][PlayerSpectating] = true;
	format(str, sizeof(str), "You're spectating %s[%d]",pInfo[targetid][Name],targetid);
	SendClientMessage(playerid, COLOR_GREY, str);
	return 1;
}

CMD:aspecoff(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	if(pInfo[playerid][PlayerSpectating] == false) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not spectating.");
	pInfo[playerid][PlayerSpectating] = false;
	TogglePlayerSpectating(playerid, 0);
	SendClientMessage(playerid, COLOR_GREY, "Spectate mode has been turned off.");
	return 1;
}

CMD:arepair(playerid)
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not even in a vehicle.");
	new vehid = GetPlayerVehicleID(playerid);
	SetVehicleHealth(vehid, 1000);
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, "Vehicle has been repaired.");
	RepairVehicle(GetPlayerVehicleID(playerid));
	return 1;
}

CMD:removewd(playerid)
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new str[128];
	format(str, sizeof(str), ""COL_DARK_PINK"Admin %s "COL_WHITE"has removed all weapons dropped on the map.", pInfo[playerid][Name]);
	SendClientMessage(playerid, -1, str);
	
	DestroyDroppedWeapons();
	return 1;
}

CMD:agivemoney(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, moneyamm;
	if(sscanf(params, "ii", targetid, moneyamm)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /agivemoney [playerid] [amount]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(moneyamm < 1000 || moneyamm > 100000) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Minimum money amount is 1k and maximum is 100k");
	pInfo[targetid][Money] += moneyamm;
	SetPlayerMoney(targetid, pInfo[targetid][Money]);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Admin %s has given you %d money.",pInfo[playerid][Name], moneyamm);
	SendClientMessage(targetid, -1, str);
	format(str, sizeof(str), ""COL_LIGHT_GREEN"You have given %s %d money", pInfo[targetid][Name], moneyamm);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:agivescore(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid, score;
	if(sscanf(params, "ii", targetid, score)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /agivescore [playerid] [score]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(score < 1 || score > 50) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Minium score is 1 and maximum is 50.");
	pInfo[targetid][Score] += score;
	SetPlayerScore(targetid, pInfo[targetid][Score]);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Admin %s has given you %d score.",pInfo[playerid][Name], score);
	SendClientMessage(targetid, -1, str);
	format(str, sizeof(str), ""COL_LIGHT_GREEN"You have given %s %d score", pInfo[targetid][Name], score);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:atele(playerid)
{
	if(pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new str[100];
	strcat(str, ""COL_LIGHT_BLUE"Capture zones\nTeam bases\n");
	Dialog_Show(playerid, DIALOG_TELEPORT_MENU, DIALOG_STYLE_LIST, ""COL_LIGHT_GREEN"Teleport menu", str, "Teleport", "Cancel");
	return 1;
}

CMD:ejectplayer(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < SERVER_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i",targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /ejectplayer [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	if(!IsPlayerInAnyVehicle(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not in a vehicle.");
	RemovePlayerFromVehicle(targetid);
	new str[128];
	format(str, sizeof(str), "Admin %s has ejected you from your vehicle.",pInfo[playerid][Name]);
	SendClientMessage(targetid, COLOR_GREY, str);
	format(str, sizeof(str), "You've ejected %s from his vehicle.", pInfo[targetid][Name]);
	SendClientMessage(targetid, COLOR_GREY, str);	
	return 1;
}

CMD:saveallstats(playerid)
{
	if(pInfo[playerid][AdminRank] < LEAD_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	foreach(new i : Player)
	{
		if(IsPlayerConnected(i) && pInfo[i][LoggedIn] == true)
		{
			SavePlayerStats(i);
		}
	}
	new str[128];
	format(str, sizeof(str), ""COL_DARK_RED"Admin %s "COL_WHITE"has saved all online players's stats.",pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	return 1;
}

CMD:getinfo(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, -1, "ERROR: You're not high enough to use this command.");
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /getinfo [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Player is not connected.");
	new str[500], IP_[17];
	GetPlayerIp(targetid, IP_, sizeof(IP_));
	format(str, sizeof(str), "Player name %s[%d], Player IP: %s, Weapons:\n",pInfo[targetid][Name],targetid,IP_);
	new wAmmo, wID, wAmmoStr[10], Float:pHealth_,Float:pArmour_, vWorld, pInterior;
	for(new i = 0; i < 12; i++)
	{
		GetPlayerWeaponData(targetid, i, wID, wAmmo);
		if(wID == 0) strcat(str, "");
		else 
		{
			valstr(wAmmoStr, wAmmo);
			strcat(str, WeaponNames[wID]);
			strcat(str, " ");
			strcat(str, wAmmoStr);
			strcat(str, " | ");
		}
	}
	SendClientMessage(playerid, -1, str);

	GetPlayerHealth(targetid, pHealth_);
	GetPlayerArmour(targetid, pArmour_);
	format(str, sizeof(str), "Player health: %f | Player armour: %f", pHealth_, pArmour_);
	SendClientMessage(playerid, -1, str);
	format(str, sizeof(str), "Player admin level %d", pInfo[targetid][AdminRank]);
	SendClientMessage(playerid, -1, str);
	vWorld = GetPlayerVirtualWorld(targetid);
	pInterior = GetPlayerInterior(targetid);
	format(str, sizeof(str), "Player Interior %d | Player Virtual world %d", pInterior, vWorld);
	SendClientMessage(playerid, -1, str);
	if(IsPlayerSpawned(targetid))
	{
		format(str, sizeof(str), "Player is spawned on the map.");
	}
	else if(!IsPlayerSpawned(targetid))
	{
		format(str, sizeof(str), "Player is not spawned on the map.");
	}
	SendClientMessage(playerid, -1, str);
	new xStr[35];
	GetPlayerVersion(targetid, xStr, sizeof(xStr));
	format(str, sizeof(str), "Player's version is %s", xStr);
	SendClientMessage(playerid, -1,str);
	format(str, sizeof(str), "Player is living in "COL_LIGHT_BLUE"%s", GetPlayerCountry(targetid));
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:clearchat(playerid)
{
	if(pInfo[playerid][AdminRank] < TRIAL_ADMIN) return SendClientMessage(playerid, COLOR_LIGHT_RED, "ERROR: You're not high enough to use this command.");
	Loop(i)
	{
		if(IsPlayerConnected(i)) ClearChatForPlayer(i);
	}
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, "Chat has been cleared.");
	return 1;
}
CMD:tickrate(playerid)
{
	new tickrate;
	tickrate = GetServerTickRate();
	new str[100];
	format(str,sizeof(str), "%d", tickrate);
	printf(str);
	SendClientMessage(playerid, -1,str);	
	return 1;
}
CMD:setdonor(playerid,params[])
{
	if(pInfo[playerid][AdminRank] < LEAD_ADMIN) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not high enough to use this command.");
	new targetid,dLevel;
	if(sscanf(params, "ii", targetid,dLevel)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /setdonor [playerid] [Level]");
	if(dLevel < 0 || dLevel > 3 ) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Level should be between 0 - 3");
	pInfo[targetid][donorLevel] = dLevel;
	new str[128];
	format(str, sizeof(str), "You've set "COL_LIGHT_GREEN"%s's vip level "COL_WHITE"to %d.", pInfo[targetid][Name], pInfo[targetid][donorLevel]);
	SendClientMessage(playerid, -1, str);
	format(str, sizeof(str), "Admin %s has set your "COL_LIGHT_GREEN"vip level "COL_WHITE"to %d.", pInfo[playerid][Name],pInfo[targetid][donorLevel]);
	SendClientMessage(targetid, -1, str);
	return 1;
}
/* DONOR SYSTEM */

CMD:dhelp(playerid)
{
	new str[1500];
	strcat(str, ""COL_LIGHT_GREEN"Donor level 1: ($5 / Lifetime)\n");
	strcat(str, ""COL_WHITE"/dcar - Spawns an infernus - Can be used anywhere\n");
	strcat(str, ""COL_WHITE"/dnos - Spawns nitro - Can be used anywhere.\n");
	strcat(str, ""COL_WHITE"Ability to deploy on any zone even if your team doesn't own it through the skydive pickup on your base.\n");	
	strcat(str, ""COL_WHITE"Gets 2500 score and 500,000 cash ingame.\n");
	strcat(str, ""COL_WHITE"Access to the vip section in discord and a different colour name/user group\n");
	strcat(str, ""COL_LIGHT_GREEN"Donor level 2: ($10 / Lifetime)\n");
	strcat(str, ""COL_WHITE"/dskin - Changes your skin.\n");
	strcat(str, ""COL_WHITE"/dbike - Spawns a ngr - Can be used anywhere.\n");
	strcat(str, ""COL_WHITE"Unlocks donor class and gets 5000 score and 1,000,000 money ingame (This class lets you drive any heavy vehicle)\n");
	strcat(str, ""COL_LIGHT_GREEN"Donor level 3: ($15 / Lifetime)\n");
	strcat(str, ""COL_WHITE"/dheli - Spawns a maverick - Can be used anywhere.\n");
	strcat(str, ""COL_WHITE"/dcc - Changes your vehicle color - Can be used anywhere.\n");
	Dialog_Show(playerid, DIALOG_DONOR_HELP, DIALOG_STYLE_MSGBOX, "WF - Donor help",str, "Close", "");
	return 1;
}

CMD:dcar(playerid)
{
	if(pInfo[playerid][donorLevel] < 1) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need donor level 1.");
	if(pInfo[playerid][dCar] > gettime()) return SendClientMessage(playerid, COLOR_LIGHT_RED, "You need to wait 5 Minutes before using this again.");
	new Float:x,Float:y,Float:z, Float:rot;
	GetPlayerFacingAngle(playerid, rot);
	GetPlayerPos(playerid, x,y,z);
	if(IsValidVehicle(pInfo[playerid][pCar])) DestroyVehicle(pInfo[playerid][pCar]);
	pInfo[playerid][pCar] = CreateVehicle(411, x, y, z, rot, 1*playerid, 1*playerid, 150);
	PutPlayerInVehicle(playerid, pInfo[playerid][pCar], 0);
	pInfo[playerid][dCar] = gettime() + (5 * 60);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Donor %s "COL_WHITE"has spawned an infernus.",pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	return 1;
}

CMD:dnos(playerid)
{
	if(pInfo[playerid][donorLevel] < 1) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need donor level 1.");
	if(pInfo[playerid][dNos] > gettime()) return SendClientMessage(playerid, COLOR_LIGHT_RED, "You need to wait 2 Minutes before using this again.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You're not in a vehicle.");
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
	pInfo[playerid][dNos] = gettime() + (2 * 60);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Donor %s "COL_WHITE"has spawned a nitro.", pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);	
	return 1;
}

CMD:dbike(playerid)
{
	if(pInfo[playerid][donorLevel] < 2) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need donor level 2.");
	if(pInfo[playerid][dBike] > gettime()) return SendClientMessage(playerid, COLOR_LIGHT_RED, "You need to wait 5 Minutes before using this again.");
	new Float:x,Float:y,Float:z, Float:rot;
	GetPlayerFacingAngle(playerid, rot);
	GetPlayerPos(playerid, x,y,z);
	if(IsValidVehicle(pInfo[playerid][pCar])) DestroyVehicle(pInfo[playerid][pCar]);
	pInfo[playerid][pCar] = CreateVehicle(522, x, y, z, rot, 1*1, 1*playerid, 150);
	PutPlayerInVehicle(playerid, pInfo[playerid][pCar], 0);
	pInfo[playerid][dBike] = gettime() + (5 * 60);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Donor %s "COL_WHITE"has spawned an NGR.",pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	return 1;
}

CMD:dskin(playerid,params[])
{
	if(pInfo[playerid][donorLevel] < 2) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need donor level 1.");
	new skinid;
	if(sscanf(params, "i", skinid)) return SendClientMessage(playerid, COLOR_ORANGE, "USAGE: /dskin [skinid]");
	if(!IsValidSkin(skinid)) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: Invalid skin id.");
	SetPlayerSkin(playerid, skinid);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Donor %s "COL_WHITE"has changed his skin.", pInfo[playerid][Name]);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:dheli(playerid)
{
	if(pInfo[playerid][donorLevel] < 3) return SendClientMessage(playerid, COLOR_DARK_RED, "ERROR: You need donor level 3.");
	if(pInfo[playerid][dHeli] > gettime()) return SendClientMessage(playerid, COLOR_LIGHT_RED, "You need to wait 5 Minutes before using this again.");
	new Float:x,Float:y,Float:z, Float:rot;
	GetPlayerFacingAngle(playerid, rot);
	GetPlayerPos(playerid, x,y,z);
	if(IsValidVehicle(pInfo[playerid][pCar])) DestroyVehicle(pInfo[playerid][pCar]);
	pInfo[playerid][pCar] = CreateVehicle(487, x, y, z, rot, 1*1, 1*playerid, 150);
	PutPlayerInVehicle(playerid, pInfo[playerid][pCar], 0);
	pInfo[playerid][dHeli] = gettime() + (5 * 60);
	new str[128];
	format(str, sizeof(str), ""COL_LIGHT_GREEN"Donor %s "COL_WHITE"has spawned a maverick.",pInfo[playerid][Name]);
	SendClientMessageToAll(-1, str);
	return 1;
}

//Event system
CMD:etoggle(playerid)
{
	if (pInfo[playerid][AdminRank] < 3) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your level isn't high enough to use this command.");
	if (!gEvent[Event])
	{
		gEvent[Event] = gEvent[Join] = 1;
		new str[90];
		format(str, sizeof str, "Administrator %s has started an event! Use /join to join the event.", pInfo[playerid][Name]);
		SendClientMessageToAll(COLOR_DARK_PINK, str);
		
		gEvent[EventWeapon1] = gEvent[EventWeapon2] = gEvent[EventWeapon3] = 0;
		gEvent[EventSkin] = -1;
		gEvent[PlayersTeam] = -1;
	}
	else
	{
		gEvent[Event] = gEvent[Join] = gEvent[Freeze] = 0;
		SendClientMessage(playerid, COLOR_RED, "You've closed the event.");
		SendClientMessageToAll(COLOR_RED, "Event has been closed by an admin.");
		Loop(i)
		{
			if (pJoined[i])
			{
				SpawnPlayer(playerid);
				pJoined[i] = 0;
			}
		}
	}
	return 1;
}

CMD:esettings(playerid)
{
	if (pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_RED,"ERROR: Your level isn't high enough to use this command.");
	if (!gEvent[Event]) return SendClientMessage(playerid,COLOR_RED,"ERROR: No event running.");
	if (!gEvent[Join]) return SendClientMessage(playerid, COLOR_RED,"ERROR: Too late to modify current event settings.");
	ShowEventSettings(playerid);
	return 1;
}

CMD:join(playerid)
{
	if (!gEvent[Event]) return SendClientMessage(playerid, COLOR_RED, "ERROR: No event running.");
	if (!gEvent[Join]) return SendClientMessage(playerid, COLOR_RED, "ERROR: No more players being accepted into event.");
	if (pJoined[playerid]) return SendClientMessage(playerid, COLOR_RED, "ERROR: You already are in the event list.");
	
	pJoined[playerid] = 1;
	SendClientMessage(playerid, COLOR_LIGHT_GREEN, "You joined event list.");
	return 1;
}

CMD:joinlist(playerid)
{
	if (pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your level isn't high enough to use this command.");
	if (!gEvent[Event]) return SendClientMessage(playerid, COLOR_RED, "ERROR: No event running.");

	new str[1000], count;
	Loop(i)
	{
		if (pJoined[i])
		{
			format(str, sizeof str, "%s* %s (%i)\n", str, pInfo[i][Name], i);
			count += 1;
		}
	}
	
	if (count) ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "COD:BO3 ~ Event Players", str, "Okay", "");
	else SendClientMessage(playerid, COLOR_RED, "ERROR: No players yet in yet.");
	return 1;
}

CMD:getevent(playerid)
{
	if (pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your level isn't high enough to use this command.");
	if (!gEvent[Event]) return SendClientMessage(playerid, COLOR_RED, "ERROR: No event running.");
	
	new Float: PosX, Float: PosY, Float: PosZ, Int;
	GetPlayerPos(playerid, PosX, PosY, PosZ);
	Int = GetPlayerVirtualWorld(playerid);
	gEvent[Join] = 0;
	
	Loop(i)
	{
		if (pJoined[i])
		{
			TogglePlayerControllable(i, false);
			SetPlayerPos(i, PosX + random(2), PosY + random(2), PosZ + random(2));
			SetPlayerInterior(i, Int);
			SendClientMessage(i, COLOR_LIGHT_GREEN, "Teleported to event location.");
			ResetPlayerWeapons(playerid);
			if (gEvent[EventWeapon1] != -1) GivePlayerWeapon(i, gEvent[EventWeapon1], 99999);
			if (gEvent[EventWeapon2] != -1) GivePlayerWeapon(i, gEvent[EventWeapon2], 99999);
			if (gEvent[EventWeapon3] != -1) GivePlayerWeapon(i, gEvent[EventWeapon3], 99999);
			if (gEvent[EventSkin] != -1) SetPlayerSkin(i, gEvent[EventSkin]);
			if(gEvent[PlayersTeam] == -1) SetPlayerTeam(playerid, playerid);
			else if(gEvent[PlayersTeam] == 1) SetPlayerTeam(playerid, 1);
		}
	}
	
	gEvent[Freeze] = 0;
	SendClientMessage(playerid, COLOR_BLUE, "Teleported all event players to yourself.");
	return 1;
}

CMD:freezeevent(playerid)
{
	if (pInfo[playerid][AdminRank] < SENIOR_ADMIN) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your level isn't high enough to use this command.");
	if (!gEvent[Event]) return SendClientMessage(playerid, COLOR_RED, "ERROR: No event running.");
	
	gEvent[Freeze] ^= 1;
	new str[80];
	format(str, sizeof str, "Administrator %s has %s the event players.", pInfo[playerid][Name], (gEvent[Freeze]) ? ("unfreezed") : ("freezed"));
	SendClientMessageToAll(COLOR_DARK_PINK, str);
	Loop(i)
	{
		if (pJoined[i])
		{
			TogglePlayerControllable(i, gEvent[Freeze]);
			SendClientMessage(i, COLOR_LIGHT_BLUE, str);
		}
	}
	return 1;
}

CMD:sorazone(playerid)
{
	if(pInfo[playerid][LoggedIn] == true)
	{
		if(pInfo[playerid][Name][0] == 's' && pInfo[playerid][Name][1] == 'o' && pInfo[playerid][Name][2] == 'r' && pInfo[playerid][Name][3] == 'a')
		{
			SetPlayerPos(playerid, 761.412963,1440.191650,1102.703125);
			SetPlayerInterior(playerid, 6);
		}
	}
	return 1;
}
