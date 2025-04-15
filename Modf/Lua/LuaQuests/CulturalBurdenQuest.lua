--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local RESOURCE_CRASHED_SATELLITE_TYPE = GameInfo.Resources["RESOURCE_CRASHED_SATELLITE"].ID;

local RESOURCE_CULTURAL_BURDEN_QUEST_CRASH_SITE_TYPE = GameInfo.Resources["RESOURCE_CULTURAL_BURDEN_QUEST_CRASH_SITE"].ID;
local IMPROVEMENT_CULTURAL_BURDEN_QUEST_CRASH_SITE_TYPE = GameInfo.Improvements["IMPROVEMENT_CULTURAL_BURDEN_QUEST_CRASH_SITE"].ID;

local XENOMASS_TYPE = GameInfo.Resources["RESOURCE_XENOMASS"].ID;

local REMOVE_WRECKAGE_LANDMARK_ACTION_TYPE = GameInfo.LandmarkActions["LANDMARK_ACTION_CULTURAL_BURDEN_REMOVE_WRECKAGE"].ID;
local DRAIN_XENOMASS_LANDMARK_ACTION_TYPE = GameInfo.LandmarkActions["LANDMARK_ACTION_CULTURAL_BURDEN_DRAIN_XENOMASS"].ID;

local HARMONY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.HARMONY_TYPE].Description;
local PURITY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.PURITY_TYPE].Description;
local SUPREMACY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.SUPREMACY_TYPE].Description;
local AFFINITY_REWARD = 10;
local CULTURE_REWARD = 50;
local SCIENCE_REWARD = 50;

local WORKER_SPEED_PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_CULTURAL_BURDEN_WORKER_SPEED"].ID;


