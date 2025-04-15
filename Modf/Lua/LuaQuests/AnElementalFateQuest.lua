--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local RESOURCE_AN_ELEMENTAL_FATE_CAVE_TYPE = GameInfo.Resources["RESOURCE_AN_ELEMENTAL_FATE_CAVE"].ID;
local IMPROVEMENT_AN_ELEMENTAL_FATE_CAVE_TYPE = GameInfo.Improvements["IMPROVEMENT_AN_ELEMENTAL_FATE_CAVE"].ID;

local ENTER_LANDMARK_ACTION_TYPE = GameInfo.LandmarkActions["LANDMARK_ACTION_AN_ELEMENTAL_FATE_ENTER_DOORWAY"].ID;
local MINE_LANDMARK_ACTION_TYPE = GameInfo.LandmarkActions["LANDMARK_ACTION_AN_ELEMENTAL_FATE_MINE_DOORWAY"].ID;

local HARMONY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.HARMONY_TYPE].Description;
local PURITY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.PURITY_TYPE].Description;
local SUPREMACY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.SUPREMACY_TYPE].Description;
local AFFINITY_REWARD = 10;

local HARMONY_UNIT_TYPE = GameInfo.Units["UNIT_MARINE"].ID;

----------------------------------------------------
-- Initialization
----------------------------------------------------
function QuestScript.OnInit()

	function QuestScript.OnAlienNestDestroyed(playerType, plotX, plotY)

		-- make sure this alien nest is on a land tile (only land nests are supported for this quest)
		local plot : object = Map.GetPlot(plotX, plotY);
		if( plot == nil or
			plot:IsWater())
		then
			return;
		end

		-- check if player can start quest
		if(QuestScript.PersistentData.PlayerEligibility ~= nil and 
		   QuestScript.PersistentData.PlayerEligibility[playerType] == true) then

			local nestSite = {};
			nestSite.X = plotX;
			nestSite.Y = plotY;

			-- start quest
			StartQuest(playerType, QuestScript.Info.ID, nestSite);

			-- unregister queued quest
				UnregisterQueuedQuest(playerType, QuestScript.Info.ID);

			-- turn off start possibility for player
			QuestScript.PersistentData.PlayerEligibility[playerType] = false;
		end
	end
	GameEvents.AlienNestDestroyed.Add(QuestScript.OnAlienNestDestroyed);



	function QuestScript.OnLandmarkAction(playerType, landmarkActionType, plotIndex)
	
		if(landmarkActionType == ENTER_LANDMARK_ACTION_TYPE and
			QuestScript.PersistentData.Doorways ~= nil) then

			for i = 1, #QuestScript.PersistentData.Doorways do

				local doorway = QuestScript.PersistentData.Doorways[i];

				if(doorway.RemainingUses > 0 and
					doorway.PlotIndex == plotIndex) then



					local plot = Map.GetPlot(doorway.X, doorway.Y);

					QuestScript.CommitUnitToDoorway(plot);

					QuestScript.PersistentData.Doorways[i].RemainingUses = doorway.RemainingUses - 1;

					if(QuestScript.PersistentData.Doorways[i].RemainingUses == 0) then

						-- clear improvement and resource
						plot:SetResourceType(-1);--(-1, 1)
						plot:ClearImprovementType();
					end

					break;
				end
			end
		end
	end

	GameEvents.LandmarkAction.Add(QuestScript.OnLandmarkAction);
end

----------------------------------------------------
-- Constants
---------------------------------------------------- 


