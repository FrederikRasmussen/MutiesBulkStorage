require("MutiesBulkStorage/Crafting");
require("MutiesBulkStorage/Tooltips");
local fak = require("MutiesBulkStorage/FirstAidKit/Main");

local function tooltipText(storage)
    local lines = {};
    if not storage:getModData().MutiesBulkStorage then return lines end;

    local bandageAmount = MutiesBulkStorage.CountStorageUsedByLimitName(storage, "FirstAidKitBandage");
    table.insert(lines, "Bandages: " .. bandageAmount .. "/" .. MutiesBulkStorage.Settings.Limits.FirstAidKitBandage);

    local disinfectantAmount = MutiesBulkStorage.CountStorageUsedByLimitName(storage, "FirstAidKitDisinfectant");
    table.insert(lines, "Disinfectant: " .. disinfectantAmount .. "/" .. MutiesBulkStorage.Settings.Limits.FirstAidKitDisinfectant);

    local painkillersAmount = MutiesBulkStorage.CountStorageUsedByLimitName(storage, "FirstAidKitPainkillers");
    table.insert(lines, "Painkillers: " .. painkillersAmount .. "/" .. MutiesBulkStorage.Settings.Limits.FirstAidKitPainkillers);
    return lines;
end
MutiesBulkStorage.Tooltips[fak.itemType] = tooltipText;