--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local BUILDING_ORGAN_PRINTER_NUMBER_TO_BUILD = 3;--1
local BUILDING_XENONURSERY_TYPE = GameInfo.Buildings["BUILDING_XENONURSERY"].ID;
local BUILDING_ORGAN_PRINTER_TYPE = GameInfo.Buildings["BUILDING_ORGAN_PRINTER"].ID;		

local AFFINITY_REWARD = 10;

local PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_THE_BEATING_HEART_SOCIETY_HARMONY"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		----------------------------------------------------
		-- Build Xenosanctuary
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltXenosanctuary == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			quest.PersistentData.HasBuiltXenosanctuary = true;

			-- Set the prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_LEADFOOT_SOLDIER_PROLOGUE"));

			-- objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_XENONURSERY_TYPE, 1);
			--newObjective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_LEADFOOT_SOLDIER_BUILD_XENO_SANCTUARY_SUMMARY"));
			newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_LEADFOOT_SOLDIER_BUILD_XENO_SANCTUARY_EPILOGUE"));

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Build Organ Printer
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltOrganPrinter == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			quest.PersistentData.HasBuiltOrganPrinter = true;

			-- objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_ORGAN_PRINTER_TYPE, BUILDING_ORGAN_PRINTER_NUMBER_TO_BUILD);
			--newObjective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_LEADFOOT_SOLDIER_BUILD_ORGAN_PRINTER_SUMMARY"));
			newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_LEADFOOT_SOLDIER_BUILD_ORGAN_PRINTER_EPILOGUE"));

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
	local prerequisitTech1 = GameInfo.Technologies["TECH_ORGANICS"].ID;--MGH
	local prerequisitTech2 = GameInfo.Technologies["TECH_ROBOTICS"].ID;--MGH

	return Players[playerType]:HasTech(prerequisitTech1) or Players[playerType]:HasTech(prerequisitTech2);
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Harmony(),
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