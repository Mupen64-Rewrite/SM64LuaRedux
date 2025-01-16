local ctrl = false
local shift = false
local alt = false
local key = nil

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
        elseif key == "enter" then
            key = "Enter"
        else
            key = string.upper(key)
        end

        str = str .. key .. " "
    end
    for key, value in pairs(hotkey.keys) do
    end

    return str
end

local function get_current_keys()
    local keys = {}

    if ctrl then
        keys[#keys + 1] = "control"
    end

    if shift then
        keys[#keys + 1] = "shift"
    end

    if alt then
        keys[#keys + 1] = "alt"
    end

    if key then
        keys[#keys + 1] = key
    end

    return keys
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

        Settings.hotkeys_selected_index = ugui.listbox({
            uid = 400,
            rectangle = grid_rect(0, 0, 8, 8),
            selected_index = Settings.hotkeys_selected_index,
            items = lualinq.select(Settings.hotkeys, function(x)
                return x.identifier .. " - " .. hotkey_to_string(x)
            end),
        })

        BreitbandGraphics.draw_text = prev_draw_text

        if ugui.button({
                uid = 405,
                rectangle = grid_rect(0, 8, 2, 1),
                is_enabled = not Settings.hotkeys_assigning,
                text = "Clear",
            }) then
            Settings.hotkeys[Settings.hotkeys_selected_index].keys = {}
        end

        if ugui.button({
                uid = 410,
                rectangle = grid_rect(2, 8, 2, 1),
                is_enabled = not Settings.hotkeys_assigning,
                text = "Reset",
            }) then
            Settings.hotkeys[Settings.hotkeys_selected_index].keys = Presets.get_default_preset().hotkeys
                [Settings.hotkeys_selected_index].keys
        end

        if ugui.button({
                uid = 415,
                rectangle = grid_rect(4, 8, 4, 1),
                text = Settings.hotkeys_assigning and hotkey_to_string({ keys = get_current_keys() }) or "Assign",
            }) then
            ctrl = false
            shift = false
            alt = false
            key = nil
            Settings.hotkeys_assigning = true
        end

        Settings.hotkeys_enabled = not Settings.hotkeys_assigning

        -- FIXME: Early return
        if Settings.hotkeys_assigning then
            if ugui.internal.environment.held_keys["control"] then
                ctrl = true
            end
            if ugui.internal.environment.held_keys["shift"] then
                shift = true
            end
            if ugui.internal.environment.held_keys["alt"] then
                alt = true
            end

            local CONFIRM_KEY = "enter"
            for vkey, _ in pairs(ugui.internal.environment.held_keys) do
                if vkey ~= "control" and vkey ~= "shift" and vkey ~= "alt" and vkey ~= "xmouse" and vkey ~= "ymouse" and vkey ~= "ywmouse" and vkey ~= "leftclick" and vkey ~= "rightclick" and vkey ~= CONFIRM_KEY then
                    key = vkey
                end

                if vkey == CONFIRM_KEY then
                    Settings.hotkeys[Settings.hotkeys_selected_index].keys = get_current_keys()
                    Settings.hotkeys_selected_index = math.min(Settings.hotkeys_selected_index + 1, #Settings.hotkeys)
                    Settings.hotkeys_assigning = false
                end
            end

            local theme = Styles.theme()
            local foreground_color = BreitbandGraphics.invert_color(theme.background_color)

            BreitbandGraphics.draw_text(
                grid_rect(0, 9, 8, 0.5),
                "start",
                "center",
                { aliased = not theme.cleartype },
                foreground_color,
                theme.font_size * Drawing.scale,
                theme.font_name,
                "Press Enter to confirm")
        end
    end
}
