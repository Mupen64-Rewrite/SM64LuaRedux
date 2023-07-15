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
dofile(CURRENT_PATH .. "mupen-lua-ugui-ext.lua")
dofile(CURRENT_PATH .. "nineslice.lua")
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
        local previous_grid_size = Settings.GridSize

        Settings.VisualStyleIndex = Mupen_lua_ugui.combobox({
            uid = 1,
            is_enabled = true,
            rectangle = grid_rect(0, 0, 4, 1),
            items = Settings.VisualStyles,
            selected_index = Settings.VisualStyleIndex,
        })
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
