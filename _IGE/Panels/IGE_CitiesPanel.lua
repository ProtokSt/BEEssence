-- Released under GPL v3
--------------------------------------------------------------
include("IGE_API_All");
include("InfoTooltipInclude");
local _dpo = true;
--_dpo = false;
print("IGE_CitiesPanel");
IGE = nil;

local normalBuildings = {};
local wonders = {};
local nationalWonders = {};
local artifactBuildings = {};
local harmony = {};
local supremacy = {};
local purity = {};

local groupInstances = {};
local buildingsItemManager = CreateInstanceManager("BuildingGroupInstance", "SubStack", Controls.ScrolllStack );
local unitsManager = CreateInstanceManager("ListItemInstance", "Button", Controls.UnitsOnPlotList );

local affinityItemManager = CreateInstanceManager("BuildingGroupInstance", "SubStack", Controls.AffinityBuildings );

local normalBuildingManager = CreateInstanceManager("ListItemInstance", "Button", Controls.BuildingContainer);
local wondersManager = CreateInstanceManager("ListItemInstance", "Button", Controls.wondersGroupInstance);
local nationalWondersManager = CreateInstanceManager("ListItemInstance", "Button", Controls.nationalWondersGroupInstance);
if IGE_HasRisingTide then
	artifactBuildingsManager = CreateInstanceManager("ListItemInstance", "Button", Controls.artifactBuildingsGroupInstance);
	artifactBuildingsManager.maxHeight = g_listsSizeY;
end
local harmonyManager = CreateInstanceManager("ListItemInstance", "Button", Controls.harmonyInstance);
local supremacyManager = CreateInstanceManager("ListItemInstance", "Button", Controls.supremacyInstance);
local purityManager = CreateInstanceManager("ListItemInstance", "Button", Controls.purityInstance);
local groups = {};
local affinitygroups = {};

normalBuildingManager.maxHeight = g_listsSizeY;
wondersManager.maxHeight = g_listsSizeY;
nationalWondersManager.maxHeight = g_listsSizeY;

harmonyManager.maxHeight = g_listsSizeY;
supremacyManager.maxHeight = g_listsSizeY;
purityManager.maxHeight = g_listsSizeY;
unitsManager.maxButtonHeight = 50;


local data = {};
local isVisible = false;
local isTeleporting = false;
local currentPlot = nil;
local currentCity = nil;
local currentUnit = nil;
local currentUnitIndex = 0;
local currentReligion = 0;
local teleportationStartPlot = nil;
g_IGESelectedUpgrade = nil;
g_IGESelectedPerk = nil;

--===============================================================================================
-- CORE EVENTS
--===============================================================================================
local function OnSharingGlobalAndOptions(_IGE)
	IGE = _IGE;
end
LuaEvents.IGE_SharingGlobalAndOptions.Add(OnSharingGlobalAndOptions);

function CreateGroup(theControl, name)
	local theInstance = buildingsItemManager:GetInstance();
	if theInstance then
		theInstance.Header:SetText(name);
		theControl:ChangeParent(theInstance.List);
		groups[name] = { instance = theInstance, control = theControl, visible = true };
	end
end

function CreateAffinityGroup(theControl, name)
	local theInstance = affinityItemManager:GetInstance();
	if theInstance then
		theInstance.Header:SetText(name);
		theInstance.HeaderBackground:SetSizeX(affinityPanelX);
		theControl:ChangeParent(theInstance.List);
		affinitygroups[name] = { instance = theInstance, control = theControl, visible = true };
	end
end

