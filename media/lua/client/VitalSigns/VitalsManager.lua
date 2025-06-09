require "VitalClasses/VitalSignsClass"

VitalsManager = {};

VitalsManager.DEFAULT_INCAP_THRESHOLD = 25;

function VitalsManager.SetVitalsFromBaseline(player)

    local vitals = player:getModData().IMO_Vitals;
    if not vitals then return end;

    vitals:setFromBaseline();
end

function VitalsManager.OnCreatePlayer(playerNum, player)

    if not player then return end;

    local modData = player:getModData();
    if not modData then return end;

    if not modData.IMO_Vitals or #modData.IMO_Vitals == 0 then
        local vitals = VitalSigns:new(player);

        for i, v in ipairs(vitals) do
            print("VITALS ---");
            print(string.format("%s", vitals[i]));
        end

        player:getModData().IMO_Vitals = vitals;
        player:transmitModData();
    end
end

Events.OnCreatePlayer.Add(VitalsManager.OnCreatePlayer);