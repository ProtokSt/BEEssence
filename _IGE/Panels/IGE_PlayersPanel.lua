-- Released under GPL v3
--------------------------------------------------------------
include("IGE_API_All");
include( "IconSupport" );
include( "InfoTooltipInclude" );
print("IGE_PlayersPanel");
IGE = {};

local majorPlayerItemManager = CreateInstanceManager("PlayerInstance", "Button", Controls.MajorPlayersList);
majorPlayerItemManager.maxHeight = g_listsSizeY;
if IGE_HasRisingTide then
	artifactOldEarthItemManager = CreateInstanceManager("ArtifactsInstance", "Button", Controls.OEList );
	artifactAlienItemManager = CreateInstanceManager("ArtifactsInstance", "Button", Controls.AList );
	artifactProgenitorItemManager = CreateInstanceManager("ArtifactsInstance", "Button", Controls.PList );

	artifactOldEarthItemManager.maxHeight = g_listsSizeY;
	artifactAlienItemManager.maxHeight = g_listsSizeY;
	artifactProgenitorItemManager.maxHeight = g_listsSizeY;

	artifactOldEarthItemManager.columnWidth = 200;
	artifactAlienItemManager.columnWidth = 200;
	artifactProgenitorItemManager.columnWidth = 200;
end

local data = {};
local actions = nil;
local isVisible = false;
local currentActionID = 1;
local artifactOldEarth = {};
local artifactAlien = {};
local artifactProgenitor = {};
--===============================================================================================
-- EVENTS
--===============================================================================================
local function OnSharingGlobalAndOptions(_IGE)
	IGE = _IGE;
end
LuaEvents.IGE_SharingGlobalAndOptions.Add(OnSharingGlobalAndOptions);

-------------------------------------------------------------------------------------------------
function OnInitialize()
	SetPlayersData(data, {});
	if IGE_HasRisingTide then
		SetArtifactsData(data,		{});
	end
	
	Resize(Controls.Container);
	Resize(Controls.ScrollPanel);

	Controls.Container:SetSizeVal(g_panelSizeX, g_panelSizeY);
	Controls.ScrollPanel:SetSizeVal(g_panelSizeX, g_panelSizeY - 10);
	Controls.ScrollBar:SetSizeY(Controls.ScrollPanel:GetSizeY());

	Controls.TopStack:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);
	Controls.Stack:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);

	local firstStackSplitX = g_panelSizeX / 2;

	Controls.PropertiesStack:SetSizeVal(firstStackSplitX, g_panelSizeY - 26);
	Controls.EditBoxStack:SetSizeVal(firstStackSplitX, g_panelSizeY - 26);

	Controls.ActionsStack:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);
	local playerStackY = g_panelSizeX - 54;--44 from drop down menu + offsetY 20 + offsetY 10
	Controls.PlayersStack:SetSizeVal(g_panelSizeX, playerStackY);
	Controls.ActionHeaderBackground:SetSizeX(g_panelSizeX - 5);

	if IGE_HasRisingTide then
		Controls.ArtifactsStack:SetSizeVal(g_panelSizeX,  g_panelSizeY - 26);
		Controls.ArtifactHeaderBackground:SetSizeX(g_panelSizeX - 5);
	else
		Controls.ArtifactsStack:SetHide(true);
	end

	Controls.OEHeaderBackground:SetSizeX(g_panelSizeX - 5);
	Controls.AHeaderBackground:SetSizeX(g_panelSizeX - 5);
	Controls.PHeaderBackground:SetSizeX(g_panelSizeX - 5);

	-- Split artifacts into categories
	if IGE_HasRisingTide then
		for _, artifact in ipairs(data.artifacts) do
			if artifact.category == "ARTIFACT_CATEGORY_OLD_EARTH" then
				table.insert(artifactOldEarth, artifact);
			elseif artifact.category == "ARTIFACT_CATEGORY_ALIEN" then
				table.insert(artifactAlien, artifact);
			elseif artifact.category == "ARTIFACT_CATEGORY_PROGENITOR" then
				table.insert(artifactProgenitor, artifact);
			else
					print("IGE_PlayersPanel: artifact.category == nil..... no category matched... for ",artifact.type);
			end
		end
	end

	actions =
	{
		{ text = L("TXT_KEY_IGE_PLANETFALL"),				filter = CanPlanetfall,		handler = Planetfall,		none=L("TXT_KEY_IGE_PLANETFALL_NONE") },
		{ text = L("TXT_KEY_IGE_MEET"),						filter = CanMeet,			handler = Meet,				none=L("TXT_KEY_IGE_MEET_NONE") },
		{ text = L("TXT_KEY_IGE_FORM_TEAM"),				filter = CanFormTeam,		handler = FormTeam,			none=L("TXT_KEY_IGE_FORM_TEAM_NONE") },
		{ text = L("TXT_KEY_IGE_MAKE_PEACE"),				filter = CanMakePeace,		handler = MakePeace,		none=L("TXT_KEY_IGE_MAKE_PEACE_NONE") },
		{ text = L("TXT_KEY_IGE_DECLARE_WAR"),				filter = CanDeclareWar,		handler = DeclareWar,		none=L("TXT_KEY_IGE_TWO_SIDES_NONE") },
		{ text = L("TXT_KEY_IGE_DECLARE_WAR_BY"),			filter = CanBeDeclaredWar,	handler = MakeDeclaredWar,	none=L("TXT_KEY_IGE_TWO_SIDES_NONE") },
	};

    for i, v in ipairs(actions) do
        local instance = {};
        Controls.PullDown:BuildEntry("InstanceOne", instance);
        instance.Button:SetText(v.text);
        instance.Button:SetVoid1(i);
    end
    Controls.PullDown:CalculateInternals();

	LuaEvents.IGE_RegisterTab("PLAYERS",  L("TXT_KEY_IGE_PLAYERS_PANEL"), 3, "change",  "")
