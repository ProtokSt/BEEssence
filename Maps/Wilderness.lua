-- ===========================================================================
---- 2023 - Blessed by Protok St.
---- SUMMARY: 6th map size,
---- PangaeaFractalWorld:GeneratePlotTypes(args)
---- FeatureGenerator:__initTundraWildHeights()
---- GetMapScriptInfo() - miasma spawn option
---- AddFeatures() - miasma spawn option
---- FeatureGenerator:AddFeaturesAtPlot(iX, iY) - fixing a bug of missing reefs
-- ===========================================================================
---- VERSION: Migugh modified 2025-02-10
---- MGH icon index changed
---- MGH added a lake/ocean in the middle and add the resources appear again
---- MGH more affinity resources on wild areas
-- ===========================================================================
------------------------------------------------------------------------------
--	FILE:	 Wilderness.lua
--	AUTHOR:  Bob Thomas
--	PURPOSE: Global map script - Simulates a supercontinent with a heavily 
--	         infested alien wilderness in its heartland. All starts on coast.
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

include("MapGenerator");
include("FractalWorld");
include("FeatureGenerator");
include("TerrainGenerator");
include("RiverGenerator");
include("IslandMaker");

------------------------------------------------------------------------------
function GetMapScriptInfo()
	local world_age, temperature, rainfall, sea_level, resources = GetCoreMapOptions()
	return {
		Name = "TXT_KEY_MAP_WILDERNESS_NAME",
		Type = "TXT_KEY_MAP_WILDERNESS_TYPE",
		Description = "TXT_KEY_MAP_WILDERNESS_HELP",
		--IsAdvancedMap = false,--MGH
		IconIndex = 21,--MGH (old:0)
		SortIndex = 2,
		CustomOptions = {world_age, temperature, rainfall, sea_level, resources},
	}
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
------------------------------------------------------------------------------
PangaeaFractalWorld = {};
------------------------------------------------------------------------------
function PangaeaFractalWorld.Create(fracXExp, fracYExp)
	local gridWidth, gridHeight = Map.GetGridSize();
	
	local data = {
		InitFractal = FractalWorld.InitFractal,
		ShiftPlotTypes = FractalWorld.ShiftPlotTypes,
		ShiftPlotTypesBy = FractalWorld.ShiftPlotTypesBy,
		DetermineXShift = FractalWorld.DetermineXShift,
		DetermineYShift = FractalWorld.DetermineYShift,
		GenerateCenterRift = FractalWorld.GenerateCenterRift,
		GeneratePlotTypes = PangaeaFractalWorld.GeneratePlotTypes,	-- Custom method
		
		iFlags = Map.GetFractalFlags(),
		
		fracXExp = fracXExp,
		fracYExp = fracYExp,
		
		iNumPlotsX = gridWidth,
		iNumPlotsY = gridHeight,
		plotTypes = table.fill(PlotTypes.PLOT_OCEAN, gridWidth * gridHeight)
	};
		
	return data;
