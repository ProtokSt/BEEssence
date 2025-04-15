-- ===========================================================================
---- 2023 - Blessed by Protok St
--	FILE:	 AC_Skeeper_Tail.lua
--  VERSION: 1.0.1
--	AUTHOR:  Protok St
--	PURPOSE: Map for multiplayer competition mostly
--           Mirrored map with vertical hills/mountains ridge in center 
-- ===========================================================================
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------
-- print("AC_Skeeper_Tail.lua Start ---------------------------------------- ") -- dbg

-- ACDLC
include("MapGenerator");
include("FeatureGenerator");
include("FractalWorld");
include("MapmakerUtilities");	-- exp1
include("TerrainGenerator");
include("IslandMaker");			-- vanilla
include("MultilayeredFractal");
include("RiverGenerator");

-------------------------------------------------------------------------------
function GetMapScriptInfo()
	-- print("GetMapScriptInfo Start ---- ") -- dbg
	--local world_age, temperature, rainfall, sea_level, resources = GetCoreMapOptions()
	return {
		Name = "TXT_KEY_MAP_SKEEPER_TAIL_NAME",
		Type = "TXT_KEY_MAP_SKEEPER_TAIL_TYPE",
		Description = "TXT_KEY_MAP_SKEEPER_TAIL_HELP",
		--IsAdvancedMap = false,
		--SupportsMultiplayer = true,
		-- Campaign = true,
		IconIndex = 5,	
		CustomOptions = {
			{
				Name = "TXT_KEY_MAP_OPTION_RESOURCES",
				Description = "TXT_KEY_MAP_OPTION_RESOURCES_HELP",
				Values = {
					{"TXT_KEY_MAP_OPTION_SPARSE", "TXT_KEY_MAP_OPTION_RES_SPARSE_HELP"},
					{"TXT_KEY_MAP_OPTION_STANDARD", "TXT_KEY_MAP_OPTION_RES_STANDARD_HELP"},
					{"TXT_KEY_MAP_OPTION_ABUNDANT", "TXT_KEY_MAP_OPTION_RES_ABUNDANT_HELP"},
					{"TXT_KEY_MAP_OPTION_LEGENDARY_START", "TXT_KEY_MAP_OPTION_RES_LEGENDARY_START_HELP"},
					{"TXT_KEY_MAP_OPTION_STRATEGIC_BALANCE", "TXT_KEY_MAP_OPTION_RES_STRATEGIC_BALANCE_HELP"},
					{"TXT_KEY_MAP_OPTION_RANDOM", "TXT_KEY_MAP_OPTION_RES_RANDOM_HELP"},
					{"TXT_KEY_MAP_OPTION_RES_REAL_RANDOM", "TXT_KEY_MAP_OPTION_RES_REAL_RANDOM_HELP"},
					{"TXT_KEY_MAP_OPTION_RES_COMPET", "TXT_KEY_MAP_OPTION_RES_COMPET_HELP"},
				},
				-- DefaultValue = 7,
				DefaultValue = 8,
				SortPriority = -95,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_LANDSCAPE_TYPE",
				Description = "TXT_KEY_MAP_OPTION_LANDSCAPE_TYPE_HELP",
				Values = {
					{"TXT_KEY_MAP_OPTION_SKPRTL_STATIC", "TXT_KEY_MAP_OPTION_SKPRTL_STATIC_HELP"},
					{"TXT_KEY_MAP_OPTION_SKPRTL_DYNAMIC", "TXT_KEY_MAP_OPTION_SKPRTL_DYNAMIC_HELP"},
				},
				DefaultValue = 2,
				SortPriority = 10,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_WRAPPED",
				Description = "TXT_KEY_MAP_OPTION_WRAPPED_HELP",
				Values = { -- user choosed wrapX type of map
					{"TXT_KEY_MAP_OPTION_WRAPPED_FALSE", "TXT_KEY_MAP_OPTION_WRAPPED_FALSE_HELP"},
					{"TXT_KEY_MAP_OPTION_WRAPPED_TRUE", "TXT_KEY_MAP_OPTION_WRAPPED_TRUE_HELP"},
				},
				DefaultValue = 1,
				SortPriority = 20,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_MIASMA_ON_START",
				Description = "TXT_KEY_MAP_OPTION_MIASMA_ON_START_HELP",
				Values = {
					{"TXT_KEY_MAP_OPTION_NO_MIASMA_ON_START", 	"TXT_KEY_MAP_OPTION_NO_MIASMA_ON_START_HELP"},
					{"TXT_KEY_MAP_OPTION_MIASMA_THEN_WILDNESS", "TXT_KEY_MAP_OPTION_MIASMA_THEN_WILDNESS_HELP"},
					{"TXT_KEY_MAP_OPTION_MIASMA_AFTER_WILDNESS","TXT_KEY_MAP_OPTION_MIASMA_AFTER_WILDNESS_HELP"},
					{"TXT_KEY_MAP_OPTION_MIASMA_ALMOST", 		"TXT_KEY_MAP_OPTION_MIASMA_ALMOST_HELP"},
					{"TXT_KEY_MAP_OPTION_MIASMA_ALL_MAP", 		"TXT_KEY_MAP_OPTION_MIASMA_ALL_MAP_HELP"},
				},
				DefaultValue = 2,
				SortPriority = 30,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_STARTINGS",
				Description = "TXT_KEY_MAP_OPTION_STARTINGS_HELP",
				Values = { 
					{"TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_STRAIGHT", "TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_STRAIGHT_HELP"},
					{"TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_DIAGONAL", "TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_DIAGONAL_HELP"},
					{"TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_RANDOM", "TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_RANDOM_HELP"},
					{"TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_USUAL", "TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_USUAL_HELP"},
					{"TXT_KEY_MAP_OPTION_STARTINGS_TEAMS_WE", "TXT_KEY_MAP_OPTION_STARTINGS_TEAMS_WE_HELP"},
				},
				DefaultValue = 1,
				SortPriority = 40,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_LANDMARKS",
				Description = "TXT_KEY_MAP_OPTION_LANDMARKS_HELP",
				Values = { 
					{"TXT_KEY_MAP_OPTION_LANDMARKS_0", 			"TXT_KEY_MAP_OPTION_LANDMARKS_0_HELP"},
					{"TXT_KEY_MAP_OPTION_LANDMARKS_1_BIOME", 	"TXT_KEY_MAP_OPTION_LANDMARKS_1_BIOME_HELP"},
					{"TXT_KEY_MAP_OPTION_LANDMARKS_2_BIOME_PLUS_WATER", "TXT_KEY_MAP_OPTION_LANDMARKS_2_BIOME_PLUS_WATER_HELP"},
					{"TXT_KEY_MAP_OPTION_LANDMARKS_3_BIOME_PLUS_WATER_PLUS", "TXT_KEY_MAP_OPTION_LANDMARKS_3_BIOME_PLUS_WATER_PLUS_HELP"},
					{"TXT_KEY_MAP_OPTION_LANDMARKS_1_RANDOM", 	"TXT_KEY_MAP_OPTION_LANDMARKS_1_RANDOM_HELP"},
					{"TXT_KEY_MAP_OPTION_LANDMARKS_2_RANDOM", 	"TXT_KEY_MAP_OPTION_LANDMARKS_2_RANDOM_HELP"},
					{"TXT_KEY_MAP_OPTION_LANDMARKS_3_RANDOM", 	"TXT_KEY_MAP_OPTION_LANDMARKS_3_RANDOM_HELP"},
					{"TXT_KEY_MAP_OPTION_LANDMARKS_X_MAX", 		"TXT_KEY_MAP_OPTION_LANDMARKS_X_MAX_HELP"},
				},
				DefaultValue = 1,
				SortPriority = 50,
			},
		},
	}
