-- Input Direction Lua Script v3.5
-- Author: MKDasher
-- Hacker: Eddio0141
-- Special thanks to Pannenkoek2012 and Peter Fedak for angle calculation support.
-- Also thanks to MKDasher to making the code very clean
-- Other contributors:
--	Madghostek, Xander, galoomba, ShadoXFM, Lemon, Manama, tjk

function folder(thisFileName)
    local str = debug.getinfo(2, 'S').source:sub(2)
    return (str:match('^.*/(.*).lua$') or str):sub(1, -(thisFileName):len() - 1)
end

function get_keys(t)
    local keys = {}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end

PATH = debug.getinfo(1).source:sub(2):match("(.*\\)") .. "\\InputDirection_dev\\"
CURRENT_PATH = debug.getinfo(1).source:sub(2):match("(.*\\)") .. "\\"

dofile(CURRENT_PATH .. "mupen-lua-ugui.lua")
dofile(CURRENT_PATH .. "mupen-lua-ugui-ext.lua")
dofile(PATH .. "Settings.lua")
dofile(PATH .. "Drawing.lua")
Drawing.resizeScreen()

dofile(PATH .. "Memory.lua")
dofile(PATH .. "Joypad.lua")
dofile(PATH .. "Angles.lua")
dofile(PATH .. "Engine.lua")
dofile(PATH .. "Buttons.lua")
dofile(PATH .. "Input.lua")
dofile(PATH .. "Program.lua")
dofile(PATH .. "MoreMaths.lua")
dofile(PATH .. "Actions.lua")
dofile(PATH .. "Swimming.lua")
dofile(PATH .. "RNGToIndex.lua")
dofile(PATH .. "IndexToRNG.lua")
dofile(PATH .. "recordghost.lua")
dofile(PATH .. "Timing.lua")

Settings.ShowEffectiveAngles = false -- show angles floored to the nearest multiple of 16
local tabs = {
    "TAS",
    "Timing",
    "Settings",
}
local tab_index = 1

Settings.create_styles()
Mupen_lua_ugui_ext.apply_nineslice(Settings.styles[Settings.active_style_index])

Program.initFrame()
Memory.UpdatePrevPos()
function main()
    Program.initFrame()
    Program.main()
    Timing.update()
    Program.rngSetter()
    Joypad.send()
    Swimming.swim("A")

    if recording_ghost then
        Ghost.main()
    end
end

