-- Vehicle Info
-- FUNCTIONS --



-- Toggle mouse true/false
function VInfo:toggleMouse(show)
    if (g_gui:getIsGuiVisible()) then return; end;
    if (type(show) == "boolean") then
        g_inputBinding:setShowMouseCursor(show);
    else
        g_inputBinding:setShowMouseCursor(not g_inputBinding:getShowMouseCursor());
    end
    VInfo.isMouseActive = g_inputBinding:getShowMouseCursor();
end;

-- Switch to selected vehicle
function VInfo:SwitchToVehicle(vehicle)
    if (g_currentMission.controlledVehicle == vehicle) then return; end;
    g_currentMission:requestToEnterVehicle(vehicle);
    VInfo:toggleMouse(false);
end;

-- Sort vehicle in the list 
function VInfo:SortVehicle(targetVehicle)
    table.remove(VInfo.vehicleList, VInfo.selectedVehicle.vi.id);
    table.insert(VInfo.vehicleList, targetVehicle.vi.id, VInfo.selectedVehicle);

    -- Set vehicle id's back to the current list order
    for key, veh in ipairs(VInfo.vehicleList) do
        veh.vi.id = key;
    end;

    -- Clear the selectedVehicle
    VInfo.selectedVehicle = nil;
end;

-- Overwrite default TAB binding
function VInfo:overwriteDefaultTabBinding()
	if not (string.len(g_gui.currentGuiName) > 0) then
        local state = false;

		if g_inputBinding.nameActions.SWITCH_VEHICLE.bindings[1] ~= nil and g_inputBinding.nameActions.SWITCH_VEHICLE.bindings[1].isActive ~= state then
			local eventsTab = InputBinding.getEventsForActionName(g_inputBinding, "SWITCH_VEHICLE");
			if eventsTab[1] ~= nil then
				g_inputBinding:setActionEventActive(eventsTab[1].id, state);
			end;
		end;
		
		if g_inputBinding.nameActions.SWITCH_VEHICLE_BACK.bindings[1] ~= nil and g_inputBinding.nameActions.SWITCH_VEHICLE_BACK.bindings[1].isActive ~= state then
			local eventsShiftTab = InputBinding.getEventsForActionName(g_inputBinding, "SWITCH_VEHICLE_BACK");
			if eventsShiftTab[1] ~= nil then
				g_inputBinding:setActionEventActive(eventsShiftTab[1].id, state);
			end;
		end;
	end;
end;

-- Draws Object on same line
function VInfo:updateObjectText(info, lineNumber)
    local posX = VInfo.text.posX;
    local posY = VInfo.text.posY;
    local size = VInfo.settings.textSize[VInfo.text.size];
    local lineWidth = 0;

    -- Draw every object after eachother with seperator inbetween
    for index, obj in pairs(info) do
        if (type(obj) == "table") then
            if (obj.text ~= nil) then
                setTextAlignment(0);
                local line = posY - (size * lineNumber);
                local text = '';
                local objWidth = 0;

                -- [1] speed
                if (index == 1) then
                    text = obj.text;
                    objWidth = size*2;
                else text = obj.text;
                    objWidth = getTextWidth(size, text);
                end;

                -- Draw text
                if (obj.bold) then setTextBold(true); else setTextBold(false); end;
                if (obj.color) then setTextColor(unpack(obj.color));
                else setTextColor(unpack(VInfo.colors.default)); end;
                renderText(posX, line, size, text);

                -- Add the textWidth to draw after 1st draw
                posX = posX + objWidth;
                lineWidth = lineWidth + objWidth;

                -- Set text to original state
                setTextBold(false);
                setTextColor(unpack(VInfo.colors.default));

                -- Render the seperator
                text = VInfo.text.seperator;
                objWidth = getTextWidth(size, text);
                renderText(posX, line, size, text);
                posX = posX + objWidth;
                lineWidth = lineWidth + objWidth;
            end;
        end;
    end;
    local bg = Overlay.new(VInfo.images["BG_VInfo"], VInfo.text.posX-0.001, VInfo.text.posY - (size * lineNumber) - (size/4.5), lineWidth, (size));
    bg:setColor(1,1,1, VInfo.settings.backgroundTransparency[VInfo.text.bgAlpha]);
    bg:render();
