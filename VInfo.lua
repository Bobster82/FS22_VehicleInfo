--[[
    Vehicle Info shows information about your vehicles and attachments, active/helper/player/parked, fillLevels.

        + Click on the text (vehicle) to switch to it.
        + Modify the order of appearance, to personalise the "Tab order".
        + Show / Hide inactive and/or parked vehicles.
        + Skip inactive and/or parked vehicles, to personalise the "Tab order".
        + See realtime information about the current status of your vehicles, attachments and fill levels.

    How to use:
    * Press 'right mouse button' to (de)activate the mouse cursor.
    * Press 'left ALT + m' key to open the settings menu (close it with selecting '[X]close').
    * Change menu settings by clicking on the text.
    * Click on the text to switch to the vehicle.
    * Press 'Tab' key to switch to the next vehicle in the list,
        press 'left shift + Tab' to switch to the previous one.
    * Press 'left ALT' key and 'left mouse button' to select a vehicle,
        select another vehicle with 'left ALT key' and 'left mouse button' to switch the order.
    * Press 'left ALT + q' key to mark the vehicle as '[P]' parked,
        press again to remove parking or just start driving.
    * Click on the [Vi] icon (if enabled) to toggle the quick show function,
        blue (off): only vehicles according to settigs are shown.
        green (on): all vehicles are shown.


    This mod is made by me from scratch with snippets/looks from some other mods. It was only meant for personal use,
        but upon request I share this with you. Created only for single player.
    I got my inspiration from several mods, credits to: HappyLooser (VehicleInspector), sperrgebiet (VehicleExplorer), 
        CoursePlay Dev team (CoursePlay), AutoDrive Dev team (AutoDrive).

    If you have any issues with the mod or anything related, please contact me on https://github.com/Bobster82/FS22_VehicleInfo
]]







-- Main table
VInfo = {};
VInfo.name = "VInfo";
VInfo.fullName = "Vehicle Info";
VInfo.author = "Bobster82";
VInfo.version = "1.0.0.2";
VInfo.dir = g_currentModDirectory;
VInfo.hudName = "VINFO_HUD";

-- Text settings
VInfo.text = {};
VInfo.text.size = 5;
VInfo.text.bgAlpha = 6;
VInfo.text.posX = 0.002;
VInfo.text.posY = 0.95;
VInfo.text.seperator = " | ";
VInfo.text.helper = "H";
VInfo.text.cpHelper = "CP";
VInfo.text.adHelper = "AD";
VInfo.text.parked = "    [P] ";
VInfo.text.blocked = "Blocked";
VInfo.text.stopped = "Stopped";

-- Table with colors
VInfo.colors = {
    lightBlue = {0.00, 0.70, 1.00, 1.00},  -- LightBlue
    default =   {1.00, 1.00, 1.00, 1.00},  -- White
    parked =    {0.70, 0.70, 0.70, 0.70},  -- Light Gray
    hovered =   {0.20, 0.20, 1.00, 1.00},  -- Purple
    blocked =   {1.00, 0.00, 0.00, 1.00},  -- Red
    selected =  {1.00, 0.00, 0.00, 1.00},  -- Red
    tankLow =   {0.00, 1.00, 0.00, 1.00},  -- Green
    tankMid =   {1.00, 0.60, 0.00, 1.00},  -- Orange
    tankFull =  {1.00, 0.00, 0.00, 1.00},  -- Red
    inActive =  {0.60, 0.38, 0.38, 1.00},  -- Dark red
    entered =   {0.00, 1.00, 1.00, 1.00},  -- Cyan
    helper =    {0.75, 1.00, 0.45, 1.00},  -- Green/Yellow
    BGColor =   {0.00, 0.00, 0.00, 0.70},  -- Only alpha is working
    BGBlack =   {0.00, 0.00, 0.00, 1.00}   -- Only alpha is working
};

