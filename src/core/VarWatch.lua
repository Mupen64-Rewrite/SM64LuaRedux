local function get_current_action()
    for i = 1, #Actions, 1 do
        local action = Actions[i]
        if action.value == Memory.current.mario_action then
            return action.name
        end
    end
    return "Unknown action " .. Memory.current.mario_action
end

VarWatch = {
    variables = {
        {
            identifier = "yaw_facing",
            visible = true,
            value = function()
                local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_facing_yaw) or Memory.current.mario_facing_yaw)
                local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_facing_yaw) + 32768) % 65536 or (Memory.current.mario_facing_yaw + 32768) % 65536)
                return string.format("Facing Yaw: %s (O: %s)", Formatter.angle(angle), Formatter.angle(opposite))
            end
        },
        {
            identifier = "yaw_intended",
            visible = true,
            value = function()
                local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_intended_yaw) or Memory.current.mario_intended_yaw)
                local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_intended_yaw) + 32768) % 65536 or (Memory.current.mario_intended_yaw + 32768) % 65536)
                return string.format("Intended Yaw: %s (O: %s)", Formatter.angle(angle), Formatter.angle(opposite))
            end
        },
        {
            identifier = "h_spd",
            visible = true,
            value = function()
                local h_speed = MoreMaths.dec_to_float(Memory.current.mario_h_speed)
                local h_sliding_speed = Engine.GetHSlidingSpeed()
                return string.format("H Spd: %s (S: %s)", Formatter.ups(h_speed), Formatter.ups(h_sliding_speed))
            end
        },
        {
            identifier = "v_spd",
            visible = true,
            value = function()
                local y_speed = MoreMaths.dec_to_float(Memory.current.mario_v_speed)
                return string.format("Y Spd: %s", Formatter.ups(y_speed))
            end
        },
        {
            identifier = "spd_efficiency",
            visible = true,
            value = function()
                return string.format("Spd Efficiency: %s", Formatter.percent(Engine.GetSpeedEfficiency()))
            end
        },
        {
            identifier = "position_x",
            visible = true,
            value = function()
                return string.format("X: %s", Formatter.u(MoreMaths.dec_to_float(Memory.current.mario_x)))
            end
        },
        {
            identifier = "position_y",
            visible = true,
            value = function()
                return string.format("Y: %s", Formatter.u(MoreMaths.dec_to_float(Memory.current.mario_y)))
            end
        },
        {
            identifier = "position_z",
            visible = true,
            value = function()
                return string.format("Z: %s", Formatter.u(MoreMaths.dec_to_float(Memory.current.mario_z)))
            end
        },
        {
            identifier = "xz_movement",
            visible = true,
            value = function()
                return string.format("XZ Movement: %s", Formatter.u(Engine.get_distance_moved()))
            end
        },
        {
            identifier = "action",
            visible = true,
            value = function()
                return "Action: " .. get_current_action()
            end
        },
        {
            identifier = "rng",
            visible = true,
            value = function()
                return "RNG: " .. Memory.current.rng_value .. " (index: " .. get_index(Memory.current.rng_value) .. ")"
            end
        },
        {
            identifier = "moved_dist",
            visible = true,
            value = function()
                local dist = Settings.track_moved_distance and Engine.GetTotalDistMoved() or Settings.moved_distance
                return string.format("Moved Dist: %s", Formatter.u(dist))
            end
        },
        {
            identifier = "atan_basic",
            visible = true,
            value = function()
                return string.format("E: %s R: %s D: %s N: %s", Settings.atan_exp,
                    MoreMaths.round(Settings.atan_r, Settings.format_decimal_points),
                    MoreMaths.round(Settings.atan_d, Settings.format_decimal_points),
                    MoreMaths.round(Settings.atan_n, Settings.format_decimal_points)
                )
            end
        },
        {
            identifier = "atan_start_frame",
            visible = true,
            value = function()
                return "S: " .. (Settings.atan_start + 1)
            end
        },
    },
    processed_values = {}
}

VarWatch.update = function()
    VarWatch.processed_values = {}
    for key, value in pairs(VarWatch.variables) do
        if value.visible then
            VarWatch.processed_values[#VarWatch.processed_values + 1] = value.value()
        end
    end
end