end	
------------------------------------------------------------------------------
function PangaeaFractalWorld:GeneratePlotTypes(args)
	if(args == nil) then args = {}; end
	local iW, iH = Map.GetGridSize()
	local fracFlags = {FRAC_POLAR = true};
	
	local sea_level_low = 48;--MGH (old:62)
	local sea_level_normal = 56;--MGH (old:66)
	local sea_level_high = 64;--MGH (old:70)
	local world_age_old = 2;
	local world_age_normal = 3;
	local world_age_new = 5;
	--
	local extra_mountains = 2;
	local grain_amount = 3;
	local adjust_plates = 1.2;
	local shift_plot_types = true;
	local tectonic_islands = true;
	local hills_ridge_flags = self.iFlags;
	local peaks_ridge_flags = self.iFlags;
	local has_center_rift = false;
	
	local sea_level = Map.GetCustomOption(4)
	if sea_level == 4 then
		sea_level = 1 + Map.Rand(3, "Random Sea Level - Lua");
	end
	local world_age = Map.GetCustomOption(1)
	if world_age == 4 then
		world_age = 1 + Map.Rand(3, "Random World Age - Lua");
	end

	-- Set Sea Level according to user selection.
	local water_percent = sea_level_normal;
	if sea_level == 1 then -- Low Sea Level
		water_percent = sea_level_low
	elseif sea_level == 3 then -- High Sea Level
		water_percent = sea_level_high
	else -- Normal Sea Level
	end

	-- Set values for hills and mountains according to World Age chosen by user.
	local adjustment = world_age_normal;
	if world_age == 3 then -- 5 Billion Years
		adjustment = world_age_old;
		adjust_plates = adjust_plates * 0.75;
	elseif world_age == 1 then -- 3 Billion Years
		adjustment = world_age_new;
		adjust_plates = adjust_plates * 1.5;
	else -- 4 Billion Years
	end
	-- Apply adjustment to hills and peaks settings.
	local hillsBottom1 = 28 - adjustment;
	local hillsTop1 = 28 + adjustment;
	local hillsBottom2 = 72 - adjustment;
	local hillsTop2 = 72 + adjustment;
	local hillsClumps = 1 + adjustment;
	local hillsNearMountains = 91 - (adjustment * 2) - extra_mountains;
	local mountains = 97 - adjustment - extra_mountains;

	-- Hills and Mountains handled differently according to map size - Bob
	local WorldSizeTypes = {};
	for row in GameInfo.Worlds() do
		WorldSizeTypes[row.Type] = row.ID;
	end
	local sizekey = Map.GetWorldSize();
	-- Fractal Grains
	local sizevalues = {
		[WorldSizeTypes.WORLDSIZE_DUEL]     = 3,
		[WorldSizeTypes.WORLDSIZE_TINY]     = 3,
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 4,
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 4,
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 5,
		[WorldSizeTypes.WORLDSIZE_HUGE]		= 5
	};
	local grain = sizevalues[sizekey] or 3;
	-- Tectonics Plate Counts
	local platevalues = {
		[WorldSizeTypes.WORLDSIZE_DUEL]		= 6,
		[WorldSizeTypes.WORLDSIZE_TINY]     = 9,
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 12,
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 18,
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 24,
		[WorldSizeTypes.WORLDSIZE_HUGE]     = 30
	};
	local numPlates = platevalues[sizekey] or 5;
	-- Add in any plate count modifications passed in from the map script. - Bob
	numPlates = numPlates * adjust_plates;

	-- Generate continental fractal layer and examine the largest landmass. Reject
	-- the result until the largest landmass occupies 85% or more of the total land.
	local done = false;
	local iAttempts = 0;
	local iWaterThreshold, biggest_area, iNumTotalLandTiles, iNumBiggestAreaTiles, iBiggestID;

	-- Wilderness oval data.
	local arms_list = {0.48, 0.44, 0.40};
	local arms_multiplier = arms_list[sea_level];
	local wilderness_list = {0.42, 0.38, 0.34};
	local wilderness_multiplier = wilderness_list[sea_level];
	local cohesion_list = {0.33, 0.3, 0.27};
	local cohesion_multiplier = cohesion_list[sea_level];
	local centerX = iW / 2;
	local centerY = iH / 2;
	local majorAxis_arms = centerX * arms_multiplier;
	local minorAxis_arms = centerY * arms_multiplier;
	local majorAxis_outer = centerX * wilderness_multiplier;
	local minorAxis_outer = centerY * wilderness_multiplier;
	local majorAxis_inner = centerX * cohesion_multiplier;
	local minorAxis_inner = centerY * cohesion_multiplier;
	local majorAxisSquared_arms = majorAxis_arms * majorAxis_arms;
	local minorAxisSquared_arms = minorAxis_arms * minorAxis_arms;
	local majorAxisSquared_outer = majorAxis_outer * majorAxis_outer;
	local minorAxisSquared_outer = minorAxis_outer * minorAxis_outer;
	local majorAxisSquared_inner = majorAxis_inner * majorAxis_inner;
	local minorAxisSquared_inner = minorAxis_inner * minorAxis_inner;

	-- Main loop. Crafts a pangaea plus the wilderness area. Total must meet landmass cohesion requirements.
	while done == false do
		self.continentsFrac = nil;
		self:InitFractal{continent_grain = 1, rift_grain = -1};
		iWaterThreshold = self.continentsFrac:GetHeight(water_percent);
		
		iNumTotalLandTiles = 0;
		for x = 0, self.iNumPlotsX - 1 do
			for y = 0, self.iNumPlotsY - 1 do
				local i = y * self.iNumPlotsX + x;
				local val = self.continentsFrac:GetHeight(x, y);
				if(val <= iWaterThreshold) then
					self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
				else
					self.plotTypes[i] = PlotTypes.PLOT_LAND;
					iNumTotalLandTiles = iNumTotalLandTiles + 1;
				end
			end
		end
		
		SetPlotTypes(self.plotTypes);
		Map.RecalculateAreas();
		
		biggest_area = Map.FindBiggestArea(false);
		iNumBiggestAreaTiles = biggest_area:GetNumTiles();
		-- Now test the biggest landmass to see if it is large enough.
		if iNumBiggestAreaTiles >= iNumTotalLandTiles * 0.65 then --MGH:(old: 0.85)
			done = true;
			iBiggestID = biggest_area:GetID();
		end
		iAttempts = iAttempts + 1;
		
		--[[ Printout for debug use only
		print("-"); print("--- Pangaea landmass generation, Attempt#", iAttempts, "---");
		print("- This attempt successful: ", done);
		print("- Total Land Plots in world:", iNumTotalLandTiles);
		print("- Land Plots belonging to biggest landmass:", iNumBiggestAreaTiles);
		print("- Percentage of land belonging to Pangaea: ", 100 * iNumBiggestAreaTiles / iNumTotalLandTiles);
		print("- Continent Grain for this attempt: ", grain_dice);
		print("- Rift Grain for this attempt: ", rift_dice);
		print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
		print(".");
		]]--
	end

	self:ShiftPlotTypes();

	-- Craft the Wildnerness at the center of the continent.
	local armsFrac = Fractal.Create(iW, iH, 4, fracFlags, -1, -1);
	local iArmsThreshold = armsFrac:GetHeight(85);
	local wildernessFrac = Fractal.Create(iW, iH, 4, fracFlags, -1, -1);
	local iThreshold = wildernessFrac:GetHeight(79);
	for y = 0, iH - 1 do
		for x = 0, iW - 1 do
			local deltaX = x - centerX;
			local deltaY = y - centerY;
			local deltaXSquared = deltaX * deltaX;
			local deltaYSquared = deltaY * deltaY;
			local d_arms = deltaXSquared/majorAxisSquared_outer + deltaYSquared/minorAxisSquared_outer;
			local d_outer = deltaXSquared/majorAxisSquared_outer + deltaYSquared/minorAxisSquared_outer;
			local d_inner = deltaXSquared/majorAxisSquared_inner + deltaYSquared/minorAxisSquared_inner;
			if d_outer <= 1 then -- Plot is inside the main oval.
				local i = y * iW + x + 1;
				local plot = Map.GetPlot(x, y);
				if d_inner > 1 then -- Plot is outside the core oval. Wild plot if fractal says so.
					local wildVal = wildernessFrac:GetHeight(x, y);
					if wildVal < iThreshold then -- Wild plot, must be land.
						if self.plotTypes[i] == PlotTypes.PLOT_OCEAN then
							self.plotTypes[i] = PlotTypes.PLOT_LAND;
						end
						plot:SetWildness(11); -- Setting all Wildness to Forest Periphery (11) for starters. Will sort out "Core" plots and terrain types later.
					end
				--MGH: else -- Plot is inside the core oval. Wild plot, must be land.
				--MGH: 	if self.plotTypes[i] == PlotTypes.PLOT_OCEAN then
				--MGH: 		self.plotTypes[i] = PlotTypes.PLOT_LAND;
				--MGH: 	end
				--MGH:	plot:SetWildness(11);
				end
			elseif d_arms <= 1 then -- Plot is inside the "add snaky arms" oval.
				local armsVal = wildernessFrac:GetHeight(x, y);
				if armsVal >= iArmsThreshold then -- Convert to land, if ocean.
					if self.plotTypes[i] == PlotTypes.PLOT_OCEAN then
						self.plotTypes[i] = PlotTypes.PLOT_LAND;
					end
				end
			end
		end
	end

	-- Generate fractals to govern hills and mountains
	self.hillsFrac = Fractal.Create(self.iNumPlotsX, self.iNumPlotsY, grain, self.iFlags, self.fracXExp, self.fracYExp);
	self.mountainsFrac = Fractal.Create(self.iNumPlotsX, self.iNumPlotsY, grain, self.iFlags, self.fracXExp, self.fracYExp);
	self.hillsFrac:BuildRidges(numPlates, hills_ridge_flags, 1, 2);
	self.mountainsFrac:BuildRidges((numPlates * 2) / 3, peaks_ridge_flags, 6, 1);
	-- Get height values
	local iHillsBottom1 = self.hillsFrac:GetHeight(hillsBottom1);
	local iHillsTop1 = self.hillsFrac:GetHeight(hillsTop1);
	local iHillsBottom2 = self.hillsFrac:GetHeight(hillsBottom2);
	local iHillsTop2 = self.hillsFrac:GetHeight(hillsTop2);
	local iHillsClumps = self.mountainsFrac:GetHeight(hillsClumps);
	local iHillsNearMountains = self.mountainsFrac:GetHeight(hillsNearMountains);
	local iMountainThreshold = self.mountainsFrac:GetHeight(mountains);
	local iPassThreshold = self.hillsFrac:GetHeight(hillsNearMountains);
	-- Get height values for tectonic islands
	local iMountain100 = self.mountainsFrac:GetHeight(100);
	local iMountain99 = self.mountainsFrac:GetHeight(99);
	local iMountain97 = self.mountainsFrac:GetHeight(97);
	local iMountain95 = self.mountainsFrac:GetHeight(95);

	for x = 0, self.iNumPlotsX - 1 do
		for y = 0, self.iNumPlotsY - 1 do
		
			local i = y * self.iNumPlotsX + x;
			local val = self.continentsFrac:GetHeight(x, y);
			local mountainVal = self.mountainsFrac:GetHeight(x, y);
			local hillVal = self.hillsFrac:GetHeight(x, y);
	
			if(val <= iWaterThreshold) then
				self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
				
				if tectonic_islands then -- Build islands in oceans along tectonic ridge lines - Brian
					if (mountainVal == iMountain100) then -- Isolated peak in the ocean
						self.plotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
						local plot = Map.GetPlot(x, y)
						if plot:GetWildness() > 0 then
							plot:SetWildness(0)
						end
					elseif (mountainVal == iMountain99) then
						self.plotTypes[i] = PlotTypes.PLOT_HILLS;
					elseif (mountainVal == iMountain97) or (mountainVal == iMountain95) then
						self.plotTypes[i] = PlotTypes.PLOT_LAND;
					end
				end
					
			else
				if (mountainVal >= iMountainThreshold) then
					if (hillVal >= iPassThreshold) then -- Mountain Pass though the ridgeline - Brian
						self.plotTypes[i] = PlotTypes.PLOT_HILLS;
					else -- Mountain
						self.plotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
						local plot = Map.GetPlot(x, y)
						if plot:GetWildness() > 0 then
							plot:SetWildness(0)
						end
					end
				elseif (mountainVal >= iHillsNearMountains) then
					self.plotTypes[i] = PlotTypes.PLOT_HILLS; -- Foot hills - Bob
				else
					if ((hillVal >= iHillsBottom1 and hillVal <= iHillsTop1) or (hillVal >= iHillsBottom2 and hillVal <= iHillsTop2)) then
						self.plotTypes[i] = PlotTypes.PLOT_HILLS;
					else
						self.plotTypes[i] = PlotTypes.PLOT_LAND;
					end
				end
			end
		end
	end
	
	local rand_lake_offset = Map.Rand(2, "Random Central Area - Lua");-- 0 to 2
	local cont = 0;
	--Turn all plots in buffer zone to a little lake.
	for x = (self.iNumPlotsX / 2) + rand_lake_offset - 2, (self.iNumPlotsX / 2) + rand_lake_offset do
		for y = (self.iNumPlotsY / 2) + rand_lake_offset - 2, (self.iNumPlotsY / 2) + rand_lake_offset do
			local i = y * self.iNumPlotsX + x;
			local rand_lake_percent = 1 + Map.Rand(20, "Random Lake - Lua");--90%,85%,80%,75%,70%... water
			if cont == 16 then
				break;
			elseif rand_lake_percent <= 18 - cont then
				self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
				cont = cont + 1;
			end
		end
	end
	rand_lake_offset = Map.Rand(6, "Random Central Area - Lua");-- 0 to 6
	for x = (self.iNumPlotsX / 2) + rand_lake_offset - 6, (self.iNumPlotsX / 2) + rand_lake_offset do
		for y = (self.iNumPlotsY / 2) + rand_lake_offset - 6, (self.iNumPlotsY / 2) + rand_lake_offset do
			local i = y * self.iNumPlotsX + x;
			local rand_lake_percent = 1 + Map.Rand(22, "Random Lake - Lua");--?%... water
			if cont == 16 then
				break;
			elseif rand_lake_percent <= 22 - cont then
				self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
				cont = cont + 1;
			end
		end
	end
	cont = 0;
	rand_lake_offset = Map.Rand(6, "Random Central Area - Lua");-- 0 to 6
	for x = (self.iNumPlotsX / 2) + rand_lake_offset, (self.iNumPlotsX / 2) + rand_lake_offset - 6, -1 do
		for y = (self.iNumPlotsY / 2) + rand_lake_offset, (self.iNumPlotsY / 2) + rand_lake_offset - 6, -1 do
			local i = y * self.iNumPlotsX + x;
			local rand_lake_percent = 1 + Map.Rand(30, "Random Lake - Lua");--?%... water
			if cont == 16 then
				break;
			elseif rand_lake_percent <= 24 - cont then
				self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
				cont = cont + 1;
			end
		end
	end

	return self.plotTypes;
