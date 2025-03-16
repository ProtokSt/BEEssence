--MGH modified
include( "GameplayUtilities" );

local ObjectiveScript = {}

----------------------------------------------------
-- Constants
----------------------------------------------------
local DISCOVERY_PROJECT = GameInfo.Projects["PROJECT_DISCOVER_SIGNAL"];
local DISCOVERY_FROM_EXPEDITION_TABLE = {
	--[GameInfo.Resources["RESOURCE_ALIEN_RUIN"].ID]			= 10, --MGH:Removed
	--[GameInfo.Resources["RESOURCE_ALIEN_RUIN_OCEAN"].ID]		= 10, --MGH:Removed
	[GameInfo.Resources["RESOURCE_SOUNDING_BELL_OCEAN"].ID]		= 30, --MGH:(old:20)
	[GameInfo.Resources["RESOURCE_SUNKEN_SPACECRAFT_OCEAN"].ID] = 20,
};
local DISCOVERY_ORBITAL_UNIT = GameInfo.Units["UNIT_DEEP_SPACE_TELESCOPE"];
local DISCOVER_FROM_ORBITAL_UNIT_TURNS = 200;--10
local PIECES_TO_COMPLETE = 2;

----------------------------------------------------
-- Callbacks
----------------------------------------------------
function ObjectiveScript.OnStart(objective)
	objective.PersistentData.TurnTimer = 0;
	objective.PersistentData.HasStartedTimer = false;
	objective.PersistentData.PiecesFound = 0;
	objective.PersistentData.HasFoundPiece = false;

	ObjectiveScript.SetSummary(objective);
end

function ObjectiveScript.OnRegisterListeners(objective)
	-- A piece can be randomly completed by a Progenitor Ruin expedition
	function objective.OnBuildFinished(playerType, buildX, buildY, improvementType, buildType, removedResourceType)
		if (objective:GetOwner() == playerType) then
			if (buildType == GameDefines["BUILD_EXPEDITION"]) then
				if (not objective.PersistentData.HasFoundPiece) then
					for id : number, chance : number in pairs(DISCOVERY_FROM_EXPEDITION_TABLE) do
						if (removedResourceType == id) then
							-- AI players have higher chance of finding signal pieces
							if (Players[playerType]:IsHuman() == false) then
								chance = chance * 2;--3
							end
							local roll : number = Game.Rand(100, "Chance to gain Signal piece from Expedition");
							if (roll < chance) then
								ObjectiveScript.OnPieceCompleted(objective)
								objective.PersistentData.HasFoundPiece = true;
								local player = Players[playerType];
								player:SetContactPieceFound(true);
							end
						end
					end
				end
			end
		end
	end
	GameEvents.BuildFinished.Add(objective.OnBuildFinished);

	-- A piece can be completed by building a special project
	function objective.OnProjectProcessed(playerType, projectType, plotIndex)
		if (objective:GetOwner() == playerType and projectType == DISCOVERY_PROJECT.ID) then
			ObjectiveScript.OnPieceCompleted(objective)
		end
	end
	GameEvents.ProjectProcessed.Add(objective.OnProjectProcessed);

	-- A countdown to piece complete can be started by an orbital unit
	function objective.OnOrbitalUnitLaunched(playerType, unitType, plotX, plotY)
		if (objective:GetOwner() == playerType and 
			unitType == DISCOVERY_ORBITAL_UNIT.ID and 
			objective.PersistentData.HasStartedTimer == false) 
		then
			objective.PersistentData.HasStartedTimer = true;
			objective.PersistentData.TurnTimer = 0;
		end
	end
	GameEvents.OrbitalUnitLaunched.Add(objective.OnOrbitalUnitLaunched);

	-- If we're counting down, we care about the turn
	function objective.OnPlayerDoTurn(playerType)
		if (playerType == objective:GetOwner() and objective.PersistentData.HasStartedTimer) then
			objective.PersistentData.TurnTimer = objective.PersistentData.TurnTimer + 1;
			if (objective.PersistentData.TurnTimer > DISCOVER_FROM_ORBITAL_UNIT_TURNS) then
				ObjectiveScript.OnPieceCompleted(objective)
			end
		end
	end
	GameEvents.PlayerDoTurn.Add(objective.OnPlayerDoTurn);
end

function ObjectiveScript.OnUnregisterListeners(objective)
--	GameEvents.PlayerExploredGoody.Remove(objective.OnPlayerExploredGoody);
	GameEvents.ProjectProcessed.Remove(objective.OnProjectProcessed);
	GameEvents.OrbitalUnitLaunched.Remove(objective.OnOrbitalUnitLaunched);
	GameEvents.PlayerDoTurn.Remove(objective.OnPlayerDoTurn);
end

function ObjectiveScript.GetUnitAIWeight(objective, unitType)
	if (objective.PersistentData.UnitType ~= -1) then
		if (unitType == DISCOVERY_ORBITAL_UNIT.ID) then
			return 1;
		end
	end

	return 0;
end

function ObjectiveScript.GetTechAIWeight(objective, techType)
	if (techType == GameplayUtilities.GetProjectPrereqTechID(DISCOVERY_PROJECT)) then
		return 1;
	end
	if (techType == GameplayUtilities.GetUnitPrereqTechID(DISCOVERY_ORBITAL_UNIT)) then
		return 1;
	end

	return 0;
end

function ObjectiveScript.OnPieceCompleted(objective)

	if(objective.PersistentData.PiecesFound == nil) then
		objective.PersistentData.PiecesFound = 0;
	end
	objective.PersistentData.PiecesFound = objective.PersistentData.PiecesFound + 1;

	-- Update summary
	ObjectiveScript.SetSummary(objective);

	-- Check completion
	if (objective.PersistentData.PiecesFound >= PIECES_TO_COMPLETE) then
		objective:Succeed();
	end
end

function ObjectiveScript.SetSummary(objective)
	objective:SetSummary(Locale.ConvertTextKey("TXT_KEY_QUEST_VICTORY_CONTACT_SIGNAL", objective.PersistentData.PiecesFound, PIECES_TO_COMPLETE));
end

return ObjectiveScript;