return {
    name = "Grind",
    update = function()

    end,
    draw = function()
        if Mupen_lua_ugui.button({
                uid = 0,
                is_enabled = true,
                rectangle = grid_rect(0, 0, 3, 1),
                text = Settings.grind and "Stop" or "Start",
            }) then
            Settings.grind = not Settings.grind
            if Settings.grind then
                Grind.start()
            end
        end
        Settings.grind_left = Mupen_lua_ugui.toggle_button({
            uid = 5,
            is_enabled = true,
            rectangle = grid_rect(0, 1, 1, 1),
            text = "<",
            is_checked = Settings.grind_left
        })
        Settings.grind_left = not Mupen_lua_ugui.toggle_button({
            uid = 10,
            is_enabled = true,
            rectangle = grid_rect(1, 1, 1, 1),
            text = ">",
            is_checked = not Settings.grind_left
        })
        Settings.grind_divisor = Mupen_lua_ugui.numberbox({
            uid = 15,
            is_enabled = true,
            rectangle = grid_rect(3, 0, 3, 1),
            value = Settings.grind_divisor,
            places = 2,
        })
    end
}
