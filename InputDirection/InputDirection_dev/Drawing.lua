Drawing = {
    WIDTH_OFFSET = 222,
    Screen = {
        Height = 0,
        Width = 0
    }
}

function Drawing.resizeScreen()
    screen = wgui.info()
    Drawing.Screen.Height = screen.height
    width10 = screen.width % 10
    if width10 == 0 or width10 == 4 or width10 == 8 then
        Drawing.Screen.Width = screen.width
        wgui.resize(screen.width + Drawing.WIDTH_OFFSET, screen.height)
    else
        Drawing.Screen.Width = screen.width - Drawing.WIDTH_OFFSET
    end
end

function Drawing.UnResizeScreen()
    wgui.resize(Drawing.Screen.Width, Drawing.Screen.Height)
end

function Drawing.paint()
    

    for i = 1, #Buttons, 1 do
        local button = Buttons[i]
        if button.type == ButtonType.button then
            local previous = button.pressed()

            local pressed = Mupen_lua_ugui.toggle_button({
                uid = i,
                is_enabled = button.enabled(),
                rectangle = {
                    x = button.box[1],
                    y = button.box[2],
                    width = button.box[3],
                    height = button.box[4]
                },
                text = button.text,
                is_checked = previous
            })
            if not (pressed == previous) then
                button:onclick()
                Settings.Layout.TextArea.selectedItem = 0
            end
        elseif button.type == ButtonType.textArea then
            local value = button.value()



            local previous_active_control_id = Mupen_lua_ugui.active_control_uid
            if button.editing() and button.enabled() then
                Mupen_lua_ugui.control_data[i] = {
                    caret_index = Settings.Layout.TextArea.selectedChar,
                    selection_start = Settings.Layout.TextArea.selectedChar,
                    selection_end = Settings.Layout.TextArea.selectedChar + 1,
                }
                Mupen_lua_ugui.active_control_uid = i
            else
                Mupen_lua_ugui.control_data[i] = {
                    caret_index = 0,
                    selection_start = nil,
                    selection_end = nil,
                }
            end

            Mupen_lua_ugui.stylers.windows_10.draw_textbox({
                uid = i,
                is_enabled = button.enabled(),
                rectangle = {
                    x = button.box[1],
                    y = button.box[2],
                    width = button.box[3],
                    height = button.box[4]
                },
                text = value and string.format("%0" .. tostring(button.inputSize) .. "d", value) or
                    string.rep('-', button.inputSize),
            })

            Mupen_lua_ugui.active_control_uid = previous_active_control_id
        end
    end

    Drawing.drawAnalogStick(Drawing.Screen.Width + Drawing.WIDTH_OFFSET / 3 - 5, 209)
    wgui.setcolor(BreitbandGraphics.color_to_hex(ustyle.foreground_color))
    wgui.setfont(10, "Arial", "")
    wgui.text(Drawing.Screen.Width + 149, 146, "Magnitude")
    Drawing.drawAngles(Drawing.Screen.Width + 5, 276)
    Drawing.drawMiscData(Drawing.Screen.Width + 5, 304)
end

function Drawing.drawAngles(x, y)
    if Settings.ShowEffectiveAngles then
        wgui.text(x, y, "Yaw (Facing): " .. Engine.getEffectiveAngle(Memory.Mario.FacingYaw))
        wgui.text(x, y + 14, "Yaw (Intended): " .. Engine.getEffectiveAngle(Memory.Mario.IntendedYaw))
        wgui.text(x + 140, y, "O: " .. (Engine.getEffectiveAngle(Memory.Mario.FacingYaw) + 32768) % 65536)        --wgui.text(x, y + 30, "Opposite (Facing): " ..  (Engine.getEffectiveAngle(Memory.Mario.FacingYaw) + 32768) % 65536)
        wgui.text(x + 140, y + 14, "O: " .. (Engine.getEffectiveAngle(Memory.Mario.IntendedYaw) + 32768) % 65536) --wgui.text(x, y + 45, "Opposite (Intended): " ..  (Engine.getEffectiveAngle(Memory.Mario.IntendedYaw) + 32768) % 65536)
    else
        wgui.text(x, y, "Yaw (Facing): " .. Memory.Mario.FacingYaw)
        wgui.text(x, y + 14, "Yaw (Intended): " .. Memory.Mario.IntendedYaw)
        wgui.text(x + 140, y, "O: " .. (Memory.Mario.FacingYaw + 32768) % 65536)        --wgui.text(x + 45, y, "Opposite (Facing): " ..  (Memory.Mario.FacingYaw + 32768) % 65536)
        wgui.text(x + 140, y + 14, "O: " .. (Memory.Mario.IntendedYaw + 32768) % 65536) --wgui.text(x, y + 45, "Opposite (Intended): " ..  (Memory.Mario.IntendedYaw + 32768) % 65536)
    end
end

