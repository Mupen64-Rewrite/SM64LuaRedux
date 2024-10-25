local var_funcs = {
    ["yaw_facing"] = function()
        local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_facing_yaw) or Memory.current.mario_facing_yaw)
        local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_facing_yaw) + 32768) % 65536 or (Memory.current.mario_facing_yaw + 32768) % 65536)
        return string.format("Facing Yaw: %s (O: %s)", Formatter.angle(angle), Formatter.angle(opposite))
    end,
    ["yaw_intended"] = function()
        local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_intended_yaw) or Memory.current.mario_intended_yaw)
        local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_intended_yaw) + 32768) % 65536 or (Memory.current.mario_intended_yaw + 32768) % 65536)
        return string.format("Intended Yaw: %s (O: %s)", Formatter.angle(angle), Formatter.angle(opposite))
    end,
    ["h_spd"] = function()
        local h_speed = Memory.current.mario_h_speed
        local h_sliding_speed = Engine.GetHSlidingSpeed()
        return string.format("H Spd: %s (S: %s)", Formatter.ups(h_speed), Formatter.ups(h_sliding_speed))
    end,
    ["v_spd"] = function()
        local y_speed = Memory.current.mario_v_speed
        return string.format("Y Spd: %s", Formatter.ups(y_speed))
    end,
    ["spd_efficiency"] = function()
        return string.format("Spd Efficiency: %s", Formatter.percent(Engine.GetSpeedEfficiency()))
    end,
    ["position_x"] = function()
        return string.format("X: %s", Formatter.u(Memory.current.mario_x))
    end,
    ["position_y"] = function()
        return string.format("Y: %s", Formatter.u(Memory.current.mario_y))
    end,
    ["position_z"] = function()
        return string.format("Z: %s", Formatter.u(Memory.current.mario_z))
    end,
    ["pitch"] = function()
        return string.format("Pitch: %s", Formatter.angle(Memory.current.mario_pitch))
    end,
    ["yaw_vel"] = function()
        return string.format("Yaw Vel: %s", Formatter.angle(Memory.mario_yaw_vel))
    end,
    ["pitch_vel"] = function() 
        return string.format("Pitch Vel: %s", Formatter.angle(Memory.mario_pitch_vel))
    end,
    ["xz_movement"] = function()
        return string.format("XZ Movement: %s", Formatter.u(Engine.get_distance_moved()))
    end,
    ["action"] = function()
        local name = Actions.name_from_value(Memory.current.mario_action)
        return "Action: " .. (name or ("Unknown action " .. Memory.current.mario_action))
    end,
    ["rng"] = function()
        return "RNG: " .. Memory.current.rng_value .. " (index: " .. get_index(Memory.current.rng_value) .. ")"
    end,
    ["moved_dist"] = function()
        local dist = Settings.track_moved_distance and Engine.GetTotalDistMoved() or Settings.moved_distance
        return string.format("Moved Dist: %s", Formatter.u(dist))
    end,
    ["atan_basic"] = function()
        return string.format("E: %s R: %s D: %s N: %s", Settings.atan_exp,
            MoreMaths.round(Settings.atan_r, Settings.format_decimal_points),
            MoreMaths.round(Settings.atan_d, Settings.format_decimal_points),
            MoreMaths.round(Settings.atan_n, Settings.format_decimal_points)
        )
    end,
    ["atan_start_frame"] = function()
        return "S: " .. math.floor(Settings.atan_start + 1)
    end
}
VarWatch = {
    processed_values = {}
}

VarWatch_compute_value = function(key)
    return var_funcs[key]()
end

VarWatch_update = function()
    if paint_skipped then
        return
    end
    VarWatch.processed_values = {}
    for key, value in pairs(Settings.variables) do
        if value.visible then
            VarWatch.processed_values[#VarWatch.processed_values + 1] = var_funcs[value.identifier]()
        end
    end
end
