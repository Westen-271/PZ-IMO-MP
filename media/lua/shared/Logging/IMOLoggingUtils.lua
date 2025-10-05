require "ISLogSystem";

IMOLoggingUtils = {};

function IMOLoggingUtils.logError(string)
    writeLog("IMO_Errors", string);
    error(string);
end

function IMOLoggingUtils.errorDumpParams(params)
    if not params then return end;

    local dumpString = "";
    for k, v in pairs(params) do
        dumpString = dumpString .. string.format("[%s]: %s | ", k, v or "nil");
    end

    IMOLoggingUtils.logError(dumpString);
end


return IMOLoggingUtils;