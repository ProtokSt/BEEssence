--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local PREVIOUS_CHAPTER_TYPE : number = GameInfo.Quests["QUEST_THE_GENIUS_OF_OLIVIA_ROSS"].ID;
local CAMP_RESCOURCE_TYPE : number = GameInfo.Resources["RESOURCE_AN_ELEMENTAL_FATE_CAVE"].ID;
local ROSS_WEED_ARTIFACT_TYPE : number = GameInfo.Artifacts["ARTIFACT_ROSS_WEED"].ID;
local IDEAL_CAMP_DISTANCE : number = 8;--MGH +/-3
local MIN_CAMP_DISTANCE : number = 8-3;--MGH +/-3
local MAX_CAMP_DISTANCE : number = 8+3;--MGH +/-3


local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		----------------------------------------------------
		-- Build Expedition
		----------------------------------------------------
		ActionNode{function(quest : object, objective : object)
			if (quest.PersistentData.HasBuiltExpedition == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and 
				objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_EXPEDITION"].ID) 
			then
				quest.PersistentData.HasBuiltExpedition = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- find expedition plot
			local cityID : number = quest.PersistentData.City.ID;

			local player : object = Players[quest:GetOwner()];
			if(player == nil) then
				error("player was nil.");
			end

			local city : object = player:GetCityByID(cityID);
			if(city == nil) then
				city = player:GetCapitalCity();
			end

			local expeditionPlot : object = QuestScript.FindExpeditionPlot(quest:GetOwner(), city:GetX(), city:GetY(), MIN_CAMP_DISTANCE, MAX_CAMP_DISTANCE);
			if(expeditionPlot == nil) then
				error("Could not find expedition plot. This should have been caught in the prerequisit check.");
			end

			quest.PersistentData.ExpeditionPlot = {};
			quest.PersistentData.ExpeditionPlot.X = expeditionPlot:GetX();
			quest.PersistentData.ExpeditionPlot.Y = expeditionPlot:GetY();
			
			-- plop expedition resource/improvement
			expeditionPlot:SetResourceType(CAMP_RESCOURCE_TYPE, 1);

			-- watch plot
			local expeditionType = GameDefines["BUILD_EXPEDITION"];
			local playerType = quest:GetOwner();
			GameplayUtilities.AddWatchedPlotToQuest(quest, expeditionPlot:GetX(), expeditionPlot:GetY(), { expeditionType }, { playerType });

			-- set introduction (epilogue for last objective)
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SIGHTINGS_OF_OLIVIA_ROSS_TRADE_WITH_STATION_EPILOGUE", city:GetName()));--MGH:(old:station:GetName())

			-- add new objective
			local expeditionSiteDescription = Locale.ConvertTextKey("TXT_KEY_QUEST_SIGHTINGS_OF_OLIVIA_ROSS_EXPEDITION_SITE_DESCRIPTION");
			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_EXPEDITION", expeditionPlot:GetX(), expeditionPlot:GetY(), expeditionSiteDescription);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest : object, objective : object)

			-- set introduction (epilogue for last objective)
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SIGHTINGS_OF_OLIVIA_ROSS_BUILD_EXPEDITION_EPILOGUE"));

			-- remove resource from expedition plot
			local expeditionPlotData : table = quest.PersistentData.ExpeditionPlot;
			if(expeditionPlotData == nil) then
				error("expeditionPlotData was not in the quest's PersistantData.");
			end

			local expeditionPlot : object = Map.GetPlot(expeditionPlotData.X, expeditionPlotData.Y);
			if(expeditionPlot == nil) then
				error("Could not find plot with expeditionPlotData.");
			end

			expeditionPlot:SetResourceType(-1);

			-- unwatch plot
			GameplayUtilities.RemoveWatchedPlotFromQuest(quest, expeditionPlotData.X, expeditionPlotData.Y);

			-- Give rewards
			local player : object = Players[quest:GetOwner()];
			local rewards : table = quest.PersistentData.Rewards;
			local dividedReward : number = QuestRewards.DefaultQuestReward / 2;

			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.Artifact:GiveReward(player, ROSS_WEED_ARTIFACT_TYPE);

			-- Set reward strings
			local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
			local artifactRewardStrings : table = rewards.Artifact:GetRewardStrings(ROSS_WEED_ARTIFACT_TYPE);

			quest:SetReward(unpack(affinityRewardStrings), unpack(artifactRewardStrings));

			-- Succeed
			quest:Succeed();

			return BehaviorStatus.SUCCEEDED;
		end},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType : number)

	-- get player
	local player : object = Players[playerType];
	if(player == nil) then
		error("player was nil.");
	end

	if(not HasPlayerDoneQuestType(player:GetID(), PREVIOUS_CHAPTER_TYPE)) then
		return false;
	end

	-- get city (attempt to use same city from last quest)
	local city : object = QuestScript.GetPreviousCity(player);
	if(city == nil or
		city:GetOwner() ~= playerType)
	then
		city = QuestScript.FindCity(player);
	end

	local expeditionPlot : object = QuestScript.FindExpeditionPlot(playerType, city:GetX(), city:GetY(), MIN_CAMP_DISTANCE, MAX_CAMP_DISTANCE);
	if(expeditionPlot == nil) then
		return false;
	end

	return true;
