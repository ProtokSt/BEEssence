-- Released under GPL v3
--------------------------------------------------------------
include("IGE_API_All");
include( "InstanceManager" );
include( "SupportFunctions" );
include( "TechButtonInclude" );
include( "TechHelpInclude" );
include( "AffinityInclude" );
include( "MathHelpers" );
include( "TechFilterFunctions" );
print("IGE_TechsPanel");
IGE = nil;

local isInitialized = false;


local function OnSharingGlobalAndOptions(_IGE)
	IGE = _IGE;
end
LuaEvents.IGE_SharingGlobalAndOptions.Add(OnSharingGlobalAndOptions);

-- ===== 1 Time Toggable Options =============================================

local m_IGEfastDebug						= false; 	-- Debug: Use to animated in all nodes while debugging (before they are done loaded.)
local m_IGEshowTechIDsDebug				= false;		-- Debug: Show technology IDs in their names
local m_IGEforceNodesNum					= -1; 		-- Debug: Force only this many nodes on the tree
local isHasLineSparkles				= false;	-- Faint Sparkles along ALL lines
local isHasLineSparklesAvailable		= true;		-- Same as above but for available lines only.


-- ===== COLOR and TEXTURE constants =========================================

-- Colors are in ABGR hex format:
local MAX_LINE_SPARKLES					= 12;				-- Number of art elements moving on a line
local g_IGEcolorLine 						= 0x7f74564a;
local g_IGEcolorAvailableLine				= 0xffb4366b; --0xffF05099; --0xff501040; --0xffb4366b;	 -- purple 	

local g_IGEcolorNotResearched 				= 0x50ffffff; --0xbb7d7570;	 -- gray 		125, 117, 	112
local g_IGEcolorAvailable					= 0xaaffffff;
local g_IGEcolorCurrent 					= 0xfff09020;	 -- blue 		251, 187, 	74
local g_IGEcolorAlreadyResearched			= 0xffd6b8a3;	 -- 
local g_IGEcolorWhiteAlmost			 	= 0xfffafafa;	 -- white		250, 250, 	250
local g_IGEcolorNodeSelectedCursor			= 0xffe09050;
local g_IGEcolorNotResearchedSmallIcons	= 0xff908070;

-- TechWebAtlas:
local g_IGEtextureTearFullNotResearched	= { u=1,	v=1 };		-- 68x68
local g_IGEtextureTearFullResearched		= { u=69,	v=1 };
local g_IGEtextureTearFullSelected			= { u=137,	v=1 };
local g_IGEtextureTearFullAvailable		= { u=205,	v=1 };
local g_IGEtextureTearLeafNotResearched	= { u=1,	v=70 };
local g_IGEtextureTearLeafResearched		= { u=54,	v=70 };
local g_IGEtextureTearLeafSelected			= { u=107,	v=70 };
local g_IGEtextureTearLeafAvailable		= { u=160,	v=70 };


local g_IGEtextColors = {};
g_IGEtextColors["AlreadyResearched"]		= g_IGEcolorWhiteAlmost;
g_IGEtextColors["Free"]					= g_IGEcolorNotResearched;
g_IGEtextColors["CurrentlyResearching"]	= g_IGEcolorCurrent;
g_IGEtextColors["Available"]				= g_IGEcolorNotResearched;
g_IGEtextColors["Locked"]					= g_IGEcolorNotResearched;
g_IGEtextColors["Unavailable"]				= g_IGEcolorNotResearched;

local g_IGEiconColors = {};
g_IGEiconColors["AlreadyResearched"]		= g_IGEcolorWhiteAlmost;
g_IGEiconColors["Free"]					= g_IGEcolorAvailable;
g_IGEiconColors["CurrentlyResearching"]	= g_IGEcolorWhiteAlmost;
g_IGEiconColors["Available"]				= g_IGEcolorAvailable;
g_IGEiconColors["Locked"]					= g_IGEcolorNotResearched;
g_IGEiconColors["Unavailable"]				= g_IGEcolorNotResearched;

local g_IGEsmallIconColors = {};
g_IGEsmallIconColors["AlreadyResearched"]		= g_IGEcolorWhiteAlmost;
g_IGEsmallIconColors["Free"]					= g_IGEcolorNotResearchedSmallIcons;
g_IGEsmallIconColors["CurrentlyResearching"]	= g_IGEcolorWhiteAlmost;
g_IGEsmallIconColors["Available"]				= g_IGEcolorNotResearchedSmallIcons;
g_IGEsmallIconColors["Locked"]					= g_IGEcolorNotResearchedSmallIcons;
g_IGEsmallIconColors["Unavailable"]			= g_IGEcolorNotResearchedSmallIcons;

local g_IGEtextureBgFull = {};
g_IGEtextureBgFull["AlreadyResearched"]	= g_IGEtextureTearFullResearched;
g_IGEtextureBgFull["Free"]					= g_IGEtextureTearFullAvailable;
g_IGEtextureBgFull["CurrentlyResearching"]	= g_IGEtextureTearFullSelected;
g_IGEtextureBgFull["Available"]			= g_IGEtextureTearFullAvailable;
g_IGEtextureBgFull["Locked"]				= g_IGEtextureTearFullNotResearched;
g_IGEtextureBgFull["Unavailable"]			= g_IGEtextureTearFullNotResearched;

local g_IGEtextureBgLeaf = {};
g_IGEtextureBgLeaf["AlreadyResearched"]	= g_IGEtextureTearLeafResearched;
g_IGEtextureBgLeaf["Free"]					= g_IGEtextureTearLeafAvailable;
g_IGEtextureBgLeaf["CurrentlyResearching"]	= g_IGEtextureTearLeafSelected;
g_IGEtextureBgLeaf["Available"]			= g_IGEtextureTearLeafAvailable;
g_IGEtextureBgLeaf["Locked"]				= g_IGEtextureTearLeafNotResearched;
g_IGEtextureBgLeaf["Unavailable"]			= g_IGEtextureTearLeafNotResearched;

local g_IGEcolorAffinity		= {};
g_IGEcolorAffinity["AFFINITY_TYPE_HARMONY"] 		= 0xffa7d74a;
g_IGEcolorAffinity["AFFINITY_TYPE_PURITY"] 		= 0xff1d1ad8;
g_IGEcolorAffinity["AFFINITY_TYPE_SUPREMACY"] 		= 0xff2fbcff;

local AFFINITY_RING_SIZE	:number				= 46;		-- 46x46
local m_IGEaffinityRingUVIndex	:table				= {};			
m_IGEaffinityRingUVIndex[AFFINITY.harmony]			= {u=0,v=0};
m_IGEaffinityRingUVIndex[AFFINITY.purity]			= {u=1,v=0};
m_IGEaffinityRingUVIndex[AFFINITY.supremacy]		= {u=2,v=0};
m_IGEaffinityRingUVIndex[AFFINITY.purityharmony]	= {u=0,v=1};
m_IGEaffinityRingUVIndex[AFFINITY.supremacypurity]	= {u=1,v=1};
m_IGEaffinityRingUVIndex[AFFINITY.harmonysupremacy]= {u=2,v=1};
m_IGEaffinityRingUVIndex[AFFINITY.harmonypuritysupremacy]= {u=0,v=2};	-- Yes there is one that has all three.

-- ===== Static Constants ===================================================

local m_IGEsmallButtonTextureSize 	= 45;
local g_IGEmaxSmallButtons 		= 6;	-- Maximum number of small buttons per tech
local MAX_TECH_NAME_LENGTH 		= 32; 	-- Locale.Length(Locale.Lookup("TXT_KEY_TURNS"));
local NUM_SEARCH_CONTROLS		:number = 5;		-- Number of search result fields.
local SEARCH_TYPE_MAIN_TECH		:number = 1;
local SEARCH_TYPE_UNLOCKABLE	:number = 2;
local SEARCH_TYPE_MISC_TEXT		:number = 3;
local SEARCH_SCORE_HIGH			:number = 5;		-- Be favored in search results
local SEARCH_SCORE_MEDIUM		:number = 3;		-- Less favored in search results
local SEARCH_SCORE_LOW			:number = 1;		-- Less favored in search results
local REFRESH_ALL_IDS			:table	= { 51 };	-- Memetwork (in Orbital Networks); Techs, that if completed, affect TT or other values on all nodes

-- ===== Members ===================================================

local g_IGEloadedTechButtonNum 	= 1;	-- number of tech buttons created
local g_IGEmaxTechs				= 0;

local g_IGEisOpen				= false;

