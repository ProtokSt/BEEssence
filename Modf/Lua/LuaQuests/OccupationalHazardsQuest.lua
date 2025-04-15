--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};


----------------------------------------------------
-- Constants
---------------------------------------------------- 
local BUILDING_ALIEN_PRESERVE_TYPE = GameInfo.Buildings["BUILDING_ALIEN_PRESERVE"].ID;
local ALIEN_NEST_COUNT = 1;--2

local HARMONY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.HARMONY_TYPE].Description;
local PURITY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.PURITY_TYPE].Description;
local SUPREMACY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.SUPREMACY_TYPE].Description;
local AFFINITY_REWARD = 10;
local YIELD_REWARD = 50;


-- Domesticate vs. Eradicate Prompt Behavior
function QuestScript.DomesticateEradicatePrompt(quest, objective)

	if(quest.PersistentData.HasMadeDomesticateEradicateChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeDomesticateEradicateChoice = true;
		quest.PersistentData.DomesticateEradicateChoice = objective.PersistentData.Choice;

		if(objective.PersistentData.Choice == 1) then

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_CHOICE_DOMESTICATE_EPILOGUE"));

		elseif(objective.PersistentData.Choice == 2) then

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_CHOICE_ERADICATE_EPILOGUE"));
		end
		return BehaviorStatus.SUCCEEDED;
	end

	-- prologue
	quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_OBJECTIVE_DOMESTICATE_ERADICATE_PROMPT_SUMMARY"));

	-- objective
	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_OBJECTIVE_DOMESTICATE_ERADICATE_PROMPT_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_CHOICE_DOMESTICATE"),
											FlavorTypes = {
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_CHOICE_ERADICATE"),
											FlavorTypes = {
											}}
	);

	-- add tooltips
	local rewards = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Harmony:GetToolTip() .. ", " .. rewards.Supremacy:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Purity:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Alien Preserve Behavior
function QuestScript.BuildAlienPreserve(quest, objective)

	if(quest.PersistentData.DomesticateEradicateChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltAlienPreserve == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltAlienPreserve = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_ALIEN_PRESERVE_TYPE, 1);
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_OBJECTIVE_ADOPT_TRAIN_PROMPT_SUMMARY"));

	return BehaviorStatus.IN_PROGRESS;
end

-- Adopt vs. Train Prompt Behavior
function QuestScript.AdoptTrainPrompt(quest, objective)

	if(quest.PersistentData.HasMadeAdoptTrainChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeAdoptTrainChoice = true;
		quest.PersistentData.AdoptTrainChoice = objective.PersistentData.Choice;

		if(objective.PersistentData.Choice == 1) then

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_END_HARMONY"));

		elseif(objective.PersistentData.Choice == 2) then

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_END_SUPREMACY"));
		end
		return BehaviorStatus.SUCCEEDED;
	end

	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_DESCRIPTION"), 
		Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_OBJECTIVE_ADOPT_TRAIN_PROMPT_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_CHOICE_ADOPT"), 
											FlavorTypes = {
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_CHOICE_TRAIN"), 
											FlavorTypes = {
											}}
	);

	-- add tooltips
	local rewards = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Harmony:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Supremacy:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Adopt Behavior