end
------------------------------------------------------------------------------
function GetMapInitData(worldSize)
	print("GetMapInitData Start ---- ") -- dbg
	-- This function can reset map grid sizes or world wrap settings.
	-- Optional func called by engine
	--
	-- make advanced start MAP options available for all functions
	g_ResourcesOption = Map.GetCustomOption(1) -- GLOBAL variable.
	g_GenTypeOption = Map.GetCustomOption(2) -- GLOBAL variable.
	g_WrappedOption = Map.GetCustomOption(3) -- GLOBAL variable.
	g_MiasmaOption = Map.GetCustomOption(4) -- GLOBAL variable.
	g_StartingsOption = Map.GetCustomOption(5) -- GLOBAL variable.
	g_LandmarksOption = Map.GetCustomOption(6) -- GLOBAL variable.
	
	-- Test map has special grid sizes
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {34, 24},
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {34, 24},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {34, 24},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {34, 24},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {34, 24},
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {34, 24},
		-- [GameInfo.Worlds.WORLDSIZE_TINY.ID] = {42, 30},
		-- [GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {54, 38},
		-- [GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {68, 48},
		-- [GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {86, 60},
		-- [GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {108, 76}
		}
	local grid_size = worldsizes[worldSize];
	--
	local world = GameInfo.Worlds[worldSize];
	-- Wrap the map by option
	local wrappedmap = true;
	if g_WrappedOption == 1 then wrappedmap = false end
	
	if(world ~= nil) then
	return {
		Width = grid_size[1],
		Height = grid_size[2],
		WrapX = wrappedmap,
		-- WrapX = false,
	};      
    end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Map Generator Methods Customed by Map
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function SetPlotTypes(plotTypes)
	print("Setting Plot Types (AC_Skeeper_Tail.lua)");
	-- NOTE: Plots() is indexed from 0, the way the plots are indexed in C++
	-- However, Lua tables are indexed from 1, and all incoming plot tables should be indexed this way.
	-- So we add 1 to the Plots() index to find the matching plot data in plotTypes.
	-- Protok: It's wrong. The last one X,Y tile will be not affected if we start to work with list of tiles not from first one but first + 1. So I fixed it.
	for i, plot in Plots() do
		plot:SetPlotType(plotTypes[i + 1], false, false);
		-- plot:SetPlotType(plotTypes[i], false, false);
	end
end
------------------------------------------------------------------------------
-- FIRST MAIN FUNC
function GeneratePlotTypes()
	-- This is a basic, empty shell. All map scripts should replace this function with their own.
	print("Generating Plot Types (AC_Skeeper_Tail.lua)");
	local _dpo = true;
	-- local _dpo = false;

	--plotTypes is 0-based to map directly to Map.GetPlotByIndex
	local plotLand = PlotTypes.PLOT_LAND;
	local plotOcean = PlotTypes.PLOT_OCEAN; -- not real
	local plotMountain = PlotTypes.PLOT_MOUNTAIN;
	local plotHill = PlotTypes.PLOT_HILLS;
	local plotCanyon = PlotTypes.PLOT_CANYON;
	local plotPeak = PlotTypes.PLOT_PEAK;
	local plotTypes = {};
	
	local iW, iH = Map.GetGridSize();
	local sizekey = Map.GetWorldSize();

	for i = 1, Map.GetNumPlots(), 1 do plotTypes[i] = plotLand; end
	
	SetPlotTypes(plotTypes);

	local cvm_plot, cvm_x, gto, cvm_plot2, cvm_plot3, boolcheck
	local direction_types = {
		DirectionTypes.DIRECTION_NORTHEAST,
		DirectionTypes.DIRECTION_EAST,
		DirectionTypes.DIRECTION_SOUTHEAST,
		DirectionTypes.DIRECTION_SOUTHWEST,
		DirectionTypes.DIRECTION_WEST,
		DirectionTypes.DIRECTION_NORTHWEST
		};

	-- Central Hill Ridge
	cvm_x = 15; for y = 0, iH-1, 1 do Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false) end	
	cvm_x = 16; for y = 0, iH-1, 1 do Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false) end	
	cvm_x = 17; for y = 0, iH-1, 1 do Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false) end	
	cvm_x = 18; for y = 0, iH-1, 1 do Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false) end	
	cvm_x = 19; for y = 0, iH-1, 2 do Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false) end	
	
	cvm_x = 14;
	if g_GenTypeOption == 2 then
		for y = 1, iH-1, 2 do
			gto = Map.Rand(5, "Skeeper Dynamic Map M-1")
			if gto > 2 then Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false); end
			gto = Map.Rand(5, "Skeeper Dynamic Map M-1")
			if gto > 2 then Map.GetPlot(cvm_x-1, y):SetPlotType(plotHill, false, false); end
			gto = Map.Rand(5, "Skeeper Dynamic Map M-1")
			if gto > 2 then Map.GetPlot(cvm_x-2, y):SetPlotType(plotHill, false, false); end
			gto = Map.Rand(5, "Skeeper Dynamic Map M-1")
			if gto > 2 then Map.GetPlot(cvm_x+5, y):SetPlotType(plotHill, false, false); end
			gto = Map.Rand(5, "Skeeper Dynamic Map M-1")
			if gto > 2 then Map.GetPlot(cvm_x+6, y):SetPlotType(plotHill, false, false); end
			gto = Map.Rand(5, "Skeeper Dynamic Map M-1")
			if gto > 2 then Map.GetPlot(cvm_x+7, y):SetPlotType(plotHill, false, false); end
		end	
	else
		for y = 3, iH-1, 4 do
			Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
			Map.GetPlot(cvm_x-1, y):SetPlotType(plotHill, false, false);
			Map.GetPlot(cvm_x+5, y):SetPlotType(plotHill, false, false);
			Map.GetPlot(cvm_x+6, y):SetPlotType(plotHill, false, false);
		end	
		cvm_x = 12;
		for y = 7, iH-1, 8 do
			Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
			Map.GetPlot(cvm_x+9, y):SetPlotType(plotHill, false, false);
		end	
	end	

	-- Central vertical mountain
	cvm_x = iW/2;
	for y = 0, iH-1, 2 do
		Map.GetPlot(cvm_x, y):SetPlotType(plotMountain, false, false)
		if g_GenTypeOption == 2 then gto = Map.Rand(4, "Skeeper Dynamic Map M1") end
		if gto == 0 then Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false); end	
	end	
		-- separates mountains	
	cvm_x = 16;
	if g_GenTypeOption == 2 then
		for y = 1, iH-1, 2 do
			gto = Map.Rand(4, "Skeeper Dynamic Map M2.1")
			if gto == 0 then 
				Map.GetPlot(cvm_x, y):SetPlotType(plotMountain, false, false); 
				gto = Map.Rand(4, "Skeeper Dynamic Map M2.2")
				if gto > 1 then Map.GetPlot(cvm_x+1, y):SetPlotType(plotMountain, false, false); end
			end	
			gto = Map.Rand(4, "Skeeper Dynamic Map M2")
			if gto == 0 then 
				Map.GetPlot(cvm_x+1, y):SetPlotType(plotMountain, false, false); 
				gto = Map.Rand(4, "Skeeper Dynamic Map M2.3")
				if gto > 1 then Map.GetPlot(cvm_x, y):SetPlotType(plotMountain, false, false); end
			end	
		end	
	else
		for y = 7, iH-1, 8 do
			Map.GetPlot(cvm_x, y):SetPlotType(plotMountain, false, false);
			Map.GetPlot(cvm_x+1, y):SetPlotType(plotMountain, false, false);
		end	
	end	
		-- separates mountains addition for dynamic
	cvm_x = 16;
	if g_GenTypeOption == 2 then	
		for y = 0, iH-1, 2 do
			cvm_plot = Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_EAST)
			cvm_plot2 = Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHEAST)
			cvm_plot3 = Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHEAST)
			boolcheck = false
			if ((cvm_plot2 ~= nil) and (cvm_plot3 ~= nil)) then
				boolcheck = ((not cvm_plot:IsMountain()) and (not cvm_plot2:IsMountain()) and (not cvm_plot3:IsMountain()))
			end
			if boolcheck then
					gto = Map.Rand(4, "Skeeper Dynamic Map M3.1") if _dpo then print("M3.1 "..gto); end;
					if gto > 0 then Map.GetPlot(cvm_x, y):SetPlotType(plotMountain, false, false); end	
					
					cvm_plot = Map.PlotDirection(cvm_x+2, y, DirectionTypes.DIRECTION_WEST)
					cvm_plot2 = Map.PlotDirection(cvm_x+2, y, DirectionTypes.DIRECTION_SOUTHWEST)
					cvm_plot3 = Map.PlotDirection(cvm_x+2, y, DirectionTypes.DIRECTION_NORTHWEST)
					boolcheck = false
					if ((cvm_plot2 ~= nil) and (cvm_plot3 ~= nil)) then
						boolcheck = ((not cvm_plot:IsMountain()) and (not cvm_plot2:IsMountain()) and (not cvm_plot3:IsMountain()))
					end
					if boolcheck then
						gto = Map.Rand(4, "Skeeper Dynamic Map M3.2") if _dpo then print("M3.2 "..gto); end;
						if gto > 0 then Map.GetPlot(cvm_x+2, y):SetPlotType(plotMountain, false, false); end						
					end
			elseif (not cvm_plot:IsMountain()) then
				gto = Map.Rand(4, "Skeeper Dynamic Map M3.3") if _dpo then print("M3.3 "..gto); end;
				if gto == 0 then Map.GetPlot(cvm_x, y):SetPlotType(plotMountain, false, false); end	
				gto = Map.Rand(4, "Skeeper Dynamic Map M3.4") if _dpo then print("M3.4 "..gto); end;
				if gto == 0 then Map.GetPlot(cvm_x+2, y):SetPlotType(plotMountain, false, false); end	
			else
				gto = Map.Rand(8, "Skeeper Dynamic Map M3.5") if _dpo then print("M3.5 "..gto); end;
				if gto == 0 then Map.GetPlot(cvm_x, y):SetPlotType(plotMountain, false, false); end
				gto = Map.Rand(8, "Skeeper Dynamic Map M3.6") if _dpo then print("M3.6 "..gto); end;
				if gto == 0 then Map.GetPlot(cvm_x+2, y):SetPlotType(plotMountain, false, false); end	
			end

			if _dpo then print("M3 for "..cvm_x..", "..y); end;
		end	
	end	
	
	-- Left Side Map Cut
	if g_WrappedOption == 1 then 
		cvm_x = 0;
		for y = 0, iH-1, 2 do Map.GetPlot(cvm_x, y):SetPlotType(plotMountain, false, false) end	
	end
		
	-- central canyons
	cvm_x = 15;
	if g_GenTypeOption == 2 then
		for y = 1, iH-1, 2 do
			gto = Map.Rand(4, "Skeeper Dynamic Map M4")
			if gto > 1 then Map.GetPlot(cvm_x, y):SetPlotType(plotCanyon, false, false); end	
			gto = Map.Rand(4, "Skeeper Dynamic Map M4")
			if gto > 1 then Map.GetPlot(cvm_x+3, y):SetPlotType(plotCanyon, false, false); end	
			gto = Map.Rand(4, "Skeeper Dynamic Map M4")
			if gto > 1 then Map.GetPlot(cvm_x-1, y):SetPlotType(plotCanyon, false, false); end	
			gto = Map.Rand(4, "Skeeper Dynamic Map M4")
			if gto > 1 then Map.GetPlot(cvm_x+4, y):SetPlotType(plotCanyon, false, false); end	
		end			
	else
		for y = 1, iH-1, 2 do
			Map.GetPlot(cvm_x, y):SetPlotType(plotCanyon, false, false);
			Map.GetPlot(cvm_x+3, y):SetPlotType(plotCanyon, false, false);
		end	
	end	
	
	-- central lakes, makes with terrain, Ocean is not Type of Plot anymore
	-- cvm_x = 14;
	-- for y = 2, iH-1, 4 do
		-- Map.GetPlot(cvm_x, y):SetPlotType(plotOcean, false, false);
		-- Map.GetPlot(cvm_x+6, y):SetPlotType(plotOcean, false, false);
	-- end
		
	-- desert hill
	cvm_x = 3;
	if g_GenTypeOption == 2 then
		for y = 0, iH-1, 1 do
			gto = Map.Rand(5, "Skeeper Dynamic Map M5")
			if gto > 0 then Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false); end	
			gto = Map.Rand(5, "Skeeper Dynamic Map M5")
			if gto == 0 then Map.GetPlot(cvm_x-1, y):SetPlotType(plotHill, false, false); end	
		end	
	else
		for y = 0, iH-1, 1 do
			Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
		end	
	end	
	
	cvm_x = 31;
	if g_GenTypeOption == 2 then
		for y = 0, iH-1, 1 do
			gto = Map.Rand(5, "Skeeper Dynamic Map M5")
			if gto > 0 then 
				if (y % 2 == 0) then
					Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
				else
					Map.GetPlot(cvm_x-1, y):SetPlotType(plotHill, false, false);
				end
			end
			gto = Map.Rand(5, "Skeeper Dynamic Map M5")
			if gto == 0 then 
				if (y % 2 == 0) then
					Map.GetPlot(cvm_x+1, y):SetPlotType(plotHill, false, false);
				else
					Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
				end			
			end
		end	
	else
		for y = 0, iH-1, 1 do
			if (y % 2 == 0) then
				Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
			else
				Map.GetPlot(cvm_x-1, y):SetPlotType(plotHill, false, false);
			end
		end	
	end	
		
	-- grass hill
	cvm_x = 4;
	if g_GenTypeOption == 2 then
		for y = 0, iH-1, 1 do
			gto = Map.Rand(5, "Skeeper Dynamic Map M6")
			if gto > 0 then Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false); end
			gto = Map.Rand(5, "Skeeper Dynamic Map M6")
			if gto == 0 then Map.GetPlot(cvm_x+1, y):SetPlotType(plotHill, false, false); end
		end	
	else
		for y = 0, iH-1, 1 do
			Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
		end	
	end	
	
	cvm_x = 30;
	if g_GenTypeOption == 2 then
		for y = 0, iH-1, 1 do
			gto = Map.Rand(5, "Skeeper Dynamic Map M6")
			if gto > 0 then 
				if (y % 2 == 0) then
					Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
				else
					Map.GetPlot(cvm_x-1, y):SetPlotType(plotHill, false, false);
				end
			end
			gto = Map.Rand(5, "Skeeper Dynamic Map M6")
			if gto == 0 then 
				if (y % 2 == 0) then
					Map.GetPlot(cvm_x-1, y):SetPlotType(plotHill, false, false);
				else
					Map.GetPlot(cvm_x-2, y):SetPlotType(plotHill, false, false);
				end			
			end
		end	
	else
		for y = 0, iH-1, 1 do
			if (y % 2 == 0) then
				Map.GetPlot(cvm_x, y):SetPlotType(plotHill, false, false);
			else
				Map.GetPlot(cvm_x-1, y):SetPlotType(plotHill, false, false);
			end
		end	
	end	

