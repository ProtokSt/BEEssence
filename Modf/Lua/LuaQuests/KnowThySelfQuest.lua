--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Affinity Quest Setup
----------------------------------------------------
function QuestScript.PrerequisitesMet(playerType)

	return true;
end

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local BUILDING_NETWORK_TYPE = "BUILDING_NETWORK";

local YIELD_REWARD = 100;
local AFFINITY_REWARD = 50;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		----------------------------------------------------
		-- Build Buildings 
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltRelics == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltRelics = true;
				return BehaviorStatus.SUCCEEDED;
			end

				-- Set the prologue
				quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_KNOW_THYSELF_PROLOGUE"));

				-- find building count
				local player = Players[quest:GetOwner()];

				local numNormalCities = 0;
				for city in player:Cities() do
					if(city ~= nil and city:IsRazing() == false and city:IsPuppet() == false) then
						numNormalCities = numNormalCities + 1;
					end
				end

				-- Set the first objective
				local relicID : number = GameInfo.Buildings[BUILDING_NETWORK_TYPE].ID;

				local objective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", relicID, numNormalCities);
				objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_KNOW_THYSELF_OBJECTIVE_BUILD_BUILDING_EPILOGUE"));

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

	local numNormalCities = 0;
	local numBuildings = 0;
	local player = Players[playerType];
	local relicID : number = GameInfo.Buildings[BUILDING_NETWORK_TYPE].ID;
	
	for city in player:Cities() do
		if(city ~= nil and city:IsRazing() == false and city:IsPuppet() == false) then
			numNormalCities = numNormalCities + 1;
		end
	end

	for city in player:Cities() do
		if (city:IsHasBuilding(relicID)) then
			numBuildings = numBuildings + 1;
		end
	end
	
	return numNormalCities > numBuildings;
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

	QuestRewards.AddReward( rewards, "Affinity", "Purity" );
	QuestRewards.AddReward( rewards, "Yield", rewards.YieldName );

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
