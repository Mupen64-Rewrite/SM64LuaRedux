local theme = get_base_style()

theme.background_color = { r = 236, g = 233, b = 216 }
theme.font_size = 11.4
theme.font_name = "Tahoma"
theme.pixelated_text = true
theme.draw_joystick_inner = function(rectangle, visual_state, position)
    local outline_color = BreitbandGraphics.colors.black
    local tip_color = Mupen_lua_ugui.standard_styler.joystick_tip_colors[visual_state]
    local line_color = BreitbandGraphics.hex_to_color("#84A7F9")

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
    name = 'Windows XP',
    theme = theme,
}
