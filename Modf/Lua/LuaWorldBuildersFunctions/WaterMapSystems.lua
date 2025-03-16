--MGH modified
------------------------------------------------------------------------------
--	FILE:	 WaterMapSystems.lua
--	AUTHOR:  Bob Thomas
--	PURPOSE: Functions designed to resource placement on water.
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------
include("MapmakerUtilities");
------------------------------------------------------------------------------
-- PROTOTYPE Methods
------------------------------------------------------------------------------
hstructure StartLocation
	PlotIndex : number
	Value : number
end

------------------------------------------------------------------------------
function ProtytypeGenerateWaterTerrain(args)
	print("PROTOTYPE Water Terrain depth process");
	
	local gridWidth, gridHeight = Map.GetGridSize();

	local perlinOffset = {
		x = Map.Rand(600, "Water Depth Perlin offset X value") / 100,
		y = Map.Rand(600, "Water Depth Perlin offset Y value") / 100,
	};

	local shallowWater = GameDefines.SHALLOW_WATER_TERRAIN;
	local deepWater = GameDefines.DEEP_WATER_TERRAIN;
	local trench = GameDefines.TRENCH_WATER_TERRAIN;

	local depthFrequency : number = 4.0;
	local amplitude : number = 1.0;

	for i, plot in Plots() do
		if(plot:IsWater()) then
			if(plot:IsAdjacentToLand()) then
				plot:SetTerrainType(shallowWater, false, false);
			else
				-- Get perlin value for this location
				local perlinX : number = (plot:GetX() / gridWidth + perlinOffset.x) * depthFrequency;
				local perlinY : number = (plot:GetY() / gridHeight + perlinOffset.y) * depthFrequency;
				local depthValue : number = Fractal.GetPerlinNoise(perlinX, perlinY) * amplitude;

				if (depthValue > 0) then					
					if (depthValue > 0.6) then
						plot:SetTerrainType(trench, false, false);
					else
						plot:SetTerrainType(deepWater, false, false);
					end
					--plot:SetTerrainType(deepWater, false, false);
				else
					plot:SetTerrainType(shallowWater, false, false);
				end
			end
		end
	end
end

------------------------------------------------------------------------------
function PrototypePlaceWaterResources(args)
	print("PROTOTYPE Water Terrain resource placement (TestTerran.Lua)");

	-- What % of the relevant plots should get a resource (roughly)
	local density : number = 20;

	local shallowResources:table = {};
	local deepResources:table = {};

	for row in GameInfo.Resource_TerrainBooleans() do
		if row.TerrainType == "TERRAIN_COAST" then
			table.insert(shallowResources, row.ResourceType);
		elseif row.TerrainType == "TERRAIN_OCEAN" then
			table.insert(deepResources, row.ResourceType);
		end
	end
	
	local lakeResources:table = {}; -- MGH

	for row in GameInfo.Resource_FeatureBooleans() do -- MGH
		if row.FeatureType == "FEATURE_LAKE" then
			table.insert(lakeResources, row.ResourceType);
		end
	end

	for i, plot in Plots() do
		if(plot:IsWater()) then
			if plot:IsLake() then -- MGH
				plot:SetFeatureType(self.featureRiver, -1);
				print("self.featureRiver: " .. self.featureRiver);
			end
			-- Avoid considering water plots adjacent to land, as those are already incorporated in the standard resource placer
			if (not plot:IsAdjacentToLand()) then
				-- Random chance to place a resource at each water plot (under given density)
				local randChance : number = Map.Rand(100, "Water resource random chance");
				if (randChance < density) then				
					
					-- Select a resource
					if plot:IsLake() then -- MGH
						local resourceRoll : number = 1 + Map.Rand(#lakeResources, "Lake Resource selection roll");
						local resourceType : string = lakeResources[resourceRoll];
						if resourceType ~= nil then
							local resourceInfo : table = GameInfo.Resources[resourceType];
							plot:SetResourceType(resourceInfo.ID, 1);
						end
					elseif plot:GetTerrainType() == GameDefines.SHALLOW_WATER_TERRAIN then
						local resourceRoll : number = 1 + Map.Rand(#shallowResources, "Shallow Resource selection roll");
						local resourceType : string = shallowResources[resourceRoll];
						if resourceType ~= nil then
							local resourceInfo : table = GameInfo.Resources[resourceType];
							plot:SetResourceType(resourceInfo.ID, 1);
						end
					else
						local resourceRoll : number = 1 + Map.Rand(#deepResources, "Deep Resource selection roll");
						local resourceType : string = deepResources[resourceRoll];
						if resourceType ~= nil then
							local resourceInfo : table = GameInfo.Resources[resourceType];
							plot:SetResourceType(resourceInfo.ID, 1);
						end
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------------
function PrototypePlaceWaterStartLocations(args)

	-- Cache IDs for players that require water start
	local waterStartPlayers : table = {};
	for playerType : number = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
		local player = Players[playerType];
		if (not player:IsMinorCiv() and player:IsEverAlive()) then
			if PlayerShouldStartWater(playerType) then	--	MapmakerUtilities			
				table.insert(waterStartPlayers, playerType);
			end
		end
	end

	local candidatePlot : object = nil;
	local allCandidates : table = {};

	local rangeToLand : number = 3;
	local rangeToOther : number = 8;

	for plotIndex : number = 0, Map.GetNumPlots() - 1, 1 do
		candidatePlot = Map.GetPlotByIndex(plotIndex);

		-- Valid water city sites must be:
		--	-	Shallow terrain
		--	-	At least X tiles from land
		--	-	At least Y tiles from another player start
		if (candidatePlot:GetTerrainType() == GameDefines.SHALLOW_WATER_TERRAIN) then

			local valid : boolean = true;
			local thisX : number = candidatePlot:GetX();
			local thisY : number = candidatePlot:GetY();
			local nearbyPlot : object = nil;

			for dX : number = -rangeToOther, rangeToOther do
				for dY : number = -rangeToOther, rangeToOther do

					nearbyPlot = Map.GetPlotXY(thisX, thisY, dX, dY);
					if (nearbyPlot ~= nil) then
						
						if (nearbyPlot:IsStartingPlot()) then
							valid = false;
							break;
						else
							local distance : number = Map.PlotDistance(thisX, thisY, nearbyPlot:GetX(), nearbyPlot:GetY());
							if (not nearbyPlot:IsWater() and distance <= rangeToLand) then
								valid = false;
								break;
							end
						end
					end
				end
			end

			if (valid == true) then
				local foundValue : number = candidatePlot:GetFoundValue(0);
				if foundValue > 0 then
					local data = hmake StartLocation
					{
						PlotIndex = candidatePlot:GetPlotIndex();
						Value = foundValue;
					};
					table.insert(allCandidates, data);
				end
			end
		end
	end

	if (#allCandidates > 0) then

		table.sort(allCandidates, function(a, b) 
			if(a.Value == b.Value) then
				return a.PlotIndex > b.PlotIndex;
			else
				return a.Value > b.Value;
			end
		end);


		for i, playerID : number in ipairs(waterStartPlayers) do

			local startPlotData : StartLocation = allCandidates[i];
			local plot : object = Map.GetPlotByIndex(startPlotData.PlotIndex);
			local player : object = Players[playerID]
			if (plot ~= nil and player ~= nil) then
				player:SetStartingPlot(plot)
			end
		end
	end
end
