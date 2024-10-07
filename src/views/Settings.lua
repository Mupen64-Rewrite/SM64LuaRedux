local views = {
    dofile(views_path .. "VisualSettings.lua"),
    dofile(views_path .. "VarWatchSettings.lua"),
    dofile(views_path .. "MemorySettings.lua"),
}

return {
    name = "Settings",
    draw = function()
        local data = ugui.tabcontrol({
            uid = 100,
            rectangle = grid_rect(0, 0, 8, 15),
            items = lualinq.select_key(views, "name"),
            selected_index = Settings.settings_tab_index,
        })
        Settings.settings_tab_index = data.selected_index

        Drawing.push_offset(0, data.rectangle.y)
        views[Settings.settings_tab_index].draw()
        Drawing.pop_offset()
    end
}
