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
        Settings.goal_angle = Mupen_lua_ugui.numberbox({
            uid = 5065,
            is_enabled = Settings.movement_mode == Settings.movement_modes.match_angle,
            rectangle = grid_rect(4, 3, 4, 1),
            places = 5,
            value = Settings.goal_angle
        })
        Settings.goal_mag = Mupen_lua_ugui.numberbox({
            uid = 5066,
            is_enabled = true,
            rectangle = grid_rect(4, 5, 2, 1),
            places = 3,
            value = Settings.goal_mag
        })

        Settings.high_magnitude = Mupen_lua_ugui.toggle_button({
            uid = 5050,
            is_enabled = true,
            rectangle = grid_rect(6, 5, 1, 1),
            text = 'H',
            is_checked = Settings.high_magnitude
        })

        if Mupen_lua_ugui.button({
                uid = 5067,
                is_enabled = true,
                rectangle = grid_rect(7, 5, 1, 1),
                text = 'R',
            }) then
            Settings.goal_mag = 127
        end

        Settings.strain_speed_target = Mupen_lua_ugui.toggle_button({
            uid = 5068,
            is_enabled = true,
            rectangle = grid_rect(7, 0, 1, 1),
            text = '.99',
            is_checked = Settings.strain_speed_target
        })

        Settings.swim = Mupen_lua_ugui.toggle_button({
            uid = 999,
            is_enabled = true,
            rectangle = grid_rect(6, 1, 2, 1),
            text = 'Swim',
            is_checked = Settings.swim
        })
        Settings.dyaw = Mupen_lua_ugui.toggle_button({
            uid = 1000,
            is_enabled = Settings.movement_mode == Settings.movement_modes.match_angle,
            rectangle = grid_rect(4, 1, 2, 1),
            text = 'D-Yaw',
            is_checked = Settings.dyaw
        })
        Settings.strain_left = Mupen_lua_ugui.toggle_button({
            uid = 1001,
            is_enabled = true,
            rectangle = grid_rect(4, 0, 0.5, 1),
            text = '<',
            is_checked = Settings.strain_left
        })
        Settings.strain_always = Mupen_lua_ugui.toggle_button({
            uid = 1002,
            is_enabled = Settings.strain_speed_target,
            rectangle = grid_rect(4.5, 0, 2, 1),
            text = 'Always',
            is_checked = Settings.strain_always
        })
        Settings.strain_right = Mupen_lua_ugui.toggle_button({
            uid = 1003,
            is_enabled = true,
            rectangle = grid_rect(6.5, 0, 0.5, 1),
            text = '>',
            is_checked = Settings.strain_right
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
        if Settings.goal_mag and Settings.goal_mag < 127 then
            local r = Settings.goal_mag
            BreitbandGraphics.draw_ellipse({
                x = joystick_rect[1] + joystick_rect[3] / 2 - r / 2,
                y = joystick_rect[2] + joystick_rect[4] / 2 - r / 2,
                width = r,
                height = r
            }, BreitbandGraphics.colors.red, 1)
        end
    end
}
