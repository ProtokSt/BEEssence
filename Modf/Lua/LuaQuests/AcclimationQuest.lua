--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local BUILDING_GAIAN_WELL_NUMBER_TO_BUILD = 1;
local BUILDING_GENE_SMELTER_NUMBER_TO_BUILD = 4;--2

local BUILDING_GAIAN_WELL_TYPE = GameInfo.Buildings["BUILDING_GAIAN_WELL"].ID;
local BUILDING_GENE_SMELTER_TYPE = GameInfo.Buildings["BUILDING_GENE_SMELTER"].ID;

local RESPIRATION_PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_ACCLIMATION_TRADE_ROUTE_YIELDS"].ID;
local DIGESTION_PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_ACCLIMATION_GROWTH_CARRYOVER"].ID;

local HARMONY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.HARMONY_TYPE].Description;
local AFFINITY_REWARD = 10;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		----------------------------------------------------
		-- Build Borehole
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltBorehole == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then

				-- find city
				local cityID : number = quest.PersistentData.City.ID;
				local player : object = Players[quest:GetOwner()];
				local city : object = player:GetCityByID(cityID);
				if(city == nil) then
					error("city was nil.");
				end

				-- Set epilogue
				local buildingName = GameInfo.Buildings[BUILDING_GAIAN_WELL_TYPE].Description;

				objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_OBJECTIVE_BUILD_BOREHOLE_EPILOGUE", city:GetNameKey(), buildingName));

				quest.PersistentData.HasBuiltBorehole = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- find city
			local city = QuestScript.CityNearCanyon(quest:GetOwner());

			quest.PersistentData.City = {};
			quest.PersistentData.City.ID = city:GetID();

			-- Set the prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_PROLOGUE", city:GetNameKey()));

			-- objective
			local buildingName = GameInfo.Buildings[BUILDING_GAIAN_WELL_TYPE].Description;

			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_GAIAN_WELL_TYPE, BUILDING_GAIAN_WELL_NUMBER_TO_BUILD, city:GetID());

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Build Gene Gardens
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltGeneGardens == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID and objective.PersistentData.BuildingType == BUILDING_GENE_SMELTER_TYPE) then
				quest.PersistentData.HasBuiltGeneGardens = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- objective
			local numBuildings = BUILDING_GENE_SMELTER_NUMBER_TO_BUILD;
			local player = Players[quest:GetOwner()];
			
			local numNormalCities = 0;
			for city in player:Cities() do
				if(city ~= nil and city:IsRazing() == false and city:IsPuppet() == false) then
					numNormalCities = numNormalCities + 1;
				end
			end
			
			local numPlayerCities = numNormalCities;

			if(numBuildings > numPlayerCities) then
				numBuildings = numPlayerCities;
			end

			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_GENE_SMELTER_TYPE, numBuildings);
			newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_OBJECTIVE_RESPIRATION_DIGESTION_PROMPT_SUMMARY"));

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Respiration vs. Digestion Prompt
		----------------------------------------------------
		ActionNode{function(quest, objective)

			if(quest.PersistentData.HasMadeRepirationDigestionChoice == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
				quest.PersistentData.HasMadeRepirationDigestionChoice = true;
				quest.PersistentData.RepirationDigestionChoice = objective.PersistentData.Choice;

				if(objective.PersistentData.Choice == 1) then

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_CHOICE_RESPIRATION_EPILOGUE"));
				else

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_CHOICE_DIGESTION_EPILOGUE"));
				end

				return BehaviorStatus.SUCCEEDED;
			end

			local newObjective = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_OBJECTIVE_RESPIRATION_DIGESTION_PROMPT_SUMMARY"),
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_CHOICE_RESPIRATION"), 
											FlavorTypes = {
											}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_ACCLIMATION_CHOICE_DIGESTION"), 
											FlavorTypes = {
											}}
			);

			-- add tooltips
			local rewards = quest.PersistentData.Rewards;
			newObjective:SetPromptTooltipA(rewards.Respiration:GetToolTip(RESPIRATION_PERK_TYPE));
			newObjective:SetPromptTooltipB(rewards.Digestion:GetToolTip(DIGESTION_PERK_TYPE));

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Respiration vs. Digestion Choice
		----------------------------------------------------
		SelectorNode{


			----------------------------------------------------
			-- End Respiration
			----------------------------------------------------
			ActionNode{function(quest, objective)
				if(quest.PersistentData.RepirationDigestionChoice ~= 1) then
					return BehaviorStatus.FAILED;
				end

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 2;

				local rewards = quest.PersistentData.Rewards;
				local player = Players[quest:GetOwner()];
				rewards.Affinity:GiveReward(player, dividedReward);
				rewards.Respiration:GiveReward(player, RESPIRATION_PERK_TYPE);

				-- Set reward strings
				local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
				local respirationRewardStrings = rewards.Respiration:GetRewardStrings(RESPIRATION_PERK_TYPE);

				quest:SetReward(unpack(affinityRewardStrings), unpack(respirationRewardStrings));

				-- Succeed
				quest:Succeed();

				return BehaviorStatus.IN_PROGRESS;
			end},

			----------------------------------------------------
			-- End Digestion
			----------------------------------------------------
			ActionNode{function(quest, objective)
				if(quest.PersistentData.RepirationDigestionChoice ~= 2) then
					return BehaviorStatus.FAILED;
				end

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 2;

				local player = Players[quest:GetOwner()];
				local rewards = quest.PersistentData.Rewards;
				
				rewards.Affinity:GiveReward(player, dividedReward);
				rewards.Digestion:GiveReward(player, DIGESTION_PERK_TYPE);

				-- Set reward strings
				local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
				local digestionRewardStrings = rewards.Digestion:GetRewardStrings(DIGESTION_PERK_TYPE);

				quest:SetReward(unpack(affinityRewardStrings), unpack(digestionRewardStrings));

				-- Succeed
				quest:Succeed();

				return BehaviorStatus.IN_PROGRESS;
			end},
		},
	},
}

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)
	return QuestScript.CityNearCanyon(playerType) ~= nil;
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Harmony(),
		Respiration = QuestRewards.PlayerPerk(),
		Digestion = QuestRewards.PlayerPerk()
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


function QuestScript.CityNearCanyon(playerType)

	local canyonType = GameInfo.Terrains["TERRAIN_CANYON"].ID;
	local player = Players[playerType];

	local HexRadius = 2;
	local currentIndex = 0;

	for city in player:Cities() do

		local plotX = city:GetX();
		local plotY = city:GetY();

		for shiftX = -HexRadius, HexRadius, 1 do
			for shiftY = -HexRadius, HexRadius, 1 do

				local candidatePlot = Map.PlotXYWithRangeCheck(plotX, plotY, shiftX, shiftY, HexRadius);

				if(candidatePlot ~= nil and (candidatePlot:GetX() ~= plotX and candidatePlot:GetY() ~= plotY)) then

					if(candidatePlot:IsCanyon()) then

						return city;
					end
				end
			end
		end
	end

	return nil;
end

return QuestScript;