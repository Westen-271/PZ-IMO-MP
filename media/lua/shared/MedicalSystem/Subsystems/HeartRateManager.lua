--[[
    IMMERSIVE MEDICAL OVERHAUL - Subsystems > HeartRateManager.lua.

    This class is responsible for managing a character's heart rate.

    Author: Westie
--]]

require "ISBaseObject";
HeartRateManager = ISBaseObject:derive("IMOPlayerHeartRateManager");

IMOLoggingUtils = IMOLoggingUtils or {};

---Creates a new HeartRateManager.
---@param isFemale boolean IsoPlayer:isFemale().
---@param weight number The character's weight from IsoPlayer:getNutrition():getWeight().
---@param fitnessLvl number The character's fitness perk level.
---@return table HeartRateManager The newly created heart rate manager to be associated with a parent MedicalSystem.
function HeartRateManager:new(isFemale, weight, fitnessLvl)
    local o = {};
    setmetatable(o, self);
    self.__index = self;

    o.isFemale = isFemale;
    o.weight = weight;
    o.fitnessLvl = fitnessLvl;

    o:calculateBaselineHeartRate();
    return o;
end

---Calculates the baseline heart rate for the character 
---Source: https://my.clevelandclinic.org/health/articles/17644-women-and-heart-rate
function HeartRateManager:calculateBaselineHeartRate()

    if self.isFemale == nil or not self.weight or not self.fitnessLvl then
        IMOLoggingUtils.logError("HeartRateManager - attempted to calculate baseline BPM but one or more required args is nil.");
        IMOLoggingUtils.errorDumpParams({ isFemale = self.isFemale, weight = self.weight, fitnessLvl = self.fitnessLvl });
        return;
    end

    local defaultBPM = ZombRand(70, 80);
    if self.isFemale then
        defaultBPM = defaultBPM + ZombRand(1, 10);
    end

    -- Completely arbitrary, for every 1 weight above 80 is a potential extra max BPM.
    local overweightAddition = 0;
    if self.weight > 80 then
        local overweightBy = self.weight - 80;
        overweightAddition = ZombRand(overweightBy);
    end
    
    -- Completely arbitrary, but resting heart rate should be affected by fitness level. For each level above 7, subtract a random amount between 1 and 10.
    local fitnessLvlDiff = self.fitnessLvl - 7;
    if fitnessLvlDiff < 0 then fitnessLvlDiff = 0 end;

    local fitnessSubtraction = 0;
    if fitnessLvlDiff > 0 then
        for i = 1, fitnessLvlDiff do
            fitnessSubtraction = fitnessSubtraction + ZombRand(1, 10);
        end
    end

    defaultBPM = defaultBPM + overweightAddition - fitnessSubtraction;
    self.baselineHeartRate = defaultBPM;
end