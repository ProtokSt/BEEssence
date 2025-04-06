----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local LIFEFORM_SENSOR_TYPE = GameInfo.Spacecraft["SPACECRAFT_LIFEFORM_SENSOR"].ID;
local alienNestsReveiledRewardSummaryKey : string = "TXT_KEY_QUEST_GENETIC_ENTANGLEMENT_ALIEN_NESTS_REVEILED_REWARD_SUMMARY";
local NUMBER_TO_KILL = 5;--3
local AFFINITY_REWARD = 10;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		----------------------------------------------------
		-- Kill Aliens
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasKilledAliens == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_KILL_PLAYER_UNITS"].ID) then
				quest.PersistentData.HasKilledAliens = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set the prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_GENETIC_ENTANGLEMENT_PROLOGUE"));
			
			-- objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_KILL_PLAYER_UNITS", GameDefines.ALIEN_PLAYER, NUMBER_TO_KILL);
			newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_GENETIC_ENTANGLEMENT_KILL_ALIENS_EPILOGUE"));

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

			-- unlock alien nest site locations
			player:DoRevealAlienNests();

			-- Set reward strings
			local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
			local alienNestsReveiledRewardSummary : string = Locale.ConvertTextKey(alienNestsReveiledRewardSummaryKey);

			quest:SetReward(unpack(affinityRewardStrings), alienNestsReveiledRewardSummary);

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

	return (Game.GetLoadoutSpacecraft(playerType) ~= LIFEFORM_SENSOR_TYPE);
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Harmony()
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