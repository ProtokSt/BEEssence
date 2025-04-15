-- Released under GPLv3
--------------------------------------------------------------

Orbital_Warning = L("TXT_KEY_IGE_ORBITAL");
BUG_NoGraphicalUpdate = L("TXT_KEY_IGE_NO_GRAPHICAL_UPDATE");
BUG_SavegameCorruption = L("TXT_KEY_IGE_SAVE_GAME_CORRUPTION");

local portraitSize = 128;
local largeSize = 64;
local smallSize = 45;

-------------------------------------------------------------------------------------------------
local function ReportBadRef(tableName, invalidToken, context)
	print("!!!!!!!!! WARNING! In table '"..tableName.."', the token '"..getstr(invalidToken).."' does not exist for '"..getstr(context).."'");
end

local function ReportBadField(tableName, invalidFieldName, entryID)
	print("!!!!!!!!! WARNING! In table '"..tableName.."', the field '"..getstr(invalidFieldName).."' is invalid for '"..getstr(entryID).."'");
end

-------------------------------------------------------------------------------------------------
local function IsValidBuilding(type)
	--[[local condition = "BuildingType = '" .. type .. "'";
	for row in GameInfo.Civilization_BuildingClassOverrides( condition ) do
		if row.CivilizationType ~= Game.GetActiveCivilizationType() then return false end
	end]]
	return true;
end

-------------------------------------------------------------------------------------------------
function AppendIDAndTypeToHelp(item)
	if not item.help then
		item.help = ""
	elseif item.help ~= "" then
		item.help = item.help.."[NEWLINE]"
	end
	item.help = item.help.."[COLOR_LIGHT_GREY]ID="..item.ID..", Type="..item.type.."[ENDCOLOR]"
end

-------------------------------------------------------------------------------------------------
function SetPlayersData(data, options)
	if data.playersByID then return end
	data.playersByCivType = {};
	data.playersByID = {};
	data.minorPlayers = {};
	data.majorPlayers = {};
	data.allPlayers = {};

	for i = 0, GameDefines.MAX_CIV_PLAYERS, 1 do
		local row = Players[i];
		if row:IsEverAlive() then	-- Must check it to prevent a crash
			local item = {};
			item.ID = i;
			item.isCityState = (i >= GameDefines.MAX_MAJOR_CIVS) and (i < GameDefines.MAX_CIV_PLAYERS);
			item.visible = true;
			item.enabled = true;
			item.priority = (i < GameDefines.MAX_CIV_PLAYERS and 1 or 0);

			item.civilizationType = row:GetCivilizationType();
			local civInfo = GameInfo.Civilizations[item.civilizationType];
			item.civilizationName = L(civInfo.ShortDescription);

			if item.isCityState then
				local minorCivType = row:GetMinorCivType();
				local minorCivInfo = GameInfo.MinorCivilizations[minorCivType];
				item.name = L(minorCivInfo.Description);
				item.type = minorCivType;

				local trait = GameInfo.MinorCivilizations[minorCivType].MinorCivTrait;
				if trait then
					local traitData = GameInfo.MinorCivTraits[trait];
					if traitData then
						item.smallTexture = traitData.TraitIcon;
					else
						ReportBadField("MinorCivTraits", "-", trait);
					end
				else
					ReportBadField("MinorCivilizations", "MinorCivTrait", minorCivType);
				end
				item.textureOffset, item.texture = IconLookup(civInfo.PortraitIndex, largeSize, civInfo.AlphaIconAtlas);	
			else
				item.name = L(row:GetName());
				item.type = row:GetLeaderType();
				item.subtitle = item.civilizationName;

				item.leaderType = row:GetLeaderType();

				if i == GameDefines.MAX_CIV_PLAYERS then
					item.texture = "Art/IgeBarbarian64.dds";
					item.smallTexture = "Art/IgeBarbarian32.dds";
					item.isAlien = true;
				else
					local leaderInfo = GameInfo.Leaders[item.leaderType];
					item.textureOffset, item.texture = IconLookup(leaderInfo.PortraitIndex, largeSize, leaderInfo.IconAtlas);	
					item.smallTextureOffset, item.smallTexture = IconLookup(civInfo.PortraitIndex, 32, civInfo.IconAtlas);	
					item.civTextureOffset, item.civTexture = IconLookup(civInfo.PortraitIndex, 45, civInfo.IconAtlas);	
				end
			end

			-- Insert
			data.playersByID[item.ID] = item;
			data.playersByCivType[item.civilizationType] = item;
			table.insert(data.allPlayers, item);
			if item.isCityState then
				table.insert(data.minorPlayers, item);
			else
				table.insert(data.majorPlayers, item);
			end
		end
	end

	-- Sort
	table.sort(data.majorPlayers, DefaultSort);
	table.sort(data.minorPlayers, DefaultSort);

	if options.none then
		table.insert(players, 1, { ID = -1, name = L("TXT_KEY_IGE_NONE"), priority=999, visible = true, enabled = true});
	end
