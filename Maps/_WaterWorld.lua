-- ===========================================================================
---- VERSION: Migugh modified 2025-02-10
-- ===========================================================================
--------------------------------------------------------------------------------
--	FILE:	 _WaterWorld.lua
--  VERSION: 1.1.0
--	AUTHOR:  Migugh
--  BASED ON: WaterWorld.lua by Keith Sponburgh (Steam: EvilVictor -- Civ Fanatics: Seven05)
--	PURPOSE: Produces an ocean world - Optimized for 1v1 or two-teams multiplayer
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

include("MapGenerator");
include("MultilayeredFractal");
include("TerrainGenerator");
include("RiverGenerator");
include("FeatureGenerator");
include("MapmakerUtilities");

-------------------------------------------------------------------------------
function GetMapScriptInfo()
	--local world_age, temperature, rainfall, sea_level, resources = GetCoreMapOptions()
	local world_age, temperature, rainfall, sea_level, resources, miasma_spawn, planet_landmarks = GetCoreMapOptions()
	return {
		Name = "TXT_KEY_MAP_WATERWORLD_NAME",--MGH WaterWorld
		Type = "TXT_KEY_MAP_WATERWORLD_TYPE",--MGH
		Description = "TXT_KEY_MAP_WATERWORLD_HELP",--MGH
		--IconAtlas = "WORLDTYPE_ATLAS",
		IconIndex = 3,--MGH (old:17)
		CustomOptions = {
			{
				Name = "TXT_KEY_MAP_OPTION_DOMINANT_TERRAIN",
				Values = {
					{"TXT_KEY_MAP_SCRIPT_SKIRMISH_GRASSLANDS", "TXT_KEY_MAP_SCRIPT_SKIRMISH_GRASSLANDS_HELP"},
					{"TXT_KEY_MAP_SCRIPT_SKIRMISH_PLAINS", "TXT_KEY_MAP_SCRIPT_SKIRMISH_PLAINS_HELP"},
					{"TXT_KEY_MAP_SCRIPT_SKIRMISH_FOREST", "TXT_KEY_MAP_SCRIPT_SKIRMISH_FOREST_HELP"},
					{"TXT_KEY_MAP_SCRIPT_SKIRMISH_MARSH", "TXT_KEY_MAP_SCRIPT_SKIRMISH_MARSH_HELP"},
					{"TXT_KEY_MAP_SCRIPT_SKIRMISH_DESERT", "TXT_KEY_MAP_SCRIPT_SKIRMISH_DESERT_HELP"},
					{"TXT_KEY_MAP_SCRIPT_SKIRMISH_TUNDRA", "TXT_KEY_MAP_SCRIPT_SKIRMISH_TUNDRA_HELP"},
					{"TXT_KEY_MAP_SCRIPT_SKIRMISH_HILLS", "TXT_KEY_MAP_SCRIPT_SKIRMISH_HILLS_HELP"},
					{"TXT_KEY_MAP_OPTION_GLOBAL_CLIMATE", "TXT_KEY_MAP_OPTION_GLOBAL_CLIMATE_HELP"},
					"TXT_KEY_MAP_OPTION_RANDOM",
				},
				DefaultValue = 9,
				SortPriority = 1,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_SEA_LEVEL",
				Values = {
					"TXT_KEY_MAP_OPTION_LOW",
					"TXT_KEY_MAP_OPTION_MEDIUM",
					"TXT_KEY_MAP_OPTION_HIGH",
					"TXT_KEY_MAP_OPTION_RANDOM",
				},
				DefaultValue = 1,
				SortPriority = 2,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_RESOURCES",	-- Customizing the Resource setting to Default to Strategic Balance.
				Values = { -- Only one option here, but this will let all users know that resources are not set at default.
					-- Balanced Res script works only in vanilla. May be I will rework it later for RT.
					-- Now here will be my Resources Option
					--"TXT_KEY_MAP_OPTION_BALANCED_RESOURCES", -- obsolete untill reworked
					{"TXT_KEY_MAP_OPTION_SPARSE", "TXT_KEY_MAP_OPTION_RES_SPARSE_HELP"},
					{"TXT_KEY_MAP_OPTION_STANDARD", "TXT_KEY_MAP_OPTION_RES_STANDARD_HELP"},
					{"TXT_KEY_MAP_OPTION_ABUNDANT", "TXT_KEY_MAP_OPTION_RES_ABUNDANT_HELP"},
					{"TXT_KEY_MAP_OPTION_LEGENDARY_START", "TXT_KEY_MAP_OPTION_RES_LEGENDARY_START_HELP"},
					{"TXT_KEY_MAP_OPTION_STRATEGIC_BALANCE", "TXT_KEY_MAP_OPTION_RES_STRATEGIC_BALANCE_HELP"},
					{"TXT_KEY_MAP_OPTION_RANDOM", "TXT_KEY_MAP_OPTION_RES_RANDOM_HELP"},
					{"TXT_KEY_MAP_OPTION_RES_REAL_RANDOM", "TXT_KEY_MAP_OPTION_RES_REAL_RANDOM_HELP"},
					{"TXT_KEY_MAP_OPTION_RES_COMPET", "TXT_KEY_MAP_OPTION_RES_COMPET_HELP"},
				},
				DefaultValue = 5,
				SortPriority = 3,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_STARTINGS",
				Description = "TXT_KEY_MAP_OPTION_STARTINGS_HELP",
				Values = { -- MGH: Team 2vs2 support (optimized for start on water)
					{"TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_USUAL", "TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_USUAL_HELP"},
					{"TXT_KEY_MAP_OPTION_STARTINGS_TEAMS_WE", "TXT_KEY_MAP_OPTION_STARTINGS_TEAMS_WE_HELP"},
				},
				DefaultValue = 1,
				SortPriority = 4,
			},
			miasma_spawn,
			planet_landmarks,
		},
	}
