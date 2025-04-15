-- Released under GPL v3
--------------------------------------------------------------
include("IGE_API_All");
print("IGE_UnitsPanel");
IGE = nil;

local groupInstances = {};
local unitItemManager = CreateInstanceManager("GroupInstance", "SubStack", Controls.UnitsContainer );
local regularUnitManager = CreateInstanceManager("ListItemInstance", "Button", Controls.regularUnits );
local civilianUnitManager = CreateInstanceManager("ListItemInstance", "Button", Controls.civilianUnits );
local affinityItemManager = CreateInstanceManager("GroupInstance", "SubStack", Controls.AffinityContainer );
local harmonyUnitManager = CreateInstanceManager("ListItemInstance", "Button", Controls.harmonyUnits );
local supremacyUnitManager = CreateInstanceManager("ListItemInstance", "Button", Controls.supremacyUnits );
local purityUnitManager = CreateInstanceManager("ListItemInstance", "Button", Controls.purityUnits );
local orbitalUnitManager = CreateInstanceManager("ListItemInstance", "Button", Controls.orbitalUnits );
local alienUnitManager = CreateInstanceManager("ListItemInstance", "Button", Controls.alienUnits );

regularUnitManager.maxHeight = g_listsSizeY;
civilianUnitManager.maxHeight = g_listsSizeY;
harmonyUnitManager.maxHeight = g_listsSizeY;
supremacyUnitManager.maxHeight = g_listsSizeY;
purityUnitManager.maxHeight = g_listsSizeY;
orbitalUnitManager.maxHeight = g_listsSizeY;
alienUnitManager.maxHeight = g_listsSizeY;

local groups = {};
local affinitygroups = {};

local data = {};
local isVisible = false;
local currentUnit = nil;
local currentLevel = 1;

--===============================================================================================
-- CORE EVENTS
--===============================================================================================
local function OnSharingGlobalAndOptions(_IGE)
	IGE = _IGE;
end
LuaEvents.IGE_SharingGlobalAndOptions.Add(OnSharingGlobalAndOptions);

function CreateGroup(theControl, name)
	local theInstance = unitItemManager:GetInstance();
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
	print("IGE_UnitsPanel.OnInitialize");
	SetUnitsData(data);

	Controls.Container:SetSizeVal(g_panelSizeX, g_panelSizeY);
	Controls.ScrollPanel:SetSizeVal(g_panelSizeX, g_panelSizeY - 10);
	Controls.UnitsContainer:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);
	Controls.AffinityContainer:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);
	Controls.ScrollBar:SetSizeY(Controls.ScrollPanel:GetSizeY());
	
	CreateGroup(Controls.civilianUnits, L("TXT_KEY_IGE_CIVILIAN_UNITS"));
	CreateGroup(Controls.regularUnits, L("TXT_KEY_COMBAT_HEADING1_TITLE"));
	CreateAffinityGroup(Controls.harmonyUnits, L("TXT_KEY_AFFINITY_HARMONY_HEADING2_TITLE"));
	CreateAffinityGroup(Controls.supremacyUnits, L("TXT_KEY_AFFINITY_SUPREMACY_HEADING2_TITLE"));
	CreateAffinityGroup(Controls.purityUnits, L("TXT_KEY_AFFINITY_PURITY_HEADING2_TITLE"));
	CreateGroup(Controls.orbitalUnits, L("TXT_KEY_ORBITAL_UNIT_HEADING2_TITLE"));	
	CreateGroup(Controls.alienUnits, L("TXT_KEY_BARBARIAN_BARBARIANS_HEADING2_TITLE"));

	local tt = L("TXT_KEY_IGE_UNITS_PANEL_HELP");
	LuaEvents.IGE_RegisterTab("UNITS", L("TXT_KEY_IGE_UNITS_PANEL"), 2, "paint",  tt, currentUnit)
	print("IGE_UnitsPanel.OnInitialize - Done");
end
LuaEvents.IGE_Initialize.Add(OnInitialize)

-------------------------------------------------------------------------------------------------
function OnSelectedPanel(ID)
	isVisible = (ID == "UNITS");
end
LuaEvents.IGE_SelectedPanel.Add(OnSelectedPanel);

-------------------------------------------------------------------------------------------------
function CreateUnit(plot)
	local pUnit;
	local pPlayer = Players[IGE.currentPlayerID];
	pUnit = pPlayer:InitUnit(currentUnit.ID, plot:GetX(), plot:GetY());	
	-- Level/Promotion
	if currentLevel ~= 1 and not currentUnit.isOrbital then
		-- Test if unit can reach set level
		if not pUnit:CanAcquireLevel(currentLevel) then
			for i=currentLevel, 1, -1 do 
				print(i);
				local test = pUnit:CanAcquireLevel(i);
				if test then
					currentLevel = i;
					break;
				end
			end
		end
		-- Give promotion
		local XPNeededForLevel = pUnit:ExperienceNeededForLevel(currentLevel);
		pUnit:SetExperience(XPNeededForLevel);
		pUnit:TestPromotionReady();
	end