end

-------------------------------------------------------------------------------------------------
function SetTerrainsData(data)
	if data.terrains then return end 
	data.terrainsByTypes = {};
	data.waterTerrains = {};
	data.terrains = {};

	local lakeName = L("TXT_KEY_PLOTROLL_LAKE")
	local coastName = L(GameInfo.Terrains["TERRAIN_COAST"].Description)

	for row in GameInfo.Terrains() do	
		local item = {};
		local name = L(row.Description);
		local isCoast = (row.Type == "TERRAIN_COAST")
		item.ID = row.ID
		item.name = name
		item.type = row.Type
		item.water = row.Water
		item.condition = "TerrainType = '" .. row.Type .. "'";
		item.action = SetTerrain;
		item.visible = item.ID < 7;
		item.selected = false;
		item.enabled = true;
		item.note = BUG_NoGraphicalUpdate;
		item.yieldChanges = {};
		item.yields = {};

		-- Texture
		item.textureOffset, item.texture = IconLookup( row.PortraitIndex, largeSize, row.IconAtlas );
		
		-- Sea yield changes
		if item.water then
			local coastSuffix = isCoast and coastName or nil
			for row in GameInfo.Building_SeaPlotYieldChanges() do
				if IsValidBuilding(row.BuildingType) then
					local building = GameInfo.Buildings[row.BuildingType];
					if building then
						table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(building.Description), type = "BUILDING", suffix = coastSuffix });
					else
						ReportBadRef("Building_SeaPlotYieldChanges", row.BuildingType, item.type);
					end
				end
			end
		end

		-- Lake yield changes
		if isCoast then
			for row in GameInfo.Building_LakePlotYieldChanges() do
				if IsValidBuilding(row.BuildingType) then
					local building = GameInfo.Buildings[row.BuildingType];
					if building then
						table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(building.Description), type = "BUILDING", suffix = lakeName });
					else
						ReportBadRef("Building_LakePlotYieldChanges", row.BuildingType, item.type);
					end
				end
			end
		end

		item.help = GetYieldChangeString(item);
		AppendIDAndTypeToHelp(item);

		-- Yields
		for row in GameInfo.Terrain_Yields( item.condition ) do
			item.yields[row.YieldType] = row.Yield;
		end

		-- Coast fixes and yields
		if isCoast then
			item.name = L("TXT_KEY_IGE_COAST_OR_LAKE")
			item.help = L("TXT_KEY_IGE_COAST_OR_LAKE_HELP").."[NEWLINE][NEWLINE]"..item.help

			item.yieldGroups = {}
			item.yieldGroups[lakeName] = {}
			for row in GameInfo.Feature_YieldChanges{FeatureType = "FEATURE_LAKE"} do
				item.yieldGroups[lakeName][row.YieldType] = row.Yield;
			end
			item.yieldGroups[coastName] = item.yields
			item.yields = nil
		end
		item.subtitle = GetYieldString(item);

		-- Insert
		data.terrainsByTypes[item.type] = item;
		if item.water then
			table.insert(data.waterTerrains, item);
		else
			table.insert(data.terrains, item);
		end
	end

	-- Sort
	table.sort(data.waterTerrains, DefaultSort);
	table.sort(data.terrains, DefaultSort);
end

-------------------------------------------------------------------------------------------------


