local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Definitions
----------------------------------------------------
hstructure BuildingChoiceStruct
	ID : number
	Text : string
	Epilogue : string
	Flavor : number
	RewardPerkType : string
end

hstructure BuildingQuestStruct
	TitleTextKey : string
	BodyTextKey : string
	SummaryTextKey : string
	ChoiceA : BuildingChoiceStruct
	ChoiceB : BuildingChoiceStruct
end

----------------------------------------------------
-- Locals (constants)
----------------------------------------------------
local TRIGGER_CHANCE = 5;
local VARIANT_SUFFIX : string = "_VARIANT_B";

local BUILDING_CHOICES_TABLE = {};

--BUILDING_CLINIC
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_CLINIC"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_CLINIC",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_CLINIC_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_CLINIC_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_CLINIC_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_CLINIC_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_CITY_DEFENSE"].ID,
		RewardPerkType = "PLAYERPERK_MGH_CLINICS_A";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_CLINIC_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_CLINIC_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_HEALTH"].ID,
		RewardPerkType = "PLAYERPERK_MGH_CLINICS_B";
	}
}
--BUILDING_DEPOT
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_DEPOT"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_DEPOT",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_DEPOT_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_DEPOT_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_DEPOT_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_DEPOT_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_PRODUCTION"].ID,
		RewardPerkType = "PLAYERPERK_DEPOTS_PRODUCTION_FLAT";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_DEPOT_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_DEPOT_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_I_LAND_TRADE_ROUTE"].ID,
		RewardPerkType = "PLAYERPERK_MGH_DEPOTS_B";
	}
}
--BUILDING_ULTRASONIC_FENCE
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_ULTRASONIC_FENCE"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_ULTRASONIC_FENCE",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_ULTRASONIC_FENCE_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_ULTRASONIC_FENCE_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_ULTRASONIC_FENCE_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_ULTRASONIC_FENCE_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_CITY_DEFENSE"].ID,
		RewardPerkType = "PLAYERPERK_ULTRASONIC_FENCES_REPEL_RANGE";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_ULTRASONIC_FENCE_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_ULTRASONIC_FENCE_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_EXPANSION"].ID,
		RewardPerkType = "PLAYERPERK_TRADERS_IMMUNE_TO_ALIENS";
	}
}
--BUILDING_COMMAND_CENTER
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_COMMAND_CENTER"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_COMMAND_CENTER",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_COMMAND_CENTER_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_COMMAND_CENTER_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_COMMAND_CENTER_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_COMMAND_CENTER_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_CITY_DEFENSE"].ID,
		RewardPerkType = "PLAYERPERK_SURVEILLANCE_WEB_SPY_LEVELING";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_COMMAND_CENTER_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_COMMAND_CENTER_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_ESPIONAGE"].ID,
		RewardPerkType = "PLAYERPERK_COMMAND_CENTERS_SPIES";
	}
}
--BUILDING_SPY_AGENCY
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_SPY_AGENCY"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_VIVARIUM",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_VIVARIUM_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_VIVARIUM_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_VIVARIUM_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_VIVARIUM_CHOICE_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_SCIENCE"].ID,
		RewardPerkType = "PLAYERPERK_MGH_SPY_AGENCY_A";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_VIVARIUM_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_VIVARIUM_CHOICE_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_GROWTH"].ID,
		RewardPerkType = "PLAYERPERK_MGH_SPY_AGENCY_B";		
	}
}
--BUILDING_ALIEN_PRESERVE
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_ALIEN_PRESERVE"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_ALIEN_PRESERVE",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_ALIEN_PRESERVE_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_ALIEN_PRESERVE_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_ALIEN_PRESERVE_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_ALIEN_PRESERVE_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_DEFENSE"].ID,
		RewardPerkType = "PLAYERPERK_MGH_ALIEN_PRESERVES_A";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_ALIEN_PRESERVE_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_ALIEN_PRESERVE_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_CITY_DEFENSE"].ID,
		RewardPerkType = "PLAYERPERK_MGH_ALIEN_PRESERVES_B";
	}
}
--BUILDING_SURVEILLANCE_WEB
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_SURVEILLANCE_WEB"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_SURVEILLANCE_WEB",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_SURVEILLANCE_WEB_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_SURVEILLANCE_WEB_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_SURVEILLANCE_WEB_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_SURVEILLANCE_WEB_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_ESPIONAGE"].ID,
		RewardPerkType = "PLAYERPERK_MGH_SURVEILLANCE_WEB_A";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_SURVEILLANCE_WEB_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_SURVEILLANCE_WEB_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_CITY_DEFENSE"].ID,
		RewardPerkType = "PLAYERPERK_MGH_SURVEILLANCE_WEB_B";
	}
}
--BUILDING_XENO_SANCTUARY
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_XENO_SANCTUARY"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_XENO_SANCTUARY",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_XENO_SANCTUARY_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_XENO_SANCTUARY_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_XENO_SANCTUARY_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_XENO_SANCTUARY_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_CULTURE"].ID,
		RewardPerkType = "PLAYERPERK_CIVIL_CRECHES_WORKER_SPEED";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_XENO_SANCTUARY_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_XENO_SANCTUARY_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_GROWTH"].ID,
		RewardPerkType = "PLAYERPERK_MICROBIAL_MINES_HARMONY_LVL_SCIENCE";
	}
}
--BUILDING_SKYCRANE
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_SKYCRANE"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_SKYCRANE",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_SKYCRANE_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_SKYCRANE_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_SKYCRANE_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_SKYCRANE_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_PRODUCTION"].ID,
		RewardPerkType = "PLAYERPERK_FEEDSITE_HUBS_WORKER_SPEED";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_SKYCRANE_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_SKYCRANE_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_TILE_IMPROVEMENT"].ID,
		RewardPerkType = "PLAYERPERK_MANTLES_PURITY_LVL_SCIENCE";
	}
}
--BUILDING_HYPERCORE
BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_HYPERCORE"].ID] = hmake BuildingQuestStruct {
	TitleTextKey = "TXT_KEY_QUEST_BUILDING_HYPERCORE",
	BodyTextKey = "TXT_KEY_QUEST_BUILDING_HYPERCORE_BODY",
	SummaryTextKey = "TXT_KEY_QUEST_BUILDING_HYPERCORE_SUMMARY",
	ChoiceA = hmake BuildingChoiceStruct {
		ID = 1,
		Text = "TXT_KEY_QUEST_BUILDING_HYPERCORE_CHOICE_A",
		Epilogue = "TXT_KEY_QUEST_BUILDING_HYPERCORE_EPILOGUE_A";
		Flavor = GameInfo.Flavors["FLAVOR_SCIENCE"].ID,
		RewardPerkType = "PLAYERPERK_RECYCLERS_WORKER_SPEED";
	},
	ChoiceB = hmake BuildingChoiceStruct {
		ID = 2,
		Text = "TXT_KEY_QUEST_BUILDING_HYPERCORE_CHOICE_B",
		Epilogue = "TXT_KEY_QUEST_BUILDING_HYPERCORE_EPILOGUE_B";
		Flavor = GameInfo.Flavors["FLAVOR_CULTURE"].ID,
		RewardPerkType = "PLAYERPERK_HYPERCORES_SUPREMACY_LVL_SCIENCE";
	}
}
--TEMPLATE
--BUILDING_CHOICES_TABLE[GameInfo.Buildings["BUILDING_X"].ID] = hmake BuildingQuestStruct {
	--TitleTextKey = "TXT_KEY_QUEST_BUILDING_X",
	--BodyTextKey = "TXT_KEY_QUEST_BUILDING_X_BODY",
	--SummaryTextKey = "TXT_KEY_QUEST_BUILDING_X_SUMMARY",
	--ChoiceA = hmake BuildingChoiceStruct {
		--ID = 1,
		--Text = "TXT_KEY_QUEST_BUILDING_X_CHOICE_A",
		--Epilogue = "TXT_KEY_QUEST_BUILDING_X_EPILOGUE_A";
		--Flavor = GameInfo.Flavors[""].ID,
		--RewardPerkType = "";
	--},
	--ChoiceB = hmake BuildingChoiceStruct {
		--ID = 2,
		--Text = "TXT_KEY_QUEST_BUILDING_X_CHOICE_B",
		--Epilogue = "TXT_KEY_QUEST_BUILDING_X_EPILOGUE_B";
		--Flavor = GameInfo.Flavors[""].ID,
		--RewardPerkType = "";
	--}
--}

