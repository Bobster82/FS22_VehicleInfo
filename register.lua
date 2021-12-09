--
-- Vehicle Info
-- register Specialization
--
--

local modName = g_currentModName
local modDir = g_currentModDirectory

-- Load source files
source(Utils.getFilename("VInfo.lua", modDir));
source(Utils.getFilename("VIData.lua", modDir));
source(Utils.getFilename("Actions.lua", modDir));
source(Utils.getFilename("Functions.lua", modDir));

-- Save Configuration when saving savegame
FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, VInfo.saveSavegame)

VIRegister = {};

if VIData.VISpecName == nil then
    VIData.VISpecName = modName .. ".VIData";
end;

if g_specializationManager:getSpecializationByName("VIData") == nil then
    g_specializationManager:addSpecialization("VIData", "VIData", Utils.getFilename("VIData.lua", modDir), nil);
end;

-- attach our spec to vehicles
function valVehicleTypes(typeManager)
    if VIData == nil then
        VInfo:log("Unable to add specialization 'VIData'");
        return;
    end;

    for vehicleType, typeDef in pairs(typeManager.types) do
		if (typeDef.hasVISpec == true) then print ("typeDef.hasVISpec == true || " .. tostring(vehicleType)) end;
        if typeDef ~= nil and VIData.excludedVehicleType(vehicleType) and (not typeDef.hasVISpec == true) then
			if VIData.prerequisitesPresent(typeDef.specializations) then
				if typeDef.specializationsByName[VIData.VISpecName] == nil then
					VInfo:log("VIData attached to vehicleType: %s", tostring(vehicleType));
					typeManager:addSpecialization(vehicleType, VIData.VISpecName);
					typeDef.hasVISpec = true;
				end;
			end;
		end;
    end;
end;
TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, valVehicleTypes);

function VIRegister:loadMap(name)
end;

function VIRegister:deleteMap()
end;

function VIRegister:mouseEvent(posX, posY, isDown, isUp, button)
end;

function VIRegister:keyEvent(unicode, sym, modifier, isDown)
end;

function VIRegister:update(dt)
end;

function VIRegister:draw()
end;


addModEventListener(VIRegister);
