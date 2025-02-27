local theme = get_base_style()

theme.background_color = { r = 54, g = 30, b = 53 }
theme.font_size = 11.4
theme.font_name = "Consolas"
theme.cleartype = false

theme.button.text = {
    [1] = BreitbandGraphics.colors.black,
    [2] = BreitbandGraphics.colors.black,
    [3] = BreitbandGraphics.colors.black,
    [0] = BreitbandGraphics.repeated_to_color(131),
}
theme.textbox.text = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox_item.text = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.joystick.back = {
    [1] = BreitbandGraphics.hex_to_color("#00000000"),
    [2] = BreitbandGraphics.hex_to_color("#00000000"),
    [3] = BreitbandGraphics.hex_to_color("#00000000"),
    [0] = BreitbandGraphics.hex_to_color("#00000000"),
}
theme.joystick.outline = {
    [1] = BreitbandGraphics.hex_to_color("#2D022B"),
    [2] = BreitbandGraphics.hex_to_color("#2D022B"),
    [3] = BreitbandGraphics.hex_to_color("#2D022B"),
    [0] = BreitbandGraphics.hex_to_color("#2D022B"),
}
theme.joystick.inner_mag = {
    [1] = BreitbandGraphics.hex_to_color("#2D022B22"),
    [2] = BreitbandGraphics.hex_to_color("#2D022B22"),
    [3] = BreitbandGraphics.hex_to_color("#2D022B22"),
    [0] = BreitbandGraphics.hex_to_color("#2D022B22"),
}
theme.joystick.outer_mag = {
    [1] = BreitbandGraphics.hex_to_color("#2D022B"),
    [2] = BreitbandGraphics.hex_to_color("#2D022B"),
    [3] = BreitbandGraphics.hex_to_color("#2D022B"),
    [0] = BreitbandGraphics.hex_to_color("#2D022B"),
}
theme.joystick.line = {
    [1] = BreitbandGraphics.hex_to_color("#2D022B"),
    [2] = BreitbandGraphics.hex_to_color("#2D022B"),
    [3] = BreitbandGraphics.hex_to_color("#2D022B"),
    [0] = BreitbandGraphics.hex_to_color("#2D022B"),
}
theme.joystick.tip = {
    [1] = BreitbandGraphics.hex_to_color("#560453"),
    [2] = BreitbandGraphics.hex_to_color("#560453"),
    [3] = BreitbandGraphics.hex_to_color("#560453"),
    [0] = BreitbandGraphics.hex_to_color("#560453"),
}
return {
    name = 'Windows 3 Pink',
    theme = theme
}
