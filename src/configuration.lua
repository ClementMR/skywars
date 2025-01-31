local log = core.log

skywars.game_active = false
skywars.in_game = {}
skywars.spectators = {}
skywars.player_count = 0
skywars.player_pos = {}
skywars.chests_pos = {}
skywars.map_pos1 = {}
skywars.map_pos2 = {}
skywars.map_center = {}
skywars.schem_pos = {}

local function read_file(file_path)
    local config = { player_pos = {}, chests_pos = {} }
    local file = io.open(file_path, "r")
    if not file then
        log("error", "[Configuration] Unable to open configuration file at: " .. file_path)
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
                    log("warning", "[Configuration] Invalid player position format in config: " .. line)
                end
            elseif key:match("^chest_pos%d+$") then
                local x, y, z, param2 = value:match("([^,]+),([^,]+),([^,]+),([^,]+)")
                if x and y and z and param2 then
                    table.insert(config.chests_pos,
                        {x = tonumber(x), y = tonumber(y), z = tonumber(z), param2 = tonumber(param2)})
                else
                    core.log("warning", "[Configuration] Invalid chest position format in config: " .. line)
                end
            elseif key == "schem_pos" or key == "map_center" or key == "map_pos1" or key == "map_pos2" then
                local x, y, z = value:match("([^,]+),([^,]+),([^,]+)")
                if x and y and z then
                    config[key] = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
                else
                    log("warning", "[Configuration] Invalid " .. key .. " format in config: " .. line)
                end
            else
                config[key] = tonumber(value) or value
            end
        end
    end
    file:close()
    return config
end

local function load_map_conf()
    local config = read_file(core.get_modpath("skywars") .. "/map" .. "/configuration.txt")
    if config then
        skywars.player_pos = config.player_pos or {}
        skywars.chests_pos = config.chests_pos or {}
        skywars.map_pos1 = config.map_pos1 or {}
        skywars.map_pos2 = config.map_pos2 or {}
        skywars.map_center = config.map_center or {x = 0, y = 0, z = 0}
        skywars.schem_pos = config.schem_pos or {x = 0, y = 0, z = 0}
    end
end

core.after(0.1, load_map_conf)