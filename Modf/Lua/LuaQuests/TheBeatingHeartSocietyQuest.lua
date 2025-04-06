--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local BUILDING_RECYCLER_TYPE : number = GameInfo.Buildings["BUILDING_RECYCLER"].ID;
local BUILDING_DRYDOCK_TYPE : number = GameInfo.Buildings["BUILDING_DRYDOCK"].ID;
local BUILDING_ROCKET_BATTERY_TYPE : number = GameInfo.Buildings["BUILDING_ROCKET_BATTERY"].ID;
local IMPROVEMENT_BIOWELL_TYPE : number = GameInfo.Improvements["IMPROVEMENT_BIOWELL"].ID;
local IMPROVEMENT_DOME_TYPE : number = GameInfo.Improvements["IMPROVEMENT_DOME"].ID;
local IMPROVEMENT_NODE_TYPE : number = GameInfo.Improvements["IMPROVEMENT_NODE"].ID;
local MARINE_TYPE : number = GameInfo.Units["UNIT_MARINE"].ID;
local NAVAL_MELEE_TYPE : number = GameInfo.Units["UNIT_NAVAL_MELEE"].ID;
--local HARMONY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_THE_BEATING_HEART_SOCIETY_HARMONY"].ID;
--local PURITY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_THE_BEATING_HEART_SOCIETY_PURITY"].ID;
--local SUPREMACY_PERK_TYPE : number = GameInfo.PlayerPerks["PLAYERPERK_THE_BEATING_HEART_SOCIETY_SUPREMACY"].ID;

