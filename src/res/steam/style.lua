local theme = get_base_style()
theme.background_color = BreitbandGraphics.hex_to_color("#4C5945")
theme.font_size = 11.4
theme.font_name = "Tahoma"
theme.pixelated_text = true
theme.button.text_colors = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(131),
}
theme.textbox.text_colors = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox.text_colors = {
    [1] = BreitbandGraphics.colors.white,
    [2] = BreitbandGraphics.colors.white,
    [3] = BreitbandGraphics.colors.white,
    [0] = BreitbandGraphics.repeated_to_color(209),
}
theme.joystick.back_colors = {
    [1] = BreitbandGraphics.hex_to_color("#00000000"),
    [2] = BreitbandGraphics.hex_to_color("#00000000"),
    [3] = BreitbandGraphics.hex_to_color("#00000000"),
    [0] = BreitbandGraphics.hex_to_color("#00000000"),
}
theme.joystick.outline_colors = {
    [1] = BreitbandGraphics.hex_to_color("#4FA33D"),
    [2] = BreitbandGraphics.hex_to_color("#4FA33D"),
    [3] = BreitbandGraphics.hex_to_color("#4FA33D"),
    [0] = BreitbandGraphics.hex_to_color("#4FA33D"),
}
theme.joystick.inner_mag_colors = {
    [1] = BreitbandGraphics.hex_to_color("#4FA33D22"),
    [2] = BreitbandGraphics.hex_to_color("#4FA33D22"),
    [3] = BreitbandGraphics.hex_to_color("#4FA33D22"),
    [0] = BreitbandGraphics.hex_to_color("#4FA33D22"),
}
theme.joystick.outer_mag_colors = {
    [1] = BreitbandGraphics.hex_to_color("#4FA33D"),
    [2] = BreitbandGraphics.hex_to_color("#4FA33D"),
    [3] = BreitbandGraphics.hex_to_color("#4FA33D"),
    [0] = BreitbandGraphics.hex_to_color("#4FA33D"),
}
theme.joystick.line_colors = {
    [1] = BreitbandGraphics.hex_to_color("#00CE4B"),
    [2] = BreitbandGraphics.hex_to_color("#00CE4B"),
    [3] = BreitbandGraphics.hex_to_color("#00CE4B"),
    [0] = BreitbandGraphics.hex_to_color("#00CE4B"),
}
theme.joystick.tip_colors = {
    [1] = BreitbandGraphics.hex_to_color("#00CE4B"),
    [2] = BreitbandGraphics.hex_to_color("#00CE4B"),
    [3] = BreitbandGraphics.hex_to_color("#00CE4B"),
    [0] = BreitbandGraphics.hex_to_color("#00CE4B"),
}

return {
    name = 'Steam',
    theme = theme
}
