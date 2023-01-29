local SkippedRecipes = {}
SkippedRecipes["Add flour to plastic tub"] = true;
SkippedRecipes["Fill plastic tub with flour"] = true;

local Replacements = {};
Replacements["Base.Flour"] = {};
table.insert(Replacements["Base.Flour"], "Mutie.PlasticTubFlour");
Replacements["Base.Cornflour"] = {};
table.insert(Replacements["Base.Cornflour"], "Mutie.PlasticTubCornflour")

---@param source Recipe.Source
local function ModifySource(recipe, source)
    local ingredients = source:getItems();
    local ingredientsSet = {};
    local newIngredientLists = {};
    for i = 0, ingredients:size() - 1 do
        local ingredient = ingredients:get(i);
        ingredientsSet[ingredient] = true;
        if Replacements[ingredient] then
            table.insert(newIngredientLists, Replacements[ingredient]);
        end
    end
    for _, list in pairs(newIngredientLists) do
        for _, ingredient in pairs(list) do
            if not ingredientsSet[ingredient] then
                ingredients:add(ingredient);
            end
        end
    end
end

local function ModifySources(recipe, sources)
    if not sources then return end
    for i = 0, sources:size() - 1 do
        ModifySource(recipe, sources:get(i));
    end
end

local function ModifyRecipes()
    local recipes = getScriptManager():getAllRecipes();
    for i = 0, recipes:size() - 1 do
        ---@type JRecipe
        local recipe = recipes:get(i);
        if not SkippedRecipes[recipe:getName()] then
            ModifySources(recipe, recipe:getSource());
        end
    end
end
Events.OnGameStart.Add(ModifyRecipes);