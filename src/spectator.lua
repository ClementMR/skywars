local function set_spectator_privileges(player)
    return minetest.set_player_privs(player:get_player_name(), {shout=true, fly=true, fast=true})
end

function mg.set_spectator_properties(player)
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

function mg.teleport_spectator(player)
    return player:set_pos(mg.map_center)
end

function mg.add_spectator(player)
    local name = player:get_player_name()

    table.insert(mg.spectators, player)

    local names = {}
    for _, spectator in ipairs(mg.get_spectators()) do
        table.insert(names, spectator:get_player_name())
        mg.send_message(spectator:get_player_name(), color_api.f_text.grey, name.." is now spectating.")
    end

    local message = "You are currently spectating! You can leave spectator mode using /quit\nCurrent spectator(s): " .. table.concat(names, ", ")
    mg.send_message(name, color_api.f_text.grey, message)

    mg.teleport_spectator(player)

    if not mg.is_admin(player) then
        set_spectator_privileges(player)
    end

    minetest.log("action", "[Spectator] Player " .. name .." became a spectator")
end

function mg.remove_spectator(player)
    if mg.get_player_in_list(player, mg.get_spectators()) then
        if not mg.is_admin(player) then
            mg.reset_privileges(player)
        end
        reset_properties(player)

        mg.remove_player_in_list(player, mg.spectators)

        minetest.log("action", "[Spectator] Player " .. player:get_player_name() .." was removed from the spectator list")
    end
end

function mg.remove_all_spectators()
    for i, p in ipairs(mg.get_spectators()) do
        mg.init_player(p)

        reset_properties(p)

        minetest.log("action", "[Spectator] Player " .. p:get_player_name() .." was removed from the spectator list")
    end

    mg.set_spectators_null()
end