--MGH Modified
---- 2022 - Blessed by Protok St
--===============================================
-- Event Control
--===============================================
-- A special actions for specfic game events.
----------------------------------------------------
print("---- EventControl.lua INIT ----"); -- dbg
include( "MathHelpers" );
include("ArtifactUtilities.lua");
----------------------------------------------------
--
----------------------------------------------------
local NO_MARVELS = Game.IsOption("GAMEOPTION_NO_MARVELS");
local ModSaveDB = Modding.OpenSaveData();
-----------------------------
------------------------------------------------------------------
function LoadoutStartEffect(pPlayer, plotX, plotY)
print("LoadoutStartEffect start -- pPlayer="..tostring(pPlayer).." plotX="..tostring(plotX).." plotY="..tostring(plotY)); -- dbg
-- Serv to do ... by Loadout
-- create units
-- reveal map
-- give an Artifact
-- give an Influence

	-- predefined vars
	local pPlayerColonists = PreGame.GetLoadoutColonist(pPlayer)
	local pPlayerCargo = PreGame.GetLoadoutCargo(pPlayer)
	local pPlayerSpacecraft = PreGame.GetLoadoutSpacecraft(pPlayer)
	local iW, iH = Map.GetGridSize();
	local sizekey = Map.GetWorldSize();
	-- print("StartingLoadoutMapReveal sizekey: "..tostring(sizekey)); -- dbg
	local _RevealRange = 10 + sizekey; -- increase radius according to map size by ID from +0 to +5

	-- GameData Table Objects
	local _CARGO_WEAPONRY = GameInfo.Cargo["CARGO_WEAPONRY"].ID
	--MGH:local _CARGO_ADVANCEARMA = GameInfo.Cargo["CARGO_ADVANCED_ARMAMENT"].ID
	--MGH:local _CARGO_MORCC1 = GameInfo.Cargo["CARGO_MORC_CONTRACT_1"].ID
	--MGH:local _CARGO_MORCC2 = GameInfo.Cargo["CARGO_MORC_CONTRACT_2"].ID
	--MGH:local _CARGO_EXPLORER = GameInfo.Cargo["CARGO_EXPLORER_CORPS"].ID
	--MGH:local _CG_MXHTS = GameInfo.Cargo["CARGO_MUSEUM_EXHIBITS"].ID;
	local _UNIT_EXPLORER = GameInfo.Units["UNIT_EXPLORER"].ID
	local _UNIT_MARINE = GameInfo.Units["UNIT_MARINE"].ID
	local _UNIT_CANONIR = GameInfo.Units["UNIT_NAVAL_FIGHTER"].ID
	local _UNIT_MIASMRE = GameInfo.Units["UNIT_MIASMIC_REPULSOR"].ID
	local _UNIT_SOLAR = GameInfo.Units["UNIT_SOLAR_COLLECTOR"].ID
	
	--MGH:
	--[[
	local _SC_XGP = GameInfo.Spacecraft["SPACECRAFT_XENOGEOLOGY_PROBE"].ID;
	local _SC_12BD = GameInfo.Spacecraft["SPACECRAFT_TWELVEBRAVE_DATA"].ID;
	local _SC_PELENG = GameInfo.Spacecraft["SPACECRAFT_PELENGATOR"].ID;
	local _SC_HESC = GameInfo.Spacecraft["SPACECRAFT_HEIGHT_SCANNER"].ID;
	local _SC_RESNR = GameInfo.Spacecraft["SPACECRAFT_REEF_SONAR"].ID;
	local _SC_DIPMIS = GameInfo.Spacecraft["SPACECRAFT_DIPLOMATIC_MISSION"].ID;
	local _res_firaxite = GameInfo.Resources["RESOURCE_FIRAXITE"].ID;
	local _res_xenomass = GameInfo.Resources["RESOURCE_XENOMASS"].ID;
	local _res_floatstone = GameInfo.Resources["RESOURCE_FLOAT_STONE"].ID;
	local _fea_ice = GameInfo.Features["FEATURE_ICE"].ID;
	local _fea_crater = GameInfo.Features["FEATURE_CRATER"].ID;
	local _fea_reef = GameInfo.Features["FEATURE_REEF"].ID;
	]]--
	
	-- vars in use
	-- local Fplot, Distance, resourceType, pResource;
	local Fplot, Distance, gameSpeedType, _speedscale, _grantedamount;

	-- Prepare HQ checking
	local pPlayerHQ = Players[pPlayer]:GetCapitalCity();
	local Cplot = Map.GetPlot(plotX, plotY);
	local cityID = Cplot:GetPlotCity();
	
	-- if cityID == pPlayerHQ then
	
		--if pPlayerCargo == _CARGO_WEAPONRY then
		--	local unit = Players[pPlayer]:InitUnit(_UNIT_MARINE, plotX, plotY)
		--end
		--MGH:
		--[[
		if pPlayerCargo == _CARGO_EXPLORER then
			local unit = Players[pPlayer]:InitUnit(_UNIT_EXPLORER, plotX, plotY)
		end
		if pPlayerCargo == _CARGO_MORCC1 then
			local unit = Players[pPlayer]:InitUnit(_UNIT_MIASMRE, plotX, plotY)
		end
		if pPlayerCargo == _CARGO_MORCC2 then
			local unit = Players[pPlayer]:InitUnit(_UNIT_SOLAR, plotX, plotY)
		end
		if Cplot:IsWater() then
			if pPlayerCargo == _CARGO_ADVANCEARMA then
				local unit = Players[pPlayer]:InitUnit(_UNIT_CANONIR, plotX, plotY)
			end
		end
		
		if pPlayerSpacecraft == _SC_XGP then
			for y = 0, iH - 1 do
				for x = 0, iW - 1 do
					Fplot = Map.GetPlot(x, y)
					Distance = DistancePlots(Cplot, Fplot, _RevealRange); -- normal
					-- Distance = DistancePlots(Map.GetPlot(5, 10), Fplot, _RevealRange); -- test
					if Distance <= _RevealRange then
						if (Fplot:GetResourceType() == _res_firaxite) then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true) 	end;
						if (Fplot:GetResourceType() == _res_xenomass) then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true) 	end;
						if (Fplot:GetResourceType() == _res_floatstone) then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true) 	end;
					end
				end
			end
		end
		
		if pPlayerSpacecraft == _SC_12BD then
			for y = 0, iH - 1 do
				for x = 0, iW - 1 do
					Fplot = Map.GetPlot(x, y)
					Distance = DistancePlots(Cplot, Fplot, _RevealRange); -- normal
					-- Distance = DistancePlots(Map.GetPlot(5, 10), Fplot, _RevealRange); -- test				
					if Distance <= _RevealRange then
						-- (Game.GetResourceClassType(iResourceID) == GameInfo.ResourceClasses["RESOURCECLASS_STRATEGIC"].ID)
						-- resourceType = Fplot:GetResourceType(); 	pResource = GameInfo.Resources[resourceType];
						-- if (Fplot:HasResource() and pResource.ResourceClassType == "RESOURCECLASS_BASIC") then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true) 	end;
						if (Fplot:HasResource() and GameInfo.Resources[Fplot:GetResourceType()].ResourceClassType == "RESOURCECLASS_BASIC") then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true) 	end;
					end
				end
			end
		end
		
		if pPlayerSpacecraft == _SC_PELENG then
			for y = 0, iH - 1 do
				for x = 0, iW - 1 do
					Fplot = Map.GetPlot(x, y)
					Distance = DistancePlots(Cplot, Fplot, (_RevealRange+2)); -- normal		
					if Distance > (_RevealRange+2) then
						if (Fplot:HasImprovement() and GameInfo.Improvements[Fplot:GetImprovementType()].Type == "IMPROVEMENT_GOODY_HUT") then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true) 	end;
					end
				end
			end
		end
		
		if pPlayerSpacecraft == _SC_HESC then
			for y = 0, iH - 1 do
				for x = 0, iW - 1 do
					Fplot = Map.GetPlot(x, y)
					-- print("Fplot: "..x..", "..y.." Fplot:GetTerrainType() "..tostring(Fplot:GetTerrainType())); -- dbg
					-- print("Fplot: "..x..", "..y.." Fplot:GetFeatureType() "..tostring(Fplot:GetFeatureType())); -- dbg

					if (Fplot:GetFeatureType() == _fea_ice) then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true)
					elseif (Fplot:GetFeatureType() == _fea_crater) then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true)
					end;

					if Fplot:IsMountain() then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true)
					elseif Fplot:IsCanyon() then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true)
					end;					

				end
			end
		end
		
		if pPlayerSpacecraft == _SC_RESNR then
			for y = 0, iH - 1 do
				for x = 0, iW - 1 do
					Fplot = Map.GetPlot(x, y)
					-- print("Fplot: "..x..", "..y.." Fplot:GetTerrainType() "..tostring(Fplot:GetTerrainType())); -- dbg
					-- print("Fplot: "..x..", "..y.." Fplot:GetFeatureType() "..tostring(Fplot:GetFeatureType())); -- dbg

					if (Fplot:GetFeatureType() == _fea_reef) then Fplot:SetRevealed(Players[pPlayer]:GetTeam(), true) end;

				end
			end
		end
		
		if pPlayerSpacecraft == _SC_DIPMIS then
			gameSpeedType = Game.GetGameSpeedType();
			-- print("gameSpeedType ="..tostring(gameSpeedType)); -- dbg	
			_speedscale = GameInfo.GameSpeeds[gameSpeedType].EnergyPercent;
			-- print("_speedscale ="..tostring(_speedscale)); -- dbg
			for row in GameInfo.Spacecraft_GrantedYield() do
				-- print("row.SpacecraftType ="..tostring(row.SpacecraftType)); -- dbg
				-- local _t = GameInfo.Spacecraft["SPACECRAFT_DIPLOMATIC_MISSION"].Type;
				-- print("GameInfo.Spacecraft[SPACECRAFT_DIPLOMATIC_MISSION].Type ="..tostring(_t)); -- dbg
				if row.SpacecraftType == GameInfo.Spacecraft["SPACECRAFT_DIPLOMATIC_MISSION"].Type then
					_grantedamount = row.Yield;
					_grantedamount = _grantedamount * _speedscale / 100;
					Players[pPlayer]:ChangeDiplomaticCapital(_grantedamount);
				end
			end	
		end
		]]--
		
		--MGH:
		--[[
		if pPlayerCargo == _CG_MXHTS then
			local artifact = ArtifactUtilities.ChooseArtifactFromCategory(pPlayer, GameInfo.ArtifactCategories["ARTIFACT_CATEGORY_OLD_EARTH"].ID);
			Players[pPlayer]:AddArtifact(artifact);
			
		end]]--
	-- end
	
