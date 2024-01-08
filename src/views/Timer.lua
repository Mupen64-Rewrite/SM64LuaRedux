return {
    name = "Timer",
    draw = function()
        if Mupen_lua_ugui.button({
                uid = 10,

                rectangle = grid_rect(0, 0, 2, 1),
                text = "Start"
            }) then
            Timer.start()
        end
        if Mupen_lua_ugui.button({
                uid = 15,

                rectangle = grid_rect(2, 0, 2, 1),
                text = "Stop"
            }) then
            Timer.stop()
        end
        if Mupen_lua_ugui.button({
                uid = 20,

                rectangle = grid_rect(4, 0, 2, 1),
                text = "Reset"
            }) then
            Timer.reset()
        end
        is_control_automatic = Mupen_lua_ugui.toggle_button({
            uid = 25,
            rectangle = grid_rect(6, 0, 2, 1),
            text = is_control_automatic and "Auto" or "Manual",
            is_checked = is_control_automatic
        })
        Mupen_lua_ugui.joystick({
            uid = 30,

            rectangle = grid_rect(2, 1, 4, 4),
            position = {
                x = Mupen_lua_ugui.internal.remap(Joypad.input.X, -128, 128, 0, 1),
                y = Mupen_lua_ugui.internal.remap(-Joypad.input.Y, -128, 128, 0, 1),
            }
        })

        BreitbandGraphics.draw_text(grid_rect(2, 5, 4, 1), "center", "center",
            { aliased = Presets.styles[Settings.active_style_index].theme.pixelated_text },
            BreitbandGraphics.invert_color(Presets.styles[Settings.active_style_index].theme.background_color),
            Presets.styles[Settings.active_style_index].theme.font_size * Drawing.scale * 2,
            "Consolas",
            Timer.get_frame_text())

        Mupen_lua_ugui.toggle_button({
            uid = 35,

            rectangle = grid_rect(4, 6, 2),
            text = "A",
            is_checked = Joypad.input.A
        })

        Mupen_lua_ugui.toggle_button({
            uid = 40,

            rectangle = grid_rect(2, 6, 2),
            text = "B",
            is_checked = Joypad.input.B
        })

        Mupen_lua_ugui.toggle_button({
            uid = 45,

            rectangle = grid_rect(3, 8, 1),
            text = "Z",
            is_checked = Joypad.input.Z
        })

        Mupen_lua_ugui.toggle_button({
            uid = 50,

            rectangle = grid_rect(4, 8, 1),
            text = "S",
            is_checked = Joypad.input.start
        })

        Mupen_lua_ugui.toggle_button({
            uid = 55,

            rectangle = grid_rect(1, 7),
            text = "L",
            is_checked = Joypad.input.L
        })

        Mupen_lua_ugui.toggle_button({
            uid = 60,

            rectangle = grid_rect(6, 7),
            text = "R",
            is_checked = Joypad.input.R
        })

        Mupen_lua_ugui.toggle_button({
            uid = 65,

            rectangle = grid_rect(0, 7),
            text = "C<",
            is_checked = Joypad.input.Cleft
        })

        Mupen_lua_ugui.toggle_button({
            uid = 70,

            rectangle = grid_rect(2, 7),
            text = "C>",
            is_checked = Joypad.input.Cright
        })

        Mupen_lua_ugui.toggle_button({
            uid = 75,

            rectangle = grid_rect(1, 6),
            text = "C^",
            is_checked = Joypad.input.Cup
        })

        Mupen_lua_ugui.toggle_button({
            uid = 80,

            rectangle = grid_rect(1, 8),
            text = "Cv",
            is_checked = Joypad.input.Cdown
        })

        Mupen_lua_ugui.toggle_button({
            uid = 85,

            rectangle = grid_rect(5, 7),
            text = "D<",
            is_checked = Joypad.input.left
        })

        Mupen_lua_ugui.toggle_button({
            uid = 90,

            rectangle = grid_rect(7, 7),
            text = "D>",
            is_checked = Joypad.input.right
        })

        Mupen_lua_ugui.toggle_button({
            uid = 95,

            rectangle = grid_rect(6, 6),
            text = "D^",
            is_checked = Joypad.input.up
        })

        Mupen_lua_ugui.toggle_button({
            uid = 100,

            rectangle = grid_rect(6, 8),
            text = "Dv",
            is_checked = Joypad.input.down
        })

        Mupen_lua_ugui.listbox({
            uid = 105,
            rectangle = grid_rect(0, 9, 8, 6),
            selected_index = nil,
            items = VarWatch.processed_values,
        })
    end
}
