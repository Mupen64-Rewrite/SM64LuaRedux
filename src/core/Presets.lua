local function create_default_preset()
    return Mupen_lua_ugui.internal.deep_clone(Settings)
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
    Settings = Presets.presets[i]
    Presets.set_style(Presets.styles[Settings.active_style_index].theme)
    VarWatch_update()
end

function Presets.reset(i)
    Presets.presets[i] = Mupen_lua_ugui.internal.deep_clone(default_preset)
end

function Presets.save()
    print("Saving preset...")
    local serialized = json.encode(Presets.presets)
    local file = io.open("presets.json", "w")
    file:write(serialized)
    io.close(file)
end

function Presets.restore()
    print("Restoring presets...")
    local file = io.open("presets.json", "r")
    if not file then
        print("No presets to restore")
        return
    end
    local text = file:read("a")
    io.close(file)
    local deserialized = json.decode(text)
    Presets.presets = deserialized
end
