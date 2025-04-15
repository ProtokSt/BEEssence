-- Released under GPL v3
--------------------------------------------------------------
include("IGE_API_All");
include("IGE_API_Rivers");
include("IGE_API_Terrain");
include("UIExtras");
print("IGE_TerrainPanel");
IGE = nil;

local groupManager = CreateInstanceManager("GroupInstance", "SubStack", Controls.MainStack );
local routeItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.RouteList );
local improvementItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.ImprovementList );
local projectItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.ProjectList );
local notImprovementItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.NotImprovementList );
local strategicResourceItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.StrategicResourceList );
local artifactResourceItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.ArtifactResourceList );
local basicResourceItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.BasicResourceList );
local waterItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.WaterList );
local terrainItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.TerrainList );
local featureItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.FeatureList );
local typeItemManager = CreateInstanceManager("TypeInstance", "Button", Controls.TypeList );
local fogItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.FogList );
local ownershipItemManager = CreateInstanceManager("ListItemInstance", "Button", Controls.OwnershipList );

local redoStack = {};
local undoStack = {};
local groups = {};
local editData = {};
local paintData = {};
local currentPlot = nil;
local editSound = "AS2D_BUILD_UNIT";
local selectedStrategicResource = nil;
local clickHandler = nil;
local isEditing = true;
local isVisible = false;

routeItemManager.maxHeight = g_listsSizeY;
improvementItemManager.maxHeight = g_listsSizeY;
notImprovementItemManager.maxHeight = g_listsSizeY;
strategicResourceItemManager.maxHeight = g_listsSizeY;
artifactResourceItemManager.maxHeight = g_listsSizeY;
basicResourceItemManager.maxHeight = g_listsSizeY;
waterItemManager.maxHeight = g_listsSizeY;
terrainItemManager.maxHeight = g_listsSizeY;
featureItemManager.maxHeight = g_listsSizeY;
typeItemManager.maxHeight = g_listsSizeY;
fogItemManager.maxHeight = g_listsSizeY;
ownershipItemManager.maxHeight = g_listsSizeY;
projectItemManager.maxHeight = g_listsSizeY;

--===============================================================================================
-- INITIALIZATION
--===============================================================================================
local function InitializeData(data)
	SetTerrainsData(data,		{});
	SetPlotTypesData(data,		{});
	SetFeaturesData(data,		{ none=true });
	SetResourcesData(data,		{ none=true });
	SetImprovementsData(data,	{ none=true });
	SetRoutesData(data,			{ none=true });

	data.fogs = 
	{
		{ ID = 1, name = L("TXT_KEY_IGE_EXPLORED_SETTING"), visible = true, enabled = true, action = SetFog, value = false, help=L("TXT_KEY_IGE_EXPLORED_SETTING_HELP") },
		{ ID = 2, name = L("TXT_KEY_IGE_UNEXPLORED_SETTING"), visible = true, enabled = true, action = SetFog, value = true, help=L("TXT_KEY_IGE_UNEXPLORED_SETTING_HELP") },
	};
	data.ownerships = 
	{
		{ ID = 1, name = L("TXT_KEY_IGE_FREE_LAND_SETTING"), visible = true, enabled = true, action = SetOwnership, value = false, next = false, help=L("TXT_KEY_IGE_FREE_LAND_SETTING_HELP") },
		{ ID = 2, name = L("TXT_KEY_IGE_YOUR_LAND_SETTING"), visible = true, enabled = true, action = SetOwnership, value = true, next = false, help=L("TXT_KEY_IGE_YOUR_LAND_SETTING_HELP") },
		{ ID = 3, name = L("TXT_KEY_IGE_NEXTP_LAND_SETTING"), visible = true, enabled = true, action = SetOwnership, value = true, next = true, help=L("TXT_KEY_IGE_NEXTP_LAND_SETTING_HELP") },
	};
end

-------------------------------------------------------------------------------------------------
function CreateGroup(theControl, name)
	local theInstance = groupManager:GetInstance();
	if theInstance then
		theInstance.Header:SetText(name);
		theControl:ChangeParent(theInstance.List);
		groups[name] = { instance = theInstance, control = theControl, visible = true };
	end