end
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
function GetMapInitData(worldSize)
	print("GetMapInitData Start ---- ") -- dbg
	-- This function can reset map grid sizes or world wrap settings.
	-- Optional func called by engine
	--
	-- make advanced start MAP options available for all functions
	g_DOMINANT_TERRAIN_Option = Map.GetCustomOption(1) -- GLOBAL variable.
	g_WATER_Option 			  = 1 -- GLOBAL variable.
	g_SEALEVEL_Option		  = Map.GetCustomOption(2) -- GLOBAL variable.
	g_ResourcesOption 		  = Map.GetCustomOption(3) -- GLOBAL variable.
	g_StartingsOption 		  = Map.GetCustomOption(4) -- GLOBAL variable.
	g_LandscapeOption 		  = 1 -- GLOBAL variable.
	g_MiasmaOption 			  = Map.GetCustomOption(5) -- GLOBAL variable.
	g_LandmarksOption 		  = Map.GetCustomOption(6) -- GLOBAL variable.
	
	local worldsizes = {
		-- Sizes for worlds without oceans:
		--		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {28, 18},
		-- 		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {36, 22},
		-- 		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {46, 28},
		-- 		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {60, 36},
		-- 		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {72, 44},
		-- 		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {84, 52}
		-- Sizes for worlds with oceans:
 		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {34, 24},
 		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {42, 30},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {54, 38},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {68, 48},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {86, 60},
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {108, 76}
		}
	local grid_size = worldsizes[worldSize];
	--
	local world = GameInfo.Worlds[worldSize];
	if(world ~= nil) then
	return {
		Width = grid_size[1],
		Height = grid_size[2],
		WrapX = true, --Wrap or not the map
	};      
    end
