--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local PREVIOUS_CHAPTER_TYPE = GameInfo.Quests["QUEST_THE_DEATH_PROBLEM"].ID;
local IMPROVEMENT_ACADEMY_NUMBER_TO_BUILD : number = 3;--1
local IMPROVEMENT_ACADEMY_TYPE : number = GameInfo.Improvements["IMPROVEMENT_ACADEMY"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{

		----------------------------------------------------
		-- Kill Alien Nest
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasKilledAlienNest == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_DESTROY_ALIEN_NESTS"].ID) then
				quest.PersistentData.HasKilledAlienNest = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set epilogue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_SAEVARS_THEOREM_PROLOGUE"));

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_DESTROY_ALIEN_NESTS", 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Build Acadamy
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasBuiltAcademy == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
				quest.PersistentData.HasBuiltAcademy = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set prologue
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SAEVARS_THEOREM_KILLED_ALIEN_NEST_EPILOGUE"));

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_ACADEMY_TYPE, IMPROVEMENT_ACADEMY_NUMBER_TO_BUILD);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SAEVARS_THEOREM_BUILD_ACADEMY_EPILOGUE"));

			-- Give rewards
			local player : table = Players[quest:GetOwner()];
			if(player == nil) then
				error("player was nil");
			end

			local city : object = player:GetCapitalCity();
			if(city == nil) then
				error("city was nil");
			end

			local rewards : table = quest.PersistentData.Rewards;
			if(rewards == nil) then
				error("rewards was nil");
			end

			local dividedReward : number = QuestRewards.DefaultQuestReward / 3;

			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.Production:GiveReward(city, dividedReward);
			rewards.Culture:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
			if(affinityRewardStrings == nil) then
				error("affinityRewardStrings was nil");
			end

			local productionRewardStrings : table = rewards.Production:GetRewardStrings(city, dividedReward);
			if(productionRewardStrings == nil) then
				error("productionRewardStrings was nil");
			end

			local cultureRewardStrings : table = rewards.Culture:GetRewardStrings(player, dividedReward);
			if(cultureRewardStrings == nil) then
				error("cultureRewardStrings was nil");
			end

			quest:SetReward(unpack(affinityRewardStrings), unpack(productionRewardStrings), unpack(cultureRewardStrings));

			-- Succeed
			quest:Succeed();

			return BehaviorStatus.SUCCEEDED;
		end},
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
	QuestRewards.AddReward(rewards, "Production", "Production");
	QuestRewards.AddReward(rewards, "Culture", "Culture");

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

return QuestScript;