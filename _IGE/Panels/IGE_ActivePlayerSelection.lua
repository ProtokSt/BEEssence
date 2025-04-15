-- Released under GPL v3
--------------------------------------------------------------
include("IGE_API_All");
print("IGE_ActivePlayerSelection");
IGE = nil;

local majorPlayerItemManager = CreateInstanceManager("MajorPlayerInstance", "Button", Controls.MajorPlayerList);
local panelID = "PLAYER_SELECTION";
local isVisible = false;
local data = {};

-------------------------------------------------------------------------------------------------
function OnSelectedPanel(ID)
	isVisible = (ID == panelID);
end
LuaEvents.IGE_SelectedPanel.Add(OnSelectedPanel)

-------------------------------------------------------------------------------------------------
local function OnSharingGlobalAndOptions(_IGE)
	IGE = _IGE;
end
LuaEvents.IGE_SharingGlobalAndOptions.Add(OnSharingGlobalAndOptions);

-------------------------------------------------------------------------------------------------
function OnInitialize()
	Resize(Controls.Container);
	Resize(Controls.ScrollPanel);
	Controls.Container:SetSizeX(g_panelSizeX);
	Controls.Container:SetSizeY(g_panelSizeY);
	Controls.ScrollPanel:SetSizeX(g_panelSizeX - 20);
	Controls.ScrollPanel:SetSizeY(g_panelSizeY - 46);
	Controls.Stack:SetSizeX(g_panelSizeX - 20);
	Controls.Stack:SetSizeY(g_panelSizeY - 46);
	Controls.ScrollBar:SetSizeY(Controls.ScrollPanel:GetSizeY());

	majorPlayerItemManager.maxHeight = g_listsSizeY;
	
	SetPlayersData(data, { none=false });
end
LuaEvents.IGE_Initialize.Add(OnInitialize);

-------------------------------------------------------------------------------------------------
function OnUpdate()
	Controls.Container:SetHide(not isVisible);
	if not isVisible then return end

	for k, v in pairs(data.allPlayers) do
		v.selected = false;
		v.visible = (v.ID >= 0 and Players[v.ID]:IsAlive() and Players[v.ID]:IsFoundedFirstCity());
		if v.ID == IGE.initialPlayerID then
			v.priority = 10;
			v.label = L("TXT_KEY_YOU").." - "..v.civilizationName;
		else
			v.label = v.civilizationName and v.name.." - "..v.civilizationName or v.name;
			v.priority = 2;
		end
	end

	table.sort(data.majorPlayers, DefaultSort);

	UpdateList(data.majorPlayers, majorPlayerItemManager, function(v) LuaEvents.IGE_SelectPlayer(v.ID) end);
end
LuaEvents.IGE_Update.Add(OnUpdate);
