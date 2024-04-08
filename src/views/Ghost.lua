return {
    name = "Ghost",
    draw = function()
        if ugui.button({
                uid = 5,
                
                rectangle = grid_rect(0, 0, 4, 1),
                text = Ghost.is_recording and "Stop Recording" or "Start Recording",
            }) then
            Ghost.toggle_recording()
        end
    end
}