------------------------------------------------------
-- Game Events
------------------------------------------------------ 
-- Building Processed
function QuestScript.OnBuildingProcessed(playerID, buildingID, cityID, buildingAdded)
	print("BUILDINGCHOICE->QuestScript.OnBuildingProcessed playerID="..playerID.." buildingID="..buildingID);--MGH
	if QuestScript.PersistentData.PlayerTriggerTables[playerID] ~= nil then
		local buildTableData = nil;
		for buildingTableID, buildingTableRow in ipairs(QuestScript.PersistentData.PlayerTriggerTables[playerID]) do
			if(buildingTableRow.BuildingID == buildingID) then
				buildTableData = buildingTableRow;
				break;
			end
		end

		if buildTableData ~= nil then
			-- data already exists, increment or decrement depending on whether the building is being added or removed
			if buildingAdded then
				buildTableData.TriggerChance = buildTableData.TriggerChance + TRIGGER_CHANCE;
			else
				buildTableData.TriggerChance = buildTableData.TriggerChance - TRIGGER_CHANCE;
			end
		else
			-- first building of its class, set base table data
			local newTableData = {};
			newTableData.TriggerChance = TRIGGER_CHANCE;
			newTableData.QuestStarted = false;
			newTableData.BuildingID = buildingID;
			table.insert(QuestScript.PersistentData.PlayerTriggerTables[playerID], newTableData);
		end
	else
		-- no player table for some reason
		error(string.format("No table for player %s in PlayerTriggerTables", playerID));
	end
