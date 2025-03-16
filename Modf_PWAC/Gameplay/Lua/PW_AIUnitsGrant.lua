---- 12/04/2020 - Blessed by Protok St. (orginal by Ryika)
---- 8 turns is too fast. It is make a unit Cap and slow down the production.
---- Lets do 12 turns +/-2 each round of grant.
---- And a players names in a Log of course.
---- Now, lets scale the number of Scouts with size of map, cells count.
---- Count and Log spawned number.

--========================================================================================
-- Adjustable Variables (Feel free to change the numbers, should not cause problems)
--========================================================================================

local everyXTurnsBasic		=		12 -- AI Scout Count is checked every X turns (gets adjusted for Game Speed). 
local ScoutstoMaintain		=		1 -- If an A has less than X many scouts, then a new one will be spawned in its capital. 
local everyRoundShift		=		2 -- Random shifts from -x..+x
local TotalScoutsSpawned	=		0 -- 


--========================================================================================
-- Constants (Should not be edited unless you know what you're doing!)
--========================================================================================

local TurnsSinceLastSpawn	=		0 
local iResearchMod			=		GameInfo.GameSpeeds[Game.GetGameSpeedType()].ResearchPercent / 100
local UNIT_EXPLORER			=		GameInfo.Units["UNIT_EXPLORER"].ID
local everyXTurns			=		math.ceil(everyXTurnsBasic * iResearchMod) -- Calculates 
local CheckTurnsRound		=		everyXTurns - everyRoundShift + math.random(everyRoundShift*2)  -- 
local SkipInitialization	=		0

-- checking map
local CellsCountCheck		=		Map.GetNumPlots()
if 		CellsCountCheck <= 800 	then ScoutstoMaintain = ScoutstoMaintain;--1 	-- 3 -- up to 800 cells
elseif 	CellsCountCheck <= 1300 then ScoutstoMaintain = ScoutstoMaintain;--2 	-- 4 -- up to 1300 cells
elseif 	CellsCountCheck <= 2300 then ScoutstoMaintain = ScoutstoMaintain;--3 	-- 5 -- up to 2300 cells
elseif 	CellsCountCheck <= 3800 then ScoutstoMaintain = ScoutstoMaintain + 1;--3 	-- 6 -- up to 3800 cells
else 								 ScoutstoMaintain = ScoutstoMaintain + 2;--4 	-- 6 -- up to *** cells
end
	
--[[	An oceanless planet
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {28, 20},			560
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {36, 24},			864
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {44, 30},		1320
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {54, 36},		1944
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {70, 44},		3080
		Tilted_Axis
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {52, 32},			1664
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {68, 44},			2992
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {88, 56},		4928
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {108, 68},	7344
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {118, 74},		8732
		Skirmish
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {28, 18},			504
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {36, 22},			792
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {46, 28},		1288
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {60, 36},		2160
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {72, 44},		3168
		Inland Sea
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {28, 18},			504
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {36, 22},			792
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {46, 28},		1288
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {60, 36},		2160
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {72, 44},		3168
		Ice age
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {44, 18},			792
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {56, 24},			1344
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {70, 30},		2100
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {92, 38},		3469
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {116, 46},		5336
]]


--========================================================================================
-- Initialization
--========================================================================================

if SkipInitialization ~= 1 then
	print("----------------------------------------------------------")
	print("Script Loaded. EXPLORERS GRANT")
	if Game.GetCustomOption("GAMEOPTION_PW_AI_EXPLORERS_GRANT") == 0 then
		print("Free Explorers are disabled.")
	else
		print("AIs will get a free Scout every " .. everyXTurns .. "+/-"..everyRoundShift.." Turns if they have less than " .. ScoutstoMaintain .. ".")
		print("Number of Scouts scaled by map cells count. Which now = "..Map.GetNumPlots())
	end
	print("----------------------------------------------------------")
end


--========================================================================================
-- Functions and Stuff
--========================================================================================

-- Checks the Number of Scouts of every player and gives out new ones to AIs that have less than the ScoutstoMaintain-Value.
function FreeScoutFunction(iPlayer)
	if Game.GetCustomOption("GAMEOPTION_PW_AI_EXPLORERS_GRANT") ~= 0 then
		local ActivePlayer = iPlayer
		if ActivePlayer == 0 then
			TurnsSinceLastSpawn = TurnsSinceLastSpawn + 1
			--if TurnsSinceLastSpawn >= everyXTurns then
			if TurnsSinceLastSpawn >= CheckTurnsRound then
				CheckTurnsRound = everyXTurns - everyRoundShift + math.random(0,everyRoundShift*2)
				print("-------- Giving out a round of free Explorers! --------")
				print("Now turn - "..Game.GetGameTurn()..". Since Last Spawn - "..TurnsSinceLastSpawn..". Next round after - "..CheckTurnsRound.." turns.")
				TurnsSinceLastSpawn = 0
				for pPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
					local NumScouts = 0
					-- Restrict to AIs only
					if( PreGame.GetSlotStatus( pPlayer ) == SlotStatus.SS_COMPUTER ) then
						local CapitalCity = Players[pPlayer]:GetCapitalCity()
						if CapitalCity ~= nil then
							-- Loop through all Units to see how many Scouts this AI has.
							for iUnit in Players[pPlayer]:Units() do
								if iUnit:GetUnitType() == UNIT_EXPLORER then
									NumScouts = NumScouts + 1
								end
							end
							if NumScouts < ScoutstoMaintain then
								print(pPlayer .. ". "..Players[pPlayer]:GetName().." is an AI and only had " .. NumScouts .. " Scouts. It gets a free one!")
								local unit = Players[pPlayer]:InitUnit(UNIT_EXPLORER, CapitalCity:GetX(), CapitalCity:GetY(), UNITAI_EXPLORE)
								unit:JumpToNearestValidPlot()
								TotalScoutsSpawned = TotalScoutsSpawned	+1
							else
								print(pPlayer .. ". "..Players[pPlayer]:GetName().." is an AI but already has " .. NumScouts .. " Scouts.")
							end
						else
							print(pPlayer .. ". "..Players[pPlayer]:GetName().." is an AI but Capital was nil.")
						end
					end
				end
				print("Total Explorers spawned - "..TotalScoutsSpawned)
				print("-------------------------------------------------------")
			end
		end
	end
end		
-- GameEvents.PlayerDoTurn.Add(FreeScoutFunction);
if (Game.IsGameMultiPlayer() == false) then
	GameEvents.PlayerDoTurn.Add(FreeScoutFunction);
else
	print("In this version AGU option is off in MP games."); -- dbg
end