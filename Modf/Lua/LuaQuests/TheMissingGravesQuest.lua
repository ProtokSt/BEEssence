--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local PREVIOUS_CHAPTER_TYPE : number = GameInfo.Quests["QUEST_SAEVARS_THEOREM"].ID;
local IMPROVEMENT_FARM_NUMBER_TO_BUILD : number = 5;--2
local IMPROVEMENT_FARM_TYPE : number = GameInfo.Improvements["IMPROVEMENT_FARM"].ID;
local SCIENCE_BONUS : number = 60;
local PRODUCTION_BONUS : number = 100;

QuestScript.PlayerPopulationEffects = 
{
	Production = 1,
	Science = 1,
};

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{

		----------------------------------------------------
		-- Build Farms
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltFarms == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
				quest.PersistentData.HasBuiltFarms = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set epilogue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_PROLOGUE"));

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_FARM_TYPE, IMPROVEMENT_FARM_NUMBER_TO_BUILD);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Found Outpost
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasFoundedOutpost == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_FOUND_OUTPOSTS"].ID) then
				quest.PersistentData.HasFoundedOutpost = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set epilogue
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_BUILT_FARMS_EPILOGUE"));

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_FOUND_OUTPOSTS", 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Age vs. Offspring Prompt
		----------------------------------------------------
		ActionNode{function(quest, objective)

			if(quest.PersistentData.HasMadeAgeOffspringChoice == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
				quest.PersistentData.HasMadeAgeOffspringChoice = true;
				quest.PersistentData.AgeOffspringChoice = objective.PersistentData.Choice;
				return BehaviorStatus.SUCCEEDED;
			end

			local newObjective = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_AGE_OFFSPRING_CHOICE_SUMMARY"),
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_AGE_OFFSPRING_AGE_CAP_CHOICE"), 
													FlavorTypes = {
													
													}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_AGE_OFFSPRING_OFFSPRING_CAP_CHOICE"), 
													FlavorTypes = {
													
													}}
			);

			-- add tooltips
			local rewards = quest.PersistentData.Rewards;
			newObjective:SetPromptTooltipA(rewards.ProductionAllCities:GetToolTip());
			newObjective:SetPromptTooltipB(rewards.Science:GetToolTip());

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Age vs. Offspring Choice
		----------------------------------------------------
		SelectorNode{


			----------------------------------------------------
			-- End Age Cap
			----------------------------------------------------
			ActionNode{function(quest, objective)
				if(quest.PersistentData.AgeOffspringChoice ~= 1) then
					return BehaviorStatus.FAILED;
				end

				-- Set epilogue
				objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_AGE_CAP_CHOICE_EPILOGUE"));

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 2;

				local rewards = quest.PersistentData.Rewards;
				local player = Players[quest:GetOwner()];
				rewards.Affinity:GiveReward(player, dividedReward);
				rewards.ProductionAllCities:GiveReward(player, dividedReward);
				QuestScript.AddPlayerPopulationEffect(quest:GetOwner(), QuestScript.PlayerPopulationEffects.Production);--Changed

				-- Set reward strings
				local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
				local productionAllCitiesRewardStrings = rewards.ProductionAllCities:GetRewardStrings(player, dividedReward);
				local productionBonusRewardString = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_PRODUCTION_BONUS_HELP", PRODUCTION_BONUS);

				quest:SetReward(unpack(affinityRewardStrings), unpack(productionAllCitiesRewardStrings), productionBonusRewardString);

				-- Succeed
				quest:Succeed();

				return BehaviorStatus.IN_PROGRESS;
			end},

			----------------------------------------------------
			-- End Offspring Cap
			----------------------------------------------------
			ActionNode{function(quest, objective)
				if(quest.PersistentData.AgeOffspringChoice ~= 2) then
					return BehaviorStatus.FAILED;
				end

				-- Set epilogue
				objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_OFFSPRING_CAP_CHOICE_EPILOGUE"));

				-- Give rewards
				local dividedReward : number = QuestRewards.DefaultQuestReward / 2;

				local rewards : table = quest.PersistentData.Rewards;
				local player : table = Players[quest:GetOwner()];
				rewards.Affinity:GiveReward(player, dividedReward);
				rewards.Science:GiveReward(player, dividedReward);
				QuestScript.AddPlayerPopulationEffect(quest:GetOwner(), QuestScript.PlayerPopulationEffects.Science);

				-- Set reward strings
				local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
				local scienceRewardStrings : table = rewards.Science:GetRewardStrings(player, dividedReward);
				local scienceBonusRewardString = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_MISSING_GRAVES_SCIENCE_BONUS_HELP", SCIENCE_BONUS);

				quest:SetReward(unpack(affinityRewardStrings), unpack(scienceRewardStrings), scienceBonusRewardString);

				-- Succeed
				quest:Succeed();

				return BehaviorStatus.IN_PROGRESS;
			end},
		},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType : number)
	local player : table = Players[playerType];
	if(player == nil) then
		error("player was nil");
	end

	return DidPlayerSucceedQuestType(player:GetID(), PREVIOUS_CHAPTER_TYPE)
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Affinity", "Purity");
	QuestRewards.AddReward(rewards, "ProductionAllCities", "ProductionAllCities");
	QuestRewards.AddReward(rewards, "Science", "Science");

	MergeTable(rewards, quest.PersistentData.Rewards);
	quest.PersistentData.Rewards = rewards;
	rewards = {}
end

function QuestScript.OnStart(quest : table)
	AddRewards(quest);
	BehaviorTree.Tick(quest, nil);
end

function QuestScript.OnLoad(quest : table)
	AddRewards(quest);
end

function QuestScript.OnObjectiveComplete(quest : table, objective)
	BehaviorTree.Tick(quest, objective);
end

----------------------------------------------------
-- Quest-Specific Functionality
----------------------------------------------------
function QuestScript.AddPlayerPopulationEffect(playerType : number, playerPopulationEffect : number)
	if(QuestScript.PersistentData.PopulationEffectsByPlayerType == nil) then
		QuestScript.PersistentData.PopulationEffectsByPlayerType = {};
	end

	QuestScript.PersistentData.PopulationEffectsByPlayerType[playerType] = playerPopulationEffect;
end

function QuestScript.OnSetPopulation(cityX : number, cityY : number, oldPopulation : number, newPopulation : number)
	local plot : table = Map.GetPlot(cityX, cityY);
	if(plot == nil) then
		error("plot was nil");
	end

	local city : table = plot:GetPlotCity();
	if(city == nil) then
		return;
	end

	if(QuestScript.PersistentData.PopulationEffectsByPlayerType == nil) then
		return;
	end

	local playerType : number = city:GetOwner();
	if(QuestScript.PersistentData.PopulationEffectsByPlayerType[playerType] == nil) then
		return;
	end

	local playerPopulationEffect : number = QuestScript.PersistentData.PopulationEffectsByPlayerType[playerType];
	if(playerPopulationEffect == nil) then
		error("playerPopulationEffect was nil");
	end

	if(playerPopulationEffect == QuestScript.PlayerPopulationEffects.Production) then
		city:ChangeOverflowProduction(PRODUCTION_BONUS);
	elseif(playerPopulationEffect == QuestScript.PlayerPopulationEffects.Science) then
		local player : table = Players[playerType];
		if(player == nil) then
			error("player was nil");
		end

		player:GrantScience(SCIENCE_BONUS);
	end
end
GameEvents.SetPopulation.Add(QuestScript.OnSetPopulation);

return QuestScript;