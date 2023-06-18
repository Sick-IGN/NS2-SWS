
local strformat = string.format
local floor = math.floor

local function _GetGameStartTime()
    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if (entityList:GetSize() > 0) then
        local gameInfo = entityList:GetEntityAtIndex(0)
        local state = gameInfo:GetState()

        if (state == kGameState.Started) then
            return gameInfo:GetStartTime()
        else
            return Shared.GetTime()
        end
    end

    return Shared.GetTime()
end

local function _GetRoundTime()
    return math.floor(Shared.GetTime() - _GetGameStartTime())
end

local maxResetReadyTime = 30
function OnCommandReady(client)
    local player = client:GetControllingPlayer()

    if player then
        local teamNumber = player:GetTeamNumber()

        if not (teamNumber == kMarineTeamType or teamNumber == kAlienTeamType) then
            return
        end

        if _GetRoundTime() <= maxResetReadyTime then
            -- If both team are already ready, reset
            if sws_team_ready[kMarineTeamType] and sws_team_ready[kAlienTeamType] then
                GetGamerules():ResetGame()
            end
            -- else
            --     Shared:ShotgunMessage(string.format("%s has %s for %s(%d) (round not reset, %ds time limit reached)",
            --                                         player:GetName(),
            --                                         (sws_team_ready[teamNumber] and "readied" or "unreadied"),
            --                                         teamNumber == kAlienTeamType and "Aliens" or "Frontiersmen",
            --                                         teamNumber,
            --                                         maxResetReadyTime)
            --     )
            --     return
            -- -- If readying past the delay, end the game for the other team
            -- GetGamerules():EndGame(GetEnemyTeamNumber(teamNumber))

            sws_team_ready[teamNumber] = not sws_team_ready[teamNumber]
            Shared:ShotgunMessage(string.format("%s has %s for %s(%d)",
                                                player:GetName(),
                                                (sws_team_ready[teamNumber] and "readied" or "unreadied"),
                                                teamNumber == kAlienTeamType and "Aliens" or "Frontiersmen",
                                                teamNumber)
            )

            -- if not sws_team_ready[GetEnemyTeamNumber(teamNumber)] then
            --     Shared:ShotgunMessage("Waiting for the other team to type ready")
            -- else
            --     Shared:ShotgunMessage("Both teams ready, starting the round")
            -- end

            sws_last_ready = Shared.GetTime()
            sws_reset = false
        end

    end
    -- Shared:ShotgunMessage(string.format("%s -> %.5s/%.5s/%.5s with a frequency of %.5s (last straffe refresh: %.5s)",
    --                                    s:GetName(),
    --                                    tostring(s.smoothXHairValue),
    --                                    tostring(s.lowerXHairValue),
    --                                    tostring(s.upperXHairValue),
    --                                    tostring(s.kStraffingFreq),
    --                                    tostring(s.straffeRefreshRate)
    --                                   ))
end

Event.Hook("Console_ready", OnCommandReady)
Event.Hook("Console_rdy", OnCommandReady)
