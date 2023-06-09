-- We override NS2Gamerules to avoid having to override the NS2 gameserver.
-- @todo port this all to our own gamerules class.



if Server then

    local kGameEndCheckInterval = 0.75
    local kDeathmatchTimeLimit = 60*15
    local kCaptureTheGorgeTimeLimit = (60*10) + 35

    function NS2Gamerules:GetCanSpawnImmediately()
        -- we want to force respawn via spawners.
        return false
    end

	--Disable filler bots
	function NS2Gamerules:SetMaxBots()
	end


    function NS2Gamerules:BuildTeam(teamType)
        -- TEAM MODE - we always want aliens, because only aliens are shotgun worthy!
        return AlienTeam()
    end

    -- Force joining aliens.
    function NS2Gamerules:GetCanJoinTeamNumber(teamNumber)

        -- TEAM MODE - we don t care about the teams in team mode!
        if kTeamModeEnabled then
            return true
        end

       -- DEATHMATCH - force team 2
       return  (teamNumber == self.team2:GetTeamNumber())
    end

    function NS2Gamerules:ScorePoint( entity )
        entity:GetTeam().points = entity:GetTeam().points + 1
        RewardOnFireEffect(entity)
        entity:GetTeam():TeamRewardPoints( kScorePointsTeamCapture )
        rewardPoints(entity, kScorePointsCapture)
    end


    local kPauseToSocializeBeforeMapcycle = 30
    function NS2Gamerules:SetGameState(state)

        if state ~= self.gameState then

            self.gameState = state
            self.gameInfo:SetState(state)
            self.timeGameStateChanged = Shared.GetTime()
            self.timeSinceGameStateChanged = 0

            local frozenState = (state == kGameState.Countdown) and (not Shared.GetDevMode())

            if self.team1.SetFrozenState and self.team2.SetFrozenState then
                self.team1:SetFrozenState(frozenState)
                self.team2:SetFrozenState(frozenState)
            end

            if self.gameState == kGameState.Started then

                PostGameViz("Game started")
                self.gameStartTime = Shared.GetTime()

                self.gameInfo:SetStartTime(self.gameStartTime)

                if kTeamModeEnabled then
                    SendEventMessage(self.team1, kEventMessageTypes.StartTeamGame)
                    SendEventMessage(self.team2, kEventMessageTypes.StartTeamGame)
                else
                    SendEventMessage(self.team1, kEventMessageTypes.StartDeathmatchGame)
                    SendEventMessage(self.team2, kEventMessageTypes.StartDeathmatchGame)
                end

                -- Reset disconnected player resources when a game starts to prevent shenanigans.
                self.disconnectedPlayerResources = { }

            end

            -- On end game, check for map switch conditions
            if state == kGameState.Team1Won or state == kGameState.Team2Won then

                if MapCycle_TestCycleMap() then
                    self.timeToCycleMap = Shared.GetTime() + kPauseToSocializeBeforeMapcycle
                else
                    self.timeToCycleMap = nil
                end

            end

        end

    end

    local kLimitCallFrequency = {}
    function SNTL_LimitCallFrequency(id, frequency)
        local now = Shared.GetTime()

        if kLimitCallFrequency[id] then
            if kLimitCallFrequency[id] >= now then
                return true
            end
            kLimitCallFrequency[id] = now + frequency
        else
            kLimitCallFrequency[id] = 0
        end
        return false
    end

    sws_reset = false
    sws_last_ready = 0
    sws_team_ready = {}
    function NS2Gamerules:CheckGameStart()


        if kTeamModeEnabled and not (sws_team_ready[kAlienTeamType] == true and sws_team_ready[kMarineTeamType] == true) then
            if self:GetGameState() ~= kGameState.NotStarted then
                if not SNTL_LimitCallFrequency("rdy_message_warning", 30) then
                    if sws_team_ready[kAlienTeamType] then
                        Shared:ShotgunMessage("Aliens are ready, waiting for Frontiersmen")
                    elseif sws_team_ready[kMarineTeamType] then
                        Shared:ShotgunMessage("Frontiersmen are ready, waiting for Aliens")
                    else
                        Shared:ShotgunMessage("Both teams need to be ready to start (type 'ready' in console)")
                    end
                end
                self:SetGameState(kGameState.NotStarted)
            end
            return
        end

        local startDelay = 10
        local countDown = (sws_last_ready + startDelay) - Shared.GetTime()
        if countDown > 0 then
            if not SNTL_LimitCallFrequency("start timer", 1) then
                Shared:ShotgunMessage(string.format("Starting the round in %d", math.ceil(countDown)))
            end
            return
        end

        if sws_reset == false then
            self:ResetGame()
            sws_reset = true
            return
        end

        local playerCount = self.team1:GetNumPlayers() + self.team2:GetNumPlayers()

        if self:GetGameState() == kGameState.PreGame then

            if playerCount == 0 then
                self:SetGameState(kGameState.NotStarted)
                Shared:ShotgunMessage("Round aborted!")
            end

        elseif self:GetGameState() < kGameState.PreGame then

            -- Start game when we have /any/ players in the game.

            if  (playerCount > 0) then
			-- Log(self:GetGameState())
                if self:GetGameState() >= kGameState.WarmUp then
                    self:SetGameState(kGameState.PreGame)
                    self.score = 0
                    Shared:ShotgunMessage("Lock and load!")

                    -- @todo find a good location for this.
                end
            end

        end

    end

    local function UpdateSpawnTime(self)
        --------------
        local playerCount = self.team1:GetNumPlayers() + self.team2:GetNumPlayers()

        local new_kAlienSpawnTime = kTeamAlienSpawnTime -- FFA

        Log("-- %d / %d", playerCount, new_kAlienSpawnTime)
        if kTeamModeEnabled then
            -- team mode requires longer spawn time.
            new_kAlienSpawnTime = (playerCount < (5+5)) and kFastTeamAlienSpawnTime or kTeamAlienSpawnTime
           if new_kAlienSpawnTime ~= kAlienSpawnTime then
                if new_kAlienSpawnTime == kTeamAlienSpawnTime then
                    Log("Balance: updating the spawn time from %ds to %ds (5v5 reached)", kAlienSpawnTime, new_kAlienSpawnTime)
                else
                    Log("Balance: Updating the spawn time from %ds to %ds (1v1 - 4v4)", kAlienSpawnTime, new_kAlienSpawnTime)
                end
                kAlienSpawnTime = new_kAlienSpawnTime
            end
        end

        --------------
    end

    function NS2Gamerules:JoinTeam(player, newTeamNumber, force)



        if not kTeamModeEnabled then
            newTeamNumber = kTeam2Index
        end

        local client = Server.GetOwner(player)
        if not client then return end

        local success = false
        local newPlayer

        local oldPlayerWasSpectating = client and client:GetSpectatingPlayer()
        local oldTeamNumber = player:GetTeamNumber()

        -- Join new team
        if oldTeamNumber ~= newTeamNumber or force then

            if not Shared.GetCheatsEnabled() and self:GetGameStarted() and newTeamNumber ~= kTeamReadyRoom then
                player.spawnBlockTime = Shared.GetTime() + kSuicideDelay
            end

            local team = self:GetTeam(newTeamNumber)
            local oldTeam = self:GetTeam(oldTeamNumber)

            -- Remove the player from the old queue if they happen to be in one
            if oldTeam then
                oldTeam:RemovePlayerFromRespawnQueue(player)
            end

            -- Spawn immediately if going to ready room, game hasn t started, cheats on, or game started recently
            if newTeamNumber == kTeamReadyRoom or self:GetCanSpawnImmediately() or force then

                success, newPlayer = team:ReplaceRespawnPlayer(player, nil, nil)

                local teamTechPoint = team.GetInitialTechPoint and team:GetInitialTechPoint()
                if teamTechPoint then
                    newPlayer:OnInitialSpawn(teamTechPoint:GetOrigin())
                end

            else

                -- Destroy the existing player and create a spectator in their place.
                newPlayer = player:Replace(team:GetSpectatorMapName(), newTeamNumber)

                -- Queue up the spectator for respawn.
                team:PutPlayerInRespawnQueue(newPlayer)

                success = true

            end

            local clientUserId = client:GetUserId()
            --Save old pres
            if oldTeam == self.team1 or oldTeam == self.team2 then
                if not self.clientpres[clientUserId] then self.clientpres[clientUserId] = {} end
                self.clientpres[clientUserId][oldTeamNumber] = player:GetResources()
            end

            -- Update frozen state of player based on the game state and player team.
            if team == self.team1 or team == self.team2 then

                local devMode = Shared.GetDevMode()
                local inCountdown = self:GetGameState() == kGameState.Countdown
                if not devMode and inCountdown then
                    newPlayer.frozen = true
                end

                local pres = self.clientpres[clientUserId] and self.clientpres[clientUserId][newTeamNumber]
                newPlayer:SetResources( pres or ConditionalValue(team == self.team1, kMarineInitialIndivRes, kAlienInitialIndivRes) )

            else

                -- Ready room or spectator players should never be frozen
                newPlayer.frozen = false

            end


            newPlayer:TriggerEffects("join_team")

            if success then

                local newPlayerClient = Server.GetOwner(newPlayer)
                if oldPlayerWasSpectating then
                    newPlayerClient:SetSpectatingPlayer(nil)
                end

                if newPlayer.OnJoinTeam then
                    newPlayer:OnJoinTeam()
                end

                -- Check if concede sequence is in progress, and if so, set this new player up to
                -- see it.
                if GetConcedeSequenceActive() then
                    GetConcedeSequence():AddPlayer(newPlayer)
                end

                if newTeamNumber == kTeam1Index or newTeamNumber == kTeam2Index then
                    self.playerRanking:SetEntranceTime( newPlayer, newTeamNumber )  --Hive2 added team param
                elseif oldTeamNumber == kTeam1Index or oldTeamNumber == kTeam2Index then
                    self.playerRanking:SetExitTime( newPlayer, oldTeamNumber ) --Hive2 added team param
                end

                Server.SendNetworkMessage(newPlayerClient, "SetClientTeamNumber", { teamNumber = newPlayer:GetTeamNumber() }, true)

                if newTeamNumber == kSpectatorIndex then
                    newPlayer:SetSpectatorMode(kSpectatorMode.Overhead)
                end

                self.botTeamController:UpdateBots()
            end

            UpdateSpawnTime(self)
            return success, newPlayer

        end

        -- Return old player
        UpdateSpawnTime(self)
        return success, player

	end

    function NS2Gamerules:OnClientConnect(client)
        local player = Gamerules.OnClientConnect(self, client) -- creates player entity
        -- warn players they are not getting a typical match.
        -- Wouldn t want to confuse the greens.
        player:ShotgunMessage("You are playing custom mod: Skulks With Shotguns!")
        player:ShotgunMessage("This is not Vanilla NS2! Have fun!")
        -- Move spectators into the spectator team
        if client:GetIsSpectator() then
            self:JoinTeam(player, kSpectatorIndex, true)
        end

        return player
    end

    function NS2Gamerules:GetPregameLength()
        -- we have no need for a pre-game.
        return 0
    end

    local function ResetPlayerScores()

        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            if player.ResetScores then
                player:ResetScores()
            end
        end

    end

    function NS2Gamerules:UpdatePregame(timePassed)


        local state = self:GetGameState()
        if(state == kGameState.Team1Won or state == kGameState.Team2Won or state == kGameState.Draw) and not GetConcedeSequenceActive() then
            if force or self.timeSinceGameStateChanged >= kTimeToReadyRoom then
                -- Force the commanders to logout before we spawn people
                -- in the ready room
                self:LogoutCommanders()

                -- Set all players to ready room team
                Server.ForAllPlayers(MovePlayerToReadyRoom)

                -- Spawn them there and reset teams
                self:ResetGame()
            end
        end

        if self:GetGameState() == kGameState.PreGame then


                if kTeamModeEnabled then
                    self.team1:PlayPrivateTeamSound(kSfxCaptureStart)
                    self.team2:PlayPrivateTeamSound(kSfxCaptureStart)
                else
                    self.team1:PlayPrivateTeamSound(kSfxDeathmatchStart)
                    self.team2:PlayPrivateTeamSound(kSfxDeathmatchStart)
                end

                ResetPlayerScores()
                self:SetGameState(kGameState.Started)
                self.playerRanking:StartGame()

        end

    end

    -- returns number of living players on team.
    local function GetNumAlivePlayers(self)
        local numPlayers = 0

        for index, playerId in ipairs(self.playerIds) do
            local player = Shared.GetEntity(playerId)
            if player ~= nil and player:GetId() ~= Entity.invalidId and player:GetIsAlive() == true then
                numPlayers = numPlayers + 1
            end
        end

        return numPlayers
    end

	--returns the name of the last surviving player
	local function GetSurvivorName(self)
        local name = ""

        for index, playerId in ipairs(self.playerIds) do
            local player = Shared.GetEntity(playerId)
            if player ~= nil and player:GetId() ~= Entity.invalidId and player:GetIsAlive() == true then
                name = player:GetName()
            end
        end

        return name
    end

    function NS2Gamerules:GetGameLengthTime()
       return math.max( 0, (math.floor( Shared.GetTime() ) - self.gameInfo:GetStartTime()) )
    end

    /**
     * Ends the current game
     */
    function NS2Gamerules:EndGame(winningTeam)

        if self:GetGameState() == kGameState.Started then

            if self.autoTeamBalanceEnabled then
                TEST_EVENT("Auto-team balance, game ended")
            end

            local winningTeamType = nil
            if winningTeam == self.team1 then
                winningTeamType = kMarineTeamType
            end
            if winningTeam == self.team2 then
                winningTeamType = kAlienTeamType
            end

            if winningTeamType == kMarineTeamType then

                self:SetGameState(kGameState.Team1Won)
                PostGameViz("Blue Team Wins!")

            elseif winningTeamType == kAlienTeamType then

                self:SetGameState(kGameState.Team2Won)
                PostGameViz("Red Team Win!")

            else

                self:SetGameState(kGameState.Draw)
                PostGameViz("Draw Game!")

            end

            sws_team_ready = {} -- SwS: clear ready states

            Server.SendNetworkMessage( "GameEnd", { win = winningTeamType }, true)

            self.team1:ClearRespawnQueue()
            self.team2:ClearRespawnQueue()

            -- Clear out Draw Game window handling
            self.team1Lost = nil
            self.team2Lost = nil
            self.timeDrawWindowEnds = nil

            -- Automatically end any performance logging when the round has ended.
            Shared.ConsoleCommand("p_endlog")

            if winningTeam then
                self.playerRanking:EndGame(winningTeam)
            end
            TournamentModeOnGameEnd()

        end

    end

    function NS2Gamerules:CheckGameEnd()

        PROFILE("NS2Gamerules:CheckGameEnd")

        if self:GetGameStarted() and self.timeGameEnded == nil and not self.preventGameEnd then

            if kTeamModeEnabled then

                -- no more living players on team, and out of spawns? game lost/deathmatch over!
                local team1Won = (self.team1:GetPoints() >= kCaptureWinPoints)
                local team2Won = (self.team2:GetPoints() >= kCaptureWinPoints)

                -- time based mode.
                if not team1Won and not team2Won and kTeamModeTimelimit > 0 then

                    if self:GetGameLengthTime() >= kTeamModeTimelimit then
                        team1Won = self.team1:GetPoints() > self.team2:GetPoints()
                        team2Won = self.team1:GetPoints() < self.team2:GetPoints()

                        -- draw condition.
                        if (team1Won == false) and (team2Won == false) then
                            Shared:ShotgunMessage("Neither Team Wins!")
                            self:DrawGame()
                        end
                    else
                        -- timer still ticking.
                        team1Won = false
                        team2Won = false
                    end
                end

                if team1Won then
                    Shared:ShotgunMessage("Blue Team Wins!")
                    self.team1:PlayPrivateTeamSound(kSfxBlueWins)
                    self.team2:PlayPrivateTeamSound(kSfxBlueWins)
                    self:EndGame(self.team1)
                end
                if team2Won then
                    Shared:ShotgunMessage("Red Team Wins!")
                    self.team1:PlayPrivateTeamSound(kSfxRedWins)
                    self.team2:PlayPrivateTeamSound(kSfxRedWins)
                    self:EndGame(self.team2)
                end
            else
                -- no foes remain.
                local noFoesRemain = (GetNumAlivePlayers(self.team2) <= 1) and (not self.team2:GetHasAbilityToRespawn())
                if noFoesRemain then
                    Shared:ShotgunMessage("Total Decimation!")
					if (GetNumAlivePlayers(self.team2) == 1)  then
						local name = GetSurvivorName(self.team2)
						Shared:ShotgunMessage( name .. " Wins!")
					end
					self.timeGameEnded = Shared.GetTime()
                    self:DrawGame()
                end
            end

            -- game is taking too long.
            if self.timeLastGameEndCheck == nil or (Shared.GetTime() > self.timeLastGameEndCheck + kGameEndCheckInterval) then

                if (not kTeamModeEnabled and (self.timeSinceGameStateChanged >= kDeathmatchTimeLimit)) or
                   (kTeamModeEnabled and (self.timeSinceGameStateChanged >= kCaptureTheGorgeTimeLimit)) then
                    Shared:ShotgunMessage("Time limit reached! For shame..")
                    self:DrawGame()
                end

                self.timeLastGameEndCheck = Shared.GetTime()

            end

        end

    end


    function NS2Gamerules:OnMapPostLoad()

        Gamerules.OnMapPostLoad(self)

        -- Now allow script actors to hook post load
        local allScriptActors = Shared.GetEntitiesWithClassname("ScriptActor")
        for index, scriptActor in ientitylist(allScriptActors) do
            scriptActor:OnMapPostLoad()
        end

        -- fall back on resource points as spawns if none exist for the shadow team.
        if table.maxn(Server.shadowSpawnList) <= 0 then
            Shared:ShotgunWarning("Map lacks shadow_spawn entities on the map! Falling back on ResourcePoints.")
            for index, entity in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
                local spawn = ShadowSpawn()
                spawn:OnCreate()
                spawn:SetAngles(entity:GetAngles())
                spawn:SetOrigin(entity:GetOrigin())
                table.insert(Server.shadowSpawnList, spawn)
            end
        end

        -- fall back on resource points as spawns if none exist for the vanilla team.
        if table.maxn(Server.vanillaSpawnList) <= 0 then
            Shared:ShotgunWarning("Map lacks vanilla_spawn entitities on the map! Falling back on ResourcePoints.")
            for index, entity in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
                local spawn = VanillaSpawn()
                spawn:OnCreate()
                spawn:SetAngles(entity:GetAngles())
                spawn:SetOrigin(entity:GetOrigin())
                table.insert(Server.vanillaSpawnList, spawn)
            end
        end
    end

	function NS2Gamerules:CheckForNoCommander(onTeam, commanderType) end
	function NS2Gamerules:UpdateAutoTeamBalance(dt) end
	function NS2Gamerules:KillEnemiesNearCommandStructureInPreGame(timePassed) end
    -- disable these methods in OnUpdate, we don t want them to trigger.
    local function DisabledUpdateAutoTeamBalance(self, dt) end
    local function DisabledCheckForNoCommander(self, onTeam, commanderType) end
    local function DisabledKillEnemiesNearCommandStructureInPreGame(self, timePassed) end

    -- ReplaceLocals( NS2Gamerules.OnUpdate, { UpdateAutoTeamBalance = DisabledUpdateAutoTeamBalance } )
    -- ReplaceLocals( NS2Gamerules.OnUpdate, { CheckForNoCommander = DisabledCheckForNoCommander } )
    -- ReplaceLocals( NS2Gamerules.OnUpdate, { KillEnemiesNearCommandStructureInPreGame = DisabledKillEnemiesNearCommandStructureInPreGame } )

end
