function minigame.boxes(pos, material)
    local height = 4
    local width = 3
    local depth = 3
    local p_space = {
        {x = 0, y = 1, z = 0},
        {x = 0, y = 2, z = 0}
    }
    local minp = {
        x = pos.x - math.floor(width / 2),
        y = pos.y - 1,
        z = pos.z - math.floor(depth / 2)
    }
    local maxp = {
        x = pos.x + math.floor(width / 2),
        y = pos.y + height - 1,
        z = pos.z + math.floor(depth / 2)
    }
    minetest.emerge_area(minp, maxp, function(_, _, calls)
        if calls == 0 then
            for y = 0, height - 1 do
                for x = -math.floor(width / 2), math.floor(width / 2) do
                    for z = -math.floor(depth / 2), math.floor(depth / 2) do
                        local r_x = -x
                        local r_z = -z
                        local new_pos = {
                            x = pos.x + r_x,
                            y = pos.y + y - 1,
                            z = pos.z + r_z
                        }
                        local spaces = false
                        for _, space in ipairs(p_space) do
                            if r_x == space.x and y == space.y and r_z == space.z then
                                spaces = true
                                break
                            end
                        end
                        if not spaces then
                            minetest.set_node(new_pos, {name = material})
                        end
                    end
                end
            end
        end
    end)
end

function minigame.place_map(pos, map)
    local map_path = minetest.get_modpath("minigame") .. "/maps/" .. map .. "/map.mts"
    return minetest.place_schematic(pos, map_path, "0", nil, true)
end

minetest.register_node("minigame:playerbox", {
    description = "Playerbox",
	inventory_image = "default_apple.png",
	drawtype = "glasslike_framed_optional",
	is_ground_content = false,
	tiles = {"default_glass.png"},
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	drop = "",
	sounds = mcl_sounds.node_sound_glass_defaults(),
	groups = {creative_breakable = 1, not_in_creative_inventory = 1, not_solid = 1},
	on_blast = function() end,
})