function QuestScript.EndAdopt(quest, objective)

	if(quest.PersistentData.AdoptTrainChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Harmony:GiveReward(player, dividedReward);
	rewards.Adopt:GiveReward(player, dividedReward);

	-- Set reward strings
	local harmonyRewardStrings = rewards.Harmony:GetRewardStrings(player, dividedReward);
	local adoptRewardStrings = rewards.Adopt:GetRewardStrings(player, dividedReward);

	quest:SetReward(unpack(harmonyRewardStrings), unpack(adoptRewardStrings));

	-- Succeed
	quest:Succeed();
	
	return BehaviorStatus.IN_PROGRESS;
end

-- End Train Behavior
function QuestScript.EndTrain(quest, objective)

	if(quest.PersistentData.AdoptTrainChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;

	local player = Players[quest:GetOwner()];
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Supremacy:GiveReward(player, dividedReward);
	rewards.Train:GiveReward(player, dividedReward);

	-- Set reward strings
	local supremacyRewardStrings = rewards.Supremacy:GetRewardStrings(player, dividedReward);
	local trainRewardStrings = rewards.Train:GetRewardStrings(player, dividedReward);

	quest:SetReward(unpack(supremacyRewardStrings), unpack(trainRewardStrings));

	-- Succeed
	quest:Succeed();
	
	return BehaviorStatus.IN_PROGRESS;
end

-- Kill Alien Nests Behavior
function QuestScript.KillAlienNests(quest, objective)

	if(quest.PersistentData.DomesticateEradicateChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasKilledAlienNests == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_DESTROY_ALIEN_NESTS"].ID) then
		quest.PersistentData.HasKilledAlienNests = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_DESTROY_ALIEN_NESTS", ALIEN_NEST_COUNT);
	newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_OCCUPATIONAL_HAZARDS_END_PURITY"));

	return BehaviorStatus.IN_PROGRESS;
end

-- End Eradicate
function QuestScript.EndEradicate(quest, objective)

	-- Give rewards
	local dividedReward = QuestRewards.DefaultQuestReward / 2;
	
	local player = Players[quest:GetOwner()];
	local city = player:GetCapitalCity();
	local rewards = quest.PersistentData.Rewards;
				
	rewards.Purity:GiveReward(player, dividedReward);
	rewards.Eradicate:GiveReward(city, dividedReward);

	-- Set reward strings
	local purityRewardStrings = rewards.Purity:GetRewardStrings(player, dividedReward);
	local eradicateRewardStrings = rewards.Eradicate:GetRewardStrings(city, dividedReward);

	quest:SetReward(unpack(purityRewardStrings), unpack(eradicateRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.IN_PROGRESS;
end


local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		-- Domesticate vs. Eradicate Prompt
		ActionNode{QuestScript.DomesticateEradicatePrompt},

		-- Domesticate vs. Eradicate Choice
		SelectorNode{

			SequenceNode{

				-- Build Alien Preserve
				ActionNode{QuestScript.BuildAlienPreserve},

				-- Adopt vs. Train Prompt
				ActionNode{QuestScript.AdoptTrainPrompt},

				-- Adopt vs. Train Choice
				SelectorNode{

					-- End Adopt
					ActionNode{QuestScript.EndAdopt},

					-- End Train
					ActionNode{QuestScript.EndTrain},
				},
			},
	
			SequenceNode{

				-- Kill Alien Nests
				ActionNode{QuestScript.KillAlienNests},

				-- End Eradicate
				ActionNode{QuestScript.EndEradicate},
			},
		},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)

	return QuestScript.FindBuildingInCity(playerType) == nil;
end

local function AddRewards(quest : table, isLoad : boolean)

	local rewards = {};

	if (isLoad) then
		if (quest.PersistentData.Rewards ~= nil and quest.PersistentData.Rewards.AdoptName ~= nil) then
			rewards.AdoptName = quest.PersistentData.Rewards.AdoptName;
		end
		if (quest.PersistentData.Rewards ~= nil and quest.PersistentData.Rewards.EradicateName ~= nil) then
			rewards.EradicateName= quest.PersistentData.Rewards.EradicateName;
		end
	end

	if (rewards.AdoptName == nil) then
		rewards.AdoptName = QuestRewards.ChooseReward("Culture", "Energy", "CultureEnergy" );
	end

	if (rewards.EradicateName == nil) then
		rewards.EradicateName = QuestRewards.ChooseReward("Food", "Population", "FoodPopulation" );
	end

	QuestRewards.AddReward( rewards, "Harmony", "Harmony" );
	QuestRewards.AddReward( rewards, "Purity", "Purity" );
	QuestRewards.AddReward( rewards, "Supremacy", "Supremacy" );
	QuestRewards.AddReward( rewards, "Train", "ProductionAllCities" );
	QuestRewards.AddReward( rewards, "Adopt", rewards.AdoptName );
	QuestRewards.AddReward( rewards, "Eradicate", rewards.EradicateName );

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

----------------------------------------------------
-- Quest-specific functions
----------------------------------------------------
function QuestScript.FindBuildingInCity(playerType)
	local player = Players[playerType];

	local candidateCity = nil;

	for city in player:Cities() do
		local hasAlienPreserve = city:IsHasBuilding(BUILDING_ALIEN_PRESERVE_TYPE);
		
		if(hasAlienPreserve) then
			candidateCity = city;
			break;
		end
	end

	return candidateCity;
end

return QuestScript;