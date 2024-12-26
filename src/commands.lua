local dark_green = "#028F00"

minetest.register_chatcommand("join", {
    description = "Allows you to join a mini-game",
    privs = {interact=true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            skywars.send_message(name, "nil", "You are not in the game.")
            return false
        end

        skywars.join_game(player)
    end
})

for _, cmd in ipairs({"quit", "leave"}) do
    minetest.register_chatcommand(cmd, {
        description = "Allows you to leave a mini-game",
        privs = {},
        func = function(name)
            local player = minetest.get_player_by_name(name)
            if skywars.get_player_in_list(player, skywars.get_spectators()) then
                skywars.init_player(player)
                skywars.send_message(name, "nil", "You have left spectator mode.")
            end
            skywars.leave_game(player)
            skywars.remove_spectator(player)
        end
    })
end

minetest.register_chatcommand("print_info", {
    description = "Displays mini-game informations",
    privs = {server=true},
    func = function(name, param)
        skywars.send_message(name, dark_green, "===============================================")

        skywars.send_message(name, "nil", "Player count: " .. skywars.get_player_count())

        local in_game = {}
        for _, player in ipairs(skywars.get_players()) do
            table.insert(in_game, player:get_player_name())
        end
        skywars.send_message(name, "nil", "Player list:  " .. table.concat(in_game, ", "))

        local spectators = {}
        for _, spec in ipairs(skywars.get_spectators()) do
            table.insert(spectators, spec:get_player_name())
        end
        skywars.send_message(name, "nil", "Spectator list:  " .. table.concat(spectators, ", "))

        if skywars.is_game_active() then
            skywars.send_message(name, "nil", "Game is active")
        else
            skywars.send_message(name, "nil", "Game is inactive")
        end

        skywars.send_message(name, dark_green, "===============================================")
    end
})