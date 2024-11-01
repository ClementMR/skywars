kit_selection = {}

local kit_selected = {}

local kits = {
    swordman = {
        items = {
            "mcl_tools:sword_iron",
            "mcl_core:apple 10",
            "mcl_core:stone 10"
        },
        message = "Kit selected : Swordman"
    },
    archer = {
        items = {
            "mcl_bows:bow",
            "mcl_bows:arrow 10",
            "mcl_core:stone 5"
        },
        message = "Kit selected : Archer"
    }
}

local function kit_form(player)
    local formspec =
        "formspec_version[7]" ..
        "size[5.5,4,false]" ..
        "no_prepend[]" ..
        "label[0.5,0.5;Kits: ]" ..
        "image_button[1,1.5;1.5,1.5;default_tool_steelsword.png;swordman;]" ..
        "image_button[3,1.5;1.5,1.5;mcl_bows_bow_1.png;archer;]"
    minetest.show_formspec(player:get_player_name(), "kit_selection:form", formspec)
end

local function select_kit(player, kit_name)
    kit_selected[player:get_player_name()] = kit_name
    hud_api.fast_hud(
        player,
        "kit_selected",
        kits[kit_name].message,
        color_api.f_hud.red,
        0.5,
        0.75,
        0.5,
        0.5,
        3
    )
    minetest.close_formspec(player:get_player_name(), "kit_selection:form")
    minetest.log("action", "[Kit-selection] Player "..player:get_player_name().." selected the kit '"..kit_name.."'")
end

function kit_selection.connection(player)
    player:get_inventory():set_list("main", {})
    player:get_inventory():add_item("main", "kit_selection:selector")
    kit_form(player)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "kit_selection:form" then
        for kit_name, _ in pairs(kits) do
            if fields[kit_name] then
                select_kit(player, kit_name)
                break
            end
        end
    end
end)

function kit_selection.give(player)
    player:get_inventory():set_list("main", {})
    for _, item in ipairs(kits[kit_selected[player:get_player_name()] or "swordman"].items) do
        player:get_inventory():add_item("main", item)
    end
end

minetest.register_craftitem("kit_selection:selector", {
    description = "Select your kit",
    inventory_image = "mcl_compass_compass_00.png",
    groups = {not_in_creative_inventory = 1},
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        kit_form(user)
    end
})