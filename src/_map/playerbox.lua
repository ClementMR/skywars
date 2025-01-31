function skywars.set_box(pos, material)
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

    core.emerge_area(minp, maxp, function(_, _, calls)
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
                            core.set_node(new_pos, {name = material})
                        end
                    end
                end
            end
        end
    end)
end