end
-------------------------------------------------------------------------------------------
function MultilayeredFractal:GeneratePlotsByRegion()
	-- Sirian's MultilayeredFractal controlling function.
	-- This implementation is specific to _WaterWorld.
	
	local userInputSeaLevelSetting = g_SEALEVEL_Option; --Map.GetCustomOption(2); -- USER CHOICE variable.
	if userInputSeaLevelSetting == 4 then
		userInputSeaLevelSetting = 1 + Map.Rand(3, "Random Sea Level - Lua");
	end
	print("userInputSeaLevelSetting: " .. userInputSeaLevelSetting);
	
	local iW, iH = Map.GetGridSize();
	
	-- Initiate plot table, fill all data slots with type PLOT_OCEAN
	table.fill(self.wholeworldPlotTypes, PlotTypes.PLOT_OCEAN, iW * iH);
	
	if userInputSeaLevelSetting == 3 then --HIGH Sea Level
		return self.wholeworldPlotTypes;--Return all water
	end
	
	-- Hex adjustment tables used for crater simulation.
	local firstRingYIsEven = {{0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}}
	local firstRingYIsOdd = {{1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}}
	
	-- The first layer uses a custom method to simulate craters. A crater is simply a ring
	-- of land at this point so we only need few large ones.  These will probably be mostly
	-- obscured by the following layers.
	
	local craterCount = math.ceil(iH / 8);
	
	for loop = 1, craterCount do
		local craterR = 6 + Map.Rand(3, "Meteor Strike - Lua");
		local craterX = craterR + 3 + Map.Rand(iW - (craterR + 3), "Meteor Strike - Lua");
		local craterY = 10 + Map.Rand(iH - 10, "Meteor Strike - Lua");
		
		local nextX, nextY, plot_adjustments;

		local iWorld = craterY * iW + craterX + 1;
		self.wholeworldPlotTypes[iWorld] = PlotTypes.PLOT_OCEAN
		
		for radius = 1, craterR do
			local currentX = craterX - radius;
			local currentY = craterY;
			for direction_index = 1, 6 do
				for plot_to_handle = 1, radius do
					-- Must account for hex factor.
					if currentY / 2 > math.floor(currentY / 2) then -- Current Y is odd. Use odd table.
						plot_adjustments = firstRingYIsOdd[direction_index];
					else -- Current Y is even. Use plot adjustments from even table.
						plot_adjustments = firstRingYIsEven[direction_index];
					end
					-- Identify the next plot in the ring.
					nextX = currentX + plot_adjustments[1];
					nextY = currentY + plot_adjustments[2];
					
					local realX = nextX;
					local realY = nextY;
					local ringPlotIndex = realY * iW + realX + 1;

					-- The "hard" crater ring is r - 1 so the outer ring can be softened with some noise
					-- and r - 2 can have some noise too
					
					if radius < craterR - 2 then -- Water
						self.wholeworldPlotTypes[ringPlotIndex] = PlotTypes.PLOT_OCEAN
					else -- Land
						if radius == craterR - 1 then -- "hard" ring
							if Map.Rand(craterR, "Meteor Strike - Lua") > 1 then
								self.wholeworldPlotTypes[ringPlotIndex] = PlotTypes.PLOT_LAND
							end
						else -- "soft" ring
							if Map.Rand(craterR, "Meteor Strike - Lua") == 1 then
								self.wholeworldPlotTypes[ringPlotIndex] = PlotTypes.PLOT_LAND
							end
						end
					end
					currentX, currentY = nextX, nextY;
				end
			end
		end
	end
	
	-- Generate Patches of Empty Ocean to erode the large craters
	
	-- iWaterPercent is inverted in this step, what the layer creates as "land"
	-- will become "water" when the layer is applied.  So, a low iWaterPercent
	-- will create larger oceans.
	
	local args = {};
	args.iWaterPercent = 5;--MGH (old:60)
	args.iRegionWidth = math.ceil(iW);
	args.iRegionHeight = math.ceil(iH);
	args.iRegionWestX = math.floor(0);
	args.iRegionSouthY = math.floor(0);
	args.iRegionGrain = 4;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = self.iHorzFlags;
	args.iRegionFracXExp = 7;
	args.iRegionFracYExp = 6;
	args.iRiftGrain = -1;
	
	self:GenerateWaterLayer(args)
	
	-- Generate Tiny Islands to distort the initial crater layer further and follow-up
	-- with a second water layer to open up the oceans.

	local args = {};
	args.iWaterPercent = 99;--MGH (old:85)
	args.iRegionWidth = math.ceil(iW);
	args.iRegionHeight = math.ceil(iH * 0.7);
	args.iRegionWestX = math.floor(0);
	args.iRegionSouthY = math.floor(iH * 0.15);
	args.iRegionGrain = 4;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = self.iHorzFlags;
	args.iRegionFracXExp = 7;
	args.iRegionFracYExp = 6;
	
	self:GenerateFractalLayerWithoutHills(args)
	
	local args = {};
	args.iWaterPercent = 95;--MGH (old:50)
	args.iRegionWidth = math.ceil(iW);
	args.iRegionHeight = math.ceil(iH);
	args.iRegionWestX = math.floor(0);
	args.iRegionSouthY = math.floor(0);
	args.iRegionGrain = 3;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = self.iHorzFlags;
	args.iRegionFracXExp = 7;
	args.iRegionFracYExp = 6;
	args.iRiftGrain = -1;
	
	self:GenerateWaterLayer(args)
	
	-- This crater layer will create some of the most prominent features of the map.
	
	local craterCount = math.ceil(iH / 9);
	
	for loop = 1, craterCount do
		local craterR = 6 + Map.Rand(3, "Meteor Strike - Lua");
		local craterX = craterR + 3 + Map.Rand(iW - (craterR + 3), "Meteor Strike - Lua");
		local craterY = 10 + Map.Rand(iH - 10, "Meteor Strike - Lua");
		
		local nextX, nextY, plot_adjustments;

		local iWorld = craterY * iW + craterX + 1;
		self.wholeworldPlotTypes[iWorld] = PlotTypes.PLOT_OCEAN
		
		for radius = 1, craterR do
			local currentX = craterX - radius;
			local currentY = craterY;
			for direction_index = 1, 6 do
				for plot_to_handle = 1, radius do
					-- Must account for hex factor.
					if currentY / 2 > math.floor(currentY / 2) then -- Current Y is odd. Use odd table.
						plot_adjustments = firstRingYIsOdd[direction_index];
					else -- Current Y is even. Use plot adjustments from even table.
						plot_adjustments = firstRingYIsEven[direction_index];
					end
					-- Identify the next plot in the ring.
					nextX = currentX + plot_adjustments[1];
					nextY = currentY + plot_adjustments[2];
					
					local realX = nextX;
					local realY = nextY;
					local ringPlotIndex = realY * iW + realX + 1;

					-- The "hard" crater ring is r - 1 so the outer ring can be softened with some noise
					-- and r - 2 can have some noise too
					
					if radius < craterR - 2 then -- Water
						self.wholeworldPlotTypes[ringPlotIndex] = PlotTypes.PLOT_OCEAN
					else -- Land
						if radius == craterR - 1 then -- "hard" ring
							if Map.Rand(craterR, "Meteor Strike - Lua") > 3 then
								self.wholeworldPlotTypes[ringPlotIndex] = PlotTypes.PLOT_LAND
							end
						else -- "soft" ring
							if Map.Rand(craterR, "Meteor Strike - Lua") == 1 then
								self.wholeworldPlotTypes[ringPlotIndex] = PlotTypes.PLOT_LAND
							end
						end
					end
					currentX, currentY = nextX, nextY;
				end
			end
		end
	end

	-- Add in more craters, smaller this time around
	
	local craterCount = math.ceil(iH / 4);
	
	for loop = 1, craterCount do
		local craterX = 10 + Map.Rand(iW - 10, "Meteor Strike - Lua");
		local craterY = 10 + Map.Rand(iH - 10, "Meteor Strike - Lua");
		local craterR = 1 + Map.Rand(3, "Meteor Strike - Lua");
		
		local nextX, nextY, plot_adjustments;

		local iWorld = craterY * iW + craterX + 1;
		self.wholeworldPlotTypes[iWorld] = PlotTypes.PLOT_OCEAN
		
		for radius = 1, craterR do
			local currentX = craterX - radius;
			local currentY = craterY;
			for direction_index = 1, 6 do
				for plot_to_handle = 1, radius do
					-- Must account for hex factor.
					if currentY / 2 > math.floor(currentY / 2) then -- Current Y is odd. Use odd table.
						plot_adjustments = firstRingYIsOdd[direction_index];
					else -- Current Y is even. Use plot adjustments from even table.
						plot_adjustments = firstRingYIsEven[direction_index];
					end
					-- Identify the next plot in the ring.
					nextX = currentX + plot_adjustments[1];
					nextY = currentY + plot_adjustments[2];
					
					local realX = nextX;
					local realY = nextY;
					local ringPlotIndex = realY * iW + realX + 1;

					if radius < craterR then -- Water
						self.wholeworldPlotTypes[ringPlotIndex] = PlotTypes.PLOT_OCEAN
					else -- Land
						if Map.Rand(craterR, "Meteor Strike - Lua") == 1 then
							self.wholeworldPlotTypes[ringPlotIndex] = PlotTypes.PLOT_LAND
						end
					end
					currentX, currentY = nextX, nextY;
				end
			end
		end
	end
	
	-- Generate More Patches of Empty Ocean
			
	local args = {};
	args.iWaterPercent = 99;--MGH (older:80)
	args.iRegionWidth = math.ceil(iW);
	args.iRegionHeight = math.ceil(iH);
	args.iRegionWestX = math.floor(0);
	args.iRegionSouthY = math.floor(0);
	args.iRegionGrain = 3;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = self.iHorzFlags;
	args.iRegionFracXExp = 7;
	args.iRegionFracYExp = 6;
	args.iRiftGrain = -1;
	
	self:GenerateWaterLayer(args)
	
	-- Ensure a strip of unbroken ocean at top and bottom of map.
	for x = 0, iW - 1 do
		local i_bottom = x + 1;
		local i_top = (iH - 1) * iW + x + 1;
		self.wholeworldPlotTypes[i_bottom] = PlotTypes.PLOT_OCEAN;
		self.wholeworldPlotTypes[i_top] = PlotTypes.PLOT_OCEAN;
	end

	-- Land and water are set. Apply hills and mountains.
	local args = {
		extra_mountains = 0,--MGH (old:4)
		adjust_plates = 1.3,
		}
	self:ApplyTectonics(args);
	
	if userInputSeaLevelSetting == 2 then --MEDIUM Sea Level
		--Ramdomly change to water
		for y = 0, iH - 1 do
			for x = 0, iW - 1 do
				local plotIndex = y * iW + x + 1; -- Lua tables/lists/arrays start at 1, not 0 like C++ or Python
				if self.wholeworldPlotTypes[plotIndex] == PlotTypes.PLOT_LAND or self.wholeworldPlotTypes[plotIndex] == PlotTypes.PLOT_HILLS then
					local diceroll = Map.Rand(3, "Random Change into ocean - Lua"); -- 33% chance turn into ocean.
					if diceroll == 1 then
						self.wholeworldPlotTypes[plotIndex] = PlotTypes.PLOT_OCEAN;
					end
				end
			end
		end
	end

	-- Plot Type generation completed. Return global plot array.
	return self.wholeworldPlotTypes;
	
