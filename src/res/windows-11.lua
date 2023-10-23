local theme = get_base_style()
theme.path = res_path .. "windows-11-atlas.png"
return {
    name = 'Windows 11',
    theme = spread(theme) {
        font_name = "Segoe UI Variable Text",
        font_size = 12
    }
}