local g_IGETechLineManager 	= InstanceManager:new( "TechLineInstance", 	 	"TechLine", 		Controls.TechTreeDragPanel );
local g_IGEBGLineManager 		= InstanceManager:new( "BackgroundLineInstance","Line", 			Controls.TechTreeDragPanel );
local g_IGESparkleManager 		= InstanceManager:new( "SparkleInstance",		"Sparkle", 			Controls.TechTreeDragPanel );
local g_IGESelectedTechManager = InstanceManager:new( "SelectedWebInstance", 	"Accoutrements",	Controls.TechTreeDragPanel );
local g_IGEFilteredTechManager = InstanceManager:new( "SelectedWebInstance", 	"Accoutrements",	Controls.FilteredDragPanel );
local g_IGETechInstanceManager = InstanceManager:new( "TechWebNodeInstance", 	"TechButton", 		Controls.TechTreeDragPanel );
local g_IGELeafInstanceManager = InstanceManager:new( "TechWebLeafInstance", 	"TechButton", 		Controls.TechTreeDragPanel );
local m_IGEHighlightNodeIM		:table = InstanceManager:new( "HighlightNodeInstance", 	"Content", 			Controls.TechTreeDragPanel );


local g_IGENeedsFullRefreshOnOpen 	= false;
local g_IGENeedsFullRefresh 		= false;
local g_IGENeedsNodeArtRefresh		= true;
local m_IGEnumQueuedItems			= 0;

local g_IGEradiusScalar		= 400;		-- applied to the GridRadius value set on a tech entry to produce the true screen-unit value
local g_IGEgridRatio			= 0.6;		-- default ratio of y-axis to x-axis. Anything other than 1 will produce an elliptical look to the web
local g_IGElineInstances 		= {};		-- offsets are synced with table above for corresponding, actual line coordinates to draw

local g_IGEscreenWidth			= -1;					-- screen resolution width
local g_IGEscreenHeight		= -1;					-- screen resolution height
local g_IGEscreenCenterH		= -1;					-- half screen width
local g_IGEscreenCenterV		= -1;					-- half screen height
local g_IGEwebExtents			= { xmin=0, ymin= 0, xmax= 0, ymax= 0 };	-- how far does diagram


local g_IGEtechButtons 		= {};					-- Collection of all the buttons
local g_IGEcurrentTechButton;							-- Button of the tech currently being researched
local g_IGEselectedArt;								-- Art for the selected node.
local g_IGEselectedFilteredArt;						-- Art for the selected node if it's filtered out.
local g_IGEtechs;										-- cache of techs for across-frame (stream) loading
local g_IGEanimValueAfterLoad	= 0;					-- value (0 to 1) for animation in after loading
local g_IGEupdateAnim			= 0;					-- persistant value for animating (after load)
local m_IGEhighlightedArt		:table;					-- Art to callout a node.

local g_IGEtechLeafToParent	= {};					-- Temporary, for storing leaf techs
local g_IGEtechParentToLeafs	= {};

local m_IGEisEnterPressedInSearch		:boolean = false;	-- Was enter pressed while doing a search (instead of using mouse to click).
local g_IGEfilterTable			= {};					-- Contains table of filters
local g_IGEcurrentFilter		= nil;					-- Filter currently being used in displaying techs.
local g_IGEcurrentFilterLabel	= nil;					-- Filter text for the current filter.
local g_IGEsearchTable					= {};
 
local isVisible = false;

-------------------------------------------------------------------------------------------------
function OnInitialize()
	local pPlayer = IGE.currentPlayer;
	local activeTeam = Teams[pPlayer:GetTeam()];
	local civType 	= GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type;

	
	if (not isInitialized) then
		-- Setup filter area
		local pullDownButton = Controls.FilterPulldown:GetButton();	
		pullDownButton:SetText( "   "..Locale.ConvertTextKey("TXT_KEY_TECHWEB_FILTER"));	
		local pullDownLabel = pullDownButton:GetTextControl();
		pullDownLabel:SetAnchor("L,C");
		pullDownLabel:ReprocessAnchoring();


		-- Hard coded/special filters:
		table.insert( g_IGEfilterTable, { "", "TXT_KEY_TECHWEB_FILTER_NONE", nil } );

		-- Load entried into filter table from TechFilters XML data
		for row in GameInfo.TechFilters() do
			table.insert(g_IGEfilterTable, { row.IconString, row.Description, g_TechFilters[row.Type] });
		end

		for i,filterType in ipairs(g_IGEfilterTable) do
			local filterIconText = filterType[1];
			local filterLabel	 = Locale.ConvertTextKey( filterType[2] );
			local filterFunction = filterType[3];
        
			local controlTable	 = {};        
			Controls.FilterPulldown:BuildEntry( "FilterItemInstance", controlTable );

			controlTable.Button:SetText( filterLabel );
			local labelControl = controlTable.Button:GetTextControl();
			labelControl:SetAnchor("L,C");
			labelControl:ReprocessAnchoring();

			-- If a text icon exists, use it and bump the label in the button over.
			if filterIconText ~= nil and filterIconText ~= "" then
				controlTable.IconText:SetText( filterIconText );
				labelControl:SetOffsetVal(35, 0);
				filterLabel = filterIconText .." ".. filterLabel;
			else
				labelControl:SetOffsetVal(5, 0);	-- Move over ever so slightly anyway.
				filterLabel = filterLabel;
			end

			-- Use a lambda function to organize how paramters will be passed...
			controlTable.Button:RegisterCallback( Mouse.eLClick,  function() IGE_OnFilterClicked( filterLabel, filterFunction ); end );
		end
		Controls.FilterPulldown:CalculateInternals();

		IGE_DrawBackground();

		Controls.SearchResult1:RegisterCallback( Mouse.eLClick, IGE_OnSearchResult1ButtonClicked );
		Controls.SearchResult2:RegisterCallback( Mouse.eLClick, IGE_OnSearchResult2ButtonClicked );
		Controls.SearchResult3:RegisterCallback( Mouse.eLClick, IGE_OnSearchResult3ButtonClicked );
		Controls.SearchResult4:RegisterCallback( Mouse.eLClick, IGE_OnSearchResult4ButtonClicked );
		Controls.SearchResult5:RegisterCallback( Mouse.eLClick, IGE_OnSearchResult5ButtonClicked );

		GatherInfoAboutUniqueStuff( civType );
		g_IGEscreenCenterH = 1276 / 2;
		g_IGEscreenCenterV = 410 / 2;
		g_IGEwebExtents = { 
			xmin=-g_IGEscreenCenterH, 
			ymin=-g_IGEscreenCenterV, 
			xmax=g_IGEscreenCenterH, 
			ymax=g_IGEscreenCenterV 
		};
		IGE_BuildTechConnections();

		-- Create instance here that shows selected node.
		-- This is not in the XML but exactly here so it's created after the lines, but
		-- before the Nodes are created.  Otherwise, z-order will make the art look bad
		-- (lines going through nodes, etc.. )
		g_IGEselectedArt = g_IGESelectedTechManager:GetInstance();
		g_IGEselectedArt.LeafPieces:SetHide( true );
		g_IGEselectedArt.FullPieces:SetHide( true );

		m_IGEhighlightedArt = m_IGEHighlightNodeIM:GetInstance();
		m_IGEhighlightedArt.Content:SetHide( false );
		
		-- Now create one for the filtered layer, so if an item is filtered out but is selected this
		-- will be used instead of the one above.
		g_IGEselectedFilteredArt = g_IGEFilteredTechManager:GetInstance();
		g_IGEselectedFilteredArt.LeafPieces:SetHide( true );
		g_IGEselectedFilteredArt.FullPieces:SetHide( true );	
		g_IGEselectedFilteredArt.Accoutrements:ChangeParent( Controls.FilteredDragPanel );

		techPediaSearchStrings = {};

		local nodesToPreload = 8;
		if ( not (m_IGEforceNodesNum == -1) ) then
			nodesToPreload = m_IGEforceNodesNum;
		end
		local iTech = 0;
		g_IGEtechs = {};
		for tech in GameInfo.Technologies() do
			iTech = iTech + 1;		
			if iTech < nodesToPreload then
				IGE_AddTechNode( tech );			
				g_IGEloadedTechButtonNum = iTech;
			end
			g_IGEtechs[iTech] = tech;
		end	
		g_IGEmaxTechs = #g_IGEtechs;
		if (m_IGEfastDebug) then					g_IGEmaxTechs = 40; end -- debug: - faster debugging by limiting techs
		if ( not (m_IGEforceNodesNum == -1) ) then	g_IGEmaxTechs = g_IGEforceNodesNum; end
	
		-- resize the panel to fit the contents
		Controls.TechTreeDragPanel:CalculateInternalSize();
		Controls.FilteredDragPanel:CalculateInternalSize();

		-- Set callbacks from drag control
		Controls.TechTreeDragPanel:SetDragCallback(   	 IGE_OnDragChange );

		 -- start centered
		Controls.TechTreeDragPanel:SetDragOffset( g_IGEscreenCenterH, g_IGEscreenCenterV );
		Controls.FilteredDragPanel:SetDragOffset( g_IGEscreenCenterH, g_IGEscreenCenterV );

		IGE_ClearSearchResults();
		IGE_RefreshDisplay();
		ContextPtr:SetUpdate( IGE_OnUpdateAddTechs );

		-- Debug: Needed for hotloading or certain things (keyboard input, won't work.)
		if ( not ContextPtr:IsHidden() ) then
			g_IGEisOpen = true;
			Events.SerialEventToggleTechWeb(false);
		end
		isInitialized = true;		
	end

	Resize(Controls.Container);

	
	local tt = L("TXT_KEY_IGE_TECHS_PANEL_HELP");
	LuaEvents.IGE_RegisterTab("TECHS", L("TXT_KEY_IGE_TECHS_PANEL"), 4, "change",  tt);
end
LuaEvents.IGE_Initialize.Add(OnInitialize)

----------------------------------------------
function OnSelectedPanel(ID)
	isVisible = (ID == "TECHS");
end
LuaEvents.IGE_SelectedPanel.Add(OnSelectedPanel);

function OnUpdate()
	--Controls.Container:SetHide(not isVisible);
	if not isVisible then return end

	--UIManager:QueuePopup(ContextPtr, PopupPriority.eUtmost);
	g_IGEisOpen = true;
	ContextPtr:SetHide(false);
	g_IGENeedsNodeArtRefresh = true;
	IGE_RefreshDisplay();

	LuaEvents.IGE_SetMouseMode(IGE_MODE_NONE);
end
LuaEvents.IGE_Update.Add(OnUpdate);

function OnClose ()
	--UIManager:DequeuePopup( ContextPtr );
	Events.SerialEventToggleTechWeb(false);
    g_IGEisOpen = false;
	ContextPtr:SetHide(true);
	LuaEvents.IGE_SetTab("PLAYERS");
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose );

