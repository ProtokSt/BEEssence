--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local ULTRASONIC_FENCE_TYPE = GameInfo.Buildings["BUILDING_ULTRASONIC_FENCE"].ID;
local LABORATORY_TYPE = GameInfo.Buildings["BUILDING_LABORATORY"].ID;
local ULTRASONIC_FENCES_REPEL_RANGE_PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_ULTRASONIC_FENCES_REPEL_RANGE"].ID;


local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		----------------------------------------------------
		-- Build UltraSonic Fence
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltUltrasonicFence == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltUltrasonicFence = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- find eligible city (without ultrasonic fence)
			local player = Players[quest:GetOwner()];
			local city = player:GetCapitalCity();
			if(city == nil) then
				error("city was nil");
			end
			
			--quest.PersistentData.City = {};
			--quest.PersistentData.City.ID = city:GetID();

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_GENIUS_OF_OLIVIA_ROSS_PROLOGUE", city:GetName()));

			-- add new objective
			--local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", ULTRASONIC_FENCE_TYPE, 1, city:GetID());
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", ULTRASONIC_FENCE_TYPE, 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Build Laboratory
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltLaboratory == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and 
				objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID
				and quest.PersistentData.HasBegunBuildLaboratoryObjective == true) then

				quest.PersistentData.HasBuiltLaboratory = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- begin this quest chapter (support for two sequential objective of the same type)
			quest.PersistentData.HasBegunBuildLaboratoryObjective = true;

			-- find eligible city (with ultrasonic fence) --MGH
			local player = Players[quest:GetOwner()];--MGH
			local city = QuestScript.FindCity(player);--MGH
			if(city == nil) then
				error("city was nil");
			end
			
			quest.PersistentData.City = {};--MGH
			quest.PersistentData.City.ID = city:GetID();--MGH

			-- set introduction (epilogue for last objective)
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_GENIUS_OF_OLIVIA_ROSS_BUILD_ULTRASONIC_FENCE_EPILOGUE", city:GetName()));--MGH:GetNameKey

			-- add new objective
			--local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", LABORATORY_TYPE, 1, city:GetID());
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", LABORATORY_TYPE, 1);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest, objective)

			-- find city
			local cityID : number = quest.PersistentData.City.ID;
			local player : object = Players[quest:GetOwner()];
			local city : object = player:GetCityByID(cityID);

			-- set introduction (epilogue for last objective)
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_GENIUS_OF_OLIVIA_ROSS_BUILD_LABORATORY_EPILOGUE", city:GetNameKey()));

			-- store city info for next Chapter of Quest
			if(QuestScript.PersistentData.CitiesByPlayer == nil) then
				QuestScript.PersistentData.CitiesByPlayer = {};
			end

			if(QuestScript.PersistentData.CitiesByPlayer[quest:GetOwner()] == nil) then
				QuestScript.PersistentData.CitiesByPlayer[quest:GetOwner()] = {};
			end

			QuestScript.PersistentData.CitiesByPlayer[quest:GetOwner()].ID = city:GetID();

			-- Give rewards
			local player = Players[quest:GetOwner()];
			local rewards = quest.PersistentData.Rewards;
			local dividedReward = QuestRewards.DefaultQuestReward / 2;

			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.Perk:GiveReward(player, ULTRASONIC_FENCES_REPEL_RANGE_PERK_TYPE);

			-- Set reward strings
			local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
			local perkRewardStrings = rewards.Perk:GetRewardStrings(ULTRASONIC_FENCES_REPEL_RANGE_PERK_TYPE);

			quest:SetReward(unpack(affinityRewardStrings), unpack(perkRewardStrings));

			-- Succeed
			quest:Succeed();

			return BehaviorStatus.SUCCEEDED;
		end},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)
	if(playerType~=nil) then
		return Players[playerType]:CountNumBuildings(ULTRASONIC_FENCE_TYPE) == 0;
	else
		return false;
	end
end

local function AddRewards(quest : table, isLoad : boolean)

	local rewards = {}
	QuestRewards.AddReward(rewards, "Affinity", "Supremacy");--MGH
	QuestRewards.AddReward(rewards, "Perk", "PlayerPerk");

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

----------------------------------------------------
-- QuestScript Functionality
---------------------------------------------------- 
function QuestScript.FindCity(player)

	local cities : table = {};

	for city in player:Cities() do
		if(city ~= nil and city:IsHasBuilding(ULTRASONIC_FENCE_TYPE)) then --MGH
			table.insert(cities, city);
		end
	end

	local randomCityIndex = Game.Rand(#cities, "choosing city") + 1;
	return cities[randomCityIndex];
end

return QuestScript;