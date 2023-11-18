function grid(x, y, x_span, y_span)
    if not x_span then
        x_span = 1
    end
    if not y_span then
        y_span = 1
    end

    local base_x = Drawing.initial_size.width + (Settings.grid_size * x)
    local base_y = (Settings.grid_size * y)

    local rect = {
        base_x + Settings.grid_gap,
        base_y + Settings.grid_gap,
        (Settings.grid_size * x_span) - Settings.grid_gap * 2,
        (Settings.grid_size * y_span) - Settings.grid_gap * 2,
    }

    rect[1] = (Drawing.initial_size.width + (Settings.grid_size * x * Drawing.scale)) + Settings.grid_gap
    rect[2] = rect[2] * Drawing.scale
    rect[3] = rect[3] * Drawing.scale
    rect[4] = rect[4] * Drawing.scale

    return { math.floor(rect[1]), math.floor(rect[2]), math.floor(rect[3]), math.floor(rect[4]) }
end

function grid_rect(x, y, x_span, y_span)
    local value = grid(x, y, x_span, y_span)
    return {
        x = value[1],
        y = value[2],
        width = value[3],
        height = value[4],
    }
end