end
------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Setting Plot Types (Lua _WaterWorld) ...");

	local layered_world = MultilayeredFractal.Create();
	local plotsOceania = layered_world:GeneratePlotsByRegion();
	
	SetPlotTypes(plotsOceania);

	GenerateCoasts();
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain (Lua _WaterWorld) ...");

	local args = {temperature = 2}; -- Hard coded for now
	local terraingen = TerrainGenerator.Create(args);

	terrainTypes = terraingen:GenerateTerrain();
	
	SetTerrainTypes(terrainTypes);
end
------------------------------------------------------------------------------
function RiverGenerator:GetCapsForMethodC()
	-- Set up caps for number of formations and plots based on world size.
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {2, 4, 2, 0},
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {3, 6, 2, 0},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {5, 11, 2, 1},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {6, 16, 2, 2},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {7, 25, 3, 2},
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {9, 39, 3, 3},
		};
	local caps_list = worldsizes[Map.GetWorldSize()];
	local max_lines, max_plots, base_length, extension_range = caps_list[1], caps_list[2], caps_list[3], caps_list[4];
	return max_lines, max_plots, base_length, extension_range;
end
------------------------------------------------------------------------------
function AddRivers()
	print("Generating Rivers, Canyons, and Lakes. (Lua _WaterWorld) ...");

	local args = {minimum_percentage_of_total_land = 2};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end
