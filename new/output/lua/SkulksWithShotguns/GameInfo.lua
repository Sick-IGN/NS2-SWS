-- Changed

if Server then

    function GameInfo:SetTeam1CosmeticSlot( cosmeticSlot, cosmetic )
        assert(cosmeticSlot >= kTeamCosmeticSlot1 and cosmeticSlot <= kTeamCosmeticSlot6)
        if cosmeticSlot == kTeamCosmeticSlot1 then
            self.team1Cosmetic1 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot2 then
            self.team1Cosmetic2 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot3 then
            self.team1Cosmetic3 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot4 then
            self.team1Cosmetic4 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot5 then
            self.team1Cosmetic5 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot6 then
            self.team2Cosmetic6 = cosmetic
        end
    end

    function GameInfo:SetTeam2CosmeticSlot( cosmeticSlot, cosmetic )
        assert(cosmeticSlot >= kTeamCosmeticSlot1 and cosmeticSlot <= kTeamCosmeticSlot6)
        if cosmeticSlot == kTeamCosmeticSlot1 then
            self.team2Cosmetic1 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot2 then
            self.team2Cosmetic2 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot3 then
            self.team2Cosmetic3 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot4 then
            self.team2Cosmetic4 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot5 then
            self.team2Cosmetic5 = cosmetic
        elseif cosmeticSlot == kTeamCosmeticSlot6 then
            self.team2Cosmetic6 = cosmetic
        end
    end

    function GameInfo:SetTeamCosmeticSlot( teamNum, cosmeticSlot, cosmeticId )
        assert(teamNum == kTeam1Index or teamNum == kTeam2Index)
        assert(cosmeticSlot >= kTeamCosmeticSlot1 and cosmeticSlot <= kTeamCosmeticSlot6)
        assert(cosmeticId)

        if teamNum == kTeam1Index then
            self:SetTeam1CosmeticSlot(cosmeticSlot, cosmeticId)
        elseif teamNum == kTeam2Index then
            self:SetTeam2CosmeticSlot(cosmeticSlot, cosmeticId)
        end

    end

end