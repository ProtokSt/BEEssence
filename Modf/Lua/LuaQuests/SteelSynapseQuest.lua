--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local BUILDING_FEEDSITE_HUB_NUMBER_TO_BUILD = 3;
local BUILDING_FEEDSITE_HUB_TYPE = "BUILDING_FEEDSITE_HUB";

local YIELD_REWARD = 100;
local AFFINITY_REWARD = 50;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		----------------------------------------------------
		-- Build Buildings 
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltBuildings == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltBuildings = true;
				return BehaviorStatus.SUCCEEDED;
			end

				-- Set the prologue
				quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_STEEL_SYNAPSE_PROLOGUE"));

				-- find building count
				local numBuildings = BUILDING_FEEDSITE_HUB_NUMBER_TO_BUILD;

				-- Set the first objective
				local objective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_FEEDSITE_HUB_TYPE, numBuildings);
				--objective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_STEEL_SYNAPSE_OBJECTIVE_BUILD_BUILDING_SUMMARY", numBuildings));
				objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_STEEL_SYNAPSE_OBJECTIVE_BUILD_BUILDING_EPILOGUE"));

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasEnded == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			-- Give rewards
			local dividedReward = QuestRewards.DefaultQuestReward / 2;

			local player = Players[quest:GetOwner()];
			local rewards = quest.PersistentData.Rewards;
				
			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.Yield:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
			local yieldRewardStrings = rewards.Yield:GetRewardStrings(player, dividedReward);

			quest:SetReward(unpack(affinityRewardStrings), unpack(yieldRewardStrings));

			-- Succeed
			quest:Succeed();

			return BehaviorStatus.IN_PROGRESS;
		end},
	},
}

----------------------------------------------------
-- Callbacks
----------------------------------------------------
function QuestScript.PrerequisitesMet(playerType)

	local player = Players[playerType];
	
	local numNormalCities = 0;
	for city in player:Cities() do
		if(city ~= nil and city:IsRazing() == false and city:IsPuppet() == false) then
			numNormalCities = numNormalCities + 1;
		end
	end
	
	if(numNormalCities < BUILDING_FEEDSITE_HUB_NUMBER_TO_BUILD) then
		return false;
	end
	
	return Players[playerType]:CountNumBuildings(GameInfo.Buildings[BUILDING_FEEDSITE_HUB_TYPE].ID) == 0;
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Supremacy(),
		Yield = QuestRewards.Science()
	}

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

return QuestScript;