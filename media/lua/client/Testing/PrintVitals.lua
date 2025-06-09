function PrintIMOVitals(player)
    local modData = player:getModData();

    if not modData.IMO_Vitals then
        print("IMO Vitals do not exist!");
        return
    end

    print("Blood Volume: " .. tostring(modData.IMO_Vitals.bloodVolume));
    print("Max Blood Volume:" .. tostring(modData.IMO_Vitals.maxBloodVolume));
end