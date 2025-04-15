-- Released under GPL v3
--------------------------------------------------------------
include("FLuaVector");
include("IGE_API_All");
include("IconSupport");
include("InstanceManager");
include("SupportFunctions");
include("InfoTooltipInclude");
print("IGE_PoliciesPanel");
IGE = nil;


local g_IGECategoryColors = 
{
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_MIGHT"].ID] = "[COLOR_VIRTUE_MIGHT]",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_PROSPERITY"].ID] = "[COLOR_VIRTUE_PROSPERITY]",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_KNOWLEDGE"].ID] = "[COLOR_VIRTUE_KNOWLEDGE]",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_INDUSTRY"].ID] = "[COLOR_VIRTUE_INDUSTRY]",
};
local g_IGEDepthColors =
{
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_MODERATE"].ID] = {x=1, y=1, z=1, w=0.5},
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_DEVOTED"].ID] = {x=1, y=1, z=1, w=0.8},
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_EXTREME"].ID] = {x=1, y=1, z=1, w=1},
}

local g_IGEUnavailableVirtueColor = {x=0.5, y=0.5, z=0.5, w=0.5};
local g_IGEAvailableVirtueColor = {x=1, y=1, z=1, w=0.5};
local g_IGEAcquiredVirtueColors = 
{
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_MIGHT"].ID] = {x=1, y=1, z=1, w=1},
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_PROSPERITY"].ID] = {x=1, y=1, z=1, w=1},
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_KNOWLEDGE"].ID] = {x=1, y=1, z=1, w=1},
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_INDUSTRY"].ID] = {x=1, y=1, z=1, w=1},
};

local g_IGEUnacquiredVirtueTexture = "Virtue_Virtue_Off.dds";
local g_IGEAcquiredVirtueTextures =
{
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_MIGHT"].ID] = "Virtue_Virtue_Might.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_PROSPERITY"].ID] = "Virtue_Virtue_Prosperity.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_KNOWLEDGE"].ID] = "Virtue_Virtue_Knowledge.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_INDUSTRY"].ID] = "Virtue_Virtue_Industry.dds",
};

local g_IGEUnacquiredCategoryKickerTextures = 
{
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_MIGHT"].ID] = "Virtue_MightBonus_Off.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_PROSPERITY"].ID] = "Virtue_ProsperityBonus_Off.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_KNOWLEDGE"].ID] = "Virtue_KnowledgeBonus_Off.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_INDUSTRY"].ID] = "Virtue_IndustryBonus_Off.dds",
};
local g_IGEAcquiredCategoryKickerTextures = 
{
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_MIGHT"].ID] = "Virtue_MightBonus_On.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_PROSPERITY"].ID] = "Virtue_ProsperityBonus_On.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_KNOWLEDGE"].ID] = "Virtue_KnowledgeBonus_On.dds",
	[GameInfo.PolicyBranchTypes["POLICY_BRANCH_INDUSTRY"].ID] = "Virtue_IndustryBonus_On.dds",
};

local g_IGEUnacquiredDepthKickerTextures = 
{
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_MODERATE"].ID] = "Virtue_Level1Bonus_Off.dds",
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_DEVOTED"].ID] = "Virtue_Level2Bonus_Off.dds",
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_EXTREME"].ID] = "Virtue_Level3Bonus_Off.dds",
};
local g_IGEAcquiredDepthKickerTextures = 
{
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_MODERATE"].ID] = "Virtue_Level1Bonus_On.dds",
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_DEVOTED"].ID] = "Virtue_Level2Bonus_On.dds",
	[GameInfo.PolicyDepthTypes["POLICY_DEPTH_EXTREME"].ID] = "Virtue_Level3Bonus_On.dds",
};

local g_IGEBaseVirtueXOffset = -1;
local g_IGEBaseVirtueYOffset = 5;
local g_IGEPerVirtueXOffset = 30;
local g_IGEPerVirtueYOffset = 62;
local g_IGEPerDepthYOffset = 182;

local g_IGEFromLineYOffset = 10;
local g_IGEToLineYOffset = -10;



local isVisible = false;

-------------------------------------------------------------------------------------------------
local function OnSharingGlobalAndOptions(_IGE)
	IGE = _IGE;
end
LuaEvents.IGE_SharingGlobalAndOptions.Add(OnSharingGlobalAndOptions);

