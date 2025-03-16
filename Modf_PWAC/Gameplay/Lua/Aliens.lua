--MGH Modified
---- 2023 - Blessed by Protok
----
----------------------------------------------------
-- DBG PRINT OUT
----------------------------------------------------
local dbg_NT = true;
dbg_NT = false;
local _dpo = true;
_dpo = false;
if _dpo then print("Aliens.lua Start ---------------------------------------- ") end
----------------------------------------------------
-- INCLUDE
----------------------------------------------------
include( "MathHelpers" );
include( "AliensTables" );
include( "MapmakerUtilities" );
include( "MapUtilities");
include( "AlienTurnCounter"); -- new counter system of Planet stats

----------------------------------------------------
-- Data
----------------------------------------------------
-- DBG NATURE TEST; quick switch off for 
-- 1) miasma spreading
-- 2) nests spawn
-- 3) aliens spawn by nests

-- save sysytem
local DatalinksDB = Modding.OpenUserData("AC_Datalinks", 1);
local SaveDB = Modding.OpenSaveData();
local thisTurn = Game.GetGameTurn()

-- constants
local direction_types = {
	DirectionTypes.DIRECTION_NORTHEAST,
	DirectionTypes.DIRECTION_EAST,
	DirectionTypes.DIRECTION_SOUTHEAST,
	DirectionTypes.DIRECTION_SOUTHWEST,
	DirectionTypes.DIRECTION_WEST,
	DirectionTypes.DIRECTION_NORTHWEST
	};

local UNIT_HYDRA_LVL1	= GameInfo.Units["UNIT_ALIEN_HYDRA_LVL1"];
local UNIT_HYDRA_LVL2	= GameInfo.Units["UNIT_ALIEN_HYDRA_LVL2"];
local UNIT_HYDRA_LVL3	= GameInfo.Units["UNIT_ALIEN_HYDRA_LVL3"];

local UNIT_KRAKEN 		= GameInfo.Units["UNIT_ALIEN_KRAKEN"];
local UNIT_SIEGE_WORM 	= GameInfo.Units["UNIT_ALIEN_SIEGE_WORM"];

local HYDRA_SEED_CHANCE_OCEAN = 8;
local HYDRA_SEED_CHANCE_TRENCH = 10;
local HYDRA_SEED_CHANCE_WILD_AREA = 10;
local HYDRA_MIN_DIST_TO_PLAYER_START = 2;

local HYDRA_LIFE_CYCLE_INTERVAL = 4;	-- Hydra units update once every X turns
-- local HYDRA_LIFE_CYCLE_INTERVAL = 1;	-- test
local HYDRA_LVL1_GROW_CHANCE = 15;
local HYDRA_LVL2_GROW_CHANCE = 10;
local HYDRA_LVL3_GROW_CHANCE = 5;		-- 10 is too much after fix grow
local HYDRA_LVL3_WITHER_CHANCE = 15;

local COLOSSAL_START_TURN = GameDefines["ALIEN_SPAWN_COLOSSAL_START_TURN_MIN"];
--MGH:TODO:Change again¡¡¡¡!!!!
local NEST_MIN_SPAWN_TURNS = 14; --14 GameDefines["ALIEN_NEST_MIN_SPAWN_RATE"];
local NEST_MAX_SPAWN_TURNS = 20; --20 GameDefines["ALIEN_NEST_MAX_SPAWN_RATE"];
local NEST_BASE_RATE  = 22.5; --22.5 GameDefines["ALIEN_NEST_PW_BASE_RATE"];
local NEST_RECOVERY_RATE = 30; --25 GameDefines["ALIEN_NEST_RECOVERY_RATE"];
local NEST_SPAWN_LATE_TURNS = 200; --When we are in later turns try to reduce the spawn of nests a bit
local NEST_SPAWN_LATE_TURNS_INCREMENT = 6;--Add to min/max when we are over a late turn
local NEST_SPAWN_RANDOMIZE = 5;-- +/-NEST_SPAWN_RANDOMIZE to calculated value

-- local MIASMA_CYCLE_INTERVAL = 8;	-- Miasma try to spread once every X turns
local MIASMA_CYCLE_INTERVAL = 1;	-- Now it's that. *100 for precise 10000 chance, /8 for shift to 1/8 per turn.
local MIASMA_SPREAD_CHANCE  = 3*100/7;
local MIASMA_DISPERSE_CHANCE = 2.5*100/7;

-- SPAWN TABLES
-- Governs spawn distribution for the various alien unit types based on the
--	average dominant affinity progress for all active players (rough game progress heuristic)

-- NOTE: This must be a table of tables in order for Lua to index them by integer and ensure deterministic iteration (necessary for multiplayer)
-- local LAND_UNIT_SPAWN_TABLE
-- local WATER_UNIT_SPAWN_TABLE
-- tables moved to: AliensTables.lua

-- Governs how many colossal units are maintained per game phase
local COLOSSAL_LAND_UNIT_RATIOS = {
	[1] = { 0.00, 32, },
	[2] = { 0.35, 26, },
	[3] = { 0.65, 20, },
};

local COLOSSAL_SEA_UNIT_RATIOS = {
	[1] = { 0.00, 36, },
	[2] = { 0.35, 30, },
	[3] = { 0.65, 24, },
};

local g_ALIEN_PLAYER = Players[GameDefines.ALIEN_PLAYER];
-----=============================

-----=============================
-- USE OF ALIEN TURN COUNTER
local AlienTurnStats = AlienTurnCounter.Create()

-- This will make it work at game started or loaded
-- And give the stats for first TryGetNormalUnitToSpawn
AlienTurnStats:GetAverageDominantAffinityProgress();
AlienTurnStats:GetGlobalAlienOpinion();
AlienTurnStats:GetGlobalAlienTension();
AlienTurnStats:EveryTileStatCounter();
AlienTurnStats:GetCivilizationExpansionFactor();
AlienTurnStats:GetAlienAwakeningStage();
AlienTurnStats:GetAlienUnitsStats();
-----=============================
-- shortcut stats for this script, updated in OnUpdateUnits()
local AAStage = AlienTurnStats.AlienAwakeningStage
local NestIndices = AlienTurnStats.AnyNestPlotsIndices
local ForNestIndices = AlienTurnStats.FitForAnyNestPlotsIndices
local AffinityIndicesNum = #AlienTurnStats.AffinityResPlotsIndices
local ForMiasmaIndices = AlienTurnStats.FitForMiasmaPlotsIndices
local MiasmaIndices = AlienTurnStats.MiasmaPlotsIndices
local PossibleMiasmaIndicesNum = #AlienTurnStats.EverFitForMiasmaPlotsIndices
local CefSeaIndicesNum = #AlienTurnStats.SeaFECablePlotsIndices
local CefLandIndicesNum = #AlienTurnStats.LandFECablePlotsIndices

-- variables of miasma
local MSpreadTotal = SaveDB.GetValue("MSpreadT_"..(thisTurn-1)) or 0;
local MDisperseTotal = SaveDB.GetValue("MDispT_"..(thisTurn-1)) or 0;
-- local SpreadGeneralChance = SaveDB.GetValue("MSpreadChT_"..thisTurn) or 0;
-- local DisperseGeneralChance = SaveDB.GetValue("MDispChT_"..thisTurn) or 0;
local LMPercent = #MiasmaIndices / (PossibleMiasmaIndicesNum/100); 
LMPercent = LMPercent - LMPercent%0.1;

