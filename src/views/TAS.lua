return {
    name = "TAS",
    draw = function()
        Mupen_lua_ugui.listbox({
            uid = 0,
            rectangle = grid_rect(0, 8, 8, 6),
            selected_index = nil,
            items = VarWatch.processed_values,
        })
        Settings.goal_angle = math.abs(Mupen_lua_ugui.numberbox({
            uid = 5,
            is_enabled = Settings.movement_mode == Settings.movement_modes.match_angle,
            rectangle = grid_rect(4, 3, 4, 1),
            places = 5,
            value = Settings.goal_angle
        }))
        Settings.goal_mag = Mupen_lua_ugui.numberbox({
            uid = 10,

            rectangle = grid_rect(4, 4, 2, 1),
            places = 3,
            value = Settings.goal_mag
        })

        Settings.high_magnitude = Mupen_lua_ugui.toggle_button({
            uid = 15,

            rectangle = grid_rect(7, 4, 1, 1),
            text = 'H',
            is_checked = Settings.high_magnitude
        })

        if Mupen_lua_ugui.button({
                uid = 20,

                rectangle = grid_rect(6, 4, 1, 1),
                text = 'R',
            }) then
            Settings.goal_mag = 127
        end

        local foreground_color = BreitbandGraphics.invert_color(Presets.styles[Settings.active_style_index].theme.background_color)
        BreitbandGraphics.draw_text(
            grid_rect(4, 6, 2, 1), 
            "center", 
            "center", 
            {}, 
            foreground_color, 
            Presets.styles[Settings.active_style_index].theme.font_size * 1.25, 
            "Consolas",
            "X: " .. Joypad.input.X)
            BreitbandGraphics.draw_text(
            grid_rect(6, 6, 2, 1), 
            "center", 
            "center", 
            {}, 
            foreground_color, 
            Presets.styles[Settings.active_style_index].theme.font_size * 1.25, 
            "Consolas",
            "Y: " .. Joypad.input.Y)

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
            rectangle = grid_rect(6, 14, 2, 1),
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

        local atan_strain = Mupen_lua_ugui.toggle_button({
            uid = 75,
            rectangle = grid_rect(4, 2, 3, 1),
            text = 'Atan Strain',
            is_checked = Settings.atan_strain
        })

        if atan_strain and not Settings.atan_strain then
            -- FIXME: do we really need to update memory
            Memory.update()
            Settings.atan_start = Memory.current.mario_global_timer
        end
        Settings.atan_strain = atan_strain

        Settings.reverse_arc = Mupen_lua_ugui.toggle_button({
            uid = 80,
            rectangle = grid_rect(7, 2, 1, 1),
            text = 'I',
            is_checked = Settings.reverse_arc
        })

        if Mupen_lua_ugui.button({
                uid = 85,
                rectangle = grid_rect(4, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.atan_r = Settings.atan_r + math.pow(10, Settings.atan_exp)
        end
        if Mupen_lua_ugui.button({
                uid = 90,
                rectangle = grid_rect(4, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.atan_r = Settings.atan_r - math.pow(10, Settings.atan_exp)
        end


        if Mupen_lua_ugui.button({
                uid = 95,
                rectangle = grid_rect(4.5, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.atan_d = Settings.atan_d + math.pow(10, Settings.atan_exp)
        end
        if Mupen_lua_ugui.button({
                uid = 100,
                rectangle = grid_rect(4.5, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.atan_d = Settings.atan_d - math.pow(10, Settings.atan_exp)
        end

        if Mupen_lua_ugui.button({
                uid = 105,
                rectangle = grid_rect(5, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.atan_n = math.max(0,
                Settings.atan_n + math.pow(10, math.max(-0.6020599913279624, Settings.atan_exp)), 2)
        end
        if Mupen_lua_ugui.button({
                uid = 110,
                rectangle = grid_rect(5, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.atan_n = math.max(0,
                Settings.atan_n - math.pow(10, math.max(-0.6020599913279624, Settings.atan_exp)), 2)
        end

        if Mupen_lua_ugui.button({
                uid = 115,
                rectangle = grid_rect(5.5, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.atan_start = math.max(0, Settings.atan_start + math.pow(10, math.max(0, Settings.atan_exp)))
        end
        if Mupen_lua_ugui.button({
                uid = 120,
                rectangle = grid_rect(5.5, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.atan_start = math.max(0, Settings.atan_start - math.pow(10, math.max(0, Settings.atan_exp)))
        end

        if Mupen_lua_ugui.button({
                uid = 125,
                rectangle = grid_rect(5.5, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.atan_start = math.max(0, Settings.atan_start + math.pow(10, math.max(0, Settings.atan_exp)))
        end
        if Mupen_lua_ugui.button({
                uid = 130,
                rectangle = grid_rect(5.5, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.atan_start = math.max(0, Settings.atan_start - math.pow(10, math.max(0, Settings.atan_exp)))
        end

        if Mupen_lua_ugui.button({
                uid = 135,
                rectangle = grid_rect(6, 7, 0.5, 0.5),
                text = '+',
            }) then
            Settings.atan_exp = math.max(-4, math.min(Settings.atan_exp + 1, 4))
        end
        if Mupen_lua_ugui.button({
                uid = 140,
                rectangle = grid_rect(6, 7.5, 0.5, 0.5),
                text = '-',
            }) then
            Settings.atan_exp = math.max(-4, math.min(Settings.atan_exp - 1, 4))
        end

        if Mupen_lua_ugui.toggle_button({
                uid = 145,
                rectangle = grid_rect(0, 0, 4, 1),
                text = 'Disabled',
                is_checked = Settings.movement_mode == Settings.movement_modes.disabled
            }) ~= (Settings.movement_mode == Settings.movement_modes.disabled) then
            Settings.movement_mode = Settings.movement_modes.disabled
        end
        if Mupen_lua_ugui.toggle_button({
                uid = 150,
                rectangle = grid_rect(0, 1, 4, 1),
                text = 'Match Yaw',
                is_checked = Settings.movement_mode == Settings.movement_modes.match_yaw
            }) ~= (Settings.movement_mode == Settings.movement_modes.match_yaw) then
            Settings.movement_mode = Settings.movement_modes.match_yaw
        end
        if Mupen_lua_ugui.toggle_button({
                uid = 155,
                rectangle = grid_rect(0, 2, 4, 1),
                text = 'Reverse Angle',
                is_checked = Settings.movement_mode == Settings.movement_modes.reverse_angle
            }) ~= (Settings.movement_mode == Settings.movement_modes.reverse_angle) then
            Settings.movement_mode = Settings.movement_modes.reverse_angle
        end
        if Mupen_lua_ugui.toggle_button({
                uid = 160,
                rectangle = grid_rect(0, 3, 4, 1),
                text = 'Match Angle',
                is_checked = Settings.movement_mode == Settings.movement_modes.match_angle
            }) ~= (Settings.movement_mode == Settings.movement_modes.match_angle) then
            Settings.movement_mode = Settings.movement_modes.match_angle
        end
    end
}
