--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local BUILDING_NEUROLAB_TYPE = GameInfo.Buildings["BUILDING_NEUROLAB"].ID;

local ENERGY_REWARD = 300;
local PRODUCTION_REWARD = 50;
local UNIT_SETTLER_TYPE = GameInfo.Units["UNIT_SETTLER"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode {

		----------------------------------------
		-- Build NeuroLab
		----------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.BuildNeuroLab == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				
				-- set epilogue
				local cityID : number = quest.PersistentData.City.ID;
				local player : object = Players[quest:GetOwner()];
				local city : object = player:GetCityByID(cityID);

				objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUESTQUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_SPACE_VS_RELOCATION_PROMPT_SUMMARY", city:GetNameKey()));
				
				quest.PersistentData.BuildNeuroLab = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- find city
			local city = QuestScript.FindAvailableCity(quest:GetOwner());

			quest.PersistentData.City = {};
			quest.PersistentData.City.ID = city:GetID();

			-- Set the prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_POINT_OF_NO_RETURN_NULL_PROLOGUE", city:GetNameKey()));

			-- new objective
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_NEUROLAB_TYPE, 1, city:GetID());
			newObjective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_BUILD_NUEROLAB_SUMMARY", city:GetNameKey()));
			

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------
		-- Space vs. New City Prompt
		----------------------------------------
		ActionNode{function(quest, objective)
			if(quest.PersistentData.HasMadeChoice == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
				quest.PersistentData.HasMadeChoice = true;
				quest.PersistentData.Choice = objective.PersistentData.Choice;
				return BehaviorStatus.SUCCEEDED;
			end

			local cityID : number = quest.PersistentData.City.ID;
			local player : object = Players[quest:GetOwner()];
			local city : object = player:GetCityByID(cityID);
			if(city == nil) then
				error("city was nil.");
			end

			-- new objective
			local newObjective = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_POINT_OF_NO_RETURN_NULL_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUESTQUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_SPACE_VS_RELOCATION_PROMPT_SUMMARY", city:GetNameKey()),
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_SPACE_VS_RELOCATION_PROMPT_CHOICE_SPACE"), 
													FlavorTypes = {
														GameInfo.Flavors["FLAVOR_PRODUCTION"].ID,
													}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_SPACE_VS_RELOCATION_PROMPT_CHOICE_RELOCATION"), 
													FlavorTypes = {
														GameInfo.Flavors["FLAVOR_ENERGY"].ID,
													}}
			);

			-- add tooltips
			local rewards = quest.PersistentData.Rewards;
			newObjective:SetPromptTooltipA(rewards.Production:GetToolTip());
			newObjective:SetPromptTooltipB(rewards.Energy:GetToolTip());

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------
		-- Space vs. New City Choice
		----------------------------------------
		SelectorNode{

			SequenceNode {

				----------------------------------------
				-- Launch Orbital Unit
				----------------------------------------
				ActionNode{function(quest, objective)
					if(quest.PersistentData.Choice ~= 1) then
						return BehaviorStatus.FAILED;
					end

					if (quest.PersistentData.HasLaunchedSatellite == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LAUNCH_SATELLITES"].ID) then
						
						-- set epilogue
						local cityID : number = quest.PersistentData.City.ID;
						local player : object = Players[quest:GetOwner()];
						local city : object = player:GetCityByID(cityID);
						if(city == nil) then
							error("city was nil.");
						end

						objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_LAUNCH_ORBITAL_UNIT_EPILOGUE", city:GetNameKey()));
						
						quest.PersistentData.HasLaunchedSatellite = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- set epilogue
					local cityID : number = quest.PersistentData.City.ID;
					local player : object = Players[quest:GetOwner()];
					local city : object = player:GetCityByID(cityID);
					if(city == nil) then
						error("city was nil.");
					end

					-- set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_SPACE_VS_RELOCATION_PROMPT_CHOICE_SPACE_EPILOGUE", city:GetNameKey()));

					-- new objective
					local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_LAUNCH_SATELLITES", nil, 1, city:GetID());
					newObjective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_LAUNCH_ORBITAL_UNIT_SUMMARY", city:GetNameKey()));
					

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------
				-- End Orbital
				----------------------------------------
				ActionNode{function(quest, objective)
					if (quest.PersistentData.HasEndedOrbital == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					-- Give rewards
					local dividedReward = QuestRewards.DefaultQuestReward / 2;

					local cityID : number = quest.PersistentData.City.ID;
					local player = Players[quest:GetOwner()];
					local city : object = player:GetCityByID(cityID);
					if(city == nil) then
						error("city was nil.");
					end

					local rewards = quest.PersistentData.Rewards;
				
					rewards.Affinity:GiveReward(player, dividedReward);
					rewards.Production:GiveReward(city, dividedReward);

					-- Set reward strings
					local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
					local productionRewardStrings = rewards.Production:GetRewardStrings(city, dividedReward);

					quest:SetReward(unpack(affinityRewardStrings), unpack(productionRewardStrings));

					-- Succeed
					quest:Succeed();

					return BehaviorStatus.IN_PROGRESS;
				end},
			},

			SequenceNode {

				----------------------------------------
				-- Relocate City
				----------------------------------------
				ActionNode{function(quest, objective)
					if(quest.PersistentData.Choice ~= 2) then
						return BehaviorStatus.FAILED;
					end

					if (quest.PersistentData.HasBuiltSettler == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_UNITS"].ID) then
						-- set epilogue
						local cityID : number = quest.PersistentData.City.ID;
						local player : object = Players[quest:GetOwner()];
						local city : object = player:GetCityByID(cityID);
						if(city == nil) then
							error("city was nil.");
						end

						objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_RELOCATE_CITY_UNIT_EPILOGUE", city:GetNameKey()));
						
						quest.PersistentData.HasBuiltSettler = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- set epilogue
					local cityID : number = quest.PersistentData.City.ID;
					local player : object = Players[quest:GetOwner()];
					local city : object = player:GetCityByID(cityID);
					if(city == nil) then
						error("city was nil.");
					end

					-- set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_SPACE_VS_RELOCATION_PROMPT_CHOICE_RELOCATION_EPILOGUE", city:GetNameKey()));
					
					-- new objective
					local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_UNITS", UNIT_SETTLER_TYPE, 1, city:GetID());
					newObjective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_QUEST_POINT_OF_NO_RETURN_NULL_OBJECTIVE_RELOCATE_CITY_UNIT_SUMMARY", city:GetNameKey()));

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------
				-- End Relocate
				----------------------------------------
				ActionNode{function(quest, objective)
					if (quest.PersistentData.HasEndedRelocation == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					-- Give rewards
					local dividedReward = QuestRewards.DefaultQuestReward / 2;

					local cityID : number = quest.PersistentData.City.ID;
					local player = Players[quest:GetOwner()];
					local city : object = player:GetCityByID(cityID);
					if(city == nil) then
						error("city was nil.");
					end

					local rewards = quest.PersistentData.Rewards;
				
					-- grab city's plot
					local plot : object = Map.GetPlot(city:GetX(), city:GetY());

					player:Disband(city);

					-- if city was on a water tile, embark all land units that were on that tile
					if(plot:IsWater()) then
						local unitCount : number = plot:GetNumUnits();
						for i : number = 0, unitCount, 1 do
							local unit : object = plot:GetUnit(i);
							if(unit ~= nil) then
								if(unit:GetDomainType() ~= DomainTypes.DOMAIN_SEA) then
									unit:Embark();
								end
							end
						end
					end

					rewards.Affinity:GiveReward(player, dividedReward);
					rewards.Energy:GiveReward(player, dividedReward * 6);

					-- Set reward strings
					local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
					local energyRewardStrings = rewards.Energy:GetRewardStrings(player, dividedReward * 6);

					quest:SetReward(unpack(affinityRewardStrings), unpack(energyRewardStrings));

					-- Succeed!
					quest:Succeed();

					return BehaviorStatus.IN_PROGRESS;
				end},
			},
		},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)

	return QuestScript.FindAvailableCity(playerType) ~= nil;
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Supremacy(),
		Production = QuestRewards.Production(),
		Energy = QuestRewards.Energy(),
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

	local resourceType = GameInfo.Resources["RESOURCE_FIRAXITE"].ID;
	local capitalCity = player:GetCapitalCity();
	local candidateCity = nil;

	for city in player:Cities() do
		local hasNeuroLab = city:IsHasBuilding(BUILDING_NEUROLAB_TYPE);
		local hasFiraxite = city:IsHasResourceLocal(resourceType);
		
		if((not hasNeuroLab) and
		   hasFiraxite and 
		   city ~= capitalCity) then --changed

			candidateCity = city;
			break;
		end
	end

	return candidateCity;
end

return QuestScript;