end

-------------------------------------------------------------------------------------------------
local function OnSharingGlobalAndOptions(_IGE)
	IGE = _IGE;
end
LuaEvents.IGE_SharingGlobalAndOptions.Add(OnSharingGlobalAndOptions);

-------------------------------------------------------------------------------------------------
function OnInitialize()
	print("IGE_TerrainPanel.OnInitialize");
	InitializeData(editData);
	InitializeData(paintData);

	currentPaintSelection = paintData.terrainsByTypes["TERRAIN_GRASS"];
	currentPaintSelection.selected = true;

	Controls.Container:SetSizeVal(g_panelSizeX, g_panelSizeY);
	Controls.PromptContainer:SetSizeVal(g_panelSizeX, g_panelSizeY);
	Controls.ScrollPanel:SetSizeVal(g_panelSizeX, g_panelSizeY - 10);

	Controls.MainStack:SetSizeVal(g_panelSizeX, g_panelSizeY);
	Controls.CoreContainer:SetSizeVal(g_panelSizeX, g_panelSizeY - 26);

	Controls.ScrollBar:SetSizeY(Controls.ScrollPanel:GetSizeY());

	local othersName = L("TXT_KEY_IGE_OTHERS");
	CreateGroup(Controls.CoreContainer, L("TXT_KEY_IGE_TERRAIN"));
	CreateGroup(Controls.ResourcesStack, L("TXT_KEY_IGE_RESOURCES"));
	CreateGroup(Controls.ImprovementsStack, L("TXT_KEY_IGE_IMPROVEMENTS"));
	CreateGroup(Controls.ProjectsContainer, L("TXT_KEY_WONDER_SECTION_3"));
	CreateGroup(Controls.OthersContainer, othersName);

	local tt = L("TXT_KEY_IGE_TERRAIN_EDIT_PANEL_HELP");
	LuaEvents.IGE_RegisterTab("TERRAIN_EDITION",  L("TXT_KEY_IGE_TERRAIN_EDIT_PANEL"), 0, "edit",  tt)

	local tt = L("TXT_KEY_IGE_TERRAIN_PAINT_PANEL_HELP");
	LuaEvents.IGE_RegisterTab("TERRAIN_PAINTING", L("TXT_KEY_IGE_TERRAIN_PAINT_PANEL"), 0, "paint", tt, currentPaintSelection)
	print("IGE_TerrainPanel.OnInitialize - Done");

end
LuaEvents.IGE_Initialize.Add(OnInitialize)

--===============================================================================================
-- CORE EVENTS
--===============================================================================================
function OnSelectedPanel(ID)
	if ID == "TERRAIN_EDITION" then
		isEditing = true;
		isVisible = true;
	elseif ID == "TERRAIN_PAINTING" then
		isEditing = false;
		isVisible = true;
	else
		isVisible = false;
	end
end
LuaEvents.IGE_SelectedPanel.Add(OnSelectedPanel);

-------------------------------------------------------------------------------------------------
function ClickHandler(item)
	if isEditing then
		if currentPlot then
			Events.AudioPlay2DSound("AS2D_IF_MP_CHAT_DING");	
			BeginUndoGroup();
			DoAction(currentPlot, item.action, item);
			CommitTerrainChanges();
			CommitFogChanges();
			OnUpdate();
			if IGE.autoRevealImprovements then
				local plot = currentPlot;
				RefreshRevealPlot(plot);
			end
		end
	else
		if currentPaintSelection then
			currentPaintSelection.selected = false;
		end
		currentPaintSelection = item;
		if currentPaintSelection then
			currentPaintSelection.selected = true;
		end
		LuaEvents.IGE_SetTabData("TERRAIN_PAINTING", item);
		OnUpdate();
	end
end