end
------------------------------------------------------------------------------
function GeneratePlotTypes()
	-- Plot generation customized to ensure enough land belongs to the Pangaea.
	print("Generating Plot Types (Lua Wilderness) ...");
	
	local fractal_world = PangaeaFractalWorld.Create();
	local plotTypes = fractal_world:GeneratePlotTypes();
	
	SetPlotTypes(plotTypes);
	CreateSmallIslands(100);
	
	-- Examine all plots in buffer zone.
	local iW, iH = Map.GetGridSize();
	local firstRingYIsEven = {{0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}};
	local firstRingYIsOdd = {{1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}};
	--Remove some alone lakes in buffer zone
	for x = (iW / 2) - 6, (iW / 2) + 6 do
		for y = (iH / 2) - 6, (iH / 2) + 6 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_OCEAN then
				local isEvenY, search_table = true, {};
				if y / 2 > math.floor(y / 2) then
					isEvenY = false;
				end
				if isEvenY then
					search_table = firstRingYIsEven;
				else
					search_table = firstRingYIsOdd;
				end
				local num_findings = 0;
				for loop, plot_adjustments in ipairs(search_table) do
					local searchX, searchY;
					searchX = x + plot_adjustments[1];
					searchY = y + plot_adjustments[2];
					local searchPlot = Map.GetPlot(searchX, searchY)
					local plotType = searchPlot:GetPlotType()
					if plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS then
						num_findings = num_findings + 1;
						if num_findings == 5 then
							plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
							break;
						end
					end
				end
			end
		end
	end
	
	--Remove some alone rocks in buffer zone
	for x = (iW / 2) - 6, (iW / 2) + 6 do
		for y = (iH / 2) - 6, (iH / 2) + 6 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_LAND or plot:GetPlotType() == PlotTypes.PLOT_HILLS then
				local isEvenY, search_table = true, {};
				if y / 2 > math.floor(y / 2) then
					isEvenY = false;
				end
				if isEvenY then
					search_table = firstRingYIsEven;
				else
					search_table = firstRingYIsOdd;
				end
				local num_findings = 0;
				for loop, plot_adjustments in ipairs(search_table) do
					local searchX, searchY;
					searchX = x + plot_adjustments[1];
					searchY = y + plot_adjustments[2];
					local searchPlot = Map.GetPlot(searchX, searchY)
					local plotType = searchPlot:GetPlotType()
					if plotType == PlotTypes.PLOT_OCEAN then
						num_findings = num_findings + 1;
						if num_findings == 5 then
							plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false)
							break;
						end
					end
				end
			end
		end
	end
	
	GenerateCoasts();
