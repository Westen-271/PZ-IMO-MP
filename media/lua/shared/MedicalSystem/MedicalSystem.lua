--[[
    IMMERSIVE MEDICAL OVERHAUL - MedicalSystem.lua.

    This class controls the overall medical system of an individual player.
    It is responsible for storing the subsystems and calling their functions.
    This should be stored in IsoPlayer:getModData().IMO

    Author: Westie
--]]

require "ISBaseObject";
MedicalSystem = ISBaseObject:derive("IMOPlayerMedicalSystem");

IMOLoggingUtils = IMOLoggingUtils or {};

---Creates a new MedicalSystem.
---@param player IsoPlayer The player to associate with the medical system. This should always be created on the client for efficiency.
---@return table MedicalSystem newly created medical system with all subsystems initialised.
function MedicalSystem:new(player)
    local o = {};
    setmetatable(o, self);
    self.__index = self;

    o.character = player;
    o:initialiseSubsystems();
    return o;
end

--[[
    MEDICAL SUBSYSTEMS
--]]

---Initialises the subsystems found in shared/MedicalSystem/Subsystems.
function MedicalSystem:initialiseSubsystems()
    if not self.character then
        IMOLoggingUtils.logError("Attempted to initialise subsystems but self.character was nil.");
        return;
    end

    local characterWeight = self.character:getNutrition():getWeight();
    if not characterWeight then
        IMOLoggingUtils.logError("Attempted to initialise subsystems but could not retrieve weight for character.");
        return;
    end

    local fitnessLevel = self.character:getPerkLevel(Perks.Fitness);
    if not fitnessLevel then
        IMOLoggingUtils.logError("Attempted to initialise subsystems but could not retrieve fitness level for character.");
        return;
    end

    self.bloodManager = BloodManager:new(self.character:isFemale(), characterWeight, fitnessLevel);
    self.bloodPressureManager = BloodPressureManager:new(characterWeight, fitnessLevel);
end