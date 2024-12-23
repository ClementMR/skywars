function mg.is_player_outside(player)
    local pos = player:get_pos()
    local pos1 = mg.map_pos1
    local pos2 = mg.map_pos2

    if pos1 and pos2 then            
        if pos.x < math.min(pos1.x, pos2.x) or pos.x > math.max(pos1.x, pos2.x) or
            pos.y < math.min(pos1.y, pos2.y) or pos.y > math.max(pos1.y, pos2.y) or
            pos.z < math.min(pos1.z, pos2.z) or pos.z > math.max(pos1.z, pos2.z) then
            return true
        end
    end
end

function mg.remove_items(pos1, pos2)
    local c = {
        x = (pos1.x + pos2.x) / 2,
        y = (pos1.y + pos2.y) / 2,
        z = (pos1.z + pos2.z) / 2
    }
    local r = math.max(
        math.abs(pos1.x - pos2.x) / 2,
        math.abs(pos1.y - pos2.y) / 2,
        math.abs(pos1.z - pos2.z) / 2
    )
    for _, obj in ipairs(minetest.get_objects_inside_radius(c, r)) do
        local entity = obj:get_luaentity()
        if entity and entity.name == "__builtin:item" then
            obj:remove()
        end
    end
end

function mg.set_box(pos, material)
    local height, width, depth = 4, 3, 3

    local space = {
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
                        for _, s in ipairs(space) do
                            if r_x == s.x and y == s.y and r_z == s.z then
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

function mg.place_map(pos)
    local path = minetest.get_modpath("minigame") .. "/map/map.mts"
    return minetest.place_schematic(pos, path, "0", nil, true)
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
	sounds = default.node_sound_glass_defaults(),
	groups = {not_in_creative_inventory = 1},
	on_blast = function() end,
})

minetest.register_node("minigame:mapbox", {
    description = "Mapbox",
    inventory_image = "default_apple.png",
	drawtype = "airlike",
	paramtype = "light",
    is_ground_content = false,
	tiles = {"blank.png"},
	sunlight_propagates = true,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	on_blast = function() end,
})