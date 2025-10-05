if isServer() then return end;

local vitalData;

function EveryOneMinute()
    local player = getPlayer();

    -- Calculate the player's vitals based on current health condition.
    if not vitalData then
        vitalData = player:getModData().IMO_Vitals;
    end

    if getmetatable(vitalData) ~= IMOVitalSigns then
        print("EveryOneMinute - not instanceof")
        player:getModData().IMO_Vitals = VitalSigns:new(player);
    end

    if not vitalData.bloodVolume or not vitalData.maxBloodVolume then
        return 
    end

    vitalData:update();
    vitalData:save();

    local bloodVolumeAsPercentage = math.ceil((vitalData.bloodVolume / vitalData.maxBloodVolume) * 100);

    local sandboxVars = SandboxVars;
    print(sandboxVars.IMO);
    
    local incapThreshold = SandboxVars.IMO.IncapacitationSettings_IncapacitationHealthThreshold;

    if bloodVolumeAsPercentage < incapThreshold then
        -- Incapacitate
        print("Incap");
    end
end

function OnPlayerUpdate(player)
    if getPlayer() ~= player then return end; -- Stops unnecessary checks.

    -- Calculate vitals.
    if not vitalData then
        vitalData = player:getModData().IMO_Vitals;
    end

    if getmetatable(vitalData) ~= IMOVitalSigns then
        player:getModData().IMO_Vitals = VitalSigns:new(player);
    end

    if not vitalData.vitals or #vitalData.vitals == 0 then
        vitalData:setFromBaseline();
    end

    -- Work towards the new 
end

Events.OnPlayerUpdate.Add(OnPlayerUpdate);
Events.EveryOneMinute.Add(EveryOneMinute);