--===============================================================================================
-- types, features, resources
--===============================================================================================
-------------------------------------------------------------------------------------------------
function SetPlotTypesData(data)
	if data.types then return end
	data.types = {};

	local tex = "Art/IgeElevation.dds";
	local hillsYields = {};
	hillsYields[YieldTypes.YIELD_PRODUCTION] = 2;
	local hills = data.terrainsByTypes.TERRAIN_HILL;
	local grass = data.terrainsByTypes.TERRAIN_GRASS;
	local mountains = data.terrainsByTypes.TERRAIN_MOUNTAIN;
	local canyon = data.terrainsByTypes.TERRAIN_CANYON;

	data.types[0] = { ID = 0, type = PlotTypes.PLOT_LAND, name = L("TXT_KEY_IGE_FLAT_LAND"), texture = tex, textureOffset = Vector2(0, 0) }
	data.types[1] = { ID = 1, type = PlotTypes.PLOT_HILLS, name = hills.name, texture = tex, textureOffset = Vector2(64, 0) }
	data.types[2] = { ID = 2, type = PlotTypes.PLOT_MOUNTAIN, name = mountains.name, texture = tex, textureOffset = Vector3(128, 0) }
	data.types[3] = { ID = 3, type = PlotTypes.PLOT_CANYON, name = canyon.name, texture = tex, textureOffset = Vector3(192, 0) }

	for i, v in ipairs(data.types) do
		v.action = SetPlotType;
		v.visible = true;
		v.enabled = true;
		v.note = BUG_NoGraphicalUpdate;
	end

	hills.subtitle = GetYieldString(hills);
end

-------------------------------------------------------------------------------------------------
function SetFeaturesData(data, options)
	if data.featuresByTypes then return end
	data.featuresByTypes = {};
	data.features = {};

	for row in GameInfo.Features() do
		local item = {};
		local name = L( row.Description )
		item.ID = row.ID;
		item.name = name;
		item.type = row.Type;
		item.happiness = row.InBorderHealth;
		item.condition = "FeatureType = '" .. row.Type .. "'";
		item.action = SetFeature;
		item.requiresFlatLands = row.RequiresFlatlands;
		item.requiresRiver = row.RequiresRiver;
		item.selected = false;
		item.enabled = false;
		item.visible = true;
		item.validTerrains = {};
		item.yieldChanges = {};
		item.yields = {};
		
		-- Texture
		item.textureOffset, item.texture = IconLookup( row.PortraitIndex, largeSize, row.IconAtlas );

		-- Yields
		for row in GameInfo.Feature_YieldChanges(item.condition) do
			item.yields[row.YieldType] = row.Yield;
		end
		
		item.subtitle = GetYieldString(item);

		-- Yield changes
		for row in GameInfo.Building_FeatureYieldChanges(item.condition) do
			if IsValidBuilding(row.BuildingType) then
				local building = GameInfo.Buildings[row.BuildingType];
				if building then
					table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(building.Description), type = "BUILDING" });
				else
					ReportBadRef("Building_FeatureYieldChanges", row.BuildingType, item.type);
				end
			end
		end

		item.help = GetYieldChangeString(item);
		AppendIDAndTypeToHelp(item);

		-- Valid terrains
		for row in GameInfo.Feature_TerrainBooleans(item.condition) do
			local terrain = data.terrainsByTypes[row.TerrainType];
			item.validTerrains[terrain.ID] = terrain;
		end
				
		-- Append to tables
		data.featuresByTypes[item.type] = item;
		table.insert(data.features, item);
	end

	-- Sort
	table.sort(data.features, DefaultSort);

	if options.none then
		table.insert(data.features, 1, { ID = -1, type = -1, name = L("TXT_KEY_IGE_NONE"), visible = true, enabled = true, action = SetFeature });
	end
end

