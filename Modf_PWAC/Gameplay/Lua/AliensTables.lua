--MGH Modified
---- 2023 - Blessed by Protok St.
---- ===========================================================================
---- Alien Tables - Tables and functions for Aliens system
---- ===========================================================================
-- 
print("AliensTables.lua Start ---------------------------------------- ") -- dbg
-- include( "MathHelpers" );

-- ===========================================================================
-- DATA
-- ===========================================================================
local ModSaveDB = Modding.OpenSaveData();
local AwStage2Upgraded = ModSaveDB.GetValue("AwStage2Upgraded") or false;
local AwStage3Upgraded = ModSaveDB.GetValue("AwStage3Upgraded") or false;

-- Stage 1/2 - default aliens
local UNIT_SCARAB		= GameInfo.Units["UNIT_ALIEN_SCARAB"];
local UNIT_WOLF_BEETLE	= GameInfo.Units["UNIT_ALIEN_WOLF_BEETLE"];
local UNIT_RAPTOR 		= GameInfo.Units["UNIT_ALIEN_RAPTOR_BUG"];
local UNIT_MANTICORE 	= GameInfo.Units["UNIT_ALIEN_MANTICORE"];
local UNIT_FLYER 		= GameInfo.Units["UNIT_ALIEN_FLYER"];

local UNIT_SEA_DRAGON 	= GameInfo.Units["UNIT_ALIEN_SEA_DRAGON"];
local UNIT_POD_HUNTER 	= GameInfo.Units["UNIT_ALIEN_POD_HUNTER"];
local UNIT_AMPHIBIAN	= GameInfo.Units["UNIT_ALIEN_AMPHIBIAN"];

local UNIT_KRAKEN 		= GameInfo.Units["UNIT_ALIEN_KRAKEN"];
local UNIT_SIEGE_WORM 	= GameInfo.Units["UNIT_ALIEN_SIEGE_WORM"];

-- Stage 2/3 - specialised on biome
local UNIT_FLYER_LUSH 		= GameInfo.Units["UNIT_ALIEN_FLYER"];--MGH:_LUSH
local UNIT_FLYER_FUNG 		= GameInfo.Units["UNIT_ALIEN_FLYER"];--MGH:_FUNG
local UNIT_FLYER_ARID 		= GameInfo.Units["UNIT_ALIEN_FLYER"];--MGH:_ARID
local UNIT_FLYER_PRIM 		= GameInfo.Units["UNIT_ALIEN_FLYER"];--MGH:_PRIM
local UNIT_FLYER_FRIG 		= GameInfo.Units["UNIT_ALIEN_FLYER"];--MGH:_FRIG

local UNIT_SCARAB_LUSH 		= GameInfo.Units["UNIT_ALIEN_SCARAB"];--MGH:_LUSH
local UNIT_SCARAB_FUNG 		= GameInfo.Units["UNIT_ALIEN_SCARAB"];--MGH:_FUNG
local UNIT_SCARAB_ARID 		= GameInfo.Units["UNIT_ALIEN_SCARAB"];--MGH:_ARID
local UNIT_SCARAB_PRIM 		= GameInfo.Units["UNIT_ALIEN_SCARAB"];--MGH:_PRIM
local UNIT_SCARAB_FRIG 		= GameInfo.Units["UNIT_ALIEN_SCARAB"];--MGH:_FRIG

local UNIT_MANTICORE_LUSH 	= GameInfo.Units["UNIT_ALIEN_MANTICORE"];--MGH:_LUSH
local UNIT_MANTICORE_FUNG 	= GameInfo.Units["UNIT_ALIEN_MANTICORE"];--MGH:_FUNG
local UNIT_MANTICORE_ARID 	= GameInfo.Units["UNIT_ALIEN_MANTICORE"];--MGH:_ARID
local UNIT_MANTICORE_PRIM 	= GameInfo.Units["UNIT_ALIEN_MANTICORE"];--MGH:_PRIM
local UNIT_MANTICORE_FRIG 	= GameInfo.Units["UNIT_ALIEN_MANTICORE"];--MGH:_FRIG

local UNIT_RAPTOR_LUSH 		= GameInfo.Units["UNIT_ALIEN_RAPTOR_BUG"];--MGH:_LUSH
local UNIT_RAPTOR_FUNG 		= GameInfo.Units["UNIT_ALIEN_RAPTOR_BUG"];--MGH:_FUNG
local UNIT_RAPTOR_ARID 		= GameInfo.Units["UNIT_ALIEN_RAPTOR_BUG"];--MGH:_ARID
local UNIT_RAPTOR_PRIM 		= GameInfo.Units["UNIT_ALIEN_RAPTOR_BUG"];--MGH:_PRIM
local UNIT_RAPTOR_FRIG 		= GameInfo.Units["UNIT_ALIEN_RAPTOR_BUG"];--MGH:_FRIG

local UNIT_WOLF_BEETLE_LUSH = GameInfo.Units["UNIT_ALIEN_WOLF_BEETLE"];--MGH:_LUSH
local UNIT_WOLF_BEETLE_FUNG = GameInfo.Units["UNIT_ALIEN_WOLF_BEETLE"];--MGH:_FUNG
local UNIT_WOLF_BEETLE_ARID = GameInfo.Units["UNIT_ALIEN_WOLF_BEETLE"];--MGH:_ARID
local UNIT_WOLF_BEETLE_PRIM = GameInfo.Units["UNIT_ALIEN_WOLF_BEETLE"];--MGH:_PRIM
local UNIT_WOLF_BEETLE_FRIG = GameInfo.Units["UNIT_ALIEN_WOLF_BEETLE"];--MGH:_FRIG

local UNIT_SIEGE_WORM_LUSH = GameInfo.Units["UNIT_ALIEN_SIEGE_WORM"];--MGH:_LUSH
local UNIT_SIEGE_WORM_FUNG = GameInfo.Units["UNIT_ALIEN_SIEGE_WORM"];--MGH:_FUNG
local UNIT_SIEGE_WORM_ARID = GameInfo.Units["UNIT_ALIEN_SIEGE_WORM"];--MGH:_ARID
local UNIT_SIEGE_WORM_PRIM = GameInfo.Units["UNIT_ALIEN_SIEGE_WORM"];--MGH:_PRIM
local UNIT_SIEGE_WORM_FRIG = GameInfo.Units["UNIT_ALIEN_SIEGE_WORM"];--MGH:_FRIG

local UNIT_AMPHIBIAN_LUSH = GameInfo.Units["UNIT_ALIEN_AMPHIBIAN"];--MGH:_LUSH
local UNIT_AMPHIBIAN_FUNG = GameInfo.Units["UNIT_ALIEN_AMPHIBIAN"];--MGH:_FUNG
local UNIT_AMPHIBIAN_ARID = GameInfo.Units["UNIT_ALIEN_AMPHIBIAN"];--MGH:_ARID
local UNIT_AMPHIBIAN_PRIM = GameInfo.Units["UNIT_ALIEN_AMPHIBIAN"];--MGH:_PRIM
local UNIT_AMPHIBIAN_FRIG = GameInfo.Units["UNIT_ALIEN_AMPHIBIAN"];--MGH:_FRIG

local UNIT_POD_HUNTER_LUSH = GameInfo.Units["UNIT_ALIEN_POD_HUNTER"];--MGH:_LUSH
local UNIT_POD_HUNTER_FUNG = GameInfo.Units["UNIT_ALIEN_POD_HUNTER"];--MGH:_FUNG
local UNIT_POD_HUNTER_ARID = GameInfo.Units["UNIT_ALIEN_POD_HUNTER"];--MGH:_ARID
local UNIT_POD_HUNTER_PRIM = GameInfo.Units["UNIT_ALIEN_POD_HUNTER"];--MGH:_PRIM
local UNIT_POD_HUNTER_FRIG = GameInfo.Units["UNIT_ALIEN_POD_HUNTER"];--MGH:_FRIG

