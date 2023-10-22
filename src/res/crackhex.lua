local theme = get_base_style()

theme.path = res_path .. "crackhex-atlas.png"
theme.background_color = BreitbandGraphics.repeated_to_color(34)

theme.textbox.text_colors = {
    [1] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [2] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [3] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [0] = BreitbandGraphics.repeated_to_color(109),
}
theme.listbox.text_colors = {
    [1] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [2] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [3] = BreitbandGraphics.hex_to_color("#F7A8B8"),
    [0] = BreitbandGraphics.repeated_to_color(209),
}

return {
    name = 'Crackhex',
    theme = theme
}
