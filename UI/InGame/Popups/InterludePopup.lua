--MGH Modified
-------------------------------------------------
-- Essence Player Interlude Greeting Popup
-------------------------------------------------
local _dpo = true;--Set to true for showing debug info
if _dpo then print("MGH:Essence Player Interlude Greeting Popup"); end
--
local m_PopupInfo = nil;--Popup XML access
local g_Shown = false;--True when is this popup on screen
local g_InterludeMessageNumber = 0;--0=auto
-------------------------------------------------
-------------------------------------------------
function OnPopup(popupInfo)
	if _dpo then print("MGH:InterludePopup variables: "..tostring(m_PopupInfo~=nil).." "..tostring(g_Shown).." "..tostring(g_InterludeMessageNumber)); end
	if _dpo then print("MGH:InterludePopup OnPopup: popupInfo.Type="..tostring(popupInfo.Type).." popupInfo.Data1="..tostring(popupInfo.Data1)); end
	----
	m_PopupInfo = popupInfo;
	--if popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_INTERLUDE then
	if popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_MODDER_1 then --MGH:Someone call our popup window so
		if _dpo then print("MGH:InterludePopup OnPopup ButtonPopupTypes.BUTTONPOPUP_MODDER_1"); end
		----
		if (popupInfo.Data1 == 1) then --To get sure we are who are calling this so we set Data1 to 1
			if ContextPtr:IsHidden() then --Is hidden so we need to show it
				if _dpo then print("MGH:InterludePopup OnPopup ContextPtr:IsHidden()"); end
				----
				g_Shown = true;
				UIManager:QueuePopup(ContextPtr, PopupPriority.InGameUtmost);
			else
				if _dpo then print("MGH:InterludePopup OnPopup NOT ContextPtr:IsHidden()"); end
				----
				OnCloseButtonClicked();
			end
		else --When is called without paremeters normally to open it with PushModal
			if _dpo then print("MGH:InterludePopup OnPopup Data1 is not 1"); end
			if _dpo then g_InterludeMessageNumber = g_InterludeMessageNumber + 1; end
			----
			UIManager:QueuePopup(ContextPtr, PopupPriority.CityStateGreeting);--PopupPriority.EcologyOverview
		end
	--else--was call other so close this one if is still opened --if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_MODDER_1 then
	--	if not ContextPtr:IsHidden() and popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TUTORIAL then
	--		if _dpo then print("MGH:InterludePopup OnPopup NOT ButtonPopupTypes.BUTTONPOPUP_MODDER_1"); end
	--		----
	--		OnCloseButtonClicked();
	--	end
	--	return;
	end
end
Events.SerialEventGameMessagePopup.Add(OnPopup);
-------------------------------------------------
-------------------------------------------------
function OnCloseButtonClicked()
	if _dpo then print("MGH:InterludePopup OnCloseButtonClicked"); end
	----
	UIManager:DequeuePopup(ContextPtr);
	ShowHideHandler(false, false);--MGH:we call inside this function to ContextPtr:SetHide(true);
	--UIManager:PopModal(ContextPtr);
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnCloseButtonClicked);
-------------------------------------------------
-------------------------------------------------
--MGH:This function is called when ContextPtr:SetHide(false);
function ShowWindow()
	if _dpo then print("MGH:InterludePopup ShowWindow"); end
	----
	UIManager:QueuePopup(ContextPtr, PopupPriority.CityStateGreeting);
end
-------------------------------------------------------------------------------
------- Gather UIManager:Queue, UIManager:DequeuePopup, ContextPtr:SetHide
-------------------------------------------------------------------------------
function ShowHideHandler(isHide, isInit)
	if _dpo then print("MGH:InterludePopup ShowHideHandler: isHide="..tostring(isHide).." isInit="..tostring(isInit)) end
	----
	if (not isHide) then
		if (not g_Shown) then
			InterludePopup_UpdateWindow(isInit);
		end
		g_Shown = true;
	else--if isHide then
		g_Shown = false;
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler);--MGH:Register the function for calling it when hide status change
-------------------------------------------------
-------------------------------------------------
--MGH:Close popup with keys
function InputHandler(uiMsg, wParam, lParam)
	if uiMsg == KeyEvents.KeyDown then
		if g_Shown then
			if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
				if _dpo then print("MGH:InterludePopup InputHandler") end
				----
				OnCloseButtonClicked();
			end
		end
		return true;
	end
	--return nil;
