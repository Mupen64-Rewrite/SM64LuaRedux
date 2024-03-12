local selected_var_index = 1

local views = {
    dofile(views_path .. "VisualSettings.lua"),
}

return {
    name = "Settings",
    draw = function()
        Settings.settings_tab_index = Mupen_lua_ugui.carrousel_button({
            uid = 100,
            rectangle = grid_rect(0, 14, 8, 1),
            items = lualinq.select_key(views, "name"),
            selected_index = Settings.settings_tab_index,
        })

        local new_active_style_index = Mupen_lua_ugui.combobox({
            uid = 1,
            rectangle = grid_rect(0, 0, 4, 1),
            items = lualinq.select_key(Presets.styles, "name"),
            selected_index = Settings.active_style_index,
        })

        if new_active_style_index ~= Settings.active_style_index then
            Settings.active_style_index = new_active_style_index
            Presets.set_style(Presets.styles[Settings.active_style_index].theme)
        end

        if Mupen_lua_ugui.button({
                uid = 300,
                rectangle = grid_rect(4, 0, 1, 1),
                text = Settings.format_angles_degrees and "DEG" or "S16",
            }) then
            Settings.format_angles_degrees = not Settings.format_angles_degrees
        end

        Settings.format_decimal_points = math.abs(Mupen_lua_ugui.numberbox({
            uid = 350,
            rectangle = grid_rect(5, 0, 1, 1),
            value = Settings.format_decimal_points,
            places = 1
        }))

        selected_var_index = Mupen_lua_ugui.listbox({
            uid = 400,
            rectangle = grid_rect(0, 1, 8, 6),
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
                rectangle = grid_rect(0, 7, 1, 1),
                text = "^"
            }) then
            swap(Settings.variables, selected_var_index, selected_var_index - 1)
            selected_var_index = selected_var_index - 1
        end

        if Mupen_lua_ugui.button({
                uid = 500,
                is_enabled = selected_var_index < #Settings.variables,
                rectangle = grid_rect(1, 7, 1, 1),
                text = "v"
            }) then
            swap(Settings.variables, selected_var_index, selected_var_index + 1)
            selected_var_index = selected_var_index + 1
        end

        Settings.variables[selected_var_index].visible = not Mupen_lua_ugui.toggle_button({
            uid = 550,
            rectangle = grid_rect(2, 7, 2, 1),
            text = "Hide",
            is_checked = not Settings.variables[selected_var_index].visible
        })

        if Mupen_lua_ugui.button({
                uid = 600,
                rectangle = grid_rect(0, 8, 3, 1),
                text = "Select map file..."
            }) then
            local path = iohelper.filediag("*.map", 0)
            if string.len(path) > 0 then
                local file = io.open(path, "r")
                local text = file:read("a")
                io.close(file)
                -- TODO: Implement
            end
        end

        Settings.address_source_index = Mupen_lua_ugui.combobox({
            uid = 650,
            rectangle = grid_rect(0, 9, 3, 1),
            items = lualinq.select_key(Addresses, "name"),
            selected_index = Settings.address_source_index,
        })

        Settings.repaint_throttle = math.max(1, math.abs(Mupen_lua_ugui.numberbox({
            uid = 700,
            rectangle = grid_rect(6, 0, 1, 1),
            value = Settings.repaint_throttle,
            places = 1
        })))
    end
}
