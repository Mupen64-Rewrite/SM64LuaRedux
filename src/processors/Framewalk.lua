return {
    process = function(input)
        if not TASState.framewalk then
            return input
        end

        -- walking/hold walking action means 0-input joystick override
        if Memory.current.mario_action == 0x04000440 or Memory.current.mario_action == 0x00000442 then
            input.X = 0
            input.Y = 0
        end

        return input
    end
}
