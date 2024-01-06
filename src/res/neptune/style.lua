local theme = get_base_style()

theme.background_color = { r = 24, g = 27, b = 40 }
theme.button.text_colors = {
    [1] = BreitbandGraphics.hex_to_color("#C2C6D0"),
    [2] = BreitbandGraphics.hex_to_color("#0D1016"),
    [3] = BreitbandGraphics.hex_to_color("#4B0054"),
    [0] = BreitbandGraphics.repeated_to_color(131),
}
theme.textbox.text_colors = {
    [1] = BreitbandGraphics.hex_to_color("#C2C6D0"),
    [2] = BreitbandGraphics.hex_to_color("#C2C6D0"),
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox.text_colors = {
    [1] = BreitbandGraphics.hex_to_color("#C2C6D0"),
    [2] = BreitbandGraphics.hex_to_color("#C2C6D0"),
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.draw_joystick_inner = function(rectangle, visual_state, position)
    local outline_color = BreitbandGraphics.hex_to_color("#D05DF3")
    local tip_color = Mupen_lua_ugui.standard_styler.joystick_tip_colors[visual_state]
    local line_color = BreitbandGraphics.hex_to_color("#6EE4E7")

    BreitbandGraphics.draw_ellipse(BreitbandGraphics.inflate_rectangle(rectangle, -1),
        outline_color, 1)
    BreitbandGraphics.draw_line({
        x = rectangle.x + rectangle.width / 2,
        y = rectangle.y,
    }, {
        x = rectangle.x + rectangle.width / 2,
        y = rectangle.y + rectangle.height,
    }, outline_color, 1)
    BreitbandGraphics.draw_line({
        x = rectangle.x,
        y = rectangle.y + rectangle.height / 2,
    }, {
        x = rectangle.x + rectangle.width,
        y = rectangle.y + rectangle.height / 2,
    }, outline_color, 1)

    BreitbandGraphics.draw_line({
        x = rectangle.x + rectangle.width / 2,
        y = rectangle.y + rectangle.height / 2,
    }, {
        x = position.x,
        y = position.y,
    }, line_color, 3)
    local tip_size = 8
    BreitbandGraphics.fill_ellipse({
        x = position.x - tip_size / 2,
        y = position.y - tip_size / 2,
        width = tip_size,
        height = tip_size,
    }, tip_color)
end

return {
    name = 'Neptune',
    theme = theme
}
