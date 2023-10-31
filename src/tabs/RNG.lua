return {
    name = "RNG",
    update = function()
    end,
    draw = function()
        Settings.override_rng = Mupen_lua_ugui.toggle_button({
            uid = 1,
            
            rectangle = grid_rect(0, 0, 2, 1),
            text = "Lock to",
            is_checked = Settings.override_rng,
        })
        Settings.override_rng_use_index = Mupen_lua_ugui.toggle_button({
            uid = 2,
            is_enabled = Settings.override_rng,
            rectangle = grid_rect(0, 1, 2, 1),
            text = "Use Index",
            is_checked = Settings.override_rng_use_index,
        })
        Settings.override_rng_value = math.floor(Mupen_lua_ugui.spinner({
            uid = 300,
            is_enabled = Settings.override_rng,
            rectangle = grid_rect(2, 0, 4, 1),
            value = Settings.override_rng_value,
            minimum_value = math.mininteger,
            maximum_value = math.maxinteger
        }))
    end
}