end
LuaEvents.IGE_Initialize.Add(OnInitialize)

-------------------------------------------------------------------------------------------------
function OnSelectedPanel(ID)
	isVisible = (ID == "PLAYERS");
end
LuaEvents.IGE_SelectedPanel.Add(OnSelectedPanel);

-------------------------------------------------------------------------------------------------
function OnPullDownSelectionChanged(ID)
	currentActionID = ID;
	OnUpdate();
end
Controls.PullDown:RegisterSelectionCallback(OnPullDownSelectionChanged);

-------------------------------------------------------------------------------------------------
UpdateEnergy = HookNumericBox("Energy", 
	function() return Players[IGE.currentPlayerID]:GetEnergy() end, 
	function(amount) Players[IGE.currentPlayerID]:SetEnergy(amount) end, 
	0, nil, 100);

UpdateCulture = HookNumericBox("Culture", 
	function() return Players[IGE.currentPlayerID]:GetCulture() end, 
	function(amount) Players[IGE.currentPlayerID]:SetCulture(amount) end, 
	0, nil, 100);
if IGE_HasRisingTide then
	UpdateDiplomacy = HookNumericBox("DiplomaticCapital", 
		function() return Players[IGE.currentPlayerID]:GetDiplomaticCapital() end, 
		function(amount) Players[IGE.currentPlayerID]:SetDiplomaticCapital(amount) end, 
		0, nil, 100);
end

--===============================================================================================
-- UPDATE
--===============================================================================================
function UpdatePlayers()
	local sourceID = IGE.currentPlayerID;

	local anyMinor = false;
	local anyMajor = false;
	local action = actions[currentActionID];
	for i, v in ipairs(data.allPlayers) do
		if v.ID ~= sourceID then
			v.visible, v.enabled, v.help = action.filter(sourceID, v.ID);

			if v.isCityState then
				anyMinor = anyMinor or v.visible;
			else
				anyMajor = anyMajor or v.visible;
			end
		else
			v.visible = false;
		end
	end

	Controls.NoPlayerLabel:SetText("[COLOR_POSITIVE_TEXT]"..action.none.."[ENDCOLOR]");
	Controls.NoPlayerContainer:SetHide(anyMajor);
	Controls.NoPlayerLabel:SetHide(anyMajor);	
	Controls.MajorPlayersList:SetHide(not anyMajor);

	table.sort(data.majorPlayers, DefaultSort);

	local handler = action.handler;
	UpdateList(data.majorPlayers, majorPlayerItemManager, function(v) PlayerClickHandler(handler, sourceID, v.ID) end);

	Controls.MajorPlayersList:SetSizeY(g_listsSizeY);
