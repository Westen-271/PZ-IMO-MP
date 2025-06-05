# Style Guide
### Style guidelines and patterns for use in this project.

[Reference Material](http://lua-users.org/wiki/LuaStyleGuide)

## Indentation
4 space / 1 tab indentations.
```lua
function VitalsManager.OnCreatePlayer(playerNum, player)

....if not player then return end; -- 4

    local modData = player:getModData();
    if not modData then return end;

    if not modData.IMO_Vitals then
........modData.IMO_Vitals = {}; -- 8
        VitalsManager.AllocateCharacterBloodType(player);
    end
end
```
