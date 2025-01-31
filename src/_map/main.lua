function skywars.is_player_outside(player)
    local pos = player:get_pos()
    local pos1 = skywars.map_pos1
    local pos2 = skywars.map_pos2

    if pos1 and pos2 then            
        if pos.x < math.min(pos1.x, pos2.x) or pos.x > math.max(pos1.x, pos2.x) or
            pos.y < math.min(pos1.y, pos2.y) or pos.y > math.max(pos1.y, pos2.y) or
            pos.z < math.min(pos1.z, pos2.z) or pos.z > math.max(pos1.z, pos2.z) then
            return true
        end
    end
end

function skywars.remove_items(pos1, pos2)
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
    for _, obj in ipairs(core.get_objects_inside_radius(c, r)) do
        local entity = obj:get_luaentity()
        if entity and entity.name == "__builtin:item" then
            obj:remove()
        end
    end
end

function skywars.place_map(pos)
    local path = core.get_modpath("skywars") .. "/map/map.mts"
    return core.place_schematic(pos, path, "0", nil, true)
end