end
------------------------------------------------------------------------------
-- function TerrainGenerator:GetLatitudeAtPlot(iX, iY)
	-- print("TerrainGenerator:GetLatitudeAtPlot (PW_testing_map.Lua)"); -- dbg
	-- All latitudes fixed to be Temperate region
	
	-- return 0.35;
-- end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function SetTerrainTypes(terrainTypes)
	print("Setting Terrain Types (AC_Skeeper_Tail.Lua)");
	for i, plot in Plots() do
		if plot:IsWater() then
			plot:SetTerrainType(GameInfo.Terrains.TERRAIN_COAST.ID, false, true);
		else
			plot:SetTerrainType(terrainTypes[i+1], false, true);
		end
	end
end
------------------------------------------------------------------------------
-- SECOND MAIN FUNC
function GenerateTerrain()
	-- This is a basic, empty shell. All map scripts should replace this function with their own.
	print("Generating Terrain Types (AC_Skeeper_Tail.Lua)");
	local _dpo = true;
	-- local _dpo = false;
	
	-- terrainTypes is 0-based to map directly to Map.GetPlotByIndex
	local terrainGrass = GameInfo.Terrains.TERRAIN_GRASS.ID;
	local terrainPlains = GameInfo.Terrains.TERRAIN_PLAINS.ID;
	local terrainDesert = GameInfo.Terrains.TERRAIN_DESERT.ID;
	local terrainTundra = GameInfo.Terrains.TERRAIN_TUNDRA.ID;
	local terrainSnow = GameInfo.Terrains.TERRAIN_SNOW.ID;
	
	local terrainCoast = GameInfo.Terrains.TERRAIN_COAST.ID;
	local terrainOcean = GameInfo.Terrains.TERRAIN_OCEAN.ID;
	local terrainTrench = GameInfo.Terrains.TERRAIN_TRENCH.ID;
	
	local terrainMountain = GameInfo.Terrains.TERRAIN_MOUNTAIN.ID;
	local terrainHill = GameInfo.Terrains.TERRAIN_HILL.ID;
	local terrainCanyon = GameInfo.Terrains.TERRAIN_CANYON.ID;
	
	local terrainTypes = {};

	for i = 1, Map.GetNumPlots() - 1, 1 do terrainTypes[i] = terrainSnow; end 
	
	SetTerrainTypes(terrainTypes);	
	
	local iW, iH = Map.GetGridSize();
	local sizekey = Map.GetWorldSize();
	local cvm_plot, cvm_x, gto, cvm_plot2, cvm_plot3, boolcheck
	local direction_types = {
		DirectionTypes.DIRECTION_NORTHEAST,
		DirectionTypes.DIRECTION_EAST,
		DirectionTypes.DIRECTION_SOUTHEAST,
		DirectionTypes.DIRECTION_SOUTHWEST,
		DirectionTypes.DIRECTION_WEST,
		DirectionTypes.DIRECTION_NORTHWEST
		};
	
	-- central snow, snow cover is default
	-- cvm_x = 16;
	-- for y = 0, iH-1, 1 do
		-- Map.GetPlot(cvm_x, y):SetTerrainType(terrainSnow, false, true);
		-- Map.GetPlot(cvm_x+1, y):SetTerrainType(terrainSnow, false, true);
	-- end	
	-- cvm_x = 18;
	-- for y = 0, iH-1, 2 do
		-- Map.GetPlot(cvm_x, y):SetTerrainType(terrainSnow, false, true);
	-- end	
		
	-- tundra		
	cvm_x = 14;
	if g_GenTypeOption == 2 then
		for y = 0, iH-1, 1 do
			gto = Map.Rand(10, "Skeeper Dynamic Map T1")
			if gto > 0 then Map.GetPlot(cvm_x, y):SetTerrainType(terrainTundra, false, true); end
			gto = Map.Rand(5, "Skeeper Dynamic Map T1")
			if gto > 0 then Map.GetPlot(cvm_x+1, y):SetTerrainType(terrainTundra, false, true); end
			gto = Map.Rand(4, "Skeeper Dynamic Map T1")
			if gto > 1 then Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainTundra, false, true); end
		end			
	else
		for y = 0, iH-1, 1 do
			Map.GetPlot(cvm_x, y):SetTerrainType(terrainTundra, false, true);
			Map.GetPlot(cvm_x+1, y):SetTerrainType(terrainTundra, false, true);
			-- Map.GetPlot(cvm_x+5, y):SetTerrainType(terrainTundra, false, true);
		end	
	end	
	
	cvm_x = 20;
	if g_GenTypeOption == 2 then
		for y = 0, iH-1, 1 do
			gto = Map.Rand(10, "Skeeper Dynamic Map T1")
			if gto > 0 then 
				if (y % 2 == 0) then
					Map.GetPlot(cvm_x, y):SetTerrainType(terrainTundra, false, true);
				else
					Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainTundra, false, true);
				end
			end
			gto = Map.Rand(5, "Skeeper Dynamic Map T1")
			if gto > 0 then 
				if (y % 2 == 0) then
					Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainTundra, false, true);
				else
					Map.GetPlot(cvm_x-2, y):SetTerrainType(terrainTundra, false, true);
				end
			end
			gto = Map.Rand(4, "Skeeper Dynamic Map T1")
			if gto > 1 then 
				if (y % 2 == 0) then
					Map.GetPlot(cvm_x+1, y):SetTerrainType(terrainTundra, false, true);
				else
					Map.GetPlot(cvm_x, y):SetTerrainType(terrainTundra, false, true);
				end
			end
		end	
	else
		for y = 0, iH-1, 1 do
			if (y % 2 == 0) then
				Map.GetPlot(cvm_x, y):SetTerrainType(terrainTundra, false, true);
				Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainTundra, false, true);
			else
				Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainTundra, false, true);
				Map.GetPlot(cvm_x-2, y):SetTerrainType(terrainTundra, false, true);
			end
		end	
	end	
	
	-- central lakes
	-- cvm_x = 14;
	-- for y = 2, iH-1, 4 do
		-- Map.GetPlot(cvm_x, y):SetTerrainType(terrainCoast, false, true);
		-- Map.GetPlot(cvm_x+6, y):SetTerrainType(terrainCoast, false, true);
	-- end
	-- for y = 0, iH-1 do -- When handling global plot indices, process Y first.
		-- for x = 0, iW-1 do
			-- cvm_plot = Map.GetPlot(x, y)
			-- if cvm_plot:GetPlotType() == PlotTypes.PLOT_OCEAN then cvm_plot:SetTerrainType(terrainCoast, false, true); end
		-- end
	-- end 
	cvm_x = 14
	if g_GenTypeOption == 2 then
		for y = 2, iH-1, 4 do
			cvm_plot = Map.GetPlot(cvm_x, y)
			-- check diagonal canyons
			boolcheck = false
			boolcheck = Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHEAST):IsCanyon() or Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHEAST):IsCanyon()
			if (not boolcheck) then
				gto = Map.Rand(8, "Skeeper Dynamic Map T2.1") if _dpo then print("T2.1 "..gto); end;
				if gto > 0 then Map.GetPlot(cvm_x, y):SetTerrainType(terrainCoast, false, true); end
				gto = Map.Rand(4, "Skeeper Dynamic Map T2.2") if _dpo then print("T2.2 "..gto); end;
				if gto == 0 then
					gto = 4+ Map.Rand(3, "Skeeper Dynamic Map T2.3") if _dpo then print("T2.3 "..gto); end;
					cvm_plot = Map.PlotDirection(cvm_x, y, direction_types[gto])
					if cvm_plot then
						cvm_plot:SetTerrainType(terrainCoast, false, true)
					end
				end
			else -- if any diagonal canyon
				gto = Map.Rand(8, "Skeeper Dynamic Map T2.4") if _dpo then print("T2.4 "..gto); end;
				if gto > 0 then Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainCoast, false, true); end	
				boolcheck = Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHEAST):IsCanyon()
				if (not boolcheck) then
					gto = Map.Rand(8, "Skeeper Dynamic Map T2.5") if _dpo then print("T2.5 "..gto); end;
					if gto > 0 then Map.PlotDirection(cvm_x-1, y, DirectionTypes.DIRECTION_NORTHEAST):SetTerrainType(terrainCoast, false, true); end	
				end
				boolcheck = Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHEAST):IsCanyon()
				if (not boolcheck) then
					gto = Map.Rand(8, "Skeeper Dynamic Map T2.6") if _dpo then print("T2.6 "..gto); end;
					if gto > 0 then Map.PlotDirection(cvm_x-1, y, DirectionTypes.DIRECTION_SOUTHEAST):SetTerrainType(terrainCoast, false, true); end	
				end
			end
			if _dpo then print("T2 for "..cvm_x..", "..y); end;

			cvm_plot = Map.GetPlot(cvm_x+6, y)
			-- check diagonal canyons
			boolcheck = false
			boolcheck = Map.PlotDirection(cvm_x+6, y, DirectionTypes.DIRECTION_NORTHWEST):IsCanyon() or Map.PlotDirection(cvm_x+6, y, DirectionTypes.DIRECTION_SOUTHWEST):IsCanyon()
			if (not boolcheck) then
				gto = Map.Rand(8, "Skeeper Dynamic Map T2.7") if _dpo then print("T2.7 "..gto); end;			
				if gto > 0 then Map.GetPlot(cvm_x+6, y):SetTerrainType(terrainCoast, false, true); end
				gto = Map.Rand(4, "Skeeper Dynamic Map T2.8") if _dpo then print("T2.8 "..gto); end;
				if gto == 0 then
					gto = 1+ Map.Rand(3, "Skeeper Dynamic Map T2.9") if _dpo then print("T2.9 "..gto); end;
					cvm_plot = Map.PlotDirection(cvm_x+6, y, direction_types[gto])
					if cvm_plot then
						cvm_plot:SetTerrainType(terrainCoast, false, true)
					end
				end
			else -- if any diagonal canyon
				gto = Map.Rand(8, "Skeeper Dynamic Map T2.10") if _dpo then print("T2.10 "..gto); end;
				if gto > 0 then Map.GetPlot(cvm_x+7, y):SetTerrainType(terrainCoast, false, true); end	
				boolcheck = Map.PlotDirection(cvm_x+6, y, DirectionTypes.DIRECTION_NORTHWEST):IsCanyon()
				if (not boolcheck) then
					gto = Map.Rand(8, "Skeeper Dynamic Map T2.11") if _dpo then print("T2.11 "..gto); end;
					if gto > 0 then Map.PlotDirection(cvm_x+7, y, DirectionTypes.DIRECTION_NORTHWEST):SetTerrainType(terrainCoast, false, true); end	
				end
				boolcheck = Map.PlotDirection(cvm_x+6, y, DirectionTypes.DIRECTION_SOUTHWEST):IsCanyon()
				if (not boolcheck) then
					gto = Map.Rand(8, "Skeeper Dynamic Map T2.12") if _dpo then print("T2.12 "..gto); end;
					if gto > 0 then Map.PlotDirection(cvm_x+7, y, DirectionTypes.DIRECTION_SOUTHWEST):SetTerrainType(terrainCoast, false, true); end	
				end
			end
			if _dpo then print("T2 for "..(cvm_x+6)..", "..y); end;
		end
	else
		for y = 2, iH-1, 4 do
			Map.GetPlot(cvm_x, y):SetTerrainType(terrainCoast, false, true);
			Map.GetPlot(cvm_x+6, y):SetTerrainType(terrainCoast, false, true);
		end	
	end	

	cvm_x = 13; -- PLAINS
	if g_GenTypeOption == 2 then -- DYNAMIC
		for y = 0, iH-1, 1 do
			cvm_plot = Map.GetPlot(cvm_x, y)	-- LEFT
			boolcheck = false
			boolcheck = (cvm_plot:GetTerrainType() == terrainCoast) or (cvm_plot:GetTerrainType() == terrainTundra)
			if (not boolcheck) then
				Map.GetPlot(cvm_x, y):SetTerrainType(terrainPlains, false, true);
			end
			Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainPlains, false, true);
			Map.GetPlot(cvm_x-2, y):SetTerrainType(terrainPlains, false, true);
			Map.GetPlot(cvm_x-3, y):SetTerrainType(terrainPlains, false, true);
			gto = Map.Rand(4, "Skeeper Dynamic Map T3")
			if gto > 1 and (y % 2 == 0) then 
				Map.GetPlot(cvm_x-4, y):SetTerrainType(terrainPlains, false, true);
			end
			
			cvm_plot = Map.GetPlot(cvm_x+8, y)	-- RIGHT
			if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+7, y) end
			boolcheck = false
			boolcheck = (cvm_plot:GetTerrainType() == terrainCoast) or (cvm_plot:GetTerrainType() == terrainTundra)
			if (not boolcheck) then
				cvm_plot:SetTerrainType(terrainPlains, false, true);
			end
			cvm_plot = Map.GetPlot(cvm_x+9, y)
			if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+8, y)	end
			cvm_plot:SetTerrainType(terrainPlains, false, true);
			cvm_plot = Map.GetPlot(cvm_x+10, y)
			if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+9, y)	end
			cvm_plot:SetTerrainType(terrainPlains, false, true);
			cvm_plot = Map.GetPlot(cvm_x+11, y)
			if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+10, y)	end
			cvm_plot:SetTerrainType(terrainPlains, false, true);
			gto = Map.Rand(4, "Skeeper Dynamic Map T3")
			if gto > 1 and (y % 2 == 0) then 
				Map.GetPlot(cvm_x+12, y):SetTerrainType(terrainPlains, false, true);
			end
			
		end			
	else -- STATIC
		for y = 0, iH-1, 1 do
			Map.GetPlot(cvm_x, y):SetTerrainType(terrainPlains, false, true);
			Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainPlains, false, true);
			Map.GetPlot(cvm_x-2, y):SetTerrainType(terrainPlains, false, true);
			Map.GetPlot(cvm_x-3, y):SetTerrainType(terrainPlains, false, true);
			Map.GetPlot(cvm_x+8, y):SetTerrainType(terrainPlains, false, true);
			Map.GetPlot(cvm_x+9, y):SetTerrainType(terrainPlains, false, true);
			Map.GetPlot(cvm_x+10, y):SetTerrainType(terrainPlains, false, true);
		end	
		cvm_x = 24;
		for y = 0, iH-1, 1 do
			if (y % 2 == 0) then
				Map.GetPlot(cvm_x, y):SetTerrainType(terrainPlains, false, true);
			else
				Map.GetPlot(cvm_x-4, y):SetTerrainType(terrainPlains, false, true);
			end
		end	
	end	
	
	cvm_x = 9;	-- GRASS
	if g_GenTypeOption == 2 then -- DYNAMIC
		for y = 0, iH-1, 1 do
			cvm_plot = Map.GetPlot(cvm_x, y)	-- LEFT
			if not (cvm_plot:GetTerrainType() == terrainPlains) then
				Map.GetPlot(cvm_x, y):SetTerrainType(terrainGrass, false, true);
			end
			
			cvm_plot = Map.GetPlot(cvm_x-1, y)
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainPlains, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x-2, y)
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainPlains, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x-3, y)
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainPlains, false, true); end
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainDesert, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x-4, y)
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainDesert, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x-5, y)
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainDesert, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x-6, y)
			gto = Map.Rand(4, "Skeeper Dynamic Map T4")
			if gto == 0 and (not(y % 2 == 0)) then cvm_plot:SetTerrainType(terrainGrass, false, true); end
			
			-- cvm_x = 25	-- RIGHT
			-- cvm_plot = Map.GetPlot(cvm_x+16, y)
			cvm_plot = Map.GetPlot(cvm_x+16, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+16-1, y)	end
			if not (cvm_plot:GetTerrainType() == terrainPlains) then
				cvm_plot:SetTerrainType(terrainGrass, false, true);
			end
			
			cvm_plot = Map.GetPlot(cvm_x+16+1, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+16, y)	end
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainPlains, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x+16+2, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+16+1, y)	end
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainPlains, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x+16+3, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+16+2, y)	end
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainPlains, false, true); end
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainDesert, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x+16+4, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+16+3, y)	end
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainDesert, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x+16+5, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+16+4, y)	end
			cvm_plot:SetTerrainType(terrainGrass, false, true);
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 then cvm_plot:SetTerrainType(terrainDesert, false, true); end
			
			cvm_plot = Map.GetPlot(cvm_x+16+6, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+16+5, y)	end
			gto = Map.Rand(9, "Skeeper Dynamic Map T4")
			if gto == 0 and (not(y % 2 == 0)) then cvm_plot:SetTerrainType(terrainGrass, false, true); end

		end
	else -- STATIC
		for y = 0, iH-1, 1 do
			Map.GetPlot(cvm_x, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x-2, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x-3, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x-4, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x-5, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x+16, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x+17, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x+18, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x+19, y):SetTerrainType(terrainGrass, false, true);
			Map.GetPlot(cvm_x+20, y):SetTerrainType(terrainGrass, false, true);
		end	
		cvm_x = 30;
		for y = 0, iH-1, 1 do
			if (y % 2 == 0) then
				Map.GetPlot(cvm_x, y):SetTerrainType(terrainGrass, false, true);
			else
				Map.GetPlot(cvm_x-6, y):SetTerrainType(terrainGrass, false, true);
			end
		end	
	end	
	
	-- grass in plains for marsh, should be placed when features
	-- cvm_x = 10;
	-- for y = 3, iH-1, 8 do
		-- Map.GetPlot(cvm_x, y):SetTerrainType(terrainGrass, false, true);
		-- Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHEAST):SetTerrainType(terrainGrass, false, true);
		-- Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHEAST):SetTerrainType(terrainGrass, false, true);
	-- end	
	-- cvm_x = 23;
	-- for y = 3, iH-1, 8 do
		-- Map.GetPlot(cvm_x, y):SetTerrainType(terrainGrass, false, true);
		-- Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHWEST):SetTerrainType(terrainGrass, false, true);
		-- Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHWEST):SetTerrainType(terrainGrass, false, true);
	-- end	
	
	cvm_x = 3;	-- DESERT
	if g_GenTypeOption == 2 then -- DYNAMIC
		for y = 0, iH-1, 1 do
			cvm_plot = Map.GetPlot(cvm_x, y)	-- LEFT
			if not (cvm_plot:GetTerrainType() == terrainGrass) then
				cvm_plot:SetTerrainType(terrainDesert, false, true);
			end
			
			cvm_plot = Map.GetPlot(cvm_x-1, y)
			cvm_plot:SetTerrainType(terrainDesert, false, true);
			
			cvm_plot = Map.GetPlot(cvm_x-2, y)
			cvm_plot:SetTerrainType(terrainDesert, false, true);
			
			cvm_plot = Map.GetPlot(cvm_x-3, y)
			if (not(y % 2 == 0)) then cvm_plot:SetTerrainType(terrainDesert, false, true); end
			
			-- RIGHT
			cvm_plot = Map.GetPlot(cvm_x+28, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+28-1, y)	end
			if not (cvm_plot:GetTerrainType() == terrainGrass) then
				cvm_plot:SetTerrainType(terrainDesert, false, true);
			end
			
			cvm_plot = Map.GetPlot(cvm_x+28+1, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+28, y)	end
			cvm_plot:SetTerrainType(terrainDesert, false, true);
			
			cvm_plot = Map.GetPlot(cvm_x+28+2, y); 
			cvm_plot:SetTerrainType(terrainDesert, false, true);
			if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+28+1, y)	end
			cvm_plot:SetTerrainType(terrainDesert, false, true);
		end	
		-- Left Side Map Cut
		if g_WrappedOption == 2 then 
			cvm_x = 0;
			for y = 0, iH-1, 2 do Map.GetPlot(cvm_x, y):SetTerrainType(terrainDesert, false, true) end	
		end
	else -- STATIC	
		for y = 0, iH-1, 1 do
			Map.GetPlot(cvm_x, y):SetTerrainType(terrainDesert, false, true);
			Map.GetPlot(cvm_x-1, y):SetTerrainType(terrainDesert, false, true);
			Map.GetPlot(cvm_x-2, y):SetTerrainType(terrainDesert, false, true);
			Map.GetPlot(cvm_x-3, y):SetTerrainType(terrainDesert, false, true);
			Map.GetPlot(cvm_x+28, y):SetTerrainType(terrainDesert, false, true);
			Map.GetPlot(cvm_x+29, y):SetTerrainType(terrainDesert, false, true);
			Map.GetPlot(cvm_x+30, y):SetTerrainType(terrainDesert, false, true);
		end	
		cvm_x = 30;
		for y = 1, iH-1, 2 do
			-- if (y % 2 == 0) then
				Map.GetPlot(cvm_x, y):SetTerrainType(terrainDesert, false, true);
			-- else
				-- Map.GetPlot(cvm_x-8, y);
				-- cvm_plot:SetTerrainType(terrainGrass, false, true);
			-- end
		end	
	end	
		
	
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function RiverGenerator:Generate(args)
	print("RiverGenerator:Generate(args) - AC_Skeeper_Tail.lua");
	-- This is the controlling function for the River Generator.
	-- Only rivers
	local args = args or {};

	-- Enact Canyon generation Method C.
	-- self:MethodC()

	-- Must remove any canyons from coastlines before generating rivers.
	-- local iW, iH = Map.GetGridSize();
	-- local num_canyons_softened = 0;
	-- for x = 0, iW - 1 do
		-- for y = 0, iH - 1 do
			-- local plot = Map.GetPlot(x, y)
			-- if plot:IsCoastalLand() then -- Check for canyon.
				-- if plot:GetPlotType() == PlotTypes.PLOT_CANYON then -- Soften Canyon plot into flat land.
					-- plot:SetPlotType(PlotTypes.PLOT_LAND, false, true); -- These flags are for recalc of areas and rebuild of graphics. Instead of recalc over and over, do recalc at end of loop.
					-- num_canyons_softened = num_canyons_softened + 1;
				-- end
			-- end
		-- end
	-- end
	-- print("- -");
	-- print(num_canyons_softened, "canyons along coasts softened into flat land.");
	-- print("- -");
	--
	-- Map.RecalculateAreas();
	
	-- Add rivers.
	self:GenerateRivers(args);
	
	-- Enact Canyon generation Methods A and B.
	-- self:MethodA();
	
	-- Add lakes.
	-- self:GenerateLakes(args);
	