end

------------------------------------------------------------------
-- Serv to reveal map by SPACECRAFT_SIGNATURE_DETECTOR Loadout
function SignatureDetectorReveal(heroLandmarkType, teamType, plotIndex)
	print("SignatureDetectorReveal start -- heroLandmarkType="..tostring(heroLandmarkType).." teamType="..tostring(teamType).." plotIndex="..tostring(plotIndex)); -- dbg

	if GameInfo.Spacecraft["SPACECRAFT_SIGNATURE_DETECTOR"] == nil then return; end --MGH: Check if exists

	-- predefined vars
	local marvelType;
	for marvelInfo  in GameInfo.Marvels() do
		local marvelHeroLandmarkType = GameInfo.HeroLandmarks[marvelInfo.MajorMarvelLandmark].ID;
		if(marvelHeroLandmarkType == heroLandmarkType) then
			-- print("marvelInfo.ID = "..tostring(marvelInfo.ID)); -- dbg
			-- return marvelInfo.ID;
			marvelType = marvelInfo.ID
		end
	end
	local minorMarvelImprovementType = GameInfo.Improvements[GameInfo.Marvels[marvelType].MinorMarvelImprovement].Type;
	-- print("minorMarvelImprovementType = "..tostring(minorMarvelImprovementType)); -- dbg

	-- local pPlayerSpacecraft = PreGame.GetLoadoutSpacecraft(pPlayer)
	local iW, iH = Map.GetGridSize();

	-- GameData Table Objects
	local _SC_SiDet = GameInfo.Spacecraft["SPACECRAFT_SIGNATURE_DETECTOR"].ID;

	-- vars in use
	-- local Fplot, Distance, resourceType, pResource;
	local Fplot, player , pPlayerSpacecraft;

	for y = 0, iH - 1 do
		for x = 0, iW - 1 do
			Fplot  = Map.GetPlot(x, y)
			if (Fplot:HasImprovement() and Fplot:GetImprovementType() == GameInfoTypes[minorMarvelImprovementType]) then	
				for playerType = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
					player = Players[playerType];
					pPlayerSpacecraft = PreGame.GetLoadoutSpacecraft(playerType);
					if player:IsAlive() and (pPlayerSpacecraft == _SC_SiDet) then
						print("Fplot: "..x..", "..y.." revealed for player "..playerType); -- dbg
						Fplot:SetRevealed(player:GetTeam(), true);
					end
				end
			end
		end
	end
