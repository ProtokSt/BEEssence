--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local IMPROVEMENT_MINE_NUMBER_TO_BUILD = 1;
local BUILDING_MASS_DIGESTER_NUMBER_TO_BUILD = 1;--2

local IMPROVEMENT_MINE_TYPE = GameInfo.Improvements["IMPROVEMENT_MINE"].ID;
local MASS_DIGESTER_TYPE = GameInfo.Buildings["BUILDING_MASS_DIGESTER"].ID;
local PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_MASS_DIGESTER_CITY_HP"].ID;

local HARMONY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.HARMONY_TYPE].Description;
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
				quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_SECURE_COMPOUNDS_PROLOGUE"));

				-- objective
				local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_MINE_TYPE, IMPROVEMENT_MINE_NUMBER_TO_BUILD);
				newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SECURE_COMPOUNDS_BUILD_QUARRY_EPILOGUE"));

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Build Biofactories
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
				local player = Players[quest:GetOwner()];

				local numNormalCities = 0;
				for city in player:Cities() do
					if(city ~= nil and city:IsRazing() == false and city:IsPuppet() == false) then
						numNormalCities = numNormalCities + 1;
					end
				end

				local finalBuildCount = numNormalCities;

				if(finalBuildCount > BUILDING_MASS_DIGESTER_NUMBER_TO_BUILD) then
					finalBuildCount = BUILDING_MASS_DIGESTER_NUMBER_TO_BUILD;
				end

				local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", MASS_DIGESTER_TYPE, finalBuildCount);
				newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SECURE_COMPOUNDS_BUILD_MASS_DIGESTERS_EPILOGUE"));

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
	local prerequisitTech = GameInfo.Technologies["TECH_TERRAFORMING"].ID;--Changed from TECH_ORGANICS

	return Players[playerType]:HasTech(prerequisitTech);
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