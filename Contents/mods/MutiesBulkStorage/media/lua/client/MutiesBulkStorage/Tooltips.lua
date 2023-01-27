require "MutiesBulkStorage/Main";

MutiesBulkStorage.Tooltips = {};

---@param item InventoryItem
local function findCustomText(item)
    local tooltipTextFunction = MutiesBulkStorage.Tooltips[item:getFullType()];
    if tooltipTextFunction then
        local lines = tooltipTextFunction(item);
        if #lines <= 0 then return nil end
        local text = lines[1];
        for i = 2, #lines do
            text = text .. "\n" .. lines[i];
        end
        return text;
    end
    return nil;
end

---@param inventoryTooltip ISToolTipInv
local function renderTooltip(inventoryTooltip)
    if ISContextMenu.instance and ISContextMenu.instance.visibleCheck then return end
    if (inventoryTooltip.x <= 0 or inventoryTooltip.y <= 0) then return end
    if not inventoryTooltip.item then return end
    local text = findCustomText(inventoryTooltip.item);
    if not text then return end

    ---@type UIFont
    local drawFont = UIFont[getCore():getOptionTooltipFont()];
    ---@type UIElement
    local tooltip = inventoryTooltip.tooltip;

    --Mimic vanilla style
    local topMargin = 5;
    local bottomMargin = 5;
    local leftMargin = 5;
    local rightMargin = 6;

    local x = 0;
    local y = tooltip:getHeight() - 1;
    local width = math.max(
            tooltip:getWidth() + leftMargin + rightMargin,
            getTextManager():MeasureStringX(drawFont, text) + 20
    );
    local height =
    getTextManager():MeasureStringY(drawFont, text)
            + topMargin
            + bottomMargin;

    local backgroundColour = inventoryTooltip.backgroundColor;
    inventoryTooltip:drawRect(
            x, y,
            width, height,
            backgroundColour.a, backgroundColour.r, backgroundColour.g, backgroundColour.b
    );

    local borderColour = inventoryTooltip.borderColor;
    inventoryTooltip:drawRectBorder(
            x, y,
            width, height,
            borderColour.a, borderColour.r, borderColour.g, borderColour.b
    );
    tooltip:DrawText(
            drawFont, text,
            leftMargin + x, y + topMargin,
            1.0, 1.0, 0.8, 1.0
    );
end

local originalISToolTipInvRender = ISToolTipInv.render;
function ISToolTipInv:render()
    renderTooltip(self);
    originalISToolTipInvRender(self);
end