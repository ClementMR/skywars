local min_player = 2

function mg.countdown(t)
    if t > 0 then
        if mg.get_player_count() >= min_player then
            for _, player in ipairs(mg.get_players()) do
                hud_api.dynamic_text(
                    player,
                    "countdown",
                    "Game starts in " .. t .. "s...",
                    color_api.f_hud.green,
                    0.5,
                    0.4,
                    2,
                    2
                )
                if t <= 5 then
                    minetest.sound_play(
                        "countdown", 
                        {to_player = player:get_player_name(), gain = 0.5}, 
                        1
                    )
                end
            end
            minetest.after(1, mg.countdown, t - 1)
            minetest.log("action", "[Countdown] " .. t .. "s left")
        else
            for _, player in ipairs(mg.get_players()) do
                mg.send_message(player:get_player_name(), "nil", "Waiting for more players...")
                hud_api.remove(player, "countdown")

                t = countdown

                minetest.log("action", "[Countdown] Interrupted")
            end
        end
    else
        minetest.log("action", "[Countdown] The countdown is over")
        mg.start_game()
    end
end