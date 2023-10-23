local theme = get_base_style()

theme.path = res_path .. "windows-3-pink-atlas.png"
theme.background_color = { r = 54, g = 30, b = 53 }
theme.font_name = "Consolas"
theme.button.text_colors = {
    [1] = BreitbandGraphics.colors.black,
    [2] = BreitbandGraphics.colors.black,
    [3] = BreitbandGraphics.colors.black,
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

return {
    name = 'Windows 3 Pink',
    theme = theme
}