end
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------	
function TerrainGenerator:InitFractals()
	self.deserts = Fractal.Create(	self.iWidth, self.iHeight, 
									4, self.fractalFlags,  -- Custom for Wilderness
									self.fracXExp, self.fracYExp);
									
	self.iDesertTop = self.deserts:GetHeight(self.iDesertTopPercent);
	self.iDesertBottom = self.deserts:GetHeight(self.iDesertBottomPercent);
	
	self.iDesertWildCore = self.deserts:GetHeight(self.coreThreshold);
	self.iDesertWildPeriphery = self.deserts:GetHeight(self.peripheryThreshold);

	self.plains = Fractal.Create(	self.iWidth, self.iHeight, 
									self.grain_amount, self.fractalFlags, 
									self.fracXExp, self.fracYExp);
									
	self.iPlainsTop = self.plains:GetHeight(self.iPlainsTopPercent);
	self.iPlainsBottom = self.plains:GetHeight(self.iPlainsBottomPercent);

	self.variation = Fractal.Create(self.iWidth, self.iHeight, 
									self.grain_amount, self.fractalFlags, 
									self.fracXExp, self.fracYExp);

	self.terrainDesert	= GameInfoTypes["TERRAIN_DESERT"];
	self.terrainPlains	= GameInfoTypes["TERRAIN_PLAINS"];
	self.terrainSnow	= GameInfoTypes["TERRAIN_SNOW"];
	self.terrainTundra	= GameInfoTypes["TERRAIN_TUNDRA"];
	self.terrainGrass	= GameInfoTypes["TERRAIN_GRASS"];	