end
ContextPtr:SetInputHandler(InputHandler);
-------------------------------------------------
--- Controlling Size and Info Inside Window
-------------------------------------------------
function InterludePopup_UpdateWindow(isInit)
	if _dpo then print("MGH:InterludePopup InterludePopup_UpdateWindow"); end
	----
	local g_screenWidth, g_screenHeight = UIManager:GetScreenSizeVal();
	if _dpo then print("MGH:GetScreenSizeVal(): g_screenWidth="..tostring(g_screenWidth)..", g_screenHeight="..tostring(g_screenHeight)); end
	--Controls.Window:SetSizeVal(g_screenWidth-500,g_screenHeight-500);
	--
	InterludePopup_FormatThisMessage(Game.GetActivePlayer());
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--MGH:Set the message text
function InterludePopup_FormatThisMessage(playerID)
	if _dpo then print("MGH:InterludePopup InterludePopup_FormatThisMessage"); end
	----
	local pPlayer = Players[playerID];
	local iLocalPlayer = Game.GetActivePlayer();
	if(pPlayer ~= nil and playerID == iLocalPlayer and pPlayer:IsHuman()) then
		if _dpo then
			print("playerID={1} is active and is human", playerID);
			print(".GetTurnString=", Game.GetTurnString());
			print(".GetTurnYear=", Game.GetTurnYear());
			print(".CountNumHumanGameTurnActive=", Game.CountNumHumanGameTurnActive());
			print(".GetElapsedGameTurns=", Game.GetElapsedGameTurns());
			print(".GetGameTurn=", Game.GetGameTurn());
			print(".GetGameTurnYear=", Game.GetGameTurnYear());
			print(".GetNumGameTurnActive=", Game.GetNumGameTurnActive());
		end
		----
		
		--MGH:message variables
		--local facctionType = pPlayer:GetCivilizationType();
		local facctionShortDescription = pPlayer:GetCivilizationShortDescription();
		local facctionDescription = pPlayer:GetCivilizationDescription();
		local facctionAdjective = pPlayer:GetCivilizationAdjective();
		local missionDate = Game.GetGameTurnYear();--2600 (should be different if start the game with a later start)
		local numHumanFactions = Game.CountNumHumanGameTurnActive();
		
		-- Title
		local strTitle = Locale.ConvertTextKey("TXT_KEY_MODESSENCE_TUTORIAL_TITLE");
		
		g_InterludeMessageNumber = g_InterludeMessageNumber + 1;
		local num = g_InterludeMessageNumber;
		--if num == 0 then num = Game.GetElapsedGameTurns() + 1; end
		if _dpo then print("MGH:InterludePopup InterludePopup_OnPlayerTurnShowThisMessage num="..num.." Game.GetElapsedGameTurns()=" .. tostring( Game.GetElapsedGameTurns() ) ); end
		
		-- Description --TXT_KEY_INTERLUDE_0 is first message
		local strDescription = Locale.ConvertTextKey("TXT_KEY_MODESSENCE_TUTORIAL_BASICS_A" .. tostring(num), missionDate, numHumanFactions, facctionShortDescription, facctionDescription, facctionAdjective);
		local strPostData = Locale.ConvertTextKey("TXT_KEY_MODESSENCE_TUTORIAL_BASICS_B" .. tostring(num), missionDate, numHumanFactions);

		-- Set strings
		Controls.TitleLabel:SetText(strTitle);--XML ID=TitleLabel
		Controls.DescriptionLabel:SetText(strDescription .. "[NEWLINE][NEWLINE]" .. strPostData);--XML ID=DescriptionLabel

		-- Queue popup
		--UIManager:QueuePopup(ContextPtr, PopupPriority.CityStateGreeting);
		
		-- Size Window
		InterludePopup_SizeWindowToContent();

		-- Sound
		--Events.AudioPlay2DSound("AS2D_INTERFACE_TECH_WINDOW");
	end
end
-------------------------------------------------
-------------------------------------------------
--MGH:Set the message format
function InterludePopup_SizeWindowToContent()
	if _dpo then print("MGH:InterludePopup InterludePopup_SizeWindowToContent"); end
	----
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
----------------------------------------------------------------