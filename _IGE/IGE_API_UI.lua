-- Released under GPL v3
--------------------------------------------------------------
defaultErrorTextureSheet48 = "Art\\IgeNone48.dds";
defaultErrorTextureSheet64 = "Art\\IgeNone64.dds";
local tipControlTable = {};

-------------------------------------------------------------------------------------------------
function CreateInstanceManager(style, rootName, parentControl)
	local manager = InstanceManager:new(style, rootName, parentControl);
	local size = parentControl:GetSize();
	manager.columnWidth = size.x;
	manager.maxHeight = size.y;
	return manager;
end

--===============================================================================================
-- Tooltip
--===============================================================================================
function ToolTipHandler(item)
	if item then
		-- Resize Icon element due to artifacts only having 128 textures
		if item.isArtifact then
			tipControlTable.Image:SetSizeVal(128,128);
		else
			tipControlTable.Image:SetSizeVal(64,64);
		end
		-- Icon
		tipControlTable.Image:SetTexture( item.texture or defaultErrorTextureSheet64 );
		tipControlTable.Image:SetTextureOffset( item.textureOffset or nullOffset );
		

		-- Name and subtitle
		local label = "[COLOR_POSITIVE_TEXT]"..item.name.."[ENDCOLOR]";
		local subtitle = item.subtitle;
		if subtitle and subtitle ~= "" then 
			label = label.."[NEWLINE]"..subtitle;
		end
		local lines = { string.find(label, "[NEWLINE]") };

		if #lines <= 2 then
			tipControlTable.SmallLabel:SetText(label);
			tipControlTable.SmallLabel:SetHide(false);
			tipControlTable.LargeLabel:SetHide(true);
		else
			tipControlTable.LargeLabel:SetText(label.."[NEWLINE]");
			tipControlTable.LargeLabel:SetHide(false);
			tipControlTable.SmallLabel:SetHide(true);
		end

		-- Help
		local hasHelp = false;
		if item.help and item.help ~= "" then
			tipControlTable.Help:SetText(item.help);
			tipControlTable.Help:SetHide(false);
			hasHelp = true;
		else
			tipControlTable.Help:SetHide(true);
		end

		-- Note
		if item.note and item.note ~= "" then
			tipControlTable.Note:SetHide(false);
			tipControlTable.Note:SetText(hasHelp and "[NEWLINE]"..item.note or item.note);
		else
			tipControlTable.Note:SetHide(true);
		end

		-- Resize
		tipControlTable.Frame:DoAutoSize();
		tipControlTable.Frame:DoAutoSize();
		tipControlTable.Frame:SetHide(false);
	else
		tipControlTable.Frame:SetHide(true);
	end		
end
TTManager:GetTypeControlTable("IGE_ToolTip", tipControlTable);


--===============================================================================================
-- LISTS UPDATE
--===============================================================================================
function SetupInstance(v, instance, clickHandler, rightClickHandler)
	if clickHandler then
		instance.Button:RegisterCallback(Mouse.eLClick, function() clickHandler(v) end);
	end

	if rightClickHandler then
		instance.Button:RegisterCallback(Mouse.eRClick, function() rightClickHandler(v) end);
	end

	if v.toolTip then
		--instance.Button:SetToolTipType("");
		instance.Button:SetToolTipString(v.toolTip);
	else
		instance.Button:SetToolTipCallback(function() ToolTipHandler(v) end);
		instance.Button:SetToolTipType("IGE_ToolTip");
	end

	if instance.Label then
		instance.Label:SetText(v.label or v.name);
	end

	if instance.NameLabel then
		instance.NameLabel:SetText(v.label or v.name);
		instance.NameLabel:SetAlpha(v.enabled and 1.0 or 0.6);
	end

	if instance.Icon then
		instance.Icon:SetTexture(v.texture or defaultErrorTextureSheet64);
		instance.Icon:SetTextureOffset(v.textureOffset or nullOffset);
	end

	if instance.SmallIcon then
		instance.SmallIcon:SetTexture(v.smallTexture or defaultErrorTextureSheet48);
		instance.SmallIcon:SetTextureOffset(v.smallTextureOffset or nullOffset);
	end

	if instance.TopButton then
		if v.topData and v.selected then
			instance.TopIcon:SetTexture(v.topData.texture or defaultErrorTextureSheet64);
			instance.TopIcon:SetTextureOffset(v.topData.textureOffset or nullOffset);
			instance.TopButton:SetToolTipCallback(function() ToolTipHandler(v.topData) end);
			instance.TopButton:SetHide(false);
		else
			instance.TopButton:SetHide(true);
		end
	end

	if instance.SelectionFrame then
		instance.SelectionFrame:SetHide(not v.selected);
	end