end
----------------------------------------------------------------------------------
function TerrainGenerator:GenerateTerrainAtPlot(iX,iY)
	local lat = self:GetLatitudeAtPlot(iX,iY);

	local plot = Map.GetPlot(iX, iY);
	if (plot:IsWater()) then
		local val = plot:GetTerrainType();
		if val == TerrainTypes.NO_TERRAIN then -- Error handling.
			val = self.terrainGrass;
			plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
		end
		return val;	 
	end
	
	local terrainVal = self.terrainGrass;

	if(lat >= self.fSnowLatitude) then
		terrainVal = self.terrainSnow;
	elseif(lat >= self.fTundraLatitude) then
		terrainVal = self.terrainTundra;
	else
		local desertVal = self.deserts:GetHeight(iX, iY);
		local plainsVal = self.plains:GetHeight(iX, iY);
		if ((desertVal >= self.iDesertBottom) and (desertVal <= self.iDesertTop) and (lat < self.fDesertTopLatitude)) then
			terrainVal = self.terrainDesert;
		elseif ((plainsVal >= self.iPlainsBottom) and (plainsVal <= self.iPlainsTop)) then
			terrainVal = self.terrainPlains;
		end
	end
	
	-- Error handling.
	if (terrainVal == TerrainTypes.NO_TERRAIN) then
		return plot:GetTerrainType();
	end

	return terrainVal;
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain Types (Lua Wilderness) ...");
	
	-- Get Temperature setting input by user.
	local temp = Map.GetCustomOption(2)
	if temp == 4 then
		temp = 1 + Map.Rand(3, "Random Temperature - Lua");
	end

	local args = {
		temperature = temp,
		};
	local terraingen = TerrainGenerator.Create(args);

	terrainTypes = terraingen:GenerateTerrain();
	
	SetTerrainTypes(terrainTypes);
	
	-- Check terrain for Desert Wildness.
	local iW, iH = Map.GetGridSize()
	for y = 0, iH - 1 do
		for x = 0, iW - 1 do
			local plot = Map.GetPlot(x, y)
			local i_wild_value = plot:GetWildness()
			if i_wild_value == 11 then -- Wild Plot. Check for Desert terrain.
				local terrainType = plot:GetTerrainType()
				if terrainType == TerrainTypes.TERRAIN_DESERT then
					plot:SetWildness(21) -- Change Wildness value from Forest to Desert.
				end
			end
		end
	end
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function AddRivers()
	print("Generating Rivers, Canyons, and Lakes. (Lua Wilderness) ...");

	local args = {};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end
