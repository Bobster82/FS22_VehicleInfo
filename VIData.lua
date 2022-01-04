






-- Vehicle Info
-- Vehicle data
VIData = {};

addModEventListener(VIData);


function VIData.excludedVehicleType(vehicleType)
    if (
        vehicleType == "locomotive" or
        vehicleType == "horse" or
        vehicleType == "handToolMower" or
        vehicleType == "conveyorBelt" or
        vehicleType == "pickupConveyorBelt" or
        vehicleType == "inlineWrapper"
        ) then return false;
    else return true;
    end;
end;

function VIData.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Enterable, specializations) and
           SpecializationUtil.hasSpecialization(Motorized, specializations) and
           SpecializationUtil.hasSpecialization(Drivable, specializations);
end;

function VIData.registerEventListeners(vehicleType)
	local functionNames = {
		"onLoad",
        "onEnterVehicle",
        "onLeaveVehicle",
		"onDelete",
		"saveToXMLFile",
		"onRegisterActionEvents",
		"onUpdateTick",
        "onLoadFinished"
	};

	for _, v in ipairs(functionNames) do
		SpecializationUtil.registerEventListener(vehicleType, v, VIData);
	end;
end;

-- Register events
function VIData:onRegisterActionEvents(_, isOnActiveVehicle)
    local registerEvents = isOnActiveVehicle;
    if (self.vi ~= nil) then
        registerEvents = registerEvents or (self == g_currentMission.controlledVehicle);
    end;

    -- only in active vehicle
    if (registerEvents) then
        local ok, eventId = InputBinding.registerActionEvent(g_inputBinding, "viTogglePark", self, VIData.togglePark, false, true, false, true);
        if ok then g_inputBinding.events[eventId].displayIsVisible = true; end;
    end;
end;

-- Register vehicle functions
function VIData.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "cameraMovement", VIData.cameraMovement);
end;

-- Disables/Enables camera movements when mouse is active/deactive
function VIData:cameraMovement()
    if (VInfo.isMouseActive) then
        if (self.spec_enterable ~= nil and self.spec_enterable.cameras ~= nil) then
            for _, camera in pairs(self.spec_enterable.cameras) do
                camera.allowTranslation = false;
                camera.isRotatable = false;
            end;
        end;
    else
        if (self.spec_enterable ~= nil and self.spec_enterable.cameras ~= nil) then
            for _, camera in pairs(self.spec_enterable.cameras) do
                camera.allowTranslation = true;
                camera.isRotatable = true;
            end;
        end;
    end;

    self.vi.lastMouseState = VInfo.isMouseActive;
end;

-- onUpdateTick
function VIData:onUpdateTick()
    if (self.vi == nil) then return; end;

    self.vi.isHelper = (self:getCurrentHelper() ~= nil);
    self.vi.isActive = (self:getIsMotorStarted() or self.vi.isHelper);
    if (self.vi.isParked and self:getLastSpeed() > 1) then
        self.vi.isParked = false;
    end;

    if (self.vi.lastMouseState ~= VInfo.isMouseActive) then
        self:cameraMovement();
    end;
end;

-- onDelete
function VIData:onDelete()
    if (self.vi == nil) then return; end;
    
    if (VInfo.vehicleList[self.vi.id] == self) then
        table.remove(VInfo.vehicleList, self.vi.id)
        for newId, vehicle in ipairs(VInfo.vehicleList) do
            -- deleted a vehicle, need to adjust the ids to the current list order
            vehicle.vi.id = newId;
        end;
    end;
end;

-- When we leave a vehicle
function VIData:onLeaveVehicle()
    if (VInfo.isMouseActive) then
        VInfo:toggleMouse(false);
    end;
end;

-- When we enter a vehicle
function VIData:onEnterVehicle()
    if (VInfo.isMouseActive) then
        VInfo:toggleMouse(false);
    end;
end;

-- on save, the key is vehicles.vehicle(#).VInfo
function VIData:saveToXMLFile(xmlfile, key)
    local xml = xmlfile.handle;
    if (self.vi == nil) then return; end;

    VInfo:log("Save vehicle: %s, id: %s", self:getName(), self.vi.id);

    removeXMLProperty(xml, key)
    setXMLInt(xml, key .."#id", self.vi.id)
    setXMLBool(xml, key .."#isParked", self.vi.isParked or false)
end;

-- Try to load info from xml file into vehicle (self)
function VIData:onLoad(savegame)
    if (savegame ~= nil) then
        local xml = savegame.xmlFile.handle;
        local key = savegame.key .. "." .. VIData.VISpecName;
        -- Load vehicle from xml
        if (self.vi == nil) then
            if (hasXMLProperty(xml, key)) then
                VInfo:log("%s, Load settings from XML", self:getName());
                self.vi = {};
                self.vi.id = getXMLInt(xml, key.."#id");
                self.vi.isParked = getXMLBool(xml, key.."#isParked") or false;
                VInfo.vehicleList[self.vi.id] = self;
            else
                -- NO XML INFO, prob new vehicle or not saved.
                VInfo:log("No xml info, creating new one")
                VIData:initVehicle(self);
            end;
        else
            VInfo:warning("NO XML INFO");
        end;
    end;
    if (self.vi ~= nil) then
        self.vi.lastMouseState = false;
    end;
end;

-- Init a new vehicle if it doesnt has xml or was just bought.
function VIData:initVehicle(vehicle)
    VInfo:log("New vehicle: %s, -> initVehicle(self)", vehicle:getName())
    local id = #VInfo.vehicleList +1;
    vehicle.vi = {};
    vehicle.vi.id = id;
    vehicle.vi.isParked = false;
    vehicle.vi.lastMouseState = false;
    VInfo.vehicleList[id] = vehicle;
end;

-- onLoadFinished
function VIData:onLoadFinished()
    if (g_currentMission.player ~= nil and g_currentMission.player.farmId ~= nil) then
        -- self is vehicle
        local farmId = g_currentMission.player.farmId;
        local vehFarmId = self.ownerFarmId;
        if (vehFarmId == farmId and self.vi == nil) then
            -- No info from XML, so prob a new vehicle.
            VIData:initVehicle(self);
        end;
    end;
end;
