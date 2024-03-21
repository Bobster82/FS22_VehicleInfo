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


--[[


Version 1.0.0.6
New added:
VInfo.settings.autoParkWithAD
VInfo.settings.showIsLeasedIsMission
VInfo.settings.canMoveText
VInfo.settings.showHelperName
VInfo.settings.maxTextLength is working, need to add settings in menu




]]




-- Main table
VInfo = {};
VInfo.name = "VInfo";
VInfo.fullName = "Vehicle Info";
VInfo.modDir = g_currentModDirectory;
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
VInfo.text.waiting = "Waiting";
VInfo.text.isLeased = "*";
VInfo.text.isMission = "**";
VInfo.text.lowFuel = "LowFuel";

-- Table with colors
VInfo.colors = {
	lightBlue = {0.00, 0.70, 1.00, 1.00},	-- LightBlue
	default =   {1.00, 1.00, 1.00, 1.00},	-- White
	parked =    {0.70, 0.70, 0.70, 0.70},	-- Light Gray
	hovered =   {0.20, 0.20, 1.00, 1.00},	-- Purple
	blocked =   {1.00, 0.00, 0.00, 1.00},	-- Red
	selected =  {1.00, 0.00, 0.00, 1.00},	-- Red
	tankLow =   {0.00, 1.00, 0.00, 1.00},	-- Green
	tankMid =   {1.00, 0.60, 0.00, 1.00},	-- Orange
	tankFull =  {1.00, 0.00, 0.00, 1.00},	-- Red
	inActive =  {0.60, 0.38, 0.38, 1.00},	-- Dark red
	entered =   {0.00, 1.00, 1.00, 1.00},	-- Cyan
	helper =    {0.15, 1.00, 0.15, 1.00},	-- Green/Yellow
	BGColor =   {0.00, 0.00, 0.00, 0.70},	-- Only alpha is working
	BGBlack =   {0.00, 0.00, 0.00, 1.00},	-- Only alpha is working
	isLeased = 	{0.20, 0.40, 1.00, 1.00},	-- Kinda blue
	lowFuel =	{1.00, 0.55, 0.00, 1.00},	-- Dark orange
	waiting = 	{0.10, 0.20, 1.00, 1.00}	-- Blue
};

-- Settings
VInfo.settings = {};
VInfo.settings.canVehicleTabWhenParked = true;		-- Parked vehicle is or isnt able to be tabbed
VInfo.settings.showParkedVehicles = true;			-- Show parked vehicles in the list
VInfo.settings.canVehicleTabWhenInActive = true;	-- Inactive vehicle is or isnt able to be tabbed
VInfo.settings.showInActiveVehicles = true;			-- Show the vehicle in the list when inactive
VInfo.settings.maxImp = 3;							-- Max number of implements attached to show
VInfo.settings.showVInfo = true;					-- Shows the VInfo
VInfo.settings.showSettings = false;				-- Shows the settings menu
VInfo.settings.showIcon = true;						-- Shows the quick action icon
VInfo.settings.showAll = false;						-- Use the icon to quick show/ hide hidden vehicles
VInfo.settings.textSize = {0.008, 0.009, 0.010, 0.011, 0.012, 0.013, 0.014, 0.015, 0.016};      -- TextSize
VInfo.settings.backgroundTransparency = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1};    -- Background transparency
VInfo.settings.showHelperName = false;				-- Shows the current active helper name
VInfo.settings.showIsLeasedIsMission = true;		-- Shows if the vehicle is leased or borrowed for a mission
VInfo.settings.canMoveText = false;					-- Hold LMB on the text to drag the text around
VInfo.settings.autoParkWithAD = true;				-- When ad has finished parking its vehicle, we set it to park
VInfo.settings.maxTextLength = 18;					-- Max length of a text between separators
VInfo.settings.showLowFuelWarning = true;			-- Show warning if vehicle has low fuel (diesel)

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
VInfo.lastMousePosX = 0;
VInfo.lastMousePosY = 0;

VInfo.isMovingText = false;
VInfo.mouseOverTextField = false;


addModEventListener(VInfo);

--################################


-- FS loadMap
function VInfo:loadMap()
	local modDesc = loadXMLFile("modDesc", VInfo.modDir .. "modDesc.xml");
	VInfo.version = getXMLString(modDesc, "modDesc.version");
	VInfo.author = getXMLString(modDesc, "modDesc.author");
	VInfo:log("Vehicle Info, version: %s, Author: %s", VInfo.version, VInfo.author);
	FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, VInfo.RegisterActionEvents);

	VInfo.images["BG_VInfo"] = VInfo.modDir .."Img/BG_VInfo.dds";
	VInfo.images["BG_Menu"] = VInfo.modDir .."Img/BG_Menu.dds";
	VInfo.images["VI_Icon"] = VInfo.modDir .."Img/VI_Icon.dds";
	VInfo.images["VI_Icon_H"] = VInfo.modDir .."Img/VI_Icon_hovered.dds";

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

	ok, eventId = InputBinding.registerActionEvent(g_inputBinding, InputAction.viSetMoveText,self, VInfo.action_viSetMoveText ,false ,true ,false ,true, nil);
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
	if (VInfo.settings.canMoveText) then
		local width = self.maxLineWidth;
		local height = self.maxLineHeight + 0.005;
		local posX = VInfo.text.posX - 0.001;
		local posY = VInfo.text.posY - height;
		

		self.mouseOverTextField = self:isMouseOverArea(posX, posY, width, height);

		if (self.mouseOverTextField) then
			local bg = Overlay.new(VInfo.images["BG_VInfo"], posX, posY, width, height);
			bg:setColor(1,1,1,0.7);
			bg:render();
		end
		
	end
