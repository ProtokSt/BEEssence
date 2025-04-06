--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local MIN_NUMBER_TO_BUILD = 3;
local MAX_NUMBER_TO_BUILD = 6;
local TERRASCAPE_TYPE = GameInfo.Improvements["IMPROVEMENT_TERRASCAPE"].ID;

local PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_QUARRY_CULTURE_FLAT"].ID;

local AFFINITY_REWARD = 10;
local YIELD_REWARD = 50;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		----------------------------------------------------
		-- Build Terrascapes
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltTerrascapes == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
				quest.PersistentData.HasBuiltTerrascapes = true;
				return BehaviorStatus.SUCCEEDED;
			end

				-- Set the prologue
				quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_FROM_SCRATCH_PROLOGUE"));

				-- objective
				local player = Players[quest:GetOwner()];
				local finalBuildCount = player:GetNumCities();

				if(finalBuildCount < MIN_NUMBER_TO_BUILD) then
					finalBuildCount = MIN_NUMBER_TO_BUILD;
				end
				if(finalBuildCount > MAX_NUMBER_TO_BUILD) then
					finalBuildCount = MAX_NUMBER_TO_BUILD;
				end

				local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", TERRASCAPE_TYPE, finalBuildCount);
				newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FROM_SCRATCH_BUILD_TERRASCAPES_EPILOGUE"));

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
			local dividedReward = QuestRewards.DefaultQuestReward / 3;

			local player = Players[quest:GetOwner()];
			local rewards = quest.PersistentData.Rewards;
				
			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.Yield:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
			local yieldRewardStrings = rewards.Yield:GetRewardStrings(player, dividedReward);
			local perkRewardStrings = rewards.Perk:GetRewardStrings(PERK_TYPE);

			quest:SetReward(unpack(affinityRewardStrings), unpack(yieldRewardStrings), unpack(perkRewardStrings));

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
	return true;
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards = {};

	if (isLoad) then
		if (quest.PersistentData.Rewards ~= nil and quest.PersistentData.Rewards.YieldName ~= nil) then
			rewards.YieldName = quest.PersistentData.Rewards.YieldName;
		end
	end

	if (rewards.YieldName == nil) then
		rewards.YieldName = QuestRewards.ChooseReward("Culture", "Energy", "CultureEnergy" );
	end

	QuestRewards.AddReward(rewards, "Affinity", "Purity" );
	QuestRewards.AddReward(rewards, "Yield", rewards.YieldName );
	QuestRewards.AddReward(rewards, "Perk", "PlayerPerk" );

	MergeTable(rewards, quest.PersistentData.Rewards);
	quest.PersistentData.Rewards = rewards;
	rewards = {}
end

function QuestScript.OnStart(quest)
	
	-- find quest reward categories
	AddRewards(quest, false);

	BehaviorTree.Tick(quest, nil);
end

function QuestScript.OnLoad(quest)
	AddRewards(quest, true);
end

function QuestScript.OnObjectiveComplete(quest, objective)
	BehaviorTree.Tick(quest, objective);
end

return QuestScript;