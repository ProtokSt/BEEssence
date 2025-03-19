--MGH Modified
-------------------------------------------------
-- Essence Player Interlude Greeting Popup
-------------------------------------------------
print("MGH:Essence Player Interlude Greeting Popup");
local m_PopupInfo = nil;
-------------------------------------------------
-------------------------------------------------
function OnPopup(popupInfo)
	print("MGH:OnPopup Interlude Greeting");
	if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_STATION_GREETING then return; end
	--
	m_PopupInfo = popupInfo;
	local playerType = m_PopupInfo.Data1;
	local questIndex = m_PopupInfo.Data2;
	--
	if(playerType ~= Game.GetActivePlayer()) then return; end -- Do not show the interlude in other player turn
	--
	if popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_STATION_GREETING then
		ShowThisMessage();
	end
end
-- MGH:Add to Events
Events.SerialEventGameMessagePopup.Add(OnPopup);
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
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnCloseButtonClicked()
	UIManager:DequeuePopup(ContextPtr);
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnCloseButtonClicked);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler(uiMsg, wParam, lParam)
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            OnCloseButtonClicked();
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler(bIsHide, bInitState)
    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();
        	Events.SerialEventGameMessagePopupShown(m_PopupInfo);
        else
            UI.decTurnTimerSemaphore();
            Events.SerialEventGameMessagePopupProcessed.CallImmediate(m_PopupInfo.Type, 0);
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );
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
    local pPlayer = Players[playerID];
	local iLocalPlayer = Game.GetActivePlayer();
	print("MGH:This function is called every turn");
    if(pPlayer ~= nil and playerID == iLocalPlayer and pPlayer:IsHuman() and g_PlayersReadInterlude[playerID] == false)then
		print("MGH: Interlude should be opened for playerID={1}", playerID);
		print(".GetTurnString="Game.GetTurnString());
		print(".GetTurnYear="Game.GetTurnYear());
		print(".CountNumHumanGameTurnActive="Game.CountNumHumanGameTurnActive());
		print(".GetElapsedGameTurns="Game.GetElapsedGameTurns());
		print(".GetGameTurn="Game.GetGameTurn());
		print(".GetGameTurnYear="Game.GetGameTurnYear());
		print(".GetNumGameTurnActive="Game.GetNumGameTurnActive());
		ShowThisMessage();
		g_PlayersReadInterlude[playerID] = false;
	end
end
----------------------------------------------------
-- MGH:Add to GameEvents
GameEvents.PlayerDoTurn.Add(OnPlayerShowInterludeMessage);