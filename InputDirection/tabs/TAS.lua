return {
    update = function()

    end,
    draw = function()
        Drawing.paint()
        Mupen_lua_ugui.listbox({
            uid = 13377331,
            is_enabled = true,
            rectangle = grid_rect(0, 8, 8, 7),
            selected_index = nil,
            items = VarWatch.get_values(),
        })
        Settings.goalAngle = Mupen_lua_ugui.numberbox({
            uid = 5065,
            is_enabled = true,
            rectangle = grid_rect(4, 3, 4, 1),
            places = 5,
            value = Settings.goalAngle
        })
        Settings.goalMag = Mupen_lua_ugui.numberbox({
            uid = 5066,
            is_enabled = true,
            rectangle = grid_rect(4, 5, 2, 1),
            places = 3,
            value = Settings.goalMag
        })
        Input.update()
    end
}
