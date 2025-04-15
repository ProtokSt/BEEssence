-- ===========================================================================
---- VERSION: Migugh modified 2025-02-10
-- ===========================================================================
------------------------------------------------------------------------------
--	FILE:	 _Bigland.lua
--  VERSION: 1.1.0
--	AUTHOR:  Migugh
--	PURPOSE: Simulates a planet that have only some small seas areas - Optimized for 1v1 or two-teams multiplayer
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

include("MapGenerator");
include("FractalWorld");
include("FeatureGenerator");
include("TerrainGenerator");
include("RiverGenerator");
include("MultilayeredFractal");
include("MapmakerUtilities");

------------------------------------------------------------------------------
function GetMapScriptInfo()
	--local world_age, temperature, rainfall, sea_level, resources = GetCoreMapOptions();
	local world_age, temperature, rainfall, sea_level, resources, miasma_spawn, planet_landmarks = GetCoreMapOptions()

	return {
		Name = "TXT_KEY_MAP_BIGLAND_NAME", --MGH: Bigland
		Type = "TXT_KEY_MAP_BIGLAND_TYPE", --MGH
		Description = "TXT_KEY_MAP_BIGLAND_HELP", --MGH
		IconAtlas = "WORLDTYPE_ATLAS",
		IconIndex = 14, --MGH
		--CustomOptions = {world_age, temperature, rainfall, sea_level, resources},
		--CustomOptions = {sea_level, resources, teams_settings},
		
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
				DefaultValue = 2,
				SortPriority = 2,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_RESOURCES",
				Values = { -- Only one option here, but this will let all users know that resources are not set at default.
					"TXT_KEY_MAP_OPTION_BALANCED_RESOURCES",
				},
				DefaultValue = 1,
				SortPriority = 3,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_STARTINGS",
				Description = "TXT_KEY_MAP_OPTION_STARTINGS_HELP",
				Values = { -- MGH: Team 2vs2 support
					{"TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_USUAL", "TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_USUAL_HELP"},
					{"TXT_KEY_MAP_OPTION_STARTINGS_TEAMS_WE", "TXT_KEY_MAP_OPTION_STARTINGS_TEAMS_WE_HELP"},
				},
				DefaultValue = 1,
				SortPriority = 4,
			},
			miasma_spawn,
			planet_landmarks,
		},

	};
	
