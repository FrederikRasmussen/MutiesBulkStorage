require("MutiesBulkStorage/Main");
local StorageItems = MutiesBulkStorage.StorageItems;
local Settings = MutiesBulkStorage.Settings;
local Limits = Settings.Limits;

---@param storage InventoryItem
function MutiesBulkStorage.InitialiseOrGetStoredItems(storage)
    local data = storage:getModData();
    data.MutiesBulkStorage = data.MutiesBulkStorage or {};
    data.MutiesBulkStorage.StoredItems = data.MutiesBulkStorage.StoredItems or {};
    return data.MutiesBulkStorage.StoredItems;
end

function MutiesBulkStorage.InitialiseOrGetStoredWeight(storage)
    local data = storage:getModData();
    data.MutiesBulkStorage = data.MutiesBulkStorage or {};
    data.MutiesBulkStorage.StoredWeight = data.MutiesBulkStorage.StoredWeight or 0.0;
    return data.MutiesBulkStorage.StoredWeight;
end

function MutiesBulkStorage.SetStoredWeight(storage, storedWeight)
    local data = storage:getModData();
    data.MutiesBulkStorage = data.MutiesBulkStorage or {};
    data.MutiesBulkStorage.StoredWeight = storedWeight;
end

function MutiesBulkStorage.LimitUsedByStorableType(storage, storableType)
    local storageFunctions = StorageItems[storage:getFullType()];
    local storableFunctions = storageFunctions.items[storableType];
    return storableFunctions.limit or storageFunctions.limit or "Default";
end

function MutiesBulkStorage.CountStorageUsedByLimitName(storage, limitName)
    local storedItems = MutiesBulkStorage.InitialiseOrGetStoredItems(storage);
    if limitName == "Default" then
        return #storedItems;
    end
    local count = 0;
    for _, item in pairs(storedItems) do
        if limitName == MutiesBulkStorage.LimitUsedByStorableType(storage, item.type) then
            count = count + 1;
        end
    end
    return count;
end

---@param storable InventoryItem
---@param storage InventoryItem
function MutiesBulkStorage.Predicate.CanAddToStorage(storage, limitName)
    if not storage then return true end
    if not storage.getModData then return true end
    if not storage:getModData() or not storage:getModData().MutiesBulkStorage then return true end
    limitName = limitName or StorageItems[storage:getFullType()].limit or "Default";
    local limit = Limits[limitName];
    local count = MutiesBulkStorage.CountStorageUsedByLimitName(storage, limitName);
    return count < limit;
end

function MutiesBulkStorage.Predicate.CanTakeFromStorage(storage, limitName)
    if not storage then return true end
    if not storage.getModData then return true end
    if not storage:getModData() then return storage:getModData().MutiesBulkStorage; end
    limitName = limitName or StorageItems[storage:getFullType()].limit or "Default";
    local count = MutiesBulkStorage.CountStorageUsedByLimitName(storage, limitName);
    return count > 0;
end

---@param player IsoGameCharacter
local function addToStorage(player, ingredients, shouldRemoveStorable)
    ---@type InventoryItem
    local storage, item;
    for i = 0, ingredients:size() - 1 do
        ---@type InventoryItem
        local current = ingredients:get(i);
        if StorageItems[current:getFullType()] then
            storage = current;
        else
            item = current;
        end
    end
    local storageFunctions = StorageItems[storage:getFullType()];
    local itemFunctions = storageFunctions.items[item:getFullType()];
    if not itemFunctions then
        error("Storage item " .. storage:getFullType() ..
                " attempted to add incompatible item " .. item:getFullType());
    end
    local storedItems = MutiesBulkStorage.InitialiseOrGetStoredItems(storage);
    local itemData = {};
    itemData.type = item:getFullType();
    itemData.weight = item:getActualWeight();
    for field, functions in pairs(itemFunctions) do
        if field ~= "limit" then
            itemData[field] = functions.getter(item);
        end
    end
    table.insert(storedItems, itemData);

    local storedWeight = MutiesBulkStorage.InitialiseOrGetStoredWeight(storage);
    storedWeight = storedWeight + itemData.weight;
    MutiesBulkStorage.SetStoredWeight(storage, storedWeight);
    local finalWeight = storedWeight * storageFunctions.weightModifier;
    if finalWeight < storageFunctions.minimumWeight then
        storage:setActualWeight(storageFunctions.minimumWeight);
    else
        storage:setActualWeight(finalWeight);
    end
    storage:setCustomWeight(true);

    if shouldRemoveStorable then
        player:getInventory():removeItemWithIDRecurse(item:getID());
    end
end

---@param ingredients ArrayList
function MutiesBulkStorage.OnCreate.AddToStorage(ingredients, result, player)
    addToStorage(player, ingredients);
end

function MutiesBulkStorage.OnCreate.AddWholeToStorage(ingredients, result, player)
    addToStorage(player, ingredients, true);
end

function MutiesBulkStorage.FindItemInStorage(storage, limitName)
    local items = MutiesBulkStorage.InitialiseOrGetStoredItems(storage);
    for _, item in pairs(items) do
        if limitName then
            if limitName == MutiesBulkStorage.LimitUsedByStorableType(storage, item.type) then
                return item;
            end
        else
            return item;
        end
    end
end

function MutiesBulkStorage.InstantiateInventoryItemFromStorage(storage, item)
    local itemFunctions = StorageItems[storage:getFullType()].items[item.type];
    local inventoryItem = InventoryItemFactory.CreateItem(item.type);
    for field, value in pairs(item) do
        if field ~= "type" then
            if itemFunctions[field].setter then
                itemFunctions[field].setter(inventoryItem, value);
            end
        end
    end
    return inventoryItem;
end

function MutiesBulkStorage.RemoveItemFromStorage(storage, item)
    local items = MutiesBulkStorage.InitialiseOrGetStoredItems(storage);
    for i = 1, #items do
        if item == items[i] then
            table.remove(items, i);

            local storedWeight = MutiesBulkStorage.InitialiseOrGetStoredWeight(storage);
            storedWeight = storedWeight - item.weight;
            MutiesBulkStorage.SetStoredWeight(storage, storedWeight);
            local storageFunctions = StorageItems[storage:getFullType()];
            local finalWeight = storedWeight * storageFunctions.weightModifier;
            if finalWeight < storageFunctions.minimumWeight then
                storage:setActualWeight(storageFunctions.minimumWeight);
            else
                storage:setActualWeight(finalWeight);
            end
            storage:setCustomWeight(true);

            return true;
        end
    end
    return false;
end

function MutiesBulkStorage.OnCreate.TakeFromStorage(ingredients, result, player, limitName)
    local storage;
    for i = 0, ingredients:size() - 1 do
        ---@type InventoryItem
        local current = ingredients:get(i);
        if StorageItems[current:getFullType()] then
            storage = current;
        end
    end
    local item = MutiesBulkStorage.FindItemInStorage(storage, limitName);
    MutiesBulkStorage.RemoveItemFromStorage(storage, item);
    local inventoryItem = MutiesBulkStorage.InstantiateInventoryItemFromStorage(storage, item);
    player:getInventory():addItem(inventoryItem);
end