-- ===========================================================================
--	Programmatically Draw an oval via line segments
-- ===========================================================================
function IGE_DrawBackgroundOval( distance, color )

	local start = 0;
	local step	= 360 / ( 50 + ((math.ceil(distance/100) * 4) ));

	local x,y;
	local ox,oy = PolarToRatioCartesian( distance, start, g_IGEgridRatio );
	for degrees = start+step,361, step do
		x, y = PolarToRatioCartesian( distance, degrees, g_IGEgridRatio );

		local lineInstance 	= g_IGEBGLineManager:GetInstance();
		lineInstance.Line:SetWidth( 2 + ((distance/2500) * 16) );
		lineInstance.Line:SetColor( color );
		lineInstance.Line:SetStartVal( x, y);
		lineInstance.Line:SetEndVal( ox, oy );
		lineInstance.Line:SetHide(false);		
		
		-- Save old points for ending of line for next loop...
		ox = x;
		oy = y;
	end
end

-- ===========================================================================
--	Programmatically draw the background.
-- ===========================================================================
function IGE_DrawBackground()
	local MAX_BOUNDS	= 1900;
	local MAX_SPARKLES	= 200;

	g_IGEBGLineManager:ResetInstances();

	-- Draw multiple rings pointing to center
	for distance=100,MAX_BOUNDS,370 do
		--DrawBackgroundOval( distance-5, 0x03f0c0b0 );	-- style it, slightly smaller ring with each ring
		IGE_DrawBackgroundOval( distance, 0x14f0c0b0 );
	end
end

-- ===========================================================================
--	Create collection of coordiantes that map lines between techs
-- ===========================================================================
function IGE_BuildTechConnections()	
	local connectionsSeen = {};
	g_IGElineInstances = {};

	for row in GameInfo.Technology_Connections() do
		local firstTech = GameInfo.Technologies[row.FirstTech];
		local secondTech = GameInfo.Technologies[row.SecondTech];
		-- Techs must be valid and both cannot be leafs
		if ( firstTech ~= nil and secondTech ~= nil ) then
			
			-- Swap based on ID or if a child tech
			if (firstTech.ID > secondTech.ID) or (firstTech.LeafTech and not secondTech.LeafTech) then
				local temp = firstTech;
				firstTech = secondTech;
				secondTech = temp;
			end

			-- Now smaller ids are first in the list with the accept of children techs.

			-- One parent may have many leaves
			if ( g_IGEtechParentToLeafs[firstTech.ID] == nil) then
				g_IGEtechParentToLeafs[firstTech.ID] = {};
			end

			if (firstTech.LeafTech and secondTech.LeafTech) then
			
				-- If there is a chain of children, more likely they will need to be sorted out
				-- by traversing from parent to most leaf child.  This will have to be done later.
				print("(Maybe) TODO: Implement chained leafs; if we use them");

			elseif ( secondTech.LeafTech ) then
				
				local leafs = g_IGEtechParentToLeafs[firstTech.ID];
				table.insert( leafs, secondTech );

				-- One leaf can only have one parent
				g_IGEtechLeafToParent[secondTech.ID] = firstTech;
			
			else
			
				local hash = firstTech.ID .. '_' .. secondTech.ID;

				-- Draw a line for unseen connections
				if not connectionsSeen[hash] then
					connectionsSeen[hash] = true;
				
					-- Protect the flock (even in script... make sure DB entry has proper values!)
					if firstTech.GridRadius ~= nil and secondTech.GridRadius ~= nil then

						local startX, startY= IGE_GetTechXY( firstTech );
						local endX, endY 	= IGE_GetTechXY( secondTech );
						local lineInstance 	= g_IGETechLineManager:GetInstance();

						lineInstance["firstTechId"]	= firstTech.ID;
						lineInstance["secondTechId"]= secondTech.ID;
						lineInstance["sX"]			= startX;
						lineInstance["sY"]			= startY;
						lineInstance["eX"]			= endX;
						lineInstance["eY"]			= endY;
						if ( isHasLineSparkles ) then
							lineInstance["sparkle1"]	= g_IGESparkleManager:GetInstance();
							lineInstance["sparkle2"]	= g_IGESparkleManager:GetInstance();
							lineInstance["sparkle3"]	= g_IGESparkleManager:GetInstance();
						end
						if ( isHasLineSparklesAvailable ) then
							--print("Sparkles for: ", startX .. ", ".. startY .." to ".. endX ..", ".. endY );
							for availSparkleIdx=1,MAX_LINE_SPARKLES,1 do
								lineInstance["extra"..tostring(availSparkleIdx)]	= g_IGESparkleManager:GetInstance();
							end
						end

						table.insert( g_IGElineInstances,	lineInstance );
					else
						print("Tech "..tech.Description.." misisng <GridRadius>.");
					end
				end
			end
		end -- if nil
	end
end

-- ===========================================================================
--	Obtain the screen space X and Y coordiantes for a tech
--	ARGS:	tech object
--	RETURNS: x,y
-- ===========================================================================
function IGE_GetTechXY( tech )

	if tech.LeafTech then

		local button 		= g_IGEtechButtons[ tech.ID ];

		-- Only dynamically place children if guaranteed all are loaded.
		if ( g_IGEloadedTechButtonNum >= g_IGEmaxTechs ) then
			
			button.TechButton:SetHide( false );			
			--button.TechButton:SetAlpha( g_IGEanimValueAfterLoad );

			-- Obtain the parent to this leaf
			local parentTech 	= button.parent;
			local parentButton 	= g_IGEtechButtons[ parentTech.ID ];

			-- Loop through the children of the parent, when it eventually finds
			-- this child... do all the maths and return.
			for i,child in ipairs(parentButton.children) do
				if (child.ID == tech.ID) then
					local parentx:number ,parenty :number = parentButton.TechButton:GetOffsetVal();
					return parentx + 38, parenty + (36 + (i*69));
				end
			end
			print("WARNING: A leaf tech couldn't be dynamically positioned against it's parent.", tech.Type, parentTech.Type );
		else
			button.TechButton:SetHide( true );
		end
	end


	if tech.GridRadius == 0 then
		return 0,0;
	end

	local x,y = PolarToRatioCartesian( tech.GridRadius * g_IGEradiusScalar, tech.GridDegrees, g_IGEgridRatio );
	return x, y;
end