end

------------------------------------------------------------------
function LoadoutEffectsAsBuildingsCityCreated(pPlayer, plotX, plotY)
print("LoadoutEffectsAsBuildingsCityCreated start -- pPlayer="..tostring(pPlayer).." plotX="..tostring(plotX).." plotY="..tostring(plotY)); -- dbg
	-- Serv to manage effects from Loadout
	-- deal with single added LA effect
	-- worked both when captured and created city
	
	-- check if the Module has an Effect
	-- 		if yes, then count the effect type
	-- 		remove the building of this effect type
	-- add the building of this effect type
	-- 		if no, then count every possible effect type
	-- 		remove the building of this effect type
	
	-- GameData Table Objects	
	-- Prepare HQ checking
	local pPlayerHQ = Players[pPlayer]:GetCapitalCity();	
	local plot = Map.GetPlot(plotX, plotY);
	local cityID = plot:GetPlotCity();
	-- vars in use
	local BuildingTypeToAdd;

	-- predefined vars
	local pPlayerColonists = PreGame.GetLoadoutColonist(pPlayer);	-- returns ID
	local info_Colonist = GameInfo.Colonists[pPlayerColonists];
	local LoadoutColonistType = info_Colonist.Type;
	
	local pPlayerCargo = PreGame.GetLoadoutCargo(pPlayer)
	local info_Cargo = GameInfo.Cargo[pPlayerCargo];
	local LoadoutCargoType = info_Cargo.Type;
	
	local pPlayerSpacecraft = PreGame.GetLoadoutSpacecraft(pPlayer)
	-- print("LoadoutColonistType: "..tostring(LoadoutColonistType)); -- dbg

	-- nullify all effects, if captured
	for row in GameInfo.Colonist_EffectAsBuilding() do
		-- print("LoadoutEffectsAsBuildings nullify: "..tostring(row.BuildingType)); -- dbg
		BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
		print("BuildingTypeToAdd "..tostring(BuildingTypeToAdd).." cityID "..tostring(cityID)); -- dbg
		cityID:SetNumRealBuilding(BuildingTypeToAdd, 0);
	end	
	for row in GameInfo.Colonist_EffectAsSingleBuilding() do
		-- print("LoadoutEffectsAsBuildings nullify: "..tostring(row.BuildingType)); -- dbg
		BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
		cityID:SetNumRealBuilding(BuildingTypeToAdd, 0);
	end	
	
	-- EffectAsSingleBuilding
	if cityID == pPlayerHQ then
		print("cityID == pPlayerHQ "); -- dbg
		for row in GameInfo.Cargo_EffectAsSingleBuilding{ CargoType = LoadoutCargoType } do
			BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
			print("BuildingTypeToAdd "..tostring(BuildingTypeToAdd).." cityID "..tostring(cityID)); -- dbg
			cityID:SetNumRealBuilding(BuildingTypeToAdd, 1);
		end	
		for row in GameInfo.Colonist_EffectAsSingleBuilding{ ColonistType = LoadoutColonistType } do
			BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
			print("BuildingTypeToAdd "..tostring(BuildingTypeToAdd).." cityID "..tostring(cityID)); -- dbg
			cityID:SetNumRealBuilding(BuildingTypeToAdd, 1);
		end	
	end
	
	-- EffectAsBuilding
	for row in GameInfo.Colonist_EffectAsBuilding{ ColonistType = LoadoutColonistType } do
		-- local BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType];
		-- print("row.BuildingType: "..tostring(row.BuildingType)); -- dbg
		BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
		cityID:SetNumRealBuilding(BuildingTypeToAdd, 1);
		-- Events.SpecificCityInfoDirty(pPlayer, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_BANNER);
		-- Events.SpecificCityInfoDirty(pPlayer, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_PRODUCTION);
		-- Events.SerialEventGameDataDirty();
	end		
