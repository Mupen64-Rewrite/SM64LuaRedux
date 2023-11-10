Drawing = {
    initial_size = nil,
    size = nil,
    scale = 1,
    scale_tolerance = 0.1
}

function Drawing.size_up()
    Drawing.initial_size = wgui.info()
    Drawing.scale = (Drawing.initial_size.height - 23) / 600
    local extra_space = (Settings.grid_size * 8)
    if Drawing.scale > 1 + Drawing.scale_tolerance or Drawing.scale < 1 - Drawing.scale_tolerance then
        extra_space = extra_space * Drawing.scale
    end
    wgui.resize(math.floor(Drawing.initial_size.width + extra_space),
        Drawing.initial_size.height)
    Drawing.size = wgui.info()
    print("Scale factor " .. Drawing.scale)
end

function Drawing.size_down()
    wgui.resize(wgui.info().width - (wgui.info().width - Drawing.initial_size.width), wgui.info().height)
end