end

-------------------------------------------------------------------------------------------------
local function ResizeListItemInstance(instance, columnWidth, labelWidth, maxButtonHeight)
	instance.Button:SetSizeX(columnWidth);	
	instance.NameLabel:SetSizeX(labelWidth);
	if maxButtonHeight then
		instance.Button:SetSizeY(maxButtonHeight);
		instance.NameLabel:SetSizeY(maxButtonHeight);
	end
	if instance.SelectionFrame then
		instance.SelectionFrame:SetSizeX(columnWidth);
		if maxButtonHeight then
			instance.SelectionFrame:SetSizeY(maxButtonHeight);
		end
	end
	if instance.HoverHighLight then
		instance.HoverHighLight:SetSizeX(columnWidth);
		if maxButtonHeight then
			instance.HoverHighLight:SetSizeY(maxButtonHeight);
		end
	end
	if instance.HoverAnim then
		instance.HoverAnim:SetSizeX(columnWidth);
		if maxButtonHeight then
			instance.HoverAnim:SetSizeY(maxButtonHeight);
		end
	end
	TruncateString(instance.NameLabel, labelWidth, instance.NameLabel:GetText());
end

-------------------------------------------------------------------------------------------------
function UpdateGeneric(items, listManager, clickHandler, columnWidth)
	columnWidth = columnWidth or listManager.columnWidth;
	local labelWidth = columnWidth - 10;

	listManager:ResetInstances();
	for i, v in ipairs(items) do
		if v.visible then
			local instance = listManager:GetInstance();
			if instance then
				SetupInstance(v, instance, clickHandler);
				if instance.NameLabel then
					ResizeListItemInstance(instance, columnWidth, labelWidth);
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------
local columnPadding = 5;
function UpdateList(items, listManager, clickHandler, rightClickHandler, instances)
	local parent = listManager.m_ParentControl;
	local rootControlName = listManager.m_RootControlName;

	-- Layout
	local height = 0;
	local offsetX = 0;
	local offsetY = 0;
	local maxHeight = listManager.maxHeight;
	local maxButtonHeight = listManager.maxButtonHeight;

	local columnWidth = listManager.columnWidth;
	local labelWidth = columnWidth - 10;
	local isEmpty = true;
	local newColumn = false;

	-- Scroll first column
	listManager:ResetInstances();
	for i, v in ipairs(items) do
		if v.visible then
			local instance = listManager:GetInstance();
			if instance then
				isEmpty = false;
				if instances then 
					instances[v] = instance;
				end
				SetupInstance(v, instance, clickHandler, rightClickHandler);

				-- Resize
				if maxButtonHeight ~= nil then
					ResizeListItemInstance(instance, columnWidth, labelWidth, maxButtonHeight);
				else
					ResizeListItemInstance(instance, columnWidth, labelWidth);
				end

				-- New column ?
				local size = instance.Button:GetSize();
				if offsetY + size.y > maxHeight then
					offsetX = offsetX + columnWidth + columnPadding;
					if not newColumn then
						height = offsetY;
						newColumn = true;
					end
					offsetY = 0;
				end
				-- Offset
				--print(v.name.." ; "..offsetX.." ; "..offsetY);
				instance.Button:SetOffsetX(offsetX);
				instance.Button:SetOffsetY(offsetY);
				offsetY = offsetY + size.y;
				
				if offsetY > height then height = offsetY 
				end
				
			end
			
		end
	end

	-- Update parent size
	parent:SetSizeX(offsetX + columnWidth);
	parent:SetSizeY(height);
	parent:SetHide(isEmpty);

	return offsetX + columnWidth, height;
end