------------------------------------------------------------------------------
function AddAtolls()
	--if Map.GetCustomOption(2) >= 2 then --MEDIUM & HIGH Sea Level
	if g_SEALEVEL_Option >= 2 then --MEDIUM & HIGH Sea Level
		return;
	end

	print("AddAtolls. (Lua _WaterWorld) ...");
	-- Adds the new feature Atolls in to the game, for oceanic maps.
	local iW, iH = Map.GetGridSize()
	
	-- World has oceans, proceed with adding Atolls.
	local iNumAtollsPlaced = 0;
	local direction_types = {
		DirectionTypes.DIRECTION_NORTHEAST,
		DirectionTypes.DIRECTION_EAST,
		DirectionTypes.DIRECTION_SOUTHEAST,
		DirectionTypes.DIRECTION_SOUTHWEST,
		DirectionTypes.DIRECTION_WEST,
		DirectionTypes.DIRECTION_NORTHWEST
	};
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = 8,
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = 15,
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = 20,
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = 25,
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = 30,
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = 40,
	};
	local atoll_target = worldsizes[Map.GetWorldSize()];
	local atoll_number = atoll_target + Map.Rand(atoll_target, "Number of Atolls to place - LUA");
	local feature_atoll;
	for thisFeature in GameInfo.Features() do
		if thisFeature.Type == "FEATURE_REEF" then --FEATURE_ATOLL
			feature_atoll = thisFeature.ID;
		end
	end

	-- Generate candidate plot lists.
	local temp_one_tile_island_list, temp_alpha_list, temp_beta_list = {}, {}, {};
	local temp_gamma_list, temp_delta_list, temp_epsilon_list = {}, {}, {};
	for y = 0, iH - 1 do
		for x = 0, iW - 1 do
			local i = y * iW + x + 1; -- Lua tables/lists/arrays start at 1, not 0 like C++ or Python
			local plot = Map.GetPlot(x, y)
			local plotType = plot:GetPlotType()
			if plotType == PlotTypes.PLOT_OCEAN then
				local featureType = plot:GetFeatureType()
				if featureType ~= FeatureTypes.FEATURE_ICE then
					if not plot:IsLake() then
						local terrainType = plot:GetTerrainType()
						if terrainType == TerrainTypes.TERRAIN_COAST then
							if plot:IsAdjacentToLand() then
								-- Check all adjacent plots and identify adjacent landmasses.
								local iNumLandAdjacent, biggest_adj_area = 0, 0;
								local bPlotValid = true;
								for loop, direction in ipairs(direction_types) do
									local adjPlot = Map.PlotDirection(x, y, direction)
									if adjPlot ~= nil then
										local adjPlotType = adjPlot:GetPlotType()
										if adjPlotType ~= PlotTypes.PLOT_OCEAN then -- Found land.
											iNumLandAdjacent = iNumLandAdjacent + 1;
											-- Avoid being adjacent to tundra, snow, or feature ice!
											local adjTerrainType = adjPlot:GetTerrainType()
											if adjTerrainType == TerrainTypes.TERRAIN_TUNDRA or adjTerrainType == TerrainTypes.TERRAIN_SNOW then
												bPlotValid = false;
											end
											local adjFeatureType = adjPlot:GetFeatureType()
											if adjFeatureType == FeatureTypes.FEATURE_ICE then
												bPlotValid = false;
											end
											if adjPlotType == PlotTypes.PLOT_LAND or adjPlotType == PlotTypes.PLOT_HILLS then
												local iArea = adjPlot:GetArea()
												local adjArea = Map.GetArea(iArea)
												local iNumAreaPlots = adjArea:GetNumTiles()
												if iNumAreaPlots > biggest_adj_area then
													biggest_adj_area = iNumAreaPlots;
												end
											end
										end
									end
								end
								-- Only plots with a single land plot adjacent can be eligible.
								if iNumLandAdjacent == 1 and bPlotValid == true then
									if biggest_adj_area >= 76 then
										-- discard this site
									elseif biggest_adj_area >= 41 then
										table.insert(temp_epsilon_list, i);
									elseif biggest_adj_area >= 17 then
										table.insert(temp_delta_list, i);
									elseif biggest_adj_area >= 8 then
										table.insert(temp_gamma_list, i);
									elseif biggest_adj_area >= 3 then
										table.insert(temp_beta_list, i);
									elseif biggest_adj_area >= 1 then
										table.insert(temp_alpha_list, i);
									--else -- Unexpected result
										--print("** Area Plot Count =", biggest_adj_area);
									end
								end
							end
						end
					end
				end
			end
		end
	end
	local alpha_list = GetShuffledCopyOfTable(temp_alpha_list)
	local beta_list = GetShuffledCopyOfTable(temp_beta_list)
	local gamma_list = GetShuffledCopyOfTable(temp_gamma_list)
	local delta_list = GetShuffledCopyOfTable(temp_delta_list)
	local epsilon_list = GetShuffledCopyOfTable(temp_epsilon_list)

	-- Determine maximum number able to be placed, per candidate category.
	local max_alpha = math.ceil(table.maxn(alpha_list) / 4);
	local max_beta = math.ceil(table.maxn(beta_list) / 5);
	local max_gamma = math.ceil(table.maxn(gamma_list) / 4);
	local max_delta = math.ceil(table.maxn(delta_list) / 3);
	local max_epsilon = math.ceil(table.maxn(epsilon_list) / 4);
	
	-- Place Atolls.
	local plotIndex;
	local i_alpha, i_beta, i_gamma, i_delta, i_epsilon = 1, 1, 1, 1, 1;
	for loop = 1, atoll_number do
		local able_to_proceed = true;
		local diceroll = 1 + Map.Rand(100, "Atoll Placement Type - LUA");
		if diceroll <= 40 and max_alpha > 0 then
			plotIndex = alpha_list[i_alpha];
			i_alpha = i_alpha + 1;
			max_alpha = max_alpha - 1;
			--print("- Alpha site chosen");
		elseif diceroll <= 65 then
			if max_beta > 0 then
				plotIndex = beta_list[i_beta];
				i_beta = i_beta + 1;
				max_beta = max_beta - 1;
				--print("- Beta site chosen");
			elseif max_alpha > 0 then
				plotIndex = alpha_list[i_alpha];
				i_alpha = i_alpha + 1;
				max_alpha = max_alpha - 1;
				--print("- Alpha site chosen");
			else -- Unable to place this Atoll
				--print("-"); print("* Atoll #", loop, "was unable to be placed.");
				able_to_proceed = false;
			end
		elseif diceroll <= 80 then
			if max_gamma > 0 then
				plotIndex = gamma_list[i_gamma];
				i_gamma = i_gamma + 1;
				max_gamma = max_gamma - 1;
				--print("- Gamma site chosen");
			elseif max_beta > 0 then
				plotIndex = beta_list[i_beta];
				i_beta = i_beta + 1;
				max_beta = max_beta - 1;
				--print("- Beta site chosen");
			elseif max_alpha > 0 then
				plotIndex = alpha_list[i_alpha];
				i_alpha = i_alpha + 1;
				max_alpha = max_alpha - 1;
				--print("- Alpha site chosen");
			else -- Unable to place this Atoll
				--print("-"); print("* Atoll #", loop, "was unable to be placed.");
				able_to_proceed = false;
			end
		elseif diceroll <= 90 then
			if max_delta > 0 then
				plotIndex = delta_list[i_delta];
				i_delta = i_delta + 1;
				max_delta = max_delta - 1;
				--print("- Delta site chosen");
			elseif max_gamma > 0 then
				plotIndex = gamma_list[i_gamma];
				i_gamma = i_gamma + 1;
				max_gamma = max_gamma - 1;
				--print("- Gamma site chosen");
			elseif max_beta > 0 then
				plotIndex = beta_list[i_beta];
				i_beta = i_beta + 1;
				max_beta = max_beta - 1;
				--print("- Beta site chosen");
			elseif max_alpha > 0 then
				plotIndex = alpha_list[i_alpha];
				i_alpha = i_alpha + 1;
				max_alpha = max_alpha - 1;
				--print("- Alpha site chosen");
			else -- Unable to place this Atoll
				--print("-"); print("* Atoll #", loop, "was unable to be placed.");
				able_to_proceed = false;
			end
		else
			if max_epsilon > 0 then
				plotIndex = epsilon_list[i_epsilon];
				i_epsilon = i_epsilon + 1;
				max_epsilon = max_epsilon - 1;
				--print("- Epsilon site chosen");
			elseif max_delta > 0 then
				plotIndex = delta_list[i_delta];
				i_delta = i_delta + 1;
				max_delta = max_delta - 1;
				--print("- Delta site chosen");
			elseif max_gamma > 0 then
				plotIndex = gamma_list[i_gamma];
				i_gamma = i_gamma + 1;
				max_gamma = max_gamma - 1;
				--print("- Gamma site chosen");
			elseif max_beta > 0 then
				plotIndex = beta_list[i_beta];
				--print("- Beta site chosen");
				i_beta = i_beta + 1;
				max_beta = max_beta - 1;
			elseif max_alpha > 0 then
				plotIndex = alpha_list[i_alpha];
				i_alpha = i_alpha + 1;
				max_alpha = max_alpha - 1;
				--print("- Alpha site chosen");
			else -- Unable to place this Atoll
				--print("-"); print("* Atoll #", loop, "was unable to be placed.");
				able_to_proceed = false;
			end
		end
		if able_to_proceed and plotIndex ~= nil then
			local x = (plotIndex - 1) % iW;
			local y = (plotIndex - x - 1) / iW;
			local plot = Map.GetPlot(x, y)
			--plot:SetFeatureType(feature_atoll, -1);
			--add mountain plot
			local diceroll_mountain = 1 + Map.Rand(100, "Add mountain");
			local plotType = plot:GetPlotType();
			if plotType == PlotTypes.PLOT_OCEAN and diceroll_mountain >= 45 then
				--Place a mountain here
				plot:SetPlotType(PlotTypes.PLOT_MOUNTAIN,false,false);
				print("Added a mountain");
			end
			iNumAtollsPlaced = iNumAtollsPlaced + 1;
			print("Atolls able places: " .. iNumAtollsPlaced);
		--else
			--print("** ERROR ** Atoll unable to be placed and/or chosen Plot Index was nil.");
		end
	end
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features (Lua _WaterWorld) ...");
	
	local args = {
		rainfall = 2, -- Hard coded for now
		miasmaSpawnWay = g_MiasmaOption,
	};
	local featuregen = FeatureGenerator.Create(args);
	local featuregen = FeatureGenerator.Create(args);

	-- False parameter removes mountains from coastlines.
	featuregen:AddFeatures(false);
	
	AddAtolls();