end

function LoadoutEffectsAsBuildingsCityCaptured(cityX, cityY, pPlayer)
print("LoadoutEffectsAsBuildingsCityCaptured start -- cityX="..tostring(cityX).." cityY="..tostring(cityY).." pPlayer="..tostring(pPlayer)); -- dbg
	-- Serv to manage effects from Loadout
	-- deal with single added LA effect
	-- Nullify was done by Created func
	
	-- GameData Table Objects
	
	-- Prepare HQ checking
	local pPlayerHQ = Players[pPlayer]:GetCapitalCity();	
	local plot = Map.GetPlot(cityX, cityY);
	local cityID = plot:GetPlotCity();
	local PreviousOwner = cityID:GetPreviousOwner();
	local PreviousOwnerNewHQ = Players[PreviousOwner]:GetCapitalCity();
	-- print("PreviousOwner: "..tostring(PreviousOwner).." PreviousOwnerNewHQ "..tostring(PreviousOwnerNewHQ)); -- dbg
	
	-- vars in use
	local BuildingTypeToAdd;

	-- predefined vars
	local pPlayerColonists = PreGame.GetLoadoutColonist(pPlayer);	-- returns ID
	local info_Colonist = GameInfo.Colonists[pPlayerColonists];
	local LoadoutColonistType = info_Colonist.Type;
	
	local pPlayerCargo = PreGame.GetLoadoutCargo(pPlayer)
	local info_Cargo = GameInfo.Cargo[pPlayerCargo];
	local LoadoutCargoType = info_Cargo.Type;
	
	local pPlayerSpacecraft = PreGame.GetLoadoutSpacecraft(pPlayer)
	-- print("LoadoutColonistType: "..tostring(LoadoutColonistType)); -- dbg
	
	-- deal with single added LA effect, when capture. 
	-- 1. Captured HQ. Add to previous owner new HQ;
	-- GetPreviousOwner
	-- IsCapital
	-- Cities
	if Players[PreviousOwner]:GetNumCities() > 0 and PreviousOwnerNewHQ ~= nil then
		-- print("Players[PreviousOwner]:GetNumCities() > 0 and PreviousOwnerNewHQ ~= nil"); -- dbg
		for city in Players[PreviousOwner]:Cities() do
			-- print("for city "..tostring(city)); -- dbg
			for row in GameInfo.Cargo_EffectAsSingleBuilding() do
				-- print("LoadoutEffectsAsBuildings nullify: "..tostring(row.BuildingType)); -- dbg
				BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
				-- print("BuildingTypeToAdd "..tostring(BuildingTypeToAdd).." city "..tostring(city)); -- dbg
				city:SetNumRealBuilding(BuildingTypeToAdd, 0);
			end	
			for row in GameInfo.Colonist_EffectAsSingleBuilding() do
				BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
				city:SetNumRealBuilding(BuildingTypeToAdd, 0);
			end	
			if city == PreviousOwnerNewHQ then
				-- print("city == PreviousOwnerNewHQ"); -- dbg
				local PreviousPlayerCargo = PreGame.GetLoadoutCargo(PreviousOwner)
				local info_Cargo = GameInfo.Cargo[PreviousPlayerCargo];
				local LoadoutCargoType = info_Cargo.Type;
				local PreviousPlayerColonists = PreGame.GetLoadoutColonist(PreviousOwner)
				local info_Colonist = GameInfo.Cargo[PreviousPlayerColonists];
				local LoadoutColonistType = info_Colonist.Type;
				-- move to the new place
				for row in GameInfo.Cargo_EffectAsSingleBuilding{ CargoType = LoadoutCargoType } do
					BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
					city:SetNumRealBuilding(BuildingTypeToAdd, 1);
				end	
				for row in GameInfo.Colonist_EffectAsSingleBuilding{ ColonistType = LoadoutColonistType } do
					BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
					city:SetNumRealBuilding(BuildingTypeToAdd, 1);
				end	
			end
		end
	end
	
	-- 2. Recaptured HQ. Move back here;
	if cityID == pPlayerHQ then
		-- print("cityID == pPlayerHQ "); -- dbg
		for city in Players[pPlayer]:Cities() do
			for row in GameInfo.Cargo_EffectAsSingleBuilding() do
				-- print("LoadoutEffectsAsBuildings nullify: "..tostring(row.BuildingType)); -- dbg
				BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
				-- print("BuildingTypeToAdd "..tostring(BuildingTypeToAdd).." city "..tostring(city)); -- dbg
				city:SetNumRealBuilding(BuildingTypeToAdd, 0);
			end	
			for row in GameInfo.Colonist_EffectAsSingleBuilding() do
				BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
				city:SetNumRealBuilding(BuildingTypeToAdd, 0);
			end	
			
		end
		-- move back here
		for row in GameInfo.Cargo_EffectAsSingleBuilding{ CargoType = LoadoutCargoType } do
			BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
			cityID:SetNumRealBuilding(BuildingTypeToAdd, 1);
		end	
		for row in GameInfo.Colonist_EffectAsSingleBuilding{ CargoType = LoadoutColonistType } do
			BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
			cityID:SetNumRealBuilding(BuildingTypeToAdd, 1);
		end	
	end
	
