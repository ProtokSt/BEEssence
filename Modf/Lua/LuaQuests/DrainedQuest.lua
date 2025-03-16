--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local PREVIOUS_CHAPTER_TYPE : number = GameInfo.Quests["QUEST_CHARGED"].ID;
local BUILDING_ALLOY_FOUNDRY_NUMBER_TO_BUILD : number = 1;--2
local BUILDING_ALLOY_FOUNDRY_TYPE : number = GameInfo.Buildings["BUILDING_ALLOY_FOUNDRY"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		----------------------------------------------------
		-- Choose Between Brothers
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasChosenBetweenBrothers == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
				quest.PersistentData.HasChosenBetweenBrothers = true;
				quest.PersistentData.BrothersChoice = objective.PersistentData.Choice;

				-- add this choice to a table in the quest script, to be used by the following quest in this chain
				if(QuestScript.PersistentData.BrothersChoiceByPlayer == nil) then
					QuestScript.PersistentData.BrothersChoiceByPlayer = {};
				end

				QuestScript.PersistentData.BrothersChoiceByPlayer[quest:GetOwner()] = objective.PersistentData.Choice;

				return BehaviorStatus.SUCCEEDED;
			end

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_BROTHERS_CHOICE_PROMPT_SUMMARY"));

			-- add new objective
			local newObjective = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_BROTHERS_CHOICE_PROMPT_SUMMARY"),
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_BROTHERS_CHOICE_BROTHER_A"), 
													FlavorTypes = {}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_BROTHERS_CHOICE_BROTHER_B"), 
													FlavorTypes = {}}
			);

			-- add tooltips
			local rewards : table = quest.PersistentData.Rewards;
			if(rewards == nil) then
				error("rewards was nil");
			end

			newObjective:SetPromptTooltipA(rewards.Science:GetToolTip());
			newObjective:SetPromptTooltipB(rewards.Culture:GetToolTip());

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Brother's Choice
		----------------------------------------------------
		SelectorNode{
			
			----------------------------------------------------
			-- Choice: Brother A
			----------------------------------------------------
			SequenceNode{

				----------------------------------------------------
				-- Launch Satellites
				----------------------------------------------------
				ActionNode{function(quest : table, objective : table)
					if(quest.PersistentData.BrothersChoice ~= 1) then
						return BehaviorStatus.FAILED;
					end

					if (quest.PersistentData.HasLaunchedSatellites == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_LAUNCH_SATELLITES"].ID) then
						quest.PersistentData.HasLaunchedSatellites = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_BROTHERS_CHOICE_BROTHER_A_EPILOGUE"));

					-- add new objective
					AddObjective(quest, "QUEST_OBJECTIVE_LAUNCH_SATELLITES", nil, 2);

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- End
				----------------------------------------------------
				ActionNode{function(quest : table, objective : table)

					-- set introduction (epilogue for last objective)
					local civName : string = Players[quest:GetOwner()]:GetCivilizationDescription();
					if(civName == nil) then
						error("civName was nil");
					end

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_LAUNCH_SATELLITES_EPILOGUE", civName));

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

					rewards.Affinity:GiveReward(player, dividedReward);
					rewards.Science:GiveReward(player, dividedReward);

					-- Set reward strings
					local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
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
				end},
			},

			----------------------------------------------------
			-- Choice: Brother B
			----------------------------------------------------
			SequenceNode{

				----------------------------------------------------
				-- Build Alloy Foundries
				----------------------------------------------------
				ActionNode{function(quest : table, objective : table)
					if(quest.PersistentData.BrothersChoice ~= 2) then
						return BehaviorStatus.FAILED;
					end

					if (quest.PersistentData.HasBuiltAlloyFoundries == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_BUILDING"].ID) then
						quest.PersistentData.HasBuiltAlloyFoundries = true;
						return BehaviorStatus.SUCCEEDED;
					end

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_BROTHERS_CHOICE_BROTHER_B_EPILOGUE"));

					-- add new objective
					AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_ALLOY_FOUNDRY_TYPE, BUILDING_ALLOY_FOUNDRY_NUMBER_TO_BUILD);

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- End
				----------------------------------------------------
				ActionNode{function(quest : table, objective : table)

					-- set introduction (epilogue for last objective)
					local civName : string = Players[quest:GetOwner()]:GetCivilizationDescription();
					if(civName == nil) then
						error("civName was nil");
					end

					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_DRAINED_BUILD_ALLOY_FOUNDARIES_EPILOGUE"));

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

					rewards.Affinity:GiveReward(player, dividedReward);
					rewards.Culture:GiveReward(player, dividedReward);

					-- Set reward strings
					local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
					if(affinityRewardStrings == nil) then
						error("affinityRewardStrings was nil");
					end

					local cultureRewardStrings : table = rewards.Culture:GetRewardStrings(player, dividedReward);
					if(cultureRewardStrings == nil) then
						error("cultureRewardStrings was nil");
					end

					quest:SetReward(unpack(affinityRewardStrings), unpack(cultureRewardStrings));

					-- Succeed
					quest:Succeed();

					return BehaviorStatus.SUCCEEDED;
				end},
			}
		}
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

	if(not DidPlayerSucceedQuestType(player:GetID(), PREVIOUS_CHAPTER_TYPE)) then
		return false;
	end
	return true;
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Affinity", "Supremacy");
	QuestRewards.AddReward(rewards, "Science", "Science");
	QuestRewards.AddReward(rewards, "Culture", "Culture");

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