-------------------------------------------------------------------------------------------------
function SetResourcesData(data, options)
	if data.allResources then return end
	data.allResources = {};
	data.resourcesByTypes = {};
	data.strategicResources = {};
	data.artifactResources = {};
	data.basicResources = {};

 	for row in GameInfo.Resources() do
 		local item = {};
 		local name = L( row.Description )
 		item.name = name;
 		item.nameKey = row.Description;
 		item.ID = row.ID;
		item.type = row.Type;
		item.hills = row.Hills;
		item.flatLands = row.Flatlands;
		item.iconString = row.IconString;
		item.condition = "ResourceType = '" .. row.Type .. "'";
		item.action = SetResource;
		item.usage = row.ResourceClassType;
		item.showYieldMod = true;
		item.selected = false;
		item.enabled = false;
		item.visible = true;
		item.baseQty = 1;
		item.qty = 1;
		item.validTerrains = {};
		item.validFeatures = {};
		item.yieldChanges = {};
		item.yields = {};

		-- Texture
		item.textureOffset, item.texture = IconLookup( row.PortraitIndex, largeSize, row.IconAtlas );				
		item.smallTextureOffset, item.smallTexture = IconLookup( row.PortraitIndex, smallSize, row.IconAtlas );	
			
		-- Yields
		for row in GameInfo.Resource_YieldChanges( item.condition ) do
			item.yields[row.YieldType] = row.Yield;
		end
		item.subtitle = GetYieldString(item);

		-- Valid terrains
		local maritime = true;
		for row in GameInfo.Resource_TerrainBooleans(item.condition) do
			if row.TerrainType ~= "TERRAIN_COAST" and row.TerrainType ~= "TERRAIN_OCEAN" then maritime = false; end
			local terrain = data.terrainsByTypes[row.TerrainType];
			if terrain then
				item.validTerrains[terrain.ID] = terrain;
			else
				ReportBadRef("Resource_TerrainBooleans", row.TerrainType, item.type);
			end
		end

		-- Valid features
		for row in GameInfo.Resource_FeatureBooleans(item.condition) do
			local feature = data.featuresByTypes[row.FeatureType];
			if feature then
				item.validFeatures[feature.ID] = feature;
				maritime = false;
			else
				ReportBadRef("Resource_FeatureBooleans", row.FeatureType, item.type);
			end
		end

		-- Resource yield changes
		local improvementBringsBonus = false;
		for row in GameInfo.Improvement_ResourceType_Yields(item.condition) do
			local improvement = GameInfo.Improvements[row.ImprovementType];
			if improvement then
				table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(improvement.Description), type = "IMPROVEMENT" });
				improvementBringsBonus = true;
			else
				ReportBadRef("Improvement_ResourceType_Yields", row.ImprovementType, item.type);
			end
		end
		-- There is an improvement but it doesn't bring any bonus, let's add a 0 yield bonus
		if not improvementBringsBonus then
			local improvementData = GameInfo.Improvement_ResourceTypes(item.condition)();
			if improvementData then
				local improvement = GameInfo.Improvements[improvementData.ImprovementType];
				if improvement then
					table.insert(item.yieldChanges, { yield = 0, name = L(improvement.Description), type = "IMPROVEMENT" });
				else
					ReportBadRef("Improvement_ResourceTypes", improvementData.ImprovementType, item.type);
				end
			end
		end
		for row in GameInfo.Building_ResourceYieldChanges(item.condition) do
			if IsValidBuilding(row.BuildingType) then
				local building = GameInfo.Buildings[row.BuildingType];
				if building then
					table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(building.Description), type = "BUILDING" });
				else
					ReportBadRef("Building_ResourceYieldChanges", row.BuildingType, item.type);
				end
			end
		end
		if maritime then 
			for row in GameInfo.Building_SeaResourceYieldChanges() do
				if IsValidBuilding(row.BuildingType) then
					local building = GameInfo.Buildings[row.BuildingType];
					if building then
						table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(building.Description), type = "BUILDING" });
					else
						ReportBadRef("Building_SeaResourceYieldChanges", row.BuildingType, item.type);
					end
				end
			end
		end
		item.help = GetYieldChangeString(item);
		AppendIDAndTypeToHelp(item);

		-- Warnings
		local valid = item.type ~= "RESOURCE_HIDDEN_ARTIFACTS" and item.name ~= "Placeholder"

		-- Append to tables
		if valid then 
			data.allResources[item.ID] = item;
			data.resourcesByTypes[item.type] = item;

			--Add Ocean to item name
			if string.find(item.type, "OCEAN") ~= nil then
				item.name = item.name.." (Ocean)";
			end

			if item.usage == "RESOURCECLASS_BASIC" then
				table.insert(data.basicResources, item);
			elseif item.usage == "RESOURCECLASS_STRATEGIC" then
				table.insert(data.strategicResources, item);
			elseif item.usage == "RESOURCECLASS_ARTIFACT" then
				table.insert(data.artifactResources, item);
			else
				print("SetResourcesData: Not appended to table: ",item.type);
			end
			
			if item.type == "RESOURCE_PETROLEUM" then item.baseQty = 2
			elseif item.type == "RESOURCE_GEOTHERMAL_ENERGY" then item.baseQty = 2
			elseif item.type == "RESOURCE_TITANIUM" then item.baseQty = 2
			elseif item.type == "RESOURCE_XENOMASS" then item.baseQty = 2
			elseif item.type == "RESOURCE_FLOAT_STONE" then item.baseQty = 2
			elseif item.type == "RESOURCE_FIRAXITE" then item.baseQty = 2
			end
		end
	end

	-- Sort
	table.sort(data.basicResources, DefaultSort);
	table.sort(data.artifactResources, DefaultSort);
	table.sort(data.strategicResources, DefaultSort);

	if options.none then
		table.insert(data.basicResources, 1, { ID = -1, type = -1, name = L("TXT_KEY_IGE_NONE"), visible = true, enabled = true, note = BUG_NoGraphicalUpdate, action = SetResource });
		data.allResources[-1] = data.basicResources[1];
	end