end;

-- Main function
function VInfo:vehicleInfoUpdate()
	self.maxLineWidth = 0;
	self.maxLineHeight = 0;
	local lineNumber = 0;
	local textSize = VInfo.settings.textSize[VInfo.text.size]
	if (VInfo.vehicleList ~= nil) then
		for _, vehicle in ipairs(VInfo.vehicleList) do
			if (vehicle.vi == nil) then return; end;
			local draw = true;

			local isHelper = vehicle:getIsAIActive();
			local isEntered = vehicle:getIsEntered();
			local isActive = vehicle:getIsMotorStarted() or isHelper;
			local isParked = vehicle.vi.isParked;
			local isSelected = (vehicle == VInfo.selectedVehicle);
			local isBlocked = VInfo:isVehicleBlocked(vehicle);
			vehicle.vi.isBlocked = isBlocked;
			local isWaiting = VInfo:getIsWaiting(vehicle);
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

				-- Leased or mission vehicle
				if (VInfo.settings.showIsLeasedIsMission) then VInfo:getIsLeasedIsMission(vehicle, Obj)	end;

				-- Check for low fuel level
				if VInfo.settings.showLowFuelWarning and VInfo.getIsLowFuel(vehicle) then
					Obj[#Obj+1] = {text = VInfo.text.lowFuel, color = VInfo.colors.lowFuel}
				end
				-- Name of the vehicle
				local name = #Obj+1;
				Obj[name] = {text = tostring(vehicle:getName())};

				-- Check if its a combine (need for filllevel check)
				if vehicle.spec_combine ~= nil then
					local cb = #Obj+1;
					Obj[cb] = {}; Obj[cb].text, Obj[cb].color = VInfo:getFillUnitInfo(vehicle, 1); end;

				-- Check if vehicle has trailers or tools with fillunits
				VInfo:getAttachedInfo(vehicle, Obj);

				-- Display player name or if helper active and or helper name.
				VInfo:getActiveName(vehicle, isEntered, isHelper, name, Obj);

				-- Combine text for calculate width for mouse over function.
				if (VInfo.isMouseActive and not VInfo.settings.showSettings) then
					local text = "";
					for _,v in ipairs(Obj) do
						if (v.text ~= nil) then
							if (string.len(v.text) > VInfo.settings.maxTextLength) then
								v.text = string.sub(v.text, 0, VInfo.settings.maxTextLength);
								v.text = v.text.."..";
							end;
							text = string.format("%s%s%s", text, VInfo.text.seperator, v.text)
						end;
					end;
					local maxwidth = getTextWidth(textSize, text)
					local maxHeight = getTextHeight(textSize, text) * (lineNumber + 1);

					if (self.maxLineWidth < maxwidth) then
						self.maxLineWidth = maxwidth;
					end;
					if (self.maxLineHeight < maxHeight) then
						self.maxLineHeight = maxHeight;
					end
					local posY = VInfo.text.posY - (textSize * (lineNumber+1));
					isHovered = VInfo:isMouseOverText(text, textSize, VInfo.text.posX, posY);
				end;

				-- Set temp vehicle for hovered
				if (isHovered) then VInfo.vehicle = vehicle;
				elseif (not isHovered and VInfo.vehicle == vehicle) then VInfo.vehicle = nil; end;

				-- Setting colors
				if (isHelper and not isEntered) then Obj[name].color = VInfo.colors.helper; end;
				if (isBlocked and not isEntered and not isWaiting) then Obj[speed].color = VInfo.colors.blocked; Obj[speed].text = VInfo.text.blocked; --  and not VInfo:getIsCPActive(vehicle)
				elseif (isWaiting and not isEntered) then Obj[speed].color = VInfo.colors.waiting; Obj[speed].text = VInfo.text.waiting; end;
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
		local posX = self.text.posX - 0.001;
		local posY = self.text.posY;
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
	if (sym == 27) then -- Escape key (enter menu), we dont want to be frozen in game menu (prevents using spacebar)
		if (VInfo.settings.showSettings) 		then VInfo.closeSettingsMenu(); end;
		if (VInfo.settings.canMoveText) then VInfo.settings.canMoveText = false; end;
		if (g_currentMission.isPlayerFrozen) 	then g_currentMission.isPlayerFrozen = false; end;
	end;
end;

-- Check for mouse events
function VInfo:mouseEvent(posX, posY, isDown, isUp, button)
	self.isMouseActive = g_inputBinding:getShowMouseCursor();
	if (self.isMouseActive) then
		self.mousePosX = posX;
		self.mousePosY = posY;

		if (self.settings.canMoveText and self.mouseOverTextField) then
			self:movingText(posX, posY, isDown, isUp, button);
		end;

		if (button == 1 and isUp) then VInfo:LMBDown(); end;-- action

		if (g_currentMission.player ~= nil and g_currentMission.player.isEntered) then
			if (g_gui.currentGuiName == "") then
				g_currentMission.isPlayerFrozen = true;
			end;
		end;

	elseif (g_currentMission.isPlayerFrozen) then
		g_currentMission.isPlayerFrozen = false;
	end;
end;

function VInfo:movingText(posX, posY, isDown, isUp, button)
	if (button == 1 and isDown) then
		self.isMovingText = true
		self.lastMousePosX = posX
		self.lastMousePosY = posY
	elseif button == 1 and isUp then
		self.isMovingText = false;
	end
	if (self.isMovingText) then
		local diffX = posX - self.lastMousePosX;
		local diffY = posY - self.lastMousePosY;
		self.text.posX = self.text.posX + diffX;
		self.text.posY = self.text.posY + diffY;
		self.lastMousePosX = posX;
		self.lastMousePosY = posY;
		
	end
end

