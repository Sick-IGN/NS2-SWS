kSWSWeaponEffects =
{
    sws_attack_sound = 
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire"},
        }
    },
    
    sws_attack = 
    {
        shotgunAttackEffects = 
        {
            {viewmodel_cinematic = "cinematics/marine/shotgun/muzzle_flash.cinematic", attach_point = "CamBone"},
            {player_cinematic = "cinematics/marine/shotgun/muzzle_flash.cinematic", attach_point = "Bip01_Head"},
            {player_cinematic = "cinematics/marine/shotgun/shell.cinematic", attach_point = "Bip01_Head"} ,
        },
    },

}

GetEffectManager():AddEffectData("SWSWeaponEffects", kSWSWeaponEffects)

GetEffectManager():PrecacheEffects()