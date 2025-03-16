--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local PREVIOUS_CHAPTER_TYPE : number = GameInfo.Quests["QUEST_THE_LONELY_REVOLUTION"].ID;
local MARINE_TYPE : number = GameInfo.Units["UNIT_MARINE"].ID;
local BUILDING_BIOGLASS_FURNACE_TYPE : number = GameInfo.Buildings["BUILDING_BIOGLASS_FURNACE"].ID;
local BUILDING_FEEDSITE_HUB_TYPE : number = GameInfo.Buildings["BUILDING_FEEDSITE_HUB"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{

		----------------------------------------------------
		-- Build Marine In Capital
		----------------------------------------------------
		ActionNode{function(quest : object, objective : object)
			if (quest.PersistentData.HasBuiltMarine == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_UNITS"].ID) then
				quest.PersistentData.HasBuiltMarine = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set prologue
			quest:SetPrologue(Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_PROLOGUE"));

			-- find Capital
			local player : object = Players[quest:GetOwner()];
			if(player == nil) then
				error("player was nil");
			end

			local city : object = player:GetCapitalCity();
			if(city == nil) then
				error("city was nil");
			end

			-- add new objective
			local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_UNITS", nil, 1, city:GetID());

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Regulation vs. Subsidy Prompt
		----------------------------------------------------
		ActionNode{function(quest : object, objective : object)

			if(quest.PersistentData.HasMadeRegulateSubsidizeChoice == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if(objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
				quest.PersistentData.HasMadeRegulateSubsidizeChoice = true;
				quest.PersistentData.RegulateSubsidizeChoice = objective.PersistentData.Choice;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set epilogue
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_REGULATE_SUBSIDIZE_CHOICE_SUMMARY"));

			local newObjective : object = AddObjective(
				quest, 
				"QUEST_OBJECTIVE_PROMPT",
				Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_DESCRIPTION"),
				Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_REGULATE_SUBSIDIZE_CHOICE_SUMMARY"),
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_REGULATE_CHOICE"), 
													FlavorTypes = {
													
													}},
				hmake CvQuestPromptObjectiveOption{	Text = Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_SUBSIDIZE_CHOICE"), 
													FlavorTypes = {
													
													}}
			);

			-- add tooltips
			local rewards : table = quest.PersistentData.Rewards;
			newObjective:SetPromptTooltipA(rewards.Culture:GetToolTip());
			newObjective:SetPromptTooltipB(rewards.Energy:GetToolTip());

			-- set prompt image
			newObjective:SetPromptImagePath(GameplayUtilities.PromptImageAffinity);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Regulation vs. Subsidy Choice
		----------------------------------------------------
		SelectorNode{
			
			----------------------------------------------------
			-- Regulation Choice
			----------------------------------------------------
			SequenceNode{

				----------------------------------------------------
				-- Build Academies
				----------------------------------------------------
				ActionNode{function(quest : object, objective : object)
					if(quest.PersistentData.RegulateSubsidizeChoice ~= 1) then
						return BehaviorStatus.FAILED;
					end
					
					if (quest.PersistentData.HasBuiltAcademiesRegulation == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					quest.PersistentData.HasBuiltAcademiesRegulation = true;

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_REGULATE_CHOICE_EPILOGUE"));

					-- add new objective
					local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_BIOGLASS_FURNACE_TYPE, 1);

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- End Regulation
				----------------------------------------------------
				ActionNode{function(quest : object, objective : object)

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_BUILD_ACADEMIES_REGULATION_EPILOGUE"));

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
			},

			----------------------------------------------------
			-- Subsidy Choice
			----------------------------------------------------
			SequenceNode{

				----------------------------------------------------
				-- Build Academies
				----------------------------------------------------
				ActionNode{function(quest : object, objective : object)
					if(quest.PersistentData.RegulateSubsidizeChoice ~= 2) then
						return BehaviorStatus.FAILED;
					end
					
					if (quest.PersistentData.HasBuiltAcademiesSubsidy == true) then
						return BehaviorStatus.SUCCEEDED;
					end

					quest.PersistentData.HasBuiltAcademiesSubsidy = true;

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_SUBSIDIZE_CHOICE_EPILOGUE"));

					-- add new objective
					local newObjective : object = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_BUILDING", BUILDING_FEEDSITE_HUB_TYPE, 2);

					return BehaviorStatus.IN_PROGRESS;
				end},

				----------------------------------------------------
				-- End Subsidy
				----------------------------------------------------
				ActionNode{function(quest : table, objective : table)

					-- Set epilogue
					objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_PAY_DAY_BUILD_ACADEMIES_SUBSIDY_EPILOGUE"));

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
					rewards.Energy:GiveReward(player, dividedReward);

					-- Set reward strings
					local affinityRewardStrings : table = rewards.Affinity:GetRewardStrings(player, dividedReward);
					if(affinityRewardStrings == nil) then
						error("affinityRewardStrings was nil");
					end

					local energyRewardStrings : table = rewards.Energy:GetRewardStrings(player, dividedReward);
					if(energyRewardStrings == nil) then
						error("energyRewardStrings was nil");
					end

					quest:SetReward(unpack(affinityRewardStrings), unpack(energyRewardStrings));

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
	local player : table = Players[playerType];
	if(player == nil) then
		error("player was nil");
	end

	return DidPlayerSucceedQuestType(player:GetID(), PREVIOUS_CHAPTER_TYPE)
end

local function AddRewards(quest : table, isLoad : boolean)
	local rewards : table = {}
	QuestRewards.AddReward(rewards, "Affinity", "Supremacy");
	QuestRewards.AddReward(rewards, "Energy", "Energy");
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