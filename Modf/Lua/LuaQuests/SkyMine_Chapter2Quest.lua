--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local PURITY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.PURITY_TYPE].Description;
local AFFINITY_REWARD = 10;
local PRODUCTION_REWARD = 10;

local FIRAXITE_TYPE = GameInfo.Resources["RESOURCE_FIRAXITE"].ID;

local CRASHED_SATELLITE_TYPE = GameInfo.Resources["RESOURCE_CRASHED_SATELLITE"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{
	
		----------------------------------------------------
		-- Build Expedition at Crash Site
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltExpedition == true) then
				return BehaviorStatus.SUCCEEDED;
			end
			
			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_EXPEDITION"].ID) then
				quest.PersistentData.HasBuiltExpedition = true;
				return BehaviorStatus.SUCCEEDED;
			end

				-- Set the prologue
				quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_CHAPTER2_PROLOGUE"));

				-- find crash site
				local crashSite = QuestScript.CrashSitePlot(quest:GetOwner());
				quest.PersistentData.CrashSite = {
					X = crashSite:GetX();
					Y = crashSite:GetY();
				}

				-- objective
				local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_EXPEDITION", crashSite:GetX(),  crashSite:GetY(), "TXT_KEY_QUEST_SKY_MINE_CHAPTER2_IMPACT_CRATER");
				newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_CHAPTER2_OBJECTIVE_BUILD_EXPEDITION_EPILOGUE"));

				-- drop the spaceship on it
				Game.DoMeteor(crashSite:GetX(), crashSite:GetY(), CRASHED_SATELLITE_TYPE);

				-- watch crash site
				local expeditionType = GameDefines["BUILD_EXPEDITION"];
				local playerType = quest:GetOwner();
				GameplayUtilities.AddWatchedPlotToQuest(quest, crashSite:GetX(), crashSite:GetY(), { expeditionType }, { playerType });

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- End
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasEnded == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			-- unwatch plot
			local crashSite = quest.PersistentData.CrashSite;
			GameplayUtilities.RemoveWatchedPlotFromQuest(quest, crashSite.X, crashSite.Y);
			
			-- add firaxite to tile
			local plot = Map.GetPlot(crashSite.X, crashSite.Y);

			plot:ClearImprovementType();
			plot:SetResourceType(-1);
			local firaxiteToDrop = 2;--Game.Rand(3, "Rolling to recieve firaxite");
			plot:SetResourceType(FIRAXITE_TYPE, firaxiteToDrop);
			plot:ChangeNumResource(firaxiteToDrop);--MGH

			-- Give rewards
			local dividedReward = QuestRewards.DefaultQuestReward / 4;--3

			local player = Players[quest:GetOwner()];
			local rewards = quest.PersistentData.Rewards;
				
			rewards.Affinity:GiveReward(player, dividedReward);
			rewards.ProductionAllCities:GiveReward(player, dividedReward);

			-- Set reward strings
			local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
			local productionAllCitiesRewardStrings = rewards.ProductionAllCities:GetRewardStrings(player, dividedReward);

			quest:SetReward(unpack(affinityRewardStrings), unpack(productionAllCitiesRewardStrings));

			-- Succeed
			quest:Succeed();

			return BehaviorStatus.IN_PROGRESS;
		end},
	},
}

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)

	return QuestScript.CrashSitePlot(playerType) ~= nil;
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.Supremacy(),
		ProductionAllCities = QuestRewards.ProductionAllCities()
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


function QuestScript.CrashSitePlot(playerType)

	local player = Player[playerType];
	local forestType = GameInfo.Features["FEATURE_FOREST"].ID;
	
	for i = 0, Map.GetNumPlots() - 1 do

		local plot = Map.GetPlotByIndex(i);

		if(plot:GetOwner() == playerType and
			plot:CanHaveFeature(forestType) == true and
			plot:CanHaveResource(CRASHED_SATELLITE_TYPE, false) == true and
			plot:HasImprovement() == false)
		then

			return plot;
		end
	end

	return nil;
end

return QuestScript;