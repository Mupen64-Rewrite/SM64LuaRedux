Framewalk = {}


function Framewalk.update()
    if not Settings.framewalk then
        return
    end

    -- walking/hold walking action means 0-input joystick override
    if Memory.current.mario_action == 0x04000440 or Memory.current.mario_action == 0x00000442 then
        local input = joypad.get(Settings.controller_index)
        input["X"] = 0
        input["Y"] = 0
		joypad.set(Settings.controller_index, input)
    end
end