--MGH Modified
---- 2023 - Blessed by Protok St
---- CivilopediaCategory[CategoryMain].PopulateList
---- 
---- CivilopediaCategory[CategoryConcepts].DisplayList
---- CivilopediaCategory[CategoryConcepts].SelectHeading
----
---- CivilopediaCategory[CategoryImprovements].PopulateList
---- CivilopediaCategory[CategoryImprovements].DisplayHomePage
---- CivilopediaCategory[CategoryImprovements].SelectHeading
---- CivilopediaCategory[CategoryImprovements].DisplayList
---- CivilopediaCategory[CategoryImprovements].SelectArticle
---- 	Modernization of Yield
---- CivilopediaCategory[CategoryImprovements].buttonTexture
----
---- CivilopediaCategory[CategoryTech].SelectArticle
----
---- ClearArticle
---- g_PrereqVirtueManager
---- g_PrereqAffinityManager
---- ResizeEtc
---- 
---- CivilopediaCategory[CategoryCivilizations].buttonTexture
---- CivilopediaCategory[CategoryCivilizations].labelString
---- CivilopediaCategory[CategoryCivilizations].SelectHeading
---- CivilopediaCategory[CategoryCivilizations].DisplayList
---- CivilopediaCategory[CategoryCivilizations].DisplayHomePage
---- 
---- UpdateSuperWideTextBlock2

---- TXT_KEY_SIMPLE_NUM_NAMED_YIELD
-------------------------------------------------
-- Civilopedia screen
-------------------------------------------------
local _dpo = true;
--_dpo = false;
include( "InstanceManager" );
include( "IconSupport" );
include( "InfoTooltipInclude" );
local DatalinksDB = Modding.OpenUserData("AC_Datalinks", 1);

-- table.sort method for sorting alphabetically.
function Alphabetically(a, b)
	return Locale.Compare(a.entryName, b.entryName) == -1;
end

local portraitSize = 128;
local buttonSize = 64;

-- various sizes of elements
local wideOuterFrameWidth		= 436;
local wideInnerFrameWidth		= 440;
local wideLabelWrapWidth		= 452; -- 410
local superWideOuterFrameWidth	= 680; -- 680;
local superWideInnerFrameWidth	= 680; -- 680;
local superWideLabelWrapWidth	= 610;
local narrowOuterFrameWidth		= 234;
local narrowInnerFrameWidth		= 238;
local narrowLabelWrapWidth		= 210
local textPaddingFromInnerFrame = 34;
local offsetsBetweenFrames		= 4;
local quoteButtonOffset			= 60;
local numberOfButtonsPerRow		= 3;
local buttonPadding				= 8;
local buttonPaddingTimesTwo		= 16;

-- textures that will be used a lot
local defaultErrorTextureSheet = "TechAtlasSmall.dds";

local addToList = 1;
local dontAddToList = 0;

-- defines for the various categories of topics
local CategoryMain			= 1;
local CategoryConcepts		= 2;
local CategoryTech			= 3;
local CategoryUnits			= 4;
local CategoryUpgrades		= 5;
local CategoryBuildings		= 6;
local CategoryWonders		= 7;
local CategoryVirtues		= 8;
local CategoryEspionage		= 9;
local CategoryCivilizations = 10;
local CategoryQuests		= 11;
local CategoryTerrain		= 12;
local CategoryResources		= 13;
local CategoryImprovements	= 14;
local CategoryAffinities	= 15;
local CategoryStations		= 16;
local CategoryDiplomacy		= 17;
local CategoryArtifacts		= 18;
local m_numCategories		= 18;

local m_selectedCategory = CategoryMain;
local CivilopediaCategory	= {};
local m_historyCurrentIndex	= 0;	-- Current topic index
local m_endTopic			= 0;	--
local m_listOfTopicsViewed	= {};

local sortedList			= {};
local otherSortedList		= {};
local searchableTextKeyList = {};
local searchableList		= {};
local m_categorizedListOfArticles = {};							-- All the articles!
local MAX_ENTRIES_PER_CATEGORY	= 10000;						-- All article are in a 1D array; but virtually are in a 2d array with this being the max per row.
local homePageOfCategoryID		= MAX_ENTRIES_PER_CATEGORY - 1;	-- Home page entries are last (possible) item in a category.


local ConceptBuildingSpecialistsId;
do
	-- Hide this in a scope to prevent later references.
	local conceptBuildingSpecialists =  GameInfo.Concepts["CONCEPT_BUILDINGS_SPECIALISTS"];		
	
	-- If it's not nil, set it to the ID.			
	ConceptBuildingSpecialistsId = conceptBuildingSpecialists and conceptBuildingSpecialists.ID;
end

-- Ignore tables, if for any reason we want to hide an entity from appearing in the tabbed sections
local facilitiesToIgnore = {
	BUILDING_MARSH_FOREST_ENERGY = true,
};
local projectsToIgnore = {
	PROJECT_MOVE_CITY = true,
};
local unitsToIgnore = {
	UNIT_ALIEN_HYDRA_LVL1 = true,
	UNIT_ALIEN_HYDRA_LVL2 = true,
	UNIT_SEA_TRADER = true,

	UNIT_ALIEN_FLYER_LUSH = true,
	UNIT_ALIEN_FLYER_FUNG = true,
	UNIT_ALIEN_FLYER_ARID = true,
	UNIT_ALIEN_FLYER_PRIM = true,
	UNIT_ALIEN_FLYER_FRIG = true,

	UNIT_ALIEN_WOLF_BEETLE_LUSH = true,
	UNIT_ALIEN_WOLF_BEETLE_FUNG = true,
	UNIT_ALIEN_WOLF_BEETLE_ARID = true,
	UNIT_ALIEN_WOLF_BEETLE_PRIM = true,
	UNIT_ALIEN_WOLF_BEETLE_FRIG = true,

	UNIT_ALIEN_RAPTOR_BUG_LUSH = true,
	UNIT_ALIEN_RAPTOR_BUG_FUNG = true,
	UNIT_ALIEN_RAPTOR_BUG_ARID = true,
	UNIT_ALIEN_RAPTOR_BUG_PRIM = true,
	UNIT_ALIEN_RAPTOR_BUG_FRIG = true,

	UNIT_ALIEN_MANTICORE_LUSH = true,
	UNIT_ALIEN_MANTICORE_FUNG = true,
	UNIT_ALIEN_MANTICORE_ARID = true,
	UNIT_ALIEN_MANTICORE_PRIM = true,
	UNIT_ALIEN_MANTICORE_FRIG = true,

	UNIT_ALIEN_SCARAB_LUSH = true,
	UNIT_ALIEN_SCARAB_FUNG = true,
	UNIT_ALIEN_SCARAB_ARID = true,
	UNIT_ALIEN_SCARAB_PRIM = true,
	UNIT_ALIEN_SCARAB_FRIG = true,

	UNIT_ALIEN_SIEGE_WORM_LUSH = true,
	UNIT_ALIEN_SIEGE_WORM_FUNG = true,
	UNIT_ALIEN_SIEGE_WORM_ARID = true,
	UNIT_ALIEN_SIEGE_WORM_PRIM = true,
	UNIT_ALIEN_SIEGE_WORM_FRIG = true,

	UNIT_ALIEN_AMPHIBIAN_LUSH = true,
	UNIT_ALIEN_AMPHIBIAN_FUNG = true,
	UNIT_ALIEN_AMPHIBIAN_ARID = true,
	UNIT_ALIEN_AMPHIBIAN_PRIM = true,
	UNIT_ALIEN_AMPHIBIAN_FRIG = true,

	UNIT_ALIEN_POD_HUNTER_LUSH = true,
	UNIT_ALIEN_POD_HUNTER_FUNG = true,
	UNIT_ALIEN_POD_HUNTER_ARID = true,
	UNIT_ALIEN_POD_HUNTER_PRIM = true,
	UNIT_ALIEN_POD_HUNTER_FRIG = true,

	UNIT_ALIEN_SEA_DRAGON_LUSH = true,
	UNIT_ALIEN_SEA_DRAGON_FUNG = true,
	UNIT_ALIEN_SEA_DRAGON_ARID = true,
	UNIT_ALIEN_SEA_DRAGON_PRIM = true,
	UNIT_ALIEN_SEA_DRAGON_FRIG = true,

	UNIT_ALIEN_KRAKEN_LUSH = true,
	UNIT_ALIEN_KRAKEN_FUNG = true,
	UNIT_ALIEN_KRAKEN_ARID = true,
	UNIT_ALIEN_KRAKEN_PRIM = true,
	UNIT_ALIEN_KRAKEN_FRIG = true,
};

-- Affinity images (TODO: Add to internal atlas system)
local m_textureAffinity		= {};
m_textureAffinity["AFFINITY_TYPE_PURITY"] 		= { atlas="TECHWEB_ATLAS_32x32", size=32, index=0};
m_textureAffinity["AFFINITY_TYPE_HARMONY"] 		= { atlas="TECHWEB_ATLAS_32x32", size=32, index=1};
m_textureAffinity["AFFINITY_TYPE_SUPREMACY"] 	= { atlas="TECHWEB_ATLAS_32x32", size=32, index=2};

local m_tooltipAffinity		= {};
m_tooltipAffinity["AFFINITY_TYPE_HARMONY"] 		= "TXT_KEY_TECHWEB_AFFINITY_ADDS_HARMONY";
m_tooltipAffinity["AFFINITY_TYPE_PURITY"] 		= "TXT_KEY_TECHWEB_AFFINITY_ADDS_PURITY";
m_tooltipAffinity["AFFINITY_TYPE_SUPREMACY"] 	= "TXT_KEY_TECHWEB_AFFINITY_ADDS_SUPREMACY";


-- the instance managers
local g_ListItemManager			= InstanceManager:new( "ListItemInstance", "ListItemButton", Controls.ListOfArticles );
local g_ListItemManagerC2		= InstanceManager:new( "ListItemInstanceC2", "ListItemButtonC2", Controls.ListOfArticles );

local g_ListHeadingManager		= InstanceManager:new( "ListHeadingInstance", "ListHeadingButton", Controls.ListOfArticles );
local g_ListHeadingManagerC2	= InstanceManager:new( "ListHeadingInstanceC2", "ListHeadingButtonC2", Controls.ListOfArticles );

local g_PrereqTechManager		= InstanceManager:new( "PrereqTechInstance", "PrereqTechButton", Controls.PrereqTechInnerFrame );
local g_PrereqVirtueManager		= InstanceManager:new( "PrereqVirtueInstance", "PrereqVirtueButton", Controls.PrereqVirtueInnerFrame );
local g_PrereqAffinityManager	= InstanceManager:new( "PrereqAffinityInstance", "PrereqAffinityButton", Controls.PrereqAffinityInnerFrame );
local g_ObsoleteTechManager		= InstanceManager:new( "ObsoleteTechInstance", "ObsoleteTechButton", Controls.ObsoleteTechInnerFrame );
local g_UpgradeManager			= InstanceManager:new( "UpgradeInstance", "UpgradeButton", Controls.UpgradeInnerFrame );
local g_LeadsToTechManager		= InstanceManager:new( "LeadsToTechInstance", "LeadsToTechButton", Controls.LeadsToTechInnerFrame );
local g_UnlockedUnitsManager	= InstanceManager:new( "UnlockedUnitInstance", "UnlockedUnitButton", Controls.UnlockedUnitsInnerFrame );
local g_UnlockedBuildingsManager= InstanceManager:new( "UnlockedBuildingInstance", "UnlockedBuildingButton", Controls.UnlockedBuildingsInnerFrame );
local g_RevealedResourcesManager= InstanceManager:new( "RevealedResourceInstance", "RevealedResourceButton", Controls.RevealedResourcesInnerFrame );
local g_RequiredResourcesManager= InstanceManager:new( "RequiredResourceInstance", "RequiredResourceButton", Controls.RequiredResourcesInnerFrame );
local g_WorkerActionsManager	= InstanceManager:new( "WorkerActionInstance", "WorkerActionButton", Controls.WorkerActionsInnerFrame );
local g_UnlockedProjectsManager = InstanceManager:new( "UnlockedProjectInstance", "UnlockedProjectButton", Controls.UnlockedProjectsInnerFrame );
local g_PromotionsManager		= InstanceManager:new( "PromotionInstance", "PromotionButton", Controls.FreePromotionsInnerFrame );
local g_SpecialistsManager		= InstanceManager:new( "SpecialistInstance", "SpecialistButton", Controls.SpecialistsInnerFrame );
local g_RequiredBuildingsManager= InstanceManager:new( "RequiredBuildingInstance", "RequiredBuildingButton", Controls.RequiredBuildingsInnerFrame );
local g_LocalResourcesManager	= InstanceManager:new( "LocalResourceInstance", "LocalResourceButton", Controls.LocalResourcesInnerFrame );
local g_RequiredPromotionsManager = InstanceManager:new( "RequiredPromotionInstance", "RequiredPromotionButton", Controls.RequiredPromotionsInnerFrame );
local g_RequiredPoliciesManager = InstanceManager:new( "RequiredPolicyInstance", "RequiredPolicyButton", Controls.RequiredPoliciesInnerFrame );
local g_FreeFormTextManager		= InstanceManager:new( "FreeFormTextInstance", "FFTextFrame", Controls.FFTextStack );

local g_BBTextManager			= InstanceManager:new( "BBTextInstance", "BBTextFrame", Controls.BBTextStack );
local g_BBC2TextManager			= InstanceManager:new( "BBC2TextInstance", "BBC2TextFrame", Controls.BBTextStack ); -- 
local g_BBC3TextManager			= InstanceManager:new( "BBC3TextInstance", "BBC3TextFrame", Controls.BBTextStack ); -- 

local g_LeadersManager			= InstanceManager:new( "LeaderInstance", "LeaderButton", Controls.LeadersInnerFrame );
local g_UniqueUnitsManager		= InstanceManager:new( "UniqueUnitInstance", "UniqueUnitButton", Controls.UniqueUnitsInnerFrame );
local g_UniqueBuildingsManager	= InstanceManager:new( "UniqueBuildingInstance", "UniqueBuildingButton", Controls.UniqueBuildingsInnerFrame );
local g_UniqueImprovementsManager = InstanceManager:new( "UniqueImprovementInstance", "UniqueImprovementButton", Controls.UniqueImprovementsInnerFrame );
local g_CivilizationsManager	= InstanceManager:new( "CivilizationInstance", "CivilizationButton", Controls.CivilizationsInnerFrame );
-- local g_TraitsManager			= InstanceManager:new( "TraitInstance", "TraitButton", Controls.TraitsInnerFrame );
local g_TraitsManager			= InstanceManager:new( "TraitInstance", "TraitButton", Controls.AgreementsUnlockedInnerFrame ); -- PW
local g_ArtsManager				= InstanceManager:new( "ArtInstance", "ArtButton", Controls.ArtsInnerFrame ); -- PW
local g_FeaturesManager			= InstanceManager:new( "FeatureInstance", "FeatureButton", Controls.FeaturesInnerFrame );
local g_ResourcesFoundManager	= InstanceManager:new( "ResourceFoundInstance", "ResourceFoundButton", Controls.ResourcesFoundInnerFrame );
local g_TerrainsManager			= InstanceManager:new( "TerrainInstance", "TerrainButton", Controls.TerrainsInnerFrame );
local g_MarvelsManager			= InstanceManager:new( "MarvelInstance", "MarvelButton", Controls.MarvelsInnerFrame );
local g_ReplacesManager			= InstanceManager:new( "ReplaceInstance", "ReplaceButton", Controls.ReplacesInnerFrame );
local g_RevealTechsManager		= InstanceManager:new( "RevealTechInstance", "RevealTechButton", Controls.RevealTechsInnerFrame );
local g_ImprovementsManager		= InstanceManager:new( "ImprovementInstance", "ImprovementButton", Controls.ImprovementsInnerFrame );
local g_AffinitiesGainedManager	= InstanceManager:new( "AffinityInstance", "AffinityButton", Controls.AffinitiesGainedInnerFrame );


-- ===========================================================================
--	CACHED tables
-- ===========================================================================

local CachedUnitAffinityPrereqs	= {};
local CachedBuildingAffinityPrereqs	= {};
local CachedProjectAffinityPrereqs	= {};

for row in GameInfo.Unit_AffinityPrereqs() do
	if CachedUnitAffinityPrereqs[row.UnitType] == nil then
		CachedUnitAffinityPrereqs[row.UnitType] = {};
	end
	CachedUnitAffinityPrereqs[row.UnitType][row.AffinityType] = row.Level;
end
for row in GameInfo.Building_AffinityPrereqs() do
	if CachedBuildingAffinityPrereqs[row.BuildingType] == nil then
		CachedBuildingAffinityPrereqs[row.BuildingType] = {};
	end
	CachedBuildingAffinityPrereqs[row.BuildingType][row.AffinityType] = row.Level;
end
for row in GameInfo.Project_AffinityPrereqs() do
	if CachedProjectAffinityPrereqs[row.ProjectType] == nil then
		CachedProjectAffinityPrereqs[row.ProjectType] = {};
	end
	CachedProjectAffinityPrereqs[row.ProjectType][row.AffinityType] = row.Level;
end

-- ===========================================================================
local UsualSizeFrameWidth		= 704; -- 680;
local UsualSizeTextWrapWidth	= 38; -- will use: UsualSizeFrameWidth - UsualSizeTextWrapWidth;
local QuoteSizeFrameWidth		= 452;
local QuoteSizeTextWrapWidth	= 24; -- will use: UsualSizeFrameWidth - UsualSizeTextWrapWidth;

-- put text into a text block and resize the block
function UpdateTextBlock( localizedString, label, innerFrame, outerFrame )
	local contentSize;
	local frameSize = {};
	-- label:SetWrapWidth(wideLabelWrapWidth);
	label:SetWrapWidth(wideLabelWrapWidth - UsualSizeTextWrapWidth);
	label:SetText( localizedString );
	
	contentSize = label:GetSize();
	-- frameSize.x = wideInnerFrameWidth;
	frameSize.x = wideLabelWrapWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame;
	innerFrame:SetSize( frameSize );
	-- innerFrame:SetOffsetVal(0, 0);
	
	-- frameSize.x = wideOuterFrameWidth;
	frameSize.x = wideLabelWrapWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame - offsetsBetweenFrames;
	outerFrame:SetSize( frameSize );
	outerFrame:SetHide( false );
	
	outerFrame:SetOffsetVal(-14, 24);
end

function UpdateNarrowTextBlock( localizedString, label, innerFrame, outerFrame )
	local contentSize;
	local frameSize = {};
	label:SetWrapWidth(narrowLabelWrapWidth);
	label:SetText( localizedString );
	contentSize = label:GetSize();
	frameSize.x = narrowInnerFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame;
	innerFrame:SetSize( frameSize );
	frameSize.x = narrowOuterFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame - offsetsBetweenFrames;
	outerFrame:SetSize( frameSize );
	outerFrame:SetHide( false );
end

function UpdateSuperWideTextBlock( localizedString, label, innerFrame, outerFrame )
	local contentSize;
	local frameSize = {};
	-- label:SetWrapWidth(superWideLabelWrapWidth);
	label:SetWrapWidth(UsualSizeFrameWidth - UsualSizeTextWrapWidth);
	label:SetText( localizedString );
	
	contentSize = label:GetSize();
	-- frameSize.x = superWideInnerFrameWidth;
	frameSize.x = UsualSizeFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame; -- ��� ��� ������������ �� � �� ������, �� ���������� ������� �� � ����������� � ����� � ����.
	innerFrame:SetSize( frameSize );
	-- innerFrame:SetHide( true ); -- 
	-- innerFrame:SetOffsetVal(14, 0);
	innerFrame:SetOffsetVal(0, 0);
	
	-- frameSize.x = superWideOuterFrameWidth;
	frameSize.x = UsualSizeFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame - offsetsBetweenFrames;
	outerFrame:SetSize( frameSize );
	outerFrame:SetHide( false );
	outerFrame:SetOffsetVal(-14, 24);
end

function UpdateCentrQuoteBlock( localizedString, label, innerFrame, outerFrame )
	local contentSize;
	local frameSize = {};
	label:SetWrapWidth(QuoteSizeFrameWidth - QuoteSizeTextWrapWidth);
	label:SetText( localizedString );
	
	contentSize = label:GetSize();
	frameSize.x = QuoteSizeFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame;
	innerFrame:SetSize( frameSize );
	innerFrame:SetOffsetVal(0, 0);
	
	frameSize.x = QuoteSizeFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame - offsetsBetweenFrames;
	outerFrame:SetSize( frameSize );
	outerFrame:SetHide( false );
	
	outerFrame:SetOffsetVal(-51, 0);
	-- outerFrame:SetAnchor("C,T");
	-- outerFrame:ReprocessAnchoring();
	-- Controls.UnitName:SetFontSize( 24 );
end

function UpdateRightQuoteBlock( localizedString, label, innerFrame, outerFrame )
	local contentSize;
	local frameSize = {};
	label:SetWrapWidth(QuoteSizeFrameWidth - QuoteSizeTextWrapWidth);
	label:SetText( localizedString );
	
	contentSize = label:GetSize();
	frameSize.x = QuoteSizeFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame;
	innerFrame:SetSize( frameSize );
	innerFrame:SetOffsetVal(14, 0);
	
	frameSize.x = QuoteSizeFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame - offsetsBetweenFrames;
	outerFrame:SetSize( frameSize );
	outerFrame:SetHide( false );
	
	outerFrame:SetOffsetVal(0, 0);
	-- outerFrame:SetAnchor("C,T");
	-- outerFrame:ReprocessAnchoring();
end

-- for left aligned BBTextInstance blocks
function UpdateUsualSizeTextBlock( localizedString, label, innerFrame, outerFrame )
	local contentSize;
	local frameSize = {};
	label:SetWrapWidth(UsualSizeFrameWidth - UsualSizeTextWrapWidth);
	label:SetText( localizedString );
	
	contentSize = label:GetSize();
	frameSize.x = UsualSizeFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame; -- ��� ��� ������������ �� � �� ������, �� ���������� ������� �� � ����������� � ����� � ����.
	innerFrame:SetSize( frameSize );
	innerFrame:SetOffsetVal(0, 0);
	-- innerFrame:SetHide( true ); -- 
	
	frameSize.x = UsualSizeFrameWidth;
	frameSize.y = contentSize.y + textPaddingFromInnerFrame - offsetsBetweenFrames;
	outerFrame:SetSize( frameSize );
	outerFrame:SetHide( false );
	outerFrame:SetOffsetVal(0, 24);
end

-- ===========================================================================
-- Dynamically resize frame based on contents.
--
function ShowAndSizeFrameToText( textString, textControl, gridInnerFrameControl, gridOutterFrameControl )
	local PADDING = 20;
	textControl:SetText( textString );
	local height = textControl:GetSizeY();				
	gridInnerFrameControl:SetSizeY( height + PADDING );
	gridInnerFrameControl:ReprocessAnchoring();
	if ( gridOutterFrameControl ~= nil ) then
		gridOutterFrameControl:SetHide( false );
		gridOutterFrameControl:SetSizeY( height + PADDING  );
		gridOutterFrameControl:ReprocessAnchoring();
	end
end

-- ===========================================================================
-- Clear text instances
--
function ClearTextInstances()
	g_BBTextManager:DestroyInstances();		
	g_BBC2TextManager:DestroyInstances();
	g_BBC3TextManager:DestroyInstances();
end

-- ===========================================================================
function SetSelectedCategory( thisCategory, isAddingToHistoryList )
	--print("SetSelectedCategory("..tostring(thisCategory)..")");
	if m_selectedCategory ~= thisCategory then

		m_selectedCategory = thisCategory;
		
		print(thisCategory);
		-- set up tab
		Controls.SelectedCategoryTab:SetOffsetVal(49 * (m_selectedCategory - 1), 0);
		Controls.SelectedCategoryTab:SetTexture( CivilopediaCategory[m_selectedCategory].buttonTexture );
		
		-- set up label for category
		Controls.CategoryLabel:SetText( Locale.ToUpper(CivilopediaCategory[m_selectedCategory].labelString) );
		
		-- populate the list of entries
		if CivilopediaCategory[m_selectedCategory].DisplayList then
			CivilopediaCategory[m_selectedCategory].DisplayList();
		else
			g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
			g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();
		end
		Controls.ListOfArticles:CalculateSize();
		Controls.ListOfArticles:ReprocessAnchoring();

	end

	-- get first entry from list (this will be a special page)
	if CivilopediaCategory[m_selectedCategory].DisplayHomePage then
		CivilopediaCategory[m_selectedCategory].DisplayHomePage();		
		if isAddingToHistoryList == addToList then
			AddToNavigationHistory(m_selectedCategory, homePageOfCategoryID );
		end
	end	
	Controls.ScrollPanel:CalculateInternalSize();
	Controls.LeftScrollPanel:CalculateInternalSize();
end

-- ===========================================================================
--	Setup generic stuff for each category
-- ===========================================================================
for i = 1, m_numCategories, 1 do
	CivilopediaCategory[i] = {};
	CivilopediaCategory[i].tag = i;
	CivilopediaCategory[i].buttonClicked = function()
		SetSelectedCategory(CivilopediaCategory[i].tag, addToList );
	end
	local buttonName = "CategoryButton"..tostring(i);
	Controls[buttonName]:RegisterCallback( Mouse.eLClick, CivilopediaCategory[i].buttonClicked );
end

-------------------------------------------------------------------------------
-- setup the special case stuff for each category
-------------------------------------------------------------------------------
CivilopediaCategory[CategoryMain].buttonTexture		= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsGameplay.dds";
-- CivilopediaCategory[CategoryMain].buttonTexture		= "civilopediatopbuttonsgameplay_svprim.dds";
CivilopediaCategory[CategoryConcepts].buttonTexture	= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsSeededStart.dds";
-- CivilopediaCategory[CategoryConcepts].buttonTexture	= "Assets/UI/Art/Civilopedia/civilopediatopbuttonsseededstart_svprim.dds";
CivilopediaCategory[CategoryTech].buttonTexture			= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsTechnology.dds";
-- CivilopediaCategory[CategoryUnits].buttonTexture		= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsUnit.dds";
CivilopediaCategory[CategoryUnits].buttonTexture		= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsUnit_svprim.dds";
CivilopediaCategory[CategoryUpgrades].buttonTexture		= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsUpgrades.dds";
CivilopediaCategory[CategoryBuildings].buttonTexture	= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsBuildings.dds";
CivilopediaCategory[CategoryWonders].buttonTexture		= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsWonders.dds";
CivilopediaCategory[CategoryVirtues].buttonTexture		= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsVirtues.dds";
CivilopediaCategory[CategoryEspionage].buttonTexture	= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsEspionage.dds";
CivilopediaCategory[CategoryCivilizations].buttonTexture= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsCivs.dds";
-- CivilopediaCategory[CategoryCivilizations].buttonTexture= "CivilopediaTopButtonsCivs_svprim.dds";
CivilopediaCategory[CategoryQuests].buttonTexture		= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsQuests.dds";
CivilopediaCategory[CategoryTerrain].buttonTexture		= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsTerrain.dds";
CivilopediaCategory[CategoryResources].buttonTexture	= "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsResourcesImprovements.dds";
CivilopediaCategory[CategoryImprovements].buttonTexture = "Assets/UI/Art/Civilopedia/CivilopediaTopButtonsImprovements.dds";
-- CivilopediaCategory[CategoryImprovements].buttonTexture = "CivilopediaTopButtonsImprovements_svprim.dds";
CivilopediaCategory[CategoryAffinities].buttonTexture	= "CivilopediaTopButtonsAffinities.dds";
CivilopediaCategory[CategoryStations].buttonTexture		= "CivilopediaTopButtonsStations.dds";
CivilopediaCategory[CategoryDiplomacy].buttonTexture	= "CivilopediaTopButtonsDiplomacy.dds";
CivilopediaCategory[CategoryArtifacts].buttonTexture	= "CivilopediaTopButtonsArtifacts.dds";

CivilopediaCategory[CategoryMain].labelString		= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_1_AC_LABEL" );
CivilopediaCategory[CategoryConcepts].labelString	= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_2_LABEL" );
CivilopediaCategory[CategoryTech].labelString			= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_3_LABEL" );
CivilopediaCategory[CategoryUnits].labelString			= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_4_LABEL" );
CivilopediaCategory[CategoryUpgrades].labelString		= Locale.ConvertTextKey( "TXT_KEY_UPGRADES_HEADING1_TITLE" );
CivilopediaCategory[CategoryBuildings].labelString		= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_6_LABEL" );
CivilopediaCategory[CategoryWonders].labelString		= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_7_LABEL" );
CivilopediaCategory[CategoryVirtues].labelString		= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_8_LABEL" );
CivilopediaCategory[CategoryEspionage].labelString		= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_9_LABEL" );
CivilopediaCategory[CategoryCivilizations].labelString	= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_10_AC_LABEL" );
CivilopediaCategory[CategoryQuests].labelString			= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_11_LABEL" );
CivilopediaCategory[CategoryTerrain].labelString		= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_12_LABEL" );
CivilopediaCategory[CategoryResources].labelString		= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_13_LABEL" );
CivilopediaCategory[CategoryImprovements].labelString	= Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_14_LABEL" );
CivilopediaCategory[CategoryAffinities].labelString		= Locale.Lookup("TXT_KEY_PEDIA_CATEGORY_15_LABEL");
CivilopediaCategory[CategoryStations].labelString		= Locale.Lookup("TXT_KEY_PEDIA_CATEGORY_16_LABEL");
CivilopediaCategory[CategoryDiplomacy].labelString		= Locale.Lookup("TXT_KEY_PEDIA_CATEGORY_17_LABEL");
CivilopediaCategory[CategoryArtifacts].labelString		= Locale.Lookup("TXT_KEY_PEDIA_CATEGORY_18_LABEL");

CivilopediaCategory[CategoryMain].PopulateList = function()
	sortedList[CategoryMain] = {};

	sortedList[CategoryMain][1] = {}; -- there is only one section 
	local tableid = 1;		
	
		-- for each major category
 		for i=1, m_numCategories,1 do  
 		
			-- add an entry to a list (localized name, tag, etc.)
 			local article = {};
 			local compoundName = "TXT_KEY_PEDIA_CATEGORY_" .. tostring(i) .. "_LABEL" ;
 			local name = Locale.ConvertTextKey( compoundName );
			--antonjs: Remove this ugly exception once we can add text again
			-- if (i <= 2) or (i == 10) or (i == 14) then
				-- name = string.format("[COLOR:116,161,155,255]" .. Locale.ConvertTextKey(compoundName) .. "[ENDCOLOR]");
			-- end
			if (i == 1) then
				name = Locale.ConvertTextKey("TXT_KEY_PEDIA_CATEGORY_1_AC_LABEL");
			elseif (i == 5) then
				name = Locale.ConvertTextKey("TXT_KEY_UPGRADES_HEADING1_TITLE");
			elseif (i == 10) then
				name = Locale.ConvertTextKey("TXT_KEY_PEDIA_CATEGORY_10_AC_LABEL");
			end
 			article.entryName = name;
 			article.entryID = i;
			article.entryCategory = CategoryMain;

			sortedList[CategoryMain][1][tableid] = article;
			tableid = tableid + 1;
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[compoundName] = article;
			m_categorizedListOfArticles[(CategoryMain * MAX_ENTRIES_PER_CATEGORY) + i] = article;
		end		
end

CivilopediaCategory[CategoryConcepts].PopulateList = function()
	sortedList[CategoryConcepts] = {};	
	local GameConceptsList = sortedList[CategoryConcepts];
	
	local conceptSections = {
		-- HEADER_AFFINITY = 1,
		HEADER_ECOLOGY = 1,
		--HEADER_HEALTH = 2,
		HEADER_CITIES = 2,
		HEADER_COMBAT = 3,
		HEADER_TERRAIN = 4,
		HEADER_RESOURCES = 5,
		HEADER_IMPROVEMENTS = 6,
		HEADER_CITYGROWTH = 7,
		HEADER_TECHNOLOGY = 8,
		HEADER_CULTURE = 9,
		HEADER_DIPLOMACY = 10,
		HEADER_HEALTH = 11,
		HEADER_FOW = 12,
		HEADER_POLICIES = 13,
		HEADER_ENERGY = 14,
		HEADER_EXPLORER = 15,
		HEADER_ALIENS = 16,
		HEADER_ARTIFACTS = 17,
		HEADER_UNITS = 18,
		HEADER_MOVEMENT = 19,
		HEADER_AIRCOMBAT = 20,
		HEADER_ESPIONAGE = 21,
		HEADER_TRADE = 22,
		HEADER_QUESTS = 23,
		HEADER_STATIONS = 24,
		HEADER_ORBITAL = 25,
		HEADER_ADVISORS = 26,
		HEADER_PEOPLE = 27,
		HEADER_VICTORY = 28,	
	}
	
	-- Create table.
	for i,v in pairs(conceptSections) do
		-- if i == 1 then 
			-- GameConceptsList[v] = {	headingOpen = true,	}; 
		-- else
			GameConceptsList[v] = {
				headingOpen = false,
			}; 
		-- end
	end	
	
	-- for each concept
	for thisConcept in GameInfo.Concepts() do
		
		local sectionID = conceptSections[thisConcept.CivilopediaHeaderType];
		if(sectionID ~= nil) then
			-- add an article to the list (localized name, unit tag, etc.)
			local article = {};
			local name = Locale.ConvertTextKey( thisConcept.Description )
			-- coloring
			-- if (thisConcept.CivilopediaHeaderType == HEADER_ECOLOGY) then
				-- name = string.format("[COLOR:116,161,155,255]" .. Locale.ConvertTextKey(thisConcept.Description) .. "[ENDCOLOR]");
			-- end
			article.entryName = name;
			article.entryID = thisConcept.ID;
			article.entryCategory = CategoryConcepts;
			article.InsertBefore = thisConcept.InsertBefore;
			article.InsertAfter = thisConcept.InsertAfter;
			article.Type = thisConcept.Type;

			table.insert(GameConceptsList[sectionID], article);
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[thisConcept.Description] = article;
			m_categorizedListOfArticles[(CategoryConcepts * MAX_ENTRIES_PER_CATEGORY) + thisConcept.ID] = article;
		end
	end
	
	-- In order to maintain the original order as best as possible,
	-- we assign "InsertBefore" values to all items that lack any insert.
	for _, conceptList in ipairs(GameConceptsList) do
		for i = #conceptList, 1, -1 do
			local concept = conceptList[i];
			
			if(concept.InsertBefore == nil and concept.InsertAfter == nil) then
				for ii = i - 1, 1, -1 do
					local previousConcept = conceptList[ii];
					if(previousConcept.InsertBefore == nil and previousConcept.InsertAfter == nil) then
						concept.InsertAfter = previousConcept.Type;
						break;
					end
				end
			end
		end
	end
	
	
	-- sort the articles by their dependencies.
	function DependencySort(articles)
		
		-- index articles by Topic
		local articlesByType= {};
		local dependencies = {};
		
		for i,v in ipairs(articles) do
			articlesByType[v.Type] = v;
			dependencies[v] = {};
		end
		
		for i,v in ipairs(articles) do
			
			local insertBefore = v.InsertBefore;
			if(insertBefore ~= nil) then
				local article = articlesByType[insertBefore];
				dependencies[article][v] = true;
			end
			
			local insertAfter = v.InsertAfter;
			if(insertAfter ~= nil) then
				local article = articlesByType[insertAfter];
				dependencies[v][article] = true;
			end
		end
		
		local sortedList = {};
		
		local articleCount = #articles;
		while(#sortedList < articleCount) do
			
			-- Attempt to find a node with 0 dependencies
			local article;
			for i,a in ipairs(articles) do
				if(dependencies[a] ~= nil and table.count(dependencies[a]) == 0) then
					article = a;
					break;
				end
			end
			
			if(article == nil) then
				print("Failed to sort articles topologically!! There are dependency cycles.");
				return nil;
			else
			
				-- Insert Node
				table.insert(sortedList, article);
				
				-- Remove node
				dependencies[article] = nil;
				for a,d in pairs(dependencies) do
					d[article] = nil;
				end
			end
		end
		
		return sortedList;
	end
		
	for i,v in ipairs(GameConceptsList) do
		local oldList = v;
		local newList = DependencySort(v);
	
		if(newList == nil) then
			newList = oldList;
		else
			newList.headingOpen = false;
		end
		
		GameConceptsList[i] = newList;
	end
end

CivilopediaCategory[CategoryTech].PopulateList = function()
	-- add the instances of the tech entries
	
	sortedList[CategoryTech] = {};
	local tableid = 1;

	for tech in GameInfo.Technologies() do
		-- add a tech entry to a list (localized name, unit tag, etc.)
 		local article	= {};
 		local name		= Locale.ConvertTextKey( tech.Description )

 		article.entryName		= name;
 		article.entryID			= tech.ID;
		article.entryCategory	= CategoryTech;			
		article.tooltipTextureOffset, article.tooltipTexture = IconLookup( tech.PortraitIndex, buttonSize, tech.IconAtlas );
		if not article.tooltipTextureOffset then
			article.tooltipTexture = defaultErrorTextureSheet;
			article.tooltipTextureOffset = nullOffset;
		end				
			
		sortedList[CategoryTech][tableid] = article;
		tableid = tableid + 1;
			
		-- Index into various lists by the appropriate keys
		searchableList[Locale.ToLower(name)]	= article;
		searchableTextKeyList[tech.Description] = article;
		m_categorizedListOfArticles[(CategoryTech * MAX_ENTRIES_PER_CATEGORY) + tech.ID] = article;
	end

	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryTech], Alphabetically);
		
end

CivilopediaCategory[CategoryUnits].PopulateList = function()
	--print("CivilopediaCategory[CategoryUnits].PopulateList"); -- dbg
	-- add the instances of the unit entries
	sortedList[CategoryUnits] = {};
	local tableID = 1;

	-- 5 - alien
	-- 4 - orbital
	-- 3 - combat
	-- 2 - prototypes
	-- 1 - noncombat
	tableID = 1;
	
	local SubCatIndex = 1;
	sortedList[CategoryUnits][SubCatIndex] = {}; -- NON combat PW

	for unit in GameInfo.Units() do
	-- check if it fit subcat
		local available = true;
		local ignore = unitsToIgnore[unit.Type];

		if( available and not ignore ) then
			if (unit.Combat == 0) and (unit.RangedCombat == 0) then
				if unit.Orbital == NULL then
					local article = {};
					local name = Locale.ConvertTextKey( unit.Description )
					article.entryName = name;
					article.entryID = unit.ID;
					article.entryCategory = CategoryUnits;				

					local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon(unit.ID);

					article.tooltipTextureOffset, article.tooltipTexture = IconLookup( portraitIndex, buttonSize, portraitAtlas );				
					if not article.tooltipTextureOffset then
						article.tooltipTexture = defaultErrorTextureSheet;
						article.tooltipTextureOffset = nullOffset;
					end	

					sortedList[CategoryUnits][SubCatIndex][tableID] = article;
					tableID = tableID + 1;
					-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg
				
					-- index by various keys
					searchableList[Locale.ToLower(name)] = article;
					searchableTextKeyList[unit.Description] = article;
					m_categorizedListOfArticles[(CategoryUnits * MAX_ENTRIES_PER_CATEGORY) + unit.ID] = article;
				end
			end
		end
	end
	-- sort this list alphabetically by localized name
	-- table.sort(sortedList[CategoryUnits][SubCatIndex], Alphabetically);

	tableID = 1;
	SubCatIndex = 2;
	sortedList[CategoryUnits][SubCatIndex] = {}; -- Prototype PW

	for unit in GameInfo.Units() do
	-- check if it fit subcat
		local available = true;
		local ignore = unitsToIgnore[unit.Type];

		if( available and not ignore ) then
			if (unit.Prototype) then
					local article = {};
					local name = Locale.ConvertTextKey( unit.Description );
					--if unit.Prototype == true then 	name = "[ICON_PROTOTYPE] "..name	end
					--if unit.Affiliation ~= NULL then 	name = "[ICON_"..unit.Affiliation.."] "..name		end
					if unit.Affiliation ~= NULL then
						local n = string.find( name, "ICON" );
						if n == 2 then
							name = "[ICON_"..unit.Affiliation.."]"..name
						else
							name = "[ICON_"..unit.Affiliation.."] "..name
						end
					end
				if unit.Orbital ~= NULL then
					local n = string.find( name, "ICON" );
					if n == 2 then
						name = "[ICON_ORBITAL_DURATION]"..name
					else
						name = "[ICON_ORBITAL_DURATION] "..name
					end
				end
				if unit.Prototype == true then
					local n = string.find( name, "ICON" );
					if n == 2 then
						name = "[ICON_PROTOTYPE]"..name
					else
						name = "[ICON_PROTOTYPE] "..name
					end
				end

					--local num = string.find( name, "ICON" );
					--if _dpo then print(tostring(num).. " - "..string.len(name) .. " - ".. name:len()); end

					article.entryName = name;
					article.entryID = unit.ID;
					article.entryCategory = CategoryUnits;				

					local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon(unit.ID);

					article.tooltipTextureOffset, article.tooltipTexture = IconLookup( portraitIndex, buttonSize, portraitAtlas );				
					if not article.tooltipTextureOffset then
						article.tooltipTexture = defaultErrorTextureSheet;
						article.tooltipTextureOffset = nullOffset;
					end	

					sortedList[CategoryUnits][SubCatIndex][tableID] = article;
					tableID = tableID + 1;
					-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg
				
					-- index by various keys
					searchableList[Locale.ToLower(name)] = article;
					searchableTextKeyList[unit.Description] = article;
					m_categorizedListOfArticles[(CategoryUnits * MAX_ENTRIES_PER_CATEGORY) + unit.ID] = article;
			end
		end
	end
	-- sort this list alphabetically by localized name
	-- table.sort(sortedList[CategoryUnits][SubCatIndex], Alphabetically);

	tableID = 1;
	SubCatIndex = 3;
	sortedList[CategoryUnits][SubCatIndex] = {}; -- combat PW

	for unit in GameInfo.Units() do
	-- check if it fit subcat
		local available = true;
		-- Unlocked through Firaxis Live? Lets switch this cycle off.
		-- if (unit.FiraxisLiveUnlockKey ~= nil) then
			-- local value = FiraxisLive.GetKeyValue(unit.FiraxisLiveUnlockKey);
			-- available = (value ~= 0);
		-- else
			-- available = true;
		-- end
		local ignore = unitsToIgnore[unit.Type];

		if( available and not ignore ) then
			if (unit.Combat > 0) or (unit.RangedCombat > 0) then
				if (unit.Orbital == NULL) and (unit.AlienLifeform == false) and (unit.Prototype == false) then
					local article = {};
					local name = Locale.ConvertTextKey( unit.Description )
					--if unit.Prototype == true then 	name = "[ICON_PROTOTYPE] "..name	end
					--if unit.Affiliation ~= NULL then 	name = "[ICON_"..unit.Affiliation.."] "..name		end

					if unit.Affiliation ~= NULL then
						local n = string.find( name, "ICON" );
						if n == 2 then
							name = "[ICON_"..unit.Affiliation.."]"..name
						else
							name = "[ICON_"..unit.Affiliation.."] "..name
						end
					end
					if unit.Prototype == true then
						local n = string.find( name, "ICON" );
						if n == 2 then
							name = "[ICON_PROTOTYPE]"..name
						else
							name = "[ICON_PROTOTYPE] "..name
						end
					end

					--local num = string.find( name, "ICON" );
					--if _dpo then print(tostring(num).. " - "..string.len(name) .. " - ".. name:len()); end

					article.entryName = name;
					article.entryID = unit.ID;
					article.entryCategory = CategoryUnits;

					local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon(unit.ID);

					article.tooltipTextureOffset, article.tooltipTexture = IconLookup( portraitIndex, buttonSize, portraitAtlas );
					if not article.tooltipTextureOffset then
						article.tooltipTexture = defaultErrorTextureSheet;
						article.tooltipTextureOffset = nullOffset;
					end

					sortedList[CategoryUnits][SubCatIndex][tableID] = article;
					tableID = tableID + 1;
					-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg

					-- index by various keys
					searchableList[Locale.ToLower(name)] = article;
					searchableTextKeyList[unit.Description] = article;
					m_categorizedListOfArticles[(CategoryUnits * MAX_ENTRIES_PER_CATEGORY) + unit.ID] = article;
				end
			end
		end
	end
	-- sort this list alphabetically by localized name
	-- table.sort(sortedList[CategoryUnits][SubCatIndex], Alphabetically);
	
	tableID = 1;
	SubCatIndex = 4;
	sortedList[CategoryUnits][SubCatIndex] = {}; -- Orbital PW

	for unit in GameInfo.Units() do
	-- check if it fit subcat
		local available = true;
		local ignore = unitsToIgnore[unit.Type];

		if( available and not ignore ) then
			-- if (unit.Combat == 0) and (unit.RangedCombat == 0) then
				if (unit.Orbital ~= NULL) and (unit.Prototype == false) then
					local article = {};
					local name = Locale.ConvertTextKey( unit.Description )
					--if unit.Prototype == true then 	name = "[ICON_PROTOTYPE] "..name	end
					--if unit.Affiliation ~= NULL then 	name = "[ICON_"..unit.Affiliation.."] "..name		end

					if unit.Affiliation ~= NULL then
						local n = string.find( name, "ICON" );
						if n == 2 then
							name = "[ICON_"..unit.Affiliation.."]"..name
						else
							name = "[ICON_"..unit.Affiliation.."] "..name
						end
					end
					if unit.Orbital ~= NULL then
						local n = string.find( name, "ICON" );
						if n == 2 then
							name = "[ICON_ORBITAL_DURATION]"..name
						else
							name = "[ICON_ORBITAL_DURATION] "..name
						end
					end
					if unit.Prototype == true then
						local n = string.find( name, "ICON" );
						if n == 2 then
							name = "[ICON_PROTOTYPE]"..name
						else
							name = "[ICON_PROTOTYPE] "..name
						end
					end
					article.entryName = name;
					article.entryID = unit.ID;
					article.entryCategory = CategoryUnits;				

					local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon(unit.ID);

					article.tooltipTextureOffset, article.tooltipTexture = IconLookup( portraitIndex, buttonSize, portraitAtlas );				
					if not article.tooltipTextureOffset then
						article.tooltipTexture = defaultErrorTextureSheet;
						article.tooltipTextureOffset = nullOffset;
					end	

					sortedList[CategoryUnits][SubCatIndex][tableID] = article;
					tableID = tableID + 1;
					-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg
				
					-- index by various keys
					searchableList[Locale.ToLower(name)] = article;
					searchableTextKeyList[unit.Description] = article;
					m_categorizedListOfArticles[(CategoryUnits * MAX_ENTRIES_PER_CATEGORY) + unit.ID] = article;
				end
			-- end
		end
	end
	-- sort this list alphabetically by localized name
	-- table.sort(sortedList[CategoryUnits][SubCatIndex], Alphabetically);
	
	tableID = 1;
	SubCatIndex = 5;
	sortedList[CategoryUnits][SubCatIndex] = {}; -- Alien PW

	for unit in GameInfo.Units() do
	-- check if it fit subcat
		local available = true;
		local ignore = unitsToIgnore[unit.Type];

		if( available and not ignore ) then
			-- if (unit.Combat == 0) and (unit.RangedCombat == 0) then
				if unit.AlienLifeform == true then
					local article = {};
					local name = Locale.ConvertTextKey( unit.Description )
					article.entryName = name;
					article.entryID = unit.ID;
					article.entryCategory = CategoryUnits;				

					local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon(unit.ID);

					article.tooltipTextureOffset, article.tooltipTexture = IconLookup( portraitIndex, buttonSize, portraitAtlas );				
					if not article.tooltipTextureOffset then
						article.tooltipTexture = defaultErrorTextureSheet;
						article.tooltipTextureOffset = nullOffset;
					end	

					sortedList[CategoryUnits][SubCatIndex][tableID] = article;
					tableID = tableID + 1;
					-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg
				
					-- index by various keys
					searchableList[Locale.ToLower(name)] = article;
					searchableTextKeyList[unit.Description] = article;
					m_categorizedListOfArticles[(CategoryUnits * MAX_ENTRIES_PER_CATEGORY) + unit.ID] = article;
				end
			-- end
		end
	end
	-- sort this list alphabetically by localized name
	-- table.sort(sortedList[CategoryUnits][SubCatIndex], Alphabetically);
	
	sortedList[CategoryUnits][1].headingOpen = true; -- open them for first time
	sortedList[CategoryUnits][2].headingOpen = false;
	sortedList[CategoryUnits][3].headingOpen = true;
	sortedList[CategoryUnits][4].headingOpen = true;
	sortedList[CategoryUnits][5].headingOpen = true;
	
end

CivilopediaCategory[CategoryUpgrades].PopulateList = function()
	print("CivilopediaCategory[CategoryUpgrades].PopulateList"); -- dbg
	-- add the instances of the promotion entries
	sortedList[CategoryUpgrades] = {};
	
	local unitIndex = 1;
	for unit in GameInfo.Units() do
		local upgradeIndex = 1;
		for upgrade in GameInfo.UnitUpgrades("UnitType = '" .. unit.Type .. "' ORDER BY UpgradeTier") do
			if (sortedList[CategoryUpgrades][unitIndex] == nil) then
				sortedList[CategoryUpgrades][unitIndex] = {};
			end
			local article = {};
			local name = Locale.ConvertTextKey(upgrade.Description);
			article.entryName = name;
			article.entryID = upgrade.ID;
			article.entryCategory = CategoryUpgrades;

			local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon(unit.ID);
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( portraitIndex, buttonSize, portraitAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end

			sortedList[CategoryUpgrades][unitIndex][upgradeIndex] = article;
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[upgrade.Description] = article;
			m_categorizedListOfArticles[(CategoryUpgrades * MAX_ENTRIES_PER_CATEGORY) + upgrade.ID] = article;
			upgradeIndex = upgradeIndex + 1;
			-- print("PopulateList set article "..upgradeIndex.." "..unitIndex); -- dbg
		end
		if (upgradeIndex > 1) then
			unitIndex = unitIndex + 1;
		end
	end
end

CivilopediaCategory[CategoryBuildings].PopulateList = function()
	-- add the instances of the building entries
	
	sortedList[CategoryBuildings] = {};
	local entryID = 1;
	
	for building in GameInfo.Buildings() do
		local available = true;
		local ignore = facilitiesToIgnore[building.Type];
		if not ignore then
			local thisBuildingClass = GameInfo.BuildingClasses[building.BuildingClass];
			ignore = false;--MGH:--thisBuildingClass.Effect;
		end
	
		if( available and not ignore ) then
			-- exclude wonders, etc.
			local thisBuildingClass = GameInfo.BuildingClasses[building.BuildingClass];
			if thisBuildingClass.MaxGlobalInstances < 0 and thisBuildingClass.MaxPlayerInstances < 0 and thisBuildingClass.MaxTeamInstances < 0 then
				local article = {};
				local name = Locale.ConvertTextKey( building.Description )
				article.entryName = name;
				article.entryID = building.ID;
				article.entryCategory = CategoryBuildings;
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( building.PortraitIndex, buttonSize, building.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end				
				
				sortedList[CategoryBuildings][entryID] = article;
				entryID = entryID + 1;
				
				-- index by various keys
				searchableList[Locale.ToLower(name)] = article;
				searchableTextKeyList[building.Description] = article;
				m_categorizedListOfArticles[(CategoryBuildings * MAX_ENTRIES_PER_CATEGORY) + building.ID] = article;
			end
		end
	end
		
	table.sort(sortedList[CategoryBuildings], Alphabetically);
end

CivilopediaCategory[CategoryWonders].PopulateList = function()
	-- add the instances of the Wonder, National Wonder, Team Wonder, and Project entries
	
	sortedList[CategoryWonders] = {};
	
	-- first Wonders
	sortedList[CategoryWonders][1] = {};
	local tableid = 1;

	for building in GameInfo.Buildings() do	
		-- exclude wonders etc.				
		local thisBuildingClass = GameInfo.BuildingClasses[building.BuildingClass];
		if thisBuildingClass.MaxGlobalInstances > 0  then
			local article = {};
			local name = Locale.ConvertTextKey( building.Description )
			article.entryName = name;
			article.entryID = building.ID;
			article.entryCategory = CategoryWonders;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( building.PortraitIndex, buttonSize, building.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				
			
			sortedList[CategoryWonders][1][tableid] = article;
			tableid = tableid + 1;
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[building.Description] = article;
			m_categorizedListOfArticles[(CategoryWonders * MAX_ENTRIES_PER_CATEGORY) + building.ID] = article;
		end
	end
	
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryWonders][1], Alphabetically);
			
	-- next National Wonders
	sortedList[CategoryWonders][2] = {};
	tableid = 1;

	for building in GameInfo.Buildings() do	
		local thisBuildingClass = GameInfo.BuildingClasses[building.BuildingClass];
		if thisBuildingClass.MaxPlayerInstances == 1 and building.SpecialistCount == 0 then
			local article = {};
			local name = Locale.ConvertTextKey( building.Description )
			article.entryName = name;
			article.entryID = building.ID;
			article.entryCategory = CategoryWonders;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( building.PortraitIndex, buttonSize, building.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				
			
			sortedList[CategoryWonders][2][tableid] = article;
			tableid = tableid + 1;
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[building.Description] = article;
			m_categorizedListOfArticles[(CategoryWonders * MAX_ENTRIES_PER_CATEGORY) + building.ID] = article;
		end
	end
	
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryWonders][2], Alphabetically);
	
	-- finally Projects
	sortedList[CategoryWonders][3] = {};
	tableid = 1;

	for building in GameInfo.Projects() do
		local bIgnore = projectsToIgnore[building.Type];	
		if(bIgnore ~= true) then
			local article = {};
			local name = Locale.ConvertTextKey( building.Description )
			article.entryName = name;
			article.entryID = building.ID + 1000;
			article.entryCategory = CategoryWonders;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( building.PortraitIndex, buttonSize, building.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				
			
			sortedList[CategoryWonders][3][tableid] = article;
			tableid = tableid + 1;
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[building.Description] = article;
			m_categorizedListOfArticles[(CategoryWonders * MAX_ENTRIES_PER_CATEGORY) + building.ID + 1000] = article;
		end
	end
	
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryWonders][3], Alphabetically);
					
end

CivilopediaCategory[CategoryVirtues].PopulateList = function()
	-- add the instances of the policy entries
	
	sortedList[CategoryVirtues] = {};
	
	-- compose a list of ones that are kicker bonuses
	local kickers = {};
	for info in GameInfo.PolicyBranch_KickerPolicies() do
		kickers[info.PolicyType] = true;
	end
	for info in GameInfo.PolicyDepth_KickerPolicies() do
		kickers[info.PolicyType] = true;
	end

	-- for each policy branch
	for branch in GameInfo.PolicyBranchTypes() do
	
		local branchID = branch.ID;
	
		sortedList[CategoryVirtues][branchID] = {};
		local tableid = 1;
	
		-- for each policy in this branch
 		for policy in GameInfo.Policies("PolicyBranchType = '" .. branch.Type .. "'") do
 			-- don't show kickers
 			if (kickers[policy.Type] == nil) then
				local article = {};
				local name = Locale.ConvertTextKey( policy.Description )
				article.entryName = name;
				article.entryID = policy.ID;
				article.entryCategory = CategoryVirtues;
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( policy.PortraitIndex, buttonSize, policy.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end				
				
				sortedList[CategoryVirtues][branchID][tableid] = article;
				tableid = tableid + 1;
				
				-- index by various keys
				searchableList[Locale.ToLower(name)] = article;
				searchableTextKeyList[policy.Description] = article;
				m_categorizedListOfArticles[(CategoryVirtues * MAX_ENTRIES_PER_CATEGORY) + policy.ID] = article;
			end
		end

		-- sort this list alphabetically by localized name
		table.sort(sortedList[CategoryVirtues][branchID], Alphabetically);
	
	end
		
end

CivilopediaCategory[CategoryEspionage].PopulateList = function()
	local GetConceptPerk = function(conceptType)
		-- Check if there's a security project with this concept type
		for row in GameInfo.NationalSecurityProjects{Concept = conceptType} do
			return GameInfo.PlayerPerks[row.PlayerPerk];
		end

		-- Add more types of perk checks here

		return nil;
	end
	
	sortedList[CategoryEspionage] = {};
	local espionageList = sortedList[CategoryEspionage];

	-- for each concept
	for thisConcept in GameInfo.Concepts() do
		if(thisConcept.CivilopediaHeaderType == "HEADER_ESPIONAGE") then
			-- add an article to the list (localized name, unit tag, etc.)
			local article = {};
			local name = Locale.ConvertTextKey( thisConcept.Description )
			article.entryName = name;
			article.entryID = thisConcept.ID;
			article.entryCategory = CategoryEspionage;
			article.InsertBefore = thisConcept.InsertBefore;
			article.InsertAfter = thisConcept.InsertAfter;
			article.Type = thisConcept.Type;
			article.PlayerPerk = GetConceptPerk(article.Type);

			table.insert(espionageList, article);
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[thisConcept.Description] = article;
			m_categorizedListOfArticles[(CategoryEspionage * MAX_ENTRIES_PER_CATEGORY) + thisConcept.ID] = article;
		end
	end

	-- In order to maintain the original order as best as possible,
	-- we assign "InsertBefore" values to all items that lack any insert.
	for i = #espionageList, 1, -1 do
		local concept = espionageList[i];
		
		if(concept.InsertBefore == nil and concept.InsertAfter == nil) then
			for ii = i - 1, 1, -1 do
				local previousConcept = espionageList[ii];
				if(previousConcept.InsertBefore == nil and previousConcept.InsertAfter == nil) then
					concept.InsertAfter = previousConcept.Type;
					break;
				end
			end
		end
	end

	
	-- sort the articles by their dependencies.
	function DependencySort(articles)
		
		-- index articles by Topic
		local articlesByType= {};
		local dependencies = {};
		
		for i,v in ipairs(articles) do
			articlesByType[v.Type] = v;
			dependencies[v] = {};
		end
		
		for i,v in ipairs(articles) do
			
			local insertBefore = v.InsertBefore;
			if(insertBefore ~= nil) then
				local article = articlesByType[insertBefore];
				dependencies[article][v] = true;
			end
			
			local insertAfter = v.InsertAfter;
			if(insertAfter ~= nil) then
				local article = articlesByType[insertAfter];
				dependencies[v][article] = true;
			end
		end
		
		local sortedList = {};
		
		local articleCount = #articles;
		while(#sortedList < articleCount) do
			
			-- Attempt to find a node with 0 dependencies
			local article;
			for i,a in ipairs(articles) do
				if(dependencies[a] ~= nil and table.count(dependencies[a]) == 0) then
					article = a;
					break;
				end
			end
			
			if(article == nil) then
				print("Failed to sort articles topologically!! There are dependency cycles.");
				return nil;
			else
			
				-- Insert Node
				table.insert(sortedList, article);
				
				-- Remove node
				dependencies[article] = nil;
				for a,d in pairs(dependencies) do
					d[article] = nil;
				end
			end
		end
		
		return sortedList;
	end
		
	local oldList = espionageList;
	local newList = DependencySort(espionageList);

	if(newList == nil) then
		newList = oldList;
	else
		newList.headingOpen = false;
	end
	
	espionageList = newList;
	
end

CivilopediaCategory[CategoryCivilizations].PopulateList = function()
	-- add the instances of the Civilization and Leader entries
	
	sortedList[CategoryCivilizations] = {};
	
	-- first Civilizations
	sortedList[CategoryCivilizations][1] = {};
	local tableid = 1;

	for row in GameInfo.Civilizations() do
		if row.Playable == true or row.AIPlayable == true then
		--if row.Type ~= "CIVILIZATION_MINOR" and row.Type ~= "CIVILIZATION_ALIEN" and row.Type ~= "CIVILIZATION_NEUTRAL_PROXY" then
			local article = {};
			local name = Locale.ConvertTextKey( row.ShortDescription )
			article.entryName = name;
			article.entryID = row.ID;
			article.entryCategory = CategoryCivilizations;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				

			sortedList[CategoryCivilizations][1][tableid] = article;
			tableid = tableid + 1;
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[row.ShortDescription] = article;
			m_categorizedListOfArticles[(CategoryCivilizations * MAX_ENTRIES_PER_CATEGORY) + row.ID] = article;
		end
	end
	
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryCivilizations][1], Alphabetically);
			
	-- next Leaders
	sortedList[CategoryCivilizations][2] = {};
	local tableid = 1;
	
	for row in GameInfo.Civilizations() do	
		if row.Playable == true or row.AIPlayable == true then
		--if row.Type ~= "CIVILIZATION_MINOR" and row.Type ~= "CIVILIZATION_ALIEN" and row.Type ~= "CIVILIZATION_NEUTRAL_PROXY" then
			local leader = nil;
			for leaderRow in GameInfo.Civilization_Leaders{CivilizationType = row.Type} do
				leader = GameInfo.Leaders[ leaderRow.LeaderheadType ];
			end
			local article = {};
			local name = Locale.ConvertTextKey( leader.Description )
			article.entryName = name;
			article.entryID = row.ID + 1000;
			article.entryCategory = CategoryCivilizations;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( leader.PortraitIndex, buttonSize, leader.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				

			sortedList[CategoryCivilizations][2][tableid] = article;
			tableid = tableid + 1;
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[leader.Description] = article;
			m_categorizedListOfArticles[(CategoryCivilizations * MAX_ENTRIES_PER_CATEGORY) + row.ID + 1000] = article;

			-- Special-case fix-up for searching for leaders with special characters in their name
			if (leader.Type == "LEADER_FRANCO_IBERIA") then
				searchableList[Locale.ToLower("Elodie")] = article;
			end
		end
	end
	
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryCivilizations][2], Alphabetically);
					
end

CivilopediaCategory[CategoryQuests].PopulateList = function()
	sortedList[CategoryQuests] = {};
	local articlelist = sortedList[CategoryQuests];
		
	-- for each concept
	for thisConcept in GameInfo.Concepts() do
		if(thisConcept.CivilopediaHeaderType == "HEADER_QUESTS") then
			-- add an article to the list (localized name, unit tag, etc.)
			local article = {};
			local name = Locale.ConvertTextKey( thisConcept.Description )
			article.entryName = name;
			article.entryID = thisConcept.ID;
			article.entryCategory = CategoryQuests;
			article.InsertBefore = thisConcept.InsertBefore;
			article.InsertAfter = thisConcept.InsertAfter;
			article.Type = thisConcept.Type;

			table.insert(articlelist, article);
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[thisConcept.Description] = article;
			m_categorizedListOfArticles[(CategoryQuests * MAX_ENTRIES_PER_CATEGORY) + thisConcept.ID] = article;
		end
	end

	-- In order to maintain the original order as best as possible,
	-- we assign "InsertBefore" values to all items that lack any insert.
	for i = #articlelist, 1, -1 do
		local concept = articlelist[i];
		
		if(concept.InsertBefore == nil and concept.InsertAfter == nil) then
			for ii = i - 1, 1, -1 do
				local previousConcept = articlelist[ii];
				if(previousConcept.InsertBefore == nil and previousConcept.InsertAfter == nil) then
					concept.InsertAfter = previousConcept.Type;
					break;
				end
			end
		end
	end

	
	-- sort the articles by their dependencies.
	function DependencySort(articles)
		
		-- index articles by Topic
		local articlesByType= {};
		local dependencies = {};
		
		for i,v in ipairs(articles) do
			articlesByType[v.Type] = v;
			dependencies[v] = {};
		end
		
		for i,v in ipairs(articles) do
			
			local insertBefore = v.InsertBefore;
			if(insertBefore ~= nil) then
				local article = articlesByType[insertBefore];
				dependencies[article][v] = true;
			end
			
			local insertAfter = v.InsertAfter;
			if(insertAfter ~= nil) then
				local article = articlesByType[insertAfter];
				dependencies[v][article] = true;
			end
		end
		
		local sortedList = {};
		
		local articleCount = #articles;
		while(#sortedList < articleCount) do
			
			-- Attempt to find a node with 0 dependencies
			local article;
			for i,a in ipairs(articles) do
				if(dependencies[a] ~= nil and table.count(dependencies[a]) == 0) then
					article = a;
					break;
				end
			end
			
			if(article == nil) then
				print("Failed to sort articles topologically!! There are dependency cycles.");
				return nil;
			else
			
				-- Insert Node
				table.insert(sortedList, article);
				
				-- Remove node
				dependencies[article] = nil;
				for a,d in pairs(dependencies) do
					d[article] = nil;
				end
			end
		end
		
		return sortedList;
	end
		
	local oldList = articlelist;
	local newList = DependencySort(articlelist);

	if(newList == nil) then
		newList = oldList;
	else
		newList.headingOpen = false;
	end
	
	articlelist = newList;	
end

CivilopediaCategory[CategoryTerrain].PopulateList = function()
	-- add the instances of the Terrain and Features entries
	
	sortedList[CategoryTerrain] = {};
	
	-- first Terrains
	sortedList[CategoryTerrain][1] = {};
	local tableid = 1;

	for row in GameInfo.Terrains() do	
		if not row.GraphicalOnly then
			local article = {};
			local name = Locale.ConvertTextKey( row.Description )
			article.entryName = name;
			article.entryID = row.ID;
			article.entryCategory = CategoryTerrain;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				

			sortedList[CategoryTerrain][1][tableid] = article;
			tableid = tableid + 1;
		
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[row.Description] = article;
			m_categorizedListOfArticles[(CategoryTerrain * MAX_ENTRIES_PER_CATEGORY) + row.ID] = article; -- add a fudge factor
		end
	end
	
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryTerrain][1], Alphabetically);
			
	-- next Features
	sortedList[CategoryTerrain][2] = {};
	tableid = 1;

	for row in GameInfo.Features() do	
		if not row.GraphicalOnly then
			local article = {};
			local name = Locale.ConvertTextKey( row.Description )
			article.entryName = name;
			article.entryID = row.ID + 1000;
			article.entryCategory = CategoryTerrain;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				

			sortedList[CategoryTerrain][2][tableid] = article;
			tableid = tableid + 1;
		
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[row.Description] = article;
			m_categorizedListOfArticles[(CategoryTerrain * MAX_ENTRIES_PER_CATEGORY) + row.ID + 1000] = article; -- add a fudge factor
		end
	end

	-- also add the fake features (river and lake)
	for row in GameInfo.FakeFeatures() do	
		if( row.DecorationOnly == false ) then
			local article = {};
			local name = Locale.ConvertTextKey( row.Description )
			article.entryName = name;
			article.entryID = row.ID + 2000;
			article.entryCategory = CategoryTerrain;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				

			sortedList[CategoryTerrain][2][tableid] = article;
			tableid = tableid + 1;
		
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[row.Description] = article;
			m_categorizedListOfArticles[(CategoryTerrain * MAX_ENTRIES_PER_CATEGORY) + row.ID + 2000] = article; -- add a fudge factor
		end
	end

	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryTerrain][2], Alphabetically);

	-- Last Biomes
	sortedList[CategoryTerrain][3] = {};
	tableid = 1;

	for row in GameInfo.Planets() do	
		local article = {};
		local name = Locale.ConvertTextKey( row.Description )
		article.entryName = name;
		article.entryID = row.ID + 3000;
		article.entryCategory = CategoryTerrain;
		article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
		if not article.tooltipTextureOffset then
			article.tooltipTexture = defaultErrorTextureSheet;
			article.tooltipTextureOffset = nullOffset;
		end	

		sortedList[CategoryTerrain][3][tableid] = article;
		tableid = tableid + 1;
		
		-- index by various keys
		searchableList[Locale.ToLower(name)] = article;
		searchableTextKeyList[row.Description] = article;
		m_categorizedListOfArticles[(CategoryTerrain * MAX_ENTRIES_PER_CATEGORY) + row.ID + 3000] = article;
	end
	table.sort(sortedList[CategoryTerrain][3], Alphabetically);

	-- Oh, but then! Marvels
	sortedList[CategoryTerrain][4] = {};
	tableid = 1;

	for row in GameInfo.Marvels() do	
		local article = {};
		local heroLandmarkInfo = GameInfo.HeroLandmarks[row.MajorMarvelLandmark];
		local name = Locale.ConvertTextKey( heroLandmarkInfo.Description )
		article.entryName = name;
		article.entryID = row.ID + 4000;
		article.entryCategory = CategoryTerrain;
		article.tooltipTextureOffset, article.tooltipTexture = IconLookup( 35, buttonSize, "RESOURCE_ATLAS" );				
		if not article.tooltipTextureOffset then
			article.tooltipTexture = defaultErrorTextureSheet;
			article.tooltipTextureOffset = nullOffset;
		end	

		sortedList[CategoryTerrain][4][tableid] = article;
		tableid = tableid + 1;
		
		-- index by various keys
		searchableList[Locale.ToLower(name)] = article;
		searchableTextKeyList[heroLandmarkInfo.Description] = article;
		m_categorizedListOfArticles[(CategoryTerrain * MAX_ENTRIES_PER_CATEGORY) + row.ID + 4000] = article;
	end
	table.sort(sortedList[CategoryTerrain][4], Alphabetically);
end

CivilopediaCategory[CategoryResources].PopulateList = function()
	-- add the instances of the resource entries
	
	sortedList[CategoryResources] = {};
	
	-- for each type of resource

	for resourceClassInfo in GameInfo.ResourceClasses() do
		
		sortedList[CategoryResources][resourceClassInfo.ID] = {};
		local tableid = 1;
	
		-- for each type of resource
 		for resource in GameInfo.Resources( "ResourceClassType = '" .. resourceClassInfo.Type .. "'" ) do
			if resource.ShowInCivilopedia then
				-- add a tech entry to a list (localized name, tag, etc.)
 				local article = {};
 				local name = Locale.ConvertTextKey( resource.Description )
 				article.entryName = name;
 				article.entryID = resource.ID;
				article.entryIDAlt = -1;
				article.entryCategory = CategoryResources;
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( resource.PortraitIndex, buttonSize, resource.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end

				-- if the resource name already exists, add an alternate entryID.
				local found = false;
				for _, originalArticle in ipairs(sortedList[CategoryResources][resourceClassInfo.ID]) do
					if originalArticle.entryName == name then
						found = true;
						article = originalArticle;
						article.entryIDAlt = resource.ID;
						break;
					end
				end

				if not found then
					sortedList[CategoryResources][resourceClassInfo.ID][tableid] = article;
					tableid = tableid + 1;
				end
			
				-- index by various keys
				searchableList[Locale.ToLower(name)] = article;
				searchableTextKeyList[resource.Description] = article;
				m_categorizedListOfArticles[(CategoryResources * MAX_ENTRIES_PER_CATEGORY) + resource.ID] = article;
			end
		end

		-- sort this list alphabetically by localized name
		table.sort(sortedList[CategoryResources][resourceClassInfo.ID], Alphabetically);
	
	end
					
end

CivilopediaCategory[CategoryImprovements].PopulateList = function()
	-- add the instances of the improvement entries
	
	sortedList[CategoryImprovements] = {};
	
	-- Worker
	sortedList[CategoryImprovements][1] = {}; -- three sections. PW
	local tableid = 1;
	
	-- for each improvement
	for row in GameInfo.Improvements() do	
		-- if not row.GraphicalOnly then
		if (not row.MinorMarvel and not row.GraphicalOnly) then
			if ( not row.CannotPillage and row.Civilopedia ~= nil ) then
			-- Ignore entries without a civilopedia entry (e.g., "Partial" improvments omitted in BE or they appear twice in list.
				if ( row.Type ~= "IMPROVEMENT_EARTHLING_SETTLEMENT" and row.Type ~= "IMPROVEMENT_EXPEDITION" ) then 
					-- add an article to the list (localized name, unit tag, etc.)
					local article = {};
					local name = Locale.ConvertTextKey( row.Description );
					article.entryName = name;
					article.entryID = row.ID;
					article.entryCategory = CategoryImprovements;
					article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
					if not article.tooltipTextureOffset then
						article.tooltipTexture = defaultErrorTextureSheet;
						article.tooltipTextureOffset = nullOffset;
					end				
				
					sortedList[CategoryImprovements][1][tableid] = article;
					tableid = tableid + 1;
				
					-- index by various keys
					searchableList[Locale.ToLower(name)] = article;
					searchableTextKeyList[row.Description] = article;
					m_categorizedListOfArticles[(CategoryImprovements * MAX_ENTRIES_PER_CATEGORY) + row.ID] = article;
				end
			end
		end
	end
	
	--add roads and magrail
	for row in GameInfo.Routes() do
		local article = {};
		local name = Locale.ConvertTextKey( row.Description );
		article.entryName = name;
		article.entryID = row.ID + 3000;
		article.entryCategory = CategoryImprovements;
		article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
		if not article.tooltipTextureOffset then
			article.tooltipTexture = defaultErrorTextureSheet;
			article.tooltipTextureOffset = nullOffset;
		end				
		
		sortedList[CategoryImprovements][1][tableid] = article;
		tableid = tableid + 1;
		
		-- index by various keys
		searchableList[Locale.ToLower(name)] = article;
		searchableTextKeyList[row.Description] = article;
		m_categorizedListOfArticles[(CategoryImprovements * MAX_ENTRIES_PER_CATEGORY) + 3000 + row.ID] = article;
	end

	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryImprovements][1], Alphabetically);
	
	-- Other
	sortedList[CategoryImprovements][2] = {};
	tableid = 1;

	for row in GameInfo.Improvements() do
		-- if (not row.MinorMarvel and not row.GraphicalOnly) or ( row.Type == "IMPROVEMENT_MIND_FLOWER" or row.Type == "IMPROVEMENT_SUPREMACY_GATE" or row.Type == "IMPROVEMENT_PURITY_GATE" or row.Type == "IMPROVEMENT_BEACON" ) then
		-- ���� ������ ������� ������ �����������, ��� ��� ����� ��� � ���� ���������� ������������� ����, � �� � ������.
		if (not row.MinorMarvel and not row.GraphicalOnly) then
			if ( row.CannotPillage and row.Civilopedia ~= nil ) or ( row.Type == "IMPROVEMENT_EARTHLING_SETTLEMENT" or row.Type == "IMPROVEMENT_EXPEDITION" ) then
				local article = {};
				local name = Locale.ConvertTextKey( row.Description );
				article.entryName = name;
				article.entryID = row.ID + 1000;
				article.entryCategory = CategoryImprovements;
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end				
				
				sortedList[CategoryImprovements][2][tableid] = article;
				tableid = tableid + 1;
				
				-- index by various keys
				searchableList[Locale.ToLower(name)] = article;
				searchableTextKeyList[row.Description] = article;
				m_categorizedListOfArticles[(CategoryImprovements * MAX_ENTRIES_PER_CATEGORY) + row.ID + 1000] = article;
			end
		end
	end
	table.sort(sortedList[CategoryImprovements][2], Alphabetically);	
	
	-- Minor Marvels
	sortedList[CategoryImprovements][3] = {};
	tableid = 1;

	for row in GameInfo.Improvements() do
		if row.MinorMarvel then
			local article = {};
			local name = Locale.ConvertTextKey( row.Description );
			article.entryName = name;
			article.entryID = row.ID + 2000;
			article.entryCategory = CategoryImprovements;
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end				
			
			sortedList[CategoryImprovements][3][tableid] = article;
			tableid = tableid + 1;
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[row.Description] = article;
			m_categorizedListOfArticles[(CategoryImprovements * MAX_ENTRIES_PER_CATEGORY) + row.ID + 2000] = article;
			
		end
	end
	table.sort(sortedList[CategoryImprovements][3], Alphabetically);	
			
end

CivilopediaCategory[CategoryAffinities].PopulateList = function()
	sortedList[CategoryAffinities] = {};
	local articlelist = sortedList[CategoryAffinities];
		
	-- for each concept
	for thisConcept in GameInfo.Concepts() do
		if(thisConcept.CivilopediaHeaderType == "HEADER_AFFINITY") then
			-- add an article to the list (localized name, unit tag, etc.)
			local article = {};
			local name = Locale.ConvertTextKey( thisConcept.Description )
			article.entryName = name;
			article.entryID = thisConcept.ID;
			article.entryCategory = CategoryAffinities;
			article.InsertBefore = thisConcept.InsertBefore;
			article.InsertAfter = thisConcept.InsertAfter;
			article.Type = thisConcept.Type;

			table.insert(articlelist, article);
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[thisConcept.Description] = article;
			m_categorizedListOfArticles[(CategoryAffinities * MAX_ENTRIES_PER_CATEGORY) + thisConcept.ID] = article;
		end
	end
	
	-- Perk lists
	for affinity in GameInfo.Affinity_Types() do
		local article = {};
		local name = Locale.ConvertTextKey("TXT_KEY_PEDIA_AFFINITY_PERKS_LABEL", affinity.Description);
		local entryID = affinity.ID + 1000;
		local articleType = affinity.Type .. "_PERKS";

		article.entryName = name;
		article.entryID = entryID;
		article.entryCategory = CategoryAffinities;
		article.Type = articleType;
		table.insert(articlelist, article);

		-- index by various keys
		searchableList[Locale.ToLower(name)] = article;
		searchableTextKeyList[articleType] = article;
		m_categorizedListOfArticles[(CategoryAffinities * MAX_ENTRIES_PER_CATEGORY) + entryID] = article;
	end

	-- In order to maintain the original order as best as possible,
	-- we assign "InsertBefore" values to all items that lack any insert.
	for i = #articlelist, 1, -1 do
		local concept = articlelist[i];
		
		if(concept.InsertBefore == nil and concept.InsertAfter == nil) then
			for ii = i - 1, 1, -1 do
				local previousConcept = articlelist[ii];
				if(previousConcept.InsertBefore == nil and previousConcept.InsertAfter == nil) then
					concept.InsertAfter = previousConcept.Type;
					break;
				end
			end
		end
	end

	
	-- sort the articles by their dependencies.
	function DependencySort(articles)
		
		-- index articles by Topic
		local articlesByType= {};
		local dependencies = {};
		
		for i,v in ipairs(articles) do
			articlesByType[v.Type] = v;
			dependencies[v] = {};
		end
		
		for i,v in ipairs(articles) do
			
			local insertBefore = v.InsertBefore;
			if(insertBefore ~= nil) then
				local article = articlesByType[insertBefore];
				dependencies[article][v] = true;
			end
			
			local insertAfter = v.InsertAfter;
			if(insertAfter ~= nil) then
				local article = articlesByType[insertAfter];
				dependencies[v][article] = true;
			end
		end
		
		local sortedList = {};
		
		local articleCount = #articles;
		while(#sortedList < articleCount) do
			
			-- Attempt to find a node with 0 dependencies
			local article;
			for i,a in ipairs(articles) do
				if(dependencies[a] ~= nil and table.count(dependencies[a]) == 0) then
					article = a;
					break;
				end
			end
			
			if(article == nil) then
				print("Failed to sort articles topologically!! There are dependency cycles.");
				return nil;
			else
			
				-- Insert Node
				table.insert(sortedList, article);
				
				-- Remove node
				dependencies[article] = nil;
				for a,d in pairs(dependencies) do
					d[article] = nil;
				end
			end
		end
		
		return sortedList;
	end
		
	local oldList = articlelist;
	local newList = DependencySort(articlelist);

	if(newList == nil) then
		newList = oldList;
	else
		newList.headingOpen = false;
	end
	
	articlelist = newList;			
end

CivilopediaCategory[CategoryStations].PopulateList = function()
	sortedList[CategoryStations] = {};
	local articlelist = sortedList[CategoryStations];
		
	-- for each concept
	for thisConcept in GameInfo.Concepts() do
		if(thisConcept.CivilopediaHeaderType == "HEADER_STATIONS") then
			-- add an article to the list (localized name, unit tag, etc.)
			local article = {};
			local name = Locale.ConvertTextKey( thisConcept.Description )
			article.entryName = name;
			article.entryID = thisConcept.ID;
			article.entryCategory = CategoryStations;
			article.InsertBefore = thisConcept.InsertBefore;
			article.InsertAfter = thisConcept.InsertAfter;
			article.Type = thisConcept.Type;

			table.insert(articlelist, article);
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[thisConcept.Description] = article;
			m_categorizedListOfArticles[(CategoryStations * MAX_ENTRIES_PER_CATEGORY) + thisConcept.ID] = article;
		end
	end
	
		-- In order to maintain the original order as best as possible,
	-- we assign "InsertBefore" values to all items that lack any insert.
	for i = #articlelist, 1, -1 do
		local concept = articlelist[i];
		
		if(concept.InsertBefore == nil and concept.InsertAfter == nil) then
			for ii = i - 1, 1, -1 do
				local previousConcept = articlelist[ii];
				if(previousConcept.InsertBefore == nil and previousConcept.InsertAfter == nil) then
					concept.InsertAfter = previousConcept.Type;
					break;
				end
			end
		end
	end

	
	-- sort the articles by their dependencies.
	function DependencySort(articles)
		
		-- index articles by Topic
		local articlesByType= {};
		local dependencies = {};
		
		for i,v in ipairs(articles) do
			articlesByType[v.Type] = v;
			dependencies[v] = {};
		end
		
		for i,v in ipairs(articles) do
			
			local insertBefore = v.InsertBefore;
			if(insertBefore ~= nil) then
				local article = articlesByType[insertBefore];
				dependencies[article][v] = true;
			end
			
			local insertAfter = v.InsertAfter;
			if(insertAfter ~= nil) then
				local article = articlesByType[insertAfter];
				dependencies[v][article] = true;
			end
		end
		
		local sortedList = {};
		
		local articleCount = #articles;
		while(#sortedList < articleCount) do
			
			-- Attempt to find a node with 0 dependencies
			local article;
			for i,a in ipairs(articles) do
				if(dependencies[a] ~= nil and table.count(dependencies[a]) == 0) then
					article = a;
					break;
				end
			end
			
			if(article == nil) then
				print("Failed to sort articles topologically!! There are dependency cycles.");
				return nil;
			else
			
				-- Insert Node
				table.insert(sortedList, article);
				
				-- Remove node
				dependencies[article] = nil;
				for a,d in pairs(dependencies) do
					d[article] = nil;
				end
			end
		end
		
		return sortedList;
	end
		
	local oldList = articlelist;
	local newList = DependencySort(articlelist);

	if(newList == nil) then
		newList = oldList;
	else
		newList.headingOpen = false;
	end
	
	articlelist = newList;			
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
CivilopediaCategory[CategoryDiplomacy].PopulateList = function()	--	PW
	-- print("CivilopediaCategory[CategoryDiplomacy].PopulateList"); -- dbg
	sortedList[CategoryDiplomacy] = {};
	
	-- first Personality Traits
	-- 4 - Military Trait
	-- 3 - Domestic Trait
	-- 2 - Political Trait
	-- 1 - Character Trait
	
	local tableid = 1;
	local SubCatIndex = 1;
	sortedList[CategoryDiplomacy][SubCatIndex] = {}; -- Character Trait PW	
	for trait in GameInfo.PersonalityTraits() do	
		if trait.TraitCategoryType == "PERSONALITY_TRAIT_CATEGORY_CHARACTER" then
			-- print("TraitCategoryType = 'PERSONALITY_TRAIT_CATEGORY_CHARACTER'"); -- dbg
			local article = {};
			local name = Locale.ConvertTextKey( trait.Description )
			article.entryName = name;
			article.entryID = trait.ID;
			article.entryCategory = CategoryDiplomacy;	
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( trait.PortraitIndex, buttonSize, trait.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end					

			sortedList[CategoryDiplomacy][SubCatIndex][tableid] = article;
			tableid = tableid + 1;			
			-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg	
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[trait.Description] = article;
			m_categorizedListOfArticles[(CategoryDiplomacy * MAX_ENTRIES_PER_CATEGORY) + trait.ID] = article;
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryDiplomacy][SubCatIndex], Alphabetically);
	sortedList[CategoryDiplomacy][SubCatIndex].headingOpen = true; -- open for first time
	
	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	-- SubCatIndex = 2;
	sortedList[CategoryDiplomacy][SubCatIndex] = {}; -- Political Trait PW
	for trait in GameInfo.PersonalityTraits( "TraitCategoryType = 'PERSONALITY_TRAIT_CATEGORY_POLITICAL'" ) do	
		-- print("TraitCategoryType = 'PERSONALITY_TRAIT_CATEGORY_POLITICAL'"); -- dbg
		local article = {};
		local name = Locale.ConvertTextKey( trait.Description )
		article.entryName = name;
		article.entryID = trait.ID;
		article.entryCategory = CategoryDiplomacy;	
		article.tooltipTextureOffset, article.tooltipTexture = IconLookup( trait.PortraitIndex, buttonSize, trait.IconAtlas );				
		if not article.tooltipTextureOffset then
			article.tooltipTexture = defaultErrorTextureSheet;
			article.tooltipTextureOffset = nullOffset;
		end					

		sortedList[CategoryDiplomacy][SubCatIndex][tableid] = article;
		tableid = tableid + 1;		
		-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg	
		
		-- index by various keys
		searchableList[Locale.ToLower(name)] = article;
		searchableTextKeyList[trait.Description] = article;
		m_categorizedListOfArticles[(CategoryDiplomacy * MAX_ENTRIES_PER_CATEGORY) + trait.ID] = article;
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryDiplomacy][SubCatIndex], Alphabetically);
	sortedList[CategoryDiplomacy][SubCatIndex].headingOpen = true; -- open for first time
	
	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	sortedList[CategoryDiplomacy][SubCatIndex] = {}; -- Domestic Trait PW
	for trait in GameInfo.PersonalityTraits() do	
		if trait.TraitCategoryType == "PERSONALITY_TRAIT_CATEGORY_DOMESTIC" then
			local article = {};
			local name = Locale.ConvertTextKey( trait.Description )
			article.entryName = name;
			article.entryID = trait.ID;
			article.entryCategory = CategoryDiplomacy;	
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( trait.PortraitIndex, buttonSize, trait.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end					

			sortedList[CategoryDiplomacy][SubCatIndex][tableid] = article;
			tableid = tableid + 1;			
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[trait.Description] = article;
			m_categorizedListOfArticles[(CategoryDiplomacy * MAX_ENTRIES_PER_CATEGORY) + trait.ID] = article;
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryDiplomacy][SubCatIndex], Alphabetically);
	sortedList[CategoryDiplomacy][SubCatIndex].headingOpen = true; -- open for first time
	
	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	sortedList[CategoryDiplomacy][SubCatIndex] = {}; -- Military Trait PW
	for trait in GameInfo.PersonalityTraits() do	
		if trait.TraitCategoryType == "PERSONALITY_TRAIT_CATEGORY_MILITARY" then
			local article = {};
			local name = Locale.ConvertTextKey( trait.Description )
			article.entryName = name;
			article.entryID = trait.ID;
			article.entryCategory = CategoryDiplomacy;	
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( trait.PortraitIndex, buttonSize, trait.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end					

			sortedList[CategoryDiplomacy][SubCatIndex][tableid] = article;
			tableid = tableid + 1;			
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[trait.Description] = article;
			m_categorizedListOfArticles[(CategoryDiplomacy * MAX_ENTRIES_PER_CATEGORY) + trait.ID] = article;
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryDiplomacy][SubCatIndex], Alphabetically);
	sortedList[CategoryDiplomacy][SubCatIndex].headingOpen = true; -- open for first time


	-- next Foreign Policies
	-- 8 - Military Agreement
	-- 7 - Domestic Agreement
	-- 6 - Political Agreement
	-- 5 - Character Agreement
	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	-- SubCatIndex = 5
	sortedList[CategoryDiplomacy][SubCatIndex] = {};
	for agreement in GameInfo.ForeignPolicies() do
		-- local ThisAgreemTrait = false;
		local ThisAgreemTraitCat = false;
		for trait_policy in GameInfo.PersonalityTraits_ForeignPolicies( "ForeignPolicyType = '"..agreement.Type.."'" ) do
			-- ThisAgreemTrait = GameInfo.PersonalityTraits[trait_policy.PersonalityTraitType].Type;
			ThisAgreemTraitCat = GameInfo.PersonalityTraits[trait_policy.PersonalityTraitType].TraitCategoryType;
			-- if ThisAgreemTraitCat then -- dbg
				-- print("ThisAgreemTraitCat is ".. ThisAgreemTraitCat .." for ".. agreement.Type); -- dbg	
			-- end -- dbg
			if ThisAgreemTraitCat == "PERSONALITY_TRAIT_CATEGORY_CHARACTER" then
				local article = {};
				local name = Locale.ConvertTextKey( agreement.Description )
				article.entryName = name;
				article.entryID = agreement.ID + 1000;
				article.entryCategory = CategoryDiplomacy;
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( agreement.PortraitIndex, buttonSize, agreement.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end				

				sortedList[CategoryDiplomacy][SubCatIndex][tableid] = article;
				tableid = tableid + 1;
				
				-- index by various keys
				searchableList[Locale.ToLower(name)] = article;
				searchableTextKeyList[agreement.Description] = article;
				m_categorizedListOfArticles[(CategoryDiplomacy * MAX_ENTRIES_PER_CATEGORY) + agreement.ID + 1000] = article;
			end
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryDiplomacy][SubCatIndex], Alphabetically);
	sortedList[CategoryDiplomacy][SubCatIndex].headingOpen = true; -- open for first time

	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	-- SubCatIndex = 5
	sortedList[CategoryDiplomacy][SubCatIndex] = {};
	for agreement in GameInfo.ForeignPolicies() do
		-- local ThisAgreemTrait = false;
		local ThisAgreemTraitCat = false;
		for trait_policy in GameInfo.PersonalityTraits_ForeignPolicies( "ForeignPolicyType = '"..agreement.Type.."'" ) do
			-- ThisAgreemTrait = GameInfo.PersonalityTraits[trait_policy.PersonalityTraitType].Type;
			ThisAgreemTraitCat = GameInfo.PersonalityTraits[trait_policy.PersonalityTraitType].TraitCategoryType;
			-- if ThisAgreemTraitCat then -- dbg
				-- print("ThisAgreemTraitCat is ".. ThisAgreemTraitCat .." for ".. agreement.Type); -- dbg	
			-- end -- dbg
			if ThisAgreemTraitCat == "PERSONALITY_TRAIT_CATEGORY_POLITICAL" then
				local article = {};
				local name = Locale.ConvertTextKey( agreement.Description )
				article.entryName = name;
				article.entryID = agreement.ID + 1000;
				article.entryCategory = CategoryDiplomacy;
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( agreement.PortraitIndex, buttonSize, agreement.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end				

				sortedList[CategoryDiplomacy][SubCatIndex][tableid] = article;
				tableid = tableid + 1;
				
				-- index by various keys
				searchableList[Locale.ToLower(name)] = article;
				searchableTextKeyList[agreement.Description] = article;
				m_categorizedListOfArticles[(CategoryDiplomacy * MAX_ENTRIES_PER_CATEGORY) + agreement.ID + 1000] = article;
			end
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryDiplomacy][SubCatIndex], Alphabetically);
	sortedList[CategoryDiplomacy][SubCatIndex].headingOpen = true; -- open for first time

	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	-- SubCatIndex = 5
	sortedList[CategoryDiplomacy][SubCatIndex] = {};
	for agreement in GameInfo.ForeignPolicies() do
		-- local ThisAgreemTrait = false;
		local ThisAgreemTraitCat = false;
		for trait_policy in GameInfo.PersonalityTraits_ForeignPolicies( "ForeignPolicyType = '"..agreement.Type.."'" ) do
			-- ThisAgreemTrait = GameInfo.PersonalityTraits[trait_policy.PersonalityTraitType].Type;
			ThisAgreemTraitCat = GameInfo.PersonalityTraits[trait_policy.PersonalityTraitType].TraitCategoryType;
			-- if ThisAgreemTraitCat then -- dbg
				-- print("ThisAgreemTraitCat is ".. ThisAgreemTraitCat .." for ".. agreement.Type); -- dbg	
			-- end -- dbg
			if ThisAgreemTraitCat == "PERSONALITY_TRAIT_CATEGORY_DOMESTIC" then
				local article = {};
				local name = Locale.ConvertTextKey( agreement.Description )
				article.entryName = name;
				article.entryID = agreement.ID + 1000;
				article.entryCategory = CategoryDiplomacy;
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( agreement.PortraitIndex, buttonSize, agreement.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end				

				sortedList[CategoryDiplomacy][SubCatIndex][tableid] = article;
				tableid = tableid + 1;
				
				-- index by various keys
				searchableList[Locale.ToLower(name)] = article;
				searchableTextKeyList[agreement.Description] = article;
				m_categorizedListOfArticles[(CategoryDiplomacy * MAX_ENTRIES_PER_CATEGORY) + agreement.ID + 1000] = article;
			end
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryDiplomacy][SubCatIndex], Alphabetically);
	sortedList[CategoryDiplomacy][SubCatIndex].headingOpen = true; -- open for first time

	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	-- SubCatIndex = 5
	sortedList[CategoryDiplomacy][SubCatIndex] = {};
	for agreement in GameInfo.ForeignPolicies() do
		-- local ThisAgreemTrait = false;
		local ThisAgreemTraitCat = false;
		for trait_policy in GameInfo.PersonalityTraits_ForeignPolicies( "ForeignPolicyType = '"..agreement.Type.."'" ) do
			-- ThisAgreemTrait = GameInfo.PersonalityTraits[trait_policy.PersonalityTraitType].Type;
			ThisAgreemTraitCat = GameInfo.PersonalityTraits[trait_policy.PersonalityTraitType].TraitCategoryType;
			-- if ThisAgreemTraitCat then -- dbg
				-- print("ThisAgreemTraitCat is ".. ThisAgreemTraitCat .." for ".. agreement.Type); -- dbg	
			-- end -- dbg
			if ThisAgreemTraitCat == "PERSONALITY_TRAIT_CATEGORY_MILITARY" then
				local article = {};
				local name = Locale.ConvertTextKey( agreement.Description )
				article.entryName = name;
				article.entryID = agreement.ID + 1000;
				article.entryCategory = CategoryDiplomacy;
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( agreement.PortraitIndex, buttonSize, agreement.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end				

				sortedList[CategoryDiplomacy][SubCatIndex][tableid] = article;
				tableid = tableid + 1;
				
				-- index by various keys
				searchableList[Locale.ToLower(name)] = article;
				searchableTextKeyList[agreement.Description] = article;
				m_categorizedListOfArticles[(CategoryDiplomacy * MAX_ENTRIES_PER_CATEGORY) + agreement.ID + 1000] = article;
			end
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryDiplomacy][SubCatIndex], Alphabetically);
	sortedList[CategoryDiplomacy][SubCatIndex].headingOpen = true; -- open for first time
	
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
CivilopediaCategory[CategoryArtifacts].PopulateList = function()
	sortedList[CategoryArtifacts] = {};
	
	-- first Artifacts
	-- 3 - Progenitor
	-- 2 - Alien
	-- 1 - Old Earth
	local tableid = 1;
	local SubCatIndex = 1;
	sortedList[CategoryArtifacts][SubCatIndex] = {}; -- Old Earth Category
	for row in GameInfo.Artifacts() do	
		if row.Category == "ARTIFACT_CATEGORY_OLD_EARTH" then
			local article = {};
			local name = Locale.ConvertTextKey( row.Description )
			article.entryName = name;
			article.entryID = row.ID;
			article.entryCategory = CategoryArtifacts;	
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end					

			sortedList[CategoryArtifacts][SubCatIndex][tableid] = article;
			tableid = tableid + 1;			
			-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg	
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[row.Description] = article;
			m_categorizedListOfArticles[(CategoryArtifacts * MAX_ENTRIES_PER_CATEGORY) + row.ID] = article;
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryArtifacts][SubCatIndex], Alphabetically);
	sortedList[CategoryArtifacts][SubCatIndex].headingOpen = true; -- open for first time
	
	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	sortedList[CategoryArtifacts][SubCatIndex] = {}; -- Alien Category
	for row in GameInfo.Artifacts() do	
		if row.Category == "ARTIFACT_CATEGORY_ALIEN" then
			local article = {};
			local name = Locale.ConvertTextKey( row.Description )
			article.entryName = name;
			article.entryID = row.ID;
			article.entryCategory = CategoryArtifacts;	
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end					

			sortedList[CategoryArtifacts][SubCatIndex][tableid] = article;
			tableid = tableid + 1;			
			-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg	
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[row.Description] = article;
			m_categorizedListOfArticles[(CategoryArtifacts * MAX_ENTRIES_PER_CATEGORY) + row.ID] = article;
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryArtifacts][SubCatIndex], Alphabetically);
	sortedList[CategoryArtifacts][SubCatIndex].headingOpen = true; -- open for first time
	
	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	sortedList[CategoryArtifacts][SubCatIndex] = {}; -- Progenitor Category
	for row in GameInfo.Artifacts() do	
		if row.Category == "ARTIFACT_CATEGORY_PROGENITOR" then
			local article = {};
			local name = Locale.ConvertTextKey( row.Description )
			article.entryName = name;
			article.entryID = row.ID;
			article.entryCategory = CategoryArtifacts;	
			article.tooltipTextureOffset, article.tooltipTexture = IconLookup( row.PortraitIndex, buttonSize, row.IconAtlas );				
			if not article.tooltipTextureOffset then
				article.tooltipTexture = defaultErrorTextureSheet;
				article.tooltipTextureOffset = nullOffset;
			end					

			sortedList[CategoryArtifacts][SubCatIndex][tableid] = article;
			tableid = tableid + 1;			
			-- print("PopulateList set article "..tableID.." "..SubCatIndex); -- dbg	
			
			-- index by various keys
			searchableList[Locale.ToLower(name)] = article;
			searchableTextKeyList[row.Description] = article;
			m_categorizedListOfArticles[(CategoryArtifacts * MAX_ENTRIES_PER_CATEGORY) + row.ID] = article;
		end
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryArtifacts][SubCatIndex], Alphabetically);
	sortedList[CategoryArtifacts][SubCatIndex].headingOpen = true; -- open for first time
	
	-- next Artifact Reward Perks
	tableid = 1;
	SubCatIndex = SubCatIndex + 1;
	sortedList[CategoryArtifacts][SubCatIndex] = {};
	for row in GameInfo.ArtifactRewards() do
		local article = {};
		local name = Locale.ConvertTextKey( row.Description )
		article.entryName = name;
		article.entryID = row.ID + 1000;
		article.entryCategory = CategoryArtifacts;
		
		local rewardInfo = GameInfo.ArtifactRewards[row.ID];
		if (rewardInfo ~= nil) then
			if rewardInfo.BuildingReward ~= nil then
				local building = GameInfo.Buildings[rewardInfo.BuildingReward];
				if building == nil then
					-- error("Artifact reward points to a building/wonder which doesn't exist (yet) in the game database '" ..tostring(_rewardInfo.BuildingReward) .."'");
				else
					article.tooltipTextureOffset, article.tooltipTexture = IconLookup( building.PortraitIndex, buttonSize, building.IconAtlas );				
					if not article.tooltipTextureOffset then
						article.tooltipTexture = defaultErrorTextureSheet;
						article.tooltipTextureOffset = nullOffset;
					end	
				end
			--MGH:Check this
			--[[elseif rewardInfo.IconAtlas ~= nil and rewardInfo.PortraitIndex ~= nil and rewardInfo.PortraitIndex ~= -1 then
				article.tooltipTextureOffset, article.tooltipTexture = IconLookup( rewardInfo.PortraitIndex, buttonSize, rewardInfo.IconAtlas );				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end
			]]--
			elseif rewardInfo.PlayerPerkReward ~= nil then
				article.tooltipTextureOffset, article.tooltipTexture = {0,0}, "ArtifactRewardFunctionality"..tostring(buttonSize)..".dds";				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end	
			elseif rewardInfo.PromotionReward ~= nil then
				article.tooltipTextureOffset, article.tooltipTexture = {0,0}, "ArtifactRewardPromotion"..tostring(buttonSize)..".dds";				
				if not article.tooltipTextureOffset then
					article.tooltipTexture = defaultErrorTextureSheet;
					article.tooltipTextureOffset = nullOffset;
				end	
			else
				print("No (known) artifact reward type image for '" .. rewardInfo.Type .. "'.");
				-- Controls.Portrait:SetHide( true );
			end
		end
		
		sortedList[CategoryArtifacts][SubCatIndex][tableid] = article;
		tableid = tableid + 1;
		
		-- index by various keys
		searchableList[Locale.ToLower(name)] = article;
		searchableTextKeyList[row.Description] = article;
		m_categorizedListOfArticles[(CategoryArtifacts * MAX_ENTRIES_PER_CATEGORY) + row.ID + 1000] = article;
	end
	-- sort this list alphabetically by localized name
	table.sort(sortedList[CategoryArtifacts][SubCatIndex], Alphabetically);
	sortedList[CategoryArtifacts][SubCatIndex].headingOpen = true; -- open for first time
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function ResizeEtc()
	
	-- These top level pieces need processing in case a resolution change occurred.
	Controls.BackDrop:ReprocessAnchoring();
	Controls.MainBox:ReprocessAnchoring();
	Controls.MainBackground:ReprocessAnchoring();

	-- Determine size of the rest of the contents...
	Controls.WideStack:CalculateSize();
	Controls.WideStack:ReprocessAnchoring();
	Controls.FullPageStack:CalculateSize();
	Controls.FullPageStack:ReprocessAnchoring();
	Controls.FFTextStack:CalculateSize();
	Controls.FFTextStack:ReprocessAnchoring();
	Controls.BBTextStack:CalculateSize();
	Controls.BBTextStack:ReprocessAnchoring();
	Controls.NarrowStack:CalculateSize();
	Controls.NarrowStack:ReprocessAnchoring();
	
	-- ??TRON: Eventually remove once ControlBase auto-resizes based on parent/full as long as no explicit SetSize calls are made.
	-- Resize the viewable area, calculate internals, then calculate external visible area/scrollbar:
	-- adjust the various parts to fit the screen size
	local _, screenSizeY = UIManager:GetScreenSizeVal(); -- Controls.BackDrop:GetSize();

	Controls.LeftScrollPanel:SetSizeY( screenSizeY - 149 );
	Controls.ListOfArticles:CalculateSize();	
	Controls.LeftScrollPanel:CalculateInternalSize();

	Controls.ScrollPanel:SetSizeY( screenSizeY - 186 );	
	Controls.ScrollPanel:CalculateInternalSize();

	Controls.MainVerticalContentDivider:SetSizeY( screenSizeY - 149 );
	Controls.MainBackground:SetSizeY( screenSizeY - 104 );
end


--------------------------------------------------------------------------------------------------------
-- a few handy-dandy helper functions
--------------------------------------------------------------------------------------------------------
function UpdateButtonFrame( numButtonsAdded, innerFrame, outerFrame )
	if numButtonsAdded > 0 then
		local frameSize = {};
		local h = (math.floor((numButtonsAdded - 1) / numberOfButtonsPerRow) + 1) * buttonSize + buttonPaddingTimesTwo;
		frameSize.x = narrowInnerFrameWidth;
		frameSize.y = h;
		innerFrame:SetSize( frameSize );
		frameSize.x = narrowOuterFrameWidth;
		frameSize.y = h - offsetsBetweenFrames;
		outerFrame:SetSize( frameSize );
		outerFrame:SetHide( false );
	end
end	

function UpdateSmallButton( buttonAdded, image, button, textureSheet, textureOffset, category, localizedText, buttonId )
	
	if(textureSheet ~= nil) then
		image:SetTexture( textureSheet );
	end
	
	if(textureOffset ~= nil) then
		image:SetTextureOffset( textureOffset );	
	end
	
	button:SetOffsetVal( (buttonAdded % numberOfButtonsPerRow) * buttonSize + buttonPadding, math.floor(buttonAdded / numberOfButtonsPerRow) * buttonSize + buttonPadding );				
	button:SetToolTipString( localizedText );
	
	if(category ~= nil) then
		button:SetVoids( buttonId, addToList );
		button:RegisterCallback( Mouse.eLClick, CivilopediaCategory[category].SelectArticle );
	end
end

-- this will need to be enhanced to look at the current language
function TagExists( tag )
	return Locale.HasTextKey(tag);
end

--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

CivilopediaCategory[CategoryMain].DisplayHomePage = function()

	ClearArticle();
	-- Controls.ArticleID:SetText( Locale.ConvertTextKey("TXT_KEY_PEDIA_HOME_PAGE_LABEL") );	
	Controls.ArticleID:SetText( Locale.ToUpper("TXT_KEY_PEDIA_HOME_PAGE_AC_LABEL") );	
	
	Controls.PortraitFrame:SetHide( true );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
	
	--Welcome and insert 1st manual paragraph
	-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_HOME_PAGE_BLURB_TEXT" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateCentrQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_HOME_PAGE_BLURB_TEXT" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );

	local thisBBTextInstance;

	-- Quote on top center
	-- thisBBTextInstance = g_BBTextManager:GetInstance();
	-- if thisBBTextInstance then
		-- UpdateCentrQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_HOME_PAGE_BLURB_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	-- end		

	-- The Datalinks
	thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_DATALINKS_HELP_LABEL" ));
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_DATALINKS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	

	-- How to use the Pedia	
	thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_HOME_PAGE_HELP_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_HOME_PAGE_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_HOME_PAGE_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end		

	Controls.BBTextStack:SetHide( false );		
	
	
	ResizeEtc();
end;

CivilopediaCategory[CategoryConcepts].DisplayHomePage = function()

	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_GAME_CONCEPT_PAGE_LABEL" ));	
	
	Controls.PortraitFrame:SetHide( true );
	
	-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_GCONCEPTS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateCentrQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_GCONCEPTS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();

	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_GAME_CONCEPT_PAGE_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_GAME_CONCEPT_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_GAME_CONCEPT_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	
	Controls.BBTextStack:SetHide( false );
	
	--Did you know fact/tip of the day? Can be taken from rando advisor text.  Or link to random page or modding
	ResizeEtc();
end;

CivilopediaCategory[CategoryTech].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_TECH_PAGE_LABEL" ));	
	
	local portraitIndex = 48;
	local portraitAtlas = "TECH_ATLAS_1";
		
	for row in DB.Query("SELECT PortraitIndex, IconAtlas from Technologies ORDER By Random() LIMIT 1") do
		portraitIndex = row.PortraitIndex;
		portraitAtlas = row.IconAtlas;
	end	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end
	
	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_TECHS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_TECHS" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
	
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TECH_PAGE_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TECHNOLOGIES_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TECHNOLOGIES_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryUnits].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_UNITS_PAGE_LABEL" ));	
	
	local portraitIndex = 26;
	local portraitAtlas = "UNIT_ATLAS_1";
		
	for row in DB.Query("SELECT ID from Units  ORDER By Random() LIMIT 1") do
		portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon(row.ID);
	end	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end
	
	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_UNITS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_UNITS" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
	
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_UNITS_PAGE_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_UNITS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_UNITS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryUpgrades].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_UPGRADES_HEADING1_TITLE" ));	
	
	local portraitIndex = 16;
	local portraitAtlas = "PROMOTION_ATLAS";

	for row in DB.Query("SELECT PortraitIndex, IconAtlas from UnitPerks ORDER By Random() LIMIT 1") do
		portraitIndex = row.PortraitIndex;
		portraitAtlas = row.IconAtlas;
	end	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end
	
	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_PROMOTIONS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_PROMOTIONS" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
			
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_UPGRADES_HEADING1_TITLE" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_PROMOTIONS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_PROMOTIONS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryBuildings].DisplayHomePage = function()
	print("CivilopediaCategory[CategoryBuildings].DisplayHomePage"); -- dbg
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_BUILDINGS_PAGE_LABEL" ));	
	
	local portraitIndex = 24;
	local portraitAtlas = "BW_ATLAS_1";
		
	for row in DB.Query("SELECT PortraitIndex, IconAtlas from Buildings where WonderSplashImage IS NULL ORDER By Random() LIMIT 1") do
		portraitIndex = row.PortraitIndex;
		portraitAtlas = row.IconAtlas;
	end	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end
	
	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_BUILDINGS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_BUILDINGS" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
			
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_BUILDINGS_PAGE_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_BUILDINGS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_BUILDINGS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryWonders].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_WONDERS_PAGE_LABEL" ));	
	
	local portraitIndex = 2;
	local portraitAtlas = "BW_ATLAS_2";
		
	for row in DB.Query("SELECT PortraitIndex, IconAtlas from Buildings Where WonderSplashImage IS NOT NULL ORDER By Random() LIMIT 1") do
		portraitIndex = row.PortraitIndex;
		portraitAtlas = row.IconAtlas;
	end	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end
	
	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_WONDERS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_WONDERS" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
	
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_WONDERS_PAGE_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_WONDERS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_WONDERS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryVirtues].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_POLICIES_PAGE_LABEL" ));	
	
	local portraitIndex = 25;
	local portraitAtlas = "POLICY_ATLAS";
		--
	for row in DB.Query("SELECT PortraitIndex, IconAtlas from Policies Where IconAtlas IS NOT NULL ORDER By Random() LIMIT 1") do
		portraitIndex = row.PortraitIndex;
		portraitAtlas = row.IconAtlas;
	end	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
		-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_POLICIES" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
		UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_POLICIES" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	else
		Controls.PortraitFrame:SetHide( true );
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_POLICIES" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
		UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_POLICIES" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	end
	
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
	
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_POLICIES_PAGE_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_SOCIAL_POL_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_SOCIAL_POL_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryEspionage].DisplayHomePage = function()
	ClearArticle();
	
	local espionageLabel = "TXT_KEY_PEDIA_ESPIONAGE_PAGE_LABEL";
	Controls.ArticleID:SetText( Locale.ToUpper( espionageLabel ));	

	Controls.PortraitFrame:SetHide( true );
	-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_ESPIONAGE" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateCentrQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_ESPIONAGE" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
		
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( espionageLabel ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_SPEC_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_SPEC_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryCivilizations].DisplayHomePage = function()
	ClearArticle();
	-- Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_CIVILIZATIONS_PAGE_LABEL" ));	
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_CATEGORY_10_AC_LABEL" ));	
	
	local portraitIndex = 7;
	local portraitAtlas = "LEADER_ATLAS";
		
	local randomfaction = math.random(12)
	local thisfaction = GameInfo.Civilizations[randomfaction - 1]
	portraitIndex = thisfaction.PortraitIndex;
	portraitAtlas = thisfaction.IconAtlas;
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait2 ) then
		Controls.Portrait2:SetHide( false );
	else
		Controls.Portrait2:SetHide( true );
	end

	local condition = "CivilizationType = '" .. thisfaction.Type .. "'";
	for row in GameInfo.Civilization_Leaders( condition ) do
		local thisfactionleader = GameInfo.Leaders[row.LeaderheadType];
		if thisfactionleader then
			portraitIndex = thisfactionleader.PortraitIndex;
			portraitAtlas = thisfactionleader.IconAtlas;
			if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait3 ) then
				Controls.PortraitFrame:SetHide( false );
				Controls.Portrait3:SetHide( false );
			else
				Controls.PortraitFrame:SetHide( true );
				Controls.Portrait3:SetHide( true );
			end
		end
	end

	-- for row in DB.Query("SELECT PortraitIndex, IconAtlas from Leaders where Type <> \"LEADER_ALIEN\" ORDER By Random() LIMIT 1") do
		-- portraitIndex = row.PortraitIndex;
		-- portraitAtlas = row.IconAtlas;
	-- end	

local tempel = {
	"TXT_KEY_PEDIA_QUOTE_BLOCK_CIVS",
	"TXT_KEY_TECH_ALIEN_DOMESTICATION_QUOTE",
	"TXT_KEY_PEDIA_QUOTE_BLOCK_PROMOTIONS",
	"TXT_KEY_BUILDING_MACHINE_ASSISTED_FREE_WILL_QUOTE",
	"TXT_KEY_PEDIA_QUOTE_BLOCK_POLICIES",
	"TXT_KEY_PEDIA_QUOTE_BLOCK_UNITS",
	"TXT_KEY_PEDIA_QUOTE_BLOCK_QUESTS",
	"TXT_KEY_PEDIA_QUOTE_BLOCK_BUILDINGS",
	"TXT_KEY_PEDIA_DIPLOMACY_HOMEPAGE_TEXT1",
	"TXT_KEY_PEDIA_QUOTE_BLOCK_DIPLOMACY",
	"TXT_KEY_BUILDING_QUANTUM_POLITICS_QUOTE",
	"TXT_KEY_BUILDING_TEMPORAL_CALCULUS_QUOTE",
};

	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_CIVS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( tempel[randomfaction] ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
	
			
	-- Basic Sectional Infos	-- 
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_SPONSORS_HELP_LABEL" ));
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_CIVS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );			--- IMPORTANT!
	
	thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_FACTIONS_UNITY_HELP_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_FACTIONS_UNITY_HELP_TEXT" ), thisBBTextInstance.BBC2TextLabel, thisBBTextInstance.BBC2TextInnerFrame, thisBBTextInstance.BBC2TextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_FACTIONS_UNITY_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	
	local textcolored = "";
	thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey("TXT_KEY_PEDIA_FACTIONS_ANCHORCETI_HELP_LABEL") );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey("TXT_KEY_PEDIA_FACTIONS_ANCHORCETI_HELP_TEXT"), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	
	ResizeEtc();
end;

CivilopediaCategory[CategoryQuests].DisplayHomePage = function()
	ClearArticle();
	
	-- local articlelabel = Locale.Lookup("TXT_KEY_PEDIA_QUESTS_PAGE_LABEL");
	local articlelabel = Locale.ToUpper("TXT_KEY_PEDIA_QUESTS_PAGE_LABEL");
	Controls.ArticleID:SetText(articlelabel);	

	Controls.PortraitFrame:SetHide( true );
	-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_QUESTS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateCentrQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_QUESTS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
		
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText(articlelabel);
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUESTS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUESTS_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryTerrain].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_TERRAIN_PAGE_LABEL" ));	
	
	local portraitIndex = 9;
	local portraitAtlas = "TERRAIN_ATLAS";
		
	for row in DB.Query("SELECT PortraitIndex, IconAtlas from Terrains ORDER By Random() LIMIT 1") do
		portraitIndex = row.PortraitIndex;
		portraitAtlas = row.IconAtlas;
	end	
	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end
	
	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_TERRAIN" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_TERRAIN" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
			
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAIN_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAIN_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );	
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAIN_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );	
	end	
	Controls.BBTextStack:SetHide( false );
	thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAIN_FEATURES_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAIN_FEATURES_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAIN_FEATURES_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end
	ResizeEtc();
end;

CivilopediaCategory[CategoryResources].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_RESOURCES_PAGE_LABEL" ));	
	
	local portraitIndex = 6;
	local portraitAtlas = "RESOURCE_ATLAS";
		
	for row in DB.Query("SELECT PortraitIndex, IconAtlas from Resources ORDER By Random() LIMIT 1") do
		portraitIndex = row.PortraitIndex;
		portraitAtlas = row.IconAtlas;
	end	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end
	
	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_RESOURCES" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_RESOURCES" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
			
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_RESOURCES_PAGE_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_RESOURCES_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_RESOURCES_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryImprovements].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_IMPROVEMENTS_PAGE_LABEL" ));	
	
	--eventually make random?
	local portraitIndex = 1;
	local portraitAtlas = "BW_ATLAS_1";
		
	for row in DB.Query("SELECT PortraitIndex, IconAtlas from Improvements ORDER By Random() LIMIT 1") do
		portraitIndex = row.PortraitIndex;
		portraitAtlas = row.IconAtlas;
	end	
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end
	
	local quotes_text = {
	"TXT_KEY_PEDIA_QUOTE_BLOCK_IMPROVEMENTS",
	"TXT_KEY_PEDIA_QUOTE_BLOCK_IMPROVEMENTS_2",
	}; 
	
	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_IMPROVEMENTS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( quotes_text[math.random(#quotes_text)] ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
			
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENTS_PAGE_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENT_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENT_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	
	-- local thisBBTextInstance = g_BBC2TextManager:GetInstance();
	thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		-- thisBBTextInstance.BBC2TextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENTS_OTHER" ));
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENTS_OTHER" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENTS_OTHER_HELP_TEXT" ), thisBBTextInstance.BBC2TextLabel, thisBBTextInstance.BBC2TextInnerFrame, thisBBTextInstance.BBC2TextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENTS_OTHER_HELP_TEXT" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end
	ResizeEtc();
end;

CivilopediaCategory[CategoryAffinities].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_AFFINITIES_PAGE_LABEL" ));	
	
	local iconIndex;
	local iconAtlas;

	for row in DB.Query("SELECT IconIndex, IconAtlas from Affinity_Types ORDER By Random() LIMIT 1") do
		iconIndex = row.IconIndex;
		iconAtlas = row.IconAtlas;
	end	
	
	if IconHookup( iconIndex, portraitSize, iconAtlas, Controls.Portrait ) then
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.PortraitFrame:SetHide( true );
	end

	-- UpdateTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_AFFINITIES" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_AFFINITIES" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
			
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_AFFINITIES_HOMEPAGE_LABEL1" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_AFFINITIES_HOMEPAGE_TEXT1" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_AFFINITIES_HOMEPAGE_TEXT1" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryStations].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_STATIONS_PAGE_LABEL" ));	
	
	Controls.PortraitFrame:SetHide(true);
	
	-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_STATIONS_HOMEPAGE_BLURB" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateCentrQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_STATIONS_HOMEPAGE_BLURB" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
			
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_STATIONS_HOMEPAGE_LABEL1" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_STATIONS_HOMEPAGE_TEXT1" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_STATIONS_HOMEPAGE_TEXT1" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;

CivilopediaCategory[CategoryDiplomacy].DisplayHomePage = function()
	-- print("CivilopediaCategory[CategoryDiplomacy].DisplayHomePage"); -- dbg
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_DIPLOMACY_PAGE_LABEL" ));	
	
	-- PW. add a random icon
	local portraitIndex = 1;
	local portraitAtlas = "BW_ATLAS_1";
	local _mr = math.random(2);
	-- print("_mr = math.random(2) = "..tostring(_mr)); -- dbg
	
	if _mr == 1 then 
		for row in DB.Query("SELECT PortraitIndex, IconAtlas from ForeignPolicies ORDER By Random() LIMIT 1") do
			portraitIndex = row.PortraitIndex;
			portraitAtlas = row.IconAtlas;
		end	
		-- print("ForeignPolicies PortraitIndex - ".. tostring(portraitIndex)..", IconAtlas - "..tostring(portraitAtlas)); -- dbg
	else
		for row in DB.Query("SELECT PortraitIndex, IconAtlas from PersonalityTraits ORDER By Random() LIMIT 1") do
			portraitIndex = row.PortraitIndex;
			portraitAtlas = row.IconAtlas;
		end	
		-- print("PersonalityTraits PortraitIndex - ".. tostring(portraitIndex)..", IconAtlas - "..tostring(portraitAtlas)); -- dbg
	end
	
	if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait, true ) then
		Controls.PortraitFrame:SetHide( false );
		-- print("Controls.PortraitFrame:SetHide( false );"); -- dbg
	else
		Controls.PortraitFrame:SetHide( true );
		-- print("Controls.PortraitFrame:SetHide( true );"); -- dbg
	end


	-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_DIPLOMACY" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	UpdateRightQuoteBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_DIPLOMACY" ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
			
	--Basic Sectional Infos	
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_17_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_DIPLOMACY_HOMEPAGE_TEXT1" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_DIPLOMACY_HOMEPAGE_TEXT1" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	
	-- Diplomacy Homepage Text PW
	thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		-- thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_DATALINKS_HELP_LABEL" ));
		local dhtext = Locale.ConvertTextKey( "TXT_KEY_CONCEPT_PERSONALITY_TRAITS_HEADING2_BODY" ); 
		dhtext = dhtext.."[NEWLINE][NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_CONCEPT_CHARACTER_TRAITS_HEADING2_BODY" ); 
		dhtext = dhtext.."[NEWLINE][NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_CONCEPT_POLITICAL_TRAITS_HEADING2_BODY" ); 
		dhtext = dhtext.."[NEWLINE][NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_CONCEPT_DOMESTIC_TRAITS_HEADING2_BODY" ); 
		dhtext = dhtext.."[NEWLINE][NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_CONCEPT_MILITARY_TRAITS_HEADING2_BODY" ); 
		dhtext = dhtext.."[NEWLINE][NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_CONCEPT_AGREEMENTS_HEADING2_BODY" ); 
		dhtext = dhtext.."[NEWLINE][NEWLINE]"..Locale.ConvertTextKey( "TXT_KEY_PEDIA_DIPLOMACY_HOMEPAGE_TEXT2" ); 
		
		
		UpdateUsualSizeTextBlock( dhtext, thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	
	ResizeEtc();
end;

CivilopediaCategory[CategoryArtifacts].DisplayHomePage = function()
	ClearArticle();
	Controls.ArticleID:SetText( Locale.ToUpper( "TXT_KEY_PEDIA_ARTIFACTS_PAGE_LABEL" ));	

	-- PW. add a random icon
	local portrait1Index, portrait2Index, portrait3Index = 1,1,1;
	local portrait1Atlas, portrait2Atlas, portrait3Atlas = "BW_ATLAS_1","BW_ATLAS_1","BW_ATLAS_1";
	local art_category = math.random(4);
	
	local _i = 1; -- handle iterate
	if art_category == 1 then
		_i = 1
		for row in DB.Query("SELECT PortraitIndex, IconAtlas from Artifacts where Category = \"ARTIFACT_CATEGORY_OLD_EARTH\" ORDER By Random() LIMIT 3") do
			if _i == 1 then portrait1Index = row.PortraitIndex; portrait1Atlas = row.IconAtlas; end
			if _i == 2 then portrait2Index = row.PortraitIndex; portrait2Atlas = row.IconAtlas; end
			if _i == 3 then portrait3Index = row.PortraitIndex; portrait3Atlas = row.IconAtlas; end
			_i = _i +1;
		end
	elseif art_category == 2 then
		_i = 1
		for row in DB.Query("SELECT PortraitIndex, IconAtlas from Artifacts where Category = \"ARTIFACT_CATEGORY_ALIEN\" ORDER By Random() LIMIT 3") do
			if _i == 1 then portrait1Index = row.PortraitIndex; portrait1Atlas = row.IconAtlas; end
			if _i == 2 then portrait2Index = row.PortraitIndex; portrait2Atlas = row.IconAtlas; end
			if _i == 3 then portrait3Index = row.PortraitIndex; portrait3Atlas = row.IconAtlas; end
			_i = _i +1;
		end
	elseif art_category == 3 then
		_i = 1
		for row in DB.Query("SELECT PortraitIndex, IconAtlas from Artifacts where Category = \"ARTIFACT_CATEGORY_PROGENITOR\" ORDER By Random() LIMIT 3") do
			if _i == 1 then portrait1Index = row.PortraitIndex; portrait1Atlas = row.IconAtlas; end
			if _i == 2 then portrait2Index = row.PortraitIndex; portrait2Atlas = row.IconAtlas; end
			if _i == 3 then portrait3Index = row.PortraitIndex; portrait3Atlas = row.IconAtlas; end
			_i = _i +1;
		end
	elseif art_category == 4 then
		for row in DB.Query("SELECT PortraitIndex, IconAtlas from Artifacts where Category = \"ARTIFACT_CATEGORY_OLD_EARTH\" ORDER By Random() LIMIT 1") do
			portrait1Index = row.PortraitIndex;
			portrait1Atlas = row.IconAtlas;
		end
		for row in DB.Query("SELECT PortraitIndex, IconAtlas from Artifacts where Category = \"ARTIFACT_CATEGORY_ALIEN\" ORDER By Random() LIMIT 1") do
			portrait2Index = row.PortraitIndex;
			portrait2Atlas = row.IconAtlas;
		end
		for row in DB.Query("SELECT PortraitIndex, IconAtlas from Artifacts where Category = \"ARTIFACT_CATEGORY_PROGENITOR\" ORDER By Random() LIMIT 1") do
			portrait3Index = row.PortraitIndex;
			portrait3Atlas = row.IconAtlas;
		end
	end
	
	if IconHookup( portrait3Index, portraitSize, portrait3Atlas, Controls.Portrait5 ) then
		Controls.Portrait5:SetHide( false );
	else
		Controls.Portrait5:SetHide( true );
	end
	if IconHookup( portrait2Index, portraitSize, portrait2Atlas, Controls.Portrait4 ) then
		Controls.Portrait4:SetHide( false );
	else
		Controls.Portrait4:SetHide( true );
	end
	if IconHookup( portrait1Index, portraitSize, portrait1Atlas, Controls.Portrait3 ) then
		Controls.Portrait3:SetHide( false );
		Controls.PortraitFrame:SetHide( false );
	else
		Controls.Portrait3:SetHide( true );
		Controls.PortraitFrame:SetHide( true );
	end
	
	-- g_BBTextManager:DestroyInstances();		g_BBC2TextManager:DestroyInstances();
	ClearTextInstances();
	
	-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_ARTIFACTS" ), Controls.HomePageBlurbLabel, Controls.HomePageBlurbInnerFrame, Controls.HomePageBlurbFrame );
	-- Strange text w/o label
	local thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( "" );
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_ARTIFACTS" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_QUOTE_BLOCK_ARTIFACTS" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
			
	--Basic Sectional Infos	
	thisBBTextInstance = g_BBTextManager:GetInstance();
	if thisBBTextInstance then
		thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_18_LABEL" ));
		-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_ARTIFACTS_HOMEPAGE_TEXT1" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
		UpdateUsualSizeTextBlock( Locale.ConvertTextKey( "TXT_KEY_PEDIA_ARTIFACTS_HOMEPAGE_TEXT1" ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
	end	
	Controls.BBTextStack:SetHide( false );
	ResizeEtc();
end;


-- ===========================================================================
--	First page Index/TOC selects categories, much like buttons across the
--	top of the screen.
-- ===========================================================================
CivilopediaCategory[CategoryMain].SelectArticle = function( pageID, shouldAddToList )
	ClearArticle();	
	SetSelectedCategory( pageID, shouldAddToList );
	ResizeEtc();
end


-- ===========================================================================
--	Add a topic to the back/forward navigation history.
-- ===========================================================================
function AddToNavigationHistory( categoryIndex, itemID )
	m_historyCurrentIndex = m_historyCurrentIndex + 1;
	m_listOfTopicsViewed[m_historyCurrentIndex] = m_categorizedListOfArticles[(categoryIndex * MAX_ENTRIES_PER_CATEGORY) + itemID];
	for i = m_historyCurrentIndex + 1, m_endTopic, 1 do
		m_listOfTopicsViewed[i] = nil;
	end
	m_endTopic = m_historyCurrentIndex;
end

-- ===========================================================================
CivilopediaCategory[CategoryConcepts].SelectArticle = function( conceptID, shouldAddToList )
	print("CivilopediaCategory[CategoryConcepts].SelectArticle");
	if m_selectedCategory ~= CategoryConcepts then
		SetSelectedCategory(CategoryConcepts, dontAddToList );
	end
	
	ClearArticle();
	ClearTextInstances();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryConcepts, conceptID );
	end
	
	if conceptID ~= -1 then
		local thisConcept = GameInfo.Concepts[conceptID];
		
		if thisConcept then
		
			-- update the name
			local name = Locale.ToUpper( thisConcept.Description ); 	
			Controls.ArticleID:SetText( name );
			
			-- portrait
			
			-- update the summary
			if thisConcept.Summary then
				-- if thisConcept.CivilopediaHeaderType == "HEADER_ECOLOGY" then
					-- UpdateSuperWideTextBlock( Locale.ConvertTextKey( thisConcept.Summary ), Controls.SummaryC2Label, Controls.SummaryC2InnerFrame, Controls.SummaryC2Frame );
				-- else
					UpdateSuperWideTextBlock( Locale.ConvertTextKey( thisConcept.Summary ), Controls.SummaryLabel, Controls.SummaryInnerFrame, Controls.SummaryFrame );
				-- end
			end

			
			-- add cycle to add stages
			local tagString = false;

			if name == Locale.ToUpper( "TXT_KEY_ECOLOGY_SOA_DESC" ) then tagString = "TXT_KEY_AWAKENING_STAGE"; end;
			if tagString then
				local headerString = tagString .. "_HEADING_";
				local bodyString = tagString .. "_TEXT_";
				local notFound = false;
				local i = 1;
				local pdb_aas = DatalinksDB.GetValue("AlienAwakeningStage") or 0;
				repeat
					local headerTag = headerString .. tostring( i );
					local bodyTag = bodyString .. tostring( i );
					if TagExists( headerTag ) and TagExists( bodyTag ) then
						-- check the Profile DB to reach this info
						if i <= pdb_aas then						
							local thisBBTextInstance = g_BBTextManager:GetInstance()
							if thisBBTextInstance then
								thisBBTextInstance.BBTextHeader:SetText( Locale.ConvertTextKey( headerTag ));
								UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
							end
							-- adjust y position to fit first summary block
							if i == 1 then
								local adjY = Controls.SummaryFrame:GetSizeY();
								-- print("adjY = "..tostring(adjY));
								thisBBTextInstance.BBTextFrame:SetOffsetY(adjY-125);
							end
						end
					else
						notFound = true;
					end
					i = i + 1;
				until notFound;
				Controls.BBTextStack:SetHide( false );
			end
			tagString = false;


			-- add output of database of HealthLevels
			if name == Locale.ToUpper( "TXT_KEY_HEALTH_LEVELSUNHEALTH_HEADING2_TITLE" ) then tagString = true; end;
			if tagString then
				local headerTag, bodyTag = "", "";
				local UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;

				-- Combat Power
				headerTag, bodyTag = "", "";
				UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;
				headerTag = Locale.ConvertTextKey( "TXT_KEY_COMBAT_POWER" ) ..":"
				for info in GameInfo.HealthLevels() do
					local HealthLevelType = info.Type;
					local CombatMod = info.CombatModifier;
					local HealthStart = info.HealthStart;
					local HealthEnd = info.HealthEnd;
					if (CombatMod ~= nil) and (CombatMod ~= 0) then
						-- correct and nice picture for negatives
						--UpToModPP = (math.abs(HealthEnd) - math.abs(HealthStart)) * CombatMod;
						-- positive add to top
						if CombatMod > 0 then
							TotalModPositive = TotalModPositive + CombatMod
							bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_COMBAT_POWER_S", HealthStart, CombatMod, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
						else
							TotalModNegative = TotalModNegative + CombatMod
							if HealthLevelType == "HEALTH_LEVEL_COMBAT_PENAL_5" then
								bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_COMBAT_POWER_S", HealthStart, CombatMod, TotalModNegative) .. "[ENDCOLOR]";
							else
								bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_COMBAT_POWER_S", HealthStart, CombatMod, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
							end
						end
					end
				end
				if ( headerTag ~= "" ) and ( bodyTag ~= "" ) then
					local thisBBTextInstance = g_BBTextManager:GetInstance();
					if thisBBTextInstance then
						thisBBTextInstance.BBTextHeader:SetText( headerTag );
						UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
						-- adjust y position to fit first summary block
						local adjY = Controls.SummaryFrame:GetSizeY();
						-- print("adjY = "..tostring(adjY));
						thisBBTextInstance.BBTextFrame:SetOffsetY(adjY-125);
					end
				end

				-- Intrigue
				headerTag, bodyTag = "", "";
				UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;
				headerTag = Locale.ConvertTextKey( "TXT_KEY_INTRIGUE_IN_BASES" ) ..":"
				for info in GameInfo.HealthLevels() do
					local HealthLevelType = info.Type;
					local CityIntrigueModPP = info.CityIntrigueModifierPerPoint;
					local HealthStart = info.HealthStart;
					local HealthEnd = info.HealthEnd;
					if (CityIntrigueModPP ~= nil) and (CityIntrigueModPP ~= 0) then
						-- correct and nice picture for negatives
						UpToModPP = (math.abs(HealthEnd) - math.abs(HealthStart)) * CityIntrigueModPP;
						-- positive add to top
						if UpToModPP < 0 then
							TotalModPositive = TotalModPositive + UpToModPP
							bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INTRIGUE_IN_BASES", HealthStart, HealthEnd, CityIntrigueModPP, UpToModPP, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
						else
							TotalModNegative = TotalModNegative + UpToModPP
							if HealthLevelType == "HEALTH_LEVEL_INTRIGUE_PENAL_3" then
								bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INTRIGUE_IN_BASES", HealthStart, HealthEnd, CityIntrigueModPP, UpToModPP, TotalModNegative) .. "[ENDCOLOR]";
							else
								bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INTRIGUE_IN_BASES", HealthStart, HealthEnd, CityIntrigueModPP, UpToModPP, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
							end
						end
					end
				end
				if ( headerTag ~= "" ) and ( bodyTag ~= "" ) then
					local thisBBTextInstance = g_BBTextManager:GetInstance();
					if thisBBTextInstance then
						thisBBTextInstance.BBTextHeader:SetText( headerTag );
						UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
					end
				end

				-- Outpost Growth
				headerTag, bodyTag = "", "";
				UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;
				headerTag = Locale.ConvertTextKey( "TXT_KEY_GROWTH_IN_OUTPOST" ) ..":"
				for info in GameInfo.HealthLevels() do
					local HealthLevelType = info.Type;
					local OutpostGrowthModPP = info.OutpostGrowthModifierPerPoint;
					local HealthStart = info.HealthStart;
					local HealthEnd = info.HealthEnd;
					if (OutpostGrowthModPP ~= nil) and (OutpostGrowthModPP ~= 0) then
						-- correct and nice picture for negatives
						UpToModPP = (math.abs(HealthEnd) - math.abs(HealthStart)) * OutpostGrowthModPP;
						-- positive add to top
						if UpToModPP > 0 then
							TotalModPositive = TotalModPositive + UpToModPP
							bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_OUTPOST_GROWTH", HealthStart, HealthEnd, OutpostGrowthModPP, UpToModPP, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
						else
							TotalModNegative = TotalModNegative + UpToModPP
							if HealthLevelType == "HEALTH_LEVEL_OUTPOST_GROWTH_PENAL_3" then
								bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_OUTPOST_GROWTH", HealthStart, HealthEnd, OutpostGrowthModPP, UpToModPP, TotalModNegative) .. "[ENDCOLOR]";
							else
								bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_OUTPOST_GROWTH", HealthStart, HealthEnd, OutpostGrowthModPP, UpToModPP, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
							end
						end
					end
				end
				if ( headerTag ~= "" ) and ( bodyTag ~= "" ) then
					local thisBBTextInstance = g_BBTextManager:GetInstance();
					if thisBBTextInstance then
						thisBBTextInstance.BBTextHeader:SetText( headerTag );
						UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
					end
				end

				-- Base Growth
				headerTag, bodyTag = "", "";
				UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;
				headerTag = Locale.ConvertTextKey( "TXT_KEY_GROWTH_IN_BASES" ) ..":"
				for info in GameInfo.HealthLevels() do
					local HealthLevelType = info.Type;
					local cityGrowthModPP = info.CityGrowthModifierPerPoint;
					local HealthStart = info.HealthStart;
					local HealthEnd = info.HealthEnd;
					if (cityGrowthModPP ~= nil) and (cityGrowthModPP ~= 0) then
						-- correct and nice picture for negatives
						--if HealthStart < 0 then HealthStart = HealthStart + 1 end
						UpToModPP = (math.abs(HealthEnd) - math.abs(HealthStart)) * cityGrowthModPP;
						-- positive add to top
						if UpToModPP > 0 then
							TotalModPositive = TotalModPositive + UpToModPP
							bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_BASE_GROWTH", HealthStart, HealthEnd, cityGrowthModPP, UpToModPP, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
						else
							TotalModNegative = TotalModNegative + UpToModPP
							if HealthLevelType == "HEALTH_LEVEL_BASE_GROWTH_PENAL_5" then
								bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_BASE_GROWTH", HealthStart, HealthEnd, cityGrowthModPP, UpToModPP, TotalModNegative) .. "[ENDCOLOR]";
							else
								bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_BASE_GROWTH", HealthStart, HealthEnd, cityGrowthModPP, UpToModPP, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
							end
						end
					end
				end
				if ( headerTag ~= "" ) and ( bodyTag ~= "" ) then
					local thisBBTextInstance = g_BBTextManager:GetInstance();
					if thisBBTextInstance then
						thisBBTextInstance.BBTextHeader:SetText( headerTag );
						UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
					end
				end

				-- Base Minerals Production
				headerTag, bodyTag = "", "";
				UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;
				headerTag = Locale.ConvertTextKey( "TXT_KEY_MINERALS_PRODUCTION_IN_BASES" ) ..":"
				local condition = "YieldType = 'YIELD_PRODUCTION'";
				for infoYPP in GameInfo.HealthLevels_CityYieldModifiersPerPoint( condition ) do
					local HealthLevelType = infoYPP.HealthLevelType
					local YPPamount = infoYPP.Yield
					for info in GameInfo.HealthLevels( "Type = '"..HealthLevelType.."'" ) do
						--local HealthLevelType = info.Type;
						--local cityGrowthModPP = info.CityGrowthModifierPerPoint;
						local HealthStart = info.HealthStart;
						local HealthEnd = info.HealthEnd;
						if (YPPamount ~= nil) and (YPPamount ~= 0) then
							-- correct and nice picture for negatives
							--if HealthStart < 0 then HealthStart = HealthStart + 1 end
							UpToModPP = (math.abs(HealthEnd) - math.abs(HealthStart)) * YPPamount;
							-- positive add to top
							if UpToModPP > 0 then
								TotalModPositive = TotalModPositive + UpToModPP
								bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_MINERALS_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
							else
								TotalModNegative = TotalModNegative + UpToModPP
								if HealthLevelType == "HEALTH_LEVEL_BASE_MINERALS_PENAL_5" then
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_MINERALS_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModNegative) .. "[ENDCOLOR]";
								else
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_MINERALS_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
								end
							end
						end
					end
				end
				for infoYPP in GameInfo.HealthLevels_CityYieldModifiers( condition ) do
					local HealthLevelType = infoYPP.HealthLevelType
					local YPPamount = infoYPP.Yield
					for info in GameInfo.HealthLevels( "Type = '"..HealthLevelType.."'" ) do
						local HealthStart = info.HealthStart;
						local HealthEnd = info.HealthEnd;
						if (YPPamount ~= nil) and (YPPamount ~= 0) then
							-- positive add to top
							if YPPamount > 0 then
								TotalModPositive = TotalModPositive + YPPamount
								bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_MINERALS_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
							else
								TotalModNegative = TotalModNegative + YPPamount
								if HealthLevelType == "HEALTH_LEVEL_BASE_MINERALS_PENAL_5" then
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_MINERALS_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModNegative) .. "[ENDCOLOR]";
								else
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_MINERALS_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
								end
							end
						end
					end
				end
				if ( headerTag ~= "" ) and ( bodyTag ~= "" ) then
					local thisBBTextInstance = g_BBTextManager:GetInstance();
					if thisBBTextInstance then
						thisBBTextInstance.BBTextHeader:SetText( headerTag );
						UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
					end
				end

				-- Base Science Production
				headerTag, bodyTag = "", "";
				UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;
				headerTag = Locale.ConvertTextKey( "TXT_KEY_SCIENCE_PRODUCTION_IN_BASES" ) ..":"
				local condition = "YieldType = 'YIELD_SCIENCE'";
				for infoYPP in GameInfo.HealthLevels_CityYieldModifiersPerPoint( condition ) do
					local HealthLevelType = infoYPP.HealthLevelType
					local YPPamount = infoYPP.Yield
					for info in GameInfo.HealthLevels( "Type = '"..HealthLevelType.."'" ) do
						local HealthStart = info.HealthStart;
						local HealthEnd = info.HealthEnd;
						if (YPPamount ~= nil) and (YPPamount ~= 0) then
							-- correct and nice picture for negatives
							UpToModPP = (math.abs(HealthEnd) - math.abs(HealthStart)) * YPPamount;
							-- positive add to top
							if UpToModPP > 0 then
								TotalModPositive = TotalModPositive + UpToModPP
								bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_SCIENCE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
							else
								TotalModNegative = TotalModNegative + UpToModPP
								if HealthLevelType == "HEALTH_LEVEL_BASE_SCIENCE_PENAL_6" then
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_SCIENCE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModNegative) .. "[ENDCOLOR]";
								else
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_SCIENCE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
								end
							end
						end
					end
				end
				for infoYPP in GameInfo.HealthLevels_CityYieldModifiers( condition ) do
					local HealthLevelType = infoYPP.HealthLevelType
					local YPPamount = infoYPP.Yield
					for info in GameInfo.HealthLevels( "Type = '"..HealthLevelType.."'" ) do
						local HealthStart = info.HealthStart;
						local HealthEnd = info.HealthEnd;
						if (YPPamount ~= nil) and (YPPamount ~= 0) then
							-- positive add to top
							if YPPamount > 0 then
								TotalModPositive = TotalModPositive + YPPamount
								bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_SCIENCE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
							else
								TotalModNegative = TotalModNegative + YPPamount
								if HealthLevelType == "HEALTH_LEVEL_BASE_SCIENCE_PENAL_6" then
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_SCIENCE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModNegative) .. "[ENDCOLOR]";
								else
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_SCIENCE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
								end
							end
						end
					end
				end
				if ( headerTag ~= "" ) and ( bodyTag ~= "" ) then
					local thisBBTextInstance = g_BBTextManager:GetInstance();
					if thisBBTextInstance then
						thisBBTextInstance.BBTextHeader:SetText( headerTag );
						UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
					end
				end

				-- Base Culture Production
				headerTag, bodyTag = "", "";
				UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;
				headerTag = Locale.ConvertTextKey( "TXT_KEY_CULTURE_PRODUCTION_IN_BASES" ) ..":"
				local condition = "YieldType = 'YIELD_CULTURE'";
				for infoYPP in GameInfo.HealthLevels_CityYieldModifiersPerPoint( condition ) do
					local HealthLevelType = infoYPP.HealthLevelType
					local YPPamount = infoYPP.Yield
					for info in GameInfo.HealthLevels( "Type = '"..HealthLevelType.."'" ) do
						local HealthStart = info.HealthStart;
						local HealthEnd = info.HealthEnd;
						if (YPPamount ~= nil) and (YPPamount ~= 0) then
							-- correct and nice picture for negatives
							UpToModPP = (math.abs(HealthEnd) - math.abs(HealthStart)) * YPPamount;
							-- positive add to top
							if UpToModPP > 0 then
								TotalModPositive = TotalModPositive + UpToModPP
								bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_CULTURE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
							else
								TotalModNegative = TotalModNegative + UpToModPP
								if HealthLevelType == "HEALTH_LEVEL_BASE_CULTURE_PENAL_3" then
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_CULTURE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModNegative) .. "[ENDCOLOR]";
								else
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_CULTURE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
								end
							end
						end
					end
				end
				for infoYPP in GameInfo.HealthLevels_CityYieldModifiers( condition ) do
					local HealthLevelType = infoYPP.HealthLevelType
					local YPPamount = infoYPP.Yield
					for info in GameInfo.HealthLevels( "Type = '"..HealthLevelType.."'" ) do
						local HealthStart = info.HealthStart;
						local HealthEnd = info.HealthEnd;
						if (YPPamount ~= nil) and (YPPamount ~= 0) then
							-- positive add to top
							if YPPamount > 0 then
								TotalModPositive = TotalModPositive + YPPamount
								bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_CULTURE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
							else
								TotalModNegative = TotalModNegative + YPPamount
								if HealthLevelType == "HEALTH_LEVEL_BASE_CULTURE_PENAL_3" then
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_CULTURE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModNegative) .. "[ENDCOLOR]";
								else
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_CULTURE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
								end
							end
						end
					end
				end
				if ( headerTag ~= "" ) and ( bodyTag ~= "" ) then
					local thisBBTextInstance = g_BBTextManager:GetInstance();
					if thisBBTextInstance then
						thisBBTextInstance.BBTextHeader:SetText( headerTag );
						UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
					end
				end

				-- Base Influence Production
				headerTag, bodyTag = "", "";
				UpToModPP, TotalModPositive, TotalModNegative = 0,0,0;
				headerTag = Locale.ConvertTextKey( "TXT_KEY_INFLUENCE_PRODUCTION_IN_BASES" ) ..":"
				local condition = "YieldType = 'YIELD_CAPITAL'";
				for infoYPP in GameInfo.HealthLevels_CityYieldModifiersPerPoint( condition ) do
					local HealthLevelType = infoYPP.HealthLevelType
					local YPPamount = infoYPP.Yield
					for info in GameInfo.HealthLevels( "Type = '"..HealthLevelType.."'" ) do
						local HealthStart = info.HealthStart;
						local HealthEnd = info.HealthEnd;
						if (YPPamount ~= nil) and (YPPamount ~= 0) then
							-- correct and nice picture for negatives
							UpToModPP = (math.abs(HealthEnd) - math.abs(HealthStart)) * YPPamount;
							-- positive add to top
							if UpToModPP > 0 then
								TotalModPositive = TotalModPositive + UpToModPP
								bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INFLUENCE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
							else
								TotalModNegative = TotalModNegative + UpToModPP
								if HealthLevelType == "HEALTH_LEVEL_BASE_INFLUENCE_PENAL_3" then
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INFLUENCE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModNegative) .. "[ENDCOLOR]";
								else
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INFLUENCE_PRODUCTION_IN_BASES", HealthStart, HealthEnd, YPPamount, UpToModPP, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
								end
							end
						end
					end
				end
				for infoYPP in GameInfo.HealthLevels_CityYieldModifiers( condition ) do
					local HealthLevelType = infoYPP.HealthLevelType
					local YPPamount = infoYPP.Yield
					for info in GameInfo.HealthLevels( "Type = '"..HealthLevelType.."'" ) do
						local HealthStart = info.HealthStart;
						local HealthEnd = info.HealthEnd;
						if (YPPamount ~= nil) and (YPPamount ~= 0) then
							-- positive add to top
							if YPPamount > 0 then
								TotalModPositive = TotalModPositive + YPPamount
								bodyTag = "[ICON_BULLET][COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INFLUENCE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModPositive) .. "[ENDCOLOR][NEWLINE]" .. bodyTag;
							else
								TotalModNegative = TotalModNegative + YPPamount
								if HealthLevelType == "HEALTH_LEVEL_BASE_INFLUENCE_PENAL_3" then
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INFLUENCE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModNegative) .. "[ENDCOLOR]";
								else
									bodyTag = bodyTag .. "[ICON_BULLET][COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_HEALTH_LEVEL_EFFECT_DATABASE_INFLUENCE_PRODUCTION_IN_BASES_S", HealthStart, YPPamount, TotalModNegative) .. "[ENDCOLOR][NEWLINE]";
								end
							end
						end
					end
				end
				if ( headerTag ~= "" ) and ( bodyTag ~= "" ) then
					local thisBBTextInstance = g_BBTextManager:GetInstance();
					if thisBBTextInstance then
						thisBBTextInstance.BBTextHeader:SetText( headerTag );
						UpdateUsualSizeTextBlock( Locale.ConvertTextKey( bodyTag ), thisBBTextInstance.BBTextLabel, thisBBTextInstance.BBTextInnerFrame, thisBBTextInstance.BBTextFrame );
					end
				end

				-- show stack when all set
				Controls.BBTextStack:SetHide( false );
			end
			tagString = false;

			-- related images
			
			-- related concepts		
		end

	end	

	ResizeEtc();
end

-- ===========================================================================
CivilopediaCategory[CategoryTech].SelectArticle = function( techID, shouldAddToList )
	print("CivilopediaCategory[CategoryTech].SelectArticle");

	if m_selectedCategory ~= CategoryTech then
		SetSelectedCategory(CategoryTech, dontAddToList );
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryTech, techID );
	end
	
	if techID ~= -1 then
		local thisTech = GameInfo.Technologies[techID];
					
		local name = Locale.ToUpper( thisTech.Description ); 	
		Controls.ArticleID:SetText( name );

		-- if we have one, update the tech picture
		if IconHookup( thisTech.PortraitIndex, portraitSize, thisTech.IconAtlas, Controls.Portrait ) then
			Controls.PortraitFrame:SetHide( false );
		else
			Controls.PortraitFrame:SetHide( true );
		end
		
		-- update the cost
		Controls.CostFrame:SetHide( false );

		local cost = thisTech.Cost;
		if(Game ~= nil) then
			local pPlayer = Players[Game.GetActivePlayer()];
			local pTeam = Teams[pPlayer:GetTeam()];
			local pTeamTechs = pTeam:GetTeamTechs();
			cost = pTeamTechs:GetResearchCost(techID);		
		end

		if (cost > 0) then
			Controls.CostLabel:SetText( tostring(cost).." [ICON_RESEARCH]" );
		else
			Controls.CostLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_FREE" ) );
		end
		
 		local contentSize;
 		local frameSize = {};
		local buttonAdded = 0;

		local techType = thisTech.Type;
		local condition = "TechType = '" .. techType .. "'";
		local prereqCondition = "PrereqTech = '" .. techType .. "'";
		local otherPrereqCondition = "TechPrereq = '" .. techType .. "'";
		local revealCondition = "TechReveal = '" .. techType .. "'";

		-- update the prereq techs
		g_PrereqTechManager:DestroyInstances();
		buttonAdded = 0;
		for row in GameInfo.Technology_PrereqTechs( condition ) do
			local prereq = GameInfo.Technologies[row.PrereqTech];
			local thisPrereqInstance = g_PrereqTechManager:GetInstance();
			if thisPrereqInstance then
				local textureOffset, textureSheet = IconLookup( prereq.PortraitIndex, buttonSize, prereq.IconAtlas );				
				if textureOffset == nil then
					textureSheet = defaultErrorTextureSheet;
					textureOffset = nullOffset;
				end				
				UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqTechImage, thisPrereqInstance.PrereqTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereq.Description ), prereq.ID );
				buttonAdded = buttonAdded + 1;
			end			
		end
		UpdateButtonFrame( buttonAdded, Controls.PrereqTechInnerFrame, Controls.PrereqTechFrame );

		-- update the leads to techs
		g_LeadsToTechManager:DestroyInstances();
		buttonAdded = 0;
		for row in GameInfo.Technology_PrereqTechs( prereqCondition ) do
			local leadsTo = GameInfo.Technologies[row.TechType];
			local thisLeadsToInstance = g_LeadsToTechManager:GetInstance();
			if thisLeadsToInstance then
				local textureOffset, textureSheet = IconLookup( leadsTo.PortraitIndex, buttonSize, leadsTo.IconAtlas );				
				if textureOffset == nil then
					textureSheet = defaultErrorTextureSheet;
					textureOffset = nullOffset;
				end				
				UpdateSmallButton( buttonAdded, thisLeadsToInstance.LeadsToTechImage, thisLeadsToInstance.LeadsToTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( leadsTo.Description ), leadsTo.ID );
				buttonAdded = buttonAdded + 1;
			end			
		end
		-- update the units unlocked
		g_UnlockedUnitsManager:DestroyInstances();
		buttonAdded = 0;
		for thisUnitInfo in GameInfo.Units( prereqCondition ) do
			if thisUnitInfo.ShowInPedia then
				local thisUnitInstance = g_UnlockedUnitsManager:GetInstance();
				if thisUnitInstance then		
					local portraitIndex, iconAtlas  = UI.GetUnitPortraitIcon( thisUnitInfo.ID );
					local textureOffset, textureSheet = IconLookup( portraitIndex, buttonSize, iconAtlas );	
					UpdateSmallButton( buttonAdded, thisUnitInstance.UnlockedUnitImage, thisUnitInstance.UnlockedUnitButton, textureSheet, textureOffset, CategoryUnits, Locale.ConvertTextKey( thisUnitInfo.Description ), thisUnitInfo.ID );
					buttonAdded = buttonAdded + 1;
				end
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.UnlockedUnitsInnerFrame, Controls.UnlockedUnitsFrame );
		
		-- update the buildings unlocked
		g_UnlockedBuildingsManager:DestroyInstances();
		buttonAdded = 0;
		for thisBuildingInfo in GameInfo.Buildings( prereqCondition ) do
			local thisBuildingInstance = g_UnlockedBuildingsManager:GetInstance();
			if thisBuildingInstance then

				if not IconHookup( thisBuildingInfo.PortraitIndex, buttonSize, thisBuildingInfo.IconAtlas, thisBuildingInstance.UnlockedBuildingImage ) then
					thisBuildingInstance.UnlockedBuildingImage:SetTexture( defaultErrorTextureSheet );
					thisBuildingInstance.UnlockedBuildingImage:SetTextureOffset( nullOffset );
				end

				--move this button
				thisBuildingInstance.UnlockedBuildingButton:SetOffsetVal( (buttonAdded % numberOfButtonsPerRow) * buttonSize + buttonPadding, math.floor(buttonAdded / numberOfButtonsPerRow) * buttonSize + buttonPadding );
				
				thisBuildingInstance.UnlockedBuildingButton:SetToolTipString( Locale.ConvertTextKey( thisBuildingInfo.Description ) );
				thisBuildingInstance.UnlockedBuildingButton:SetVoids( thisBuildingInfo.ID, addToList );
				local thisBuildingClass = GameInfo.BuildingClasses[thisBuildingInfo.BuildingClass];
				if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and thisBuildingInfo.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
					thisBuildingInstance.UnlockedBuildingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].SelectArticle );
				else
					thisBuildingInstance.UnlockedBuildingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryBuildings].SelectArticle );
				end
				buttonAdded = buttonAdded + 1;
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.UnlockedBuildingsInnerFrame, Controls.UnlockedBuildingsFrame );
		
		-- update the projects unlocked
		g_UnlockedProjectsManager:DestroyInstances();
		buttonAdded = 0;
		for thisProjectInfo in GameInfo.Projects( otherPrereqCondition ) do
		
			local bIgnore = projectsToIgnore[thisProjectInfo.Type];
			if(bIgnore ~= true) then
				local thisProjectInstance = g_UnlockedProjectsManager:GetInstance();
				if thisProjectInstance then
					local textureOffset, textureSheet = IconLookup( thisProjectInfo.PortraitIndex, buttonSize, thisProjectInfo.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisProjectInstance.UnlockedProjectImage, thisProjectInstance.UnlockedProjectButton, textureSheet, textureOffset, CategoryWonders, Locale.ConvertTextKey( thisProjectInfo.Description ), thisProjectInfo.ID + 1000);
					buttonAdded = buttonAdded + 1;
				end
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.UnlockedProjectsInnerFrame, Controls.UnlockedProjectsFrame );
		
		-- update the resources revealed
		g_RevealedResourcesManager:DestroyInstances();
		buttonAdded = 0;
		for revealedResource in GameInfo.Resources( revealCondition ) do
			local thisRevealedResourceInstance = g_RevealedResourcesManager:GetInstance();
			if thisRevealedResourceInstance then
				local textureOffset, textureSheet = IconLookup( revealedResource.PortraitIndex, buttonSize, revealedResource.IconAtlas );				
				if textureOffset == nil then
					textureSheet = defaultErrorTextureSheet;
					textureOffset = nullOffset;
				end				
				UpdateSmallButton( buttonAdded, thisRevealedResourceInstance.RevealedResourceImage, thisRevealedResourceInstance.RevealedResourceButton, textureSheet, textureOffset, CategoryResources, Locale.ConvertTextKey( revealedResource.Description ), revealedResource.ID );
				buttonAdded = buttonAdded + 1;
			end			
		end
		UpdateButtonFrame( buttonAdded, Controls.RevealedResourcesInnerFrame, Controls.RevealedResourcesFrame );

		-- update the build actions unlocked
		g_WorkerActionsManager:DestroyInstances();
		buttonAdded = 0;
		for thisBuildInfo in GameInfo.Builds( prereqCondition ) do
			local thisWorkerActionInstance = g_WorkerActionsManager:GetInstance();
			if thisWorkerActionInstance then
				local textureOffset, textureSheet = IconLookup( thisBuildInfo.IconIndex, buttonSize, thisBuildInfo.IconAtlas );				
				if textureOffset == nil then
					textureSheet = defaultErrorTextureSheet;
					textureOffset = nullOffset;
				end
				if thisBuildInfo.RouteType then
					UpdateSmallButton( buttonAdded, thisWorkerActionInstance.WorkerActionImage, thisWorkerActionInstance.WorkerActionButton, textureSheet, textureOffset, CategoryImprovements, Locale.ConvertTextKey( thisBuildInfo.Description ), GameInfo.Routes[thisBuildInfo.RouteType].ID + 3000 );
				elseif thisBuildInfo.ImprovementType then
					UpdateSmallButton( buttonAdded, thisWorkerActionInstance.WorkerActionImage, thisWorkerActionInstance.WorkerActionButton, textureSheet, textureOffset, CategoryImprovements, Locale.ConvertTextKey( thisBuildInfo.Description ), GameInfo.Improvements[thisBuildInfo.ImprovementType].ID );-- add fudge factor
				else -- we are a choppy thing
					UpdateSmallButton( buttonAdded, thisWorkerActionInstance.WorkerActionImage, thisWorkerActionInstance.WorkerActionButton, textureSheet, textureOffset, CategoryConcepts, Locale.ConvertTextKey( thisBuildInfo.Description ), GameInfo.Concepts["CONCEPT_WORKERS_CLEARINGLAND"].ID );-- add fudge factor
				end
				buttonAdded = buttonAdded + 1;
			end			
		end
		UpdateButtonFrame( buttonAdded, Controls.WorkerActionsInnerFrame, Controls.WorkerActionsFrame );

		-- Helper to get the Civiloepedia concept for an affinity.
		local GetConceptAffinity = function(affinityType)
			-- Check if there's a security project with this concept type
			for row in GameInfo.Affinity_Types{Type = affinityType} do
				return GameInfo.Concepts[ row.CivilopediaConcept ];
			end
			return nil;
		end

		-- Affinities Gained
		g_AffinitiesGainedManager:DestroyInstances();
		buttonAdded = 0;
		for row in GameInfo.Technology_Affinities( condition ) do
			local affinityInfo = GameInfo.Affinity_Types[row.AffinityType];
			if affinityInfo then
				local thisAffinityInstance = g_AffinitiesGainedManager:GetInstance();
				if thisAffinityInstance then
					local textureOffset, textureSheet = IconLookup( affinityInfo.IconIndex, buttonSize, affinityInfo.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisAffinityInstance.AffinityImage, thisAffinityInstance.AffinityButton, textureSheet, textureOffset, CategoryAffinities, Locale.ConvertTextKey( affinityInfo.Description ), GetConceptAffinity(row.AffinityType).ID );
					buttonAdded = buttonAdded + 1;
				end
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.AffinitiesGainedInnerFrame, Controls.AffinitiesGainedFrame );

		-- update the related articles
		Controls.RelatedArticlesFrame:SetHide( true ); -- todo: figure out how this should be implemented

		-- update the game info
		if (thisTech.Help) then
			UpdateTextBlock( Locale.ConvertTextKey( thisTech.Help ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
		end

		-- update the quote
		if thisTech.Quote then
			-- UpdateTextBlock( Locale.ConvertTextKey( thisTech.Quote ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
			UpdateRightQuoteBlock( Locale.ConvertTextKey( thisTech.Quote ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
		end

		--Controls.QuoteLabel:SetText( Locale.ConvertTextKey( thisTech.Quote ) );
		--contentSize = Controls.QuoteLabel:GetSize();
		--frameSize.x = wideInnerFrameWidth;
		--frameSize.y = contentSize.y + textPaddingFromInnerFrame + quoteButtonOffset;
		--Controls.QuoteInnerFrame:SetSize( frameSize );
		--frameSize.x = wideOuterFrameWidth;
		--frameSize.y = contentSize.y + textPaddingFromInnerFrame - offsetsBetweenFrames + quoteButtonOffset;
		--Controls.QuoteFrame:SetSize( frameSize );
		--Controls.QuoteFrame:SetHide( false );

		-- update the special abilites
		local abilitiesString = "";
		local numAbilities = 0;
		for row in GameInfo.Route_TechMovementChanges( condition ) do
			if numAbilities > 0 then
				 abilitiesString = abilitiesString .. "[NEWLINE]";
			end
			abilitiesString = abilitiesString .. Locale.ConvertTextKey("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_MOVEMENT", GameInfo.Routes[row.RouteType].Description);
			numAbilities = numAbilities + 1;
		end	
	
		for row in GameInfo.Improvement_TechYieldChanges( condition ) do
			if numAbilities > 0 then
				 abilitiesString = abilitiesString .. "[NEWLINE]";
			end
			abilitiesString = abilitiesString .. Locale.ConvertTextKey("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_YIELDCHANGES", GameInfo.Improvements[row.ImprovementType].Description, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, row.Yield);
			numAbilities = numAbilities + 1;
		end	

		for row in GameInfo.Improvement_TechNoFreshWaterYieldChanges( condition ) do
			if numAbilities > 0 then
				 abilitiesString = abilitiesString .. "[NEWLINE]";
			end
			
			abilitiesString = abilitiesString .. Locale.ConvertTextKey("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_NOFRESHWATERYIELDCHANGES", GameInfo.Improvements[row.ImprovementType].Description, GameInfo.Yields[row.YieldType].Description, row.Yield );
			numAbilities = numAbilities + 1;
		end	

		for row in GameInfo.Improvement_TechFreshWaterYieldChanges( condition ) do
			if numAbilities > 0 then
				 abilitiesString = abilitiesString .. "[NEWLINE]";
			end
			abilitiesString = abilitiesString .. Locale.ConvertTextKey("TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_FRESHWATERYIELDCHANGES", GameInfo.Improvements[row.ImprovementType].Description, GameInfo.Yields[row.YieldType].Description, row.Yield );
			numAbilities = numAbilities + 1;
		end	

		if thisTech.EmbarkedMoveChange > 0 then
			if numAbilities > 0 then
				 abilitiesString = abilitiesString .. "[NEWLINE]";
			end
			abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_FAST_EMBARK_STRING" );
			numAbilities = numAbilities + 1;
		end
		
		--if thisTech.BridgeBuilding then
			--if numAbilities > 0 then
				 --abilitiesString = abilitiesString .. "[NEWLINE]";
			--end
			--abilitiesString = abilitiesString .. Locale.ConvertTextKey( "TXT_KEY_ABLTY_BRIDGE_STRING" );
			--numAbilities = numAbilities + 1;
		--end

		if numAbilities > 0 then
			UpdateTextBlock( Locale.ConvertTextKey( abilitiesString ), Controls.AbilitiesLabel, Controls.AbilitiesInnerFrame, Controls.AbilitiesFrame );
		else
			Controls.AbilitiesFrame:SetHide( true );			
		end
		
		-- update the historical info
		if (thisTech.Civilopedia) then
			UpdateTextBlock( Locale.ConvertTextKey( thisTech.Civilopedia ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
		end
		
		-- update the related images
		Controls.RelatedImagesFrame:SetHide( true );
		
		---- Improves Yield PW
		g_TerrainsManager:DestroyInstances();
		buttonAdded = 0;
		local canceldouble;
		for row in GameInfo.Feature_TechYieldChanges( condition ) do
			if row.Yield ~= 0 then
				local thisFeature = GameInfo.Features[row.FeatureType];
				if thisFeature.ID ~= canceldouble and thisFeature then 
					local thisFeatureInstance = g_TerrainsManager:GetInstance();
					if thisFeatureInstance then
					
						local textureOffset, textureSheet = IconLookup( thisFeature.PortraitIndex, buttonSize, thisFeature.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end				
						
						UpdateSmallButton( buttonAdded, thisFeatureInstance.TerrainImage, thisFeatureInstance.TerrainButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisFeature.Description ), thisFeature.ID + 1000 );
						
						buttonAdded = buttonAdded + 1;	
						canceldouble = thisFeature.ID	
					end
				end
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.TerrainsInnerFrame, Controls.TerrainsFrame );
		---- Improves Yield PW
		
	end
	
	ResizeEtc();

end

CivilopediaCategory[CategoryUnits].SelectArticle = function( unitID, shouldAddToList )
	-- print("CivilopediaCategory[CategoryUnits].SelectArticle");
	if m_selectedCategory ~= CategoryUnits then
		SetSelectedCategory(CategoryUnits, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryUnits, unitID );
	end
	
	if unitID ~= -1 then
		local thisUnit = GameInfo.Units[unitID];
					
		-- update the name
		local name = Locale.ToUpper( thisUnit.Description );
		if thisUnit.Affiliation ~= NULL then
			local n = string.find( name, "ICON" );
			if n == 2 then
				name = "[ICON_"..thisUnit.Affiliation.."]"..name
			else
				name = "[ICON_"..thisUnit.Affiliation.."] "..name
			end
		end
		if thisUnit.Orbital ~= NULL then
			local n = string.find( name, "ICON" );
			if n == 2 then
				name = "[ICON_ORBITAL_DURATION]"..name
			else
				name = "[ICON_ORBITAL_DURATION] "..name
			end
		end
		if thisUnit.Prototype == true then
			local n = string.find( name, "ICON" );
			if n == 2 then
				name = "[ICON_PROTOTYPE]"..name
			else
				name = "[ICON_PROTOTYPE] "..name
			end
		end

		Controls.ArticleID:SetText( name );

		local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon( thisUnit.ID );

		-- update the portrait
		if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
			Controls.PortraitFrame:SetHide( false );
		else
			Controls.PortraitFrame:SetHide( true );
		end

		-- update the cost
		local showCost = true;

		if (thisUnit.AlienLifeform) then
			showCost = false;
		end

		if (showCost) then
			Controls.CostFrame:SetHide( false );
		
			local costString = "";
		
			local cost = thisUnit.Cost;
			if(Game ~= nil) then
				cost = Players[Game.GetActivePlayer()]:GetUnitProductionNeeded( unitID );
			end
			if(cost > 0) then
				costString = tostring(cost) .. " [ICON_PRODUCTION]";
			else
				costString = Locale.Lookup("TXT_KEY_FREE");
				
				if(thisUnit.Type == "UNIT_SETTLER") then
					Controls.CostFrame:SetHide(true);
				end
			end				
			Controls.CostLabel:SetText(costString);
		end
		
		-- update the Combat value
		local combat = thisUnit.Combat;
		if combat > 0 then
			Controls.CombatLabel:SetText( tostring(combat).." [ICON_STRENGTH]" );
			Controls.CombatFrame:SetHide( false );
		end
		
		-- update the Ranged Combat value
		local rangedCombat = thisUnit.RangedCombat;
		if rangedCombat > 0 then
			Controls.RangedCombatLabel:SetText( tostring(rangedCombat).." [ICON_RANGE_STRENGTH]" );
			Controls.RangedCombatFrame:SetHide( false );
		end
		
		-- update the Ranged Combat value
		local rangedCombatRange = thisUnit.Range;
		if rangedCombatRange > 0 then
			Controls.RangedCombatRangeLabel:SetText( tostring(rangedCombatRange) .. " [ICON_ATTACK_RANGE]" );
			Controls.RangedCombatRangeFrame:SetHide( false );
		end

		local orbitalInfo = thisUnit.Orbital and GameInfo.OrbitalUnits[thisUnit.Orbital];
			
		-- update the Movement value
		local movementRange = thisUnit.Moves;
		if movementRange > 0 and not thisUnit.Immobile then
			Controls.MovementLabel:SetText( tostring(movementRange).." [ICON_MOVES]" );
			Controls.MovementFrame:SetHide( false );
		end

		-- Orbital info
		if(orbitalInfo ~= nil) then
			Controls.OrbitalEffectRangeLabel:SetText(tostring(orbitalInfo.EffectRange) .. " [ICON_ORBITAL_RANGE]");
			Controls.OrbitalEffectRangeFrame:SetHide(false);

			-- If we're in game, query the modified value!
			local turnDuration = orbitalInfo.TurnDuration;
			if(Game) then
				local activePlayerID = Game.GetActivePlayer();
				local activePlayer = Players[activePlayerID];
				turnDuration = activePlayer:GetTurnsUnitAllowedInOrbit(thisUnit.ID, true);
			end

			local orbitalTurnDuration = tostring(turnDuration) .. " [ICON_ORBITAL_DURATION]";
			Controls.OrbitalTurnDurationLabel:SetText(orbitalTurnDuration);
			Controls.OrbitalTurnDurationFrame:SetHide(false);

		else
			Controls.OrbitalEffectRangeFrame:SetHide(true);
			Controls.OrbitalTurnDurationFrame:SetHide(true);
		end
		
 		local contentSize;
 		local frameSize = {};
		local buttonAdded = 0;
 		
 		-- update the free promotions
		g_PromotionsManager:DestroyInstances();
		buttonAdded = 0;

		local condition = "UnitType = '" .. thisUnit.Type .. "'";
		for row in GameInfo.Unit_FreePromotions( condition ) do
			local promotion = GameInfo.UnitPromotions[row.PromotionType];
			if promotion then
				local thisPromotionInstance = g_PromotionsManager:GetInstance();
				if thisPromotionInstance then
					local textureOffset, textureSheet = IconLookup( promotion.PortraitIndex, buttonSize, promotion.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end

					local promotionText = "[COLOR_YELLOW]" .. Locale.ConvertTextKey( promotion.Description ) .. "[ENDCOLOR][NEWLINE][NEWLINE]" .. Locale.ConvertTextKey( promotion.Help );

					UpdateSmallButton( 
						buttonAdded, 
						thisPromotionInstance.PromotionImage, 
						thisPromotionInstance.PromotionButton, 
						textureSheet, 
						textureOffset, 
						nil, 
						promotionText, 
						promotion.ID );

					buttonAdded = buttonAdded + 1;
				end
			end	
		end
		UpdateButtonFrame( buttonAdded, Controls.FreePromotionsInnerFrame, Controls.FreePromotionsFrame );

		-- update the required resources
		Controls.RequiredResourcesLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_REQ_RESRC_LABEL" ) );
		g_RequiredResourcesManager:DestroyInstances();
		buttonAdded = 0;

		local condition = "UnitType = '" .. thisUnit.Type .. "'";

		for row in GameInfo.Unit_ResourceQuantityRequirements( condition ) do
			local requiredResource = GameInfo.Resources[row.ResourceType];
			if requiredResource then
				local thisRequiredResourceInstance = g_RequiredResourcesManager:GetInstance();
				if thisRequiredResourceInstance then
					local textureOffset, textureSheet = IconLookup( requiredResource.PortraitIndex, buttonSize, requiredResource.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisRequiredResourceInstance.RequiredResourceImage, thisRequiredResourceInstance.RequiredResourceButton, textureSheet, textureOffset, CategoryResources, Locale.ConvertTextKey( requiredResource.Description ), requiredResource.ID );
					buttonAdded = buttonAdded + 1;
				end
			end		
		end
		UpdateButtonFrame( buttonAdded, Controls.RequiredResourcesInnerFrame, Controls.RequiredResourcesFrame );

		-- update the prereq techs
		g_PrereqTechManager:DestroyInstances();
		buttonAdded = 0;

		if thisUnit.PrereqTech then
			local prereq = GameInfo.Technologies[thisUnit.PrereqTech];
			if prereq then
				local thisPrereqInstance = g_PrereqTechManager:GetInstance();
				if thisPrereqInstance then
					local textureOffset, textureSheet = IconLookup( prereq.PortraitIndex, buttonSize, prereq.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqTechImage, thisPrereqInstance.PrereqTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereq.Description ), prereq.ID );
					buttonAdded = buttonAdded + 1;
				end	
			end
		end	
		UpdateButtonFrame( buttonAdded, Controls.PrereqTechInnerFrame, Controls.PrereqTechFrame );

		-- update the obsolete techs
		g_ObsoleteTechManager:DestroyInstances();
		buttonAdded = 0;

		if thisUnit.ObsoleteTech then
			local obs = GameInfo.Technologies[thisUnit.ObsoleteTech];
			if obs then
				local thisTechInstance = g_ObsoleteTechManager:GetInstance();
				if thisTechInstance then
					local textureOffset, textureSheet = IconLookup( obs.PortraitIndex, buttonSize, obs.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisTechInstance.ObsoleteTechImage, thisTechInstance.ObsoleteTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( obs.Description ), obs.ID );
					buttonAdded = buttonAdded + 1;
				end	
			end
		end	
		UpdateButtonFrame( buttonAdded, Controls.ObsoleteTechInnerFrame, Controls.ObsoleteTechFrame );

		-- update the Upgrade units
		g_UpgradeManager:DestroyInstances();
		buttonAdded = 0;
		
		if(Game ~= nil) then
			local iUnitUpgrade = Game.GetUnitUpgradesTo(unitID);
			if iUnitUpgrade ~= nil and iUnitUpgrade ~= -1 then
				local obs = GameInfo.Units[iUnitUpgrade];
				if obs then
					local thisUpgradeInstance = g_UpgradeManager:GetInstance();
					if thisUpgradeInstance then
						local textureOffset, textureSheet = IconLookup( obs.PortraitIndex, buttonSize, obs.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end				
						UpdateSmallButton( buttonAdded, thisUpgradeInstance.UpgradeImage, thisUpgradeInstance.UpgradeButton, textureSheet, textureOffset, CategoryUnits, Locale.ConvertTextKey( obs.Description ), obs.ID );
						buttonAdded = buttonAdded + 1;
					end	
				end
			end	
		else
			for row in GameInfo.Unit_ClassUpgrades{UnitType = thisUnit.Type} do	
				local unitClass = GameInfo.UnitClasses[row.UnitClassType];
				local upgradeUnit = GameInfo.Units[unitClass.DefaultUnit];
				if (upgradeUnit) then
					local thisUpgradeInstance = g_UpgradeManager:GetInstance();
					if thisUpgradeInstance then
						local textureOffset, textureSheet = IconLookup( upgradeUnit.PortraitIndex, buttonSize, upgradeUnit.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end				
						UpdateSmallButton( buttonAdded, thisUpgradeInstance.UpgradeImage, thisUpgradeInstance.UpgradeButton, textureSheet, textureOffset, CategoryUnits, Locale.ConvertTextKey( upgradeUnit.Description ), upgradeUnit.ID );
						buttonAdded = buttonAdded + 1;
					end	
				end		
			end
		end
		
		UpdateButtonFrame( buttonAdded, Controls.UpgradeInnerFrame, Controls.UpgradeFrame );
		
		-- Are we a unique unit?  If so, who do I replace?
		local replacesUnitClass = {};
		local specificCivs = {};
		
		local classOverrideCondition = string.format("UnitType='%s' and CivilizationType <> 'CIVILIZATION_ALIEN' and CivilizationType <> 'CIVILIZATION_MINOR' and CivilizationType <> 'CIVILIZATION_NEUTRAL_PROXY'", thisUnit.Type);
		for row in GameInfo.Civilization_UnitClassOverrides(classOverrideCondition) do
			specificCivs[row.CivilizationType] = 1;
			replacesUnitClass[row.UnitClassType] = 1;
		end
		 	
		g_ReplacesManager:DestroyInstances();
		buttonAdded = 0;
		for unitClassType, _ in pairs(replacesUnitClass) do
			for replacedUnit in DB.Query("SELECT u.ID, u.Description, u.PortraitIndex, u.IconAtlas from Units as u inner join UnitClasses as uc on u.Type = uc.DefaultUnit where uc.Type = ?", unitClassType) do
				local thisUnitInstance = g_ReplacesManager:GetInstance();
				if thisUnitInstance then
					local textureOffset, textureSheet = IconLookup( replacedUnit.PortraitIndex, buttonSize, replacedUnit.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisUnitInstance.ReplaceImage, thisUnitInstance.ReplaceButton, textureSheet, textureOffset, CategoryUnits, Locale.ConvertTextKey( replacedUnit.Description ), replacedUnit.ID );
					buttonAdded = buttonAdded + 1;
				end
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.ReplacesInnerFrame, Controls.ReplacesFrame );

		g_CivilizationsManager:DestroyInstances();
		buttonAdded = 0;
		for civilizationType, _ in pairs(specificCivs) do
		
			local civ = GameInfo.Civilizations[civilizationType];
			if(civ ~= nil) then
				local thisCivInstance = g_CivilizationsManager:GetInstance();
				if thisCivInstance then
					local textureOffset, textureSheet = IconLookup( civ.PortraitIndex, buttonSize, civ.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisCivInstance.CivilizationImage, thisCivInstance.CivilizationButton, textureSheet, textureOffset, CategoryCivilizations, Locale.ConvertTextKey( civ.ShortDescription ), civ.ID );
					buttonAdded = buttonAdded + 1;
				end	
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.CivilizationsInnerFrame, Controls.CivilizationsFrame );

		-- update the game info
		if thisUnit.Help then
			UpdateTextBlock( Locale.ConvertTextKey( thisUnit.Help ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
		end
				
		-- update the strategy info
		if thisUnit.Strategy then
			UpdateTextBlock( Locale.ConvertTextKey( thisUnit.Strategy ), Controls.StrategyLabel, Controls.StrategyInnerFrame, Controls.StrategyFrame );
		end
		
		-- update the historical info
		if thisUnit.Civilopedia then
			UpdateTextBlock( Locale.ConvertTextKey( thisUnit.Civilopedia ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
		end

		-- update special abilities
		local abilityLines = {};
		if (thisUnit.Invisibility) then
			table.insert(abilityLines, "[COLOR_YELLOW]" .. Locale.ConvertTextKey("TXT_KEY_TERM_INVISIBILITY") .. "[ENDCOLOR]");
			table.insert(abilityLines, Locale.ConvertTextKey("TXT_KEY_SUMMARY_INVISIBILITY"));
		end

		if #abilityLines > 0 then
			local abilitiesString = table.concat(abilityLines, "[NEWLINE]");
			UpdateTextBlock( abilitiesString, Controls.AbilitiesLabel, Controls.AbilitiesInnerFrame, Controls.AbilitiesFrame );
		else
			Controls.AbilitiesFrame:SetHide( true );			
		end

		-- Affinity Level Requirements
		local gameInfoText = "";
		Controls.ReqAffinitiesFrame:SetHide(true);
		local unitAffinityPrereq = CachedUnitAffinityPrereqs[thisUnit.Type];
		if (unitAffinityPrereq ~= nil) then
			local gameInfoText = "";
			local firstEntry = true;

			for affinityType, level in pairs(unitAffinityPrereq) do
				local affinityInfo = GameInfo.Affinity_Types[affinityType];
				local prereqString = Locale.ConvertTextKey("TXT_KEY_AFFINITY_LEVEL_REQUIRED", affinityInfo.ColorType, level, affinityInfo.IconString, affinityInfo.Description);
				if (firstEntry == false) then
					gameInfoText = gameInfoText .. "[NEWLINE]";					
				end
				gameInfoText = gameInfoText .. prereqString;
				firstEntry = false;
			end

			local affinityHeader = Locale.ConvertTextKey("TXT_KEY_PEDIA_CATEGORY_15_LABEL") .. ":";
			Controls.ReqAffinitiesHeader:SetText( affinityHeader );				
			Controls.ReqAffinitiesFrame:SetHide(false);
			Controls.ReqAffinitiesLabel:SetText( gameInfoText );

			local PADDING = 30;
			local height = Controls.ReqAffinitiesLabel:GetSizeY();
			Controls.ReqAffinitiesFrame:SetSizeY( height + PADDING );
			Controls.ReqAffinitiesInnerFrame:SetSizeY( height + PADDING );
		end
		
		-- update the related images
		Controls.RelatedImagesFrame:SetHide( true );
		
	end

	ResizeEtc();

end

local defaultPromotionPortraitOffset = Vector2( 256, 256 );

CivilopediaCategory[CategoryUpgrades].SelectArticle = function( upgradeID, shouldAddToList )
	print("CivilopediaCategory[CategoryUpgrades].SelectArticle");
	if m_selectedCategory ~= CategoryUpgrades then
		SetSelectedCategory(CategoryUpgrades, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryUpgrades, upgradeID );
	end
	
	if upgradeID ~= -1 then
		local upgradeInfo = GameInfo.UnitUpgrades[upgradeID];
		local unitInfo = GameInfo.Units[upgradeInfo.UnitType];
		local freePerkInfo = GameInfo.UnitPerks[upgradeInfo.FreePerk];
		if (upgradeInfo ~= nil and unitInfo ~= nil and freePerkInfo ~= nil) then
			-- update the name
			local name = Locale.ToUpper( upgradeInfo.Description );
			Controls.ArticleID:SetText( name );

			-- Icon portrait
			local portraitIndex, portraitAtlas = UI.GetUnitPortraitIcon( unitInfo.ID );
			if IconHookup( portraitIndex, portraitSize, portraitAtlas, Controls.Portrait ) then
				Controls.PortraitFrame:SetHide( false );
			else
				Controls.PortraitFrame:SetHide( true );
			end
			
			-- Game Info text
			local gameInfoText = "";
			if (upgradeInfo.AnyAffinityLevel > 0) then
				gameInfoText = gameInfoText .. Locale.ConvertTextKey("TXT_KEY_UPANEL_AFFINITY_LEVEL_UNLOCK_TT", "TXT_KEY_AFFINITY_TYPE_ANY", upgradeInfo.AnyAffinityLevel) .. "[NEWLINE]"
			end
			if (upgradeInfo.HarmonyLevel > 0) then
				gameInfoText = gameInfoText .. "[ICON_HARMONY] [COLOR_HARMONY_AFFINITY]" .. Locale.ConvertTextKey("TXT_KEY_UPANEL_AFFINITY_LEVEL_UNLOCK_TT", "TXT_KEY_AFFINITY_TYPE_HARMONY", upgradeInfo.HarmonyLevel) .. "[ENDCOLOR][NEWLINE]";
			end
			if (upgradeInfo.PurityLevel > 0) then
				gameInfoText = gameInfoText .. "[ICON_PURITY] [COLOR_PURITY_AFFINITY]" .. Locale.ConvertTextKey("TXT_KEY_UPANEL_AFFINITY_LEVEL_UNLOCK_TT", "TXT_KEY_AFFINITY_TYPE_PURITY", upgradeInfo.PurityLevel) .. "[ENDCOLOR][NEWLINE]";
			end
			if (upgradeInfo.SupremacyLevel > 0) then
				gameInfoText = gameInfoText .. "[ICON_SUPREMACY] [COLOR_SUPREMACY_AFFINITY]" .. Locale.ConvertTextKey("TXT_KEY_UPANEL_AFFINITY_LEVEL_UNLOCK_TT", "TXT_KEY_AFFINITY_TYPE_SUPREMACY", upgradeInfo.SupremacyLevel) .. "[ENDCOLOR][NEWLINE]";
			end
			if (gameInfoText ~= "") then
				gameInfoText = gameInfoText .. "[NEWLINE]";
			end
			gameInfoText = gameInfoText .. GetHelpTextForUnitPerk(freePerkInfo.ID);
			gameInfoText = gameInfoText .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_UNIT_UPGRADE_CHOOSE_PERK");
			local AndText = " " .. Locale.ConvertTextKey("TXT_KEY_AND") .. " ";
			for choiceInfo in GameInfo.UnitUpgradePerkChoices("UpgradeType = '" .. upgradeInfo.Type.. "'") do
				local chosenPerkInfo = GameInfo.UnitPerks[choiceInfo.PerkType];
				local perkText		 = GetHelpTextForUnitPerk(chosenPerkInfo.ID);
				perkText = string.gsub( perkText, "%[NEWLINE%]", AndText );
				gameInfoText = gameInfoText .. "[NEWLINE][ICON_BULLET]" .. perkText;
			end
			UpdateTextBlock( gameInfoText, Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
		end
	end	

	ResizeEtc();

end

function SelectBuildingOrWonderArticle( buildingID )
	if buildingID ~= -1 then
		local thisBuilding = GameInfo.Buildings[buildingID];
					
		-- update the name
		local name = Locale.ToUpper( thisBuilding.Description ); 	
		Controls.ArticleID:SetText( name );

		-- update the portrait
		if IconHookup( thisBuilding.PortraitIndex, portraitSize, thisBuilding.IconAtlas, Controls.Portrait ) then
			Controls.PortraitFrame:SetHide( false );
		else
			Controls.PortraitFrame:SetHide( true );
		end
		
		-- update the cost
		Controls.CostFrame:SetHide( false );
		local costString = "";
		
		local cost = thisBuilding.Cost;
		if(Game ~= nil) then
			cost = Players[Game.GetActivePlayer()]:GetBuildingProductionNeeded( buildingID );
		end
		
		local costPerPlayer = 0;
		for tLeagueProject in GameInfo.LeagueProjects() do
			if (tLeagueProject ~= nil) then
				for iTier = 1, 3, 1 do
					if (tLeagueProject["RewardTier" .. iTier] ~= nil) then
						local tReward = GameInfo.LeagueProjectRewards[tLeagueProject["RewardTier" .. iTier]];
						if (tReward ~= nil and tReward.Building ~= nil) then
							if (GameInfo.Buildings[tReward.Building] ~= nil and GameInfo.Buildings[tReward.Building].ID == buildingID) then
								costPerPlayer = tLeagueProject.CostPerPlayer;
								if (Game ~= nil and Game.GetNumActiveLeagues() > 0) then
									local pLeague = Game.GetActiveLeague();
									if (pLeague ~= nil) then
										costPerPlayer = pLeague:GetProjectCostPerPlayer(tLeagueProject.ID) / 100;
									end
								end
							end
						end
					end
				end
			end
		end
		
		if(costPerPlayer > 0) then
			costString = Locale.ConvertTextKey("TXT_KEY_LEAGUE_PROJECT_COST_PER_PLAYER", costPerPlayer);
		else
			if(cost > 0 and thisBuilding.Cost ~= 0) then
				costString = tostring(cost).. " [ICON_PRODUCTION]";
			else
				costString = Locale.Lookup("TXT_KEY_FREE");
			end
		end
		
		Controls.CostLabel:SetText(costString);
		
		-- update the maintenance
		local energyMaintenance = thisBuilding.EnergyMaintenance;
		if energyMaintenance > 0 then
			Controls.MaintenanceLabel:SetText( tostring(energyMaintenance).." [ICON_ENERGY]" );
			Controls.MaintenanceFrame:SetHide( false );
		end

		-- update the Health
		local healthStrings = {};
		local iHealth = thisBuilding.Health;
		if (iHealth ~= nil and iHealth ~= 0) then
			table.insert(healthStrings, "+" .. tostring(iHealth).." [ICON_HEALTH_1]");		
		end

		local iHealthModifier = thisBuilding.HealthModifier;
		if(iHealthModifier ~= nil and iHealthModifier ~= 0) then
			table.insert(healthStrings, "+" .. tostring(iHealthModifier).."% [ICON_HEALTH_1]");
		end

		local iUnHealthModifier = thisBuilding.UnhealthModifier;
		if (iUnHealthModifier ~= nil and iUnHealthModifier ~= 0) then
			table.insert(healthStrings,  "+" .. tostring(iUnHealthModifier).."% [ICON_UNHEALTH]");
		end

		if(#healthStrings > 0) then
			Controls.HealthLabel:SetText(table.concat(healthStrings, " "));
			Controls.HealthFrame:SetHide( false );
		end

		local GetBuildingYieldChange = function(buildingID, yieldType)
			if(Game ~= nil) then
				return Game.GetBuildingYieldChange(buildingID, YieldTypes[yieldType]);
			else
				local yieldModifier = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				for row in GameInfo.Building_YieldChanges{BuildingType = buildingType, YieldType = yieldType} do
					yieldModifier = yieldModifier + row.Yield;
				end
				
				return yieldModifier;
			end
		
		end

		-- update the Defense
		local defenseEntries = {};
		local iDefense = thisBuilding.Defense;
		if iDefense > 0 then
			table.insert(defenseEntries, tostring(iDefense / 100).." [ICON_STRENGTH]");
		end
		
		local iExtraHitPoints = thisBuilding.ExtraCityHitPoints;
		if(iExtraHitPoints > 0) then
			table.insert(defenseEntries, Locale.Lookup("TXT_KEY_PEDIA_DEFENSE_HITPOINTS", iExtraHitPoints));
		end
		
		if(#defenseEntries > 0) then
			Controls.DefenseLabel:SetText(table.concat(defenseEntries, ", "));
			Controls.DefenseFrame:SetHide(false);
		else
			Controls.DefenseFrame:SetHide(true);
		end
		
		local GetBuildingYieldModifier = function(buildingID, yieldType)
			if(Game ~= nil) then
				return Game.GetBuildingYieldModifier(buildingID, YieldTypes[yieldType]);
			else
				local yieldModifier = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				for row in GameInfo.Building_YieldModifiers{BuildingType = buildingType, YieldType = yieldType} do
					yieldModifier = yieldModifier + row.Yield;
				end
				
				return yieldModifier;
			end
			
		end
		
		-- Use Game to calculate Yield Changes and modifiers.
		-- update the Food Change
		local iFood = GetBuildingYieldChange(buildingID, "YIELD_FOOD");
		if (iFood > 0) then
			Controls.FoodLabel:SetText( "+" .. tostring(iFood).." [ICON_FOOD]" );
			Controls.FoodFrame:SetHide( false );
		end


		local energyStrings = {};
		-- update the Energy Change
		local iGold = GetBuildingYieldChange(buildingID, "YIELD_ENERGY");
		if (iGold > 0) then
			table.insert(energyStrings, "+" .. tostring(iGold) .. "[ICON_ENERGY]");
		end

		-- update the Energy
		local iGold = GetBuildingYieldModifier(buildingID, "YIELD_ENERGY");
		if (iGold > 0) then
			table.insert(energyStrings, "+" .. tostring(iGold) .. "% [ICON_ENERGY]");
		end

		if(#energyStrings > 0) then
			Controls.GoldLabel:SetText(table.concat(energyStrings, ", "));
			Controls.GoldFrame:SetHide(false);
		else
			Controls.GoldFrame:SetHide(true);
		end


		-- update the Science
		local scienceItems = {};
		local iScience = GetBuildingYieldModifier(buildingID, "YIELD_SCIENCE");
		if(iScience > 0) then
			table.insert(scienceItems, "+" .. tostring(iScience).."% [ICON_RESEARCH]" );
		end
		
		-- update the Science Change
		local iScience = GetBuildingYieldChange(buildingID, "YIELD_SCIENCE");
		if(iScience > 0) then
			table.insert(scienceItems, "+" .. tostring(iScience).." [ICON_RESEARCH]" );
		end
		
		if(#scienceItems > 0) then
			Controls.ScienceLabel:SetText( table.concat(scienceItems, ", ") );
			Controls.ScienceFrame:SetHide( false );
		end

		-- update the Culture
		local cultureItems = {};
		local iCulture = GetBuildingYieldChange(buildingID, "YIELD_CULTURE");
		if iCulture > 0 then
			table.insert(cultureItems, "+" .. tostring(iCulture).." [ICON_CULTURE]" );			
		end

		-- update the Culture % mods		
		local iCulture = GetBuildingYieldModifier(buildingID, "YIELD_CULTURE");
		if(iCulture > 0) then
			table.insert(cultureItems, "+" .. tostring(iCulture).."% [ICON_CULTURE]");
		end

		if(#cultureItems > 0) then
			Controls.CultureLabel:SetText( table.concat(cultureItems, ", ") );
			Controls.CultureFrame:SetHide( false );
		end

		-- PRODUCTION
		local productionItems = {};

		-- FLAT Production
		local iProduction = GetBuildingYieldChange(buildingID, "YIELD_PRODUCTION");
		if(iProduction > 0) then
			table.insert(productionItems, "+" .. tostring(iProduction).." [ICON_PRODUCTION]");
		end

		-- MOD Production
		local iProduction = GetBuildingYieldModifier(buildingID, "YIELD_PRODUCTION");
		if(iProduction > 0) then
			table.insert(productionItems, "+" .. tostring(iProduction).."% [ICON_PRODUCTION]");
		end        

		-- Commit Production Items        
		if(#productionItems > 0) then
			Controls.ProductionLabel:SetText( table.concat(productionItems, ", ") );
			Controls.ProductionFrame:SetHide( false );
		end

		-- DIPLOMATIC CAPITAL
		local diploCapitalItems = {};

		-- FLAT Diplomatic Capital
		local iDiploCapital = GetBuildingYieldChange(buildingID, "YIELD_CAPITAL");
		if(iDiploCapital > 0) then
			table.insert(diploCapitalItems, "+" .. tostring(iDiploCapital).." [ICON_DIPLO_CAPITAL]");
		end

		-- MOD Diplomatic Capital
		iDiploCapital = GetBuildingYieldModifier(buildingID, "YIELD_CAPITAL");
		if(iDiploCapital > 0) then
			table.insert(diploCapitalItems, "+" .. tostring(iDiploCapital).."% [ICON_DIPLO_CAPITAL]");
		end        

		-- Commit Diplo Capital Items        
		if(#diploCapitalItems > 0) then
			Controls.DiploCapitalLabel:SetText( table.concat(diploCapitalItems, ", ") );
			Controls.DiploCapitalFrame:SetHide( false );
		end

 		local contentSize;
 		local frameSize = {};
		local buttonAdded = 0;

		-- update the prereq techs
		g_PrereqTechManager:DestroyInstances();

		if thisBuilding.PrereqTech then
			local prereq = GameInfo.Technologies[thisBuilding.PrereqTech];
			if prereq then
				local thisPrereqInstance = g_PrereqTechManager:GetInstance();
				if thisPrereqInstance then
					local textureOffset, textureSheet = IconLookup( prereq.PortraitIndex, buttonSize, prereq.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqTechImage, thisPrereqInstance.PrereqTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereq.Description ), prereq.ID );
					buttonAdded = buttonAdded + 1;
				end	
			end
		end	
		UpdateButtonFrame( buttonAdded, Controls.PrereqTechInnerFrame, Controls.PrereqTechFrame );

		local condition = "BuildingType = '" .. thisBuilding.Type .. "'";

		-- SpecialistType
		g_SpecialistsManager:DestroyInstances();
		buttonAdded = 0;

		if (thisBuilding.SpecialistCount > 0 and thisBuilding.SpecialistType) then
			local thisSpec = GameInfo.Specialists[thisBuilding.SpecialistType];
			if(thisSpec)  then
				for i = 1, thisBuilding.SpecialistCount, 1 do
					local thisSpecialistInstance = g_SpecialistsManager:GetInstance();
					if thisSpecialistInstance then
						local textureOffset, textureSheet = IconLookup( thisSpec.PortraitIndex, buttonSize, thisSpec.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end				

						UpdateSmallButton( buttonAdded, thisSpecialistInstance.SpecialistImage, thisSpecialistInstance.SpecialistButton, textureSheet, textureOffset, CategoryConcepts, Locale.ConvertTextKey( thisSpec.Description ), ConceptBuildingSpecialistsId);
						buttonAdded = buttonAdded + 1;
					end	
				end
			end
		end	
		UpdateButtonFrame( buttonAdded, Controls.SpecialistsInnerFrame, Controls.SpecialistsFrame );
		
		-- required buildings
		g_RequiredBuildingsManager:DestroyInstances();
		buttonAdded = 0;
		for row in GameInfo.Building_ClassesNeededInCity( condition ) do
			local buildingClass = GameInfo.BuildingClasses[row.BuildingClassType];
			if(buildingClass) then
				local thisBuildingInfo = GameInfo.Buildings[buildingClass.DefaultBuilding];
				if (thisBuildingInfo) then
					local thisBuildingInstance = g_RequiredBuildingsManager:GetInstance();
					if thisBuildingInstance then

						if not IconHookup( thisBuildingInfo.PortraitIndex, buttonSize, thisBuildingInfo.IconAtlas, thisBuildingInstance.RequiredBuildingImage ) then
							thisBuildingInstance.RequiredBuildingImage:SetTexture( defaultErrorTextureSheet );
							thisBuildingInstance.RequiredBuildingImage:SetTextureOffset( nullOffset );
						end
						
						--move this button
						thisBuildingInstance.RequiredBuildingButton:SetOffsetVal( (buttonAdded % numberOfButtonsPerRow) * buttonSize + buttonPadding, math.floor(buttonAdded / numberOfButtonsPerRow) * buttonSize + buttonPadding );
						
						thisBuildingInstance.RequiredBuildingButton:SetToolTipString( Locale.ConvertTextKey( thisBuildingInfo.Description ) );
						thisBuildingInstance.RequiredBuildingButton:SetVoids( thisBuildingInfo.ID, addToList );
						local thisBuildingClass = GameInfo.BuildingClasses[thisBuildingInfo.BuildingClass];
						if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and thisBuildingInfo.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
							thisBuildingInstance.RequiredBuildingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].SelectArticle );
						else
							thisBuildingInstance.RequiredBuildingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryBuildings].SelectArticle );
						end
						buttonAdded = buttonAdded + 1;
					end
				end
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.RequiredBuildingsInnerFrame, Controls.RequiredBuildingsFrame );

		-- needed local resources
		g_LocalResourcesManager:DestroyInstances();
		buttonAdded = 0;

		for row in GameInfo.Building_LocalResourceAnds( condition ) do
			local requiredResource = GameInfo.Resources[row.ResourceType];
			if requiredResource then
				local thisLocalResourceInstance = g_LocalResourcesManager:GetInstance();
				if thisLocalResourceInstance then
					local textureOffset, textureSheet = IconLookup( requiredResource.PortraitIndex, buttonSize, requiredResource.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisLocalResourceInstance.LocalResourceImage, thisLocalResourceInstance.LocalResourceButton, textureSheet, textureOffset, CategoryResources, Locale.ConvertTextKey( requiredResource.Description ), requiredResource.ID );
					buttonAdded = buttonAdded + 1;
				end
			end		
		end
		UpdateButtonFrame( buttonAdded, Controls.LocalResourcesInnerFrame, Controls.LocalResourcesFrame );
		
		-- update the required resources
		Controls.RequiredResourcesLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_REQ_RESRC_LABEL" ) );
		g_RequiredResourcesManager:DestroyInstances();
		buttonAdded = 0;

		for row in GameInfo.Building_ResourceQuantityRequirements( condition ) do
			local requiredResource = GameInfo.Resources[row.ResourceType];
			if requiredResource then
				local thisRequiredResourceInstance = g_RequiredResourcesManager:GetInstance();
				if thisRequiredResourceInstance then
					local textureOffset, textureSheet = IconLookup( requiredResource.PortraitIndex, buttonSize, requiredResource.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisRequiredResourceInstance.RequiredResourceImage, thisRequiredResourceInstance.RequiredResourceButton, textureSheet, textureOffset, CategoryResources, Locale.ConvertTextKey( requiredResource.Description ), requiredResource.ID );
					buttonAdded = buttonAdded + 1;
				end
			end		
		end
		UpdateButtonFrame( buttonAdded, Controls.RequiredResourcesInnerFrame, Controls.RequiredResourcesFrame );

		-- Are we a unique building?  If so, who do I replace?
		g_ReplacesManager:DestroyInstances();
		buttonAdded = 0;
		local defaultBuilding = nil;
		local thisCiv = nil;
		for row in GameInfo.Civilization_BuildingClassOverrides( condition ) do
			if row.Playable == true or row.AIPlayable == true then
			--if row.CivilizationType ~= "CIVILIZATION_ALIEN" and row.CivilizationType ~= "CIVILIZATION_MINOR" and row.CivilizationType ~= "CIVILIZATION_NEUTRAL_PROXY" then
				local otherCondition = "Type = '" .. row.BuildingClassType .. "'";
				for classrow in GameInfo.BuildingClasses( otherCondition ) do
					defaultBuilding = GameInfo.Buildings[classrow.DefaultBuilding];
				end
				if defaultBuilding then
					thisCiv = GameInfo.Civilizations[row.CivilizationType];
					break;
				end
			end
		end
		if defaultBuilding then
			local thisBuildingInstance = g_ReplacesManager:GetInstance();
			if thisBuildingInstance then
				local textureOffset, textureSheet = IconLookup( defaultBuilding.PortraitIndex, buttonSize, defaultBuilding.IconAtlas );				
				if textureOffset == nil then
					textureSheet = defaultErrorTextureSheet;
					textureOffset = nullOffset;
				end				
				UpdateSmallButton( buttonAdded, thisBuildingInstance.ReplaceImage, thisBuildingInstance.ReplaceButton, textureSheet, textureOffset, CategoryBuildings, Locale.ConvertTextKey( defaultBuilding.Description ), defaultBuilding.ID );
				buttonAdded = buttonAdded + 1;
			end
		end
		UpdateButtonFrame( buttonAdded, Controls.ReplacesInnerFrame, Controls.ReplacesFrame );

		buttonAdded = 0;
		if thisCiv then
			g_CivilizationsManager:DestroyInstances();
			local thisCivInstance = g_CivilizationsManager:GetInstance();
			if thisCivInstance then
				local textureOffset, textureSheet = IconLookup( thisCiv.PortraitIndex, buttonSize, thisCiv.IconAtlas );				
				if textureOffset == nil then
					textureSheet = defaultErrorTextureSheet;
					textureOffset = nullOffset;
				end				
				UpdateSmallButton( buttonAdded, thisCivInstance.CivilizationImage, thisCivInstance.CivilizationButton, textureSheet, textureOffset, CategoryCivilizations, Locale.ConvertTextKey( thisCiv.ShortDescription ), thisCiv.ID );
				buttonAdded = buttonAdded + 1;
			end	
		end
		UpdateButtonFrame( buttonAdded, Controls.CivilizationsInnerFrame, Controls.CivilizationsFrame );

		------------------------------------------------------------------
		-- update the GAME INFO
		-- NOTE! This will include parameterized effects that do not fit any of the standard stats above
		-- NOTE! You cannot use the Game class here because you can get to the Civilopedia from the main
		--       menu before Game is instantiated.
		
		local gameInfoItems = {};

		local GetTerrainYieldChange = function(buildingID, yieldID, terrainID)
			if(Game ~= nil) then
				return Game.GetBuildingFlatYieldFromTerrain(buildingID, yieldID, terrainID);
			else
				local yieldModifier = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local yieldType = GameInfo.Yields[yieldID].Type;
				local terrainType = GameInfo.Terrains[terrainID].Type;
				for row in GameInfo.Building_TerrainYieldChanges{BuildingType = buildingType, YieldType = yieldType, TerrainType = terrainType } do
					yieldModifier = yieldModifier + row.Yield;
				end
				
				return yieldModifier;
			end
		end

		local GetFeatureYieldChange = function(buildingID, yieldID, featureID)
			if(Game ~= nil) then
				return Game.GetBuildingFlatYieldFromFeature(buildingID, yieldID, featureID);
			else
				local yieldChange = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local yieldType = GameInfo.Yields[yieldID].Type;
				local featureType = GameInfo.Features[featureID].Type;
				for row in GameInfo.Building_FeatureYieldChanges{BuildingType = buildingType, YieldType = yieldType, FeatureType = featureType } do
					yieldChange = yieldChange + row.Yield;
				end
				
				return yieldChange;
			end
		end

		local GetResourceYieldChange = function(buildingID, yieldID, resourceID)
			if(Game ~= nil) then
				return Game.GetBuildingFlatYieldFromResource(buildingID, yieldID, resourceID);
			else
				local yieldChange = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local yieldType = GameInfo.Yields[yieldID].Type;
				local resourceType = GameInfo.Resources[resourceID].Type;
				for row in GameInfo.Building_ResourceYieldChanges{BuildingType = buildingType, YieldType = yieldType, ResourceType = resourceType } do
					yieldChange = yieldChange + row.Yield;
				end
				
				return yieldChange;
			end
		end

		local GetResourceYieldChange = function(buildingID, yieldID, resourceID)
			if(Game ~= nil) then
				return Game.GetBuildingFlatYieldFromResource(buildingID, yieldID, resourceID);
			else
				local yieldChange = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local yieldType = GameInfo.Yields[yieldID].Type;
				local resourceType = GameInfo.Resources[resourceID].Type;
				for row in GameInfo.Building_ResourceYieldChanges{BuildingType = buildingType, YieldType = yieldType, ResourceType = resourceType } do
					yieldChange = yieldChange + row.Yield;
				end
				
				return yieldChange;
			end
		end

		local GetTradeYieldChange = function(buildingID, yieldID)
			if(Game ~= nil) then
				return Game.GetBuildingTradeYieldChange(buildingID, yieldID);
			else
				local yieldChange = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local yieldType = GameInfo.Yields[yieldID].Type;
				for row in GameInfo.Building_TradeYieldChanges{BuildingType = buildingType, YieldType = yieldType } do
					yieldChange = yieldChange + row.Yield;
				end
				
				return yieldChange;
			end
		end

		local GetTradeYieldModifier = function(buildingID, yieldID)
			if(Game ~= nil) then
				return Game.GetBuildingTradeYieldModifier(buildingID, yieldID);
			else
				local yieldModifier = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local yieldType = GameInfo.Yields[yieldID].Type;
				for row in GameInfo.Building_TradeYieldModifiers{BuildingType = buildingType, YieldType = yieldType } do
					yieldModifier = yieldModifier + row.Yield;
				end
				
				return yieldModifier;
			end
		end

		-- SPECIAL YIELDS and EFFECTS
		for yieldInfo in GameInfo.Yields() do
			local eYield = yieldInfo.ID;
			
			-- Yield from TERRAIN
			for terrainInfo in GameInfo.Terrains() do
				local iTerrainYield = GetTerrainYieldChange(buildingID, eYield, terrainInfo.ID);
				if (iTerrainYield ~= nil and iTerrainYield ~= 0) then
					table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_LOCAL_TERRAIN", iTerrainYield, yieldInfo.IconString, yieldInfo.Description, terrainInfo.Description));
				end
			end

			-- Yield from FEATURES
			for featureInfo in GameInfo.Features() do
				local iFeatureYield = GetFeatureYieldChange(buildingID, eYield, featureInfo.ID);
				if (iFeatureYield ~= nil and iFeatureYield ~= 0) then
					table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_LOCAL_FEATURES", iFeatureYield, yieldInfo.IconString, yieldInfo.Description, featureInfo.Description));
				end
			end

			-- Yield from RESOURCES
			for resourceInfo in GameInfo.Resources() do
				local iResourceYield = GetResourceYieldChange(buildingID, eYield, resourceInfo.ID);
				if (iResourceYield ~= nil and iResourceYield ~= 0) then
					table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_LOCAL_RESOURCES", iResourceYield, yieldInfo.IconString, yieldInfo.Description, resourceInfo.IconString, resourceInfo.Description));
				end
			end

			--Yields from TRADE ROUTES
			-- FLAT
			local iFlatTradeYield = GetTradeYieldChange(buildingID, eYield);
			if (iFlatTradeYield ~= nil and iFlatTradeYield ~= 0) then
				InsertYieldString( gameInfoItems, "TXT_KEY_YIELD_FROM_SPECIFIC_OBJECT", "TXT_KEY_NEGATIVE_YIELD_FROM_SPECIFIC_OBJECT", iFlatTradeYield, yieldInfo.IconString, yieldInfo.Description, "TXT_KEY_EO_TRADE");
			end

			-- MOD
			local iModTradeYield = GetTradeYieldModifier(buildingID, eYield);
			if (iModTradeYield ~= nil and iModTradeYield ~= 0) then
				InsertYieldString( gameInfoItems, "TXT_KEY_YIELD_MOD_FROM_SPECIFIC_OBJECT", "TXT_KEY_NEGATIVE_YIELD_MOD_FROM_SPECIFIC_OBJECT", iModTradeYield, yieldInfo.IconString, yieldInfo.Description, "TXT_KEY_EO_TRADE");
			end
		end

		--
		local GetTerrainHealth = function(buildingID, terrainID)
			if(Game ~= nil) then
				return Game.GetBuildingFlatHealthFromTerrain(buildingID, terrainID);
			else
				local health = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local terrainType = GameInfo.Terrains[terrainID].Type;
				for row in GameInfo.Building_TerrainHealthChange{BuildingType = buildingType, TerrainType = terrainType } do
					health = health + row.Quantity;
				end
				
				return health;
			end
		end

		-- Special from TERRAIN
		for terrainInfo in GameInfo.Terrains() do
			-- Health
			local iTerrainHealth = GetTerrainHealth(buildingID, terrainInfo.ID);
			if (iTerrainHealth ~= nil and iTerrainHealth ~= 0) then
				InsertYieldString( gameInfoItems, "TXT_KEY_YIELD_FROM_SPECIFIC_OBJECT", "TXT_KEY_NEGATIVE_YIELD_FROM_SPECIFIC_OBJECT", iTerrainHealth, HEALTH_ICON, "TXT_KEY_HEALTH", terrainInfo.Description );
			end
		end

		--
		local GetFeaturesHealth = function(buildingID, featureID)
			if(Game ~= nil) then
				return Game.GetBuildingFlatHealthFromFeature(buildingID, featureID);
			else
				local health = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local featureType = GameInfo.Features[featureID].Type;
				for row in GameInfo.Building_FeatureHealthChange{BuildingType = buildingType, FeatureType = featureType } do
					health = health + row.Quantity;
				end
				
				return health;
			end
		end
		
		-- Special from FEATURES
		for featureInfo in GameInfo.Features() do
			-- Health
			local iFeatureHealth = GetFeaturesHealth(buildingID, featureInfo.ID);
			if (iFeatureHealth ~= nil and iFeatureHealth ~= 0) then
				InsertYieldString( gameInfoItems, "TXT_KEY_YIELD_FROM_SPECIFIC_OBJECT", "TXT_KEY_NEGATIVE_YIELD_FROM_SPECIFIC_OBJECT", iFeatureHealth, HEALTH_ICON, "TXT_KEY_HEALTH", featureInfo.Description);
			end
		end

		--
		local GetResourcesHealth = function(buildingID, resourceID)
			if(Game ~= nil) then
				return Game.GetBuildingFlatHealthFromResource(buildingID, resourceID);
			else
				local health = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local resourceType = GameInfo.Resources[resourceID].Type;
				for row in GameInfo.Building_ResourceHealthChange{BuildingType = buildingType, ResourceType = resourceType } do
					health = health + row.Quantity;
				end
				
				return health;
			end
		end

		-- Special from RESOURCES
		for resourceInfo in GameInfo.Resources() do
			-- Health
			local iResourceHealth = GetResourcesHealth(buildingID, resourceInfo.ID);
			if (iResourceHealth ~= nil and iResourceHealth ~= 0) then
				InsertYieldString( gameInfoItems, "TXT_KEY_YIELD_FROM_SPECIFIC_ICON_OBJECT", "TXT_KEY_NEGATIVE_YIELD_FROM_SPECIFIC_ICON_OBJECT", iResourceHealth, HEALTH_ICON, "TXT_KEY_HEALTH", resourceInfo.IconString, resourceInfo.Description);
			end
		end

		--
		local GetDomainModifier = function(buildingID, domainID)
			if(Game ~= nil) then
				return Game.GetBuildingDomainProductionModifier(buildingID, domainID);
			else
				local modifier = 0;
				local buildingType = GameInfo.Buildings[buildingID].Type;
				local domainType = GameInfo.Domains[domainID].Type;
				for row in GameInfo.Building_DomainProductionModifiers{BuildingType = buildingType, DomainType = domainType } do
					modifier = modifier + row.Modifier;
				end
				
				return modifier;
			end
		end

		-- DOMAIN Production Modifiers
		for domainInfo in GameInfo.Domains() do
			local iDomainProductionMod = GetDomainModifier(buildingID, domainInfo.ID);
			if (iDomainProductionMod ~= nil and iDomainProductionMod ~= 0) then
				table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_DOMAIN_PRODUCTION_MOD", iDomainProductionMod, domainInfo.Description));
			end
		end

		-- Orbital Production
		local iOrbitalProductionMod = thisBuilding.OrbitalProductionModifier;
		if (iOrbitalProductionMod ~= nil and iOrbitalProductionMod ~= 0) then
			table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_DOMAIN_PRODUCTION_MOD", iOrbitalProductionMod, "TXT_KEY_ORBITAL_UNITS"));
		end

		-- Orbital Coverage
		local iOrbitalCoverage = thisBuilding.OrbitalCoverageChange;
		if (iOrbitalCoverage ~= nil and iOrbitalCoverage ~= 0) then
			table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_BUILDING_ORBITAL_COVERAGE", iOrbitalCoverage));
		end

		-- Anti-Orbital Strike
		local iOrbitalStrikeRangeChange = thisBuilding.OrbitalStrikeRangeChange;
		if (iOrbitalStrikeRangeChange ~= nil and iOrbitalStrikeRangeChange ~= 0) then
			table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_UNITPERK_RANGE_AGAINST_ORBITAL_CHANGE", iOrbitalStrikeRangeChange));
		end

		-- City Strike Damage	
		local iCityStrikeDamage = thisBuilding.CityStrikeModifier;
		if (iCityStrikeDamage ~= nil and iCityStrikeDamage ~= 0) then
			table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_STRIKE_MODIFIER", iCityStrikeDamage));
		end

		-- Covert Ops Intrigue Cap
		local iIntrigueCapChange = thisBuilding.IntrigueCapChange;
		if (iIntrigueCapChange ~= nil and iIntrigueCapChange < 0) then
			local iIntrigueLevelsChange = (iIntrigueCapChange * -1) / (100 / GameDefines.MAX_CITY_INTRIGUE_LEVELS); -- Make it positive to show in UI
			table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_BUILDING_CITY_INTRIGUE_CAP", iIntrigueLevelsChange));
		end

		-- Move City Cost 
		local iCityMoveCostModifier = thisBuilding.CityMoveCostModifier;
		if (iCityMoveCostModifier ~= nil and iCityMoveCostModifier ~= 0) then
			table.insert(gameInfoItems, Locale.ConvertTextKey("TXT_KEY_BUILDING_MOVE_COST_MOD", iCityMoveCostModifier));
		end

		-- Pre-written Help
		if thisBuilding.Help and (thisBuilding.Help ~= thisBuilding.Strategy) then
			table.insert(gameInfoItems, Locale.ConvertTextKey(thisBuilding.Help));
		end

		-- COMMIT GAME INFO
		if (#gameInfoItems > 0) then
			local completeGameInfoStr = table.concat(gameInfoItems, "[NEWLINE]");
			UpdateTextBlock(completeGameInfoStr, Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame);
		end
		------------------------------------------------------------------
				
		-- update the strategy info
		if thisBuilding.Strategy then
			UpdateTextBlock( Locale.ConvertTextKey( thisBuilding.Strategy ), Controls.StrategyLabel, Controls.StrategyInnerFrame, Controls.StrategyFrame );
		end
		
		-- update the historical info
		if thisBuilding.Civilopedia then
			UpdateTextBlock( Locale.ConvertTextKey( thisBuilding.Civilopedia ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
		end
		
		if thisBuilding.Quote then
			-- UpdateTextBlock( Locale.ConvertTextKey( thisBuilding.Quote ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
			UpdateRightQuoteBlock( Locale.ConvertTextKey( thisBuilding.Quote ), Controls.SilentQuoteLabel, Controls.SilentQuoteInnerFrame, Controls.SilentQuoteFrame );
		end

		---- Improves Yield PW
		g_TerrainsManager:DestroyInstances();
		buttonAdded = 0;
		local canceldouble;
		for row in GameInfo.Building_TerrainYieldChanges( condition ) do
			if row.Yield ~= 0 then
				local thisTerrain = GameInfo.Terrains[row.TerrainType];
				if thisTerrain.ID ~= canceldouble then 
					if thisTerrain then
						local thisTerrainInstance = g_TerrainsManager:GetInstance();
						if thisTerrainInstance then
						
							local textureOffset, textureSheet = IconLookup( thisTerrain.PortraitIndex, buttonSize, thisTerrain.IconAtlas );				
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end				
							
							UpdateSmallButton( buttonAdded, thisTerrainInstance.TerrainImage, thisTerrainInstance.TerrainButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisTerrain.Description ), thisTerrain.ID );
							
							buttonAdded = buttonAdded + 1;	
							canceldouble = thisTerrain.ID	
						end
					end
				end
			end
		end
		canceldouble = 0;
		for row in GameInfo.Building_SeaPlotYieldChanges( condition ) do
			if row.Yield ~= 0 then
				-- for row2 in GameInfo.Terrains( "EffectTypeTag = 'WATER'" and "GraphicalOnly = 'false'"  ) do
				for row2 in GameInfo.Terrains( "EffectTypeTag = 'WATER'") do
					if row2.ID ~= canceldouble and row2.GraphicalOnly == false then 

						local thisTerrainInstance = g_TerrainsManager:GetInstance();
						if thisTerrainInstance then
						
							local textureOffset, textureSheet = IconLookup( row2.PortraitIndex, buttonSize, row2.IconAtlas );				
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end				
							
							UpdateSmallButton( buttonAdded, thisTerrainInstance.TerrainImage, thisTerrainInstance.TerrainButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( row2.Description ), row2.ID );
							
							buttonAdded = buttonAdded + 1;	
							canceldouble = row2.ID	

						end
					end		
				end
			end
		end	
		canceldouble = 0;
		for row in GameInfo.Building_FeatureYieldChanges( condition ) do
			if row.Yield ~= 0 then
				local thisFeature = GameInfo.Features[row.FeatureType];
				if thisFeature.ID ~= canceldouble then 
					if thisFeature then
						local thisFeatureInstance = g_TerrainsManager:GetInstance();
						if thisFeatureInstance then
						
							local textureOffset, textureSheet = IconLookup( thisFeature.PortraitIndex, buttonSize, thisFeature.IconAtlas );				
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end				
							
							UpdateSmallButton( buttonAdded, thisFeatureInstance.TerrainImage, thisFeatureInstance.TerrainButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisFeature.Description ), thisFeature.ID + 1000 );
							
							buttonAdded = buttonAdded + 1;	
							canceldouble = thisFeature.ID	
						end
					end
				end
			end
		end	
		UpdateButtonFrame( buttonAdded, Controls.TerrainsInnerFrame, Controls.TerrainsFrame );
		---- Improves Yield PW

		-- Affinity Level Requirements
		local gameInfoText = "";
		Controls.ReqAffinitiesFrame:SetHide(true);
		local buildingAffinityPrereq = CachedBuildingAffinityPrereqs[thisBuilding.Type];
		if (buildingAffinityPrereq ~= nil) then
			local gameInfoText = "";
			local firstEntry = true;

			for affinityType, level in pairs(buildingAffinityPrereq) do
				local affinityInfo = GameInfo.Affinity_Types[affinityType];
				local prereqString = Locale.ConvertTextKey("TXT_KEY_AFFINITY_LEVEL_REQUIRED", affinityInfo.ColorType, level, affinityInfo.IconString, affinityInfo.Description);				
				if (firstEntry == false) then
					gameInfoText = gameInfoText .. "[NEWLINE]";
				end				
				gameInfoText = gameInfoText .. prereqString;
				firstEntry = false;
			end

			local affinityHeader = Locale.ConvertTextKey("TXT_KEY_PEDIA_CATEGORY_15_LABEL") .. ":";
			Controls.ReqAffinitiesHeader:SetText( affinityHeader );				
			Controls.ReqAffinitiesFrame:SetHide(false);
			Controls.ReqAffinitiesLabel:SetText( gameInfoText );

			local PADDING = 30;
			local height = Controls.ReqAffinitiesLabel:GetSizeY();
			Controls.ReqAffinitiesFrame:SetSizeY( height + PADDING );
			Controls.ReqAffinitiesInnerFrame:SetSizeY( height + PADDING );
		end
		
		-- update the related images
		Controls.RelatedImagesFrame:SetHide( true );

	end
end

CivilopediaCategory[CategoryBuildings].SelectArticle = function( buildingID, shouldAddToList )
	print("CivilopediaCategory[CategoryBuildings].SelectArticle");
	if m_selectedCategory ~= CategoryBuildings then
		SetSelectedCategory(CategoryBuildings, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryBuildings, buildingID );
	end
	
	SelectBuildingOrWonderArticle( buildingID );

	ResizeEtc();

end


CivilopediaCategory[CategoryWonders].SelectArticle = function( wonderID, shouldAddToList )
	print("CivilopediaCategory[CategoryWonders].SelectArticle");
	if m_selectedCategory ~= CategoryWonders then
		SetSelectedCategory(CategoryWonders, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryWonders, wonderID );
	end
	
	if wonderID < 1000 then
		SelectBuildingOrWonderArticle( wonderID );
	else
		local projectID = wonderID - 1000;
		if projectID ~= -1 then
		
			local thisProject = GameInfo.Projects[projectID];
						
			-- update the name
			local name = Locale.ToUpper( thisProject.Description ); 	
			Controls.ArticleID:SetText( name );

			-- update the portrait
			if IconHookup( thisProject.PortraitIndex, portraitSize, thisProject.IconAtlas, Controls.Portrait ) then
				Controls.PortraitFrame:SetHide( false );
			else
				Controls.PortraitFrame:SetHide( true );
			end
			
			-- update the cost
			Controls.CostFrame:SetHide( false );
			local cost = thisProject.Cost;
			if(cost > 0 and Game ~= nil) then
				cost = Players[Game.GetActivePlayer()]:GetProjectProductionNeeded( projectID );
			end
			
			if(cost > 0) then
				Controls.CostLabel:SetText( tostring(cost).." [ICON_PRODUCTION]" );
			elseif(cost == 0) then
				Controls.CostLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_FREE" ) );
			else
				Controls.CostFrame:SetHide(true);
			end
	
 			local contentSize;
 			local frameSize = {};
			local buttonAdded = 0;

			-- update the prereq techs
			g_PrereqTechManager:DestroyInstances();
			buttonAdded = 0;

			if thisProject.TechPrereq then
				local prereq = GameInfo.Technologies[thisProject.TechPrereq];
				if prereq then
					local thisPrereqInstance = g_PrereqTechManager:GetInstance();
					if thisPrereqInstance then
						local textureOffset, textureSheet = IconLookup( prereq.PortraitIndex, buttonSize, prereq.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end				
						UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqTechImage, thisPrereqInstance.PrereqTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereq.Description ), prereq.ID );
						buttonAdded = buttonAdded + 1;
					end	
				end
			end	
			UpdateButtonFrame( buttonAdded, Controls.PrereqTechInnerFrame, Controls.PrereqTechFrame );

			local condition = "BuildingType = '" .. thisProject.Type .. "'";
			
			-- required buildings
			g_RequiredBuildingsManager:DestroyInstances();
			buttonAdded = 0;
			for row in GameInfo.Building_ClassesNeededInCity( condition ) do
				local buildingClass = GameInfo.BuildingClasses[row.BuildingClassType];
				if(buildingClass ~= nil) then
					local thisBuildingInfo = GameInfo.Buildings[buildingClass.DefaultBuilding];
					if(thisBuildingInfo ~= nil) then
						local thisBuildingInstance = g_RequiredBuildingsManager:GetInstance();
						if thisBuildingInstance then

							if not IconHookup( thisBuildingInfo.PortraitIndex, buttonSize, thisBuildingInfo.IconAtlas, thisBuildingInstance.RequiredBuildingImage ) then
								thisBuildingInstance.RequiredBuildingImage:SetTexture( defaultErrorTextureSheet );
								thisBuildingInstance.RequiredBuildingImage:SetTextureOffset( nullOffset );
							end
							
							--move this button
							thisBuildingInstance.RequiredBuildingButton:SetOffsetVal( (buttonAdded % numberOfButtonsPerRow) * buttonSize + buttonPadding, math.floor(buttonAdded / numberOfButtonsPerRow) * buttonSize + buttonPadding );
							
							thisBuildingInstance.RequiredBuildingButton:SetToolTipString( Locale.ConvertTextKey( thisBuildingInfo.Description ) );
							thisBuildingInstance.RequiredBuildingButton:SetVoids( thisBuildingInfo.ID, addToList );
							local thisBuildingClass = GameInfo.BuildingClasses[thisBuildingInfo.BuildingClass];
							if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and thisBuildingInfo.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
								thisBuildingInstance.RequiredBuildingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].SelectArticle );
							else
								thisBuildingInstance.RequiredBuildingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryBuildings].SelectArticle );
							end
							buttonAdded = buttonAdded + 1;
						end
					end
				end
			end
			UpdateButtonFrame( buttonAdded, Controls.RequiredBuildingsInnerFrame, Controls.RequiredBuildingsFrame );

			-- Affinity Level Requirements
			local gameInfoText = "";
			Controls.ReqAffinitiesFrame:SetHide(true);
			local projectAffinityPrereq = CachedProjectAffinityPrereqs[thisProject.Type];
			if (projectAffinityPrereq ~= nil) then
				local gameInfoText = "";
				local firstEntry = true;

				for affinityType, level in pairs(projectAffinityPrereq) do
					local affinityInfo = GameInfo.Affinity_Types[affinityType];
					local prereqString = Locale.ConvertTextKey("TXT_KEY_AFFINITY_LEVEL_REQUIRED", affinityInfo.ColorType, level, affinityInfo.IconString, affinityInfo.Description);				
					if (firstEntry == false) then
						gameInfoText = gameInfoText .. "[NEWLINE]";
					end				
					gameInfoText = gameInfoText .. prereqString;
					firstEntry = false;
				end

				local affinityHeader = Locale.ConvertTextKey("TXT_KEY_PEDIA_CATEGORY_15_LABEL") .. ":";
				Controls.ReqAffinitiesHeader:SetText( affinityHeader );				
				Controls.ReqAffinitiesFrame:SetHide(false);
				Controls.ReqAffinitiesLabel:SetText( gameInfoText );

				local PADDING = 30;
				local height = Controls.ReqAffinitiesLabel:GetSizeY();
				Controls.ReqAffinitiesFrame:SetSizeY( height + PADDING );
				Controls.ReqAffinitiesInnerFrame:SetSizeY( height + PADDING );
			end
			
			-- update the game info
			if thisProject.Help then
				UpdateTextBlock( Locale.ConvertTextKey( thisProject.Help ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
				--UpdateTextBlock( Locale.ConvertTextKey( thisProject.Help ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
			end
					
			-- update the strategy info
			if (thisProject.Strategy) then
				UpdateTextBlock( Locale.ConvertTextKey( thisProject.Strategy ), Controls.StrategyLabel, Controls.StrategyInnerFrame, Controls.StrategyFrame );
			end
			
			-- update the historical info
			if (thisProject.Civilopedia) then
				UpdateTextBlock( Locale.ConvertTextKey( thisProject.Civilopedia ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
			end
					
			-- update the related images
			Controls.RelatedImagesFrame:SetHide( true );
		end
	end

	ResizeEtc();

end

CivilopediaCategory[CategoryVirtues].SelectArticle = function( policyID, shouldAddToList )
	print("CivilopediaCategory[CategoryVirtues].SelectArticle");
	if m_selectedCategory ~= CategoryVirtues then
		SetSelectedCategory(CategoryVirtues, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryVirtues, policyID );
	end
	
	if policyID ~= -1 then
	
		local thisPolicy = GameInfo.Policies[policyID];
					
		-- update the name
		local name = Locale.ToUpper( thisPolicy.Description ); 	
		Controls.ArticleID:SetText( name );

		-- update the portrait
		if IconHookup( thisPolicy.PortraitIndex, portraitSize, thisPolicy.IconAtlas, Controls.Portrait ) then
			Controls.PortraitFrame:SetHide( false );
		else
			Controls.PortraitFrame:SetHide( true );
		end
		
		-- update the policy branch
		if thisPolicy.PolicyBranchType then
			local branch = GameInfo.PolicyBranchTypes[thisPolicy.PolicyBranchType];
			if branch then
				local branchName = Locale.ConvertTextKey( branch.Description ); 	
				Controls.PolicyBranchLabel:SetText( branchName );
				Controls.PolicyBranchFrame:SetHide( false );
				-- update the prereq era
				if branch.EraPrereq then
					local era = GameInfo.Eras[branch.EraPrereq];
					if era then
						local eraName = Locale.ConvertTextKey( era.Description ); 	
						Controls.PrereqEraLabel:SetText( eraName );
						Controls.PrereqEraFrame:SetHide( false );
					end
				end
			end
		end
				
		local contentSize;
		local frameSize = {};
		local buttonAdded = 0;

		-- update the prereq policies
		g_RequiredPoliciesManager:DestroyInstances();
		buttonAdded = 0;

		local condition = "PolicyType = '" .. thisPolicy.Type .. "'";

		for row in GameInfo.Policy_PrereqPolicies( condition ) do
			local requiredPolicy = GameInfo.Policies[row.PrereqPolicy];
			if requiredPolicy then
				local thisRequiredPolicyInstance = g_RequiredPoliciesManager:GetInstance();
				if thisRequiredPolicyInstance then
					local textureOffset, textureSheet = IconLookup( requiredPolicy.PortraitIndex, buttonSize, requiredPolicy.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisRequiredPolicyInstance.RequiredPolicyImage, thisRequiredPolicyInstance.RequiredPolicyButton, textureSheet, textureOffset, CategoryVirtues, Locale.ConvertTextKey( requiredPolicy.Description ), requiredPolicy.ID );
					buttonAdded = buttonAdded + 1;
				end
			end		
		end
		UpdateButtonFrame( buttonAdded, Controls.RequiredPoliciesInnerFrame, Controls.RequiredPoliciesFrame );
		
		local tenetLevelLabels = {
			"TXT_KEY_POLICYSCREEN_L1_TENET",
			"TXT_KEY_POLICYSCREEN_L2_TENET",
			"TXT_KEY_POLICYSCREEN_L3_TENET",
		}
		
		local tenetLevel = tonumber(thisPolicy.Level);
		if(tenetLevel ~= nil and tenetLevel > 0) then
			Controls.TenetLevelLabel:LocalizeAndSetText(tenetLevelLabels[tenetLevel]);
			Controls.TenetLevelFrame:SetHide(false);	
		else
			Controls.TenetLevelFrame:SetHide(true);
		end
		

		-- update the game info
		if thisPolicy.Help then
			UpdateTextBlock( Locale.ConvertTextKey( thisPolicy.Help ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
		else
			UpdateTextBlock( GetHelpTextForVirtue( policyID ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
		end
				
		-- update the strategy info
		--UpdateTextBlock( Locale.ConvertTextKey( thisPolicy.Strategy ), Controls.StrategyLabel, Controls.StrategyInnerFrame, Controls.StrategyFrame );
		
		-- update the historical info
		if (thisPolicy.Civilopedia) then
			UpdateTextBlock( Locale.ConvertTextKey( thisPolicy.Civilopedia ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
		end
		
		-- update the related images
		Controls.RelatedImagesFrame:SetHide( true );
	end

	ResizeEtc();

end


CivilopediaCategory[CategoryEspionage].SelectArticle =  function( conceptID, shouldAddToList )
	print("CivilopediaCategory[CategoryEspionage].SelectArticle");
	if m_selectedCategory ~= CategoryEspionage then
		SetSelectedCategory(CategoryEspionage, dontAddToList);
	end
	
	ClearArticle();
	
	local article = m_categorizedListOfArticles[(CategoryEspionage * MAX_ENTRIES_PER_CATEGORY) + conceptID];

	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryEspionage, conceptID );
	end
	
	if conceptID ~= -1 then
		local thisConcept = GameInfo.Concepts[conceptID];
		
		if thisConcept then
		
			-- update the name
			local name = Locale.ToUpper( thisConcept.Description ); 	
			Controls.ArticleID:SetText( name );
			
			-- portrait
			
			-- update the summary
			if thisConcept.Summary then
				UpdateSuperWideTextBlock( Locale.ConvertTextKey( thisConcept.Summary ), Controls.SummaryLabel, Controls.SummaryInnerFrame, Controls.SummaryFrame );
			end

			-- update perk
			if article.PlayerPerk and article.PlayerPerk.Description then
				UpdateSuperWideTextBlock( Locale.ConvertTextKey( article.PlayerPerk.Description ), Controls.ExtendedLabel, Controls.ExtendedInnerFrame, Controls.ExtendedFrame );
			end
			
			-- related images
			
			-- related concepts
		
		end

	end	

	ResizeEtc();
end


CivilopediaCategory[CategoryCivilizations].SelectArticle = function( rawCivID, shouldAddToList )
	print("CivilopediaCategory[CategoryCivilizations].SelectArticle");
	if m_selectedCategory ~= CategoryCivilizations then
		SetSelectedCategory(CategoryCivilizations, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryCivilizations, rawCivID );
	end

	if rawCivID < 1000 then
		if rawCivID ~= -1 then
		
			local thisCiv = GameInfo.Civilizations[rawCivID];
			if thisCiv and (thisCiv.Playable == true or thisCiv.AIPlayable == true) then
			--if thisCiv and thisCiv.Type ~= "CIVILIZATION_MINOR" and thisCiv.Type ~= "CIVILIZATION_ALIEN" and row.CivilizationType ~= "CIVILIZATION_NEUTRAL_PROXY" then
							
				-- update the name
				local name = Locale.ToUpper( thisCiv.ShortDescription )
				Controls.ArticleID:SetText( name );

				-- update the portrait
				if IconHookup( thisCiv.PortraitIndex, portraitSize, thisCiv.IconAtlas, Controls.Portrait ) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				local buttonAdded = 0;
		 		local condition = "CivilizationType = '" .. thisCiv.Type .. "'";
				
				-- add a list of leaders
				g_LeadersManager:DestroyInstances();
				buttonAdded = 0;
					
				local leader = nil;
				for leaderRow in GameInfo.Civilization_Leaders{CivilizationType = thisCiv.Type} do
					leader = GameInfo.Leaders[ leaderRow.LeaderheadType ];
				end
				local thisLeaderInstance = g_LeadersManager:GetInstance();
				if thisLeaderInstance then
					local textureOffset, textureSheet = IconLookup( leader.PortraitIndex, buttonSize, leader.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisLeaderInstance.LeaderImage, thisLeaderInstance.LeaderButton, textureSheet, textureOffset, CategoryCivilizations, Locale.ConvertTextKey( leader.Description ), thisCiv.ID + 1000 );
					buttonAdded = buttonAdded + 1;
				end	
				UpdateButtonFrame( buttonAdded, Controls.LeadersInnerFrame, Controls.LeadersFrame );
				
				-- list of UUs
 				g_UniqueUnitsManager:DestroyInstances();
				buttonAdded = 0;
				for thisOverride in GameInfo.Civilization_UnitClassOverrides( condition ) do
					if thisOverride.UnitType ~= nil then
						local thisUnitInfo = GameInfo.Units[thisOverride.UnitType];
						if thisUnitInfo then
							local thisUnitInstance = g_UniqueUnitsManager:GetInstance();
							if thisUnitInstance then
								local textureOffset, textureSheet = IconLookup( thisUnitInfo.PortraitIndex, buttonSize, thisUnitInfo.IconAtlas );				
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end			
								
								local unitCategory = CategoryUnits;
								local unitEntryID = thisUnitInfo.ID;
									
								UpdateSmallButton( buttonAdded, thisUnitInstance.UniqueUnitImage, thisUnitInstance.UniqueUnitButton, textureSheet, textureOffset, unitCategory, Locale.ConvertTextKey( thisUnitInfo.Description ), unitEntryID);
								buttonAdded = buttonAdded + 1;
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.UniqueUnitsInnerFrame, Controls.UniqueUnitsFrame );	 	  
				
				-- list of UBs
				g_UniqueBuildingsManager:DestroyInstances();
				buttonAdded = 0;
				for thisOverride in GameInfo.Civilization_BuildingClassOverrides( condition ) do
					if(thisOverride.BuildingType ~= nil) then
						local thisBuildingInfo = GameInfo.Buildings[thisOverride.BuildingType];
						if thisBuildingInfo then
							local thisBuildingInstance = g_UniqueBuildingsManager:GetInstance();
							if thisBuildingInstance then

								if not IconHookup( thisBuildingInfo.PortraitIndex, buttonSize, thisBuildingInfo.IconAtlas, thisBuildingInstance.UniqueBuildingImage ) then
									thisBuildingInstance.UniqueBuildingImage:SetTexture( defaultErrorTextureSheet );
									thisBuildingInstance.UniqueBuildingImage:SetTextureOffset( nullOffset );
								end
								
								--move this button
								thisBuildingInstance.UniqueBuildingButton:SetOffsetVal( (buttonAdded % numberOfButtonsPerRow) * buttonSize + buttonPadding, math.floor(buttonAdded / numberOfButtonsPerRow) * buttonSize + buttonPadding );
								
								thisBuildingInstance.UniqueBuildingButton:SetToolTipString( Locale.ConvertTextKey( thisBuildingInfo.Description ) );
								thisBuildingInstance.UniqueBuildingButton:SetVoids( thisBuildingInfo.ID, addToList );
								local thisBuildingClass = GameInfo.BuildingClasses[thisBuildingInfo.BuildingClass];
								if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and thisBuildingInfo.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
									thisBuildingInstance.UniqueBuildingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].SelectArticle );
								else
									thisBuildingInstance.UniqueBuildingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryBuildings].SelectArticle );
								end

								buttonAdded = buttonAdded + 1;
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.UniqueBuildingsInnerFrame, Controls.UniqueBuildingsFrame );
				
				-- list of unique improvements	 	  
				g_UniqueImprovementsManager:DestroyInstances();
				buttonAdded = 0;
				for thisImprovement in GameInfo.Improvements( condition ) do
					local thisImprovementInstance = g_UniqueImprovementsManager:GetInstance();
					if thisImprovementInstance then

						if not IconHookup( thisImprovement.PortraitIndex, buttonSize, thisImprovement.IconAtlas, thisImprovementInstance.UniqueImprovementImage ) then
							thisImprovementInstance.UniqueImprovementImage:SetTexture( defaultErrorTextureSheet );
							thisImprovementInstance.UniqueImprovementImage:SetTextureOffset( nullOffset );
						end
						
						--move this button
						thisImprovementInstance.UniqueImprovementButton:SetOffsetVal( (buttonAdded % numberOfButtonsPerRow) * buttonSize + buttonPadding, math.floor(buttonAdded / numberOfButtonsPerRow) * buttonSize + buttonPadding );
						
						thisImprovementInstance.UniqueImprovementButton:SetToolTipString( Locale.ConvertTextKey( thisImprovement.Description ) );
						thisImprovementInstance.UniqueImprovementButton:SetVoids( thisImprovement.ID, addToList );
						thisImprovementInstance.UniqueImprovementButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryImprovements].SelectArticle );

						buttonAdded = buttonAdded + 1;
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.UniqueImprovementsInnerFrame, Controls.UniqueImprovementsFrame );
				
				-- list of special abilities
				buttonAdded = 0;
				
				-- add the free form text
				g_FreeFormTextManager:DestroyInstances();
				
				local tagString = thisCiv.CivilopediaTag;
				if tagString then
					local headerString = tagString .. "_HEADING_";
					local bodyString = tagString .. "_TEXT_";
					local notFound = false;
					local i = 1;
					repeat
						local headerTag = headerString .. tostring( i );
						local bodyTag = bodyString .. tostring( i );
						if TagExists( headerTag ) and TagExists( bodyTag ) then
							local thisFreeFormTextInstance = g_FreeFormTextManager:GetInstance();
							if thisFreeFormTextInstance then
								thisFreeFormTextInstance.FFTextHeader:SetText( Locale.ConvertTextKey( headerTag ));
								UpdateTextBlock( Locale.ConvertTextKey( bodyTag ), thisFreeFormTextInstance.FFTextLabel, thisFreeFormTextInstance.FFTextInnerFrame, thisFreeFormTextInstance.FFTextFrame );
							end
						else
							notFound = true;		
						end
						i = i + 1;
					until notFound;

					local factoidHeaderString = tagString .. "_FACTOID_HEADING";
					local factoidBodyString = tagString .. "_FACTOID_TEXT";
					if TagExists( factoidHeaderString ) and TagExists( factoidBodyString ) then
						local thisFreeFormTextInstance = g_FreeFormTextManager:GetInstance();
						if thisFreeFormTextInstance then
							thisFreeFormTextInstance.FFTextHeader:SetText( Locale.ConvertTextKey( factoidHeaderString ));
							UpdateTextBlock( Locale.ConvertTextKey( factoidBodyString ), thisFreeFormTextInstance.FFTextLabel, thisFreeFormTextInstance.FFTextInnerFrame, thisFreeFormTextInstance.FFTextFrame );
						end
					end
					
					Controls.FFTextStack:SetHide( false );

				end	
				
				-- update the related images
				Controls.RelatedImagesFrame:SetHide( true );
			end
		end
	else
		local civID = rawCivID - 1000;
		if civID ~= -1 then
		
			local thisCiv = GameInfo.Civilizations[civID];
			if thisCiv and (thisCiv.Playable == true or thisCiv.AIPlayable == true) then
			--if thisCiv and thisCiv.Type ~= "CIVILIZATION_MINOR" and thisCiv.Type ~= "CIVILIZATION_ALIEN" and row.CivilizationType ~= "CIVILIZATION_NEUTRAL_PROXY" then
							
				local leader = nil;
				for leaderRow in GameInfo.Civilization_Leaders{CivilizationType = thisCiv.Type} do
					leader = GameInfo.Leaders[ leaderRow.LeaderheadType ];
				end

				-- update the name
				local tagString = leader.CivilopediaTag;
				if tagString then
					local name = Locale.ToUpper( tagString.."_NAME" );
					Controls.ArticleID:SetText( name );
					Controls.SubtitleLabel:SetText( Locale.ConvertTextKey( tagString.."_SUBTITLE" ) );
					Controls.SubtitleID:SetHide( false );
				else
					local name = Locale.ToUpper( leader.Description )
					Controls.ArticleID:SetText( name );
				end

				-- update the portrait
				if IconHookup( leader.PortraitIndex, portraitSize, leader.IconAtlas, Controls.Portrait ) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				local buttonAdded = 0;
				
				-- add titles etc.
				if tagString then

					local livedKey = tagString .. "_LIVED";
					if(Locale.HasTextKey(livedKey)) then
						Controls.LivedLabel:SetText( Locale.ConvertTextKey( livedKey ) );
						Controls.LivedFrame:SetHide( false );
					else
						Controls.LivedFrame:SetHide(true);
					end
				
					local titlesString = tagString .. "_TITLES_";
					local notFound = false;
					local i = 1;
					local titles = "";
					local numTitles = 0;
					repeat
						local titlesTag = titlesString .. tostring( i );
						if TagExists( titlesTag ) then
							if numTitles > 0 then
								titles = titles .. "[NEWLINE][NEWLINE]";
							end
							numTitles = numTitles + 1;
							titles = titles .. Locale.ConvertTextKey( titlesTag );
						else
							notFound = true;		
						end
						i = i + 1;
					until notFound;
					if numTitles > 0 then
						UpdateNarrowTextBlock( Locale.ConvertTextKey( titles ), Controls.TitlesLabel, Controls.TitlesInnerFrame, Controls.TitlesFrame );
					end
				end

 				local condition = "LeaderType = '" .. leader.Type .. "'";
								--
				-- add the civ icon
				g_CivilizationsManager:DestroyInstances();
				buttonAdded = 0;
				local thisCivInstance = g_CivilizationsManager:GetInstance();
				if thisCivInstance then
					local textureOffset, textureSheet = IconLookup( thisCiv.PortraitIndex, buttonSize, thisCiv.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisCivInstance.CivilizationImage, thisCivInstance.CivilizationButton, textureSheet, textureOffset, CategoryCivilizations, Locale.ConvertTextKey( thisCiv.ShortDescription ), thisCiv.ID );
					buttonAdded = buttonAdded + 1;
				end	
				UpdateButtonFrame( buttonAdded, Controls.CivilizationsInnerFrame, Controls.CivilizationsFrame );
						
				-- update the game info
				local personalityInfo = GameInfo.Personalities[thisCiv.Personality];
				if (personalityInfo ~= nil) then
					local uniqueTrait = GameInfo.PersonalityTraits[personalityInfo.UniquePersonalityTrait];
					if (uniqueTrait ~= nil) then
						local traitString = "[COLOR_CYAN]"..Locale.Lookup(uniqueTrait.Description).."[ENDCOLOR][NEWLINE]"..Locale.Lookup(uniqueTrait.Help);
						UpdateTextBlock( traitString, Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
					end
				end
										
				-- add the free form text
				g_FreeFormTextManager:DestroyInstances();
				if tagString then
					local headerString = tagString .. "_HEADING_";
					local bodyString = tagString .. "_TEXT_";
					local notFound = false;
					local i = 1;
					repeat
						local headerTag = headerString .. tostring( i );
						local bodyTag = bodyString .. tostring( i );
						if TagExists( headerTag ) and TagExists( bodyTag ) then
							local thisFreeFormTextInstance = g_FreeFormTextManager:GetInstance();
							if thisFreeFormTextInstance then
								thisFreeFormTextInstance.FFTextHeader:SetText( Locale.ConvertTextKey( headerTag ));
								UpdateTextBlock( Locale.ConvertTextKey( bodyTag ), thisFreeFormTextInstance.FFTextLabel, thisFreeFormTextInstance.FFTextInnerFrame, thisFreeFormTextInstance.FFTextFrame );
							end
						else
							notFound = true;		
						end
						i = i + 1;
					until notFound;
					
					notFound = false;
					i = 1;
					repeat
						local bodyString = tagString .. "_FACT_";
						local bodyTag = bodyString .. tostring( i );
						if TagExists( bodyTag ) then
							local thisFreeFormTextInstance = g_FreeFormTextManager:GetInstance();
							if thisFreeFormTextInstance then
								thisFreeFormTextInstance.FFTextHeader:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_FACTOID" ));
								UpdateTextBlock( Locale.ConvertTextKey( bodyTag ), thisFreeFormTextInstance.FFTextLabel, thisFreeFormTextInstance.FFTextInnerFrame, thisFreeFormTextInstance.FFTextFrame );
							end
						else
							notFound = true;		
						end
						i = i + 1;
					until notFound;
											
					Controls.FFTextStack:SetHide( false );

				end
				
				-- update the related images
				Controls.RelatedImagesFrame:SetHide( true );

			end
		end
	end

	ResizeEtc();

end

CivilopediaCategory[CategoryQuests].SelectArticle = function( conceptID, shouldAddToList )
	print("CivilopediaCategory[CategoryQuests].SelectArticle");
	if m_selectedCategory ~= CategoryQuests then
		SetSelectedCategory(CategoryQuests, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryQuests, conceptID );
	end
	
	if conceptID ~= -1 then
		local thisConcept = GameInfo.Concepts[conceptID];
		
		if thisConcept then
		
			-- update the name
			local name = Locale.ToUpper( thisConcept.Description ); 	
			Controls.ArticleID:SetText( name );
			
			-- portrait
			
			-- update the summary
			if thisConcept.Summary then
				UpdateSuperWideTextBlock( Locale.ConvertTextKey( thisConcept.Summary ), Controls.SummaryLabel, Controls.SummaryInnerFrame, Controls.SummaryFrame );
			end
			
			-- related images
			
			-- related concepts
		
		end

	end	

	ResizeEtc();
end


CivilopediaCategory[CategoryTerrain].SelectArticle = function( rawTerrainID, shouldAddToList )
	print("CivilopediaCategory[CategoryTerrain].SelectArticle");
	if m_selectedCategory ~= CategoryTerrain then
		SetSelectedCategory(CategoryTerrain, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryTerrain, rawTerrainID );
	end

	-- Terrains
	if rawTerrainID < 1000 then
		local terrainId = rawTerrainID;
		if terrainId ~= -1 then
		
			local thisTerrain = GameInfo.Terrains[terrainId];
			if thisTerrain then

				-- update the name
				local name = Locale.ToUpper( thisTerrain.Description )
				Controls.ArticleID:SetText( name );

				-- update the portrait
				if IconHookup( thisTerrain.PortraitIndex, portraitSize, thisTerrain.IconAtlas, Controls.Portrait ) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				local buttonAdded = 0;
		 		local condition = "TerrainType = '" .. thisTerrain.Type .. "'";
				
				-- Modernization of Yield ---------------------- PW
				local ModernYieldLines = {};
				
					-- by Buildings
				for row in GameInfo.Building_TerrainYieldChanges( condition ) do
					-- if row.Yield ~= 0 and row.Effect ~= true then
					if row.Yield ~= 0 then
						local thisBuildingClass = GameInfo.BuildingClasses[GameInfo.Buildings[row.BuildingType].BuildingClass];
						if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and prereqMbuilding.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
							table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_SECRET_PROJ_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Buildings[row.BuildingType].Description));
						else
							table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_BUILDING_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Buildings[row.BuildingType].Description));
						end	
					end
				end		

				if thisTerrain.EffectTypeTag == "WATER" then
					for row in GameInfo.Building_SeaPlotYieldChanges() do
						if row.Yield ~= 0 then
							local thisBuildingClass = GameInfo.BuildingClasses[GameInfo.Buildings[row.BuildingType].BuildingClass];
							if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and prereqMbuilding.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
								table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_SECRET_PROJ_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Buildings[row.BuildingType].Description));
							else
								table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_BUILDING_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Buildings[row.BuildingType].Description));
							end	
						end	
					end		
				end

				if #ModernYieldLines > 0 then
					ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(ModernYieldLines, "[NEWLINE]") ), Controls.ModernYieldLabel, Controls.ModernYieldInnerFrame, Controls.ModernYieldFrame  );
				else
					-- ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ), Controls.ModernYieldLabel, Controls.ModernYieldInnerFrame, Controls.ModernYieldFrame );
				end	
				-- Modernization of Yield ---------------------- PW	

				---- PW update the PREQ buildings
				g_RequiredBuildingsManager:DestroyInstances();
				buttonAdded = 0;
				local canceldouble;
				for row in GameInfo.Building_TerrainYieldChanges( condition ) do
					local prereqMbuilding = GameInfo.Buildings[row.BuildingType];	
					if prereqMbuilding and prereqMbuilding.Effect ~= true then
						if prereqMbuilding.ID ~= canceldouble then 
							local thisPrereqInstance = g_RequiredBuildingsManager:GetInstance();
							if thisPrereqInstance then
								
								local textureOffset, textureSheet = IconLookup( prereqMbuilding.PortraitIndex, buttonSize, prereqMbuilding.IconAtlas );		
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end	
								
								local thisBuildingClass = GameInfo.BuildingClasses[prereqMbuilding.BuildingClass];
								if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and prereqMbuilding.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
									UpdateSmallButton( buttonAdded, thisPrereqInstance.RequiredBuildingImage, thisPrereqInstance.RequiredBuildingButton, textureSheet, textureOffset, CategoryWonders, Locale.ConvertTextKey( prereqMbuilding.Description ), prereqMbuilding.ID );
								else
									UpdateSmallButton( buttonAdded, thisPrereqInstance.RequiredBuildingImage, thisPrereqInstance.RequiredBuildingButton, textureSheet, textureOffset, CategoryBuildings, Locale.ConvertTextKey( prereqMbuilding.Description ), prereqMbuilding.ID );
								end

								buttonAdded = buttonAdded + 1;	
								canceldouble = prereqMbuilding.ID						
							end
						end
					end
				end
				
				canceldouble = 0;
				if thisTerrain.EffectTypeTag == "WATER" then
					for row in GameInfo.Building_SeaPlotYieldChanges() do
						local prereqMbuilding = GameInfo.Buildings[row.BuildingType];	
						if prereqMbuilding and prereqMbuilding.Effect ~= true then
							if prereqMbuilding.ID ~= canceldouble then 
								local thisPrereqInstance = g_RequiredBuildingsManager:GetInstance();
								if thisPrereqInstance then
									
									local textureOffset, textureSheet = IconLookup( prereqMbuilding.PortraitIndex, buttonSize, prereqMbuilding.IconAtlas );		
									if textureOffset == nil then
										textureSheet = defaultErrorTextureSheet;
										textureOffset = nullOffset;
									end	
									
									local thisBuildingClass = GameInfo.BuildingClasses[prereqMbuilding.BuildingClass];
									if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and prereqMbuilding.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
										UpdateSmallButton( buttonAdded, thisPrereqInstance.RequiredBuildingImage, thisPrereqInstance.RequiredBuildingButton, textureSheet, textureOffset, CategoryWonders, Locale.ConvertTextKey( prereqMbuilding.Description ), prereqMbuilding.ID );
									else
										UpdateSmallButton( buttonAdded, thisPrereqInstance.RequiredBuildingImage, thisPrereqInstance.RequiredBuildingButton, textureSheet, textureOffset, CategoryBuildings, Locale.ConvertTextKey( prereqMbuilding.Description ), prereqMbuilding.ID );
									end

									buttonAdded = buttonAdded + 1;	
									canceldouble = prereqMbuilding.ID						
								end
							end
						end
					end		
				end
				
				UpdateButtonFrame( buttonAdded, Controls.RequiredBuildingsInnerFrame, Controls.RequiredBuildingsFrame );
				
				-- City Yield
				Controls.YieldFrame:SetHide( false );
				local yieldLines = {};
				for row in GameInfo.Terrain_Yields( condition ) do
					table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description));
				end
				-- special case hackery for hills
				if thisTerrain.Type == "TERRAIN_HILL" then
					local iconString = GameInfo.Yields["YIELD_PRODUCTION"].IconString;
					local description =  GameInfo.Yields["YIELD_PRODUCTION"].Description;

					table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", tostring(1), iconString, description));
				end
				
				if #yieldLines > 0 then
					ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(yieldLines, ", ") ), Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame  );
				else
					ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ) , Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame  );
				end
				
				-- Movement
				Controls.MovementCostFrame:SetHide( false );
				local moveCost = thisTerrain.Movement;
				-- special case hackery for hills
				if thisTerrain.Type == "TERRAIN_HILL" then
					moveCost = moveCost + GameDefines.HILLS_EXTRA_MOVEMENT;
				end
				if thisTerrain.Type == "TERRAIN_MOUNTAIN" then
					Controls.MovementCostLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPASSABLE" ) );
				else
					Controls.MovementCostLabel:SetText( Locale.ConvertTextKey( moveCost ).."[ICON_MOVES]" );
				end

				-- Combat Modifier
				Controls.CombatModFrame:SetHide( false );
				local combatModifier = 0;
				local combatModString = "";
				if thisTerrain.Type == "TERRAIN_HILL" or thisTerrain.Type == "TERRAIN_MOUNTAIN" then
					combatModifier = GameDefines.HILLS_EXTRA_DEFENSE;
				elseif thisTerrain.Water then
					combatModifier = 0;
				else
					combatModifier = GameDefines.FLAT_LAND_EXTRA_DEFENSE;
				end
				if combatModifier > 0 then
					combatModString = "+";
				end
				combatModString = combatModString..tostring(combatModifier).."%";
				Controls.CombatModLabel:SetText( combatModString );

				-- Features that can exist on this terrain
 				g_FeaturesManager:DestroyInstances();
				buttonAdded = 0;
				for row in GameInfo.Feature_TerrainBooleans( condition ) do
					local thisFeature = GameInfo.Features[row.FeatureType];
					if thisFeature then
						local thisFeatureInstance = g_FeaturesManager:GetInstance();
						if thisFeatureInstance then
							local textureOffset, textureSheet = IconLookup( thisFeature.PortraitIndex, buttonSize, thisFeature.IconAtlas );				
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end				
							UpdateSmallButton( buttonAdded, thisFeatureInstance.FeatureImage, thisFeatureInstance.FeatureButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisFeature.Description ), thisFeature.ID + 1000 ); -- todo: add a fudge factor
							buttonAdded = buttonAdded + 1;
						end
					end
				end
				Controls.FeaturesFrameLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_FEATURES_LABEL" ) ); -- PW
				UpdateButtonFrame( buttonAdded, Controls.FeaturesInnerFrame, Controls.FeaturesFrame );	 	  

				-- Resources that can exist on this terrain
				local resourcesShown = {};
				Controls.ResourcesFoundLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_RESOURCESFOUND_LABEL" ) );
 				g_ResourcesFoundManager:DestroyInstances();
				buttonAdded = 0;
				for row in GameInfo.Resource_TerrainBooleans( condition ) do
					local thisResource = GameInfo.Resources[row.ResourceType];
					if thisResource and thisResource.ShowInCivilopedia then
						local thisResourceInstance = g_ResourcesFoundManager:GetInstance();
						if thisResourceInstance then
							local textureOffset, textureSheet = IconLookup( thisResource.PortraitIndex, buttonSize, thisResource.IconAtlas );				
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end				
							resourcesShown[row.ResourceType] = true;
							UpdateSmallButton( buttonAdded, thisResourceInstance.ResourceFoundImage, thisResourceInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryResources, Locale.ConvertTextKey( thisResource.Description ), thisResource.ID );
							buttonAdded = buttonAdded + 1;
						end
					end
				end
				-- special case hackery for hills
				if thisTerrain.Type == "TERRAIN_HILL" then
					for thisResource in GameInfo.Resources() do
						if thisResource and thisResource.Hills and thisResource.ShowInCivilopedia then
							if( resourcesShown[thisResource.ID] == nil ) then
								local thisResourceInstance = g_ResourcesFoundManager:GetInstance();
								if thisResourceInstance then
									local textureOffset, textureSheet = IconLookup( thisResource.PortraitIndex, buttonSize, thisResource.IconAtlas );				
									if textureOffset == nil then
										textureSheet = defaultErrorTextureSheet;
										textureOffset = nullOffset;
									end				
									UpdateSmallButton( buttonAdded, thisResourceInstance.ResourceFoundImage, thisResourceInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryResources, Locale.ConvertTextKey( thisResource.Description ), thisResource.ID );
									buttonAdded = buttonAdded + 1;
								end
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.ResourcesFoundInnerFrame, Controls.ResourcesFoundFrame );	 	  

				-- generic text
				if (thisTerrain.Civilopedia) then
					UpdateTextBlock( Locale.ConvertTextKey( thisTerrain.Civilopedia ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
				end
				
				-- update the related images
				Controls.RelatedImagesFrame:SetHide( true );
			end
		end

	-- Features
	elseif rawTerrainID < 3000 then
		local featureID = rawTerrainID - 1000;
		if featureID ~= -1 then
		
			local thisFeature;
			if featureID < 1000 then
				thisFeature = GameInfo.Features[featureID];
			else
				thisFeature = GameInfo.FakeFeatures[featureID-1000];
			end
			if thisFeature then

				-- update the name
				local name = Locale.ToUpper( thisFeature.Description )
				Controls.ArticleID:SetText( name );

				-- update the portrait
				if IconHookup( thisFeature.PortraitIndex, portraitSize, thisFeature.IconAtlas, Controls.Portrait ) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				local buttonAdded = 0;
		 		local condition = "FeatureType = '" .. thisFeature.Type .. "'";
				
				-- City Yield
				Controls.YieldFrame:SetHide( false );
				local yieldLines = {};
				for row in GameInfo.Feature_YieldChanges( condition ) do
					table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description));
				end				
				-- add Health
				if thisFeature.InBorderHealth and thisFeature.InBorderHealth ~= 0 then
					table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", thisFeature.InBorderHealth, "[ICON_HEALTH_1]", "TXT_KEY_TOPIC_HEALTH"));
				end

				if #yieldLines > 0 then
					ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(yieldLines, ", ") ), Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame  );
				else
					ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ), Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame  );
				end
				
				-- Movement
				Controls.MovementCostFrame:SetHide( false );
				local moveCost = thisFeature.Movement;
				if thisFeature.Impassable then
					Controls.MovementCostLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPASSABLE" ) );
				elseif (moveCost ~= nil and tonumber(moveCost) ~= 0) then
					Controls.MovementCostLabel:SetText( Locale.ConvertTextKey( moveCost ).."[ICON_MOVES]" );
				else
					Controls.MovementCostFrame:SetHide( true );
				end

				-- Combat Modifier
				Controls.CombatModFrame:SetHide( false );
				if (thisFeature.Defense ~= 0  or thisFeature.Type == "FEATURE_RIVER") then
					local defense = thisFeature.Defense;
					if(thisFeature.Type == "FEATURE_RIVER") then
						local additionalModifier = GameDefines.RIVER_ATTACK_MODIFIER;
						if(additionalModifier ~= nil) then
							defense = defense + additionalModifier;
						end
					end

					local combatModString = tostring(defense) .. "%";
					if(defense > 0) then
						combatModString = "+" .. combatModString;
					end 
					Controls.CombatModLabel:SetText( combatModString );
				else
					Controls.CombatModFrame:SetHide( true );
				end

				-- Terrains that can carry this feature
 				g_FeaturesManager:DestroyInstances();
				buttonAdded = 0;
				for row in GameInfo.Feature_TerrainBooleans( condition ) do
					-- local thisTerrain = GameInfo.Features[row.TerrainType]; -- PW fixed bug
					local thisTerrain = GameInfo.Terrains[row.TerrainType];
					if thisTerrain then
						local thisTerrainInstance = g_FeaturesManager:GetInstance();
						if thisTerrainInstance then
							local textureOffset, textureSheet = IconLookup( thisTerrain.PortraitIndex, buttonSize, thisTerrain.IconAtlas );				
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end				
							UpdateSmallButton( buttonAdded, thisTerrainInstance.FeatureImage, thisTerrainInstance.FeatureButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisTerrain.Description ), thisTerrain.ID );
							buttonAdded = buttonAdded + 1;
						end
					end
				end
				-- UpdateButtonFrame( buttonAdded, Controls.TerrainsInnerFrame, Controls.TerrainsFrame ); -- PW fixed bug	
				Controls.FeaturesFrameLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_FEATURES_ON_TER_LABEL" ) ); 	  
				UpdateButtonFrame( buttonAdded, Controls.FeaturesInnerFrame, Controls.FeaturesFrame );	 	  

				-- Resources that can exist on this feature
				Controls.ResourcesFoundLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_RESOURCESFOUND_LABEL" ) );
  				g_ResourcesFoundManager:DestroyInstances();
				buttonAdded = 0;
				for row in GameInfo.Resource_FeatureBooleans( condition ) do
					local thisResource = GameInfo.Resources[row.ResourceType];
					if thisResource and thisResource.ShowInCivilopedia then
						local thisResourceInstance = g_ResourcesFoundManager:GetInstance();
						if thisResourceInstance then
							local textureOffset, textureSheet = IconLookup( thisResource.PortraitIndex, buttonSize, thisResource.IconAtlas );				
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end				
							UpdateSmallButton( buttonAdded, thisResourceInstance.ResourceFoundImage, thisResourceInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryResources, Locale.ConvertTextKey( thisResource.Description ), thisResource.ID );
							buttonAdded = buttonAdded + 1;
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.ResourcesFoundInnerFrame, Controls.ResourcesFoundFrame );	 	  

				---- PW update the PREQ buildings
				g_RequiredBuildingsManager:DestroyInstances();
				buttonAdded = 0;
				local canceldouble;
				for row in GameInfo.Building_FeatureYieldChanges( condition ) do
					local prereqMbuilding = GameInfo.Buildings[row.BuildingType];	
					if prereqMbuilding and prereqMbuilding.Effect ~= true then
						if prereqMbuilding.ID ~= canceldouble then 
							local thisPrereqInstance = g_RequiredBuildingsManager:GetInstance();
							if thisPrereqInstance then
								
								local textureOffset, textureSheet = IconLookup( prereqMbuilding.PortraitIndex, buttonSize, prereqMbuilding.IconAtlas );		
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end	
								
								local thisBuildingClass = GameInfo.BuildingClasses[prereqMbuilding.BuildingClass];
								if thisBuildingClass.MaxGlobalInstances > 0 or (thisBuildingClass.MaxPlayerInstances == 1 and prereqMbuilding.SpecialistCount == 0) or thisBuildingClass.MaxTeamInstances > 0 then
									UpdateSmallButton( buttonAdded, thisPrereqInstance.RequiredBuildingImage, thisPrereqInstance.RequiredBuildingButton, textureSheet, textureOffset, CategoryWonders, Locale.ConvertTextKey( prereqMbuilding.Description ), prereqMbuilding.ID );
								else
									UpdateSmallButton( buttonAdded, thisPrereqInstance.RequiredBuildingImage, thisPrereqInstance.RequiredBuildingButton, textureSheet, textureOffset, CategoryBuildings, Locale.ConvertTextKey( prereqMbuilding.Description ), prereqMbuilding.ID );
								end

								buttonAdded = buttonAdded + 1;	
								canceldouble = prereqMbuilding.ID						
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.RequiredBuildingsInnerFrame, Controls.RequiredBuildingsFrame );

				---- modernization tech preqs
				g_PrereqTechManager:DestroyInstances();
				buttonAdded = 0;
				local canceldouble;
				for row in GameInfo.Feature_TechYieldChanges( condition ) do
					local prereqMtech = GameInfo.Technologies[row.TechType];	
					if prereqMtech then
						if prereqMtech.ID ~= canceldouble then 
							local thisPrereqInstance = g_PrereqTechManager:GetInstance();
							if thisPrereqInstance then
								local textureOffset, textureSheet = IconLookup( prereqMtech.PortraitIndex, buttonSize, prereqMtech.IconAtlas );		
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end	
								UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqTechImage, thisPrereqInstance.PrereqTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereqMtech.Description ), prereqMtech.ID );
								buttonAdded = buttonAdded + 1;	
								canceldouble = prereqMtech.ID						
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.PrereqTechInnerFrame, Controls.PrereqTechFrame );

				-- Modernization of Yield ---------------------- PW
				local ModernYieldLines = {};
				
					-- by tech
				for row in GameInfo.Feature_TechYieldChanges( condition ) do
					if row.Yield ~= 0 then
						table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_TECH_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Technologies[row.TechType].Description));
					end
				end	
				
					-- by Buildings
				for row in GameInfo.Building_FeatureYieldChanges( condition ) do
					if row.Yield ~= 0 and row.Effect ~= true then
						table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_BUILDING_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Buildings[row.BuildingType].Description));
					end
				end	
				
					-- by policy
				-- for row in GameInfo.Policy_ImprovementYieldChanges( condition ) do
					-- if row.Yield > 0 then
						-- table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_POLICY_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Policies[row.PolicyType].Description));
					-- end
				-- end	
				
					-- by affinity
				-- for row in GameInfo.PlayerPerks_ImprovementYieldEffects( condition ) do
					-- local conditionPerk = "PlayerPerk = '" .. row.PlayerPerkType .. "'";
					-- for prereqAff in GameInfo.Affinity_Perks( conditionPerk ) do
						-- if prereqAff then
							-- if row.FlatYield > 0 then
								-- local AffReqLev = "[COLOR_HARMONY_AFFINITY]"..tostring(prereqAff.HarmonyLevelNeeded).."[ENDCOLOR]/[COLOR_PURITY_AFFINITY]"..tostring(prereqAff.PurityLevelNeeded).."[ENDCOLOR]/[COLOR_SUPREMACY_AFFINITY]"..tostring(prereqAff.SupremacyLevelNeeded).."[ENDCOLOR]"
								-- table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_AFFINITY_YIELD_CHANGE", row.FlatYield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, AffReqLev));
							-- end
							-- if row.FlatHealth > 0 then
								-- local AffReqLev = "[COLOR_HARMONY_AFFINITY]"..tostring(prereqAff.HarmonyLevelNeeded).."[ENDCOLOR]/[COLOR_PURITY_AFFINITY]"..tostring(prereqAff.PurityLevelNeeded).."[ENDCOLOR]/[COLOR_SUPREMACY_AFFINITY]"..tostring(prereqAff.SupremacyLevelNeeded).."[ENDCOLOR]"
								-- table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_AFFINITY_YIELD_CHANGE", row.FlatHealth, "[ICON_HEALTH]", "TXT_KEY_HEALTH", AffReqLev));
							-- end
						-- end				
					-- end				
				-- end				

				if #ModernYieldLines > 0 then
					ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(ModernYieldLines, "[NEWLINE]") ), Controls.ModernYieldLabel, Controls.ModernYieldInnerFrame, Controls.ModernYieldFrame  );
				else
					-- ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ), Controls.ModernYieldLabel, Controls.ModernYieldInnerFrame, Controls.ModernYieldFrame );
				end	
				-- Modernization of Yield ---------------------- PW	

				if(featureID < 1000) then
					-- generic text
					if (thisFeature.Help) then
						UpdateTextBlock( Locale.ConvertTextKey( thisFeature.Help ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
					end
					
					if (thisFeature.Civilopedia) then
						UpdateTextBlock( Locale.ConvertTextKey( thisFeature.Civilopedia ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
					end			
				else
					if (thisFeature.Civilopedia) then
						UpdateTextBlock( Locale.ConvertTextKey( thisFeature.Civilopedia ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
					end				
				end
				
				-- update the related images
				Controls.RelatedImagesFrame:SetHide( true );
			end

		end
	-- Panets
	elseif rawTerrainID < 4000 then
		local planetID = rawTerrainID - 3000;
		if planetID ~= -1 then
			local planetInfo = GameInfo.Planets[planetID];
			if planetInfo then

				-- Name
				local name = Locale.ToUpper( planetInfo.Description )
				Controls.ArticleID:SetText( name );

				-- Summary
				for effectRow in GameInfo.PlanetEffects{ PlanetType = planetInfo.Type } do
					UpdateTextBlock( Locale.Lookup(effectRow.ToolTip), Controls.SummaryLabel, Controls.SummaryInnerFrame, Controls.SummaryFrame );
				end

				-- Portrait
				if IconHookup( planetInfo.PortraitIndex, portraitSize, planetInfo.IconAtlas, Controls.Portrait ) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				-- Game Info
				UpdateTextBlock( Locale.Lookup(planetInfo.ToolTip), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );

				-- History
				UpdateTextBlock( Locale.Lookup(planetInfo.Civilopedia), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame);
			end
		end
	-- Marvels
	elseif rawTerrainID < 5000 then
		local marvelID = rawTerrainID - 4000;
		if marvelID ~= -1 then
			local marvelInfo = GameInfo.Marvels[marvelID];
			local heroLandmarkInfo = GameInfo.HeroLandmarks[marvelInfo.MajorMarvelLandmark];
			local minorMarvelImprovementInfo = GameInfo.Improvements[marvelInfo.MinorMarvelImprovement];
			if marvelInfo and heroLandmarkInfo and minorMarvelImprovementInfo then

				-- Name
				local name = Locale.ToUpper( heroLandmarkInfo.Description )
				Controls.ArticleID:SetText( name );

				-- Summary
				UpdateTextBlock( Locale.Lookup(marvelInfo.MajorMarvelSummary), Controls.SummaryLabel, Controls.SummaryInnerFrame, Controls.SummaryFrame );

				-- Portrait
				if IconHookup( minorMarvelImprovementInfo.MinorMarvelUnusedFlagIconIndex, portraitSize, minorMarvelImprovementInfo.MinorMarvelUnusedFlagIconAtlas, Controls.Portrait ) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				-- Game Info
				UpdateTextBlock( Locale.Lookup(marvelInfo.MajorMarvelGameInfo), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
			end
		end
	end

	ResizeEtc();

end


CivilopediaCategory[CategoryResources].SelectArticle = function( resourceID, shouldAddToList )
	print("CivilopediaCategory[CategoryResources].SelectArticle");
	if m_selectedCategory ~= CategoryResources then
		SetSelectedCategory(CategoryResources, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryResources, resourceID );
	end

	local altResourceID = -1;
	if(resourceID >= 65536) then
		altResourceID = ((resourceID - (resourceID % 65536)) / 65536) - 1;
		resourceID = resourceID % 65536;
	end

	if resourceID ~= -1 then
	
		local thisResource = GameInfo.Resources[resourceID];
		local altResource = nil;
		if(altResourceID ~= -1) then
			altResource = GameInfo.Resources[altResourceID];
		end

		if thisResource and thisResource.ShowInCivilopedia then

			-- update the name
			local name = Locale.ToUpper( thisResource.Description )
			Controls.ArticleID:SetText( name );

			-- update the portrait
			if IconHookup( thisResource.PortraitIndex, portraitSize, thisResource.IconAtlas, Controls.Portrait ) then
				Controls.PortraitFrame:SetHide( false );
			else
				Controls.PortraitFrame:SetHide( true );
			end

			local buttonAdded = 0;
	 		local condition = "ResourceType = '" .. thisResource.Type .. "'";
			local altCondition = "";
			
			if( altResource ~= nil ) then
				altCondition = "or ResourceType = '" .. altResource.Type .. "'";
			end
			
			-- tech visibility
			g_RevealTechsManager:DestroyInstances();
			buttonAdded = 0;
			if thisResource.TechReveal then
				local prereq = GameInfo.Technologies[thisResource.TechReveal];
				local thisPrereqInstance = g_RevealTechsManager:GetInstance();
				if thisPrereqInstance then
					local textureOffset, textureSheet = IconLookup( prereq.PortraitIndex, buttonSize, prereq.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisPrereqInstance.RevealTechImage, thisPrereqInstance.RevealTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereq.Description ), prereq.ID );
					buttonAdded = buttonAdded + 1;
				end			
				UpdateButtonFrame( buttonAdded, Controls.RevealTechsInnerFrame, Controls.RevealTechsFrame );
			end

			-- City Yield
			Controls.YieldFrame:SetHide( false );
			
			local yieldLines = {};
			for row in GameInfo.Resource_YieldChanges( condition ) do
				if row.Yield > 0 then
					table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description));
				end
			end

			if #yieldLines > 0 then
				ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(yieldLines, ", ") ), Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame  );
			else
				ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ), Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame  );
			end

			-- found on
			Controls.ResourcesFoundLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAINS_LABEL" ) );
			g_ResourcesFoundManager:DestroyInstances(); -- okay, this is supposed to be a resource, but for now a round button is a round button
			buttonAdded = 0;
			for row in GameInfo.Resource_FeatureBooleans( condition .. altCondition ) do
				local thisFeature = GameInfo.Features[row.FeatureType];
				if thisFeature then
					local thisFeatureInstance = g_ResourcesFoundManager:GetInstance();
					if thisFeatureInstance then
						local textureOffset, textureSheet = IconLookup( thisFeature.PortraitIndex, buttonSize, thisFeature.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end				
						UpdateSmallButton( buttonAdded, thisFeatureInstance.ResourceFoundImage, thisFeatureInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisFeature.Description ), thisFeature.ID + 1000 ); -- todo: add a fudge factor
						buttonAdded = buttonAdded + 1;
					end
				end
			end
			
			local bAlreadyShowingHills = false;
			for row in GameInfo.Resource_TerrainBooleans( condition .. altCondition ) do
				local thisTerrain = GameInfo.Terrains[row.TerrainType];
				if thisTerrain then
					local thisTerrainInstance = g_ResourcesFoundManager:GetInstance();
					if thisTerrainInstance then
						if(row.TerrainType == "TERRAIN_HILL") then
							bAlreadyShowingHills = true;
						end
					
						local textureOffset, textureSheet = IconLookup( thisTerrain.PortraitIndex, buttonSize, thisTerrain.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end				
						UpdateSmallButton( buttonAdded, thisTerrainInstance.ResourceFoundImage, thisTerrainInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisTerrain.Description ), thisTerrain.ID );
						buttonAdded = buttonAdded + 1;
					end
				end
			end

			-- hackery for hills
			if thisResource and thisResource.Hills and not bAlreadyShowingHills then
				local thisTerrain = GameInfo.Terrains["TERRAIN_HILL"];
				local thisTerrainInstance = g_ResourcesFoundManager:GetInstance();
				if thisTerrainInstance then
					local textureOffset, textureSheet = IconLookup( thisTerrain.PortraitIndex, buttonSize, thisTerrain.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( buttonAdded, thisTerrainInstance.ResourceFoundImage, thisTerrainInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisTerrain.Description ), thisTerrain.ID );
					buttonAdded = buttonAdded + 1;
				end
			end
			UpdateButtonFrame( buttonAdded, Controls.ResourcesFoundInnerFrame, Controls.ResourcesFoundFrame );	 	  
			
			-- improvement
			g_ImprovementsManager:DestroyInstances();
			buttonAdded = 0;
			for row in GameInfo.Improvement_ResourceTypes( condition ) do
				local thisImprovement = GameInfo.Improvements[row.ImprovementType];
				if thisImprovement then
					local thisImprovementInstance = g_ImprovementsManager:GetInstance();
					if thisImprovementInstance then
						local textureOffset, textureSheet = IconLookup( thisImprovement.PortraitIndex, buttonSize, thisImprovement.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end				
						UpdateSmallButton( buttonAdded, thisImprovementInstance.ImprovementImage, thisImprovementInstance.ImprovementButton, textureSheet, textureOffset, CategoryImprovements, Locale.ConvertTextKey( thisImprovement.Description ), thisImprovement.ID );
						buttonAdded = buttonAdded + 1;
					end
				end
			end
			UpdateButtonFrame( buttonAdded, Controls.ImprovementsInnerFrame, Controls.ImprovementsFrame );	 	  
			
			-- game info
			if (thisResource.Help) then
				UpdateTextBlock( Locale.ConvertTextKey( thisResource.Help ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
			end

			-- generic text
			if (thisResource.Civilopedia) then
				UpdateTextBlock( Locale.ConvertTextKey( thisResource.Civilopedia ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
			end

			
			
			-- update the related images
			Controls.RelatedImagesFrame:SetHide( true );
		end
	end

	ResizeEtc();

end


CivilopediaCategory[CategoryImprovements].SelectArticle = function( improvementID, shouldAddToList )
	if _dpo then print("CivilopediaCategory[CategoryImprovements].SelectArticle"); end
	if m_selectedCategory ~= CategoryImprovements then
		SetSelectedCategory(CategoryImprovements, dontAddToList);
	end

	ClearArticle();

	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryImprovements, improvementID );
	end

	-- if improvementID ~= -1 and improvementID < 3000 then

	if improvementID ~= -1 then

		if improvementID < 3000 then

			if improvementID < 1000 then
			elseif improvementID < 2000 then improvementID=improvementID-1000
			elseif improvementID < 3000 then improvementID=improvementID-2000
			end

			local thisImprovement = GameInfo.Improvements[improvementID];
			if thisImprovement then

				-- update the name
				local name = Locale.ToUpper( thisImprovement.Description )
				Controls.ArticleID:SetText( name );

				-- update the portrait
				if IconHookup( thisImprovement.PortraitIndex, portraitSize, thisImprovement.IconAtlas, Controls.Portrait ) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				local buttonAdded = 0;
				local condition = "ImprovementType = '" .. thisImprovement.Type .. "'";

				---- tech visibility
				g_PrereqTechManager:DestroyInstances();
				buttonAdded = 0;

				local prereq = nil;
				for row in GameInfo.Builds( condition ) do
					if row.PrereqTech then
						prereq = GameInfo.Technologies[row.PrereqTech];
					end
				end

				if prereq then
					local thisPrereqInstance = g_PrereqTechManager:GetInstance();
					if thisPrereqInstance then
						local textureOffset, textureSheet = IconLookup( prereq.PortraitIndex, buttonSize, prereq.IconAtlas );
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end
						UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqTechImage, thisPrereqInstance.PrereqTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereq.Description ), prereq.ID );
						buttonAdded = buttonAdded + 1;
						-- UpdateButtonFrame( buttonAdded, Controls.PrereqTechInnerFrame, Controls.PrereqTechFrame );
					end
				end

				---- modernization tech preqs
				local canceldouble;
				for row in GameInfo.Improvement_TechYieldChanges( condition ) do
					local prereqMtech = GameInfo.Technologies[row.TechType];
					if prereqMtech then
						if prereqMtech.ID ~= canceldouble then
							local thisPrereqInstance = g_PrereqTechManager:GetInstance();
							if thisPrereqInstance then
								local textureOffset, textureSheet = IconLookup( prereqMtech.PortraitIndex, buttonSize, prereqMtech.IconAtlas );
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end
								UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqTechImage, thisPrereqInstance.PrereqTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereqMtech.Description ), prereqMtech.ID );
								buttonAdded = buttonAdded + 1;
								canceldouble = prereqMtech.ID
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.PrereqTechInnerFrame, Controls.PrereqTechFrame );

				---- virtue visibility
				g_PrereqVirtueManager:DestroyInstances();
				buttonAdded = 0;
				canceldouble = -1;

				for row in GameInfo.Policy_ImprovementYieldChanges( condition ) do
					local prereqV = GameInfo.Policies[row.PolicyType];
					if prereqV then
						if prereqV.ID ~= canceldouble then
							local thisPrereqInstance = g_PrereqVirtueManager:GetInstance();
							if thisPrereqInstance then
								local textureOffset, textureSheet = IconLookup( prereqV.PortraitIndex, buttonSize, prereqV.IconAtlas );
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end
								UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqVirtueImage, thisPrereqInstance.PrereqVirtueButton, textureSheet, textureOffset, CategoryVirtues, Locale.ConvertTextKey( prereqV.Description ), prereqV.ID );
								buttonAdded = buttonAdded + 1;
								canceldouble = prereqV.ID
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.PrereqVirtueInnerFrame, Controls.PrereqVirtueFrame );

				---- Affinity visibility. Reload frame with btns
				g_PrereqAffinityManager:DestroyInstances();
				buttonAdded = 0;
				canceldouble = -1;
				-- ����� ������ �� ��������� � �������������. ����� ������� ��������� �����, ��� ��� ��������� ��������� �� � ������ �������������, � � ����� ������� �� ���. �� � ������ PlayerPerks_ImprovementYieldEffects ���� ����� �� �� ������������.
				--
				for row in GameInfo.PlayerPerks_ImprovementYieldEffects( condition ) do
					-- take Impr type from Perk and check if this perk in AffPerks
					-- can't be taken by type, because there is no "Type" column. And adding Type column in asset xml is crashing first turn.
					local conditionPerk = "PlayerPerk = '" .. row.PlayerPerkType .. "'";
					for prereqAff in GameInfo.Affinity_Perks( conditionPerk ) do
						if prereqAff then
							-- print("prereqAff1: "..tostring(row.PlayerPerkType)); -- dbg
							-- print("prereqAff2: "..tostring(prereqAff.PlayerPerk)); -- dbg
							if prereqAff.ID ~= canceldouble then
								local thisPrereqInstance = g_PrereqAffinityManager:GetInstance();
								if thisPrereqInstance then
									local textureOffset, textureSheet = IconLookup( prereqAff.IconIndex, buttonSize, prereqAff.IconAtlas );
									if textureOffset == nil then
										textureSheet = defaultErrorTextureSheet;
										textureOffset = nullOffset;
									end
									local AffReqLev = "[COLOR_HARMONY_AFFINITY]"..tostring(prereqAff.HarmonyLevelNeeded).."[ENDCOLOR]/[COLOR_PURITY_AFFINITY]"..tostring(prereqAff.PurityLevelNeeded).."[ENDCOLOR]/[COLOR_SUPREMACY_AFFINITY]"..tostring(prereqAff.SupremacyLevelNeeded).."[ENDCOLOR]"
									UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqAffinityImage, thisPrereqInstance.PrereqAffinityButton, textureSheet, textureOffset, CategoryAffinities, AffReqLev, prereqAff.ID );
									buttonAdded = buttonAdded + 1;
									canceldouble = prereqAff.ID
								end
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.PrereqAffinityInnerFrame, Controls.PrereqAffinityFrame );

				-- Yield
				local yieldLines = {};
				for row in GameInfo.Improvement_Yields( condition ) do
					if row.Yield > 0 then
						table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description));
					end
				end

				-- Yield if adjacent to Base
				for row in GameInfo.Improvement_AdjacentCityYields( condition ) do
					if row.Yield > 0 then
						table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_ADJ_BASE_NUM_NAMED_YIELD", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description));
					end
				end

				-- Yield on particular resources
				for row in GameInfo.Improvement_ResourceType_Yields( condition ) do
					if row.Yield > 0 then
						local yieldInfo = GameInfo.Yields[row.YieldType];
						local resourceInfo = GameInfo.Resources[row.ResourceType];
						if (yieldInfo ~= nil and resourceInfo ~= nil) then
							InsertYieldString(yieldLines, "TXT_KEY_YIELD_FROM_SPECIFIC_ICON_OBJECT", "TXT_KEY_NEGATIVE_YIELD_FROM_SPECIFIC_ICON_OBJECT", row.Yield, yieldInfo.IconString, yieldInfo.Description, resourceInfo.Description, resourceInfo.IconString );
						end
					end
				end

				-- City Strength / HP
				local iCityHP = thisImprovement.CityHP;
				if(iCityHP > 0) then
					table.insert(yieldLines, Locale.Lookup("TXT_KEY_PRODUCTION_BUILDING_HITPOINTS_TT", iCityHP));
				end

				-- add in mountain adjacency yield
				for row in GameInfo.Improvement_AdjacentMountainYieldChanges( condition ) do
					if row.Yield > 0 then
						table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description));
					end
				end

				if #yieldLines > 0 then
					ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(yieldLines, "[NEWLINE]") ), Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame  );
				else
					ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ), Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame );
				end

				-- Modernization of Yield ---------------------- PW
				local ModernYieldLines = {};

				-- by tech
				for row in GameInfo.Improvement_TechYieldChanges( condition ) do
					if row.Yield > 0 then
						table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_TECH_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Technologies[row.TechType].Description));
					end
				end

				-- by policy
				for row in GameInfo.Policy_ImprovementYieldChanges( condition ) do
					if row.Yield > 0 then
						table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_POLICY_YIELD_CHANGE", row.Yield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, GameInfo.Policies[row.PolicyType].Description));
					end
				end

				-- by affinity
				for row in GameInfo.PlayerPerks_ImprovementYieldEffects( condition ) do
					local conditionPerk = "PlayerPerk = '" .. row.PlayerPerkType .. "'";
					for prereqAff in GameInfo.Affinity_Perks( conditionPerk ) do
						if prereqAff then
							if row.FlatYield > 0 then
								local AffReqLev = "[COLOR_HARMONY_AFFINITY]"..tostring(prereqAff.HarmonyLevelNeeded).."[ENDCOLOR]/[COLOR_PURITY_AFFINITY]"..tostring(prereqAff.PurityLevelNeeded).."[ENDCOLOR]/[COLOR_SUPREMACY_AFFINITY]"..tostring(prereqAff.SupremacyLevelNeeded).."[ENDCOLOR]"
								table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_AFFINITY_YIELD_CHANGE", row.FlatYield, GameInfo.Yields[row.YieldType].IconString, GameInfo.Yields[row.YieldType].Description, AffReqLev));
							end
							if row.FlatHealth > 0 then
								local AffReqLev = "[COLOR_HARMONY_AFFINITY]"..tostring(prereqAff.HarmonyLevelNeeded).."[ENDCOLOR]/[COLOR_PURITY_AFFINITY]"..tostring(prereqAff.PurityLevelNeeded).."[ENDCOLOR]/[COLOR_SUPREMACY_AFFINITY]"..tostring(prereqAff.SupremacyLevelNeeded).."[ENDCOLOR]"
								table.insert(ModernYieldLines, Locale.ConvertTextKey("TXT_KEY_PEDIA_MODERN_AFFINITY_YIELD_CHANGE", row.FlatHealth, "[ICON_HEALTH]", "TXT_KEY_HEALTH", AffReqLev));
							end
						end
					end
				end

				if #ModernYieldLines > 0 then
					ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(ModernYieldLines, "[NEWLINE]") ), Controls.ModernYieldLabel, Controls.ModernYieldInnerFrame, Controls.ModernYieldFrame  );
				else
					-- ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ), Controls.ModernYieldLabel, Controls.ModernYieldInnerFrame, Controls.ModernYieldFrame );
				end
				-- Modernization of Yield ---------------------- PW			

				buttonAdded = 0;
				if thisImprovement.CivilizationType then
					local thisCiv = GameInfo.Civilizations[thisImprovement.CivilizationType];
					if thisCiv then
						g_CivilizationsManager:DestroyInstances();
						local thisCivInstance = g_CivilizationsManager:GetInstance();
						if thisCivInstance then
							local textureOffset, textureSheet = IconLookup( thisCiv.PortraitIndex, buttonSize, thisCiv.IconAtlas );
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end
							UpdateSmallButton( buttonAdded, thisCivInstance.CivilizationImage, thisCivInstance.CivilizationButton, textureSheet, textureOffset, CategoryCivilizations, Locale.ConvertTextKey( thisCiv.ShortDescription ), thisCiv.ID );
							buttonAdded = buttonAdded + 1;
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.CivilizationsInnerFrame, Controls.CivilizationsFrame );

				-- found on
				local foundKey = (thisImprovement.Goody or thisImprovement.IgnoreOwnership) and "TXT_KEY_PEDIA_TERRAINS_LABEL" or "TXT_KEY_PEDIA_FOUNDON_LABEL";
				Controls.ResourcesFoundLabel:SetText( Locale.ConvertTextKey(foundKey) );
				g_ResourcesFoundManager:DestroyInstances(); -- okay, this is supposed to be a resource, but for now a round button is a round button
				buttonAdded = 0;
				if( thisImprovement.MarvelType == nil ) then
					for row in GameInfo.Improvement_ValidFeatures( condition ) do
						local thisFeature = GameInfo.Features[row.FeatureType];
						if thisFeature then
							local thisFeatureInstance = g_ResourcesFoundManager:GetInstance();
							if thisFeatureInstance then
								local textureOffset, textureSheet = IconLookup( thisFeature.PortraitIndex, buttonSize, thisFeature.IconAtlas );
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end
								UpdateSmallButton( buttonAdded, thisFeatureInstance.ResourceFoundImage, thisFeatureInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisFeature.Description ), thisFeature.ID + 1000 ); -- todo: add a fudge factor
								buttonAdded = buttonAdded + 1;
							end
						end
					end
					for row in GameInfo.Improvement_ValidTerrains( condition ) do
						local thisTerrain = GameInfo.Terrains[row.TerrainType];
						if thisTerrain then
							local thisTerrainInstance = g_ResourcesFoundManager:GetInstance();
							if thisTerrainInstance then
								local textureOffset, textureSheet = IconLookup( thisTerrain.PortraitIndex, buttonSize, thisTerrain.IconAtlas );
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end
								UpdateSmallButton( buttonAdded, thisTerrainInstance.ResourceFoundImage, thisTerrainInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisTerrain.Description ), thisTerrain.ID );
								buttonAdded = buttonAdded + 1;
							end
						end
					end
					-- hackery for hills
					--if thisImprovement and thisImprovement.HillsMakesValid then
					--local thisTerrain = GameInfo.Terrains["TERRAIN_HILL"];
					--local thisTerrainInstance = g_ResourcesFoundManager:GetInstance();
					--if thisTerrainInstance then
					--local textureSheet;
					--local textureOffset;
					--textureSheet = defaultErrorTextureSheet;
					--textureOffset = nullOffset;
					--UpdateSmallButton( buttonAdded, thisTerrainInstance.ResourceFoundImage, thisTerrainInstance.ResourceFoundButton, textureSheet, textureOffset, CategoryTerrain, Locale.ConvertTextKey( thisTerrain.Description ), thisTerrain.ID );
					--buttonAdded = buttonAdded + 1;
					--end
					--end
				end
				UpdateButtonFrame( buttonAdded, Controls.ResourcesFoundInnerFrame, Controls.ResourcesFoundFrame );

				-- Required resource
				Controls.RequiredResourcesLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVES_RESRC_LABEL" ) );
				g_RequiredResourcesManager:DestroyInstances();
				buttonAdded = 0;
				if thisImprovement.Type ~= "IMPROVEMENT_EXPEDITION" then
					for row in GameInfo.Improvement_ResourceTypes( condition ) do
						local requiredResource = GameInfo.Resources[row.ResourceType];
						if requiredResource then
							local thisRequiredResourceInstance = g_RequiredResourcesManager:GetInstance();
							if thisRequiredResourceInstance then
								local textureOffset, textureSheet = IconLookup( requiredResource.PortraitIndex, buttonSize, requiredResource.IconAtlas );
								if textureOffset == nil then
									textureSheet = defaultErrorTextureSheet;
									textureOffset = nullOffset;
								end
								UpdateSmallButton( buttonAdded, thisRequiredResourceInstance.RequiredResourceImage, thisRequiredResourceInstance.RequiredResourceButton, textureSheet, textureOffset, CategoryResources, Locale.ConvertTextKey( requiredResource.Description ), requiredResource.ID );
								buttonAdded = buttonAdded + 1;
							end
						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.RequiredResourcesInnerFrame, Controls.RequiredResourcesFrame );

				-- update the maintenance
				local maintenanceLines = {};
				local energyMaintenance = thisImprovement.EnergyMaintenance;
				if energyMaintenance > 0 then
					--Controls.MaintenanceLabel:SetText( Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", energyMaintenance, "[ICON_ENERGY]", "TXT_KEY_YIELD_ENERGY") );
					--Controls.MaintenanceFrame:SetHide( false );
					table.insert(maintenanceLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", energyMaintenance, "[ICON_ENERGY]", "TXT_KEY_YIELD_ENERGY"));
				end

				-- check disable adjacent
				local NoTwoAdjacent = thisImprovement.NoTwoAdjacent;
				if NoTwoAdjacent then
					table.insert(maintenanceLines, Locale.ConvertTextKey("TXT_KEY_NO_TWO_ADJACENT_MAINTENANCE"));
				end

				if #maintenanceLines > 0 then
					ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(maintenanceLines, "[NEWLINE]") ), Controls.MaintenanceLabel, Controls.MaintenanceInnerFrame, Controls.MaintenanceFrame  );
				--else
					--ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ), Controls.YieldLabel, Controls.YieldInnerFrame, Controls.YieldFrame );
				end

				-- update the Health
				local iHealth = thisImprovement.Health;
				local iUnhealth = thisImprovement.Unhealth;
				if iHealth > 0 then
					Controls.HealthLabel:SetText( Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", iHealth, "[ICON_HEALTH_1]", "TXT_KEY_HEALTH") );
					Controls.HealthFrame:SetHide( false );
				elseif iUnhealth > 0 then
					Controls.HealthLabel:SetText( Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", iUnhealth, "[ICON_HEALTH_4]", "TXT_KEY_UNHEALTH") );
					Controls.HealthFrame:SetHide( false );
				end

				-- update the game info
				if (thisImprovement.Help) then
					UpdateTextBlock( Locale.ConvertTextKey( thisImprovement.Help ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
				end

				-- generic text
				if (thisImprovement.Civilopedia) then
					local gameinfocollect = Locale.ConvertTextKey( thisImprovement.Civilopedia )
					local tIdescription = "[COLOR_PWAC_MMTEXTSELECT_1]"..Locale.ConvertTextKey(thisImprovement.Description).. "[ENDCOLOR]"
					-- NoTwoAdjacent
					if (thisImprovement.NoTwoAdjacent) then
						-- gameinfocollect = gameinfocollect.."[NEWLINE][NEWLINE]"..Locale.ConvertTextKey("TXT_KEY_BUILD_BLOCKED_CANNOT_BE_ADJACENT", thisImprovement.Description);
						gameinfocollect = gameinfocollect.."[NEWLINE][NEWLINE]"..Locale.ConvertTextKey("TXT_KEY_BUILD_BLOCKED_CANNOT_BE_ADJACENT", tIdescription);
					end

					UpdateTextBlock( gameinfocollect, Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
					-- UpdateTextBlock( Locale.ConvertTextKey( thisImprovement.Civilopedia ).."[NEWLINE]", Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
					-- UpdateTextBlock( Locale.ConvertTextKey( concat( thisImprovement.Civilopedia, "[NEWLINE]") ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
					-- ShowAndSizeFrameToText( Locale.ConvertTextKey( thisImprovement.Civilopedia ).."[NEWLINE]", Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
				end

				-- update the related images
				Controls.RelatedImagesFrame:SetHide( true );
			end
			--Roads and Magrail
		elseif improvementID ~= -1 then

			improvementID = improvementID - 3000;
			local thisImprovement = GameInfo.Routes[improvementID];
			if thisImprovement then

				-- update the name
				local name = Locale.ToUpper( thisImprovement.Description )
				Controls.ArticleID:SetText( name );

				if IconHookup( thisImprovement.PortraitIndex, portraitSize, thisImprovement.IconAtlas, Controls.Portrait ) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				local buttonAdded = 0;
				local condition = "RouteType = '" .. thisImprovement.Type .. "'";

				-- tech visibility
				g_PrereqTechManager:DestroyInstances();
				buttonAdded = 0;

				local prereq = nil;
				for row in GameInfo.Builds( condition ) do
					if row.PrereqTech then
						prereq = GameInfo.Technologies[row.PrereqTech];
					end
				end

				if prereq then
					local thisPrereqInstance = g_PrereqTechManager:GetInstance();
					if thisPrereqInstance then
						local textureOffset, textureSheet = IconLookup( prereq.PortraitIndex, buttonSize, prereq.IconAtlas );
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end
						UpdateSmallButton( buttonAdded, thisPrereqInstance.PrereqTechImage, thisPrereqInstance.PrereqTechButton, textureSheet, textureOffset, CategoryTech, Locale.ConvertTextKey( prereq.Description ), prereq.ID );
						buttonAdded = buttonAdded + 1;
						UpdateButtonFrame( buttonAdded, Controls.PrereqTechInnerFrame, Controls.PrereqTechFrame );
					end
				end

				-- generic text
				if (thisImprovement.Civilopedia) then
					UpdateTextBlock( Locale.ConvertTextKey( thisImprovement.Civilopedia ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
				end

				-- update the related images
				Controls.RelatedImagesFrame:SetHide( true );
			end
		end
	end

	ResizeEtc();
end

CivilopediaCategory[CategoryAffinities].SelectArticle = function(conceptID, shouldAddToList)
	print("CivilopediaCategory[CategoryAffinities].SelectArticle");
	if m_selectedCategory ~= CategoryAffinities then
		SetSelectedCategory(CategoryAffinities, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryAffinities, conceptID );
	end
	
	if conceptID ~= -1 then
		-- Perk lists
		if (conceptID >= 1000) then
			local affinityID = conceptID - 1000;
			local affinityInfo = GameInfo.Affinity_Types[affinityID];
			if (affinityInfo ~= nil) then
				-- Name
				Controls.ArticleID:SetText( Locale.ToUpper("TXT_KEY_PEDIA_AFFINITY_PERKS_LABEL", affinityInfo.Description) );

				-- Summary
				local summaryLines = {};

				local mainColumn = "";
				local hybridOptions = {};
				if (affinityInfo.Type == "AFFINITY_TYPE_HARMONY") then
					mainColumn = "HarmonyLevelNeeded";
					table.insert(hybridOptions, { Column = "PurityLevelNeeded", ID = GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID} );
					table.insert(hybridOptions, { Column = "SupremacyLevelNeeded", ID = GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID} );
				elseif (affinityInfo.Type == "AFFINITY_TYPE_PURITY") then
					mainColumn = "PurityLevelNeeded";
					table.insert(hybridOptions, { Column = "HarmonyLevelNeeded", ID = GameInfo.Affinity_Types["AFFINITY_TYPE_HARMONY"].ID} );
					table.insert(hybridOptions, { Column = "SupremacyLevelNeeded", ID = GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID} );
				elseif (affinityInfo.Type == "AFFINITY_TYPE_SUPREMACY") then
					mainColumn = "SupremacyLevelNeeded";
					table.insert(hybridOptions, { Column = "PurityLevelNeeded", ID = GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID} );
					table.insert(hybridOptions, { Column = "HarmonyLevelNeeded", ID = GameInfo.Affinity_Types["AFFINITY_TYPE_HARMONY"].ID} );
				end

				for row in GameInfo.Affinity_Perks(mainColumn .. " > 0") do
					local perkInfo = GameInfo.PlayerPerks[row.PlayerPerk];
					local perkStr = Locale.ConvertTextKey("TXT_KEY_PEDIA_AFFINITY_PERKS_AT_LEVEL", row[mainColumn], affinityInfo.IconString, affinityInfo.Description);

					-- Hybrid?
					local hybridAffinity = nil;
					for _,hybridOption in ipairs(hybridOptions) do
						if (row[hybridOption.Column] > 0) then
							hybridAffinity = GameInfo.Affinity_Types[hybridOption.ID];
							perkStr = Locale.ConvertTextKey("TXT_KEY_PEDIA_AFFINITY_PERKS_HYBRID_AT_LEVEL", 
								row[mainColumn], 
								affinityInfo.IconString, 
								affinityInfo.Description, 
								hybridAffinity.IconString,
								hybridAffinity.Description);
							break;
						end
					end
					
					perkStr = perkStr .. ":[NEWLINE][ICON_BULLET]";
					-- Protok Setting a check
					if perkInfo ~= nil then
						perkStr = perkStr .. Locale.Lookup(perkInfo.Help);
					end
					table.insert( summaryLines, perkStr );
				end

				UpdateSuperWideTextBlock( table.concat(summaryLines, "[NEWLINE][NEWLINE]"), Controls.SummaryLabel, Controls.SummaryInnerFrame, Controls.SummaryFrame );
			end
		else
			-- Concepts
			local thisConcept = GameInfo.Concepts[conceptID];		
			if thisConcept then		
				-- update the name
				local name = Locale.ToUpper( thisConcept.Description ); 	
				Controls.ArticleID:SetText( name );
			
				-- portrait
			
				-- update the summary
				if thisConcept.Summary then
					UpdateSuperWideTextBlock( Locale.ConvertTextKey( thisConcept.Summary ), Controls.SummaryLabel, Controls.SummaryInnerFrame, Controls.SummaryFrame );
				end

				-- game info
				local gameInfoText = "";
				if (thisConcept.Type == "CONCEPT_AFFINITY_HARMONY") then
					gameInfoText =  GetHelpTextForAffinity(GameInfo.Affinity_Types["AFFINITY_TYPE_HARMONY"].ID, nil);
				elseif (thisConcept.Type == "CONCEPT_AFFINITY_PURITY") then
					gameInfoText =  GetHelpTextForAffinity(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID, nil);
				elseif (thisConcept.Type == "CONCEPT_AFFINITY_SUPREMACY") then
					gameInfoText =  GetHelpTextForAffinity(GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID, nil);
				end
				if (gameInfoText ~= "") then
					UpdateSuperWideTextBlock( gameInfoText, Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
				end
			
				-- related images 
			
				-- related concepts		
			end
		end
	end	

	ResizeEtc();
end

CivilopediaCategory[CategoryStations].SelectArticle = function(conceptID, shouldAddToList)
		print("CivilopediaCategory[CategoryStations].SelectArticle");
	if m_selectedCategory ~= CategoryStations then
		SetSelectedCategory(CategoryStations, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryStations, conceptID );
	end
	
	if conceptID ~= -1 then
		local thisConcept = GameInfo.Concepts[conceptID];
		
		if thisConcept then
		
			-- update the name
			local name = Locale.ToUpper( thisConcept.Description ); 	
			Controls.ArticleID:SetText( name );
			
			-- portrait
			
			-- update the summary
			if thisConcept.Summary then
				UpdateSuperWideTextBlock( Locale.ConvertTextKey( thisConcept.Summary ), Controls.SummaryLabel, Controls.SummaryInnerFrame, Controls.SummaryFrame );
			end
						
			-- related images
			
			-- related concepts
		
		end

	end	

	ResizeEtc();
end

CivilopediaCategory[CategoryDiplomacy].SelectArticle = function(entryID, shouldAddToList)
	-- print("CivilopediaCategory[CategoryDiplomacy].SelectArticle");
	if m_selectedCategory ~= CategoryDiplomacy then
		SetSelectedCategory(CategoryDiplomacy, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryDiplomacy, entryID );
	end

	-- Personality Traits
	if entryID < 1000 then
		local traitID = entryID;
		if traitID ~= -1 then
		
			local traitInfo = GameInfo.PersonalityTraits[traitID];
			if traitInfo then

				-- Name
				local name = Locale.ToUpper( traitInfo.Description )
				Controls.ArticleID:SetText( name );

				-- Category
				local traitCategory = GameInfo.PersonalityTraitCategories[traitInfo.TraitCategoryType];
				Controls.SubtitleLabel:SetText( Locale.ToUpper( Locale.Lookup(traitCategory.Description)));
				Controls.SubtitleID:SetHide( false );

				-- Icon
				if IconHookup(traitInfo.PortraitIndex, portraitSize, traitInfo.IconAtlas, Controls.Portrait) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end

				-- Game Info
				local gameInfoText = "";
				for row in GameInfo.PersonalityTraits_Perks{ PersonalityTraitType = traitInfo.Type } do
					local rowPerk = GameInfo.PlayerPerks[row.PlayerPerkType];
					if (rowPerk ~= nil) then

						if (gameInfoText ~= "") then
							gameInfoText = gameInfoText.."[NEWLINE][NEWLINE]";
						end

						gameInfoText = gameInfoText.."[COLOR_CYAN]"..Locale.ConvertTextKey("TXT_KEY_DIPLOMACY_PERK_LEVEL", row.Level).."[ENDCOLOR]: ";
						gameInfoText = gameInfoText..Locale.Lookup(rowPerk.Help)						
					end
				end

				-- AI Hint text for non-Character Traits
				if (traitInfo.Unique == false) then
					gameInfoText = gameInfoText.."[NEWLINE][NEWLINE]";
					gameInfoText = gameInfoText..Locale.Lookup(traitInfo.Help);
				end
				UpdateTextBlock( gameInfoText, Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
				
				-- Agreements Unlocked. PW
				g_TraitsManager:DestroyInstances();
				local buttonAdded = 0;
				local TraitType = traitInfo.Type;
				local condition = "PersonalityTraitType = '" .. TraitType .. "'";	
				for row in GameInfo.PersonalityTraits_ForeignPolicies( condition ) do 	-- take each row by this condition
					local unlockAgre = GameInfo.ForeignPolicies[row.ForeignPolicyType]; -- take needed object by reference
					if unlockAgre then
						local thisAgreementInstance = g_TraitsManager:GetInstance();
						if thisAgreementInstance then
							local textureOffset, textureSheet = IconLookup( unlockAgre.PortraitIndex, buttonSize, unlockAgre.IconAtlas );		
							if textureOffset == nil then
								textureSheet = defaultErrorTextureSheet;
								textureOffset = nullOffset;
							end	
							UpdateSmallButton( buttonAdded, thisAgreementInstance.TraitImage, thisAgreementInstance.TraitButton, textureSheet, textureOffset, CategoryDiplomacy, Locale.ConvertTextKey( unlockAgre.Description ), unlockAgre.ID + 1000 );
							buttonAdded = buttonAdded + 1;	

						end
					end
				end
				UpdateButtonFrame( buttonAdded, Controls.AgreementsUnlockedInnerFrame, Controls.AgreementsUnlockedFrame );
			end
		end
	else
		-- Foreign Policies
		local policyID = entryID - 1000;
		if policyID ~= -1 then
		
			local policyInfo = GameInfo.ForeignPolicies[policyID];
			if policyInfo then

				-- Name
				local name = Locale.ToUpper( policyInfo.Description )
				Controls.ArticleID:SetText( name );		
				
				-- Icon
				if IconHookup(policyInfo.PortraitIndex, portraitSize, policyInfo.IconAtlas, Controls.Portrait) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end	

				-- Game Info
				local gameInfoText = "";
				for row in GameInfo.ForeignPolicies_Perks{ ForeignPolicyType = policyInfo.Type } do
					local rowPerk = GameInfo.PlayerPerks[row.PlayerPerkType];
					if (rowPerk ~= nil) then

						if (gameInfoText ~= "") then
							gameInfoText = gameInfoText.."[NEWLINE][NEWLINE]";
						end
						
						local relationshipInfo = GameInfo.RelationshipLevels[row.RelationshipLevelType];
						gameInfoText = gameInfoText.."[COLOR_CYAN]"..Locale.Lookup(relationshipInfo.Description).."[ENDCOLOR]: ";
						gameInfoText = gameInfoText..Locale.Lookup(rowPerk.Help)
					end
				end
				UpdateTextBlock( gameInfoText, Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );

				-- tech visibility
				g_RevealTechsManager:DestroyInstances();
				local unlockTraitType = nil;
				for row in GameInfo.PersonalityTraits_ForeignPolicies() do
					if row.ForeignPolicyType == policyInfo.Type then
						unlockTraitType = row.PersonalityTraitType;
						break;
					end
				end
				local unlockTrait = GameInfo.PersonalityTraits[unlockTraitType];
				if (unlockTrait ~= nil) then
					local instance = g_RevealTechsManager:GetInstance();
					local textureOffset, textureSheet = IconLookup( unlockTrait.PortraitIndex, buttonSize, unlockTrait.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end				
					UpdateSmallButton( 0, instance.RevealTechImage, instance.RevealTechButton, textureSheet, textureOffset, CategoryDiplomacy, Locale.ConvertTextKey( unlockTrait.Description ), unlockTrait.ID );
					UpdateButtonFrame( 1, Controls.RevealTechsInnerFrame, Controls.RevealTechsFrame );
				end
				
				-- Cost
				Controls.CostFrame:SetHide( false );
				local costString = "";
				local cost = policyInfo.PurchaseCost;
				local costPT = policyInfo.PerTurnCost;
				if(cost > 0) then
					costString = tostring(cost) .. " [ICON_DIPLO_CAPITAL] +"..costPT.." [ICON_DIPLO_CAPITAL] "..Locale.Lookup("TXT_KEY_DIPLOMACYUI_PERTURN");
					Controls.CostFrame:SetHide( false );
					Controls.CostLabel:SetText(costString);
				end				
			end
		end
	end

	ResizeEtc();
end

CivilopediaCategory[CategoryArtifacts].SelectArticle = function(entryID, shouldAddToList)

	print("CivilopediaCategory[CategoryArtifacts].SelectArticle");
	if m_selectedCategory ~= CategoryArtifacts then
		SetSelectedCategory(CategoryArtifacts, dontAddToList);
	end
	
	ClearArticle();
	
	if shouldAddToList == addToList then
		AddToNavigationHistory( CategoryArtifacts, entryID );
	end

	-- Artifacts
	if entryID < 1000 then
		local artifactID = entryID;
		if artifactID ~= -1 then
			local artifactInfo = GameInfo.Artifacts[artifactID];
			if (artifactInfo ~= nil) then
				-- Name
				local name = Locale.ToUpper( artifactInfo.Description );
				Controls.ArticleID:SetText( name );

				-- Portrait
				if IconHookup(artifactInfo.PortraitIndex, portraitSize, artifactInfo.IconAtlas, Controls.Portrait) then
					Controls.PortraitFrame:SetHide( false );
				else
					Controls.PortraitFrame:SetHide( true );
				end
			
				-- Game Info
				local gameInfoText = "";
				local artifactCategoryInfo = GameInfo.ArtifactCategories[artifactInfo.Category];
				if (artifactCategoryInfo ~= nil) then
					gameInfoText = "[COLOR_YELLOW]"..Locale.Lookup("TXT_KEY_ARTIFACT_CATEGORY").."[ENDCOLOR]: "..Locale.ConvertTextKey( artifactCategoryInfo.Description );
					-- adding icon
					if artifactInfo.Category == "ARTIFACT_CATEGORY_OLD_EARTH" then gameInfoText = gameInfoText.." [ICON_ARTIFACT_OLDEARTH]" 
					elseif artifactInfo.Category == "ARTIFACT_CATEGORY_ALIEN" then gameInfoText = gameInfoText.." [ICON_ARTIFACT_ALIEN]" 
					elseif artifactInfo.Category == "ARTIFACT_CATEGORY_PROGENITOR" then gameInfoText = gameInfoText.." [ICON_ARTIFACT_PROGENITOR]" end
					gameInfoText = gameInfoText.."[NEWLINE][NEWLINE]";
					gameInfoText = gameInfoText..Locale.ConvertTextKey( artifactCategoryInfo.RewardHint );

					UpdateTextBlock( gameInfoText, Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );
				end

				-- History
				UpdateTextBlock( Locale.ConvertTextKey( artifactInfo.Explanation ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
			end
			
			---- ADDING Yield
			local yieldLines = {};
			if artifactInfo.FoodRewardPercent > 0 then 
				table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", artifactInfo.FoodRewardPercent, GameInfo.Yields["YIELD_FOOD"].IconString, GameInfo.Yields["YIELD_FOOD"].Description));
			end
			if artifactInfo.ProductionRewardPercent > 0 then 
				table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", artifactInfo.ProductionRewardPercent, GameInfo.Yields["YIELD_PRODUCTION"].IconString, GameInfo.Yields["YIELD_PRODUCTION"].Description));
			end
			if artifactInfo.EnergyRewardPercent > 0 then 
				table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", artifactInfo.EnergyRewardPercent, GameInfo.Yields["YIELD_ENERGY"].IconString, GameInfo.Yields["YIELD_ENERGY"].Description));
			end
			if artifactInfo.ScienceRewardPercent > 0 then 
				table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", artifactInfo.ScienceRewardPercent, GameInfo.Yields["YIELD_SCIENCE"].IconString, GameInfo.Yields["YIELD_SCIENCE"].Description));
			end
			if artifactInfo.CultureRewardPercent > 0 then 
				table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", artifactInfo.CultureRewardPercent, GameInfo.Yields["YIELD_CULTURE"].IconString, GameInfo.Yields["YIELD_CULTURE"].Description));
			end
			 if artifactInfo.InfluenceRewardPercent > 0 then
				 table.insert(yieldLines, Locale.ConvertTextKey("TXT_KEY_SIMPLE_NUM_NAMED_YIELD", artifactInfo.InfluenceRewardPercent, GameInfo.Yields["YIELD_CAPITAL"].IconString, GameInfo.Yields["YIELD_CAPITAL"].Description));
			 end

			if #yieldLines > 0 then
				ShowAndSizeFrameToText( Locale.ConvertTextKey( table.concat(yieldLines, "[NEWLINE]") ), Controls.StudyArtYieldLabel, Controls.StudyArtYieldInnerFrame, Controls.StudyArtYieldFrame  );
			else
				ShowAndSizeFrameToText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_NO_YIELD" ), Controls.StudyArtYieldLabel, Controls.StudyArtYieldInnerFrame, Controls.StudyArtYieldFrame );
			end	
			
			-- UNLOCKED REWARD
			g_ArtsManager:DestroyInstances();
			-- g_RevealTechsManager:DestroyInstances();
			local buttonAdded = 0;
			local RewardType = artifactInfo.RewardPreference;
			local unlockReward = GameInfo.ArtifactRewards[RewardType];
			if (unlockReward ~= nil) then
				local thisArtInstance = g_ArtsManager:GetInstance();
				-- local thisArtInstance = g_RevealTechsManager:GetInstance();
				local textureOffset, textureSheet;	
--------------------------------				
				if unlockReward.BuildingReward ~= nil then
					local building = GameInfo.Buildings[unlockReward.BuildingReward];
					if building == nil then
						-- error("Artifact reward points to a building/wonder which doesn't exist (yet) in the game database '" ..tostring(_rewardInfo.BuildingReward) .."'");
					else
						textureOffset, textureSheet = IconLookup( building.PortraitIndex, buttonSize, building.IconAtlas );				
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end	
					end
				elseif unlockReward.IconAtlas ~= nil and unlockReward.PortraitIndex ~= -1 then
					textureOffset, textureSheet = IconLookup( unlockReward.PortraitIndex, buttonSize, unlockReward.IconAtlas );				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end	
				elseif unlockReward.PlayerPerkReward ~= nil then
					textureOffset, textureSheet = {0,0}, "ArtifactRewardFunctionality"..tostring(buttonSize)..".dds";				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end	
				elseif unlockReward.PromotionReward ~= nil then
					textureOffset, textureSheet = {0,0}, "ArtifactRewardPromotion"..tostring(buttonSize)..".dds";				
					if textureOffset == nil then
						textureSheet = defaultErrorTextureSheet;
						textureOffset = nullOffset;
					end	
				else
					print("No (known) artifact reward type image for '" .. unlockReward.Type .. "'.");
					-- Controls.Portrait:SetHide( true );
				end
				-- print("textureSheet - " .. tostring(textureSheet) .. ", textureOffset - "..tostring(textureOffset) );
--------------------------------		
				UpdateSmallButton( 0, thisArtInstance.ArtImage, thisArtInstance.ArtButton, textureSheet, textureOffset, CategoryArtifacts, Locale.ConvertTextKey( unlockReward.Description ), unlockReward.ID +1000 );
				UpdateButtonFrame( 1, Controls.ArtsInnerFrame, Controls.ArtsFrame );
			end			
		end	

	-- Artifact Reward Perks
	else
		local rewardID = entryID - 1000;
		if rewardID ~= -1 then
			local rewardInfo = GameInfo.ArtifactRewards[rewardID];
			if (rewardInfo ~= nil) then
				-- Name
				local name = Locale.ToUpper( rewardInfo.Description );
				Controls.ArticleID:SetText( name );

				-- Portrait
				if rewardInfo.BuildingReward ~= nil then
					local building = GameInfo.Buildings[rewardInfo.BuildingReward];
					if building == nil then
						error("Artifact reward points to a building/wonder which doesn't exist (yet) in the game database '" ..tostring(rewardInfo.BuildingReward) .."'");
					else
						if(IconHookup( building.PortraitIndex, portraitSize, building.IconAtlas, Controls.Portrait )) then
							Controls.PortraitFrame:SetHide( false );
						else
							Controls.PortraitFrame:SetHide( true );
						end
					end
				elseif rewardInfo.IconAtlas ~= nil and rewardInfo.PortraitIndex ~= -1 then
					-- Generic icon hook up?
					IconHookup( rewardInfo.PortraitIndex, portraitSize, rewardInfo.IconAtlas, Controls.Portrait );
				elseif rewardInfo.PlayerPerkReward ~= nil then
					Controls.Portrait:SetTexture( "ArtifactRewardFunctionality"..tostring(portraitSize)..".dds" );
					Controls.Portrait:SetTextureOffsetVal(0, 0);
					Controls.PortraitFrame:SetHide( false );
				elseif rewardInfo.PromotionReward ~= nil then
					Controls.Portrait:SetTexture( "ArtifactRewardPromotion"..tostring(portraitSize)..".dds" );
					Controls.Portrait:SetTextureOffsetVal(0, 0);
					Controls.PortraitFrame:SetHide( false );
				else
					error("No (known) artifact reward type image for '" .. rewardInfo.Type .. "'.");
					Controls.Portrait:SetHide( true );
				end
			
				-- Game Info
				UpdateTextBlock( Locale.ConvertTextKey( rewardInfo.EffectsSummary ), Controls.GameInfoLabel, Controls.GameInfoInnerFrame, Controls.GameInfoFrame );

				-- History
				UpdateTextBlock( Locale.ConvertTextKey( rewardInfo.Explanation ), Controls.HistoryLabel, Controls.HistoryInnerFrame, Controls.HistoryFrame );
			end

			-- GRANTED BY ART
			g_ArtsManager:DestroyInstances();
			local buttonAdded = 0;
			local RewardType = rewardInfo.Type;
			local condition = "RewardPreference = '" .. RewardType .. "'";	
			for row in GameInfo.Artifacts( condition ) do 	-- take each row by this condition
				local Art = GameInfo.Artifacts[row.Type]; -- take needed object by reference
				if Art then
					local thisArtInstance = g_ArtsManager:GetInstance();
					if thisArtInstance then
						local textureOffset, textureSheet = IconLookup( Art.PortraitIndex, buttonSize, Art.IconAtlas );		
						if textureOffset == nil then
							textureSheet = defaultErrorTextureSheet;
							textureOffset = nullOffset;
						end	
						UpdateSmallButton( buttonAdded, thisArtInstance.ArtImage, thisArtInstance.ArtButton, textureSheet, textureOffset, CategoryArtifacts, Locale.ConvertTextKey( Art.Description ), Art.ID );
						buttonAdded = buttonAdded + 1;	

					end
				end
			end
			UpdateButtonFrame( buttonAdded, Controls.ArtsInnerFrame, Controls.ArtsFrame );	

		end
	end

	ResizeEtc();
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

function SortFunction( a, b )

    local aVal = otherSortedList[ tostring( a ) ];
    local bVal = otherSortedList[ tostring( b ) ];
    
    if (aVal == nil) or (bVal == nil) then 
		--print("nil : "..tostring( a ).." = "..tostring(aVal).." : "..tostring( b ).." = "..tostring(bVal))
		if aVal and (bVal == nil) then
			return false;
		elseif (aVal == nil) and bVal then
			return true;
		else
			return tostring(a) < tostring(b); -- gotta do something deterministic
        end;
    else
        return aVal < bVal;
    end
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

CivilopediaCategory[CategoryMain].SelectHeading = function( selectedEraID, dummy )
	print("CivilopediaCategory[CategoryMain].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first era
	--local thisListInstance = g_ListItemManager:GetInstance();
	--if thisListInstance then
	--	sortOrder = sortOrder + 1;
	--	thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_HOME_PAGE_LABEL" ));
	--	thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
	--	thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryMain].buttonClicked );
	--	thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
	--	otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	--end
	
	Controls.ListOfArticles:CalculateSize();
	Controls.ScrollPanel:CalculateInternalSize();
end

CivilopediaCategory[CategoryConcepts].SelectHeading = function( selectedEraID, dummy )
print("CivilopediaCategory[CategoryConcepts].SelectHeading ----") -- dbg
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryConcepts][selectedEraID].headingOpen = not sortedList[CategoryConcepts][selectedEraID].headingOpen; -- ain't lua great
--start working here on making the display not f up when closes

	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first era
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_GAME_CONCEPT_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end
	
	local numConcepts = #sortedList[CategoryConcepts];
	for section = 1, numConcepts, 1 do	
		-- print("for section ---- "..tostring(section)) -- dbg
		-- add a section header
		local thisHeaderInstance;
		if section == 1 then
			thisHeaderInstance = g_ListHeadingManagerC2:GetInstance();
		else
			thisHeaderInstance = g_ListHeadingManager:GetInstance();
		end
			
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			local textString = "TXT_KEY_GAME_CONCEPT_SECTION_"..tostring( section );
			-- coloring
			if section == 1 then
				textString = "TXT_KEY_GAME_CONCEPT_SECTION_"..tostring( section ) .. "_AC" ;
				if sortedList[CategoryConcepts][section].headingOpen then
					local localizedLabel = "[ICON_MINUS_GREEN] "..Locale.ConvertTextKey( textString );
					-- localizedLabel = string.format("[COLOR:116,161,155,255]" .. localizedLabel .. "[ENDCOLOR]");
					thisHeaderInstance.ListHeadingLabelC2:SetText( localizedLabel );
				else
					local localizedLabel = "[ICON_PLUS_GREEN] "..Locale.ConvertTextKey( textString );
					-- localizedLabel = string.format("[COLOR:116,161,155,255]" .. localizedLabel .. "[ENDCOLOR]");
					thisHeaderInstance.ListHeadingLabelC2:SetText( localizedLabel );
				end
				thisHeaderInstance.ListHeadingButtonC2:SetVoids( section, 0 );
				thisHeaderInstance.ListHeadingButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].SelectHeading );
				otherSortedList[tostring( thisHeaderInstance.ListHeadingButtonC2 )] = sortOrder;

			else
				if sortedList[CategoryConcepts][section].headingOpen then
					local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
					thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
				else
					local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
					thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
				end
				thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
				thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].SelectHeading );
				otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
			end	
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryConcepts][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryConcepts][section]) do
				-- print("for ipairs(sortedList[CategoryConcepts][section]) ---- "..tostring(section)) -- dbg
				if section == 1 then
					local thisListInstance = g_ListItemManagerC2:GetInstance();
					if thisListInstance then
						sortOrder = sortOrder + 1;
						thisListInstance.ListItemLabelC2:SetText( v.entryName );
						thisListInstance.ListItemButtonC2:SetVoids( v.entryID, addToList );
						thisListInstance.ListItemButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].SelectArticle );
						thisListInstance.ListItemButtonC2:SetToolTipCallback( TipHandler )
						otherSortedList[tostring( thisListInstance.ListItemButtonC2 )] = sortOrder;
					end
				else
					local thisListInstance = g_ListItemManager:GetInstance();
					if thisListInstance then
						sortOrder = sortOrder + 1;
						thisListInstance.ListItemLabel:SetText( v.entryName );
						thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
						thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].SelectArticle );
						thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
						otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
					end
				end
			end
		end
	end
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
end

CivilopediaCategory[CategoryTech].SelectHeading = function( selectedEraID, dummy )
	print("CivilopediaCategory[CategoryTech].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryTech].headingOpen = not sortedList[CategoryTech].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first era
	local thisTechInstance = g_ListItemManager:GetInstance();
	if thisTechInstance then
		sortOrder = sortOrder + 1;
		thisTechInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TECH_PAGE_LABEL" ));
		thisTechInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisTechInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTech].buttonClicked );
		thisTechInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisTechInstance.ListItemButton )] = sortOrder;
	end

	-- for each element of the sorted list		
	if sortedList[CategoryTech].headingOpen then
		for i, v in ipairs(sortedList[CategoryTech]) do
			local thisListInstance = g_ListItemManager:GetInstance();
			if thisListInstance then
				sortOrder = sortOrder + 1;
				thisListInstance.ListItemLabel:SetText( v.entryName );
				thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
				thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTech].SelectArticle );
				thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
				otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
			end
		end
	end
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryUnits].SelectHeading = function( selectedEraID, dummy )
	print("CivilopediaCategory[CategoryUnits].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryUnits][selectedEraID].headingOpen = not sortedList[CategoryUnits][selectedEraID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first era
	-- local thisListInstance = g_ListItemManager:GetInstance();
	local thisListInstance = g_ListItemManagerC2:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabelC2:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_UNITS_PAGE_LABEL" ));
		thisListInstance.ListItemButtonC2:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUnits].buttonClicked );
		thisListInstance.ListItemButtonC2:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButtonC2 )] = sortOrder;
	end


------ mutate this
	-- for each element of the sorted list		
	-- function PopulateHeaderAndItems(categoryID)
		-- if sortedList[CategoryUnits].headingOpen then
			-- for i, v in ipairs(sortedList[CategoryUnits]) do
				-- local thisListInstance = g_ListItemManager:GetInstance();
				-- if thisListInstance then
					-- sortOrder = sortOrder + 1;
					-- thisListInstance.ListItemLabel:SetText( v.entryName );
					-- thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					-- thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUnits].SelectArticle );
					-- thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					-- otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				-- end
			-- end
		-- end
	-- end
	
	-- PopulateHeaderAndItems(0)
------ mutate this
------ into this
	for section = 1, 5, 1 do
		-- add a section header
		-- local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		local thisHeaderInstance = g_ListHeadingManagerC2:GetInstance();
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			if sortedList[CategoryUnits][section].headingOpen then
				local textString = "TXT_KEY_UNITS_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_MINUS_GREEN] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabelC2:SetText( localizedLabel );
			else
				local textString = "TXT_KEY_UNITS_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_PLUS_GREEN] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabelC2:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButtonC2:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUnits].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButtonC2 )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryUnits][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryUnits][section]) do
				-- local thisListInstance = g_ListItemManager:GetInstance();
				local thisListInstance = g_ListItemManagerC2:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabelC2:SetText( v.entryName );
					thisListInstance.ListItemButtonC2:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUnits].SelectArticle );
					thisListInstance.ListItemButtonC2:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButtonC2 )] = sortOrder;
				end
			end
		end
	end	
------ into this

	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();	
end

CivilopediaCategory[CategoryUpgrades].SelectHeading = function( selectedSection, dummy )
	print("CivilopediaCategory[CategoryUpgrades].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryUpgrades][selectedSection].headingOpen = not sortedList[CategoryUpgrades][selectedSection].headingOpen; -- ain't lua great

	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first era
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_UPGRADES_HEADING1_TITLE" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUpgrades].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for unitIndex = 1, #sortedList[CategoryUpgrades], 1 do
		if (sortedList[CategoryUpgrades][unitIndex][1] ~= nil) then
			-- add a section header
			local thisHeaderInstance = g_ListHeadingManager:GetInstance();
			if thisHeaderInstance then
				sortOrder = sortOrder + 1;
				local upgradeInfo = GameInfo.UnitUpgrades[sortedList[CategoryUpgrades][unitIndex][1].entryID];
				local unitInfo = GameInfo.Units[upgradeInfo.UnitType];
				local text = Locale.ConvertTextKey(unitInfo.Description);
				if sortedList[CategoryUpgrades][unitIndex].headingOpen then
					text = "[ICON_MINUS] " .. text;
				else
					text = "[ICON_PLUS] " .. text;
				end
				thisHeaderInstance.ListHeadingLabel:SetText(text);
				thisHeaderInstance.ListHeadingButton:SetVoids( unitIndex, 0 );
				thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUpgrades].SelectHeading );
				otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
			end

			-- for each element of the sorted list
			if sortedList[CategoryUpgrades][unitIndex].headingOpen then
				for i, v in ipairs(sortedList[CategoryUpgrades][unitIndex]) do
					local thisListInstance = g_ListItemManager:GetInstance();
					if thisListInstance then
						sortOrder = sortOrder + 1;
						thisListInstance.ListItemLabel:SetText( v.entryName );
						thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
						thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUpgrades].SelectArticle );
						thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
						otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
					end
				end
			end
		end
	end
	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();

end

CivilopediaCategory[CategoryBuildings].SelectHeading = function( selectedEraID, dummy )
	print("CivilopediaCategory[CategoryBuildings].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryBuildings][selectedEraID].headingOpen = not sortedList[CategoryBuildings][selectedEraID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first era
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_BUILDINGS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryBuildings].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end
	
	function PopulateAndAdd(categoryID)

		-- for each element of the sorted list		
		if sortedList[CategoryBuildings].headingOpen then
			for i, v in ipairs(sortedList[CategoryBuildings]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryBuildings].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end
	end

	PopulateAndAdd(0);
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();	
end

CivilopediaCategory[CategoryWonders].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryWonders].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryWonders][selectedSectionID].headingOpen = not sortedList[CategoryWonders][selectedSectionID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_WONDERS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 3, 1 do	
		-- add a section header
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			if sortedList[CategoryWonders][section].headingOpen then
				local textString = "TXT_KEY_WONDER_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local textString = "TXT_KEY_WONDER_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryWonders][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryWonders][section]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryVirtues].SelectHeading = function( selectedBranchID, dummy )
	print("CivilopediaCategory[CategoryVirtues].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryVirtues][selectedBranchID].headingOpen = not sortedList[CategoryVirtues][selectedBranchID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first branch
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_POLICIES_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryVirtues].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for branch in GameInfo.PolicyBranchTypes() do
	
		local branchID = branch.ID;
		-- add a branch header
		local thisHeadingInstance = g_ListHeadingManager:GetInstance();
		if thisHeadingInstance then
			sortOrder = sortOrder + 1;
			if sortedList[CategoryVirtues][branchID].headingOpen then
				local textString = branch.Description;
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeadingInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local textString = branch.Description;
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeadingInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			thisHeadingInstance.ListHeadingButton:SetVoids( branchID, 0 );
			thisHeadingInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryVirtues].SelectHeading );
			otherSortedList[tostring( thisHeadingInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryVirtues][branchID].headingOpen then
			for i, v in ipairs(sortedList[CategoryVirtues][branchID]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryVirtues].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryEspionage].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryEspionage].SelectHeading");
	error("This method should never be hit as this category has no headings.");	
end

CivilopediaCategory[CategoryCivilizations].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryCivilizations].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryCivilizations][selectedSectionID].headingOpen = not sortedList[CategoryCivilizations][selectedSectionID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		-- thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_CIVILIZATIONS_PAGE_LABEL" ));
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_10_AC_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryCivilizations].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 2, 1 do	
		-- add a section header
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			if sortedList[CategoryCivilizations][section].headingOpen then
				local textString = "TXT_KEY_CIVILIZATION_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local textString = "TXT_KEY_CIVILIZATION_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryCivilizations].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryCivilizations][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryCivilizations][section]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryCivilizations].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryQuests].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryQuests].SelectHeading");
	error("This function should never be hit as this category has no headings.");
end

CivilopediaCategory[CategoryTerrain].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryTerrain].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryTerrain][selectedSectionID].headingOpen = not sortedList[CategoryTerrain][selectedSectionID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAIN_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTerrain].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 4, 1 do	
		-- add a section header
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			local textString = "TXT_KEY_TERRAIN_SECTION_"..tostring( section );
			if section == 4 then textString = "TXT_KEY_TERRAIN_SECTION_"..tostring( section ).."_AC"; end
			if sortedList[CategoryTerrain][section].headingOpen then
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTerrain].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryTerrain][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryTerrain][section]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTerrain].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryResources].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryResources].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryResources][selectedSectionID].headingOpen = not sortedList[CategoryResources][selectedSectionID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_RESOURCES_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryResources].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 0, 2, 1 do	
		-- add a section header
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			if sortedList[CategoryResources][section].headingOpen then
				local textString = "TXT_KEY_RESOURCES_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local textString = "TXT_KEY_RESOURCES_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryResources].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryResources][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryResources][section]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID + ((v.entryIDAlt+1) * 65536), addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryResources].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryImprovements].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryImprovements].SelectHeading"); -- dbg
	-- todo: implement if there are ever sections in the Improvements page
	-- print("I should never get here");		
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();
	
	sortedList[CategoryImprovements][selectedSectionID].headingOpen = not sortedList[CategoryImprovements][selectedSectionID].headingOpen; -- ain't lua great

	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENTS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryImprovements].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 3, 1 do	
		-- add a section header
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			if sortedList[CategoryImprovements][section].headingOpen then
				local textString = "TXT_KEY_IMPROVEMENTS_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local textString = "TXT_KEY_IMPROVEMENTS_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryImprovements].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryImprovements][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryImprovements][section]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryImprovements].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
end

CivilopediaCategory[CategoryAffinities].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryAffinities].SelectHeading");
	error("This function should never be hit as this category has no headings.");
end

CivilopediaCategory[CategoryStations].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryAffinities].SelectHeading");
	error("This function should never be hit as this category has no headings.");
end

CivilopediaCategory[CategoryDiplomacy].SelectHeading = function( selectedSectionID, dummy )
	-- print("CivilopediaCategory[CategoryDiplomacy].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryDiplomacy][selectedSectionID].headingOpen = not sortedList[CategoryDiplomacy][selectedSectionID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_DIPLOMACY_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryDiplomacy].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 8, 1 do	
		-- add a section header
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		local textString = "TXT_KEY_DIPLOMACY_AC_SECTION_"..tostring( section );
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			if sortedList[CategoryDiplomacy][section].headingOpen then
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryDiplomacy].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryDiplomacy][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryDiplomacy][section]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryDiplomacy].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end
	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
	Controls.ScrollPanel:CalculateInternalSize();
end

CivilopediaCategory[CategoryArtifacts].SelectHeading = function( selectedSectionID, dummy )
	print("CivilopediaCategory[CategoryArtifacts].SelectHeading");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	sortedList[CategoryArtifacts][selectedSectionID].headingOpen = not sortedList[CategoryArtifacts][selectedSectionID].headingOpen; -- ain't lua great
	
	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_ARTIFACTS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryArtifacts].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 4, 1 do	
		-- add a section header
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		local textString = "TXT_KEY_ARTIFACTS_SECTION_AC_"..tostring( section );
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			if sortedList[CategoryArtifacts][section].headingOpen then
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryArtifacts].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryArtifacts][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryArtifacts][section]) do
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryArtifacts].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
end

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

CivilopediaCategory[CategoryMain].DisplayList = function( selectedSection, dummy )
	print("CivilopediaCategory[CategoryMain].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the rest of the stuff
	--local thisListInstance = g_ListItemManager:GetInstance();
	--if thisListInstance then
	--	sortOrder = sortOrder + 1;
	--	thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_HOME_PAGE_LABEL" ));
	--	thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
	--	thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryMain].buttonClicked );
	--	thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
	--	otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	--end
		-- for each element of the sorted list		
	for i, v in ipairs(sortedList[CategoryMain][1]) do
		-- add an entry
		local thisListInstance = g_ListItemManager:GetInstance();
		if thisListInstance then
			sortOrder = sortOrder + 1;
			thisListInstance.ListItemLabel:SetText( v.entryName );
			thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
			thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryMain].SelectArticle );
			thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
			otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
		end
	end
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
end

CivilopediaCategory[CategoryConcepts].DisplayList = function( selectedSection, dummy )
	print("CivilopediaCategory[CategoryConcepts].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};

	-- put in a home page before the rest of the stuff
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_GAME_CONCEPT_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end
	
	-- for each element of the sorted list
	local numSections = #sortedList[CategoryConcepts];
	
	local GameConceptsList = sortedList[CategoryConcepts];
	for section = 1,numSections,1 do
		
		local headingOpen = GameConceptsList[section].headingOpen;
		if(headingOpen == nil) then
			headingOpen = true;
			GameConceptsList[section].headingOpen = true;
		end
		
		if section == 1 then 
			headingOpen = true;
			GameConceptsList[section].headingOpen = true;
		end;
		
		
		local thisHeaderInstance;
		-- green
		if section == 1 then 
			thisHeaderInstance = g_ListHeadingManagerC2:GetInstance();
		else
			thisHeaderInstance = g_ListHeadingManager:GetInstance();
		end;		
		
		if thisHeaderInstance then
		
			sortOrder = sortOrder + 1;
			local textString = "TXT_KEY_GAME_CONCEPT_SECTION_"..tostring( section );
			-- coloring
			if section == 1 then
				textString = "TXT_KEY_GAME_CONCEPT_SECTION_"..tostring( section ) .. "_AC" ;
				thisHeaderInstance.ListHeadingButtonC2:SetVoids( section, 0 );
				thisHeaderInstance.ListHeadingButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].SelectHeading );
				otherSortedList[tostring( thisHeaderInstance.ListHeadingButtonC2 )] = sortOrder;
				if(headingOpen == true) then
					local localizedLabel = "[ICON_MINUS_GREEN] "..Locale.ConvertTextKey( textString );
					-- localizedLabel = string.format("[COLOR:116,161,155,255]" .. localizedLabel .. "[ENDCOLOR]");
					thisHeaderInstance.ListHeadingLabelC2:SetText( localizedLabel );
				else
					local localizedLabel = "[ICON_PLUS_GREEN] "..Locale.ConvertTextKey( textString );
					-- localizedLabel = string.format("[COLOR:116,161,155,255]" .. localizedLabel .. "[ENDCOLOR]");
					thisHeaderInstance.ListHeadingLabelC2:SetText( localizedLabel );
				end	
			else
				thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
				thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].SelectHeading );
				otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
				if(headingOpen == true) then
					local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
					thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
				else
					local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
					thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
				end			
			end
		end	
		
		if(headingOpen == true) then
			for i, v in ipairs(sortedList[CategoryConcepts][section]) do
				-- add an entry
				if section == 1 then
					local thisListInstance = g_ListItemManagerC2:GetInstance();
					if thisListInstance then
						sortOrder = sortOrder + 1;
						thisListInstance.ListItemLabelC2:SetText( v.entryName );
						thisListInstance.ListItemButtonC2:SetVoids( v.entryID, addToList );
						thisListInstance.ListItemButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].SelectArticle );
						thisListInstance.ListItemButtonC2:SetToolTipCallback( TipHandler )
						otherSortedList[tostring( thisListInstance.ListItemButtonC2 )] = sortOrder;
					end
				else
					local thisListInstance = g_ListItemManager:GetInstance();
					if thisListInstance then
						sortOrder = sortOrder + 1;
						thisListInstance.ListItemLabel:SetText( v.entryName );
						thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
						thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryConcepts].SelectArticle );
						thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
						otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
					end
				end
			end
		end
	end
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
	Controls.ScrollPanel:CalculateInternalSize();
end

CivilopediaCategory[CategoryTech].DisplayList = function()
	print("CivilopediaCategory[CategoryTech].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();
	
	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first era
	local thisTechInstance = g_ListItemManager:GetInstance();
	if thisTechInstance then
		sortOrder = sortOrder + 1;
		thisTechInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TECH_PAGE_LABEL" ));
		thisTechInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisTechInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTech].buttonClicked );
		thisTechInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisTechInstance.ListItemButton )] = sortOrder;
	end


	-- for each element of the sorted list		
	for i, v in ipairs(sortedList[CategoryTech]) do
		-- add a tech entry
		local thisTechInstance = g_ListItemManager:GetInstance();
		if thisTechInstance then
			sortOrder = sortOrder + 1;
			thisTechInstance.ListItemLabel:SetText( v.entryName );
			thisTechInstance.ListItemButton:SetVoids( v.entryID, addToList );
			thisTechInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTech].SelectArticle );
			thisTechInstance.ListItemButton:SetToolTipCallback( TipHandler );
			otherSortedList[tostring( thisTechInstance.ListItemButton )] = sortOrder;
		end
	end
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
end

CivilopediaCategory[CategoryUnits].DisplayList = function()
	print("CivilopediaCategory[CategoryUnits].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first era
	-- local thisListInstance = g_ListItemManager:GetInstance();
	local thisListInstance = g_ListItemManagerC2:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabelC2:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_UNITS_PAGE_LABEL" ));
		thisListInstance.ListItemButtonC2:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUnits].buttonClicked );
		thisListInstance.ListItemButtonC2:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButtonC2 )] = sortOrder;
	end
	
--------
	-- for each element of the sorted list	
	for section = 1, 5, 1 do
		-- add a section header
		-- local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		local thisHeaderInstance = g_ListHeadingManagerC2:GetInstance();
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			-- sortedList[CategoryUnits][section].headingOpen = true; -- ain't lua great
			if sortedList[CategoryUnits][section].headingOpen then	-- Lets remember the position. PW
				local textString = "TXT_KEY_UNITS_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_MINUS_GREEN] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabelC2:SetText( localizedLabel );
			else
				local textString = "TXT_KEY_UNITS_SECTION_"..tostring( section );
				local localizedLabel = "[ICON_PLUS_GREEN] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabelC2:SetText( localizedLabel );
			end
			thisHeaderInstance.ListHeadingButtonC2:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUnits].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButtonC2 )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryUnits][section].headingOpen then
			for i, v in ipairs(sortedList[CategoryUnits][section]) do
				-- local thisListInstance = g_ListItemManager:GetInstance();
				local thisListInstance = g_ListItemManagerC2:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabelC2:SetText( v.entryName );
					thisListInstance.ListItemButtonC2:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButtonC2:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUnits].SelectArticle );
					thisListInstance.ListItemButtonC2:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButtonC2 )] = sortOrder;
				end
			end
		end
	end	
--------

	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
	Controls.ScrollPanel:CalculateInternalSize();
		
end

CivilopediaCategory[CategoryUpgrades].DisplayList = function()
	print("start CivilopediaCategory[CategoryUpgrades].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();
	
	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the rest of the stuff
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_UPGRADES_HEADING1_TITLE" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUpgrades].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	-- for each element of the sorted list		
	for unitIndex = 1, #sortedList[CategoryUpgrades], 1 do
		if (sortedList[CategoryUpgrades][unitIndex][1] ~= nil) then
			local thisHeaderInstance = g_ListHeadingManager:GetInstance();
			if thisHeaderInstance then
				sortedList[CategoryUpgrades][unitIndex].headingOpen = true;
				sortOrder = sortOrder + 1;
				local upgradeInfo = GameInfo.UnitUpgrades[sortedList[CategoryUpgrades][unitIndex][1].entryID];
				local unitInfo = GameInfo.Units[upgradeInfo.UnitType];
				local text = "[ICON_MINUS] " .. Locale.ConvertTextKey(unitInfo.Description);
				thisHeaderInstance.ListHeadingLabel:SetText(text);
				thisHeaderInstance.ListHeadingButton:SetVoids( unitIndex, 0 );
				thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUpgrades].SelectHeading );
				otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
			end

			for i, v in ipairs(sortedList[CategoryUpgrades][unitIndex]) do
				-- add an entry
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryUpgrades].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end
	end

	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
	Controls.ScrollPanel:CalculateInternalSize();
end

CivilopediaCategory[CategoryBuildings].DisplayList = function()
	print("CivilopediaCategory[CategoryBuildings].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first era
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_BUILDINGS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryBuildings].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end
	
	function PopulateAndAdd(categoryID)
		-- for each element of the sorted list		
		for i, v in ipairs(sortedList[CategoryBuildings]) do
			-- add an entry
			local thisListInstance = g_ListItemManager:GetInstance();
			if thisListInstance then
				sortOrder = sortOrder + 1;
				thisListInstance.ListItemLabel:SetText( v.entryName );
				thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
				thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryBuildings].SelectArticle );
				thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
				otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
			end
		end
	end

	PopulateAndAdd(0);
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
end

CivilopediaCategory[CategoryWonders].DisplayList = function()
	print("CivilopediaCategory[CategoryWonders].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_WONDERS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 3, 1 do	
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortedList[CategoryWonders][section].headingOpen = true; -- ain't lua great
			sortOrder = sortOrder + 1;
			local textString = "TXT_KEY_WONDER_SECTION_"..tostring( section );
			local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
			thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		for i, v in ipairs(sortedList[CategoryWonders][section]) do
			-- add a unit entry
			local thisListInstance = g_ListItemManager:GetInstance();
			if thisListInstance then
				sortOrder = sortOrder + 1;
				thisListInstance.ListItemLabel:SetText( v.entryName );
				thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
				thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryWonders].SelectArticle );
				thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
				otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
	Controls.ScrollPanel:CalculateInternalSize();
		
end

CivilopediaCategory[CategoryVirtues].DisplayList = function()
	print("CivilopediaCategory[CategoryVirtues].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first branch
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_POLICIES_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryVirtues].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for branch in GameInfo.PolicyBranchTypes() do
	
		local branchID = branch.ID;
		-- add a branch header
		local thisHeadingInstance = g_ListHeadingManager:GetInstance();
		if thisHeadingInstance then
			sortedList[CategoryVirtues][branchID].headingOpen = true; -- ain't lua great
			sortOrder = sortOrder + 1;
			local textString = branch.Description;
			local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
			thisHeadingInstance.ListHeadingLabel:SetText( localizedLabel );
			thisHeadingInstance.ListHeadingButton:SetVoids( branchID, 0 );
			thisHeadingInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryVirtues].SelectHeading );
			otherSortedList[tostring( thisHeadingInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		for i, v in ipairs(sortedList[CategoryVirtues][branchID]) do
			-- add an entry
			local thisListInstance = g_ListItemManager:GetInstance();
			if thisListInstance then
				sortOrder = sortOrder + 1;
				thisListInstance.ListItemLabel:SetText( v.entryName );
				thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
				thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryVirtues].SelectArticle );
				thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
				otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryEspionage].DisplayList = function()
	print("CivilopediaCategory[CategoryEspionage].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	local espionageLabel = "TXT_KEY_PEDIA_ESPIONAGE_PAGE_LABEL";

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( espionageLabel ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryEspionage].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end
	
	local espionageList = sortedList[CategoryEspionage];
	local onArticleSelect = CivilopediaCategory[CategoryEspionage].SelectArticle
	
	for _, v in ipairs(espionageList) do	

		-- add a unit entry
		local thisListInstance = g_ListItemManager:GetInstance();
		if thisListInstance then
			thisListInstance.ListItemLabel:SetText( v.entryName );
			thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
			thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, onArticleSelect );
			thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
			sortOrder = sortOrder + 1;
			otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
		end
	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryCivilizations].DisplayList = function()
	print("CivilopediaCategory[CategoryCivilizations].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		-- thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_CIVILIZATIONS_PAGE_LABEL" ));
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_CATEGORY_10_AC_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryCivilizations].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 2, 1 do	
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortedList[CategoryCivilizations][section].headingOpen = true; -- ain't lua great
			sortOrder = sortOrder + 1;
			local textString = "TXT_KEY_CIVILIZATIONS_SECTION_"..tostring( section );
			local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
			thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryCivilizations].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		for i, v in ipairs(sortedList[CategoryCivilizations][section]) do
			-- add a unit entry
			local thisListInstance = g_ListItemManager:GetInstance();
			if thisListInstance then
				sortOrder = sortOrder + 1;
				thisListInstance.ListItemLabel:SetText( v.entryName );
				thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
				thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryCivilizations].SelectArticle );
				thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
				otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryQuests].DisplayList = function()

	print("CivilopediaCategory[CategoryQuests].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	
	local headerlabel = "TXT_KEY_PEDIA_QUESTS_PAGE_LABEL";

	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( headerlabel ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryQuests].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end
	
	local espionageList = sortedList[CategoryQuests];
	local onArticleSelect = CivilopediaCategory[CategoryQuests].SelectArticle
	
	for _, v in ipairs(espionageList) do	

		-- add a unit entry
		local thisListInstance = g_ListItemManager:GetInstance();
		if thisListInstance then
			thisListInstance.ListItemLabel:SetText( v.entryName );
			thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
			thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, onArticleSelect );
			thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
			sortOrder = sortOrder + 1;
			otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
		end
	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
		
end

CivilopediaCategory[CategoryTerrain].DisplayList = function()
	print("CivilopediaCategory[CategoryTerrain].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_TERRAIN_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTerrain].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 4, 1 do	
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortedList[CategoryTerrain][section].headingOpen = true; -- ain't lua great
			sortOrder = sortOrder + 1;
			local textString = "TXT_KEY_TERRAIN_SECTION_"..tostring( section );
			if section == 4 then textString = "TXT_KEY_TERRAIN_SECTION_"..tostring( section ).."_AC"; end
			local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
			thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTerrain].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		for i, v in ipairs(sortedList[CategoryTerrain][section]) do
			-- add a unit entry
			local thisListInstance = g_ListItemManager:GetInstance();
			if thisListInstance then
				sortOrder = sortOrder + 1;
				thisListInstance.ListItemLabel:SetText( v.entryName );
				thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
				thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryTerrain].SelectArticle );
				thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
				otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryResources].DisplayList = function()
	print("CivilopediaCategory[CategoryResources].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_RESOURCES_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryResources].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 0, 2, 1 do	
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortedList[CategoryResources][section].headingOpen = true; -- ain't lua great
			sortOrder = sortOrder + 1;
			local textString = "TXT_KEY_RESOURCES_SECTION_"..tostring( section );
			local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
			thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryResources].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		for i, v in ipairs(sortedList[CategoryResources][section]) do
			-- add a unit entry
			local thisListInstance = g_ListItemManager:GetInstance();
			if thisListInstance then
				sortOrder = sortOrder + 1;
				thisListInstance.ListItemLabel:SetText( v.entryName );
				thisListInstance.ListItemButton:SetVoids( v.entryID + ((v.entryIDAlt+1) * 65536), addToList );
				thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryResources].SelectArticle );
				thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
				otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
		
end

CivilopediaCategory[CategoryImprovements].DisplayList = function()
	print("start CivilopediaCategory[CategoryImprovements].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();
	
	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the rest of the stuff
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_IMPROVEMENTS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryImprovements].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end
	

	for section = 1, 3, 1 do	
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		if thisHeaderInstance then
			sortedList[CategoryImprovements][section].headingOpen = true; -- ain't lua great
			sortOrder = sortOrder + 1;
			local textString = "TXT_KEY_IMPROVEMENTS_SECTION_"..tostring( section );
			local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
			thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryImprovements].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		for i, v in ipairs(sortedList[CategoryImprovements][section]) do
			-- add a unit entry
			local thisListInstance = g_ListItemManager:GetInstance();
			if thisListInstance then
				sortOrder = sortOrder + 1;
				thisListInstance.ListItemLabel:SetText( v.entryName );
				thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
				thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryImprovements].SelectArticle );
				thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
				otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
			end
		end

	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();

end

CivilopediaCategory[CategoryAffinities].DisplayList = function()
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_AFFINITIES_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryAffinities].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	-- for each element of the sorted list		
	for i, v in ipairs(sortedList[CategoryAffinities]) do
		-- add a unit entry
		local thisListInstance = g_ListItemManager:GetInstance();
		if thisListInstance then
			sortOrder = sortOrder + 1;
			thisListInstance.ListItemLabel:SetText( v.entryName );
			thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
			thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, function(dummy, shouldAddToList) CivilopediaCategory[CategoryAffinities].SelectArticle(v.entryID, shouldAddToList); end);
			thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
			otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
		end
	end
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();

end

CivilopediaCategory[CategoryStations].DisplayList = function()
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_STATIONS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryStations].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	-- for each element of the sorted list		
	for i, v in ipairs(sortedList[CategoryStations]) do
		-- add a unit entry
		local thisListInstance = g_ListItemManager:GetInstance();
		if thisListInstance then
			sortOrder = sortOrder + 1;
			thisListInstance.ListItemLabel:SetText( v.entryName );
			thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
			thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, function(dummy, shouldAddToList) CivilopediaCategory[CategoryStations].SelectArticle(v.entryID, shouldAddToList); end);
			thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
			otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
		end
	end
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();

end

CivilopediaCategory[CategoryDiplomacy].DisplayList = function()		 -- PW
	-- print("CivilopediaCategory[CategoryDiplomacy].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_DIPLOMACY_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryDiplomacy].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 8, 1 do	
		-- print("for section = "..section.." do"); -- dbg
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		local textString = "TXT_KEY_DIPLOMACY_AC_SECTION_"..tostring( section );
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			-- sortedList[CategoryDiplomacy][section].headingOpen = true;
			if sortedList[CategoryDiplomacy][section].headingOpen then	-- Lets remember the position. PW
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			-- local textString = "TXT_KEY_DIPLOMACY_SECTION_"..tostring( section );
			-- local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
			-- thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryDiplomacy].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list		
		if sortedList[CategoryDiplomacy][section].headingOpen then		--	PW
			-- print("section "..section.." opened"); -- dbg
			for i, v in ipairs(sortedList[CategoryDiplomacy][section]) do
				-- add entry
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryDiplomacy].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
					-- print("add "..v.entryName.." "); -- dbg
				end
			end
		end
	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
	Controls.ScrollPanel:CalculateInternalSize();
end

CivilopediaCategory[CategoryArtifacts].DisplayList = function()
	print("CivilopediaCategory[CategoryArtifacts].DisplayList");
	g_ListHeadingManager:DestroyInstances(); 	g_ListHeadingManagerC2:DestroyInstances();
	g_ListItemManager:DestroyInstances();	g_ListItemManagerC2:DestroyInstances();

	local sortOrder = 0;
	otherSortedList = {};
	
	-- put in a home page before the first section
	local thisListInstance = g_ListItemManager:GetInstance();
	if thisListInstance then
		sortOrder = sortOrder + 1;
		thisListInstance.ListItemLabel:SetText( Locale.ConvertTextKey( "TXT_KEY_PEDIA_ARTIFACTS_PAGE_LABEL" ));
		thisListInstance.ListItemButton:SetVoids( homePageOfCategoryID, addToList );
		thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryArtifacts].buttonClicked );
		thisListInstance.ListItemButton:SetToolTipCallback( TipHandler );
		otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
	end

	for section = 1, 4, 1 do	
		local thisHeaderInstance = g_ListHeadingManager:GetInstance();
		local textString = "TXT_KEY_ARTIFACTS_SECTION_AC_"..tostring( section );
		if thisHeaderInstance then
			sortOrder = sortOrder + 1;
			-- sortedList[CategoryArtifacts][section].headingOpen = true;
			if sortedList[CategoryArtifacts][section].headingOpen then	-- Lets remember the position. PW
				local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			else
				local localizedLabel = "[ICON_PLUS] "..Locale.ConvertTextKey( textString );
				thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			end
			-- local textString = "TXT_KEY_ARTIFACTS_SECTION_"..tostring( section );
			-- local localizedLabel = "[ICON_MINUS] "..Locale.ConvertTextKey( textString );
			-- thisHeaderInstance.ListHeadingLabel:SetText( localizedLabel );
			thisHeaderInstance.ListHeadingButton:SetVoids( section, 0 );
			thisHeaderInstance.ListHeadingButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryArtifacts].SelectHeading );
			otherSortedList[tostring( thisHeaderInstance.ListHeadingButton )] = sortOrder;
		end	
		
		-- for each element of the sorted list	
		if sortedList[CategoryArtifacts][section].headingOpen then		--	PW	
			for i, v in ipairs(sortedList[CategoryArtifacts][section]) do
				-- add a unit entry
				local thisListInstance = g_ListItemManager:GetInstance();
				if thisListInstance then
					sortOrder = sortOrder + 1;
					thisListInstance.ListItemLabel:SetText( v.entryName );
					thisListInstance.ListItemButton:SetVoids( v.entryID, addToList );
					thisListInstance.ListItemButton:RegisterCallback( Mouse.eLClick, CivilopediaCategory[CategoryArtifacts].SelectArticle );
					thisListInstance.ListItemButton:SetToolTipCallback( TipHandler )
					otherSortedList[tostring( thisListInstance.ListItemButton )] = sortOrder;
				end
			end
		end
	end	
	
	Controls.ListOfArticles:SortChildren( SortFunction );
	ResizeEtc();
	Controls.ScrollPanel:CalculateInternalSize();
end

-- ===========================================================================
-- ===========================================================================
function ClearArticle()
	Controls.ScrollPanel:SetScrollValue( 0 );
	Controls.PortraitFrame:SetHide( true );
	Controls.Portrait2:SetHide( true );  -- PW
	Controls.Portrait3:SetHide( true );  -- PW
	Controls.Portrait4:SetHide( true );  -- PW
	Controls.Portrait5:SetHide( true );  -- PW
	Controls.CostFrame:SetHide( true );
	Controls.MaintenanceFrame:SetHide( true );
	Controls.HealthFrame:SetHide( true );
	Controls.CultureFrame:SetHide( true );
	Controls.FaithFrame:SetHide( true );
	Controls.DefenseFrame:SetHide( true );
	Controls.FoodFrame:SetHide( true );
	Controls.GoldFrame:SetHide( true );
	Controls.ScienceFrame:SetHide( true );
	Controls.ProductionFrame:SetHide( true );
	Controls.DiploCapitalFrame:SetHide( true );
	Controls.CombatFrame:SetHide( true );
	Controls.RangedCombatFrame:SetHide( true );
	Controls.RangedCombatRangeFrame:SetHide( true );
	Controls.MovementFrame:SetHide( true );
	Controls.OrbitalEffectRangeFrame:SetHide(true);
	Controls.OrbitalTurnDurationFrame:SetHide(true);
	Controls.FreePromotionsFrame:SetHide( true );
	Controls.PrereqTechFrame:SetHide( true );
	Controls.PrereqVirtueFrame:SetHide( true ); ---- PW
	Controls.PrereqAffinityFrame:SetHide( true ); ---- PW
	Controls.LeadsToTechFrame:SetHide( true );
	Controls.ObsoleteTechFrame:SetHide( true );
	Controls.UpgradeFrame:SetHide( true );
	Controls.UnlockedUnitsFrame:SetHide( true );
	Controls.UnlockedBuildingsFrame:SetHide( true );
	Controls.RequiredBuildingsFrame:SetHide( true );
	Controls.RevealedResourcesFrame:SetHide( true );
	Controls.RequiredResourcesFrame:SetHide( true );
	Controls.RequiredPromotionsFrame:SetHide( true );
	Controls.LocalResourcesFrame:SetHide( true );
	Controls.WorkerActionsFrame:SetHide( true );
	Controls.UnlockedProjectsFrame:SetHide( true );
	Controls.SpecialistsFrame:SetHide( true );
	Controls.RelatedArticlesFrame:SetHide( true );
	Controls.GameInfoFrame:SetHide( true );
	Controls.QuoteFrame:SetHide( true );
	Controls.SilentQuoteFrame:SetHide( true );
	Controls.AbilitiesFrame:SetHide( true );			
	Controls.HistoryFrame:SetHide( true );
	Controls.StrategyFrame:SetHide( true );
	Controls.RelatedImagesFrame:SetHide( true );		
	Controls.SummaryFrame:SetHide( true );		
	Controls.SummaryC2Frame:SetHide( true );	 ---- PW	
	Controls.ExtendedFrame:SetHide( true );		
	Controls.DNotesFrame:SetHide( true );		
	Controls.RequiredPoliciesFrame:SetHide( true );		
	Controls.PrereqEraFrame:SetHide( true );		
	Controls.PolicyBranchFrame:SetHide( true );	
	Controls.TenetLevelFrame:SetHide(true);	
	Controls.LeadersFrame:SetHide( true );
	Controls.UniqueUnitsFrame:SetHide( true );
	Controls.UniqueBuildingsFrame:SetHide( true );
	Controls.UniqueImprovementsFrame:SetHide( true );	
	Controls.CivilizationsFrame:SetHide ( true );
	Controls.TraitsFrame:SetHide( true );
	Controls.LivedFrame:SetHide( true );
	Controls.TitlesFrame:SetHide( true );
	Controls.SubtitleID:SetHide( true );
	Controls.YieldFrame:SetHide( true );
	Controls.StudyArtYieldFrame:SetHide( true );
	Controls.ModernYieldFrame:SetHide( true );	-- PW
	Controls.MountainYieldFrame:SetHide( true );
	Controls.MovementCostFrame:SetHide( true );
	Controls.CombatModFrame:SetHide( true );
	Controls.FeaturesFrame:SetHide( true );
	Controls.ResourcesFoundFrame:SetHide( true );
	Controls.TerrainsFrame:SetHide( true );
	Controls.MarvelsFrame:SetHide( true );
	Controls.ReplacesFrame:SetHide( true );
	Controls.RevealTechsFrame:SetHide( true );
	Controls.AgreementsUnlockedFrame:SetHide( true );
	Controls.ArtsFrame:SetHide( true );
	Controls.ImprovementsFrame:SetHide( true );
	Controls.AffinitiesGainedFrame:SetHide( true );
	Controls.ReqAffinitiesFrame:SetHide( true );
	Controls.HomePageBlurbFrame:SetHide( true );
	Controls.FFTextStack:SetHide( true );
	Controls.BBTextStack:SetHide ( true );
	Controls.PartialMatchPullDown:SetHide( true );
	Controls.SearchButton:SetHide( false );	
	
	Controls.Portrait:UnloadTexture();
	Controls.Portrait:SetTexture("256x256Frame.dds");
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function OnClose()
	Controls.Portrait:UnloadTexture();
    UIManager:DequeuePopup( ContextPtr );
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose );


-- ===========================================================================
--	Navigate back to the previous entry.
-- ===========================================================================
function OnBackButtonClicked()
	-- Don't go past first entry, which should Civilopedia welcome screen.
	if m_historyCurrentIndex > 1 then
		m_historyCurrentIndex = m_historyCurrentIndex - 1;		
		
		local article = m_listOfTopicsViewed[m_historyCurrentIndex];
		if article then
			SetSelectedCategory( article.entryCategory, dontAddToList );
			
			-- Display (special) home page or regular article...
			if ( article.entryID == homePageOfCategoryID ) then
				CivilopediaCategory[article.entryCategory].DisplayHomePage();
			else
				CivilopediaCategory[article.entryCategory].SelectArticle( article.entryID, dontAddToList );
			end

		end
	end
end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnBackButtonClicked );

-- ===========================================================================
--	Navigate forward to the next entry in the history chain.
-- ===========================================================================
function OnForwardButtonClicked()
	if m_historyCurrentIndex < m_endTopic then
		m_historyCurrentIndex = m_historyCurrentIndex + 1;
		local article = m_listOfTopicsViewed[m_historyCurrentIndex];
		if article then
			SetSelectedCategory( article.entryCategory, dontAddToList );			

			-- Display (special) home page or regular article...
			if ( article.entryID == homePageOfCategoryID ) then
				CivilopediaCategory[article.entryCategory].DisplayHomePage();
			else
				CivilopediaCategory[article.entryCategory].SelectArticle( article.entryID, dontAddToList );
			end
		end
	end
end
Controls.ForwardButton:RegisterCallback( Mouse.eLClick, OnForwardButtonClicked );

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- PW: added option for open exact category by number. removed
function SearchForPediaEntry( searchString )
	print("SearchForPediaEntry started ---- "..tostring(searchString)) -- dbg

	UIManager:SetUICursor( 1 );
		
    if( searchString ~= nil and searchString ~= "" ) then
    	local article = searchableTextKeyList[searchString];
    	if article == nil then
    		article = searchableList[Locale.ToLower(searchString)];
    	end
    	
		-- local iscatnumber = tonumber(searchString)
		-- print("iscatnumber: "..tostring(iscatnumber)) -- dbg
		
    	if article then
    		SetSelectedCategory( article.entryCategory, dontAddToList );
    		CivilopediaCategory[article.entryCategory].SelectArticle( article.entryID, addToList );
			
    	-- elseif (0 < iscatnumber and iscatnumber < 19) then
    		-- SetSelectedCategory( iscatnumber, addToList );
			
    	else
    		SetSelectedCategory( CategoryConcepts, addToList );
    		-- SetSelectedCategory( CategoryCivilizations, addToList );
    	end
    end
	
	if( searchString == "OPEN_VIA_HOTKEY" ) then
    	if( ContextPtr:IsHidden() == false ) then
    	    OnClose();
	    else
        	UIManager:QueuePopup( ContextPtr, PopupPriority.eUtmost );
    	end
	else
    	UIManager:QueuePopup( ContextPtr, PopupPriority.eUtmost );
	end

	UIManager:SetUICursor( 0 );

end
Events.SearchForPediaEntry.Add( SearchForPediaEntry );
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function GoToPediaHomePage ( iHomePage )
	UIManager:SetUICursor( 1 );
	UIManager:QueuePopup( ContextPtr, PopupPriority.Civilopedia );
	SetSelectedCategory( iHomePage, dontAddToList );
	UIManager:SetUICursor( 0 );
end
Events.GoToPediaHomePage.Add( GoToPediaHomePage );



----------------------------------------------------------------
----------------------------------------------------------------
function ValidateText(text)

	if #text < 3 then
		return false;
	end

	local isAllWhiteSpace = true;
	local numNonWhiteSpace = 0;
	for i = 1, #text, 1 do
		if string.byte(text, i) ~= 32 then
			isAllWhiteSpace = false;
			numNonWhiteSpace = numNonWhiteSpace + 1;
		end
	end
	
	if isAllWhiteSpace then
		return false;
	end
	
	if numNonWhiteSpace < 3 then
		return false;
	end
	
	-- don't allow % character
	for i = 1, #text, 1 do
		if string.byte(text, i) == 37 then
			return false;
		end
	end
	
	local invalidCharArray = { '\"', '<', '>', '|', '\b', '\0', '\t', '\n', '/', '\\', '*', '?', '%[', ']' };

	for i, ch in ipairs(invalidCharArray) do
		if string.find(text, ch) ~= nil then
			return false;
		end
	end
	
	-- don't allow control characters
	for i = 1, #text, 1 do
		if string.byte(text, i) < 32 then
			return false;
		end
	end
	
	return true;
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function OnSearchButtonClicked()
	UIManager:SetUICursor( 1 );
	local searchString = Controls.SearchEditBox:GetText();
	local lowerCaseSearchString = nil;
	if searchString ~= nil and searchString ~= "" and ValidateText(searchString) then

		local article = searchableTextKeyList[searchString];
		if article == nil then
			lowerCaseSearchString = Locale.ToLower(searchString);
			article = searchableList[lowerCaseSearchString];
		end
	    
		if article then
			SetSelectedCategory( article.entryCategory, dontAddToList );
			CivilopediaCategory[article.entryCategory].SelectArticle( article.entryID, addToList );
		else
		
			-- try to see if there is a partial match
			local partialMatch = {};
			local numberMatches = 0;
			for i, v in pairs(searchableList) do
				if string.find(Locale.ToLower(v.entryName), lowerCaseSearchString) ~= nil then
					numberMatches = numberMatches + 1;
					partialMatch[numberMatches] = v.entryName;
				end
			end
			if numberMatches == 1 then
				article = searchableList[Locale.ToLower(partialMatch[1])];
				if article then
					SetSelectedCategory( article.entryCategory, dontAddToList );
					CivilopediaCategory[article.entryCategory].SelectArticle( article.entryID, addToList );
				end
			elseif numberMatches > 1 then -- populate a dropdown with the matches
				Controls.PartialMatchPullDown:ClearEntries();
				--print "---------------------------------"
				for i, v in pairs( partialMatch ) do
					local controlTable = {};
					Controls.PartialMatchPullDown:BuildEntry( "InstanceOne", controlTable );
					controlTable.Button:SetText( v );
					
					controlTable.Button:RegisterCallback(Mouse.eLClick, 
					function()
						SearchForPediaEntry( v );
					end);

					controlTable.Button:SetVoid1( i );
					--print(v);
				end
				Controls.PartialMatchPullDown:CalculateInternals();
				--print "---------------------------------"
				--Controls.SearchButton:SetHide( true );
				Controls.PartialMatchPullDown:SetHide( false );
				Controls.PartialMatchPullDown:GetButton():SetText( searchString );
			else
				Controls.SearchNotFoundText:LocalizeAndSetText("TXT_KEY_SEARCH_NOT_FOUND", searchString);
				Controls.SearchFoundNothing:SetHide(false);
			end
		end
	end
	UIManager:SetUICursor( 0 );
end
Controls.SearchButton:RegisterCallback( Mouse.eLClick, OnSearchButtonClicked );


function OnSearchTextEnter( stringContent, control )	
	OnSearchButtonClicked();
end
Controls.SearchEditBox:RegisterCommitCallback( OnSearchTextEnter );

function OnSearchNotFoundOK()
	Controls.SearchFoundNothing:SetHide(true);
end
Controls.OK:RegisterCallback(Mouse.eLClick, OnSearchNotFoundOK );
 
 -- ==========================================================================
function InputHandler( uiMsg, wParam, lParam )
    if(uiMsg == KeyEvents.KeyDown) then

		-- Eat up ENTER
		if ( wParam == Keys.VK_RETURN ) then
			return true;
		end

		if(not Controls.SearchFoundNothing:IsHidden()) then
			if(wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN) then
				Controls.SearchFoundNothing:SetHide(true);
				return true;
			end
		else
			if(wParam == Keys.VK_ESCAPE) then
				OnClose();
				return true;
			end
		end
    end
end
ContextPtr:SetInputHandler( InputHandler );

-- ==========================================================================
function ShowHideHandler( isHide )
    if( isHide ) then
		Controls.Portrait:UnloadTexture();
        Events.SystemUpdateUI.CallImmediate( SystemUpdateUIType.BulkShowUI );
		LuaEvents.CivilopediaHidden();
	else
        Events.SystemUpdateUI.CallImmediate( SystemUpdateUIType.BulkHideUI );
        
		-- Clears out any in-progress UI state (like range attack/bombard)
		if (InterfaceModeTypes ~= nil) then
			if (UI.GetInterfaceMode() ~= InterfaceModeTypes.INTERFACEMODE_PLANETFALL) then
				UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION);
				UI.ClearSelectedCities();
			end
		end

		if m_historyCurrentIndex > 1 then
			local article = m_listOfTopicsViewed[m_historyCurrentIndex];
			if article then
				SetSelectedCategory( article.entryCategory, dontAddToList );
				if(article.entryID == homePageOfCategoryID) then
					CivilopediaCategory[article.entryCategory].DisplayHomePage();
				else
					CivilopediaCategory[article.entryCategory].SelectArticle( article.entryID, dontAddToList );
				end
			else
				SetSelectedCategory(CategoryTerrain); -- this is a dummy so that the trigger for the next one fires
				SetSelectedCategory(CategoryMain);
				CivilopediaCategory[CategoryMain].DisplayHomePage();
			end
		else
			ResizeEtc();
		end

		LuaEvents.CivilopediaShown();
	end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
Events.GameplaySetActivePlayer.Add(OnClose);


----------------------------------------------------------------
-- If we hear a multiplayer game invite was sent, exit
-- so we don't interfere with the transition
----------------------------------------------------------------
function OnMultiplayerGameInvite()
   	if( ContextPtr:IsHidden() == false ) then
		OnClose();
	end
end
Events.MultiplayerGameLobbyInvite.Add( OnMultiplayerGameInvite );
Events.MultiplayerGameServerInvite.Add( OnMultiplayerGameInvite );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local tipControlTable = {};
TTManager:GetTypeControlTable( "TypeRoundImage", tipControlTable );
function TipHandler( control )
	local id = control:GetVoid1() % 65536;
	local article = m_categorizedListOfArticles[(m_selectedCategory * MAX_ENTRIES_PER_CATEGORY) + id];
	if article and article.tooltipTexture then
		tipControlTable.ToolTipImage:SetTexture( article.tooltipTexture );
		tipControlTable.ToolTipImage:SetTextureOffset( article.tooltipTextureOffset );
		tipControlTable.ToolTipFrame:SetHide( false );
	else
		tipControlTable.ToolTipFrame:SetHide( true );
	end		
end


-- ===========================================================================
--	Adds contents for a category's homepage article to the main catalog.
-- ===========================================================================
function AddCategoryHomePageArticle( categoryID )
	local article = {};
 	article.entryName		= "homePage";
 	article.entryID			= homePageOfCategoryID;
	article.entryCategory	= categoryID;
	m_categorizedListOfArticles[(categoryID * MAX_ENTRIES_PER_CATEGORY) + homePageOfCategoryID] = article;
end


-- ===========================================================================
-- ===========================================================================
function Initialize()

	-- Initialize all category related things...
	for i = 1, m_numCategories, 1 do
		if CivilopediaCategory[i].PopulateList then
			CivilopediaCategory[i].PopulateList();
			AddCategoryHomePageArticle( i );
		end
	end

	-- Set selected category to something invalid so the function will not
	-- think there is a cached value and properly select it.
	local initialCategory = m_selectedCategory;
	m_selectedCategory = -1;
	SetSelectedCategory( initialCategory, addToList );

	CivilopediaCategory[CategoryMain].DisplayHomePage();
end
Initialize();

-- ===========================================================================
-- MGH:
-- Luacheck supports setting some options directly in the checked files using inline configuration comments
-- <--
-- uacheck: push ignore hasProperty
function hasProperty(object, propertyName)
    local success, _ = pcall(hasProperty_);
    return success;
end
function hasProperty_(object, propertyName) -- luacheck: ignore
	object[propertyName] = object[propertyName]; -- No warnings
end
-- uacheck: pop
-- -->
-- Luacheck Warnings are emitted