-------------------------------------------------------------------------------------------------
function OnInitialize()
	print("IGE_PoliciesPanel.OnInitialize");
	Controls.VirtueCategoryStack:CalculateSize();
	local windowName = "[ICON_BULLET] IGE ";
	windowName = windowName..L("TXT_KEY_GAME_CONCEPT_SECTION_13").." [ICON_BULLET]";
	Controls.WindowName:SetText(windowName);
	local tabtext = L("TXT_KEY_GAME_CONCEPT_SECTION_13");
	tabtext = tabtext .." (F8)";
	LuaEvents.IGE_RegisterTab("POLICIES", tabtext, 5, "change",  "");
	print("IGE_PoliciesPanel.OnInitialize - Done");
end
LuaEvents.IGE_Initialize.Add(OnInitialize)

-------------------------------------------------------------------------------------------------
function OnSelectedPanel(ID)
	isVisible = (ID == "POLICIES");
end
LuaEvents.IGE_SelectedPanel.Add(OnSelectedPanel);

function OnClose ()
	ContextPtr:SetHide(true);
	LuaEvents.IGE_SetTab("PLAYERS");
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose );


function IGE_OnVirtueClicked(virtueID)
	local newValue = not IGE.currentPlayer:HasPolicy(virtueID);
	IGE.currentPlayer:SetHasPolicy(virtueID, newValue);
	print("virtueID: ",virtueID);
	Events.AudioPlay2DSound("AS2D_INTERFACE_POLICY_CONFIRM");
	OnUpdate();	
end

function IGE_OnVirtueRootClicked(categoryID)
	local newValue = not IGE.currentPlayer:IsPolicyBranchUnlocked(categoryID);
	--The categories have different acutal policy IDs
	-- 3 Industries
	if categoryID == 3 then
		correctID = 45;
		IGE.currentPlayer:SetHasPolicy(correctID, newValue);
	-- 2 Knowledge
	elseif categoryID == 2 then
		correctID = 30;
		IGE.currentPlayer:SetHasPolicy(correctID, newValue);
	-- 1 Prosperity
	elseif categoryID == 1 then
		correctID = 15;
		IGE.currentPlayer:SetHasPolicy(correctID, newValue);
	-- 0 Might
	elseif categoryID == 0 then
		correctID = 2;
		IGE.currentPlayer:SetHasPolicy(correctID, newValue);
	else
		print("Error Virtue Category");
	end
	-- Still need to use categoryID to light up the icons
	IGE.currentPlayer:SetPolicyBranchUnlocked(categoryID, newValue);
	Events.AudioPlay2DSound("AS2D_INTERFACE_POLICY_CONFIRM");
	OnUpdate();
end

function OnUpdate()
	ContextPtr:SetHide(not isVisible);
	if not isVisible then return end
	LuaEvents.IGE_SetMouseMode(IGE_MODE_NONE);
	UpdateWindow();
end
LuaEvents.IGE_Update.Add(OnUpdate);

--------------- Virtue Stuff ----

function UpdateWindow()	
	local pPlayer = IGE.currentPlayer;

	Controls.VirtueDepthStack:DestroyAllChildren();
	Controls.VirtueCategoryStack:DestroyAllChildren();

	for depthData in GameInfo.PolicyDepthTypes() do
		IGE_AddVirtueDepth(pPlayer, Controls.VirtueDepthStack, depthData);
	end

	for categoryData in GameInfo.PolicyBranchTypes() do
		IGE_AddVirtueCategory(pPlayer, Controls.VirtueCategoryStack, categoryData);
	end

	Controls.VirtueDepthStack:CalculateSize();
	Controls.VirtueDepthStack:ReprocessAnchoring();
	Controls.VirtueCategoryStack:CalculateSize();
	Controls.VirtueCategoryStack:ReprocessAnchoring();
end

