if isServer() then return end

local function TEST_OnPlayerUpdate(player)
    if player:getFallTime() > 50 then
        print("Fall time: " .. tostring(player:getFallTime()));
        player:setLastFallSpeed(0.0);
        player:setFallTime(0.0);
    end

    local vitals = player:getModData().IMO_Vitals;
    if not vitals then return end;

    if player:getCurrentState() and player:getCurrentState():getName() == "PlayerFallingState" then
        if vitals.wasFallingLastUpdate and vitals.wasFallingLastUpdate == true then

            vitals.fallingTime = (player:getModData().IMO_Vitals.fallingTime or 0) + 1;
        end

        vitals.wasFallingLastUpdate = true;
    else
        if not vitals.wasFallingLastUpdate or vitals.wasFallingLastUpdate == false then
            
        end
    end
end

Events.OnPlayerUpdate.Add(TEST_OnPlayerUpdate);