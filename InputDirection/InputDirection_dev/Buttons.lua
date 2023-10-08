ButtonType = {
    button = 0,
    -- text : button text
    -- box : total size of the button
    textArea = 1
}
function grid(x, y, x_span, y_span)
    if not x_span then
        x_span = 1
    end
    if not y_span then
        y_span = 1
    end

    local base_x = Drawing.Screen.Width + (Settings.GridSize * x)
    local base_y = (Settings.GridSize * y)

    local rect = {
        base_x + Settings.GridGap,
        base_y + Settings.GridGap,
        (Settings.GridSize * x_span) - Settings.GridGap * 2,
        (Settings.GridSize * y_span) - Settings.GridGap * 2,
    }

    if Drawing.Scale > 1 + Drawing.ScaleTolerance then
        -- scaling up, we space everything out but keep dimensions
        rect[2] = rect[2] * Drawing.Scale
    end
    if Drawing.Scale < 1 - Drawing.ScaleTolerance then
        -- scaling down, we squish and compress everything
        rect[1] = (rect[1] * Drawing.Scale) + (Drawing.WIDTH_OFFSET * Drawing.Scale * 0.5)
        rect[2] = rect[2] * Drawing.Scale
        rect[3] = rect[3] * Drawing.Scale
        rect[4] = rect[4] * Drawing.Scale
    end

    return rect
end

function grid_rect(x, y, x_span, y_span)
    local value = grid(x, y, x_span, y_span)
    return {
        x = value[1],
        y = value[2],
        width = value[3],
        height = value[4],
    }
end

recording_ghost = false

local pow = math.pow

local function getDigit(value, length, digit)
    if digit == nil then digit = Settings.Layout.TextArea.selectedChar end
    return math.floor(value / pow(10, length - digit)) % 10
end

local function updateDigit(value, length, digit_value, digit)
    if digit == nil then digit = Settings.Layout.TextArea.selectedChar end
    local old_digit_value = getDigit(value, length, digit)
    local new_value = value + (digit_value - old_digit_value) * pow(10, length - digit)
    local max = pow(10, length)
    return (new_value + max) % max
end