-------------------------------------------------------------------------------------------------
function OnInitialize()
	SetUnitsData(data, {});
	SetBuildingsData(data, {});	

	-- Controls Auto resize
	Controls.OuterContainer:SetSizeVal(g_panelSizeX, g_panelSizeY);
	Controls.Container:SetSizeVal(g_panelSizeX, g_panelSizeY);
	Controls.ScrollPanel:SetSizeVal(g_panelSizeX, g_panelSizeY - 10);

	Controls.ScrolllStack:SetSizeVal(g_panelSizeX, g_panelSizeY);
	Controls.Stack:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);	

	Controls.UnitCitySeparator:SetSizeY(g_panelSizeY);
	Controls.UnitContainer:SetSizeY(g_panelSizeY - 26);
	Controls.UnitEdition:SetSizeY(g_panelSizeY - 26);
	Controls.UnitsOnPlotList:SetSizeY(g_panelSizeY - 26);

	Controls.CityEdition:SetSizeVal(g_panelSizeX - 200, g_panelSizeY - 26);
	
	Controls.CityProperties:SetSizeVal(citypanelsplitX, g_panelSizeY - 26);
	Controls.CityProperties2:SetSizeVal(citypanelsplitX, g_panelSizeY - 26);

	Controls.BuildingContainer:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);
	Controls.nationalWondersGroupInstance:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);
	Controls.wondersGroupInstance:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);
	Controls.artifactBuildingsGroupInstance:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);

	Controls.AffinityBuildings:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);
	
	Controls.ScrollBar:SetSizeY(Controls.ScrollPanel:GetSizeY());
	
	CreateGroup(Controls.BuildingContainer, L("TXT_KEY_ENERGY_BUILDINGS_HEADING3_TITLE"));
	CreateAffinityGroup(Controls.harmonyInstance, L("TXT_KEY_AFFINITY_HARMONY_HEADING2_TITLE"));
	CreateAffinityGroup(Controls.supremacyInstance, L("TXT_KEY_AFFINITY_SUPREMACY_HEADING2_TITLE"));
	CreateAffinityGroup(Controls.purityInstance, L("TXT_KEY_AFFINITY_PURITY_HEADING2_TITLE"));
	CreateGroup(Controls.wondersGroupInstance, L("TXT_KEY_MODDING_CATEGORY_55"));	
	CreateGroup(Controls.nationalWondersGroupInstance, L("TXT_KEY_WONDER_SECTION_2"));
	if IGE_HasRisingTide then
		CreateGroup(Controls.artifactBuildingsGroupInstance, L("TXT_KEY_ARTIFACTS_SECTION_2"));
	else
		Controls.artifactBuildingsGroupInstance:SetHide(true);
	end
	
	-- Extract buildings and split into categories
	for _, building in ipairs(data.buildings) do
		
		if building.isWonder then
			table.insert(wonders, building);
		elseif building.isNationalWonder then
			table.insert(nationalWonders, building);
		elseif building.isArtifactBuilding then
			table.insert(artifactBuildings, building);
		elseif building.affinity ~= nil then			
			if building.affinity == "AFFINITY_TYPE_HARMONY" then
				table.insert(harmony, building);
			elseif building.affinity == "AFFINITY_TYPE_SUPREMACY" then
				table.insert(supremacy, building);
			elseif building.affinity == "AFFINITY_TYPE_PURITY" then
				table.insert(purity, building);
			else
				print("IGE_CitiesPanel: building.affinity ~= nil..... but no type matched...");
			end
		else
			table.insert(normalBuildings, building);
		end
	end
	
	local tt = L("TXT_KEY_IGE_CITIES_AND_UNITS_PANEL_HELP");
	LuaEvents.IGE_RegisterTab("CITIES_AND_UNITS",  L("TXT_KEY_IGE_CITIES_AND_UNITS_PANEL"), 1, "edit",  tt)
end
LuaEvents.IGE_Initialize.Add(OnInitialize);

-------------------------------------------------------------------------------------------------
function OnSelectedPanel(ID)
	isVisible = (ID == "CITIES_AND_UNITS");
	OnMoveUnitCancelButtonClick();
end
LuaEvents.IGE_SelectedPanel.Add(OnSelectedPanel);