-------------------------------------------------------------------------------------------------
function UpdateHierarchizedList(items, itemManager, clickHandler, rightClickHandler, instances)
	local currentCivID = IGE.currentPlayer:GetCivilizationType();
	local currentCivType = GameInfo.Civilizations[currentCivID].Type;
	table.sort(items, DefaultSort);

	-- Collect default units
	local defaultItemsByClass = {}
	for _, item in ipairs(items) do
		local availableForThisCiv = (not item.civilizationType) or item.civilizationType == currentCivType
		item.enabled = item.enabled and availableForThisCiv

		-- This is our civ-specific unit
		if item.civilizationType and item.civilizationType == currentCivType then
			defaultItemsByClass[item.class] = item;

		-- No default unit yet, or the default one is specific to another civ
		elseif (not defaultItemsByClass[item.class]) or  (defaultItemsByClass[item.class].civilizationType and (defaultItemsByClass[item.class].civilizationType ~= currentCivType)) then
			defaultItemsByClass[item.class] = item;
		end
	end

	-- Toogle selected/enabled
	for _, item in ipairs(items) do 
		local defaultItem = defaultItemsByClass[item.class];
		item.isDefault = (defaultItem == item) or (defaultItem and item and (defaultItem.type == item.type));
		item.label = item.isDefault and item.label or "   "..item.label;
		--item.enabled = item.enabled and item.isDefault;
	end

	-- Gather disabled units in alpha order
	local k = 1;
	local nonDefaultItems = {};
	while true do
		local item = items[k];
		if not item then break end

		if not item.isDefault then 
			table.insert(nonDefaultItems, item);
			table.remove(items, k);
		else
			k = k + 1;
		end
	end

	-- Reinsert disabled units on proper position
	for _, item in ipairs(nonDefaultItems) do
		local k = #items
		while k > 0 do
			local defaultItem = items[k];
			if defaultItem.class == item.class then
				table.insert(items, k + 1, item);
				break;
			end
			k = k - 1;
		end
	end

	-- Update list
	local x, y = UpdateList(items, itemManager, clickHandler, rightClickHandler, instances);
	--print("IGE_API_UI: x,y: ",x,y);
	-- returns list height for updating UI
	return y;
end


--===============================================================================================
-- GRAPH SETUP
--===============================================================================================
local function SetupHLine(manager, x1, x2, y)
	local instance = manager:GetInstance();
	instance.Root:SetOffsetVal(math.min(x1, x2), y);
	instance.ConnectorH:SetSizeX(math.abs(x2 - x1));
	instance.ConnectorH:SetHide(false);
	instance.Image:SetHide(true);
end

-------------------------------------------------------------------------------------------------
local function SetupVLine(manager, x, y1, y2)
	local instance = manager:GetInstance();
	instance.Root:SetOffsetVal(x, math.min(y1, y2));
	instance.ConnectorV:SetSizeY(math.abs(y2 - y1));
	instance.ConnectorV:SetHide(false);
	instance.Image:SetHide(true);
end

-------------------------------------------------------------------------------------------------
local function SetupTurn(manager, align, x, y)
	local instance = manager:GetInstance();
	instance.Image:SetTexture("Connect_JonCurve_"..align..".dds");

	if align == "topleft" then
		instance.Root:SetOffsetVal(x - 8, y - 8);
	elseif align == "topright" then
		instance.Root:SetOffsetVal(x, y - 8);
	elseif align == "bottomleft" then
		instance.Root:SetOffsetVal(x - 8, y);
	else
		instance.Root:SetOffsetVal(x, y);
	end
end

