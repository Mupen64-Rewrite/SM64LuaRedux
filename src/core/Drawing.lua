Drawing = {
    initial_size = nil,
    size = nil,
    scale = 1,
    scale_tolerance = 0.1
}

function Drawing.size_up()
    Drawing.initial_size = wgui.info()
    Drawing.scale = Drawing.initial_size.height / 600
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

function Drawing.paint()
    for i = 1, #Buttons, 1 do
        local button = Buttons[i]
        local box = button.box()

        if button.pressed then
            -- togglebutton
            local previous = button.pressed()
            local pressed = Mupen_lua_ugui.toggle_button({
                uid = i * 5000,
                is_enabled = button.enabled and button.enabled() or true,
                rectangle = {
                    x = box[1],
                    y = box[2],
                    width = box[3],
                    height = box[4]
                },
                text = button.text,
                is_checked = previous
            })
            if not (pressed == previous) then
                button:onclick()
            end
        else
            -- pushbutton
            if Mupen_lua_ugui.button({
                    uid = i * 5000,
                    is_enabled = button.enabled and button.enabled() or true,
                    rectangle = {
                        x = box[1],
                        y = box[2],
                        width = box[3],
                        height = box[4]
                    },
                    text = button.text,
                }) then
                button:onclick()
            end
        end
    end
end