Buttons = {
    {
        name = "ignore y",
        type = ButtonType.button,
        text = "Ignore Y",
        box = function()
            return grid(4, 15, 4, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.dist_button.ignore_y == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.dist_button.ignore_y == true) then
                Settings.Layout.Button.dist_button.ignore_y = false
            else
                Settings.Layout.Button.dist_button.ignore_y = true
            end
        end
    },
    {
        name = ".99",
        type = ButtonType.button,
        text = ".99",
        box = function()
            return grid(7, 0, 1, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.target_strain == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.strain_button.target_strain == true) then
                Settings.Layout.Button.strain_button.target_strain = false
                Settings.Layout.Button.strain_button.always = false
            else
                Settings.Layout.Button.strain_button.target_strain = true
            end
        end
    },
    {
        name = "always .99",
        type = ButtonType.button,
        text = "Always",
        box = function()
            return grid(4, 0, 3, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.always == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.strain_button.always == true) then
                Settings.Layout.Button.strain_button.always = false
            elseif (Settings.Layout.Button.strain_button.target_strain == true) then
                Settings.Layout.Button.strain_button.always = true
            end
        end
    },
    {
        name = ".99 left",
        type = ButtonType.button,
        text = "<",
        box = function()
            return grid(4, 1, 1, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.left == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.left = not Settings.Layout.Button.strain_button.left
        end
    },
    {
        name = ".99 right",
        type = ButtonType.button,
        text = ">",
        box = function()
            return grid(7, 1, 1, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.right == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.right = not Settings.Layout.Button.strain_button.right
        end
    },
    {
        name = "swim",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.SWIM],
        box = function()
            return grid(4, 2, 2, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.swimming == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.swimming == true) then
                Settings.Layout.Button.swimming = false
            else
                Settings.Layout.Button.swimming = true
            end
        end
    },
    {
        name = "high magnitude",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.HIGH_MAG],
        box = function()
            return grid(6, 2, 2, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.highmag == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.strain_button.highmag == true) then
                Settings.Layout.Button.strain_button.highmag = false
            else
                Settings.Layout.Button.strain_button.highmag = true
            end
        end
    },
    {
        name = "dyaw",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.DYAW],
        box = function()
            return grid(5, 1, 2, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.dyaw == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.strain_button.dyaw == true) then
                Settings.Layout.Button.strain_button.dyaw = false
            else
                Settings.Layout.Button.strain_button.dyaw = true
            end
        end
    },
    {
        name = "arcotan strain",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.ARCTANSTRAIN],
        box = function()
            return grid(4, 4, 3, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.arctan == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.strain_button.arctan == true) then
                Settings.Layout.Button.strain_button.arctan = false
            else
                Settings.Layout.Button.strain_button.arctan = true
                Memory.Refresh()
                Settings.Layout.Button.strain_button.arctanstart = Memory.Mario.GlobalTimer
            end
        end
    },
    {
        name = "reverse arcotan strain",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.REVERSE_ARCTAN],
        box = function()
            return grid(7, 4, 1, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.reverse_arc == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.strain_button.reverse_arc == true) then
                Settings.Layout.Button.strain_button.reverse_arc = false
            else
                Settings.Layout.Button.strain_button.reverse_arc = true
            end
        end
    },
    {
        name = "increment arcotan ratio",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCR],
        box = function()
            return grid(4, 7, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctanr = Settings.Layout.Button.strain_button.arctanr +
                10 ^ Settings.Layout.Button.strain_button.arctanexp
        end
    },
    {
        name = "decrement arcotan ratio",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCR],
        box = function()
            return grid(4, 7.5, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctanr = Settings.Layout.Button.strain_button.arctanr -
                10 ^ Settings.Layout.Button.strain_button.arctanexp
        end
    },
    {
        name = "increment arcotan displacement",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCD],
        box = function()
            return grid(4.5, 7, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctand = Settings.Layout.Button.strain_button.arctand +
                10 ^ Settings.Layout.Button.strain_button.arctanexp
        end
    },
    {
        name = "decrement arcotan displacement",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCD],
        box = function()
            return grid(4.5, 7.5, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctand = Settings.Layout.Button.strain_button.arctand -
                10 ^ Settings.Layout.Button.strain_button.arctanexp
        end
    },
    {
        name = "increment arcotan length",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCN],
        box = function()
            return grid(5, 7, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctann = MoreMaths.Round(
                math.max(0,
                    Settings.Layout.Button.strain_button.arctann +
                    10 ^ math.max(-0.6020599913279624, Settings.Layout.Button.strain_button.arctanexp)), 2)
        end
    },
    {
        name = "decrement arcotan length",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCN],
        box = function()
            return grid(5, 7.5, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctann = MoreMaths.Round(
                math.max(0,
                    Settings.Layout.Button.strain_button.arctann -
                    10 ^ math.max(-0.6020599913279624, Settings.Layout.Button.strain_button.arctanexp)), 2)
        end
    },
    {
        name = "increment arcotan start frame",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCS],
        box = function()
            return grid(5.5, 7, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctanstart = math.max(0,
                Settings.Layout.Button.strain_button.arctanstart +
                10 ^ math.max(0, Settings.Layout.Button.strain_button.arctanexp))
        end
    },
    {
        name = "decrement arcotan start frame",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCS],
        box = function()
            return grid(5.5, 7.5, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctanstart = math.max(0,
                Settings.Layout.Button.strain_button.arctanstart -
                10 ^ math.max(0, Settings.Layout.Button.strain_button.arctanexp))
        end
    },
    {
        name = "increment arcotan step",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCE],
        box = function()
            return grid(6, 7, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctanexp = math.max(-4,
                math.min(Settings.Layout.Button.strain_button.arctanexp + 1, 4))
        end
    },
    {
        name = "decrement arcotan step",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCE],
        box = function()
            return grid(6, 7.5, 0.5, 0.5)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.strain_button.controls == true
        end,
        onclick = function(self)
            Settings.Layout.Button.strain_button.arctanexp = math.max(-4,
                math.min(Settings.Layout.Button.strain_button.arctanexp - 1, 4))
        end
    },
    {
        name = "dist moved",
        type = ButtonType.button,
        text = "Get Moved Distance",
        box = function()
            return grid(0, 15, 4, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.dist_button.enabled == true
        end,
        onclick = function(self)
            if (Settings.Layout.Button.dist_button.enabled == false) then
                Settings.Layout.Button.dist_button.enabled = true
                Settings.Layout.Button.dist_button.axis.x = MoreMaths.DecodeDecToFloat(Memory.Mario.X)
                Settings.Layout.Button.dist_button.axis.y = MoreMaths.DecodeDecToFloat(Memory.Mario.Y)
                Settings.Layout.Button.dist_button.axis.z = MoreMaths.DecodeDecToFloat(Memory.Mario.Z)
            else
                Settings.Layout.Button.dist_button.enabled = false
                Settings.Layout.Button.dist_button.dist_moved_save = Engine.GetTotalDistMoved()
            end
        end
    },
    {
        name = "disabled",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.DISABLED],
        box = function()
            return grid(0, 0, 4, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.selectedItem == Settings.Layout.Button.DISABLED
        end,
        onclick = function(self)
            Settings.Layout.Button.selectedItem = Settings.Layout.Button.DISABLED
        end
    },
    {
        name = "match yaw",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.MATCH_YAW],
        box = function()
            return grid(0, 1, 4, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_YAW
        end,
        onclick = function(self)
            Settings.Layout.Button.selectedItem = Settings.Layout.Button.MATCH_YAW
        end
    },
    {
        name = "reverse angle",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.REVERSE_ANGLE],
        box = function()
            return grid(0, 2, 4, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.selectedItem == Settings.Layout.Button.REVERSE_ANGLE
        end,
        onclick = function(self)
            Settings.Layout.Button.selectedItem = Settings.Layout.Button.REVERSE_ANGLE
        end
    },
    {
        name = "match angle",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.MATCH_ANGLE],
        box = function()
            return grid(0, 3, 4, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_ANGLE
        end,
        onclick = function(self)
            Settings.Layout.Button.selectedItem = Settings.Layout.Button.MATCH_ANGLE
        end
    },
    {
        name = "match angle value",
        type = ButtonType.textArea,
        inputSize = 5,
        box = function()
            return grid(4, 3, 4, 1)
        end,
        value = function()
            return Settings.goalAngle
        end,
        enabled = function()
            return Settings.Layout.Button.selectedItem == Settings.Layout.Button.MATCH_ANGLE
        end,
        editing = function()
            return Settings.Layout.TextArea.selectedItem == Settings.Layout.TextArea.MATCH_ANGLE
        end,
        onclick = function(self, char)
            if (Settings.Layout.TextArea.selectedItem ~= Settings.Layout.TextArea.MATCH_ANGLE) then
                Settings.Layout.TextArea.selectedItem = Settings.Layout.TextArea.MATCH_ANGLE
                Settings.Layout.TextArea.selectedChar = 1 -- on first click set to leading digit
            else
                Settings.Layout.TextArea.selectedChar = char
            end
            Settings.Layout.TextArea.blinkTimer = 0
            Settings.Layout.TextArea.showUnderscore = true
        end,
        onkeypress = function(self, key)
            local oldkey = math.floor(Settings.goalAngle /
                math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)) % 10
            Settings.goalAngle = Settings.goalAngle +
                (key - oldkey) * math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)
            Settings.Layout.TextArea.selectedChar = Settings.Layout.TextArea.selectedChar + 1
            if Settings.Layout.TextArea.selectedChar > self.inputSize then
                Settings.Layout.TextArea.selectedItem = 0
            end
        end,
        onarrowpress = function(self, key)
            if (key == "left") then
                Settings.Layout.TextArea.selectedChar = Settings.Layout.TextArea.selectedChar - 1
                if (Settings.Layout.TextArea.selectedChar == 0) then
                    Settings.Layout.TextArea.selectedChar = self.inputSize
                end
                Settings.Layout.TextArea.showUnderscore = false
            elseif (key == "right") then
                Settings.Layout.TextArea.selectedChar = Settings.Layout.TextArea.selectedChar + 1
                if (Settings.Layout.TextArea.selectedChar == self.inputSize + 1) then
                    Settings.Layout.TextArea.selectedChar = 1
                end
                Settings.Layout.TextArea.showUnderscore = false
            elseif (key == "up") then
                local oldkey = getDigit(Settings.goalAngle, self.inputSize)
                Settings.goalAngle = updateDigit(Settings.goalAngle, self.inputSize, oldkey + 1)
                Settings.Layout.TextArea.showUnderscore = true
            elseif (key == "down") then
                local oldkey = getDigit(Settings.goalAngle, self.inputSize)
                Settings.goalAngle = updateDigit(Settings.goalAngle, self.inputSize, oldkey - 1)
                Settings.Layout.TextArea.showUnderscore = true
            end
            Settings.Layout.TextArea.blinkTimer = -1
        end
    },
    {
        name = "magnitude value",
        type = ButtonType.textArea,
        inputSize = 3,
        box = function()
            return grid(4, 5, 2, 1)
        end,
        value = function()
            return Settings.goalMag
        end,
        enabled = function()
            return true
        end,
        editing = function()
            return Settings.Layout.TextArea.selectedItem == Settings.Layout.TextArea.MAGNITUDE
        end,
        onclick = function(self, char)
            if (Settings.Layout.TextArea.selectedItem ~= Settings.Layout.TextArea.MAGNITUDE) then
                Settings.Layout.TextArea.selectedItem = Settings.Layout.TextArea.MAGNITUDE
                Settings.Layout.TextArea.selectedChar = 1
            else
                Settings.Layout.TextArea.selectedChar = char
            end
            Settings.Layout.TextArea.blinkTimer = 0
            Settings.Layout.TextArea.showUnderscore = true
        end,
        onkeypress = function(self, key)
            local goalMag = Settings.goalMag or 0
            local oldkey = math.floor(goalMag / math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)) %
                10
            goalMag = goalMag + (key - oldkey) * math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)
            Settings.Layout.TextArea.selectedChar = Settings.Layout.TextArea.selectedChar + 1
            if Settings.Layout.TextArea.selectedChar > self.inputSize then
                Settings.Layout.TextArea.selectedItem = 0
                if goalMag > 127 then
                    goalMag = 127
                end
            end
            Settings.goalMag = goalMag
        end,
        onarrowpress = function(self, key)
            if (key == "left") then
                Settings.Layout.TextArea.selectedChar = Settings.Layout.TextArea.selectedChar - 1
                if (Settings.Layout.TextArea.selectedChar == 0) then
                    Settings.Layout.TextArea.selectedChar = self.inputSize
                end
                Settings.Layout.TextArea.showUnderscore = false
            elseif (key == "right") then
                Settings.Layout.TextArea.selectedChar = Settings.Layout.TextArea.selectedChar + 1
                if (Settings.Layout.TextArea.selectedChar == self.inputSize + 1) then
                    Settings.Layout.TextArea.selectedChar = 1
                end
                Settings.Layout.TextArea.showUnderscore = false
            elseif (key == "up") then
                local oldkey = getDigit(Settings.goalMag, self.inputSize)
                Settings.goalMag = updateDigit(Settings.goalMag, self.inputSize, oldkey + 1)
                Settings.Layout.TextArea.showUnderscore = true
            elseif (key == "down") then
                local oldkey = getDigit(Settings.goalMag, self.inputSize)
                Settings.goalMag = updateDigit(Settings.goalMag, self.inputSize, oldkey - 1)
                Settings.Layout.TextArea.showUnderscore = true
            end
            Settings.Layout.TextArea.blinkTimer = -1
        end
    },
    {
        name = "reset magnitude",
        type = ButtonType.button,
        text = Settings.Layout.Button.items[Settings.Layout.Button.RESET_MAG],
        box = function()
            return grid(6, 5, 2, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return false
        end,
        onclick = function(self)
            Settings.goalMag = 127
        end
    },
    {
        name = "record ghost",
        type = ButtonType.button,
        text = "Record Ghost",
        box = function()
            return grid(4, 6, 4, 1)
        end,
        enabled = function()
            return true
        end,
        pressed = function()
            return Settings.Layout.Button.RECORD_GHOST == true
        end,
        onclick = function(self)
            i = 0
            if (Settings.Layout.Button.RECORD_GHOST == true) then
                self.text = "Record ghost"
                Settings.Layout.Button.RECORD_GHOST = false
                recording_ghost = false
                if (i == 0) then
                    Ghost.write_file()
                    i = i + 1
                end
            else
                self.text = "Stop recording"
                Settings.Layout.Button.RECORD_GHOST = true
                recording_ghost = true
                i = 0
            end
        end
    },
}

function Buttons.getGhostButtonText()
    if recording_ghost then
        return "End Recording"
    else
        return Settings.Layout.Button.items[31]
    end
end
