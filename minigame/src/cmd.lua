minetest.register_chatcommand("select_map", {
    description = "Allows you to select a map",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            minetest.show_formspec(name, "minigame:map_selection", minigame.map_form())
        else
            minetest.chat_send_player(name, "You are not in the game.")
        end
    end
})

minetest.register_chatcommand("join", {
    description = "Allows you to join a mini-game",
    params = "",
    privs = {interact=true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            minetest.chat_send_player(name, "You are not in the game.")
            return false
        end

        if minigame.maps[param] then
            minigame.join_game(player, param)
        else
            local list = table.concat(minigame.get_table_keys(minigame.maps), ", ")
            local message = "Please provide a valid map name.\nAvailable maps : "..list
            minigame.send_message(name, "nil", message)
        end
    end
})

for _, cmd in ipairs({"quit", "leave"}) do
    minetest.register_chatcommand(cmd, {
        description = "Allows you to leave a mini-game",
        params = "",
        privs = {},
        func = function(name)
            local player = minetest.get_player_by_name(name) 
            local found = false
            if not player then
                minetest.chat_send_player(name, "You are not in the game.")
                return false
            end

            for map_name, map_data in pairs(minigame.maps) do
                for _, p in ipairs(map_data.in_game) do
                    if p == player then
                        minigame.leave_game(player, map_name)
                        found = true
                        return
                    end
                end
                for i, spec in ipairs(map_data.spectators) do
                    if spec == player then
                        minigame.remove_spectator(player, map_data)
                        minigame.init_player(player)
                        minigame.send_message(name, "nil", "You have left spectator mode.")
                        found = true
                        return
                    end
                end
            end
            if not found then
                minigame.send_message(name, "nil", "You are not currently in any mini-game.")
            end
        end
    })
end