end

local function AddRewards(quest : table, isLoad : boolean)

	local rewards = {}
	QuestRewards.AddReward(rewards, "Affinity", "Purity");--MGH
	QuestRewards.AddReward(rewards, "Artifact", "Artifact");

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
-- QuestScript Functionality
---------------------------------------------------- 

function QuestScript.GetPreviousCity(player : object)

	local questScript : object = GetQuestScript(PREVIOUS_CHAPTER_TYPE);
	if(questScript ~= nil and
		questScript.PersistentData.CitiesByPlayer ~= nil and
		questScript.PersistentData.CitiesByPlayer[player:GetID()] ~= nil)
	then
		local cityData : table = questScript.PersistentData.CitiesByPlayer[player:GetID()];
		if(cityData == nil) then
			return nil;
		end
		
		local cityID : number = cityData.ID;
		return player:GetCityByID(cityID);
	end
end

function QuestScript.FindCity(player : object)

	local cities : table = {};

	for city : object in player:Cities() do
		table.insert(cities, city);
	end

	local randomCityIndex = Game.Rand(#cities, "choosing city") + 1;
	return cities[randomCityIndex];
end

function QuestScript.FindExpeditionPlot(playerType, cityX, cityY, minDistance, maxDistance)

	-- find a plot near city between minDistance maxDistance, inside the player's territory
	local minX : number = cityX - maxDistance;
	local maxX : number = cityX + maxDistance;
	local minY : number = cityY - maxDistance;
	local maxY : number = cityY + maxDistance;

	-- gather candidate plots (within maxDistance of the target city, inside the player's territory or unowned, and compatible with the needed resource type)
	local candidatePlots : table = {};
	for x : number = minX, maxX, 1 do
		for y : number = minY, maxY, 1 do
			if(x<=cityX-minDistance or x>=cityX+minDistance)--MGH
				if(y<=cityY-minDistance or y>=cityY+minDistance)--MGH
					local candidatePlot : object = Map.GetPlot(x, y);
					if(candidatePlot ~= nil and
						(candidatePlot:GetOwner() == playerType or not candidatePlot:IsOwned()) and
						candidatePlot:CanHaveResource(CAMP_RESCOURCE_TYPE) and
						candidatePlot:HasImprovement() == false and
						candidatePlot:GetHeroLandmark() == -1)
					then
						table.insert(candidatePlots, candidatePlot);
					end
				end
			end
		end
	end

	-- choose a plot if possible
	if(#candidatePlots > 0) then
		local randomPlotIndex : number = Game.Rand(#candidatePlots, "choosing plot") + 1;
		return candidatePlots[randomPlotIndex];
	end
end

return QuestScript;