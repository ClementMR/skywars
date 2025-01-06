local C = minetest.colorize
local log = minetest.log

function skywars.is_game_active()
    return skywars.game_active
end

function skywars.set_game_status(value)
    skywars.game_active = value
end

function skywars.get_players()
    local players = {}
    for _, player in ipairs(skywars.in_game) do
        table.insert(players, player)
    end
    return players or {}
end

function skywars.is_last_player()
    return skywars.player_count == 1
end

function skywars.get_spectators()
    local spectators = {}
    for _, player in ipairs(skywars.spectators) do
        table.insert(spectators, player)
    end
    return spectators or {}
end

function skywars.set_spectators_null()
    skywars.spectators = {}
end

function skywars.get_player_in_list(player, list)
    for i, p in ipairs(list) do
        if p == player then
            return true
        end
    end
    return false
end

function skywars.remove_player_in_list(player, list)
    for i, p in ipairs(list) do
        if p == player then
            table.remove(list, i)
            break
        end
    end
end

function skywars.get_players()
    local players = {}
    for _, player in ipairs(skywars.in_game) do
        table.insert(players, player)
    end
    return players or {}
end

function skywars.get_player_count()
    return skywars.player_count
end

function skywars.increment_player_count()
    skywars.player_count = skywars.player_count + 1
end

function skywars.decrement_player_count()
    skywars.player_count = skywars.player_count - 1
end

function skywars.is_player_count_null()
    return skywars.get_player_count() == 0
end

function skywars.remove_player(player)
    skywars.remove_player_in_list(player, skywars.in_game)
    skywars.decrement_player_count()
end

function skywars.reset_privileges(player)
    return minetest.set_player_privs(player:get_player_name(), {interact=true, shout=true})
end

function skywars.send_message(name, color, message)
    return minetest.chat_send_player(name, C(color, message))
end

function skywars.send_join_message(player)
    local message = ">> " .. player:get_player_name() .. " joined the mini-game."

    for _, player in ipairs(skywars.get_players()) do
        skywars.send_message(player:get_player_name(), "#00FF00", message)
    end

    for _, spectator in ipairs(skywars.get_spectators()) do
        skywars.send_message(spectator:get_player_name(), "#00FF00", message)
    end
end

function skywars.send_leave_message(player)
    local message = "<< " .. player:get_player_name() .. " left the mini-game."

    for _, player in ipairs(skywars.get_players()) do
        skywars.send_message(player:get_player_name(), "#FF0000", message)
    end

    for _, spectator in ipairs(skywars.get_spectators()) do
        skywars.send_message(spectator:get_player_name(), "#FF0000", message)
    end
end

function skywars.show_player_count()
    local message = "[Player count] ".. skywars.get_player_count() .. " players remaining."

    for _, player in ipairs(skywars.get_players()) do
        skywars.send_message(player:get_player_name(), "nil", message)
    end

    for _, spectator in ipairs(skywars.get_spectators()) do
        skywars.send_message(spectator:get_player_name(), "nil", message)
    end
end

function skywars.winner(player)
    local name = player:get_player_name()
    minetest.sound_play(
        "game_winner", 
        {to_player = name, gain = 1.0}, 
        true
    )

    skywars.fast_hud(
        player, 
        "winner", 
        player:get_player_name().." won the game!", 
        "0x00FF00", 
        0.5, 
        0.25, 
        3, 
        3, 
        3
    )
    log("action", "[Winner] " .. name .. " won the game")
end

function skywars.is_admin(player)
    if minetest.check_player_privs(player, {game_admin=true}) then
        return true
    end
    return false
end