local UNIT_SEA_DRAGON_LUSH = GameInfo.Units["UNIT_ALIEN_SEA_DRAGON"];--MGH:_LUSH
local UNIT_SEA_DRAGON_FUNG = GameInfo.Units["UNIT_ALIEN_SEA_DRAGON"];--MGH:_FUNG
local UNIT_SEA_DRAGON_ARID = GameInfo.Units["UNIT_ALIEN_SEA_DRAGON"];--MGH:_ARID
local UNIT_SEA_DRAGON_PRIM = GameInfo.Units["UNIT_ALIEN_SEA_DRAGON"];--MGH:_PRIM
local UNIT_SEA_DRAGON_FRIG = GameInfo.Units["UNIT_ALIEN_SEA_DRAGON"];--MGH:_FRIG

local UNIT_KRAKEN_LUSH = GameInfo.Units["UNIT_ALIEN_KRAKEN"];--MGH:_LUSH
local UNIT_KRAKEN_FUNG = GameInfo.Units["UNIT_ALIEN_KRAKEN"];--MGH:_FUNG
local UNIT_KRAKEN_ARID = GameInfo.Units["UNIT_ALIEN_KRAKEN"];--MGH:_ARID
local UNIT_KRAKEN_PRIM = GameInfo.Units["UNIT_ALIEN_KRAKEN"];--MGH:_PRIM
local UNIT_KRAKEN_FRIG = GameInfo.Units["UNIT_ALIEN_KRAKEN"];--MGH:_FRIG

-- ===========================================================================
-- OPEN SEASON TABLES
-- ===========================================================================
-- These are the base Spawnchances for different Alien Types. They get modified by the Open Season script.
-- place is a flag of where this skeleton can be spawned. 0 - ocean, 1 - both, 2 - land.
local OPEN_SEASON_SKELETON_TABLE = {
		
		{ unitType = UNIT_FLYER,			PercentChance = 6, place = 2 },	
		{ unitType = UNIT_FLYER_LUSH,		PercentChance = 6, place = 2 },
		{ unitType = UNIT_FLYER_FUNG,		PercentChance = 6, place = 2 },
		{ unitType = UNIT_FLYER_ARID,		PercentChance = 6, place = 2 },
		{ unitType = UNIT_FLYER_PRIM,		PercentChance = 6, place = 2 },
		{ unitType = UNIT_FLYER_FRIG,		PercentChance = 6, place = 2 },	

		{ unitType = UNIT_SCARAB,			PercentChance = 1, place = 2 },
		{ unitType = UNIT_SCARAB_LUSH,		PercentChance = 2, place = 2 },
		{ unitType = UNIT_SCARAB_FUNG,		PercentChance = 2, place = 2 },
		{ unitType = UNIT_SCARAB_ARID,		PercentChance = 2, place = 2 },
		{ unitType = UNIT_SCARAB_PRIM,		PercentChance = 2, place = 2 },
		{ unitType = UNIT_SCARAB_FRIG,		PercentChance = 2, place = 2 },
		
		{ unitType = UNIT_WOLF_BEETLE,		PercentChance = 4, place = 2 },
		{ unitType = UNIT_WOLF_BEETLE_LUSH,	PercentChance = 5, place = 2 },
		{ unitType = UNIT_WOLF_BEETLE_FUNG,	PercentChance = 5, place = 2 },
		{ unitType = UNIT_WOLF_BEETLE_ARID,	PercentChance = 5, place = 2 },
		{ unitType = UNIT_WOLF_BEETLE_PRIM,	PercentChance = 5, place = 2 },
		{ unitType = UNIT_WOLF_BEETLE_FRIG,	PercentChance = 5, place = 2 },
		
		{ unitType = UNIT_MANTICORE,		PercentChance = 3, place = 2 },
		{ unitType = UNIT_MANTICORE_LUSH,	PercentChance = 4, place = 2 },
		{ unitType = UNIT_MANTICORE_FUNG,	PercentChance = 4, place = 2 },
		{ unitType = UNIT_MANTICORE_ARID,	PercentChance = 4, place = 2 },
		{ unitType = UNIT_MANTICORE_PRIM,	PercentChance = 4, place = 2 },
		{ unitType = UNIT_MANTICORE_FRIG,	PercentChance = 4, place = 2 },
		
		{ unitType = UNIT_RAPTOR,			PercentChance = 5, place = 2 },
		{ unitType = UNIT_RAPTOR_LUSH,		PercentChance = 6, place = 2 },
		{ unitType = UNIT_RAPTOR_FUNG,		PercentChance = 6, place = 2 },
		{ unitType = UNIT_RAPTOR_ARID,		PercentChance = 6, place = 2 },
		{ unitType = UNIT_RAPTOR_PRIM,		PercentChance = 6, place = 2 },
		{ unitType = UNIT_RAPTOR_FRIG,		PercentChance = 6, place = 2 },
		
		{ unitType = UNIT_SIEGE_WORM,		PercentChance = 20, place = 2 },
		{ unitType = UNIT_SIEGE_WORM_LUSH,	PercentChance = 21, place = 2 },
		{ unitType = UNIT_SIEGE_WORM_FUNG,	PercentChance = 21, place = 2 },
		{ unitType = UNIT_SIEGE_WORM_ARID,	PercentChance = 21, place = 2 },
		{ unitType = UNIT_SIEGE_WORM_PRIM,	PercentChance = 21, place = 2 },
		{ unitType = UNIT_SIEGE_WORM_FRIG,	PercentChance = 21, place = 2 },
		
		{ unitType = UNIT_AMPHIBIAN,		PercentChance = 10, place = 1 },
		{ unitType = UNIT_AMPHIBIAN_LUSH,	PercentChance = 11, place = 1 },
		{ unitType = UNIT_AMPHIBIAN_FUNG,	PercentChance = 11, place = 1 },
		{ unitType = UNIT_AMPHIBIAN_ARID,	PercentChance = 11, place = 1 },
		{ unitType = UNIT_AMPHIBIAN_PRIM,	PercentChance = 11, place = 1 },
		{ unitType = UNIT_AMPHIBIAN_FRIG,	PercentChance = 11, place = 1 },
		
		{ unitType = UNIT_POD_HUNTER,		PercentChance = 2, place = 0 },
		{ unitType = UNIT_POD_HUNTER_LUSH,	PercentChance = 3, place = 0 },
		{ unitType = UNIT_POD_HUNTER_FUNG,	PercentChance = 3, place = 0 },
		{ unitType = UNIT_POD_HUNTER_ARID,	PercentChance = 3, place = 0 },
		{ unitType = UNIT_POD_HUNTER_PRIM,	PercentChance = 3, place = 0 },
		{ unitType = UNIT_POD_HUNTER_FRIG,	PercentChance = 3, place = 0 },
		
		{ unitType = UNIT_SEA_DRAGON,		PercentChance = 3, place = 0 },
		{ unitType = UNIT_SEA_DRAGON_LUSH,	PercentChance = 4, place = 0 },
		{ unitType = UNIT_SEA_DRAGON_FUNG,	PercentChance = 4, place = 0 },
		{ unitType = UNIT_SEA_DRAGON_ARID,	PercentChance = 4, place = 0 },
		{ unitType = UNIT_SEA_DRAGON_PRIM,	PercentChance = 4, place = 0 },
		{ unitType = UNIT_SEA_DRAGON_FRIG,	PercentChance = 4, place = 0 },
		
		{ unitType = UNIT_KRAKEN,			PercentChance = 16, place = 0 }, 
		{ unitType = UNIT_KRAKEN_LUSH,		PercentChance = 17, place = 0 },
		{ unitType = UNIT_KRAKEN_FUNG,		PercentChance = 17, place = 0 },
		{ unitType = UNIT_KRAKEN_ARID,		PercentChance = 17, place = 0 },
		{ unitType = UNIT_KRAKEN_PRIM,		PercentChance = 17, place = 0 },
		{ unitType = UNIT_KRAKEN_FRIG,		PercentChance = 17, place = 0 },
};