-- variables to save for VM_MiasmaStats -- to load stats on game loading
SaveDB.SetValue("PossibleMiasmaIndicesNum", PossibleMiasmaIndicesNum);
SaveDB.SetValue("MiasmaIndicesNum", #MiasmaIndices);
SaveDB.SetValue("LMPercent", LMPercent);


-- ===========================================================================
-- General Methods
-- ===========================================================================
function OnNewGameInit()
	if _dpo then print("OnNewGameInit Start ---------------------------------------- ") end

	-- Adjust turn interval for game speed
	local gameSpeedType = Game.GetGameSpeedType();
	local gameSpeedInfo = GameInfo.GameSpeeds[gameSpeedType];
	-- 	moved to UpdateHydraUnits for fixing the save loading missings
	-- if (gameSpeedInfo ~= nil and gameSpeedInfo.AlienSpawnMod ~= nil) then
		-- HYDRA_LIFE_CYCLE_INTERVAL = math.ceil((HYDRA_LIFE_CYCLE_INTERVAL * gameSpeedInfo.AlienSpawnMod) / 100);
	-- end

	-- Spawn initial Hydracoral seed nodes based on deep-water and trench plots
	for i = 0, Map.GetNumPlots()-1, 1 do
		local plot = Map.GetPlotByIndex(i);
		if (plot:IsWater()) then
			-- Restrictions
			local plotValid = true;

			local nearestPlayerStart = Map.FindNearestStartPlot(plot:GetX(), plot:GetY());
			if (nearestPlayerStart ~= nil and Map.PlotDistance(plot:GetX(), plot:GetY(), nearestPlayerStart:GetX(), nearestPlayerStart:GetY()) <= HYDRA_MIN_DIST_TO_PLAYER_START) then
				plotValid = false;
			end
			-- Check validity for Hydra lvl 3 since it has the most restrictions
			if (Aliens.IsPlotValidForAlienUnitSpawn(plot, UNIT_HYDRA_LVL3.ID) == false) then
				plotValid = false;
			end
			
			if (plotValid) then
				-- accumulate chance to seed Hydracoral based on plot characteristics
				local totalChance = 0;
				-- Hydracoral must spawn on deep or trench
				if (plot:GetTerrainType() == TerrainTypes.TERRAIN_OCEAN) then
					totalChance = totalChance + HYDRA_SEED_CHANCE_OCEAN;
				elseif (plot:GetTerrainType() == TerrainTypes.TERRAIN_TRENCH) then
					totalChance = totalChance + HYDRA_SEED_CHANCE_TRENCH;
				end				
				if (totalChance > 0) then
					-- Bump chance for wildness
					if (plot:GetWildness() > 0) then
						totalChance = totalChance + HYDRA_SEED_CHANCE_WILD_AREA;
					end

					if (totalChance > 0) then
						local roll = Game.Rand(100, "Hydracoral seed spawn roll")+1;
						if (roll <= totalChance) then
							-- New Hydracoral will be made, determine if lvl 2 or 3
							roll = Game.Rand(100, "Hydracoral seed spawn roll for level")+1;
							if (roll >= 66) then
								local newUnit = g_ALIEN_PLAYER:InitUnit(UNIT_HYDRA_LVL2.ID, plot:GetX(), plot:GetY(), NO_UNITAI, direction_types[1+Game.Rand(6, "Update Hydras - direction for LVL3")]);
							else
								local newUnit = g_ALIEN_PLAYER:InitUnit(UNIT_HYDRA_LVL3.ID, plot:GetX(), plot:GetY(), NO_UNITAI, direction_types[1+Game.Rand(6, "Update Hydras - direction for LVL3")]);
							end						
						end
					end
				end
			end
		end
	end

	-- Run several update loops on Hydra units to set up initial sprawl state
	for i = 0, 3 do
		UpdateHydraUnits(true);	
	end

end

-- Happens each turn as part of Aliens::DoTurn process
-- Between Normal Aliens and Colossal
-- before tile iterator
function OnUpdateUnits()
	if _dpo then
		print("--------------------- OnUpdateAlienUnits ------------------- ")
		print("--------------------- TURN: "..Game.GetGameTurn().." ------------------------ ")
	end
		
	AlienTurnStats:GetAverageDominantAffinityProgress();
	AlienTurnStats:GetGlobalAlienOpinion();
	AlienTurnStats:GetGlobalAlienTension();
	AlienTurnStats:EveryTileStatCounter();
	AlienTurnStats:GetCivilizationExpansionFactor();
	AlienTurnStats:GetAlienAwakeningStage();
	
	-- stats for script
	AAStage = AlienTurnStats.AlienAwakeningStage
	NestIndices = AlienTurnStats.AnyNestPlotsIndices
	ForNestIndices = AlienTurnStats.FitForAnyNestPlotsIndices
	AffinityIndicesNum = #AlienTurnStats.AffinityResPlotsIndices
	ForMiasmaIndices = AlienTurnStats.FitForMiasmaPlotsIndices
	MiasmaIndices = AlienTurnStats.MiasmaPlotsIndices
	PossibleMiasmaIndicesNum = #AlienTurnStats.EverFitForMiasmaPlotsIndices
	CefSeaIndicesNum = #AlienTurnStats.SeaFECablePlotsIndices
	CefLandIndicesNum = #AlienTurnStats.LandFECablePlotsIndices
		
	-- alien spawners
	UpdateNests();
	UpdateMiasma();
	UpdateHydraUnits();
	
	AlienTurnStats:GetAlienUnitsStats();	-- take alien stats
	
	if _dpo then
		--print("Game.GetMaxTurns() = "..tostring(Game.GetMaxTurns()));
		print("--------------------- OnUpdateAlienUnits ------------------- ") -- dbg
		print("--------------------- DONE: "..Game.GetGameTurn().." ------------------------ ")
	end
end

function OnPlayerOpinionChanged(playerType)
	if _dpo then print("OnPlayerOpinionChanged: Player: ".. playerType) end
	local _dpo = true;
	 _dpo = false;
	local player;
	local alienOpinion;

	for i = 0, 63 do
		if i == playerType then
			player = Players[i];
			if player:IsMajorCiv() and player:IsAlive() then
				alienOpinion = Aliens.GetOpinionForPlayer(i);
				if alienOpinion == 0 then
					alienOpinion = "0 - NEUTRAL";
				elseif alienOpinion == 1 then
					alienOpinion = "1 - FRIENDLY";
				elseif alienOpinion == 2 then
					alienOpinion = "2 - HOSTILE";
				elseif alienOpinion == 3 then
					alienOpinion = "3 - VERY_HOSTILE";
				end;
				if _dpo then print("Player "..i..": ".. tostring(GameInfo.Civilizations[Players[i]:GetCivilizationType()].Type) .. " Changed AlienOpinoin to: " .. tostring(alienOpinion)); end;
			end
		end
	end
end

-- ===========================================================================
-- Unit Spawning Methods
-- ===========================================================================

-- Get a land unit to spawn at the given location from the weighted spawn tables
function GetWeightedUnitTypeToSpawn(plotX, plotY, iscoloss)
	if _dpo then print("---=== GetWeightedUnitTypeToSpawn Start ===---") end
	local _dpo = true;
	  _dpo = false;
	if Map.GetPlot(plotX, plotY):HasAlienNest() then
		if _dpo then print("Plot "..plotX..", "..plotY.." has got a nest") end
	else
		if _dpo then print("Plot "..plotX..", "..plotY.." has not got a nest") end
	end
	local _stage = AAStage or 0;
	local Biome = Game.GetPlanet();
	local spawnSite = Map.GetPlot(plotX, plotY);
	local Iscoloss = iscoloss or false;
	-- local averageAffinityProgress = Game.GetAverageDominantAffinityProgress();
	local GlobalAlienTension = AlienTurnStats.GlobalAlienTension or 0.01;

	if AlienTurnStats.ADAP_doneThisTurn == false then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = false THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == nil then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = nil THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == true then
		if _dpo then print("GlobalAlienTension: " .. tostring(GlobalAlienTension)); end
	end

	local domainTable;
	local listnumber; -- a mark for stages app
	if (spawnSite:IsWater()) then
		-- domainTable = WATER_UNIT_SPAWN_TABLE;
		domainTable, listnumber = LandWaterUnitSpawnTable(_stage, Biome, "WATER", Iscoloss);
		-- if domainTable["universal"] ~= nil then
			-- local roll_b = Game.Rand(domainTable["universal"], "Alien universal biome roll");	
			-- print("This SpawnBiomeTable is universal for any biome. Roll biome number "..roll_b.." from " .. domainTable["universal"]); -- dbg
			-- domainTable = domainTable[roll_b];
		-- else
			-- print("This SpawnBiomeTable is regular"); -- dbg
		-- end
	else
		-- domainTable = LAND_UNIT_SPAWN_TABLE;
		domainTable, listnumber = LandWaterUnitSpawnTable(_stage, Biome, "LAND", Iscoloss);
		-- if domainTable["universal"] ~= nil then
			-- local roll_b = Game.Rand(domainTable["universal"], "Alien universal biome roll");	
			-- print("This SpawnBiomeTable is universal for any biome. Roll biome number "..roll_b.." from " .. domainTable["universal"]); -- dbg
			-- domainTable = domainTable[roll_b];
		-- else
			-- print("This SpawnBiomeTable is regular"); -- dbg
		-- end
	end

	-- averageAffinityProgress = 0.40; -- dbg
	-- GlobalAlienTension = 0.40; -- dbg
	local spawnTable = {};

	-- Protok: pairs order is totally broken
	-- for k, subTable in pairs(domainTable) do
		-- print("GetWeightedUnitTypeToSpawn: k: " .. tostring(k)); -- dbg
		-- if (averageAffinityProgress >= k) then
			-- spawnTable = subTable;
		-- end
	-- end
	
	for i, subTable in ipairs(domainTable) do
		if (GlobalAlienTension >= subTable[1]) then
			spawnTable = subTable[2];
			if _dpo then print("SpawnTable: " .. tostring(i).. ", started from: ".. tostring(subTable[1]).. ", taken with GlobalAlienTension: ".. tostring(GlobalAlienTension)); end
		end
	end

	local roll = Game.Rand(100, "Alien Spawn Unit selection roll") +1;

	for i, pair in ipairs(spawnTable) do
		if _dpo then print("SpawnTableEntry:  AlienType: " .. pair.Unit.Type .. " PercentChance: " .. pair.PercentChance.. " Roll: ".. roll .. ", Site(x,y): "..plotX..", "..plotY); end
		if (roll <= pair.PercentChance) then
			return pair.Unit.ID, listnumber;
		else
			roll = roll - pair.PercentChance;
		end
	end

	-- Something went wrong if there were no units returned
	return -1;
end

-- Determine what (if any) normal sea/land unit to spawn this turn
function TryGetNormalUnitToSpawn(domainType)
	if _dpo then print("---=== TryGetNormalUnitToSpawn Start ---- domainType: "..tostring(domainType).." ===---") end
	local _dpo = true;
	 _dpo = false;
	-- Rules:
	-- Returns a unit based on spawn tables for the current game phase (based on average affinity progress)
	-- Will return -1 if the aliens are already at saturation
	local _stage = AAStage or 0;
	local Biome = Game.GetPlanet();
	-- local averageAffinityProgress = Game.GetAverageDominantAffinityProgress();
	local GlobalAlienTension = AlienTurnStats.GlobalAlienTension or 0.01;

	if AlienTurnStats.ADAP_doneThisTurn == false then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = false THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == nil then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = nil THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == true then
		if _dpo then print("GlobalAlienTension: " .. tostring(GlobalAlienTension)); end
	end

	-- Domain data
	local numCurrentUnits = ALIENS.GetNumNormalUnits(domainType);
	local numDomainUnitsLost = 0;
	local numDomainPlots = 0;
	local domainTable;

	if (domainType == DomainTypes.DOMAIN_LAND) then
		numDomainUnitsLost = Aliens.GetTotalLandUnitsLost();
		numDomainPlots = Map.GetLandPlots();
		-- domainTable = LAND_UNIT_SPAWN_TABLE;		
		domainTable = LandWaterUnitSpawnTable(_stage, Biome, "LAND");
		-- if domainTable["universal"] ~= nil then
			-- local roll_b = Game.Rand(domainTable["universal"], "Alien universal biome roll");	
			-- print("This SpawnBiomeTable is universal for any biome. Roll biome number "..roll_b.." from " .. domainTable["universal"]); -- dbg
			-- domainTable = domainTable[roll_b];
		-- else
			-- print("This SpawnBiomeTable is regular"); -- dbg
		-- end
	else -- Sea
		numDomainUnitsLost = Aliens.GetTotalSeaUnitsLost();
		-- numDomainPlots = Map.GetWaterPlots() - Map.GetLakePlots();
		numDomainPlots = Map.GetWaterPlots();
		-- domainTable = WATER_UNIT_SPAWN_TABLE;
		domainTable = LandWaterUnitSpawnTable(_stage, Biome, "WATER");
		-- if domainTable["universal"] ~= nil then
			-- local roll_b = Game.Rand(domainTable["universal"], "Alien universal biome roll");	
			-- print("This SpawnBiomeTable is universal for any biome. Roll biome number "..roll_b.." from " .. domainTable["universal"]); -- dbg
			-- domainTable = domainTable[roll_b];
		-- else
			-- print("This SpawnBiomeTable is regular"); -- dbg
		-- end
	end
	
	if (domainTable == nil) then
		error("TryGetNormalUnitToSpawn: spawn table is nil!");
		return -1;
	end

	local spawnTable = {};
	
	-- Protok: pairs order is totally broken
	-- for k, subTable in pairs(domainTable) do
		-- if (averageAffinityProgress >= k) then
			-- spawnTable = subTable;
		-- end
	-- end

	for i, subTable in ipairs(domainTable) do
		if (GlobalAlienTension >= subTable[1]) then
			spawnTable = subTable[2];
			if _dpo then print("SpawnTable: " .. tostring(i).. ", started from: ".. tostring(subTable[1]).. ", taken with GlobalAlienTension ".. tostring(GlobalAlienTension)); end
		end
	end

	local idealRatio = 100 / GameDefines.ALIEN_SEED_MAX_MAP_DENSITY;
	local currentRatio = ZeroSafeRatio(numDomainPlots, numCurrentUnits);
	if _dpo then print("Domain idealRatio: " .. tostring(idealRatio).. ", currentRatio: ".. tostring(currentRatio).. " (DomainPlots=".. tostring(numDomainPlots).."/normalUnits="..tostring(numCurrentUnits)..")"); end
	if (currentRatio > idealRatio) then		
		
		-- Spawn chance base is 10%, 20% if the ratio is greater than 2		
		local spawnChance = 10;

		local ratioRatio = ZeroSafeRatio(currentRatio, idealRatio);
		if (ratioRatio > 2) then
			spawnChance = 20;
		end

		-- spawnChance = 100 -- dbg

		local chance = Game.Rand(100, "TryGetNormalUnitToSpawn: spawn chance") +1;
		if _dpo then print("SpawnChance: " .. tostring(spawnChance).. ", and roll: ".. tostring(chance)); end
		if (chance <= spawnChance) then

			local roll = Game.Rand(100, "TryGetNormalUnitToSpawn: selection roll") +1;

			for i, pair in ipairs(spawnTable) do
				-- print("SpawnTableEntry:  AlienType: " .. pair.Unit.Type .. " PercentChance: " .. pair.PercentChance.. " Roll: ".. roll .. ", Site(x,y): "..plotX..", "..plotY);
				if _dpo then print("SpawnTableEntry:  AlienType: " .. pair.Unit.Type .. " PercentChance: " .. pair.PercentChance.. " Roll: ".. roll); end
				if (roll <= pair.PercentChance) then
					return pair.Unit.ID;
				else
					roll = roll - pair.PercentChance;
				end
			end
			
		else
			-- Safe exit -- no unit rolled this turn
			return -1;
		end
	end

	-- No unit this turn
	return -1;
end

-- AI routine to determine what, if any, colossal unit type to spawn at this time (may return none)
function TryGetColossalUnitToSpawn(domainType)
	if _dpo then print("TryGetColossalUnitToSpawn Start ---- domainType: "..tostring(domainType).."  ") end
	
	if domainType == DomainTypes.DOMAIN_LAND then
		return GetColossalLandUnitToSpawn();
	elseif domainType == DomainTypes.DOMAIN_SEA then
		return GetColossalSeaUnitToSpawn();
	else
		if _dpo then print("TryGetColossalUnitToSpawn [Lua]: Unhandled domain type"); end
	end

	return -1;
end

-- Determine what (if any) LAND colossal unit to spawn this turn
function GetColossalLandUnitToSpawn()
	if _dpo then print("---=== GetColossalLandUnitToSpawn Start ===--- ") end
	local _dpo = true;
	 _dpo = false;

	-- Rules:
	-- Colossal units are maintained as a sliding ratio of 
	-- num units to total normal units active.

	-- Gate against colossal units start turn
	if (Game.GetGameTurn() < COLOSSAL_START_TURN) then
		if _dpo then print("Not a colossal start turn now. Which is: " .. tostring(COLOSSAL_START_TURN)); end
		return -1;
	end

	local _stage = AAStage or 0;
	local Biome = Game.GetPlanet();
	-- local averageAffinityProgress = Game.GetAverageDominantAffinityProgress();
	local GlobalAlienTension = AlienTurnStats.GlobalAlienTension or 0.01;

	if AlienTurnStats.ADAP_doneThisTurn == false then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = false THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == nil then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = nil THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == true then
		if _dpo then print("GlobalAlienTension: " .. tostring(GlobalAlienTension)); end
	end
	
	local idealRatio = 0.0;
	
	-- Protok: pairs order is totally broken
	-- for k, ratio in pairs(COLOSSAL_LAND_UNIT_RATIOS) do
		-- if (averageAffinityProgress >= k) then
			-- idealRatio = ratio;
			-- print("idealRatio: " .. tostring(ratio).. ", started from: ".. tostring(k).. ", taken with ".. tostring(averageAffinityProgress)); -- dbg
		-- end
	-- end	
	
	for i, ratio in ipairs(COLOSSAL_LAND_UNIT_RATIOS) do
		if (GlobalAlienTension >= ratio[1]) then
			idealRatio = ratio[2];
			if _dpo then print("idealRatio: " .. tostring(ratio[2]).. ", started from: ".. tostring(ratio[1]).. ", taken with GlobalAlienTension ".. tostring(GlobalAlienTension)); end
		end
	end

	local numNormalUnits = ALIENS.GetNumNormalUnits(DomainTypes.DOMAIN_LAND);
	local numColossalUnits = ALIENS.GetNumColossalUnits(DomainTypes.DOMAIN_LAND);

	local currentRatio = ZeroSafeRatio(numNormalUnits, numColossalUnits);
	if _dpo then print("Domain Land idealRatio: " .. tostring(idealRatio).. ", currentRatio: ".. tostring(currentRatio).. " (normalUnits=".. tostring(numNormalUnits).."/colossal="..tostring(numColossalUnits)..")"); end

	if (currentRatio > idealRatio) then
		if _dpo then print("Spawn Coloss"); end
		local domainTable = LandWaterUnitSpawnTable(_stage, Biome, "LAND", true);
	
		local spawnTable = {};
		
		for i, subTable in ipairs(domainTable) do
			if (GlobalAlienTension >= subTable[1]) then
				spawnTable = subTable[2];
				if _dpo then print("SpawnTable: " .. tostring(i).. ", started from: ".. tostring(subTable[1]).. ", taken with GlobalAlienTension ".. tostring(GlobalAlienTension)); end
			end
		end

		local roll = Game.Rand(100, "Alien Spawn Unit selection roll") +1;		
			
		for i, pair in ipairs(spawnTable) do
			if _dpo then print("SpawnTableEntry:  AlienType: " .. pair.Unit.Type .. " PercentChance: " .. pair.PercentChance.. " Roll: ".. roll .. ", Site(x,y): "..tostring(plotX)..", "..tostring(plotY)); end
			if (roll <= pair.PercentChance) then
				return pair.Unit.ID;
			else
				roll = roll - pair.PercentChance;
			end
		end
		-- Something went wrong if there were no units returned
		return -1;
		-- return UNIT_SIEGE_WORM.ID;
	else
		if _dpo then print("No spawn Coloss"); end
	end

	return -1;
end

-- Determine what (if any) SEA colossal unit to spawn this turn
function GetColossalSeaUnitToSpawn()
	if _dpo then print("---=== GetColossalSeaUnitToSpawn Start ===---") end
	local _dpo = true;
	 _dpo = false;

	-- Rules:
	-- Colossal units are maintained as a sliding ratio of 
	-- num units to total normal units active.

	-- Gate against colossal units start turn
	if (Game.GetGameTurn() < COLOSSAL_START_TURN) then
		if _dpo then print("Not a colossal start turn now. Which is: " .. tostring(COLOSSAL_START_TURN)); end
		return -1;
	end

	local _stage = AAStage or 0;
	local Biome = Game.GetPlanet();
	-- local averageAffinityProgress = Game.GetAverageDominantAffinityProgress();
	local GlobalAlienTension = AlienTurnStats.GlobalAlienTension or 0.01;

	if AlienTurnStats.ADAP_doneThisTurn == false then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = false THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == nil then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = nil THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == true then
		if _dpo then print("GlobalAlienTension: " .. tostring(GlobalAlienTension)); end
	end

	local idealRatio = 0.0;
	
	-- Protok: pairs order is totally broken
	-- for k, ratio in pairs(COLOSSAL_SEA_UNIT_RATIOS) do
		-- if (averageAffinityProgress >= k) then
			-- idealRatio = ratio;
			-- print("idealRatio: " .. tostring(ratio).. ", started from: ".. tostring(k).. ", taken with ".. tostring(averageAffinityProgress)); -- dbg
		-- end
	-- end

	for i, ratio in ipairs(COLOSSAL_SEA_UNIT_RATIOS) do
		if (GlobalAlienTension >= ratio[1]) then
			idealRatio = ratio[2];
			if _dpo then print("idealRatio: " .. tostring(ratio[2]).. ", started from: ".. tostring(ratio[1]).. ", taken with GlobalAlienTension ".. tostring(GlobalAlienTension)); end
		end
	end
	
	local numNormalUnits = ALIENS.GetNumNormalUnits(DomainTypes.DOMAIN_SEA);
	local numColossalUnits = ALIENS.GetNumColossalUnits(DomainTypes.DOMAIN_SEA);

	local currentRatio = ZeroSafeRatio(numNormalUnits, numColossalUnits);
	if _dpo then print("Domain Sea idealRatio: " .. tostring(idealRatio).. ", currentRatio: ".. tostring(currentRatio).. " (normalUnits=".. tostring(numNormalUnits).."/colossal="..tostring(numColossalUnits)..")"); end

	if (currentRatio > idealRatio) then
		if _dpo then print("Spawn Coloss"); end
		local domainTable = LandWaterUnitSpawnTable(_stage, Biome, "WATER", true);
	
		local spawnTable = {};
		
		for i, subTable in ipairs(domainTable) do
			if (GlobalAlienTension >= subTable[1]) then
				spawnTable = subTable[2];
				if _dpo then print("SpawnTable: " .. tostring(i).. ", started from: ".. tostring(subTable[1]).. ", taken with GlobalAlienTension ".. tostring(GlobalAlienTension)); end
			end
		end

		local roll = Game.Rand(100, "Alien Spawn Unit selection roll") +1;		
			
		for i, pair in ipairs(spawnTable) do
			if _dpo then print("SpawnTableEntry:  AlienType: " .. pair.Unit.Type .. " PercentChance: " .. pair.PercentChance.. " Roll: ".. roll .. ", Site(x,y): "..tostring(plotX)..", "..tostring(plotY)); end
			if (roll <= pair.PercentChance) then
				return pair.Unit.ID;
			else
				roll = roll - pair.PercentChance;
			end
		end
		-- Something went wrong if there were no units returned
		return -1;
		-- return UNIT_KRAKEN.ID;
	else
		if _dpo then print("No spawn Coloss"); end
	end

	return -1;
end

-- ===========================================================================
-- Unit AI Methods
-- ===========================================================================

-- Update Hydracoral (Hex Blocker) units	
--	Hydracoral units work in groups like a plant with a root and vines
--	Hydracorals only update once every X turns -- a life cycle with regular bloom and die-off periods
--	LVL1-2 are vines, they have a % chance to improve to the next level up each update
--	LVL3 units are "roots" - they have a chance to spawn new LVL1s, or to die off and stop spawning
-- PWAC corrected
function UpdateHydraUnits(ignoreInterval)	
	-- advanced option to return default Not growing bug
	local ReproductionOff = Game.GetCustomOption("GAMEOPTION_PW_HYDRACORAL_REPRODUCTION_OFF");
	
	-- bug fix for scaling hydra cycle after loading a save
	local HydraLifeCycle_SpeedScaled = HYDRA_LIFE_CYCLE_INTERVAL;
	if (gameSpeedInfo ~= nil and gameSpeedInfo.AlienSpawnMod ~= nil) then
		HydraLifeCycle_SpeedScaled = math.ceil((HydraLifeCycle_SpeedScaled * gameSpeedInfo.AlienSpawnMod) / 100);
	end
	
	-- print("UpdateHydraUnits Start. ReproductionOff = "..tostring(ReproductionOff)..", HydraLifeCycle_SpeedScaled = "..tostring(HydraLifeCycle_SpeedScaled)) -- dbg
	
	-- Stats: L3 died, L1 growed, L2 growed, L3 growed, 
	local _HydraCstats = {
		{0, 0, 0, 0},
	-- HydraCs total, L1, L2, L3		
		{0, 0, 0, 0}, };
	
	if g_ALIEN_PLAYER == nil then
		error("Could not retrieve alien player object");
		return;
	end

	local allAlienUnits = ALIENS.GetAllAlienUnits();	

	local gameTurn = Game.GetGameTurn();
	if (gameTurn % HydraLifeCycle_SpeedScaled == 0 or ignoreInterval) then

		if (UNIT_HYDRA_LVL1 == nil or UNIT_HYDRA_LVL2 == nil or UNIT_HYDRA_LVL3 == nil) then
			error("Could not find Alien Hydra unit infos");
			return;
		end

		local alienUnit = nil;
		for i, unitID in ipairs(allAlienUnits) do
			alienUnit = g_ALIEN_PLAYER:GetUnitByID(unitID);
			if (alienUnit ~= nil) then

				local unitType = alienUnit:GetUnitType();
				local plotX = alienUnit:GetX();
				local plotY = alienUnit:GetY();

				local growAllowed = true;
				local dieOffAllowed = true;

				-- during our initial setup (ignoreInterval == true), we will not allow dieOff.
				if (ignoreInterval) then 
					dieOffAllowed = false; 
					ReproductionOff = 0; -- during our initial setup they should grow
				end

				-- Wounded units do not grow
				if (alienUnit:GetDamage() > 0) then growAllowed = false; end

				-- Hydra Level 1 (small)
				if (unitType == UNIT_HYDRA_LVL1.ID) then
					_HydraCstats[2][1] = _HydraCstats[2][1] + 1;
					if (growAllowed) then
						-- Chance to improve to Medium
						local roll = Game.Rand(100, "Alien Hydra LVL1 growth chance roll") +1;
						if (roll <= HYDRA_LVL1_GROW_CHANCE) then
							-- alienUnit:Kill(true, -1);
							local newUnit = g_ALIEN_PLAYER:InitUnit(UNIT_HYDRA_LVL2.ID, plotX, plotY, NO_UNITAI, direction_types[1+Game.Rand(6, "Update Hydras - direction for LVL2")]);
							newUnit:Convert(alienUnit);
							_HydraCstats[2][3] = _HydraCstats[2][3] + 1;
							_HydraCstats[1][3] = _HydraCstats[1][3] + 1;
						else
							_HydraCstats[2][2] = _HydraCstats[2][2] + 1;
						end
					end
					
				-- Hydra Level 2 (medium)
				elseif (unitType == UNIT_HYDRA_LVL2.ID) then
					_HydraCstats[2][1] = _HydraCstats[2][1] + 1;
					if (growAllowed) then
						-- Chance to improve to Large
						local roll = Game.Rand(100, "Alien Hydra LVL2 growth chance roll") +1;
						if (roll <= HYDRA_LVL2_GROW_CHANCE) then
							-- alienUnit:Kill(true, -1);
							local newUnit = g_ALIEN_PLAYER:InitUnit(UNIT_HYDRA_LVL3.ID, plotX, plotY, NO_UNITAI, direction_types[1+Game.Rand(6, "Update Hydras - direction for LVL3")]);
							newUnit:Convert(alienUnit, 1);
							_HydraCstats[2][4] = _HydraCstats[2][4] + 1;
							_HydraCstats[1][4] = _HydraCstats[1][4] + 1;
						else
							_HydraCstats[2][3] = _HydraCstats[2][3] + 1;
						end
					end
					
				-- Hydra Level 3 (large)
				elseif (unitType == UNIT_HYDRA_LVL3.ID) then
					-- fixing unavailable growing
					if (growAllowed) and ((ReproductionOff == 0) or (ReproductionOff == nil)) then
						-- First: growth of Small nodes
						-- All plots adjacent to this unit that do NOT have a Hydra have chance to get a Small node (within constraints)
						for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
							local adjacentPlot = Map.PlotDirection(plotX, plotY, direction);
							if (adjacentPlot ~= nil) then
								if (adjacentPlot:IsWater()) then
									local valid = true;
									-- Standard check
									if (Aliens.IsPlotValidForAlienUnitSpawn(adjacentPlot, UNIT_HYDRA_LVL1.ID) == false) then
										valid = false;
									end
									if (valid) then
										local roll = Game.Rand(100, "Alien Hydra LVL3 growth chance roll") +1;
										if (roll <= HYDRA_LVL3_GROW_CHANCE) then
											local newUnit = g_ALIEN_PLAYER:InitUnit(UNIT_HYDRA_LVL1.ID, adjacentPlot:GetX(), adjacentPlot:GetY(), NO_UNITAI, direction_types[1+Game.Rand(6, "Update Hydras - direction for new LVL1")]);
											_HydraCstats[2][2] = _HydraCstats[2][2] + 1;
											_HydraCstats[2][1] = _HydraCstats[2][1] + 1;
											_HydraCstats[1][2] = _HydraCstats[1][2] + 1;
										end
									end
								end
							end
						end
					end				
					if (dieOffAllowed) then
						-- Second: die-off
						local roll = Game.Rand(100, "Alien Hydra LVL3 die-off roll") +1;
						if (roll <= HYDRA_LVL3_WITHER_CHANCE) then
							alienUnit:Kill(true, -1);
							_HydraCstats[1][1] = _HydraCstats[1][1] + 1;
						else
							_HydraCstats[2][4] = _HydraCstats[2][4] + 1;
							_HydraCstats[2][1] = _HydraCstats[2][1] + 1;
						end
					else
						_HydraCstats[2][4] = _HydraCstats[2][4] + 1;
					end	
				end
			end
		end
		-- print("HydraCorals total = "..tostring(_HydraCstats[2][1])..",  LVL1 = "..tostring(_HydraCstats[2][2])..",  LVL2 = "..tostring(_HydraCstats[2][3])..",  LVL3 = "..tostring(_HydraCstats[2][4])) -- dbg
		-- print("HydraCorals Died = "..tostring(_HydraCstats[1][1])..",  LVL1 Growed = "..tostring(_HydraCstats[1][2])..",  LVL2 Growed = "..tostring(_HydraCstats[1][3])..",  LVL3 Growed = "..tostring(_HydraCstats[1][4])) -- dbg
	end
end

-- Show stats on screen
function VM_MiasmaStats(PossibleMiasmaIndicesNum, MiasmaPlotsTotal, LMPercent, MSpreadTotal, SpreadThisTurn, MDisperseTotal, DisperseThisTurn, SpreadGeneralChance, DisperseGeneralChance)	
	if _dpo then print("VM_MiasmaStats start -- "); end;
	
	local _dpo = true;
	-- _dpo = false;
	
	--if dbg_NT then
		LuaEvents.VM_MiasmaSpreadTest(PossibleMiasmaIndicesNum, MiasmaPlotsTotal, LMPercent, MSpreadTotal, SpreadThisTurn, MDisperseTotal, DisperseThisTurn, SpreadGeneralChance, DisperseGeneralChance);
	-- else
		-- LuaEvents.VM_MiasmaSpreadTest(PossibleMiasmaIndicesNum, MiasmaPlotsTotal, LMPercent, MSpreadTotal, SpreadThisTurn, MDisperseTotal, DisperseThisTurn, SpreadGeneralChance, DisperseGeneralChance);
	--end
end

-- PWAC spread and disperse of miasma. Live Miasma 1.03
function UpdateMiasma(ignoreInterval)
	-- advanced option to return switch off spreading
	local MiasmaSpreadOff = Game.GetCustomOption("GAMEOPTION_PW_MIASMA_SPREADING_OFF");
	if _dpo then print("UpdateMiasma start, ignoreInterval "..tostring(ignoreInterval)..", MiasmaSpreadOff "..tostring(MiasmaSpreadOff)); end;
	local _dpo = true;
	 --_dpo = false;
	-- scaling miasma cycle
	local MiasmaSpreadCycle_SpeedScaled = MIASMA_CYCLE_INTERVAL;
	
	-- stats
	local SpreadThisTurn = 0;
	local DisperseThisTurn = 0;
	local SpreadGeneralChance = 0;
	local DisperseGeneralChance = 0;
	local MiasmaPlotsTotal = #MiasmaIndices;
	-- local LMPercent = MiasmaPlotsTotal / (PossibleMiasmaIndicesNum/100); 
	-- LMPercent = LMPercent - LMPercent%0.1;

	local thisTurn = Game.GetGameTurn();
	if (thisTurn % MiasmaSpreadCycle_SpeedScaled == 0 or ignoreInterval) then
		if _dpo then print("MiasmaIndices = "..tostring(#MiasmaIndices)..",  ForMiasmaIndices = "..tostring(#ForMiasmaIndices)) end;

		if (MiasmaSpreadOff == 0) or (MiasmaSpreadOff == nil) then
			-- FitForMiasmaPlots = GetShuffledCopyOfTable(FitForMiasmaPlots);
			ForMiasmaIndices = GetShuffledCopyOfTable(ForMiasmaIndices);
			---------------------------------
			-- MIASMA SPREAD
			---------------------------------
			for loop = 1, #ForMiasmaIndices do
				local lp_index = ForMiasmaIndices[loop];
				local looplot = Map.GetPlotByIndex(lp_index);
				local pX = looplot:GetX();
				local pY = looplot:GetY();
				local roll = Game.Rand(10000, "Miasma spread chance roll") +1;
				local thisplotchance = MIASMA_SPREAD_CHANCE;

				-- adjust to game speed - alienspawnmod
				if (gameSpeedInfo ~= nil and gameSpeedInfo.AlienSpawnMod ~= nil) then
					thisplotchance = math.ceil(thisplotchance / (gameSpeedInfo.AlienSpawnMod / 100));
				end

				-- check surround miasma shift
				local surr = 0;
				for j, direction in ipairs(direction_types) do
					local adjPlot = Map.PlotDirection(pX, pY, direction)
					if adjPlot ~= nil and adjPlot:HasMiasma() then
						surr = surr +1;
					end
				end
				if surr <= 1 then thisplotchance = thisplotchance * 1.5
				elseif surr == 5 then thisplotchance = thisplotchance / 1.5
				elseif surr == 6 then thisplotchance = thisplotchance / 2.32
				end;

				-- check for PLOT TYPE
				-- Hills harder to spread
				-- But Forest discard the influence of Hill
				if looplot:IsHills() and looplot:GetFeatureType() ~= FeatureTypes.FEATURE_FOREST then thisplotchance = thisplotchance / 1.79 end;

				-- check for TERRAIN TYPE
				-- Desert harder to spread
				-- Snow more harder to spread
				if (looplot:GetTerrainType() == TerrainTypes.TERRAIN_TUNDRA) then thisplotchance = thisplotchance / 1.2
				elseif (looplot:GetTerrainType() == TerrainTypes.TERRAIN_DESERT) then thisplotchance = thisplotchance / 1.4
				elseif (looplot:GetTerrainType() == TerrainTypes.TERRAIN_SNOW) then thisplotchance = thisplotchance / 1.6
				end

				-- check for FEATURE TYPE
				-- Forest harder to spread
				-- Marsh easier to spread
				-- Flood Plains easier to spread
				if looplot:GetFeatureType() == FeatureTypes.FEATURE_FOREST then thisplotchance = thisplotchance / 1.85
				elseif looplot:GetFeatureType() == FeatureTypes.FEATURE_MARSH then thisplotchance = thisplotchance * 1.35
				elseif looplot:GetFeatureType() == FeatureTypes.FEATURE_FLOOD_PLAINS then thisplotchance = thisplotchance * 1.23
				end;

				-- check for Nest shift
				if looplot:HasAlienNest() then thisplotchance = thisplotchance * 1.5 end;

				-- check for territory
				if looplot:IsOwned() then thisplotchance = thisplotchance / 1.55 end;

				-- FEC offset

				-- quest offset

				-- global miasma percent offset. LMPercent
				if LMPercent < 1 then thisplotchance = thisplotchance * 5.2
				elseif LMPercent <= 4 then thisplotchance = thisplotchance * 4.1
				elseif LMPercent <= 7 then thisplotchance = thisplotchance * 3.0
				elseif LMPercent <= 16 then thisplotchance = thisplotchance * 1.9
				elseif LMPercent >= 40 and LMPercent <= 45 then thisplotchance = thisplotchance / 1.4
				elseif LMPercent >= 45 and LMPercent <= 50 then thisplotchance = thisplotchance / 2.5
				elseif LMPercent >= 50 then thisplotchance = thisplotchance / 3.6
				end;

				-- round
				if _dpo then print("thisplotchance to spawn miasma = "..thisplotchance..", looplot: "..pX..", "..pY) end
				thisplotchance = math.ceil(thisplotchance);

				-- THIS TURN SPREAD GENERAL CHANCE
				SpreadGeneralChance = SpreadGeneralChance + thisplotchance;

				if (roll <= thisplotchance) then
					-- check one more time
					if looplot:CanHaveMiasma() and (not looplot:HasMiasma()) then
						-- looplot:SetFeatureType(GameInfo.Features["FEATURE_MIASMA"].ID);
						-- looplot:SetFeatureType(FeatureTypes.FEATURE_MIASMA, -1); -- это реально убирает с клетки другие FEATURES
						looplot:SetMiasma(true);	-- это ВИЗУАЛЬНО удаляет лес на клетке. При перезагрузке восстанавливается.
						-- trying to unbug graphic engine
						if looplot:GetFeatureType() == FeatureTypes.FEATURE_FOREST then
							if _dpo then print("forest") end
							looplot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
							looplot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
						end
						if looplot:GetFeatureType() == FeatureTypes.FEATURE_MARSH then
							if _dpo then print("marsh") end
							looplot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
							looplot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
						end
						if looplot:GetFeatureType() == FeatureTypes.FEATURE_FLOOD_PLAINS then
							if _dpo then print("flood") end
							looplot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
							looplot:SetFeatureType(FeatureTypes.FEATURE_FLOOD_PLAINS, -1);
						end
						-- looplot:SetArea(-1)
						SpreadThisTurn = SpreadThisTurn+1;
						MiasmaPlotsTotal = MiasmaPlotsTotal+1
						if _dpo then print("Miasma spread chance: "..thisplotchance..", and roll: "..roll..", looplot: "..pX..", "..pY); end
					end
				end
			end

			---------------------------------
			-- MIASMA DISPERSE
			---------------------------------
			MiasmaIndices = GetShuffledCopyOfTable(MiasmaIndices);
			for loop = 1, #MiasmaIndices do
				local lp_index = MiasmaIndices[loop];
				local looplot = Map.GetPlotByIndex(lp_index);
				local pX = looplot:GetX();
				local pY = looplot:GetY();
				local roll = Game.Rand(10000, "Miasma disperse chance roll") +1;
				local thisplotchance = MIASMA_DISPERSE_CHANCE;

				-- adjust to game speed - alienspawnmod
				if (gameSpeedInfo ~= nil and gameSpeedInfo.AlienSpawnMod ~= nil) then
					thisplotchance = math.ceil(thisplotchance / (gameSpeedInfo.AlienSpawnMod / 100));
				end

				-- check surround miasma
				local surr = 0;
				for j, direction in ipairs(direction_types) do
					local adjPlot = Map.PlotDirection(pX, pY, direction)
					if adjPlot ~= nil and adjPlot:HasMiasma() then
						surr = surr +1;
					end
				end
				if surr == 0 then thisplotchance = thisplotchance * 0
				elseif surr == 4 then thisplotchance = thisplotchance * 1.18
				elseif surr == 5 then thisplotchance = thisplotchance * 1.54
				elseif surr == 6 then thisplotchance = thisplotchance * 2.25
				end

				-- check for PLOT TYPE
				-- Hills harder to dissolve, except surrounded by 6 easier
				-- But Forest discard the influence of Hill
				if looplot:IsHills() and looplot:GetFeatureType() ~= FeatureTypes.FEATURE_FOREST then
					if surr == 6 then
						thisplotchance = thisplotchance * 1.19
					else
						thisplotchance = thisplotchance / 1.79
					end
				end;

				-- check for TERRAIN TYPE
				-- Grass easier to dissolve
				-- Plains easier to dissolve
				-- Tundra easier to dissolve
				if (looplot:GetTerrainType() == TerrainTypes.TERRAIN_GRASS) then thisplotchance = thisplotchance * 1.3
				elseif (looplot:GetTerrainType() == TerrainTypes.TERRAIN_PLAINS) then thisplotchance = thisplotchance * 1.2
				elseif (looplot:GetTerrainType() == TerrainTypes.TERRAIN_TUNDRA) then thisplotchance = thisplotchance * 1.1
				end

				-- check for FEATURE TYPE
				-- Forest harder to dissolve
				-- Marsh harder to dissolve
				if looplot:GetFeatureType() == FeatureTypes.FEATURE_FOREST then thisplotchance = thisplotchance / 1.72
				elseif looplot:GetFeatureType() == FeatureTypes.FEATURE_MARSH then thisplotchance = thisplotchance / 1.25
				end;

				-- check for nest or xenomass
				if looplot:HasAlienNest() or (looplot:GetResourceType() == GameInfo.Resources["RESOURCE_XENOMASS"].ID) then thisplotchance = thisplotchance * 0 end;

				-- check for territory
				if looplot:IsOwned() then thisplotchance = thisplotchance / 1.55 end;

				-- FEC offset

				-- quest offset

				-- global miasma percent offset. LMPercent
				if LMPercent <= 7 then thisplotchance = thisplotchance / 1.8
				elseif LMPercent >= 40 and LMPercent <= 45 then thisplotchance = thisplotchance / 1.4
				elseif LMPercent >= 45 and LMPercent <= 50 then thisplotchance = thisplotchance / 2.5
				elseif LMPercent >= 50 then thisplotchance = thisplotchance / 3.6
				end;

				-- round
				if _dpo then  print("thisplotchance to disperse miasma = "..thisplotchance..", looplot: "..pX..", "..pY) end
				thisplotchance = math.ceil(thisplotchance);

				-- THIS TURN DISPERSE GENERAL CHANCE
				DisperseGeneralChance = DisperseGeneralChance + thisplotchance;

				if (roll < thisplotchance) then
					-- check one more time
					if looplot:HasMiasma() then
						looplot:SetMiasma(false);
						DisperseThisTurn = DisperseThisTurn+1;
						MiasmaPlotsTotal = MiasmaPlotsTotal-1
						-- print("Miasma disperse chance: "..thisplotchance..", and roll: "..roll..", looplot: "..pX..", "..pY); -- dbg
					end
				end
			end

			LMPercent = MiasmaPlotsTotal / (PossibleMiasmaIndicesNum/100);
			LMPercent = LMPercent - LMPercent%0.1;
			SaveDB.SetValue("SpreadGeneralChance", SpreadGeneralChance);
			SaveDB.SetValue("DisperseGeneralChance", DisperseGeneralChance);

			if _dpo then print("SpreadThisTurn = "..tostring(SpreadThisTurn)..",  DisperseThisTurn = "..tostring(DisperseThisTurn)) end
			if _dpo then print("NATURE TEST") end
			if _dpo then print("PossibleMiasmaIndicesNum = "..tostring(PossibleMiasmaIndicesNum)..",  MiasmaPlotsTotal = "..tostring(MiasmaPlotsTotal)..",  LMPercent = "..tostring(LMPercent)..",  MSpreadTotal = "..tostring(MSpreadTotal)..",  MDisperseTotal = "..tostring(MDisperseTotal)) end

			VM_MiasmaStats(PossibleMiasmaIndicesNum, MiasmaPlotsTotal, LMPercent, MSpreadTotal, SpreadThisTurn, MDisperseTotal, DisperseThisTurn, SpreadGeneralChance, DisperseGeneralChance);
			MSpreadTotal = MSpreadTotal + SpreadThisTurn;
			MDisperseTotal = MDisperseTotal + DisperseThisTurn;
			SaveDB.SetValue("MSpreadT_"..thisTurn, MSpreadTotal);
			SaveDB.SetValue("MDispT_"..thisTurn, MDisperseTotal);
		end
	end
end

-- PWAC alien nests spawning system
function UpdateNests()
	if _dpo then print("UpdateNests Start ---------------------------------------- ") end
	local _dpo = true;
	 _dpo = false;
	-- local CurrentNestRate = #NestPlots/(NestStat[5]/100); -- obsolete
	local CurrentNestRate = #NestIndices/(AffinityIndicesNum/100);
	local CurrentSpawnNestRate = NEST_BASE_RATE;
	print("MGH:#NestIndices="..tostring(#NestIndices).." AffinityIndicesNum="..AffinityIndicesNum);
	print("MGH:CurrentNestRate="..CurrentNestRate.." NEST_BASE_RATE="..NEST_BASE_RATE);
	local NestRespawnTurns = NEST_RECOVERY_RATE * GameInfo.GameSpeeds[Game.GetGameSpeedType()].EnergyPercent / 100;
	print("MGH:GAMESPEED="..GameInfo.GameSpeeds[Game.GetGameSpeedType()].EnergyPercent.."%");
	print("MGH:TURNSforALIENScalculated="..NestRespawnTurns);
	NestRespawnTurns = NestRespawnTurns + Game.Rand(NEST_SPAWN_RANDOMIZE*2, "NEST_SPAWN_RANDOMIZE roll")-NEST_SPAWN_RANDOMIZE;--Randomize
	print("MGH:TURNSforALIENSrandomized="..NestRespawnTurns);
	if NestRespawnTurns > NEST_MIN_SPAWN_TURNS then
		NestRespawnTurns = NEST_MIN_SPAWN_TURNS;
	end
	if NestRespawnTurns < NEST_MAX_SPAWN_TURNS then
		NestRespawnTurns = NEST_MAX_SPAWN_TURNS;
	end
	if thisTurn >= NEST_SPAWN_LATE_TURNS then
		NestRespawnTurns = NestRespawnTurns + NEST_SPAWN_LATE_TURNS_INCREMENT;
	end
	print("MGH:TURNSforALIENS="..NestRespawnTurns);
	-- biome
	local planetInfo = GameInfo.Planets[Game.GetPlanet()];
	local PlanetTypeEffects;
	for effectRow in GameInfo.PlanetEffects{ PlanetType = planetInfo.Type } do PlanetTypeEffects = effectRow; end;
	-- print("AlienNestSpawnRateMod : "..tostring(PlanetTypeEffects.AlienNestSpawnRateMod));
	if (PlanetTypeEffects.AlienNestSpawnRateMod ~= nil and PlanetTypeEffects.AlienNestSpawnRateMod ~= 0) then
		CurrentSpawnNestRate = CurrentSpawnNestRate+(CurrentSpawnNestRate/100*PlanetTypeEffects.AlienNestSpawnRateMod);
		-- print("CurrentSpawnNestRate adjusted by Biome AlienNestSpawnRateMod: "..tostring(CurrentSpawnNestRate));
	end
	-- options
	if Game.GetCustomOption("GAMEOPTION_PW_ALIENS_LIKE_STRATEGICS") == 1 then CurrentSpawnNestRate = CurrentSpawnNestRate + 5; end;
	if Game.GetCustomOption("GAMEOPTION_PW_ALIENS_LIKE_BASICS") == 1 then CurrentSpawnNestRate = CurrentSpawnNestRate + 5; end;
	if Game.GetCustomOption("GAMEOPTION_PW_ALIENS_LIKE_EXCAVATIONS") == 1 then CurrentSpawnNestRate = CurrentSpawnNestRate + 5; end;
	if Game.GetCustomOption("GAMEOPTION_FRENZIED_ALIENS") == 1 then
		CurrentSpawnNestRate = CurrentSpawnNestRate + 5;
		NestRespawnTurns = math.ceil(NestRespawnTurns - (NestRespawnTurns / 100 * 10)); -- 90%
	end
	-- any additional factors	
	if _dpo then print("CurrentSpawnNestRate: "..tostring(CurrentSpawnNestRate).." > CurrentNestRate: "..tostring(CurrentNestRate).." ?"); end
	if CurrentSpawnNestRate > CurrentNestRate then
		-- FitForNestPlots = GetShuffledCopyOfTable(FitForNestPlots); -- obsolete
		ForNestIndices = GetShuffledCopyOfTable(ForNestIndices);
		for loop = 1, #ForNestIndices do
			local lp_index = ForNestIndices[loop];
			local looplot = Map.GetPlotByIndex(lp_index);
			local pX = looplot:GetX();
			local pY = looplot:GetY();
			-- if (not looplot:HasAlienNest() and not looplot:IsOwned() and not looplot:IsUnit() and not looplot:HasImprovement()) then
			if (not looplot:HasAlienNest() and not looplot:IsOwned() and not looplot:HasImprovement()) then
				-- check unit
				if (not looplot:IsUnit()) or 
				((looplot:GetNumUnits() < 2) and (looplot:GetUnit():GetOwner() == 62)) then
					-- check destoyed cool down
					local DestroyedTurn = SaveDB.GetValue("DestroyedNest_x"..pX.."_y"..pY);
					local cooldownpass = true;
					if DestroyedTurn then
						local CurrentTurn = Game.GetGameTurn();
						cooldownpass = NestRespawnTurns <= (CurrentTurn - DestroyedTurn);
						if not cooldownpass then
							if _dpo then print("Tried plot is in destroyed cooldown - "..NestRespawnTurns..". DestroyedTurn: "..DestroyedTurn..", looplot: "..pX..", "..pY); end
						end
					end
					if cooldownpass then
						-- check visibility by anyone;
						local chanceADJ = 1;
						for pPlayer = 0, 63 do
							if (Players[pPlayer]:IsAlive() and looplot:IsVisible(Players[pPlayer]:GetTeam(), false)) then
								if _dpo then print("looplot: "..pX..", "..pY.." is visible by player "..pPlayer..". "..tostring(GameInfo.Civilizations[Players[pPlayer]:GetCivilizationType()].Type)) end
								if pPlayer ~= 62 and pPlayer ~= 63 then
									chanceADJ = chanceADJ * 0.33;
									break;
								end
							end
						end
						-- adjust chance for non strategic tiles
						if looplot:HasResource() then
							if not (GameInfo.Resources[looplot:GetResourceType()].ResourceClassType == "RESOURCECLASS_STRATEGIC") then 
								chanceADJ = chanceADJ * 0.50;
							end
						end
						-- try to spawn nest with roll
						local roll = Game.Rand(100, "Alien Nest Spawn roll") +1;
						local chanceADJ = chanceADJ * 100;
						if (roll < chanceADJ) then
							-- DBG NATURE TEST;
							if (not dbg_NT) then
								if (looplot:IsWater()) then
									if _dpo then print("Spawned Water Nest. Spawnchance: "..chanceADJ..", and roll: "..roll..", looplot: "..pX..", "..pY..", Res:"..tostring(GameInfo.Resources[looplot:GetResourceType()].Type)); end
									looplot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_ALIEN_NEST_OCEAN"].ID);
									-- NestIndices[1+#NestIndices] = looplot:GetPlotIndex();
									table.insert(NestIndices, looplot:GetPlotIndex())
									if (not looplot:IsUnit()) then
										local andunit = GetWeightedUnitTypeToSpawn(pX, pY);
										local direction = 1+Game.Rand(6, "Update Nests - Unit direction")
										g_ALIEN_PLAYER:InitUnit(andunit, pX, pY, NO_UNITAI, direction_types[direction]) 
									end;
									break;
								else
									if _dpo then print("Spawned Land Nest. Spawnchance: "..chanceADJ..", and roll: "..roll..", looplot: "..pX..", "..pY..", Res: "..tostring(GameInfo.Resources[looplot:GetResourceType()].Type)); end
									looplot:SetImprovementType(GameInfo.Improvements["IMPROVEMENT_ALIEN_NEST"].ID);	
									if (not looplot:HasMiasma()) then
										local mroll = Game.Rand(10, "Alien Nest Spawn Miasma roll");
										if mroll < 1 then 
											-- looplot:SetFeatureType(FeatureTypes.FEATURE_MIASMA, -1); -- delete other features
											looplot:SetMiasma(true);	-- это ВИЗУАЛЬНО удаляет лес на клетке. При перезагрузке восстанавливается.
											-- looplot:SetArea(-1)
											-- trying to unbug graphic engine
											if looplot:GetFeatureType() == FeatureTypes.FEATURE_FOREST then
												-- print("forest") -- dbg
												looplot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
												looplot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
											end 
											if looplot:GetFeatureType() == FeatureTypes.FEATURE_MARSH then
												-- print("marsh") -- dbg
												looplot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
												looplot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
											end 
											if looplot:GetFeatureType() == FeatureTypes.FEATURE_FLOOD_PLAINS then
												-- print("flood") -- dbg
												looplot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
												looplot:SetFeatureType(FeatureTypes.FEATURE_FLOOD_PLAINS, -1);
											end
											if _dpo then print("Miasma rolled") end
										end
									else
										if _dpo then print("Has Miasma") end
									end
									-- NestIndices[1+#NestIndices] = looplot:GetPlotIndex();
									table.insert(NestIndices, looplot:GetPlotIndex())
									if (not looplot:IsUnit()) then
										local andunit = GetWeightedUnitTypeToSpawn(pX, pY);
										g_ALIEN_PLAYER:InitUnit(andunit, pX, pY, NO_UNITAI, direction_types[1+Game.Rand(6, "Update Nests - Unit direction")]) 
									end
									break;				
								end
							end
						else
							if _dpo then print("No Spawn. Spawnchance: "..chanceADJ..", and roll: "..roll..", looplot: "..pX..", "..pY); end
						end
					end				
				end
			end
		end
	end

	-- Fixing AverageDominantAffinityProgress and GlobalAlienOpinion
	-- first was: the bigger one goes to matter
	-- second now: sum of both divided by 2 
	local GlobalAlienTension = AlienTurnStats.GlobalAlienTension or 0.01;

	if AlienTurnStats.ADAP_doneThisTurn == false then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = false THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == nil then
		if _dpo then error("AlienTurnStats.ADAP_doneThisTurn = nil THAT SHOULD NEVER BE") end
		AlienTurnStats:GetAverageDominantAffinityProgress();
		AlienTurnStats:GetGlobalAlienOpinion();
		AlienTurnStats:GetGlobalAlienTension();
	elseif AlienTurnStats.ADAP_doneThisTurn == true then
		if _dpo then print("GlobalAlienTension: " .. tostring(GlobalAlienTension)); end
	end
	
	-- Spawn Aliens from the nest plots
	if 1 == 1 then
		-- NestPlots = GetShuffledCopyOfTable(NestPlots); -- obsolete
		NestIndices = GetShuffledCopyOfTable(NestIndices);
		for loop = 1, #NestIndices do
			local lp_index = NestIndices[loop];
			local looplot = Map.GetPlotByIndex(lp_index);
			local pX = looplot:GetX();
			local pY = looplot:GetY();
			local iscoloss = false;
			local alsaround = 0;
			local numCurrentUnits = 0;
			local numNormalUnits = 0;
			local numColossalUnits = 0;
			local numDomainPlots = 0;
			local currentRatio = 0.0;	--	
			local currentRatioColoss = 0.0;	--	alien normal units per coloss
			local currentRatioNormUn = 0.0;	--	domain tiles per alien unit
			local idealRatio	 = 0.0;
			local idealRatioColoss = 0.0;
			local idealRatioNormUn = 0.0;
			local BaseUnitSpawnChance = 20; -- gets lots off correction in different cases
			if _dpo then print("[[==--------------------------------==]]");
			print("[[==-- Spawn Alien in Nest: "..tostring(pX)..", "..tostring(pY).." --==]]"); end

			-- water / land, normal / coloss, current / ideal ratios
			if looplot:IsWater() then
				numDomainPlots = CefSeaIndicesNum;
				numNormalUnits = ALIENS.GetNumNormalUnits(DomainTypes.DOMAIN_SEA);
				numColossalUnits = ALIENS.GetNumColossalUnits(DomainTypes.DOMAIN_SEA);
				for i, ratio in ipairs(COLOSSAL_SEA_UNIT_RATIOS) do
					if (GlobalAlienTension >= ratio[1]) then
						idealRatioColoss = ratio[2];
						if _dpo then print("Water idealRatioColoss: " .. tostring(ratio[2]).. ", started from: ".. tostring(ratio[1]).. ", taken with GlobalAlienTension ".. tostring(GlobalAlienTension)); end
					end
				end	
				currentRatioColoss = ZeroSafeRatio(numNormalUnits, numColossalUnits);
				idealRatioNormUn = 100 / GameDefines.ALIEN_SEED_MAX_MAP_DENSITY;
				currentRatioNormUn = ZeroSafeRatio(numDomainPlots, numNormalUnits);

				if _dpo then print("Domain Water. Coloss Ratio Ideal/Current: " .. tostring(idealRatioColoss).. "/".. tostring(currentRatioColoss).. " Normal Ratio Ideal/Current: ".. tostring(idealRatioNormUn).."/"..tostring(currentRatioNormUn)); end
			else
				numDomainPlots = CefLandIndicesNum;
				numNormalUnits = ALIENS.GetNumNormalUnits(DomainTypes.DOMAIN_LAND);
				numColossalUnits = ALIENS.GetNumColossalUnits(DomainTypes.DOMAIN_LAND);
				for i, ratio in ipairs(COLOSSAL_LAND_UNIT_RATIOS) do
					if (GlobalAlienTension >= ratio[1]) then
						idealRatioColoss = ratio[2];
						if _dpo then  print("Land idealRatioColoss: " .. tostring(ratio[2]).. ", started from: ".. tostring(ratio[1]).. ", taken with GlobalAlienTension ".. tostring(GlobalAlienTension)); end
					end
				end	
				currentRatioColoss = ZeroSafeRatio(numNormalUnits, numColossalUnits);
				idealRatioNormUn = 100 / GameDefines.ALIEN_SEED_MAX_MAP_DENSITY;
				currentRatioNormUn = ZeroSafeRatio(numDomainPlots, numNormalUnits);

				if _dpo then print("Domain Land. Coloss Ratio Ideal/Current: " .. tostring(idealRatioColoss).. "/".. tostring(currentRatioColoss).. " Normal Ratio Ideal/Current: ".. tostring(idealRatioNormUn).."/"..tostring(currentRatioNormUn)); end
			end
			
			-- Gate of colossal rate and colossal units start turn
			-- choose ratios of normal or coloss
			if (Game.GetGameTurn() < COLOSSAL_START_TURN) then
				if _dpo then print("Can't be colossus, because not a colossus turn yet, which is: " .. tostring(COLOSSAL_START_TURN)); end
				idealRatio = idealRatioNormUn
				currentRatio = currentRatioNormUn
			elseif (currentRatioColoss > idealRatioColoss) then
				if _dpo then print("Can be colossus"); end
				iscoloss = true;
				idealRatio = idealRatioColoss
				currentRatio = currentRatioColoss
			else
				if _dpo then print("Can't be colossus, because of rating"); end
				idealRatio = idealRatioNormUn
				currentRatio = currentRatioNormUn		
			end			
			
			-- influence of PlanetTypeEffects.AlienNestSpawnRateMod 
			if (PlanetTypeEffects.AlienNestSpawnRateMod ~= nil and PlanetTypeEffects.AlienNestSpawnRateMod ~= 0) then
				idealRatio = 100 / (GameDefines.ALIEN_SEED_MAX_MAP_DENSITY + (GameDefines.ALIEN_SEED_MAX_MAP_DENSITY / 100 * PlanetTypeEffects.AlienNestSpawnRateMod));
				if _dpo then print("idealRatio adjusted by lanetTypeEffects.AlienNestSpawnRateMod to "..tostring(idealRatio)); end
			end
			-- influence of PlanetTypeEffects.AlienSpawnRateMod 
			if (PlanetTypeEffects.AlienSpawnRateMod ~= nil and PlanetTypeEffects.AlienSpawnRateMod ~= 0) then
				BaseUnitSpawnChance = BaseUnitSpawnChance + (BaseUnitSpawnChance/100*PlanetTypeEffects.AlienSpawnRateMod)
				if _dpo then print("BaseUnitSpawnChance adjusted by lanetTypeEffects.AlienSpawnRateMod to "..tostring(BaseUnitSpawnChance)); end
			end
			
			-- if there is no units on nest or only 1 alien
			if (not looplot:IsUnit()) or 
			((looplot:GetNumUnits() < 2) and (looplot:GetUnit():GetOwner() == 62)) then
				if (currentRatio > idealRatio) then	
					-- all surround units
					for j, direction in ipairs(direction_types) do
						local adjPlot = Map.PlotDirection(pX, pY, direction)
						if adjPlot ~= nil and adjPlot:IsUnit() then
							-- print("Has a unit on adjusted plot direction "..j); -- dbg
							local unitCount = adjPlot:GetNumUnits();
							for i = 0, unitCount, 1 do
								local unit = adjPlot:GetUnit(i);
								if(unit ~= nil) then
									if (unit:GetOwner() == 62) then
										local unitClass = GameInfo.UnitClasses[unit:GetUnitClassType()].ID;
										-- local unitClass1 = GameInfo.UnitClasses["UNITCLASS_ALIEN_HYDRA_LVL1"];
										-- local unitClass2 = GameInfo.UnitClasses["UNITCLASS_ALIEN_HYDRA_LVL2"];
										-- local unitClass3 = GameInfo.UnitClasses["UNITCLASS_ALIEN_HYDRA_LVL3"];
										-- print("unitClass: "..tostring(unitClass)); 
										-- print("unitClass1: "..tostring(unitClass1));
										-- print("unitClass2: "..tostring(unitClass2));
										-- print("unitClass3: "..tostring(unitClass3));
										if (unitClass ~= GameInfo.UnitClasses["UNITCLASS_ALIEN_HYDRA_LVL1"].ID) and 
										(unitClass ~= GameInfo.UnitClasses["UNITCLASS_ALIEN_HYDRA_LVL2"].ID) and
										(unitClass ~= GameInfo.UnitClasses["UNITCLASS_ALIEN_HYDRA_LVL3"].ID) then
											alsaround = alsaround+1;
											if _dpo then print("Has an Alien unit on adjusted plot direction "..j); end
										else
											if _dpo then print("Has a Hydra unit on adjusted plot direction "..j); end
										end;
									else
										if _dpo then print("Has a Player unit on adjusted plot direction "..j); end
									end
								end
							end
						end
					end
					-- minus 3% for each
					BaseUnitSpawnChance = BaseUnitSpawnChance - alsaround * 3;
					
					-- minus 6% if unit alien on tile
					if looplot:IsUnit() then
						BaseUnitSpawnChance = BaseUnitSpawnChance - 6;
					end
					
					-- check visibility by anyone;
					local visible = 1;
					for pPlayer = 0, 63 do
						if (Players[pPlayer]:IsAlive() and looplot:IsVisible(Players[pPlayer]:GetTeam(), false)) then
							if _dpo then print("looplot: "..pX..", "..pY.." is visible by player "..pPlayer..". "..tostring(GameInfo.Civilizations[Players[pPlayer]:GetCivilizationType()].Type)) end
							if pPlayer ~= 62 and pPlayer ~= 63 then
								visible = 2;
								break;
							end
						end
					end
					if BaseUnitSpawnChance > 0 then
						BaseUnitSpawnChance = BaseUnitSpawnChance/visible;
					else
						BaseUnitSpawnChance = BaseUnitSpawnChance - (visible * 3);
					end 
					
					-- check owned tile; UpRate works only on wild nest.
					local owned = 1;
					if looplot:IsOwned() then
						if _dpo then print("looplot: "..pX..", "..pY.." is owned") end
						owned = 2; -- may be 3 or 4, need test
					else
						if (currentRatio/idealRatio > 2) then BaseUnitSpawnChance = BaseUnitSpawnChance + 8 end; -- too less aliens
						if (currentRatio/idealRatio > 4) then BaseUnitSpawnChance = BaseUnitSpawnChance + 8 end; -- too too less aliens
					end
					if BaseUnitSpawnChance > 0 then
						BaseUnitSpawnChance = BaseUnitSpawnChance/owned;
					end
					
					-- roll and spawn
					-- local roll = Game.Rand(100, "Roll to Nest spawn Alien");
					local roll = Game.Rand(100, "Roll to Nest spawn Alien on "..pX..", "..pY) +1;
					if _dpo then print("BaseUnitSpawnChance, and roll 100: " .. tostring(BaseUnitSpawnChance).. ", ".. tostring(roll)); end
					if (roll < BaseUnitSpawnChance) then
						local andunit, listnumber = GetWeightedUnitTypeToSpawn(pX, pY, iscoloss);
						-- DBG NATURE TEST;
						if (not dbg_NT) then
							local SOAlien = g_ALIEN_PLAYER:InitUnit(andunit, pX, pY, NO_UNITAI, direction_types[1+Game.Rand(6, "Update Nests - Unit direction")])
							AwakeningStageApp(SOAlien, andunit, AAStage, listnumber);
						end;
					end;
				end
			else
				if _dpo then print("Tile is occupied"); end
			end
			-- print("Worked Nest: "..pX..", "..pY..", BaseUnitSpawnChance: "..BaseUnitSpawnChance..", alsaround: "..alsaround..", currentRatio: "..currentRatio..", idealRatio: "..idealRatio); -- dbg
		end
	end
end

--============================================================================================
