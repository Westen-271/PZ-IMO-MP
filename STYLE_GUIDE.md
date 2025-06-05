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

### Variable Naming

**Internal global variables** - underscore followed by upper case letters, e.g. ``` _RELEASE_VERSION```.

**Constant values** - upper case words separated by underscore, e.g. ```BLOOD_TYPES = {}```.

**Discarded/ignored loop variables** - underscore (semantic only), e.g. ```for _, v in ipairs(BLOOD_TYPES) do```

**camelCase** - use for local variables inside functions, as well as longer property names e.g. 
```lua
function VitalsManager.OnCreatePlayer(playerNum, player)

    ...

    local modData = player:getModData();
    if not modData then return end;

    ...
end
```

```player.lastSeenTimestamp.```

**PascalCase** - use for function names and object names, e.g. ```local function GenerateRandomNumber()```.

**Pascal_Snake_Case** - use for properties or global variables that are contextualised or categorised by a prefix, e.g. ```player:getModData().IMO_Vitals``` or ```IMO_YearSettings_firstGenHemostatics```.

**lowercase** - use for short one-word local variables and properties, e.g. ```object.timestamp```.

### Conditionals
**Checking variable exists** - use just the variable name, e.g. ```if account then``` or ```if not account then```


### Comments
**Use space after --** - spaces should be used after -- to make the text more readable, e.g. ```-- Example comment.```