end

function TechEffectsAsBuildingsCityCreated(pPlayer, plotX, plotY)
print("TechEffectsAsBuildingsCityCreated start -- pPlayer="..tostring(pPlayer).." plotX="..tostring(plotX).." plotY="..tostring(plotY)); -- dbg
	-- Serv to manage effects from Tech
	-- deal with each row of Tech Effect table
	-- worked both when captured and created city
		
	-- Берём таблицу Technology_EffectAsBuilding
	-- Считываем каждую ячейку. 
	-- Если есть нужная технология 
	--      удалить строение этого типа эффекта
	-- 		добавляем здание эффект к базе
	-- Если нет -
	--      удалить строение этого типа эффекта
	
	-- GameData Table Objects	
	-- Prepare checking
	local pPlayerHQ = Players[pPlayer]:GetCapitalCity();	
	local CityOwnerPlayer = Players[pPlayer];
	local plot = Map.GetPlot(plotX, plotY);
	local cityID = plot:GetPlotCity();
	-- vars in use
	local BuildingTypeToAdd;
	local TechTypeToCheck;

	-- predefined vars

	-- Check Tech Effect table - add/remove Building Effect
	for row in GameInfo.Technology_EffectAsBuilding() do
		print("TechEffectsAsBuildingsCityCreated Building: "..tostring(row.BuildingType)..", Tech: "..tostring(row.TechType)); -- dbg
		BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
		TechTypeToCheck = GameInfo.Technologies[row.TechType].ID;
		
		if CityOwnerPlayer:HasTech(TechTypeToCheck) then
			print("Place BuildingTypeToAdd "..tostring(BuildingTypeToAdd).." cityID "..tostring(cityID)); -- dbg
			-- cityID:SetNumRealBuilding(BuildingTypeToAdd, 0);
			cityID:SetNumRealBuilding(BuildingTypeToAdd, 1);
		else
			print("Delete BuildingTypeToAdd "..tostring(BuildingTypeToAdd).." cityID "..tostring(cityID)); -- dbg
			cityID:SetNumRealBuilding(BuildingTypeToAdd, 0);
		end
		
	end	
	
