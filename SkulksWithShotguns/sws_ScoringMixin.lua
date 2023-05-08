Script.Load("lua/ScoringMixin.lua")

local function PlaySound( self, soundEffect )
    Server.PlayPrivateSound(self, soundEffect, self, 1.0, Vector(0, 0, 0), true)
end

function ScoringMixin:GetScoreGainedCurrentLife()
    return self.scoreGainedCurrentLife
end

function ScoringMixin:GetPlayerLevel()
    return self.playerLevel
end
  
function ScoringMixin:GetTotalXP()
    return self.totalXP
end

function ScoringMixin:GetPlayerSkill()
    return self.skill
end

function ScoringMixin:GetPlayerSkillOffset()
    return self.skillOffset
end

if Server then
    function ScoringMixin:SetTotalKills(totalKills)
        self.totalKills = math.round(totalKills)
    end
    
    function ScoringMixin:SetTotalAssists(totalAssists)
        self.totalAssists = math.round(totalAssists)
    end
    
    function ScoringMixin:SetTotalDeaths(totalDeaths)
        self.totalDeaths = math.round(totalDeaths)
    end
    
    function ScoringMixin:SetPlayerSkill(skill)
        self.skill = math.round(skill)
    end

    function ScoringMixin:SetPlayerSkillOffset( skillOffset )
        self.skillOffset = skillOffset
    end

    function ScoringMixin:SetAdagradSum(adagradSum)
        self.adagradSum = adagradSum
    end

    function ScoringMixin:SetCommanderAdagradSum(adagradSum)
        self.commAdagradSum = adagradSum
    end

    function ScoringMixin:SetCommanderSkill( commSkill )
        self.commSkill = math.round(commSkill)
    end

    function ScoringMixin:SetCommanderSkillOffset( commSkillOffset )
        self.commSkillOffset = commSkillOffset
    end
    
    function ScoringMixin:SetTotalScore(totalScore)
        self.totalScore = math.round(totalScore)
    end
    
    function ScoringMixin:SetTotalPlayTime(totalPlayTime)
        self.totalPlayTime = math.round(totalPlayTime)
    end
    
    function ScoringMixin:SetPlayerLevel(playerLevel)
        self.playerLevel = math.round(playerLevel)
    end 

    function ScoringMixin:SetTotalXP(playerLevel)
        self.totalXP = math.round(playerLevel)
    end 
end

-- Reward killstreaks!
function ScoringMixin:rewardKill()
    if Server then 
        if self.killstreak == 2 then 
            self:GiveUpgrade(kTechId.Adrenaline) 
            Shared:ShotgunMessage("Double Kill! " .. self:GetName() .. " gained adrenaline!")
            PlaySound(self, kSfxKillstreak1)
        end
        if self.killstreak == 4 then 
            self:GiveUpgrade(kTechId.Celerity) 
            Shared:ShotgunMessage("Multi Kill! " .. self:GetName() .. " gained celerity!") 
            PlaySound(self, kSfxKillstreak2)
        end
        if self.killstreak == 6 then 
            self:GiveUpgrade(kTechId.Regeneration) 
            Shared:ShotgunMessage("Ultra Kill! " .. self:GetName() .. " gained regeneration!") 
            PlaySound(self, kSfxKillstreak3)
        end
        if self.killstreak == 8 then 
            self:GiveUpgrade(kTechId.Carapace) 
            Shared:ShotgunMessage("MONSTERKILL!! " .. self:GetName() .. " gained carapace!") 
            PlaySound(self, kSfxKillstreak4)
        end
        
        
        -- Give players that achieve quick successive kills the fire effect which gives 1.3x damage boost.
        local now = Shared.GetTime()        
        self.lastKillTime = self.lastKillTime or 0
        if now - self.lastKillTime <= 3 then
            RewardOnFireEffect(self)
            PlaySound(self, kSfxKillstreak4)
        end
        self.lastKillTime = now
    end
end

function RewardOnFireEffect(self)
   self:SetOnFire()
   Shared:ShotgunMessage(self:GetName() .. " is on fire! (temporary Weapons III)")
end

function ScoringMixin:GetAdagradSum()
    return self.adagradSum
end


function ScoringMixin:GetSkillTier()
    if self.playerSkill < 0 then return 0 end

    if not self.skillTier then
        local isRookie = self:GetPlayerLevel() <= kRookieLevel
        self.skillTier = GetPlayerSkillTier(self:GetPlayerSkill(), isRookie, self:GetAdagradSum())
    end

    return self.skillTier
end
