--===============================================
-- Interlude Control
--===============================================
-- A Controller for Interlude Popups
----------------------------------------------------
-- dbg print out
local _dpo = true; 
--_dpo = false;
if _dpo then print("---- InterludeControl.lua INIT ----"); end

---- Task 1. Show Interlude Notify each turn after 1
function InterludeControl(playerType)
    if _dpo then print("InterludeControl(playerType = "..tostring(playerType)..", turn: "..tostring(Game.GetGameTurn())..")")end
    local currentTurn = Game.GetGameTurn();
    local iCurrentPlayer = Game:GetActivePlayer();

    -- comparing Player with Current
    if (currentTurn > 1) and (iCurrentPlayer == playerType) then
        -- Data1 - 0/1
        Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_MODDER_1, Data1 = 1} );
        Events.AudioPlay2DSound("AS2D_INTERFACE_POLICY_CONFIRM");
    end

end
GameEvents.PlayerDoTurn.Add(InterludeControl);