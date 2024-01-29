local theme = get_base_style()

theme.font_name = "Consolas"
theme.background_color = BreitbandGraphics.repeated_to_color(34)
theme.button.text_colors = {
    [1] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [2] = BreitbandGraphics.colors.black,
    [3] = BreitbandGraphics.colors.black,
    [0] = BreitbandGraphics.repeated_to_color(131),
}
theme.textbox.text_colors = {
    [1] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [2] = BreitbandGraphics.colors.black,
    [3] = BreitbandGraphics.colors.black,
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox.text_colors = {
    [1] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [2] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [3] = BreitbandGraphics.colors.black,
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.joystick.back_colors = {
    [1] = BreitbandGraphics.hex_to_color("#00000000"),
    [2] = BreitbandGraphics.hex_to_color("#00000000"),
    [3] = BreitbandGraphics.hex_to_color("#00000000"),
    [0] = BreitbandGraphics.hex_to_color("#00000000"),
}
theme.joystick.outline_colors = {
    [1] = BreitbandGraphics.hex_to_color("#386A87"),
    [2] = BreitbandGraphics.hex_to_color("#386A87"),
    [3] = BreitbandGraphics.hex_to_color("#386A87"),
    [0] = BreitbandGraphics.hex_to_color("#386A87"),
}
theme.joystick.inner_mag_colors = {
    [1] = BreitbandGraphics.hex_to_color("#55A0CC22"),
    [2] = BreitbandGraphics.hex_to_color("#55A0CC22"),
    [3] = BreitbandGraphics.hex_to_color("#55A0CC22"),
    [0] = BreitbandGraphics.hex_to_color("#55A0CC22"),
}
theme.joystick.outer_mag_colors = {
    [1] = BreitbandGraphics.hex_to_color("#55A0CC"),
    [2] = BreitbandGraphics.hex_to_color("#55A0CC"),
    [3] = BreitbandGraphics.hex_to_color("#55A0CC"),
    [0] = BreitbandGraphics.hex_to_color("#55A0CC"),
}
theme.joystick.line_colors = {
    [1] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [2] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [3] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [0] = BreitbandGraphics.hex_to_color("#EEAFC0"),
}
theme.joystick.tip_colors = {
    [1] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [2] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [3] = BreitbandGraphics.hex_to_color("#EEAFC0"),
    [0] = BreitbandGraphics.hex_to_color("#EEAFC0"),
}
return {
    name = 'Crackhex',
    theme = theme
}
