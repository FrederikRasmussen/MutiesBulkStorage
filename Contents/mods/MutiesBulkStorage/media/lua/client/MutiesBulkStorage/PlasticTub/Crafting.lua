require("MutiesBulkStorage/Main")

function MutiesBulkStorage.Predicate.CanAddFlourToPlasticTub(plasticTub)
    if not plasticTub then return true end
    if not plasticTub.getDelta then return true end
    if plasticTub:getFullType() == "Base.Flour" then return true end
    return plasticTub:getDelta() < 1.0;
end

---@param result DrainableComboItem
---@param player IsoGameCharacter
function MutiesBulkStorage.OnCreate.FillPlasticTubWithFlour(ingredients, result, player)
    ---@type DrainableComboItem | InventoryItem
    local tub;
    ---@type DrainableComboItem | InventoryItem
    local flour;
    for i = 0, ingredients:size() - 1 do
        ---@type InventoryItem
        local current = ingredients:get(i);
        if current:getFullType() == "Base.Flour" then
            flour = current;
        else
            tub = current;
        end
    end
    local tubFlour = 0.0;
    if instanceof(tub, "DrainableComboItem") then
        tubFlour = tub:getDelta() + tub:getUseDelta();
    end
    local flourToTubRatio = flour:getUseDelta() / result:getUseDelta();
    local flourForTub = (flour:getDelta() + flour:getUseDelta()) / flourToTubRatio;
    tubFlour = tubFlour + flourForTub;
    local overfill = 0.0;
    if tubFlour > 1.0 then
        overfill = tubFlour - 1.0;
        tubFlour = 1.0;
        flour:setDelta(overfill * flourToTubRatio);
    end
    result:setDelta(tubFlour);
    if tub then
        player:getInventory():removeItemWithIDRecurse(tub:getID());
    end
    if overfill == 0.0 then
        player:getInventory():removeItemWithIDRecurse(flour:getID());
    end
end