end
------------------------------------------------------------------------------
-- THIRD MAIN FUNC
function AddRivers()
	print("-------------------------------");
	print("AddRivers AC_Skeeper_Tail.lua ---- ") -- dbg
	-- happens in Map.Generator before features
	-- FlowDirectionTypes.NO_FLOWDIRECTION
	local iW, iH = Map.GetGridSize();
	

	local cvm_plot;
	local cvm_x;
	-- FlowDirectionTypes.NO_FLOWDIRECTION
	-- FlowDirectionTypes.FLOWDIRECTION_NORTH
	-- FlowDirectionTypes.FLOWDIRECTION_NORTHEAST
	-- FlowDirectionTypes.FLOWDIRECTION_SOUTHEAST
	-- FlowDirectionTypes.FLOWDIRECTION_SOUTH
	-- FlowDirectionTypes.FLOWDIRECTION_SOUTHWEST
	-- FlowDirectionTypes.FLOWDIRECTION_NORTHWEST

	if g_GenTypeOption == 2 then -- DYNAMIC
		local args = {};
		local rivergen = RiverGenerator.Create(args);
		
		rivergen:Generate();		
	else -- STATIC
		-- right rivers
		cvm_x = 20;
		for y = 1, iH-1, 8 do
			cvm_plot = Map.GetPlot(cvm_x-1, y);	
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);	
			cvm_plot = Map.GetPlot(cvm_x, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTHEAST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);	
			cvm_plot = Map.GetPlot(cvm_x+1, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);	
			cvm_plot = Map.GetPlot(cvm_x+2, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);	
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTH);		
			cvm_plot = Map.GetPlot(cvm_x+3, y+1);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+4, y+1);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+5, y+1);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);	
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTH);		
			cvm_plot = Map.GetPlot(cvm_x+5, y+2);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+6, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+7, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+8, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+9, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+10, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+11, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+12, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+13, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
		end
		cvm_x = 20;
		for y = 6, iH-1, 8 do
			cvm_plot = Map.GetPlot(cvm_x, y);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+1, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+2, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+1, y-1);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);
			cvm_plot = Map.GetPlot(cvm_x+2, y-1);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+3, y-1);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+3, y-2);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);
			cvm_plot = Map.GetPlot(cvm_x+4, y-2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+5, y-2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+6, y-2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST);
			cvm_plot = Map.GetPlot(cvm_x+5, y-3);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);
		end	
		-- left rivers
		cvm_x = 13;
		for y = 1, iH-1, 8 do
			cvm_plot = Map.GetPlot(cvm_x, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);
			cvm_plot = Map.GetPlot(cvm_x-1, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-2, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot = Map.GetPlot(cvm_x-2, y+1);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot = Map.GetPlot(cvm_x-3, y);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTH);
			cvm_plot = Map.GetPlot(cvm_x-3, y+1);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-4, y+1);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-5, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot = Map.GetPlot(cvm_x-5, y+1);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTH);
			cvm_plot = Map.GetPlot(cvm_x-6, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-7, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-8, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-9, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-10, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-11, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-12, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-13, y+2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
		end	
		cvm_x = 14;
		for y = 6, iH-1, 8 do
			cvm_plot = Map.GetPlot(cvm_x, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot = Map.GetPlot(cvm_x-1, y);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-2, y);
			-- cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-3, y-1);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot = Map.GetPlot(cvm_x-4, y-1);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			-- cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);
			cvm_plot = Map.GetPlot(cvm_x-4, y-2);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot = Map.GetPlot(cvm_x-5, y-2);
			cvm_plot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.NO_FLOWDIRECTION);
			cvm_plot = Map.GetPlot(cvm_x-6, y-2);
			cvm_plot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST);
			cvm_plot = Map.GetPlot(cvm_x-7, y-3);
			cvm_plot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH);
		end	
	end	
		
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- FOURTH MAIN FUNC
function AddFeatures()
	print("-------------------------------");
	print("AddFeatures AC_Skeeper_Tail.lua ---- ") -- dbg

	local featureIce 		 = GameInfo.Features.FEATURE_ICE.ID;
	local featureMarsh 		 = GameInfo.Features.FEATURE_MARSH.ID;
	local featureFloodPlains = GameInfo.Features.FEATURE_FLOOD_PLAINS.ID;
	local featureForest		 = GameInfo.Features.FEATURE_FOREST.ID;
	local featureMiasma		 = GameInfo.Features.FEATURE_MIASMA.ID;
	local featureCrater		 = GameInfo.Features.FEATURE_CRATER.ID;
	local featureReef		 = GameInfo.Features.FEATURE_REEF.ID;
	
	local terrainGrass = GameInfo.Terrains.TERRAIN_GRASS.ID;
	local terrainPlains = GameInfo.Terrains.TERRAIN_PLAINS.ID;
	local terrainDesert = GameInfo.Terrains.TERRAIN_DESERT.ID;
	local terrainTundra = GameInfo.Terrains.TERRAIN_TUNDRA.ID;
	local terrainSnow = GameInfo.Terrains.TERRAIN_SNOW.ID;
	
	local terrainCoast = GameInfo.Terrains.TERRAIN_COAST.ID;
	local terrainOcean = GameInfo.Terrains.TERRAIN_OCEAN.ID;
	local terrainTrench = GameInfo.Terrains.TERRAIN_TRENCH.ID;
	
	local terrainMountain = GameInfo.Terrains.TERRAIN_MOUNTAIN.ID;
	local terrainHill = GameInfo.Terrains.TERRAIN_HILL.ID;
	local terrainCanyon = GameInfo.Terrains.TERRAIN_CANYON.ID;

	local iW, iH = Map.GetGridSize();
	local sizekey = Map.GetWorldSize();
	local cvm_plot, cvm_x, gto, cvm_plot2, cvm_plot3, boolcheck
	local direction_types = {
		DirectionTypes.DIRECTION_NORTHEAST,
		DirectionTypes.DIRECTION_EAST,
		DirectionTypes.DIRECTION_SOUTHEAST,
		DirectionTypes.DIRECTION_SOUTHWEST,
		DirectionTypes.DIRECTION_WEST,
		DirectionTypes.DIRECTION_NORTHWEST
		};


	cvm_x = 12;	-- PLAINS FOREST	
	if g_GenTypeOption == 2 then -- DYNAMIC
		for y = 0, iH-1, 1 do
			cvm_plot = Map.GetPlot(cvm_x+1, y)	-- LEFT
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F1")
					if gto > 1 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F1")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x+2, y)
			if cvm_plot:CanHaveFeature(featureForest) then
				gto = Map.Rand(9, "Skeeper Dynamic Map F1")
				if gto < 2 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
			end
			
			cvm_plot = Map.GetPlot(cvm_x, y)
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F1")
					if gto > 4 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F1")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x-1, y)
			if cvm_plot:CanHaveFeature(featureForest) then
				gto = Map.Rand(9, "Skeeper Dynamic Map F1")
				if gto < 2 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
			end
			
			cvm_plot = Map.GetPlot(cvm_x-2, y)
			if cvm_plot:CanHaveFeature(featureForest) then
				gto = Map.Rand(9, "Skeeper Dynamic Map F1")
				if gto < 2 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
			end

			-- RIGHT
			cvm_plot = Map.GetPlot(cvm_x+9, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+9-1, y)	end
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F1")
					if gto > 1 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F1")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x+9-1, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+9-2, y)	end
			if cvm_plot:CanHaveFeature(featureForest) then
				gto = Map.Rand(9, "Skeeper Dynamic Map F1")
				if gto < 2 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
			end
			
			cvm_plot = Map.GetPlot(cvm_x+9+1, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+9, y)	end
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F1")
					if gto > 4 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F1")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x+9+2, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+9+1, y)	end
			if cvm_plot:CanHaveFeature(featureForest) then
				gto = Map.Rand(9, "Skeeper Dynamic Map F1")
				if gto < 2 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
			end
			
			cvm_plot = Map.GetPlot(cvm_x+9+3, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+9+2, y)	end
			if cvm_plot:CanHaveFeature(featureForest) then
				gto = Map.Rand(9, "Skeeper Dynamic Map F1")
				if gto < 2 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
			end
			
		end	

	else -- STATIC
		-- plains forest
		for y = 0, iH-1, 1 do
			Map.GetPlot(cvm_x, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
			Map.GetPlot(cvm_x+1, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
			Map.GetPlot(cvm_x+9, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
		end	
		cvm_x = 22;
		for y = 0, iH-1, 1 do
			if (y % 2 == 0) then
				Map.GetPlot(cvm_x, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
			else
				Map.GetPlot(cvm_x-2, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
			end
		end	
	end	
		
		
	cvm_x = 5;-- GRASS HILLS FOREST
	if g_GenTypeOption == 2 then -- DYNAMIC
		for y = 0, iH-1, 1 do
			cvm_plot = Map.GetPlot(cvm_x, y)	-- LEFT
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto == 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x-1, y)
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 1 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x-2, y)
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 2 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			-- RIGHT
			cvm_plot = Map.GetPlot(cvm_x+24, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+24-1, y)	end
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto == 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x+24+1, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+24+1-1, y)	end
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 1 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x+24+2, y); if not (y % 2 == 0) then cvm_plot = Map.GetPlot(cvm_x+24+2-1, y)	end
			if cvm_plot:CanHaveFeature(featureForest) then
				if cvm_plot:IsHills() then
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 2 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				else
					gto = Map.Rand(9, "Skeeper Dynamic Map F2")
					if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FOREST, -1); end
				end
			end
			
		end
	else -- STATIC
		for y = 0, iH-1, 1 do
			Map.GetPlot(cvm_x, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
			Map.GetPlot(cvm_x-1, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
			Map.GetPlot(cvm_x+24, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
		end	
		cvm_x = 30;
		for y = 0, iH-1, 1 do
			if (y % 2 == 0) then
				Map.GetPlot(cvm_x, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
			else
				Map.GetPlot(cvm_x-2, y):SetFeatureType(FeatureTypes.FEATURE_FOREST, -1);
			end
		end	
	end	
	

	cvm_x = 10;  -- GRASS MARSH
	if g_GenTypeOption == 2 then -- DYNAMIC
		for y = 3, iH-1, 8 do
			cvm_plot = Map.GetPlot(cvm_x, y)	-- LEFT
			boolcheck = (cvm_plot:GetFeatureType() == FeatureTypes.FEATURE_FOREST)
			gto = Map.Rand(4, "Skeeper Dynamic Map F3")
			if boolcheck or gto == 0 then
				for j, direction in ipairs(direction_types) do
					cvm_plot = Map.PlotDirection(cvm_x, y, direction)
					boolcheck = (cvm_plot:GetFeatureType() == FeatureTypes.FEATURE_FOREST)
					if cvm_plot ~= nil and (not boolcheck) then
						gto = Map.Rand(10, "Skeeper Dynamic Map F3")
						if gto > 0 then			
							cvm_plot:SetTerrainType(terrainGrass, false, true);
							cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
						end
					end
				end				
			else
				cvm_plot:SetTerrainType(terrainGrass, false, true);
				cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
				for j, direction in ipairs(direction_types) do
					cvm_plot = Map.PlotDirection(cvm_x, y, direction)
					boolcheck = (cvm_plot:GetFeatureType() == FeatureTypes.FEATURE_FOREST)
					if cvm_plot ~= nil and (not boolcheck) then
						gto = Map.Rand(6, "Skeeper Dynamic Map F3")
						if gto > 1 then				
							cvm_plot:SetTerrainType(terrainGrass, false, true);
							cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
						end
					end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x-2, y)
			gto = Map.Rand(4, "Skeeper Dynamic Map F3")
			if gto > 0 then
				cvm_plot:SetTerrainType(terrainGrass, false, true);
				cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);				
			end
			
			cvm_plot = Map.GetPlot(cvm_x-3, y)
			gto = Map.Rand(4, "Skeeper Dynamic Map F3")
			if gto > 1 then
				cvm_plot:SetTerrainType(terrainGrass, false, true);
				cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);				
			end
		end
		
		cvm_x = 23;  -- RIGHT
		for y = 3, iH-1, 8 do
			cvm_plot = Map.GetPlot(cvm_x, y)
			boolcheck = (cvm_plot:GetFeatureType() == FeatureTypes.FEATURE_FOREST)
			gto = Map.Rand(4, "Skeeper Dynamic Map F3")
			if boolcheck or gto == 0 then
				for j, direction in ipairs(direction_types) do
					cvm_plot = Map.PlotDirection(cvm_x, y, direction)
					boolcheck = (cvm_plot:GetFeatureType() == FeatureTypes.FEATURE_FOREST)
					if cvm_plot ~= nil and (not boolcheck) then
						gto = Map.Rand(10, "Skeeper Dynamic Map F3")
						if gto > 0 then			
							cvm_plot:SetTerrainType(terrainGrass, false, true);
							cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
						end
					end
				end				
			else
				cvm_plot:SetTerrainType(terrainGrass, false, true);
				cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
				for j, direction in ipairs(direction_types) do
					cvm_plot = Map.PlotDirection(cvm_x, y, direction)
					boolcheck = (cvm_plot:GetFeatureType() == FeatureTypes.FEATURE_FOREST)
					if cvm_plot ~= nil and (not boolcheck) then
						gto = Map.Rand(6, "Skeeper Dynamic Map F3")
						if gto > 1 then				
							cvm_plot:SetTerrainType(terrainGrass, false, true);
							cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
						end
					end
				end
			end
			
			cvm_plot = Map.GetPlot(cvm_x+2, y)
			gto = Map.Rand(4, "Skeeper Dynamic Map F3")
			if gto > 0 then
				cvm_plot:SetTerrainType(terrainGrass, false, true);
				cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);				
			end
			
			cvm_plot = Map.GetPlot(cvm_x+3, y)
			gto = Map.Rand(4, "Skeeper Dynamic Map F3")
			if gto > 1 then
				cvm_plot:SetTerrainType(terrainGrass, false, true);
				cvm_plot:SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);				
			end
		end
	else -- STATIC
		for y = 3, iH-1, 8 do
			Map.GetPlot(cvm_x, y):SetTerrainType(terrainGrass, false, true);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHEAST):SetTerrainType(terrainGrass, false, true);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHEAST):SetTerrainType(terrainGrass, false, true);
			
			Map.GetPlot(cvm_x, y):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_WEST):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHEAST):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHEAST):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
			Map.GetPlot(cvm_x-2, y):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
		end	
		cvm_x = 23;
		for y = 3, iH-1, 8 do
			Map.GetPlot(cvm_x, y):SetTerrainType(terrainGrass, false, true);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHWEST):SetTerrainType(terrainGrass, false, true);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHWEST):SetTerrainType(terrainGrass, false, true);
			
			Map.GetPlot(cvm_x, y):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_EAST):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_SOUTHWEST):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
			Map.PlotDirection(cvm_x, y, DirectionTypes.DIRECTION_NORTHWEST):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
			Map.GetPlot(cvm_x+2, y):SetFeatureType(FeatureTypes.FEATURE_MARSH, -1);
		end	
	end	
	
	
	-- DESESRT FLOOD PLAINS
	if g_GenTypeOption == 2 then -- DYNAMIC
		for i = 0, Map.GetNumPlots()-1, 1 do
			cvm_plot = Map.GetPlotByIndex(i);
			if (cvm_plot:CanHaveFeature(FeatureTypes.FEATURE_FLOOD_PLAINS)) then
				gto = Map.Rand(9, "Skeeper Dynamic Map F4")
				if gto > 0 then cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FLOOD_PLAINS, -1); end
			end
		end
	
	else -- STATIC
		for i = 0, Map.GetNumPlots()-1, 1 do
			cvm_plot = Map.GetPlotByIndex(i);
			if (cvm_plot:CanHaveFeature(FeatureTypes.FEATURE_FLOOD_PLAINS)) then
				cvm_plot:SetFeatureType(FeatureTypes.FEATURE_FLOOD_PLAINS, -1);
			end
		end
	end


	-- WILDNESS AND MIASMA
	local featuregen = FeatureGenerator.Create();
	if g_MiasmaOption == 1 then -- no miasma
	
	elseif g_MiasmaOption == 2 then -- miasma before wildness
		featuregen:AddMiasma();
	end
	
	for y = 0, iH - 1, 1 do -- After wildness-layer is generated miasma generation increasing in 5-7%
		for x = 0, iW - 1, 1 do
			local lat = featuregen:GetLatitudeAtPlot(x, y);
			cvm_plot = Map.GetPlot(x, y);
			featuregen:DetermineWildness(cvm_plot, x, y, lat);
		end
	end
	
	if g_MiasmaOption == 3 then -- miasma after wildness
		featuregen:AddMiasma();
	
	elseif g_MiasmaOption == 4 then -- miasma 90%
		for y = 0, iH - 1 do
			for x = 0, iW - 1 do
				local cvm_plot = Map.GetPlot(x, y)
				if (cvm_plot:IsWater() or cvm_plot:IsMountain()) then
				else
					local rand = Map.Rand(10, "Feature Gen - Miasma 90%")
					if rand > 0 then
						cvm_plot:SetMiasma(true);
					end
				end
			end
		end
	
	elseif g_MiasmaOption == 5 then -- miasma all over
		for y = 0, iH - 1 do
			for x = 0, iW - 1 do
				local cvm_plot = Map.GetPlot(x, y)
				if (cvm_plot:IsWater() or cvm_plot:IsMountain()) then
				else
					cvm_plot:SetMiasma(true);
				end
			end
		end
	end


