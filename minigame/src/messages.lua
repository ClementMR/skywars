local C = minetest.colorize

function minigame.send_message(name, color, message)
    minetest.chat_send_player(name, C(color, message))
end

function minigame.send_message_to_group(group, color, message)
    for _, player in ipairs(group) do
        minetest.chat_send_player(player:get_player_name(), C(color, message))
    end
end

function minigame.send_join_message(player, map)
    local map_data = minigame.map_name(map)
    local message = "> " .. player:get_player_name() .. " joined the mini-game."
    for _, players in ipairs(map_data.in_game) do
        minigame.send_message(players:get_player_name(), color_api.f_text.green, message)
    end
end

function minigame.send_leave_message(player, map)
    local map_data = minigame.map_name(map)
    local message = "< " .. player:get_player_name() .. " left the mini-game."
    for _, players in ipairs(map_data.in_game) do
        minigame.send_message(players:get_player_name(), color_api.f_text.red, message)
    end
    for _, specs in ipairs(map_data.spectators) do
        minigame.send_message(specs:get_player_name(), color_api.f_text.red, message)
    end
end

function minigame.player_count(map)
    local map_data = minigame.map_name(map)
    local message = map_data.nb .. " players remaining."

    for _, players in ipairs(map_data.in_game) do
        minigame.send_message(players:get_player_name(), "nil", message)
    end
    for _, specs in ipairs(map_data.spectators) do
        minigame.send_message(specs:get_player_name(), "nil", message)
    end
end