--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local PREVIOUS_CHAPTER_TYPE : number = GameInfo.Quests["QUEST_THE_SOUNDS_OF_HARVEST"].ID;
local BUILDING_TYPE : number = GameInfo.Buildings["BUILDING_HOLOSUITE"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		----------------------------------------------------
		-- Build Launch Complex
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasBuiltHolosuite == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltHolosuite = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SILENT_SYMPHONY_PROLOGUE"));

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_TYPE, 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Connect cities to Capital
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasConnectedCitiesToCapital == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_CONNECT_CITIES_TO_CAPITAL"].ID) then
				quest.PersistentData.HasConnectedCitiesToCapital = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set epilogue
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SILENT_SYMPHONY_BUILD_HOLOSUITE_EPILOGUE"));

			-- find number of cities to connect
			local numcitiesToConnect = 2;
			local player : table = Players[quest:GetOwner()];
			if(player == nil) then
				error("player was nil");
			end
			
			local numNormalCities : number = 0;
			for city in player:Cities() do
				if (city ~= nil and 
					not city:IsCapital() and
					city:IsRazing() == false and
					city:IsPuppet() == false and
					city:IsWater() == false)
				then
					numNormalCities = numNormalCities + 1;
				end
			end
			
			if(numcitiesToConnect > numNormalCities) then
				numcitiesToConnect = numNormalCities;
			end

			if(numcitiesToConnect < 1) then
				numcitiesToConnect = 1;
			end

			-- add new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_CONNECT_CITIES_TO_CAPITAL", numcitiesToConnect);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)

			-- set introduction (epilogue for last objective)
			local civName : string = Players[quest:GetOwner()]:GetCivilizationDescription();
			if(civName == nil) then
				error("civName was nil");
			end

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SILENT_SYMPHONY_CONNECT_CITIES_EPILOGUE"));

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
			rewards.Culture:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
			if(affinityRewardStrings == nil) then
				error("affinityRewardStrings was nil");
			end

			local cultureRewardStrings : table = rewards.Culture:GetRewardStrings(player, dividedReward);
			if(cultureRewardStrings == nil) then
				error("cultureRewardStrings was nil");
			end

			quest:SetReward(unpack(affinityRewardStrings), unpack(cultureRewardStrings));

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
	local player = Players[playerType];
	if(player == nil) then
		error("player was nil");
	end

	if(not HasPlayerDoneQuestType(player:GetID(), PREVIOUS_CHAPTER_TYPE)) then
		return false;
	end

	return true;
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Affinity", "Harmony");
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

----------------------------------------------------
-- Quest-Specific Functionality
----------------------------------------------------

return QuestScript;