-- Investigate Nest Site Behavior
function QuestScript.InvestigateNestSite(quest, objective)

	if(quest.PersistentData.HasInvestigateNestSite == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_EXPEDITION"].ID) then
		-- refresh the explorer's unit panel if it is selected.
		Events.SerialEventUnitInfoDirty();

		quest.PersistentData.HasInvestigateNestSite = true;
		return BehaviorStatus.SUCCEEDED;
	end

	local nestSite = quest.PersistentData.NestSite;

	-- set resource
	local plot = Map.GetPlot(nestSite.X, nestSite.Y);
	quest.PersistentData.MGHNestSiteSavedResource = plot:GetResourceType();--SaveResource!!!
	plot:SetResourceType(-1);
	plot:SetResourceType(RESOURCE_AN_ELEMENTAL_FATE_CAVE_TYPE, 1);

	-- watch plot
	local expeditionType = GameDefines["BUILD_EXPEDITION"];
	local playerType = quest:GetOwner();
	GameplayUtilities.AddWatchedPlotToQuest(quest, nestSite.X, nestSite.Y, { expeditionType }, { playerType });

	-- add prologue
	quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_PROLOGUE"));

	-- add objective
	local alienNestDescription = GameInfo.Improvements["IMPROVEMENT_ALIEN_NEST"].Description;
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_EXPEDITION", nestSite.X, nestSite.Y, alienNestDescription);
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_OBJECTIVE_RESCUE_PROBE_MINE_PROMPT_SUMMARY"));

	return BehaviorStatus.IN_PROGRESS;
end

-- Rescue vs. Probe vs. Mine Prompt Behavior
function QuestScript.RescueProbeMinePrompt(quest, objective)

	if(quest.PersistentData.HasMadeRescueProbeMineChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeRescueProbeMineChoice = true;
		quest.PersistentData.RescueProbeMineChoice = objective.PersistentData.Choice;

		if(objective.PersistentData.Choice == 1) then
			
			objective:SetEpilogue("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_CHOICE_RESCUE_EPILOGUE");
		elseif(objective.PersistentData.Choice == 2) then

			objective:SetEpilogue("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_CHOICE_PROBE_EPILOGUE");
		elseif(objective.PersistentData.Choice == 3) then

			objective:SetEpilogue("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_CHOICE_MINE_EPILOGUE");
		end

		return BehaviorStatus.SUCCEEDED;
	end

	-- add landmark
	local nestSite = quest.PersistentData.NestSite;
	local plot = Map.GetPlot(nestSite.X, nestSite.Y);

	-- add resource
	plot:SetResourceType(-1);
	plot:SetResourceType(RESOURCE_AN_ELEMENTAL_FATE_CAVE_TYPE, 1);
	plot:SetImprovementType(IMPROVEMENT_AN_ELEMENTAL_FATE_CAVE_TYPE);

	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_OBJECTIVE_RESCUE_PROBE_MINE_PROMPT_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_CHOICE_RESCUE"), 
													FlavorTypes = {
														GameInfo.Flavors["FLAVOR_HARMONY"].ID,
													}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_CHOICE_PROBE"), 
													FlavorTypes = {
														GameInfo.Flavors["FLAVOR_SUPREMACY"].ID,
													}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_CHOICE_MINE"), 
													FlavorTypes = {
														GameInfo.Flavors["FLAVOR_PURITY"].ID,
													}}
	);


	-- add tooltips
	local rewards = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Harmony:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Supremacy:GetToolTip());
	newObjective:SetPromptTooltipC(rewards.Purity:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Rescue Behavior
function QuestScript.Rescue(quest, objective)

	if(quest.PersistentData.RescueProbeMineChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasRescued == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LANDMARK_ACTION"].ID) then
		quest.PersistentData.HasRescued = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- add objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_LANDMARK_ACTION", ENTER_LANDMARK_ACTION_TYPE, quest.PersistentData.NestSite.X, quest.PersistentData.NestSite.Y);
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_OBJECTIVE_RESCUE_EPILOGUE"));

	-- setup use of doorway
	local nestSite = quest.PersistentData.NestSite;
	local plot = Map.GetPlot(nestSite.X, nestSite.Y);

	if(QuestScript.PersistentData.Doorways== nil) then

		QuestScript.PersistentData.Doorways = {};
	end

	local index = #QuestScript.PersistentData.Doorways + 1;

	QuestScript.PersistentData.Doorways[index] = {};
	QuestScript.PersistentData.Doorways[index].RemainingUses = 1;
	QuestScript.PersistentData.Doorways[index].PlotIndex = plot:GetPlotIndex();
	QuestScript.PersistentData.Doorways[index].X = plot:GetX();
	QuestScript.PersistentData.Doorways[index].Y = plot:GetY();

	return BehaviorStatus.IN_PROGRESS;
end

-- Probe Behavior
function QuestScript.Probe(quest, objective)

	if(quest.PersistentData.RescueProbeMineChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if(quest.PersistentData.HasProbed == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_EXPEDITION"].ID) then
		-- refresh the explorer's unit panel if it is selected.
		Events.SerialEventUnitInfoDirty();
			
		quest.PersistentData.HasProbed = true;
		return BehaviorStatus.SUCCEEDED;
	end

	local nestSite = quest.PersistentData.NestSite;
	local plot = Map.GetPlot(nestSite.X, nestSite.Y);

	-- unwatch plot
	GameplayUtilities.RemoveWatchedPlotFromQuest(quest, nestSite.X, nestSite.Y);

	-- clear improvement to make room for expedition
	plot:ClearImprovementType();

	-- add objective
	local alienNestDescription = GameInfo.Improvements["IMPROVEMENT_ALIEN_NEST"].Description;
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_EXPEDITION", nestSite.X, nestSite.Y, alienNestDescription);
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_OBJECTIVE_PROBE_EPILOGUE"));

	return BehaviorStatus.IN_PROGRESS;
end

-- Mine Behavior
function QuestScript.Mine(quest, objective)

	if(quest.PersistentData.RescueProbeMineChoice ~= 3) then
		return BehaviorStatus.FAILED;
	end

	if(quest.PersistentData.HasMined == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LANDMARK_ACTION"].ID) then

		-- refresh the explorer's unit panel if it is selected.
		Events.SerialEventUnitInfoDirty();

		quest.PersistentData.HasMined = true;
		return BehaviorStatus.SUCCEEDED;
	end

	local nestSite = quest.PersistentData.NestSite;

	-- add objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_LANDMARK_ACTION", MINE_LANDMARK_ACTION_TYPE, quest.PersistentData.NestSite.X, quest.PersistentData.NestSite.Y);
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_OBJECTIVE_MINE_EPILOGUE"));

	return BehaviorStatus.IN_PROGRESS;
end

-- End Harmony Behavior
function QuestScript.EndHarmony(quest, objective)

	-- remove landmark
	local nestSite = quest.PersistentData.NestSite;
	local plot = Map.GetPlot(nestSite.X, nestSite.Y);
	plot:SetResourceType(-1);
	plot:SetResourceType(quest.PersistentData.MGHNestSiteSavedResource);--LoadResource!!!
	plot:ClearImprovementType();

	-- unwatch plot
	GameplayUtilities.RemoveWatchedPlotFromQuest(quest, nestSite.X, nestSite.Y);

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Harmony:GiveReward(player, dividedReward);

	-- Set reward strings
	local harmonyRewardStrings = rewards.Harmony:GetRewardStrings(player, dividedReward);

	quest:SetReward(unpack(harmonyRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end

-- End Supremacy Behavior
function QuestScript.EndSupremacy(quest, objective)

	-- remove landmark
	local nestSite = quest.PersistentData.NestSite;
	local plot = Map.GetPlot(nestSite.X, nestSite.Y);
	plot:SetResourceType(-1);
	plot:SetResourceType(quest.PersistentData.MGHNestSiteSavedResource);--LoadResource!!!
	plot:ClearImprovementType();

	-- make Firaxite locations visible
	QuestScript.RevealFiraxiteLocations(quest:GetOwner());

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Supremacy:GiveReward(player, dividedReward);

	-- Set reward strings
	local supremacyRewardStrings = rewards.Supremacy:GetRewardStrings(player, dividedReward);

	local firaxiteRevealedRewardDescription : string = Locale.ConvertTextKey("TXT_KEY_QUEST_AN_ELEMENTAL_FATE_FIRAXITE_REVEALED_REWARD_DESCRIPTION");
	table.insert(supremacyRewardStrings, firaxiteRevealedRewardDescription);

	quest:SetReward(unpack(supremacyRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end

-- End Purity Behavior
function QuestScript.EndPurity(quest, objective)

	-- remove landmark
	local nestSite = quest.PersistentData.NestSite;
	local plot = Map.GetPlot(nestSite.X, nestSite.Y);
	plot:SetResourceType(-1);
	plot:SetResourceType(quest.PersistentData.MGHNestSiteSavedResource);--LoadResource!!!
	plot:ClearImprovementType();

	-- unwatch plot
	GameplayUtilities.RemoveWatchedPlotFromQuest(quest, nestSite.X, nestSite.Y);

	-- scatter floatstone
	QuestScript.ScatterFloatStone(plot);

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 3;--/2

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Purity:GiveReward(player, dividedReward);

	-- Set reward strings
	local purityRewardStrings = rewards.Purity:GetRewardStrings(player, dividedReward);

	quest:SetReward(unpack(purityRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		-- Investigate Nest Site
		ActionNode{QuestScript.InvestigateNestSite},

		-- Rescue vs. Probe vs. Mine Prompt
		ActionNode{QuestScript.RescueProbeMinePrompt},

		-- Rescue vs. Probe vs. Mine Choice
		SelectorNode{

			SequenceNode{

				-- Rescue
				ActionNode{QuestScript.Rescue},

				-- End Harmony
				ActionNode{QuestScript.EndHarmony},
			},

			SequenceNode{

				-- Probe
				ActionNode{QuestScript.Probe},

				-- End Supremacy
				ActionNode{QuestScript.EndSupremacy},
			},

			SequenceNode{

				-- Mine
				ActionNode{QuestScript.Mine},

				-- End Purity
				ActionNode{QuestScript.EndPurity},
			},

		},
	},
};
----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)
	local prerequisitTech = GameInfo.Technologies["TECH_PHYSICS"].ID;--MGH (this will be less common now to appear)-P

	return Players[playerType]:HasTech(prerequisitTech);
end

function QuestScript.QueueStartForPlayer(playerType)

	-- add start eligibility for player
	if(QuestScript.PersistentData.PlayerEligibility == nil) then

		QuestScript.PersistentData.PlayerEligibility = {};
	end

	QuestScript.PersistentData.PlayerEligibility[playerType] = true;
end

local function AddRewards(quest)

	local rewards = {
		Harmony = QuestRewards.Harmony(),
		Purity = QuestRewards.Purity(),
		Supremacy = QuestRewards.Supremacy(),
		Units = QuestRewards.Units()
	}

	MergeTable(rewards, quest.PersistentData.Rewards);
	quest.PersistentData.Rewards = rewards;
	rewards = {}
end

function QuestScript.OnStart(quest, nestSite)

	-- find quest reward categories
	AddRewards(quest);

	quest.PersistentData.NestSite = nestSite;

	BehaviorTree.Tick(quest, nil);
end

function QuestScript.OnLoad(quest)
	AddRewards(quest);
end

function QuestScript.OnObjectiveComplete(quest, objective)
	BehaviorTree.Tick(quest, objective);
end

function QuestScript.CanDoLandmarkAction(quest, landmarkActionType, plot)
	-- If we have no unit on the tile, return false
	local numUnits = plot:GetNumUnits();
	if (numUnits == 0) then
		return false;
	end


	if(landmarkActionType == ENTER_LANDMARK_ACTION_TYPE and
		(quest:DidSucceed() or quest.PersistentData.RescueProbeMineChoice == 1)) then
		
		local explorerType = GameInfo.Units["UNIT_EXPLORER"].ID;

		-- If we have a military unit selected on the tile, we're good to go.
		local selectedUnit = plot:GetSelectedUnit();
		if (selectedUnit:GetOwner() == quest:GetOwner() and
			selectedUnit:GetMoves() > 0 and
			selectedUnit:GetCombatStrength() > 0 and
			selectedUnit:GetUnitType() ~= explorerType and
			selectedUnit:CanEarnExperience() == true) then
			return true;
		end

	elseif(landmarkActionType == MINE_LANDMARK_ACTION_TYPE and
		quest.PersistentData.RescueProbeMineChoice == 3) then

		local nestSite = quest.PersistentData.NestSite;

		if(nestSite == nil) then
			return false;
		end

		if(plot:GetX() ~= nestSite.X or 
			plot:GetY() ~= nestSite.Y) then
			return false;
		end

		if(quest.PersistentData.RescueProbeMineChoice == nil) then
			return false;
		end
		

		return true;
	end

	return false;
end


----------------------------------------------------
-- Quest Specific
---------------------------------------------------- 
function QuestScript.CommitUnitToDoorway(plot)

	-- get unit
	local unit = plot:GetUnit();
	local player = Players[unit:GetOwner()];
	local currentLevel = unit:GetLevel();
	local XPNeededForCurrentLevel = unit:ExperienceNeededForLevel(currentLevel);
	local currentXP = unit:GetExperience();
	local overflowXP = currentXP - XPNeededForCurrentLevel;

	if(unit:CanAcquireLevel(currentLevel + 2)) then

		local XPNeeded = unit:ExperienceNeededForLevel(currentLevel + 2);
		unit:SetExperience(XPNeeded + overflowXP);
		unit:TestPromotionReady();
	elseif(unit:CanAcquireLevel(currentLevel + 1)) then
		
		local XPNeeded = unit:ExperienceNeededForLevel(currentLevel + 1);
		unit:SetExperience(XPNeeded + overflowXP);
		unit:TestPromotionReady();

		--create extra unit
		local newUnit = player:InitUnit(HARMONY_UNIT_TYPE, plot:GetX(), plot:GetY());
		newUnit:JumpToNearestValidPlot();

		local XPNeededForFirstLevel = unit:ExperienceNeededForLevel(1);
		newUnit:SetExperience(XPNeededForFirstLevel);
		newUnit:TestPromotionReady();
	else

		--create extra unit
		local newUnit = player:InitUnit(HARMONY_UNIT_TYPE, plot:GetX(), plot:GetY());
		newUnit:JumpToNearestValidPlot();

		local XPNeededForLevel = unit:ExperienceNeededForLevel(2);
		newUnit:SetExperience(XPNeededForLevel);
		newUnit:TestPromotionReady();
	end
end

function QuestScript.RevealFiraxiteLocations(playerType)

	local FIRAXITE_TYPE = GameInfo.Resources["RESOURCE_FIRAXITE"].ID;

	-- find team
	local player = Players[playerType];
	local team = player:GetTeam();

	-- reveal firaxite locations
	for i = 0, Map.GetNumPlots() - 1 do

		local plot = Map.GetPlotByIndex(i);

		if(plot:GetResourceType() == FIRAXITE_TYPE) then

			plot:SetRevealed(team, true);
		end
	end
end

function QuestScript.ScatterFloatStone(plot)

	local FLOAT_STONE_TYPE = GameInfo.Resources["RESOURCE_FLOAT_STONE"].ID;

	local centerX = plot:GetX();
	local centerY = plot:GetY();
	
	local HexRadius = 1;
	repeat
		for shiftX = -HexRadius, HexRadius, 1 do
			for shiftY = -HexRadius, HexRadius, 1 do
				local plot = Map.PlotXYWithRangeCheck(centerX, centerY, shiftX, shiftY, HexRadius);
				if (plot ~= nil and shiftX ~= 0 and shiftY ~= 0) then
					if(plot:HasImprovement() == false and
					plot:IsCity() == false and
					--[[plot:GetNumUnits() == 0 and]]
					--[[plot:IsWater() == false and]]
					plot:CanHaveResource(FLOAT_STONE_TYPE) == true) then
						local floatstoneToDrop = 2;--Game.Rand(3, "Rolling to recieve floatstone");
						plot:SetResourceType(FLOAT_STONE_TYPE, floatstoneToDrop);
						plot:ChangeNumResource(floatstoneToDrop);--MGH:
						return;
					end
				end
			end
		end
		HexRadius = HexRadius + 1;
	until (HexRadius >= 3)
	
end

return QuestScript;