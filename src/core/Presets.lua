local function create_default_preset()
    return ugui.internal.deep_clone(Settings)
end

local default_preset = create_default_preset()

Presets = {
    persistent = {
        current_index = 1,
        presets = {},
    },
}

print("Creating default presets...")

for i = 1, 6, 1 do
    Presets.persistent.presets[i] = create_default_preset()
end

function Presets.get_default_preset()
    return ugui.internal.deep_clone(default_preset)
end

function Presets.apply(i)
    -- HACK: The TASState isn't currently serialized properly.
    -- Here, the TASState contents are injected into the presets and are also restored when loading.
    for key, value in pairs(TASState) do
        Settings["tasstate_" .. key] = value
    end

    Presets.persistent.current_index = ugui.internal.clamp(i, 1, #Presets.persistent.presets)
    Settings = Presets.persistent.presets[Presets.persistent.current_index]
    Styles.update_style()
    VarWatch_update()

    -- HACK: See above
    for key, value in pairs(TASState) do
        TASState[key] = Settings["tasstate_" .. key] == nil and NewTASState()[key] or Settings["tasstate_" .. key]
    end
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

    deserialized = deep_merge(Presets.persistent, deserialized)

    Presets.persistent = deserialized
end
