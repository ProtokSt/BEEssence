--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local IMPROVEMENT_MINE_NUMBER_TO_BUILD = 2;

local IMPROVEMENT_MINE_TYPE = GameInfo.Improvements["IMPROVEMENT_MINE"].ID;
local LABORATORY_TYPE = GameInfo.Buildings["BUILDING_THERMOHALINE_RUDDER"].ID;

local PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_MGH_SEA_WELL_PRODUCTION_FLAT"].ID;

local AFFINITY_REWARD = 10;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		----------------------------------------------------
		-- Build Quarry
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltQuarry == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
				quest.PersistentData.HasBuiltQuarry = true;
				return BehaviorStatus.SUCCEEDED;
			end

				-- Set the prologue
				quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_NO_ONE_THING_PROLOGUE"));

				-- objective
				local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_MINE_TYPE, IMPROVEMENT_MINE_NUMBER_TO_BUILD);
				newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_NO_ONE_THING_BUILD_QUARRY_EPILOGUE"));

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Build Laboratory
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltLaboratory == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltLaboratory = true;
				return BehaviorStatus.SUCCEEDED;
			end

				-- objective
				local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", LABORATORY_TYPE, NUMBER_TO_BUILD);
				newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_NO_ONE_THING_BUILD_LABORATORY_EPILOGUE"));

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

			local rewards = quest.PersistentData.Rewards;
			local player = Players[quest:GetOwner()];

			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.Perk:GiveReward(player, PERK_TYPE);

			-- Set reward strings
			local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
			local perkRewardStrings = rewards.Perk:GetRewardStrings(PERK_TYPE);

			quest:SetReward(unpack(affinityRewardStrings), unpack(perkRewardStrings));

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
	
	local numWaterCities = 0;
	for city in player:Cities() do
		if(city ~= nil and city:IsRazing() == false and city:IsPuppet() == false and city:IsWater() == true) then
			numWaterCities = numWaterCities + 1;
		end
	end
	
	if(numWaterCities == 0) then
		return false;
	end
	
	return true;
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Purity(),
		Perk = QuestRewards.PlayerPerk()
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