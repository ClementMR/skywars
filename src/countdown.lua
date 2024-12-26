local min_player = 2
local log = minetest.log

function skywars.countdown(t)
    if t > 0 then
        if skywars.get_player_count() >= min_player then
            for _, player in ipairs(skywars.get_players()) do
                skywars.hud_dynamic(
                    player,
                    "countdown",
                    "Game starts in " .. t .. "s...",
                    "0x00FF00", 
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
            minetest.after(1, skywars.countdown, t - 1)
            log("action", "[Countdown] " .. t .. "s left")
        else
            for _, player in ipairs(skywars.get_players()) do
                skywars.send_message(player:get_player_name(), "nil", "Waiting for more players...")

                skywars.hud_remove(player, "countdown")

                t = countdown

                log("action", "[Countdown] Interrupted")
            end
        end
    else
        log("action", "[Countdown] The countdown is over")
        skywars.start_game()
    end
end