function IGE_AddVirtueDepth(viewingPlayer, depthStack, depthData)
	local depthControl = {};
	ContextPtr:BuildInstanceForControl("VirtueDepthInstance", depthControl, depthStack);

	-- Kicker progress bar
	local depthVirtuesEarned = viewingPlayer:GetNumPoliciesInDepth(depthData.ID);
	local depthVirtuesTotal = IGE_GetTotalVirtuesInDepth(depthData);
	local sizeYPerVirtue = depthControl.BaseBar:GetSizeY() / depthVirtuesTotal;
	depthControl.ProgressBar:SetSizeY(depthVirtuesEarned * sizeYPerVirtue);
	depthControl.ProgressBar:SetColor(RGBAObjectToABGRHex(g_IGEDepthColors[depthData.ID]));

	-- Kicker brackets
	local previousEndingIndex = 0;
	for tKickerInfo in GameInfo.PolicyDepth_KickerPolicies("PolicyDepthType = \"" .. depthData.Type .. "\" ORDER BY NumNeededInDepth") do
		local policyData = GameInfo.Policies[tKickerInfo.PolicyType];
		local kickerControl = {};
		ContextPtr:BuildInstanceForControl("VirtueDepthKickerInstance", kickerControl, depthControl.BaseBar);
		
		kickerControl.Bracket:SetOffsetY(previousEndingIndex * sizeYPerVirtue);
		kickerControl.Bracket:SetSizeY((tKickerInfo.NumNeededInDepth - previousEndingIndex) * sizeYPerVirtue);
		previousEndingIndex = tKickerInfo.NumNeededInDepth;

		local tooltip = "[COLOR_GREY]" .. Locale.ConvertTextKey(policyData.Description) .. "[ENDCOLOR]";
		tooltip = tooltip .. "[NEWLINE][NEWLINE]";
		tooltip = tooltip .. GetHelpTextForVirtue(policyData.ID);
		kickerControl.KickerIcon:SetToolTipString(tooltip);

		local iconTexture = g_IGEUnacquiredDepthKickerTextures[depthData.ID];
		if (viewingPlayer:HasPolicy(policyData.ID)) then
			iconTexture = g_IGEAcquiredDepthKickerTextures[depthData.ID];
		end
		kickerControl.KickerIcon:SetTexture(iconTexture);
	end
end

function IGE_GetTotalVirtuesInDepth(depthData)
	local count = 0;
	for policyData in GameInfo.Policies("PolicyDepthType = \"" .. depthData.Type .. "\"") do
		if (not Game.IsKickerPolicy(policyData.ID)) then
			count = count + 1;
		end
	end
	return count;	
end



