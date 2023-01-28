require("MutiesBulkStorage/Main");
require("MutiesBulkStorage/Crafting");
require("MutiesBulkStorage/Proxies");

local fak = {};

fak.itemType = "Mutie.FirstAidKitPacked";
fak.Settings = MutiesBulkStorage.Settings.FirstAidKit;
fak.LimitNames = {};
fak.LimitNames.Bandage = "FirstAidKitBandage";
fak.LimitNames.Disinfectant = "FirstAidKitDisinfectant";
fak.LimitNames.Painkillers = "FirstAidKitPainkillers";

local function addFirstAidKitPackedStorage()
    local proxies = MutiesBulkStorage.Proxies;
    MutiesBulkStorage.AddStorage(fak.itemType);
    -- Add disinfectants to the storage
    local disinfectantType = "Base.Disinfectant";
    MutiesBulkStorage.AddStorableToStorage(fak.itemType, disinfectantType);
    MutiesBulkStorage.AddFieldToStorable(fak.itemType, disinfectantType,
            "alcoholPower", proxies.getAlcoholPower);
    MutiesBulkStorage.AddFieldToStorable(fak.itemType, disinfectantType,
            "deltaUses", proxies.getUses, proxies.setUses);
    MutiesBulkStorage.AddLimitToStorable(fak.itemType, disinfectantType, fak.LimitNames.Disinfectant);
    -- Add painkillers to the storage
    local painkillersType = "Base.Pills";
    MutiesBulkStorage.AddStorableToStorage(fak.itemType, painkillersType);
    MutiesBulkStorage.AddFieldToStorable(fak.itemType, painkillersType,
            "deltaUses", proxies.getUses, proxies.setUses);
    MutiesBulkStorage.AddLimitToStorable(fak.itemType, painkillersType, fak.LimitNames.Painkillers);
    -- Dynamically add bandages as storables
    local allItems = getScriptManager():getAllItems();
    ---@type Item
    local firstAidKitScriptItem;
    for i = 0, allItems:size() - 1 do
        ---@type Item
        local item = allItems:get(i);
        if item:isCanBandage() then
            local type = item:getFullName();
            MutiesBulkStorage.AddStorableToStorage(fak.itemType, type);
            MutiesBulkStorage.AddFieldToStorable(fak.itemType, type,
                    "bandagePower", proxies.getBandagePower);
            MutiesBulkStorage.AddLimitToStorable(fak.itemType, type, fak.LimitNames.Bandage);
        end
        if item:getFullName() == fak.itemType then
            firstAidKitScriptItem = item;
        end
    end
    MutiesBulkStorage.AddStorageWeightModifier(fak.itemType, fak.Settings.WeightModifier);
    MutiesBulkStorage.AddStorageMinimumWeight(fak.itemType, firstAidKitScriptItem:getActualWeight());
end
Events.OnInitGlobalModData.Add(addFirstAidKitPackedStorage);

return fak;
