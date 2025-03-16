--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Initialization
----------------------------------------------------
function QuestScript.OnInit()

	function QuestScript.OnPlayerDoTurn(playerType)

		if(QuestScript.PersistentData.CompletedData ~= nil and QuestScript.PersistentData.CompletedData[playerType] ~= nil) then

			local city = QuestScript.PersistentData.CompletedData[playerType].City;

			-- start chapter 2
			local questType = GameInfo.Quests["QUEST_FAMILIAR_EXOTICS_CHAPTER_2"].ID;
			local questScript = GetQuestScript(questType);

			if(questScript.PrerequisitesMet ~= nil and 
				questScript.PrerequisitesMet(playerType, city.X, city.Y) == true) then

				StartQuest(playerType, questScript.Info.ID, city.X, city.Y);

				QuestScript.PersistentData.CompletedData[playerType] = nil;
			end
		end
	end

	GameEvents.PlayerDoTurn.Add(QuestScript.OnPlayerDoTurn);
end

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local QUEST_NAME = GameInfo.Quests["QUEST_FAMILIAR_EXOTICS"].Description;

local BUILDING_CYTONURSERY_TYPE = GameInfo.Buildings["BUILDING_CYTONURSERY"].ID;

local POPULATION_REWARD = 1;
local CULTURE_REWARD = 50;
local ENERGY_REWARD = 50;
local PRODUCTION_REWARD = 50;
local SCIENCE_REWARD = 50;
local FOOD_REWARD = 50;

local AFFINITY_REWARD = 10;

-- Contain vs. Ignore Prompt Behavior
function QuestScript.ContainIgnorePrompt(quest, objective)

	if(quest.PersistentData.HasMadeContainIgnoreChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeContainIgnoreChoice = true;
		quest.PersistentData.ContainIgnoreChoice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	local city = QuestScript.FindCity(Players[quest:GetOwner()]);

	quest.PersistentData.City = {};
	quest.PersistentData.City.X = city:GetX();
	quest.PersistentData.City.Y = city:GetY();
	quest.PersistentData.City.ID = city:GetID();
	quest.PersistentData.City.Name = city:GetName();

	quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_OBJECTIVE_CONTAIN_IGNORE_PROMPT_PROLOGUE", city:GetName()));

	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_OBJECTIVE_CONTAIN_IGNORE_PROMPT_PROLOGUE", city:GetName()),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHOICE_CONTAIN"), 
											FlavorTypes = {
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHOICE_IGNORE"), 
											FlavorTypes = {
											}}
	);

	-- add tooltips
	local rewards = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Harmony:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Purity:GetToolTip() .. ", " .. rewards.Supremacy:GetToolTip());
	
	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Xeno Sanctuary Behavior
function QuestScript.BuildXenoSanctuary(quest, objective)

	if(quest.PersistentData.ContainIgnoreChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltXenoSanctuary == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltXenoSanctuary = true;
		return BehaviorStatus.SUCCEEDED;
	end

	local plot = Map.GetPlot(quest.PersistentData.City.X, quest.PersistentData.City.Y);
	local city = plot:GetPlotCity();

	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHOICE_CONTAIN_EPILOGUE"));
			
	-- build building objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_CYTONURSERY_TYPE, 1, city:GetID());
	newObjective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_OBJECTIVE_BUILD_BUILDING_PROMPT_SUMMARY", GameInfo.Buildings[BUILDING_CYTONURSERY_TYPE].Description, quest.PersistentData.City.Name));
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_OBJECTIVE_OUTLAW_LICENSE_PROMPT_SUMMARY"));

	return BehaviorStatus.IN_PROGRESS;
end

-- Outlaw vs. License Prompt Behavior
function QuestScript.OutlawLicensePrompt(quest, objective)

	if(quest.PersistentData.HasMadeOutlawLicenseChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeOutlawLicenseChoice = true;
		quest.PersistentData.OutlawLicenseChoice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_OBJECTIVE_OUTLAW_LICENSE_PROMPT_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHOICE_OUTLAW"), 
											FlavorTypes = {
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_CHOICE_LICENSE"), 
											FlavorTypes = {
											}}
	);

	-- add tooltips
	local rewards = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Outlaw:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.License:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Outlaw Behavior
