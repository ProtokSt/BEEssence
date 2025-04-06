--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local BUILDING_REPAIR_FACILITY_TYPE : number = GameInfo.Buildings["BUILDING_REPAIR_FACILITY"].ID;
local BUILDING_BIOFACTORY_TYPE : number = GameInfo.Buildings["BUILDING_BIOFACTORY"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		----------------------------------------------------
		-- Trade With Station
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasTradedWithStation == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			quest.PersistentData.HasTradedWithStation = true;

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_A_WEALTH_OF_LIMBS_PROLOGUE"));

			-- add new objective
			local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_REPAIR_FACILITY_TYPE, 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Build Laboratory
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasBuiltLaboratory == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			quest.PersistentData.HasBuiltLaboratory = true;

			-- Set epilogue
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_A_WEALTH_OF_LIMBS_TRADE_WITH_STATION_EPILOGUE"));

			-- add new objective
			local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_BIOFACTORY_TYPE, 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_A_WEALTH_OF_LIMBS_BUILD_LABORATORY_EPILOGUE"));

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
			rewards.ProductionAllCities:GiveReward(player, dividedReward);
			rewards.Science:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
			if(affinityRewardStrings == nil) then
				error("affinityRewardStrings was nil");
			end

			local productionAllCitiesRewardStrings : table = rewards.ProductionAllCities:GetRewardStrings(player, dividedReward);
			if(productionAllCitiesRewardStrings == nil) then
				error("productionAllCitiesRewardStrings was nil");
			end

			local scienceRewardStrings : table = rewards.Science:GetRewardStrings(player, dividedReward);
			if(scienceRewardStrings == nil) then
				error("scienceRewardStrings was nil");
			end

			quest:SetReward(unpack(affinityRewardStrings), unpack(productionAllCitiesRewardStrings), unpack(scienceRewardStrings));

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
	QuestRewards.AddReward(rewards, "Affinity", "Harmony");
	QuestRewards.AddReward(rewards, "ProductionAllCities", "ProductionAllCities");
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

return QuestScript;