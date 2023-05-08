kSWSWeaponEffects =
{
    shotgun_attack_sound_last =
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire_last"},
        }
    },
    
    shotgun_attack_sound = 
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire"},
        }
    },
    
    shotgun_attack_sound_medium = 
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire_upgrade_1"},
        }
    },
    
    shotgun_attack_sound_max = 
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire_upgrade_3"},
        }
    },

    shotgun_attack = 
    {
        shotgunAttackEffects = 
        {
            {viewmodel_cinematic = "cinematics/marine/shotgun/muzzle_flash.cinematic", attach_point = "fxnode_shotgunmuzzle"},
            {weapon_cinematic = "cinematics/marine/shotgun/muzzle_flash.cinematic", attach_point = "fxnode_shotgunmuzzle"},
            {weapon_cinematic = "cinematics/marine/shotgun/shell.cinematic", attach_point = "fxnode_shotguncasing"} ,
        },
    },
    
    -- Special shotgun reload effects
    shotgun_reload_start =
    {
        shotgunReloadStartEffects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/start_reload"},
        },
    },

    shotgun_reload_shell =
    {
        shotgunReloadShellEffects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/load_shell"},
        },
    },

    shotgun_reload_end =
    {
        shotgunReloadEndEffects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/end_reload"},
        },
    },
    
}

GetEffectManager():AddEffectData("SWSWeaponEffects", kSWSWeaponEffects)