end


--===============================================================================================
-- Improvements & routes
--===============================================================================================
function SetImprovementsData(data, options)
	if data.improvements then return end
	data.projects = {};
	data.notImprovements = {};
	data.improvements = {};

	for row in GameInfo.Improvements() do	
		local item = {};
		local name = L( row.Description );
		item.ID = row.ID;
		item.name = name;
		item.type = row.Type;
		item.condition = "ImprovementType = '" .. row.Type .. "'";
		item.action = SetImprovement;
		item.defenseModifier = row.DefenseModifier;
		item.requiresFlatlandsOrFreshWater = row.RequiresFlatlandsOrFreshWater;
		item.freshWaterMakesValid = row.FreshWaterMakesValid;
		item.hillsMakesValid = row.HillsMakesValid;
		item.showYieldMod = true;
		item.visible = true;
		item.enabled = true;
		item.yields = {};
		item.yieldChanges = {};
		item.validTerrains = {};
		item.validFeatures = {};
		item.improvedResources = {};
		item.isNest = row.AlienNest;
		item.isGoody = row.Goody;
		item.isProject = nil;
		item.cannotPillage = row.CannotPillage;
		if IGE_HasRisingTide then
			item.isMarvel = row.MinorMarvel;
		end


		-- Texture
		item.textureOffset, item.texture = IconLookup(row.PortraitIndex, largeSize, row.IconAtlas);
		item.smallTextureOffset, item.smallTexture = IconLookup(row.PortraitIndex, smallSize, row.IconAtlas );

		-- Yields
		for subRow in GameInfo.Improvement_Yields(item.condition) do
			item.yields[subRow.YieldType] = subRow.Yield;
		end
		

		-- Yields for improved resources
		for subRow in GameInfo.Improvement_ResourceTypes(item.condition) do
			local resource = data.resourcesByTypes[subRow.ResourceType];
			if resource then
				for yieldChangeRow in GameInfo.Improvement_ResourceType_Yields(resource.condition) do
					if yieldChangeRow.ImprovementType == item.type then
						item.improvedResources[resource.ID] = { resource = resource, yieldType = yieldChangeRow.YieldType, yield = yieldChangeRow.Yield };
					end
				end
			else
				ReportBadRef("Improvement_ResourceTypes", subRow.ResourceType, item.type);
			end
		end
		item.subtitle = GetYieldString(item);

		-- Valid terrains
		for row in GameInfo.Improvement_ValidTerrains(item.condition) do
			local terrain = data.terrainsByTypes[row.TerrainType];
			if terrain then 
				item.validTerrains[terrain.ID] = terrain;
			else
				ReportBadRef("Improvement_ValidTerrains", row.TerrainType, item.type);
			end
		end

		-- Valid features
		for row in GameInfo.Improvement_ValidFeatures(item.condition) do
			local feature = data.featuresByTypes[row.FeatureType];
			if feature then 
				item.validFeatures[feature.ID] = feature;
			else
				ReportBadRef("Improvement_ValidFeatures", row.FeatureType, item.type);
			end
		end

		-- Yield changes
		for row in GameInfo.Improvement_TechYieldChanges(item.condition) do
			local tech = GameInfo.Technologies[row.TechType]
			if tech then
				table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(tech.Description), type = "TECH" });
			else
				ReportBadRef("Improvement_TechYieldChanges", row.TechType, item.type);
			end
		end
		for row in GameInfo.Improvement_TechNoFreshWaterYieldChanges(item.condition) do
			local tech = GameInfo.Technologies[row.TechType]
			if tech then
				table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(tech.Description).." (no fresh water)", type = "TECH" });
			else
				ReportBadRef("Improvement_TechNoFreshWaterYieldChanges", row.TechType, item.type);
			end
		end
		for row in GameInfo.Improvement_TechFreshWaterYieldChanges(item.condition) do
			local tech = GameInfo.Technologies[row.TechType]
			if tech then
				table.insert(item.yieldChanges, { yieldType = row.YieldType, yield = row.Yield, name = L(tech.Description).." (fresh water)", type = "TECH" });
			else
				ReportBadRef("Improvement_TechFreshWaterYieldChanges", row.TechType, item.type);
			end
		end
		item.help = GetYieldChangeString(item);
		AppendIDAndTypeToHelp(item);

		--Get projects data
		local projectsData = GameInfo.Projects("CompleteImprovement = '"..item.type.."'")();
		if projectsData then
			item.isProject = true;
		end

		-- Insert in tables
		local addValid = true;

		if string.match(item.type,"PARTIAL") then
			addValid = false;
		end
		if string.match(item.type,"STATION") then
			addValid = false;
		end
		if string.match(item.type,"SOLID_STATE") then
			addValid = false;
		end
		if string.match(item.type,"ELEMENTAL_FATE") then
			addValid = false;
		end
		if string.match(item.type,"EYE_OF_THE") then
			addValid = false;
		end
		if string.match(item.type,"DEPTH_GAUGE") then
			addValid = false;
		end
		if string.match(item.type,"HEX_CAGE") then
			addValid = false;
		end
		if string.match(item.type,"OUTPOST") then
			addValid = false;
		end
		if string.match(item.type,"MINEFIELD") then
			addValid = false;
		end
		if string.match(item.type,"QUEST") then
			addValid = false;
		end

		if addValid then
			
			--add Ocean to item name
			if string.find(item.type, "OCEAN") ~= nil or string.find(item.type, "WATER") ~= nil then
				item.name = item.name.." (Ocean)";
			end

			if item.isProject then
				table.insert(data.projects, item);
			elseif item.isMarvel then
				table.insert(data.notImprovements, item);
			else
				table.insert(data.improvements, item);
			end	
		end
	end

	-- Sort
	table.sort(data.projects, DefaultSort);
	table.sort(data.improvements, DefaultSort);
	table.sort(data.notImprovements, DefaultSort);

	if options.none then
		table.insert(data.notImprovements, 1, { ID = -1, type = -1, name = L("TXT_KEY_IGE_NONE"), visible = true, enabled = true, action = SetImprovement });
	end
