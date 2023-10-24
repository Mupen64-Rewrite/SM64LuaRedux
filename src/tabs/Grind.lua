return {
    name = "Grind",
    update = function()
        -- grinding:
        -- if airborne, try bidirectional inputs and find minimum for reaching diveslide action
        -- if divesliding, try bidirectional inputs and find minimum for reaching airborne action

        if Memory.current.mario_action == 0x0100088C then
            -- freefall


            return
        end

        if Memory.current.mario_action == 0x00880456 then
            -- diveslide
            return
        end
    end,
    draw = function()
        Settings.grind = Mupen_lua_ugui.toggle_button({
            uid = 0,
            is_enabled = true,
            rectangle = grid_rect(0, 0, 3, 1),
            text = memory.readdword(0x00B3B17C),
            is_checked = Settings.grind
        })
    end
}