end

-- function TechEffectsAsBuildingsTeamTechResearched(teamType, techType, change)
function TechEffectsAsBuildings_TechAcquired(eTeam, techID)
	-- print("TechEffectsAsBuildingsTeamTechResearched start -- teamType="..tostring(teamType).." techType="..tostring(techType).." change="..tostring(change)); -- dbg
	print("TechEffectsAsBuildings_TechAcquired start -- eTeam="..tostring(eTeam).." techID="..tostring(techID)); -- dbg
	-- Serv to manage effects from Tech
	-- deal with each row of Tech Effect table
	-- GameData Table Objects	
	-- Prepare checking	
	-- vars in use
	local BuildingTypeToAdd;
	local TechTypeToCheck;
	local PlayerToCheck;
	local TeamToCheck;
	
	-- Check Tech Effect table 
	for row in GameInfo.Technology_EffectAsBuilding() do
		if GameInfo.Technologies[row.TechType].ID == techID then
			-- loop through all Major Civ players
			BuildingTypeToAdd = GameInfo.Buildings[row.BuildingType].ID;
			for i = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
				PlayerToCheck = Players[i];
				TeamToCheck = PlayerToCheck:GetTeam();
				print("TechEffectsAsBuildings_TechAcquired --  "..tostring(row.TechType).. "  TeamToCheck="..tostring(TeamToCheck)); -- dbg
				if (PlayerToCheck:IsMajorCiv() and	PlayerToCheck:IsAlive()) and (TeamToCheck == eTeam) then
					print("TechEffectsAsBuildings_TechAcquired Right Team"); -- dbg
					for city in PlayerToCheck:Cities() do
						city:SetNumRealBuilding(BuildingTypeToAdd, 1);
					end
				end
			end
		end
	end
	
