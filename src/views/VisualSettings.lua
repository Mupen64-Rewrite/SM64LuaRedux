local items = {
    {
        text = "Style",
        func = function(rect)
            local new_active_style_index = ugui.combobox({
                uid = 1,
                rectangle = rect,
                items = lualinq.select_key(Presets.styles, "name"),
                selected_index = Settings.active_style_index,
            })

            if new_active_style_index ~= Settings.active_style_index then
                Settings.active_style_index = new_active_style_index
                Presets.set_style(Presets.styles[Settings.active_style_index].theme)
            end
        end
    },
    {
        text = "Angle formatting",
        func = function(rect)
            if ugui.button({
                    uid = 5,
                    rectangle = rect,
                    text = Settings.format_angles_degrees and "Degree" or "Short",
                }) then
                Settings.format_angles_degrees = not Settings.format_angles_degrees
            end
        end
    },
    {
        text = "Decimal points",
        func = function(rect)
            Settings.format_decimal_points = math.abs(ugui.numberbox({
                uid = 10,
                rectangle = rect,
                value = Settings.format_decimal_points,
                places = 1
            }))
        end
    },
    {
        text = "Fast-forward frame skip",
        tooltip = "Skips every nth frame when fast-forwarding to increase performance.",
        func = function(rect)
            Settings.repaint_throttle = math.max(1, math.abs(ugui.numberbox({
                uid = 15,
                rectangle = rect,
                value = Settings.repaint_throttle,
                places = 1
            })))
        end
    },
    {
        text = "Update every VI",
        tooltip = "Updates the UI every VI, improving mupen capture sync. Reduces performance.",
        func = function(rect)
            Settings.read_memory_every_vi = ugui.toggle_button({
                uid = 20,
                rectangle = rect,
                text = Settings.read_memory_every_vi and "On" or "Off",
                is_checked = Settings.read_memory_every_vi
            })
        end
    },
}

return {
    name = "Visuals",
    draw = function()
        local theme = Presets.styles[Settings.active_style_index].theme
        local foreground_color = BreitbandGraphics.invert_color(theme.background_color)

        local y = 0.1
        for i = 1, #items, 1 do
            local item = items[i]

            BreitbandGraphics.draw_text(
                grid_rect(0, y, 8, 0.5),
                "start",
                "center",
                { aliased = theme.pixelated_text },
                foreground_color,
                theme.font_size * Drawing.scale * 1.25,
                theme.font_name,
                item.text)

            item.func(grid_rect(0, y + 0.6, 4, 1))

            if item.tooltip and BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, grid_rect(0, y, 8, 0.5)) then
                ugui.menu({
                    uid = 999,
                    rectangle = {
                        x = ugui.internal.environment.mouse_position.x,
                        y = ugui.internal.environment.mouse_position.y,
                    },
                    items = {
                        {
                            text = item.tooltip,
                            callback = function() end
                        }
                    }
                })
            end

            y = y + 1.75
        end
    end
}
