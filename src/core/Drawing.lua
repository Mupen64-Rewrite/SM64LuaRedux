Drawing = {
    initial_size = nil,
    size = nil,
    scale = 1,
    offset_stack = {},
}

function Drawing.size_up()
    Drawing.initial_size = wgui.info()
    Drawing.scale = (Drawing.initial_size.height - 23) / 600
    Drawing.scale = MoreMaths.round(Drawing.scale, 2)

    local extra_space = (Settings.grid_size * 8) * Drawing.scale
    wgui.resize(math.floor(Drawing.initial_size.width + extra_space),
        Drawing.initial_size.height)
    Drawing.size = wgui.info()
    print("Scale factor " .. Drawing.scale)
end

function Drawing.size_down()
    wgui.resize(wgui.info().width - (wgui.info().width - Drawing.initial_size.width), wgui.info().height)
end

function grid(x, y, x_span, y_span, abs, gap)
    if not gap then
        gap = Settings.grid_gap
    end
    if not x_span then
        x_span = 1
    end
    if not y_span then
        y_span = 1
    end

    local baseline_x = abs and 0 or Drawing.initial_size.width

    local base_x = baseline_x + (Settings.grid_size * x)
    local base_y = (Settings.grid_size * y)

    local rect = {
        base_x + gap,
        base_y + gap,
        (Settings.grid_size * x_span) - gap * 2,
        (Settings.grid_size * y_span) - gap * 2,
    }

    rect[1] = (baseline_x + (Settings.grid_size * x * Drawing.scale)) + gap
    rect[2] = rect[2] * Drawing.scale
    rect[3] = rect[3] * Drawing.scale
    rect[4] = rect[4] * Drawing.scale

    return { math.floor(rect[1]), math.floor(rect[2]), math.floor(rect[3]), math.floor(rect[4]) }
end

function Drawing.push_offset(x, y)
    Drawing.offset_stack[#Drawing.offset_stack + 1] = { x = x, y = y }
end

function Drawing.pop_offset()
    if #Drawing.offset_stack == 0 then
        return
    end
    table.remove(Drawing.offset_stack, #Drawing.offset_stack)
end

local function adjust_rect(rect)
    for _, value in pairs(Drawing.offset_stack) do
        rect.x = rect.x + value.x
        rect.y = rect.y + value.y
    end
    return rect
end

function grid_rect(x, y, x_span, y_span, gap)
    local value = grid(x, y, x_span, y_span, false, gap)
    return adjust_rect({
        x = value[1],
        y = value[2],
        width = value[3],
        height = value[4],
    })
end

function grid_rect_abs(x, y, x_span, y_span, gap)
    local value = grid(x, y, x_span, y_span, true, gap)
    return adjust_rect({
        x = value[1],
        y = value[2],
        width = value[3],
        height = value[4],
    })
end