end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ExcludedTiles()
	print("ExcludedTiles (AC_Skeeper_Tail.lua)");
	-- dbg print out
	local _dpo = true;
	_dpo = false;
	
	local ExcludedTilesIndexes = {};
	local iW, iH = Map.GetGridSize();
	local sizekey = Map.GetWorldSize();
	local cvm_plot, cvm_x, gto, cvm_plot2, cvm_plot3, boolcheck
	
	local terrainGrass = GameInfo.Terrains.TERRAIN_GRASS.ID;
	local terrainPlains = GameInfo.Terrains.TERRAIN_PLAINS.ID;
	local terrainDesert = GameInfo.Terrains.TERRAIN_DESERT.ID;
	local terrainTundra = GameInfo.Terrains.TERRAIN_TUNDRA.ID;
	local terrainSnow = GameInfo.Terrains.TERRAIN_SNOW.ID;
	
	for y = 0, iH - 1, 1 do 
		for x = 0, iW - 1, 1 do
			cvm_plot = Map.GetPlot(x, y);
			local terrainType = cvm_plot:GetTerrainType();
			if terrainType == terrainTundra or terrainType == terrainSnow then
				local cvm_index = cvm_plot:GetPlotIndex()
				table.insert(ExcludedTilesIndexes, cvm_index);
				if _dpo then print("ExcludedTilesIndexes "..tostring(table.getn(ExcludedTilesIndexes))..". "..tostring(x)..", "..tostring(y)..", "..tostring(cvm_index)); end
			end
		end
	end	
	
	if table.getn(ExcludedTilesIndexes) > 0 then
		return ExcludedTilesIndexes
	else
		return false;
	end
	
	return false;

