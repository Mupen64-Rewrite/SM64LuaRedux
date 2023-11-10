return {
    name = "TAS",
    update = function()

    end,
    draw = function()
        Drawing.paint()
        Mupen_lua_ugui.listbox({
            uid = 0,
            
            rectangle = grid_rect(0, 8, 8, 6),
            selected_index = nil,
            items = VarWatch.current_values,
        })
        Settings.goal_angle = Mupen_lua_ugui.numberbox({
            uid = 5,
            is_enabled = Settings.movement_mode == Settings.movement_modes.match_angle,
            rectangle = grid_rect(4, 3, 4, 1),
            places = 5,
            value = Settings.goal_angle
        })
        Settings.goal_mag = Mupen_lua_ugui.numberbox({
            uid = 10,
            
            rectangle = grid_rect(4, 4, 4, 1),
            places = 3,
            value = Settings.goal_mag
        })

        Settings.high_magnitude = Mupen_lua_ugui.toggle_button({
            uid = 15,
            
            rectangle = grid_rect(4, 6, 2, 1),
            text = 'Hi-Mag',
            is_checked = Settings.high_magnitude
        })

        if Mupen_lua_ugui.button({
                uid = 20,
                
                rectangle = grid_rect(6, 6, 2, 1),
                text = 'Reset',
            }) then
            Settings.goal_mag = 127
        end

        if Mupen_lua_ugui.button({
                uid = 25,
                
                rectangle = grid_rect(4, 5, 2, 1),
                text = 'Spdkick',
            }) then
            Settings.goal_mag = 48
            Settings.high_magnitude = true
        end

        Settings.framewalk = Mupen_lua_ugui.toggle_button({
            uid = 30,
            
            rectangle = grid_rect(6, 5, 2, 1),
            text = 'Framewalk',
            is_checked = Settings.framewalk
        })

        Settings.strain_always = Mupen_lua_ugui.toggle_button({
            uid = 35,
            is_enabled = Settings.strain_speed_target,
            rectangle = grid_rect(4, 0, 3, 1),
            text = 'Always',
            is_checked = Settings.strain_always
        })
        Settings.strain_speed_target = Mupen_lua_ugui.toggle_button({
            uid = 40,
            
            rectangle = grid_rect(7, 0, 1, 1),
            text = '.99',
            is_checked = Settings.strain_speed_target
        })

        Settings.swim = Mupen_lua_ugui.toggle_button({
            uid = 45,
            rectangle = grid_rect(6.5, 7, 1.5, 1),
            text = 'Swim',
            is_checked = Settings.swim
        })
        Settings.dyaw = Mupen_lua_ugui.toggle_button({
            uid = 50,
            is_enabled = Settings.movement_mode == Settings.movement_modes.match_angle,
            rectangle = grid_rect(4, 1, 2, 1),
            text = 'D-Yaw',
            is_checked = Settings.dyaw
        })
        Settings.strain_left = Mupen_lua_ugui.toggle_button({
            uid = 55,
            
            rectangle = grid_rect(6, 1, 1, 1),
            text = '<',
            is_checked = Settings.strain_left
        })

        Settings.strain_right = Mupen_lua_ugui.toggle_button({
            uid = 60,
            
            rectangle = grid_rect(7, 1, 1, 1),
            text = '>',
            is_checked = Settings.strain_right
        })

        local previous_track_moved_distance = Settings.track_moved_distance
        Settings.track_moved_distance = Mupen_lua_ugui.toggle_button({
            uid = 65,
            
            rectangle = grid_rect(0, 14, 4, 1),
            text = 'Moved Distance',
            is_checked = Settings.track_moved_distance
        })

        if Settings.track_moved_distance and not previous_track_moved_distance then
            Settings.moved_distance_axis.x = MoreMaths.dec_to_float(Memory.current.mario_x)
            Settings.moved_distance_axis.y = MoreMaths.dec_to_float(Memory.current.mario_y)
            Settings.moved_distance_axis.z = MoreMaths.dec_to_float(Memory.current.mario_z)
        end
        if not Settings.track_moved_distance and previous_track_moved_distance then
            Settings.moved_distance = Engine.GetTotalDistMoved()
        end

        Settings.moved_distance_ignore_y = Mupen_lua_ugui.toggle_button({
            uid = 70,
            
            rectangle = grid_rect(4, 14, 2, 1),
            text = 'Ignore Y',
            is_checked = Settings.moved_distance_ignore_y
        })

        local joystick_rect = grid(0, 4, 4, 4)
        Mupen_lua_ugui.joystick({
            uid = 70,
            
            rectangle = {
                x = joystick_rect[1],
                y = joystick_rect[2],
                width = joystick_rect[3],
                height = joystick_rect[4]
            },
            position = {
                x = Mupen_lua_ugui.internal.remap(Joypad.input.X, -128, 128, 0, 1),
                y = Mupen_lua_ugui.internal.remap(-Joypad.input.Y, -128, 128, 0, 1),
            }
        })
        if Settings.goal_mag and Settings.goal_mag < 127 then
            local r = Settings.goal_mag * Drawing.scale
            BreitbandGraphics.draw_ellipse({
                x = joystick_rect[1] + joystick_rect[3] / 2 - r / 2,
                y = joystick_rect[2] + joystick_rect[4] / 2 - r / 2,
                width = r,
                height = r
            }, BreitbandGraphics.colors.red, 1)
        end
    end
}
