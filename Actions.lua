--================--
-- GLOBAL ACTIONS --
--================--


-- Left Mouse button click
function VInfo:LMBDown()
    if not (VInfo.settings.showVInfo or VInfo.settings.showSettings) then return; end;

    if (VInfo.vehicle ~= nil and VInfo.isModifierPressed and not VInfo.settings.showSettings) then

        -- Modifier pressed. We are with mouse over 'vehicle' in list, select or sort vehicle in the list
        if (VInfo.selectedVehicle == nil) then
            VInfo.selectedVehicle = VInfo.vehicle;
        elseif (VInfo.selectedVehicle == VInfo.vehicle) then
            VInfo.selectedVehicle = nil;
        elseif (VInfo.selectedVehicle ~= VInfo.vehicle) then
            VInfo:SortVehicle(VInfo.vehicle);
        end;

    elseif (VInfo.vehicle ~= nil and VInfo.selectedVehicle == nil and not VInfo.isModifierPressed) then
        -- We are with mouse over 'vehicle' in list
        VInfo:SwitchToVehicle(VInfo.vehicle);
    elseif (VInfo.button1 ~= nil) then
        -- We have an active button.
        VInfo.button1();
        VInfo.button1 = nil;
    end;

end;

-- Switch to next vehicle in our list
function VInfo:action_viSwitchToNextVehicle(actionName, keyStatus, arg3, arg4, arg5)
    if (#VInfo.vehicleList > 0) then
        local canTabIA = VInfo.settings.canVehicleTabWhenInActive;
        local canTabP = VInfo.settings.canVehicleTabWhenParked;

        local index = 1;
        local currentIndex = 0;
        local nextVehicle = nil;

        for i, vehicle in ipairs(VInfo.vehicleList) do
            if (vehicle:getIsEntered()) then currentIndex = i; end;
        end;

        while (true) do
            if (index > #VInfo.vehicleList) then break; end;

            local vehicle = VInfo.vehicleList[index];
            -- 1st vehicle we can tab to when we are at end of list (or not in a vehicle)
            if (nextVehicle == nil and VInfo.vehicleList[currentIndex] ~= vehicle) then
                if (not vehicle.vi.isActive and canTabIA and not vehicle.vi.isParked) then
                    nextVehicle = vehicle;
                elseif (vehicle.vi.isParked and canTabP) then
                    nextVehicle = vehicle;
                elseif (vehicle.vi.isActive) then
                    nextVehicle = vehicle;
                end;
            end;

            if (index > currentIndex and VInfo.vehicleList[currentIndex] ~= vehicle) then
                if (not vehicle.vi.isActive and canTabIA and not vehicle.vi.isParked) then
                    nextVehicle = vehicle; break;
                elseif (vehicle.vi.isParked and canTabP) then
                    nextVehicle = vehicle; break;
                elseif (vehicle.vi.isActive) then
                    nextVehicle = vehicle; break;
                end;
            end;

            index = index +1;
        end; -- end while

        if (nextVehicle ~= nil) then
            g_currentMission:requestToEnterVehicle(nextVehicle);
        else VInfo:log("No vehicle found to tab to, 'action_viSwitchToNextVehicle'")
        end;

    end;

end;

-- Switch to previous vehicle in our list
function VInfo:action_viSwitchToPreviousVehicle(actionName, keyStatus, arg3, arg4, arg5)
    if (#VInfo.vehicleList > 0) then
        local canTabIA = VInfo.settings.canVehicleTabWhenInActive;
        local canTabP = VInfo.settings.canVehicleTabWhenParked;

        local index = #VInfo.vehicleList;
        local currentIndex = 0;
        local nextVehicle = nil;

        for i, vehicle in ipairs(VInfo.vehicleList) do
            if (vehicle:getIsEntered()) then currentIndex = i; end;
        end;

        while true do
            if (index < 1) then break; end;

            local vehicle = VInfo.vehicleList[index];
            -- 1st vehicle we can tab to when we are at end of list
            if (nextVehicle == nil and VInfo.vehicleList[currentIndex] ~= vehicle) then
                if (not vehicle.vi.isActive and canTabIA and not vehicle.vi.isParked) then
                    nextVehicle = vehicle;
                elseif (vehicle.vi.isParked and canTabP) then
                    nextVehicle = vehicle;
                elseif (vehicle.vi.isActive) then
                    nextVehicle = vehicle;
                end;
            end;

            if (index < currentIndex and VInfo.vehicleList[currentIndex] ~= vehicle) then
                if (not vehicle.vi.isActive and canTabIA and not vehicle.vi.isParked) then
                    nextVehicle = vehicle; break;
                elseif (vehicle.vi.isParked and canTabP) then
                    nextVehicle = vehicle; break;
                elseif (vehicle.vi.isActive) then
                    nextVehicle = vehicle; break;
                end;
            end;

            index = index -1;
        end;

        if (nextVehicle ~= nil) then
            g_currentMission:requestToEnterVehicle(nextVehicle)
        else VInfo:log("No vehicle found to tab to, 'action_viSwitchToPreviousVehicle'");
        end;

    end;
end;

-- Set the vehicle parking
function VIData:togglePark()
    if (self.vi == nil) then return; end;

    self.vi.isParked = not self.vi.isParked;
    if (self.spec_motorized.isMotorStarted and self.vi.isParked) then
        if (self.stopMotor ~= nil) then
            self:stopMotor();
        end;
    elseif (not self.spec_motorized.isMotorStarted and not self.vi.isParked) then self:startMotor();
    end;
end;