-------------------------------------------------------------------------------------------------
function OnSelectedPlot(plot)
	currentUnitIndex = 0;
	currentPlot = plot;
end
LuaEvents.IGE_SelectedPlot.Add(OnSelectedPlot);

--===============================================================================================
-- UPDATE
--===============================================================================================
local function UpdateUnits()
	local count = currentPlot:GetNumUnits();
	Controls.UnitEdition:SetHide(count == 0);
	Controls.NoUnitOnPlot:SetHide(count ~= 0);
	if count == 0 then return end

	-- Update units list
	units = {};
	currentUnit = currentPlot:GetUnit(0);
	for i = 0, count - 1 do
		local pUnit = currentPlot:GetUnit(i);
		local unitID = pUnit:GetUnitType();
		local unit = data.unitsByID[unitID];
		local pOwner = Players[pUnit:GetOwner()];

		local item = {};

		-- Label
		if (pUnit:HasName()) then
			local desc = L("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", pOwner:GetCivilizationAdjectiveKey(), pUnit:GetNameKey());
			item.label = string.format("%s (%s)", pUnit:GetNameNoDesc(), desc); 
		else
			item.label = L("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", pOwner:GetCivilizationAdjectiveKey(), pUnit:GetNameKey());
		end

		local strength = pUnit:GetCombatStrength();
		if (strength > 0) then
			item.label = item.label.."[NEWLINE]"..L("TXT_KEY_EUPANEL_LOWER_STRENGTH")..": ".. pUnit:GetCombatStrength();
		end
			
		local damage = pUnit:GetDamage();
		local MaxDamage = GameDefines["MAX_HIT_POINTS"];
		if (damage > 0) then
			item.label = item.label.."[NEWLINE]" .. L("TXT_KEY_UPANEL_SET_HITPOINTS_TT", (MaxDamage-damage), MaxDamage );
		else
			item.label = item.label.."[NEWLINE]" .. L("TXT_KEY_UPANEL_SET_HITPOINTS_TT", MaxDamage, MaxDamage );
		end
		
		-- Other unit
		item.actor = pUnit;
		item.name = unit.name;
		item.subtitle = pOwner:GetCivilizationShortDescription();
		item.textureOffset = unit.textureOffset;
		item.texture = unit.texture;
		item.help = unit.help;
		item.selected = (i == currentUnitIndex);
		item.visible = true;
		item.enabled = true;
		item.index = i;

		-- Insertion
		table.insert(units, item);
		if item.selected then
			currentUnit = pUnit;
		end
	end

	local unitsListX, unitsListY = UpdateList(units, unitsManager, UnitClickHandler);
	Controls.UnitsOnPlotList:SetSizeY(unitsListY);
	Controls.UnitEdition:CalculateSize();
	Controls.UnitEdition:ReprocessAnchoring();
end

function InvalidateCity()
	if currentCity then
		local cityID = currentCity:GetID();
		local playerID = currentCity:GetOwner();
		Events.SpecificCityInfoDirty(playerID, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_BANNER);
		Events.SpecificCityInfoDirty(playerID, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_PRODUCTION);
	end
	Events.SerialEventGameDataDirty();
	OnUpdate();
end

-------------------------------------------------------------------------------------------------
function UpdateBuildingList(buildings, manager, instance, prefix)
	for _, v in ipairs(buildings) do
		local count = currentCity:GetNumRealBuilding(v.ID);
		v.label = (count > 1) and prefix..v.name.." x"..count or v.name;
		v.enabled = currentCity:CanConstruct(v.ID, 1, 1, 1) or count ~= 0;
		v.selected = count ~= 0;
	end

	local y = UpdateHierarchizedList(buildings, manager, BuildingClickHandler);
	--list height
	return y;
end

