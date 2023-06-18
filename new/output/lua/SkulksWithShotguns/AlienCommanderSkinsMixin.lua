function AlienCommanderSkinsMixin:__initmixin()
    self.structureVariant = kDefaultAlienStructureVariant
    self.tunnelVariant = kDefaultAlienTunnelVariant
    self.drifterVariant = kDefaultAlienDrifterVariant
    self.harvesterVariant = kDefaultHarvesterVariant
    self.eggVariant = kDefaultEggVariant
    self.cystVariant = kDefaultAlienCystVariant

    --Waste to send this when round is already in progress, so clamp to pregame/warmup only
    if Client and GetGameInfoEntity():GetState() < kGameState.Countdown then
        SendPlayerVariantUpdate()
    end
end