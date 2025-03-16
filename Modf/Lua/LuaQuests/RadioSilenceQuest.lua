--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local PREVIOUS_CHAPTER_TYPE : number = GameInfo.Quests["QUEST_THE_SOUNDS_OF_HARVEST"].ID;

local BUILDING_CYTONURSERY_TYPE : number = GameInfo.Buildings["BUILDING_CYTONURSERY"].ID;
local BUILDING_PROGENITOR_GARDEN_NUMBER_TO_BUILD = 4;--1
local BUILDING_PROGENITOR_GARDEN_TYPE : number = GameInfo.Buildings["BUILDING_PROGENITOR_GARDEN"].ID;

local PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_MGH_PLANTATION_FOOD_FLAT"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		----------------------------------------------------
		-- Separation vs. Integration Prompt
		----------------------------------------------------
		ActionNode{function(quest : object, objective : object)

			if(quest.PersistentData.HasMadeSeparationIntegrationChoice == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
				quest.PersistentData.HasMadeSeparationIntegrationChoice = true;
				quest.PersistentData.SeparationIntegrationChoice = objective.PersistentData.Choice;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_SEPARATION_INTEGRATION_CHOICE_SUMMARY"));

			local newObjective : object = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_SEPARATION_INTEGRATION_CHOICE_SUMMARY"),
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_SEPARATION_CHOICE"), 
													FlavorTypes = {
													
													}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_INTEGRATION_CHOICE"), 
													FlavorTypes = {
													
													}}
			);

			-- add tooltips
			local rewards : table = quest.PersistentData.Rewards;
			newObjective:SetPromptTooltipA(rewards.Population:GetToolTip());
			newObjective:SetPromptTooltipB(rewards.Perk:GetToolTip(PERK_TYPE));

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Separation vs. Integration Choice
		----------------------------------------------------
		SelectorNode{
			
			----------------------------------------------------
			-- Separation Choice
			----------------------------------------------------
			SequenceNode{
			
				----------------------------------------------------
				-- Found City
				----------------------------------------------------
				ActionNode{function(quest : object, objective : object)
					if(quest.PersistentData.SeparationIntegrationChoice ~= 1) then
						return BehaviorStatus.FAILED;
					end

					if (quest.PersistentData.HasFoundedCity == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_FOUND_CITIES"].ID) then
						quest.PersistentData.HasFoundedCity = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_SEPARATION_CHOICE_EPILOGUE"));

					-- add new objective
					local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_FOUND_CITIES", 1);

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- Build Vivarium
				----------------------------------------------------
				ActionNode{function(quest : object, objective : object)
					if (quest.PersistentData.HasBuiltVivarium == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
						quest.PersistentData.HasBuiltVivarium = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_FOUND_CITY_EPILOGUE"));

					-- find city ID
					local cityID : number = objective.PersistentData[1].ID;

					-- save city ID
					quest.PersistentData.NewCityData = {};
					quest.PersistentData.NewCityData.ID = cityID;

					-- add new objective
					local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_CYTONURSERY_TYPE, 1, cityID);

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- End Seperation
				----------------------------------------------------
				ActionNode{function(quest : table, objective : table)

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_BUILD_VIVARIUM_EPILOGUE"));

					-- find target city
					local cityID : number = quest.PersistentData.NewCityData.ID;
					local player : object = Players[quest:GetOwner()];
					local city : object = player:GetCityByID(cityID);
					if(city == nil) then
						error("city was nil");
					end

					-- Give rewards
					local player : table = Players[quest:GetOwner()];
					if(player == nil) then
						error("player was nil");
					end

					local rewards : table = quest.PersistentData.Rewards;
					if(rewards == nil) then
						error("rewards was nil");
					end

					local dividedReward : number = QuestRewards.DefaultQuestReward / 3;

					rewards.Affinity:GiveReward(player, dividedReward);
					rewards.Population:GiveReward(city, dividedReward);
					rewards.Culture:GiveReward(player, dividedReward);

					-- Set reward strings
					local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
					if(affinityRewardStrings == nil) then
						error("affinityRewardStrings was nil");
					end

					local populationRewardStrings : table = rewards.Population:GetRewardStrings(city, dividedReward);
					if(populationRewardStrings == nil) then
						error("populationRewardStrings was nil");
					end

					local cultureRewardStrings : table = rewards.Culture:GetRewardStrings(player, dividedReward);
					if(cultureRewardStrings == nil) then
						error("cultureRewardStrings was nil");
					end

					quest:SetReward(unpack(affinityRewardStrings), unpack(populationRewardStrings), unpack(cultureRewardStrings));

					-- Succeed
					quest:Succeed();

					return BehaviorStatus.SUCCEEDED;
				end},
			},

			----------------------------------------------------
			-- Integration Choice
			----------------------------------------------------
			SequenceNode{

				----------------------------------------------------
				-- Build Xenosanctuaries
				----------------------------------------------------
				ActionNode{function(quest : object, objective : object)
					if (quest.PersistentData.HasBuiltXenosanctuaries == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
						quest.PersistentData.HasBuiltXenosanctuaries = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_INTEGRATION_CHOICE_EPILOGUE"));

					-- add new objective
					local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_PROGENITOR_GARDEN_TYPE, BUILDING_PROGENITOR_GARDEN_NUMBER_TO_BUILD);

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- Launch Satellites
				----------------------------------------------------
				ActionNode{function(quest : table, objective : table)
					if (quest.PersistentData.HasLaunchedSatellites == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LAUNCH_SATELLITES"].ID) then
						quest.PersistentData.HasLaunchedSatellites = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_BUILD_XENOSANCTUARIES_EPILOGUE"));

					-- add new objective
					AddObjective(quest, "QUEST_OBJECTIVE_LAUNCH_SATELLITES", nil, 1);

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- End Integration
				----------------------------------------------------
				ActionNode{function(quest : table, objective : table)

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_RADIO_SILENCE_LAUNCH_SATELLITES_EPILOGUE"));

					-- Give rewards
					local player : table = Players[quest:GetOwner()];
					if(player == nil) then
						error("player was nil");
					end

					local rewards : table = quest.PersistentData.Rewards;
					if(rewards == nil) then
						error("rewards was nil");
					end

					local dividedReward : number = QuestRewards.DefaultQuestReward / 3;

					rewards.Affinity:GiveReward(player, dividedReward);
					rewards.ProductionAllCities:GiveReward(player, dividedReward);
					rewards.Perk:GiveReward(player, PERK_TYPE);

					-- Set reward strings
					local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
					if(affinityRewardStrings == nil) then
						error("affinityRewardStrings was nil");
					end

					local productionAllCitiesRewardStrings : table = rewards.ProductionAllCities:GetRewardStrings(player, dividedReward);
					if(productionAllCitiesRewardStrings == nil) then
						error("productionAllCitiesRewardStrings was nil");
					end

					local perkRewardStrings = rewards.Perk:GetRewardStrings(PERK_TYPE);
					if(perkRewardStrings == nil) then
						error("perkRewardStrings was nil");
					end

					quest:SetReward(unpack(affinityRewardStrings), unpack(cultureRewardStrings), unpack(perkRewardStrings));

					-- Succeed
					quest:Succeed();

					return BehaviorStatus.SUCCEEDED;
				end},
			},
		},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType : number)
	local player : object = Players[playerType];
	if(player == nil) then
		error("player was nil");
	end

	return DidPlayerSucceedQuestType(player:GetID(), PREVIOUS_CHAPTER_TYPE)
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Affinity", "Harmony");
	QuestRewards.AddReward(rewards, "Population", "Population");
	QuestRewards.AddReward(rewards, "Culture", "Culture");
	QuestRewards.AddReward(rewards, "ProductionAllCities", "ProductionAllCities");
	QuestRewards.AddReward(rewards, "Perk", "PlayerPerk" );

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

return QuestScript;