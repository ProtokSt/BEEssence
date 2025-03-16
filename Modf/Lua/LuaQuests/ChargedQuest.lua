--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local BUILDING_NEOPLANETARIUM_NUMBER_TO_BUILD : number = 2;--1
local BUILDING_NEOPLANETARIUM_TYPE : number = GameInfo.Buildings["BUILDING_NEOPLANETARIUM"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		----------------------------------------------------
		-- Build Launch Complex
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasBuiltLaunchComplex == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltLaunchComplex = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_CHARGED_PROLOGUE"));

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_NEOPLANETARIUM_TYPE, BUILDING_NEOPLANETARIUM_NUMBER_TO_BUILD);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Launch Satellites
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasLaunchedSatellites == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LAUNCH_SATELLITES"].ID) then
				quest.PersistentData.HasLaunchedSatellites = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set epilogue
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CHARGED_BUILD_LAUNCH_COMPLEX_EPILOGUE"));

			-- add new objective
			AddObjective(quest, "QUEST_OBJECTIVE_LAUNCH_SATELLITES", nil, 2);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)

			-- set introduction (epilogue for last objective)
			local civNameKey : string = Players[quest:GetOwner()]:GetCivilizationDescriptionKey();
			if(civNameKey == nil) then
				error("civNameKey was nil");
			end

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CHARGED_LAUNCH_SATELLITES_EPILOGUE", civNameKey));

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
			rewards.Energy:GiveReward(player, dividedReward);
			rewards.Culture:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
			if(affinityRewardStrings == nil) then
				error("affinityRewardStrings was nil");
			end

			local energyRewardStrings : table = rewards.Energy:GetRewardStrings(player, dividedReward);
			if(energyRewardStrings == nil) then
				error("energyRewardStrings was nil");
			end

			local cultureRewardStrings : table = rewards.Culture:GetRewardStrings(player, dividedReward);
			if(cultureRewardStrings == nil) then
				error("cultureRewardStrings was nil");
			end

			quest:SetReward(unpack(affinityRewardStrings), unpack(energyRewardStrings), unpack(cultureRewardStrings));

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
	QuestRewards.AddReward(rewards, "Affinity", "Supremacy");
	QuestRewards.AddReward(rewards, "Energy", "Energy");
	QuestRewards.AddReward(rewards, "Culture", "Culture");

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