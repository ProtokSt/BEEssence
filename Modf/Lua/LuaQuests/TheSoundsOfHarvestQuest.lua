--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local IMPROVEMENT_PLANTATION_TYPE : number = GameInfo.Improvements["IMPROVEMENT_PLANTATION"].ID;
local BUILDING_TYPE : number = GameInfo.Buildings["BUILDING_MOLECULAR_FORGE"].ID;

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

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SOUNDS_OF_HARVEST_PROLOGUE"));

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_PLANTATION_TYPE, 2);

			return BehaviorStatus.IN_PROGRESS;
		end},

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
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SOUNDS_OF_HARVEST_BUILD_FARMS_EPILOGUE"));

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_TYPE, 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SOUNDS_OF_HARVEST_BUILD_CLINIC_EPILOGUE"));

			-- Give rewards
			local player : table = Players[quest:GetOwner()];
			if(player == nil) then
				error("player was nil");
			end

			local rewards : table = quest.PersistentData.Rewards;
			if(rewards == nil) then
				error("rewards was nil");
			end

			local dividedReward : number = QuestRewards.DefaultQuestReward / 3;

			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.Culture:GiveReward(player, dividedReward);
			rewards.Science:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
			if(affinityRewardStrings == nil) then
				error("affinityRewardStrings was nil");
			end

			local cultureRewardStrings : table = rewards.Culture:GetRewardStrings(player, dividedReward);
			if(cultureRewardStrings == nil) then
				error("cultureRewardStrings was nil");
			end

			local scienceRewardStrings : table = rewards.Science:GetRewardStrings(player, dividedReward);
			if(scienceRewardStrings == nil) then
				error("scienceRewardStrings was nil");
			end

			quest:SetReward(unpack(affinityRewardStrings), unpack(cultureRewardStrings), unpack(scienceRewardStrings));

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
	local player : object = Players[playerType];
	if(player == nil) then
		error("player was nil.");
		return false;
	end

	local capitalCity : object = player:GetCapitalCity();
	if(capitalCity:IsWater()) then
		return false;
	end
	
	return true;
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Affinity", "Harmony");
	QuestRewards.AddReward(rewards, "Culture", "Culture");
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

return QuestScript;