end
-------------------------------------------------------------------------------
function StartingLocations()
	print("StartingLocations (AC_Skeeper_Tail.lua)");
	
	local FixedStartingsStraight = { 
	-- player1  = Map.GetPlot(5, 11):GetPlotIndex(),
	-- player2  = Map.GetPlot(28,11):GetPlotIndex(),
	-- player3  = Map.GetPlot(5, 19):GetPlotIndex(),
	-- player4	 = Map.GetPlot(28,19):GetPlotIndex(),
	-- player5  = Map.GetPlot(5,  3):GetPlotIndex(),
	-- player6  = Map.GetPlot(28, 3):GetPlotIndex(),
	-- player7  = Map.GetPlot(12,12):GetPlotIndex(),
	-- player8  = Map.GetPlot(22,12):GetPlotIndex(),
	-- player9  = Map.GetPlot(12,20):GetPlotIndex(),
	-- player10 = Map.GetPlot(22,20):GetPlotIndex(),
	-- player11 = Map.GetPlot(12, 4):GetPlotIndex(),
	-- player12 = Map.GetPlot(22, 4):GetPlotIndex(),
	};
	
	FixedStartingsStraight = { 
		Map.GetPlot(5, 11):GetPlotIndex(),	-- player1
		Map.GetPlot(28,11):GetPlotIndex(),	-- player2
		Map.GetPlot(5, 19):GetPlotIndex(),	-- player3
		Map.GetPlot(28,19):GetPlotIndex(),	-- player4
		Map.GetPlot(5,  3):GetPlotIndex(),	-- player5
		Map.GetPlot(28, 3):GetPlotIndex(),	-- player6
		Map.GetPlot(12,12):GetPlotIndex(),	-- player7
		Map.GetPlot(22,12):GetPlotIndex(),	-- player8
		Map.GetPlot(12,20):GetPlotIndex(),	-- player9
		Map.GetPlot(22,20):GetPlotIndex(),	-- player10
		Map.GetPlot(12, 4):GetPlotIndex(),	-- player11
		Map.GetPlot(22, 4):GetPlotIndex(),	-- player12
	};
	
	local FixedStartingsDiagonal = { 
		Map.GetPlot(5,  3):GetPlotIndex(),	-- player1
		Map.GetPlot(28,19):GetPlotIndex(),	-- player2
		Map.GetPlot(5, 19):GetPlotIndex(),	-- player3
		Map.GetPlot(28, 3):GetPlotIndex(),	-- player4
		Map.GetPlot(12,12):GetPlotIndex(),	-- player5
		Map.GetPlot(22,12):GetPlotIndex(),	-- player6
		Map.GetPlot(5, 11):GetPlotIndex(),	-- player7
		Map.GetPlot(28,11):GetPlotIndex(),	-- player8
		Map.GetPlot(12, 4):GetPlotIndex(),	-- player9
		Map.GetPlot(22,20):GetPlotIndex(),	-- player10
		Map.GetPlot(12,20):GetPlotIndex(),	-- player11
		Map.GetPlot(22, 4):GetPlotIndex(),	-- player12
	};
	
	local FixedStartingsRandom = GetShuffledCopyOfTable(FixedStartingsStraight);
	
	-- Straight, Diagonal, Shuffle, Usual Random
	
	if g_StartingsOption == 1 then
		return FixedStartingsStraight
	elseif g_StartingsOption == 2 then
		return FixedStartingsDiagonal
	elseif g_StartingsOption == 3 then
		return FixedStartingsRandom	
	elseif g_StartingsOption >= 4 then
		return false;
	end
	
	return false;