end;

-- Logging function
function VInfo:log(...)
    print("  [VI]: " .. string.format(...));
end;

-- Logging warning function
function VInfo:warning(...)
    print("  [VI][Warning!]: " .. string.format(...));
end;

-- Returns current vehicle/implement fruit and filllevel
function VInfo:getFillUnitInfo(vehicle, fillUnitNum)
    local fillUnit = nil;
    local fillPercent = 0;
    local color;
    local fruitID = vehicle:getFillUnitFillType(fillUnitNum);

    if math.floor(vehicle:getFillUnitFillLevel(fillUnitNum)) > 0 then
        local fruit = nil;
        if vehicle.spec_fillUnit.fillUnits[fillUnitNum].fillTypeToDisplay ~= 1 then
            fruit = g_fillTypeManager:getFillTypeByIndex(vehicle.spec_fillUnit.fillUnits[fillUnitNum].fillTypeToDisplay).title;
        else
            fruit = g_fillTypeManager:getFillTypeByIndex(fruitID).title;
        end;
        fillPercent = math.floor(vehicle:getFillUnitFillLevelPercentage(fillUnitNum) * 100);
        fillUnit = string.format("%s %s (%s%%)", fruit, math.floor(vehicle:getFillUnitFillLevel(fillUnitNum)), fillPercent);
    end;

    -- Set the color for the amount (need to check if seeder e.a ... seeder is ok when full, trailer is ok when empty)
    if (fillUnit ~= nil) then color = self:setFillColor(vehicle, fillPercent) end;
    return fillUnit, color;
end;

-- Set the text color of fillunits
function VInfo:setFillColor(vehicle, fillPercent)
    local color;
    if (not vehicle.spec_sowingMachine and not vehicle.spec_sprayer) then
        -- Probably a trailer or harvester
        if (fillPercent > 90) then
            color = VInfo.colors.tankFull;
        elseif (fillPercent > 25) then
            color = VInfo.colors.tankMid;
        elseif (fillPercent > 5) then
            color = VInfo.colors.tankLow;
        end;
    elseif (vehicle.spec_sowingMachine or vehicle.spec_sprayer) then
        -- its a sowing machine or a sprayer (reversing colors)
        if (fillPercent > 75) then
            color = VInfo.colors.tankLow;
        elseif (fillPercent > 10) then
            color = VInfo.colors.tankMid;
        elseif (fillPercent <= 10) then
            color = VInfo.colors.tankFull;
        end;
    end;
    return color;
end;

