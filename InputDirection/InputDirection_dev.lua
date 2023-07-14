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

PATH = debug.getinfo(1).source:sub(2):match("(.*\\)") .. "\\InputDirection_dev\\"
CURRENT_PATH = debug.getinfo(1).source:sub(2):match("(.*\\)") .. "\\"

dofile(CURRENT_PATH .. "mupen-lua-ugui.lua")
dofile(CURRENT_PATH .. "nineslice.lua")
dofile(PATH .. "Drawing.lua")
Drawing.resizeScreen()

dofile(PATH .. "Memory.lua")
dofile(PATH .. "Settings.lua")
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

Settings.ShowEffectiveAngles = false -- show angles floored to the nearest multiple of 16
local tabs = {
    "TAS",
    "Settings"
}
local tab_index = 1
ustyle = {}

Program.initFrame()
Memory.UpdatePrevPos()
function main()
    Program.initFrame()
    Program.main()
    Program.rngSetter()
    Joypad.send()
    Swimming.swim("A")

    if recording_ghost then
        Ghost.main()
    end
end

function drawing()
    section_name_path = folder('InputDirection_dev.lua') .. 'res\\' .. Settings.VisualStyles[Settings.VisualStyleIndex]
    if not ustyles[section_name_path .. '.ustyles'] then
        ustyles[section_name_path .. '.ustyles'] = parse_ustyles(section_name_path .. '.ustyles')
    end
    
    ustyle = ustyles[section_name_path .. '.ustyles']

    for key, _ in pairs(Mupen_lua_ugui.stylers.windows_10.raised_frame_text_colors) do
        Mupen_lua_ugui.stylers.windows_10.raised_frame_text_colors[key] = ustyle.raised_frame_text_colors[key]
    end
    for key, _ in pairs(Mupen_lua_ugui.stylers.windows_10.edit_frame_text_colors) do
        Mupen_lua_ugui.stylers.windows_10.edit_frame_text_colors[key] = ustyle.edit_frame_text_colors[key]
    end

    local keys = input.get()
    Mupen_lua_ugui.begin_frame(BreitbandGraphics.renderers.d2d, Mupen_lua_ugui.stylers.windows_10, {
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

    BreitbandGraphics.renderers.d2d.fill_rectangle({
        x = Drawing.Screen.Width,
        y = 0,
        width = Drawing.Screen.Width + Drawing.WIDTH_OFFSET,
        height = Drawing.Screen.Height - 20
    }, ustyles[section_name_path .. '.ustyles'].background_color)

    if tab_index == 1 then
        Drawing.paint()
        Input.update()
    elseif tab_index == 2 then
        Settings.VisualStyleIndex = Mupen_lua_ugui.combobox({
            uid = 12345678,
            is_enabled = true,
            rectangle = {
                x = Drawing.Screen.Width + 5,
                y = 5,
                width = 150,
                height = 23,
            },
            items = Settings.VisualStyles,
            selected_index = Settings.VisualStyleIndex,
        })
    else
        print('what')
    end



    tab_index = Mupen_lua_ugui.carrousel_button({
        uid = 420,
        is_enabled = true,
        rectangle = {
            x = Drawing.Screen.Width + 5,
            y = 555,
            width = Drawing.WIDTH_OFFSET - 10,
            height = 23,
        },
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
    emu.atloadstate(drawing, false)
    emu.atreset(Drawing.resizeScreen, false)
else
    print("update ur mupen")
end