end
-------------------------------------------------------------------------------
-- FIFTH MAIN FUNC
function StartPlotSystem()
-- function StartPlotSystem1()
	print("StartPlotSystem Override (AC_Skeeper_Tail.lua)");
	
	print("Creating start plot database.");
	local start_plot_database = AssignStartingPlots.Create()
	
	print("Dividing the map in to Regions.");
	local m = 2; -- Continental
	if g_StartingsOption == 5 then
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
		excludeTiles = ExcludedTiles(),
		ignoreMiasmaToFertility = true,
		};
	start_plot_database:GenerateRegions(args)
	
	print("Choosing start locations for civilizations.");
	args = {
		mustBeInOrAdjacentToWater = false,
		mustBeInWater = false,
		ignoreWildness = true,
		startLocs = StartingLocations(),
		centerBias = 50, -- % of radius from region center to examine first
		middleBias = 80, -- % of radius from region center to check second
		minFoodInner = 1,
		minProdInner = 0,
		minGoodInner = 3,
		minFoodMiddle = 4,
		minProdMiddle = 0,
		minGoodMiddle = 6,
		minFoodOuter = 4,
		minProdOuter = 2,
		minGoodOuter = 8,
		maxJunk = 10,
		};
	start_plot_database:ChooseLocations(args)
	
	print("Normalizing start locations and assigning them to Players.");
	args = {
		-- startLocs = StartingLocations(),
		};
	start_plot_database:BalanceAndAssign(args)
	
	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()
	
	
