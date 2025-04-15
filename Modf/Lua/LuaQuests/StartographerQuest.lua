--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local CONTINENTAL_SURVEYOR_TYPE = GameInfo.Spacecraft["SPACECRAFT_SURVEYOR"].ID;

local UNIT_DEEP_SPACE_TELESCOPE_TYPE = GameInfo.Units["UNIT_DEEP_SPACE_TELESCOPE"].ID;
local BUILDING_NEOPLANETARIUM_TYPE = GameInfo.Buildings["BUILDING_NEOPLANETARIUM"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		----------------------------------------------------
		-- Launch Telescope
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasLaunchedTelescope == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set the prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_STARTOGRAPHER_PROLOGUE"));

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LAUNCH_SATELLITES"].ID) then
				quest.PersistentData.HasLaunchedTelescope = true;
				return BehaviorStatus.SUCCEEDED;
			end

			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_LAUNCH_SATELLITES", UNIT_DEEP_SPACE_TELESCOPE_TYPE, 1);
			newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_STARTOGRAPHER_OBJECTIVE_LAUNCH_SATELLITE_EPILOGUE"));

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Build Observatories
		----------------------------------------------------
		ActionNode{function(quest, objective)
			if (quest.PersistentData.HasBuiltObservatory == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
				quest.PersistentData.HasBuiltObservatory = true;

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 2;

				local player = Players[quest:GetOwner()];
				local rewards = quest.PersistentData.Rewards;
				
				local dominantAffinityType = player:GetDominantAffinityType();
				if(dominantAffinityType == -1) then
					dominantAffinityType = Game.Rand(2, "Random affinity type roll") + 1;
				end

				rewards.Affinity:GiveReward(player, dividedReward, dominantAffinityType);
				player:DoRevealContinentOutline();

				-- Set reward strings
				local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward, dominantAffinityType);
				local continentOutlinesRewardString = Locale.ConvertTextKey("TXT_KEY_QUEST_STARTOGRAPHER_CONTINENT_OUTLINES_REWARD");

				quest:SetReward(unpack(affinityRewardStrings), continentOutlinesRewardString);

				quest:Succeed();

				return BehaviorStatus.SUCCEEDED;
			end

			local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_NEOPLANETARIUM_TYPE, 1);
			--newObjective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_STARTOGRAPHER_OBJECTIVE_BUILD_OBSERVATORIES_SUMMARY"));
			newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_STARTOGRAPHER_OBJECTIVE_BUILD_OBSERVATORIES_EPILOGUE"));

			return BehaviorStatus.IN_PROGRESS;
		end},
	},
};

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)

	return Game.GetLoadoutSpacecraft(playerType) ~= CONTINENTAL_SURVEYOR_TYPE;
end

local function AddRewards(quest)

	local rewards = {
		Affinity = QuestRewards.DominantAffinity()
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

return QuestScript;