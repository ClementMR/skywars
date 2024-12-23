minetest.register_chatcommand("join", {
    description = "Allows you to join a mini-game",
    privs = {interact=true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            mg.send_message(name, "nil", "You are not in the game.")
            return false
        end

        mg.join_game(player)
    end
})

for _, cmd in ipairs({"quit", "leave"}) do
    minetest.register_chatcommand(cmd, {
        description = "Allows you to leave a mini-game",
        privs = {interact=true},
        func = function(name)
            local player = minetest.get_player_by_name(name)
            if mg.get_player_in_list(player, mg.get_spectators()) then
                mg.init_player(player)
                mg.send_message(name, "nil", "You have left spectator mode.")
            end
            mg.leave_game(player)
            mg.remove_spectator(player)
        end
    })
end

minetest.register_chatcommand("print_info", {
    description = "Displays mini-game informations",
    privs = {server=true},
    func = function(name, param)
        mg.send_message(name, color_api.f_text.dark_green, "===============================================")

        mg.send_message(name, "nil", "Player count: " .. mg.get_player_count())

        local in_game = {}
        for _, player in ipairs(mg.get_players()) do
            table.insert(in_game, player:get_player_name())
        end
        mg.send_message(name, "nil", "Player list:  " .. table.concat(in_game, ", "))

        local spectators = {}
        for _, spec in ipairs(mg.get_spectators()) do
            table.insert(spectators, spec:get_player_name())
        end
        mg.send_message(name, "nil", "Spectator list:  " .. table.concat(spectators, ", "))

        if mg.is_game_active() then
            mg.send_message(name, "nil", "Game is active")
        else
            mg.send_message(name, "nil", "Game is inactive")
        end

        mg.send_message(name, color_api.f_text.dark_green, "===============================================")
    end
})