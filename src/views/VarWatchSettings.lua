local selected_var_index = 1

return {
    name = "VarWatch",
    draw = function()
        selected_var_index = Mupen_lua_ugui.listbox({
            uid = 400,
            rectangle = grid_rect(0, 0, 8, 13),
            selected_index = selected_var_index,
            items = lualinq.select(Settings.variables, function(x)
                if not x.visible then
                    return x.identifier .. " (disabled)"
                end
                return x.identifier
            end),
        })

        if Mupen_lua_ugui.button({
                uid = 450,
                is_enabled = selected_var_index > 1,
                rectangle = grid_rect(0, 13, 1, 1),
                text = "^"
            }) then
            swap(Settings.variables, selected_var_index, selected_var_index - 1)
            selected_var_index = selected_var_index - 1
        end

        if Mupen_lua_ugui.button({
                uid = 500,
                is_enabled = selected_var_index < #Settings.variables,
                rectangle = grid_rect(1, 13, 1, 1),
                text = "v"
            }) then
            swap(Settings.variables, selected_var_index, selected_var_index + 1)
            selected_var_index = selected_var_index + 1
        end

        Settings.variables[selected_var_index].visible = not Mupen_lua_ugui.toggle_button({
            uid = 550,
            rectangle = grid_rect(2, 13, 2, 1),
            text = "Hide",
            is_checked = not Settings.variables[selected_var_index].visible
        })
    end
}
