local AIR_HIT_WALL = 0x000008A7
return {
    process = function(input)
        if not Settings.auto_firsties then
            return input
        end

        if Memory.current.mario_action == AIR_HIT_WALL then
            input["A"] = 1
        end
        return input
    end
}
