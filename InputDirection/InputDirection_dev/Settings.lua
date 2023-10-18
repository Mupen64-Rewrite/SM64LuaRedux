Settings = {
    movement_modes = {
        disabled = 1,
        match_yaw = 2,
        reverse_angle = 3,
        match_angle = 4,
    },
    goalAngle = 0,
    goalMag = 127,
    setRNG = false,
    ShowEffectiveAngles = false,
    recording_ghost = false,
    GridSize = 33,
    GridGap = 1,
    movement_mode = 1,
    styles = {
        {},
        {},
        {},
        {},
        {},
    },
    active_style_index = 2
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
        listbox = {
            text_colors = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.white,
                [0] = BreitbandGraphics.repeated_to_color(204),
            },
            states = {
                [1] = {
                    source = expand({ 80, 1, 3, 3 }),
                    center = expand({ 81, 2, 1, 1 }),
                },
                [2] = {
                    source = expand({ 80, 1, 3, 3 }),
                    center = expand({ 81, 2, 1, 1 }),
                },
                [3] = {
                    source = expand({ 80, 1, 3, 3 }),
                    center = expand({ 81, 2, 1, 1 }),
                },
                [0] = {
                    source = expand({ 80, 10, 3, 3 }),
                    center = expand({ 81, 11, 1, 1 }),
                }
            }
        },
        listbox_item = {
            states = {
                [1] = {
                    source = expand({ 83, 5, 3, 4 }),
                    center = expand({ 84, 6, 1, 2 }),
                },
                [2] = {
                    source = expand({ 83, 5, 3, 4 }),
                    center = expand({ 84, 6, 1, 2 }),
                },
                [3] = {
                    source = expand({ 83, 1, 3, 4 }),
                    center = expand({ 84, 2, 1, 2 }),
                },
                [0] = {
                    source = expand({ 83, 5, 3, 4 }),
                    center = expand({ 84, 6, 1, 2 }),
                }
            }
        },
        scrollbar_thumb = {
            states = {
                [1] = {
                    source = expand({ 30, 66, 17, 11 }),
                    center = expand({ 38, 70, 2, 3 }),
                },
                [2] = {
                    source = expand({ 30, 77, 17, 11 }),
                    center = expand({ 38, 81, 2, 3 }),
                },
                [3] = {
                    source = expand({ 30, 88, 17, 11 }),
                    center = expand({ 38, 92, 2, 3 }),
                },
                [0] = {
                    source = expand({ 30, 110, 17, 11 }),
                    center = expand({ 38, 114, 2, 3 }),
                }
            }
        },
        scrollbar_rail = expand({ 30, 99, 17, 11 })
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
    Settings.styles[3].listbox.text_colors = {
        [1] = BreitbandGraphics.colors.white,
        [2] = BreitbandGraphics.colors.white,
        [3] = BreitbandGraphics.colors.white,
        [0] = BreitbandGraphics.repeated_to_color(209),
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
    Settings.styles[4].listbox.states = {
        [1] = {
            source = expand({ 34, 22, 3, 3 }),
            center = expand({ 35, 23, 1, 1 }),
        },
        [2] = {
            source = expand({ 34, 25, 3, 3 }),
            center = expand({ 35, 26, 1, 1 }),
        },
        [3] = {
            source = expand({ 34, 28, 3, 3 }),
            center = expand({ 35, 29, 1, 1 }),
        },
        [0] = {
            source = expand({ 34, 31, 3, 3 }),
            center = expand({ 35, 32, 1, 1 }),
        }
    }
    Settings.styles[4].listbox_item.states = {
        [1] = {
            source = expand({ 34, 40, 3, 4 }),
            center = expand({ 35, 41, 1, 2 }),
        },
        [2] = {
            source = expand({ 34, 40, 3, 4 }),
            center = expand({ 35, 41, 1, 2 }),
        },
        [3] = {
            source = expand({ 34, 35, 3, 4 }),
            center = expand({ 35, 36, 1, 2 }),
        },
        [0] = {
            source = expand({ 34, 40, 3, 4 }),
            center = expand({ 35, 41, 1, 2 }),
        }
    }
    Settings.styles[4].scrollbar_thumb = {
        states = {
            [1] = {
                source = expand({ 55, 57, 17, 22 }),
                center = expand({ 59, 61, 9, 14 }),
            },
            [2] = {
                source = expand({ 55, 79, 17, 22 }),
                center = expand({ 59, 83, 9, 14 }),
            },
            [3] = {
                source = expand({ 55, 101, 17, 22 }),
                center = expand({ 59, 105, 9, 14 }),
            },
            [0] = {
                source = expand({ 55, 145, 17, 22 }),
                center = expand({ 59, 149, 9, 14 }),
            }
        }
    }
    Settings.styles[4].scrollbar_rail = expand({ 55, 123, 17, 22 })
    Settings.styles[5] = spread(get_windows_10_nineslice_style()) {
        path = folder("InputDirection_dev/Settings.lua") .. "res/windows-3-pink-atlas.png",
        background_color = { r = 54, g = 30, b = 53 },
        font_name = "Consolas"
    }
    Settings.styles[5].button.text_colors = Settings.styles[3].button.text_colors
    Settings.styles[5].textbox.text_colors = Settings.styles[3].textbox.text_colors
    Settings.styles[5].listbox.text_colors = Settings.styles[3].textbox.text_colors
end
