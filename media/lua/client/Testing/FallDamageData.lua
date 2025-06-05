if isServer() then return end

local function TEST_OnPlayerUpdate(player)
    if player:getFallTime() > 50 then
        print("Fall time: " .. tostring(player:getFallTime()));
        player:setLastFallSpeed(0.0);
        player:setFallTime(0.0);
    end
end

Events.OnPlayerUpdate.Add(TEST_OnPlayerUpdate);