end
GameEvents.BuildingProcessed.Add(QuestScript.OnBuildingProcessed);

-- Active Player Turn Start
function QuestScript.OnPlayerDoTurn(playerID)
	--print("QuestScript.OnPlayerDoTurn player " .. playerID);

	if QuestScript.PersistentData.PlayerTriggerTables[playerID] ~= nil then
		for i, buildingTable in ipairs(QuestScript.PersistentData.PlayerTriggerTables[playerID]) do

			-- Only check buildings that have entries in the BUILDING_CHOICES_TABLE
			if BUILDING_CHOICES_TABLE[buildingTable.BuildingID] ~= nil then

				if buildingTable.QuestStarted == false and buildingTable.TriggerChance > 0 then

					print("BUILDINGCHOICE->Rolling to start quest for Building: " .. tostring(GameInfo.Buildings[buildingTable.BuildingID].Type));--MGH
					local roll = Game.Rand(100, "Building Quest Trigger: player " .. playerID .. " BuildID " .. buildingTable.BuildingID);
					if (roll <= buildingTable.TriggerChance) then
						buildingTable.QuestStarted = true;	
						StartQuest(playerID, QuestScript.Info.ID, buildingTable.BuildingID);
						return;
					end
				end
			end
		end
	end
end
GameEvents.PlayerDoTurn.Add(QuestScript.OnPlayerDoTurn);

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.OnInit()
	print("BUILDINGCHOICE->QuestScript.OnInit");--MGH
	-- Init player-level trigger table
	QuestScript.PersistentData.PlayerTriggerTables = {};

	for playerType = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
		-- Init sub-table for building classes
		QuestScript.PersistentData.PlayerTriggerTables[playerType] = {};
	end
end

