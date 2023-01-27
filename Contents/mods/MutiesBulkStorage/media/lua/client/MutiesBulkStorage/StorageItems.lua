require("MutiesBulkStorage/Main");

local StorageItems = {};

function MutiesBulkStorage.AddStorage(fullType)
    StorageItems[fullType] = StorageItems[fullType] or {}
    StorageItems[fullType].type = StorageItems[fullType].type or fullType;
    StorageItems[fullType].items = StorageItems[fullType].items or {};
    StorageItems[fullType].preAdd = StorageItems[fullType].preAdd or {};
    StorageItems[fullType].postAdd = StorageItems[fullType].postAdd or {};
end

function MutiesBulkStorage.RemoveStorage(fullType)
    local storageItem = StorageItems[fullType];
    StorageItems[fullType] = nil;
    return storageItem;
end

function MutiesBulkStorage.AddStorableToStorage(storageFullType, storableFullType)
    StorageItems[storageFullType].items[storableFullType] = StorageItems[storageFullType].items[storableFullType] or {};
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

function MutiesBulkStorage.PreAddForStorage(fullType, preAdd)
    table.insert(StorageItems[fullType].preAdd, preAdd);
end

function MutiesBulkStorage.PostAddForStorage(fullType, postAdd)
    table.insert(StorageItems[fullType].postAdd, postAdd);
end
return StorageItems;