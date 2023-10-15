return {
    update = function ()
        
    end,
    draw = function()
        Drawing.paint()
        Mupen_lua_ugui.listbox({
            uid = 13377331,
            is_enabled = true,
            rectangle = grid_rect(0, 8, 8, 7),
            selected_index = nil,
            items = VarWatch.get_values(),
        })
        Input.update()
    end
}
