--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local BUILDING_PHARMALAB_TYPE : number = GameInfo.Buildings["BUILDING_PHARMALAB"].ID;
local BUILDING_DEFENSE_PERIMETER_TYPE : number = GameInfo.Buildings["BUILDING_DEFENSE_PERIMETER"].ID;
local IMPROVEMENT_PETROL_WELL_TYPE : number = GameInfo.Improvements["IMPROVEMENT_PETROL_WELL"].ID;
local BUILDING_ULTRASONIC_FENCE_TYPE : number = GameInfo.Buildings["BUILDING_ULTRASONIC_FENCE"].ID;
local BUILDING_COMMAND_CENTER_TYPE : number = GameInfo.Buildings["BUILDING_COMMAND_CENTER"].ID;
local BUILDING_SPY_AGENCY_TYPE : number = GameInfo.Buildings["BUILDING_SPY_AGENCY"].ID;
local HARMONY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_THE_SUBSET_CURSE_HARMONY"].ID;
local PURITY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_THE_SUBSET_CURSE_PURITY"].ID;
local SUPREMACY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_THE_SUBSET_CURSE_SUPREMACY"].ID;


-- Build Laboratory
function QuestScript.BuildLaboratory(quest : table, objective : table)
	if (quest.PersistentData.HasBuiltLaboratory == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltLaboratory = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set prologue
	quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_PROLOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_PHARMALAB_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Accept vs. Reject Prompt
function QuestScript.AcceptRejectPrompt(quest : table, objective : table)
	if(quest.PersistentData.HasMadeAcceptRejectChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeAcceptRejectChoice = true;
		quest.PersistentData.AcceptRejectChoice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_ACCEPT_REJECT_CHOICE_SUMMARY"));

	local newObjective : object = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_ACCEPT_REJECT_CHOICE_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_ACCEPT_CHOICE"), 
											FlavorTypes = {}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_REJECT_CHOICE"), 
											FlavorTypes = {}}
	);

	-- add tooltips
	local rewards : table = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Harmony:GetToolTip() .. ", " .. rewards.Supremacy:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Purity:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Pharmalab
function QuestScript.BuildPharmalab(quest : table, objective : table)
	if(quest.PersistentData.AcceptRejectChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltPharmalab == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltPharmalab = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_ACCEPT_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_DEFENSE_PERIMETER_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Spread vs. Hone Prompt
function QuestScript.SpreadHonePrompt(quest : table, objective : table)
	if(quest.PersistentData.HasMadeSpreadHoneChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeSpreadHoneChoice = true;
		quest.PersistentData.SpreadHoneChoice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_SPREAD_HONE_CHOICE_SUMMARY"));

	local newObjective = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_SPREAD_HONE_CHOICE_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_SPREAD_CHOICE"), 
											FlavorTypes = {}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_HONE_CHOICE"), 
											FlavorTypes = {}}
	);

	-- add tooltips
	local rewards : table = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Harmony:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Supremacy:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Biofactory
