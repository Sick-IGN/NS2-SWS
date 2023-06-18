
// enable deathmatch mode by making everyone enemy of everyone.
local original_GetAreEnemies = GetAreEnemies;
function GetAreEnemies(entityOne, entityTwo)

    // in team mode, we want regular team checks.
    if kTeamModeEnabled then
        return original_GetAreEnemies(entityOne,entityTwo)
    end

    return entityOne and entityTwo
end

// we are not friends! (disables wallsight for teammates)
local original_GetAreFriends = GetAreFriends;
function GetAreFriends(entityOne, entityTwo)

    // in team mode, do regular friend checks.
    if kTeamModeEnabled then
        return original_GetAreFriends(entityOne,entityTwo)
    end

    return false
end

// force default level for shell
function GetShellLevel(teamNumber)
    return 3
end

// force default level for spur
function GetSpurLevel(teamNumber)
    return 3
end

// force default level for veil
function GetVeilLevel(teamNumber)
    return 3
end

if Client then
    local orig_GetIsMarineUnit = GetIsMarineUnit
    function GetIsMarineUnit(entity)
        local player = Client.GetLocalPlayer()

        -- if player and (player:GetTeamType() == kAlienTeamType or player:GetTeamType() == kMarineTeamType) then
        --     if entity and HasMixin(entity, "Team") and GetAreEnemies(entity, player) then
        --         return true
        --     end
        --     return false
        -- end
        -- return orig_GetIsMarineUnit(entity)
        if not player
            or not entity
            or not HasMixin(entity, "Team")
            or not HasMixin(player, "Team")
            or not (player:GetTeamType() == kAlienTeamType or player:GetTeamType() == kMarineTeamType)
        then
            return false --orig_GetIsMarineUnit(entity)
        end
        return true-- and entity:GetTeamNumber() ~= player:GetTeamNumber()
    end

    local orig_GetIsAlienUnit = GetIsAlienUnit
    function GetIsAlienUnit(entity)
        local player = Client.GetLocalPlayer()

        -- if player and (player:GetTeamType() == kAlienTeamType or player:GetTeamType() == kMarineTeamType) then
        --     if entity and HasMixin(entity, "Team") and GetAreEnemies(entity, player) then
        --         return true
        --     end
        --     return false
        -- end
        -- return orig_GetIsMarineUnit(entity)
        if not player
            or not entity
            or not HasMixin(entity, "Team")
            or not HasMixin(player, "Team")
            or not (player:GetTeamType() == kAlienTeamType or player:GetTeamType() == kMarineTeamType)
        then
            return false --orig_GetIsAlienUnit(entity)
        end
        return true -- entity:GetTeamNumber() ~= player:GetTeamNumber()
    end

end
