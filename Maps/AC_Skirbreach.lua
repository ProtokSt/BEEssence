-- ===========================================================================
---- 2023 - Blessed by Protok St
--	FILE:	 AC_Skirbreach.lua
--  VERSION: 1.14.4
--	AUTHOR:  Protok St, Migugh
--	PURPOSE: Restoring Skirmish map - Optimized for 1v1 or two-teams multiplayer.
--	BREACH:  Breach Landscape version made by Migugh, convert to option by Protok
-- ===========================================================================
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------
-- print("AC_Skirmish.lua Start ---------------------------------------- ") -- dbg

-- acdlc
include("MapGenerator");
include("FractalWorld");
include("FeatureGenerator");
include("TerrainGenerator");
include("RiverGenerator");
include("MultilayeredFractal");
include("MapmakerUtilities");	-- exp1
local _dpo = true;
-- _dpo = false;
------------------------------------------------------------------------------
function GetMapScriptInfo()
	 print("GetMapScriptInfo Start AC_Skirmish ---- ") -- dbg
	local world_age, temperature, rainfall, sea_level, resources, miasma_spawn, planet_landmarks = GetCoreMapOptions()
	return {
		Name = "TXT_KEY_MAP_ACDLC_SKIRMISH_NAME",
		Type = "TXT_KEY_MAP_ACDLC_SKIRMISH_TYPE",
		Description = "TXT_KEY_MAP_ACDLC_SKIRMISH_HELP",
		IconAtlas = "WORLDTYPE_ATLAS",
		IconIndex = 19,
		--CustomOptions = {world_age, temperature, rainfall, sea_level, resources},

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
				Name = "TXT_KEY_MAP_OPTION_WATER_SETTING",
				Values = {
					{"TXT_KEY_MAP_OPTION_RIVERS", "TXT_KEY_MAP_OPTION_RIVERS_HELP"},
					{"TXT_KEY_MAP_OPTION_SMALL_LAKES", "TXT_KEY_MAP_OPTION_SMALL_LAKES_HELP"},
					{"TXT_KEY_MAP_OPTION_SEAS", "TXT_KEY_MAP_OPTION_SEAS_HELP"},
					{"TXT_KEY_MAP_OPTION_RIVERS_AND_SEAS", "TXT_KEY_MAP_OPTION_RIVERS_AND_SEAS_HELP"},
					{"TXT_KEY_MAP_OPTION_DRY", "TXT_KEY_MAP_OPTION_DRY_HELP"},
					"TXT_KEY_MAP_OPTION_RANDOM",
				},
				DefaultValue = 1,
				SortPriority = 2,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_RESOURCES",
				Description = "TXT_KEY_MAP_OPTION_RESOURCES_HELP",
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
				DefaultValue = 8,
				SortPriority = 3,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_STARTINGS",
				Description = "TXT_KEY_MAP_OPTION_STARTINGS_HELP",
				Values = {
					{"TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_USUAL", "TXT_KEY_MAP_OPTION_SKPRTL_STARTINGS_USUAL_HELP"},
					{"TXT_KEY_MAP_OPTION_STARTINGS_TEAMS_WE", "TXT_KEY_MAP_OPTION_STARTINGS_TEAMS_WE_HELP"},
				},
				DefaultValue = 2,
				SortPriority = 10,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_LANDSCAPE_TYPE",
				Description = "TXT_KEY_MAP_OPTION_LANDSCAPE_TYPE_HELP",
				Values = {
					{"TXT_KEY_MAP_OPTION_SKIRMISH_TYPE_1", "TXT_KEY_MAP_OPTION_SKIRMISH_TYPE_1_HELP"},
					{"TXT_KEY_MAP_OPTION_SKIRMISH_TYPE_2", "TXT_KEY_MAP_OPTION_SKIRMISH_TYPE_2_HELP"},
				},
				DefaultValue = 2,
				SortPriority = 20,
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
	g_WATER_Option 			  = Map.GetCustomOption(2) -- GLOBAL variable.
	g_ResourcesOption 		  = Map.GetCustomOption(3) -- GLOBAL variable.
	g_StartingsOption 		  = Map.GetCustomOption(4) -- GLOBAL variable.
	g_LandscapeOption 		  = Map.GetCustomOption(5) -- GLOBAL variable.
	g_MiasmaOption 			  = Map.GetCustomOption(6) -- GLOBAL variable.
	g_LandmarksOption 		  = Map.GetCustomOption(7) -- GLOBAL variable.

	-- Skirmish is a world without oceans, so use grid sizes two levels below normal.
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {28, 18},
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {36, 22},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {46, 28},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {60, 36},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {72, 44},
		[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {84, 52}
		}
	local grid_size = worldsizes[worldSize];
	--
	local world = GameInfo.Worlds[worldSize];
	if(world ~= nil) then
	return {
		Width = grid_size[1],
		Height = grid_size[2],
		WrapX = false,
	};      
    end
end
------------------------------------------------------------------------------
function MultilayeredFractal:GeneratePlotsByRegion()
	local _dpo = true;
	-- _dpo = false;
	if _dpo then print("MultilayeredFractal:GeneratePlotsByRegion Start AC_Skirmish---- ") end
	-- Sirian's MultilayeredFractal controlling function.
	-- You -MUST- customize this function for each script using MultilayeredFractal.
	--
	-- This implementation is specific to Skirmish.
	local iW, iH = Map.GetGridSize();
	local fracFlags = {FRAC_WRAP_X = true, FRAC_POLAR = true};
	self.wholeworldPlotTypes = table.fill(PlotTypes.PLOT_LAND, iW * iH);

	-- Get user inputs.
	dominant_terrain = g_DOMINANT_TERRAIN_Option -- GLOBAL variable.
	if dominant_terrain == 9 then -- Random
		dominant_terrain = 1 + Map.Rand(8, "Random Type of Dominant Terrain - Skirmish LUA");
	end
	userInputWaterSetting = g_WATER_Option -- GLOBAL variable.
	if userInputWaterSetting == 6 then -- Random
		userInputWaterSetting = 1 + Map.Rand(5, "Random Water Setting - Skirmish LUA");
	end

	-- Lake density: applies only to Small Lakes and Seas settings.
	if userInputWaterSetting >= 2 and userInputWaterSetting <= 4 then
		local lake_list = {0, 93, 85, 85};
		local lake_grains = {0, 5, 3, 3};
		local lakes = lake_list[userInputWaterSetting];
		local lake_grain = lake_grains[userInputWaterSetting];

		local lakesFrac = Fractal.Create(iW, iH, lake_grain, fracFlags, -1, -1);
		local iLakesThreshold = lakesFrac:GetHeight(lakes);

		for y = 1, iH - 2 do
			for x = 0, iW - 1 do
				local i = y * iW + x + 1; -- add one because Lua arrays start at 1
				local lakeVal = lakesFrac:GetHeight(x, y);
				if lakeVal >= iLakesThreshold then
					self.wholeworldPlotTypes[i] = PlotTypes.PLOT_OCEAN;
				end
			end
		end
	end

	-- Apply hills and mountains.
	if dominant_terrain == 7 then -- Hills dominate.
		local worldsizes = {
			[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = 4,
			[GameInfo.Worlds.WORLDSIZE_TINY.ID] = 4,
			[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = 5,
			[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = 5,
			[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = 5,
			[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = 5,
		}
		local grain = worldsizes[Map.GetWorldSize()];

		local terrainFrac = Fractal.Create(iW, iH, grain, fracFlags, -1, -1);
		local iHillsThreshold = terrainFrac:GetHeight(70);
		local iPeaksThreshold = terrainFrac:GetHeight(95);
		local iHillsClumps = terrainFrac:GetHeight(10);

		local hillsFrac = Fractal.Create(iW, iH, grain, fracFlags, -1, -1);
		local iHillsBottom1 = hillsFrac:GetHeight(20);
		local iHillsTop1 = hillsFrac:GetHeight(30);
		local iHillsBottom2 = hillsFrac:GetHeight(70);
		local iHillsTop2 = hillsFrac:GetHeight(80);
		if _dpo then print("\
iHillsThreshold = "..tostring(iHillsThreshold).."\
iPeaksThreshold = "..tostring(iPeaksThreshold).."\
iHillsClumps = "..tostring(iHillsClumps).."\
iHillsBottom1 = "..tostring(iHillsBottom1).."\
iHillsTop1 = "..tostring(iHillsTop1).."\
iHillsBottom2 = "..tostring(iHillsBottom2).."\
iHillsTop2 = "..tostring(iHillsTop2)); end

		for x = 0, iW - 1 do
			for y = 0, iH - 1 do
				local i = y * iW + x + 1;
				local val = terrainFrac:GetHeight(x, y);
				if _dpo then print("i = "..tostring(i)..", val = "..tostring(val)); end
				if val >= iPeaksThreshold then
					self.wholeworldPlotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
				elseif val >= iHillsThreshold or val <= iHillsClumps then
					self.wholeworldPlotTypes[i] = PlotTypes.PLOT_HILLS;
					if _dpo then print("hill1 "..x..", "..y); end
				else
					local hillsVal = hillsFrac:GetHeight(x, y);
					if hillsVal >= iHillsBottom1 and hillsVal <= iHillsTop1 then
						self.wholeworldPlotTypes[i] = PlotTypes.PLOT_HILLS;
						if _dpo then print("hill2 "..x..", "..y); end
					elseif hillsVal >= iHillsBottom2 and hillsVal <= iHillsTop2 then
						self.wholeworldPlotTypes[i] = PlotTypes.PLOT_HILLS;
							if _dpo then print("hill3 "..x..", "..y); end
					end
				end
			end
		end

	else -- Normal hills and mountains.
		local args = {
			adjust_plates = 1.2,
		};
		self:ApplyTectonics(args)
	end

	-- Create buffer zone in middle four columns. This will create some choke points.
	--
	if g_LandscapeOption == 2 then
		-- Turn all plots in buffer zone to ocean.
		for x = iW / 2 - 3, iW / 2 + 2 do
			for y = 0, iH - 1 do
				local i = y * iW + x + 1;
				self.wholeworldPlotTypes[i] = PlotTypes.PLOT_OCEAN;
			end
		end
		-- Add random smattering of hills to middle two columns of buffer zone.
		local west_half, east_half = {}, {};
		for loop = 1, iH - 2 do
			table.insert(west_half, loop);
			table.insert(east_half, loop);
		end
		local west_shuffled = GetShuffledCopyOfTable(west_half)
		local east_shuffled = GetShuffledCopyOfTable(east_half)
		local iNumMountainsPerColumn = math.max(math.floor(iH * 0.225), math.floor((iH / 4) - 1));
		local x_west, x_east = iW / 2 - 1, iW / 2;
		for loop = 1, iNumMountainsPerColumn do
			local y_west, y_east = west_shuffled[loop], east_shuffled[loop];
			local i_west_plot = y_west * iW + x_west + 1;
			local i_east_plot = y_east * iW + x_east + 1;
			self.wholeworldPlotTypes[i_west_plot] = PlotTypes.PLOT_HILLS;
			self.wholeworldPlotTypes[i_east_plot] = PlotTypes.PLOT_HILLS;
		end
		-- Add random ocean in left and right of buffer zone.
		for x = iW / 2 - 4, iW / 2 + 3 do
			for y = 1, iH - 2 do
				local i = y * iW + x + 1;
				local rand_ocean = 1 + Map.Rand(20, "Random Ocean - Lua");--15% land 45% water
				if rand_ocean <= 3 then
					self.wholeworldPlotTypes[i] = PlotTypes.PLOT_LAND;
				elseif rand_ocean <= 12 then
					self.wholeworldPlotTypes[i] = PlotTypes.PLOT_OCEAN;
				end
			end
		end

		-- Plot Type generation completed. Return global plot array.
		return self.wholeworldPlotTypes
	else
		-- Turn all plots in buffer zone to land.
		for x = iW / 2 - 2, iW / 2 + 1 do
			for y = 1, iH - 2 do
				local i = y * iW + x + 1;
				self.wholeworldPlotTypes[i] = PlotTypes.PLOT_LAND;
			end
		end
		-- Add mountains in top and bottom rows of buffer zone.
		for x = iW / 2 - 2, iW / 2 + 1 do
			local i = x + 1;
			self.wholeworldPlotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
			i = (iH - 1) * iW + x + 1;
			self.wholeworldPlotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
		end
		-- Add random smattering of mountains to middle two columns of buffer zone.
		local west_half, east_half = {}, {};
		for loop = 1, iH - 2 do
			table.insert(west_half, loop);
			table.insert(east_half, loop);
		end
		local west_shuffled = GetShuffledCopyOfTable(west_half)
		local east_shuffled = GetShuffledCopyOfTable(east_half)
		local iNumMountainsPerColumn = math.max(math.floor(iH * 0.225), math.floor((iH / 4) - 1));
		local x_west, x_east = iW / 2 - 1, iW / 2;
		for loop = 1, iNumMountainsPerColumn do
			local y_west, y_east = west_shuffled[loop], east_shuffled[loop];
			local i_west_plot = y_west * iW + x_west + 1;
			local i_east_plot = y_east * iW + x_east + 1;
			self.wholeworldPlotTypes[i_west_plot] = PlotTypes.PLOT_MOUNTAIN;
			self.wholeworldPlotTypes[i_east_plot] = PlotTypes.PLOT_MOUNTAIN;
		end
		-- Hills need to be added near mountains, but this needs to wait until after plot types have been initially set.

		-- Plot Type generation completed. Return global plot array.
		return self.wholeworldPlotTypes
	end
end
------------------------------------------------------------------------------
-- Map Generator Methods Customed by Map
------------------------------------------------------------------------------
function SetPlotTypes(plotTypes)
	local _dpo = true;
	-- _dpo = false;
	if _dpo then print("SetPlotTypes(plotTypes) (AC_Skirmish.lua)"); end
	-- NOTE: Plots() is indexed from 0, the way the plots are indexed in C++
	-- However, Lua tables are indexed from 1, and all incoming plot tables should be indexed this way.
	-- So we add 1 to the Plots() index to find the matching plot data in plotTypes.
	
	-- Protok: It's wrong. The last one X,Y tile will be not affected if we start to work with list of tiles not from first one but first + 1. So I fixed it.
	-- It is appeared as a more complex bug, causing shift 1 tile further in a skirmish map.
	for i, plot in Plots() do
		-- plot:SetPlotType(plotTypes[i + 1], false, false);
		plot:SetPlotType(plotTypes[i], false, false);
	end
end
------------------------------------------------------------------------------
function GeneratePlotTypes()
	local _dpo = true;
	-- _dpo = false;
	if _dpo then print("GeneratePlotTypes() (AC_Skirmish.lua) ..."); end

	local layered_world = MultilayeredFractal.Create();
	local plotsSkirmish = layered_world:GeneratePlotsByRegion();
	
	SetPlotTypes(plotsSkirmish);

	-- Examine all plots in buffer zone.
	local iW, iH = Map.GetGridSize();
	local firstRingYIsEven = {{0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}};
	local firstRingYIsOdd = {{1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}};
	for x = iW / 2 - 2, iW / 2 + 1 do
		for y = 1, iH - 2 do
			local plot = Map.GetPlot(x, y)
			if plot:IsFlatlands() then -- Check for adjacent Mountain plot; if found, change this plot to Hills.
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
					if plotType == PlotTypes.PLOT_MOUNTAIN then
						local diceroll = Map.Rand(5, "Random Canyon in Middle - Lua"); -- 20% chance turn this hill into canyon.
						if diceroll < 1 then
							plot:SetPlotType(PlotTypes.PLOT_CANYON, false, false)
						else
							plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)
							if _dpo then print("hill4 "..plot:GetX()..", "..plot:GetY()); end
						end
						break
					end
				end
			end
		end
	end

	if g_LandscapeOption == 2 then
		--Remove some alone rocks
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
								plot:SetPlotType(PlotTypes.PLOT_OCEAN, false, false)
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
	end

	GenerateCoasts();
end
------------------------------------------------------------------------------
function TerrainGenerator:GenerateTerrainAtPlot(iX,iY)
	-- print("TerrainGenerator:GenerateTerrainAtPlot Start ---- ") -- dbg
	local lat = self:GetLatitudeAtPlot(iX,iY);
	local terrainVal = self.terrainGrass;

	local plot = Map.GetPlot(iX, iY);
	if (plot:IsWater()) then
		local val = plot:GetTerrainType();
		if val == TerrainTypes.NO_TERRAIN then -- Error handling.
			val = self.terrainGrass;
			plot:SetPlotType(PlotTypes.PLOT_LAND, false, false);
		end
		return val;	 
	end
	
	-- Begin implementation of User Input for dominant terrain type (Skirmish.lua)
	if dominant_terrain == 2 then -- Plains
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
		elseif(lat >= self.fSnowLatitude) then -- to test appearance
			terrainVal = self.terrainSnow;
		end
	elseif dominant_terrain == 4 then -- Marsh
		-- Set Desert Wild Area value, even though there are no deserts.
		local desertVal = self.deserts:GetHeight(iX, iY);
		if not (plot:IsMountain() or plot:IsCanyon()) then
			if desertVal >= self.deserts:GetHeight(91) then
				plot:SetWildness(20);
			elseif desertVal >= self.deserts:GetHeight(85) then
				plot:SetWildness(21);
			end
		end
		if(lat >= self.fSnowLatitude) then -- to test appearance
			terrainVal = self.terrainTundra;
		end
		-- All grass all the time!
	elseif dominant_terrain == 5 then -- Desert
		local desertVal = self.deserts:GetHeight(iX, iY);
		local plainsVal = self.plains:GetHeight(iX, iY);
		if desertVal >= self.deserts:GetHeight(25) then
			terrainVal = self.terrainDesert;
			-- Set Desert Wild Area value.
			if not (plot:IsMountain() or plot:IsCanyon()) then
				if desertVal >= self.deserts:GetHeight(88) then
					plot:SetWildness(20);
				elseif desertVal >= self.deserts:GetHeight(80) then
					plot:SetWildness(21);
				end
			end
		elseif plainsVal >= self.plains:GetHeight(40) then
			terrainVal = self.terrainPlains;
		elseif(lat >= self.fSnowLatitude) then -- to test appearance
			terrainVal = self.terrainTundra;
		end
	elseif dominant_terrain == 6 then -- Tundra
		local desertVal = self.deserts:GetHeight(iX, iY);
		local plainsVal = self.plains:GetHeight(iX, iY);
		if plainsVal >= self.plains:GetHeight(85) then
			terrainVal = self.terrainPlains;
		elseif desertVal >= self.deserts:GetHeight(88) then
			terrainVal = self.terrainSnow;
			-- Set Desert Wild Area value -- using snow for this.
			if not (plot:IsMountain() or plot:IsCanyon()) then
				if desertVal >= self.deserts:GetHeight(93) then
					plot:SetWildness(20);
				elseif desertVal >= self.deserts:GetHeight(88) then
					plot:SetWildness(21);
				end
			end
		elseif(lat >= self.fSnowLatitude) then -- to test appearance
			terrainVal = self.terrainSnow;
		else
			terrainVal = self.terrainTundra;
		end
	elseif dominant_terrain == 8 then -- Global (aka normal climate bands)
		if(lat >= self.fSnowLatitude) then
			terrainVal = self.terrainSnow;
		elseif(lat >= self.fTundraLatitude) then
			terrainVal = self.terrainTundra;
		elseif (lat < self.fGrassLatitude) then
			terrainVal = self.terrainGrass;
		else
			local desertVal = self.deserts:GetHeight(iX, iY);
			local plainsVal = self.plains:GetHeight(iX, iY);
			if ((desertVal >= self.iDesertBottom) and (desertVal <= self.iDesertTop) and (lat >= self.fDesertBottomLatitude) and (lat < self.fDesertTopLatitude)) then
				terrainVal = self.terrainDesert;
				-- Set Desert Wild Area value.
				if not (plot:IsMountain() or plot:IsCanyon()) then
					if desertVal >= self.deserts:GetHeight(91) then
						plot:SetWildness(20);
					elseif desertVal >= self.deserts:GetHeight(85) then
						plot:SetWildness(21);
					end
				end
			elseif ((plainsVal >= self.iPlainsBottom) and (plainsVal <= self.iPlainsTop)) then
				terrainVal = self.terrainPlains;
			end
		end
	else -- Grassland / Forest / Hills
		local plainsVal = self.plains:GetHeight(iX, iY);
		if plainsVal >= self.plains:GetHeight(85) then
			terrainVal = self.terrainPlains;
		end
		-- Set Desert Wild Area value, even though there are no deserts.
		local desertVal = self.deserts:GetHeight(iX, iY);
		if not (plot:IsMountain() or plot:IsCanyon()) then
			if desertVal >= self.deserts:GetHeight(91) then
				plot:SetWildness(20);
			elseif desertVal >= self.deserts:GetHeight(85) then
				plot:SetWildness(21);
			end
		end
	end
	
	return terrainVal;
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain (AC_Skirmish.lua) ...");
	
	local terraingen = TerrainGenerator.Create();

	local terrainTypes = terraingen:GenerateTerrain();
	
	SetTerrainTypes(terrainTypes);
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function RiverGenerator:GetRiverValueAtPlot(plot)
	-- print("RiverGenerator:GetRiverValueAtPlot Start ---- ") -- dbg
	-- Custom method to force rivers to flow away from the map center.
	local iW, iH = Map.GetGridSize()
	local x = plot:GetX()
	local y = plot:GetY()
	local random_factor = Map.Rand(3, "River direction random factor - Skirmish LUA");
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
function RiverGenerator:GenerateRivers(args)
	print("RiverGenerator:GenerateRivers Start ---- ") -- dbg
	-- Only add rivers if Water Setting is value of 1 or 4. Otherwise no rivers.
	if userInputWaterSetting == 2 or userInputWaterSetting == 3 or userInputWaterSetting == 5 then -- No Rivers!
		return
	end

	-- Customization for Skirmish, to keep river starts away from buffer zone in middle columns of map, and set river "original flow direction".
	local iW, iH = Map.GetGridSize()
	print("Skirmish - Adding Rivers");
	local passConditions = {
		function(plot)
			return plot:IsHills() or plot:IsMountain();
		end,
		
		function(plot)
			return (not plot:IsCoastalLand()) and (Map.Rand(8, "MapGenerator AddRivers") == 0);
		end,
		
		function(plot)
			local area = plot:Area();
			local plotsPerRiverEdge = GameDefines["PLOTS_PER_RIVER_EDGE"];
			return (plot:IsHills() or plot:IsMountain()) and (area:GetNumRiverEdges() <	((area:GetNumTiles() / plotsPerRiverEdge) + 1));
		end,
		
		function(plot)
			local area = plot:Area();
			local plotsPerRiverEdge = GameDefines["PLOTS_PER_RIVER_EDGE"];
			return (area:GetNumRiverEdges() < (area:GetNumTiles() / plotsPerRiverEdge) + 1);
		end
	}
	for iPass, passCondition in ipairs(passConditions) do
		local riverSourceRange;
		local seaWaterRange;
		if (iPass <= 2) then
			riverSourceRange = GameDefines["RIVER_SOURCE_MIN_RIVER_RANGE"];
			seaWaterRange = GameDefines["RIVER_SOURCE_MIN_SEAWATER_RANGE"];
		else
			riverSourceRange = (GameDefines["RIVER_SOURCE_MIN_RIVER_RANGE"] / 2);
			seaWaterRange = (GameDefines["RIVER_SOURCE_MIN_SEAWATER_RANGE"] / 2);
		end
		for i, plot in Plots() do
			local current_x = plot:GetX()
			local current_y = plot:GetY()
			if current_x < 1 or current_x >= iW - 2 or current_y < 2 or current_y >= iH - 1 then
				-- Plot too close to edge, ignore it.
			elseif current_x >= (iW / 2) - 2 and current_x <= (iW / 2) + 1 then
				-- Plot in buffer zone, ignore it.
			elseif (not plot:IsWater()) then
				if(passCondition(plot)) then
					if (not Map.FindWater(plot, riverSourceRange, true)) then
						if (not Map.FindWater(plot, seaWaterRange, false)) then
							local inlandCorner = plot:GetInlandCorner();
							if(inlandCorner) then
								local start_x = inlandCorner:GetX()
								local start_y = inlandCorner:GetY()
								local orig_direction;
								if start_y < iH / 2 then -- South half of map
									if start_x < iW / 2 then -- West half of map
										orig_direction = FlowDirectionTypes.FLOWDIRECTION_NORTHWEST;
									else -- East half
										orig_direction = FlowDirectionTypes.FLOWDIRECTION_NORTHEAST;
									end
								else -- North half of map
									if start_x < iW / 2 then -- West half of map
										orig_direction = FlowDirectionTypes.FLOWDIRECTION_SOUTHWEST;
									else -- NE corner
										orig_direction = FlowDirectionTypes.FLOWDIRECTION_SOUTHEAST;
									end
								end
								self:DoRiver(inlandCorner, nil, orig_direction, nil);
							end
						end
					end
				end			
			end
		end
	end		
end
------------------------------------------------------------------------------
function RiverGenerator:GenerateLakes(args)
	print("RiverGenerator:GenerateLakes Start ---- ") -- dbg
	-- No lakes added in this manner.
end
------------------------------------------------------------------------------
function RiverGenerator:GetCapsForMethodC()
	print("RiverGenerator:GetCapsForMethodC Start ---- ") -- dbg
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
	print("RiverGenerator:MethodA Start AC_Skirmish ---- ") -- dbg
	--print("Map Generation - Adding canyons via Method A.");
	local iW, iH = Map.GetGridSize();
	local iFlags = Map.GetFractalFlags();
	local grain = 3;
	
	-- Generating canyons in large fractal rings, by taking a slice out of the lower middle heights.	
	local canyons = Fractal.Create(iW, iH, grain, iFlags, -1, -1);
	local canyon_bottom_1		= canyons:GetHeight(24);
	local canyon_top_1			= canyons:GetHeight(27);
	local canyon_bottom_2		= canyons:GetHeight(35);
	local canyon_top_2			= canyons:GetHeight(36);
	
	-- Generate canyons.
	for y = 1, iH - 2 do
		for x = 0, iW - 1 do
			local plot = Map.GetPlot(x, y);
			-- Canyon plot must not be water.
			if not plot:IsWater() then
				-- Canyon plot must not be coastal land.
				if not plot:IsCoastalLand() then
					-- Canyon plot must not be river.
					if not plot:IsRiver() then
						-- Preserve existing mountains or canyons.
						if not (plot:IsMountain() or plot:IsCanyon()) then
							-- Check to see if this plot is a member of one of the fractal canyon rings.
							local canyonVal = canyons:GetHeight(x, y);
							if (canyonVal >= canyon_bottom_1 and canyonVal <= canyon_top_1) or (canyonVal >= canyon_bottom_2 and canyonVal <= canyon_top_2) then
								-- Plot has met all conditions. Place canyon here.
								plot:SetPlotType(PlotTypes.PLOT_CANYON, false, false);
								self.num_type_a_canyons_placed = self.num_type_a_canyons_placed + 1;
							end
						end
					end
				end
			end
		end
	end
	
	print("- -"); print("- Number of Type A canyons placed: ", self.num_type_a_canyons_placed); print("- -");
	
	Map.RecalculateAreas()
end
------------------------------------------------------------------------------
function AddRivers()
	print("Generating Rivers, Canyons, and Lakes. (AC_Skirmish.lua) ...");

	local args = {};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end

------------------------------------------------------------------------------
function FeatureGenerator:__initFractals()
	print("FeatureGenerator:__initFractals Start AC_Skirmish ---- ") -- dbg
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
	
	if dominant_terrain == 3 then -- Forest
		self.iClumpLevel	= self.forestclumps:GetHeight(65) -- 35% forest clumps
		self.iForestLevel	= self.forests:GetHeight(55) -- 45% forest coverage of what isn't covered by clumps.
	elseif dominant_terrain == 6 then -- Tundra
		self.iClumpLevel	= self.forestclumps:GetHeight(80) -- 20% forest clumps
		self.iForestLevel	= self.forests:GetHeight(60) -- 40% forest coverage of what isn't covered by clumps.
	elseif dominant_terrain == 8 then -- Global
		self.iClumpLevel	= self.forestclumps:GetHeight(90) -- 10% forest clumps
		self.iForestLevel	= self.forests:GetHeight(69) -- 31% forest coverage of what isn't covered by clumps.
	end
end
------------------------------------------------------------------------------
function FeatureGenerator:AddIceAtPlot(plot, iX, iY, lat)
	-- print("FeatureGenerator:AddIceAtPlot Start ---- ") -- dbg
	if dominant_terrain == 8 then -- Global
		if (plot:CanHaveFeature(self.featureIce)) then
			if Map.IsWrapX() and (iY == 0 or iY == self.iGridH - 1) then
				plot:SetFeatureType(self.featureIce, -1)
			else
				local rand = Map.Rand(100, "Add Ice Lua")/100.0;
				if(rand < 8 * (lat - 0.875)) then
					plot:SetFeatureType(self.featureIce, -1);
				elseif(rand < 4 * (lat - 0.75)) then
					plot:SetFeatureType(self.featureIce, -1);
				end
			end
		end
	end
end
------------------------------------------------------------------------------
function FeatureGenerator:AddJunglesAtPlot(plot, iX, iY, lat)
	-- print("FeatureGenerator:AddJunglesAtPlot Start ---- ") -- dbg
	if dominant_terrain == 4 then -- Marsh
		if plot:IsFlatlands() then
			local jungle_height = self.jungles:GetHeight(iX, iY);
			if jungle_height <= self.jungles:GetHeight(70) and jungle_height >= self.jungles:GetHeight(20) then
				plot:SetFeatureType(self.featureMarsh, -1);
			end
		end
	elseif dominant_terrain == 8 then -- Global, use default.
		local jungle_height = self.jungles:GetHeight(iX, iY);
		if jungle_height <= self.iJungleTop and jungle_height >= self.iJungleBottom + (self.iJungleRange * lat) then
			if(plot:CanHaveFeature(self.featureJungle)) then
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
end
------------------------------------------------------------------------------
function FeatureGenerator:DetermineWildness(plot, iX, iY, lat)
	-- print("FeatureGenerator:DetermineWildness Start ---- ") -- dbg
	-- Determine Wildness value for forest, tundra and ocean.
	-- Forest Clump fractal is used for these three types of Wild Areas. (Desert Wilds are determined using the Desert fractal in TerrainGenerator).
	local iWildVal = self.forestclumps:GetHeight(iX, iY)
	if not (plot:IsWater() or plot:IsMountain() or plot:IsCanyon()) then -- Land plot.
		local terrain_value = plot:GetTerrainType()

		if dominant_terrain == 6 then -- Tundra: Xenomass will be placed in Tundra wilds.
			if terrain_value == self.terrainTundra then -- Check for Tundra Wildness.
				if iWildVal >= self.forestclumps:GetHeight(85) then -- Tundra Wild Area, Core plot.
					plot:SetWildness(30)
					self.iNumCoreTundraWilds = self.iNumCoreTundraWilds + 1;
				elseif iWildVal >= self.forestclumps:GetHeight(75) then -- Tundra Wild Area, Periphery plot.
					plot:SetWildness(31)
					self.iNumPeripheryTundraWilds = self.iNumPeripheryTundraWilds + 1;
				end
			end
		elseif dominant_terrain == 8 then -- Global
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
		else -- No tundra present on the map! Firaxite will be placed in Forest wilds.
			-- Handle Forest Wildness.
			if iWildVal >= self.forestclumps:GetHeight(85) then -- Forest Wild Area, Core plot.
				plot:SetWildness(10) -- Forest wild area, Core plot.
				self.iNumCoreForestWilds = self.iNumCoreForestWilds + 1;
			elseif iWildVal >= self.forestclumps:GetHeight(75) then -- Forest Wild Area, Periphery plot.
				plot:SetWildness(11) -- Forest wild area, Periphery plot.
				self.iNumPeripheryForestWilds = self.iNumPeripheryForestWilds + 1;
			end
		end
	end
end
------------------------------------------------------------------------------

function AddFeatures()
	print("Adding Features (AC_Skirmish.lua) ...");

	local args = {
		miasmaSpawnWay = g_MiasmaOption,
	};
	local featuregen = FeatureGenerator.Create(args);

	featuregen:AddFeatures();
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
----- Skirmish, reworked by Protok
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
function AssignStartingPlots:PlaceKeyStrategics_s()
	-- This is a BE function to regulate the amounts of the "key" strategics that get placed.
	-- This regulation pertains to Float Stone, Xenomass and Firaxite.
	self:GetKeyStrategicsTargetValues()

	-- For Skirmish only, handle terrain cases. Note: All cases have Desert wild already handled.
	if dominant_terrain == 6 then -- Tundra map, no Forest Wild present. Place Xenomass in tundra wild.
		self.large_xenomass_list = self.large_firaxite_list;
		self.small_xenomass_list = self.small_firaxite_list;
	elseif dominant_terrain < 8 then -- No tundra present. Place Firaxite in forest wild.
		self.large_firaxite_list = self.large_xenomass_list;
		self.small_firaxite_list = self.small_xenomass_list;
	end

	-- Process large deposits inside wild areas.
	local rand1, rand2, rand3 = self.xenomass_max - self.xenomass_min + 1, self.firaxite_max - self.firaxite_min + 1, self.floatstone_max - self.floatstone_min + 1;
	local large_xenomass_target = Map.Rand(rand1, "Number of Large Xenomass deposits to place - Lua") + self.xenomass_min;
	local large_firaxite_target = Map.Rand(rand2, "Number of Large Firaxite deposits to place - Lua") + self.firaxite_min;
	local large_floatstone_target = Map.Rand(rand3, "Number of Large Float Stone deposits to place - Lua") + self.floatstone_min;

	local resources_to_place = {
		{self.xenomass_ID, self.xenomass_base, self.xenomass_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.large_xenomass_list, resources_to_place, true, large_xenomass_target)

	local resources_to_place = {
		{self.firaxite_ID, self.firaxite_base, self.firaxite_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.large_firaxite_list, resources_to_place, true, large_firaxite_target)

	local resources_to_place = {
		{self.floatstone_ID, self.floatstone_base, self.floatstone_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.large_floatstone_list, resources_to_place, true, large_floatstone_target)

	-- Process small deposits inside wild areas.
	local rand1, rand2, rand3 = self.xenomass_max - self.xenomass_min + 1, self.firaxite_max - self.firaxite_min + 1, self.floatstone_max - self.floatstone_min + 1;
	local small_xenomass_target = Map.Rand(rand1, "Number of Large Xenomass deposits to place - Lua") + self.xenomass_min;
	local small_firaxite_target = Map.Rand(rand2, "Number of Large Firaxite deposits to place - Lua") + self.firaxite_min;
	local small_floatstone_target = Map.Rand(rand3, "Number of Large Float Stone deposits to place - Lua") + self.floatstone_min;

	local resources_to_place = {
		{self.xenomass_ID, self.minor_xenomass_base, self.minor_xenomass_range, 100, 1, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.small_xenomass_list, resources_to_place, true, small_xenomass_target)

	local resources_to_place = {
		{self.firaxite_ID, self.minor_firaxite_base, self.minor_firaxite_range, 100, 1, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.small_firaxite_list, resources_to_place, true, small_firaxite_target)

	local resources_to_place = {
		{self.floatstone_ID, self.minor_floatstone_base, self.minor_floatstone_range, 100, 1, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.small_floatstone_list, resources_to_place, true, small_floatstone_target)

	-- Process small deposits outside wild areas.
	local rand1, rand2, rand3 = 2 * (self.xenomass_max - self.xenomass_min + 1), 2 * (self.firaxite_max - self.firaxite_min + 1), 2 * (self.floatstone_max - self.floatstone_min + 1);
	local loose_xenomass_target = Map.Rand(rand1, "Number of Large Xenomass deposits to place - Lua") + 2 * self.xenomass_min;
	local loose_firaxite_target = Map.Rand(rand2, "Number of Large Firaxite deposits to place - Lua") + 2 * self.firaxite_min;
	local loose_floatstone_target = Map.Rand(rand3, "Number of Large Float Stone deposits to place - Lua") + 2 * self.floatstone_min;

	local resources_to_place = {
		{self.xenomass_ID, self.minor_xenomass_base, self.minor_xenomass_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.loose_xenomass_list, resources_to_place, true, loose_xenomass_target)

	local resources_to_place = {
		{self.firaxite_ID, self.minor_firaxite_base, self.minor_firaxite_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.loose_firaxite_list, resources_to_place, true, loose_firaxite_target)

	local resources_to_place = {
		{self.floatstone_ID, self.minor_floatstone_base, self.minor_floatstone_range, 100, 2, 2}, };
	self:BeyondEarthProcessStrategicResourceList(3, self.loose_floatstone_list, resources_to_place, true, loose_floatstone_target)

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
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function getLandmarksOption()
	print("getLandmarksOption customed by map");
	return g_LandmarksOption
end
