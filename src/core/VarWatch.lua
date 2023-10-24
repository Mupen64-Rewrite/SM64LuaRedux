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
                    h_speed = MoreMaths.dec_to_float(Memory.current.mario_h_speed)
                end
                return "H Spd: " ..
                    MoreMaths.round(h_speed, 5) .. " (Sliding: " .. MoreMaths.round(Engine.GetHSlidingSpeed(), 6) .. ")"
            end
        },
        {
            identifier = "v_spd",
            value = function()
                local y_speed = 0
                if Memory.current.mario_v_speed > 0 then
                    y_speed = MoreMaths.round(MoreMaths.dec_to_float(Memory.current.mario_v_speed), 6)
                end
                return "Y Spd: " .. MoreMaths.round(y_speed, 6)
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
                    MoreMaths.round(MoreMaths.dec_to_float(Memory.current.mario_x), 2)
            end
        },
        {
            identifier = "position_y",
            value = function()
                return "Y: " ..
                    MoreMaths.round(MoreMaths.dec_to_float(Memory.current.mario_y), 2)
            end
        },
        {
            identifier = "position_z",
            value = function()
                return "Z: " ..
                    MoreMaths.round(MoreMaths.dec_to_float(Memory.current.mario_z), 2)
            end
        },
        {
            identifier = "xz_movement",
            value = function()
                return "XZ Movement: " .. MoreMaths.round(Engine.GetDistMoved(), 6)
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
                .. " R: " .. MoreMaths.round(Settings.atan_r, 5)
                .. " D: " .. MoreMaths.round(Settings.atan_d, 5)
                .. " N: " .. MoreMaths.round(Settings.atan_n, 2)
            end
        },
        {
            identifier = "atan_start_frame",
            value = function()
                return "S: " .. MoreMaths.round(Settings.atan_start + 1, 2)
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