function drawing()
    local keys = input.get()
    Mupen_lua_ugui.begin_frame(BreitbandGraphics, Mupen_lua_ugui.stylers.windows_10, {
        pointer = {
            position = {
                x = keys.xmouse,
                y = keys.ymouse,
            },
            is_primary_down = keys.leftclick,
        },
        keyboard = {
            held_keys = keys,
        },
    })

    Memory.Refresh()

    BreitbandGraphics.fill_rectangle({
        x = Drawing.Screen.Width,
        y = 0,
        width = Drawing.Screen.Width + Drawing.WIDTH_OFFSET,
        height = Drawing.Screen.Height - 20
    }, Settings.styles[Settings.active_style_index].background_color)

    if tab_index == 1 then
        Drawing.paint()

        local h_speed = 0
        if Memory.Mario.HSpeed ~= 0 then
            h_speed = MoreMaths.DecodeDecToFloat(Memory.Mario.HSpeed)
        end

        local y_speed = 0
        if Memory.Mario.VSpeed > 0 then
            y_speed = MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.VSpeed), 6)
        end

        local distmoved = Engine.GetTotalDistMoved()
        if (Settings.Layout.Button.dist_button.enabled == false) then
            distmoved = Settings.Layout.Button.dist_button.dist_moved_save
        end


        local items = {
            "Yaw (Facing): " ..
            (Settings.ShowEffectiveAngles and Engine.getEffectiveAngle(Memory.Mario.FacingYaw) or Memory.Mario.FacingYaw),
            "Yaw (Intended): " ..
            (Settings.ShowEffectiveAngles and Engine.getEffectiveAngle(Memory.Mario.IntendedYaw) or Memory.Mario.IntendedYaw),
            "Yaw (Facing) O: " ..
            (Settings.ShowEffectiveAngles and (Engine.getEffectiveAngle(Memory.Mario.FacingYaw) + 32768) % 65536 or (Memory.Mario.FacingYaw + 32768) % 65536),
            "Yaw (Intended) O: " ..
            (Settings.ShowEffectiveAngles and (Engine.getEffectiveAngle(Memory.Mario.IntendedYaw) + 32768) % 65536 or (Memory.Mario.IntendedYaw + 32768) % 65536),
            "H Spd: " .. MoreMaths.Round(h_speed, 5) .. " (Sliding: " .. MoreMaths.Round(Engine.GetHSlidingSpeed(), 6) .. ")",
            "Y Spd: " .. MoreMaths.Round(y_speed, 6),
            "Spd Efficiency: " .. Engine.GetSpeedEfficiency() .. "%",
            "XYZ " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.X), 2) .. " | " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Y), 2) .. " | " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Z), 2),
            "XZ Movement: " .. MoreMaths.Round(Engine.GetDistMoved(), 6),
            "Action: " .. Engine.GetCurrentAction(),
            "RNG: " .. Memory.RNGValue .. " (index: " .. get_index(Memory.RNGValue) .. ")",
            "Moved Dist: " .. distmoved,
            "E: " .. Settings.Layout.Button.strain_button.arctanexp,
            "R: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctanr, 5),
            "D: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctand, 5),
            "N: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctann, 2),
            "S: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctanstart + 1, 2),
        }

        Mupen_lua_ugui.listbox({
            uid = 13377331,
            is_enabled = true,
            rectangle = grid_rect(0, 8, 7, 6),
            selected_index = 2,
            items = items,
        })

        Input.update()
    elseif tab_index == 2 then
        Timing.draw()
    elseif tab_index == 3 then
        local previous_grid_size = Settings.GridSize

        Settings.active_style_index = Mupen_lua_ugui.combobox({
            uid = 1,
            is_enabled = true,
            rectangle = grid_rect(0, 0, 4, 1),
            items = {
                "Windows 10",
                "Windows 11",
                "Windows 10 Dark",
                "Windows 7",
            },
            selected_index = Settings.active_style_index,
        })
        Mupen_lua_ugui_ext.apply_nineslice(Settings.styles[Settings.active_style_index])
        Settings.GridSize = Mupen_lua_ugui.spinner({
            uid = 100,
            is_enabled = true,
            rectangle = grid_rect(0, 1, 4, 1),
            value = Settings.GridSize,
            is_horizontal = false,
            minimum_value = -128,
            maximum_value = 128,
        })
        Settings.GridGap = Mupen_lua_ugui.spinner({
            uid = 200,
            is_enabled = true,
            rectangle = grid_rect(4, 1, 4, 1),
            value = Settings.GridGap,
            is_horizontal = false,
            minimum_value = 0,
            maximum_value = 20,
        })
        Mupen_lua_ugui.stylers.windows_10.font_name = Mupen_lua_ugui.textbox({
            uid = 300,
            is_enabled = true,
            rectangle = grid_rect(0, 2, 4, 1),
            text = Mupen_lua_ugui.stylers.windows_10.font_name
        })
        Mupen_lua_ugui.stylers.windows_10.font_size = Mupen_lua_ugui.spinner({
            uid = 400,
            is_enabled = true,
            rectangle = grid_rect(4, 2, 4, 1),
            value = Mupen_lua_ugui.stylers.windows_10.font_size,
            is_horizontal = false,
            minimum_value = 0,
            maximum_value = 28,
        })
        if not (Settings.GridSize == previous_grid_size) then
            -- we cant resize the screen while drawing, as it nukes the d2d context and crashes the emu
            -- we need to do it **on the ui thread**, outside of drawing ops

            -- not possible because everything's called from random threads lol
            -- :(
        end
    else
        print('what')
    end



    tab_index = Mupen_lua_ugui.carrousel_button({
        uid = 420,
        is_enabled = true,
        rectangle = grid_rect(0, 16, 8, 1),
        items = tabs,
        selected_index = tab_index,
    })

    Mupen_lua_ugui.end_frame()
end

function close()
    Drawing.UnResizeScreen()
end

emu.atinput(main)
emu.atupdatescreen(drawing)
emu.atstop(close)
if emu.atloadstate then
    emu.atreset(Drawing.resizeScreen, false)
else
    print("update ur mupen")
end

emu.atwindowmessage(function(a, b, c, d)
    Input.at_window_message(a, b, c, d)
end)
