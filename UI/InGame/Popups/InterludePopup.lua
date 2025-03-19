--MGH Modified
-------------------------------------------------
-- Essence Player Interlude Greeting Popup
-------------------------------------------------
local _dpo = true;
-- _dpo = false;
if _dpo then print("MGH:Essence Player Interlude Greeting Popup"); end

local m_PopupInfo = nil;
local g_Shown = false;
-------------------------------------------------
-------------------------------------------------
function OnPopup(popupInfo)
	if _dpo then print("MGH:OnPopup Interlude Greeting: "..tostring(popupInfo.Type)..", "..tostring(popupInfo.Interlude));end
	m_PopupInfo = popupInfo;
	--if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_INTERLUDE then
	if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_MODDER_1 then
		if not ContextPtr:IsHidden() and popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TUTORIAL then
			OnCloseButtonClicked();
		end
		return;
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_MODDER_1	then
		if _dpo then print("ButtonPopupTypes.BUTTONPOPUP_MODDER_1");end
		if (popupInfo.Data1 == 1) then
			if (not ContextPtr:IsHidden()) then
				OnCloseButtonClicked()
			else
				g_Shown = true
				UIManager:QueuePopup(ContextPtr, PopupPriority.InGameUtmost);
			end
		else
			UIManager:QueuePopup(ContextPtr, PopupPriority.EcologyOverview);
		end

	end
end
Events.SerialEventGameMessagePopup.Add(OnPopup);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnCloseButtonClicked()
	if _dpo then print("OnCloseButtonClicked"); end
	UIManager:DequeuePopup(ContextPtr);
	--ContextPtr:SetHide(true);
	--UIManager:PopModal(ContextPtr);
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnCloseButtonClicked);
-------------------------------------------------
-------------------------------------------------
function ShowWindow()
	if _dpo then print("ShowWindow"); end
	UIManager:QueuePopup( ContextPtr, PopupPriority.InGameUtmost );
end
-------------------------------------------------------------------------------
------- Gather UIManager:Queue, UIManager:DequeuePopup, ContextPtr:SetHide
-------------------------------------------------------------------------------
function ShowHideHandler(isHide, isInit)
	if _dpo then print("ShowHideHandler started ---- isHide "..tostring(isHide)) end

	if (not isHide) then
		if( not g_Shown ) then
			g_Shown = true;
			UpdateWindow();
		end

	elseif isHide then
		g_Shown = false;
		--UIManager:DequeuePopup( ContextPtr );
		ContextPtr:SetHide(true);
	end

end
ContextPtr:SetShowHideHandler( ShowHideHandler );
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler(uiMsg, wParam, lParam)
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
			OnCloseButtonClicked();
		end
		-- info Print
		if(wParam == Keys.VK_F2) then
			OnPlayerTurnShowInterludeMessage(Game.GetActivePlayer())
		end
		return true;
	end
end
ContextPtr:SetInputHandler( InputHandler );
-------------------------------------------------
--- Controlling Size and Info Inside Window
-------------------------------------------------
function UpdateWindow()
	if _dpo then print("UpdateWindow"); end
	local playerID = Game.GetActivePlayer();
	local pPlayer = Players[playerID];

	local g_screenWidth, g_screenHeight = UIManager:GetScreenSizeVal();
	if _dpo then print("SizeToScreen: "..tostring(g_screenWidth)..", "..tostring(g_screenHeight)); end
	Controls.Window:SetSizeVal(g_screenWidth-500,g_screenHeight-500);

	--OnPlayerTurnShowInterludeMessage(playerID);
end
-------------------------------------------------
-------------------------------------------------








-------------------------------------------------
-------------------------------------------------
function SizeWindowToContent()
	Controls.ContentStack:CalculateSize();
	Controls.ContentStack:ReprocessAnchoring();
	local windowx = 500;
	if(Controls.ContentStack:GetSizeX() > Controls.TitleLabel:GetSizeX()) then
		windowx = Controls.ContentStack:GetSizeX() + 40;
	else
		windowx = Controls.TitleLabel:GetSizeX() + 40;
	end
	local windowy = Controls.ContentStack:GetSizeY() + 75;
	Controls.Window:SetSizeX(windowx);
	Controls.WindowHeader:SetSizeX(windowx);
	Controls.HeaderSeparator:SetSizeX(windowx);
	Controls.Window:SetSizeY(windowy);
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowThisMessage()
	--MGH:Show message
	local ourFacctionName = "PlayerFacctionName-CHANGETOAVARIABLE-Game.GetActivePlayer()";--TODO:CHANGE THIS
	local missionDate = 2100;--TODO:CHANGE THIS
	local numHumanFactions = 1;--TODO:CHANGE THIS
	
	-- Title
	local strTitle = Locale.ConvertTextKey("TXT_KEY_POPUP_STATION_CONQUERED");--TODO:CHANGE THIS
	
	-- Description
	local strDescription = Locale.ConvertTextKey("TXT_KEY_POPUP_STATION_CONQUERED_DESC", ourFacctionName , missionDate, numHumanFactions);--TODO:CHANGE THIS
	local strPostData = "Mission Year 1 - Datalinks (1/1)";

	-- Set strings
	Controls.TitleLabel:SetText(strTitle);
	Controls.DescriptionLabel:SetText(strDescription .. "[NEWLINE][NEWLINE]" .. strPostData);

	-- Queue popup
	UIManager:QueuePopup(ContextPtr, PopupPriority.CityStateGreeting);
	
	-- Size Window
	SizeWindowToContent();

	-- Sound
	Events.AudioPlay2DSound("AS2D_INTERFACE_TECH_WINDOW");
end
----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
Events.GameplaySetActivePlayer.Add(OnCloseButtonClicked);

-- MGH:Interlude Messages system:
----------------------------------------------------
----------------------------------------------------
g_PlayersReadInterlude = {};--empty array
for i = 0, GameDefines.MAX_PLAYERS - 1 do
	g_PlayersReadInterlude[i] = false;
end

function OnPlayerTurnShowInterludeMessage(playerID)
	if _dpo then print("OnPlayerTurnShowInterludeMessage start"); end
    local pPlayer = Players[playerID];
	local iLocalPlayer = Game.GetActivePlayer();
    if(pPlayer ~= nil and playerID == iLocalPlayer and pPlayer:IsHuman() and g_PlayersReadInterlude[playerID] == false)then
		print("MGH: Interlude should be opened for playerID={1}", playerID);
		print(".GetTurnString=", Game.GetTurnString());
		print(".GetTurnYear=", Game.GetTurnYear());
		print(".CountNumHumanGameTurnActive=", Game.CountNumHumanGameTurnActive());
		print(".GetElapsedGameTurns=", Game.GetElapsedGameTurns());
		print(".GetGameTurn=", Game.GetGameTurn());
		print(".GetGameTurnYear=", Game.GetGameTurnYear());
		print(".GetNumGameTurnActive=", Game.GetNumGameTurnActive());
		--ShowThisMessage();
		g_PlayersReadInterlude[playerID] = false;
	end
end
----------------------------------------------------
-- MGH:Add to GameEvents
--GameEvents.PlayerDoTurn.Add(OnPlayerTurnShowInterludeMessage);