-------------------------------------------------------------------------------------------------
local function UpdateCityUI()
	currentCity = currentPlot:GetPlotCity();
	Controls.CityEdition:SetHide(currentCity == nil);
	Controls.NoCityOnPlot:SetHide(currentCity ~= nil);

	-- Hide building lists unless city is selected
	for k, v in pairs(groups) do
		v.instance.SubStack:SetHide(currentCity == nil);
	end
	for k, v in pairs(affinitygroups) do
		v.instance.SubStack:SetHide(currentCity == nil);
	end
	
	if not currentCity then return end

	UpdatePopulation(currentCity:GetPopulation());
	Controls.PuppetCityCB:SetCheck(false);
	Controls.MartialLawCB:SetCheck(false);
	Controls.NeverLostCityCB:SetCheck(false);
	Controls.ReconqueredCityCB:SetCheck(false);

	if currentCity:IsPuppet() then
		Controls.PuppetCityCB:SetCheck(true);
	elseif currentCity:IsMartialLaw() then
		Controls.MartialLawCB:SetCheck(true);
	elseif currentCity:IsNeverLost() then
		Controls.NeverLostCityCB:SetCheck(true);
	else
		Controls.ReconqueredCityCB:SetCheck(true);
	end

	Controls.CaptureCityButton:SetDisabled(IGE.currentPlayerID == currentCity:GetOwner());
	Controls.CityNameBox:SetText(currentCity:GetName());

	local normalBuildingsY =	UpdateBuildingList(normalBuildings, normalBuildingManager, BuildingContainer, "");
	local harmonyY =			UpdateBuildingList(harmony, harmonyManager, harmonyInstance, "");
	local supremacyY =			UpdateBuildingList(supremacy, supremacyManager, supremacyInstance, "");
	local purityY =				UpdateBuildingList(purity, purityManager, purityInstance, "");
	local wondersY =			UpdateBuildingList(wonders, wondersManager, wondersGroupInstance, "");
	local nationalWondersY =	UpdateBuildingList(nationalWonders, nationalWondersManager, nationalWondersGroupInstance, "");
	if IGE_HasRisingTide then
		artifactBuildingsY =	UpdateBuildingList(artifactBuildings, artifactBuildingsManager, artifactBuildingsGroupInstance, "");
	end

	-- Update groups size
	local groupCount = 0;
	local listY = g_listsSizeY;
	for k, v in pairs(groups) do
		--Set list height according to its actual size
		if v.control == Controls.BuildingContainer then
			listY = normalBuildingsY;
		elseif v.control == Controls.wondersGroupInstance then
			listY = wondersY;
		elseif v.control == Controls.nationalWondersGroupInstance then
			listY = nationalWondersY;
		elseif v.control == Controls.artifactBuildingsGroupInstance then
			listY = artifactBuildingsY;
		end
		v.instance.SubStack:SetHide(not v.visible);
		if v.visible then
			if v.control.CalculateSize then
				v.control:CalculateSize();
			end
			v.instance.HeaderBackground:SetSizeX(g_panelSizeX - 5);
			v.instance.List:SetOffsetX(10);
			v.instance.List:SetSizeY(listY);
			groupCount = groupCount + 1;
		end

		local controlSizeY = v.control:GetSizeY();
		local listSizeY = v.instance.List:GetSizeY();

		if controlSizeY ~= listSizeY then
			v.control:SetSizeY(listSizeY);
		end
	end

	-- update affinity group size
	local affinitygroupCount = 0;
	for k, v in pairs(affinitygroups) do
		--Set list height according to its actual size
		if v.control == Controls.harmonyInstance then
			listY = harmonyY;
		elseif v.control == Controls.supremacyInstance then
			listY = supremacyY;
		elseif v.control == Controls.purityInstance then
			listY = purityY;
		end
		if v.visible then
			v.instance.List:SetSizeY(listY);
			affinitygroupCount = affinitygroupCount + 1;
		end
	end
	
    Controls.ScrollPanel:CalculateInternalSize();
end

