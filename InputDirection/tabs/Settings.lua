local selected_var_index = 1

return {
    update = function()

    end,

    draw = function()
        Settings.active_style_index = Mupen_lua_ugui.combobox({
            uid = 1,
            is_enabled = true,
            rectangle = grid_rect(0, 0, 4, 1),
            items = {
                "Windows 10",
                "Windows 11",
                "Windows 10 Dark",
                "Windows 7",
                "Windows 3 Pink",
            },
            selected_index = Settings.active_style_index,
        })
        Mupen_lua_ugui_ext.apply_nineslice(Settings.styles[Settings.active_style_index])
        Settings.GridSize = Mupen_lua_ugui.spinner({
            uid = 100,
            is_enabled = true,
            rectangle = grid_rect(0, 1, 4, 1),
            value = Settings.GridSize,
            is_horizontal = false,
            minimum_value = -128,
            maximum_value = 128,
        })
        Settings.GridGap = Mupen_lua_ugui.spinner({
            uid = 200,
            is_enabled = true,
            rectangle = grid_rect(4, 1, 4, 1),
            value = Settings.GridGap,
            is_horizontal = false,
            minimum_value = 0,
            maximum_value = 20,
        })

        if Mupen_lua_ugui.button({
                uid = 20,
                is_enabled = selected_var_index > 1,
                rectangle = grid_rect(0, 9, 1, 1),
                text = "^"
            }) then
            local tmp = VarWatch.active_variables[selected_var_index - 1]
            VarWatch.active_variables[selected_var_index - 1] = VarWatch.active_variables[selected_var_index]
            VarWatch.active_variables[selected_var_index] = tmp
            selected_var_index = selected_var_index - 1
        end

        if Mupen_lua_ugui.button({
                uid = 20,
                is_enabled = selected_var_index < #VarWatch.active_variables,
                rectangle = grid_rect(1, 9, 1, 1),
                text = "v"
            }) then
            local tmp = VarWatch.active_variables[selected_var_index + 1]
            VarWatch.active_variables[selected_var_index + 1] = VarWatch.active_variables[selected_var_index]
            VarWatch.active_variables[selected_var_index] = tmp
            selected_var_index = selected_var_index + 1
        end

        selected_var_index = Mupen_lua_ugui.listbox({
            uid = 13377331,
            is_enabled = true,
            rectangle = grid_rect(0, 2, 8, 7),
            selected_index = selected_var_index,
            items = VarWatch.active_variables,
        })
    end
}
