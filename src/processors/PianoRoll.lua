return {
    process = function(input)
        local override = CurrentPianoRollOverride()
        if override and override.enable_engine then
            TASState = override
            return override.joy
        else
            TASState = DefaultTASState
            return input
        end
    end
}
