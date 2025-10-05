--[[
    IMMERSIVE MEDICAL OVERHAUL - Subsystems > BloodPressureManager.lua.

    This class is responsible for managing a character's blood pressure (systolic and diastolic).

    Author: Westie
--]]

require "ISBaseObject";
BloodPressureManager = ISBaseObject:derive("IMOPlayerBloodPressureManager");

IMOLoggingUtils = IMOLoggingUtils or {};

---Creates a new BloodPressureManager.
---@param weight number The character's weight from IsoPlayer:getNutrition():getWeight().
---@param fitnessLvl number The character's fitness perk level.
---@return table BloodPressureManager The newly created blood manager to be associated with a parent MedicalSystem.
function BloodPressureManager:new(weight, fitnessLvl)
    local o = {};
    setmetatable(o, self);
    self.__index = self;

    o.weight = weight;
    o.fitnessLvl = fitnessLvl;

    o:calculateBaselinePressure();
    return o;
end

---Calculates the baseline systolic and diastolic pressure for a player based on their weight.
---Sources: https://pmc.ncbi.nlm.nih.gov/articles/PMC11125317/, https://pzwiki.net/wiki/High_Weight
function BloodPressureManager:calculateBaselinePressure()

    -- Between 80 and 85, every 1kg of weight increases possible BP by 2.
    -- Between 85 and 100, every 1kg of weight increases possible BP by 3.

    -- So at weight 83, that's (3*2=6) possible for systolic and diastolic, bringing max blood pressure between 120/80 and 126/86.
    -- At weight 95, that's (95-80=15) * 3 = 45 possible, bringing max blood pressure between 120/80 and 165/125.

    -- Then every fitness level above 5 reduces the range by 1%. So at level 10, that's up to 5% subtracted from 120/80.
    -- (120 * 0.05 = 6) (80 * 0.05 = 4) so possible up to 112/76.

    local baselineBP = { systolic = 120, diastolic = 80 };

    local OVERWEIGHT_POSSIBLE_INCREASE = 2;
    local OBESE_POSSIBLE_INCREASE = 3;
    local DEFAULT_WEIGHT = 80;
    local OBESE_WEIGHT = 85;

    if not self.weight or not self.fitnessLvl then
        IMOLoggingUtils.logError("BloodPressureManager - attempted to calculate baseline pressure but one or more required args is nil.");
        IMOLoggingUtils.errorDumpParams({ weight = self.weight, fitnessLvl = self.fitnessLvl });
        return;
    end

    local newMax = 0;
    local overweightAmount = 0;

    if self.weight > DEFAULT_WEIGHT and self.weight <= OBESE_WEIGHT then
        overweightAmount = (self.weight - DEFAULT_WEIGHT) * OVERWEIGHT_POSSIBLE_INCREASE;
    elseif self.weight > OBESE_WEIGHT then
        overweightAmount = (self.weight - DEFAULT_WEIGHT) * OBESE_POSSIBLE_INCREASE;
    end

    newMax = ZombRand(overweightAmount + 1);

    local newSystolic = baseLineBP.systolic + newMax;
    local newDiastolic = baselineBP.diastolic + newMax;

    self.baseline = { systolic = newSystolic, diastolic = newDiastolic };
    self.systolic = newSystolic;
    self.diastolic = newDiastolic;
end
