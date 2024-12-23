mg = {}

minetest.register_privilege("game_admin", {
    give_to_singleplayer = false,
    give_to_admin = true,
})

local modpath = minetest.get_modpath(minetest.get_current_modname()).."/src"

local files = {
    "configuration",
    "api",
    "player",
    "countdown",
    "map",
    "game",
    "spectator",
    "gamesteps",
    "cmd",
}

for _, file in ipairs(files) do
    dofile(modpath.."/"..file..".lua")
end

if minetest.get_modpath("player_api") then
    dofile(modpath.."/npc.lua")
end

minetest.register_on_joinplayer(function(player,  last_login)
    if not mg.is_admin(player) then
        minetest.after(0.1, mg.init_player, player)
    end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    if mg.get_player_in_list(player, mg.get_players()) then

        mg.remove_player(player)

        mg.send_leave_message(player)

        if mg.get_player_count() > 1 then
            mg.show_player_count()
        end
    elseif mg.get_player_in_list(player, mg.get_spectators()) then
        mg.remove_player_in_list(player, mg.spectators)
    end
end)

minetest.register_on_dieplayer(function(player, reason)
    if mg.get_player_in_list(player, mg.get_players()) then

        mg.remove_player(player)

        mg.send_leave_message(player)

        if mg.get_player_count() > 1 then
            mg.show_player_count()
            mg.add_spectator(player)
        end

        player:respawn()
    end
end)

minetest.register_on_respawnplayer(function(player)
    if mg.get_player_in_list(player, mg.get_spectators()) then
        minetest.after(0.1, mg.teleport_spectator, player)
    else
        minetest.after(0.1, mg.init_player, player)
    end
end)

minetest.register_on_mods_loaded(function()
    local old_handlers = minetest.registered_on_chat_messages
    minetest.registered_on_chat_messages = {
        function(name, message)
            local chat = message:sub(1, 1) ~= "/"
            if chat and not minetest.check_player_privs(name, {shout = true}) then
                mg.send_message(name, "nil", "-!- You don't have permission to speak.")
                return true
            end

            for _, handler in ipairs(old_handlers) do
                if handler(name, message) then
                    return true
                end
            end

            local is_spectator = false
            if mg.get_player_in_list(minetest.get_player_by_name(name), mg.get_spectators()) then
                is_spectator = true
            end

            if chat and is_spectator then
                for _, spectator in ipairs(mg.get_spectators()) do
                    mg.send_message(
                        spectator:get_player_name(), 
                        color_api.f_text.grey, 
                        "[Spectator] <" .. name .. "> " .. message
                    )
                    minetest.log("action", "[Spectator] <" ..name .. "> " .. message)
                end

                return true
            elseif chat and not is_spectator then
                minetest.chat_send_all("<" .. name .. "> " .. message)
                minetest.log("action", "CHAT: <" ..name .. "> " .. message)
            end

            return true
        end
    }
end)