function QuestScript.BuildBiofactory(quest : table, objective : table)
	if(quest.PersistentData.SpreadHoneChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltBiofactory == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltBiofactory = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_SPREAD_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_COMMAND_CENTER_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Harmony
function QuestScript.EndHarmony(quest : table, objective : table)
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_BUILD_BIOFACTORY_EPILOGUE"));

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

	rewards.Harmony:GiveReward(player, dividedReward);
	rewards.Perk:GiveReward(player, HARMONY_PERK_TYPE);

	-- Set reward strings
	local affinityRewardStrings : table = rewards.Harmony:GetRewardStrings(player, dividedReward);
	if(affinityRewardStrings == nil) then
		error("affinityRewardStrings was nil");
	end

	local perksRewardStrings : table = rewards.Perk:GetRewardStrings(HARMONY_PERK_TYPE);
	if(perksRewardStrings == nil) then
		error("perksRewardStrings was nil");
	end

	quest:SetReward(unpack(affinityRewardStrings), unpack(perksRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.SUCCEEDED;
end

-- Build Spy Agency
function QuestScript.BuildSpyAgency(quest : table, objective : table)
	if(quest.PersistentData.SpreadHoneChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltSpyAgency == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltSpyAgency = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_HONE_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_SPY_AGENCY_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Supremacy
function QuestScript.EndSupremacy(quest : table, objective : table)
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_BUILD_SPY_AGENCY_EPILOGUE"));

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

	rewards.Supremacy:GiveReward(player, dividedReward);
	rewards.Perk:GiveReward(player, SUPREMACY_PERK_TYPE);

	-- Set reward strings
	local affinityRewardStrings : table = rewards.Supremacy:GetRewardStrings(player, dividedReward);
	if(affinityRewardStrings == nil) then
		error("affinityRewardStrings was nil");
	end

	local perksRewardStrings : table = rewards.Perk:GetRewardStrings(SUPREMACY_PERK_TYPE);
	if(perksRewardStrings == nil) then
		error("perksRewardStrings was nil");
	end

	quest:SetReward(unpack(affinityRewardStrings), unpack(perksRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.SUCCEEDED;
end

-- Find Resource Pods
function QuestScript.FindResourcePods(quest : table, objective : table)
	if(quest.PersistentData.AcceptRejectChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasFoundResourcePods == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	--if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_FIND_RESOURCE_PODS"].ID) then
	--if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
	if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
		quest.PersistentData.HasFoundResourcePods = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- Set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_DESCRIPTION_REJECT_CHOICE_EPILOGUE"));

	-- add new objective
	-- Set the first objective
	--AddObjective(quest, "QUEST_OBJECTIVE_FIND_RESOURCE_PODS", 1);--2->1
	--local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_DEFENSE_PERIMETER_TYPE, 1);-- build building objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_PETROL_WELL_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Gene Garden
function QuestScript.BuildGeneGarden(quest : table, objective : table)
	if (quest.PersistentData.HasBuiltGeneGarden == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltGeneGarden = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_FIND_RESOURCE_PODS_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_ULTRASONIC_FENCE_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Purity
function QuestScript.EndPurity(quest : table, objective : table)
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_SUBSET_CURSE_BUILD_GENE_GARDEN_EPILOGUE"));

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

	rewards.Purity:GiveReward(player, dividedReward);
	rewards.Perk:GiveReward(player, PURITY_PERK_TYPE);

	-- Set reward strings
	local affinityRewardStrings : table = rewards.Purity:GetRewardStrings(player, dividedReward);
	if(affinityRewardStrings == nil) then
		error("affinityRewardStrings was nil");
	end

	local perksRewardStrings : table = rewards.Perk:GetRewardStrings(PURITY_PERK_TYPE);
	if(perksRewardStrings == nil) then
		error("perksRewardStrings was nil");
	end

	quest:SetReward(unpack(affinityRewardStrings), unpack(perksRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.SUCCEEDED;
end

-- Behavior Tree
local BehaviorTree : CvBehaviorNode = BehaviorTree{
	
	SequenceNode{
	
		-- Build Laboratory
		ActionNode{QuestScript.BuildLaboratory},

		-- Accept vs. Reject Prompt
		ActionNode{QuestScript.AcceptRejectPrompt},

		-- Accept vs. Reject Choice
		SelectorNode{
		
			-- (Accept)
			SequenceNode{

				-- Build Pharmalab
				ActionNode{QuestScript.BuildPharmalab},

				-- Spread vs. Hone Prompt
				ActionNode{QuestScript.SpreadHonePrompt},

				-- Spread vs. Hone Choice
				SelectorNode{

					-- (Spread)
					SequenceNode{

						-- Build Biofactory
						ActionNode{QuestScript.BuildBiofactory},

						-- End Harmony
						ActionNode{QuestScript.EndHarmony},
					},

					-- (Hone)
					SequenceNode{

						-- Build Spy Agency
						ActionNode{QuestScript.BuildSpyAgency},

						-- End Supremacy
						ActionNode{QuestScript.EndSupremacy},
					},
				}
			},

			-- (Reject)
			SequenceNode{

				-- Find Resource Pods
				ActionNode{QuestScript.FindResourcePods},

				-- Build Gene Garden
				ActionNode{QuestScript.BuildGeneGarden},

				-- End Purity
				ActionNode{QuestScript.EndPurity},
			},
		},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType : number)
	if(Game.IsOption(GameOptionTypes.GAMEOPTION_NO_GOODY_HUTS)) then
		return false;
	end
	
	if(QuestScript.FindBuildingInCity(playerType) ~= nil) then
		return false;
	end
	
	return QuestScript.FindAvailableCity(playerType) ~= nil;
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Harmony", "Harmony");
	QuestRewards.AddReward(rewards, "Purity", "Purity");
	QuestRewards.AddReward(rewards, "Supremacy", "Supremacy");
	QuestRewards.AddReward(rewards, "Perk", "PlayerPerk");

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
function QuestScript.FindBuildingInCity(playerType)
	local player = Players[playerType];

	local candidateCity = nil;

	for city in player:Cities() do
		local hasUltrasonicFence = city:IsHasBuilding(BUILDING_ULTRASONIC_FENCE_TYPE);
		local hasCommandCenter = city:IsHasBuilding(BUILDING_COMMAND_CENTER_TYPE);
		local hasSpyAgency = city:IsHasBuilding(BUILDING_SPY_AGENCY_TYPE);
		
		if(hasUltrasonicFence or hasCommandCenter or hasSpyAgency) then
			candidateCity = city;
			break;
		end
	end

	return candidateCity;
end

function QuestScript.FindAvailableCity(playerType)
	local player = Players[playerType];

	local tubersType = GameInfo.Resources["RESOURCE_TUBERS"].ID;
	local coralType = GameInfo.Resources["RESOURCE_CORAL"].ID;
	local candidateCity = nil;

	for city in player:Cities() do
		local hasPharmaLab = city:IsHasBuilding(BUILDING_PHARMALAB_TYPE);
		local hasTubers = city:IsHasResourceLocal(tubersType);
		local hasCoral = city:IsHasResourceLocal(coralType);
		
		if(not hasPharmaLab) then
			if(hasTubers or hasCoral) then
				candidateCity = city;
				break;
			end
		end
	end

	return candidateCity;
end

return QuestScript;