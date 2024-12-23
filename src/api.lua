local C = minetest.colorize

function mg.is_game_active()
    if mg.game_active then
        return true
    end
    return false
end

function mg.set_game_status(value)
    mg.game_active = value
end

function mg.get_players()
    local players = {}
    for _, player in ipairs(mg.in_game) do
        table.insert(players, player)
    end
    return players or {}
end

function mg.is_last_player()
    if mg.player_count == 1 then
        return true
    end
    return false
end

function mg.get_spectators()
    local spectators = {}
    for _, player in ipairs(mg.spectators) do
        table.insert(spectators, player)
    end
    return spectators or {}
end

function mg.set_spectators_null()
    mg.spectators = {}
end

function mg.get_player_in_list(player, list)
    for i, p in ipairs(list) do
        if p == player then
            return true
        end
    end
    return false
end

function mg.remove_player_in_list(player, list)
    for i, p in ipairs(list) do
        if p == player then
            table.remove(list, i)
            break
        end
    end
end

function mg.get_players()
    local players = {}
    for _, player in ipairs(mg.in_game) do
        table.insert(players, player)
    end
    return players or {}
end

function mg.get_player_count()
    return mg.player_count
end

function mg.increment_player_count()
    mg.player_count = mg.player_count + 1
end

function mg.decrement_player_count()
    mg.player_count = mg.player_count - 1
end

function mg.is_player_count_null()
    if mg.get_player_count() == 0 then
        return true
    end
    return false
end

function mg.remove_player(player)
    mg.remove_player_in_list(player, mg.in_game)
    mg.decrement_player_count()
end

function mg.reset_privileges(player)
    return minetest.set_player_privs(player:get_player_name(), {interact=true, shout=true})
end

function mg.send_message(name, color, message)
    return minetest.chat_send_player(name, C(color, message))
end

function mg.send_join_message(player)
    local message = "> " .. player:get_player_name() .. " joined the mini-game."

    for _, player in ipairs(mg.get_players()) do
        mg.send_message(player:get_player_name(), color_api.f_text.green, message)
    end
end

function mg.send_leave_message(player)
    local message = "< " .. player:get_player_name() .. " left the mini-game."

    for _, player in ipairs(mg.get_players()) do
        mg.send_message(player:get_player_name(), color_api.f_text.red, message)
    end

    for _, spectator in ipairs(mg.get_spectators()) do
        mg.send_message(spectator:get_player_name(), color_api.f_text.red, message)
    end
end

function mg.show_player_count()
    local message = "[Player count] ".. mg.get_player_count() .. " players remaining."

    for _, player in ipairs(mg.get_players()) do
        mg.send_message(player:get_player_name(), "nil", message)
    end

    for _, spectator in ipairs(mg.get_spectators()) do
        mg.send_message(spectator:get_player_name(), "nil", message)
    end
end

function mg.winner(player)
    local name = player:get_player_name()
    minetest.sound_play(
        "game_winner", 
        {to_player = name, gain = 1.0}, 
        true
    )

    hud_api.fast_hud(
        player, 
        "winner", 
        player:get_player_name().." won the game!", 
        color_api.f_hud.green, 
        0.5, 
        0.25, 
        3, 
        3, 
        3
    )
    minetest.log("action", "[Winner] " .. name .. " won the game")
end

function mg.is_admin(player)
    if minetest.check_player_privs(player, {game_admin=true}) then
        return true
    end
    return false
end