end
------------------------------------------------------------------------------

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
	g_MiasmaOption 			  = Map.GetCustomOption(6) -- GLOBAL variable.
	g_LandmarksOption 		  = Map.GetCustomOption(7) -- GLOBAL variable.
	
	local worldsizes = {
		-- Sizes for worlds without oceans:
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {28, 18},
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {36, 22},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {46, 28},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {60, 36},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {72, 44},
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {84, 52}
		-- Sizes for worlds with oceans:
 		-- [GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {34, 24},
 		-- [GameInfo.Worlds.WORLDSIZE_TINY.ID] = {42, 30},
		-- [GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {54, 38},
		-- [GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {68, 48},
		-- [GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {86, 60},
		-- [GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {108, 76}
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
------------------------------------------------------------------------------
function MultilayeredFractal:GeneratePlotsByRegion()
	-- Sirian's MultilayeredFractal controlling function.
	-- You -MUST- customize this function for each script using MultilayeredFractal.
	-- This implementation is specific to Seven continents.
	
	local iW, iH = Map.GetGridSize();
	local fracFlags = Map.GetFractalFlags();--Fractal settings for the map
	-- Initiate plot table, fill all data slots with type PLOT_OCEAN
	table.fill(self.wholeworldPlotTypes, PlotTypes.PLOT_OCEAN, iW * iH);

	-- Mountain density.
	local lakes_grain = 3;
	local lakesFrac = Fractal.Create(iW, iH, lakes_grain, fracFlags, -1, -1);
	local iLakesThreshold = lakesFrac:GetHeight(80);
	for y = 1, iH - 2 do --Altura (excepto las líneas de hielo)
		for x = 0, iW - 1 do --Ancho
			local i = y * iW + x + 1; -- add one because Lua arrays start at 1
			local lakeVal = lakesFrac:GetHeight(x, y);
			if lakeVal >= iLakesThreshold then
				self.wholeworldPlotTypes[i] = PlotTypes.PLOT_MOUNTAIN;--PLOT_OCEAN
			end
		end
	end

	-- Apply hills.
	local hills_grain = 5;
	local terrainFrac = Fractal.Create(iW, iH, hills_grain, fracFlags, -1, -1);
	local iHillsThreshold = terrainFrac:GetHeight(70);
	local iPeaksThreshold = terrainFrac:GetHeight(95);
	local iHillsClumps = terrainFrac:GetHeight(10);
	local hillsFrac = Fractal.Create(iW, iH, hills_grain, fracFlags, -1, -1);
	local iHillsBottom1 = hillsFrac:GetHeight(20);
	local iHillsTop1 = hillsFrac:GetHeight(30);
	local iHillsBottom2 = hillsFrac:GetHeight(70);
	local iHillsTop2 = hillsFrac:GetHeight(80);
	for x = 0, iW - 1 do
		for y = 0, iH - 1 do
			local i = y * iW + x + 1; -- add one because Lua arrays start at 1
			local terrainVal = terrainFrac:GetHeight(x, y);
			if terrainVal >= iPeaksThreshold then
				self.wholeworldPlotTypes[i] = PlotTypes.PLOT_CANYON;
			elseif terrainVal >= iHillsThreshold or terrainVal <= iHillsClumps then
				self.wholeworldPlotTypes[i] = PlotTypes.PLOT_HILLS;
			else
				local hillsVal = hillsFrac:GetHeight(x, y);
				if hillsVal >= iHillsBottom1 and hillsVal <= iHillsTop1 then
					self.wholeworldPlotTypes[i] = PlotTypes.PLOT_LAND;
				elseif hillsVal >= iHillsBottom2 and hillsVal <= iHillsTop2 then
					self.wholeworldPlotTypes[i] = PlotTypes.PLOT_LAND;
				end
			end
		end
	end

	-- Plot Type generation completed. Return global plot array.
	return self.wholeworldPlotTypes
end
------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Setting Plot Types (Lua _Bigland) ...");
	
	local userInputSeaLevelSetting = g_SEALEVEL_Option; --Map.GetCustomOption(2); -- USER CHOICE variable.
	if userInputSeaLevelSetting == 4 then
		userInputSeaLevelSetting = 1 + Map.Rand(3, "Random Sea Level - Lua");
	end
	print("userInputSeaLevelSetting: " .. userInputSeaLevelSetting);

	local layered_world = MultilayeredFractal.Create();
	local plotsBigland = layered_world:GeneratePlotsByRegion();
	SetPlotTypes(plotsBigland);

	-- Examine all plots in buffer zone.
	local iW, iH = Map.GetGridSize();
	local firstRingYIsEven = {{0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}};
	local firstRingYIsOdd = {{1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}};
	
	--Put water poles and borders
	for x = 0, iW - 1 do
		for y = 0, 2 do
			local plot = Map.GetPlot(x, y);
			plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false);
		end
	end
	for x = 0, iW - 1 do
		for y = iH - 1, iH - 3, -1 do
			local plot = Map.GetPlot(x, y);
			plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false);
		end
	end
	for x = 0, 1 do
		for y = 0, iH - 1 do
			local plot = Map.GetPlot(x, y);
			plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false);
		end
	end
	for x = iW - 1, iW - 2, -1 do
		for y = 0, iH - 1 do
			local plot = Map.GetPlot(x, y);
			plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false);
		end
	end
	
	--Clean poles and borders
	for x = 0, iW - 1 do
		for y = 3, 4 do
			local plot = Map.GetPlot(x, y);
			if plot:GetPlotType() == PlotTypes.PLOT_CANYON then
				plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
			elseif plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN then
				plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
			end
		end
	end
	for x = 0, iW - 1 do
		for y = iH - 4, iH - 5, -1 do
			local plot = Map.GetPlot(x, y);
			if plot:GetPlotType() == PlotTypes.PLOT_CANYON then
				plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
			elseif plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN then
				plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
			end
		end
	end
	for x = 3, 4 do
		for y = 0, iH - 1 do
			local plot = Map.GetPlot(x, y);
			if plot:GetPlotType() == PlotTypes.PLOT_CANYON then
				plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
			elseif plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN then
				plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
			end
		end
	end
	for x = iW - 5, iW - 6, -1 do
		for y = 0, iH - 1 do
			local plot = Map.GetPlot(x, y);
			if plot:GetPlotType() == PlotTypes.PLOT_CANYON then
				plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
			elseif plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN then
				plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
			end
		end
	end
	
	-- Check Mountain and change some into canyon.
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN then
				local diceroll = Map.Rand(5, "Random Change into hill - Lua"); -- 20% chance turn into canyon.
				if diceroll == 1 then
					plot:SetPlotType(PlotTypes.PLOT_CANYON, false, false);
				end
			end
		end
	end
	
	--Remove random tube land
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
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
							local diceroll = Map.Rand(2, "Random changed - Lua"); -- 50% chance change.
							if diceroll == 1 then
								plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false);
							end
							break;
						end
					end
				end
			end
		end
	end
	
	if userInputSeaLevelSetting == 3 then --HIGH Sea Level
		--Remove random tube water, at the beginning (later remove again)
		for x = 1, iW - 2 do
			for y = 1, iH - 2 do
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
							if num_findings == 4 then
								local diceroll = Map.Rand(2, "Random changed - Lua"); -- 50% chance change.
								if diceroll == 1 then
									plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
								end
								break;
							end
						end
					end
				end
			end
		end
	end
	
	--Random mountains, hills and land on the poles
	if userInputSeaLevelSetting < 3 then --LOW & MEDIUM Sea Level
		for cont_deep = 0, (4 - userInputSeaLevelSetting) do
			for cont = 2, 6 - cont_deep do
				--pole up
				for x = 0, iW - 1 do
					for y = 2 + cont, 0, -1 do
						local plot = Map.GetPlot(x, y)
						if plot:GetPlotType() == PlotTypes.PLOT_OCEAN then
							local diceroll = Map.Rand(5, "Random Land or Hills on ocean - Lua"); -- 40% chance turn this ocean into land, 20% hills.
							if diceroll <= 2 then
								plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
							elseif diceroll == 3 then
								plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
							end
						elseif plot:GetPlotType() == PlotTypes.PLOT_LAND then
							local diceroll = Map.Rand(10, "Random Hills on coast - Lua"); -- 10% chance turn this ocean into hills.
							if diceroll == 1 then
								plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
							end
						elseif plot:GetPlotType() == PlotTypes.PLOT_HILLS then
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
								if searchX >= 0 and searchX <= iW - 1 and searchY >= 0 and searchY <= iH - 1 then --check
									local searchPlot = Map.GetPlot(searchX, searchY)
									local plotType = searchPlot:GetPlotType()
									if plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS then
										num_findings = num_findings + 1;
									elseif plotType == PlotTypes.PLOT_MOUNTAIN then
										num_findings = num_findings + 2;
									end
									if num_findings == 6 then
										local diceroll = Map.Rand(12, "Random Land on coast - Lua"); -- 8.33% chance turn this hill into mountain.
										if diceroll == 1 then
											plot:SetPlotType(PlotTypes.PLOT_MOUNTAIN, false, false)
										end
										break;
									end
								end
							end
						end
					end
				end
				--pole down
				for x = 0, iW - 1 do
					for y = iH - 3 - cont, iH - 1 do
						local plot = Map.GetPlot(x, y)
						if plot:GetPlotType() == PlotTypes.PLOT_OCEAN then
							local diceroll = Map.Rand(5, "Random Land or Hills on ocean - Lua"); -- 40% chance turn this ocean into land, 20% hills.
							if diceroll <= 2 then
								plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
							elseif diceroll == 3 then
								plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
							end
						elseif plot:GetPlotType() == PlotTypes.PLOT_LAND then
							local diceroll = Map.Rand(10, "Random Hills on coast - Lua"); -- 10% chance turn this ocean into hills.
							if diceroll == 1 then
								plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
							end
						elseif plot:GetPlotType() == PlotTypes.PLOT_HILLS then
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
								if searchX >= 0 and searchX <= iW - 1 and searchY >= 0 and searchY <= iH - 1 then --check
									local searchPlot = Map.GetPlot(searchX, searchY)
									local plotType = searchPlot:GetPlotType()
									if plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS then
										num_findings = num_findings + 1;
									elseif plotType == PlotTypes.PLOT_MOUNTAIN then
										num_findings = num_findings + 2;
									end
									if num_findings == 6 then
										local diceroll = Map.Rand(12, "Random Land on coast - Lua"); -- 8.33% chance turn this hill into mountain.
										if diceroll == 1 then
											plot:SetPlotType(PlotTypes.PLOT_MOUNTAIN, false, false)
										end
										break;
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	--Remove golf water
	for x = iW - 2, 1, -1 do
		for y = iH - 2, 1, -1 do
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
					if plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS or plotType == PlotTypes.PLOT_MOUNTAIN then
						num_findings = num_findings + 1;
						if num_findings == 5 then
							local diceroll = Map.Rand(3, "Random changed - Lua"); -- 33% chance change.
							if diceroll == 1 then
								plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
							end
							break;
						end
					end
				end
			end
		end
	end
	
	--Remove out land
	for x = iW - 2, 1, -1 do
		for y = iH - 2, 1, -1 do
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
						if num_findings == 3 then
							local diceroll = Map.Rand(3, "Random changed - Lua"); -- 33% chance change.
							if diceroll == 1 then
								plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false);
							end
							break;
						end
					end
				end
			end
		end
	end
	
	--Remove out land with mountains
	for x = iW - 2, 1, -1 do
		for y = iH - 2, 1, -1 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_HILLS or plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN then
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
						if num_findings == 2 then
							local diceroll = Map.Rand(3, "Random changed - Lua"); -- 66% chance change.
							if diceroll ~= 1 then
								plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false);
							end
							break;
						end
					end
				end
			end
		end
	end
	
	--randomly remove some canyons near mountains
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_CANYON then
				local isEvenY, search_table = true, {};
				if y / 2 > math.floor(y / 2) then
					isEvenY = false;
				end
				if isEvenY then
					search_table = firstRingYIsEven;
				else
					search_table = firstRingYIsOdd;
				end
				for loop, plot_adjustments in ipairs(search_table) do
					local searchX, searchY;
					searchX = x + plot_adjustments[1];
					searchY = y + plot_adjustments[2];
					local searchPlot = Map.GetPlot(searchX, searchY);
					local plotType = searchPlot:GetPlotType();
					if plotType == PlotTypes.PLOT_MOUNTAIN then
						local diceroll = Map.Rand(5, "Random Change into hill - Lua"); -- 80% chance turn into hill.
						if diceroll ~= 1 then
							plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
						end
						break
					end
				end
			end
		end
	end
	
	--Remove out land with alone mountains
	for x = iW - 2, 1, -1 do
		for y = iH - 2, 1, -1 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN then
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
					if plotType ~= PlotTypes.PLOT_MOUNTAIN then
						num_findings = num_findings + 1;
						if num_findings == 6 then
							local diceroll = Map.Rand(2, "Random changed - Lua"); -- 50% chance change.
							if diceroll == 1 then
								plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
							end
							break;
						end
					end
				end
			end
		end
	end
	
	--First check (water near a mountain change to hill o land)
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
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
				for loop, plot_adjustments in ipairs(search_table) do
					local searchX, searchY;
					searchX = x + plot_adjustments[1];
					searchY = y + plot_adjustments[2];
					local searchPlot = Map.GetPlot(searchX, searchY);
					local plotType = searchPlot:GetPlotType();
					if plotType == PlotTypes.PLOT_MOUNTAIN then
						local diceroll = Map.Rand(5, "Random Change into hill - Lua"); -- 20% chance turn into hill.
						if diceroll == 1 then
							plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
						else
							plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
						end
						break
					end
				end
			end
		end
	end
	
	--Second check (Too many mountains change to canyon)
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN then
				local isEvenY, search_table = true, {};
				if y / 2 > math.floor(y / 2) then
					isEvenY = false;
				end
				if isEvenY then
					search_table = firstRingYIsEven;
				else
					search_table = firstRingYIsOdd;
				end
				for loop, plot_adjustments in ipairs(search_table) do
					local searchX, searchY;
					searchX = x + plot_adjustments[1];
					searchY = y + plot_adjustments[2];
					local searchPlot = Map.GetPlot(searchX, searchY);
					local plotType = searchPlot:GetPlotType();
					if plotType == PlotTypes.PLOT_MOUNTAIN then
						local diceroll = Map.Rand(5, "Random Change into canyon - Lua"); -- 80% chance turn into canyon.
						if diceroll > 1 then
							plot:SetPlotType(PlotTypes.PLOT_CANYON, false, false);
						end
						break
					end
				end
			end
		end
	end
	
	--Third check (No coast near mountains or canyon)
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
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
				for loop, plot_adjustments in ipairs(search_table) do
					local searchX, searchY;
					searchX = x + plot_adjustments[1];
					searchY = y + plot_adjustments[2];
					local searchPlot = Map.GetPlot(searchX, searchY)
					local plotType = searchPlot:GetPlotType()
					if plotType == PlotTypes.PLOT_MOUNTAIN or plotType == PlotTypes.PLOT_CANYON then
						local diceroll = Map.Rand(5, "Random Land on coast - Lua"); -- 20% chance turn this mountain into land, 80% hills.
						if diceroll == 1 then
							plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
						else
							plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
						end
						break
					end
				end
			end
		end
	end
	
	--Add some random mountains near land
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
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
				for loop, plot_adjustments in ipairs(search_table) do
					local searchX, searchY;
					searchX = x + plot_adjustments[1];
					searchY = y + plot_adjustments[2];
					local searchPlot = Map.GetPlot(searchX, searchY)
					local plotType = searchPlot:GetPlotType()
					if plotType == PlotTypes.PLOT_LAND then
						local diceroll = Map.Rand(10, "Random Land on coast - Lua"); -- 10% chance turn this in a mountain.
						if diceroll == 1 then
							plot:SetPlotType(PlotTypes.PLOT_MOUNTAIN, false, false);
						end
						break
					end
				end
			end
		end
	end
	
	--Remove some water near coast
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
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
						if num_findings == 3 then
							local diceroll = Map.Rand(5, "Random water removed - Lua"); -- 20% chance turn this water into land.
							if diceroll == 1 then
								plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
							end
							break;
						end
					end
				end
			end
		end
	end
	
	--No mountains or canyon near coast
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_MOUNTAIN or plot:GetPlotType() == PlotTypes.PLOT_CANYON then
				local isEvenY, search_table = true, {};
				if y / 2 > math.floor(y / 2) then
					isEvenY = false;
				end
				if isEvenY then
					search_table = firstRingYIsEven;
				else
					search_table = firstRingYIsOdd;
				end
				for loop, plot_adjustments in ipairs(search_table) do
					local searchX, searchY;
					searchX = x + plot_adjustments[1];
					searchY = y + plot_adjustments[2];
					local searchPlot = Map.GetPlot(searchX, searchY)
					local plotType = searchPlot:GetPlotType()
					if plotType == PlotTypes.PLOT_OCEAN then
						local diceroll = Map.Rand(5, "Random Land on coast - Lua"); -- 20% chance turn this mountain into land, 80% hills.
						if diceroll == 1 then
							plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
						else
							plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
						end
						break
					end
				end
			end
		end
	end
	
	--remove 3 canyons together
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
			local plot = Map.GetPlot(x, y)
			if plot:GetPlotType() == PlotTypes.PLOT_CANYON then
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
					if plot:GetPlotType() == PlotTypes.PLOT_CANYON then
						num_findings = num_findings + 1;
						if num_findings == 3 then
							plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
							break;
						end
					end
				end
			end
		end
	end
	
	--Quit water area poles
	if userInputSeaLevelSetting < 3 then --LOW & MEDIUM Sea Level
		for cont_deep = 0, 3 do
			for cont = 2, 5 - cont_deep do
				for x = 0, iW - 1 do
					for y = 2 + cont, 0, -1 do
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
								if searchX >= 0 and searchX <= iW - 1 and searchY >= 0 and searchY <= iH - 1 then --check
									local searchPlot = Map.GetPlot(searchX, searchY)
									local plotType = searchPlot:GetPlotType()
									if plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS then
										num_findings = num_findings + 1;
										if num_findings == cont then
											local diceroll = Map.Rand(10, "Random Land or Hills - Lua"); -- 10% chance turn this ocean into land, 10% hills.
											if diceroll == 1 then
												plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
											elseif diceroll == 2 then
												plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
											end
											break;
										end
									end
								end
							end
						end
					end
				end
				for x = 0, iW - 1 do
					for y = iH - 3 - cont, iH - 1 do
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
								if searchX >= 0 and searchX <= iW - 1 and searchY >= 0 and searchY <= iH - 1 then --check
									local searchPlot = Map.GetPlot(searchX, searchY)
									local plotType = searchPlot:GetPlotType()
									if plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS then
										num_findings = num_findings + 1;
										if num_findings == cont then
											local diceroll = Map.Rand(10, "Random Land or Hills - Lua"); -- 10% chance turn this ocean into land, 10% hills.
											if diceroll == 1 then
												plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
											elseif diceroll == 2 then
												plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
											end
											break;
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	--More land area
	if userInputSeaLevelSetting == 1 then --LOW Sea Level
		for x = iW - 1, 0 , -1 do
			for y = iH - 1, 0 , -1 do
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
						if searchX >= 0 and searchX <= iW - 1 and searchY >= 0 and searchY <= iH - 1 then --check
							local searchPlot = Map.GetPlot(searchX, searchY)
							local plotType = searchPlot:GetPlotType()
							if plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS then
								num_findings = num_findings + 1;
								if num_findings == 2 then
									local diceroll = Map.Rand(4, "Random Land on coast - Lua"); -- 25% chance turn this mountain into land, 25% hills.
									if diceroll == 1 then
										plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
									elseif diceroll == 2 then
										plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
									end
									break;
								end
							end
						end
					end
				end
			end
		end
	end
	
	--Remove all tube water
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
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
						if num_findings == 4 then
							plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
							break;
						end
					end
				end
			end
		end
	end
	for y = iH - 2, 1, -1 do
		for x = iW - 2, 1, -1 do
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
						if num_findings == 4 then
							plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
							break;
						end
					end
				end
			end
		end
	end
	
	--Remove some extreme golf water
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
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
	
	if userInputSeaLevelSetting == 1 then --LOW Sea Level
	    --Remove some random golf water
		for x = 1, iW - 2 do
			for y = 1, iH - 2 do
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
							if num_findings == 3 then
								local diceroll = Map.Rand(10, "Random Land on coast - Lua"); -- 10% chance turn this mountain into land, 10% hills.
								if diceroll == 1 then
									plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)
								elseif diceroll == 2 then
									plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
								end
								break;
							end
						end
					end
				end
			end
		end
	end
	
	--Add hills near mountain or canyon if the plot is water near them as exception
	for x = 1, iW - 2 do
		for y = 1, iH - 2 do
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
					if plotType == PlotTypes.PLOT_MOUNTAIN or plotType == PlotTypes.PLOT_CANYON then
						num_findings = num_findings + 1;
						if num_findings == 5 then
							plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
							break;
						end
					end
				end
			end
		end
	end
	
	GenerateCoasts();
