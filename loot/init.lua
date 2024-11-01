loot = {}

local items_list = {
    {name = "mcl_tools:sword_stone", count = {min = 1, max = 1}, chance = 0.8},
    {name = "mcl_tools:sword_iron", count = {min = 1, max = 1}, chance = 0.5},
    {name = "mcl_tools:pick_stone", count = {min = 1, max = 1}, chance = 0.8},
    {name = "mcl_tools:pick_iron", count = {min = 1, max = 1}, chance = 0.4},
    {name = "mcl_bows:bow", count = {min = 1, max = 1}, chance = 0.3},
    {name = "mcl_bows:arrow", count = {min = 6, max = 12}, chance = 0.5},
    {name = "mcl_core:apple", count = {min = 4, max = 8}, chance = 0.5},
    {name = "mcl_mobitems:cooked_beef", count = {min = 3, max = 6}, chance = 0.4},
    {name = "mcl_experience:bottle", count = {min = 16, max = 32}, chance = 0.2},
    {name = "mcl_core:lapis", count = {min = 8, max = 16}, chance = 0.25},
    {name = "mcl_wool:white", count = {min = 6, max = 12}, chance = 0.8},
    {name = "mcl_core:wood", count = {min = 8, max = 16}, chance = 0.9},
    {name = "mcl_core:stone", count = {min = 6, max = 12}, chance = 1},
    {name = "mcl_armor:helmet_iron", count = {min = 1, max = 1}, chance = 0.2},
    {name = "mcl_armor:chestplate_iron", count = {min = 1, max = 1}, chance = 0.2},
    {name = "mcl_armor:leggings_iron", count = {min = 1, max = 1}, chance = 0.2},
    {name = "mcl_armor:boots_iron", count = {min = 1, max = 1}, chance = 0.2},
    {name = "mcl_armor:helmet_leather", count = {min = 1, max = 1}, chance = 0.4},
    {name = "mcl_armor:chestplate_leather", count = {min = 1, max = 1}, chance = 0.4},
    {name = "mcl_armor:leggings_leather", count = {min = 1, max = 1}, chance = 0.4},
    {name = "mcl_armor:boots_leather", count = {min = 1, max = 1}, chance = 0.4},
    {name = "mcl_buckets:bucket_water", count = {min = 1, max = 1}, chance = 0.1},
    {name = "mcl_buckets:bucket_lava", count = {min = 1, max = 1}, chance = 0.05},
    {name = "mcl_potions:swiftness_lingering", count = {min = 1, max = 1}, chance = 0.1},
    {name = "mcl_potions:health_boost_lingering", count = {min = 1, max = 1}, chance = 0.1},
}

function loot.fill_chests(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    for _, item in ipairs(items_list) do
        local slot = math.random(1, 27)
        local count = math.random(item.count.min, item.count.max)
        if math.random() <= item.chance then
            inv:set_stack("main", slot, ItemStack(item.name.." "..count))
        end
    end
end

function loot.add_chests(positions)
    for _, pos in ipairs(positions) do
        minetest.set_node({x = pos.x, y = pos.y, z = pos.z}, {name = "mcl_chests:chest_small", param2 = pos.param2 or 0})
        loot.fill_chests(pos)
        minetest.log("action", "[Loot] chest placed at '"..pos.x..", "..pos.y..", "..pos.z.."'")
    end
end