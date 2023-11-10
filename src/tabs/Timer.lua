local transitionTimes = {}
transitionTimes[0] = 2
transitionTimes[8] = 2
transitionTimes[10] = 2
transitionTimes[16] = 2
transitionTimes[18] = 2
local VIs = 0
local PredictedVIs = 0
local State = 0
local StartVI = 0
local is_control_automatic = true
local curVI = 0
local function reset()
    State = 0
    VIs = 0
end
local function start()
    State = 1
    VIs = 2
    StartVI = curVI
end
local function stop()
    State = 2
end
local function timerAutoDetect()
    if ((State == 1) and ((Memory.current.mario_object_effective == 0) or (curVI < StartVI))) then -- Reset timer on star select, or if state before start time is loaded
        reset()
    end
    if ((State ~= 1) and (Memory.current.camera_transition_progress ~= nil) and (Memory.current.mario_object_effective ~= 0) and (transitionTimes[Memory.current.camera_transition_type] == Memory.current.camera_transition_progress) and (Memory.current.mario_action ~= 0x1300)) then -- Start timer on fade in
        start()
    end
    if ((Memory.current.mario_animation == 179) or (Memory.current.mario_animation == 205)) then -- Stop timer on star dance
        if (State == 1) then                                                     -- Stop timer on star dance
            if (PredictedVIs ~= curVI) then                                      -- fix mismatched time if there was lag as the time stops
                VIs = curVI - StartVI
            end
            if ((Memory.current.mario_action_arg & 1) == 1) then -- Special state if a non-exit star is collected
                State = 3
            else
                stop()
            end
        end
    elseif (State == 3) then -- Reactivate timer after dance
        State = 1
    end
end

local function get_frame_text()
    local decimals = (VIs * 1000 // 60 + 5) // 10 % 100
    if (VIs < 3600) then
        return string.format("%02d.%02d", VIs // 60, decimals)
    elseif (VIs < 360000) then
        return string.format("%02d:%02d.%02d", VIs // 3600, (VIs % 3600) // 60, decimals)
    else
        return "99:59.99"
    end
end

return {
    name = "Timer",
    update = function()
        curVI = emu.framecount()
        if (State == 1) then
            if (curVI <= StartVI) then
                VIs = 0
            else
                PredictedVIs = curVI + 2 -- assume it will increment by 2, fix it on the next frame if there's lag
                VIs = PredictedVIs - StartVI
            end
        end
        if (is_control_automatic) then
            timerAutoDetect()
        end
    end,
    draw = function()
        if Mupen_lua_ugui.button({
                uid = 2,
                
                rectangle = grid_rect(0, 0, 2, 1),
                text = "Start"
            }) then
            start()
        end
        if Mupen_lua_ugui.button({
                uid = 3,
                
                rectangle = grid_rect(2, 0, 2, 1),
                text = "Stop"
            }) then
            stop()
        end
        if Mupen_lua_ugui.button({
                uid = 4,
                
                rectangle = grid_rect(4, 0, 2, 1),
                text = "Reset"
            }) then
            reset()
        end
        is_control_automatic = Mupen_lua_ugui.toggle_button({
            uid = 5,
            rectangle = grid_rect(6, 0, 2, 1),
            text = is_control_automatic and "Auto" or "Manual",
            is_checked = is_control_automatic
        })
        Mupen_lua_ugui.joystick({
            uid = 1,
            
            rectangle = grid_rect(2, 1, 4, 4),
            position = {
                x = Mupen_lua_ugui.internal.remap(Joypad.input.X, -128, 128, 0, 1),
                y = Mupen_lua_ugui.internal.remap(-Joypad.input.Y, -128, 128, 0, 1),
            }
        })

        BreitbandGraphics.draw_text(grid_rect(2, 5, 4, 1), "center", "center", {},
            BreitbandGraphics.invert_color(Settings.styles[Settings.active_style_index].theme.background_color), 24,
            "Consolas",
            get_frame_text())

        Mupen_lua_ugui.toggle_button({
            uid = 3,
            
            rectangle = grid_rect(4, 6, 2),
            text = "A",
            is_checked = Joypad.input.A
        })

        Mupen_lua_ugui.toggle_button({
            uid = 4,
            
            rectangle = grid_rect(2, 6, 2),
            text = "B",
            is_checked = Joypad.input.B
        })

        Mupen_lua_ugui.toggle_button({
            uid = 5,
            
            rectangle = grid_rect(3, 8, 1),
            text = "Z",
            is_checked = Joypad.input.Z
        })

        Mupen_lua_ugui.toggle_button({
            uid = 6,
            
            rectangle = grid_rect(4, 8, 1),
            text = "S",
            is_checked = Joypad.input.start
        })

        Mupen_lua_ugui.toggle_button({
            uid = 7,
            
            rectangle = grid_rect(1, 7),
            text = "L",
            is_checked = Joypad.input.L
        })

        Mupen_lua_ugui.toggle_button({
            uid = 8,
            
            rectangle = grid_rect(6, 7),
            text = "R",
            is_checked = Joypad.input.R
        })

        Mupen_lua_ugui.toggle_button({
            uid = 9,
            
            rectangle = grid_rect(0, 7),
            text = "C<",
            is_checked = Joypad.input.Cleft
        })

        Mupen_lua_ugui.toggle_button({
            uid = 10,
            
            rectangle = grid_rect(2, 7),
            text = "C>",
            is_checked = Joypad.input.Cright
        })

        Mupen_lua_ugui.toggle_button({
            uid = 11,
            
            rectangle = grid_rect(1, 6),
            text = "C^",
            is_checked = Joypad.input.Cup
        })

        Mupen_lua_ugui.toggle_button({
            uid = 12,
            
            rectangle = grid_rect(1, 8),
            text = "Cv",
            is_checked = Joypad.input.Cdown
        })

        Mupen_lua_ugui.toggle_button({
            uid = 13,
            
            rectangle = grid_rect(5, 7),
            text = "D<",
            is_checked = Joypad.input.left
        })

        Mupen_lua_ugui.toggle_button({
            uid = 14,
            
            rectangle = grid_rect(7, 7),
            text = "D>",
            is_checked = Joypad.input.right
        })

        Mupen_lua_ugui.toggle_button({
            uid = 15,
            
            rectangle = grid_rect(6, 6),
            text = "D^",
            is_checked = Joypad.input.up
        })

        Mupen_lua_ugui.toggle_button({
            uid = 16,
            
            rectangle = grid_rect(6, 8),
            text = "Dv",
            is_checked = Joypad.input.down
        })
    end
}
