local selected_hotkey_index = 1

local function hotkey_to_string(hotkey)
    if not hotkey.keys or #hotkey.keys == 0 then
        return "(nothing)"
    end

    local str = ""

    for i = 1, #hotkey.keys, 1 do
        local key = ugui.internal.deep_clone(hotkey.keys[i])

        if key == "control" then
            key = "Ctrl"
        elseif key == "shift" then
            key = "Shift"
        elseif key == "alt" then
            key = "Alt"
        elseif key == "space" then
            key = "Space"
        elseif key == "comma" then
            key = ","
        elseif key == "period" then
            key = "."
        elseif key == "leftbracket" then
            key = "["
        elseif key == "rightbracket" then
            key = "]"
        else
            key = string.upper(key)
        end
        
        str = str .. key .. " "
    end
    for key, value in pairs(hotkey.keys) do
    end

    return str
end

return {
    name = "Hotkeys",
    draw = function()
        local prev_draw_text = BreitbandGraphics.draw_text

        BreitbandGraphics.draw_text = function(rectangle, horizontal_alignment, vertical_alignment, style, color,
                                               font_size, font_name, text)
            style.fit = true
            prev_draw_text(rectangle, horizontal_alignment, vertical_alignment, style, color, font_size, font_name, text)
        end

        selected_hotkey_index = ugui.listbox({
            uid = 400,
            rectangle = grid_rect(0, 0, 8, 8),
            selected_index = selected_hotkey_index,
            items = lualinq.select(Settings.hotkeys, function(x)
                return x.identifier .. " - " .. hotkey_to_string(x)
            end),
        })

        BreitbandGraphics.draw_text = prev_draw_text

        if ugui.button({
            uid = 405,
            rectangle = grid_rect(0, 8, 2, 1),
            text = "Clear",
        }) then
            Settings.hotkeys[selected_hotkey_index].keys = {}
        end

        if ugui.button({
            uid = 410,
            rectangle = grid_rect(2, 8, 2, 1),
            text = "Reset",
        }) then
            Settings.hotkeys[selected_hotkey_index].keys = Presets.get_default_preset().hotkeys[selected_hotkey_index].keys
        end
    end
}
