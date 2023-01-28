require("MutiesBulkStorage/Main");

local StorageItems = {};

function MutiesBulkStorage.AddStorage(fullType)
    StorageItems[fullType] = StorageItems[fullType] or {}
    StorageItems[fullType].type = StorageItems[fullType].type or fullType;
    StorageItems[fullType].items = StorageItems[fullType].items or {};
    StorageItems[fullType].weightModifier = 1.0;
    StorageItems[fullType].minimumWeight = 1.0;
end

function MutiesBulkStorage.RemoveStorage(fullType)
    local storageItem = StorageItems[fullType];
    StorageItems[fullType] = nil;
    return storageItem;
end

function MutiesBulkStorage.AddStorableToStorage(storageFullType, storableFullType)
    StorageItems[storageFullType].items[storableFullType] = StorageItems[storageFullType].items[storableFullType] or {};
    MutiesBulkStorage.AddFieldToStorable(storageFullType, storableFullType, "weight", MutiesBulkStorage.Proxies.getWeight);
end

function MutiesBulkStorage.RemoveStorableFromStorage(storageFullType, storableFullType)
    local storableItem = StorageItems[storageFullType].items[storableFullType];
    StorageItems[storageFullType].items[storableFullType] = nil;
    return storableItem;
end

function MutiesBulkStorage.AddFieldToStorable(storageFullType, storableFullType, fieldName, getter, setter)
    local storableItem = StorageItems[storageFullType].items[storableFullType];
    storableItem[fieldName] = {};
    storableItem[fieldName].getter = getter;
    storableItem[fieldName].setter = setter;
end

function MutiesBulkStorage.AddLimitToStorable(storageFullType, storableFullType, limitName)
    local storableItem = StorageItems[storageFullType].items[storableFullType];
    storableItem.limit = limitName;
end

function MutiesBulkStorage.AddStorageWeightModifier(storageFullType, multiplier)
    StorageItems[storageFullType].weightModifier = multiplier;
end

function MutiesBulkStorage.AddStorageMinimumWeight(storageFullType, minimumWeight)
    StorageItems[storageFullType].minimumWeight = minimumWeight;
end

return StorageItems;