function GetSkeletonChance(unitType)
-- return a table from OPEN_SEASON_SKELETON_TABLE or false

	for _, j in ipairs(OPEN_SEASON_SKELETON_TABLE) do
		if (unitType == j.unitType.ID) then
			-- return j.PercentChance;
			return j;
		end
	end
	return false;
end;

-- ===========================================================================
-- ALIENS PROMOTIONS
-- ===========================================================================
-- Each stage and stage list has own permanent and random promos.
local PROMOTION_ALIEN_STAGE_2 = {
	-- [0] = PROMOTION_ALIEN_STAGE_2_1, -- miasma heal, for all
	[1] = "PROMOTION_ALIEN_STAGE_2_2", -- defense
	[2] = "PROMOTION_ALIEN_STAGE_2_3", -- attack
	[3] = "PROMOTION_ALIEN_STAGE_2_4", -- combat
};

local PROMOTION_ALIEN_STAGE_3 = {
	-- [0] = PROMOTION_ALIEN_STAGE_3_1, -- miasma heal, for all
	[1] = "PROMOTION_ALIEN_STAGE_3_2", -- defense
	[2] = "PROMOTION_ALIEN_STAGE_3_3", -- attack
	[3] = "PROMOTION_ALIEN_STAGE_3_4", -- combat
};

local PROMOTION_ALIEN_STAGE_LIST_2 = {
	[1] = "PROMOTION_ALIEN_STAGE_LIST_2_1", -- defense in
	[2] = "PROMOTION_ALIEN_STAGE_LIST_2_2", -- attack to
	[3] = "PROMOTION_ALIEN_STAGE_LIST_2_3", -- defense in, attack to
};

local PROMOTION_ALIEN_STAGE_LIST_3 = {
	[1] = "PROMOTION_ALIEN_STAGE_LIST_3_1", -- defense in
	[2] = "PROMOTION_ALIEN_STAGE_LIST_3_2", -- attack to
	[3] = "PROMOTION_ALIEN_STAGE_LIST_3_3", -- defense in, attack to
};
-- ========================
--  ALIEN UPGRADES
-- ========================
local UNITUPGRADE_ALIENS_STAGE_2 = {
	-- [1] = {Upgrade = "UNITUPGRADE_ALIENS_STAGE_2", Perk = "UNITPERK_ALIENS_STAGE_2_1"}, -- defense
	-- [2] = {Upgrade = "UNITUPGRADE_ALIENS_STAGE_2", Perk = "UNITPERK_ALIENS_STAGE_2_2"}, -- attack
	[1] = {
		Upgrade = GameInfo.UnitUpgrades["UNITUPGRADE_ALIENS_STAGE_2"], 
		Perk = GameInfo.UnitPerks["UNITPERK_ALIENS_STAGE_2_1"]}, -- defense
	[2] = {
		Upgrade = GameInfo.UnitUpgrades["UNITUPGRADE_ALIENS_STAGE_2"], 
		Perk = GameInfo.UnitPerks["UNITPERK_ALIENS_STAGE_2_2"]}, -- attack
};

local UNITUPGRADE_ALIENS_STAGE_3 = {
	[1] = {
		Upgrade = GameInfo.UnitUpgrades["UNITUPGRADE_ALIENS_STAGE_3"], 
		Perk = GameInfo.UnitPerks["UNITPERK_ALIENS_STAGE_3_1"]}, -- defense
	[2] = {
		Upgrade = GameInfo.UnitUpgrades["UNITUPGRADE_ALIENS_STAGE_3"], 
		Perk = GameInfo.UnitPerks["UNITPERK_ALIENS_STAGE_3_2"]}, -- attack
};
-- ========================
--  ALIENS STAGE 2 LIST
-- ========================
local ALIENS_STAGE_LIST_2 = {
	[0] = {UNIT_FLYER_LUSH, UNIT_SCARAB_LUSH, UNIT_MANTICORE_LUSH, UNIT_RAPTOR_LUSH, UNIT_WOLF_BEETLE_LUSH, UNIT_SIEGE_WORM_LUSH,UNIT_AMPHIBIAN_LUSH}, -- biome
	[1] = {UNIT_FLYER_FUNG, UNIT_SCARAB_FUNG, UNIT_MANTICORE_FUNG, UNIT_RAPTOR_FUNG, UNIT_WOLF_BEETLE_FUNG, UNIT_SIEGE_WORM_FUNG,UNIT_AMPHIBIAN_FUNG}, -- biome
	[2] = {UNIT_FLYER_ARID, UNIT_SCARAB_ARID, UNIT_MANTICORE_ARID, UNIT_RAPTOR_ARID, UNIT_WOLF_BEETLE_ARID, UNIT_SIEGE_WORM_ARID,UNIT_AMPHIBIAN_ARID}, -- biome
	[3] = {UNIT_FLYER_PRIM, UNIT_SCARAB_PRIM, UNIT_MANTICORE_PRIM, UNIT_RAPTOR_PRIM, UNIT_WOLF_BEETLE_PRIM, UNIT_SIEGE_WORM_PRIM,UNIT_AMPHIBIAN_PRIM}, -- biome
	[4] = {UNIT_FLYER_FRIG, UNIT_SCARAB_FRIG, UNIT_MANTICORE_FRIG, UNIT_RAPTOR_FRIG, UNIT_WOLF_BEETLE_FRIG, UNIT_SIEGE_WORM_FRIG,UNIT_AMPHIBIAN_FRIG}, -- biome
};

-- ========================
--  ALIENS STAGE 3 LIST
-- ========================
local ALIENS_STAGE_LIST_3 = {
	UNIT_FLYER_LUSH, UNIT_SCARAB_LUSH, UNIT_MANTICORE_LUSH, UNIT_RAPTOR_LUSH, UNIT_WOLF_BEETLE_LUSH, UNIT_SIEGE_WORM_LUSH,UNIT_AMPHIBIAN_LUSH, 
	UNIT_FLYER_FUNG, UNIT_SCARAB_FUNG, UNIT_MANTICORE_FUNG, UNIT_RAPTOR_FUNG, UNIT_WOLF_BEETLE_FUNG, UNIT_SIEGE_WORM_FUNG,UNIT_AMPHIBIAN_FUNG,
	UNIT_FLYER_ARID, UNIT_SCARAB_ARID, UNIT_MANTICORE_ARID, UNIT_RAPTOR_ARID, UNIT_WOLF_BEETLE_ARID, UNIT_SIEGE_WORM_ARID,UNIT_AMPHIBIAN_ARID,
	UNIT_FLYER_PRIM, UNIT_SCARAB_PRIM, UNIT_MANTICORE_PRIM, UNIT_RAPTOR_PRIM, UNIT_WOLF_BEETLE_PRIM, UNIT_SIEGE_WORM_PRIM,UNIT_AMPHIBIAN_PRIM,
	UNIT_FLYER_FRIG, UNIT_SCARAB_FRIG, UNIT_MANTICORE_FRIG, UNIT_RAPTOR_FRIG, UNIT_WOLF_BEETLE_FRIG, UNIT_SIEGE_WORM_FRIG,UNIT_AMPHIBIAN_FRIG,
};