------------------------------------------------------------------------------
-- FEATURES, WILDNESS, MIASMA
------------------------------------------------------------------------------
function FeatureGenerator:__initTundraWildHeights()
	print("FeatureGenerator:__initTundraWildHeights() - Wilderness.lua");
	self.iNumCoreForestWilds = 0;
	self.iNumCoreDesertWilds = 0;
	self.iNumCoreTundraWilds = 0;
	self.iNumCoreOceanWilds = 0;
	self.iNumPeripheryForestWilds = 0;
	self.iNumPeripheryDesertWilds = 0;
	self.iNumPeripheryTundraWilds = 0;
	self.iNumPeripheryOceanWilds = 0;
	local iW, iH = Map.GetGridSize()
		
	-- Determine Tundra Wild Heights by counting eligible tundra tiles.
	self.iNumEligibleTundraTiles = 0;
	for x = 0, iW - 1 do
		for y = 0, iH - 1 do
			local plot = Map.GetPlot(x, y)
			local terrainType = plot:GetTerrainType()
			if terrainType == self.terrainTundra then
				local plotType = plot:GetPlotType()
				if plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS then
					self.iNumEligibleTundraTiles = self.iNumEligibleTundraTiles + 1;
				end
			end
			local check_for_desert_wild = plot:GetWildness()
			if check_for_desert_wild == 20 then
				self.iNumCoreDesertWilds = self.iNumCoreDesertWilds + 1;
			elseif check_for_desert_wild == 21 then
				self.iNumPeripheryDesertWilds = self.iNumPeripheryDesertWilds + 1;
			end
		end
	end
	print("-"); print("- Eligible Tundra tiles count: ", self.iNumEligibleTundraTiles);

	-- Desired number of tundra tiles per world size. If less than target, then increase ratio of tundra tiles used for Wild Area.	
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = 50,
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = 80,
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = 100,
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = 120,
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = 150,
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = 200,
		}
	local target = worldsizes[Map.GetWorldSize()];
	self.iTundraCoreHeight = 90;  -- Height to use if target or greater is found. At least (100 - this value)% of tundra tiles, by default, will be Wild Core.
	self.iTundraPeripheryHeight = 75; -- (100 - this value)% of tundra tiles, by default, will be Wild Periphery.
	self.CoreToPeripheryRatio = (100 - self.iTundraPeripheryHeight) / (100 - self.iTundraCoreHeight);
	if self.iNumEligibleTundraTiles < target then -- Adjust height downward (increasing ratio of tundra tiles assigned to be Wild).
		if self.iNumEligibleTundraTiles < target / 4 then
			self.iTundraCoreHeight = 25;
			self.iTundraPeripheryHeight = 0;
		else
			local adjusted = 100 - ((target - self.iNumEligibleTundraTiles) * 100 / target);
			self.iTundraCoreHeight = math.max(25, adjusted);
			local periph = 100 - ((100 - adjusted) * self.CoreToPeripheryRatio);
			if periph > 0 then
				self.iTundraPeripheryHeight = periph;
			else
				self.iTundraPeripheryHeight = 0;
			end
		end
	end
	print("- Tundra Core Height: ", self.iTundraCoreHeight);
	print("- - Periphery Height: ", self.iTundraPeripheryHeight); print("-");
	
	self.iTundraCoreLevel = self.forestclumps:GetHeight(self.iTundraCoreHeight)
	self.iTundraPeripheryLevel = self.forestclumps:GetHeight(self.iTundraPeripheryHeight)
	
