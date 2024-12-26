minetest.register_node("skywars:playerbox", {
    description = "Playerbox",
	inventory_image = "default_apple.png",
	drawtype = "glasslike_framed_optional",
	is_ground_content = false,
	tiles = {"default_glass.png"},
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	drop = "",
	sounds = default.node_sound_glass_defaults(),
	groups = {not_in_creative_inventory = 1},
	on_blast = function() end,
})

minetest.register_node("skywars:mapbox", {
    description = "Mapbox",
    inventory_image = "default_apple.png",
	drawtype = "airlike",
	paramtype = "light",
    is_ground_content = false,
	tiles = {"blank.png"},
	sunlight_propagates = true,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	on_blast = function() end,
})