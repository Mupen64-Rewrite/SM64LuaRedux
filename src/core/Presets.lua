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
    Mupen_lua_ugui_ext.apply_nineslice(Settings.styles[Settings.active_style_index].theme)
    VarWatch.update()
end

function Presets.reset(i)
    Presets.presets[i] = Mupen_lua_ugui.internal.deep_clone(default_preset)
end