return {
    name = "Memory",
    draw = function()
        if Mupen_lua_ugui.button({
                uid = 600,
                rectangle = grid_rect(0, 0, 4, 1),
                text = "Select map file...",
                is_enabled = false
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
            rectangle = grid_rect(4, 0, 4, 1),
            items = lualinq.select_key(Addresses, "name"),
            selected_index = Settings.address_source_index,
        })

        if Mupen_lua_ugui.button({
                uid = 700,
                rectangle = grid_rect(0, 1, 4, 1),
                text = "Autodetect",
            }) then
            Settings.address_source_index = Memory.find_matching_address_source_index()
        end

        Settings.autodetect_address = Mupen_lua_ugui.toggle_button({
            uid = 750,
            rectangle = grid_rect(4, 1, 4, 1),
            text = "Always",
            is_checked = Settings.autodetect_address
        })
    end
}
