local max_slots = 31
local log = minetest.log

local treasures = {
    {name = "default:sword_stone", max = 1, chance = 0.8},
    {name = "default:sword_steel", max = 1, chance = 0.5},
    {name = "default:pick_stone", max = 1, chance = 0.8},
    {name = "default:pick_steel", max = 1, chance = 0.4},
    {name = "default:apple", max = 20, chance = 0.4},
    {name = "default:mese_crystal", max = 4, chance = 0.25},
    {name = "default:wood", chance = 0.9},
    {name = "default:stone", chance = 1},
}
--[[
if minetest.get_modpath("3d_armor") then
    treasures = {
        {name = "3d_armor:helmet_steel", max = 1, chance = 0.2},
        {name = "3d_armor:chestplate_steel", max = 1, chance = 0.2},
        {name = "3d_armor:leggings_steel", max = 1, chance = 0.2},
        {name = "3d_armor:boots_steel", max = 1, chance = 0.2},
        {name = "3d_armor:helmet_wood", max = 1, chance = 0.4},
        {name = "3d_armor:chestplate_wood", max = 1, chance = 0.4},
        {name = "3d_armor:leggings_wood", max = 1, chance = 0.4},
        {name = "3d_armor:boots_wood", max = 1, chance = 0.4}
    }
end]]

function skywars.fill_chests(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    for _, treasure in ipairs(treasures) do
        local slot = math.random(1, max_slots)
        local count = math.random(1, treasure.max or 99)
        if math.random() <= treasure.chance then
            inv:set_stack("main", slot, ItemStack(treasure.name.." "..count))
        end
    end
end

function skywars.add_chests(positions)
    for _, pos in ipairs(positions) do
        minetest.set_node(
            {x = pos.x, y = pos.y, z = pos.z}, 
            {name = "default:chest", param2 = pos.param2 or 0}
        )
        skywars.fill_chests(pos)
        log("action", "[Treasures] chest placed at '"..pos.x..", "..pos.y..", "..pos.z.."'")
    end
end