function QuestScript.EndOutlaw(quest, objective)

	if(quest.PersistentData.OutlawLicenseChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_OUTLAW_EPILOGUE"));
			
	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Harmony:GiveReward(player, dividedReward);
	rewards.Outlaw:GiveReward(player, dividedReward);

	-- Set reward strings
	local harmonyRewardStrings = rewards.Harmony:GetRewardStrings(player, dividedReward);
	local outlawRewardStrings = rewards.Outlaw:GetRewardStrings(player, dividedReward);

	quest:SetReward(unpack(harmonyRewardStrings), unpack(outlawRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end

-- End License Behavior
function QuestScript.EndLicense(quest, objective)

	if(quest.PersistentData.OutlawLicenseChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_LICENSE_EPILOGUE"));
			
	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;

	local player = Players[quest:GetOwner()];
	local city : object = player:GetCityByID(quest.PersistentData.City.ID);

	local rewards = quest.PersistentData.Rewards;
				
	rewards.Harmony:GiveReward(player, dividedReward);

	if (city ~= nil) then
		rewards.License:GiveReward(city, dividedReward);
	end

	-- Set reward strings
	local harmonyRewardStrings = rewards.Harmony:GetRewardStrings(player, dividedReward);
	local licenseRewardStrings = rewards.License:GetRewardStrings(city, dividedReward);

	quest:SetReward(unpack(harmonyRewardStrings), unpack(licenseRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end

-- End Ignore Behavior
function QuestScript.EndIgnore(quest, objective)

	if(quest.PersistentData.ContainIgnoreChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	-- end ignore and start chapter 2

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_FAMILIAR_EXOTICS_IGNORE_EPILOGUE"));

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 3;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Ignore:GiveReward(player, dividedReward);

	-- Set reward strings
	local ignoreRewardStrings = rewards.Ignore:GetRewardStrings(player, dividedReward);

	quest:SetReward(unpack(ignoreRewardStrings));

	-- Succeed
	quest:Succeed();

	-- Setup for chapter 2
	if(QuestScript.PersistentData.CompletedData == nil) then

		QuestScript.PersistentData.CompletedData = {};
	end

	QuestScript.PersistentData.CompletedData[quest:GetOwner()] = {};
	QuestScript.PersistentData.CompletedData[quest:GetOwner()].City = quest.PersistentData.City;

	return BehaviorStatus.IN_PROGRESS;
end



local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		-- Contain vs. Ignore Prompt
		ActionNode{QuestScript.ContainIgnorePrompt},

		-- Contain vs. Ignore Choice
		SelectorNode{

			SequenceNode{

				-- Build Xeno Sanctuary
				ActionNode{QuestScript.BuildXenoSanctuary},

				-- Outlaw vs. License Prompt
				ActionNode{QuestScript.OutlawLicensePrompt},

				-- Outlaw vs. License Choice
				SelectorNode{

					-- End Outlaw
					ActionNode{QuestScript.EndOutlaw},

					-- End License
					ActionNode{QuestScript.EndLicense},
				},
			},
	
			-- End Ignore
			ActionNode{QuestScript.EndIgnore},
		},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)

	local player = Players[playerType];

	return QuestScript.FindCity(player) ~= nil;
end

local function AddRewards(quest : table, isLoad : boolean)

	local rewards = {};

	if (isLoad) then
		if (quest.PersistentData.Rewards ~= nil and quest.PersistentData.Rewards.OutlawName ~= nil) then
			rewards.LicenseName = quest.PersistentData.Rewards.LicenseName;
		end
		if (quest.PersistentData.Rewards ~= nil and quest.PersistentData.Rewards.OutlawName ~= nil) then
			rewards.OutlawName= quest.PersistentData.Rewards.OutlawName;
		end
	end

	if (rewards.LicenseName == nil) then
		rewards.LicenseName = QuestRewards.ChooseReward("Food", "Population", "Production", "FoodPopulation", "FoodProduction", "PopulationProduction", "FoodPopulationProduction");
	end

	if (rewards.OutlawName == nil) then
		rewards.OutlawName = QuestRewards.ChooseReward("Culture", "Energy", "CultureEnergy" );
	end
	
	QuestRewards.AddReward( rewards, "Harmony", "Harmony" );
	QuestRewards.AddReward( rewards, "Purity", "Purity" );
	QuestRewards.AddReward( rewards, "Supremacy", "Supremacy" );
	QuestRewards.AddReward( rewards, "Ignore", "Culture" );
	QuestRewards.AddReward( rewards, "License", rewards.LicenseName );
	QuestRewards.AddReward( rewards, "Outlaw", rewards.OutlawName );

	MergeTable(rewards, quest.PersistentData.Rewards);
	quest.PersistentData.Rewards = rewards;
	rewards = {}
end

function QuestScript.OnStart(quest)

	-- find quest reward categories
	AddRewards(quest, false);
	local player = Players[quest:GetOwner()];
	quest.PersistentData.Rewards.Outlaw:GetRewardStrings(player, QuestRewards.DefaultQuestReward);

	BehaviorTree.Tick(quest, nil);
end

function QuestScript.OnLoad(quest)
	AddRewards(quest, true);
end

function QuestScript.OnObjectiveComplete(quest, objective)
	BehaviorTree.Tick(quest, objective);
end

----------------------------------------------------
-- Quest-specific functions
---------------------------------------------------- 

function QuestScript.FindCity(player)
	
	local cityIDs = {};
	for city in player:Cities() do
		if(not city:IsWater()) then
			table.insert(cityIDs, city:GetID());
		end
	end

	local randomCityID = Game.Rand(#cityIDs, "choosing city id");

	local city = player:GetCityByID(cityIDs[randomCityID]);

	return city;
end

return QuestScript;