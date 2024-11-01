minetest.register_entity("minigame:npc", {
    initial_properties = {
        hp_max = 20,
        selectionbox = { -0.25, 0, -0.25, 0.25, 2, 0.25 },
        visual = "mesh",
        mesh = "mobs_mc_villager.b3d",
        textures = {"mobs_mc_villager_smith.png"},
        infotext = "Hello, my name is Hector!\n\nPunch me to select a mini-game!",
    },
    on_punch = function(self, hitter, time_from_last_punch, tool_capabilities, direction, damage)
        self.object:set_hp(20)
        minetest.show_formspec(hitter:get_player_name(), "minigame:map_selection", minigame.map_form())
        return true
    end,
    on_rightclick = function(self, clicker)
        minetest.show_formspec(clicker:get_player_name(), "minigame:map_selection", minigame.map_form())
        minetest.sound_play("npc-voice", {
            pos = self.object:get_pos(),
            max_hear_distance = 10,
            gain = 1.0,
        })
    end,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        local closest_player, closest_dist = nil, math.huge

        for _, player in ipairs(minetest.get_connected_players()) do
            local player_pos = player:get_pos()
            local dist = vector.distance(pos, player_pos)
            if dist < closest_dist and dist <= 5 then
                closest_player, closest_dist = player, dist
            end
        end

        if closest_player and closest_dist <= 5 then
            local player_pos = closest_player:get_pos()
            local direction = vector.direction(pos, player_pos)
            local yaw = math.atan2(direction.z, direction.x) - math.pi / 2
            self.object:set_yaw(yaw)
        end
    end,
})

minetest.register_craftitem("minigame:npc", {
    description = "Mini-game NPC",
    inventory_image = "default_stick.png^[multiply:#00FF00",
    range = 10.0,
    on_use = function(itemstack, user, pointed_thing)
        local pos = pointed_thing.above
        pos.y = pos.y - 0.5

        if pointed_thing.above then
            minetest.add_entity(pos, "minigame:npc")
        end
    end,
})