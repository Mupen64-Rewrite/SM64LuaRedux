local hotkey_funcs = {
    movement_mode_disabled = function()
        Settings.movement_mode = Settings.movement_modes.disabled
    end,
    movement_mode_match_yaw = function()
        Settings.movement_mode = Settings.movement_modes.match_yaw
    end,
    movement_mode_reverse_angle = function()
        Settings.movement_mode = Settings.movement_modes.reverse_angle
    end,
    movement_mode_match_angle = function()
        Settings.movement_mode = Settings.movement_modes.match_angle
    end,
    preset_down = function()
        Presets.apply(Presets.persistent.current_index - 1)
    end,
    preset_up = function()
        Presets.apply(Presets.persistent.current_index + 1)
    end,
}

return {
    on_key_down = function(keys)

        for _, hotkey in pairs(Settings.hotkeys) do
            local activated = true
            for _, key in pairs(hotkey.keys) do
                if not keys[key] then
                    activated = false
                end
            end
            if activated then
                hotkey_funcs[hotkey.identifier]()
                print("Hotkey " .. hotkey.identifier .. " pressed")
                return
            end
        end
    end,
}