-------------------------------------------------------------------------------------------------
function OnUpdate()
	Controls.OuterContainer:SetHide(not isVisible);
	if not isVisible then return end

	if isTeleporting then
		LuaEvents.IGE_SetMouseMode(IGE_MODE_PLOP);
		Controls.MoveUnitPromptStack:SetHide(false);
		Controls.PlotSelectionPrompt:SetHide(true);
		Controls.Container:SetHide(true);
	else
		LuaEvents.IGE_SetMouseMode(IGE_MODE_EDIT_AND_PLOP);
		Controls.MoveUnitPromptStack:SetHide(true);
		Controls.PlotSelectionPrompt:SetHide(currentPlot ~= nil);
		Controls.Container:SetHide(currentPlot == nil);
	end
	if (currentPlot ~= nil) and (not isTeleporting) then 
		UpdateUnits();
		UpdateCityUI();
	end

	Controls.CityEdition:CalculateSize();
	Controls.Stack:CalculateSize();
    Controls.ScrollPanel:CalculateInternalSize();
	Controls.ScrollBar:SetSizeX(Controls.ScrollPanel:GetSizeY());

end
LuaEvents.IGE_Update.Add(OnUpdate);

-------------------------------------------------------------------------------------------------
function UnitClickHandler(unit)
	for _, v in ipairs(units) do
		v.selected = (v == unit);
		if v.selected then currentUnitIndex = unit.index end
	end
	OnUpdate();
end

-------------------------------------------------------------------------------------------------
function BuildingClickHandler(building)
	
	local count = currentCity:GetNumRealBuilding(building.ID);
	if building.noLimit then
		currentCity:SetNumRealBuilding(building.ID, count + 1);
	else
		currentCity:SetNumRealBuilding(building.ID, count == 1 and 0 or 1);
	end
	InvalidateCity();
end

-------------------------------------------------------------------------------------------------
function BuildingRightClickHandler(building)
	local count = currentCity:GetNumRealBuilding(building.ID);
	if count ~= 0 then
		currentCity:SetNumRealBuilding(building.ID, count - 1);
	end

	InvalidateCity();
end

-------------------------------------------------------------------------------------------------
function OnDisbandUnitClick()
	currentUnit:Kill();	
	Events.SerialEventGameDataDirty();
	OnUpdate();
end
Controls.DisbandUnitButton:RegisterCallback(Mouse.eLClick, OnDisbandUnitClick);

-------------------------------------------------------------------------------------------------
function OnPromoteUnitClick()
	local level = currentUnit:GetLevel();
	local nextLevel = level + 1;
	if currentUnit:CanAcquireLevel(nextLevel) then
		local XPNeededForLevel = currentUnit:ExperienceNeededForLevel(nextLevel);
		currentUnit:SetExperience(XPNeededForLevel);
		currentUnit:TestPromotionReady();
	else
		print("Unable to promote unit: type: currentLevel: nextLEvel: ",currentUnit.Type, level, nextLevel);
	end
	Events.SerialEventGameDataDirty();
	OnUpdate();
end
Controls.PromoteUnitButton:RegisterCallback(Mouse.eLClick, OnPromoteUnitClick);

-------------------------------------------------------------------------------------------------
function OnHealUnitClick()
	currentUnit:SetDamage(0);
	OnUpdate();
end
Controls.HealUnitButton:RegisterCallback(Mouse.eLClick, OnHealUnitClick);

-------------------------------------------------------------------------------------------------
function OnCityNameChange(name)
	currentCity:SetName(name);
	OnUpdate();
end
Controls.CityNameBox:RegisterCallback(OnCityNameChange);

-------------------------------------------------------------------------------------------------
function OnDisbandCityClick()
	local playerID = currentCity:GetOwner();
	local pPlayer = Players[playerID];
	--pPlayer:Disband(currentCity);	
	local plot = currentCity:Plot()
	local hexpos = ToHexFromGrid(Vector2(plot:GetX(), plot:GetY()));
	local cityID = currentCity:GetID()
	currentCity:Kill();
	Events.SerialEventCityDestroyed(hexpos, playerID, cityID, -1)
	Events.SerialEventGameDataDirty();
	OnUpdate();
