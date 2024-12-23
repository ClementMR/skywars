local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime

    -- Hide nametag
    for _, player in ipairs(mg.get_players()) do
        player:set_properties({nametag_color = { r = 225, g = 225, b = 225, a = 0 }})
    end

    if timer >= 1 then
        timer = 0
        for i, player in ipairs(mg.get_players()) do
            -- Map is still active
            if mg.is_game_active() then
                -- Player is outside the map
                if mg.is_player_outside(player) then
                    player:set_hp(0)
                end

                -- Player is the last one
                if mg.is_last_player() then
                    mg.winner(player) -- Shown to winner
                    mg.init_player(player)
                end

                -- Game is still active and there is no player
                if mg.is_player_count_null() then
                    mg.remove_all_spectators()
                    mg.remove_items(mg.map_pos1, mg.map_pos2)

                    mg.place_map(mg.schem_pos)
                    mg.game_active = false
                end
            else
                -- Player can't leave a box
                if vector.distance(player:get_pos(), mg.player_pos[i]) > 2 then
                    player:set_pos(mg.player_pos[i])
                end
            end
        end

        for i, spectator in ipairs(mg.get_spectators()) do
            mg.set_spectator_properties(spectator)
        end
    end
end)