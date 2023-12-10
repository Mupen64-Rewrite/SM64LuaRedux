local theme = get_base_style()

theme.path = res_path .. "neptune-atlas.png"
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

return {
    name = 'Neptune',
    theme = theme
}