end
-------------------------------------------------------------------------------
-- LANDMARKS -- MARVELS
-------------------------------------------------------------------------------
function getLandmarksOption()
	print("getLandmarksOption AC_Skeeper_Tail.lua");
	return g_LandmarksOption
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- RESOURCE PODS -- GOODIES
-------------------------------------------------------------------------------
-- function AddGoodies()	return; end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- EXCAVATIONS -- RESOURCES
-------------------------------------------------------------------------------
-- SIXTH MAIN FUNC
function AddArtifacts1()
	print("-------------------------------");
	print("Adding Artifacts AC_Skeeper_Tail.lua");
	return
	-- local trt = {
	-- GameInfo.Resources.RESOURCE_AN_ELEMENTAL_FATE_CAVE.ID,	
	-- GameInfo.Resources.RESOURCE_CULTURAL_BURDEN_QUEST_CRASH_SITE.ID,	
	-- GameInfo.Resources.RESOURCE_WRITTEN_IN_STONE_QUEST_RUINS.ID,	
	-- GameInfo.Resources.RESOURCE_BEAUTY_IN_THE_EYE_OF_THE_ORBITER_GLYPH_01.ID,	
	-- GameInfo.Resources.RESOURCE_BEAUTY_IN_THE_EYE_OF_THE_ORBITER_GLYPH_02.ID,	
	-- GameInfo.Resources.RESOURCE_BEAUTY_IN_THE_EYE_OF_THE_ORBITER_GLYPH_03.ID,	
	-- GameInfo.Resources.RESOURCE_BEAUTY_IN_THE_EYE_OF_THE_ORBITER_TECH_ARCHIVE.ID,	
	-- GameInfo.Resources.RESOURCE_SOLID_STATE_CITIZEN_CRASHED_POD.ID,	
	-- };
	
	-- for i = 13, 6, -1 do
		-- local plot = Map.GetPlot(i, i);
		-- plot:SetResourceType(trt[i-5], 1);
	-- end	
	
	-- return;

end
------------------------------------------------------------------------------