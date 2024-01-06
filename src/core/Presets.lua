local function create_default_preset()
    return {
        settings  = Mupen_lua_ugui.internal.deep_clone(Settings),
        var_watch = Mupen_lua_ugui.internal.deep_clone(VarWatch)
    }
end

local default_preset = create_default_preset()

Presets = {
    current_index = 1,
    presets = {}
}

for i = 1, 6, 1 do
    Presets.presets[i] = create_default_preset()
end

function Presets.apply(i)
    Presets.current_index = i
    Settings = Presets.presets[i].settings
    VarWatch = Presets.presets[i].var_watch

    -- HACK: We store the theme's original font size and scale it according to drawing scale
    if not Settings.styles[Settings.active_style_index].theme.original_font_size then
        Settings.styles[Settings.active_style_index].theme.original_font_size = Settings.styles
            [Settings.active_style_index].theme.font_size
    end
    Settings.styles[Settings.active_style_index].theme.font_size = Settings.styles[Settings.active_style_index].theme
        .original_font_size * Drawing.scale

    -- HACK: We store the theme's original item height and scale it according to drawing scale
    if not Settings.styles[Settings.active_style_index].theme.original_item_height then
        Settings.styles[Settings.active_style_index].theme.original_item_height = Settings.styles
            [Settings.active_style_index].theme.item_height
    end
    Settings.styles[Settings.active_style_index].theme.item_height = Settings.styles[Settings.active_style_index].theme
        .original_item_height * Drawing.scale

    Mupen_lua_ugui_ext.apply_nineslice(Settings.styles[Settings.active_style_index].theme)
    VarWatch.update()
end

function Presets.reset(i)
    Presets.presets[i] = Mupen_lua_ugui.internal.deep_clone(default_preset)
end
