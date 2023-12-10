local theme = get_base_style()

theme.path = res_path .. "windows-xp-atlas.png"
theme.background_color = { r = 236, g = 233, b = 216 }
theme.font_name = "Tahoma"
theme.pixelated_text = true

return {
    name = 'Windows XP',
    theme = theme,
}