end
------------------------------------------------------------------------------
function TerrainGenerator:GenerateTerrainAtPlot(iX,iY)
	local lat = self:GetLatitudeAtPlot(iX,iY);
	local terrainVal = self.terrainGrass;

	local plot = Map.GetPlot(iX, iY);
	-- Error handling.
	if (plot:IsWater()) then
		local val = plot:GetTerrainType();
		if val == TerrainTypes.NO_TERRAIN then
			val = self.terrainGrass;
			plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
		end
		return val;	 
	end
	
	-- Begin implementation of User Input for dominant terrain type
	-- Mostly Plains, but a smattering of grass or desert.
	local desertVal = self.deserts:GetHeight(iX, iY);
	local plainsVal = self.plains:GetHeight(iX, iY);
	if desertVal >= self.deserts:GetHeight(85) then
		terrainVal = self.terrainDesert;
		-- Set Desert Wild Area value.
		if not (plot:IsMountain() or plot:IsCanyon()) then
			if desertVal >= self.deserts:GetHeight(91) then
				plot:SetWildness(20);
			elseif desertVal >= self.deserts:GetHeight(85) then
				plot:SetWildness(21);
			end
		end
	elseif plainsVal <= self.plains:GetHeight(85) then
		terrainVal = self.terrainPlains;
	end
	
	-- Global (aka normal climate bands)
	if(lat >= self.fSnowLatitude) then
		terrainVal = self.terrainSnow;
	elseif(lat >= self.fTundraLatitude) then
		terrainVal = self.terrainTundra;
	elseif (lat < self.fGrassLatitude) then
		--terrainVal = self.terrainGrass;
	else
		local plainsVal = self.plains:GetHeight(iX, iY);
		if ((plainsVal >= self.iPlainsBottom) and (plainsVal <= self.iPlainsTop)) then
			terrainVal = self.terrainPlains;
		end
	end
	
	return terrainVal;
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain (Lua _Bigland) ...");
	
	local terraingen = TerrainGenerator.Create();

	local terrainTypes = terraingen:GenerateTerrain();
	
	SetTerrainTypes(terrainTypes);
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function RiverGenerator:GetRiverValueAtPlot(plot)
	-- Custom method to force rivers to flow away from the map center.
	local iW, iH = Map.GetGridSize()
	local x = plot:GetX()
	local y = plot:GetY()
	local random_factor = Map.Rand(3, "River direction random factor");
	local direction_influence_value = (math.abs(iW - (x - (iW / 2))) + ((math.abs(y - (iH / 2))) / 3)) * random_factor;

	local numPlots = PlotTypes.NUM_PLOT_TYPES;
	local sum = ((numPlots - plot:GetPlotType()) * 20) + direction_influence_value;

	local numDirections = DirectionTypes.NUM_DIRECTION_TYPES;
	for direction = 0, numDirections - 1 do
		local adjacentPlot = Map.PlotDirection(plot:GetX(), plot:GetY(), direction);
		if (adjacentPlot ~= nil) then
			sum = sum + (numPlots - adjacentPlot:GetPlotType());
		else
			sum = sum + (numPlots * 10);
		end
	end
	sum = sum + Map.Rand(10, "River Rand");

	return sum;
