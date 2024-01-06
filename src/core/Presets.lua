local function create_default_preset()
    return {
        settings  = Mupen_lua_ugui.internal.deep_clone(Settings),
        var_watch = Mupen_lua_ugui.internal.deep_clone(VarWatch)
    }
end

local default_preset = create_default_preset()

Presets = {
    current_index = 1,
    presets = {},
    styles = {
        "windows-11",
        "windows-10",
        "windows-10-dark",
        "windows-3-pink",
        "windows-7",
        "windows-xp",
        "crackhex",
        "neptune",
        "fl-studio",
        "steam",
    }
}

for i = 1, #Presets.styles, 1 do
    local name = Presets.styles[i]
    Presets.styles[i] = dofile(res_path .. name .. "\\" .. "style.lua")
    Presets.styles[i].theme.path = res_path .. name .. "\\" .. "style.png"
end

for i = 1, 6, 1 do
    Presets.presets[i] = create_default_preset()
end

Presets.set_style = function(theme)
    local mod_theme = Mupen_lua_ugui.internal.deep_clone(theme)

    -- HACK: We scale some visual properties according to drawing scale
    mod_theme.font_size = theme.font_size * Drawing.scale
    mod_theme.item_height = theme.item_height * Drawing.scale
    
    Mupen_lua_ugui_ext.apply_nineslice(mod_theme)
end

function Presets.apply(i)
    Presets.current_index = i
    Settings = Presets.presets[i].settings
    VarWatch = Presets.presets[i].var_watch

    Presets.set_style(Presets.styles[Settings.active_style_index].theme)
    VarWatch.update()
end

function Presets.reset(i)
    Presets.presets[i] = Mupen_lua_ugui.internal.deep_clone(default_preset)
end
