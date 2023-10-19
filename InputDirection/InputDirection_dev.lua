-- Input Direction lua:
-- Author: MKDasher
-- Hacker: Eddio0141
-- Special thanks to Pannenkoek2012 and Peter Fedak for angle calculation support.
-- Also thanks to MKDasher to making the code very clean
-- Other contributors:
--	Madghostek, Xander, galoomba, ShadoXFM, Lemon, Manama, tjk, Aurumaker72

folder = debug.getinfo(1).source:sub(2):match("(.*\\)")
local tabs_path = folder .. "tabs\\"
local scripts_path = folder .. "InputDirection_dev\\"

dofile(folder .. "mupen-lua-ugui.lua")
dofile(folder .. "mupen-lua-ugui-ext.lua")
dofile(scripts_path .. "Settings.lua")
dofile(scripts_path .. "Drawing.lua")
dofile(scripts_path .. "Memory.lua")
dofile(scripts_path .. "Joypad.lua")
dofile(scripts_path .. "Angles.lua")
dofile(scripts_path .. "Engine.lua")
dofile(scripts_path .. "Buttons.lua")
dofile(scripts_path .. "Program.lua")
dofile(scripts_path .. "MoreMaths.lua")
dofile(scripts_path .. "Actions.lua")
dofile(scripts_path .. "Swimming.lua")
dofile(scripts_path .. "RNGToIndex.lua")
dofile(scripts_path .. "IndexToRNG.lua")
dofile(scripts_path .. "recordghost.lua")
dofile(scripts_path .. "VarWatch.lua")

local i_tabs = {
    {
        text = "TAS",
        code = dofile(tabs_path .. "TAS.lua")
    },
    {
        text = "Timer",
        code = dofile(tabs_path .. "Timer.lua")
    },
    {
        text = "RNG",
        code = dofile(tabs_path .. "RNG.lua")
    },
    {
        text = "Settings",
        code = dofile(tabs_path .. "Settings.lua")
    }
}
local function get_flat_tabs()
    local t = {}
    for i = 1, #i_tabs, 1 do
        t[i] = i_tabs[i].text
    end
    return t
end

local current_tab_index = 1
local mouse_wheel = 0

Settings.create_styles()
Mupen_lua_ugui_ext.apply_nineslice(Settings.styles[Settings.active_style_index])
Drawing.size_up()

function at_input()
    Program.new_frame()
    Program.main()
    i_tabs[current_tab_index].code.update()
    Program.rngSetter()
    Joypad.send()
    Swimming.swim()
    Ghost.main()
end

function at_update_screen()
    local keys = input.get()
    Mupen_lua_ugui.begin_frame({
        mouse_position = {
            x = keys.xmouse,
            y = keys.ymouse,
        },
        wheel = mouse_wheel,
        is_primary_down = keys.leftclick,
        held_keys = keys,
    })
    mouse_wheel = 0

    BreitbandGraphics.fill_rectangle({
        x = Drawing.initial_size.width,
        y = 0,
        width = Drawing.size.width - Drawing.initial_size.width,
        height = Drawing.size.height
    }, Settings.styles[Settings.active_style_index].background_color)

    i_tabs[current_tab_index].code.draw()

    current_tab_index = Mupen_lua_ugui.carrousel_button({
        uid = 420,
        is_enabled = true,
        rectangle = grid_rect(0, 16, 8, 1),
        items = get_flat_tabs(),
        selected_index = current_tab_index,
    })

    Mupen_lua_ugui.end_frame()
end

-- run 2 fake updates pass to get everything to pull itself together (UpdatePrevPos)
at_input()
at_input()

emu.atinput(at_input)
emu.atupdatescreen(at_update_screen)

emu.atstop(function()
    Drawing.size_down()
end)

emu.atreset(Drawing.size_up)

emu.atwindowmessage(function(hwnd, msg_id, wparam, lparam)
    if msg_id == 522 then                         -- WM_MOUSEWHEEL
        -- high word (most significant 16 bits) is scroll rotation in multiples of WHEEL_DELTA (120)
        local scroll = math.floor(wparam / 65536) --(wparam & 0xFFFF0000) >> 16
        if scroll == 120 then
            mouse_wheel = 1
        elseif scroll == 65416 then -- 65536 - 120
            mouse_wheel = -1
        end
    end
end)
