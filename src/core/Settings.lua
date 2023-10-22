Settings = {
    movement_modes = {
        disabled = 1,
        match_yaw = 2,
        reverse_angle = 3,
        match_angle = 4,
    },
    swimming_button = "A",
    controller_index = 1,
    goal_angle = 0,
    goal_mag = 127,
    override_rng = false,
    override_rng_use_index = false,
    override_rng_value = 0,
    show_effective_angles = true,
    recording_ghost = false,
    strain_left = true,
    strain_right = false,
    dyaw = false,
    strain_speed_target = false,
    strain_always = false,
    high_magnitude = false,
    arctan_strain = false,
    swim = false,
    GridSize = 33,
    GridGap = 1,
    movement_mode = 1,
    styles = {
        dofile(res_path .. "windows-11.lua"),
        dofile(res_path .. "windows-10.lua"),
        dofile(res_path .. "windows-10-dark.lua"),
        dofile(res_path .. "windows-7.lua"),
        dofile(res_path .. "windows-3-pink.lua"),
        dofile(res_path .. "crackhex.lua"),
    },
    active_style_index = 1
}

--[[
{} means the hotkey is disabled.
To bind to key combinations list them. Ex: {"control", "M"}
Numbers will always edit value fields, and arrow keys
arrow keys will always change selected digits in value fields.
For a list of valid keys (case-sensitive) see:
  https://docs.google.com/document/d/1SWd-oAFBKsGmwUs0qGiOrk3zfX9wYHhi3x5aKPQS_o0/edit#bookmark=id.jcojkq7g066s
]]
--
Settings.Hotkeys = {
    ["dist moved"] = {},
    ["ignore y"] = {},

    [".99"] = {},
    ["always .99"] = {},
    [".99 left"] = {},
    [".99 right"] = {},

    ["disabled"] = {},
    ["match yaw"] = {},
    ["reverse angle"] = {},

    ["match angle"] = {},
    ["match angle value"] = {},
    ["dyaw"] = {},

    ["arcotan strain"] = {},
    ["reverse arcotan strain"] = {},

    ["increment arcotan ratio"] = {},
    ["decrement arcotan ratio"] = {},

    ["increment arcotan displacement"] = {},
    ["decrement arcotan displacement"] = {},

    ["increment arcotan length"] = {},
    ["decrement arcotan length"] = {},

    ["increment arcotan start frame"] = {},
    ["decrement arcotan start frame"] = {},

    ["increment arcotan step"] = {},
    ["decrement arcotan step"] = {},

    ["magnitude value"] = {},
    ["speedkick magnitude"] = {},
    ["reset magnitude"] = {},
    ["high magnitude"] = {},

    ["swim"] = {},

    ["set rng"] = {},
    ["use value"] = {},
    ["use index"] = {},
    ["set rng input"] = {},

    ["record ghost"] = {}
}



Settings.Colors = {
    Text = "#000000",
    ReadWriteText = "#FF0000", -- should be the same as or a bit brighter than Button.Pressed.Top
    Background = "#fdfdfd",
    InputField = {             -- where you enter the facing angle or mag
        --EditingText = "#000000", -- optional, defaults to Theme.Text
        Editing = "#FFFFFF",
        Enabled = "#FFFFFF",
        Disabled = "#FFFFFF",
        OutsideOutline = "#7A7A7A", -- outermost
        Outline = "#7A7A7A"         -- inner (creates depth)
    }
}

Settings.Layout = {
    Button = {
        selectedItem = 1,

        dist_button = {
            enabled = false,
            dist_moved_save = 0,
            ignore_y = false,
            axis = {
                x = 0,
                y = 0,
                z = 0
            }
        },
        strain_button = {
            controls = false,
            reverse_arc = false,
            arctanstart = 0,
            arctanr = 1.0,
            arctand = 0.0,
            arctann = 10,
            arctanexp = 0,
            highmag = false
        },
        set_rng_mode = {
            value = false,
            index = true,
        },
        swimming = false
    },
}
