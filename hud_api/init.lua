hud_api = {}
hud_ids = {}

function hud_api.dynamic_text(player, id, txt, color, pos_x, pos_y, size_x, size_y)
    local name = player:get_player_name()
    local hud_id = id .. "_" .. name
    if hud_ids[hud_id] then
        player:hud_change(hud_ids[hud_id], "text", txt)
    else
        hud_ids[hud_id] = player:hud_add({
            type = "text",
            position = {x = pos_x or 0.5, y = pos_y or 0.5},
            text = txt or "Hello World!",
            number = color or 0xFFFFFF,
            size = {x = size_x or 1, y = size_y or 1}
        })
    end
end

function hud_api.image(player, id, img, pos_x, pos_y, scale_x, scale_y)
    local name = player:get_player_name()
    local hud_id = id .. "_" .. name
    hud_ids[hud_id] = player:hud_add({
        type = "image",
        position = {x = pos_x or 0.5, y = pos_y or 0.5},
        text = img or "default_image.png",
        scale = {x = scale_x or 1, y = scale_y or 1}
    })
end

function hud_api.remove(player, id)
    local name = player:get_player_name()
    local hud_id = id .. "_" .. name
    if hud_ids[hud_id] then
        player:hud_remove(hud_ids[hud_id])
        hud_ids[hud_id] = nil
    end
end

function hud_api.fast_hud(player, id, txt, color, pos_x, pos_y, size_x, size_y, delay)
    hud_api.dynamic_text(
        player,
        id,
        txt,
        color,
        pos_x,
        pos_y,
        size_x,
        size_y
    )
    minetest.after(delay or 2, hud_api.remove, player, id)
end

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    for hud_id, id in pairs(hud_ids) do
        if string.find(hud_id, "_" .. name) then
            player:hud_remove(id)
            hud_ids[hud_id] = nil
        end
    end
end)
