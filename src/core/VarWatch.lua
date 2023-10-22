VarWatch = {
    variables = {
        {
            identifier = "yaw_facing",
            value = function()
                local o = (Settings.show_effective_angles and (Engine.getEffectiveAngle(Memory.current.mario_facing_yaw) + 32768) % 65536 or (Memory.current.mario_facing_yaw + 32768) % 65536)
                return "Yaw (Facing): " ..
                    (Settings.show_effective_angles and Engine.getEffectiveAngle(Memory.current.mario_facing_yaw) or Memory.current.mario_facing_yaw) ..
                    " (O: " .. o .. ")"
            end
        },
        {
            identifier = "yaw_intended",
            value = function()
                local o = (Settings.show_effective_angles and (Engine.getEffectiveAngle(Memory.current.mario_intended_yaw) + 32768) % 65536 or (Memory.current.mario_intended_yaw + 32768) % 65536)
                return "Yaw (Intended): " ..
                    (Settings.show_effective_angles and Engine.getEffectiveAngle(Memory.current.mario_intended_yaw) or Memory.current.mario_intended_yaw) ..
                    " (O: " .. o .. ")"
            end
        },
        {
            identifier = "h_spd",
            value = function()
                local h_speed = 0
                if Memory.current.mario_h_speed ~= 0 then
                    h_speed = MoreMaths.DecodeDecToFloat(Memory.current.mario_h_speed)
                end
                return "H Spd: " ..
                    MoreMaths.Round(h_speed, 5) .. " (Sliding: " .. MoreMaths.Round(Engine.GetHSlidingSpeed(), 6) .. ")"
            end
        },
        {
            identifier = "v_spd",
            value = function()
                local y_speed = 0
                if Memory.current.mario_v_speed > 0 then
                    y_speed = MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.current.mario_v_speed), 6)
                end
                return "Y Spd: " .. MoreMaths.Round(y_speed, 6)
            end
        },
        {
            identifier = "spd_efficiency",
            value = function()
                return "Spd Efficiency: " .. Engine.GetSpeedEfficiency() .. "%"
            end
        },
        {
            identifier = "position_x",
            value = function()
                return "X: " ..
                    MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.current.mario_x), 2)
            end
        },
        {
            identifier = "position_y",
            value = function()
                return "Y: " ..
                    MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.current.mario_y), 2)
            end
        },
        {
            identifier = "position_z",
            value = function()
                return "Z: " ..
                    MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.current.mario_z), 2)
            end
        },
        {
            identifier = "xz_movement",
            value = function()
                return "XZ Movement: " .. MoreMaths.Round(Engine.GetDistMoved(), 6)
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
                local distmoved = Engine.GetTotalDistMoved()
                if (Settings.track_moved_distance == false) then
                    distmoved = Settings.moved_distance
                end
                return "Moved Dist: " .. distmoved
            end
        },
        {
            identifier = "atan_basic",
            value = function ()
                return 
                   "E: " .. Settings.atan_exp 
                .. " R: " .. MoreMaths.Round(Settings.atan_r, 5)
                .. " D: " .. MoreMaths.Round(Settings.atan_d, 5)
                .. " N: " .. MoreMaths.Round(Settings.atan_n, 2)
            end
        },
        {
            identifier = "atan_start_frame",
            value = function()
                return "S: " .. MoreMaths.Round(Settings.atan_start + 1, 2)
            end
        },
    },
    active_variables = {}
}


local function where(table, cb)
    for key, value in pairs(table) do
        if cb(value) then
            return value
        end
    end
end
for key, value in pairs(VarWatch.variables) do
    VarWatch.active_variables[#VarWatch.active_variables + 1] = value.identifier
end

VarWatch.get_values = function()
    local items = {}

    for _, value in pairs(VarWatch.active_variables) do
        items[#items + 1] = where(VarWatch.variables, function(a)
            return a.identifier == value
        end).value()
    end

    return items
end