end
------------------------------------------------------------------------------
function RiverGenerator:GenerateLakes(args)
	-- No lakes added in this manner.
end
------------------------------------------------------------------------------
function RiverGenerator:GetCapsForMethodC()
	-- Set up caps for number of formations and plots based on world size.
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {2, 4, 2, 0},
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {3, 7, 2, 1},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {5, 12, 2, 2},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {6, 18, 2, 3},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {7, 28, 3, 3},
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {9, 42, 3, 4},
		};
	local caps_list = worldsizes[Map.GetWorldSize()];
	local max_lines, max_plots, base_length, extension_range = caps_list[1], caps_list[2], caps_list[3], caps_list[4];
	return max_lines, max_plots, base_length, extension_range;
end
----------------------------------------------------------------------------------
function RiverGenerator:MethodA()
	-- No canyons added in this manner.
end
------------------------------------------------------------------------------
function AddRivers()
	print("Generating Rivers. (Lua _Bigland) ...");

	local args = {};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end
------------------------------------------------------------------------------
function FeatureGenerator:__initFractals()
	local width = self.iGridW;
	local height = self.iGridH;
	self.terrainSnow	= GameInfoTypes["TERRAIN_SNOW"];
	self.terrainTundra	= GameInfoTypes["TERRAIN_TUNDRA"];
	
	-- Create fractals
	self.jungles		= Fractal.Create(width, height, self.jungle_grain, self.fractalFlags, self.fracXExp, self.fracYExp);
	self.forests		= Fractal.Create(width, height, self.forest_grain, self.fractalFlags, self.fracXExp, self.fracYExp);
	self.forestclumps	= Fractal.Create(width, height, self.clump_grain, self.fractalFlags, self.fracXExp, self.fracYExp);
	self.marsh			= Fractal.Create(width, height, 4, self.fractalFlags, self.fracXExp, self.fracYExp);
	self.repurpose		= Fractal.Create(width, height, 5, self.fractalFlags, self.fracXExp, self.fracYExp);
	self.miasma			= Fractal.Create(width, height, 7, self.fractalFlags, self.fracXExp, self.fracYExp);
	
	-- Get heights
	self.iJungleBottom	= self.jungles:GetHeight((100 - self.iJunglePercent)/2)
	self.iJungleTop		= self.jungles:GetHeight((100 + self.iJunglePercent)/2)
	self.iJungleRange	= (self.iJungleTop - self.iJungleBottom) * self.iJungleFactor;
	self.iForestLevel	= self.forests:GetHeight(80) -- 20% forest coverage
	self.iClumpLevel	= self.forestclumps:GetHeight(94) -- 6% forest clumps
	self.iMarshLevel	= self.marsh:GetHeight(100 - self.fMarshPercent)
	self.iBottom		= self.repurpose:GetHeight(25)
	self.iTop			= self.repurpose:GetHeight(50)
	
	self.iWildAreaLevel = self.forestclumps:GetHeight(self.iWildAreaHeight)
	self.iMiasmaBase	= self.miasma:GetHeight(100 - self.iMiasmaBasePercent)
	
	self.iClumpLevel	= self.forestclumps:GetHeight(90) -- 10% forest clumps
	self.iForestLevel	= self.forests:GetHeight(70) -- 30% forest coverage of what isn't covered by clumps.
