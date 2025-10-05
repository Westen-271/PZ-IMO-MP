--[[
    IMMERSIVE MEDICAL OVERHAUL - Subsystems > BloodManager.lua.

    This class is responsible for managing a character's blood volume and their total blood volume.

    Author: Westie
--]]

require "ISBaseObject";
BloodManager = ISBaseObject:derive("IMOPlayerBloodManager");

IMOLoggingUtils = IMOLoggingUtils or {};

---Creates a new BloodManager.
---@param isFemale boolean Whether the player character is female or not (IsoPlayer:isFemale()).
---@param weight number The character's weight from IsoPlayer:getNutrition():getWeight().
---@param fitnessLvl number The level of the player's fitness perk from 1-10.
---@return table BloodManager The newly created blood manager to be associated with a parent MedicalSystem.
function BloodManager:new(isFemale, weight, fitnessLvl)
    local o = {};
    setmetatable(o, self);
    self.__index = self;

    o.isFemale = isFemale;
    o.weight = weight;
    o.fitnessLvl = fitnessLvl;

    o:calculateTotalBloodVolume();
    return o;
end

---Calculates the total blood volume for the player based on weight and gender.<br/>
---<b>Sources:</b> https://www.ncbi.nlm.nih.gov/books/NBK526077/ and https://www.ncbi.nlm.nih.gov/books/NBK470382/.
function BloodManager:calculateTotalBloodVolume()

    if self.isFemale == nil or not self.weight or not self.fitnessLvl then
        IMOLoggingUtils.logError("BloodManager - attempted to calculate total blood volume but one or more required args is nil.");
        IMOLoggingUtils.errorDumpParams({ isFemale = self.isFemale, weight = self.weight, fitnessLvl = self.fitnessLvl });
        return;
    end

    -- Base blood volume is per sandbox settings..
    local baseVolume = SandboxVars.IMO.VitalsSettings_DefaultMaxBloodVolume;
    if not baseVolume then
        IMOLoggingUtils.logError("BloodManager - could not retrieve default max blood volume from sandbox settings.");
        baseVolume = 5000;
    end

    local randomWeightPercentage = ZombRand(7, 10); -- I don't think it accounts for the last number so needs to be 7-10 to have a chance of 7-9.
    local weightBloodVolume = self.weight * (randomWeightPercentage / 100); -- e.g. 70 * (7 / 100 = 0.07) = 4.9.
    weightBloodVolume = weightBloodVolume * 1000; -- To turn from litres to mililitres.

    local genderVarianceMax = (self.isFemale and 0.03308) or 0.03219; -- Values taken from https://www.ncbi.nlm.nih.gov/books/NBK526077/ (simplified).
    local randomGenderVariance = ZombRandFloat(-math.abs(genderVarianceMax), genderVarianceMax);
    
    local variationAmount = weightBloodVolume * randomGenderVariance; -- e.g. 4900 * -0.015 = -73.5.

    weightBloodVolume = weightBloodVolume + variationAmount;

    -- Now to account for fitness level - source: https://www.sciencedirect.com/science/article/abs/pii/S0002962915325404
    -- So to keep things simple, each fitness level past 5 accounts for 5% (completely arbitrary).
    local countedFitnessLevels = self.fitnessLvl - 5;
    if countedFitnessLevels < 0 then countedFitnessLevels = 1 end;

    local fitnessIncrease = weightBloodVolume * (0.05 * countedFitnessLevels); -- So if is 5 fitness or below, then 5000 * (0.05 * 0 = 0) = 0.
    weightBloodVolume = weightBloodVolume + fitnessIncrease;

    self.maxBloodVolume = weightBloodVolume;
end