end

-------------------------------------------------------------------------------------------------
function OnUpdate()
	Controls.Container:SetHide(not isVisible);
	if not isVisible then return end

	LuaEvents.IGE_SetMouseMode(IGE_MODE_NONE);

	-- Update controls
	local pPlayer = IGE.currentPlayer;
	UpdateEnergy(pPlayer:GetEnergy());
	UpdateCulture(pPlayer:GetCulture());
	if IGE_HasRisingTide then
		UpdateDiplomacy(pPlayer:GetDiplomaticCapital());
	else
		Controls.DiploContainer:SetHide(true);
	end

	affinitystring();

	Controls.PullDown:GetButton():SetText(actions[currentActionID].text);
	UpdatePlayers();

	if IGE_HasRisingTide then
		artifactsOEX, artifactsOEY = UpdateList(artifactOldEarth, artifactOldEarthItemManager, function(v) ArtifactClickHandler(v) end);
		artifactsAX, artifactsAY = UpdateList(artifactAlien, artifactAlienItemManager, function(v) ArtifactClickHandler(v) end);
		artifactsPX, artifactsPY = UpdateList(artifactProgenitor, artifactProgenitorItemManager, function(v) ArtifactClickHandler(v) end);
	end

	if not IGE_HasRisingTide then
		Controls.ActionsStack:SetSizeY(g_listsSizeY);
	end
    Controls.ScrollPanel:CalculateInternalSize();
	Controls.ScrollBar:SetSizeY(Controls.ScrollPanel:GetSizeY());
end
LuaEvents.IGE_Update.Add(OnUpdate);

function affinitystring()
	local pPlayer = IGE.currentPlayer;
	local hlevel = pPlayer:GetAffinityLevel(0);
	local plevel = pPlayer:GetAffinityLevel(1);
	local slevel = pPlayer:GetAffinityLevel(2);

	Controls.harmonylabel:SetText(Locale.ConvertTextKey("TXT_KEY_IGE_AFFINITY") .. " " .. hlevel);
	Controls.puritylabel:SetText(Locale.ConvertTextKey("TXT_KEY_IGE_AFFINITY") .. " " .. plevel);
	Controls.supremacylabel:SetText(Locale.ConvertTextKey("TXT_KEY_IGE_AFFINITY") .. " " .. slevel);
end

--===============================================================================================
-- DIPLOMATIC HANDLERS
--===============================================================================================
function PlayerClickHandler(handler, sourceID, targetID)
	handler(sourceID, targetID);
	OnUpdate();
end

function AllClick()
	local handler = actions[currentActionID].handler;
	for i, v in ipairs(data.allPlayers) do
		if v.visible and v.enabled and not v.isAlien then
			handler(IGE.currentPlayerID, v.ID);
		end
	end
	OnUpdate();
end
Controls.AllButton:RegisterCallback(Mouse.eLClick, AllClick);

function NotifyDiplo(sourceID, targetID, type, summaryTexKey, detailsTxtKey)
	Players[sourceID]:AddNotification(type, 
		L("TXT_KEY_NOTIFICATION_CITY_WLTKD", Players[targetID]:GetCivilizationDescription()),
		L(summaryTexKey, Players[targetID]:GetCivilizationDescription()), nil, nil, targetID);
end

-------------------------------------------------------------------------------------------------
function CanMeet(sourceID, targetID)
	if not Players[targetID]:IsAlive() or not Players[targetID]:IsFoundedFirstCity() or Players[targetID] == Players[GameDefines.ALIEN_PLAYER] then 
		return false ;
	else
		local visible = not GetTeam(sourceID):IsHasMet(GetTeamID(targetID));
		return visible, true;
	end
