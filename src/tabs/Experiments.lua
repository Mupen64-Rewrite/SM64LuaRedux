return {
    name = "Experiments",
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
            rectangle = grid_rect(6, 0, 1, 1),
            text = "<",
            is_checked = Settings.grind_left
        })
        Settings.grind_left = not Mupen_lua_ugui.toggle_button({
            uid = 10,
            is_enabled = true,
            rectangle = grid_rect(7, 0, 1, 1),
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

        local lookahead = Mupen_lua_ugui.toggle_button({
            uid = 20,
            is_enabled = true,
            rectangle = grid_rect(0, 1, 3, 1),
            text = "Lookahead",
            is_checked = Settings.lookahead
        })
        Settings.lookahead_length = Mupen_lua_ugui.numberbox({
            uid = 25,
            is_enabled = true,
            rectangle = grid_rect(3, 1, 3, 1),
            value = Settings.lookahead_length,
            places = 1,
        })


        if not Settings.lookahead and lookahead then
            Lookahead.start()
        end

        Settings.lookahead = lookahead
    end
}
