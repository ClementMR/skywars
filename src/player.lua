local spawnpoint = minetest.setting_get_pos("static_spawnpoint") or {x=0,y=30,z=0}

local function clear_armor(player)
    local name, armor_inv = armor:get_valid_player(player, "[clearinv]")

    if not name then
        return
    end

    local drop = {}
    for i=1, armor_inv:get_size("armor") do
        local stack = armor_inv:get_stack("armor", i)
        if stack:get_count() > 0 then
            table.insert(drop, stack)
            armor:run_callbacks("on_unequip", player, i, stack)
            armor_inv:set_stack("armor", i, nil)
        end
    end
    armor:save_armor_inventory(player)
    armor:set_player_armor(player)
end

function skywars.clear_inv(player)
    if minetest.get_modpath("3d_armor") then
        clear_armor(player)
    end
    player:get_inventory():set_list("main", {})
    player:get_inventory():set_list("craft", {})
    player:get_inventory():set_list("craftpreview", {})
end

function skywars.update_status(player)
    player:set_hp(20)
end

function skywars.init_player(player)
    if not skywars.is_admin(player) then
        skywars.reset_privileges(player)
        skywars.clear_inv(player)
    end
    player:set_pos(spawnpoint)
    skywars.update_status(player)
end