end

function CanFormTeam(sourceID, targetID)
	if not Players[targetID]:IsAlive() or not Players[targetID]:IsFoundedFirstCity() or Players[targetID] == Players[GameDefines.ALIEN_PLAYER] then 
		return false;
	elseif GetTeamID(sourceID) == GetTeamID(targetID) then
		return true, false, L("TXT_KEY_IGE_ALREADY_IN_TEAM_ERROR") ;
	else
		return true, true;
	end
end

function CanMakePeace(sourceID, targetID)
	if not Players[targetID]:IsAlive() or not Players[targetID]:IsFoundedFirstCity() or Players[targetID] == Players[GameDefines.ALIEN_PLAYER] then 
		return false;
	elseif not GetTeam(sourceID):IsAtWar(GetTeamID(targetID)) then
		return false;
	else
		return true, true;
	end
end

function CanDeclareWar(sourceID, targetID)
	if not Players[targetID]:IsAlive() or not Players[targetID]:IsFoundedFirstCity() or Players[targetID] == Players[GameDefines.ALIEN_PLAYER] then 
		return false;
	elseif GetTeamID(sourceID) == GetTeamID(targetID) then
		return true, false, L("TXT_KEY_IGE_SAME_TEAM_ERROR");
	elseif GetTeam(sourceID):IsAtWar(GetTeamID(targetID)) then
		return true, false, L("TXT_KEY_IGE_ALREADY_AT_WAR_ERROR");
	else
		return true, true;
	end
end

function CanBeDeclaredWar(sourceID, targetID)
	if not Players[targetID]:IsAlive() or not Players[targetID]:IsFoundedFirstCity() or Players[targetID] == Players[GameDefines.ALIEN_PLAYER] then 
		return false;
	else
		return CanDeclareWar(targetID, sourceID);
	end
end

function CanPlanetfall(sourceID, targetID)
	if not Players[targetID]:IsAlive() or Players[targetID]:IsFoundedFirstCity () or Players[targetID] == Players[GameDefines.ALIEN_PLAYER] then
		return false ;
	else
		return true, true;
	end
end

-------------------------------------------------------------------------------------------------
function Meet(sourceID, targetID)
	GetTeam(sourceID):Meet(GetTeamID(targetID), false);
	OnUpdate();
end

function MakePeace(sourceID, targetID)
	GetTeam(sourceID):MakePeace(GetTeamID(targetID));
	OnUpdate();
end

function FormTeam(sourceID, targetID)
	GetTeam(sourceID):AddTeam(GetTeamID(targetID));
	OnUpdate();
end

function DeclareWar(sourceID, targetID)
	GetTeam(sourceID):DeclareWar(GetTeamID(targetID));
	OnUpdate();
end

function MakeDeclaredWar(sourceID, targetID)
	DeclareWar(targetID, sourceID);
	OnUpdate();
end

function Planetfall(sourceID, targetID)
	local pPlayer = Players[targetID];
	local pStartPlot = pPlayer:GetStartingPlot();

	if pStartPlot == nil then
		error("function Planetfall: start location must be a valid plot");
	end

	local plotX = pStartPlot:GetX();
	local plotY = pStartPlot:GetY();

	-- Do planetfall
	if pPlayer:CanPlanetfallFound(plotX, plotY) then
			Network.SendPlanetfall(targetID, plotX, plotY, false);
	end
	OnUpdate();
end

--===============================================================================================
-- REGULAR HANDLERS
--===============================================================================================

function OnTakeSeatClick()
	LuaEvents.IGE_ForceQuit(true);
end
Controls.TakeSeatButton:RegisterCallback(Mouse.eLClick, OnTakeSeatClick);

-------------------------------------------------------------------------------------------------
function OnUnexploreMapClick()
	LuaEvents.IGE_ForceRevealMap(false);
end
Controls.UnexploreMapButton:RegisterCallback(Mouse.eLClick, OnUnexploreMapClick);

-------------------------------------------------------------------------------------------------
function OnExploreMapClick()
	LuaEvents.IGE_ForceRevealMap(true, false);