end 

function CityCreatedChecks(pPlayer, plotX, plotY)
	print("CityCreatedChecks start -- "); -- dbg
	-- All checkings which should be done usually
	
	-- Prepare HQ checking
	local pPlayerHQ = Players[pPlayer]:GetCapitalCity();
	local plot = Map.GetPlot(plotX, plotY);
	local cityID = plot:GetPlotCity();
	
	-- Loadout effects at the start
	if cityID == pPlayerHQ then
		LoadoutStartEffect(pPlayer, plotX, plotY);
	end
	
	-- Loadout effects of colonists
	if 1==1 then
		LoadoutEffectsAsBuildingsCityCreated(pPlayer, plotX, plotY);
	end
	
	-- Technology effects as buildings
	if 1==1 then
		TechEffectsAsBuildingsCityCreated(pPlayer, plotX, plotY);
	end
end

function CityCapturedChecks(cityX, cityY, pPlayer)
	print("CityCapturedChecks start -- "); -- dbg
	-- All checkings which should be done usually
	
	-- Loadout effects of colonists
	if 1==1 then
		LoadoutEffectsAsBuildingsCityCaptured(cityX, cityY, pPlayer);
	end
end

function TechAcquiredChecks( eTeam, techID )
-- function TeamTechResearchedChecks( teamType, techType, change )
	print("TechAcquiredChecks start -- "); -- dbg
	-- All checkings which should be done usually
	
	-- Technology effects as buildings
	if 1==1 then
		-- TechEffectsAsBuildingsTeamTechResearched(teamType, techType, change);
		TechEffectsAsBuildings_TechAcquired(eTeam, techID);
	end
	
end

--function GameStartedChecks( pPlayer )
function GameStartedChecks(  )
	print("GameStartedChecks start -- pPlayer="..tostring(pPlayer)); -- dbg
end

function ActivatePlayersChecks( pPlayer )
--function ActivatePlayersChecks(  )
	print("ActivatePlayersChecks start -- pPlayer="..tostring(pPlayer)); -- dbg
end

-------------------------------------------------------------------

