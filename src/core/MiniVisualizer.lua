MiniVisualizer = {}

MiniVisualizer.draw = function()
    if not Settings.mini_visualizer then
        return
    end
    BreitbandGraphics.fill_rectangle(grid_rect_abs(3, 14, 5, 2),
        Presets.styles[Settings.active_style_index].theme.background_color)
    ugui.joystick({
        uid = -100,
        rectangle = grid_rect_abs(0, 14, 3, 3),
        position = {
            x = Joypad.input.X,
            y = -Joypad.input.Y,
        },
        mag = 0
    })
    ugui.toggle_button({
        uid = -101,
        rectangle = grid_rect_abs(3, 16, 1, 1),
        text = "A",
        is_checked = Joypad.input.A
    })
    ugui.toggle_button({
        uid = -102,
        rectangle = grid_rect_abs(4, 16, 1, 1),
        text = "B",
        is_checked = Joypad.input.B
    })
    ugui.toggle_button({
        uid = -103,
        rectangle = grid_rect_abs(5, 16, 1, 1),
        text = "Z",
        is_checked = Joypad.input.Z
    })
    ugui.toggle_button({
        uid = -104,
        rectangle = grid_rect_abs(6, 16, 1, 1),
        text = "S",
        is_checked = Joypad.input.S
    })
    ugui.toggle_button({
        uid = -105,
        rectangle = grid_rect_abs(7, 16, 1, 1),
        text = "R",
        is_checked = Joypad.input.R
    })
    local foreground_color = BreitbandGraphics.invert_color(Presets.styles[Settings.active_style_index].theme
        .background_color)
    BreitbandGraphics.draw_text(
        grid_rect_abs(3, 15, 5, 1),
        "center",
        "center",
        { aliased = not Presets.styles[Settings.active_style_index].theme.cleartype },
        foreground_color,
        Presets.styles[Settings.active_style_index].theme.font_size * Drawing.scale,
        "Consolas",
        VarWatch_compute_value("action"))
    BreitbandGraphics.draw_text(
        grid_rect_abs(3, 14, 2.5, 1),
        "center",
        "center",
        { aliased = not Presets.styles[Settings.active_style_index].theme.cleartype },
        foreground_color,
        Presets.styles[Settings.active_style_index].theme.font_size * Drawing.scale * 1.25,
        "Consolas",
        "X: " .. Joypad.input.X)
    BreitbandGraphics.draw_text(
        grid_rect_abs(5.5, 14, 2.5, 1),
        "center",
        "center",
        { aliased = not Presets.styles[Settings.active_style_index].theme.cleartype },
        foreground_color,
        Presets.styles[Settings.active_style_index].theme.font_size * Drawing.scale * 1.25,
        "Consolas",
        "Y: " .. Joypad.input.Y)
end
