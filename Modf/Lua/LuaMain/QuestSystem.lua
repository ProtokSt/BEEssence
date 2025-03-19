--MGH modified
--@<Name>Echoes of Earth</Name>
--EoE edit
--BUG-1: Fixed copy-paste error that prevented the quest system from loading modded objective scripts
g_constString_mod_name_folder="Expansion3_MOD_PWAC_Essence_Balance";--MGH
g_constString_mod_relative_path_quests=g_constString_mod_name_folder.."\\Modf\\Lua\\LuaQuests";--MGH
g_constString_mod_relative_path_objectives=g_constString_mod_name_folder.."\\Modf\\Lua\\LuaQuests\\QuestObjectives";--MGH
print("MGH:Starting QuestSystem for "..g_constString_mod_name_folder);--MGH
----------------------------------------------------
-- QuestSystem created by Will Miller

include("SerializationUtilities");
include("GameplayUtilities");
include("AffinityQuestManager");
include("StationQuestManager");
include("CovertOpsQuestManager");
include("QuestRewards");
include("FLuaVector");
include("BehaviorTree");

----------------------------------------------------
-- Prototypes
----------------------------------------------------
hstructure CvQuestScriptMeta
	__index : ifunction
end

hstructure CvQuestScript
	proxytable
	meta : CvQuestScriptMeta
	Info : object
	Type : number
	OnInit : ifunction
	OnStart : ifunction
	OnObjectiveComplete : ifunction
	OnComplete : ifunction
	OnRegisterListeners : ifunction
	OnUnregisterListeners : ifunction
	CanDoLandmarkAction : ifunction
	WillFoundFailQuest : ifunction
	WillBuildFailQuest : ifunction
end

----------------------------------------------------
-- Globals
----------------------------------------------------
g_QuestScripts = {};
g_QuestObjectiveScripts = {};
g_PersistentData = {
	QuestScript = {},
	QuestInstance = {},
	ObjectiveInstance = {},
	NextQuestByPlayerType = {},
	LastQuestChapterByPlayerType = {},
	QuestSequencesByPlayer = {},

	-- Storage for managers
	AffinityQuestManagerData = AffinityQuestManager.GetPersistentData(),
	StationQuestManagerData = StationQuestManager.GetPersistentData(),
	CovertOpsQuestManagerData = CovertOpsQuestManager.GetPersistentData(),
};

g_CachedQuestInstances = {};
g_CachedObjectiveInstances = {};

----------------------------------------------------
-- Script-callable API
----------------------------------------------------
function StartQuest(playerType, questType, ...)
	local questScript = GetQuestScript(questType);
	if (questScript == nil) then
		error("Could not start quest.  Unknown quest type: " .. questType);
	end

	-- Early-out if this quest should be ignored
	if (GameInfo.Quests[questType].IgnoredByAI and not Players[playerType]:IsHuman()) then
		return;
	end

	local quest = QUESTS.StartQuest(playerType, questType);
	if( quest ~= nil ) then
		local wrapper = GetQuestWrapper(quest);

		questScript.PersistentData.__PlayersWhoHaveDoneQuest[playerType] = true;

		if (questScript.OnStart ~= nil) then
			questScript.OnStart(wrapper, unpack(arg));
		end

		if (questScript.OnRegisterListeners ~= nil) then
			questScript.OnRegisterListeners(wrapper);
		end
	end

	-- handle quest chains
	local questInfo : object = GameInfo.Quests[questType];
	if(questInfo == nil) then
		error("questInfo was nil.");
	end

	if(questInfo.QuestSetType ~= nil) then
		local questSetInfo = GameInfo.Quest_Sets[questInfo.QuestSetType];
		if(questSetInfo == nil) then
			error("questSetInfo was nil.");
		end

		if(questSetInfo.QuestSequence == true) then
			SetCurrentQuestSequenceForPlayer(playerType, questSetInfo.Type);
			SetLastQuestChapterForPlayer(playerType, questInfo.QuestSetChapter);
		end
	end