function IGE_AddVirtueCategory(viewingPlayer, categoryStack, categoryData)
	local categoryControl = {};
	ContextPtr:BuildInstanceForControl("VirtueCategoryInstance", categoryControl, categoryStack);
	local name = g_IGECategoryColors[categoryData.ID] .. Locale.ConvertTextKey("{" .. categoryData.Description .. ":upper}") .. "[ENDCOLOR]";
	categoryControl.Name:SetText(name);
	categoryControl.Name:SetToolTipString(Locale.ConvertTextKey(categoryData.Help));
	categoryControl.Background:SetTexture(categoryData.BackgroundImage);

	-- Kicker progress bar
	local categoryVirtuesEarned = viewingPlayer:GetNumPoliciesInBranch(categoryData.ID);
	local categoryVirtuesTotal = IGE_GetTotalVirtuesInCategory(categoryData);
	local sizeXPerVirtue = categoryControl.BaseBar:GetSizeX() / categoryVirtuesTotal;
	categoryControl.ProgressBar:SetSizeX(categoryVirtuesEarned * sizeXPerVirtue);
	categoryControl.ProgressBar:SetTexture(categoryData.ProgressBarImage);

	-- Kicker brackets
	local previousEndingIndex = 0;
	for tKickerInfo in GameInfo.PolicyBranch_KickerPolicies("PolicyBranchType = \"" .. categoryData.Type .. "\" ORDER BY NumNeededInBranch") do
		local policyData = GameInfo.Policies[tKickerInfo.PolicyType];
		local kickerControl = {};
		ContextPtr:BuildInstanceForControl("VirtueCategoryKickerInstance", kickerControl, categoryControl.BaseBar);

		kickerControl.Bracket:SetOffsetX(previousEndingIndex * sizeXPerVirtue);
		kickerControl.Bracket:SetSizeX((tKickerInfo.NumNeededInBranch - previousEndingIndex) * sizeXPerVirtue);
		previousEndingIndex = tKickerInfo.NumNeededInBranch;

		local tooltip = g_IGECategoryColors[categoryData.ID] .. Locale.ConvertTextKey(policyData.Description) .. "[ENDCOLOR]";
		tooltip = tooltip .. "[NEWLINE][NEWLINE]";
		tooltip = tooltip .. GetHelpTextForVirtue(policyData.ID);
		kickerControl.KickerIcon:SetToolTipString(tooltip);

		local iconTexture = g_IGEUnacquiredCategoryKickerTextures[categoryData.ID];
		if (viewingPlayer:HasPolicy(policyData.ID)) then
			iconTexture = g_IGEAcquiredCategoryKickerTextures[categoryData.ID];
		end
		kickerControl.KickerIcon:SetTexture(iconTexture);
	end

	-- Prereq lines
	for virtuePrereqData in GameInfo.Policy_PrereqORPolicies() do
		local fromVirtueData = GameInfo.Policies[virtuePrereqData.PrereqPolicy];
		local toVirtueData = GameInfo.Policies[virtuePrereqData.PolicyType];
		if (fromVirtueData ~= nil and toVirtueData ~= nil) then
			if (fromVirtueData.PolicyBranchType == categoryData.Type and toVirtueData.PolicyBranchType == categoryData.Type) then
				IGE_AddVirtueLine(viewingPlayer, categoryControl.Background, fromVirtueData, toVirtueData);
			end
		else
			print("SCRIPTING ERROR: Could not find corresponding database entries when drawing line from " .. virtuePrereqData.PrereqPolicy .. " to " .. virtuePrereqData.PolicyType);
		end
	end

	--Virtue buttons
	for virtueData in GameInfo.Policies() do
		if (not Game.IsKickerPolicy(virtueData.ID)) then
			if (virtueData.PolicyBranchType == categoryData.Type) then
				if (virtueData.Type == categoryData.FreeFinishingPolicy) then
					-- Don't draw free finishers
				elseif (virtueData.Type == categoryData.FreePolicy) then
					-- Openers are a special case, as they unlock the whole category for us
					IGE_AddVirtueRootButton(viewingPlayer, categoryControl.Background, virtueData, categoryData);
				else
					-- Regular virtues
					IGE_AddVirtueButton(viewingPlayer, categoryControl.Background, virtueData, categoryData);
				end
			end
		end
	end
end

function IGE_GetTotalVirtuesInCategory(categoryData)
	local count = 0;
	for policyData in GameInfo.Policies("PolicyBranchType = \"" .. categoryData.Type .. "\"") do
		if (not Game.IsKickerPolicy(policyData.ID)) then
			count = count + 1;
		end
	end
	return count;
end

function IGE_AddVirtueLine(viewingPlayer, parent, fromVirtueData, toVirtueData)
	local lineControl = {};
	ContextPtr:BuildInstanceForControl("VirtueLineInstance", lineControl, parent);
	if (fromVirtueData.GridX ~= toVirtueData.GridX) then
		lineControl.MainLine:SetWidth(lineControl.MainLine:GetWidth() * 1.5);
	end

	local fromCoordinates = IGE_GetVirtueCoordinates(fromVirtueData);
	local toCoordinates = IGE_GetVirtueCoordinates(toVirtueData);

	fromCoordinates.y = fromCoordinates.y + g_IGEFromLineYOffset;
	toCoordinates.y = toCoordinates.y + g_IGEToLineYOffset;
	local shiftX = lineControl.MainLine:GetWidth() / 2;

	lineControl.MainLine:SetStartVal(fromCoordinates.x, fromCoordinates.y);
	lineControl.MainLine:SetEndVal(toCoordinates.x, toCoordinates.y);
	lineControl.LeftLine:SetStartVal(fromCoordinates.x - shiftX, fromCoordinates.y);
	lineControl.LeftLine:SetEndVal(toCoordinates.x - shiftX, toCoordinates.y);
	lineControl.RightLine:SetStartVal(fromCoordinates.x + shiftX, fromCoordinates.y);
	lineControl.RightLine:SetEndVal(toCoordinates.x + shiftX, toCoordinates.y);
	return lineControl;
end

