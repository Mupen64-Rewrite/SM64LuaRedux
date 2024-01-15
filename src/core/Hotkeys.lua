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
    copy_yaw_facing_to_match_angle = function()
        Settings.goal_angle = Memory.current.mario_facing_yaw
    end,
    copy_yaw_intended_to_match_angle = function()
        Settings.goal_angle = Memory.current.mario_intended_yaw
    end,
}

return {
    on_key_down = function(keys)
        if not emu.ismainwindowinforeground() then
            return
        end
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
