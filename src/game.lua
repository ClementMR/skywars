local countdown = 14
local min_player = 2
local max_player = 12

local function add_player(player)
    mg.increment_player_count()

    table.insert(mg.in_game, player)

    hud_api.fast_hud(
        player, 
        "player_count", 
        mg.get_player_count() .. "/" .. max_player, 
        color_api.f_hud.purple, 
        0.5, 
        0.55, 
        2, 
        2, 
        1.5
    )
    minetest.log("action", "[AddPlayer] Player " .. player:get_player_name() .. " was added to the game")
end

function mg.join_game(player)
    local name = player:get_player_name()

    --Check if the game is active and if the player is already in a mini-game
    if mg.is_game_active() then
        mg.add_spectator(player)

        return false
    elseif mg.get_player_in_list(player, mg.get_players()) then
        mg.send_message(name, color_api.f_text.red, "You are already in a game.")
        minetest.log("action", "[JoinGame] Player " .. name .. " tried to join a game although he is already in one")

        return false
    end

    if mg.get_player_count() < max_player then

        -- Add player to the game
        add_player(player)

        player:set_pos(mg.player_pos[mg.get_player_count()])
        mg.set_box(mg.player_pos[mg.get_player_count()], "minigame:playerbox")

        mg.send_join_message(player)

        mg.clear_inv(player)

        mg.update_status(player)

        if mg.get_player_count() == min_player then
            mg.countdown(countdown)
        elseif mg.get_player_count() < min_player then
            mg.send_message(name, "nil", "Waiting for more players...")
        end
    else
        hud_api.fast_hud(
            player, 
            "player_count", 
            max_player .. "/" .. max_player, 
            color_api.f_hud.dark_red,
            0.5, 
            0.55, 
            2, 
            2, 
            1.5
        )

        mg.add_spectator(player)

        mg.clear_inv(player)

        minetest.log("action", "[JoinGame] Player " .. name .. " isn't able to join a game")
    end
end

function mg.start_game()
    mg.set_game_status(true)

    for _, player in ipairs(mg.get_players()) do
        minetest.sound_play("countdown_end", {to_player = player:get_player_name(), gain = 1.0}, 1)
        hud_api.fast_hud(
            player, 
            "countdown", 
            "The Game Begins!", 
            color_api.f_hud.green, 
            0.5,
            0.4,
            2,
            2,
            1
        )
    end

    for _, pos in ipairs(mg.player_pos) do
        mg.set_box(pos, "air")
    end

    mg.place_map(mg.schem_pos)
    minetest.log("action", "[StartGame] The game started")
end

function mg.leave_game(player)
    local name = player:get_player_name()
    if mg.get_player_in_list(player, mg.get_players()) then

        mg.remove_player(player)

        mg.send_leave_message(player)

        if mg.get_player_count() > 1 then
            mg.show_player_count()
        end

        hud_api.remove(player, "countdown")

        mg.init_player(player)

        minetest.log("action", "[LeaveGame] Player " ..name.." left the game")
    else
        mg.send_message(name, color_api.f_text.red, "You are not in any game.")
    end
end