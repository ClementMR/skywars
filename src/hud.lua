hud_ids = {}

function skywars.hud_dynamic(player, id, txt, color, pos_x, pos_y, size_x, size_y)
    local name = player:get_player_name()
    local hud_id = id .. "_" .. name
    if hud_ids[hud_id] then
        player:hud_change(hud_ids[hud_id], "text", txt)
    else
        hud_ids[hud_id] = player:hud_add({
            type = "text",
            position = {x = pos_x or 0.5, y = pos_y or 0.5},
            text = txt or "",
            number = color or 0xFFFFFF,
            size = {x = size_x or 1, y = size_y or 1}
        })
    end
end

function skywars.hud_remove(player, id)
    local name = player:get_player_name()
    local hud_id = id .. "_" .. name
    if hud_ids[hud_id] then
        player:hud_remove(hud_ids[hud_id])
        hud_ids[hud_id] = nil
    end
end

function skywars.hud_exists(player, id)
    local name = player:get_player_name()
    local hud_id = id .. "_" .. name
    return hud_ids[hud_id] ~= nil
end

function skywars.fast_hud(player, id, txt, color, pos_x, pos_y, size_x, size_y, delay)
    skywars.hud_dynamic(
        player,
        id,
        txt,
        color,
        pos_x,
        pos_y,
        size_x,
        size_y
    )
    core.after(delay or 2, skywars.hud_remove, player, id)
end

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    for hud_id, id in pairs(hud_ids) do
        if string.find(hud_id, "_" .. name) then
            player:hud_remove(id)
            hud_ids[hud_id] = nil
        end
    end
end)