end
Controls.ExploreMapButton:RegisterCallback(Mouse.eLClick, OnExploreMapClick);

-------------------------------------------------------------------------------------------------
function OnRevealMapClick()
	LuaEvents.IGE_ForceRevealMap(true, true);
end
Controls.RevealMapButton:RegisterCallback(Mouse.eLClick, OnRevealMapClick);

-------------------------------------------------------------------------------------------------
function OnRemoveMiamsaClick()
	LuaEvents.PWE_RemoveMiamsa(true, true);
end
Controls.RemoveMiamsaButton:RegisterCallback(Mouse.eLClick, OnRemoveMiamsaClick);

-------------------------------------------------------------------------------------------------
function OnRemovePodsClick()
	LuaEvents.PWE_RemovePods(true, true);
end
Controls.RemovePodsButton:RegisterCallback(Mouse.eLClick, OnRemovePodsClick);

-------------------------------------------------------------------------------------------------
function OnRemoveAliensClick()
	LuaEvents.PWE_RemoveAliens(true, true);
end
Controls.RemoveAliensButton:RegisterCallback(Mouse.eLClick, OnRemoveAliensClick);

-------------------------------------------------------------------------------------------------
function OnSetWild0Click()
	LuaEvents.PWE_SetWild0(true, true);
end
Controls.SetWild0Button:RegisterCallback(Mouse.eLClick, OnSetWild0Click);

-------------------------------------------------------------------------------------------------
function OnKillUnitsClick()
	local i = 0;
	while i == IGE.currentPlayerID or Players[i] == nil or not Players[i]:IsAlive() do
		i = i + 1;
	end

	local pPlayer = IGE.currentPlayer;
	LuaEvents.IGE_SelectPlayer(i);
	pPlayer:KillUnits();
end
Controls.KillUnitsButton:RegisterCallback(Mouse.eLClick, OnKillUnitsClick);

-------------------------------------------------------------------------------------------------
function OnKillClick()
	local i = 0;
	while i == IGE.currentPlayerID or Players[i] == nil or not Players[i]:IsAlive() do
		i = i + 1;
	end

	local pPlayer = IGE.currentPlayer;
	LuaEvents.IGE_SelectPlayer(i);
	pPlayer:KillUnits();
	pPlayer:KillCities();
end
Controls.KillButton:RegisterCallback(Mouse.eLClick, OnKillClick);

-------------------------------------------------------------------------------------------------
function OnFreeTechClick()
	IGE.currentPlayer:SetNumFreeTechs(IGE.currentPlayer:GetNumFreeTechs() + 1);
	IGE.currentPlayer:AddNotification(NotificationTypes.NOTIFICATION_FREE_TECH, L("TXT_KEY_IGE_FREE_TECH_BUTTON"),L("TXT_KEY_IGE_FREE_TECH_BUTTON_HELP") );
	OnUpdate();
end
Controls.FreeTechButton:RegisterCallback(Mouse.eLClick, OnFreeTechClick);

-------------------------------------------------------------------------------------------------
function OnFreePolicyClick()
	IGE.currentPlayer:SetNumFreePolicies(IGE.currentPlayer:GetNumFreePolicies() + 1);
	IGE.currentPlayer:AddNotification(NotificationTypes.NOTIFICATION_FREE_POLICY, L("TXT_KEY_IGE_FREE_POLICY_BUTTON"), L("TXT_KEY_IGE_FREE_POLICY_BUTTON_HELP"));
	OnUpdate();
end
Controls.FreePolicyButton:RegisterCallback(Mouse.eLClick, OnFreePolicyClick);

-------------------------------------------------------------------------------------------------
function OnNotificationAdded( Id, type, toolTip, strSummary, iGameValue, iExtraGameData )
	OnUpdate();
end
Events.NotificationAdded.Add(OnNotificationAdded);

-------------------------------------------------------------------------------------------------
function OnUpgradeHarmonyClick()
	local xpneeded = Players[IGE.currentPlayerID]:CalculateAffinityScoreNeededForNextLevel(0);	
	Players[IGE.currentPlayerID]:ChangeAffinityScore(0, xpneeded)	
	OnUpdate();
	UpdateCities();
