--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local PREVIOUS_CHAPTER_TYPE : number = GameInfo.Quests["QUEST_A_WEALTH_OF_LIMBS"].ID;

local BUILDING_BOREHOLE_TYPE : number = GameInfo.Buildings["BUILDING_BOREHOLE"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{

		----------------------------------------------------
		-- Build Neurolab
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasBuiltNeurolab == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltNeurolab = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_LONELY_REVOLUTION_PROLOGUE"));

			-- add new objective
			local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_BOREHOLE_TYPE, 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_LONELY_REVOLUTION_BUILD_MANUFACTORIES_EPILOGUE"));

			-- Give rewards
			local player : table = Players[quest:GetOwner()];
			if(player == nil) then
				error("player was nil");
			end

			local rewards : table = quest.PersistentData.Rewards;
			if(rewards == nil) then
				error("rewards was nil");
			end

			local dividedReward : number = QuestRewards.DefaultQuestReward / 2;

			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.Energy:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
			if(affinityRewardStrings == nil) then
				error("affinityRewardStrings was nil");
			end

			local energyRewardStrings : table = rewards.Energy:GetRewardStrings(player, dividedReward);
			if(energyRewardStrings == nil) then
				error("energyRewardStrings was nil");
			end

			quest:SetReward(unpack(affinityRewardStrings), unpack(energyRewardStrings));

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

	return DidPlayerSucceedQuestType(player:GetID(), PREVIOUS_CHAPTER_TYPE);
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Affinity", "Purity");
	QuestRewards.AddReward(rewards, "Energy", "Energy");

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