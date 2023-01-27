require "recipecode";

if not Recipe.GetItemTypes.Bandage then
    function Recipe.GetItemTypes.Bandage(scriptItems)
        local allItems = getScriptManager():getAllItems();
        for i = 0, allItems:size() - 1 do
            ---@type Item
            local item = allItems:get(i);
            if item:isCanBandage() then
                scriptItems:add(item);
            end
        end
    end
end