end

function DoesQuestMeetPrerequisites(playerType, questType)
	if (GameInfo.Quests[questType].IgnoredByAI and not Players[playerType]:IsHuman()) then
		return false;
	end

	if(IsQuestStartedInBackgroundForPlayer(playerType, questType)) then
		return false;
	end
	
	local questScript = GetQuestScript(questType);

	if (questScript == nil) then
		return false;--MGH:This happen if a quest is discarted --error("Could not find quest script");
	end

	if (questScript.PrerequisitesMet ~= nil) then
		return questScript.PrerequisitesMet(playerType);
	else
		return true;
	end
end

-- used to test quests that rely on start conditions (quests that aren't started immediately, but wait for a specific player action to start)
function QueueQuestStartConditions(playerType, questType)

	local questScript = GetQuestScript(questType);

	if (questScript == nil) then
		error("Could not queue quest start.  Unknown quest type: " .. questType);
	end


	if(questScript.PrerequisitesMet ~= nil) then
		
		local prerequisitsMet = questScript.PrerequisitesMet();

		if(prerequisitsMet == false) then

			error("Quest prerequisits are not met. Canceling quest setup for: " .. questType);

			return;
		end
	end

	if(questScript.QueueStartForPlayer ~= nil) then

		questScript.QueueStartForPlayer(playerType);
	else

		error("Could not queue quest start. No QueueStartForPlayer function found: " .. questType);
	end
end

function PopObjective(quest)
	if( quest ~= nil ) then
		local objectives : object = quest:GetObjectives();
		local lastObjective : object = objectives[#objectives];
		if( lastObjective ~= nil ) then
			local objectiveScript : object = GetObjectiveScript(lastObjective:GetType());

			if( objectiveScript ~= nil ) then
				local wrapper : object = GetObjectiveWrapper(lastObjective);

				if (objectiveScript.OnUnregisterListeners ~= nil) then
					objectiveScript.OnUnregisterListeners(wrapper);
				end
			end
		end

		QUESTS.PopObjective(quest);
	end
end

function AddObjective(quest, objectiveTypeName, ...)
	local objectiveType = GameInfo.QuestObjectives[objectiveTypeName].ID;
	local objectiveScript = GetObjectiveScript(objectiveType);
	local playerType = quest:GetOwner();
	local questType = quest:GetType();

	local objective = QUESTS.AddObjective(quest, objectiveType);
	local wrapper = GetObjectiveWrapper(objective);

	if (objectiveScript.OnRegisterListeners ~= nil) then
		objectiveScript.OnRegisterListeners(wrapper);
	end
	
	if (objectiveScript.OnStart ~= nil) then
		objectiveScript.OnStart(wrapper, unpack(arg));
	end

	if(objective:GetType() ~= GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID) then
		objective:ShowUpdateNotification();
	end

	if(	not Game.IsNetworkMultiPlayer() and
		objectiveType ~= GameInfo.QuestObjectives["QUEST_OBJECTIVE_PROMPT"].ID)
	then
		objective:ShowObjectiveReceivedPopup();
	end

	return wrapper;
end

function IsObjectiveOfType(objective, typeString)
	return objective ~= nil and objective:GetType() == GameInfo.QuestObjectives[typeString].ID;
end

function ShowActionPrompt(objective, summary, message)
	QUESTS.ShowActionPrompt(objective, summary, message);
end

function HasPlayerDoneQuestType(playerType, questType)
	local questScript = GetQuestScript(questType);
	if questScript == nil then print("MGH:questScript == nil: questType="..questType); return false; end --MGH:This happen if a quest is discarted
	return questScript.PersistentData.__PlayersWhoHaveDoneQuest[playerType] ~= nil;
end

function DidPlayerSucceedQuestType(playerType, questType)
	if HasPlayerDoneQuestType(playerType, questType) then
		local quest = Players[playerType]:GetQuest(questType);
		if (quest ~= nil) then
			return quest:DidSucceed();
		end
	end
	return false;
end

function BroadcastVictoryProgressNotification(questOwnerType:number, summary:string, message:string, x:number, y:number)
	for playerType=0,GameDefines.MAX_MAJOR_CIVS - 1, 1 do
		if (playerType ~= questOwnerType) then
			local player = Players[playerType];
			if (player ~= nil and not player:IsMinorCiv() and player:IsEverAlive()) then
				player:AddNotification(NotificationTypes.NOTIFICATION_OTHER_PLAYER_VICTORY_UPDATED, summary, message, x, y, -1);
			end
		end
	end
end

----------------------------------------------------
-- Load scripts
----------------------------------------------------
do
	-- Load objective scripts
	for objectiveInfo in GameInfo.QuestObjectives() do
		repeat
			local path;
			local file;

			-- Check mods first to see if there's a matching scriptname.
			for questObjectiveScript in Modding.GetActivatedModEntryPoints("QuestObjective") do
				--if(questScript.Name == questInfo.ScriptName) then --EOE edit:Original
				if(questObjectiveScript.Name == objectiveInfo.ScriptName) then --EOE edit:Fixed
					local addinFile = Modding.GetEvaluatedFilePath(questObjectiveScript.ModID, questObjectiveScript.Version, questObjectiveScript.File);
					path = addinFile.EvaluatedPath;
					print("MGH:QuestObjective Script loaded (Modding)=" .. tostring(path));--MGH:Print Script loaded
					break;
				end		
			end

			--MGH:Filter to load only the scripts of our interest
			if(objectiveInfo.ScriptName=="ConquerStationQuestObjective") then print("MGH:Discarted objectiveInfo: " .. objectiveInfo.ScriptName .. ".lua"); do break end end
			if(objectiveInfo.ScriptName=="CreateTradeRouteQuestObjective") then print("MGH:Discarted objectiveInfo: " .. objectiveInfo.ScriptName .. ".lua"); do break end end
			if(objectiveInfo.ScriptName=="DestroyStationQuestObjective") then print("MGH:Discarted objectiveInfo: " .. objectiveInfo.ScriptName .. ".lua"); do break end end
			if(objectiveInfo.ScriptName=="HireStationsQuestObjective") then print("MGH:Discarted objectiveInfo: " .. objectiveInfo.ScriptName .. ".lua"); do break end end

			--MGH:Attempt MGH (default explicit Mod path)
			if(path == nil) then
				path = "assets\\DLC\\"..g_constString_mod_relative_path_objectives.."\\" .. objectiveInfo.ScriptName .. ".lua";
			end
			file = loadfile(path);

			--MGH:Attempt XP1
			if(file == nil) then
				path = "assets\\DLC\\Expansion1\\Gameplay\\Lua\\Quests\\QuestObjectives\\" .. objectiveInfo.ScriptName .. ".lua";
			end
			file = loadfile(path);

			--MGH:Attempt Vainilla
			if(file == nil) then
				path = "assets\\Gameplay\\Lua\\Quests\\QuestObjectives\\" .. objectiveInfo.ScriptName .. ".lua";
			end
			file = loadfile(path);

			if(file ~= nil) then
				print("MGH:QuestObjective Script loaded=" .. tostring(path) );--MGH:Print Script loaded
			else
				print("MGH:Could not load QuestObjective Script with path=" .. tostring(path) );
			end

			--local objectiveScript = file();--MGH:Original
			local objectiveScript = nil;
			if(file ~= nil) then
				objectiveScript = file();
			end

			if (objectiveScript ~= nil) then
				-- Add some additional data to the operation table
				objectiveScript.Info = objectiveInfo;

				-- Insert the operation into our global list
				g_QuestObjectiveScripts[objectiveInfo.ID] = objectiveScript;
			else
				error("Invalid objective table");
			end

		until true --MGH:Break filters
	end

	-- Load quest scripts
	for questInfo in GameInfo.Quests() do
		repeat
			local path;
			local file;

			-- Check mods first to see if there's a matching scriptname.
			for questScript in Modding.GetActivatedModEntryPoints("Quest") do
				if(questScript.Name == questInfo.ScriptName) then

					local addinFile = Modding.GetEvaluatedFilePath(questScript.ModID, questScript.Version, questScript.File);
					path = addinFile.EvaluatedPath;
					print("MGH:Quest Script loaded (Modding)=" .. tostring(path));--MGH:Print Script loaded
					break;
				end		
			end

			--MGH:Filter to load only the scripts of our interest
			--Vainilla:
			--if(questInfo.ScriptName=="KillSiegeWormQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end --Maybe remove because too much times the same quest
			if(questInfo.ScriptName=="SolidStateCitizenQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="CapitalGainsStationQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="DogmaticEngineeringQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="FreshSpecimensStationQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="GrowthPotentialStationQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="HostileTakeoverStationQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			--OccupationalHazardsQuest modified for no Stations/Trading
			if(questInfo.ScriptName=="SpawnStationChoiceTemplateQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			--AcclimationQuest modified for no Stations/Trading
			if(questInfo.ScriptName=="AsWithManQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="TradeNetworkQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			--XP1:
			if(questInfo.ScriptName=="APraxisDarklyQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			--AWealthOfLimbsQuest modified for no Stations/Trading
			--GrowthPotentialStationQuest filtered before
			if(questInfo.ScriptName=="NostalgiaTripBQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			--SightingsOfOliviaRossQuest modified for no Stations/Trading
			if(questInfo.ScriptName=="SpawnStationChoiceTemplateQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end --Special
			if(questInfo.ScriptName=="StepanVsTheNewWorldQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			--TheBeatingHeartSocietyQuest modified for no Stations/Trading
			--TheDeathProblemQuest modified for no Stations/Trading
			--AcclimationQuest modified for no Stations/Trading
			if(questInfo.ScriptName=="AsWithManQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			--Not included in Mod:
			if(questInfo.ScriptName=="SolitudeQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="ReturnToSenderQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="HomesickQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="NostalgiaTripAQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="NostalgiaTripBQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="TheDendriteFrontierQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			if(questInfo.ScriptName=="ActionPotentialQuest") then print("MGH:Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			
			--MGH:Attempt MGH (default explicit Mod path)
			if(path == nil) then
				path = "assets\\DLC\\"..g_constString_mod_relative_path_quests.."\\" .. questInfo.ScriptName .. ".lua";
			end
			file = loadfile(path);
			
			--MGH:Disable new changed quests to avoid problems in multiplayer (due to synchronization errors or not work well in multiplayer)
			--if(Game.IsNetworkMultiPlayer() ) then
			if(questInfo.ScriptName ~= "GeneticEntanglementQuest") then
				if(file ~= nil) then print("MGH:MP Discarted questInfo: " .. questInfo.ScriptName .. ".lua"); do break end end
			end

			--MGH:Attempt XP1
			if(file == nil) then
				path = "assets\\DLC\\Expansion1\\Gameplay\\Lua\\Quests\\" .. questInfo.ScriptName .. ".lua";
			end
			file = loadfile(path);

			--MGH:Attempt Vainilla
			if(file == nil) then
				path = "assets\\Gameplay\\Lua\\Quests\\" .. questInfo.ScriptName .. ".lua";
			end
			file = loadfile(path);

			if(file ~= nil) then
				print("MGH:Quest Script loaded=" .. tostring(path) );--MGH:Print Script loaded
			else--EOE edit:Fixed
				print("MGH:Could not load Quest Script with path=" .. tostring(path) );--EOE edit:Fixed
			end
			
			--local questScript = file();--EOE edit:Original
			local questScript = nil;--EOE edit:Fixed
			if(file ~= nil) then--EOE edit:Fixed
				questScript = file();--EOE edit:Fixed
			end--EOE edit:Fixed

			if (questScript ~= nil) then
				-- Add some additional data to the operation table
				questScript.Info = questInfo;
				questScript.Type= questInfo.ID;

				-- Set up the quest script's meta table
				local mt : CvQuestScriptMeta = hmake CvQuestScriptMeta{
					__index = function(table, key)
						if (key == "PersistentData") then
							-- Try to find the persistent data.  If it isn't here, instantiate
							-- a new table.
							local persistentData = g_PersistentData.QuestScript[table.Type];
							if (persistentData == nil) then
								persistentData = {
									__PlayersWhoHaveDoneQuest = {}
								};
								g_PersistentData.QuestScript[table.Type] = persistentData;
							end

							return persistentData;
						end
					end
				};

				setmetatable(questScript, mt);

				-- Insert the operation into our global list
				g_QuestScripts[questInfo.ID] = questScript;

				-- Call init 
				if (questScript.OnInit ~= nil) then
					questScript.OnInit();
				end
			else
				error("Invalid quest table");
			end

		until true --MGH:Break filters
	end
end

----------------------------------------------------
-- Script Access Utilites
----------------------------------------------------
function GetQuestScript(questType)
	return g_QuestScripts[questType];
end

function GetObjectiveScript(objectiveType)
	return g_QuestObjectiveScripts[objectiveType];
end

function GetQuestWrapper(quest)
	local hash = quest:GetHash();
	local wrapper = g_CachedQuestInstances[hash];

	-- If we have a wrapper already, return it.  Otherwise, 
	-- build a new one.
	if (wrapper ~= nil) then
		wrapper.__Quest = quest;
	else
		-- Resolve persistent data
		local persistentData = g_PersistentData.QuestInstance[hash];
		if (persistentData == nil) then
			persistentData = {};
			g_PersistentData.QuestInstance[hash] = persistentData;
		end

		-- Create wrapper
		wrapper = {
			__Quest = quest,
			PersistentData = persistentData,
		};

		local mt = {
			__index = function(table, key)
				return table.__Quest[key];
			end
		};

		setmetatable(wrapper, mt);

		-- Cache
		g_CachedQuestInstances[hash] = wrapper;
	end

	return wrapper;
end

function GetObjectiveWrapper(objective)
	local hash = objective:GetHash();
	local wrapper = g_CachedObjectiveInstances[hash];

	if (wrapper ~= nil) then
		wrapper.__Objective = objective;
	else
		-- Resolve persistent data
		local persistentData = g_PersistentData.ObjectiveInstance[hash];
		if (persistentData == nil) then
			persistentData = {};
			g_PersistentData.ObjectiveInstance[hash] = persistentData;
		end

		-- Create wrapper
		wrapper = {
			__Objective = objective,
			PersistentData = persistentData,
		};

		local mt = {
			__index = function(table, key)
				return table.__Objective[key];
			end
		};

		setmetatable(wrapper, mt);

		-- Cache
		g_CachedObjectiveInstances[hash] = wrapper;
	end

	return wrapper;
end

function CleanupObjectiveInstance(objective)
	local hash = objective:GetHash();

	g_CachedObjectiveInstances[hash] = nil;
	g_PersistentData.ObjectiveInstance[hash] = nil;
end

function CleanupQuestInstance(objective)
	local hash = objective:GetHash();

	g_CachedQuestInstances[hash] = nil;
	g_PersistentData.QuestInstance[hash] = nil;
end

----------------------------------------------------
-- Merge the loaded persistent data into the current
-- persistent data.  This stops new data from being
-- dropped if it wasn't in the save
--
-- Taken from StackOverflow.com
----------------------------------------------------

function RemoveFunctions( tableData )
	for key, val in pairs(tableData) do
		local type = type(val);
		if (type == "function") then
			tableData[key] = nil;
		else
			if (type == "table") then
				RemoveFunctions( val );
			end
		end
	end
end


local merge_task = {}
function MergeTable( orig, new )

	if (new == nil) then
		return;
	end

	merge_task[orig] = new;

	local left = orig;
	while left ~= nil do
		local right = merge_task[left];
		for new_key, new_val in pairs(right) do
			local old_val = left[new_key];
			if old_val == nil then
				left[new_key] = new_val;
			else
				local old_type = type(old_val);
				local new_type = type(new_val);
				if (old_type == "table" and new_type == "table") then
					merge_task[old_val] = new_val;
				else
					left[new_key] = new_val;
				end
			end
		end
		merge_task[left] = nil;
		left = next(merge_task);
	end
end

----------------------------------------------------
-- Native Callbacks
----------------------------------------------------
function OnLoad()
	-- load persistent data
	local loadedData = SerializationUtilities.DeserializeTable(QUESTS.GetScriptPersistentDataBuffer());

	RemoveFunctions(loadedData);

	-- move persistent data to global area.
	MergeTable( g_PersistentData, loadedData );

	-- Clean up.
	merge_task = {};
	loadedData = {};
end

function OnSave()
	QUESTS.SetScriptPersistentDataBuffer(SerializationUtilities.SerializeTable(g_PersistentData));
end

function OnSaveQuest(playerID, questIndex)
end

-- Called before a quest is destroyed
function OnDestroyQuest(playerID, questIndex)
	local quest			= Players[playerID]:GetQuestWithIndex(questIndex);
	local questType		= quest:GetType();
	local wrapper		= GetQuestWrapper(quest);
	local questScript	= GetQuestScript(questType);

	if (questScript.OnUnregisterListeners ~= nil) then
		questScript.OnUnregisterListeners(wrapper);
	end
end

-- Called after a quest has been started
function OnStartedQuest(playerID, questIndex)
end

-- Called after a quest is loaded.
function OnLoadQuest(playerID, questIndex)
	local quest			= Players[playerID]:GetQuestWithIndex(questIndex);
	local questType		= quest:GetType();
	local wrapper		= GetQuestWrapper(quest);
	local questScript	= GetQuestScript(questType);

	if (questScript.OnLoad ~= nil) then
		questScript.OnLoad(wrapper);
	end

	if (questScript.OnRegisterListeners ~= nil) then
		questScript.OnRegisterListeners(wrapper);
	end
end

-- Called before the objective is saved.
function OnSaveObjective(playerID, questIndex, objectiveIndex)
end

-- Called when the objective is loaded.
function OnLoadObjective(playerID, questID, objectiveIndex)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	if (not objective:IsInProgress()) then
		return;
	end

	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());
	if (objectiveScript.OnRegisterListeners ~= nil) then
		objectiveScript.OnRegisterListeners(wrapper);
	end

	if (objectiveScript.OnLoad ~= nil) then
		objectiveScript.OnLoad(wrapper);
	end
end

-- Called when the objective is haulted.  This happens when a quest
-- fails.
function OnObjectiveHaulted(playerID, questID, objectiveIndex)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);
	
	local objectiveScript = GetObjectiveScript(objective:GetType());
	if (objectiveScript.OnUnregisterListeners ~= nil) then
		objectiveScript.OnUnregisterListeners(wrapper);
	end

	CleanupObjectiveInstance(objective);
end

-- Called when the quest completes.
function OnQuestComplete(playerID, questIndex)
	local quest = Players[playerID]:GetQuestWithIndex(questIndex);
	local wrapper = GetQuestWrapper(quest);

	local questScript = GetQuestScript(quest:GetType());
	if (questScript.OnComplete ~= nil) then
		questScript.OnComplete(wrapper);
	end

	if (questScript.OnUnregisterListeners ~= nil) then
		questScript.OnUnregisterListeners(wrapper);
	end

	CleanupQuestInstance(quest);
end

-- Called when the objective is finished (it may have failed)
function OnObjectiveComplete(playerID, questID, objectiveIndex)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local objectiveWrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());
	local questScript = GetQuestScript(objective:GetQuest():GetType());

	if (objectiveScript.OnUnregisterListeners ~= nil) then
		objectiveScript.OnUnregisterListeners(objectiveWrapper);
	end

	if (objectiveWrapper:DidSucceed()) then
		if (questScript.OnObjectiveComplete ~= nil) then
			local questWrapper = GetQuestWrapper(objective:GetQuest());
			questScript.OnObjectiveComplete(questWrapper, objectiveWrapper);
		end
	end

	CleanupObjectiveInstance(objective);
end

-- Called when a quest action has completed
function OnQuestAction(playerID, questID, objectiveIndex, choice)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());

	if (objectiveScript.OnAction ~= nil) then
		objectiveScript.OnAction(wrapper, choice);
	else
		error("Objective doesn't implement OnAction method");
	end
end

function CanDoLandmarkAction(playerID, questIndex, landmarkActionType, plotX, plotY, testVisible)
	local quest = Players[playerID]:GetQuestWithIndex(questIndex);
	local plot = Map.GetPlot(plotX, plotY);
	local wrapper = GetQuestWrapper(quest);
	local questScript = GetQuestScript(quest:GetType());

	if (questScript.CanDoLandmarkAction ~= nil) then
		return questScript.CanDoLandmarkAction(wrapper, landmarkActionType, plot, testVisible);
	else
		-- The default behavior is to return true if the player owns the plot
		-- with the landmark's improvement on it.
		return plot:GetOwner() == quest:GetOwner();
	end
end

function WillFoundFailQuest(plotX, plotY, foundingPlayerID, questIndex, questPlayerID)
	local quest = Players[questPlayerID]:GetQuestWithIndex(questIndex);
	local wrapper = GetQuestWrapper(quest);
	if (wrapper ~= nil) then
		return GameplayUtilities.WillFoundFailQuest(wrapper, plotX, plotY, foundingPlayerID);
	end
	return false;
end

function WillBuildFailQuest(plotX, plotY, buildingPlayerID, buildType, questIndex, questPlayerID)
	local quest = Players[questPlayerID]:GetQuestWithIndex(questIndex);
	local wrapper = GetQuestWrapper(quest);
	if (wrapper ~= nil) then
		return GameplayUtilities.WillBuildFailQuest(wrapper, plotX, plotY, buildType, buildingPlayerID);
	end
	return false;
end

-- AI functions 
function GetUnitAIWeight(playerID, questID, objectiveIndex, unitType)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());

	if (objectiveScript.GetUnitAIWeight ~= nil) then
		return objectiveScript.GetUnitAIWeight(wrapper, unitType);
	else
		return 0;
	end
end

function GetBuildingAIWeight(playerID, questID, objectiveIndex, buildingType)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());

	if (objectiveScript.GetBuildingAIWeight ~= nil) then
		return objectiveScript.GetBuildingAIWeight(wrapper, buildingType);
	else
		return 0;
	end
end

function GetProjectAIWeight(playerID, questID, objectiveIndex, projectType)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());

	if (objectiveScript.GetProjectAIWeight ~= nil) then
		return objectiveScript.GetProjectAIWeight(wrapper, projectType);
	else
		return 0;
	end
end

function GetImprovementAIWeight(playerID, questID, objectiveIndex, improvementType)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());

	if (objectiveScript.GetImprovementAIWeight ~= nil) then
		return objectiveScript.GetImprovementAIWeight(wrapper, improvementType);
	else
		return 0;
	end
end

function GetPolicyAIWeight(playerID, questID, objectiveIndex, policyType)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());

	if (objectiveScript.GetPolicyAIWeight ~= nil) then
		return objectiveScript.GetPolicyAIWeight(wrapper, policyType);
	else
		return 0;
	end
end

function GetTechAIWeight(playerID, questID, objectiveIndex, techType)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());

	if (objectiveScript.GetTechAIWeight ~= nil) then
		return objectiveScript.GetTechAIWeight(wrapper, techType);
	else
		return 0;
	end
end

function GetCovertOperationAIWeight(playerID, questID, objectiveIndex, covertOpType)
	local objective = Players[playerID]:GetQuestWithIndex(questID):GetObjectiveWithIndex(objectiveIndex);
	local wrapper = GetObjectiveWrapper(objective);

	local objectiveScript = GetObjectiveScript(objective:GetType());

	if (objectiveScript.GetCovertOperationAIWeight ~= nil) then
		return objectiveScript.GetCovertOperationAIWeight(wrapper, covertOpType);
	else
		return 0;
	end
end

-- I'm not a fan of this "Next" naming scheme, but we're already using the term "queued quest" for something else. I'll revist this naming issue at a later date.
function GetNextQuestForPlayer(playerType : number)
	return g_PersistentData.NextQuestByPlayerType[playerType];
end

function SetNextQuestForPlayer(playerType : number, questType : number)
	g_PersistentData.NextQuestByPlayerType[playerType] = questType;
end

function ClearNextQuests()
	g_PersistentData.NextQuestByPlayerType = {};
end

function GetQuestTypeBySetChapter(questSetType : string, chapterType : number)
	for info in GameInfo.Quests() do
		if(info.QuestSetType == questSetType and
			info.QuestSetChapter == chapterType)
		then
			return info.ID;
		end
	end

	return nil;
end


function GetLastQuestChapterForPlayer(playerType: number)
	if(playerType == nil) then
		error("player was nil");
	end
	
	if(g_PersistentData.LastQuestChapterByPlayerType[playerType] == nil) then
		g_PersistentData.LastQuestChapterByPlayerType[playerType] = -1;
	end

	return g_PersistentData.LastQuestChapterByPlayerType[playerType];
end

function SetLastQuestChapterForPlayer(playerType: number, lastQuestChapter : number)
	if(playerType == nil) then
		error("player was nil");
	end

	if(lastQuestChapter == nil) then
		error("lastQuestChapter was nil");
	end

	g_PersistentData.LastQuestChapterByPlayerType[playerType] = lastQuestChapter;
end

function GetCurrentQuestSequenceForPlayer(playerType: number)
	return g_PersistentData.QuestSequencesByPlayer[playerType];
end

function SetCurrentQuestSequenceForPlayer(playerType: number, currentQuestSequenceType : string)
	if(playerType == nil) then
		error("player was nil");
	end

	if(currentQuestSequenceType == nil) then
		error("currentQuestSequenceType was nil");
	end

	g_PersistentData.QuestSequencesByPlayer[playerType] = currentQuestSequenceType;
end

function GetNextChapterInQuestSequence(playerType: number, questSequenceType : string)
	if(playerType == nil) then
		error("player was nil");
	end

	if(questSequenceType == nil) then
		error("questSequenceType was nil");
	end

	local lastQuestChapter : number = GetLastQuestChapterForPlayer(playerType);
	if(lastQuestChapter == nil) then
		error("lastQuestChapter was nil");
	end

	local possibleNextChapterQuests : table = {};
	for info in GameInfo.Quests() do
		if(info.QuestSetType == questSequenceType and
			info.QuestSetChapter == lastQuestChapter + 1 and
			DoesQuestMeetPrerequisites(playerType, info.ID) == true)
		then
			table.insert(possibleNextChapterQuests, info.Type);
		end
	end

	-- if this list isn't empty, the quest chain hasn't been completed. Return the next chapter in the sequence
	if(#possibleNextChapterQuests > 0) then
		local questType = possibleNextChapterQuests[Game.Rand(#possibleNextChapterQuests, "Choosing random quest from next chapter candidates") + 1];
		return questType;
	end
end


----------------------------------------------------
-- Tuner data
----------------------------------------------------
g_QuestTunerSettings = {
	PlayerType = -1,
};