-- Settings
VInfo.settings = {};
VInfo.settings.canVehicleTabWhenParked = true;      -- Parked vehicle is or isnt able to be tabbed
VInfo.settings.showParkedVehicles = true;           -- Show parked vehicles in the list
VInfo.settings.canVehicleTabWhenInActive = true;    -- Inactive vehicle is or isnt able to be tabbed
VInfo.settings.showInActiveVehicles = true;         -- Show the vehicle in the list when inactive
VInfo.settings.maxImp = 3;                          -- Max number of implements attached to show
VInfo.settings.showVInfo = true;                    -- Shows the VInfo
VInfo.settings.showSettings = false;                -- Shows the settings menu
VInfo.settings.showIcon = true;                     -- Shows the quick action icon
VInfo.settings.showAll = false;                     -- Use the icon to quick show/ hide hidden vehicles
VInfo.settings.textSize = {0.008, 0.009, 0.010, 0.011, 0.012, 0.013, 0.014, 0.015, 0.016};      -- TextSize
VInfo.settings.backgroundTransparency = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1};    -- Background transparency

-------------------

-- Images
VInfo.images = {};

-- Vehicle(s)
VInfo.vehicleList = {};
VInfo.currentVehicle = nil;
VInfo.selectedVehicle = nil;
VInfo.vehicle = nil;

-- Modifier (left ALT)
VInfo.isModifierPressed = false;

-- Mouse
VInfo.isMouseActive = false;
VInfo.mousePosX = 0;
VInfo.mousePosY = 0;


addModEventListener(VInfo);

--################################


-- FS loadMap
function VInfo:loadMap()
    VInfo:log("Vehicle Info, version: %s, Author: %s", VInfo.version, VInfo.author);
    FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, VInfo.RegisterActionEvents);

    VInfo.images["BG_VInfo"] = VInfo.dir .."Img/BG_VInfo.dds";
    VInfo.images["BG_Menu"] = VInfo.dir .."Img/BG_Menu.dds";
    VInfo.images["VI_Icon"] = VInfo.dir .."Img/VI_Icon.dds";
    VInfo.images["VI_Icon_H"] = VInfo.dir .."Img/VI_Icon_hovered.dds";

    VInfo.loadStoredXML();
end;

-- Register action events
function VInfo:RegisterActionEvents()
    local ok, eventId = InputBinding.registerActionEvent(g_inputBinding, InputAction.viToggleMouse, self, VInfo.toggleMouse ,false ,true ,false ,true, nil);
    if ok then  g_inputBinding.events[eventId].displayIsVisible = true;
                g_inputBinding:setActionEventTextPriority(eventId, GS_PRIO_HIGH) end;
    ok, eventId = InputBinding.registerActionEvent(g_inputBinding, InputAction.viOpenSettingsMenu, self, VInfo.openSettingsMenu ,false ,true ,false ,true, nil);
    if ok then  g_inputBinding.events[eventId].displayIsVisible = true; end;

    ok, eventId = InputBinding.registerActionEvent(g_inputBinding, InputAction.viSwitchToNextVehicle,self, VInfo.action_viSwitchToNextVehicle ,false ,true ,false ,true, nil);
    if ok then  g_inputBinding.events[eventId].displayIsVisible = false; end;

    ok, eventId = InputBinding.registerActionEvent(g_inputBinding, InputAction.viSwitchToPreviousVehicle,self, VInfo.action_viSwitchToPreviousVehicle ,false ,true ,false ,true, nil);
    if ok then  g_inputBinding.events[eventId].displayIsVisible = false; end;
end;

-- FS update
function VInfo:update()
    VInfo:overwriteDefaultTabBinding();
end;

-- FS draw
function VInfo:draw()
    VInfo:vehicleInfoUpdate();
    if (VInfo.settings.showSettings) then
        VInfo:drawSettingsMenu();
    end;
    if (VInfo.settings.showIcon) then
        VInfo:drawMenuIcon();
    elseif (VInfo.settings.showAll) then
        VInfo.settings.showAll = false;
    end;
end;

