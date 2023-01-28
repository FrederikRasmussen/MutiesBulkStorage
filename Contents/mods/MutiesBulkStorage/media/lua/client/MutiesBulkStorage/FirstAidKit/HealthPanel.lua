require "ISUI/ISHealthPanel"
local fak = require("MutiesBulkStorage/FirstAidKit/Main");



local function isInjured(bodyPart)
    return (bodyPart:HasInjury() or bodyPart:stitched() or bodyPart:getSplintFactor() > 0) and not bodyPart:bandaged()
end

local BandageHandler = {};
function BandageHandler:new(panel, bodyPart)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.panel = panel
    o.bodyPart = bodyPart
    o.items = {}
    return o
end

-- Used in ISHealthPanel.lua
function BandageHandler:checkItem(item)
    if item:getFullType() == fak.itemType then
        if MutiesBulkStorage.Predicate.CanTakeFromStorage(item, fak.LimitNames.Bandage) then
            table.insert(self.items, item);
        end
    end
end

-- Used here
function BandageHandler:onMenuOptionSelected()
    ISTimedActionQueue.add(HealthPanelAction:new(self.panel:getDoctor(), self))
end

-- Used here
function BandageHandler:addToMenu(context)
    context:addOption(
            getText("ContextMenu_Bandage") .. " " .. getText("ContextMenu_WithFirstAidKit"),
            self,
            self.onMenuOptionSelected
    );
end

-- Used in ISHealthPanel.lua
function BandageHandler:isValid()
    return #self.items > 0 and isInjured(self.bodyPart);
end

-- Used in ISHealthPanel.lua
function BandageHandler:perform(previousAction)
    local firstAidKit = self.items[1];
    if firstAidKit:getContainer() ~= self.panel:getDoctor():getInventory() then
        local action = ISInventoryTransferAction:new(self.panel:getDoctor(), firstAidKit, firstAidKit:getContainer(), self.panel:getDoctor():getInventory())
        ISTimedActionQueue.addAfter(previousAction, action)
        -- FIXME: ISHealthPanel.actions never gets cleared
        self.panel.actions = self.panel.actions or {}
        self.panel.actions[action] = self.bodyPart
        previousAction = action;
    end
    local bandage = MutiesBulkStorage.FindItemInStorage(firstAidKit, fak.LimitNames.Bandage);
    local bandageItem = MutiesBulkStorage.InstantiateInventoryItemFromStorage(firstAidKit, bandage);
    self.panel:getDoctor():getInventory():addItem(bandageItem);
    MutiesBulkStorage.RemoveItemFromStorage(firstAidKit, bandage);
    local applyBandage = ISApplyBandage:new(self.panel:getDoctor(), self.panel:getPatient(), bandageItem, self.bodyPart, true);
    ISTimedActionQueue.addAfter(previousAction, applyBandage);
end

local DisinfectHandler = {};
function DisinfectHandler:new(panel, bodyPart)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.panel = panel
    o.bodyPart = bodyPart
    o.items = {}
    return o
end

-- Used in ISHealthPanel.lua
function DisinfectHandler:checkItem(item)
    if item:getFullType() == fak.itemType then
        if MutiesBulkStorage.Predicate.CanTakeFromStorage(item, fak.LimitNames.Disinfectant) then
            table.insert(self.items, item);
        end
    end
end

-- Used here
function DisinfectHandler:onMenuOptionSelected()
    ISTimedActionQueue.add(HealthPanelAction:new(self.panel:getDoctor(), self))
end

-- Used here
function DisinfectHandler:addToMenu(context)
    context:addOption(
            getText("ContextMenu_Disinfect") .. " " .. getText("ContextMenu_WithFirstAidKit"),
            self,
            self.onMenuOptionSelected
    );
end

-- Used in ISHealthPanel.lua
function DisinfectHandler:isValid()
    return #self.items > 0 and isInjured(self.bodyPart);
end

-- Used in ISHealthPanel.lua
function DisinfectHandler:perform(previousAction)
    local firstAidKit = self.items[1];
    if firstAidKit:getContainer() ~= self.panel:getDoctor():getInventory() then
        local action = ISInventoryTransferAction:new(self.panel:getDoctor(), firstAidKit, firstAidKit:getContainer(), self.panel:getDoctor():getInventory())
        ISTimedActionQueue.addAfter(previousAction, action)
        -- FIXME: ISHealthPanel.actions never gets cleared
        self.panel.actions = self.panel.actions or {}
        self.panel.actions[action] = self.bodyPart
        previousAction = action;
    end
    local disinfectant = MutiesBulkStorage.FindItemInStorage(firstAidKit, fak.LimitNames.Disinfectant);
    ---@type Food | InventoryItem
    local disinfectantItem = MutiesBulkStorage.InstantiateInventoryItemFromStorage(firstAidKit, disinfectant);
    self.panel:getDoctor():getInventory():addItem(disinfectantItem);
    MutiesBulkStorage.RemoveItemFromStorage(firstAidKit, disinfectant);
    local disinfect = ISDisinfect:new(self.panel:getDoctor(), self.panel:getPatient(), disinfectantItem, self.bodyPart);
    ISTimedActionQueue.addAfter(previousAction, disinfect);
end

-- Insert handlers for context menu
local original_ISHealthPanel_doBodyPartContextMenu = ISHealthPanel.doBodyPartContextMenu;
function ISHealthPanel:doBodyPartContextMenu(bodyPart, x, y)
    original_ISHealthPanel_doBodyPartContextMenu(self, bodyPart, x, y);

    local newHandlers = {};
    table.insert(newHandlers, BandageHandler:new(self, bodyPart));
    table.insert(newHandlers, DisinfectHandler:new(self, bodyPart));

    self:checkItems(newHandlers);

    -- Is this defining a new context menu?
    local playerNum = self.otherPlayer and self.otherPlayer:getPlayerNum() or self.character:getPlayerNum();
    local context = getPlayerContextMenu(playerNum);
    for _,handler in ipairs(newHandlers) do
        if handler:isValid() then
            handler:addToMenu(context)
        end
    end
end