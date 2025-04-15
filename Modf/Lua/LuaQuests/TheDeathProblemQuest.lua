--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local BUILDING_AUTOPLANT_TYPE : number = GameInfo.Buildings["BUILDING_AUTOPLANT"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		
		----------------------------------------------------
		-- Build Pharmalab
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasBuiltPharmalab == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltPharmalab = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_DEATH_PROBLEM_PROLOGUE"));

			-- add new objective
			local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_AUTOPLANT_TYPE, 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_DEATH_PROBLEM_FIND_RESOURCE_PODS_EPILOGUE"));

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
			rewards.Population:GiveReward(city, dividedReward);
			rewards.Science:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
			if(affinityRewardStrings == nil) then
				error("affinityRewardStrings was nil");
			end

			local populationRewardStrings : table = rewards.Population:GetRewardStrings(city, dividedReward);
			if(populationRewardStrings == nil) then
				error("populationRewardStrings was nil");
			end

			local scienceRewardStrings : table = rewards.Science:GetRewardStrings(player, dividedReward);
			if(scienceRewardStrings == nil) then
				error("scienceRewardStrings was nil");
			end

			quest:SetReward(unpack(affinityRewardStrings), unpack(populationRewardStrings), unpack(scienceRewardStrings));

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
	return true;
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Affinity", "Purity");
	QuestRewards.AddReward(rewards, "Population", "Population");
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
-- Quest Functionality
----------------------------------------------------

return QuestScript;