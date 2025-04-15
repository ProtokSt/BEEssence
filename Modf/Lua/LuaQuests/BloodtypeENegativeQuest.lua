--MGH modified
----------------------------------------------------
-- Globals
----------------------------------------------------
local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
----------------------------------------------------
local PREVIOUS_CHAPTER_TYPE : number = GameInfo.Quests["QUEST_DRAINED"].ID;
local IMPROVEMENT_MANUFACTORY_NUMBER_TO_BUILD : number = 3;--1
local IMPROVEMENT_MANUFACTORY_TYPE : number = GameInfo.Improvements["IMPROVEMENT_MANUFACTORY"].ID;

local BehaviorTree : CvBehaviorNode = BehaviorTree{
	SequenceNode{
		
		----------------------------------------------------
		-- Build Manufactory
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasBuiltManufactory == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_BUILD_IMPROVEMENTS"].ID) then
				quest.PersistentData.HasBuiltManufactory = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- find player's choice in last quest (will be used to choose between prologues)
			local player : table = Players[quest:GetOwner()];
			if(player == nil) then
				error("player was nil");
			end

			local questScript : object = GetQuestScript(PREVIOUS_CHAPTER_TYPE);
			if(questScript == nil) then
				error("questScript was nil!");
			end

			if(questScript.PersistentData.BrothersChoiceByPlayer == nil) then
				error("BrothersChoiceByPlayer table was nil");
			end

			local brothersChoice : number = questScript.PersistentData.BrothersChoiceByPlayer[quest:GetOwner()];
			if(brothersChoice == nil) then
				error("BrothersChoiceByPlayer contains no entry for this player");
			end

			local prologue : string;
			if(brothersChoice == 1) then
				prologue = Locale.ConvertTextKey("TXT_KEY_QUEST_BLOODTYPE_E_NEGATIVE_PROLOGUE_BROTHER_A");
			elseif(brothersChoice == 2) then
				local civName : string = Players[quest:GetOwner()]:GetCivilizationDescription();
				if(civName == nil) then
					error("civName was nil");
				end

				prologue = Locale.ConvertTextKey("TXT_KEY_QUEST_BLOODTYPE_E_NEGATIVE_PROLOGUE_BROTHER_B", civName);
			end

			if(prologue == nil) then
				error("No prologue was set");
			end

			-- Set prologue
			quest:SetPrologue(prologue);

			-- add new objective
			AddObjective(quest, "QUEST_OBJECTIVE_BUILD_IMPROVEMENTS", IMPROVEMENT_MANUFACTORY_TYPE, IMPROVEMENT_MANUFACTORY_NUMBER_TO_BUILD);

			return BehaviorStatus.IN_PROGRESS;
		end},

		----------------------------------------------------
		-- Send Covert Operative To Capital
		----------------------------------------------------
		ActionNode{function(quest : table, objective : table)
			if (quest.PersistentData.HasAssignedOperative == true) then
				return BehaviorStatus.SUCCEEDED;
			end

			if (objective ~= nil and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_ASSIGN_COVERT_AGENT_TO_CITY"].ID) then
				quest.PersistentData.HasAssignedOperative = true;
				return BehaviorStatus.SUCCEEDED;
			end

			-- Set epilogue
			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_BLOODTYPE_E_NEGATIVE_BUILD_MANUFACTORY_EPILOGUE"));

			-- get player's capital city
			local player : table = Players[quest:GetOwner()];
			if(player == nil) then
				error("player was nil");
			end

			local city : object = player:GetCapitalCity();
			if(city == nil) then
				error("city was nil");
			end

			-- add new objective
			AddObjective(quest, "QUEST_OBJECTIVE_ASSIGN_COVERT_AGENT_TO_CITY", city:GetID(), city:GetOwner());

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

			objective:SetEpilogue(Locale.ConvertTextKey("TXT_KEY_QUEST_BLOODTYPE_E_NEGATIVE_ASSIGN_COVERT_OPERATIVE_EPILOGUE"));

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
	QuestRewards.AddReward(rewards, "Energy", "Energy");

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