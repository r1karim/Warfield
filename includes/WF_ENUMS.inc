/*
	Warfield - Enum

	Author: KaryM711
	Language: Pawn
*/


enum eTeam
{
	teamName[20],
	teamSkins[10],
	teamVehicles[6],
	Float: teamBasePos[4],
	Float: teamSpawnPoints[9],
	Float: teamBriefcase[3],
	teamColor,
	teamColor2[12],
	Float:teamPrototypePos[4],
	Float:PrototypeCP[3],
	Float:teamSkinPickupPos[3],
	Float:AntennaPos[4],
	Float:TeamVehiclesPickupPos[3],
	Float:TeamSkyDivePickupPos[3],
	Float:TeamGuideBotPos[4],
	Float:TeamSamPos[4],

	Text3D:PrototypeTextLabel,
	TeamPoints,
	bool:TeamRadio,
	bool:BaseProtection,
	TeamRadioDownTime,
	TeamShieldDownTime,
	PrototypeID,
	baseID,
	teamBriefcaseID,
	teamAreaID,
	teamSkinPickupID,
	AntennaID,
	teamVehiclesPickupID,
	teamSkyDivePickupID,
	TeamGuideBotID,
	TeamSamID,
	teamID
};


enum eAmmoBox
{
	Float:AmmoBoxPos[4],
	AmmoBoxID
};

enum eClass
{
	className[12],
	classRank,
	classWeaponA[2],
	classWeaponB[2],
	classWeaponC[2],
	classWeaponD[2],
	classWeaponE[2],
	classWeaponF[2],
	classID
};

enum eRank
{
	rankName[20],
	rankScore,
	rankTag[5],
	rankID
};

enum eMode
{
	modeName[20],
	modeSkins[3],
	modeWeaponA[2],
	modeWeaponB[2],
	modeWeaponC[2],
	Float: modeSpawnA[3],
	Float: modeSpawnB[3],
	Float: modeSpawnC[3],
	modeInterior,
	modeID
};

enum eSupportStreak
{
	SStreakName[25],
	SStreakXP,
	SStreakKSpree,
	SStreakDescription[100]
};

enum PlayerData
{

	ID,
	Name[25],
	
	Password[65],
	hashedpass[11],
	pIP[16],
	LoginFails,
	Text3D: pLabel,
	Kills,
	Deaths,
	Score,
	Money,
	pXP,
	PrevXP,	
	
	Float:pPos[3],

	HealCMD,
	JetpackCMD,
	DroneCMD,
	PlantC4CMD,
	sMkCMD,
	sApCMD,
	sAmmoCMD,


	dBike,
	dCar,
	dNos,
	dHeli,

	BombLaunch,
	PlantedC4,
	PlantingTime,
	bool: Planting,
	C4Object,
	pSpawn,
	AdminRank,
	donorLevel,
	Warns,
	MuteTime,
	pCar,
	AmmoRefill,
	KillStreak,
	MedicKitThrowTime,
	
	CarePackageObj,
	bool:pCarePackage,
	Text3D:CarePackLabel,

	MedicKitObj,
	bool:pMedicKit,
	Text3D:MedicKitLabel,

	BallisticVestObj1,
	Text3D:BallisticVestLabel,

	BallisticVestObj2,
	Text3D:BallisticVestLabel2,

	DiveBombingVeh,
	KamikazeVeh,
	DroneVeh,

	ScoutDroneVeh,

	MoabObj,

	bool:IsPlayerInBunker,

	bool:IsPlayerFlyingDrone,
	bool:IsPlayerFlyingScoutDrone,
	bool:IsPlayerCapturingProto,
	ProtoVehID,
	TeamProtoIDOwner,

	bool:FirstSpawn,

	bool:IsPlayerHavingHelmet,
	bool:IsPlayerHavingMask,

	bool:IsPlayerDisarming,
	DisarmingTime,
	
	bool:Helmet,
	bool:Mask,
	Cache: Player_Cache,
	bool:LoggedIn,
	bool:Muted,
	bool:AdminDuty,
	bool:SpawnProtection,
	bool:PlayerSpectating,
	SpawnProtectionTime,
	bool:DND,
	bool:DuelDND
};

new pInfo[MAX_PLAYERS + 1][PlayerData];

enum e_ZONE
{
	zoneName[20],
	Float:zonePos[4],
	Float:zoneCP[3],
	Float:zoneSpawn[4],
	bool:ValidInMiniConquest,
	zoneOwner,
	zoneAttacker,
	zoneTick,
	zoneId,
	zoneCPId,
	zoneTimer,
	zonePlayer,
	zoneSPickup,
	Text3D:zoneLabel
};

enum E_PAIR
{
	E_FIRST,
	E_SECOND
}

enum eBombers
{
	Float:BomberPos[4],
	Text3D:Text3DLabelID,
	BomberBombs,
	BombObjID,
	BomberID
};

enum eShop
{
	Float:ShopPos[3],
	ShopPickupID
};

enum E_DUEL
{
	E_DUEL_ACTIVE,
	E_DUEL_WEAPON,
	E_DUEL_BET,
	E_DUEL_TARGET,
	E_DUEL_REQUEST,
	E_DUEL_PROTECTION_TIME,
	bool:E_DUEL_PROTECTION
};

enum eWeaponDrop
{
	WeaponInfo[2],
	Float:WeaponPos[3],
	WeaponObj,
	Text3D:WeaponLabel,
	bool:IsWeaponDropped
};

enum eEvent
{
	Event,
	Join,
	Freeze,
	EventType,
	EventWeapon1,
	EventWeapon2,
	EventWeapon3,
	EventSkin,
	PlayersTeam,
}
new gEvent[eEvent], pJoined[MAX_PLAYERS];