-- Main function
function VInfo:vehicleInfoUpdate()
    local lineNumber = 0;
    local textSize = VInfo.settings.textSize[VInfo.text.size]
    if (VInfo.vehicleList ~= nil) then
        for _, vehicle in ipairs(VInfo.vehicleList) do
            if (vehicle.vi == nil) then return; end;
            local draw = true;

            local isHelper = vehicle.vi.isHelper;
            local isEntered = vehicle:getIsEntered();
            local isActive = vehicle.vi.isActive;
            local isParked = vehicle.vi.isParked;
            local isSelected = (vehicle == VInfo.selectedVehicle);
            local isBlocked = VInfo:isVehicleBlocked(vehicle);
            local isHovered;

            if (not VInfo.settings.showAll) then
                if (VInfo.settings.showInActiveVehicles == false and not isActive and not isEntered and not isParked) then
                    -- We dont show InActive vehicles
                    draw = false;
                elseif (VInfo.settings.showParkedVehicles == false and isParked and not isEntered) then
                    -- We dont show parked vehicles
                    draw = false;
                end;
            end;

            if (not draw) then
                if (VInfo.vehicle == vehicle) then VInfo.vehicle = nil; end;
            else
                -- Main object
                Obj = {};

                -- Speed of the vehicle
                local speed = 1;
                Obj[speed] = {};
                if (not isActive and not isParked) then Obj[speed].text = VInfo.text.stopped;
                else Obj[speed].text = VInfo:getSpeedText(vehicle); end;

                -- Name of the vehicle
                local name = 2;
                Obj[name] = {};
                Obj[name].text = tostring(vehicle:getName());

                -- Check if its a combine (need for filllevel check)
                if vehicle.spec_combine ~= nil then Obj[#Obj+1] = {}; Obj[#Obj].text, Obj[#Obj].color = VInfo:getFillUnitInfo(vehicle, 1); end;

                -- Check if vehicle has trailers or tools with fillunits
                VInfo:getAttachedInfo(vehicle, Obj);

                -- Display player name or if helper active, what kind.
                if (isEntered) then
                    local txt = "Player"; --vehicle:getControllerName() not working atm...
                    table.insert(Obj, name, {text = txt});
                    Obj[name].bold = true;
                elseif (isHelper) then
                    local txt;
                    if (vehicle.cp ~= nil and vehicle:getIsCourseplayDriving()) then txt = VInfo.text.cpHelper;
                    elseif (vehicle.ad ~= nil and vehicle.ad.stateModule:isActive()) then txt = VInfo.text.adHelper; end;
                    txt = txt or VInfo.text.helper;
                    table.insert(Obj, name, {text = txt});
                    Obj[name].bold = true;
                end;

                -- Combine text for calculate width for mouse over function.
                if (VInfo.isMouseActive and not VInfo.settings.showSettings) then
                    local text = "";
                    for _,v in ipairs(Obj) do
                        if (v.text ~= nil) then text = string.format("%s%s%s", text, VInfo.text.seperator, v.text) end;
                    end;
                    local posY = VInfo.text.posY - (textSize * (lineNumber+1));
                    isHovered = VInfo:isMouseOverText(text, textSize, VInfo.text.posX, posY);
                end;

                -- Set temp vehicle for hovered
                if (isHovered) then VInfo.vehicle = vehicle;
                elseif (not isHovered and VInfo.vehicle == vehicle) then VInfo.vehicle = nil; end;

                -- Setting colors
                if (isHelper and not isEntered) then Obj[name].color = VInfo.colors.helper; end;
                if (isBlocked and not isEntered) then Obj[speed].color = VInfo.colors.blocked; Obj[speed].text = VInfo.text.blocked; end;
                if (not isActive) then VInfo:changeObjColor(Obj, VInfo.colors.inActive); end;
                if (isParked) then VInfo:changeObjColor(Obj, VInfo.colors.parked); Obj[speed].text = VInfo.text.parked; end;
                if (isEntered) then Obj[name].color = VInfo.colors.entered; end;
                if (isSelected) then VInfo:changeObjColor(Obj, VInfo.colors.selected); end;
                if (isHovered) then VInfo:changeObjColor(Obj, VInfo.colors.hovered); end;

                -- Draw info to the screen
                lineNumber = lineNumber + 1;
                if (not g_gameSettings.showHelpMenu and VInfo.settings.showVInfo and g_gui.currentGuiName == "") then
                    VInfo:updateObjectText(Obj, lineNumber);
                end;
            end;

        end;
    end;
end;

-- Menu icon
function VInfo:drawMenuIcon()
    if (not g_gameSettings.showHelpMenu and VInfo.settings.showVInfo and g_gui.currentGuiName == "") then
        local posX = 0.001;
        local posY = 0.95;
        local width = 0.011;
        local height = 0.015;
        local icon = (VInfo.settings.showAll) and VInfo.images["VI_Icon_H"] or VInfo.images["VI_Icon"];
        VInfo:renderIcon(posX, posY, width, height, icon, VInfo.images["VI_Icon_H"], VInfo.toggleShowAll);
    end;
end;

-- Settings menu
function VInfo:drawSettingsMenu()
    local center = 0.5;
    local width = 0.25;
    local height = 0.47;
    local posX = center - (width/2);
    local posX2 = center + (width/2);
    local posY = center + (height/2) + 0.2;
    local posY2 = center - (height/2) + 0.2;
    local textSize = 0.02;
    local indent = 0.01;
    local title = posY - 0.15;
    local line;
    local text;

    -- Render the menu background
    local bgMenu = Overlay.new(VInfo.images["BG_Menu"], posX, posY2, width, height); -- From X to Y2
    bgMenu:setColor(1,1,1,1);
    bgMenu:render();

    if (not VInfo.isMouseActive) then VInfo:toggleMouse(true); end;

    -- Sets mouseover hud.
    VInfo:isMouseOverArea(posX, posY2, width, height);

    -- Line settings
    setTextAlignment(RenderText.ALIGN_LEFT);
    setTextBold(false);
    posX = posX + indent;

    -- Line 1
    line = title - textSize * 1;
    text = "Tab trough vehicles when parked";
    VInfo:activeMenuLine(line, text, textSize, posX, VInfo.settings.canVehicleTabWhenParked, VInfo.toggleCanVehicleTabWhenParked);

    -- Line 2
    line = title - textSize * 2;
    text = "Show vehicles when parked";
    VInfo:activeMenuLine(line, text, textSize, posX, VInfo.settings.showParkedVehicles, VInfo.toggleShowParkedVehicles);

    -- Line 3
    line = title - textSize * 3;
    text = "Tab trough vehicles when not active";
    VInfo:activeMenuLine(line, text, textSize, posX, VInfo.settings.canVehicleTabWhenInActive, VInfo.toggleCanVehicleTabWhenInActive);

    -- Line 4
    line = title - textSize * 4;
    text = "Show vehicles when not active";
    VInfo:activeMenuLine(line, text, textSize, posX, VInfo.settings.showInActiveVehicles, VInfo.toggleShowInActiveVehicles);

    -- Line 5

    -- Line 6
    line = title - textSize * 6;
    text = "Text size";
    VInfo:activeMenuLine(line, text, textSize, posX, VInfo.text.size, VInfo.toggleTextSize);

    -- Line 7
    line = title - textSize * 7;
    text = "Background transparency";
    VInfo:activeMenuLine(line, text, textSize, posX, VInfo.text.bgAlpha -1, VInfo.toggleBackgroundTransparency);

    -- Line 8

    -- Line 9
    line = title - textSize * 9;
    text = "Show the logo";
    VInfo:activeMenuLine(line, text, textSize, posX, VInfo.settings.showIcon, VInfo.toggleShowIcon);

    -- Line 10

    -- Line 11

    -- Line 12
    line = title - textSize * 12;
    text = "\"Click on the text to change the setting\""
    setTextColor(unpack(VInfo.colors.default));
    renderText(posX, line, textSize, text);

    -- GroundLine
    line = posY2 + 0.005;
    text = "[X] close";
    VInfo:activeMenuLine(line, text, textSize, posX, nil, VInfo.closeSettingsMenu);

    -- Info
    setTextAlignment(RenderText.ALIGN_RIGHT);
    setTextColor(unpack(VInfo.colors.default));
    text = string.format("\"%s by: %s version: %s\"", self.fullName, self.author, self.version);
    renderText(posX2 - 0.001, line, textSize/1.4, text);

    -- Reset to defaults
    setTextAlignment(0);
    setTextBold(false);
    setTextColor(unpack(VInfo.colors.default));
end;

-- Check for key events
function VInfo:keyEvent( unicode, sym, modifier, isDown )
    self.isModifierPressed = bitAND(modifier, Input.MOD_LALT) > 0;
end;

-- Check for mouse events
function VInfo:mouseEvent(posX, posY, isDown, isUp, button)
    self.isMouseActive = g_inputBinding:getShowMouseCursor();
    if (self.isMouseActive) then
        self.mousePosX = posX;
        self.mousePosY = posY;

        if (button == 1 and isUp) then VInfo:LMBDown(); end;-- action

        if (g_currentMission.player ~= nil and g_currentMission.player.isEntered) then
            g_currentMission.isPlayerFrozen = true;
        end;

    elseif (g_currentMission.isPlayerFrozen) then
        g_currentMission.isPlayerFrozen = false;
    end;
end;
