Formatter = {}

---Formats a number as an angle
---@param value number The value to be formatted
---@return string The value's string representation
Formatter.angle = function(value)
    if Settings.format_angles_degrees then
        return string.format("%sdeg",
            MoreMaths.round(Mupen_lua_ugui.internal.remap(value, 0, 65536, 0, 360), Settings.format_decimal_points))
    else
        return tostring(MoreMaths.round(value, Settings.format_decimal_points))
    end
end

---Formats a number as a units/s value
---@param value number The value to be formatted
---@return string The value's string representation
Formatter.ups = function(value)
    return tostring(MoreMaths.round(value, Settings.format_decimal_points))
end

---Formats a number as a unit
---@param value number The value to be formatted
---@return string The value's string representation
Formatter.u = function(value)
    return tostring(MoreMaths.round(value, Settings.format_decimal_points))
end

---Formats a number (standard bounds 0-1) as a percentage
---@param value number The value to be formatted
---@return string The value's string representation
Formatter.percent = function(value)
    return MoreMaths.round(value * 100, Settings.format_decimal_points) .. "%"
end
