return {
    name = "Visuals",
    draw = function()
        local new_active_style_index = ugui.combobox({
            uid = 1,
            rectangle = grid_rect(0, 0, 4, 1),
            items = lualinq.select_key(Presets.styles, "name"),
            selected_index = Settings.active_style_index,
        })

        if new_active_style_index ~= Settings.active_style_index then
            Settings.active_style_index = new_active_style_index
            Presets.set_style(Presets.styles[Settings.active_style_index].theme)
        end

        if ugui.button({
                uid = 5,
                rectangle = grid_rect(4, 0, 1, 1),
                text = Settings.format_angles_degrees and "DEG" or "S16",
            }) then
            Settings.format_angles_degrees = not Settings.format_angles_degrees
        end

        Settings.format_decimal_points = math.abs(ugui.numberbox({
            uid = 10,
            rectangle = grid_rect(5, 0, 1, 1),
            value = Settings.format_decimal_points,
            places = 1
        }))

        Settings.repaint_throttle = math.max(1, math.abs(ugui.numberbox({
            uid = 15,
            rectangle = grid_rect(6, 0, 1, 1),
            value = Settings.repaint_throttle,
            places = 1
        })))

        Settings.read_memory_every_vi = ugui.toggle_button({
            uid = 20,
            rectangle = grid_rect(0, 1, 4, 1),
            text = "Update every VI",
            is_checked = Settings.read_memory_every_vi
        })
    end
}