end

-------------------------------------------------------------------------------------------------
function SetRoutesData(data, options)
	if data.routes then return end
	data.routes = {};

	for row in GameInfo.Routes() do	
		local item = {};
		local name = L( row.Description );
		item.ID = row.ID;
		item.name = name;
		item.type = row.Type;
		item.condition = "RouteType = '" .. row.Type .. "'";
		item.action = SetRoute;
		item.visible = true;
		item.enabled = true;
		item.yields = {};

		item.help = L(row.Civilopedia or "").."[NEWLINE]"
		AppendIDAndTypeToHelp(item);

		-- Texture
		item.textureOffset, item.texture = IconLookup(row.PortraitIndex, largeSize, row.IconAtlas);
		item.smallTextureOffset, item.smallTexture = IconLookup(row.PortraitIndex, smallSize, row.IconAtlas );

		table.insert(data.routes, item);
	end

	if options.none then
		table.insert(data.routes, 1, { ID = -1, type = -1, name = L("TXT_KEY_IGE_NONE"), visible = true, enabled = true, action = SetRoute });
	end
end

--===============================================================================================
-- TECHS, UNITS, BUILDINGS
--===============================================================================================
function SetTechnologiesData(data)
	if data.techsByTypes then return end
	data.techsByTypes = {};
	data.techs = {};

 	for row in GameInfo.Technologies() do
		
		local item = {};
		local name = L(row.Description);
		item.ID = row.ID;
		item.name = name;
		item.type = row.Type;
		item.disable = row.Disable;
		item.gridX = row.GridDegrees;
		item.gridY = row.GridRadius;
		item.enabled = true;
		item.visible = true;
		item.condition = "PrereqTech = '" .. row.Type .. "'";
		item.units = {};
		item.buildings = {};
		item.wonders = {};
		item.prereqs = {};
		
		if item.disable then
			item.label = "[COLOR_NEGATIVE_TEXT]"..item.name.."[ENDCOLOR]";
		end

		-- Texture
		item.textureOffset, item.texture = IconLookup(row.PortraitIndex, largeSize, row.IconAtlas);
		item.smallTextureOffset, item.smallTexture = IconLookup(row.PortraitIndex, smallSize, row.IconAtlas );

		--table.insert(era.techs, item);
		table.insert(data.techs, item);
		data.techsByTypes[item.type] = item;
	end

	-- Prerequisites
	for _, tech in pairs(data.techsByTypes) do
		for prereq in GameInfo.Technology_PrereqTechs("TechType = '"..tech.type.."'") do
			local prereqTech = data.techsByTypes[prereq.PrereqTech];
			if prereqTech then
				table.insert(tech.prereqs, prereqTech);
			else
				ReportBadRef("Technology_PrereqTechs", prereq.PrereqTech, tech.type);
			end
		end
	end

	-- Sort
	--for _, era in ipairs(data.eras) do
		--table.sort(era.techs, DefaultSort);
	--end
