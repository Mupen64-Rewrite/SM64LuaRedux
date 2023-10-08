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

local mouse_wheel = 0
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
dofile(PATH .. "RngPage.lua")
dofile(PATH .. "VarWatch.lua")

Settings.ShowEffectiveAngles = false -- show angles floored to the nearest multiple of 16
local tabs = {
    "TAS",
    "Timing",
    "Settings",
    "RNG",
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
            wheel = mouse_wheel
        },
        keyboard = {
            held_keys = keys,
        },
    })
    mouse_wheel = 0

    Memory.Refresh()

    BreitbandGraphics.fill_rectangle({
        x = Drawing.Screen.Width,
        y = 0,
        width = Drawing.Screen.Width + Drawing.WIDTH_OFFSET,
        height = Drawing.Screen.Height - 20
    }, Settings.styles[Settings.active_style_index].background_color)

    if tab_index == 1 then
        Drawing.paint()
        Mupen_lua_ugui.listbox({
            uid = 13377331,
            is_enabled = true,
            rectangle = grid_rect(0, 8, 8, 7),
            selected_index = nil,
            items = VarWatch.get_values(),
        })
        Input.update()
    elseif tab_index == 2 then
        Timing.draw()
    elseif tab_index == 3 then
        Settings.draw()
    elseif tab_index == 4 then
        RngPage.draw()
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

emu.atwindowmessage(function(hwnd, msg_id, wparam, lparam)
    if msg_id == 522 then                         -- WM_MOUSEWHEEL
        -- high word (most significant 16 bits) is scroll rotation in multiples of WHEEL_DELTA (120)
        local scroll = math.floor(wparam / 65536) --(wparam & 0xFFFF0000) >> 16
        if scroll == 120 then
            Input.arrowCheck("up")
            mouse_wheel = 1
        elseif scroll == 65416 then -- 65536 - 120
            Input.arrowCheck("down")
            mouse_wheel = -1
        end
    end
end)
