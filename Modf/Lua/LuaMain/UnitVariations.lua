--MGH modified
-- UnitVariations.lua
------------------------------------------------------------------------------
--	Copyright (c) 2009-2013 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------
local l_fortifyAction = 1500;
function OnUnitActionChanged(playerID, unitID, actionID)
	if playerID ~= nil and unitID ~= nil and actionID ~= nil then
		if playerID == Game.GetActivePlayer() then
			local player = Players[playerID];
			if player ~= nil then
				local unit = player:GetUnitByID(unitID);
				if unit ~= nil then
					if( actionID == l_fortifyAction ) then
						Events.AudioPlay2DSound("AS2D_UNIT_FORTIFY");
					end
				end
			end
		end
	end
end
Events.UnitActionChanged.Add(OnUnitActionChanged);
-------------------------------------------------------------------------------
-- General changes to the game:
-------------------------------------------------------------------------------	
function GrantStartingUnits(playerType, plotX, plotY)
	local player = Players[playerType];
	local plot = Map.GetPlot(plotX, plotY);
	local city = plot:GetPlotCity();
	local terrainType = plot:GetTerrainType();
	local handicap = player:GetHandicapType();
	if city:IsCapital() == true then
		--MGH:Always start with a Worker
		local unitWorker = player:InitUnit(GameInfo.Units["UNIT_WORKER"].ID, plotX, plotY);
		--unitWorker:JumpToNearestValidPlot();
		print("PreGame.GetLoadoutCargo(playerType)=???");
		--MGH:Always start with a Ultrasonic emitter
		--if PreGame.GetLoadoutCargo(playerType) == GameInfo.Cargo["CARGO_ULTRASONIC_EMITTER"].ID then
			local unitUE = player:InitUnit(GameInfo.Units["UNIT_ULTRASONIC_EMITTER"].ID, plotX, plotY);
			unitUE:JumpToNearestValidPlot();
		--end
		if terrainType == TerrainTypes.TERRAIN_COAST or terrainType == TerrainTypes.TERRAIN_OCEAN then
			-- Extra Units for AI
			if not player:IsHuman() then
				if handicap > 5 then--1 low/7 high
					local unitNavalMeleeAI = player:InitUnit(GameInfo.Units["UNIT_NAVAL_MELEE"].ID, plotX, plotY);
					unitNavalMeleeAI:JumpToNearestValidPlot();
				end		
			end
		else
			-- Extra Units for AI
			if not player:IsHuman() then
				if handicap > 5 then--1 low/7 high
					local unitMarineAI = player:InitUnit(GameInfo.Units["UNIT_MARINE"].ID, plotX, plotY);
					unitMarineAI:JumpToNearestValidPlot();
				end		
			end
		end
	end
end
GameEvents.CityCreated.Add(GrantStartingUnits);