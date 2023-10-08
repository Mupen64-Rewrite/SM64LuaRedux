RngPage = {
    enabled = false,
    use_value = true,
    rng = "0"
}


RngPage.draw = function()
    RngPage.enabled = Mupen_lua_ugui.toggle_button({
        uid = 1,
        is_enabled = true,
        rectangle = grid_rect(0, 0, 2, 1),
        text = "Lock to",
        is_checked = RngPage.enabled,
    })
    RngPage.use_value = Mupen_lua_ugui.toggle_button({
        uid = 2,
        is_enabled = RngPage.enabled,
        rectangle = grid_rect(0, 1, 2, 1),
        text = "Value",
        is_checked = RngPage.use_value,
    })
    RngPage.use_value = not Mupen_lua_ugui.toggle_button({
        uid = 3,
        is_enabled = RngPage.enabled,
        rectangle = grid_rect(2, 1, 2, 1),
        text = "Index",
        is_checked = not RngPage.use_value,
    })
    RngPage.rng = Mupen_lua_ugui.textbox({
        uid = 300,
        is_enabled = RngPage.enabled,
        rectangle = grid_rect(2, 0, 4, 1),
        text = RngPage.rng
    })
end


RngPage.update = function()
    Settings.Layout.Button.SET_RNG = RngPage.enabled
end