end

-------------------------------------------------------------------------------------------------
function SetUnitsData(data)
	local activePlayer = Players[Game.GetActivePlayer()];
	if data.unitsAlien then return end
	SetTechnologiesData(data);
	data.unitsByTypes = {};
	data.unitsByID = {};
	data.units = {};
	data.unitsUpgradable = {};
	data.unitsCivilian = {};
	data.unitsHarmony = {};
	data.unitsSupremacy = {};
	data.unitsPurity = {};
	data.unitsOrbital = {};
	data.unitsAlien = {};

 	for row in GameInfo.Units() do
		local valid = true;
		local item = {};
		local name = L(row.Description);
		item.ID = row.ID;
		item.name = name;
		item.description = row.Description;
		item.type = row.Type;
		item.class = row.Class;
		item.domain = row.Domain;
		item.isOrbital = row.Orbital ~= nil;
		item.isAlien = row.AlienLifeform;
		item.isCivilian = row.CivilianAttackPriority ~= nil;
		item.promotions = {};
		item.visible = true;
		item.enabled = true;

		--BE unit portraits
		local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon(row.ID);

		-- Texture
		item.textureOffset, item.texture = IconLookup(portraitIndex, largeSize, portraitAtlas);
		item.smallTextureOffset, item.smallTexture = IconLookup(portraitIndex, smallSize, portraitAtlas );

		-- Civilization
		local overriding = GameInfo.Civilization_UnitClassOverrides("UnitType = '"..item.type.."'")();
		if overriding then
			item.civilizationType = overriding.CivilizationType;
			local civilization = GameInfo.Civilizations[item.civilizationType];
			if civilization then
				item.civilizationName = L(GameInfo.Civilizations[item.civilizationType].ShortDescription);
				item.subtitle = item.civilizationName;
			else
				ReportBadRef("Civilization_UnitClassOverrides", overriding.civilizationType, item.type);
				valid = false;
			end
		end		

		-- Help text
		item.help = GetIGEHelpTextForUnit(row, activePlayer).."[NEWLINE]"
		AppendIDAndTypeToHelp(item);

		-- Prereq
		if row.PrereqTech then
			local tech = data.techsByTypes[row.PrereqTech];
			if tech then
				item.prereq = tech;
				table.insert(tech.units, item);
			else
				ReportBadRef("Units", row.PrereqTech, item.type);
			end
		else
			--item.era = data.erasByID[0];
		end

		-- Get affinity info
		local affinityPrereqs = GameInfo.Unit_AffinityPrereqs("UnitType = '"..item.type.."'")();
		if affinityPrereqs then
			item.affinity = affinityPrereqs.AffinityType;
		end

		-- Add warning for Orbital units (need to spawn in city)
		if item.isOrbital then
			item.note = Orbital_Warning;
		end

		-- Insert into tables
		if valid then
			if item.isCivilian then
				table.insert(data.unitsCivilian, item);
			elseif item.affinity then
				if item.affinity == "AFFINITY_TYPE_HARMONY" then
					table.insert(data.unitsHarmony, item);
				elseif item.affinity == "AFFINITY_TYPE_SUPREMACY" then
					table.insert(data.unitsSupremacy, item);
				elseif item.affinity == "AFFINITY_TYPE_PURITY" then
					table.insert(data.unitsPurity, item);
				else
					print("item.affinity does not match for: ", item.type);
				end
			elseif item.isOrbital then
				table.insert(data.unitsOrbital, item);
			elseif item.isAlien then
				table.insert(data.unitsAlien, item);
			else
				table.insert(data.units, item);
			end

			data.unitsByTypes[item.type] = item;
			data.unitsByID[item.ID] = item;
		end

	end

	-- Sort
	table.sort(data.units, DefaultSort);
	table.sort(data.unitsCivilian, DefaultSort);
	table.sort(data.unitsHarmony, DefaultSort);
	table.sort(data.unitsSupremacy, DefaultSort);
	table.sort(data.unitsPurity, DefaultSort);
	table.sort(data.unitsOrbital, DefaultSort);
	-- table.sort(data.unitsAlien, DefaultSort);

