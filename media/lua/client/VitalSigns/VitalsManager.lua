VitalsManager = {};

local VitalsManager.DEFAULT_VITAL_SIGNS =
{
    heartRate = 80,
    bloodPressure = { sys = 120, dia = 80 },
    respirationRate = 14,
};

local VitalsManager.BLOOD_TYPES =
{
    { type = "O+", chance = 37.4, canReceiveFrom = {"O+", "O-"} },

    { type = "O-", chance = 6.6, canReceiveFrom = { "O-" } },

    { type = "A+", chance = 35.7, canReceiveFrom = { "O+", "O-", "A+", "A-" } },

    { type = "A-", chance = 4.1, canReceiveFrom = { "O-", "A-" } }

    { type = "B+", chance = 8.5, canReceiveFrom = {"O+", "O-", "B+", "B-"} },

    { type = "B-", chance = 1.5, canReceiveFrom = { "O-", "B-" } },

    { type = "AB+", chance = 3.4, canReceiveFrom = { "O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-" } },

    { type = "AB-", chance = 0.6, canReceiveFrom = { "O-", "A-", "B-", "AB-" } },
};

local VitalsManager.DEFAULT_BLOOD_TYPE = { type = "O+", canReceiveFrom = {"O+", "O-"} }; -- For if something goes catastrophically wrong, use this blood type to prevent gamebreaking errors.


function VitalsManager.SelectRandomBloodType()
    local weight = 0;

    -- Calculate total value of all blood type chances.
    for _, bloodType in ipairs(VitalsManager.BLOOD_TYPES) do
        if bloodType.chance then
            weight = weight + bloodType.chance;
        end
    end

    -- Get random num.
    local randomNum = ZombRand(weight);

    local iteratedWeight = 0;
    for i, bloodType in ipairs(VitalsManager.BLOOD_TYPES) do
        iteratedWeight = iteratedWeight + bloodType.chance;

        if randomNum < iteratedWeight then
            return bloodType;
        end
    end

end

function VitalsManager.AllocateCharacterBloodType(player)
    if not player then return end;

    local allocatedBloodType = VitalsManager.SelectRandomBloodType();
    if not allocatedBloodType then
        print("[VitalsManager] Critical error occurred when generating blood type for player " .. player:getUsername() .. " - allocating default blood type: " .. VitalsManager.DEFAULT_BLOOD_TYPE.type);
        allocatedBloodType = VitalsManager.DEFAULT_BLOOD_TYPE;
    end

    player:getModData().IMO_Vitals.BloodType = allocatedBloodType;
end

function VitalsManager.OnCreatePlayer(playerNum, player)

    if not player then return end;

    local modData = player:getModData();
    if not modData then return end;

    if not modData.IMO_Vitals then
        modData.IMO_Vitals = {};
        VitalsManager.AllocateCharacterBloodType(player);
    end
end


Events.OnCreatePlayer.Add(VitalsManager.OnCreatePlayer);