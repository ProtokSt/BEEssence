--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local QUEST_NAME = GameInfo.Quests["QUEST_FAMILIAR_EXOTICS"].Description;

local BUILDING_WATER_PLANT_TYPE = GameInfo.Buildings["BUILDING_WATER_PLANT"].ID;
local BUILDING_VIVARIUM_TYPE = GameInfo.Buildings["BUILDING_VIVARIUM"].ID;
local BUILDING_TIDAL_TURBINE_TYPE = GameInfo.Buildings["BUILDING_TIDAL_TURBINE"].ID;
local BUILDING_THORIUM_REACTOR_TYPE = GameInfo.Buildings["BUILDING_THORIUM_REACTOR"].ID;

local POPULATION_REWARD = 1;
local CULTURE_REWARD = 50;
local ENERGY_REWARD = 50;
local PRODUCTION_REWARD = 50;
local SCIENCE_REWARD = 25;
local FOOD_REWARD = 25;

local AFFINITY_REWARD = 10;

-- Contain vs. Ignore Prompt Behavior
function QuestScript.FoodEnergyPrompt(quest, objective)

	if(quest.PersistentData.HasMadeChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeChoice = true;
		quest.PersistentData.Choice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	-- find city
	local cityID : number = quest.PersistentData.City.ID;
	local player : object = Players[quest:GetOwner()];
	local city : object = player:GetCityByID(cityID);
	if(city == nil) then
		error("city was nil.");
	end

	quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHAPTER_2_OBJECTIVE_FOOD_ENERGY_PROMPT_SUMMARY"));

	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHAPTER_2_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHAPTER_2_OBJECTIVE_FOOD_ENERGY_PROMPT_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHAPTER_2_CHOICE_FOOD"), 
											FlavorTypes = {
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHAPTER_2_CHOICE_ENERGY"), 
											FlavorTypes = {
											}}
	);

	-- add tooltips
	local rewards = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Purity:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Supremacy:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build PharmaLab Behavior