function NestDestroyedTurnSave(killingPlayerType, plotX, plotY)
	-- 
	local NestDestroyedTurn = Game.GetGameTurn();
	print("NestDestroyedTurnSave start -- killingPlayerType="..tostring(killingPlayerType).." plotX="..tostring(plotX).." plotY="..tostring(plotY)..", TURN "..NestDestroyedTurn); -- dbg
	local CellName = "DestroyedNest_x"..plotX.."_y"..plotY;
	ModSaveDB.SetValue(CellName, NestDestroyedTurn)
	
	-- DBG PRINT
	if 1 == 0 then
		print("EventControl.lua NestDestroyedTurnSave"); -- dbg
		print("//----------- DBG PRINT DESTROYED NESTS SAVE DB -----------//"); -- dbg
		local iW, iH = Map.GetGridSize();
		local j = 1;
		for y = 0, iH - 1 do
			for x = 0, iW - 1 do
				local SearchCellName = ModSaveDB.GetValue("DestroyedNest_x"..x.."_y"..y)
				if SearchCellName then
					print(j..". Nest on "..tostring(x)..", "..tostring(y).." was destroyed at "..SearchCellName); --
					j = j+1;
				end
			end
		end
		print("//----------- DBG PRINT DESTROYED NESTS SAVE DB -----------//"); -- dbg
	end
end
-------------------------------------------------------------------

GameEvents.CityCreated.Add(CityCreatedChecks); -- Starts when captured too!!!
--IsFoundedFirstCity -- practice this method Player
GameEvents.CityCaptureComplete.Add(CityCapturedChecks); -- Starts when HQ relocated.
-- Events.SerialEventCityCreated.Add function OnCityCreated( hexPos, playerID, cityID, cultureType, eraType, continent, size, fowState )

-----------------------------------------------
-- SignatureDetectorReveal loadout type script
-- starts when somebody founded the MajorMarvel
if (NO_MARVELS == false) then GameEvents.HeroLandmarkVisible.Add(SignatureDetectorReveal); end;

-----------------------------------------------
--Events.SerialEventStartGame.Add( GameStartedChecks );
--GameEvents.ActivatePlayers.Add( ActivatePlayersChecks );

Events.TechAcquired.Add( TechAcquiredChecks );	-- starts when tech acuired, by science, spoils of war, spies.
-- GameEvents.TeamTechResearched.Add( TeamTechResearchedChecks );

-- A system to save a date of destroyed nest
GameEvents.AlienNestDestroyed.Add(NestDestroyedTurnSave);



----------------------------------------------------
function AlienColonistTracking(playerType, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, fogState, selected, military, notInvisible, isLoading, embarkChange)
	if playerType == 62 then
		local gridPosX, gridPosY = ToGridFromHex( hexVec.x, hexVec.y );
		local unit = Players[playerType]:GetUnitByID(unitID);
		local DBType;
		if unit ~= nil then
			-- DBType = unit:GetUnitType();
			DBType = GameInfo.Units[unit:GetUnitType()].Type;
		end
		-- print("AlienColonistTracking(playerType "..tostring(playerType)..", DBType "..tostring(DBType)..", unitID "..tostring(unitID)..", gridPosX "..tostring(gridPosX)..", gridPosY "..tostring(gridPosY)..", unitType "..tostring(unitType)..", cultureType "..tostring(cultureType)..", civID "..tostring(civID)..", primaryColor "..tostring(primaryColor)..", secondaryColor "..tostring(secondaryColor)..", fogState "..tostring(fogState)..", selected "..tostring(selected)..", military "..tostring(military)..", notInvisible "..tostring(notInvisible)..", isLoading "..tostring(isLoading)..", embarkChange "..tostring(embarkChange)); -- dbg
		
		-- unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_ALIEN_STAGE_2_1"].ID, true)
		-- unit:SetHasPromotion(GameInfo.UnitPromotions["PROMOTION_COMBATHEAL_BOOST_1"].ID, true)
		
		if "UNIT_SETTLER" == DBType then
			print("--------------"); -- dbg
			print("--------------"); -- dbg
			print("--------------"); -- dbg
			print("AlienColonistTracking! WARNING IT'S HAPPEND AGAIN at "..tostring(gridPosX)..", "..tostring(gridPosY)); -- dbg
			print("--------------"); -- dbg
			print("--------------"); -- dbg
			print("--------------"); -- dbg
		end
	end	
end

-- A system to track out bug of Alien Colonists
Events.SerialEventUnitCreated.Add(AlienColonistTracking);