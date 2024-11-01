local F = minetest.formspec_escape
local C = minetest.colorize

local current_map = 1

local function format_map_name(map_name)
    local formatted = map_name:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest) 
        return first:upper() .. rest:lower() 
    end)
    return formatted
end

function minigame.map_form()
    local map_names = minigame.get_table_keys(minigame.maps)
    local map_count = #map_names
    local map_name = map_names[current_map]
    local map_data = minigame.map_name(map_name)
    local formatted_map_name = format_map_name(map_name)
    local map_image = "screenshot_" .. map_name .. ".png"
    local formspec = 
        "size[8,9]"..
        "image_button_exit[7,0;1,1;minigame_exit_bg.png;close;X]"..
        "label[3,0.5;" .. formatted_map_name .. "]"..
        "image[1.55,1.1;6,5;" .. map_image .. "]"

    if map_data.in_progress == true then
        formspec = formspec.."label[3,8;" .. C(color_api.f_text.red, map_data.nb.." player(s) online") .. "]"
        formspec = formspec.."button[1,7;6,1;join;Enter as a spectator]"
    else
        formspec = formspec.."label[3,8;" .. C(color_api.f_text.green, map_data.nb.." player(s) online") .. "]"
        formspec = formspec.."button[1,7;6,1;join;Enter]"
    end

    if map_count > 1 then
        formspec = formspec .. "button[0,4;1,1;prev;<]"
        formspec = formspec .. "button[7,4;1,1;next;>]"
    end

    return formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "minigame:map_selection" then
        local map_names = minigame.get_table_keys(minigame.maps)
        local map_count = #map_names
        if fields.prev then
            current_map = current_map - 1
            if current_map < 1 then
                current_map = map_count
            end
            minetest.show_formspec(player:get_player_name(), "minigame:map_selection", minigame.map_form())
        elseif fields.next then
            current_map = current_map + 1
            if current_map > map_count then
                current_map = 1
            end
            minetest.show_formspec(player:get_player_name(), "minigame:map_selection", minigame.map_form())
        elseif fields.join then
            local map_name = map_names[current_map]
            minigame.join_game(player, map_name)
            minetest.close_formspec(player:get_player_name(), "minigame:map_selection")
        end
    end
end)