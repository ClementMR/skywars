local spawnpoint = minetest.setting_get_pos("static_spawnpoint") or {x=0,y=10,z=0}
local global_countdown = 60
local min_player = 2

function minigame.map_name(map)
    return minigame.maps[map]
end

function minigame.get_table_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    return keys
end

local function clear_inventory(player)
    -- Drop inventory, crafting grid and armor
    local playerinv = player:get_inventory()
    local pos = player:get_pos()

    for l=1,#mcl_death_drop.registered_dropped_lists do
        local inv = mcl_death_drop.registered_dropped_lists[l].inv
        if inv == "PLAYER" then
            inv = playerinv
        elseif type(inv) == "function" then
            inv = inv(player)
        end
        local listname = mcl_death_drop.registered_dropped_lists[l].listname
        if inv then
            inv:set_list(listname, {})
        end
    end
    mcl_armor.update(player)
end

function minigame.update_status(player)
    player:set_hp(20)
    mcl_hunger.set_hunger(player, 20)
    mcl_experience.set_level(player, 0)
    mcl_experience.set_xp(player, 0)
end

function minigame.init_player(player)
    player:set_pos(spawnpoint)
    clear_inventory(player)
    minigame.update_status(player)
    minetest.set_player_privs(player:get_player_name(), {interact=true,shout=true})
end

function minigame.countdown(t, map)
    local id = "countdown"
    local map_data = minigame.map_name(map)
    if t > 0 then
        if map_data.nb >= 2 then
            for _, player in ipairs(map_data.in_game) do
                hud_api.dynamic_text(
                    player,
                    id,
                    "Game starts in " .. t .. "s...",
                    color_api.f_hud.green,
                    0.5,
                    0.4,
                    2,
                    2
                )
                if t <= 5 then
                    minetest.sound_play(id, {to_player = player:get_player_name(), gain = 0.5}, 1)
                end
            end

            minetest.after(1, minigame.countdown, t - 1, map)
        else
            for _, player in ipairs(map_data.in_game) do
                hud_api.remove(player, id)
                minigame.remove_all_spectators(map)
                minigame.send_message(player:get_player_name(), "nil", "Waiting for more players...")
                minetest.log("action", "[Mini-game] The countdown was interrupted on '"..map.."'")
                t = global_countdown
            end
        end
    else
        minetest.log("action", "[Mini-game] The countdown has ended, the game is starting on '"..map.."'")
        minigame.start_game(map)
    end
end

function minigame.start_game(map)
    local id = "countdown"
    local map_data = minigame.map_name(map)
    map_data.in_progress = true
    for _, player in ipairs(map_data.in_game) do
        hud_api.fast_hud(
            player, 
            id, 
            "The Game Begins!", 
            color_api.f_hud.green, 
            0.5,
            0.4,
            2,
            2,
            1
        )
        minetest.sound_play("countdown_end", {to_player = player:get_player_name(), gain = 1.0}, 1)
        kit_selection.give(player)
        minetest.close_formspec(player:get_player_name(), "kit_selection:form")
    end
    for i, pos in ipairs(map_data.player_pos) do
        minigame.boxes(pos, "air")
    end
    minigame.place_map(map_data.schem_pos, map)
    minetest.after(0.1, loot.add_chests, map_data.chest_pos)
    minetest.log("action", "[Mini-game] The game started on '"..map.."'")
end

function minigame.join_game(player, map)
    local id = "player_count"
    local map_data = minigame.map_name(map)

    for map_name, map_data in pairs(minigame.maps) do
        for _, p in ipairs(map_data.in_game) do
            if p == player then
                local message = "You are already in a mini-game."
                minigame.send_message(player:get_player_name(), color_api.f_text.red, message)
                return false
            end
        end
    end

    if map_data.in_progress then
        minigame.add_spectator(player, map_data)
        return false
    end

    if map_data.nb < map_data.max_nb then
        map_data.nb = map_data.nb + 1
        table.insert(map_data.in_game, player)
        minetest.log("action", "[Mini-game] Player " ..player:get_player_name().." joined the map '"..map.."'")

        hud_api.fast_hud(
            player, 
            id, 
            map_data.nb .. "/" .. map_data.max_nb, 
            color_api.f_hud.purple, 
            0.5, 
            0.55, 
            2, 
            2, 
            1.5
        )

        for i, p in ipairs(map_data.in_game) do
            if p == player then
                player:set_pos(map_data.player_pos[i])
                local log_pos = map_data.player_pos[i].x..", "..map_data.player_pos[i].y..", "..map_data.player_pos[i].z
                minetest.log("action", "[Mini-game] Player "..player:get_player_name().." teleported to '"..log_pos.."'")
                minigame.boxes(map_data.player_pos[i], "minigame:playerbox")
                minigame.update_status(player)
                minigame.send_join_message(player, map)
                kit_selection.connection(player)
                break
            end
        end
        if map_data.nb == min_player then
            minetest.log("action", "[Mini-game] The countdown is starting on '"..map.."'")
            minigame.countdown(global_countdown, map)
        elseif map_data.nb < min_player then
            minigame.send_message(player:get_player_name(), "nil", "Waiting for more players...")
        end
    else
        local max = map_data.max_nb .. "/" .. map_data.max_nb
        minigame.add_spectator(player, map_data)
        hud_api.fast_hud(player, id, max, color_api.f_hud.dark_red, 0.5, 0.55, 2, 2, 1.5)
        minetest.log("action", "[Mini-game] Player " ..player:get_player_name().." is a spectator on '"..map.."'")
        return false
    end
end

function minigame.leave_game(player, map)
    local map_data = minigame.map_name(map)
    for i, p in ipairs(map_data.in_game) do
        if p == player then
            minigame.send_leave_message(player, map)
            hud_api.remove(player, "countdown")
            map_data.nb = map_data.nb - 1

            if map_data.nb > 1 then
                minigame.player_count(map)
            end

            table.remove(map_data.in_game, i)
            minetest.log("action", "[Mini-game] Player " ..player:get_player_name().." left the map '"..map.."'")
            break
        end
    end
    minigame.init_player(player)
end

function minigame.remove_items(pos1, pos2)
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

function minigame.reset_data(map_data)
    map_data.in_game = {}
    map_data.nb = 0
    map_data.in_progress = false
end