function QuestScript.BuildPharmaLab(quest, objective)

	if(quest.PersistentData.Choice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltPharmaLab == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltPharmaLab = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- find city
	local cityID : number = quest.PersistentData.City.ID;
	local player : object = Players[quest:GetOwner()];
	local city : object = player:GetCityByID(cityID);
	if(city == nil) then
		error("city was nil.");
	end

	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHOICE_FOOD_EPILOGUE"));
			
	-- build building objective
	local buildingType : number = -1;
	if (city:IsWater()) then
		buildingType = BUILDING_WATER_PLANT_TYPE;		
	else
		buildingType = BUILDING_VIVARIUM_TYPE;
	end

	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", buildingType, 1, city:GetID());

	local buildingName = GameInfo.Buildings[buildingType].Description;
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHAPTER_2_OBJECTIVE_BUILD_PHARMALAB_EPILOGUE", buildingName));

	return BehaviorStatus.IN_PROGRESS;
end


-- End Food Behavior
function QuestScript.EndFood(quest, objective)
	
	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 3;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Purity:GiveReward(player, dividedReward);
	rewards.GrowLab:GiveReward(player, dividedReward / 2);
	rewards.Science:GiveReward(player, dividedReward / 2);

	-- Set reward strings
	local purityRewardStrings = rewards.Purity:GetRewardStrings(player, dividedReward);
	local growLabRewardStrings = rewards.GrowLab:GetRewardStrings(player, dividedReward / 2);
	local scienceRewardStrings = rewards.Science:GetRewardStrings(player, dividedReward / 2);

	quest:SetReward(unpack(purityRewardStrings), unpack(growLabRewardStrings), unpack(scienceRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end


-- Build PharmaLab Behavior
function QuestScript.BuildGrowLab(quest, objective)

	if(quest.PersistentData.Choice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltGrowLab == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltGrowLab = true;
		return BehaviorStatus.SUCCEEDED;
	end

	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHOICE_ENERGY_EPILOGUE"));
	
	-- find city
	local cityID : number = quest.PersistentData.City.ID;
	local player : object = Players[quest:GetOwner()];
	local city : object = player:GetCityByID(cityID);
	if(city == nil) then
		error("city was nil.");
	end

	local buildingType : number = -1;
	if (city:IsWater()) then
		buildingType = BUILDING_TIDAL_TURBINE_TYPE;
	else
		buildingType = BUILDING_THORIUM_REACTOR_TYPE;
	end

	-- build building objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", buildingType, 1, quest.PersistentData.City.ID);
	local buildingName = GameInfo.Buildings[buildingType].Description;
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHAPTER_2_OBJECTIVE_BUILD_GROWLAB_EPILOGUE", buildingName));

	return BehaviorStatus.IN_PROGRESS;
end


-- End Energy Behavior
function QuestScript.EndEnergy(quest, objective)
	
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
				
	rewards.Supremacy:GiveReward(player, dividedReward);
	rewards.PharmaLab:GiveReward(city, dividedReward);

	-- Set reward strings
	local supremacyRewardStrings = rewards.Supremacy:GetRewardStrings(player, dividedReward);
	local pharmaLabRewardStrings = rewards.PharmaLab:GetRewardStrings(city, dividedReward);

	quest:SetReward(unpack(supremacyRewardStrings), unpack(pharmaLabRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end




local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		-- Food vs. Energy Prompt
		ActionNode{QuestScript.FoodEnergyPrompt},

		-- Food vs. Energy Choice
		SelectorNode{

			SequenceNode{

				-- Build PharmaLab
				ActionNode{QuestScript.BuildPharmaLab},

				-- End Food
				ActionNode{QuestScript.EndFood},
			},
	
			SequenceNode{

				-- Build GrowLab
				ActionNode{QuestScript.BuildGrowLab},

				-- End Energy
				ActionNode{QuestScript.EndEnergy},
			},
		},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType, cityX, cityY)

	local plot = Map.GetPlot(cityX, cityY);
	local city = plot:GetPlotCity();

	if(city ~= nil) then

		return city:GetOwner() == playerType;
	end

	return false;
end

local function AddRewards(quest : table, isLoad : boolean)

	local rewards = {};

	if (isLoad) then
		if (quest.PersistentData.Rewards ~= nil and quest.PersistentData.Rewards.PharmaLabName ~= nil) then
			rewards.PharmaLabName = quest.PersistentData.Rewards.PharmaLabName;
		end
		if (quest.PersistentData.Rewards ~= nil and quest.PersistentData.Rewards.GrowLabName ~= nil) then
			rewards.GrowLabName= quest.PersistentData.Rewards.GrowLabName;
		end
	end

	if (rewards.PharmaLabName == nil) then
		rewards.PharmaLabName = QuestRewards.ChooseReward("Food", "Population", "Production", "FoodPopulation", "FoodProduction", "PopulationProduction", "FoodPopulationProduction");
	end

	if (rewards.GrowLabName == nil) then
		rewards.GrowLabName = QuestRewards.ChooseReward("Culture", "Energy", "CultureEnergy" );
	end

	QuestRewards.AddReward( rewards, "Purity", "Purity" );
	QuestRewards.AddReward( rewards, "Supremacy", "Supremacy" );
	QuestRewards.AddReward( rewards, "Science", "Science" );
	QuestRewards.AddReward( rewards, "PharmaLab", rewards.PharmaLabName );
	QuestRewards.AddReward( rewards, "GrowLab", rewards.GrowLabName );

	MergeTable(rewards, quest.PersistentData.Rewards);
	quest.PersistentData.Rewards = rewards;
	rewards = {}
end

function QuestScript.OnStart(quest, cityX, cityY)
	
	-- find quest reward categories
	AddRewards(quest, false);

	local plot = Map.GetPlot(cityX, cityY);
	local city = plot:GetPlotCity();


	quest.PersistentData.City = {};
	quest.PersistentData.City.ID = city:GetID();

	BehaviorTree.Tick(quest, nil);
end

function QuestScript.OnLoad(quest)
	AddRewards(quest, true);
end

function QuestScript.OnObjectiveComplete(quest, objective)
	BehaviorTree.Tick(quest, objective);
end

return QuestScript;