minigame = {
    maps = {}
}

local current_mode = minetest.get_modpath(minetest.get_current_modname())
dofile(current_mode.."/src/configuration.lua")
dofile(current_mode.."/src/main.lua")
dofile(current_mode.."/src/messages.lua")
dofile(current_mode.."/src/spectators.lua")
dofile(current_mode.."/src/formspec.lua")
dofile(current_mode.."/src/structures.lua")
dofile(current_mode.."/src/cmd.lua")
dofile(current_mode.."/src/npc.lua")

minetest.register_on_joinplayer(function(player,  last_login)
    if not minetest.check_player_privs(player, {protection_bypass=true}) then
        minetest.after(0.1, minigame.init_player, player)
    end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    for map_name, map_data in pairs(minigame.maps) do
        for i, p in ipairs(map_data.in_game) do
            if p == player then
                table.remove(map_data.in_game, i)
                map_data.nb = map_data.nb - 1
                minigame.send_leave_message(player, map_name)
                if map_data.nb > 1 then
                    minigame.player_count(map_name)
                end
                break
            end
        end
        for i, spec in ipairs(map_data.spectators) do
            if spec == player then
                table.remove(map_data.spectators, i)
                break
            end
        end
    end
end)

minetest.register_on_dieplayer(function(player, reason)
    for map_name, map_data in pairs(minigame.maps) do
        for i, p in ipairs(map_data.in_game) do
            if p == player then
                table.remove(map_data.in_game, i)
                map_data.nb = map_data.nb - 1
                minigame.send_leave_message(player, map_name)
                if map_data.nb > 1 then
                    minigame.player_count(map_name)
                end
                return false
            end
        end
    end
    return true
end)

minetest.register_on_respawnplayer(function(player)
    for map_name, map_data in pairs(minigame.maps) do
        for _, p in ipairs(map_data.spectators) do
            if p == player then
                minetest.after(0.1, minigame.teleport_spectator, player, map_data)
                break
            end
        end
    end
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    for map_name, map_data in pairs(minigame.maps) do
        for _, p in ipairs(map_data.in_game) do
            if p == player or p == hitter then
                return false
            end
        end
    end
    return true
end)

minetest.register_on_mods_loaded(function()
    local old_handlers = minetest.registered_on_chat_messages
    minetest.registered_on_chat_messages = {
        function(name, message)
            local chat = message:sub(1, 1) ~= "/"
            if chat and not minetest.check_player_privs(name, {shout = true}) then
                minigame.send_message(name, "nil", "-!- You don't have permission to speak.")
                return true
            end
            for _, handler in ipairs(old_handlers) do
                if handler(name, message) then
                    return true
                end
            end

            local is_spec = false
            for map_name, map_data in pairs(minigame.maps) do
                for _, spec in ipairs(map_data.spectators) do
                    if spec:get_player_name() == name then
                        is_spec = true
                        break
                    end
                end
            end
            if chat and is_spec then
                for map_name, map_data in pairs(minigame.maps) do
                    for _, spec in ipairs(map_data.spectators) do
                        local msg = "[Spectator] <" .. name .. "> " .. message
                        minigame.send_message(spec:get_player_name(), color_api.f_text.grey, msg)
                        minetest.log("action", "SPEC-CHAT: <" ..name .. "> " .. message)
                    end
                end
                return true
            elseif chat and not is_spec then
                minetest.chat_send_all("<" .. name .. "> " .. message)
                minetest.log("action", "CHAT: <" ..name .. "> " .. message)
            end
            return true
        end
    }
end)

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1 then
        timer = 0
        for map_name, map_data in pairs(minigame.maps) do
            for _, player in ipairs(map_data.in_game) do
                local winner = player:get_player_name()
                local id = "winner"
                local pos1 = map.map_pos1
                local pos2 = map.map_pos2

                if pos1 and pos2 then
                    if pos.x < math.min(pos1.x, pos2.x) or pos.x > math.max(pos1.x, pos2.x) or
                       pos.y < math.min(pos1.y, pos2.y) or pos.y > math.max(pos1.y, pos2.y) or
                       pos.z < math.min(pos1.z, pos2.z) or pos.z > math.max(pos1.z, pos2.z) then
                        player:set_hp(0)
                    end
                end

                if map_data.in_progress == true and map_data.nb <= 1 then
                    if map_data.nb == 1 then
                        -- Winner
                        minetest.sound_play("game_winner", {to_player = winner, gain = 1.0}, true)
                        hud_api.fast_hud(
                            player, 
                            id, 
                            "The winner is " .. winner .. "!", 
                            color_api.f_hud.green, 
                            0.5, 
                            0.25, 
                            3, 
                            3, 
                            3
                        )
                        minetest.log("action", "[Mini-game] Player " .. winner .. " won the game on '" .. map_name .. "'")
                        -- Spectators
                        for i, specs in ipairs(map_data.spectators) do
                            minetest.sound_play("game_winner", {to_player = specs:get_player_name(), gain = 1.0}, true)
                            hud_api.fast_hud(
                                specs,
                                id, 
                                "The winner is " .. winner .. "!", 
                                color_api.f_hud.green, 
                                0.5, 
                                0.25, 
                                3, 
                                3, 
                                3
                            )
                        end
                    end
                    minigame.remove_all_spectators(map_data)
                    minigame.init_player(player)
                    -- Reset
                    minigame.remove_items(pos1, pos2)
                    minigame.place_map(map_data.schem_pos, map_name)
                    minigame.reset_data(map_data)
                end
            end
        end
    end
    -- Hide nametags
    for map_name, map_data in pairs(minigame.maps) do
        for _, player in ipairs(map_data.in_game) do
            player:set_properties({nametag_color = { r = 225, b = 225, a = 0 }})
        end
        for _, spec in ipairs(map_data.spectators) do
            minigame.set_properties(spec)
        end
    end
end)