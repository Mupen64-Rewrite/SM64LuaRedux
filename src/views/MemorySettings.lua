return {
    name = "Memory",
    draw = function()
        if Mupen_lua_ugui.button({
                uid = 600,
                rectangle = grid_rect(0, 0, 4, 1),
                text = "Select map file...",
                disabled = true
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
            rectangle = grid_rect(4, 0, 3, 1),
            items = lualinq.select_key(Addresses, "name"),
            selected_index = Settings.address_source_index,
        })
    end
}
