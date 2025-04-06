--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local BUILDING_CYTONURSERY_TYPE : number = GameInfo.Buildings["BUILDING_CYTONURSERY"].ID;
local BUILDING_GAIAN_WELL_TYPE : number = GameInfo.Buildings["BUILDING_GAIAN_WELL"].ID;
local BUILDING_VIVARIUM_TYPE : number = GameInfo.Buildings["BUILDING_VIVARIUM"].ID;
local ALIEN_PRESERVE_TYPE : number = GameInfo.Buildings["BUILDING_ALIEN_PRESERVE"].ID;
local RANGED_MARINE_TYPE : number = GameInfo.Units["UNIT_RANGED_MARINE"].ID;

local HARMONY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_VANISHERS_HARMONY"].ID;
local PURITY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_VANISHERS_PURITY"].ID;
local SUPREMACY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_VANISHERS_SUPREMACY"].ID;

-- Build Clinic
function QuestScript.BuildClinic(quest : object, objective : object)
	if (quest.PersistentData.HasBuiltClinic == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltClinic = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- choose city for quest
	local cityID : number = QuestScript.GetCityID(quest:GetOwner());
	quest.PersistentData.CityID = cityID;
	
	-- find city
	local player : object = Players[quest:GetOwner()];
	if(player == nil) then
		error("player was nil");
	end
	local city : object = player:GetCityByID(cityID);

	-- set prologue
	quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_PROLOGUE", city:GetName()));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_CYTONURSERY_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Aliens Discovered Prompt
function QuestScript.AliensDiscoveredPrompt(quest : object, objective : object)
	if(quest.PersistentData.HasMadeAliensDiscoveredChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeAliensDiscoveredChoice = true;
		quest.PersistentData.AliensDiscoveredChoice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	-- find city
	local cityID : number = quest.PersistentData.CityID;
	if(cityID == nil) then
		error("cityID was nil");
	end
	
	local player : object = Players[quest:GetOwner()];
	if(player == nil) then
		error("player was nil");
	end
	local city : object = player:GetCityByID(cityID);

	-- set prologue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_ALIENS_DISCOVERED_CHOICE_SUMMARY", city:GetName()));

	local newObjective : object = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_ALIENS_DISCOVERED_CHOICE_SUMMARY", city:GetName()),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_ALIENS_DISCOVERED_ACCEPT_CHOICE"),
											FlavorTypes = {
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_ALIENS_DISCOVERED_REJECT_CHOICE"), 
											FlavorTypes = {
											}}
	);

	-- add tooltips
	local rewards : table = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Harmony:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Purity:GetToolTip() .. ", " .. rewards.Supremacy:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Vivarium