end
------------------------------------------------------------------------------
function FeatureGenerator:AddIceAtPlot(plot, iX, iY, lat)
	-- Global, use default.
	if (plot:CanHaveFeature(self.featureIce)) then
		if Map.IsWrapX() and (iY == 0 or iY == self.iGridH - 1) then
			plot:SetFeatureType(self.featureIce, -1)
		else
			local rand = Map.Rand(100, "Add Ice Lua")/100.0;
			if(rand < 8 * (lat - 0.875)) then
				plot:SetFeatureType(self.featureIce, -1);
			end
		end
	end
end
------------------------------------------------------------------------------
function FeatureGenerator:AddJunglesAtPlot(plot, iX, iY, lat)
	-- Global, use default.
	local jungle_height = self.jungles:GetHeight(iX, iY);
	if jungle_height <= self.iJungleTop and jungle_height >= self.iJungleBottom + (self.iJungleRange * lat) then
		if(plot:CanHaveFeature(self.featureMarsh)) then
			local repurpose_height = self.repurpose:GetHeight(iX, iY);
			if repurpose_height > self.iTop then
				local plotType = plot:GetPlotType()
				if plotType ~= PlotTypes.PLOT_HILLS then
					plot:SetFeatureType(self.featureMarsh, -1);
				end
			elseif repurpose_height < self.iBottom then
				plot:SetFeatureType(self.featureForest, -1);
			else -- Leave this plot clear.
			end
		end
	end