end
-------------------------------------------------------------------------------
function FeatureGenerator:AddIceAtPlot(plot, iX, iY, lat)
	--No Ice
	
	--Remove snow area
	local plotType = plot:GetPlotType();
	if lat > 0.39 and plotType == PlotTypes.PLOT_LAND then --Poles not accesibles
		plot:SetTerrainType(TerrainTypes.TERRAIN_COAST);
		print("pole area removed");
	end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
----- Skirmish system, reworked by Protok
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function AssignStartingPlots:BalanceAndAssign_s()
	-- This function determines what level of Bonus Resource support a location
	-- may need, identifies compatibility with civ-specific biases, and places starts.

	-- Normalize each start plot location.
	local iNumStarts = table.maxn(self.startingPlots);
	for region_number = 1, iNumStarts do
		self:NormalizeStartLocation(region_number)
	end

	-- Assign Civs to start plots.
	if iNumTeams == 2 then
		-- Two teams, place one in the west half, other in east -- even if team membership totals are uneven.
		print("-"); print("This is a team game with two teams! Place one team in West, other in East."); print("-");
		local playerList, westList, eastList = {}, {}, {};
		for loop = 1, self.iNumCivs do
			local player_ID = self.player_ID_list[loop];
			table.insert(playerList, player_ID);
			local player = Players[player_ID];
			local team_ID = player:GetTeam()
			if team_ID == teamWestID then
				print("Player #", player_ID, "belongs to Team #", team_ID, "and will be placed in the West.");
				table.insert(westList, player_ID);
			elseif team_ID == teamEastID then
				print("Player #", player_ID, "belongs to Team #", team_ID, "and will be placed in the East.");
				table.insert(eastList, player_ID);
			else
				print("* ERROR * - Player #", player_ID, "belongs to Team #", team_ID, "which is neither West nor East!");
			end
		end

		-- Debug
		if table.maxn(westList) ~= iNumCivsInWest then
			print("-"); print("*** ERROR! *** . . . Mismatch between number of Civs on West team and number of civs assigned to west locations.");
		end
		if table.maxn(eastList) ~= iNumCivsInEast then
			print("-"); print("*** ERROR! *** . . . Mismatch between number of Civs on East team and number of civs assigned to east locations.");
		end

		local westListShuffled = GetShuffledCopyOfTable(westList)
		local eastListShuffled = GetShuffledCopyOfTable(eastList)
		for region_number, player_ID in ipairs(westListShuffled) do
			local x = self.startingPlots[region_number][1];
			local y = self.startingPlots[region_number][2];
			local start_plot = Map.GetPlot(x, y)
			local player = Players[player_ID]
			player:SetStartingPlot(start_plot)
		end
		for loop, player_ID in ipairs(eastListShuffled) do
			local x = self.startingPlots[loop + iNumCivsInWest][1];
			local y = self.startingPlots[loop + iNumCivsInWest][2];
			local start_plot = Map.GetPlot(x, y)
			local player = Players[player_ID]
			player:SetStartingPlot(start_plot)
		end
	else
		print("-"); print("This game does not have specific start zone assignments."); print("-");
		local playerList = {};
		for loop = 1, self.iNumCivs do
			local player_ID = self.player_ID_list[loop];
			table.insert(playerList, player_ID);
		end
		local playerListShuffled = GetShuffledCopyOfTable(playerList)
		for region_number, player_ID in ipairs(playerListShuffled) do
			local x = self.startingPlots[region_number][1];
			local y = self.startingPlots[region_number][2];
			local start_plot = Map.GetPlot(x, y)
			local player = Players[player_ID]
			player:SetStartingPlot(start_plot)
		end
		-- If this is a team game (any team has more than one Civ in it) then make
		-- sure team members start near each other if possible. (This may scramble
		-- Civ biases in some cases, but there is no cure).
		if self.bTeamGame == true and team_setting ~= 2 then
			--print("However, this IS a team game, so we will try to group team members together."); print("-");
			self:NormalizeTeamLocations()
		end
	end
