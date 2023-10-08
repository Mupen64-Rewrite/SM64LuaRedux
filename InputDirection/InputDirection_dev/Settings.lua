Settings = {
    goalAngle = 0,
    goalMag = 127,
    setRNG = false,
    ShowEffectiveAngles = false,
    GridSize = 33,
    GridGap = 1,
    styles = {
        {},
        {},
        {},
        {},
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
        items = { -- spaces are used to adjust text placement
            'Disabled',
            'Match Yaw',
            'Match Angle',
            'Reverse Angle',
            'Speedkick',
            'Reset',
            'Swim',
            'Ignore Y',
            '.99',
            'Always',
            'Left',
            'Right',
            'DYaw',
            'Get moved distance',
            'Arctan Strain',
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


local function expand(t)
    return {
        x = t[1],
        y = t[2],
        width = t[3],
        height = t[4],
    }
end
local function get_windows_10_nineslice_style()
    return {
        path = folder("InputDirection_dev/Settings.lua") .. "res/windows-10-atlas.png",
        background_color = BreitbandGraphics.repeated_to_color(240),
        item_height = 15,
        font_size = 12,
        font_name = 'MS Shell Dlg 2',
        button = {
            text_colors = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.black,
                [0] = BreitbandGraphics.repeated_to_color(131),
            },
            states = {
                [1] = {
                    source = expand({ 1, 1, 11, 9 }),
                    center = expand({ 6, 5, 1, 1 }),
                },
                [2] = {
                    source = expand({ 1, 12, 11, 9 }),
                    center = expand({ 6, 16, 1, 1 }),
                },
                [3] = {
                    source = expand({ 1, 23, 11, 9 }),
                    center = expand({ 6, 27, 1, 1 }),
                },
                [0] = {
                    source = expand({ 1, 34, 11, 9 }),
                    center = expand({ 6, 38, 1, 1 }),
                }
            }
        },
        textbox = {
            text_colors = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.black,
                [0] = BreitbandGraphics.repeated_to_color(109),
            },
            states = {
                [1] = {
                    source = expand({ 74, 1, 5, 5 }),
                    center = expand({ 76, 3, 1, 1 }),
                },
                [2] = {
                    source = expand({ 74, 6, 5, 5 }),
                    center = expand({ 76, 8, 1, 1 }),
                },
                [3] = {
                    source = expand({ 74, 11, 5, 5 }),
                    center = expand({ 76, 13, 1, 1 }),
                },
                [0] = {
                    source = expand({ 74, 16, 5, 5 }),
                    center = expand({ 76, 18, 1, 1 }),
                }
            }
        },
    }
end

local function spread(template)
    local result = {}
    for key, value in pairs(template) do
        result[key] = value
    end

    return function(table)
        for key, value in pairs(table) do
            result[key] = value
        end
        return result
    end
end

Settings.create_styles = function()
    Settings.styles[1] = get_windows_10_nineslice_style()
    Settings.styles[2] = spread(get_windows_10_nineslice_style()) {
        path = folder("InputDirection_dev/Settings.lua") .. "res/windows-11-atlas.png",
    }
    Settings.styles[3] = spread(get_windows_10_nineslice_style()) {
        path = folder("InputDirection_dev/Settings.lua") .. "res/windows-10-dark-atlas.png",
        background_color = BreitbandGraphics.repeated_to_color(57),
    }
    Settings.styles[3].button.text_colors = {
        [1] = BreitbandGraphics.colors.white,
        [2] = BreitbandGraphics.colors.white,
        [3] = BreitbandGraphics.colors.white,
        [0] = BreitbandGraphics.repeated_to_color(131),
    }
    Settings.styles[3].textbox.text_colors = {
        [1] = BreitbandGraphics.colors.white,
        [2] = BreitbandGraphics.colors.white,
        [3] = BreitbandGraphics.colors.white,
        [0] = BreitbandGraphics.repeated_to_color(109),
    }

    Settings.styles[4] = spread(get_windows_10_nineslice_style()) {
        path = folder("InputDirection_dev/Settings.lua") .. "res/windows-7-atlas.png",
        background_color = { r = 234, g = 235, b = 236 },
    }
    Settings.styles[4].button.states = {
        [1] = {
            source = expand({ 1, 1, 11, 21 }),
            center = expand({ 4, 4, 5, 15 }),
        },
        [2] = {
            source = expand({ 1, 24, 11, 21 }),
            center = expand({ 4, 27, 5, 15 }),
        },
        [3] = {
            source = expand({ 1, 47, 11, 21 }),
            center = expand({ 4, 50, 5, 15 }),
        },
        [0] = {
            source = expand({ 1, 70, 11, 21 }),
            center = expand({ 4, 73, 5, 15 }),
        }
    }
    Settings.styles[4].textbox.states = {
        [1] = {
            source = expand({ 34, 1, 5, 5 }),
            center = expand({ 36, 3, 1, 1 }),
        },
        [2] = {
            source = expand({ 34, 6, 5, 5 }),
            center = expand({ 36, 8, 1, 1 }),
        },
        [3] = {
            source = expand({ 34, 11, 5, 5 }),
            center = expand({ 36, 13, 1, 1 }),
        },
        [0] = {
            source = expand({ 34, 16, 5, 5 }),
            center = expand({ 36, 18, 1, 1 }),
        }
    }
end
