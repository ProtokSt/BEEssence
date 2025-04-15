---- 2021 - Blessed by Protok St.
---- ===========================================================================
---- Long Expeditions - Expeditions Spawning Option
---- ===========================================================================
---- Standart Map Size, FastSpeed and DoubleRate makes chances: 28 out of 67. It's become each third turn spam. And 42 out of 67 on big map size - Each 2nd turn!? Nonsense!
---- Custom maps like "New Earth" are invisible for script, and detects as Small. Solved.
---- Tried to spawn on unexisting cells. Solved
---- CurrentTurn = 0 - ruin script sense on gameload. Solved
----
---- Firstly, lets decrease Base chance from 14 to 12.
---- Then remaking adjusting by map size.
---- Game Speed impact /2 less.
---- No spawn on Owned or AdjOwned plots
print("----------------------------------------------------------------")
print("Long Expeditions start loading.")

-- include("MapmakerUtilities");	--	GetShuffledCopyOfTable

----------------------------------------------------
-- Variables, counters, constants
----------------------------------------------------
local BaseAmount		= 1--1		-- how many exp sites script tries to spawn per turn
local BaseChance 		= 12 --12	-- (Standard: 12) % per Turn on STANDARD SPEED. Gets adjusted with Modifiers below and GameSpeed
-- local rollMax 			= (GameInfo.GameSpeeds[Game.GetGameSpeedType()].ResearchPercent+100) /2; -- halved 
local rollMax 			= (GameInfo.GameSpeeds[Game.GetGameSpeedType()].EnergyPercent+100); 
-- The faster GameSpeed has lesser ResearchPercent, the lesser ResearchPercent the higher chance to spawn. GAMESPEED_QUICK - 67; GAMESPEED_STANDARD - 100; GAMESPEED_EPIC - 150
local StartDelayBase 	= 24 --24	-- Number of turns before Expeditions start spawning, gets adjusted with Research Modifier.
local StartDelayFinal = math.ceil(StartDelayBase * rollMax / 100)

-- local ShiftedChance = BaseChance - ShiftBaseChance + math.random(0, ShiftBaseChance*2)  -- 
local ShiftBaseChance	= 0 --2 	-- obsolete -- Random shifts from -x..+x
local ShiftedChance = 12 -- obsolete
local AdvancedModifier 	= 2 	-- obsolete
local MaximumAttempts 	= 30 	-- obsolete -- Number of Attempts per Turn to spawn one Expedition (if Invalid Plot gets chosen). Will never spawn more than one Expedition per try (BaseAmount).

-- checking map size for adjust. Need adj by available plots, but not all.
local MapSizeMultiplier 	= 1 	-- Adjustment Map Size
-- local MapWidth, MapHeight = Map.GetGridSize()
-- local WorldSize = Map.GetWorldSize()
local CellsCountCheck		=		Map.GetNumPlots()
if 		CellsCountCheck <= 800 	then MapSizeMultiplier = 0.7		-- up to 800 cells
elseif 	CellsCountCheck <= 1300 then MapSizeMultiplier = 0.8		-- up to 1300 cells
elseif 	CellsCountCheck <= 2300 then MapSizeMultiplier = 1 			-- up to 2300 cells
elseif 	CellsCountCheck <= 3800 then MapSizeMultiplier = 1.2 		-- up to 3800 cells
else 								 MapSizeMultiplier = 1.3 		-- up to *** cells
end

local TotalExpeditionsSpawned	=	0 -- 

local LandExpeditionWeights =
{
	{ Expedition = GameInfo.Resources["RESOURCE_CRASHED_SATELLITE"].ID,		Weight = 50, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_ALIEN_SKELETON"].ID,		Weight = 15, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_ALIEN_RUIN"].ID,			Weight = 15, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_DERELICT_SETTLEMENT"].ID,	Weight = 20, Count = 0 },
};

local OceanExpeditionWeights =
{
	{ Expedition = GameInfo.Resources["RESOURCE_CRASHED_SATELLITE_OCEAN"].ID,		Weight = 35, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_DERELICT_SETTLEMENT_OCEAN"].ID,		Weight = 10, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_WRECKED_COLONY_LANDER_OCEAN"].ID,	Weight = 5, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_SUNKEN_SPACECRAFT_OCEAN"].ID,		Weight = 10, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_SUNKEN_VEHICLE_OCEAN"].ID,			Weight = 10, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_ALIEN_RUIN_OCEAN"].ID,				Weight = 10, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_SOUNDING_BELL_OCEAN"].ID,			Weight = 5, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_ALIEN_SKELETON_OCEAN"].ID,			Weight = 10, Count = 0 },
	{ Expedition = GameInfo.Resources["RESOURCE_KRAKEN_NEST_OCEAN"].ID,				Weight = 5, Count = 0 },
};

