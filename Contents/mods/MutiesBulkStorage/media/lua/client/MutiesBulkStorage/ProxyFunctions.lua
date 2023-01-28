require("MutiesBulkStorage/Main");

MutiesBulkStorage.Proxies = {};

function MutiesBulkStorage.Proxies.getBandagePower(inventoryItem)
    return inventoryItem:getBandagePower();
end

function MutiesBulkStorage.Proxies.getAlcoholPower(inventoryItem)
    return inventoryItem:getAlcoholPower();
end

function MutiesBulkStorage.Proxies.getUses(drainableComboItem)
    return drainableComboItem:getDelta() + drainableComboItem:getUseDelta();
end

function MutiesBulkStorage.Proxies.setUses(drainableComboItem, useDelta)
    return drainableComboItem:setDelta(useDelta);
end

function MutiesBulkStorage.Proxies.getWeight(inventoryItem)
    return inventoryItem:getActualWeight();
end