-------------------------------------------------------------------------------------------------
function OnPaintPlot(button, plot, shift)
	if isVisible and currentPaintSelection then
		Events.AudioPlay2DSound("AS2D_IF_MP_CHAT_DING");	
		local item = currentPaintSelection;

		DoAction(plot, item.action, item);
		if shift then
			for neighbor in Neighbors(plot) do
				if currentPaintSelection:action(neighbor) then
					DoAction(neighbor, item.action, item);
				end
			end
		end

		CommitFogChanges();
		CommitTerrainChanges();
		if IGE.autoRevealImprovements then
			RefreshRevealPlot(plot);
		end
	end
end
LuaEvents.IGE_PaintPlot.Add(OnPaintPlot);

-------------------------------------------------------------------------------------------------
function OnBeginPaint()
	BeginUndoGroup();
end
LuaEvents.IGE_BeginPaint.Add(OnBeginPaint)

-------------------------------------------------------------------------------------------------
function OnSelectedPlot(plot)
	currentPlot = plot;
end
LuaEvents.IGE_SelectedPlot.Add(OnSelectedPlot)

--===============================================================================================
-- UNDO
--===============================================================================================
function BeginUndoGroup()
	table.insert(undoStack, {});
end

-------------------------------------------------------------------------------------------------
function Undo(stack, altStack)
	while true do
		if #stack == 0 then break end

		local set = stack[#stack];
		table.remove(stack, #stack);

		if #set > 0 then
			local altSet = {};
			table.insert(altStack, altSet);

			for i = #set, 1, -1 do
				local backup = set[i];
				local plot = Map.GetPlot(backup.x, backup.y);
				local altBackup = BackupPlot(plot);
				table.insert(altSet, altBackup);
				RestorePlot(backup);
			end
			break;
		end
	end

	CommitTerrainChanges();
	CommitFogChanges();
	LuaEvents.IGE_Update();
end

-------------------------------------------------------------------------------------------------
function DoAction(plot, func, arg, invalidate)
	if invalidate == nil then 
		invalidate = true;
	end

	local backup = BackupPlot(plot);
	local changed, resourceChanged = func(arg, plot)
	if changed then
		if invalidate then
			InvalidateTerrain(plot, resourceChanged);
		end
		table.insert(undoStack[#undoStack], backup);		
	end

end

-------------------------------------------------------------------------------------------------
function OnUndo()
	if not isVisible then return end
	Undo(undoStack, redoStack);	
end
LuaEvents.IGE_Undo.Add(OnUndo);

-------------------------------------------------------------------------------------------------
function OnRedo()
	if not isVisible then return end
	Undo(redoStack, undoStack);	
end
LuaEvents.IGE_Redo.Add(OnRedo);

-------------------------------------------------------------------------------------------------
function OnPushUndoStack(set)
	if not isVisible then return end
	table.insert(undoStack, set);
end
LuaEvents.IGE_PushUndoStack.Add(OnPushUndoStack);

--===============================================================================================
-- UPDATE
--===============================================================================================
function UpdateStatusForPlot(plot)
	local selected = nil;

	-- Terrains
	local terrainID = plot:GetTerrainType();
	for i, v in pairs(editData.terrains) do
		v.enabled = CanHaveTerrain(plot, v);
		v.selected = (terrainID == v.ID);
		if v.selected then selected = v end
	end

	-- Water terrains
	for i, v in pairs(editData.waterTerrains) do
		v.enabled = CanHaveTerrain(plot, v);
		v.note = v.enabled and BUG_NoGraphicalUpdate or BUG_SavegameCorruption;
		v.selected = (terrainID == v.ID);
		if v.selected then selected = v end
	end

	-- Types
	local plotType = plot:GetPlotType();
	for i, v in pairs(editData.types) do
		v.selected = (plotType == v.type);
	end

	-- Features
	local featureID = plot:GetFeatureType();
	local noneselect = false;
	for i, v in pairs(editData.features) do
		if v.ID == -1 then
			for i, v in pairs(editData.features) do
					
			if v.ID == 4 and plot:HasMiasma() and plot:CanHaveMiasma() then
				v.enabled = true;
				v.selected = true;
				noneselect = true;
				featureID = v.ID;
			end
			v.enabled = CanHaveFeature(plot, v);
			v.selected = (featureID == v.ID);
			end
			if noneselect then
				v.selected = false;
			else
				v.selected = true;
			end
		end		
	end

	-- Resources
	local resourceID = plot:GetResourceType();
	local numResource = plot:GetNumResource();
	for k, v in pairs(editData.allResources) do 
		v.enabled = CanHaveResource(plot, v);
		v.selected = (resourceID == v.ID);

		if v.selected and v.usage == "RESOURCECLASS_STRATEGIC" then
			v.qty = numResource;
		end
	end

	-- Improvements
	local improvementID = plot:GetImprovementType();
	for k, v in pairs(editData.improvements) do 
		v.enabled = CanHaveImprovement(plot, v);
		v.selected = (improvementID == v.ID);
	end

	-- not improvements (marvels)
	for k, v in pairs(editData.notImprovements) do 
		v.enabled = CanHaveImprovement(plot, v);
		v.selected = (improvementID == v.ID);
	end

	-- Routes
	local routeID = plot:GetRouteType();
	for k, v in pairs(editData.routes) do 
		v.enabled = (plotType == PlotTypes.PLOT_LAND or plotType == PlotTypes.PLOT_HILLS);
		v.selected = (routeID == v.ID);
	end

	local isOwner = (plot:GetOwner() == IGE.currentPlayerID);
	editData.ownerships[1].selected = not isOwner;
	editData.ownerships[2].selected = isOwner;

	local team = Players[IGE.currentPlayerID]:GetTeam();
	local visible = plot:IsRevealed(team, false);
	editData.fogs[2].selected = not visible;
	editData.fogs[1].selected = visible;


	local variety = plot:GetFeatureVariety();
	IGE.pillaged = plot:IsImprovementPillaged();
end

-------------------------------------------------------------------------------------------------
local function UpdateCore(data)
	-- Strategic resources
	selectedStrategicResource = GetSelection(data.strategicResources);
	Controls.ResourceAmountGrid:SetHide(selectedStrategicResource == nil);
	Controls.ResourceAmountLabel:SetText(selectedStrategicResource and selectedStrategicResource.iconString or "");
	UpdateResourceAmount(GetResourceAmount());

	-- Pillaged improvement
	local selectedImprovement = GetSelection(data.improvements) or GetSelection(data.notImprovements);
	if selectedImprovement and selectedImprovement.ID == -1 then selectedImprovement = nil end
	
	Controls.PillageCB:SetCheck(IGE.pillaged);
	Controls.PillageCB:SetHide(selectedImprovement == nil or selectedImprovement.cannotPillage);

	-- Update lists
	UpdateGeneric(data.types,				typeItemManager,				ClickHandler);
	UpdateList(data.terrains,				terrainItemManager,				ClickHandler);
	UpdateList(data.waterTerrains,			waterItemManager,				ClickHandler);
	UpdateList(data.features,				featureItemManager,				ClickHandler);
	local basicresourcesX, basicresourcesY =	UpdateList(data.basicResources,			basicResourceItemManager,		ClickHandler);
	local artifactX, artifactY =				UpdateList(data.artifactResources,		artifactResourceItemManager,	ClickHandler);
	local strategicX, strategicY =				UpdateList(data.strategicResources,		strategicResourceItemManager,	ClickHandler);
	local notimprovementsX, notimprovementsY =	UpdateList(data.notImprovements,		notImprovementItemManager,		ClickHandler);
	local improvementsX, improvementsY =		UpdateList(data.improvements,			improvementItemManager,			ClickHandler);
	local routesX, routesY =					UpdateList(data.routes,					routeItemManager,				ClickHandler);
	local fogsX, fogsY =						UpdateList(data.fogs,					fogItemManager,					ClickHandler);
	local ownershipX, ownershipY =				UpdateList(data.ownerships,				ownershipItemManager,			ClickHandler);
	local projectsX, projectsY =				UpdateList(data.projects,				projectItemManager,				ClickHandler);

	-- Resize
	Controls.ImprovementsInnerStack:CalculateSize();
	Controls.ImprovementsInnerStack:ReprocessAnchoring();

	Controls.StrategicResourceStack:CalculateSize();
	Controls.StrategicResourceStack:ReprocessAnchoring();

	-- Update elements visibility
	local selectedLand = GetSelection(data.terrains);
	local isWaterPlot = isEditing and (selectedLand == nil);
	Controls.RiversElement:SetHide(isWaterPlot or not isEditing);
	Controls.TypeList:SetHide(isWaterPlot);

	local selectionPrompt = isEditing and (currentPlot == nil);
	Controls.PromptContainer:SetHide(not selectionPrompt);
	Controls.ScrollPanel:SetHide(selectionPrompt);

	-- Update groups size
	local groupCount = 0;
	local listY = g_listsSizeY;
	for k, v in pairs(groups) do
		
		--resize based on actual list height
		if v.control == Controls.ResourcesStack then
			listY = basicresourcesY;
		elseif v.control == Controls.ImprovementsStack then
			listY = improvementsY;
		elseif v.control == Controls.ProjectsContainer then
			listY = projectsY;
		elseif v.control == Controls.OthersContainer then
			listY = fogsY;
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
			v.instance.List:SetSizeY(controlSizeY);
		end
	end

    Controls.ScrollPanel:CalculateInternalSize();
	Controls.CoreContainer:CalculateSize();
	Controls.CoreContainer:ReprocessAnchoring();
end

-------------------------------------------------------------------------------------------------
function OnUpdate()
	Controls.OuterContainer:SetHide(not isVisible);
	Controls.RiversElement:SetHide(true);
	OnResizedReseedElement(0, 0)

	if isEditing then
		if not isVisible then return end
		LuaEvents.IGE_SetMouseMode(IGE_MODE_EDIT);

		Controls.PromptContainer:SetHide(currentPlot ~= nil);
		Controls.Container:SetHide(currentPlot == nil);
		if not currentPlot then return end

		UpdateStatusForPlot(currentPlot);
		UpdateCore(editData);
	else
		if not isVisible then return end
		LuaEvents.IGE_SetMouseMode(currentPaintSelection and IGE_MODE_PAINT or IGE_MODE_NONE);

		Controls.PromptContainer:SetHide(true);
		Controls.Container:SetHide(false);
		UpdateCore(paintData);
	end
end
LuaEvents.IGE_Update.Add(OnUpdate);

-------------------------------------------------------------------------------------------------
function OnResizedReseedElement(w, h)
	Controls.PromptLabelContainer:SetSizeX(Controls.PromptContainer:GetSizeX() - (w + 40));
	Controls.PromptLabelContainer:SetSizeY(Controls.PromptContainer:GetSizeY());
	Controls.PromptLabelContainer:ReprocessAnchoring();
	Controls.PromptContainer:ReprocessAnchoring();
end
LuaEvents.IGE_ResizedReseedElement.Add(OnResizedReseedElement)

--===============================================================================================
-- CONTROLS EVENTS
--===============================================================================================
function GetResourceAmount()
	return selectedStrategicResource and selectedStrategicResource.qty or 1;
end

-------------------------------------------------------------------------------------------------
function SetResourceAmount(amount, userInteraction)
	if selectedStrategicResource then
		selectedStrategicResource.qty = amount;

		if isEditing then
			if currentPlot and userInteraction then
				BeginUndoGroup();
				DoAction(currentPlot, SetResourceQty, amount, false);
			end
		end
	end
end
UpdateResourceAmount = HookNumericBox("ResourceAmount", GetResourceAmount, SetResourceAmount, 1, nil, 1);

-------------------------------------------------------------------------------------------------
function OnPillageCBChanged()
	if isEditing and currentPlot then
		IGE.pillaged = Controls.PillageCB:IsChecked();

		BeginUndoGroup();
		DoAction(currentPlot, SetImprovementPillaged, IGE.pillaged, false);
	end
end
Controls.PillageCB:RegisterCallback(Mouse.eLClick, OnPillageCBChanged);