end
------------------------------------------------------------------------------
function FeatureGenerator:DetermineWildness(plot, iX, iY, lat)
	-- Determine Wildness value for forest, tundra and ocean.
	-- Forest Clump fractal is used for these three types of Wild Areas. (Desert Wilds are determined using the Desert fractal in TerrainGenerator).
	local iWildVal = self.forestclumps:GetHeight(iX, iY)
	if not (plot:IsWater() or plot:IsMountain() or plot:IsCanyon()) then -- Land plot.
		local terrain_value = plot:GetTerrainType()

		if terrain_value == self.terrainTundra then -- Check for Tundra Wildness.
			if iWildVal >= self.iTundraCoreLevel then -- Tundra Wild Area, Core plot.
				plot:SetWildness(30)
				self.iNumCoreTundraWilds = self.iNumCoreTundraWilds + 1;
			elseif iWildVal >= self.iTundraPeripheryLevel then -- Tundra Wild Area, Periphery plot.
				plot:SetWildness(31)
				self.iNumPeripheryTundraWilds = self.iNumPeripheryTundraWilds + 1;
			end
		else
			-- Handle Forest Wildness.
			if iWildVal >= self.forestclumps:GetHeight(90) then -- Forest Wild Area, Core plot.
				plot:SetWildness(10) -- Forest wild area, Core plot.
				self.iNumCoreForestWilds = self.iNumCoreForestWilds + 1;
			elseif iWildVal >= self.forestclumps:GetHeight(83) then -- Forest Wild Area, Periphery plot.
				plot:SetWildness(11) -- Forest wild area, Periphery plot.
				self.iNumPeripheryForestWilds = self.iNumPeripheryForestWilds + 1;
			end
		end
	end
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features (Lua _Bigland) ...");

	local args = {
		miasmaSpawnWay = g_MiasmaOption,
	};
	local featuregen = FeatureGenerator.Create(args);

	featuregen:AddFeatures();
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
--MGH: No extra resources on hills for this map
function AssignStartingPlots:AddExtraBonusesToHillsRegions()
end
------------------------------------------------------------------------------
function getLandmarksOption() --PW
	print("getLandmarksOption customed by map");
	return g_LandmarksOption;
end