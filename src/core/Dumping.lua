Dumping = {
    data = {}
}

Dumping.start = function()
    Settings.dump_enabled = true
    Settings.dump_start_frame = emu.inputcount()
    Dumping.data = {}
    print("Dumping started")
end

Dumping.stop = function()
    Settings.dump_enabled = false

    local path = "dump.json"
    local serialized = json.encode(Dumping.data)
    local file = io.open(path, "w")
    file:write(serialized)
    io.close(file)

    print(string.format("Dumped %d frames to %s", #Dumping.data, path))
end

Dumping.update = function()
    if not Settings.dump_enabled then
        return
    end

    if (Memory.current.mario_action & 0x100) ~= 0 then
        print("Skipping non-input frame while dumping")
        return
    end

    Dumping.data[#Dumping.data + 1] = {
        frame = #Dumping.data,
        input = ugui.internal.deep_clone(Joypad.input),
        memory = ugui.internal.deep_clone(Memory.current),
        varwatch = ugui.internal.deep_clone(VarWatch.processed_values),
    }
end
