local kit_selected = {}
local log = minetest.log
local close_form = minetest.close_formspec

local kits = {
    swordman = {
        items = {
            "default:sword_steel",
            "default:apple 10",
            "default:stone 10"
        },
        title = "Swordman"
    },
    builder = {
        items = {
            "default:pick_mese",
            "default:wood 25",
            "default:shovel_steel"
        },
        title = "Builder"
    }
}

local function get_item_description(item_string)
    local item_def = minetest.registered_items[item_string:match("([^ ]+)")]
    if item_def then
        return item_def.description
    else
        return item_string
    end
end

local function kit_content(kit)
    local items_description = {}
    for _, item in ipairs(kit.items) do
        local count = item:match(" (%d+)$") or "1"
        local item_name = item:match("([^ ]+)")
        table.insert(items_description, get_item_description(item_name) .. " x" .. count)
    end
    return table.concat(items_description, "\n")
end

local function kit_form(player)
    local formspec =
        "formspec_version[7]" ..
        "size[5.5,4,false]" ..
        "no_prepend[]" ..
        "label[0.5,0.5;Kits: ]" ..

        "image_button[1,1.5;1.5,1.5;default_tool_steelsword.png;swordman;]" ..
        "tooltip[swordman;" .. kit_content(kits.swordman) .. "]" ..

        "image_button[3,1.5;1.5,1.5;default_tool_mesepick.png;builder;]" ..
        "tooltip[builder;" .. kit_content(kits.builder) .. "]"

    minetest.show_formspec(player:get_player_name(), "skywars:kits_form", formspec)
end

function skywars.add_and_show_kits(player)
    player:get_inventory():set_list("main", {})
    local inv = player:get_inventory()
    inv:add_item("main", "skywars:kit_selector")
    kit_form(player)
end

local function select_kit(name, kit_name)
    kit_selected[name] = kit_name

    skywars.fast_hud(
        minetest.get_player_by_name(name),
        "kits",
        "Kit selected: "..kits[kit_name].title, 
        "0xFF0000",
        0.5,
        0.75,
        0.5,
        0.5,
        3
    )

    close_form(name, "skywars:kits_form")
    log("action", "[Kits] Player "..name.." selected the kit "..kits[kit_name].title)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "skywars:kits_form" then
        for kit_name, _ in pairs(kits) do
            if fields[kit_name] then
                select_kit(player:get_player_name(), kit_name)
                break
            end
        end
    end
end)

function skywars.give_kit(player)
    local inv = player:get_inventory()
    inv:remove_item("main", "skywars:kit_selector")
    for _, item in ipairs(kits[kit_selected[player:get_player_name()] or "swordman"].items) do
        inv:add_item("main", item)
    end

    close_form(player:get_player_name(), "skywars:kits_form")
end

minetest.register_craftitem("skywars:kit_selector", {
    description = "Kit Selector",
    inventory_image = "default_stick.png^[multiply:#FF0000",
    groups = {not_in_creative_inventory = 1},
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        kit_form(user)
    end,
    on_drop = function(itemstack, dropper, pos)
        -- Prevent dropping the item
        return itemstack
    end
})