-- ===========================================================================
-- ALIENS SPAWN TABLES
-- ===========================================================================
-- Governs spawn distribution for the various alien unit types based on the
--	average dominant affinity progress for all active players (rough game progress heuristic)
-- ========================
--  AWAKENING STAGE 1 LIST
-- ========================
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_UNIT_SPAWN_TABLE = {
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SCARAB,		PercentChance = 45 },
		{ Unit = UNIT_WOLF_BEETLE,	PercentChance = 30 },
		{ Unit = UNIT_MANTICORE,	PercentChance = 15 },
		{ Unit = UNIT_RAPTOR,		PercentChance = 5 },
		{ Unit = UNIT_FLYER,		PercentChance = 5 },		
	}, },
	[2] = { 0.25, 
	{
		{ Unit = UNIT_SCARAB,		PercentChance = 20 },
		{ Unit = UNIT_WOLF_BEETLE,	PercentChance = 35 },
		{ Unit = UNIT_RAPTOR,		PercentChance = 15 },
		{ Unit = UNIT_FLYER,		PercentChance = 15 },
		{ Unit = UNIT_MANTICORE,	PercentChance = 15 },
	}, },
	[3] = { 0.45, 
	{
		{ Unit = UNIT_SCARAB,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE,	PercentChance = 45 },
		{ Unit = UNIT_RAPTOR,		PercentChance = 25 },
		{ Unit = UNIT_FLYER,		PercentChance = 10 },
		{ Unit = UNIT_MANTICORE,	PercentChance = 15 },
	}, },
	[4] = { 0.65, 
	{
		{ Unit = UNIT_SCARAB,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE,	PercentChance = 10 },
		{ Unit = UNIT_RAPTOR,		PercentChance = 40 },
		{ Unit = UNIT_FLYER,		PercentChance = 35 },
		{ Unit = UNIT_MANTICORE,	PercentChance = 10 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_UNIT_SPAWN_TABLE = {

	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_POD_HUNTER,	PercentChance = 55 },
		{ Unit = UNIT_SEA_DRAGON,	PercentChance = 40 },
		{ Unit = UNIT_AMPHIBIAN,	PercentChance = 5 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_POD_HUNTER,	PercentChance = 45 },
		{ Unit = UNIT_SEA_DRAGON,	PercentChance = 45 },
		{ Unit = UNIT_AMPHIBIAN,	PercentChance = 10 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_POD_HUNTER,	PercentChance = 30 }, 
		{ Unit = UNIT_SEA_DRAGON,	PercentChance = 65 }, 
		{ Unit = UNIT_AMPHIBIAN,	PercentChance = 15 }, 
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_CLS_UNIT_SPAWN_TABLE = {
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SIEGE_WORM,	PercentChance = 100 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_CLS_UNIT_SPAWN_TABLE = {
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_AMPHIBIAN,	PercentChance = 75 },
		{ Unit = UNIT_KRAKEN,		PercentChance = 25 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_AMPHIBIAN,	PercentChance = 50 },
		{ Unit = UNIT_KRAKEN,		PercentChance = 50 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_AMPHIBIAN,	PercentChance = 30 },
		{ Unit = UNIT_KRAKEN,		PercentChance = 70 },
	}, },
};
-- ========================
--  AWAKENING STAGE 2 LIST
-- ========================
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_UNIT_SPAWN_TABLE_S2_LUSH = {	-- 0
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SCARAB_LUSH,		PercentChance = 45 },
		{ Unit = UNIT_WOLF_BEETLE_LUSH,	PercentChance = 30 },
		{ Unit = UNIT_MANTICORE_LUSH,	PercentChance = 15 },
		{ Unit = UNIT_RAPTOR_LUSH,		PercentChance = 5 },
		{ Unit = UNIT_FLYER_LUSH,		PercentChance = 5 },		
	}, },
	[2] = { 0.25, 
	{
		{ Unit = UNIT_SCARAB_LUSH,		PercentChance = 20 },
		{ Unit = UNIT_WOLF_BEETLE_LUSH,	PercentChance = 35 },
		{ Unit = UNIT_RAPTOR_LUSH,		PercentChance = 15 },
		{ Unit = UNIT_FLYER_LUSH,		PercentChance = 15 },
		{ Unit = UNIT_MANTICORE_LUSH,	PercentChance = 15 },
	}, },
	[3] = { 0.45, 
	{
		{ Unit = UNIT_SCARAB_LUSH,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_LUSH,	PercentChance = 45 },
		{ Unit = UNIT_RAPTOR_LUSH,		PercentChance = 25 },
		{ Unit = UNIT_FLYER_LUSH,		PercentChance = 10 },
		{ Unit = UNIT_MANTICORE_LUSH,	PercentChance = 15 },
	}, },
	[4] = { 0.65, 
	{
		{ Unit = UNIT_SCARAB_LUSH,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_LUSH,	PercentChance = 10 },
		{ Unit = UNIT_RAPTOR_LUSH,		PercentChance = 40 },
		{ Unit = UNIT_FLYER_LUSH,		PercentChance = 35 },
		{ Unit = UNIT_MANTICORE_LUSH,	PercentChance = 10 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_UNIT_SPAWN_TABLE_S2_FUNG = {	-- 1
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SCARAB_FUNG,		PercentChance = 45 },
		{ Unit = UNIT_WOLF_BEETLE_FUNG,	PercentChance = 30 },
		{ Unit = UNIT_MANTICORE_FUNG,	PercentChance = 15 },
		{ Unit = UNIT_RAPTOR_FUNG,		PercentChance = 5 },
		{ Unit = UNIT_FLYER_FUNG,		PercentChance = 5 },		
	}, },
	[2] = { 0.25, 
	{
		{ Unit = UNIT_SCARAB_FUNG,		PercentChance = 20 },
		{ Unit = UNIT_WOLF_BEETLE_FUNG,	PercentChance = 35 },
		{ Unit = UNIT_RAPTOR_FUNG,		PercentChance = 15 },
		{ Unit = UNIT_FLYER_FUNG,		PercentChance = 15 },
		{ Unit = UNIT_MANTICORE_FUNG,	PercentChance = 15 },
	}, },
	[3] = { 0.45, 
	{
		{ Unit = UNIT_SCARAB_FUNG,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_FUNG,	PercentChance = 45 },
		{ Unit = UNIT_RAPTOR_FUNG,		PercentChance = 25 },
		{ Unit = UNIT_FLYER_FUNG,		PercentChance = 10 },
		{ Unit = UNIT_MANTICORE_FUNG,	PercentChance = 15 },
	}, },
	[4] = { 0.65, 
	{
		{ Unit = UNIT_SCARAB_FUNG,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_FUNG,	PercentChance = 10 },
		{ Unit = UNIT_RAPTOR_FUNG,		PercentChance = 40 },
		{ Unit = UNIT_FLYER_FUNG,		PercentChance = 35 },
		{ Unit = UNIT_MANTICORE_FUNG,	PercentChance = 10 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_UNIT_SPAWN_TABLE_S2_ARID = {		-- 2
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SCARAB_ARID,		PercentChance = 45 },
		{ Unit = UNIT_WOLF_BEETLE_ARID,	PercentChance = 30 },
		{ Unit = UNIT_MANTICORE_ARID,	PercentChance = 15 },
		{ Unit = UNIT_RAPTOR_ARID,		PercentChance = 5 },
		{ Unit = UNIT_FLYER_ARID,		PercentChance = 5 },		
	}, },
	[2] = { 0.25, 
	{
		{ Unit = UNIT_SCARAB_ARID,		PercentChance = 20 },
		{ Unit = UNIT_WOLF_BEETLE_ARID,	PercentChance = 35 },
		{ Unit = UNIT_RAPTOR_ARID,		PercentChance = 15 },
		{ Unit = UNIT_FLYER_ARID,		PercentChance = 15 },
		{ Unit = UNIT_MANTICORE_ARID,	PercentChance = 15 },
	}, },
	[3] = { 0.45, 
	{
		{ Unit = UNIT_SCARAB_ARID,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_ARID,	PercentChance = 45 },
		{ Unit = UNIT_RAPTOR_ARID,		PercentChance = 25 },
		{ Unit = UNIT_FLYER_ARID,		PercentChance = 10 },
		{ Unit = UNIT_MANTICORE_ARID,	PercentChance = 15 },
	}, },
	[4] = { 0.65, 
	{
		{ Unit = UNIT_SCARAB_ARID,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_ARID,	PercentChance = 10 },
		{ Unit = UNIT_RAPTOR_ARID,		PercentChance = 40 },
		{ Unit = UNIT_FLYER_ARID,		PercentChance = 35 },
		{ Unit = UNIT_MANTICORE_ARID,	PercentChance = 10 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_UNIT_SPAWN_TABLE_S2_PRIM = {		-- 3
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SCARAB_PRIM,		PercentChance = 45 },
		{ Unit = UNIT_WOLF_BEETLE_PRIM,	PercentChance = 30 },
		{ Unit = UNIT_MANTICORE_PRIM,	PercentChance = 15 },
		{ Unit = UNIT_RAPTOR_PRIM,		PercentChance = 5 },
		{ Unit = UNIT_FLYER_PRIM,		PercentChance = 5 },		
	}, },
	[2] = { 0.25, 
	{
		{ Unit = UNIT_SCARAB_PRIM,		PercentChance = 20 },
		{ Unit = UNIT_WOLF_BEETLE_PRIM,	PercentChance = 35 },
		{ Unit = UNIT_RAPTOR_PRIM,		PercentChance = 15 },
		{ Unit = UNIT_FLYER_PRIM,		PercentChance = 15 },
		{ Unit = UNIT_MANTICORE_PRIM,	PercentChance = 15 },
	}, },
	[3] = { 0.45, 
	{
		{ Unit = UNIT_SCARAB_PRIM,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_PRIM,	PercentChance = 45 },
		{ Unit = UNIT_RAPTOR_PRIM,		PercentChance = 25 },
		{ Unit = UNIT_FLYER_PRIM,		PercentChance = 10 },
		{ Unit = UNIT_MANTICORE_PRIM,	PercentChance = 15 },
	}, },
	[4] = { 0.65, 
	{
		{ Unit = UNIT_SCARAB_PRIM,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_PRIM,	PercentChance = 10 },
		{ Unit = UNIT_RAPTOR_PRIM,		PercentChance = 40 },
		{ Unit = UNIT_FLYER_PRIM,		PercentChance = 35 },
		{ Unit = UNIT_MANTICORE_PRIM,	PercentChance = 10 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_UNIT_SPAWN_TABLE_S2_FRIG = {	-- 4
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SCARAB_FRIG,		PercentChance = 45 },
		{ Unit = UNIT_WOLF_BEETLE_FRIG,	PercentChance = 30 },
		{ Unit = UNIT_MANTICORE_FRIG,	PercentChance = 15 },
		{ Unit = UNIT_RAPTOR_FRIG,		PercentChance = 5 },
		{ Unit = UNIT_FLYER_FRIG,		PercentChance = 5 },		
	}, },
	[2] = { 0.25,  
	{
		{ Unit = UNIT_SCARAB_FRIG,		PercentChance = 20 },
		{ Unit = UNIT_WOLF_BEETLE_FRIG,	PercentChance = 35 },
		{ Unit = UNIT_RAPTOR_FRIG,		PercentChance = 15 },
		{ Unit = UNIT_FLYER_FRIG,		PercentChance = 15 },
		{ Unit = UNIT_MANTICORE_FRIG,	PercentChance = 15 },
	}, },
	[3] = { 0.45, 
	{
		{ Unit = UNIT_SCARAB_FRIG,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_FRIG,	PercentChance = 45 },
		{ Unit = UNIT_RAPTOR_FRIG,		PercentChance = 25 },
		{ Unit = UNIT_FLYER_FRIG,		PercentChance = 10 },
		{ Unit = UNIT_MANTICORE_FRIG,	PercentChance = 15 },
	}, },
	[4] = { 0.65, 
	{
		{ Unit = UNIT_SCARAB_FRIG,		PercentChance = 5 },
		{ Unit = UNIT_WOLF_BEETLE_FRIG,	PercentChance = 10 },
		{ Unit = UNIT_RAPTOR_FRIG,		PercentChance = 40 },
		{ Unit = UNIT_FLYER_FRIG,		PercentChance = 35 },
		{ Unit = UNIT_MANTICORE_FRIG,	PercentChance = 10 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_UNIT_SPAWN_TABLE_S2_LUSH = {	-- 0
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_POD_HUNTER_LUSH,	PercentChance = 55 },
		{ Unit = UNIT_SEA_DRAGON_LUSH,	PercentChance = 40 },
		{ Unit = UNIT_AMPHIBIAN_LUSH,	PercentChance = 5 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_POD_HUNTER_LUSH,	PercentChance = 45 },
		{ Unit = UNIT_SEA_DRAGON_LUSH,	PercentChance = 45 },
		{ Unit = UNIT_AMPHIBIAN_LUSH,	PercentChance = 10 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_POD_HUNTER_LUSH,	PercentChance = 30 }, 
		{ Unit = UNIT_SEA_DRAGON_LUSH,	PercentChance = 65 }, 
		{ Unit = UNIT_AMPHIBIAN_LUSH,	PercentChance = 15 }, 
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_UNIT_SPAWN_TABLE_S2_FUNG = {	-- 1
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_POD_HUNTER_FUNG,	PercentChance = 55 },
		{ Unit = UNIT_SEA_DRAGON_FUNG,	PercentChance = 40 },
		{ Unit = UNIT_AMPHIBIAN_FUNG,	PercentChance = 5 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_POD_HUNTER_FUNG,	PercentChance = 45 },
		{ Unit = UNIT_SEA_DRAGON_FUNG,	PercentChance = 45 },
		{ Unit = UNIT_AMPHIBIAN_FUNG,	PercentChance = 10 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_POD_HUNTER_FUNG,	PercentChance = 30 }, 
		{ Unit = UNIT_SEA_DRAGON_FUNG,	PercentChance = 65 }, 
		{ Unit = UNIT_AMPHIBIAN_FUNG,	PercentChance = 15 }, 
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_UNIT_SPAWN_TABLE_S2_ARID = {	-- 2
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_POD_HUNTER_ARID,	PercentChance = 55 },
		{ Unit = UNIT_SEA_DRAGON_ARID,	PercentChance = 40 },
		{ Unit = UNIT_AMPHIBIAN_ARID,	PercentChance = 5 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_POD_HUNTER_ARID,	PercentChance = 45 },
		{ Unit = UNIT_SEA_DRAGON_ARID,	PercentChance = 45 },
		{ Unit = UNIT_AMPHIBIAN_ARID,	PercentChance = 10 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_POD_HUNTER_ARID,	PercentChance = 30 }, 
		{ Unit = UNIT_SEA_DRAGON_ARID,	PercentChance = 65 }, 
		{ Unit = UNIT_AMPHIBIAN_ARID,	PercentChance = 15 }, 
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_UNIT_SPAWN_TABLE_S2_PRIM = {	-- 3
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_POD_HUNTER_PRIM,	PercentChance = 55 },
		{ Unit = UNIT_SEA_DRAGON_PRIM,	PercentChance = 40 },
		{ Unit = UNIT_AMPHIBIAN_PRIM,	PercentChance = 5 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_POD_HUNTER_PRIM,	PercentChance = 45 },
		{ Unit = UNIT_SEA_DRAGON_PRIM,	PercentChance = 45 },
		{ Unit = UNIT_AMPHIBIAN_PRIM,	PercentChance = 10 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_POD_HUNTER_PRIM,	PercentChance = 30 }, 
		{ Unit = UNIT_SEA_DRAGON_PRIM,	PercentChance = 65 }, 
		{ Unit = UNIT_AMPHIBIAN_PRIM,	PercentChance = 15 }, 
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_UNIT_SPAWN_TABLE_S2_FRIG = {	-- 4
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_POD_HUNTER_FRIG,	PercentChance = 55 },
		{ Unit = UNIT_SEA_DRAGON_FRIG,	PercentChance = 40 },
		{ Unit = UNIT_AMPHIBIAN_FRIG,	PercentChance = 5 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_POD_HUNTER_FRIG,	PercentChance = 45 },
		{ Unit = UNIT_SEA_DRAGON_FRIG,	PercentChance = 45 },
		{ Unit = UNIT_AMPHIBIAN_FRIG,	PercentChance = 10 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_POD_HUNTER_FRIG,	PercentChance = 30 }, 
		{ Unit = UNIT_SEA_DRAGON_FRIG,	PercentChance = 65 }, 
		{ Unit = UNIT_AMPHIBIAN_FRIG,	PercentChance = 15 }, 
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_CLS_UNIT_SPAWN_TABLE_S2_LUSH = {	-- 0
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SIEGE_WORM_LUSH,	PercentChance = 100 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_CLS_UNIT_SPAWN_TABLE_S2_FUNG = {	-- 1
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SIEGE_WORM_FUNG,	PercentChance = 100 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_CLS_UNIT_SPAWN_TABLE_S2_ARID = {		-- 2
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SIEGE_WORM_ARID,	PercentChance = 100 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_CLS_UNIT_SPAWN_TABLE_S2_PRIM = {		-- 3
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SIEGE_WORM_PRIM,	PercentChance = 100 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local LAND_CLS_UNIT_SPAWN_TABLE_S2_FRIG = {	-- 4
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_SIEGE_WORM_FRIG,	PercentChance = 100 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_CLS_UNIT_SPAWN_TABLE_S2_LUSH = {	-- 0
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_LUSH,	PercentChance = 75 },
		{ Unit = UNIT_KRAKEN_LUSH,		PercentChance = 25 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_AMPHIBIAN_LUSH,	PercentChance = 50 },
		{ Unit = UNIT_KRAKEN_LUSH,		PercentChance = 50 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_LUSH,	PercentChance = 30 },
		{ Unit = UNIT_KRAKEN_LUSH,		PercentChance = 70 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_CLS_UNIT_SPAWN_TABLE_S2_FUNG = {	-- 1
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_FUNG,	PercentChance = 75 },
		{ Unit = UNIT_KRAKEN_FUNG,		PercentChance = 25 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_AMPHIBIAN_FUNG,	PercentChance = 50 },
		{ Unit = UNIT_KRAKEN_FUNG,		PercentChance = 50 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_FUNG,	PercentChance = 30 },
		{ Unit = UNIT_KRAKEN_FUNG,		PercentChance = 70 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_CLS_UNIT_SPAWN_TABLE_S2_ARID = {	-- 2
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_ARID,	PercentChance = 75 },
		{ Unit = UNIT_KRAKEN_ARID,		PercentChance = 25 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_AMPHIBIAN_ARID,	PercentChance = 50 },
		{ Unit = UNIT_KRAKEN_ARID,		PercentChance = 50 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_ARID,	PercentChance = 30 },
		{ Unit = UNIT_KRAKEN_ARID,		PercentChance = 70 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_CLS_UNIT_SPAWN_TABLE_S2_PRIM = {	-- 3
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_PRIM,	PercentChance = 75 },
		{ Unit = UNIT_KRAKEN_PRIM,		PercentChance = 25 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_AMPHIBIAN_PRIM,	PercentChance = 50 },
		{ Unit = UNIT_KRAKEN_PRIM,		PercentChance = 50 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_PRIM,	PercentChance = 30 },
		{ Unit = UNIT_KRAKEN_PRIM,		PercentChance = 70 },
	}, },
};
-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
local WATER_CLS_UNIT_SPAWN_TABLE_S2_FRIG = {	-- 4
	-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
	[1] = { 0.00, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_FRIG,	PercentChance = 75 },
		{ Unit = UNIT_KRAKEN_FRIG,		PercentChance = 25 },
	}, },
	[2] = { 0.35,  
	{
		{ Unit = UNIT_AMPHIBIAN_FRIG,	PercentChance = 50 },
		{ Unit = UNIT_KRAKEN_FRIG,		PercentChance = 50 },
	}, },
	[3] = { 0.65, 
	{ 
		{ Unit = UNIT_AMPHIBIAN_FRIG,	PercentChance = 30 },
		{ Unit = UNIT_KRAKEN_FRIG,		PercentChance = 70 },
	}, },
};
-- ========================
--  AWAKENING STAGE 3 LIST
-- ========================
-- NOTE: A list to generate Spisok Stage 3
local LAND_UNIT_SPAWN_TABLE_S3 = {
	["universal"] = 5,
	[0] = LAND_UNIT_SPAWN_TABLE_S2_LUSH,
	[1] = LAND_UNIT_SPAWN_TABLE_S2_FUNG,
	[2] = LAND_UNIT_SPAWN_TABLE_S2_ARID,
	[3] = LAND_UNIT_SPAWN_TABLE_S2_PRIM,
	[4] = LAND_UNIT_SPAWN_TABLE_S2_FRIG,
};
-- NOTE: A list to generate Spisok Stage 3
local WATER_UNIT_SPAWN_TABLE_S3 = {
	["universal"] = 5,
	[0] = WATER_UNIT_SPAWN_TABLE_S2_LUSH,
	[1] = WATER_UNIT_SPAWN_TABLE_S2_FUNG,
	[2] = WATER_UNIT_SPAWN_TABLE_S2_ARID,
	[3] = WATER_UNIT_SPAWN_TABLE_S2_PRIM,
	[4] = WATER_UNIT_SPAWN_TABLE_S2_FRIG,
};
-- NOTE: A list to generate Spisok Stage 3
local LAND_CLS_UNIT_SPAWN_TABLE_S3 = {
	["universal"] = 5,
	[0] = LAND_CLS_UNIT_SPAWN_TABLE_S2_LUSH,
	[1] = LAND_CLS_UNIT_SPAWN_TABLE_S2_FUNG,
	[2] = LAND_CLS_UNIT_SPAWN_TABLE_S2_ARID,
	[3] = LAND_CLS_UNIT_SPAWN_TABLE_S2_PRIM,
	[4] = LAND_CLS_UNIT_SPAWN_TABLE_S2_FRIG,
};
-- NOTE: A list to generate Spisok Stage 3
local WATER_CLS_UNIT_SPAWN_TABLE_S3 = {
	["universal"] = 5,
	[0] = WATER_CLS_UNIT_SPAWN_TABLE_S2_LUSH,
	[1] = WATER_CLS_UNIT_SPAWN_TABLE_S2_FUNG,
	[2] = WATER_CLS_UNIT_SPAWN_TABLE_S2_ARID,
	[3] = WATER_CLS_UNIT_SPAWN_TABLE_S2_PRIM,
	[4] = WATER_CLS_UNIT_SPAWN_TABLE_S2_FRIG,
};
-- ============================
--  AWAKENING STAGE 1 OF BIOME
-- ============================
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local LAND_TABLE_S1_BIOME = {
	[0] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 1 },
	},
	[1] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 1 },
	},
	[2] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 1 },
	},
	[3] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 1 },
	},
	[4] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 1 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local WATER_TABLE_S1_BIOME = {
	[0] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 1 },
	},
	[1] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 1 },
	},
	[2] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 1 },
	},
	[3] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 1 },
	},
	[4] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 1 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local LAND_CLS_TABLE_S1_BIOME = {
	[0] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 1 },
	},
	[1] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 1 },
	},
	[2] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 1 },
	},
	[3] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 1 },
	},
	[4] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 1 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local WATER_CLS_TABLE_S1_BIOME = {
	[0] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 1 },
	},
	[1] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 1 },
	},
	[2] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 1 },
	},
	[3] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 1 },
	},
	[4] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 99 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 1 },
	},
};
-- ============================
--  AWAKENING STAGE 2 OF BIOME
-- ============================
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local LAND_TABLE_S2_BIOME = {
	[0] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 66 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[1] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 66 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[2] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 66 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[3] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 66 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[4] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 66 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local WATER_TABLE_S2_BIOME = {
	[0] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 66 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[1] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 66 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[2] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 66 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[3] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 66 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[4] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 66 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local LAND_CLS_TABLE_S2_BIOME = {
	[0] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 66 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[1] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 66 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[2] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 66 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[3] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 66 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[4] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 66 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local WATER_CLS_TABLE_S2_BIOME = {
	[0] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 66 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[1] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 66 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[2] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 66 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[3] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 66 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
	[4] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 33 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 66 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 1 },
	},
};

-- ============================
--  AWAKENING STAGE 3 OF BIOME
-- ============================
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local LAND_TABLE_S3_BIOME = {
	[0] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 22 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[1] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 22 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[2] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 22 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[3] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 22 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[4] = 
	{ 
		{ _TABLE = LAND_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 22 },
		{ _TABLE = LAND_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local WATER_TABLE_S3_BIOME = {
	[0] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 22 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[1] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 22 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[2] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 22 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[3] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 22 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[4] = 
	{ 
		{ _TABLE = WATER_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 22 },
		{ _TABLE = WATER_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local LAND_CLS_TABLE_S3_BIOME = {
	[0] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 22 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[1] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 22 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[2] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 22 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[3] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 22 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[4] = 
	{ 
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 22 },
		{ _TABLE = LAND_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
};
-- NOTE: These are normalized tables! Any changes must adjust all weights to add up to 100	
local WATER_CLS_TABLE_S3_BIOME = {
	[0] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_LUSH,	PercentChance = 22 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[1] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_FUNG,	PercentChance = 22 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[2] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_ARID,	PercentChance = 22 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[3] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_PRIM,	PercentChance = 22 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
	[4] = 
	{ 
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE,			PercentChance = 11 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S2_FRIG,	PercentChance = 22 },
		{ _TABLE = WATER_CLS_UNIT_SPAWN_TABLE_S3,		PercentChance = 67 },
	},
};
-- ================== 
--  AWAKENING STAGES 
-- ================== 
local LAND_TABLE_SOA = {
	[0] = LAND_TABLE_S1_BIOME,
	[1] = LAND_TABLE_S1_BIOME,
	[2] = LAND_TABLE_S2_BIOME,
	[3] = LAND_TABLE_S3_BIOME,
	[4] = LAND_TABLE_S3_BIOME,
	[5] = LAND_TABLE_S3_BIOME,
	[6] = LAND_TABLE_S3_BIOME,
	[7] = LAND_TABLE_S3_BIOME,
	[8] = LAND_TABLE_S3_BIOME,
	[9] = LAND_TABLE_S3_BIOME,
	[10] = LAND_TABLE_S3_BIOME,
};
local WATER_TABLE_SOA = {
	[0] = WATER_TABLE_S1_BIOME,
	[1] = WATER_TABLE_S1_BIOME,
	[2] = WATER_TABLE_S2_BIOME,
	[3] = WATER_TABLE_S3_BIOME,
	[4] = WATER_TABLE_S3_BIOME,
	[5] = WATER_TABLE_S3_BIOME,
	[6] = WATER_TABLE_S3_BIOME,
	[7] = WATER_TABLE_S3_BIOME,
	[8] = WATER_TABLE_S3_BIOME,
	[9] = WATER_TABLE_S3_BIOME,
	[10] = WATER_TABLE_S3_BIOME,
};
local LAND_CLS_TABLE_SOA = {
	[0] = LAND_CLS_TABLE_S1_BIOME,
	[1] = LAND_CLS_TABLE_S1_BIOME,
	[2] = LAND_CLS_TABLE_S2_BIOME,
	[3] = LAND_CLS_TABLE_S3_BIOME,
	[4] = LAND_CLS_TABLE_S3_BIOME,
	[5] = LAND_CLS_TABLE_S3_BIOME,
	[6] = LAND_CLS_TABLE_S3_BIOME,
	[7] = LAND_CLS_TABLE_S3_BIOME,
	[8] = LAND_CLS_TABLE_S3_BIOME,
	[9] = LAND_CLS_TABLE_S3_BIOME,
	[10] = LAND_CLS_TABLE_S3_BIOME,
};
local WATER_CLS_TABLE_SOA = {
	[0] = WATER_CLS_TABLE_S1_BIOME,
	[1] = WATER_CLS_TABLE_S1_BIOME,
	[2] = WATER_CLS_TABLE_S2_BIOME,
	[3] = WATER_CLS_TABLE_S3_BIOME,
	[4] = WATER_CLS_TABLE_S3_BIOME,
	[5] = WATER_CLS_TABLE_S3_BIOME,
	[6] = WATER_CLS_TABLE_S3_BIOME,
	[7] = WATER_CLS_TABLE_S3_BIOME,
	[8] = WATER_CLS_TABLE_S3_BIOME,
	[9] = WATER_CLS_TABLE_S3_BIOME,
	[10] = WATER_CLS_TABLE_S3_BIOME,
};

-- Return the unit type id and it's list based on biome, stage, domain, coloss or not.
function LandWaterUnitSpawnTable(soa, biome, domain, colossus)
print("---=== LandWaterUnitSpawnTable Start ---- soa "..tostring(soa)..", biome "..tostring(biome)..", domain "..tostring(domain)..", colossus "..tostring(colossus)) -- dbg
	local _stage = soa or 0;
	-- _stage = 2; -- dbg
	local Biome = biome or 0;
	local Domain = domain or "LAND";
	local Coloss = colossus or false;
	local spawnBiome = {};
	local s_table = {};
	
	-- land or water unit table?
	-- coloss or normal unit table?
	if Domain == "LAND" then 
		if Coloss then
			s_table = LAND_CLS_TABLE_SOA[_stage];
		else
			s_table = LAND_TABLE_SOA[_stage];
		end
	elseif Domain == "WATER" then
		if Coloss then
			s_table = WATER_CLS_TABLE_SOA[_stage];
		else
			s_table = WATER_TABLE_SOA[_stage];
		end
	end
	
	for i, subTable in ipairs(s_table) do
		-- print("CheckBiome:  _TABLE: "..i); -- dbg
		if Biome == i then
			print("CheckBiome:  Take this biome-tables: "..i); -- dbg
			spawnBiome = subTable;
		end
	end
	
	local chosenTable = nil;
	local roll = Game.Rand(100, "Alien Spawn Table selection roll") +1;	

	for i, pair in ipairs(spawnBiome) do
		print("SpawnBiomeTable: "..i..", PercentChance: " .. pair.PercentChance.. ", Roll: ".. roll); -- dbg
		if (roll <= pair.PercentChance) then
			local BiomeTable = pair._TABLE;
			if BiomeTable["universal"] ~= nil then
				local roll_b = Game.Rand(BiomeTable["universal"], "Alien universal biome roll");	
				print("This SpawnBiomeTable is universal for any biome. Roll biome number "..(roll_b+1).." from " .. BiomeTable["universal"]); -- dbg
				BiomeTable = BiomeTable[roll_b];
			else
				print("This SpawnBiomeTable is regular"); -- dbg
			end
			return BiomeTable, i;
		else
			roll = roll - pair.PercentChance;
		end
	end	

	print("LandWaterUnitSpawnTable WARNING! cant return table") -- dbg
	return -1;
	-----------------------------------------------------------------------------------
end;

-- Application of Stage
function AwakeningStageApp(unit, unittype, stage, listnumber)
print("AwakeningStageApp stage/list "..tostring(stage).."/"..tostring(listnumber)) -- dbg
	if unit == nil then return -1 end;
	if stage == nil or stage == 0 then return -1 end;
	-- stage = 2; -- dbg
	if unittype == nil then return -1 end;
	if listnumber == nil then return -1 end;
	local udomain = GameInfo.Units[unittype].Domain;
	local promo;
	print("udomain: "..tostring(udomain)); -- dbg
	
	-----------------------------------------------------------------------------------
	-- Awakening Stage Promotions
	if stage == 1 then
		-- return true;
	end

	if stage == 2 then
		if udomain == "DOMAIN_LAND" or udomain == "DOMAIN_HOVER" or udomain == "DOMAIN_AMPHIBIOUS" then
			local roll = Game.Rand(2, "Alien Stage 2 Heal Promo");
			if roll > 0 then
				unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_ALIEN_STAGE_2_1"].ID, true)
				print("Heal setted") -- dbg
			end
		end	
		local roll = 1+ Game.Rand(#PROMOTION_ALIEN_STAGE_2, "Alien Stage 2 Random Promo");
		-- print("promo roll "..tostring(roll)); -- dbg
		promo = PROMOTION_ALIEN_STAGE_2[roll];
		print("random promo string "..tostring(promo)); -- dbg
		unit:SetHasPromotion(GameInfo.UnitPromotions[promo].ID, true)
		-- print("Random setted") -- dbg
		-- return true;
	end

	if stage >= 3 then
		if udomain == "DOMAIN_LAND" or udomain == "DOMAIN_HOVER" or udomain == "DOMAIN_AMPHIBIOUS" then
			local roll = Game.Rand(2, "Alien Stage 3 Heal Promo");
			if roll > 0 then
				unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_ALIEN_STAGE_3_1"].ID, true)
				print("Heal setted") -- dbg
			end
		end	
		local roll = 1+ Game.Rand(#PROMOTION_ALIEN_STAGE_3, "Alien Stage 3 Random Promo");
		-- print("promo roll "..tostring(roll)); -- dbg
		promo = PROMOTION_ALIEN_STAGE_3[roll];
		print("random promo string "..tostring(promo)); -- dbg
		unit:SetHasPromotion(GameInfo.UnitPromotions[promo].ID, true)
		-- print("Random setted") -- dbg
		-- return true;
	end
	
	-----------------------------------------------------------------------------------
	-- Awakening Stage List Promotions	
	if listnumber == 1 then
		-- return true;
	end

	if listnumber == 2 then
		if udomain == "DOMAIN_LAND" or udomain == "DOMAIN_HOVER" or udomain == "DOMAIN_AMPHIBIOUS" then
			local roll = 1+ Game.Rand(#PROMOTION_ALIEN_STAGE_LIST_2, "Alien Stage List 2 Random Promo");
			-- print("promo roll "..tostring(roll)); -- dbg
			promo = PROMOTION_ALIEN_STAGE_LIST_2[roll];
			print("random promo string "..tostring(promo)); -- dbg
			unit:SetHasPromotion(GameInfo.UnitPromotions[promo].ID, true)
		end	
	end

	if listnumber == 3 then
		if udomain == "DOMAIN_LAND" or udomain == "DOMAIN_HOVER" or udomain == "DOMAIN_AMPHIBIOUS" then
			local roll = 1+ Game.Rand(#PROMOTION_ALIEN_STAGE_LIST_3, "Alien Stage List 3 Random Promo");
			-- print("promo roll "..tostring(roll)); -- dbg
			promo = PROMOTION_ALIEN_STAGE_LIST_3[roll];
			print("random promo string "..tostring(promo)); -- dbg
			unit:SetHasPromotion(GameInfo.UnitPromotions[promo].ID, true)
		end	
	end
	
	-----------------------------------------------------------------------------------
	-- Awakening Stage List Upgrades	
	if stage == 1 then
		-- return true;
	end 
	
	if stage == 2 and (not AwStage2Upgraded) then
		AwStage2Upgraded = true; ModSaveDB.SetValue("AwStage2Upgraded", true);
		local g_ALIEN_PLAYER = Players[GameDefines.ALIEN_PLAYER];
		local Biome = Game.GetPlanet();
		for i, UnitInfo in ipairs(ALIENS_STAGE_LIST_2[Biome]) do
			local roll = 1+ Game.Rand(#UNITUPGRADE_ALIENS_STAGE_2, "Alien Stage List 2 Upgrade");
			for playerType = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
				local player = Players[playerType];
				player:AssignUnitUpgrade( UnitInfo.ID, UNITUPGRADE_ALIENS_STAGE_2[roll].Upgrade.ID, UNITUPGRADE_ALIENS_STAGE_2[roll].Perk.ID);
			end
			print("stage 2 upgrade unit/perk "..tostring(UnitInfo.Type).."/"..tostring(UNITUPGRADE_ALIENS_STAGE_2[roll].Perk.Type)); -- dbg
		end
	end
	
	if stage == 3 and (not AwStage3Upgraded) then
		AwStage3Upgraded = true; ModSaveDB.SetValue("AwStage3Upgraded", true);
		local g_ALIEN_PLAYER = Players[GameDefines.ALIEN_PLAYER];
		local Biome = Game.GetPlanet();
		for i, UnitInfo in ipairs(ALIENS_STAGE_LIST_3) do
			local roll = 1+ Game.Rand(#UNITUPGRADE_ALIENS_STAGE_3, "Alien Stage List 3 Upgrade");
			for playerType = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
				local player = Players[playerType];
				-- g_ALIEN_PLAYER:AssignUnitUpgrade( UnitInfo.ID, UNITUPGRADE_ALIENS_STAGE_3[roll].Upgrade.ID, UNITUPGRADE_ALIENS_STAGE_3[roll].Perk.ID);
				player:AssignUnitUpgrade( UnitInfo.ID, UNITUPGRADE_ALIENS_STAGE_3[roll].Upgrade.ID, UNITUPGRADE_ALIENS_STAGE_3[roll].Perk.ID);
			end
			print("stage 3 upgrade unit/perk "..tostring(UnitInfo.Type).."/"..tostring(UNITUPGRADE_ALIENS_STAGE_3[roll].Perk.Type)); -- dbg
		end
	end

end;