-- ===========================================================================
--	Create a new node in the web based on a tech
--		tech, The technology the node should be representing.
-- ===========================================================================
function IGE_AddTechNode( tech )

	-- Build node type based on if this is a "full" node or a leaf node.
	local thisTechButtonInstance;
	if (tech.LeafTech) then
		thisTechButtonInstance = g_IGELeafInstanceManager:GetInstance();
	else
		thisTechButtonInstance = g_IGETechInstanceManager:GetInstance();
	end

	if thisTechButtonInstance then
		
		thisTechButtonInstance.tech = tech;						-- point back to tech (easy access)		
		g_IGEtechButtons[tech.ID] = thisTechButtonInstance;		-- store this instance off for later		
		
		-- add the input handler to this button
		thisTechButtonInstance.TechButton:SetVoid1( tech.ID );
		thisTechButtonInstance.TechButton:SetVoid2( tech.LeafTech );	
		--thisTechButtonInstance.NodeName:SetVoid1( tech.ID );	-- ditto to label
		--thisTechButtonInstance.NodeName:SetVoid2( 0 );

		--thisTechButtonInstance.TechButton:RegisterCallback( Mouse.eRClick, GetTechPedia );
		thisTechButtonInstance.TechButton:RegisterCallback( Mouse.eRClick, IGE_TechClicked );

		techPediaSearchStrings[tostring(thisTechButtonInstance.TechButton)] = tech.Description;

		--local scienceDisabled = Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE);
 		--if (not scienceDisabled) then
		--	thisTechButtonInstance.TechButton	:RegisterCallback( Mouse.eLClick, IGE_TechSelected );
		--	thisTechButtonInstance.NodeName		:RegisterCallback( Mouse.eLClick, IGE_TechSelected );
		--end

		thisTechButtonInstance.TechButton:SetToolTipString( GetHelpTextForTech(tech.ID) );

		if ( tech.LeafTech ) then
			thisTechButtonInstance.parent 	= g_IGEtechLeafToParent[tech.ID];
			thisTechButtonInstance.isLeaf	= true;
		else
			thisTechButtonInstance.children = g_IGEtechParentToLeafs[tech.ID];
			thisTechButtonInstance.isLeaf	= false;
		end
		
		-- update the picture
		if IconHookup( tech.PortraitIndex, 64, tech.IconAtlas, thisTechButtonInstance.TechPortrait ) then
			--thisTechButtonInstance.TechPortrait:SetHide( false  );
		else
			thisTechButtonInstance.TechPortrait:SetHide( true );
		end

		-- Affinity ring
		local affinities:table = {};
		local hasPurity		:boolean= false;
		local hasSupremacy	:boolean= false;
		local hasHarmony	:boolean= false;
		local affinity		:number;
		for techAffinityPair in GameInfo.Technology_Affinities()  do
			if techAffinityPair.TechType == tech.Type then
				if		techAffinityPair.AffinityType == "AFFINITY_TYPE_SUPREMACY"	then hasSupremacy=true; 
				elseif	techAffinityPair.AffinityType == "AFFINITY_TYPE_PURITY"		then hasPurity	=true; 
				elseif	techAffinityPair.AffinityType == "AFFINITY_TYPE_HARMONY"	then hasHarmony	=true; 
				end
			end
		end

		if hasPurity and hasSupremacy and hasHarmony then	
			affinity = AFFINITY.harmonypuritysupremacy;
		elseif hasPurity and hasSupremacy then				affinity = AFFINITY.supremacypurity;
		elseif hasHarmony and hasPurity then				affinity = AFFINITY.purityharmony;
		elseif hasSupremacy and hasHarmony then				affinity = AFFINITY.harmonysupremacy;
		elseif hasPurity				then				affinity = AFFINITY.purity;
		elseif hasSupremacy				then				affinity = AFFINITY.supremacy;
		elseif hasHarmony				then				affinity = AFFINITY.harmony;
		end
		thisTechButtonInstance.AffinityRing:SetHide( affinity==nil );
		if affinity ~= nil then
			thisTechButtonInstance.AffinityRing:SetTextureOffsetVal( 
				m_IGEaffinityRingUVIndex[affinity].u * AFFINITY_RING_SIZE, 
				m_IGEaffinityRingUVIndex[affinity].v * AFFINITY_RING_SIZE 
			);
		end

		IGE_AddSmallButtons( thisTechButtonInstance );

		-- Add the tech's name and contents from "small buttons" (buildings, etc...) for search system
		
		local techName = Locale.ConvertTextKey( tech.Description );
		table.insert( g_IGEsearchTable, { word=techName, tech=tech, type=SEARCH_TYPE_MAIN_TECH } );
		
		for _,smallButtonText in pairs(g_recentlyAddedUnlocks) do
			--print("text: ", smallButtonText);
			smallButtonText = Locale.ConvertTextKey(smallButtonText);
			table.insert( g_IGEsearchTable, { word=smallButtonText, tech=tech, type=SEARCH_TYPE_UNLOCKABLE } );
		end
	else
		print("ERROR: Unable to create a new tech button instance for ", tech.Description);
	end
end

function IGE_TechClicked (techID, isLeaf)
	local pPlayer = IGE.currentPlayer;
	local activeTeam = Teams[pPlayer:GetTeam()];
	if(techID ~= nil) then
		if (activeTeam:IsHasTech(techID) ~= true) then
			activeTeam:SetHasTech(techID, true);
			Events.AudioPlay2DSound("AS2D_INTERFACE_TECH_WEB_CONFIRM");
		elseif (activeTeam:IsHasTech(techID)) then
			activeTeam:SetHasTech(techID, false);
			Events.AudioPlay2DSound("AS2D_INTERFACE_BUTTON_CLICK_BACK");
		end
	end

	OnUpdate();
end

function IGE_AddSmallButtons( techButtonInstance )
	AddSmallButtonsToTechButton( techButtonInstance, techButtonInstance.tech, g_IGEmaxSmallButtons, m_IGEsmallButtonTextureSize, 1);
end

-- ===========================================================================
--
--	eventRaiser,	Control hosting the tech web
--	x,				horizontal offset amount
--	y,				vertical offset amount
-- ===========================================================================
function IGE_OnDragChange( eventRaiser, x, y )
	-- Clamp to tree's dimensions (clamp half to max as we shift the screen over to center)

	-- Get center
	x = x - g_IGEscreenCenterH;
	y = y - g_IGEscreenCenterV;

	-- Clamp
	local EXTRA_SPACE = 150;
	local clampx = math.clamp(x, g_IGEwebExtents.xmin - EXTRA_SPACE, g_IGEwebExtents.xmax );
	local clampy = math.clamp(y, g_IGEwebExtents.ymin, g_IGEwebExtents.ymax );

	-- Put back the offset
	x = clampx + g_IGEscreenCenterH;
	y = clampy + g_IGEscreenCenterV;

	Controls.TechTreeDragPanel:SetDragOffset( x, y );
	Controls.FilteredDragPanel:SetDragOffset( x, y );

	--print( "extens: ", g_webExtents.xmin..","..g_webExtents.xmax, g_webExtents.ymin..","..g_webExtents.ymax, "   clamp: ",clampx..","..clampy,"   xy: ",x..","..y );	

	-- Tell listeners (aka: minimap) the offset...
	LuaEvents.TechWebMiniMapNewPosition( x, y );
end

