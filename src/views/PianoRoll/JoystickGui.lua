local UID = dofile(views_path .. "PianoRoll/UID.lua")

local function AnyEntries(table) for _ in pairs(table) do return true end return false end

local function AtanControls(draw, pianoRoll, newValues, top)
    local newAtan = ugui.toggle_button({
        uid = UID.AtanStrain,
        rectangle = grid_rect(0, top, 1, 0.5),
        text='Atan',
        is_checked = newValues.atan_strain
    })
    if pianoRoll.selection ~= nil and newAtan and not newValues.atan_strain then
        newValues.atan_start = pianoRoll.selection:min()
        newValues.atan_n = pianoRoll.selection:max() - pianoRoll.selection:min() + 1
        newValues.dyaw = true
        newValues.movement_mode = MovementModes.match_angle
    end
    newValues.atan_strain = newAtan
    if newValues.movement_mode ~= MovementModes.match_angle then
        newValues.atan_strain = false
    end

    draw:text(grid_rect(1, top, 0.5, 0.5), "end", "Qf:")
    local quarterStep = (newValues.atan_n % 1) * 4
    local newQuarterstep = ugui.spinner({
        uid = UID.AtanN,

        rectangle = grid_rect(1.5, top, 1, 0.5),
        value = quarterStep == 0 and 4 or quarterStep,
        minimum_value = 1,
        maximum_value = 4,
    })
    newValues.atan_n = math.ceil(newValues.atan_n - 1) + newQuarterstep / 4

    draw:text(grid_rect(2.5, top, 0.5, 0.5), "end", "D:")
    newValues.atan_d = ugui.spinner({
        uid = UID.AtanD,

        rectangle = grid_rect(3, top, 2, 0.5),
        value = newValues.atan_d,
        minimum_value = -10000,
        maximum_value = 10000,
        increment = math.pow(10, Settings.atan_exp),
    })

    draw:text(grid_rect(5, top, 0.5, 0.5), "end", "E:")
    Settings.atan_exp = ugui.spinner({
        uid = UID.AtanE,

        rectangle = grid_rect(5.5, top, 1, 0.5),
        value = Settings.atan_exp,
        minimum_value = -10,
        maximum_value = 10,
    })
end