function IGE_GetVirtueCoordinates(virtueData)
	local depthGridY = 0;
	local depthData = GameInfo.PolicyDepthTypes[virtueData.PolicyDepthType];
	if (depthData ~= nil) then
		depthGridY = depthData.ID * g_IGEPerDepthYOffset;
	end

	local x = g_IGEBaseVirtueXOffset + (virtueData.GridX * g_IGEPerVirtueXOffset);
	local y = g_IGEBaseVirtueYOffset + depthGridY + (virtueData.GridY * g_IGEPerVirtueYOffset);

	local coord = {["x"] = x, ["y"] = y};
	return coord;
end

function IGE_AddVirtueRootButton(viewingPlayer, parent, virtueData, categoryData)
	local virtueControl = {};
	ContextPtr:BuildInstanceForControl("VirtueButtonInstance", virtueControl, parent);
	IconHookup(virtueData.PortraitIndex, 64, virtueData.IconAtlas, virtueControl.VirtueIcon);

	local coordinates = IGE_GetVirtueCoordinates(virtueData);
	virtueControl.VirtueButton:SetOffsetVal(coordinates.x, coordinates.y);

	local tooltip = g_IGECategoryColors[categoryData.ID] .. Locale.ConvertTextKey(virtueData.Description) .. "[ENDCOLOR][NEWLINE][NEWLINE]" .. GetHelpTextForVirtue(virtueData.ID);
	local color = g_IGEUnavailableVirtueColor;
	local texture = g_IGEUnacquiredVirtueTexture;
	if (viewingPlayer:IsPolicyBranchUnlocked(categoryData.ID)) then
		color = g_IGEAcquiredVirtueColors[categoryData.ID];
		texture = g_IGEAcquiredVirtueTextures[categoryData.ID];
	elseif (viewingPlayer:CanUnlockPolicyBranch(categoryData.ID)) then
		color = g_IGEAvailableVirtueColor;
	end
	virtueControl.VirtueIcon:SetColor(RGBAObjectToABGRHex(color));

	virtueControl.VirtueButton:SetTexture(texture);
	virtueControl.VirtueButton:SetToolTipString(tooltip);
	virtueControl.VirtueButton:SetVoid1(categoryData.ID);
	virtueControl.VirtueButton:RegisterCallback(Mouse.eLClick, IGE_OnVirtueRootClicked);
	virtueControl.VirtueButton:RegisterCallback(Mouse.eRClick, function()
		local searchString = Locale.ConvertTextKey(virtueData.Description);
		Events.SearchForPediaEntry(searchString);
	end);	
	return virtueControl;
end

function IGE_AddVirtueButton(viewingPlayer, parent, virtueData, categoryData)
	local virtueControl = {};
	ContextPtr:BuildInstanceForControl("VirtueButtonInstance", virtueControl, parent);
	IconHookup(virtueData.PortraitIndex, 64, virtueData.IconAtlas, virtueControl.VirtueIcon);

	local coordinates = IGE_GetVirtueCoordinates(virtueData);
	virtueControl.VirtueButton:SetOffsetVal(coordinates.x, coordinates.y);

	local tooltip = g_IGECategoryColors[categoryData.ID] .. Locale.ConvertTextKey(virtueData.Description) .. "[ENDCOLOR][NEWLINE][NEWLINE]" .. GetHelpTextForVirtue(virtueData.ID);
	local color = g_IGEUnavailableVirtueColor;
	local texture = g_IGEUnacquiredVirtueTexture;
	if (viewingPlayer:HasPolicy(virtueData.ID)) then
		color = g_IGEAcquiredVirtueColors[categoryData.ID];
		texture = g_IGEAcquiredVirtueTextures[categoryData.ID];
	elseif (viewingPlayer:CanAdoptPolicy(virtueData.ID)) then
		color = g_IGEAvailableVirtueColor;
	end
	virtueControl.VirtueIcon:SetColor(RGBAObjectToABGRHex(color));

	virtueControl.VirtueButton:SetTexture(texture);
	virtueControl.VirtueButton:SetToolTipString(tooltip);
	virtueControl.VirtueButton:SetVoid1(virtueData.ID);
	virtueControl.VirtueButton:RegisterCallback(Mouse.eLClick, IGE_OnVirtueClicked);
	virtueControl.VirtueButton:RegisterCallback(Mouse.eRClick, function()
		local searchString = Locale.ConvertTextKey(virtueData.Description);
		Events.SearchForPediaEntry(searchString);
	end);
	return virtueControl;
end