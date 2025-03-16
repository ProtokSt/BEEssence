-- ===========================================================================
---- 2023 - Blessed by Protok St.
---- SUMMARY: added 6th map size, MIASMA option
---- RiverGenerator:GetCapsForMethodC
-- ===========================================================================
------------------------------------------------------------------------------
--	FILE:	 Archipelago.lua
--	AUTHOR:  Bob Thomas
--	PURPOSE: Global map script - Produces a world of tiny and medium islands.
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

include("MapGenerator");
include("FractalWorld");
include("FeatureGenerator");
include("TerrainGenerator");
include("RiverGenerator");

------------------------------------------------------------------------------
function GetMapScriptInfo()
	local world_age, temperature, rainfall, sea_level, resources, miasma_spawn, planet_landmarks = GetCoreMapOptions()
	return {
		Name = "TXT_KEY_MAP_ARCHIPELAGO",
		Type = "TXT_KEY_MAP_ARCHIPELAGO",
		Description = "TXT_KEY_MAP_ARCHIPELAGO_HELP",
		IconIndex = 2,
		SortIndex = 3,
		CustomOptions = {world_age, temperature, rainfall, sea_level, resources, miasma_spawn, planet_landmarks },
	};
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Generating Plot Types (Lua Archipelago) ...");

	local sea_level = Map.GetCustomOption(4)
	if sea_level == 4 then
		sea_level = 1 + Map.Rand(3, "Random Sea Level - Lua");
	end
	local world_age = Map.GetCustomOption(1)
	if world_age == 4 then
		world_age = 1 + Map.Rand(3, "Random World Age - Lua");
	end

	local fractal_world = FractalWorld.Create();
	fractal_world:InitFractal{
		continent_grain = 4};

	local args = {
		sea_level = sea_level,
		world_age = world_age,
		sea_level_low = 70,
		sea_level_normal = 74,
		sea_level_high = 78,
		extra_mountains = 0,
		adjust_plates = 1.6,
		tectonic_islands = true
		}
	local plotTypes = fractal_world:GeneratePlotTypes(args);
	
	SetPlotTypes(plotTypes);
	GenerateCoasts();
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain (Lua Archipelago) ...");
	
	-- Get Temperature setting input by user.
	local temp = Map.GetCustomOption(2)
	if temp == 4 then
		temp = 1 + Map.Rand(3, "Random Temperature - Lua");
	end

	local args = {temperature = temp};
	local terraingen = TerrainGenerator.Create(args);

	terrainTypes = terraingen:GenerateTerrain();
	
	SetTerrainTypes(terrainTypes);
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function RiverGenerator:GetCapsForMethodC()
	-- Set up caps for number of formations and plots based on world size.
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {3, 4, 1, 1},
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {4, 7, 2, 0},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {6, 12, 2, 1},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {7, 18, 2, 2},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {9, 28, 2, 3},
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {11, 42, 3, 3},	-- pwac
		};
	local caps_list = worldsizes[Map.GetWorldSize()];
	local max_lines, max_plots, base_length, extension_range = caps_list[1], caps_list[2], caps_list[3], caps_list[4];
	return max_lines, max_plots, base_length, extension_range;
end
------------------------------------------------------------------------------
function AddRivers()
	print("Generating Rivers, Canyons, and Lakes. (Lua Archipelago) ...");

	local args = {minimum_percentage_of_total_land = 2};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features (Lua Archipelago) ...");

	-- Get Rainfall setting input by user.
	local rain = Map.GetCustomOption(3)
	if rain == 4 then
		rain = 1 + Map.Rand(3, "Random Rainfall - Lua");
	end
	-- Get Miasma setting input by user.
	local miasma = Map.GetCustomOption(6)
	
	local args = {rainfall = rain,
		miasmaSpawnWay = miasma,}
	local featuregen = FeatureGenerator.Create(args);

	-- False parameter removes mountains from coastlines.
	featuregen:AddFeatures(false);
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
	-- Forcing starts along the ocean.
	local args = {
		mustBeCoast = true,
		minFoodMiddle = 2,
		minFoodOuter = 3,
		minProdOuter = 1
		};
	start_plot_database:ChooseLocations(args)
	
	print("Normalizing start locations and assigning them to Players.");
	start_plot_database:BalanceAndAssign()

	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()
	
	-- Heavy water map AI setting.
	Map.ChangeAIMapHint(5);

end
------------------------------------------------------------------------------
function getLandmarksOption() --PW
	print("getLandmarksOption customed by map");
	local landmarks = Map.GetCustomOption(7) or 3;
	return landmarks;
end