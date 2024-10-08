return {
    process = function(input)
        if TASState.movement_mode == Settings.movement_modes.disabled then
            return input
        end
        Memory.update()
        local result = Engine.inputsForAngle(TASState.goal_angle, input)
        if TASState.goal_mag then
            Engine.scaleInputsForMagnitude(result, TASState.goal_mag, TASState.high_magnitude)
        end

        input.X = result.X
        input.Y = result.Y
        return input
    end
}
