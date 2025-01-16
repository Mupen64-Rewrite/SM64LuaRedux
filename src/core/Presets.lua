local function create_default_preset()
    return ugui.internal.deep_clone(Settings)
end

local default_preset = create_default_preset()

Presets = {
    persistent = {
        protocol = 12,
        current_index = 1,
        presets = {},
    },
    styles = {
        "windows-11",
        "windows-11-v2",
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

local function deep_merge(a, b)
    local result = {}

    local function merge(t1, t2)
        local merged = {}
        for key, value in pairs(t1) do
            if type(value) == "table" and type(t2[key]) == "table" then
                merged[key] = merge(value, t2[key])
            else
                merged[key] = value
            end
        end

        for key, value in pairs(t2) do
            if type(value) == "table" and type(t1[key]) == "table" then
            else
                merged[key] = value
            end
        end

        return merged
    end

    return merge(a, b)
end

-- TODO: Move style handling into another file. This has nothing to do with presets.
for i = 1, #Presets.styles, 1 do
    local name = Presets.styles[i]
    Presets.styles[i] = dofile(res_path .. name .. "\\" .. "style.lua")
    Presets.styles[i].theme.path = res_path .. name .. "\\" .. "style.png"
    Presets.styles[i].theme = deep_merge(ugui.internal.deep_clone(ugui.standard_styler.params), Presets.styles[i].theme)
end

print("Creating default presets...")

for i = 1, 6, 1 do
    Presets.persistent.presets[i] = create_default_preset()
end

function Presets.get_default_preset()
    return ugui.internal.deep_clone(default_preset)
end

Presets.set_style = function(theme)
    local mod_theme = ugui.internal.deep_clone(theme)

    -- HACK: We scale some visual properties according to drawing scale
    local listbox_item_height = theme.listbox_item.height or ugui.standard_styler.params.listbox_item.height
    mod_theme.font_size = theme.font_size * Drawing.scale
    mod_theme.listbox_item.height = listbox_item_height * Drawing.scale
    mod_theme.joystick.tip_size = (theme.joystick.tip_size or 8) * Drawing.scale

    ugui.standard_styler.params = mod_theme
    ugui.standard_styler.params.tabcontrol.rail_size = grid_rect(0, 0, 0, 1).height
    ugui.standard_styler.params.tabcontrol.draw_frame = false
    ugui.standard_styler.params.tabcontrol.gap_x = Settings.grid_gap
    ugui.standard_styler.params.tabcontrol.gap_y = Settings.grid_gap

    ugui_ext.apply_nineslice(mod_theme)
end

function Presets.apply(i)
    Presets.persistent.current_index = ugui.internal.clamp(i, 1, #Presets.persistent.presets)
    Settings = Presets.persistent.presets[Presets.persistent.current_index]
    Presets.set_style(Presets.styles[Settings.active_style_index].theme)
    VarWatch_update()
end

function Presets.reset(i)
    Presets.persistent.presets[i] = ugui.internal.deep_clone(default_preset)
end

function Presets.save()
    print("Saving preset...")
    persistence.store("presets.lua", Presets.persistent)
end

function Presets.restore()
    print("Restoring presets...")
    local deserialized = persistence.load("presets.lua")
    if (deserialized == nil) then return end

    -- We can't load old protocol presets
    if deserialized.protocol < Presets.persistent.protocol then
        print("Preset is outdated")
        return
    end

    Presets.persistent = deserialized
end
