local function set_privileges(player)
    return minetest.set_player_privs(player:get_player_name(), {shout=true, fly=true, fast=true})
end

local function reset_privileges(player)
    return minetest.set_player_privs(player:get_player_name(), {interact=true, shout=true})
end

function minigame.teleport_spectator(player, map_data)
    return player:set_pos(map_data.map_center)
end

function minigame.set_properties(player)
    player:set_properties({
        makes_footstep_sound = false,
        show_on_minimap = false,
        --physical = false,
        nametag_color = { r = 225, g = 225, b = 225, a = 0 }
    })
end

function minigame.reset_properties(player)
    player:set_properties({
        makes_footstep_sound = true,
        show_on_minimap = true,
        --physical = true,
        nametag_color = { r = 225, b = 225, a = 225, g = 225 }
    })
end

function minigame.add_spectator(player, map_data)
    local name = player:get_player_name()

    table.insert(map_data.spectators, player)

    local names = {}
    for _, spec in ipairs(map_data.spectators) do
        table.insert(names, spec:get_player_name())
        minigame.send_message(spec:get_player_name(), color_api.f_text.grey, name.." is now spectating.")
    end

    local message = "You are currently spectating! You can leave spectator mode using /quit\nCurrent spectator(s): " .. table.concat(names, ", ")
    minigame.send_message(name, color_api.f_text.grey, message)
    set_privileges(player)
    mcl_player.player_set_visibility(player, false)
    minigame.teleport_spectator(player, map_data)
end

function minigame.remove_spectator(player, map_data)
    for i, spec in ipairs(map_data.spectators) do
        if spec == player then
            table.remove(map_data.spectators, i)
            reset_privileges(player)
            mcl_player.player_set_visibility(player, true)
            minigame.reset_properties(player)
            break
        end
    end
end

function minigame.remove_all_spectators(map_data)
    if not map_data.spectators then
        minetest.log("error", "[Mini-game] Attempted to remove spectators from a map with no spectators list.")
        return
    end

    for i = #map_data.spectators, 1, -1 do
        local spec = map_data.spectators[i]
        reset_privileges(spec)
        minigame.init_player(spec)
        mcl_player.player_set_visibility(spec, true)
        minigame.reset_properties(spec)
        table.remove(map_data.spectators, i)
    end
end