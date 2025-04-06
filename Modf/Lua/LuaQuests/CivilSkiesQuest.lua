--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local BUILDING_SOMA_DISTILLERY_TYPE : number = GameInfo.Buildings["BUILDING_SOMA_DISTILLERY"].ID;

local POPULATION_REWARD = 1;
local ENERGY_REWARD = 50;
local PRODUCTION_REWARD = 50;
local SCIENCE_REWARD = 50;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode {
		----------------------------------------------------
		-- Found a city on a tile next to Float Stone
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if(quest.PersistentData.HasFoundedCityNextToFloatStone == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasFoundedCityNextToFloatStone = true;
				return BehaviorStatus.SUCCEEDED;
			end

			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_CIVIL_SKIES_PROLOGUE"));

			-- find city
			local city = QuestScript.FindAvailableCity(quest:GetOwner());

			quest.PersistentData.City = {};
			quest.PersistentData.City.ID = city:GetID();

			-- new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_SOMA_DISTILLERY_TYPE, 1, city:GetID());
			--local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_FOUND_CITIES_NEXT_TO_RESOURCE", 1, FLOAT_STONE_TYPE);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Tourism vs. Industry Prompt
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if(quest.PersistentData.HasMadeTourismVsIndustryChoice == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then

				quest.PersistentData.HasMadeTourismVsIndustryChoice = true;
				quest.PersistentData.TourismVsIndustryChoice = objective.PersistentData.Choice;

				-- find city
				local cityID : number = quest.PersistentData.City.ID;
				local player : object = Players[quest:GetOwner()];
				local city : object = player:GetCityByID(cityID);
				if(city == nil) then
					error("city was nil.");
				end

				if(objective.PersistentData.Choice == 1) then

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CIVIL_SKIES_OBJECTIVE_Tourism_VS_Industry_Prompt_CHOICE_TOURISM_EPILOGUE", city:GetNameKey()));
				elseif(objective.PersistentData.Choice == 2) then

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CIVIL_SKIES_OBJECTIVE_Tourism_VS_Industry_Prompt_CHOICE_INDUSTRY_EPILOGUE", city:GetNameKey()));
				end

				return BehaviorStatus.SUCCEEDED;
			end

			local objectiveCityID : number = objective.PersistentData[1].ID;
			local player : object = Players[quest:GetOwner()];
			local city = player:GetCityByID(objectiveCityID);

			quest.PersistentData.City = {};
			quest.PersistentData.City.ID = city:GetID();

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_CIVIL_SKIES_OBJECTIVE_Tourism_VS_Industry_Prompt_SUMMARY", city:GetNameKey()));

			local newObjective = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_CIVIL_SKIES_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUEST_CIVIL_SKIES_OBJECTIVE_Tourism_VS_Industry_Prompt_SUMMARY", city:GetNameKey()),
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_CIVIL_SKIES_OBJECTIVE_Tourism_VS_Industry_Prompt_CHOICE_TOURISM"), 
													FlavorTypes = {
													
													}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_CIVIL_SKIES_OBJECTIVE_Tourism_VS_Industry_Prompt_CHOICE_INDUSTRY"), 
													FlavorTypes = {
													
													}}
			);

			-- add tooltips
			local rewards = quest.PersistentData.Rewards;
			newObjective:SetPromptTooltipA(rewards.Population:GetToolTip() .. ", " .. rewards.Energy:GetToolTip());
			newObjective:SetPromptTooltipB(rewards.Production:GetToolTip() .. ", " .. rewards.Science:GetToolTip());

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Tourism vs. Industry Choice
		----------------------------------------------------
		SelectorNode{
		
			----------------------------------------------------
			-- End Tourism
			----------------------------------------------------
			ActionNode{function(quest, objective)
				if(quest.PersistentData.TourismVsIndustryChoice ~= 1) then
					return BehaviorStatus.FAILED;
				end

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 3;

				-- find city
				local cityID : number = quest.PersistentData.City.ID;
				local player : object = Players[quest:GetOwner()];
				local city : object = player:GetCityByID(cityID);
				if(city == nil) then
					error("city was nil.");
				end

				local rewards = quest.PersistentData.Rewards;
				
				rewards.Affinity:GiveReward(player, dividedReward);
				rewards.Population:GiveReward(city, 1);
				rewards.Energy:GiveReward(player, dividedReward);

				-- Set reward strings
				local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
				local populationRewardStrings = rewards.Population:GetRewardStrings(city, 1);
				local energyRewardStrings = rewards.Energy:GetRewardStrings(player, dividedReward);

				quest:SetReward(unpack(affinityRewardStrings), unpack(populationRewardStrings), unpack(energyRewardStrings));

				-- Succeed!
				quest:Succeed();

				return BehaviorStatus.IN_PROGRESS;
			end},

			----------------------------------------------------
			-- End Industry
			----------------------------------------------------
			ActionNode{function(quest, objective)
				if(quest.PersistentData.TourismVsIndustryChoice ~= 2) then
					return BehaviorStatus.FAILED;
				end

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 3;

				-- find city
				local cityID : number = quest.PersistentData.City.ID;
				local player : object = Players[quest:GetOwner()];
				local city : object = player:GetCityByID(cityID);
				if(city == nil) then
					error("city was nil.");
				end

				local rewards = quest.PersistentData.Rewards;
				
				rewards.Affinity:GiveReward(player, dividedReward);
				rewards.Production:GiveReward(city, dividedReward);
				rewards.Science:GiveReward(player, dividedReward);

				-- Set reward strings
				local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
				local productionRewardStrings = rewards.Production:GetRewardStrings(city, dividedReward);
				local scienceRewardStrings = rewards.Science:GetRewardStrings(player, dividedReward);

				quest:SetReward(unpack(affinityRewardStrings), unpack(productionRewardStrings), unpack(scienceRewardStrings));

				-- Succeed!
				quest:Succeed();

				return BehaviorStatus.IN_PROGRESS;
			end},
		}
	}
}
----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)

	return QuestScript.FindAvailableCity(playerType) ~= nil;
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Purity(),
		Population = QuestRewards.Population(),
		Production = QuestRewards.Production(),
		Energy = QuestRewards.Energy(),
		Science = QuestRewards.Science()
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

----------------------------------------------------
-- Quest-specific functions
----------------------------------------------------
function QuestScript.FindAvailableCity(playerType)
	local player = Players[playerType];

	if(player:GetNumCities() <= 1) then
		return nil;
	end

	local resourceType = GameInfo.Resources["RESOURCE_FLOAT_STONE"].ID;
	local capitalCity = player:GetCapitalCity();
	local candidateCity = nil;

	for city in player:Cities() do
		local hasSomaDistillery = city:IsHasBuilding(BUILDING_SOMA_DISTILLERY_TYPE);
		local hasFloatStone = city:IsHasResourceLocal(resourceType);
		
		if((not hasSomaDistillery) and
		   hasFloatStone and 
		   city ~= capitalCity) then --changed

			candidateCity = city;
			break;
		end
	end

	return candidateCity;
end

return QuestScript;