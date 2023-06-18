
-- we don t allow any entities to be used.
function TeamMixin:GetCanBeUsed(player, useSuccessTable)
    if self:GetTechId() == kTechId.LerkEgg then
        useSuccessTable.useSuccess = true
    else
        useSuccessTable.useSuccess = false
    end
end
