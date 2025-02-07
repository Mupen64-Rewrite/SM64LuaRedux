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
    -- HACK: The movement mode (which is also used by the TAS tab) is stored in TASState, which isn't serialized.
    -- We do however need to serialize the movement mode for UX purposes.
    -- Here, the movement mode is injected into the presets and is also restored when loading
    Settings.hack_movement_mode = TASState.movement_mode

    Presets.persistent.current_index = ugui.internal.clamp(i, 1, #Presets.persistent.presets)
    Settings = Presets.persistent.presets[Presets.persistent.current_index]
    Styles.update_style()
    VarWatch_update()

    -- HACK: See above
    TASState.movement_mode = Settings.hack_movement_mode == nil and 1 or Settings.hack_movement_mode
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
