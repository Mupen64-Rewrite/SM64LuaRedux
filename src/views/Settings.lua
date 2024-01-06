local selected_var_index = 1

return {
    name = "Settings",
    draw = function()
        local new_active_style_index = Mupen_lua_ugui.combobox({
            uid = 1,
            rectangle = grid_rect(0, 0, 4, 1),
            items = lualinq.select_key(Settings.styles, "name"),
            selected_index = Settings.active_style_index,
        })

        if new_active_style_index ~= Settings.active_style_index then
            Settings.active_style_index = new_active_style_index
            Presets.set_style(Settings.styles[Settings.active_style_index].theme)
        end

        Settings.format_angles_degrees = Mupen_lua_ugui.toggle_button({
            uid = 300,
            rectangle = grid_rect(4, 0, 4, 1),
            text = "Degree formatting",
            is_checked = Settings.format_angles_degrees
        })

        Settings.format_decimal_points = Mupen_lua_ugui.spinner({
            uid = 350,
            rectangle = grid_rect(4, 1, 4, 1),
            value = Settings.format_decimal_points,
            minimum_value = 0,
            maximum_value = 8,
        })

        if Mupen_lua_ugui.button({
                uid = 20,
                is_enabled = selected_var_index > 1,
                rectangle = grid_rect(0, 9, 1, 1),
                text = "^"
            }) then
            swap(VarWatch.variables, selected_var_index, selected_var_index - 1)
            selected_var_index = selected_var_index - 1
        end

        if Mupen_lua_ugui.button({
                uid = 25,
                is_enabled = selected_var_index < #VarWatch.variables,
                rectangle = grid_rect(1, 9, 1, 1),
                text = "v"
            }) then
            swap(VarWatch.variables, selected_var_index, selected_var_index + 1)
            selected_var_index = selected_var_index + 1
        end

        VarWatch.variables[selected_var_index].visible = Mupen_lua_ugui.toggle_button({
            uid = 30,
            rectangle = grid_rect(2, 9, 2, 1),
            text = "Show",
            is_checked = VarWatch.variables[selected_var_index].visible
        })


        selected_var_index = Mupen_lua_ugui.listbox({
            uid = 13377331,
            rectangle = grid_rect(0, 2, 8, 7),
            selected_index = selected_var_index,
            items = lualinq.select(VarWatch.variables, function(x)
                if not x.visible then
                    return x.identifier .. " (disabled)"
                end
                return x.identifier
            end),
        })
    end
}
