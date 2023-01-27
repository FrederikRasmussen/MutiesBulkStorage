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
    end
end
Events.OnInitGlobalModData.Add(addFirstAidKitPackedStorage);

---@param item InventoryItem
function fak.initData(item)
    local data = item:getModData();
    data.MutiesBulkStorage = {};
    data.MutiesBulkStorage.FirstAidKit = {};
    data.MutiesBulkStorage.FirstAidKit.Bandages = {};
    data.MutiesBulkStorage.FirstAidKit.Disinfectants = {};
    data.MutiesBulkStorage.FirstAidKit.Painkillers = 0;
end

---@param item InventoryItem
function fak.data(item)
    local data = item:getModData();
    if not data.MutiesBulkStorage then return end
    if not data.MutiesBulkStorage.FirstAidKit then return end
    return data.MutiesBulkStorage.FirstAidKit;
end

---@param item InventoryItem
function fak.bandages(item)
    local data = fak.data(item);
    if not data then return end
    return data.Bandages;
end

function fak.bestBandage(bandages)
    local bestBandagePower = 0.0;
    local bestBandage;
    for i = 1, #bandages do
        local bandage = bandages[i];
        if bandage.bandagePower > bestBandagePower then
            bestBandagePower = bandage.bandagePower;
            bestBandage = bandage;
        end
    end
    return bestBandage;
end

function fak.removeBandage(firstAidKit, bandage)
    for i = 1, #fak.bandages(firstAidKit) do
        if fak.bandages(firstAidKit)[i].type == bandage.type then
            table.remove(fak.bandages(firstAidKit), i);
            break;
        end
    end
end

function fak.disinfectants(item)
    local data = fak.data(item);
    if not data then return end
    return data.Disinfectants;
end

function fak.disinfectantUses(item)
    local disinfectants = fak.disinfectants(item);
    local uses = 0;
    for _, disinfectant in pairs(disinfectants) do
        uses = uses + disinfectant.uses;
    end
    return uses;
end

function fak.bestDisinfectant(disinfectants)
    local bestDisinfectantPower = 0;
    local bestDisinfectant;
    for _, disinfectant in pairs(disinfectants) do
        if disinfectant.alcoholPower > bestDisinfectantPower then
            bestDisinfectantPower = disinfectant.alcoholPower;
            bestDisinfectant = disinfectant;
        end
    end
    return bestDisinfectant;
end

function fak.removeDisinfectantUse(firstAidKit, disinfectant)
    for _, current in pairs(fak.disinfectants(firstAidKit)) do
        if current.type == disinfectant.type then
            current.uses = current.uses - 1;
            if current.uses <= 0 then
                fak.disinfectants(firstAidKit)[current.type] = nil;
            end
        end
    end
end

function fak.painkillerUses(item)
    local data = fak.data(item);
    if not data then return end
    return data.Painkillers;
end

function fak.addPainkillerUse(firstAidKit)
    local data = fak.data(firstAidKit);
    data.Painkillers = data.Painkillers + 1;
end

function fak.removePainkillerUse(firstAidKit)
    local data = fak.data(firstAidKit);
    data.Painkillers = data.Painkillers - 1;
end

function fak.painkillerType()
    return "Base.Pills";
end

return fak;
