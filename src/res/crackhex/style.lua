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

return {
    name = 'Crackhex',
    theme = theme
}
