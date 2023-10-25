Grind = {}

-- written by aurum baker at 2am while caffeinated
-- maybe not best quality and stability
local tries = 0
local falling = false


local function get_left_inputs()
    local result = Engine.inputsForAngle(Memory.current.mario_facing_yaw + 32768 / Settings.grind_divisor)
    return {
        X = result.X,
        Y = result.Y,
    }
end

local function get_right_inputs()
    local result = Engine.inputsForAngle(Memory.current.mario_facing_yaw - 32768 / Settings.grind_divisor)
    return {
        X = result.X,
        Y = result.Y,
    }
end

Grind.update = function()
    if not Settings.grind then
        return
    end

    if Memory.current.mario_action == 0x00880456 then
        if falling then
            falling = false
            tries = 0
            -- savestate.savefile("grind.st")
            print("one cycle, now sliding")
        end
        tries = tries + 1
        local inputs = Settings.grind_left and get_right_inputs() or get_left_inputs()
        Joypad.set("X", inputs.X + tries)
        Joypad.set("Y", inputs.Y + tries)
        Joypad.set("B", true)
    end

    if Memory.current.mario_action == 0x0100088C then
        if not falling then
            falling = true
            tries = 0
            -- savestate.savefile("grind.st")
            print("one cycle, now falling")
        end
        tries = tries + 1
        local inputs = Settings.grind_left and get_left_inputs() or get_right_inputs()
        Joypad.set("X", inputs.X + tries)
        Joypad.set("Y", inputs.Y + tries)
        Joypad.set("B", true)
    end
end

Grind.start = function()
    tries = 0
    falling = Memory.current.mario_action == 0x0100088C
    -- savestate.savefile("grind.st")
    print("starting grind")
end
