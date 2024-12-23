mg.game_active = false
mg.in_game = {}
mg.spectators = {}
mg.player_count = 0
mg.player_pos = {}
mg.map_pos1 = {}
mg.map_pos2 = {}
mg.map_center = {}
mg.schem_pos = {}

local function read_file(file_path)
    local config = {player_pos = {}}
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
            elseif key == "schem_pos" or key == "map_center" or key == "map_pos1" or key == "map_pos2" then
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
    local config = read_file(minetest.get_modpath("minigame") .. "/map" .. "/configuration.txt")
    if config then
        mg.game_active = false
        mg.in_game = {}
        mg.spectators = {}
        mg.player_count = 0
        mg.player_pos = config.player_pos or {}
        mg.map_pos1 = config.map_pos1 or {}
        mg.map_pos2 = config.map_pos2 or {}
        mg.map_center = config.map_center or {x = 0, y = 0, z = 0}
        mg.schem_pos = config.schem_pos or {x = 0, y = 0, z = 0}
    end
end

minetest.after(0.1, load_maps)