local function ControlsForSelected(draw)
    local top = 9

    local pianoRoll = PianoRollContext.AssertedCurrent()

    local newValues = {}
    CloneInto(newValues, TASState)

    local displayPosition = {x = TASState.manual_joystick_x or 0, y = -(TASState.manual_joystick_y or 0)}
    local newPosition = ugui.joystick({
        uid = UID.Joypad,
        rectangle = grid_rect(0, top + 1, 2, 2),
        position = displayPosition,
    })
    if newPosition.x ~= displayPosition.x or newPosition.y ~= displayPosition.y then
        newValues.movement_mode = MovementModes.manual
        newValues.manual_joystick_x = math.min(127, math.floor(newPosition.x + 0.5)) or TASState.manual_joystick_x
        newValues.manual_joystick_y = math.min(127, -math.floor(newPosition.y + 0.5)) or TASState.manual_joystick_y
    end
    local previousThickness = ugui.standard_styler.spinner_button_thickness
    ugui.standard_styler.spinner_button_thickness = 4
    newValues.manual_joystick_x = ugui.spinner({
        uid = UID.JoypadSpinnerX,
        rectangle = grid_rect(0, top + 3, 1, 0.5),
        value = newValues.manual_joystick_x,
        minimum_value = -128,
        maximum_value = 127
    })
    newValues.manual_joystick_y = ugui.spinner({
        uid = UID.JoypadSpinnerY,
        rectangle = grid_rect(1, top + 3, 1, 0.5),
        value = newValues.manual_joystick_y,
        minimum_value = -128,
        maximum_value = 127
    })

    newValues.goal_angle = math.abs(ugui.numberbox({
        uid = UID.GoalAngle,
        is_enabled = newValues.movement_mode == MovementModes.match_angle,
        rectangle = grid_rect(2, top + 2, 2, 1),
        places = 5,
        value = newValues.goal_angle
    }))

    newValues.strain_always = ugui.toggle_button({
        uid = UID.StrainAlways,
        rectangle = grid_rect(2, top + 1, 1.2, 0.5),
        text = 'always',
        is_checked = newValues.strain_always
    })

    newValues.strain_speed_target = ugui.toggle_button({
        uid = UID.StrainSpeedTarget,
        rectangle = grid_rect(3.2, top + 1, 0.8, 0.5),
        text = '.99',
        is_checked = newValues.strain_speed_target
    })

    if ugui.toggle_button({
        uid = UID.StrainLeft,
        rectangle = grid_rect(2, top + 1.5, 1, 0.5),
        text = '<',
        is_checked = newValues.strain_left
    }) then
        newValues.strain_right = false
        newValues.strain_left = true
    else
        newValues.strain_left = false
    end

    if ugui.toggle_button({
        uid = UID.StrainRight,
        rectangle = grid_rect(3, top + 1.5, 1, 0.5),
        text = '>',
        is_checked = newValues.strain_right
    }) then
        newValues.strain_left = false
        newValues.strain_right = true
    else
        newValues.strain_right = false
    end

    if ugui.toggle_button({
        uid = UID.MovementModeManual,
        rectangle = grid_rect(4, top + 1, 1.5, 1),
        text='Manual',
        is_checked = newValues.movement_mode == MovementModes.manual
    }) then
        newValues.movement_mode = MovementModes.manual
    end

    if ugui.toggle_button({
        uid = UID.MovementModeMatchYaw,
        rectangle = grid_rect(5.5, top + 1, 1.5, 1),
        text='Yaw',
        is_checked = newValues.movement_mode == MovementModes.match_yaw
    }) then
        newValues.movement_mode = MovementModes.match_yaw
    end

    if ugui.toggle_button({
        uid = UID.MovementModeMatchAngle,
        rectangle = grid_rect(4, top + 2, 1.5, 1),
        text='Angle',
        is_checked = newValues.movement_mode == MovementModes.match_angle
    }) then
        newValues.movement_mode = MovementModes.match_angle
    end

    if ugui.toggle_button({
        uid = UID.MovementModeReverseAngle,
        rectangle = grid_rect(5.5, top + 2, 1.5, 1),
        text='Reverse',
        is_checked = newValues.movement_mode == MovementModes.reverse_angle
    }) then
        newValues.movement_mode = MovementModes.reverse_angle
    end

    newValues.dyaw = ugui.toggle_button({
        uid = UID.DYaw,
        rectangle = grid_rect(2, top + 3, 1, 0.5),
        text='DYaw',
        is_checked = newValues.dyaw
    })

    if ugui.button({
        uid = UID.SpeedKick,
        rectangle = grid_rect(3, top + 3, 1, 0.5),
        text='Spdk',
    }) then
        newValues.goal_mag = 48
    end

    newValues.goal_mag = ugui.numberbox({
        uid = UID.GoalMag,
        rectangle = grid_rect(4, top + 3, 1, 0.5),
        places = 3,
        value = newValues.goal_mag
    })

    if ugui.button({
        uid = UID.ResetMag,
        rectangle = grid_rect(5, top + 3, 0.5, 0.5),
        text='R',
    }) then
        newValues.goal_mag = 127
    end

    AtanControls(draw, pianoRoll, newValues, top + 4)

    ugui.standard_styler.spinner_button_thickness = previousThickness

    local changes = CloneInto(TASState, newValues)
    local anyChanges = AnyEntries(changes)
    if anyChanges and pianoRoll.selection ~= nil then
        for i = pianoRoll.selection:min(), pianoRoll.selection:max(), 1 do
            CloneInto(PianoRollContext.current.frames[i], changes)
        end
    end
    return anyChanges
end

return {
    Render = ControlsForSelected
}