end
Controls.HarmonyUpgrade:RegisterCallback(Mouse.eLClick, OnUpgradeHarmonyClick);

-------------------------------------------------------------------------------------------------
function OnUpgradePurityClick()
	local xpneeded = Players[IGE.currentPlayerID]:CalculateAffinityScoreNeededForNextLevel(1);	
	Players[IGE.currentPlayerID]:ChangeAffinityScore(1, xpneeded)	
	OnUpdate();
	UpdateCities();
end
Controls.PurityUpgrade:RegisterCallback(Mouse.eLClick, OnUpgradePurityClick);

-------------------------------------------------------------------------------------------------
function OnUpgradeSupremacyClick()
	local xpneeded = Players[IGE.currentPlayerID]:CalculateAffinityScoreNeededForNextLevel(2);	
	Players[IGE.currentPlayerID]:ChangeAffinityScore(2, xpneeded)	
	OnUpdate();
	UpdateCities();
end
Controls.SupremacyUpgrade:RegisterCallback(Mouse.eLClick, OnUpgradeSupremacyClick);

-------------------------------------------------------------------------------------------------
function ArtifactClickHandler(artifact)
	local pPlayer = IGE.currentPlayer;
	pPlayer:AddArtifact(artifact.ID);
	
end

-------------------------------------------------------------------------------------------------
function KillAliensButton()
	local pPlayer = Players[GameDefines.ALIEN_PLAYER];
	pPlayer:KillUnits();
end
Controls.KillAliensButton:RegisterCallback(Mouse.eLClick, KillAliensButton);

-------------------------------------------------------------------------------------------------
function UpdateCities()
	-- Reset cities.
	local player = IGE.currentPlayer;
	local numCities = player:GetNumCities();
	for cityID = 0, numCities - 1, 1 do
		local city = player:GetCityByID(cityID);
		if city ~= nil then
			city:ChangePopulation(1,true);
			city:ChangePopulation(-1,true);
		end
	end
end

-------------------------------------------------------------------------------------------------
function LevelUpStationsButton()
	if Game.GetNumActiveStations() > 0 then
		for stationIndex = 0, Game.GetNumActiveStations() - 1, 1 do
			local station = Game:GetStationByIndex( stationIndex );
			if( station ~= nil ) then
				local level = station:GetLevel();
				local maxLevel = station:GetMaxLevel();
				station:SetLevel(maxLevel);
			end
		end
	end
end
Controls.LevelUpStationsButton:RegisterCallback(Mouse.eLClick, LevelUpStationsButton);

-------------------------------------------------------------------------------------------------
function GrantAllTechsButton()
	local pPlayer = Players[IGE.currentPlayerID];
    local pTeam = Teams[pPlayer:GetTeam()];
    local pTeamTechs = pTeam:GetTeamTechs();
	local iTechLoop = 0;
    local pTechInfo = GameInfo.Technologies[iTechLoop];

    while( pTechInfo~= nil ) do
		pTeamTechs:SetHasTech(iTechLoop, true);
        iTechLoop = iTechLoop + 1;
        pTechInfo= GameInfo.Technologies[iTechLoop];
	end
end
Controls.GrantAllTechsButton:RegisterCallback(Mouse.eLClick, GrantAllTechsButton);

-------------------------------------------------------------------------------------------------
function RemoveAllTechsButton()
	local pPlayer = Players[IGE.currentPlayerID];
    local pTeam = Teams[pPlayer:GetTeam()];
    local pTeamTechs = pTeam:GetTeamTechs();
	local iTechLoop = 0;
    local pTechInfo = GameInfo.Technologies[iTechLoop];

	 while( pTechInfo~= nil ) do
        pTeamTechs:SetHasTech(iTechLoop, false);
        iTechLoop = iTechLoop + 1;
        pTechInfo= GameInfo.Technologies[iTechLoop];
	end
end
Controls.RemoveAllTechsButton:RegisterCallback(Mouse.eLClick, RemoveAllTechsButton);