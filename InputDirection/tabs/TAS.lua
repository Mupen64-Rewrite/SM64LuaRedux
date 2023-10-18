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

        local joystick_rect = grid(0, 4, 4, 4)
        Mupen_lua_ugui.joystick({
            uid = 10000,
            is_enabled = true,
            rectangle = {
                x = joystick_rect[1],
                y = joystick_rect[2],
                width = joystick_rect[3],
                height = joystick_rect[4]
            },
            position = {
                x = MoreMaths.Remap(Joypad.input.X, -128, 128, 0, 1),
                y = MoreMaths.Remap(-Joypad.input.Y, -128, 128, 0, 1),
            }
        })
        if Settings.goalMag and Settings.goalMag < 127 then
            local r = Settings.goalMag
            BreitbandGraphics.draw_ellipse({
                x = joystick_rect[1] + joystick_rect[3] / 2 - r / 2,
                y = joystick_rect[2] + joystick_rect[4] / 2 - r / 2,
                width = r,
                height = r
            }, BreitbandGraphics.colors.red, 1)
        end
    end
}