-- ===========================================================================
--	Given a tech, update it's corresponding button
-- ===========================================================================
function IGE_RefreshDisplayOfSpecificTech( tech )
	local pPlayer = IGE.currentPlayer;
	local activeTeam = Teams[pPlayer:GetTeam()];


	local techID 			= tech.ID;
	local thisTechButton 	= g_IGEtechButtons[techID];
  	local numFreeTechs 		= pPlayer:GetNumFreeTechs();
 	local researchTurnsLeft = pPlayer:GetResearchTurnsLeft( techID, true ); 	
 	local turnText 			= IGE_GetTurnText( researchTurnsLeft );
 	local isTechOwner 		= activeTeam:GetTeamTechs():HasTech(techID);
 	local isNowResearching	= (pPlayer:GetCurrentResearch() == techID);


	-- Advisor recommendations...

	-- Setup the stack to hold (any) advisor recommendations.
	-- Do this first as it may effect the amount of space for the node's name.
	thisTechButton.AdvisorStack:DestroyAllChildren();
	thisTechButton.advisorsNum = 0;
	local advisorInstance  = {};
	ContextPtr:BuildInstanceForControl( "AdvisorRecommendInstance", advisorInstance, thisTechButton.AdvisorStack );
	
	-- Create instance(s) per advisors for this tech.
	for iAdvisorLoop = 0, AdvisorTypes.NUM_ADVISOR_TYPES - 1, 1 do
		if Game.IsTechRecommended(tech.ID, iAdvisorLoop) then

			local advisorX			= -2;
			local advisorY			= -6;
			local advisorTooltip	= "";
			if ( thisTechButton.isLeaf ) then
				advisorX = 11;
			end			

			advisorInstance.EconomicRecommendation:SetHide( true );
			advisorInstance.MilitaryRecommendation:SetHide( true );
			advisorInstance.ScienceRecommendation:SetHide( true );
			advisorInstance.CultureRecommendation:SetHide( true );
			advisorInstance.GrowthRecommendation:SetHide( true );

			local pControl = nil;
			if (iAdvisorLoop	== AdvisorTypes.ADVISOR_ECONOMIC) then			
				advisorToolTip	= Locale.ConvertTextKey( "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_ECONOMIC");
				pControl		= advisorInstance.EconomicRecommendation;
			elseif (iAdvisorLoop == AdvisorTypes.ADVISOR_MILITARY) then
				advisorToolTip	= Locale.ConvertTextKey( "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_MILITARY");
				pControl		= advisorInstance.MilitaryRecommendation;
			elseif (iAdvisorLoop == AdvisorTypes.ADVISOR_SCIENCE) then
				advisorToolTip	= Locale.ConvertTextKey( "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_SCIENCE");
				pControl		= advisorInstance.ScienceRecommendation;
			elseif (iAdvisorLoop == AdvisorTypes.ADVISOR_FOREIGN) then	-- ADVISOR_CULTURE?
				advisorToolTip	= Locale.ConvertTextKey( "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_FOREIGN");
				pControl		= advisorInstance.CultureRecommendation;
			elseif (iAdvisorLoop == AdvisorTypes.ADVISOR_GROWTH) then	-- Does not exist?
				advisorToolTip	= Locale.ConvertTextKey( "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_GROWTH");
				pControl		= advisorInstance.GrowthRecommendation;
			end

			if (pControl) then
				pControl:SetHide( false );
				thisTechButton.advisorsNum  = thisTechButton.advisorsNum + 1;	-- track amt for other code
			end
		
			--advisorInstance.AdvisorMarking:ChangeParent( thisTechButton.bg );
			advisorInstance.AdvisorMarking:SetOffsetVal( 0, -2 );
			--advisorInstance.AdvisorBackground:SetOffsetVal( advisorX, advisorY );
			advisorInstance.AdvisorMarking:SetToolTipString( advisorTooltip );
			
		end
	end


	-- Update the name of this node's instance
	local techName = Locale.ConvertTextKey( tech.Description );
	techName = Locale.TruncateString(techName, MAX_TECH_NAME_LENGTH, true);
	if ( m_IGEshowTechIDsDebug ) then
		techName = tostring(techID) .. " " .. techName;
	end
	if ( not isTechOwner ) then
		techName = Locale.ToUpper(techName) .. " ".. turnText;
	else
		techName = Locale.ToUpper(techName);
	end
	--TruncateStringWithTooltip( thisTechButton.NodeName, 
	thisTechButton.NodeName	:SetText( techName );


	-- Update queue & tooltip regions.	
	if ( m_IGEnumQueuedItems > 0 ) then
		
		local progressAmount	= nil;
		local queuePosition		= pPlayer:GetQueuePosition( tech.ID );
		if queuePosition ~= 1 then 
			-- If queue is active, then only show spill-over tech for that one.
			-- But still show progress we have past that (ex. from Expeditions)
			local overflowResearch = pPlayer:GetOverflowResearch();
			local researchTowardsThis = pPlayer:GetResearchProgress(tech.ID);
			progressAmount = researchTowardsThis - overflowResearch;
			if (progressAmount < 0) then
				progressAmount = 0;
			end
		end

		thisTechButton.TechButton:SetToolTipString( GetHelpTextForTech(techID, progressAmount) );
		thisTechButton.NodeName:SetToolTipString( GetHelpTextForTech(techID, progressAmount) );
		
	else
		thisTechButton.TechButton:SetToolTipString( GetHelpTextForTech(techID), nil );
		thisTechButton.NodeName:SetToolTipString( GetHelpTextForTech(techID), nil );
	end


 	-- Rebuild the small buttons if needed
 	if (g_IGENeedsFullRefresh) then
		IGE_AddSmallButtons( thisTechButton )
 	end
 	
 	local scienceDisabled = Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE);
 	
	--if(not scienceDisabled) then
	--	thisTechButton.TechButton:SetVoid1( techID ); -- indicates tech to add to queue
	--	thisTechButton.TechButton:SetVoid2( numFreeTechs ); -- how many free techs
		--AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, techID, numFreeTechs, Mouse.eLClick, IGE_TechSelected );
		--AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, techID, numFreeTechs, Mouse.eLDblClick, OnClose );
	--end

 	if isTechOwner then -- the player (or more accurately his team) has already researched this one
		IGE_ShowTechState( thisTechButton, "AlreadyResearched");
		--if(not scienceDisabled) then
		--	thisTechButton.TechQueueLabel:SetHide( true );
		--	thisTechButton.TechButton:SetVoid2( 0 ); -- num free techs
		--	thisTechButton.TechButton:SetVoid1( -1 ); -- indicates tech is invalid
			--AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, -1, 0, Mouse.eLClick, IGE_TechSelected );
			--AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, -1, 0, Mouse.eLDblClick, OnClose );
 		--end
 		
 	elseif isNowResearching then -- the player is currently researching this one
				
		IGE_RealizeTechQueue( thisTechButton, techID );
		if pPlayer:GetNumFreeTechs() > 0 then
			
			IGE_ShowTechState( thisTechButton, "Free");		-- over-write tech queue #
			thisTechButton.TechQueueLabel:SetText( freeString );
			thisTechButton.TechQueueLabel:SetHide( false );

			-- Keep selected node's art hidden while choosing a free tech.

		else
			g_IGEcurrentTechButton = thisTechButton;
 			IGE_ShowTechState( thisTechButton, "CurrentlyResearching");
			thisTechButton.TechQueueLabel:SetHide( true );

	 		-- Determine values for the memeter
			local researchProgressPercent 		= 0;
			local researchProgressPlusThisTurnPercent = 0;
			local researchTurnsLeft 			= pPlayer:GetResearchTurnsLeft(techID, true);
			local currentResearchProgress 		= pPlayer:GetResearchProgress(techID);
			local researchNeeded 				= pPlayer:GetResearchCost(techID);
			local researchPerTurn 				= pPlayer:GetScience();
			local currentResearchPlusThisTurn 	= currentResearchProgress + researchPerTurn;		
			researchProgressPercent 			= currentResearchProgress / researchNeeded;
			researchProgressPlusThisTurnPercent = currentResearchPlusThisTurn / researchNeeded;		
			if (researchProgressPlusThisTurnPercent > 1) then
				researchProgressPlusThisTurnPercent = 1
			end

			currentResearchPlusThisTurn = currentResearchPlusThisTurn * 0.1;

			-- Set art, etc... based on if it's a leaf or not.

			local x,y 		= IGE_GetTechXY( tech );
			local width 	= thisTechButton.TechButton:GetSizeX();
			local height 	= thisTechButton.TechButton:GetSizeY();
			local accoutrementx;
			local accoutrementy;
			local meterx;
			local metery;
			local meterHeight;

			-- Set the selected art based on if a filter is active for this.
			local selectedArt = g_IGEselectedArt;
			if ( g_IGEcurrentFilter ~= nil ) then
				-- In filter mode, is this tech in the filter?
				if not g_IGEcurrentFilter( tech ) then
					-- Current tech isn't in the filter, use the filtered version of the art.
					selectedArt = g_IGEselectedFilteredArt;					
				end
			end
			selectedArt.Accoutrements:SetHide( false );


			if ( thisTechButton.isLeaf ) then
				
				-- Show selecetd leaf art				
				selectedArt.FullPieces:SetHide( true );
				selectedArt.LeafPieces:SetHide( false );
				
				accoutrementx 	= x - 34;
				accoutrementy 	= y - 30;
				meterx 			= width + thisTechButton.bg:GetSizeX() - 11;
				metery  		= 1;
				meterHeight 	= selectedArt.AmountLeaf:GetSizeY();

				-- Since art is interlaced, ensure offsets are even
				local nextHeight= math.floor(-meterHeight + (meterHeight * researchProgressPlusThisTurnPercent));
				local thisHeight= math.floor(-meterHeight + (meterHeight * researchProgressPercent));
				if ( (nextHeight) % 2 == 0) then nextHeight = nextHeight - 1; end
				if ( (thisHeight) % 2 == 1) then thisHeight = thisHeight - 1; end

				selectedArt.Accoutrements	:SetOffsetVal( accoutrementx, accoutrementy );
				selectedArt.BorderLeaf		:SetHide( false );
				selectedArt.MeterLeaf		:SetOffsetVal( meterx, metery );
				selectedArt.NewAmountLeaf	:SetTextureOffsetVal( 0, nextHeight);
				selectedArt.AmountLeaf 		:SetTextureOffsetVal( 0, thisHeight);
			
			else

				-- Show non-leaf stuff for a selected piece.
				selectedArt.FullPieces:SetHide( false );
				selectedArt.LeafPieces:SetHide( true );
									
				accoutrementx 	= x - 46;
				accoutrementy 	= y - 36;
				meterx 			= width + thisTechButton.bg:GetSizeX() - 10;
				metery  		= 0;
				meterHeight 	= selectedArt.AmountFull:GetSizeY();

				-- Since art is interlaced, ensure offsets are even
				local nextHeight= math.floor(-meterHeight + (meterHeight * researchProgressPlusThisTurnPercent));
				local thisHeight= math.floor(-meterHeight + (meterHeight * researchProgressPercent));
				if ( (nextHeight) % 2 == 0) then nextHeight = nextHeight - 1; end
				if ( (thisHeight) % 2 == 1) then thisHeight = thisHeight - 1; end

				selectedArt.Accoutrements	:SetOffsetVal( accoutrementx, accoutrementy );
				selectedArt.BorderFull		:SetHide( false );
				selectedArt.MeterFull		:SetOffsetVal( meterx, metery );
				selectedArt.NewAmountFull	:SetTextureOffsetVal( 0, nextHeight);
				selectedArt.AmountFull 		:SetTextureOffsetVal( 0, thisHeight);
					
			end
		end

 	elseif (pPlayer:CanResearch( techID ) and not scienceDisabled) then -- the player research this one right now if he wants
 		-- deal with free 		
		IGE_RealizeTechQueue( thisTechButton, techID );
		if pPlayer:GetNumFreeTechs() > 0 then
 			IGE_ShowTechState( thisTechButton, "Free");		-- over-write tech queue #
			-- update queue number to say "FREE"
			thisTechButton.TechQueueLabel:SetText( freeString );
			thisTechButton.TechQueueLabel:SetHide( false );
		else
			IGE_ShowTechState( thisTechButton, "Available");			
		end

 	elseif (not pPlayer:CanEverResearch( techID ) or pPlayer:GetNumFreeTechs() > 0) then
  		IGE_ShowTechState( thisTechButton, "Locked");
		-- have queue number say "LOCKED"
		thisTechButton.TechQueueLabel:SetText( "" );
		thisTechButton.TechQueueLabel:SetHide( false );
		--if(not scienceDisabled) then
		--	thisTechButton.TechButton:SetVoid1( -1 ); 
		--	thisTechButton.TechButton:SetVoid2( 0 ); -- num free techs
		--	AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, -1, 0, Mouse.eLClick, IGE_TechSelected );
			--AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, -1, 0, Mouse.eLDblClick, OnClose );
 		--end
 	else -- currently unavailable
 		IGE_ShowTechState( thisTechButton, "Unavailable");		
		IGE_RealizeTechQueue( thisTechButton, techID );
		if pPlayer:GetNumFreeTechs() > 0 then
			thisTechButton.TechButton:SetVoid1( -1 ); 
			AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, -1, 0, Mouse.eLClick, function() end );
		else
			--if(not scienceDisabled) then
			--	thisTechButton.TechButton:SetVoid1( tech.ID );
			--	AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, techID, numFreeTechs, Mouse.eLClick, IGE_TechSelected );
				--AddCallbackToSmallButtons( thisTechButton, g_IGEmaxSmallButtons, techID, numFreeTechs, Mouse.eLDblClick, OnClose );
			--end
		end
	end

	-- Place the node in teh web.
	local x,y = IGE_GetTechXY( tech );
	x = x - (thisTechButton.TechButton:GetSizeX() / 2);
	y = y - (thisTechButton.TechButton:GetSizeY() / 2);
	thisTechButton.TechButton:SetOffsetVal( x, y );
	

	-- Update extends of web if this node pushes it out some.
	local TECH_NODE_WIDTH = 250;
	if (x - TECH_NODE_WIDTH) < g_IGEwebExtents.xmin then
		g_IGEwebExtents.xmin = (x - TECH_NODE_WIDTH);
	elseif x > g_IGEwebExtents.xmax then
		g_IGEwebExtents.xmax = x;
	end

	if y < g_IGEwebExtents.ymin then
		g_IGEwebExtents.ymin = y;
	elseif y > g_IGEwebExtents.ymax then
		g_IGEwebExtents.ymax = y;
	end


	-- Filter, if one is set.
	if g_IGEcurrentFilter ~= nil then
		if g_IGEcurrentFilter( tech ) then
			thisTechButton.TechButton:ChangeParent( Controls.TechTreeDragPanel );
		else
			thisTechButton.TechButton:ChangeParent( Controls.FilteredDragPanel );
		end
	else
		thisTechButton.TechButton:ChangeParent( Controls.TechTreeDragPanel );
	end
