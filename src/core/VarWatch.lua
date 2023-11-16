VarWatch = {
    variables = {
        {
            identifier = "yaw_facing",
            value = function()
                local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_facing_yaw) or Memory.current.mario_facing_yaw)
                local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_facing_yaw) + 32768) % 65536 or (Memory.current.mario_facing_yaw + 32768) % 65536)
                return string.format("Facing Yaw: %s (O: %s)", Formatter.angle(angle), Formatter.angle(opposite))
            end
        },
        {
            identifier = "yaw_intended",
            value = function()
                local angle = (Settings.show_effective_angles and Engine.get_effective_angle(Memory.current.mario_intended_yaw) or Memory.current.mario_intended_yaw)
                local opposite = (Settings.show_effective_angles and (Engine.get_effective_angle(Memory.current.mario_intended_yaw) + 32768) % 65536 or (Memory.current.mario_intended_yaw + 32768) % 65536)
                return string.format("Intended Yaw: %s (O: %s)", Formatter.angle(angle), Formatter.angle(opposite))
            end
        },
        {
            identifier = "h_spd",
            value = function()
                local h_speed = MoreMaths.dec_to_float(Memory.current.mario_h_speed)
                local h_sliding_speed = Engine.GetHSlidingSpeed()
                return string.format("H Spd: %s (S: %s)", Formatter.ups(h_speed), Formatter.ups(h_sliding_speed))
            end
        },
        {
            identifier = "v_spd",
            value = function()
                local y_speed = MoreMaths.dec_to_float(Memory.current.mario_v_speed)
                return string.format("Y Spd: %s", Formatter.ups(y_speed))
            end
        },
        {
            identifier = "spd_efficiency",
            value = function()
                return string.format("Spd Efficiency: %s", Formatter.percent(Engine.GetSpeedEfficiency()))
            end
        },
        {
            identifier = "position_x",
            value = function()
                return string.format("X: %s", Formatter.u(MoreMaths.dec_to_float(Memory.current.mario_x)))
            end
        },
        {
            identifier = "position_y",
            value = function()
                return string.format("Y: %s", Formatter.u(MoreMaths.dec_to_float(Memory.current.mario_y)))
            end
        },
        {
            identifier = "position_z",
            value = function()
                return string.format("Z: %s", Formatter.u(MoreMaths.dec_to_float(Memory.current.mario_z)))
            end
        },
        {
            identifier = "xz_movement",
            value = function()
                return string.format("XZ Movement: %s", Formatter.u(Engine.GetDistMoved()))
            end
        },
        {
            identifier = "action",
            value = function()
                return "Action: " .. Engine.GetCurrentAction()
            end
        },
        {
            identifier = "rng",
            value = function()
                return "RNG: " .. Memory.current.rng_value .. " (index: " .. get_index(Memory.current.rng_value) .. ")"
            end
        },
        {
            identifier = "moved_dist",
            value = function()
                local dist = Settings.track_moved_distance and Engine.GetTotalDistMoved() or Settings.moved_distance
                return string.format("Moved Dist: %s", Formatter.u(dist))
            end
        },
        {
            identifier = "atan_basic",
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
            value = function()
                return "S: " .. (Settings.atan_start + 1)
            end
        },
    },
    active_variables = {},
    current_values = {}
}


local function where(table, cb)
    for _, value in pairs(table) do
        if cb(value) then
            return value
        end
    end
end

for _, value in pairs(VarWatch.variables) do
    VarWatch.active_variables[#VarWatch.active_variables + 1] = value.identifier
end

VarWatch.update = function()
    local items = {}

    for _, value in pairs(VarWatch.active_variables) do
        items[#items + 1] = where(VarWatch.variables, function(a)
            return a.identifier == value
        end).value()
    end

    VarWatch.current_values = items
end
