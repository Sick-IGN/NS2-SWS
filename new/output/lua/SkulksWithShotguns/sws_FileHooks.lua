-- Script.Load("lua/sntl/Elixer_Utility.lua")
-- Elixer.UseVersion(1.8)

local function ModLoader_SetupFileHook(file, replace_type)
    local sws_file = string.gsub(file, "lua/", "lua/SkulksWithShotguns/", 1)

    Log("[SwS] ModLoader.SetupFileHook(\"%s\",  \"%s\", \"%s\")", file,  sws_file, replace_type)
    ModLoader.SetupFileHook(file,  sws_file, replace_type)
end

local function ModLoader_SetupModelFileHook(file, replace_type)
    local sws_file = string.gsub(file, "models/", "sws_models/", 1)

    Log("[SwS] ModLoader.SetupModelFileHook(\"%s\",  \"%s\", \"%s\")", file,  sws_file, replace_type)
    ModLoader.SetupFileHook(file,  sws_file, replace_type)
end

ModLoader_SetupFileHook("lua/Balance.lua", "post")
ModLoader_SetupFileHook("lua/BalanceMisc.lua", "post")

ModLoader_SetupFileHook("lua/Skulk.lua", "replace")
ModLoader_SetupFileHook("lua/SkulkVariantMixin.lua", "replace")
ModLoader_SetupFileHook("lua/Lerk.lua", "post")
ModLoader_SetupFileHook("lua/LerkVariantMixin.lua", "post")
ModLoader_SetupFileHook("lua/ConsoleCommands_Server.lua", "post")

ModLoader_SetupFileHook("lua/AlienCommanderSkinsMixin.lua", "post")

ModLoader_SetupFileHook("lua/Hud2/topBar/GUIHudTopBarObjectClasses.lua", "replace")

-- ModLoader_SetupFileHook("lua/HiveVisionMixin.lua", "replace")

ModLoader_SetupFileHook("lua/Weapons/Marine/Shotgun.lua", "replace")
-- ModLoader_SetupFileHook("lua/Weapons/Alien/SpikesMixin.lua", "replace")

-- ModLoader_SetupFileHook("lua/Globals.lua", "post")
ModLoader_SetupFileHook("lua/GameInfo.lua", "post")
ModLoader_SetupFileHook("lua/NS2Gamerules.lua", "post")
ModLoader_SetupFileHook("lua/Gamerules.lua", "post")

-- ModLoader_SetupModelFileHook("models/alien/gorge/gorge.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/gorge/gorge_shadow.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/gorge/gorge_shadow_illum.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_illum.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_v2.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_v2_illum.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_vblu.material", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_vblu.model", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_view_blue.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_view_red.dds", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_vred.material", "replace")
-- ModLoader_SetupModelFileHook("models/alien/skulk/skulk_vred.model", "replace")
-- ModLoader_SetupModelFileHook("models/marine/shotgun/shotgun.material", "replace")
-- ModLoader_SetupModelFileHook("models/marine/shotgun/shotgun.model", "replace")


-- ModLoader_SetupFileHook("lua/NS2Gamerules.lua", "post")

-- ModLoader_SetupFileHook("lua/Alien.lua", "post")
-- ModLoader_SetupFileHook("lua/Ragdoll.lua", "post")
-- ModLoader_SetupFileHook("lua/RagdollMixin.lua", "post")
-- ModLoader_SetupFileHook("lua/DissolveMixin.lua", "post")

-- ModLoader_SetupFileHook("lua/Team.lua", "post")
-- ModLoader_SetupFileHook("lua/AlienTeam.lua", "post")
-- ModLoader_SetupFileHook("lua/MarineTeam.lua", "post")
-- ModLoader_SetupFileHook("lua/PlayingTeam.lua", "post")

-- ModLoader_SetupFileHook("lua/Exo.lua", "post")
-- ModLoader_SetupFileHook("lua/Marine_Server.lua", "post")

-- ModLoader_SetupFileHook("lua/Armory.lua", "post")
-- ModLoader_SetupFileHook("lua/PhaseGate.lua", "post")
-- ModLoader_SetupFileHook("lua/PrototypeLab.lua", "post")
-- ModLoader_SetupFileHook("lua/InfantryPortal.lua", "post")

-- ModLoader_SetupFileHook("lua/Balance.lua", "post")
-- ModLoader_SetupFileHook("lua/BalanceMisc.lua", "post")
-- ModLoader_SetupFileHook("lua/BalanceHealth.lua", "post")

-- ModLoader_SetupFileHook("lua/GameInfo.lua", "post")
-- ModLoader_SetupFileHook("lua/NS2Utility.lua", "post")

-- ModLoader_SetupFileHook("lua/Egg.lua", "post")
-- ModLoader_SetupFileHook("lua/Player.lua", "post")

-- ModLoader_SetupFileHook("lua/Weapons/Marine/Claw.lua", "post")

-- ModLoader_SetupFileHook("lua/bots/PlayerBot.lua", "post")
-- ModLoader_SetupFileHook("lua/bots/TeamBrain.lua", "post")
-- -- ModLoader_SetupFileHook("lua/bots/BotMotion.lua", "replace")
-- ModLoader_SetupFileHook("lua/bots/SkulkBrain_Data.lua", "replace")
-- ModLoader_SetupFileHook("lua/bots/LerkBrain_Data.lua", "replace")
-- ModLoader_SetupFileHook("lua/bots/BotTeamController.lua", "post")


-- ModLoader_SetupFileHook("lua/LOSMixin.lua", "post")

-- ModLoader_SetupFileHook("lua/NetworkMessages.lua", "post")
-- ModLoader_SetupFileHook("lua/NetworkMessages_Client.lua", "post")

-- ModLoader_SetupFileHook("lua/Shared.lua", "post")

-- if Locale then
--     local sntl_strings = {
--         ["SNTL_JOIN_ERROR_ALIEN"] = "You can only join the marine team",
--         -- --
--         ["MARINE_TEAM_GAME_STARTED"] = "Objective: Kill all the eggs",
--         ["RETURN_TO_BASE"] = "Objective: Return to base"
--     }

--     local old_Locale_ResolveString = Locale.ResolveString
--     function Locale.ResolveString(text)
--         return sntl_strings[text] or old_Locale_ResolveString(text)
--     end
-- end