function QuestScript.BuildVivarium(quest : object, objective : object)
	if(quest.PersistentData.AliensDiscoveredChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltVivarium == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltVivarium = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_ACCEPT_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_GAIAN_WELL_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Rangers
function QuestScript.BuildRanger(quest : object, objective : object)
	if (quest.PersistentData.HasBuiltRanger == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_UNITS"].ID) then
		quest.PersistentData.HasBuiltRanger = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_BUILD_VIVARIUM_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_UNITS", RANGED_MARINE_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Harmony
function QuestScript.EndHarmony(quest : object, objective : object)
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_BUILD_RANGER_EPILOGUE"));

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

-- Build Vivarium
function QuestScript.BuildUltrasonicFence(quest : object, objective : object)
	if(quest.PersistentData.AliensDiscoveredChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltUltrasonicFence == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltUltrasonicFence = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_REJECT_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_VIVARIUM_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Study Exterminate Prompt
function QuestScript.StudyExterminatePrompt(quest : object, objective : object)
	if(quest.PersistentData.HasMadeStudyExterminateChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeStudyExterminateChoice = true;
		quest.PersistentData.StudyExterminateChoice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	-- find city
	local cityID : number = quest.PersistentData.CityID;
	if(cityID == nil) then
		error("cityID was nil");
	end
	
	local player : object = Players[quest:GetOwner()];
	if(player == nil) then
		error("player was nil");
	end
	local city : object = player:GetCityByID(cityID);

	-- set prologue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_STUDY_EXTERMINATE_CHOICE_SUMMARY", city:GetName()));

	local newObjective : object = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_STUDY_EXTERMINATE_CHOICE_SUMMARY", city:GetName()),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_STUDY_EXTERMINATE_STUDY_CHOICE"), 
											FlavorTypes = {
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_STUDY_EXTERMINATE_EXTERMINATE_CHOICE"), 
											FlavorTypes = {
											}}
	);

	-- add tooltips
	local rewards : table = quest.PersistentData.Rewards;
	newObjective:SetPromptTooltipA(rewards.Purity:GetToolTip());
	newObjective:SetPromptTooltipB(rewards.Supremacy:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Alien Preserve
function QuestScript.BuildAlienPreserve(quest : object, objective : object)
	if(quest.PersistentData.StudyExterminateChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasBuiltAlienPreserve == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltAlienPreserve = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_STUDY_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", ALIEN_PRESERVE_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Purity
function QuestScript.EndPurity(quest : object, objective : object)
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_BUILD_ALIEN_PRESERVE_EPILOGUE"));

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

-- Kill Aliens
function QuestScript.KillAliens(quest : object, objective : object)
	if(quest.PersistentData.StudyExterminateChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if (quest.PersistentData.HasKilledAliens == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_KILL_PLAYER_UNITS"].ID) then
		quest.PersistentData.HasKilledAliens = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_EXTERMINATE_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_KILL_PLAYER_UNITS", GameDefines.ALIEN_PLAYER, 2);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Supremacy
function QuestScript.EndSupremacy(quest : object, objective : object)
	-- find city
	local cityID : number = quest.PersistentData.CityID;
	if(cityID == nil) then
		error("cityID was nil");
	end
	
	local player : object = Players[quest:GetOwner()];
	if(player == nil) then
		error("player was nil");
	end
	local city : object = player:GetCityByID(cityID);

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_VANISHERS_KILL_ALIENS_EPILOGUE", city:GetName()));

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

-- Behavior Tree
local BehaviorTree : CvBehaviorNode = BehaviorTree
{	
	SequenceNode
	{
		-- Build Clinic
		ActionNode{QuestScript.BuildClinic},

		-- Aliens Discovered Prompt
		ActionNode{QuestScript.AliensDiscoveredPrompt},

		-- Aliens Discovered Choice
		SelectorNode
		{
			-- (Accept)
			SequenceNode
			{
				-- Build Repair Facility
				ActionNode{QuestScript.BuildVivarium},

				-- Build Workers
				ActionNode{QuestScript.BuildRanger},

				-- End Harmony
				ActionNode{QuestScript.EndHarmony},
			},

			-- (Reject)
			SequenceNode
			{
				-- Build Ultrasonic Fence
				ActionNode{QuestScript.BuildUltrasonicFence},

				-- Study vs. Exterminate Prompt
				ActionNode{QuestScript.StudyExterminatePrompt},

				-- Study vs. Exterminate Choice
				SelectorNode
				{
					-- (Study)
					SequenceNode
					{
						-- Build Alien Preserve
						ActionNode{QuestScript.BuildAlienPreserve},

						-- End Purity
						ActionNode{QuestScript.EndPurity},
					},

					-- (Exterminate)
					SequenceNode
					{
						-- Kill Aliens
						ActionNode{QuestScript.KillAliens},

						-- End Supremacy
						ActionNode{QuestScript.EndSupremacy},
					},
				},
			},
		}
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType : number)
	local cityID : number = QuestScript.GetCityID(playerType);
	if(cityID == nil) then
		return false;
	end

	return true;
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

function QuestScript.OnObjectiveComplete(quest : table, objective : object)
	BehaviorTree.Tick(quest, objective);
end

----------------------------------------------------
-- Quest-Specific Functionality
----------------------------------------------------
function QuestScript.GetCityID(playerType : number)
	local player : object = Players[playerType];
	if(player == nil) then
		error("player was nil");
	end

	local cityIDs : table = {};

	for i : number = 0, player:GetNumCities() - 1, 1 do
		local city : object = player:GetCityByID(i);
		if(	city ~= nil and
			not city:IsWater())
		then
			table.insert(cityIDs, i);
		end
	end

	if (#cityIDs > 0) then
		return Game.Rand(#cityIDs - 1, "Choosing random city ID");
	end

	return nil;
end

return QuestScript;