end
Controls.DisbandCityButton:RegisterCallback(Mouse.eLClick, OnDisbandCityClick);

-------------------------------------------------------------------------------------------------
function OnCaptureCityClick()
	if IGE.currentPlayerID ~= currentCity:GetOwner() then
		local pPlayer = Players[IGE.currentPlayerID];
		pPlayer:AcquireCity(currentCity);	
	end
	InvalidateCity();
end
Controls.CaptureCityButton:RegisterCallback(Mouse.eLClick, OnCaptureCityClick);

-------------------------------------------------------------------------------------------------
function OnHealCityClick()
	currentCity:SetDamage(0);
	InvalidateCity();
end
Controls.HealCityButton:RegisterCallback(Mouse.eLClick, OnHealCityClick);

-------------------------------------------------------------------------------------------------
function OnHurryProductionCityClick()
	local prod = currentCity:GetProductionNeeded();
	currentCity:SetProduction(prod);
	InvalidateCity();
end
Controls.HurryCityButton:RegisterCallback(Mouse.eLClick, OnHurryProductionCityClick);

-------------------------------------------------------------------------------------------------
function OnExpandBordersCityClick()
	local playerTeamID = IGE.currentPlayer:GetTeam();
	local currentCulture = currentCity:GetCultureStored();
	local cultureNeeded = currentCity:GetCultureThreshold();
	local nextCulture = 0;

	-- Store revealed plots
	local revealed = {}
	for i = 0, Map.GetNumPlots()-1, 1 do
		local plot = Map.GetPlotByIndex(i)
		revealed[i] = plot:IsRevealed(playerTeamID, false)
	end	

	-- Looks like this command doesn't work in BE
	--currentCity:DoJONSCultureLevelIncrease();

	--Adds stored culture to city which will cause it to expand on next turn
	local cultureDiff = cultureNeeded - currentCulture;
	nextCulture = currentCulture + cultureDiff;
	currentCity:SetCultureStored(nextCulture);

	-- Update fog on plots that have just been revealed
	for i = 0, Map.GetNumPlots()-1, 1 do
		local plot = Map.GetPlotByIndex(i);
		if plot:IsRevealed(playerTeamID, false) ~= revealed[i] then
			plot:UpdateFog();
			local hexpos = ToHexFromGrid(Vector2(plot:GetX(), plot:GetY()));
			Events.HexFOWStateChanged(hexpos, true, false);
		end
	end

	-- Invalidate UI for the city
	InvalidateCity();
end
Controls.ExpandCityButton:RegisterCallback(Mouse.eLClick, OnExpandBordersCityClick);

-------------------------------------------------------------------------------------------------
function OnSetEnergyDevelopClick()
	if _dpo then print("OnSetEnergyDevelopClick ") end
	--Game.CityPushOrder(currentCity, OrderTypes.ORDER_MAINTAIN, 0, false, not false, true);
	--CityPushOrder		.CityPushOrder	void	City:pkCity	OrderTypes:eOrder	int:iData	[bool:bAlt:false]	[bool:bShift:false]	[bool:bCtrl:false]
	--currentCity:PushOrder(OrderTypes.ORDER_MAINTAIN, 0, 0, 1, false, not false, true);
	--PushOrder		:PushOrder	nil				OrderTypes:eOrder	int:iData1	int:iData2	int:bSave	bool:bPop	bool:bAppend	[bool:bForce:false]
	currentCity:SetProduction(0);
	InvalidateCity();
end
Controls.SetEnergyDevelopButton:RegisterCallback(Mouse.eLClick, OnSetEnergyDevelopClick);