-- Investigate Crash Site Behavior
function QuestScript.InvestigateCrashSite(quest, objective)

	if(quest.PersistentData.HasInvestigateCrashSite == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_EXPEDITION"].ID) then

		quest.PersistentData.HasInvestigateCrashSite = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- add prologue
	quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_PROLOGUE"));

	-- find crash site
	local crashSite = QuestScript.CrashSite(quest:GetOwner());
	crashSite:SetResourceType(-1);
	crashSite:SetResourceType(RESOURCE_CRASHED_SATELLITE_TYPE, 1);

	-- reveal crashSite
	local player = Players[quest:GetOwner()];
	crashSite:SetRevealed(player:GetTeam(), true);

	-- store crash site
	quest.PersistentData.CrashSite = {}
	quest.PersistentData.CrashSite.X = crashSite:GetX();
	quest.PersistentData.CrashSite.Y = crashSite:GetY();

	-- watch crash site
	local expeditionType = GameDefines["BUILD_EXPEDITION"];
	local playerType = quest:GetOwner();
	GameplayUtilities.AddWatchedPlotToQuest(quest, quest.PersistentData.CrashSite.X, quest.PersistentData.CrashSite.Y, { expeditionType }, { playerType });

	-- add objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_EXPEDITION", crashSite:GetX(), crashSite:GetY(), "TXT_KEY_QUEST_CULTURAL_BURDEN_SIGNAL_SOURCE");
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_OBJECTIVE_CLEAR_RECOVER_PROMPT_SUMMARY"));

	return BehaviorStatus.IN_PROGRESS;
end

-- Clear vs. Recover Prompt Behavior
function QuestScript.ClearRecoverPrompt(quest, objective)

	if(quest.PersistentData.HasMadeClearRecoverChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeClearRecoverChoice = true;
		quest.PersistentData.ClearRecoverChoice = objective.PersistentData.Choice;

		if(objective.PersistentData.Choice == 1) then
			
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_CHOICE_CLEAR_EPILOGUE"));
		elseif(objective.PersistentData.Choice == 2) then

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_CHOICE_RECOVER_EPILOGUE"));
		end

		-- refresh the explorer's unit panel if it is selected.
		Events.SerialEventUnitInfoDirty();

		return BehaviorStatus.SUCCEEDED;
	end

	-- add landmark
	local crashSite = quest.PersistentData.CrashSite;
	local plot = Map.GetPlot(crashSite.X, crashSite.Y);

	plot:SetResourceType(-1);
	plot:SetResourceType(RESOURCE_CULTURAL_BURDEN_QUEST_CRASH_SITE_TYPE, 1);
	plot:SetImprovementType(IMPROVEMENT_CULTURAL_BURDEN_QUEST_CRASH_SITE_TYPE);

	-- update watched plot
	GameplayUtilities.RemoveWatchedPlotFromQuest(quest, quest.PersistentData.CrashSite.X, quest.PersistentData.CrashSite.Y);
	GameplayUtilities.AddWatchedPlotToQuest(quest, quest.PersistentData.CrashSite.X, quest.PersistentData.CrashSite.Y);


	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_OBJECTIVE_CLEAR_RECOVER_PROMPT_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_CHOICE_CLEAR"), 
											FlavorTypes = {
												GameInfo.Flavors["FLAVOR_HARMONY"].ID,
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_CHOICE_RECOVER"), 
											FlavorTypes = {
												GameInfo.Flavors["FLAVOR_PURITY"].ID,
												GameInfo.Flavors["FLAVOR_SUPREMACY"].ID,
											}}
	);

	-- add tooltips
	local rewards = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Harmony:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Purity:GetToolTip() .. ", " .. rewards.Supremacy:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Clear Wreckage Behavior
function QuestScript.ClearWreckage(quest, objective)

	if(quest.PersistentData.ClearRecoverChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasRecoveredWreckage == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LANDMARK_ACTION"].ID) then

		-- refresh the explorer's unit panel if it is selected.
		Events.SerialEventUnitInfoDirty();

		quest.PersistentData.HasRecoveredWreckage = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- add objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_LANDMARK_ACTION", REMOVE_WRECKAGE_LANDMARK_ACTION_TYPE, quest.PersistentData.CrashSite.X, quest.PersistentData.CrashSite.Y);
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_OBJECTIVE_CLEAR_WRECKAGE_EPILOGUE"));

	return BehaviorStatus.IN_PROGRESS;
end

-- End Harmony Behavior
function QuestScript.EndHarmony(quest, objective)

	-- add xenomass to tile
	local crashSite = quest.PersistentData.CrashSite;
	local plot = Map.GetPlot(crashSite.X, crashSite.Y);
	
	plot:ClearImprovementType();
	plot:SetResourceType(-1);
	local xenomassToDrop = 2;--Game.Rand(3, "Rolling to recieve xenomass");
	plot:SetResourceType(XENOMASS_TYPE, xenomassToDrop);
	plot:ChangeNumResource(xenomassToDrop);--MGH

	-- unwatch crash site
	GameplayUtilities.RemoveWatchedPlotFromQuest(quest, quest.PersistentData.CrashSite.X, quest.PersistentData.CrashSite.Y);

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

-- Recover Wreckage Behavior
function QuestScript.RecoverWreckage(quest, objective)

	if(quest.PersistentData.ClearRecoverChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasRecoveredWreckage == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LANDMARK_ACTION"].ID) then

		-- refresh the explorer's unit panel if it is selected.
		Events.SerialEventUnitInfoDirty();

		quest.PersistentData.HasRecoveredWreckage = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- add objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_LANDMARK_ACTION", DRAIN_XENOMASS_LANDMARK_ACTION_TYPE, quest.PersistentData.CrashSite.X, quest.PersistentData.CrashSite.Y);
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_OBJECTIVE_RECORDS_TECHNOLOGY_PROMPT_SUMMARY"));

	return BehaviorStatus.IN_PROGRESS;
end

-- Records vs. Technology Prompt Behavior
function QuestScript.RecordsTechnologyPrompt(quest, objective)

	if(quest.PersistentData.HasMadeRecordsTechnologyChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeRecordsTechnologyChoice = true;
		quest.PersistentData.RecordsTechnologyChoice = objective.PersistentData.Choice;

		if(objective.PersistentData.Choice == 1) then
			
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_CHOICE_RECORDS_EPILOGUE"));
		elseif(objective.PersistentData.Choice == 2) then

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_CHOICE_TECHNOLOGY_EPILOGUE"));
		end

		return BehaviorStatus.SUCCEEDED;
	end

	-- clear improvement and resource
	local crashSite = quest.PersistentData.CrashSite;
	local plot = Map.GetPlot(crashSite.X, crashSite.Y);
	plot:ClearImprovementType();
	plot:SetResourceType(-1);

	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_OBJECTIVE_RECORDS_TECHNOLOGY_PROMPT_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_CHOICE_RECORDS"), 
											FlavorTypes = {
												GameInfo.Flavors["FLAVOR_PURITY"].ID,
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_CULTURAL_BURDEN_CHOICE_TECHNOLOGY"), 
											FlavorTypes = {
												GameInfo.Flavors["FLAVOR_SUPREMACY"].ID,
											}}
	);

	-- add tooltips
	local rewards = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Purity:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Supremacy:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Purity Behavior
function QuestScript.EndPurity(quest, objective)

	if(quest.PersistentData.RecordsTechnologyChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Purity:GiveReward(player, dividedReward);
	rewards.Records:GiveReward(player, dividedReward);

	-- Set reward strings
	local purityRewardStrings = rewards.Purity:GetRewardStrings(player, dividedReward);
	local recordRewardStrings = rewards.Records:GetRewardStrings(player, dividedReward);

	quest:SetReward(unpack(purityRewardStrings), unpack(recordRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end

-- End Supremacy Behavior
function QuestScript.EndSupremacy(quest, objective)

	if(quest.PersistentData.RecordsTechnologyChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	-- clear improvement and resource
	local crashSite = quest.PersistentData.CrashSite;
	local plot = Map.GetPlot(crashSite.X, crashSite.Y);
	plot:ClearImprovementType();
	plot:SetResourceType(-1);

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Supremacy:GiveReward(player, dividedReward);
	rewards.Technology:GiveReward(player, WORKER_SPEED_PERK_TYPE);

	-- Set reward strings
	local supremacyRewardStrings = rewards.Supremacy:GetRewardStrings(player, dividedReward);
	local technologyRewardStrings = rewards.Technology:GetRewardStrings(WORKER_SPEED_PERK_TYPE);

	quest:SetReward(unpack(supremacyRewardStrings), unpack(technologyRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		-- Investigate Crash Site
		ActionNode{QuestScript.InvestigateCrashSite},

		-- Clear vs. Recover Prompt
		ActionNode{QuestScript.ClearRecoverPrompt},

		-- Clear vs. Recover Choice
		SelectorNode{

			SequenceNode{

				-- Clear Wreckage
				ActionNode{QuestScript.ClearWreckage},

				-- End Harmony
				ActionNode{QuestScript.EndHarmony},
			},

			SequenceNode{

				-- Recover Wreckage
				ActionNode{QuestScript.RecoverWreckage},

				-- Records vs. Technology Prompt
				ActionNode{QuestScript.RecordsTechnologyPrompt},

				-- Records vs. Technology Choice
				SelectorNode{

					-- End Purity
					ActionNode{QuestScript.EndPurity},

					-- End Supremacy
					ActionNode{QuestScript.EndSupremacy},
				},
			},
		},
	},
};
----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)
	local prerequisitTech = GameInfo.Technologies["TECH_GENETICS"].ID;--MGH (this will be less common now to appear)-H

	return QuestScript.CrashSite(playerType) ~= nil and Players[playerType]:HasTech(prerequisitTech);

	--return QuestScript.CrashSite(playerType) ~= nil;
end

local function AddRewards(quest)

	local rewards = {};

	if (isLoad) then
		rewards.RecordsName = quest.PersistentData.Rewards.RecordsName;
	end

	if (rewards.RecordsName == nil) then
		rewards.RecordsName = QuestRewards.ChooseReward("Culture", "Energy", "CultureEnergy");
	end
	
	QuestRewards.AddReward(rewards, "Records", rewards.RecordsName);
	QuestRewards.AddReward(rewards, "Harmony", "Harmony");
	QuestRewards.AddReward(rewards, "Purity", "Purity");
	QuestRewards.AddReward(rewards, "Supremacy", "Supremacy");
	QuestRewards.AddReward(rewards, "Technology", "PlayerPerk");

	MergeTable(rewards, quest.PersistentData.Rewards);
	quest.PersistentData.Rewards = rewards;
	rewards = {}
end

function QuestScript.OnStart(quest)

	-- find quest reward categories
	AddRewards(quest);
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

	local crashSite = quest.PersistentData.CrashSite;

	if(crashSite ~= nil and
		(plot:GetX() ~= crashSite.X or 
		plot:GetY() ~= crashSite.Y)) then
		return false;
	end

	if(quest.PersistentData.ClearRecoverChoice == nil) then
		return false;
	end

	if(landmarkActionType == REMOVE_WRECKAGE_LANDMARK_ACTION_TYPE and
		quest.PersistentData.ClearRecoverChoice == 1) then
		return true;
	elseif(landmarkActionType == DRAIN_XENOMASS_LANDMARK_ACTION_TYPE and
		quest.PersistentData.ClearRecoverChoice == 2) then
		return true;
	end

	return false;
end


----------------------------------------------------
-- Quest Specific
---------------------------------------------------- 

function QuestScript.CrashSite(playerType)

	local player = Players[playerType];
	local city = player:GetCapitalCity();
	
	if( city ~= nil ) then
		local centerX = city:GetX();
		local centerY = city:GetY();
		local HexRadius = 4;

		for shiftX = -HexRadius, HexRadius, 1 do
			for shiftY = -HexRadius, HexRadius, 1 do
				local plot = Map.PlotXYWithRangeCheck(centerX, centerY, shiftX, shiftY, HexRadius);
				if (plot ~= nil) then

					if(plot:HasImprovement() == false and
						plot:IsCity() == false and
						plot:GetNumUnits() == 0 and
						plot:IsWater() == false and
						plot:CanHaveResource(RESOURCE_CULTURAL_BURDEN_QUEST_CRASH_SITE_TYPE) == true and
						plot:CanHaveResource(XENOMASS_TYPE) == true) then

						return plot;
					end
				end
			end
		end
	end

	return nil;
end

return QuestScript;