end

-- ===========================================================================
-- ===========================================================================
function IGE_RefreshDisplay()
	local pPlayer = IGE.currentPlayer;
	local activeTeam = Teams[pPlayer:GetTeam()];

	g_IGEcurrentTechButton = nil;

	IGE_DrawLines();

	-- Hide selected art for cases of "free" tech being granted or just completed
	-- researching tech.  If it needs to be turned on, the node that is selected
	-- will turn it on.
	g_IGEselectedArt.Accoutrements:SetHide( true );
	g_IGEselectedFilteredArt.Accoutrements:SetHide( true );

	m_IGEnumQueuedItems	= 0;
	local queuePosition = 0;
	for tech in GameInfo.Technologies() do
		queuePosition = pPlayer:GetQueuePosition( tech.ID );		
		if ( queuePosition > 0 ) then
			m_IGEnumQueuedItems = m_IGEnumQueuedItems + 1;
		end
	end

	-- Draw only the techs that have finished loading.
	local iTech = 0;
	for tech in GameInfo.Technologies() do
		iTech = iTech + 1;
		if iTech <= g_IGEloadedTechButtonNum then
			IGE_RefreshDisplayOfSpecificTech( tech );
		end
	end	

	-- Is a filter active? If so raise the art wall for those that don't pass the filter.
	Controls.FilteredTechWall:SetHide( g_IGEcurrentFilter == nil );
		
	g_IGENeedsFullRefresh = false;	
	g_IGENeedsNodeArtRefresh = false;
end

-- ===========================================================================
--	Read in line values and apply new multiplier to them to redraw at a 
--	different zoom level.
-- ===========================================================================
function IGE_DrawLines()
	local pPlayer = IGE.currentPlayer;
	local activeTeam = Teams[pPlayer:GetTeam()];
	local i;
	local lineInstance;
	local startX;
	local startY;
	local endX;
	local endY;
	local color;
	local firstTechId;
	local secondTechId;
	local lineWidth = 5;
	local currentResearchID = pPlayer:GetCurrentResearch();

	--print("Setting line width: ", lineWidth, "zoom: ".. g_zoomCurrent );  --??TRON debug

	for i,lineInstance in ipairs(g_IGElineInstances) do

		startX	= lineInstance["sX"];
		startY	= lineInstance["sY"];
		endX	= lineInstance["eX"];
		endY	= lineInstance["eY"];

		firstTechId 	= lineInstance["firstTechId"];
		secondTechId 	= lineInstance["secondTechId"];

		local hasFirst		= activeTeam:GetTeamTechs():HasTech( firstTechId );
		local hasSecond		= activeTeam:GetTeamTechs():HasTech( secondTechId );


		if 	(firstTechId == currentResearchID and hasSecond) or 
			(secondTechId == currentResearchID and hasFirst) then
			color = g_IGEcolorCurrent;					
		elseif hasFirst or hasSecond then
			if hasFirst and hasSecond then
				color = g_IGEcolorAlreadyResearched;
			else
				--print("Available tech: ",firstTechId.." to "..secondTechId);
				color = g_IGEcolorAvailableLine;
			end
		else
			color = g_IGEcolorNotResearched;
		end
		
		lineInstance.TechLine:SetWidth( lineWidth );		
		lineInstance.TechLine:SetColor( color );
		lineInstance.TechLine:SetStartVal(startX, startY);
		lineInstance.TechLine:SetEndVal(endX, endY);
		lineInstance.TechLine:SetHide(false);

		-- Animation on *ALL* lines
		if IGE_isHasLineSparkles then
			local speed = 0.2;
			for i=1,MAX_LINE_SPARKLES,1 do				
				local sparkleInstance = lineInstance["extraAll" .. tostring(i) ];
				sparkleInstance.Sparkle:SetBeginVal(startX, startY);
				sparkleInstance.Sparkle:SetEndVal(endX, endY);
				sparkleInstance.Sparkle:SetProgress( math.random() );
				sparkleInstance.Sparkle:SetSpeed( speed + (math.random() *0.2) );
				sparkleInstance.Sparkle:Play();
				sparkleInstance.Sparkle:SetHide(false);					
			end			
		end

		-- Animation on the available tech lines
		if isHasLineSparklesAvailable then			
			local speed = 0.2;
			for i=1,MAX_LINE_SPARKLES,1 do
				local sparkleInstance	= lineInstance["extra" .. tostring(i) ];
				if ( color == g_IGEcolorAvailableLine ) then
					sparkleInstance.Sparkle:SetBeginVal(startX, startY);
					sparkleInstance.Sparkle:SetEndVal(endX, endY);
					sparkleInstance.Sparkle:SetProgress( math.random() );
					sparkleInstance.Sparkle:SetSpeed( speed + (math.random() *0.1) );
					sparkleInstance.Sparkle:Play();
					sparkleInstance.Sparkle:SetHide(false);					
				else
					sparkleInstance.Sparkle:SetHide(true);
				end
			end			
		end
		
	end
