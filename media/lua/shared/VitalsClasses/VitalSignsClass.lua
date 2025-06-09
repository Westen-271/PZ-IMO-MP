require "ISBaseObject";

local BLOOD_TYPES =
{
    { type = "O+", chance = 37.4, canReceiveFrom = {"O+", "O-"} },

    { type = "O-", chance = 6.6, canReceiveFrom = { "O-" } },

    { type = "A+", chance = 35.7, canReceiveFrom = { "O+", "O-", "A+", "A-" } },

    { type = "A-", chance = 4.1, canReceiveFrom = { "O-", "A-" } },

    { type = "B+", chance = 8.5, canReceiveFrom = {"O+", "O-", "B+", "B-"} },

    { type = "B-", chance = 1.5, canReceiveFrom = { "O-", "B-" } },

    { type = "AB+", chance = 3.4, canReceiveFrom = { "O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-" } },

    { type = "AB-", chance = 0.6, canReceiveFrom = { "O-", "A-", "B-", "AB-" } },
};

local DEFAULT_BLOOD_TYPE = { type = "O+", canReceiveFrom = {"O+", "O-"} };

local DEFAULT_BLOOD_VOLUME = 5000;

VitalSigns = ISBaseObject:derive("IMOVitalSigns");

--[[
    Generates the baseline vital signs for the character, using "optimal" vital signs.
    The optimal vitals are then offset by a random amount in order to simulate the differences between people.
--]]
function VitalSigns:generateBaselineVitals()
    local baselineVitals = 
    {
        heartRate = { 
            base = 80,
            offset = ZombRand(10), 
            isOffsetNegative = ZombRand(2) 
        },

        bloodPressure = { 

            systolic = {
                base = 120,
                offset = ZombRand(20),
                isOffsetNegative = ZombRand(2),
            },

            diastolic = {
                base = 80,
                offset = ZombRand(10),
                isOffsetNegative = ZombRand(2),
            },
        },

        respRate = { 
            base = 15, 
            offset = ZombRand(3), 
            isOffsetNegative = ZombRand(2),
        },
    }

    if baselineVitals.heartRate.isOffsetNegative == 1 then
        baselineVitals.heartRate.offset = -math.abs(baselineVitals.heartRate.offset);
    end

    if baselineVitals.bloodPressure.systolic.isOffsetNegative == 1 then
        baselineVitals.bloodPressure.systolic.offset = -math.abs(baselineVitals.bloodPressure.systolic.offset);
    end

    if baselineVitals.bloodPressure.diastolic.isOffsetNegative == 1 then
        baselineVitals.bloodPressure.diastolic.offset = -math.abs(baselineVitals.bloodPressure.diastolic.offset);
    end

    if baselineVitals.respRate.isOffsetNegative == 1 then
        baselineVitals.respRate.offset = -math.abs(baselineVitals.respRate.offset);
    end

    self.baselines = {
        heartRate = baselineVitals.heartRate.base + baselineVitals.heartRate.offset,

        bloodPressure = {
            systolic = baselineVitals.bloodPressure.systolic.base + baselineVitals.bloodPressure.systolic.offset,
            diastolic = baselineVitals.bloodPressure.diastolic.base + baselineVitals.bloodPressure.diastolic.offset,
        },

        respRate = baselineVitals.respRate.base + baselineVitals.respRate.offset;
    };
end


function VitalSigns:allocateCharacterBloodType()
    if not self.character then return end;

    local weight = 0;
    local allocatedBloodType = {};

    -- Calculate total value of all blood type chances.
    for i, bloodType in ipairs(BLOOD_TYPES) do
        if BLOOD_TYPES[i].chance then
            weight = weight + BLOOD_TYPES[i].chance;
        end
    end

    -- Get random num.
    local randomNum = ZombRand(weight);

    local iteratedWeight = 0;
    for i, bloodType in ipairs(BLOOD_TYPES) do
        iteratedWeight = iteratedWeight + bloodType.chance;

        if randomNum < iteratedWeight then
           allocatedBloodType = bloodType;
        end
    end

    self.bloodType = allocatedBloodType;
end

function VitalSigns:generateBloodVolume()
    local offset = ZombRand(750);
    local posOrNegOffset = ZombRand(2);

    if posOrNegOffset == 1 then
        offset = -math.abs(offset);
    end

    self.bloodVolume = (5000 + offset) or 5000;
    self.maxBloodVolume = (5000 + offset) or 5000;
end

function VitalSigns:setFromBaseline()
    if not self.character then return end;

    if not self.baselines then
        self:generateBaselineVitals();
    end

    -- Iterate through baseline vitals and copy these to vitals.
    local tempVitals = { unpack(self.baselines); }
    if not tempVitals then return end;

    self.vitals = tempVitals;

    print("Vitals have been set from baseline.");
    for k, v in pairs(self.vitals) do
        print("Key: " .. tostring(k));
        
        if type(self.vitals[k]) == "table" then
            for i, j in pairs(self.vitals[k]) do
                print("     Key: " .. tostring(i));
                print("     " .. tostring(self.vitals[k][i]));
            end
        end
    end

    self:save();
end 

-- Calculate current blood loss in ml based on all current injuries.
function VitalSigns:calculateCurrentBloodLoss()
    if not self.character then return end;

    if not self.character:isAlive() then return end;
    if self.character:isGodMod() then return end; -- No point if they're invincible.

    local bodyDamage = self.character:getBodyDamage();
    if not bodyDamage then return end;

    -- Iterate through each body part to get the blood loss amount.
    print("Your total bleed level is:");
    print(tostring(self.character.bleedingLevel or "BLEEDING LEVEL NOT FOUND"));
    for i = 0, bodyDamage:getBodyParts():size() - 1 do
        local part = bodyDamage:getBodyParts():get(i);
        if part then

        end
    end

end

function VitalSigns:update()
    -- Step 1 is to calculate total outgoing blood loss.
    local losingBlood = self:calculateCurrentBloodLoss();

    -- Then how any other injuries affect it.
end

function VitalSigns:save()
    if not self.character then return end;

    self.character:getModData().IMO_Vitals = self;
    self.character:transmitModData();
end

function VitalSigns:new(player)
    local o = {};
    setmetatable(o, self);
    self.__index = self;

    o.character = player;
    o.baselines = {};
    o.vitals = {};
    o:generateBloodVolume();
    o:generateBaselineVitals(); -- As the vitals themselves will be updated if they do not exist next check, this does not need to copy across to the main object values.
    o:allocateCharacterBloodType();
    return o;
end

return VitalSigns;