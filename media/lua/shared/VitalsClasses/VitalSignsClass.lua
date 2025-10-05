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
    isOffsetNegative is the chance that the baseline vitals are lower than the optimal, and vice versa.

    Optimal HR = 80
    Optimal BP = 120/80
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
    for _, bloodType in ipairs(BLOOD_TYPES) do
        if bloodType and bloodType.chance then
            weight = weight + bloodType.chance;
        end
    end

    -- Get random num.
    local randomNum = ZombRand(weight);

    local iteratedWeight = 0;
    for _, bloodType in ipairs(BLOOD_TYPES) do
        if bloodType then
            iteratedWeight = iteratedWeight + bloodType.chance;

            if randomNum < iteratedWeight then
                allocatedBloodType = bloodType;
            end
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
    self.desiredVitals = tempVitals;

    print("Vitals have been set from baseline.");
    self:save();
end

--[[
    Helper functions for quick calculations that do not need to be repeated.
--]]

function VitalSigns:getCurrentBloodVolumePercentage()
    if not self.bloodVolume or not self.maxBloodVolume then return 0 end;

    return math.floor((self.bloodVolume / self.maxBloodVolume) * 100);
end

function VitalSigns:getCurrentBloodVolumeMultiplier()
    if not self.bloodVolume or not self.maxBloodVolume then return 0.0 end;

    return math.floor((self.bloodVolume / self.maxBloodVolume));
end


--[[
        Calculate current blood loss in ml based on all current injuries.
        Where nil is returned, there was an error. A blood loss of 0 means the character is still alive but is not bleeding or not capable
        of losing blood.
--]] 

function VitalSigns:calculateCurrentBloodLoss()
    if not self.character then return nil end;

    if not self.character:isAlive() then return nil end;
    if self.character:isGodMod() then return 0 end; -- No point if they're invincible.

    local bodyDamage = self.character:getBodyDamage();
    if not bodyDamage then return nil end;

    local totalBleedAmount = 0;

    -- Iterate through each body part to get the blood loss amount.
    for i = 0, bodyDamage:getBodyParts():size() - 1 do
        local part = bodyDamage:getBodyParts():get(i);
        if part and part:bleeding() then
            -- Get the bleed level from mod data.
            local partMod = part:getModData();
            if partMod and partMod.IMO_Data then
                totalBleedAmount = totalBleedAmount + (partMod.IMO_Data.bleedAmount or 0);
            end
        end
    end

    return totalBleedAmount;
end

--[[
    To be called from VitalSigns:update() or when an immediate calculation needs to be done for traumatic injuries.
    Returns % of total blood volume lost.
--]]
function VitalSigns:updateBloodLoss(lossAmt)
    if not lossAmt then return end;

    if lossAmt > 0 then
        local prevBloodVolPercent = self:getCurrentBloodVolumePercentage();

        self.bloodVolume = self.bloodVolume - lossAmt;
        if self.bloodVolume <= 0 then
            self.bloodVolume = 0;
        end

        local newBloodVolPercent = self:getCurrentBloodVolumePercentage();

        return math.floor(prevBloodVolPercent - newBloodVolPercent);
    end
end

function VitalSigns:updateVitalsFromBloodVolume(totalPercentLost)
    if not totalPercentLost then
        error("[IMO] VitalSigns:updateVitalsFromBloodVolume called with totalPercentLost returned as nil.");
        return;
    end

    -- Source: https://www.ncbi.nlm.nih.gov/books/NBK470382/
    -- Categories of blood loss:
        -- Class 1 - 100-85%: heart rate minimally elevated, no change in other vitals.
        -- Class 2 - 84%-70%: heart rate between 100 and 120, pulse pressure (systolic - diastolic) is between 25% and 30% of total, RR is 20-24.
        -- Class 3 - 69%-60%: significant BP drop, HR > 120. RR 25-30.
        -- Class 4 - 59% and lower: low blood pressure with PP < 25, BPM between 120 and 200.

    if totalPercentLost < 15 then -- Stage 1

    elseif totalPercentLost < 30 then -- Stage 2 

    elseif totalPercentLost < 40 then -- Stage 3 

    elseif totalPercentLost > 40 then -- Stage 4

    elseif totalPercentLost > 55 then -- uh oh

    end
end

function VitalSigns:update()
    -- Step 1 is to calculate total outgoing blood loss.
    local bloodToLose = self:calculateCurrentBloodLoss();
    local totalPercentLost = self:updateBloodLoss(bloodToLose);

    if not totalPercentLost then
        error("[IMO] VitalSigns:update called with totalPercentLost returned as nil.");
        return;
    end

    VitalSigns:updateVitalsFromBloodVolume(totalPercentLost);
    
    -- Then how any other injuries affect it.
end

--[[
    This is different to VitalSigns:update() - update sets the DESIRED vitals. OnTick works towards it.
    This simulates the heart pumping and the flow of blood round the body.

    e.g. Current heart rate is 60, desired is 80, the gap is 20, so each tick will add 20%.
    Current systolic BP is 100, desired is 105, the gap is 5. Each tick will add 5%.
--]] 
function VitalSigns:onTick()
    -- Heart rate.


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