end

-------------------------------------------------------------------------------------------------
function OnPlop(mouseButtonDown, plot, shift)
	if not isVisible then return end

	if not shift then
		CreateUnit(plot);
	else
		-- Kill top unit
		local count = plot:GetNumUnits();
		if count > 0 then
			local pUnit = plot:GetUnit(count - 1);
			pUnit:Kill();
		end
	end
end
LuaEvents.IGE_Plop.Add(OnPlop);

-------------------------------------------------------------------------------------------------
function ClickHandler(unit)
	currentUnit = unit;
	OnUpdate();
	LuaEvents.IGE_SetTabData("UNITS", currentUnit);
end

--===============================================================================================
-- UPDATE
--===============================================================================================
UpdateLevel = HookNumericBox("Level", 
	function() return currentLevel end, 
	function(amount) currentLevel = amount end, 
	1, nil, 1);

-------------------------------------------------------------------------------------------------
function UpdateUnitList(units, itemManager, instance)
	for _, unit in ipairs(units) do 
		--Check whether units have been upgraded, if so, update tooltip info for unit
		local activePlayer = Players[IGE.currentPlayerID];
		local bestUpgrade = activePlayer:GetBestUnitUpgrade(unit.ID);
		if bestUpgrade ~= -1 then
			local bestUpgradeInfo = GameInfo.UnitUpgrades[bestUpgrade];
			if (bestUpgradeInfo ~= nil) then
				descriptionKey = bestUpgradeInfo.Description;
				if descriptionKey ~= nil and unit.description ~= descriptionKey then
					unit.name = L(descriptionKey);
					unit.description = descriptionKey;
					ReplaceHelpTextForUpgradedUnits(unit, activePlayer, bestUpgrade);
				end
			end
		end

		unit.selected = (unit == currentUnit);
		unit.label = unit.name;
	end
	local y = UpdateHierarchizedList(units, itemManager, ClickHandler);
	return y;
end

-------------------------------------------------------------------------------------------------
function OnUpdate()
	Controls.Container:SetHide(not isVisible);
	if not isVisible then return end

	if currentUnit then
		LuaEvents.IGE_SetMouseMode(IGE_MODE_PLOP);
	else
		LuaEvents.IGE_SetMouseMode(IGE_MODE_NONE);
	end

	UpdateLevel(currentLevel);
	
	-- Units
	local civilianY =	UpdateUnitList(data.unitsCivilian, civilianUnitManager, civilianUnits);
	local unitsY =		UpdateUnitList(data.units, regularUnitManager, regularUnits);
	local harmonyY =	UpdateUnitList(data.unitsHarmony, harmonyUnitManager, harmonyUnits);
	local supremacyY =	UpdateUnitList(data.unitsSupremacy, supremacyUnitManager, supremacyUnits);
	local purityY =		UpdateUnitList(data.unitsPurity, purityUnitManager, purityUnits);
	local orbitalY =	UpdateUnitList(data.unitsOrbital, orbitalUnitManager, orbitalUnits);
	local alienY =		UpdateUnitList(data.unitsAlien, alienUnitManager, alienUnits);

	-- Update groups size
	local groupCount = 0;
	local listY = g_listsSizeY;
	for k, v in pairs(groups) do
		--Set list height according to its actual size
		if v.control == Controls.civilianUnits then
			listY = civilianY;
		elseif v.control == Controls.regularUnits then
			listY = unitsY;
		elseif v.control == Controls.orbitalUnits then
			listY = orbitalY;
		elseif v.control == Controls.alienUnits then
			listY = alienY;
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
	end

	-- update affinity group size
	local affinitygroupCount = 0;
	for k, v in pairs(affinitygroups) do
		--Set list height according to its actual size
		if v.control == Controls.harmonyUnits then
			listY = harmonyY;
		elseif v.control == Controls.supremacyUnits then
			listY = supremacyY;
		elseif v.control == Controls.purityUnits then
			listY = purityY;
		end

		if v.visible then
			v.instance.List:SetSizeY(listY);
			affinitygroupCount = affinitygroupCount + 1;
		end
	end

	Controls.ScrollPanel:CalculateInternalSize();
end
LuaEvents.IGE_Update.Add(OnUpdate);