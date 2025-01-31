local log = core.log

local function set_spectator_privileges(player)
    return core.set_player_privs(player:get_player_name(), {shout=true, fly=true, fast=true})
end

function skywars.set_spectator_properties(player)
    player:set_properties({
        makes_footstep_sound = false,
        show_on_minimap = false,
        visual_size = {x = 0, y = 0},
        nametag_color = { r = 225, g = 225, b = 225, a = 0 }
    })
end

local function reset_properties(player)
    player:set_properties({
        makes_footstep_sound = true,
        show_on_minimap = true,
        visual_size = {x = 1, y = 1},
        nametag_color = { r = 225, b = 225, a = 225, g = 225 }
    })
end

function skywars.teleport_spectator(player)
    return player:set_pos(skywars.map_center)
end

function skywars.add_spectator(player)
    local name = player:get_player_name()

    table.insert(skywars.spectators, player)

    local names = {}
    for _, spectator in ipairs(skywars.get_spectators()) do
        table.insert(names, spectator:get_player_name())
        skywars.send_message(spectator:get_player_name(), "#909090", name.." is now spectating.")
    end

    local message = "You are currently spectating! You can leave spectator mode using /quit\nCurrent spectator(s): " .. table.concat(names, ", ")
    skywars.send_message(name, "#909090", message)

    skywars.teleport_spectator(player)

    if not skywars.is_admin(player) then
        set_spectator_privileges(player)
    end

    log("action", "[Spectator] Player " .. name .." became a spectator")
end

function skywars.remove_spectator(player)
    if skywars.get_player_in_list(player, skywars.get_spectators()) then
        if not skywars.is_admin(player) then
            skywars.reset_privileges(player)
        end
        reset_properties(player)

        skywars.remove_player_in_list(player, skywars.spectators)

        log("action", "[Spectator] Player " .. player:get_player_name() .." was removed from the spectator list")
    end
end

function skywars.remove_all_spectators()
    for i, p in ipairs(skywars.get_spectators()) do
        skywars.init_player(p)

        reset_properties(p)

        log("action", "[Spectator] Player " .. p:get_player_name() .." was removed from the spectator list")
    end

    skywars.set_spectators_null()
end