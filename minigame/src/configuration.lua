local function read_configuration(file_path)
    local config = { player_pos = {}, chest_pos = {} }
    local file = io.open(file_path, "r")
    if not file then
        minetest.log("error", "[Mini-game] Unable to open configuration file at: " .. file_path)
        return nil
    end
    for line in file:lines() do
        local key, value = line:match("([^=]+)=([^=]+)")
        if key and value then
            key = key:trim()
            value = value:trim()
            if key:match("^pos%d+$") then
                local x, y, z = value:match("([^,]+),([^,]+),([^,]+)")
                if x and y and z then
                    table.insert(config.player_pos, {x = tonumber(x), y = tonumber(y), z = tonumber(z)})
                else
                    minetest.log("warning", "[Mini-game] Invalid player position format in config: " .. line)
                end
            elseif key:match("^chest_pos%d+$") then
                local x, y, z, param2 = value:match("([^,]+),([^,]+),([^,]+),([^,]+)")
                if x and y and z and param2 then
                    table.insert(config.chest_pos,
                        {x = tonumber(x), y = tonumber(y), z = tonumber(z), param2 = tonumber(param2)})
                else
                    minetest.log("warning", "[Mini-game] Invalid chest position format in config: " .. line)
                end
            elseif key == "schem_pos" or key == "map_center" or key == "rm1" or key == "rm2" then
                local x, y, z = value:match("([^,]+),([^,]+),([^,]+)")
                if x and y and z then
                    config[key] = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
                else
                    minetest.log("warning", "[Mini-game] Invalid " .. key .. " format in config: " .. line)
                end
            else
                config[key] = tonumber(value) or value
            end
        end
    end
    file:close()
    return config
end

local function load_maps()
    local maps_dir = minetest.get_modpath("minigame") .. "/maps"
    local map_files = minetest.get_dir_list(maps_dir, true)
    for _, map_name in ipairs(map_files) do
        if map_name ~= "." and map_name ~= ".." then
            local map_path = maps_dir .. "/" .. map_name
            local config = read_configuration(map_path .. "/configuration.txt")
            if config then
                minigame.maps[map_name] = {
                    player_pos = config.player_pos or {},
                    chest_pos = config.chest_pos or {},
                    schem_pos = config.schem_pos or {x = 0, y = 0, z = 0},
                    map_center = config.map_center or {x = 0, y = 0, z = 0},
                    max_nb = tonumber(config.max_player) or 0,
                    death_barrier = tonumber(config.death_barrier) or -10,
                    rm1 = config.rm1 or {},
                    rm2 = config.rm2 or {},
                    nb = 0,
                    in_game = {},
                    spectators = {},
                    in_progress = false,
                }
            else
                minetest.log("error", "[Mini-game] Failed to load config for map: " .. map_name)
            end
        end
    end
end

minetest.after(0.1, load_maps)