-------------------------------------------------------------------------------------------------
function OnPuppetCityCBChanged()
	currentCity:SetNeverLost(false);
	currentCity:IsMartialLaw(true);
	currentCity:SetPuppet(true);
	currentCity:SetProductionAutomated(true);
	InvalidateCity();
end
Controls.PuppetCityCB:RegisterCallback(Mouse.eLClick, OnPuppetCityCBChanged);

-------------------------------------------------------------------------------------------------
function OnMartialLawCBChanged()
	currentCity:SetNeverLost(false);
	currentCity:SetPuppet(false);
	currentCity:IsMartialLaw(true);
	InvalidateCity();
end
Controls.MartialLawCB:RegisterCallback(Mouse.eLClick, OnMartialLawCBChanged);

-------------------------------------------------------------------------------------------------
function OnNeverLostCityCBChanged()
	currentCity:SetPuppet(false);
	currentCity:IsMartialLaw(false);
	currentCity:SetNeverLost(true);
	InvalidateCity();
end
Controls.NeverLostCityCB:RegisterCallback(Mouse.eLClick, OnNeverLostCityCBChanged);

-------------------------------------------------------------------------------------------------
function OnReconqueredCityCBChanged()
	currentCity:SetPuppet(false);
	currentCity:IsMartialLaw(false);
	currentCity:SetNeverLost(false);
	InvalidateCity();
end
Controls.ReconqueredCityCB:RegisterCallback(Mouse.eLClick, OnReconqueredCityCBChanged);

-------------------------------------------------------------------------------------------------
function OnMoveUnitButtonClick()
	teleportationStartPlot = currentPlot;
	isTeleporting = true;
	OnUpdate();
end
Controls.MoveUnitButton:RegisterCallback(Mouse.eLClick, OnMoveUnitButtonClick);

-------------------------------------------------------------------------------------------------
function OnMoveUnitCancelButtonClick()
	teleportationStartPlot = nil;
	isTeleporting = false;
	OnUpdate();
end
Controls.MoveUnitCancelButton:RegisterCallback(Mouse.eLClick, OnMoveUnitCancelButtonClick);

-------------------------------------------------------------------------------------------------
function ResetUnitButtonClick()
	-- reset unit moves/attacks
	if (currentUnit ~= nil) then
		currentUnit:SetMoves(currentUnit:MaxMoves());
		currentUnit:SetMadeAttack(false);
	end
	OnUpdate();
end
Controls.ResetUnitButton:RegisterCallback(Mouse.eLClick, ResetUnitButtonClick);

-------------------------------------------------------------------------------------------------
function OnPlop(button, plot)
	if not isVisible then return end

	if isTeleporting then
		if plot:GetX() ~= currentUnit:GetX() or plot:GetY() ~= currentUnit:GetY() then
			currentUnit:SetXY(plot:GetX(), plot:GetY());
		end
		isTeleporting = false;
		OnUpdate();
	else
		if plot:GetPlotCity() == nil then
			IGE.currentPlayer:InitCity(plot:GetX(), plot:GetY());
			Events.SerialEventGameDataDirty();
		end
	end
end
LuaEvents.IGE_Plop.Add(OnPlop);

-------------------------------------------------------------------------------------------------
function InputHandler(uiMsg, wParam, lParam)
	if isVisible and isTeleporting then
		if uiMsg == KeyEvents.KeyDown and wParam == Keys.VK_ESCAPE then
			OnMoveUnitCancelButtonClick();
			return true;
		end
	end

	return false;
end
ContextPtr:SetInputHandler(InputHandler);

------------------------------------------------------------------------------------------------
UpdatePopulation = HookNumericBox("Population", 
	function() return currentCity:GetPopulation() end, 
	function(amount) 
		if amount ~= currentCity:GetPopulation() then
			currentCity:SetPopulation(amount, true)
			LuaEvents.IGE_Update();
		end
	end, 
	0, nil, 1);