end

-- ===========================================================================
--	Adds a few techs at a time; essentially streaming them into existance
--	as a single allocation in LUA for the whole web takes quite a while.
--	fDTime, delta time frame previous frame.
-- ===========================================================================
function IGE_OnUpdateAddTechs( fDTime )
	g_IGEloadedTechButtonNum = g_IGEloadedTechButtonNum + 1;

	local tech = g_IGEtechs[g_IGEloadedTechButtonNum];
	
	IGE_AddTechNode( tech );
	IGE_RefreshDisplayOfSpecificTech( tech );

	Controls.LoadingBarBacking:SetHide( false );
	Controls.LoadingBar:SetSizeX( g_IGEscreenWidth * (g_IGEloadedTechButtonNum / g_IGEmaxTechs) );

	if g_IGEloadedTechButtonNum >= g_IGEmaxTechs then
		ContextPtr:SetUpdate( IGE_OnUpdateAnimateAfterLoad );  	-- animate in
		g_IGENeedsNodeArtRefresh = true;						-- initialize art in leaf node.
		g_IGEselectedArt.Accoutrements:SetHide( false );	   	-- show current selection
	end
end

-- ===========================================================================
-- ===========================================================================
function IGE_OnUpdateAnimateAfterLoad( fDTime )
	g_IGEanimValueAfterLoad = g_IGEanimValueAfterLoad + (fDTime * 7);
	
	if ( g_IGEanimValueAfterLoad >= 1 ) then
		Controls.LoadingBarBacking:SetHide( true );
		g_IGEanimValueAfterLoad = 1;
		ContextPtr:SetUpdate( IGE_OnUpdate );  --turn off callback, empty function
	end

	IGE_RefreshDisplay();

	-- Set initial minimap positions and show.
	if ( IGE_m_miniMapControl ) then
		local xoff, yoff 	= Controls.TechTreeDragPanel:GetDragOffsetVal();
		LuaEvents.TechWebMiniMapNewPosition( xoff, yoff );
		IGE_m_miniMapControl:SetHide( false );
	end
end

function IGE_OnUpdate( fDTime )
	g_IGEupdateAnim = g_IGEupdateAnim + fDTime;
	if ( g_IGEupdateAnim > 1000000 ) then
		g_IGEupdateAnim = g_IGEupdateAnim - 1000000;		
	end
	ContextPtr:SetUpdate( function( misc ) end );  --turn off callback, empty function
end

-- ===========================================================================
-- ===========================================================================
function IGE_GetTurnText( turnNumber )
	local pPlayer = IGE.currentPlayer;
	local activeTeam = Teams[pPlayer:GetTeam()];
	local turnText = "";
	if 	pPlayer:GetScience() > 0 then
		local turns = tonumber( turnNumber );
		turnText = "("..turns..")";
	end
	return turnText;
end

-- ===========================================================================
--	ARGS:	Tech button to show
--			Name of the state of the button
-- ===========================================================================
function IGE_ShowTechState( thisTechButton, techStateString )
	
	-- Store last tech state for minimap to read.
	thisTechButton["techStateString"] = techStateString;

	if ( not g_IGENeedsNodeArtRefresh ) then
		return;
	end
	
	thisTechButton.TechPortrait	:SetColor( g_IGEiconColors[techStateString] );
	thisTechButton.NodeName		:SetColor( g_IGEtextColors[techStateString] );

	-- Increase background size to match text width
	local spaceUsedByAdvisors = (32 * thisTechButton.advisorsNum);
	local extraSpaceNeeded	  = 40;
	if ( thisTechButton.NodeName:GetSizeX() > (thisTechButton.bg:GetSizeX() - (extraSpaceNeeded + spaceUsedByAdvisors)) ) then
		thisTechButton.bg:SetSizeVal( thisTechButton.NodeName:GetSizeX() + (extraSpaceNeeded + spaceUsedByAdvisors), thisTechButton.bg:GetSizeY() );
	end

	-- Is it a full node or leaf node?
	if thisTechButton.tech.LeafTech then

		-- Leaf
		for i=1,g_IGEmaxSmallButtons do
			if ( thisTechButton["B"..i] == nil) then
				break;
			end
			thisTechButton["B"..i]:SetColor( g_IGEsmallIconColors[techStateString] );
		end	

		thisTechButton.Tear 		:SetTextureOffsetVal ( g_IGEtextureBgLeaf[techStateString].u, g_IGEtextureBgLeaf[techStateString].v );
		thisTechButton.TechButton		:SetSizeVal(50, 50);
		thisTechButton.bg 				:SetHide(false);
		thisTechButton.Tear 			:SetHide(false);
		thisTechButton.NodeName 		:SetHide(false);

	else			

		for i=1,g_IGEmaxSmallButtons do
			if ( thisTechButton["B"..i] == nil) then
				break;
			end
			--thisTechButton["B"..i]:SetColor( g_IGEsmallIconColors[techStateString] );
		end	

		thisTechButton.Tear 		:SetTextureOffsetVal ( g_IGEtextureBgFull[techStateString].u, g_IGEtextureBgFull[techStateString].v );
		thisTechButton.bg 				:SetHide(false);
		thisTechButton.NodeName 		:SetHide(false);
		thisTechButton.NodeHolder		:SetHide(true);
	end
end

-- ===========================================================================
-- 	Update queue number if needed, place in proper position.
-- ===========================================================================
function IGE_RealizeTechQueue( thisTechButton, techID )
	local pPlayer = IGE.currentPlayer;
	local activeTeam = Teams[pPlayer:GetTeam()];
	local queuePosition = pPlayer:GetQueuePosition( techID );
	
	if queuePosition == -1 then
		thisTechButton.TechQueueLabel:SetHide( true );
	else
		thisTechButton.TechQueueLabel:SetHide( false );					
		thisTechButton.TechQueueLabel:SetText( tostring( queuePosition-1 ) );

		if ( queuePosition == m_IGEnumQueuedItems ) then
			thisTechButton.TechQueueLabel:SetColor( 0xeeffffff, 2 );	-- glow on (last item)
		else
			thisTechButton.TechQueueLabel:SetColor( 0x00000000, 2 );	-- glow off
		end


	end

	-- If a leaf, reposition
	if ( thisTechButton.isLeaf ) then
		thisTechButton.TechQueueLabel:SetOffsetVal( 52, 0 );
	else
		thisTechButton.TechQueueLabel:SetOffsetVal( 70, 0 );
	end
end

-- ===========================================================================
-- Update the Filter text with the current label.
-- ===========================================================================
function IGE_RefreshFilterDisplay()
	local pullDownButton = Controls.FilterPulldown:GetButton();	
	if ( g_IGEcurrentFilter == nil ) then
		pullDownButton:SetText( "  "..Locale.ConvertTextKey("TXT_KEY_TECHWEB_FILTER"));
	else
		pullDownButton:SetText( "  "..Locale.ConvertTextKey(g_IGEcurrentFilterLabel));
	end
end