----------------------------------------------------
-- Functions
----------------------------------------------------
function GetShuffledCopyOfTable(incoming_table)
	-- Designed to operate on tables with no gaps. Does not affect original table.
	local len = table.maxn(incoming_table);
	local copy = {};
	local shuffledVersion = {};
	-- Make copy of table.
	for loop = 1, len do
		copy[loop] = incoming_table[loop];
	end
	-- One at a time, choose a random index from Copy to insert in to final table, then remove it from the copy.
	local left_to_do = table.maxn(copy);
	for loop = 1, len do
		local random_index = 1 + Map.Rand(left_to_do, "Shuffling table entry - Lua");
		table.insert(shuffledVersion, copy[random_index]);
		table.remove(copy, random_index);
		left_to_do = left_to_do - 1;
	end
	return shuffledVersion
end

function GetFreePlots()
	local ExpReadyPlots_list = {};
	local TotalMapPlots = Map.GetNumPlots();

	-- loop through all plots on the map.   
	for iPlotID = 0, TotalMapPlots-1 do
		local plot = Map.GetPlotByIndex(iPlotID);
		-- IsAdjacentOwned
		-- IsOwned
		-- if (plot:HasAlienNest() or 
			-- plot:IsAdjacentOwned() or 
			-- plot:HasResource() or
			-- plot:IsMountain() or 
			-- plot:IsCanyon() or 
			-- plot:GetFeatureType()==FeatureTypes.FEATURE_ICE or
			-- plot:IsStation() or 
			-- plot:HasImprovement() or 
			-- plot:GetHeroLandmark() ~= -1 ) 	then
		-- else
		if not plot:IsAdjacentOwned() and plot:CanHaveResource(GameInfo.Resources["RESOURCE_CRASHED_SATELLITE"].ID, ignoreLatitude) then
			ExpReadyPlots_list[#ExpReadyPlots_list+1] = plot;
		end
	end
	print("Long Expeditions: GetFreePlots: "..#ExpReadyPlots_list.."/"..TotalMapPlots) -- dbg
	return ExpReadyPlots_list;
end

function SpawnExpedition()
	-- print("Long Expeditions: SpawnExpedition Main") -- dbg
	local looplot;
	local pX;
	local pY;
	local deck : table = {};
	local ExpeditionID;
	
	-- check the plot
	local FreePlots_list = GetFreePlots();
	if #FreePlots_list < 1 then
		print("Long Expeditions: WARN - NO FREE PLOTS FOR EXPEDITION");
		return false;
	end
	FreePlots_list = GetShuffledCopyOfTable(FreePlots_list);
	for loop = 1, #FreePlots_list do
		looplot = FreePlots_list[loop];
		pX = looplot:GetX();
		pY = looplot:GetY();
		if looplot:GetTerrainType() == GameDefines.SHALLOW_WATER_TERRAIN then
			deck = {}; -- making new deck
			for i,t in ipairs(OceanExpeditionWeights) do
				if i == 9 then	-- cut off oceans exp
					break
				end
				if (t.Weight > 0) then
					for j = 1, t.Weight do
						table.insert(deck, t.Expedition);
					end
				end
			end
			
			if (#deck > 0) then	-- choose from deck
				ExpeditionID = 1 + Game.Rand(#deck, "Long Expeditions: ExpeditionID from #deck of OceanExpeditionWeights(-1)");
				ExpeditionID = deck[ExpeditionID];
			else
				error("Long Expeditions: WARN - Exped weight table was empty!");
			end	
			
			-- spawning
			if looplot:CanHaveResource(ExpeditionID, ignoreLatitude) then
				looplot:SetResourceType(ExpeditionID, 1)
				-- counting
				if 		ExpeditionID == OceanExpeditionWeights[1].Expedition then OceanExpeditionWeights[1].Count = OceanExpeditionWeights[1].Count+1
				elseif  ExpeditionID == OceanExpeditionWeights[2].Expedition then OceanExpeditionWeights[2].Count = OceanExpeditionWeights[2].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[3].Expedition then OceanExpeditionWeights[3].Count = OceanExpeditionWeights[3].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[4].Expedition then OceanExpeditionWeights[4].Count = OceanExpeditionWeights[4].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[5].Expedition then OceanExpeditionWeights[5].Count = OceanExpeditionWeights[5].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[6].Expedition then OceanExpeditionWeights[6].Count = OceanExpeditionWeights[6].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[7].Expedition then OceanExpeditionWeights[7].Count = OceanExpeditionWeights[7].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[8].Expedition then OceanExpeditionWeights[8].Count = OceanExpeditionWeights[8].Count+1
				else
					print("Long Expeditions: WARN - Exped type is unexpected!");
				end
				TotalExpeditionsSpawned = TotalExpeditionsSpawned + 1		
			else
				print("Long Expeditions: WARN - PLOT "..pX..","..pY.." CANT HAVE EXP.ID: "..ExpeditionID.."!");
			end
			print("Long Expeditions: turn: "..Game.GetGameTurn()..", Spawned #" .. TotalExpeditionsSpawned .. " ID:"..ExpeditionID.." on Plot " .. pX .. "," .. pY .. " (Shallow)")
			break
			
		elseif looplot:GetTerrainType() == GameDefines.DEEP_WATER_TERRAIN then
			deck = {}; -- making new deck
			for i,t in ipairs(OceanExpeditionWeights) do
				if (t.Weight > 0) then
					for j = 1, t.Weight do
						table.insert(deck, t.Expedition);
					end
				end
			end
			
			if (#deck > 0) then	-- choose from deck
				ExpeditionID = 1 + Game.Rand(#deck, "Long Expeditions: ExpeditionID from #deck of OceanExpeditionWeights");
				ExpeditionID = deck[ExpeditionID];
			else
				print("Long Expeditions: WARN - Exped weight table was empty!");
			end	
			
			-- spawning
			if looplot:CanHaveResource(ExpeditionID, ignoreLatitude) then
				looplot:SetResourceType(ExpeditionID, 1)
				-- counting
				if 		ExpeditionID == OceanExpeditionWeights[1].Expedition then OceanExpeditionWeights[1].Count = OceanExpeditionWeights[1].Count+1
				elseif  ExpeditionID == OceanExpeditionWeights[2].Expedition then OceanExpeditionWeights[2].Count = OceanExpeditionWeights[2].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[3].Expedition then OceanExpeditionWeights[3].Count = OceanExpeditionWeights[3].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[4].Expedition then OceanExpeditionWeights[4].Count = OceanExpeditionWeights[4].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[5].Expedition then OceanExpeditionWeights[5].Count = OceanExpeditionWeights[5].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[6].Expedition then OceanExpeditionWeights[6].Count = OceanExpeditionWeights[6].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[7].Expedition then OceanExpeditionWeights[7].Count = OceanExpeditionWeights[7].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[8].Expedition then OceanExpeditionWeights[8].Count = OceanExpeditionWeights[8].Count+1
				elseif 	ExpeditionID == OceanExpeditionWeights[9].Expedition then OceanExpeditionWeights[9].Count = OceanExpeditionWeights[9].Count+1
				else
					print("Long Expeditions: WARN - Exped type is unexpected!");
				end
				TotalExpeditionsSpawned = TotalExpeditionsSpawned + 1		
			else
				print("Long Expeditions: WARN - PLOT "..pX..","..pY.." CANT HAVE EXP.ID: "..ExpeditionID.."!");
			end
			print("Long Expeditions: turn: "..Game.GetGameTurn()..", Spawned #" .. TotalExpeditionsSpawned .. " ID:"..ExpeditionID.." on Plot " .. pX .. "," .. pY .. " (Ocean)")
			break
			
		elseif looplot:IsWater() == false then
			deck = {}; -- making new deck
			for i,t in ipairs(LandExpeditionWeights) do
				if (t.Weight > 0) then
					for j = 1, t.Weight do
						table.insert(deck, t.Expedition);
					end
				end
			end
			
			if (#deck > 0) then	-- choose from deck
				ExpeditionID = 1 + Game.Rand(#deck, "Long Expeditions: ExpeditionID from #deck of LandExpeditionWeights");
				ExpeditionID = deck[ExpeditionID];
			else
				print("Long Expeditions: WARN - Exped weight table was empty!");
			end	
			
			-- spawning
			if looplot:CanHaveResource(ExpeditionID, ignoreLatitude) then
				looplot:SetResourceType(ExpeditionID, 1)
				-- counting
				if 		ExpeditionID == LandExpeditionWeights[1].Expedition then LandExpeditionWeights[1].Count = LandExpeditionWeights[1].Count+1
				elseif  ExpeditionID == LandExpeditionWeights[2].Expedition then LandExpeditionWeights[2].Count = LandExpeditionWeights[2].Count+1
				elseif 	ExpeditionID == LandExpeditionWeights[3].Expedition then LandExpeditionWeights[3].Count = LandExpeditionWeights[3].Count+1
				elseif 	ExpeditionID == LandExpeditionWeights[4].Expedition then LandExpeditionWeights[4].Count = LandExpeditionWeights[4].Count+1
				else
					print("Long Expeditions: WARN - Exped type is unexpected!");
				end
				TotalExpeditionsSpawned = TotalExpeditionsSpawned + 1		
			else
				print("Long Expeditions: WARN - PLOT "..pX..","..pY.." CANT HAVE EXP.ID: "..ExpeditionID.."!");
			end
			print("Long Expeditions: turn: "..Game.GetGameTurn()..", Spawned #" .. TotalExpeditionsSpawned .. " ID:"..ExpeditionID.." on Plot " .. pX .. "," .. pY .. " (Land)")
			break
		
		else
			print("Long Expeditions: WARN - PLOT "..pX..","..pY.." HAS UNUSUAL DETERMINE!");
		end
	end
end

function LongExpeditions(playerID)
	-- print("Long Expeditions: LongExpeditions ") -- dbg
	local Roll;
	local CurrentTurn = Game.GetGameTurn();

	print("Long Expeditions: Total Expeditions spawned so far: " .. TotalExpeditionsSpawned)
	if CurrentTurn >= StartDelayFinal then
		for i=1, BaseAmount do
			Roll = 1 + Game.Rand(rollMax, "Long Expeditions: Roll for expedition #"..i); --
			print("Long Expeditions: Trying to spawn Expedition #"..i.."/"..BaseAmount..", with chance "..BaseChance.." and Roll from Max ".. Roll.. "/"..tostring(rollMax)); -- dbg
			if  Roll <= BaseChance then
				SpawnExpedition()
			else
				print("Long Expeditions: Failed! No Expedition will be spawned this time.")
			end
		end
	else
		print("Long Expeditions: Delay from start is active. (Turn " .. CurrentTurn .. " of " .. StartDelayFinal .. ")")
	end
	print("Spawned RESOURCE_CRASHED_SATELLITE = "			..LandExpeditionWeights[1].Count)
	print("Spawned RESOURCE_ALIEN_SKELETON = "				..LandExpeditionWeights[2].Count)
	print("Spawned RESOURCE_ALIEN_RUIN = "					..LandExpeditionWeights[3].Count)
	print("Spawned RESOURCE_DERELICT_SETTLEMENT = "			..LandExpeditionWeights[4].Count)
	print("Spawned RESOURCE_CRASHED_SATELLITE_OCEAN = "		..OceanExpeditionWeights[1].Count)
	print("Spawned RESOURCE_DERELICT_SETTLEMENT_OCEAN = "	..OceanExpeditionWeights[2].Count)
	print("Spawned RESOURCE_WRECKED_COLONY_LANDER_OCEAN = "	..OceanExpeditionWeights[3].Count)
	print("Spawned RESOURCE_SUNKEN_SPACECRAFT_OCEAN = "		..OceanExpeditionWeights[4].Count)
	print("Spawned RESOURCE_SUNKEN_VEHICLE_OCEAN = "		..OceanExpeditionWeights[5].Count)
	print("Spawned RESOURCE_ALIEN_RUIN_OCEAN = "			..OceanExpeditionWeights[6].Count)
	print("Spawned RESOURCE_SOUNDING_BELL_OCEAN = "			..OceanExpeditionWeights[7].Count)
	print("Spawned RESOURCE_ALIEN_SKELETON_OCEAN = "		..OceanExpeditionWeights[8].Count)
	print("Spawned RESOURCE_KRAKEN_NEST_OCEAN = "			..OceanExpeditionWeights[9].Count)
	print("-------------------------------------------------------------------")

end

function OnPlayerDoTurn(playerID)
	-- print("Long Expeditions: OnPlayerDoTurn: playerID "..playerID) -- dbg
	-- if (Players[playerID]:IsAlien() and Game.GetCustomOption("GAMEOPTION_PBS_LONG_EXPEDITIONS") ~= 0) then
	if (playerID == 62 and Game.GetCustomOption("GAMEOPTION_PBS_LONG_EXPEDITIONS") ~= 0) then
		-- print("Long Expeditions: Go") -- dbg
		LongExpeditions(playerID);
	end
end
----------------------------------------------------
-- INIT Game events
----------------------------------------------------
GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn);
-- if (Game.IsGameMultiPlayer() == false) then
	-- GameEvents.PlayerDoTurn.Add(ExpeditionChecker);
-- else
	-- print("In this version EXSpawn option is off in MP games."); -- dbg
-- end

print("Long Expeditions end loading.")
print("----------------------------------------------------------------")