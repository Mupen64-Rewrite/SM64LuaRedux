Settings = {
    goalAngle = 0,
    goalMag = 127,
    setRNG = false,
    ShowEffectiveAngles = false,
    VisualStyles = {
        "windows-95",
        "windows-aero",
        "windows-10",
        "windows-11",
        "windows-11-dark",
    },
    VisualStyleIndex = 5
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
    InputField = {           -- where you enter the facing angle or mag
        --EditingText = "#000000", -- optional, defaults to Theme.Text
        Editing = "#FFFFFF",
        Enabled = "#FFFFFF",
        Disabled = "#FFFFFF",
        OutsideOutline = "#7A7A7A", -- outermost
        Outline = "#7A7A7A"    -- inner (creates depth)
    }
}

Settings.Layout = {
    Button = {
        items = { -- spaces are used to adjust text placement
            'Disabled',
            'Match Yaw',
            'Match Angle',
            'Reverse Angle',
            'Speedkick',
            'Reset Mag',
            'Swim',
            'Ignore Y',
            '.99',
            'Always',
            'Left',
            'Right',
            'DYaw',
            'Get moved distance',
            'AtanStrain',
            '+',
            '-',
            '+',
            '-',
            '+',
            '-',
            '+',
            '-',
            '+',
            '-',
            'I',
            'High Mag',
            'Set RNG',
            'V',
            'I',
            'Record Ghost'
        },
        selectedItem = 1,

        DISABLED = 1,
        MATCH_YAW = 2,
        MATCH_ANGLE = 3,
        REVERSE_ANGLE = 4,
        MAG48 = 5,
        RESET_MAG = 6,
        SWIM = 7,
        IGNORE_Y = 8,
        POINT_99 = 9,
        ALWAYS_99 = 10,
        LEFT_99 = 11,
        RIGHT_99 = 12,
        DYAW = 13,
        DIST_MOVED = 14,
        ARCTANSTRAIN = 15,
        INCARCR = 16,
        DECARCR = 17,
        INCARCD = 18,
        DECARCD = 19,
        INCARCN = 20,
        DECARCN = 21,
        INCARCS = 22,
        DECARCS = 23,
        INCARCE = 24,
        DECARCE = 25,
        REVERSE_ARCTAN = 26,
        HIGH_MAG = 27,
        SET_RNG = 28,
        USE_VALUE = 29,
        USE_INDEX = 30,
        RECORD_GHOST = 31,

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
            always = false,
            target_strain = true,
            left = true,
            right = false,
            dyaw = false,
            arctan = false,
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
    TextArea = {
        items = { 'Match Angle', 'Magnitude', 'RNG' },
        selectedItem = 0,
        selectedChar = 1,
        blinkTimer = 0,
        blinkRate = 25, -- lower number = blink faster
        showUnderscore = true,

        MATCH_ANGLE = 1,
        MAGNITUDE = 2,
        RNG = 3
    }
}
