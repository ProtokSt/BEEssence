--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Initialization
----------------------------------------------------
function QuestScript.OnInit()

	function QuestScript.OnPlayerDoTurn(playerType)

		if(QuestScript.PersistentData.Completed ~= nil and QuestScript.PersistentData.Completed[playerType] == true) then

			-- start chapter 2
			local questType = GameInfo.Quests["QUEST_SKY_MINE_CHAPTER2"].ID;
			local questScript = GetQuestScript(questType);

			if(questScript.PrerequisitesMet ~= nil and 
				questScript.PrerequisitesMet(playerType) == true) then

				StartQuest(playerType, questScript.Info.ID)

				QuestScript.PersistentData.Completed[playerType] = false;
			end
		end
	end

	GameEvents.PlayerDoTurn.Add(QuestScript.OnPlayerDoTurn);
end

----------------------------------------------------
-- Constants
---------------------------------------------------- 

local BOREHOLE_TYPE = GameInfo.Buildings["BUILDING_BOREHOLE"].ID;
local GENE_GARDEN_TYPE = GameInfo.Buildings["BUILDING_GENE_GARDEN"].ID;

local WORK_BARGE_PERK_TYPE = GameInfo.PlayerPerks["PLAYERPERK_WORK_BARGE_FOOD_FLAT"].ID;

local PURITY_DESCRIPTION = GameInfo.Affinity_Types[AffinityQuestManager.PURITY_TYPE].Description;
local AFFINITY_REWARD = 10;
local ENERGY_REWARD = 50;

local BehaviorTree : CvBehaviorNode = BehaviorTree{

	SequenceNode{

		----------------------------------------------------
		-- Deflect vs. Allow Prompt
		----------------------------------------------------
		ActionNode{function(quest, objective)

			if(quest.PersistentData.HasMadeDeflectAllowChoice == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
				quest.PersistentData.HasMadeDeflectAllowChoice = true;
				quest.PersistentData.DeflectAllowChoice = objective.PersistentData.Choice;

				if(objective.PersistentData.Choice == 1) then

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_CHOICE_DEFLECT_EPILOGUE"));
				else

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_CHOICE_ALLOW_EPILOGUE"));
				end

				return BehaviorStatus.SUCCEEDED;
			end

			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_OBJECTIVE_DEFLECT_ALLOW_PROMPT_SUMMARY"));

			local newObjective = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_OBJECTIVE_DEFLECT_ALLOW_PROMPT_SUMMARY"),
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_CHOICE_DEFLECT"), 
													FlavorTypes = {
													}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_CHOICE_ALLOW"), 
													FlavorTypes = {
													}}
			);


			-- add tooltips
			local rewards = quest.PersistentData.Rewards;

			newObjective:SetPromptTooltipA(rewards.Deflect:GetToolTip(WORK_BARGE_PERK_TYPE));
			newObjective:SetPromptTooltipB(rewards.Allow:GetToolTip());

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Divert vs. Allow Choice
		----------------------------------------------------
		SelectorNode{


			SequenceNode{
	
				----------------------------------------------------
				-- Launch Satellite
				----------------------------------------------------
				ActionNode{function(quest, objective)
					
					if(quest.PersistentData.DeflectAllowChoice ~= 1) then
						return BehaviorStatus.FAILED;
					end

					if (quest.PersistentData.HasLaunchedSatellite == true) then
						return BehaviorStatus.SUCCEEDED;
					end
			
					if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LAUNCH_SATELLITES"].ID) then
						quest.PersistentData.HasLaunchedSatellite = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- Set objective
					local newObjective = AddObjective(quest, "QUEST_OBJECTIVE_LAUNCH_SATELLITES", nil, 1);
					newObjective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_SKY_MINE_OBJECTIVE_OBJECTIVE_LAUNCH_SATELLITE_EPILOGUE"));

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- End Deflect
				----------------------------------------------------
				ActionNode{function(quest, objective)

					-- Give rewards
					local dividedReward = QuestRewards.DefaultQuestReward / 2;

					local rewards = quest.PersistentData.Rewards;
					local player = Players[quest:GetOwner()];

					rewards.Affinity:GiveReward(player, dividedReward);
					rewards.Deflect:GiveReward(player, WORK_BARGE_PERK_TYPE);

					-- Set reward strings
					local affinityRewardStrings = rewards.Affinity:GetRewardStrings(player, dividedReward);
					local deflectRewardStrings = rewards.Deflect:GetRewardStrings(WORK_BARGE_PERK_TYPE);

					quest:SetReward(unpack(affinityRewardStrings), unpack(deflectRewardStrings));

					-- Succeed
					quest:Succeed();

					return BehaviorStatus.IN_PROGRESS;
				end},
			},

			----------------------------------------------------
			-- End Allow
			----------------------------------------------------
			ActionNode{function(quest, objective)

				if(quest.PersistentData.DeflectAllowChoice ~= 2) then
					return BehaviorStatus.FAILED;
				end

				-- Give rewards
				local dividedReward = QuestRewards.DefaultQuestReward / 4;--3

				local rewards = quest.PersistentData.Rewards;
				local player = Players[quest:GetOwner()];

				rewards.Allow:GiveReward(player, dividedReward);

				-- Set reward strings
				local allowRewardStrings = rewards.Allow:GetRewardStrings(player, dividedReward);

				quest:SetReward(unpack(allowRewardStrings));

				-- Succeed
				quest:Succeed();

				-- queue next chapter
				if(QuestScript.PersistentData.Completed == nil) then

					QuestScript.PersistentData.Completed = {};
				end

				QuestScript.PersistentData.Completed[quest:GetOwner()] = true

				return BehaviorStatus.IN_PROGRESS;
			end},
		},
	},
}

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.PrerequisitesMet(playerType)
	return true;
end

local function AddRewards(quest : table, isLoad : boolean)

	local rewards = {};

	if (isLoad) then
		if (quest.PersistentData.Rewards ~= nil and quest.PersistentData.Rewards.AllowName ~= nil) then
			rewards.AllowName = quest.PersistentData.Rewards.AllowName;
		end
	end

	if (rewards.AllowName == nil) then
		rewards.AllowName = QuestRewards.ChooseReward("Energy", "Culture", "CultureEnergy" );
	end

	QuestRewards.AddReward( rewards, "Affinity", "Supremacy" );
	QuestRewards.AddReward( rewards, "Deflect", "PlayerPerk" );
	QuestRewards.AddReward( rewards, "Allow", rewards.AllowName );

	MergeTable(rewards, quest.PersistentData.Rewards);
	quest.PersistentData.Rewards = rewards;
	rewards = {}
end

function QuestScript.OnStart(quest)

	-- find quest reward categories
	AddRewards(quest, false);

	BehaviorTree.Tick(quest, nil);
end

function QuestScript.OnLoad(quest)
	AddRewards(quest, true);
end

function QuestScript.OnObjectiveComplete(quest, objective)
	BehaviorTree.Tick(quest, objective);
end

return QuestScript;