end
------------------------------------------------------------------------------
function StartPlotSystem()
	-- Reworked for AC Skirmish.
	print("Creating start plot database.");
	local start_plot_database = AssignStartingPlots.Create()

	print("Dividing the map in to Regions.");
	-- Check 2 Teams West / East grouped starts
	local m = 2; -- Continental
	if g_StartingsOption == 2 then
		-- Determine number of teams (of Major Civs only, not City States) present in this game.
		local _, _, _, _, teams_with_major_civs, _ = GetPlayerAndTeamInfo();
		local iNumTeams = table.maxn(teams_with_major_civs);
		if iNumTeams == 2 then m = 6 end; -- Teams W/E
	end
	local res = g_ResourcesOption -- Global from GetMapInitData
	if res == 6 then res = 1 + Map.Rand(3, "Random Resources Option - Lua"); end
	local args = {
		method = m,
		resources = res,
	};
	start_plot_database:GenerateRegions(args)

	print("Choosing start locations for civilizations.");
	start_plot_database:ChooseLocations()

	print("Normalizing start locations and assigning them to Players.");
	start_plot_database:BalanceAndAssign()

	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()
	
	-- tell the AI that we should treat this as a naval + offshore expansion map
	Map.ChangeAIMapHint(1+4);
end
------------------------------------------------------------------------------
function getLandmarksOption() --PW
	print("getLandmarksOption customed by map");
	return g_LandmarksOption;
end