end

-------------------------------------------------------------------------------------------------
function SetBuildingsData(data)
	if data.buildings then return end
	SetTechnologiesData(data);
	data.buildings = {};

 	for row in GameInfo.Buildings() do
		local valid = true;
		local item = {};
		local name = L(row.Description);
		item.ID = row.ID;
		item.name = name;
		item.type = row.Type;
		item.class = row.BuildingClass;
		item.isWonder = row.WonderSplashImage;
		item.isNationalWonder = false;
		item.isArtifactBuilding = nil;
		item.visible = true;
		item.enabled = true;


		local classRow = GameInfo.BuildingClasses("Type = '"..item.class.."'")();
		if classRow then
			item.noLimit = classRow.NoLimit;
		else
			ReportBadRef("Buildings", item.class, item.type);
			valid = false;
		end
		
		--National wonder flag
		if row.ArtDefineTag == "TEMPLE" or row.Capital then
			item.isNationalWonder = true;
			item.isWonder = nil;
		end

		--Artifact flag
		if IGE_HasRisingTide then
			local classRowArtifacts = GameInfo.ArtifactRewards("BuildingReward = '"..item.type.."'")();
			if classRowArtifacts then
				item.isArtifactBuilding = classRowArtifacts.Type;
				item.isWonder = nil;
			end
		end

		-- Get affinity data
		local affinityprereqs = GameInfo.Building_AffinityPrereqs("BuildingType = '"..item.type.."'")();
		if affinityprereqs then
			item.affinity = affinityprereqs.AffinityType;
		else
			item.affinity = nil;
		end

		-- Help
		item.help = GetHelpTextForBuilding(item.ID, true, false, false).."[NEWLINE]";
		AppendIDAndTypeToHelp(item);
		if item.isNationalWonder then
			item.priority = 1;
			item.subtitle = L("TXT_KEY_IGE_NATIONAL_WONDER");
		elseif item.isWonder then
			item.subtitle = L("TXT_KEY_IGE_WONDER");
		else
			item.subtitle = "";
		end

		-- Texture
		item.textureOffset, item.texture = IconLookup(row.PortraitIndex, largeSize, row.IconAtlas);
		item.smallTextureOffset, item.smallTexture = IconLookup(row.PortraitIndex, smallSize, row.IconAtlas );

		-- Civilization
		local overriding = GameInfo.Civilization_BuildingClassOverrides("BuildingType = '"..item.type.."'")();
		if overriding then
			item.civilizationType = overriding.CivilizationType;
			local civilization = GameInfo.Civilizations[item.civilizationType];
			if civilization then
				item.civilizationName = L(GameInfo.Civilizations[item.civilizationType].ShortDescription);
				item.subtitle = item.subtitle..item.civilizationName;
			else
				ReportBadRef("Civilization_BuildingClassOverrides", overriding.CivilizationType, item.type);
				valid = false;
			end
		end

		-- Prereq
		if row.PrereqTech then
			local tech = data.techsByTypes[row.PrereqTech];
			if tech then
				item.prereq = tech;
				if item.isWonder or item.isNationalWonder then
					table.insert(tech.wonders, item);
				else
					table.insert(tech.buildings, item);
				end
			else
				ReportBadRef("Buildings", row.PrereqTech, item.type);
			end
		end
		
		-- Insert
		if valid then
			table.insert(data.buildings, item);
		end
	end

	-- Sort
	table.sort(data.buildings, DefaultSort);
end

if IGE_HasRisingTide then
	function SetArtifactsData(data, options)
		if data.artifacts then return end
		data.artifacts = {};

		for row in GameInfo.Artifacts() do	
			local item = {};
			local name = L( row.Description );
			item.ID = row.ID;
			item.name = name;
			item.type = row.Type;
			item.category = row.Category;
			item.isArtifact = true;
			item.visible = true;
			item.enabled = true;

			item.help = L(row.Explanation or "").."[NEWLINE]"
			AppendIDAndTypeToHelp(item);

			-- Texture - using portraitSize, artifacts only have 128 texture
			item.textureOffset, item.texture = IconLookup(row.PortraitIndex, portraitSize, row.IconAtlas);

			table.insert(data.artifacts, item);
		end
	end
end