function Drawing.drawTextArea(x, y, width, length, text, enabled, editing)
    wgui.setcolor(Settings.Colors.Text)
    wgui.setfont(16, "Courier", "b")
    if (editing) then
        wgui.setbrush(Settings.Colors.InputField.Editing)
        if (Settings.Colors.InputField.EditingText) then wgui.setcolor(Settings.Colors.InputField.EditingText) end
    elseif (enabled) then
        wgui.setbrush(Settings.Colors.InputField.Enabled)
    else
        wgui.setbrush(Settings.Colors.InputField.Disabled)
    end
    wgui.setpen(Settings.Colors.InputField.OutsideOutline)
    wgui.rect(x + 1, y + 1, x + width + 1, y + length + 1)
    wgui.setpen(Settings.Colors.InputField.Outline)
    wgui.line(x + 2, y + 2, x + 2, y + length)
    wgui.line(x + 2, y + 2, x + width, y + 2)
    if (editing) then
        selectedChar = Settings.Layout.TextArea.selectedChar
        Settings.Layout.TextArea.blinkTimer = (Settings.Layout.TextArea.blinkTimer + 1) %
            Settings.Layout.TextArea.blinkRate
        if (Settings.Layout.TextArea.blinkTimer == 0) then
            Settings.Layout.TextArea.showUnderscore = not Settings.Layout.TextArea.showUnderscore
        end
        if (Settings.Layout.TextArea.showUnderscore) then
            text = string.sub(text, 1, selectedChar - 1) .. "_" .. string.sub(text, selectedChar + 1, string.len(text))
        end
    end
    wgui.text(x + width / 2 - 6.5 * string.len(text), y + length / 2 - 8, text)
end

function Drawing.drawAnalogStick(x, y)
    Mupen_lua_ugui.joystick({
        uid = 10000,
        is_enabled = true,
        rectangle = {
            x = x - 64,
            y = y - 64,
            width = 128,
            height = 128
        },
        position = {
            x = MoreMaths.Remap(Joypad.input.X, -128, 128, 0, 1),
            y = MoreMaths.Remap(-Joypad.input.Y, -128, 128, 0, 1),
        }
    })
    if Settings.goalMag and Settings.goalMag < 127 then
        local r = Settings.goalMag + 6
        BreitbandGraphics.renderers.d2d.draw_ellipse({
            x = x - r / 2,
            y = y - r / 2,
            width = r,
            height = r
        }, BreitbandGraphics.colors.red, 2)
    end
    wgui.setcolor(BreitbandGraphics.color_to_hex(ustyle.foreground_color))
    wgui.setfont(10, "Courier", "")
    local stick_y = Joypad.input.Y == 0 and "0" or -Joypad.input.Y
    wgui.text(x + 102 - 2.5 * (string.len(Joypad.input.X)), y - 16, "x:" .. Joypad.input.X)
    wgui.text(x + 102 - 2.5 * (string.len(stick_y)), y - 1, "y:" .. stick_y)
end

function Drawing.drawMiscData(x, y)
    speed = 0
    if Memory.Mario.HSpeed ~= 0 then
        speed = MoreMaths.DecodeDecToFloat(Memory.Mario.HSpeed)
    end
    wgui.text(x, y, "H Spd: " .. MoreMaths.Round(speed, 5))

    wgui.text(x, y + 42, "Spd Efficiency: " .. Engine.GetSpeedEfficiency() .. "%")

    speed = 0
    if Memory.Mario.VSpeed > 0 then
        speed = MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.VSpeed), 6)
    end
    wgui.text(x, y + 56, "Y Spd: " .. speed)

    wgui.text(x, y + 14, "H Sliding Spd: " .. MoreMaths.Round(Engine.GetHSlidingSpeed(), 6))

    wgui.text(x, y + 70, "Mario X: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.X), 2), 6)
    wgui.text(x, y + 84, "Mario Y: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Y), 2), 6)
    wgui.text(x, y + 98, "Mario Z: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Z), 2), 6)

    wgui.text(x, y + 28, "XZ Movement: " .. MoreMaths.Round(Engine.GetDistMoved(), 6))

    wgui.text(x, y + 111, "Action: " .. Engine.GetCurrentAction())

    wgui.text(x + 170, 50 + y, "E: " .. Settings.Layout.Button.strain_button.arctanexp)
    wgui.text(x + 170, 50 + y + 13, "R: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctanr, 5))
    wgui.text(x + 170, 50 + y + 26, "D: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctand, 5))
    wgui.text(x + 170, 50 + y + 39, "N: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctann, 2))
    wgui.text(x + 170, 50 + y + 53, "S: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctanstart + 1, 2))

    wgui.text(x, y + 125, "RNG Value: " .. Memory.RNGValue)
    wgui.text(x, y + 139, "RNG Index: " .. get_index(Memory.RNGValue))

    distmoved = Engine.GetTotalDistMoved()
    if (Settings.Layout.Button.dist_button.enabled == false) then
        distmoved = Settings.Layout.Button.dist_button.dist_moved_save
    end
    wgui.text(x, y + 152, "Moved Dist: " .. distmoved)
end
