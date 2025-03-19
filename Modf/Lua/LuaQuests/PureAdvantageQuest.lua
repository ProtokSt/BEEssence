--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 

local BUILDING_BIONICS_LAB_TYPE = GameInfo.Buildings["BUILDING_BIONICS_LAB"].ID;

local ENERGY_REWARD = 50;
local CULTURE_REWARD = 50;

local AFFINITY_REWARD = 50;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode {
		----------------------------------------
		-- Build Organ Printers
		----------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltBuildings == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltBuildings = true;
				return BehaviorStatus.SUCCEEDED;
			end

				-- Set the prologue
				quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_PURE_ADVANTAGE_PROLOGUE"));

				-- new objective
				local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_BIONICS_LAB_TYPE, 1);
				newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_PURE_ADVANTAGE_OBJECTIVE_PRIVITIZATION_VS_ENTITLEMENT_PROMPT_SUMMARY"));

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------
		-- Privatization Vs. Entitlement
		----------------------------------------
		ActionNode{function(quest, objective)
			if(quest.PersistentData.HasMadeChoice == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
				quest.PersistentData.HasMadeChoice = true;
				quest.PersistentData.Choice = objective.PersistentData.Choice;

				if(objective.PersistentData.Choice == 1) then

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_PURE_ADVANTAGE_OBJECTIVE_PRIVITIZATION_VS_ENTITLEMENT_PROMPT_CHOICE_PRIVITIZATION_EPILOGUE"));
				else

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_PURE_ADVANTAGE_OBJECTIVE_PRIVITIZATION_VS_ENTITLEMENT_PROMPT_CHOICE_ENTITLEMENT_EPILOGUE"));
				end

				return BehaviorStatus.SUCCEEDED;
			end

			local player = Players[quest:GetOwner()];
			local cityID = objective.PersistentData[1].CityID;
			local city = player:GetCityByID(cityID);
			local cityName = city:GetName();

			quest.PersistentData.cityX = city:GetX();
			quest.PersistentData.cityY = city:GetY();
			quest.PersistentData.CityName = cityName;

			local newObjective = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_PURE_ADVANTAGE_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUEST_PURE_ADVANTAGE_OBJECTIVE_PRIVITIZATION_VS_ENTITLEMENT_PROMPT_SUMMARY"), 
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_PURE_ADVANTAGE_OBJECTIVE_PRIVITIZATION_VS_ENTITLEMENT_PROMPT_CHOICE_PRIVITIZATION"), 
													FlavorTypes = {
														GameInfo.Flavors["FLAVOR_ENERGY"].ID,
													}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_PURE_ADVANTAGE_OBJECTIVE_PRIVITIZATION_VS_ENTITLEMENT_PROMPT_CHOICE_ENTITLEMENT"), 
													FlavorTypes = {
														GameInfo.Flavors["FLAVOR_CULTURE"].ID,
													}}
				);

			-- add tooltips
			local rewards = quest.PersistentData.Rewards;
			newObjective:SetPromptTooltipA(rewards.Energy:GetToolTip());
			newObjective:SetPromptTooltipB(rewards.Culture:GetToolTip());

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Privitzation vs. Entitlement Choice
		----------------------------------------------------
		SelectorNode{

			----------------------------------------
			-- End Privatization
			----------------------------------------
			ActionNode{function(quest, objective)
				if(quest.PersistentData.Choice ~= 1) then
					return BehaviorStatus.FAILED;
				end

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 2;

				local player = Players[quest:GetOwner()];
				local rewards = quest.PersistentData.Rewards;
				
				rewards.Affinity:GiveReward(player, dividedReward);
				rewards.Energy:GiveReward(player, dividedReward);

				-- Set reward strings
				local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
				local energyRewardStrings = rewards.Energy:GetRewardStrings(player, dividedReward);

				quest:SetReward(unpack(affinityRewardStrings), unpack(energyRewardStrings));
				
				-- Succeed!
				quest:Succeed();

				return BehaviorStatus.IN_PROGRESS;
			end},

			----------------------------------------
			-- End Entitlement
			----------------------------------------
			ActionNode{function(quest, objective)
				if(quest.PersistentData.Choice ~= 2) then
					return BehaviorStatus.FAILED;
				end

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 2;

				local player = Players[quest:GetOwner()];
				local rewards = quest.PersistentData.Rewards;
				
				rewards.Affinity:GiveReward(player, dividedReward);
				rewards.Culture:GiveReward(player, dividedReward);

				-- Set reward strings
				local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
				local cultureRewardStrings = rewards.Culture:GetRewardStrings(player, dividedReward);

				quest:SetReward(unpack(affinityRewardStrings), unpack(cultureRewardStrings));
				
				-- Succeed!
				quest:Succeed();

				return BehaviorStatus.IN_PROGRESS;
			end},
		}
	}
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)
		return QuestScript.FindAvailableCity(playerType) ~= nil;
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Purity(),
		Energy = QuestRewards.Energy(),
		Culture = QuestRewards.Science()
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

	local resilinType = GameInfo.Resources["RESOURCE_RESILIN"].ID;
	local planktonType = GameInfo.Resources["RESOURCE_PLANKTON"].ID;
	local capitalCity = player:GetCapitalCity();
	local candidateCity = nil;

	for city in player:Cities() do
		local hasBionicsLab = city:IsHasBuilding(BUILDING_BIONICS_LAB_TYPE);
		local hasResilin = city:IsHasResourceLocal(resilinType);
		local hasPlankton = city:IsHasResourceLocal(planktonType);
		
		if(not hasBionicsLab and city ~= capitalCity) then
			if(hasResilin or hasPlankton) then
				candidateCity = city;
				break;
			end
		end
	end

	return candidateCity;
end

return QuestScript;