function QuestScript.OnStart(quest, buildingID)
	print("BUILDINGCHOICE->QuestScript.OnStart buildingID="..buildingID);--MGH
	local choiceTable = BUILDING_CHOICES_TABLE[buildingID];
	if choiceTable == nil then
		error(string.format("Choice table not found for Building Choice quest for building ID %s", buildingID));
		return;
	end

	-- Always roll for variant because localization results can vary based on .ini settings
	-- and we don't want that to desync multiplayer games.
	local roll : number = Game.Rand(2, "choose building quest variant");

	quest.PersistentData.UseVariant = false;
	local variantTitleKey : string = choiceTable.TitleTextKey .. VARIANT_SUFFIX;
	-- Ensure valid varian text exists (using title as test case) before rolling to use variants
	if (Locale.Lookup(variantTitleKey) ~= variantTitleKey) then
		if(roll == 1) then
			quest.PersistentData.UseVariant = true;
		end		
	end	
	
	quest.PersistentData.BuildingID = buildingID;

	-- set up text keys
	local titleTextKey : string = choiceTable.TitleTextKey;
	local bodTextKey : string = choiceTable.BodyTextKey;
	local choiceAText : string = choiceTable.ChoiceA.Text;
	local choiceBText : string = choiceTable.ChoiceB.Text;

	if(quest.PersistentData.UseVariant) then
		titleTextKey = titleTextKey .. VARIANT_SUFFIX;
		bodTextKey = bodTextKey .. VARIANT_SUFFIX;
		choiceAText = choiceAText .. VARIANT_SUFFIX;
		choiceBText = choiceBText .. VARIANT_SUFFIX;
	end

	-- Set name override
	local titleText = Locale.Lookup(titleTextKey);
	quest:SetNameOverride(titleText);

	-- Set the prologue
	local bodyText = Locale.Lookup(bodTextKey);
	quest:SetPrologue(bodyText);


	local promptObjective = AddObjective(quest, "QUEST_OBJECTIVE_PROMPT", 
		titleText,
		bodyText,
		hmake CvQuestPromptObjectiveOption{	Text =  Locale.Lookup(choiceAText), 
													FlavorTypes = {
														choiceTable.ChoiceA.Flavor
													}},
		hmake CvQuestPromptObjectiveOption{	Text =  Locale.Lookup(choiceBText), 
													FlavorTypes = {
														choiceTable.ChoiceB.Flavor
													}}
	);

	-- Set optional tooltips for choice buttons
	if promptObjective ~= nil then
		local rewardA = GameInfo.PlayerPerks[choiceTable.ChoiceA.RewardPerkType];
		if rewardA ~= nil then
			promptObjective:SetPromptTooltipA(Locale.Lookup(rewardA.Help));
		end

		local rewardB = GameInfo.PlayerPerks[choiceTable.ChoiceB.RewardPerkType];
		if rewardB ~= nil then
			promptObjective:SetPromptTooltipB(Locale.Lookup(rewardB.Help));
		end
	end

	-- set prompt image
	promptObjective:SetPromptImagePath(GameplayUtilities.PromptImageDomestic);
end

function QuestScript.OnObjectiveComplete(quest, objective)
	print("BUILDINGCHOICE->QuestScript.OnObjectiveComplete buildingID="..quest.PersistentData.BuildingID);--MGH
	if (objective.PersistentData.Choice ~= nil) then

		local choiceTable = BUILDING_CHOICES_TABLE[quest.PersistentData.BuildingID];
		if choiceTable == nil then
			error(string.format("Choice table not found for Building Choice quest for building ID %s", quest.PersistentData.BuildingID));
			return;
		end

		local pPlayer = Players[objective:GetOwner()];
		local rewardPerkInfo = nil;

		local useVariant : boolean = quest.PersistentData.UseVariant or false;
		if(useVariant == nil) then
			error("useVariant was nil.");
		end

		-- set up text keys
		local choiceAEpilogue : string = choiceTable.ChoiceA.Epilogue;
		local choiceBEpilogue : string = choiceTable.ChoiceB.Epilogue;

		if(useVariant) then
			choiceAEpilogue = choiceAEpilogue .. VARIANT_SUFFIX;
			choiceBEpilogue = choiceBEpilogue .. VARIANT_SUFFIX;
		end

		if (objective.PersistentData.Choice == choiceTable.ChoiceA.ID) then
			
			objective:SetEpilogue(Locale.Lookup(choiceAEpilogue));
			rewardPerkInfo = GameInfo.PlayerPerks[choiceTable.ChoiceA.RewardPerkType];

		elseif (objective.PersistentData.Choice == choiceTable.ChoiceB.ID) then

			objective:SetEpilogue(Locale.Lookup(choiceBEpilogue));
			rewardPerkInfo = GameInfo.PlayerPerks[choiceTable.ChoiceB.RewardPerkType];

		else
			error("Unhandled Choice Value");
			return;
		end

		if rewardPerkInfo ~= nil then
			
			-- give player perk
			pPlayer:AddPerk(rewardPerkInfo.ID);

			-- Set reward string
			quest:SetReward(Locale.Lookup(rewardPerkInfo.Help));
			
			quest:Succeed();
		end
	end
end

return QuestScript;
