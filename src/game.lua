local countdown = 14
local min_player = 2
local max_player = 12
local log = minetest.log

local function add_player(player)
    skywars.increment_player_count()

    table.insert(skywars.in_game, player)

    skywars.fast_hud(
        player, 
        "player_count", 
        skywars.get_player_count() .. "/" .. max_player, 
        "0xd500ff", 
        0.5, 
        0.55, 
        2, 
        2, 
        1.5
    )
    log("action", "[Add Player] Player " .. player:get_player_name() .. " was added to the game")
end

function skywars.join_game(player)
    local name = player:get_player_name()

    --Check if the game is active and if the player is already in a mini-game
    if skywars.is_game_active() then
        skywars.add_spectator(player)

        return false
    elseif skywars.get_player_in_list(player, skywars.get_players()) then
        skywars.send_message(name, "#FF0000", "You are already in a game.")
        log("action", "[Join Game] Player " .. name .. " tried to join a game although he is already in one")

        return false
    end

    if skywars.get_player_count() < max_player then

        -- Add player to the game
        add_player(player)

        player:set_pos(skywars.player_pos[skywars.get_player_count()])
        skywars.set_box(skywars.player_pos[skywars.get_player_count()], "skywars:playerbox")

        skywars.send_join_message(player)

        skywars.clear_inv(player)

        skywars.add_and_show_kits(player)

        skywars.update_status(player)

        if skywars.get_player_count() == min_player then
            skywars.countdown(countdown)
        elseif skywars.get_player_count() < min_player then
            skywars.send_message(name, "nil", "Waiting for more players...")
        end
    else
        skywars.fast_hud(
            player, 
            "player_count", 
            max_player .. "/" .. max_player, 
            "0xA60101",
            0.5, 
            0.55, 
            2, 
            2, 
            1.5
        )

        skywars.add_spectator(player)

        skywars.clear_inv(player)

        log("action", "[Join Game] Player " .. name .. " isn't able to join a game")
    end

    if skywars.get_player_count() == 1 then
        skywars.place_map(skywars.schem_pos)
    end
end

function skywars.start_game()
    skywars.set_game_status(true)

    for _, player in ipairs(skywars.get_players()) do
        minetest.sound_play("countdown_end", {to_player = player:get_player_name(), gain = 1.0}, 1)
        skywars.fast_hud(
            player, 
            "countdown", 
            "Game Starts!", 
            "0x00FF00", 
            0.5,
            0.4,
            2,
            2,
            1
        )

        skywars.give_kit(player)
    end

    skywars.add_chests(skywars.chests_pos)

    for _, pos in ipairs(skywars.player_pos) do
        skywars.set_box(pos, "air")
    end

    log("action", "[Start Game] The game started")
end

function skywars.leave_game(player)
    local name = player:get_player_name()
    if skywars.get_player_in_list(player, skywars.get_players()) then

        skywars.remove_player(player)

        skywars.send_leave_message(player)

        if skywars.get_player_count() > 1 then
            skywars.show_player_count()
        end

        skywars.hud_remove(player, "countdown")

        skywars.init_player(player)

        log("action", "[Leave Game] Player " ..name.." left the game")
    else
        skywars.send_message(name, "#FF0000", "You are not in any game.")
    end
end

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime

    if skywars.is_game_active() then
        -- Game is still active and there is no player
        if skywars.is_player_count_null() then
            skywars.remove_all_spectators()
            skywars.remove_items(skywars.map_pos1, skywars.map_pos2)

            skywars.game_active = false
        end
    end

    for i, player in ipairs(skywars.get_players()) do
        if skywars.is_game_active() then
            -- Last player
            if skywars.is_last_player() then
                skywars.winner(player) -- Shown to winner
                skywars.remove_player(player)
                skywars.init_player(player)
            end
        else
            -- Players can't leave their box
            if vector.distance(player:get_pos(), skywars.player_pos[i]) > 2 then
                player:set_pos(skywars.player_pos[i])
            end
        end
        -- Hide nametags
        player:set_properties({nametag_color = { r = 225, g = 225, b = 225, a = 0 }})
    end

    if timer >= 3 then
        timer = 0

        for i, player in ipairs(skywars.get_players()) do
            if skywars.is_game_active() then
                -- Player is outside the map
                if skywars.is_player_outside(player) then
                    player:set_hp(0)
                end
            end
        end

        for i, spectator in ipairs(skywars.get_spectators()) do
            skywars.set_spectator_properties(spectator)
        end
    end
end)