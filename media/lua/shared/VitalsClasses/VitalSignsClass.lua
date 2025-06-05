--[[
    Generates the baseline vital signs for the character, using "optimal" vital signs.
    The optimal vitals are then offset by a random amount in order to simulate the differences between people.
--]]
function VitalSigns:generateBaselineVitals()
    local baselineOffset = ZombRand(10);
    local offsetIsNegative = ZombRand(2);

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
            systolic = baselineVitals.bloodPressure.systolic.base + baselineVitals.bloodPressure.systolic.offset;
        },
        respRate = baselineVitals.respRate.base + baselineVitals.respRate.offset;
    };
end

function VitalSigns:new(player)
    local o = {};
    setmetatable(o, self);
    self.__index == self;

    o.character = player;
    o:generateBaselineVitals(); -- As the vitals themselves will be updated if they do not exist next check, this does not need to copy across to the main object values.
    return o;
end