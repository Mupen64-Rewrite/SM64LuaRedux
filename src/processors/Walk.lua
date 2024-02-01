return {
    process = function(input)
        if Settings.movement_mode == Settings.movement_modes.disabled then
            return input
        end

        local result = Engine.inputsForAngle(Settings.goal_angle, input)
        if Settings.goal_mag then
            Engine.scaleInputsForMagnitude(result, Settings.goal_mag, Settings.high_magnitude)
        end

        input.X = result.X
        input.Y = result.Y
        return input
    end
}
