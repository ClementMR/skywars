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

function mg.clear_inv(player)
    if minetest.get_modpath("3d_armor") then
        clear_armor(player)
    end
    player:get_inventory():set_list("main", {})
    player:get_inventory():set_list("craft", {})
    player:get_inventory():set_list("craftpreview", {})
end

local function update_stamina(player, value)
    -- function no released yet
end

function mg.update_status(player)
    if minetest.get_modpath("stamina") then
        update_stamina(player, 20)
    end
    player:set_hp(20)
end

function mg.init_player(player)
    if not mg.is_admin(player) then
        mg.reset_privileges(player)
        mg.clear_inv(player)
    end
    player:set_pos(spawnpoint)
    mg.update_status(player)
end