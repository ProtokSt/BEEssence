-------------------------------------------------
-- Main Menu
-- ===========================================================================
-- Unofficial Patch blessed by Protok St
-- ===========================================================================
include( "InstanceManager" );
----------------------------------------------------------------        
----------------------------------------------------------------        

g_SpacerManager = InstanceManager:new("SpacerInstance", "Spacer", Controls.CreditsList);
g_MajorTitleManager = InstanceManager:new("MajorTitleInstance", "Text", Controls.CreditsList);
g_MinorTitleManager = InstanceManager:new("MinorTitleInstance", "Text", Controls.CreditsList);
g_HeadingManager = InstanceManager:new("HeadingInstance", "Text", Controls.CreditsList);
g_EntryManager = InstanceManager:new("EntryInstance", "Text", Controls.CreditsList);

g_SpacerManager2 = InstanceManager:new("SpacerInstance", "Spacer", Controls.CreditsList2);
g_MajorTitleManager2 = InstanceManager:new("MajorTitleInstance", "Text", Controls.CreditsList2);
g_MinorTitleManager2 = InstanceManager:new("MinorTitleInstance", "Text", Controls.CreditsList2);
g_HeadingManager2 = InstanceManager:new("HeadingInstance", "Text", Controls.CreditsList2);
g_EntryManager2 = InstanceManager:new("EntryInstance", "Text", Controls.CreditsList2);


----------------------------------------------------------------        
----------------------------------------------------------------        
function OnBack()
	UIManager:DequeuePopup( ContextPtr );
end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnBack );


----------------------------------------------------------------        
-- Key Down Processing
----------------------------------------------------------------        
function InputHandler( uiMsg, wParam, lParam )
    if( uiMsg == KeyEvents.KeyDown )
    then
        if( wParam == Keys.VK_RETURN or wParam == Keys.VK_ESCAPE ) then
			OnBack();
        end
    end
    return true;
end
ContextPtr:SetInputHandler( InputHandler );


----------------------------------------------------------------        
----------------------------------------------------------------        
function ShowHideHandler( bIsHide, bIsInit )
	if( not bIsHide ) then
    	Controls.SlideAnim:SetToBeginning();
    	Controls.SlideAnim:Play();
    	Controls.SlideAnim2:SetToBeginning();
    	Controls.SlideAnim2:Play();
	end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

---------------------------------------------------------------- 
function GetPatchCreditsTable()       
	local t = {};
	t = {
	"[1]UNOFFICIAL DLCMOD #CivBE_ESSENCE",
	"[1](For BEYOND EARTH + Rising tide + Exoplanets)",
	"[3]We hope you enjoy the mod, like us enjoyed doing it!",
	"[N]",
	"[1]Design by Migugh (MGH) (BlueFXGames.itch.io)",
	"[N]",
	"[2]Used part of code from other modders:",
	"[1]Protok St (BEAlive Patch & Anchor Ceti)",
	"[1]Ryika (Codex)",
	"[1]Machiavelli (Echoes of Earth)",
	"[1]Paweu (Beyond Centauri)",
	"[1]Minor Annoyance (Domed Life)",
	"[1]Barathor (Larger Ultimate Units)",
	"[3]And many others...",
	"[N]",
	"[2]Testers:",
	"[1]Marcos",
	"[1]Protok St",
	"[N]",
	"[2]Really special thanks to:",
	"[1]Protok St",
	"[N]",
	"[N]",
	"[N]",
	"[N]",
	"[N]",
	};
	
	return t;
end
---------------------------------------------------------------- 
function ReadCredits()
	local creditsFile;		
	local creditsFile2;		
	local endHeader = 0;		
	local creditLine;		
	local creditHeader;		

	creditsFile = UI.GetCredits()
		
	if(not creditsFile) then		
		--print("Can't find file");	
		return	
	end		
	
	local creditsTable = makeTable(creditsFile);
	local creditsTable2 = GetPatchCreditsTable();	
		

	-- make space for Patch credits
	for ts = 1,30 do --1,40
		local spacer = g_SpacerManager:GetInstance();
	end
	
	--print each line out, with header information formatting string
	for key,currentLine in ipairs(creditsTable) do	

		local creditHeader = string.sub(currentLine, 2, 2);
		local creditLine = string.sub(currentLine, 4);

		if creditHeader == "N" then
			local spacer = g_SpacerManager:GetInstance();
		elseif creditHeader == "1" then	
			local majorTitle = g_MajorTitleManager:GetInstance();
			majorTitle.Text:SetText(creditLine);
		elseif creditHeader == "2" then	
			local minorTitle = g_MinorTitleManager:GetInstance();
			minorTitle.Text:SetText(creditLine);
		elseif creditHeader == "3" then	
			local heading = g_HeadingManager:GetInstance();
			heading.Text:SetText(creditLine);
		elseif creditHeader == "4" then	
			local entry = g_EntryManager:GetInstance();
			entry.Text:SetText(creditLine);
		else	
			print("Header type not found.");
		end
	end		
	
	--print creditsTable2
	for key,currentLine in ipairs(creditsTable2) do	

		local creditHeader = string.sub(currentLine, 2, 2);
		local creditLine = string.sub(currentLine, 4);

		if creditHeader == "N" then
			local spacer = g_SpacerManager2:GetInstance();
		elseif creditHeader == "1" then	
			local majorTitle = g_MajorTitleManager2:GetInstance();
			majorTitle.Text:SetText(creditLine);
		elseif creditHeader == "2" then	
			local minorTitle = g_MinorTitleManager2:GetInstance();
			minorTitle.Text:SetText(creditLine);
		elseif creditHeader == "3" then	
			local heading = g_HeadingManager2:GetInstance();
			heading.Text:SetText(creditLine);
		elseif creditHeader == "4" then	
			local entry = g_EntryManager2:GetInstance();
			entry.Text:SetText(creditLine);
		else	
			print("Header type not found 2.");
		end
	end	

	local screenWidth, screenHeight 	= UIManager:GetScreenSizeVal();
	
	Controls.CreditsList2:ReprocessAnchoring();		
	Controls.CreditsList2:CalculateSize();	
	Controls.CreditsList:CalculateSize();		
	Controls.CreditsList:ReprocessAnchoring();		
	Controls.MajorScroll:CalculateInternalSize();	
	
	Controls.CreditsList2:SetOffsetVal(0, 0);
	Controls.CreditsList:SetOffsetVal(0, 0);
	Controls.SlideAnim2:SetEndVal(0, -(Controls.CreditsList2:GetSizeY()));	
	
	Controls.SlideAnim:SetEndVal(0, -(Controls.CreditsList:GetSizeY()));
	
	Controls.SlideAnim2:Play();
	
	Controls.SlideAnim:Play();
end

----------------------------------------------------------------        
---------------------------------------------------------------- 
function makeTable(creditsFile)
	
	local i = 0;
	local prev_i = 1;
	local t = {};
	while true do
		i = string.find(creditsFile, "\r\n", i+1, true)    -- find 'next' newline
		
		if i == nil then break end
		
		local line = string.sub(creditsFile, prev_i, i - 1);
		
		table.insert(t, line)
		prev_i = i + 2;
	end
	
	return t;
	
end
----------------------------------------------------------------        
---------------------------------------------------------------- 

ReadCredits();