-- ===========================================================================
--	filterLabel,	Readable lable of the current filter.
--	filterFunc,		The funciton filter to apply to each node as it's built,
--					nil will reset the filters to none.
-- ===========================================================================
function IGE_OnFilterClicked( filterLabel, filterFunc )		
	g_IGEcurrentFilter=filterFunc;
	g_IGEcurrentFilterLabel=filterLabel;

	IGE_RefreshFilterDisplay();
	IGE_RefreshDisplay();
end

-- ===========================================================================
-- ===========================================================================
function IGE_OnSearchResult1ButtonClicked() IGE_PanToTech( Controls.SearchResult1["tech"] ); end
function IGE_OnSearchResult2ButtonClicked() IGE_PanToTech( Controls.SearchResult2["tech"] ); end
function IGE_OnSearchResult3ButtonClicked() IGE_PanToTech( Controls.SearchResult3["tech"] ); end
function IGE_OnSearchResult4ButtonClicked() IGE_PanToTech( Controls.SearchResult4["tech"] ); end
function IGE_OnSearchResult5ButtonClicked() IGE_PanToTech( Controls.SearchResult5["tech"] ); end

-- ===========================================================================
-- ===========================================================================
function IGE_ClearSearchResults()
	Controls.SearchResult1:SetText( "" );
	Controls.SearchResult2:SetText( "" );
	Controls.SearchResult3:SetText( "" );
	Controls.SearchResult4:SetText( "" );
	Controls.SearchResult5:SetText( "" );

	Controls.SearchResult1["tech"] = nil;
	Controls.SearchResult2["tech"] = nil;
	Controls.SearchResult3["tech"] = nil;
	Controls.SearchResult4["tech"] = nil;
	Controls.SearchResult5["tech"] = nil;
end

-- ===========================================================================
-- 	Search Input processing
-- ===========================================================================
function IGE_OnSearchInputHandler( charJustPressed, searchString )	
	IGE_ClearSearchResults();	

	-- Nothing to search?  Then done...
	if string.len(searchString) < 1 then
		return;
	end
	

	-- Obtain words that have a match
	local results 	= {};
	local strength 	= 0;
	for i,searchEntry in ipairs(g_IGEsearchTable) do
		strength = IGE_GetPotentialSearchMatch( searchString, searchEntry );
		if strength > 0 then
			table.insert( results, { strength=strength, searchEntry=searchEntry } );
		end
	end

	-- Sort by strength
	local ResultsSort = function(a, b)
		return a.strength > b.strength;
	end
	table.sort( results, ResultsSort );

	local searchControl;
	local searchControlName;
	for i,resultEntry in ipairs(results) do

		if i > NUM_SEARCH_CONTROLS then	
			break;
		end	

		searchControlName = "SearchResult"..str(i);
		searchControl = Controls[searchControlName];

		local text = resultEntry["searchEntry"]["word"];
		if ( resultEntry["searchEntry"]["type"] == SEARCH_TYPE_UNLOCKABLE ) then
			local techDescription = Locale.ConvertTextKey( resultEntry["searchEntry"]["tech"].Description);
			text = text .." (" .. techDescription .. ")";
		end

		searchControl:SetText( text );
		searchControl["tech"] = resultEntry["searchEntry"]["tech"];

		--print("IGE_ONSearchInputHandler--Sorted: ", i, resultEntry["searchEntry"]["word"] );
	end

end
Controls.SearchEditBox:RegisterCharCallback( IGE_OnSearchInputHandler );

-- ===========================================================================
--	Enter was pressed or editbox lost focus due to click outside it.
-- ===========================================================================
function IGE_OnKeywordSearchHandler( searchString )	
	-- BONUS: Common commands to effect the tech web other than searchincloseg
	--		  NOTE: English only... translations? localization look ups?
	if ( searchString == "close" or searchString == "exit") then
		local defaultSearchlabel = Locale.Lookup("TXT_KEY_TECHWEB_SEARCH");
		Controls.SearchEditBox:SetText(defaultSearchlabel);
		Controls.SearchEditBox:SetColor( 0x80808080 );
		IGE_OnClose();		-- Fake a close button clicked
		return;
	end
	
	-- BONUS: Common geek society search strings which translate to "home" node, the center of the techweb 
	if ( searchString == "~" or searchString == "localhost" or searchString == "127.0.0.1" ) then
		searchString = Locale.ConvertTextKey( m_allTechs[1].Description );
	end

	if searchString=="" then
		IGE_ClearSearchResults();
		local defaultSearchlabel = Locale.Lookup("TXT_KEY_TECHWEB_SEARCH");
		Controls.SearchEditBox:SetText(defaultSearchlabel);
		Controls.SearchEditBox:SetColor( 0x80808080 );
	else
		local mostLikelySearchText = Controls.SearchResult1:GetText();
		if ( m_IGEisEnterPressedInSearch and Controls.SearchResult1["tech"] ~= nil and mostLikelySearchText ~= "" ) then
			IGE_PanToTech( Controls.SearchResult1["tech"] );
		end
	end

	m_IGEisEnterPressedInSearch = false;
end
Controls.SearchEditBox:RegisterCommitCallback( IGE_OnKeywordSearchHandler );



-- ===========================================================================
function IGE_OnSearchHasFocus()
	Controls.SearchEditBox:SetText( "" );
	Controls.SearchEditBox:SetColor( 0xffffffff );
	Controls.SearchEditBox:ReprocessAnchoring();
end
Controls.SearchEditBox:RegisterHasFocusCallback( IGE_OnSearchHasFocus );

-- ===========================================================================
--	Pan the web to the specified tech.
--	tech,		The tech to go to.
-- ===========================================================================
function IGE_PanToTech( tech )

	-- Clear out any searches (as they may have caused the pan)	
	IGE_ClearSearchResults();

	-- Fill search with where it's panning...
	Controls.SearchEditBox:SetText( Locale.ConvertTextKey( tech.Description) );
	Controls.SearchEditBox:SetColor( 0x80808080 );

	local sx:number, sy:number	= Controls.TechTreeDragPanel:GetDragOffsetVal();
	local x	:number, y:number	= IGE_GetTechXY( tech );

	Controls.PanControl:RegisterAnimCallback( IGE_OnPanTech );
	Controls.PanControl:SetBeginVal(sx, sy);
	Controls.PanControl:SetEndVal( -x + g_IGEscreenCenterH, -y + g_IGEscreenCenterV );
	Controls.PanControl:SetToBeginning();
	Controls.PanControl:Play();

	-- Highlight the selected node
	m_IGEhighlightedArt.Content:SetHide( false );
	m_IGEhighlightedArt.Content:ChangeParent( g_IGEtechButtons[tech.ID].TechButton );
	m_IGEhighlightedArt.Content:SetOffsetVal(0,0);
	m_IGEhighlightedArt.Content:ReprocessAnchoring();
	m_IGEhighlightedArt.Content:SetToBeginning();
	m_IGEhighlightedArt.Content:Play();

end

-- ===========================================================================
--	Callback per-frame for slide animation.
-- ===========================================================================
function IGE_OnPanTech()
	local x:number, y:number = Controls.PanControl:GetOffsetVal();
	Controls.TechTreeDragPanel:SetDragOffset( x,y );
	Controls.FilteredDragPanel:SetDragOffset( x,y );
end

-- ===========================================================================
--	Take a search string and based on the entry, determine a match score
--	RETURNS: A score for the match, higher score the closer to front.
-- ===========================================================================
function IGE_GetPotentialSearchMatch( searchString, searchEntry )
	local word = searchEntry["word"];

	if string.len(searchString) > string.len( word ) then
		return -1;
	end

	-- Escape out minus sign before doing a match call.
	searchString = string.gsub( searchString, "[%-%*%.%~%$%^%?]", " " );		-- Looks ineffective but it's doing work: param 2 is using % as an escape character, param 3 is a literal!
	local status, match = pcall( string.match, Locale.ToLower(word), Locale.ToLower(searchString) );

	if status then
		if match == nil then
			return -1;
		else				
			local score = string.len( match );		
		
			-- adjust score with importance
			if ( searchEntry["type"] == SEARCH_TYPE_MAIN_TECH ) then
				score = score + SEARCH_SCORE_HIGH;
			elseif ( searchEntry["type"] == SEARCH_TYPE_UNLOCKABLE ) then
				score = score + SEARCH_SCORE_MEDIUM;
			elseif ( searchEntry["type"] == SEARCH_TYPE_MISC_TEXT ) then
				score = score + SEARCH_SCORE_LOW;
			end

			-- adjust score to be higher if pattern is found closer to front
			local num = string.find( Locale.ToLower(word), match );
			if ( num ~= nil and (10-num) > 0) then
				num = (10-num) * 4;
			else
				num = 0;
			end
		
			score = score + num;
			return score;
		end
	end

	return -1;
end