-------------------------------------------------------------------------------------------------
function UpdateGraph(items, itemManager, pipeManager, instances, sizeX, sizeY, paddingX, paddingY, x0, y0, horizontal)
	local xmin, ymin = 999, 999;
	local xmax, ymax = 0, 0;

	-- Items
	itemManager:ResetInstances();
	local rootName = itemManager.m_RootControlName;
	for i, v in ipairs(items) do
		if v.visible then
			local instance = itemManager:GetInstance();
			instances[v] = instance;

			local x = x0 + (v.gridX - 1) * paddingX;
			local y = y0 + (v.gridY - 1) * paddingY;
			instance[rootName]:SetOffsetVal(x, y);

			--print(v.name.." ; "..v.gridX.." ; "..v.gridY.." ; "..x.." ; "..y);
			xmin = math.min(xmin, x);
			ymin = math.min(ymin, y);
			xmax = math.max(xmax, x + sizeX);
			ymax = math.max(ymax, y + sizeY);
		end
	end

	-- Pipes
	local turnDelta = 11;
	local pipeDelta = 3;
	pipeManager:ResetInstances();
	for i, t in ipairs(items) do
		if t.visible then
			local tx = x0 + (t.gridX - 1) * paddingX;
			local ty = y0 + (t.gridY - 1) * paddingY;

			for _, s in ipairs(t.prereqs) do
				if s.visible then
					local sx = x0 + (s.gridX - 1) * paddingX;
					local sy = y0 + (s.gridY - 1) * paddingY;

					local x1 = math.min(sx, tx);
					local x2 = math.max(sx, tx);
					local y1 = math.min(sy, ty);
					local y2 = math.max(sy, ty);

					local middleX = (sx + sizeX + tx) / 2;
					local middleY = (sy + sizeY + ty) / 2;
					local splitX = tx - (paddingX - sizeX) * 3 / 5;
					local splitY = ty - (paddingY - sizeY) * 3 / 5;
					local threeLines = (sy ~= ty) and (sx ~= tx);

					-- Horizontal
					if sx ~= tx then
						if not threeLines then
							SetupHLine(pipeManager, sx + sizeX, tx, sy + sizeY / 2 - pipeDelta / 2);
						elseif horizontal then
							SetupHLine(pipeManager, sx + sizeX, splitX - turnDelta / 2, sy + sizeY / 2 - pipeDelta / 2);
							SetupHLine(pipeManager, splitX + turnDelta / 2, tx, ty + sizeY / 2 - pipeDelta / 2);
						else
							SetupHLine(pipeManager, x1 + sizeX / 2 + turnDelta / 2, x2 + sizeX / 2 - turnDelta / 2, splitY - pipeDelta / 2);
						end
					end

					-- Vertical
					if sy ~= ty then
						if not threeLines then
							SetupVLine(pipeManager, sx + sizeX / 2 - pipeDelta / 2, sy + sizeY, ty);
						elseif horizontal then
							SetupVLine(pipeManager, splitX - pipeDelta / 2, y1 + sizeY / 2 + turnDelta / 2, y2 + sizeY / 2 - turnDelta / 2);
						else
							SetupVLine(pipeManager, sx + sizeX / 2 - pipeDelta / 2, sy + sizeY, splitY - turnDelta / 2);
							SetupVLine(pipeManager, tx + sizeX / 2 - pipeDelta / 2, splitY + turnDelta / 2, ty);
						end
					end

					-- Turns
					if threeLines then
						local deltaLU = -pipeDelta / 2;
						local deltaRB = pipeDelta / 2 - turnDelta;
						if horizontal then
							-- Upward ?
							if ty < sy then 
								SetupTurn(pipeManager, "bottomright",	splitX + deltaRB,			sy + sizeY / 2 + deltaRB);
								SetupTurn(pipeManager, "topleft",		splitX + deltaLU,			ty + sizeY / 2 + deltaLU);
							else
								SetupTurn(pipeManager, "topright",		splitX + deltaRB,			sy + sizeY / 2 + deltaLU);
								SetupTurn(pipeManager, "bottomleft",	splitX + deltaLU,			ty + sizeY / 2 + deltaRB);
							end
						else
							-- Left to right ?
							if tx > sx then	
								SetupTurn(pipeManager, "bottomleft",	sx + sizeX / 2 + deltaLU,	splitY + deltaRB);
								SetupTurn(pipeManager, "topright",		tx + sizeX / 2 + deltaRB,	splitY + deltaLU);
							else
								SetupTurn(pipeManager, "bottomright",	sx + sizeX / 2 + deltaRB,	splitY + deltaRB);
								SetupTurn(pipeManager, "topleft",		tx + sizeX / 2 + deltaLU,	splitY + deltaLU);
							end
						end
					end
				end
			end
		end
	end

	return xmin, xmax, ymin, ymax;
end


--===============================================================================================
-- Numeric boxes
--===============================================================================================
function HookNumericBox(prefix, getter, setter, min, max, step, controlsHolder)
	if not controlsHolder then controlsHolder = Controls end
	local downButton = controlsHolder[prefix.."Down"];
	local upButton = controlsHolder[prefix.."Up"];
	local editBox = controlsHolder[prefix.."EditBox"];

	local update = function(count, userInteraction)
		count = math.floor(count + 0.5);
		downButton:SetDisabled(false);
		upButton:SetDisabled(false);

		if min and count <= min then 
			count = min;
			downButton:SetDisabled(true);
		end

		if max and count >= max then 
			count = max;
			upButton:SetDisabled(true);
		end

		setter(count, userInteraction);
		local str = tostring(count);
		if editBox:GetText() ~= str then
			editBox:SetText(str);
		end
	end

	downButton:RegisterCallback(Mouse.eLClick, function() 
			update(getter() - step, true);
		end);

	upButton:RegisterCallback(Mouse.eLClick, function() 
			update(getter() + step, true);
		end);

	editBox:RegisterCallback(function(string) 
			update(tonumber(string), true);
		end);

	return update;
end

--===============================================================================================
-- Others
--===============================================================================================
function Resize(control)
	local offset = 1280 - UIManager:GetScreenSizeVal();
	if offset > 0 then
		control:SetSizeX(control:GetSizeX() - offset);
	end
end

function LowerSizeY(control, offset)
	control:SetSizeY(control:GetSizeY() - offset);
end


--Print tables and sub tables
function print_table ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end
 