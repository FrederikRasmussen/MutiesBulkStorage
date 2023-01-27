require("MutiesBulkStorage/Main");

---@param item InventoryItem
local function addWeightToModdata(item, weight, hunger, extraWeight)
    local data = item:getModData();
    data.MutiesBulkStorage = data.MutiesBulkStorage or {};
    data.MutiesBulkStorage.FoodWeight = weight;
    data.MutiesBulkStorage.HungerAmount = hunger;
    data.MutiesBulkStorage.ExtraWeight = extraWeight;
end

local function getWeightFromModdata(item)
    local data = item:getModData();
    data.MutiesBulkStorage = data.MutiesBulkStorage or {};
    return data.MutiesBulkStorage.FoodWeight or 0.0,
            data.MutiesBulkStorage.HungerAmount or 0.0,
            data.MutiesBulkStorage.ExtraWeight or 0.0;
end

---@param ingredients ArrayList
---@param result Food | InventoryItem
---@param player IsoGameCharacter
function MutiesBulkStorage.OnCreate.SaveLeftovers(ingredients, result, player)
    ---@type Food | InventoryItem
    local food;
    ---@type InventoryItem
    local packingMaterial;
    for i = 0, ingredients:size() - 1 do
        ---@type Food | InventoryItem
        local item = ingredients:get(i);
        if item:getCategory() == "Food" then
            food = item;
        else
            packingMaterial = item;
        end
    end
    if food and packingMaterial then
        result:setOffAge(food:getOffAge());
        result:setOffAgeMax(food:getOffAgeMax());
        result:setBaseHunger(food:getBaseHunger());
        result:setHungChange(food:getHungChange());
        result:setThirstChange(food:getThirstChangeUnmodified());
        result:setBoredomChange(food:getBoredomChangeUnmodified());
        result:setUnhappyChange(food:getUnhappyChangeUnmodified());
        result:setCarbohydrates(food:getCarbohydrates());
        result:setLipids(food:getLipids());
        result:setProteins(food:getProteins());
        result:setCalories(food:getCalories());
        result:setTaintedWater(food:isTaintedWater());

        local hungerBasedWeight = food:getActualWeight();
        food:getScriptItem():getHungerChange()
        local replaceItemWeight = 0.0;
        if food:getReplaceOnUseFullType() then
            local replaceItem = player:getInventory():AddItem(food:getReplaceOnUseFullType());
            replaceItemWeight = replaceItem:getActualWeight();
        end
        hungerBasedWeight = hungerBasedWeight - replaceItemWeight;
        local packingMaterialWeight = packingMaterial:getActualWeight();
        local finalWeight = packingMaterialWeight + hungerBasedWeight * MutiesBulkStorage.Settings.LeftoverRatio;
        result:setActualWeight(finalWeight);
        result:setCustomWeight(true);
        addWeightToModdata(result, hungerBasedWeight, food:getHungerChange(), packingMaterialWeight)
    end
end

local oldStop = ISEatFoodAction.stop;
function ISEatFoodAction:stop()
    oldStop(self);
    ---@type Food | InventoryItem
    local item = self.item;
    if item:getTags():contains("Leftovers") then
        local foodWeight, fullHunger, extraWeight = getWeightFromModdata(item);
        local finalWeight = extraWeight + foodWeight * (item:getHungerChange() / fullHunger) * MutiesBulkStorage.Settings.LeftoverRatio;
        item:setActualWeight(finalWeight);
    end
end

local oldPerform = ISEatFoodAction.perform;
function ISEatFoodAction:perform()
    oldPerform(self);
    ---@type Food | InventoryItem
    local item = self.item;
    if item:getTags():contains("Leftovers") then
        local foodWeight, fullHunger, extraWeight = getWeightFromModdata(item);
        local finalWeight = extraWeight + foodWeight * (item:getHungerChange() / fullHunger) * MutiesBulkStorage.Settings.LeftoverRatio;
        item:setActualWeight(finalWeight);
    end
end

--local oldISEatFoodActionUpdate = ISEatFoodAction.update;
--function ISEatFoodAction:update()
--    oldISEatFoodActionUpdate(self);
--    ---@type Food | InventoryItem
--    local item = self.item;
--    if item:getTags():contains("Leftovers") then
--        local foodWeight, fullHunger, extraWeight = getWeightFromModdata(item);
--        local finalWeight = extraWeight + foodWeight * (item:getHungerChange() / fullHunger) * MutiesBulkStorage.Settings.LeftoverRatio;
--        item:setActualWeight(finalWeight);
--    end
--end

--local oldISEatFoodActionStop = ISEatFoodAction.stop;
--function ISEatFoodAction:stop()
--    oldISEatFoodActionStop(self);
--    ---@type Food | InventoryItem
--    local item = self.item;
--    if item:getTags():contains("Leftovers") then
--        local foodWeight, fullHunger, extraWeight = getWeightFromModdata(item);
--        local finalWeight = extraWeight + foodWeight * (item:getHungerChange() / fullHunger) * MutiesBulkStorage.Settings.LeftoverRatio;
--        item:setActualWeight(finalWeight);
--    end
--end
