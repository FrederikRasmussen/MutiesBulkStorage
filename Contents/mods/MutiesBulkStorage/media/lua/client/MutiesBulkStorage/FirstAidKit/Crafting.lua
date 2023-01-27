require("MutiesBulkStorage/Main");
require("MutiesBulkStorage/Crafting");
local fak = require("MutiesBulkStorage/FirstAidKit/Main");

---@param firstAidKit InventoryItem;
function MutiesBulkStorage.Predicate.FirstAidKitHasRoomForBandage(firstAidKit)
    return MutiesBulkStorage.Predicate.CanAddToStorage(firstAidKit, fak.LimitNames.Bandage);
end

function MutiesBulkStorage.Predicate.FirstAidKitHasBandage(firstAidKit)
    return MutiesBulkStorage.Predicate.CanTakeFromStorage(firstAidKit, fak.LimitNames.Bandage);
end

---@param player IsoGameCharacter
function MutiesBulkStorage.OnCreate.FirstAidKitTakeBandage(ingredients, result, player)
    return MutiesBulkStorage.OnCreate.TakeFromStorage(ingredients, result, player, fak.LimitNames.Bandage);
end

function MutiesBulkStorage.Predicate.FirstAidKitHasRoomForDisinfectant(firstAidKit)
    return MutiesBulkStorage.Predicate.CanAddToStorage(firstAidKit, fak.LimitNames.Disinfectant);
end

function MutiesBulkStorage.Predicate.FirstAidKitHasDisinfectant(firstAidKit)
    return MutiesBulkStorage.Predicate.CanTakeFromStorage(firstAidKit, fak.LimitNames.Disinfectant);
end

function MutiesBulkStorage.OnCreate.FirstAidKitTakeDisinfectant(ingredients, result, player)
    return MutiesBulkStorage.OnCreate.TakeFromStorage(ingredients, result, player, fak.LimitNames.Disinfectant);
end

function MutiesBulkStorage.Predicate.FirstAidKitHasRoomForPainkillers(firstAidKit)
    return MutiesBulkStorage.Predicate.CanAddToStorage(firstAidKit, fak.LimitNames.Painkillers);
end

function MutiesBulkStorage.Predicate.FirstAidKitHasPainkillers(firstAidKit)
    return MutiesBulkStorage.Predicate.CanTakeFromStorage(firstAidKit, fak.LimitNames.Painkillers);
end

function MutiesBulkStorage.OnCreate.FirstAidKitTakePainkillers(ingredients, result, player)
    return MutiesBulkStorage.OnCreate.TakeFromStorage(ingredients, result, player, fak.LimitNames.Painkillers);
end