-- Check if vehicle has trailers or tools with fillunits
function VInfo:getAttachedInfo(vehicle, obj)
    if VInfo:getAllAttachedImplements(vehicle) ~= nil then
        local allImp = VInfo:getAllAttachedImplements(vehicle);
        local maxImp = 0;

        -- Need to reverse the table, last item is 1st attached inserted
        for i = #allImp, 1, -1 do
            if (maxImp >= VInfo.settings.maxImp) then goto skipToNext; end; --
            -- We dont want to display weights e.a.
            if not (allImp[i].spec_workArea or allImp[i].spec_fillUnit or allImp[i].spec_livestockTrailer or allImp[i].spec_baleWrapper) then goto skipToNext; end;  -- 
            maxImp = maxImp + 1;

            obj[#obj+1] = {};
            obj[#obj].text = allImp[i]:getName();

            if (allImp[i].spec_fillUnit) then
                if (allImp[i]:getFillUnitFillLevel(1) ~= nil) then
                    obj[#obj+1] = {};
                    obj[#obj].text, obj[#obj].color  = self:getFillUnitInfo(allImp[i], 1);
                end;
                if (allImp[i]:getFillUnitFillLevel(2) ~= nil) then
                    obj[#obj+1] = {};
                    obj[#obj].text, obj[#obj].color = self:getFillUnitInfo(allImp[i], 2);
                end;
            end;
            ::skipToNext::
        end;
    end;
end;

-- Returns 'all' attached implements on given vehicle
function VInfo:getAllAttachedImplements(vehicle)
    if vehicle ~= nil and vehicle.getAttachedImplements and #vehicle:getAttachedImplements() > 0 then
        local allImp = {};
        local function addAllAttached(obj)
            for _, imp in pairs(obj:getAttachedImplements()) do
                addAllAttached(imp.object);
                table.insert(allImp, imp.object);
            end;
        end;
        addAllAttached(vehicle);
        return allImp;
    end;
end;

-- Check if the vehicle blocked
function VInfo:isVehicleBlocked(vehicle)
    if g_server ~= nil and g_client ~= nil and g_dedicatedServerInfo ~= nil then return false; end;
    if (vehicle.spec_aiVehicle.MoveTimer == nil) then vehicle.spec_aiVehicle.MoveTimer = 5000; end;
    if vehicle.spec_aiVehicle.isActive then
        if (vehicle:getLastSpeed() < 0.5) then
            vehicle.spec_aiVehicle.MoveTimer = vehicle.spec_aiVehicle.MoveTimer-10;
        else
            vehicle.spec_aiVehicle.MoveTimer = 5000;
        end;
        if (vehicle.spec_aiVehicle.MoveTimer < 0) then return true; end;
    else
        vehicle.spec_aiVehicle.MoveTimer = nil;
    end;
    return false;
end;

-- Change object colors
function VInfo:changeObjColor(obj, color)
    for k,v in pairs(obj) do
        if (type(v) == "table") then
            obj[k].color = color;
        end;
    end;
end;

-- Check if the mouse is over text
function VInfo:isMouseOverText(text, size, posX, posY)
    if (VInfo.isMouseActive) then
        local txtWidth = getTextWidth(size, text);
        local txtHeight = getTextHeight(size, text);

        local areaX1 = posX;
        local areaX2 = areaX1 + txtWidth;
        local areaY1 = posY;
        local areaY2 = areaY1 + txtHeight;

        return VInfo.mousePosX >= areaX1 and VInfo.mousePosX <= areaX2 and VInfo.mousePosY >= areaY1 and VInfo.mousePosY <= areaY2;
    end;
end;

function VInfo:isMouseOverArea(posX, posY, width, height)
    if (VInfo.isMouseActive) then
        local areaX1 = posX;
        local areaX2 = areaX1 + width;
        local areaY1 = posY;
        local areaY2 = areaY1 + height;

        return VInfo.mousePosX >= areaX1 and VInfo.mousePosX <= areaX2 and VInfo.mousePosY >= areaY1 and VInfo.mousePosY <= areaY2;
    end;
end;

-- returns speed of vehicle in string format
function VInfo:getSpeedText(vehicle)
	if vehicle.getLastSpeed ~= nil then
		local unit = nil;
		local speed = nil;
		if g_i18n.useMiles then
			speed = vehicle:getLastSpeed() * 0.621371;
			unit = g_i18n.texts.unit_mph;
		else
			speed = vehicle:getLastSpeed();
			unit = g_i18n.texts.unit_kmh;
		end;
        return string.format("%1.0f %s", speed, unit);
	end;
end;

-- Returns Yes/No from boolean
function VInfo:getYesNo(value)
    if (value == true) then return "Yes"; end;
    if (value == false) then return "No"; end;
end;

-- Toggle CanVehicleTabWhenParked
function VInfo.toggleCanVehicleTabWhenParked()
    VInfo.settings.canVehicleTabWhenParked = not VInfo.settings.canVehicleTabWhenParked;
end;

-- Toggle CanVehicleTabWhenInActive
function VInfo.toggleCanVehicleTabWhenInActive()
    VInfo.settings.canVehicleTabWhenInActive = not VInfo.settings.canVehicleTabWhenInActive;
end;

-- Toggle ShowParkedVehicles
function VInfo.toggleShowParkedVehicles()
    VInfo.settings.showParkedVehicles = not VInfo.settings.showParkedVehicles;
end;

-- Toggle ShowInActiveVehicles
function VInfo.toggleShowInActiveVehicles()
    VInfo.settings.showInActiveVehicles = not VInfo.settings.showInActiveVehicles;
end;

-- Toggle TextSize
function VInfo.toggleTextSize()
    local size = VInfo.text.size;
    for i, v in ipairs(VInfo.settings.textSize) do
        if (size >= #VInfo.settings.textSize) then
            VInfo.text.size = 1;
        elseif (i > size) then
            VInfo.text.size = i;
            return;
        end;
    end;
end;

-- Toggle BackgroundTransparency
function VInfo.toggleBackgroundTransparency()
    local bgAlpha = VInfo.text.bgAlpha;
    for i, v in ipairs(VInfo.settings.backgroundTransparency) do
        if (bgAlpha >= #VInfo.settings.backgroundTransparency) then
            VInfo.text.bgAlpha = 1;
        elseif (i > bgAlpha) then
            VInfo.text.bgAlpha = i;
            return;
        end;
    end;
end;

-- Toggle ShowIcon
function VInfo.toggleShowIcon()
    VInfo.settings.showIcon = not VInfo.settings.showIcon;
end;

-- Toggle ShowAll
function VInfo.toggleShowAll()
    VInfo.settings.showAll = not VInfo.settings.showAll;
end;

-- Open SettingsMenu
function VInfo:openSettingsMenu()
    VInfo.settings.showSettings = true;
    VInfo:toggleMouse(true);
    VInfo:lockContext(true);
end;

-- Close SettingsMenu
function VInfo:closeSettingsMenu()
    VInfo.settings.showSettings = false;
    VInfo:toggleMouse(false);
    VInfo:lockContext(false);
end;

-- Create a interactive text line (for settings menu)
function VInfo:activeMenuLine(line, text, textSize, posX, value, func)
    local textToRender;
    if (type(value) == "boolean") then
        textToRender =  string.format("%s: %s", text, VInfo:getYesNo(value));
    elseif (value ~= nil) then
        textToRender =  string.format("%s: %s", text, value);
    else textToRender = text;
    end;

    if (VInfo:isMouseOverText(textToRender, textSize, posX, line)) then
        setTextColor(unpack(VInfo.colors.default)); -- text hover color
        VInfo.button1 = func;
    elseif (VInfo.button1 == func) then
        VInfo.button1 = nil;
    else setTextColor(unpack(VInfo.colors.lightBlue)); -- text color
    end;
    renderText(posX, line, textSize, textToRender);
end;

-- Render interactive Icon
function VInfo:renderIcon(posX, posY, width, height, img1, img2, func)
    local iconImg;
    if (VInfo:isMouseOverArea(posX, posY, width, height)) then
        iconImg = img2;
        VInfo.button1 = func;
    elseif (VInfo.button1 == func) then
        VInfo.button1 = nil;
    else iconImg = img1;
    end;

    local icon = Overlay.new(iconImg, posX, posY, width, height);
    icon:setColor(1,1,1,1);
    icon:render();
end;

-- Helper function for table
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true;
        end;
    end;
    return false;
end;

--- Lock/Unlock mouse and keyboard from any interaction outside the menu
function VInfo:lockContext(lockIt)
	local lockIt = lockIt ~= false;
	if lockIt and g_inputBinding:getContextName() ~= VInfo.hudName then
		g_inputBinding:setContext(VInfo.hudName, true, false);
	elseif not lockIt and g_inputBinding:getContextName() == VInfo.hudName then
		g_inputBinding:revertContext(true);
	end;
end;



-----------------------------------------------------
------------------------ XML ------------------------
-----------------------------------------------------


-- Calls saveToXML
function VInfo.saveSavegame()
    if (g_server ~= nil) then VInfo.saveToXML(); end;
end;

-- Save to xml file (global script)
function VInfo.saveToXML()
    local xmlFilePath = VInfo.getXMLPath();
	local xmlFile = createXMLFile(VInfo.name, xmlFilePath, VInfo.name);

    setXMLString(xmlFile, "VInfo.author", VInfo.author);
	setXMLString(xmlFile, "VInfo.version", VInfo.version);

	setXMLFloat(xmlFile, "VInfo.text.posX", VInfo.text.posX);
    setXMLFloat(xmlFile, "VInfo.text.posY", VInfo.text.posY);
    setXMLFloat(xmlFile, "VInfo.text.size", VInfo.text.size);
    setXMLFloat(xmlFile, "VInfo.text.bgAlpha", VInfo.text.bgAlpha);

    setXMLBool(xmlFile, "VInfo.settings.canVehicleTabWhenParked", VInfo.settings.canVehicleTabWhenParked);
    setXMLBool(xmlFile, "VInfo.settings.canVehicleTabWhenNotActive", VInfo.settings.canVehicleTabWhenInActive);
    setXMLBool(xmlFile, "VInfo.settings.showParkedVehicles", VInfo.settings.showParkedVehicles);
    setXMLBool(xmlFile, "VInfo.settings.showNotActiveVehicles", VInfo.settings.showInActiveVehicles);
    setXMLInt (xmlFile, "VInfo.settings.maxImp", VInfo.settings.maxImp);
    setXMLBool(xmlFile, "VInfo.settings.showIcon", VInfo.settings.showIcon);
    setXMLBool(xmlFile, "VInfo.settings.showAll", VInfo.settings.showAll);

    saveXMLFile(xmlFile);
    VInfo:log("Saved to xml file");
end;

-- Read from xml file (global script)
function VInfo.readFromXML(xmlFile)
    if (xmlFile == nil) then return; end;

    VInfo.text.posX =                           Utils.getNoNil(getXMLFloat(xmlFile, "VInfo.text.posX"), VInfo.text.posX);
    VInfo.text.posY =                           Utils.getNoNil(getXMLFloat(xmlFile, "VInfo.text.posY"), VInfo.text.posY);
    VInfo.text.size =                           Utils.getNoNil(getXMLFloat(xmlFile, "VInfo.text.size"), VInfo.text.size);
    VInfo.text.bgAlpha =                        Utils.getNoNil(getXMLFloat(xmlFile, "VInfo.text.bgAlpha"), VInfo.text.bgAlpha);

    VInfo.settings.canVehicleTabWhenParked =    Utils.getNoNil(getXMLBool(xmlFile, "VInfo.settings.canVehicleTabWhenParked"), VInfo.settings.canVehicleTabWhenParked);
    VInfo.settings.canVehicleTabWhenInActive =  Utils.getNoNil(getXMLBool(xmlFile, "VInfo.settings.canVehicleTabWhenNotActive"), VInfo.settings.canVehicleTabWhenInActive);
    VInfo.settings.showParkedVehicles =         Utils.getNoNil(getXMLBool(xmlFile, "VInfo.settings.showParkedVehicles"), VInfo.settings.showParkedVehicles);
    VInfo.settings.showInActiveVehicles =       Utils.getNoNil(getXMLBool(xmlFile, "VInfo.settings.showNotActiveVehicles"), VInfo.settings.showInActiveVehicles);
    VInfo.settings.maxImp =                     Utils.getNoNil(getXMLInt (xmlFile, "VInfo.settings.maxImp"), VInfo.settings.maxImp);
    VInfo.settings.showOpenMenuIcon =           Utils.getNoNil(getXMLBool(xmlFile, "VInfo.settings.showIcon"), VInfo.settings.showIcon);
    VInfo.settings.showAll =                    Utils.getNoNil(getXMLBool(xmlFile, "VInfo.settings.showAll"), VInfo.settings.showAll);

end;

-- Load xml file
function VInfo.loadStoredXML()
    if (g_server == nil) then return; end;

	local xmlFilePath = VInfo.getXMLPath();

	if fileExists(xmlFilePath) then
		local xmlFile = loadXMLFile(VInfo.name, xmlFilePath);
        VInfo:log("Loaded xmlFile");
		VInfo.readFromXML(xmlFile);
        delete(xmlFile);
	else
		VInfo:warning("xmlFile not found or other error!");
	end;
end;

-- Returns the xml file path stored in savegame directory. Creates new if not exists
function VInfo.getXMLPath()
	local path = g_currentMission.missionInfo.savegameDirectory;
	if path ~= nil then
		return path .. "/VInfo_config.xml";
	else
		return getUserProfileAppPath() .. "savegame" .. g_currentMission.missionInfo.savegameIndex .. "/VInfo_config.xml";
	end;
end;