end
------------------------------------------------------------------------------
function FeatureGenerator:AddFeaturesAtPlot(iX, iY)
	-- adds any appropriate features at the plot (iX, iY) where (0,0) is in the SW
	local lat = self:GetLatitudeAtPlot(iX, iY);
	local plot = Map.GetPlot(iX, iY);
	local is_wild = plot:GetWildness()
	
	if plot:CanHaveFeature(self.featureFloodPlains) then
		-- All desert plots along river are set to flood plains.
		plot:SetFeatureType(self.featureFloodPlains, -1)
	end
	
	if (plot:GetFeatureType() == FeatureTypes.NO_FEATURE) then
		self:AddIceAtPlot(plot, iX, iY, lat);
	end

	if (plot:GetFeatureType() == FeatureTypes.NO_FEATURE) then
		self:AddMarshAtPlot(plot, iX, iY, lat);
	end
		
	if (plot:GetFeatureType() == FeatureTypes.NO_FEATURE) then
		self:AddForestsAtPlot(plot, iX, iY, lat);
	end
		
	if (plot:GetFeatureType() == FeatureTypes.NO_FEATURE) then
		self:AddJunglesAtPlot(plot, iX, iY, lat);
	end
	
	--MGH bug fixed
	if (plot:GetFeatureType() == FeatureTypes.NO_FEATURE) then
		self:AddReefsAtPlot(plot);
	end
	
	--MGH bug fixed
	if (plot:GetFeatureType() == FeatureTypes.NO_FEATURE) then
		self:AddShallowForestsAtPlot(plot, iX, iY, lat);
	end
	
	if (plot:GetFeatureType() == FeatureTypes.NO_FEATURE) then
		if is_wild == 11 then
			plot:SetWildness(21) -- Setting any Wild no-feature plots of grass or plains as "Desert Wild".
		end
	end
	
	self:DetermineWildness(plot, iX, iY, lat)
