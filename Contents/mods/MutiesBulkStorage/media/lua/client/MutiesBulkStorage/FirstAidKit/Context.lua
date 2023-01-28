require("MutiesBulkStorage/Main");
local fak = require("MutiesBulkStorage/FirstAidKit/Main");

---@param player IsoPlayer
local function onTakePainkillers(firstAidKit, player)
    local painkillers = MutiesBulkStorage.FindItemInStorage(firstAidKit, fak.LimitNames.Painkillers);
    local painkillersItem = MutiesBulkStorage.InstantiateInventoryItemFromStorage(firstAidKit, painkillers);
    player:getInventory():addItem(painkillersItem);
    MutiesBulkStorage.RemoveItemFromStorage(firstAidKit, painkillers);
    ISInventoryPaneContextMenu.takePill(painkillersItem, player:getPlayerNum());
end

local function addContextOptionsForSingleItem(character, context, firstAidKit)
    if not instanceof(firstAidKit, "InventoryItem") then
        firstAidKit = firstAidKit.items[1];
    end
    if not firstAidKit:getFullType() == fak.itemType then return false end
    if not MutiesBulkStorage.Predicate.CanTakeFromStorage(firstAidKit, fak.LimitNames.Painkillers) then return false end
    context:addOption(
            getText("ContextMenu_Take_pills"),
            firstAidKit,
            onTakePainkillers, character
    );
end

local function addContextOptions(playerNum, context, items)
    local player = getSpecificPlayer(playerNum);
    for _, item in ipairs(items) do
        if addContextOptionsForSingleItem(player, context, item) then
            return;
        end
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(addContextOptions)