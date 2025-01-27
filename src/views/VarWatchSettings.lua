local items = {
    {
        text = "Angle formatting",
        func = function(rect)
            if ugui.button({
                    uid = 10,
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
                uid = 15,
                rectangle = rect,
                value = Settings.format_decimal_points,
                places = 1
            }))
        end
    },
    {
        text = "Spd Efficiency Visualization",
        func = function(rect)
            if ugui.button({
                    uid = 30,
                    rectangle = rect,
                    text = Settings.spd_efficiency_fraction and "Fraction" or "Percentage",
                }) then
                Settings.spd_efficiency_fraction = not Settings.spd_efficiency_fraction
            end
        end
    },
}
local selected_var_index = 1

return {
    name = "Varwatch",
    draw = function()
        selected_var_index = ugui.listbox({
            uid = 400,
            rectangle = grid_rect(0, 0, 8, 8),
            selected_index = selected_var_index,
            items = lualinq.select(Settings.variables, function(x)
                if not x.visible then
                    return x.identifier .. " (disabled)"
                end
                return x.identifier
            end),
        })

        if ugui.button({
                uid = 450,
                is_enabled = selected_var_index > 1,
                rectangle = grid_rect(0, 8, 1, 1),
                text = '[icon:arrow_up]'
            }) then
            swap(Settings.variables, selected_var_index, selected_var_index - 1)
            selected_var_index = selected_var_index - 1
        end

        if ugui.button({
                uid = 500,
                is_enabled = selected_var_index < #Settings.variables,
                rectangle = grid_rect(1, 8, 1, 1),
                text = '[icon:arrow_down]'
            }) then
            swap(Settings.variables, selected_var_index, selected_var_index + 1)
            selected_var_index = selected_var_index + 1
        end

        Settings.variables[selected_var_index].visible = not ugui.toggle_button({
            uid = 550,
            rectangle = grid_rect(2, 8, 2, 1),
            text = "Hide",
            is_checked = not Settings.variables[selected_var_index].visible
        })

        Drawing.setting_list(items, { x = 0, y = 9 })
    end
}