-- Harmony Arrest Prompt
function QuestScript.HarmonyArrestPrompt(quest : table, objective : table)
	if(quest.PersistentData.HasMadeHarmonyArrestChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeHarmonyArrestChoice = true;
		quest.PersistentData.HarmonyArrestChoice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set prologue
	quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_HARMONY_ARREST_CHOICE_SUMMARY"));

	local newObjective : object = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_HARMONY_ARREST_CHOICE_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_HARMONY_ARREST_ACCEPT_CHOICE"),
											FlavorTypes = {
												GameInfo.Flavors["FLAVOR_PURITY"].ID,
												GameInfo.Flavors["FLAVOR_SUPREMACY"].ID
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_HARMONY_ARREST_REJECT_CHOICE"),
											FlavorTypes = {
												GameInfo.Flavors["FLAVOR_HARMONY"].ID
											}}
	);

	-- add tooltips
	local rewards : table = quest.PersistentData.Rewards;
	--newObjective:SetPromptTooltipA(rewards.Purity:GetToolTip() .. ", " .. rewards.Supremacy:GetToolTip());
	--newObjective:SetPromptTooltipB(rewards.Harmony:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Recycler
function QuestScript.BuildRecycler(quest : table, objective : table)
	if(quest.PersistentData.HarmonyArrestChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if(quest.PersistentData.HasBuiltRecycler == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltRecycler = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_HARMONY_ARREST_ACCEPT_CHOICE_EPILOGUE"));
	
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_RECYCLER_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Supremacy Arrest Prompt
function QuestScript.SupremacyArrestPrompt(quest : table, objective : table)
	if(quest.PersistentData.HasMadeSupremacyArrestChoice == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		quest.PersistentData.HasMadeSupremacyArrestChoice = true;
		quest.PersistentData.SupremacyArrestChoice = objective.PersistentData.Choice;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_SUPREMACY_ARREST_CHOICE_SUMMARY"));

	local newObjective : object = AddObjective(
		quest, 
		"QUEST_OBJECTIVE_PROMPT",
		Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_DESCRIPTION"),
		Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_SUPREMACY_ARREST_CHOICE_SUMMARY"),
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_SUPREMACY_ARREST_ACCEPT_CHOICE"),
											FlavorTypes = {
												GameInfo.Flavors["FLAVOR_PURITY"].ID
											}},
		hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_SUPREMACY_ARREST_REJECT_CHOICE"),
											FlavorTypes = {
												GameInfo.Flavors["FLAVOR_SUPREMACY"].ID
											}}
	);

	-- add tooltips
	local rewards : table = quest.PersistentData.Rewards;
	--newObjective:SetPromptTooltipA(rewards.Purity:GetToolTip());
	--newObjective:SetPromptTooltipB(rewards.Supremacy:GetToolTip());

	-- set prompt image
	newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Marines Purity
function QuestScript.BuildMarinesPurity(quest : table, objective : table)
	if(quest.PersistentData.SupremacyArrestChoice ~= 1) then
		return BehaviorStatus.FAILED;
	end

	if(quest.PersistentData.HasBuiltMarinesPurity == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
		quest.PersistentData.HasBuiltMarinesPurity = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- Set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_SUPREMACY_ARREST_ACCEPT_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_DOME_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- End Purity
function QuestScript.EndPurity(quest : table, objective : table)
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_BUILD_MARINES_PURITY_EPILOGUE"));

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
	rewards.Science:GiveReward(player, dividedReward);

	-- Set reward strings
	local affinityRewardStrings : table = rewards.Purity:GetRewardStrings(player, dividedReward);
	if(affinityRewardStrings == nil) then
		error("affinityRewardStrings was nil");
	end

	local scienceRewardStrings : table = rewards.Science:GetRewardStrings(player, dividedReward);
	if(scienceRewardStrings == nil) then
		error("scienceRewardStrings was nil");
	end

	quest:SetReward(unpack(affinityRewardStrings), unpack(scienceRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.SUCCEEDED;
end

-- Build Marines Supremacy
function QuestScript.BuildMarinesSupremacy(quest : table, objective : table)
	if(quest.PersistentData.SupremacyArrestChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if(quest.PersistentData.HasBuiltMarinesSupremacy == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
		quest.PersistentData.HasBuiltMarinesSupremacy = true;
		return BehaviorStatus.SUCCEEDED;
	end
	
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_SUPREMACY_ARREST_REJECT_CHOICE_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_NODE_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Kill Station Supremacy
function QuestScript.KillStationSupremacy(quest : table, objective : table)
	if(quest.PersistentData.HasKilledStationSupremacy == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_UNITS"].ID) then
		quest.PersistentData.HasKilledStationSupremacy = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_BUILD_MARINES_SUPREMACY_EPILOGUE"));
	
	-- find City
	local player : object = Players[quest:GetOwner()];
	if(player == nil) then
		error("player was nil");
	end
	local city : object = QuestScript.FindCity(player);
	if(city == nil) then
		-- find Capital
		city = player:GetCapitalCity();
		if(city == nil) then
			error("city was nil");
		end
	end

	-- choose unit type
	local unitType : number = city:IsWater() and NAVAL_MELEE_TYPE or MARINE_TYPE;

	-- add new objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_UNITS", unitType, 1, city:GetID());

	return BehaviorStatus.IN_PROGRESS;
end

-- End Supremacy
function QuestScript.EndSupremacy(quest : table, objective : table)
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_KILL_STATION_SUPREMACY_EPILOGUE"));

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
	rewards.Science:GiveReward(player, dividedReward);

	-- Set reward strings
	local affinityRewardStrings : table = rewards.Supremacy:GetRewardStrings(player, dividedReward);
	if(affinityRewardStrings == nil) then
		error("affinityRewardStrings was nil");
	end

	local scienceRewardStrings : table = rewards.Science:GetRewardStrings(player, dividedReward);
	if(scienceRewardStrings == nil) then
		error("scienceRewardStrings was nil");
	end

	quest:SetReward(unpack(affinityRewardStrings), unpack(scienceRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.SUCCEEDED;
end

-- Build Marines Harmony
function QuestScript.BuildMarinesHarmony(quest : table, objective : table)
	if(quest.PersistentData.HarmonyArrestChoice ~= 2) then
		return BehaviorStatus.FAILED;
	end

	if(quest.PersistentData.HasBuiltMarinesHarmony == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
		quest.PersistentData.HasBuiltMarinesHarmony = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_HARMONY_ARREST_REJECT_CHOICE_EPILOGUE"));

	-- find City
	local player : object = Players[quest:GetOwner()];
	if(player == nil) then
		error("player was nil");
	end
	
	local city : object = QuestScript.FindCity(player);
	if(city == nil) then
		-- find Capital
		city = player:GetCapitalCity();
		if(city == nil) then
			error("city was nil");
		end
	end
	
	if(city:IsWater()) then
		-- add new objective
		local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_DRYDOCK_TYPE, 1, city:GetID());
	else
		-- build building objective
		local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_ROCKET_BATTERY_TYPE, 1);
	end

	return BehaviorStatus.IN_PROGRESS;
end

-- Build Dome
function QuestScript.BuildDome(quest : table, objective : table)
	if(quest.PersistentData.HasBuiltDome == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
		quest.PersistentData.HasBuiltDome = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_BUILD_MARINES_HARMONY_EPILOGUE"));
			
	-- build building objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_BIOWELL_TYPE, 1);

	return BehaviorStatus.IN_PROGRESS;
end

-- Kill Station Harmony
function QuestScript.KillStationHarmony(quest : table, objective : table)
	if(quest.PersistentData.HasKilledStationHarmony == true) then
		return BehaviorStatus.SUCCEEDED;
	end

	if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_UNITS"].ID) then
		quest.PersistentData.HasKilledStationHarmony = true;
		return BehaviorStatus.SUCCEEDED;
	end

	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_BUILD_DOME_EPILOGUE"));
	
	-- find City
	local player : object = Players[quest:GetOwner()];
	if(player == nil) then
		error("player was nil");
	end
	local city : object = QuestScript.FindCity(player);
	if(city == nil) then
		-- find Capital
		city = player:GetCapitalCity();
		if(city == nil) then
			error("city was nil");
		end
	end

	-- choose unit type
	local unitType : number = city:IsWater() and NAVAL_MELEE_TYPE or MARINE_TYPE;

	-- add new objective
	local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_UNITS", unitType, 1, city:GetID());

	return BehaviorStatus.IN_PROGRESS;
end

-- End Harmony
function QuestScript.EndHarmony(quest : table, objective : table)
	-- set epilogue
	objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_THE_BEATING_HEART_SOCIETY_KILL_STATION_HARMONY_EPILOGUE"));

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
	rewards.Science:GiveReward(player, dividedReward);

	-- Set reward strings
	local affinityRewardStrings : table = rewards.Harmony:GetRewardStrings(player, dividedReward);
	if(affinityRewardStrings == nil) then
		error("affinityRewardStrings was nil");
	end

	local scienceRewardStrings : table = rewards.Science:GetRewardStrings(player, dividedReward);
	if(scienceRewardStrings == nil) then
		error("scienceRewardStrings was nil");
	end

	quest:SetReward(unpack(affinityRewardStrings), unpack(scienceRewardStrings));

	-- Succeed
	quest:Succeed();

	return BehaviorStatus.SUCCEEDED;
end

-- Behavior Tree
local BehaviorTree : CvBehaviorNode = BehaviorTree{
	
	SequenceNode{
	
		-- Harmony Arrest Prompt
		ActionNode{QuestScript.HarmonyArrestPrompt},

		--Harmony Arrest Choice
		SelectorNode{
		
			-- (Accept)
			SequenceNode{

				-- Build Recycler DONE
				ActionNode{QuestScript.BuildRecycler},

				-- Supremacy Arrest Prompt
				ActionNode{QuestScript.SupremacyArrestPrompt},

				-- Supremacy Arrest Choice
				SelectorNode{

					-- (Accept)
					SequenceNode{

						-- Build Marines Purity-->Dome DONE
						ActionNode{QuestScript.BuildMarinesPurity},

						-- End Purity
						ActionNode{QuestScript.EndPurity},
					},

					-- (Reject)
					SequenceNode{

						-- Build Marines Supremacy-->Node DONE
						ActionNode{QuestScript.BuildMarinesSupremacy},

						-- Kill Station Supremacy-->Build Marines DONE
						ActionNode{QuestScript.KillStationSupremacy},

						-- End Supremacy
						ActionNode{QuestScript.EndSupremacy},
					},
				}
			},

			-- (Reject)
			SequenceNode{

				-- Build Marines Harmony-->DryDock DONE
				ActionNode{QuestScript.BuildMarinesHarmony},

				-- Build Dome-->Biowell DONE
				ActionNode{QuestScript.BuildDome},

				-- Kill Station Harmony-->Build Marines DONE
				ActionNode{QuestScript.KillStationHarmony},

				-- End Harmony
				ActionNode{QuestScript.EndHarmony},
			},
		},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType : number)

	local player = Players[playerType];

	return (QuestScript.FindCity(player) ~= nil);
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Harmony", "Harmony");
	QuestRewards.AddReward(rewards, "Purity", "Purity");
	QuestRewards.AddReward(rewards, "Supremacy", "Supremacy");
	QuestRewards.AddReward(rewards, "Science", "Science");

	MergeTable(rewards, quest.PersistentData.Rewards);
	quest.PersistentData.Rewards = rewards;
	rewards = {};
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
function QuestScript.FindCity(player)
	
	local cityIDs = {};
	for city in player:Cities() do
		if(city:IsWater()) then
			table.insert(cityIDs, city:GetID());
		end
	end
	
	if(#cityIDs == 0) then
		return nil;
	end
	
	local randomCityID = Game.Rand(#cityIDs - 1, "choosing city id");

	return player:GetCityByID(cityIDs[randomCityID]);
end

return QuestScript;