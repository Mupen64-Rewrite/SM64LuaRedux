local transitionTimes = {}
transitionTimes[0] = 2
transitionTimes[8] = 2
transitionTimes[10] = 2
transitionTimes[16] = 2
transitionTimes[18] = 2
local VIs = 0;
local PredictedVIs = 0;
local State = 0;
local StartVI = 0;
local is_control_automatic = true;
local is_started = false;
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
    if ((State == 1) and ((Memory.Mario.EffectiveMarioObject == 0) or (curVI < StartVI))) then -- Reset timer on star select, or if state before start time is loaded
        reset()
    end
    if ((State ~= 1) and (Memory.Camera.Transition.Progress ~= nil) and (Memory.Mario.EffectiveMarioObject ~= 0) and (transitionTimes[Memory.Camera.Transition.Type] == Memory.Camera.Transition.Progress) and (Memory.Mario.Action ~= 0x1300)) then -- Start timer on fade in
        start()
    end
    if ((Memory.Mario.Animation == 179) or (Memory.Mario.Animation == 205)) then -- Stop timer on star dance
        if (State == 1) then                                                     -- Stop timer on star dance
            if (PredictedVIs ~= curVI) then                                      -- fix mismatched time if there was lag as the time stops
                VIs = curVI - StartVI
            end
            if ((Memory.Mario.ActionArg & 1) == 1) then -- Special state if a non-exit star is collected
                State = 3
            else
                stop()
            end
        end
    elseif (State == 3) then -- Reactivate timer after dance
        State = 1
    end
end

Timing = {
    get_frame_text = function()
        local decimals = (VIs * 1000 // 60 + 5) // 10 % 100
        if (VIs < 3600) then
            return string.format("%02d.%02d", VIs // 60, decimals)
        elseif (VIs < 360000) then
            return string.format("%02d:%02d.%02d", VIs // 3600, (VIs % 3600) // 60, decimals)
        else
            return "99:59.99"
        end
    end,
    update = function()
        curVI = emu.framecount()
        if (PredictedVIs % 2 ~= curVI % 2) then print(curVI) end
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
                is_enabled = true,
                rectangle = grid_rect(0, 0, 2, 1),
                text = "Start"
            }) then
            start()
        end
        if Mupen_lua_ugui.button({
                uid = 3,
                is_enabled = true,
                rectangle = grid_rect(2, 0, 2, 1),
                text = "Stop"
            }) then
            stop()
        end
        if Mupen_lua_ugui.button({
                uid = 4,
                is_enabled = true,
                rectangle = grid_rect(4, 0, 2, 1),
                text = "Reset"
            }) then
            reset()
        end
        Timing.is_control_automatic = Mupen_lua_ugui.toggle_button({
            uid = 5,
            is_enabled = true,
            rectangle = grid_rect(6, 0, 2, 1),
            text = Timing.is_control_automatic and "Automatic" or "Manual",
            is_checked = Timing.is_control_automatic
        })
        Mupen_lua_ugui.joystick({
            uid = 1,
            is_enabled = true,
            rectangle = grid_rect(2, 1, 4, 4),
            position = {
                x = MoreMaths.Remap(Joypad.input.X, -128, 128, 0, 1),
                y = MoreMaths.Remap(-Joypad.input.Y, -128, 128, 0, 1),
            }
        })

        BreitbandGraphics.draw_text(grid_rect(2, 5, 4, 1), "center", "center", {},
            BreitbandGraphics.invert_color(Settings.styles[Settings.active_style_index].background_color), 24, "Consolas",
            Timing.get_frame_text())
    end
}