end
------------------------------------------------------------------------------
function FeatureGenerator:DetermineWildness(plot, iX, iY, lat)
	-- Handle Wild Area. Determine Core plots.
	local is_wild = plot:GetWildness()
	if is_wild > 0 then -- Wild Plot. Check to see if convert to Core wild plot.
		local iWildVal = self.forestclumps:GetHeight(iX, iY)
		if iWildVal >= self.iClumpLevel then -- Set as Core plot.
			if is_wild == 11 then
				plot:SetWildness(10) -- Forest wild area, Core plot.
				self.iNumCoreForestWilds = self.iNumCoreForestWilds + 1;
			elseif is_wild == 21 then
				plot:SetWildness(20) -- Desert wild area, Core plot.
				self.iNumCoreDesertWilds = self.iNumCoreDesertWilds + 1;
			else
				print("Unexpected Wildness value: " .. is_wild .. " found at Plot " .. iX .. ", " .. iY);
			end
		else
			if is_wild == 11 then
				self.iNumPeripheryForestWilds = self.iNumPeripheryForestWilds + 1;
			elseif is_wild == 21 then
				self.iNumPeripheryDesertWilds = self.iNumPeripheryDesertWilds + 1;
			end
		end
	else -- Check to see if needs to be set as tundra or ocean wild.
		local iWildVal = self.forestclumps:GetHeight(iX, iY)
		if plot:IsWater() then -- Ocean plot.
			if not plot:IsLake() then
				if iWildVal >= self.iWildAreaLevel then
					plot:SetWildness(40) -- Designate as a "core" wild plot in an oceanic Wild Area.
					self.iNumCoreOceanWilds = self.iNumCoreOceanWilds + 1;
				elseif iWildVal >= self.iClumpLevel then
					plot:SetWildness(41) -- Designate as a "periphery" wild plot in an oceanic Wild Area.
					self.iNumPeripheryOceanWilds = self.iNumPeripheryOceanWilds + 1;
				end
			end
		elseif not (plot:IsMountain() or plot:IsCanyon()) then -- Land plot.
			local terrain_value = plot:GetTerrainType()
			if terrain_value == self.terrainTundra then -- Check for Tundra Wildness.
				if iWildVal >= self.iTundraCoreLevel then -- Tundra Wild Area, Core plot.
					plot:SetWildness(30)
					self.iNumCoreTundraWilds = self.iNumCoreTundraWilds + 1;
				elseif iWildVal >= self.iTundraPeripheryLevel then -- Tundra Wild Area, Periphery plot.
					plot:SetWildness(31)
					self.iNumPeripheryTundraWilds = self.iNumPeripheryTundraWilds + 1;
				end
			end
		end
	end
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features (Lua Wilderness) ...");

	-- Get Rainfall setting input by user.
	local rain = Map.GetCustomOption(3)
	if rain == 4 then
		rain = 1 + Map.Rand(3, "Random Rainfall - Lua");
	end
	-- PW:Get Miasma setting input by user.
	local miasma = Map.GetCustomOption(6)
	
	local args = {
		rainfall = rain,
		miasmaSpawnWay = miasma, -- PW
		};
	local featuregen = FeatureGenerator.Create(args);

	-- False parameter removes mountains from coastlines.
	featuregen:AddFeatures(false);
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function AssignStartingPlots:__CustomInit()
	self.wild_score_forgiveness_factor = 80;
end	
------------------------------------------------------------------------------
function StartPlotSystem()
	-- Get Resources setting input by user.
	local res = Map.GetCustomOption(5)
	if res == 6 then
		res = 1 + Map.Rand(3, "Random Resources Option - Lua");
	end

	print("Creating start plot database.");
	local start_plot_database = AssignStartingPlots.Create()
	
	print("Dividing the map in to Regions.");
	-- Regional Division Method 5: All Start
	local args = {
		method = 5,
		resources = res,
		};
	start_plot_database:GenerateRegions(args)

	print("Choosing start locations for civilizations.");
	local args = {mustBeCoast = true};
	start_plot_database:ChooseLocations(args)
	
	print("Normalizing start locations and assigning them to Players.");
	start_plot_database:BalanceAndAssign()

	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()
end
------------------------------------------------------------------------------
--MGH: function AssignStartingPlots:CreateResources(fertilityMap : table)
--MGH: end
------------------------------------------------------------------------------
--MGH: More Affinity resources
function AssignStartingPlots:PlaceKeyStrategics()
	-- This is a BE function to regulate the amounts of the "key" strategics that get placed.
	-- This regulation pertains to Float Stone, Xenomass and Firaxite.
	self:GetKeyStrategicsTargetValues()
	
	-- Process large deposits inside wild areas.
	local rand1, rand2, rand3 = self.xenomass_max - self.xenomass_min + 1, self.firaxite_max - self.firaxite_min + 1, self.floatstone_max - self.floatstone_min + 1;
	local large_xenomass_target = Map.Rand(rand1 + 5, "Number of Large Xenomass deposits to place - Lua") + self.xenomass_min; -- MGH
	local large_firaxite_target = Map.Rand(rand2 + 5, "Number of Large Firaxite deposits to place - Lua") + self.firaxite_min; -- MGH
	local large_floatstone_target = Map.Rand(rand3 + 5, "Number of Large Float Stone deposits to place - Lua") + self.floatstone_min; -- MGH
	
	local resources_to_place = {
	{self.xenomass_ID, self.xenomass_base, self.xenomass_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.large_xenomass_list, resources_to_place, true, large_xenomass_target)
	
	local resources_to_place = {
	{self.firaxite_ID, self.firaxite_base, self.firaxite_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.large_firaxite_list, resources_to_place, true, large_firaxite_target)
	
	local resources_to_place = {
	{self.floatstone_ID, self.floatstone_base, self.floatstone_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.large_floatstone_list, resources_to_place, true, large_floatstone_target)
end
------------------------------------------------------------------------------
--MGH: Less basic resources for this map
function AssignStartingPlots:PlaceBasicResources()
end
------------------------------------------------------------------------------
function getLandmarksOption() --PW
	print("getLandmarksOption customed by map");
	local landmarks = Map.GetCustomOption(7) or 3;
	return landmarks;
end