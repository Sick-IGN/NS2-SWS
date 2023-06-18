if Server then

	function Gamerules:RespawnPlayer(player)


		-- Randomly choose unobstructed spawn points to respawn the player
		local success = false
		local spawnPoint
		local spawnPoints = Server.readyRoomSpawnList
		local numSpawnPoints = table.icount(spawnPoints)

		if(numSpawnPoints > 0) then
		
			local spawnPoint = GetRandomClearSpawnPoint(player, spawnPoints)
			if (spawnPoint ~= nil) then
			
				local origin = spawnPoint:GetOrigin()
				local angles = spawnPoint:GetAngles()
				
				SpawnPlayerAtPoint(player, origin, angles)
				
				player:ClearEffects()
				
				success = true
				
			end

		end
		
		if(not success) then
			Print("Gamerules:RespawnPlayer(player) - Couldn t find spawn point for player.")
		end
		
		return success
		
	end

end
