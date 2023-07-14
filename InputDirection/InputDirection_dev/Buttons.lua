ButtonType = {
	button = 0,
		-- text : button text
		-- box : total size of the button
	textArea = 1
}

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
		text = Settings.Layout.Button.items[Settings.Layout.Button.IGNORE_Y],
		box = {
			Drawing.Screen.Width + 137,
			505,
			78,
			20
		},
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
		text = Settings.Layout.Button.items[Settings.Layout.Button.POINT_99],
		box = {
			Drawing.Screen.Width + 187,
			5,
			30,
			22
		},
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
		text = Settings.Layout.Button.items[Settings.Layout.Button.ALWAYS_99],
		box = {
			Drawing.Screen.Width + 137,
			5,
			47,
			22
		},
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
		text = Settings.Layout.Button.items[Settings.Layout.Button.LEFT_99],
		box = {
			Drawing.Screen.Width + 137,
			31,
			35,
			22
		},
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
		text = Settings.Layout.Button.items[Settings.Layout.Button.RIGHT_99],
		box = {
			Drawing.Screen.Width + 175,
			31,
			42,
			22
		},
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
		name = "dyaw",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.DYAW],
		box = {
			Drawing.Screen.Width + 137,
			57,
			40,
			22
		},
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
		box = {
			Drawing.Screen.Width + 137,
			83,
			64,
			22
		},
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
		box = {
			Drawing.Screen.Width + 204,
			83,
			13,
			22
		},
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
		box = {
			Drawing.Screen.Width + 147,
			317 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctanr = Settings.Layout.Button.strain_button.arctanr + 10 ^ Settings.Layout.Button.strain_button.arctanexp
		end
	},
	{
		name = "decrement arcotan ratio",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCR],
		box = {
			Drawing.Screen.Width + 159,
			317 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctanr = Settings.Layout.Button.strain_button.arctanr - 10 ^ Settings.Layout.Button.strain_button.arctanexp
		end
	},
	{
		name = "increment arcotan displacement",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCD],
		box = {
			Drawing.Screen.Width + 147,
			330 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctand = Settings.Layout.Button.strain_button.arctand + 10 ^ Settings.Layout.Button.strain_button.arctanexp
		end
	},
	{
		name = "decrement arcotan displacement",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCD],
		box = {
			Drawing.Screen.Width + 159,
			330 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctand = Settings.Layout.Button.strain_button.arctand - 10 ^ Settings.Layout.Button.strain_button.arctanexp
		end
	},
	{
		name = "increment arcotan length",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCN],
		box = {
			Drawing.Screen.Width + 147,
			344 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctann = MoreMaths.Round(math.max(0,Settings.Layout.Button.strain_button.arctann + 10 ^ math.max(-0.6020599913279624,Settings.Layout.Button.strain_button.arctanexp)), 2)
		end
	},
	{
		name = "decrement arcotan length",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCN],
		box = {
			Drawing.Screen.Width + 159,
			344 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctann = MoreMaths.Round(math.max(0,Settings.Layout.Button.strain_button.arctann - 10 ^ math.max(-0.6020599913279624,Settings.Layout.Button.strain_button.arctanexp)), 2)
		end
	},
	{
		name = "increment arcotan start frame",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCS],
		box = {
			Drawing.Screen.Width + 147,
			357 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctanstart = math.max(0,Settings.Layout.Button.strain_button.arctanstart + 10 ^ math.max(0,Settings.Layout.Button.strain_button.arctanexp))
		end
	},
	{
		name = "decrement arcotan start frame",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCS],
		box = {
			Drawing.Screen.Width + 159,
			357 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctanstart = math.max(0,Settings.Layout.Button.strain_button.arctanstart - 10 ^ math.max(0,Settings.Layout.Button.strain_button.arctanexp))
		end
	},
	{
		name = "increment arcotan step",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.INCARCE],
		box = {
			Drawing.Screen.Width + 147,
			304 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctanexp = math.max(-4, math.min(Settings.Layout.Button.strain_button.arctanexp + 1, 4))
		end
	},
	{
		name = "decrement arcotan step",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.DECARCE],
		box = {
			Drawing.Screen.Width + 159,
			304 + 50,
			10,
			12
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.strain_button.controls == true
		end,
		onclick = function(self)
			Settings.Layout.Button.strain_button.arctanexp = math.max(-4, math.min(Settings.Layout.Button.strain_button.arctanexp - 1, 4))
		end
	},
	{
		name = "dist moved",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.DIST_MOVED],
		box = {
			Drawing.Screen.Width + 5,
			505,
			130,
			20
		},
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
		box = {
			Drawing.Screen.Width + 5,
			5,
			128,
			30
		},
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
		box = {
			Drawing.Screen.Width + 5,
			40,
			128,
			30
		},
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
		box = {
			Drawing.Screen.Width + 5,
			75,
			128,
			30
		},
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
		box = {
			Drawing.Screen.Width + 5,
			110,
			128,
			30
		},
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
		box = {
			Drawing.Screen.Width + 137,
			110,
			80,
			30
		},
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
			local oldkey = math.floor(Settings.goalAngle / math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)) % 10
			Settings.goalAngle = Settings.goalAngle + (key - oldkey) * math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)
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
		box = {
			Drawing.Screen.Width + 153,
			165,
			49,
			26
		},
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
			local oldkey = math.floor(goalMag / math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)) % 10
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
		name = "speedkick magnitude",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.MAG48],
		box = {
			Drawing.Screen.Width + 143,
			230,
			69,
			13
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return false
		end,
		onclick = function(self)
			Settings.goalMag = 48
			Settings.Layout.Button.strain_button.highmag = true
		end
	},
	{
		name = "high magnitude",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.HIGH_MAG],
		box = {
			Drawing.Screen.Width + 143,
			245,
			69,
			13
		},
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
		name = "reset magnitude",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.RESET_MAG],
		box = {
			Drawing.Screen.Width + 143,
			260,
			69,
			13
		},
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
		name = "swim",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.SWIM],
		box = {
			Drawing.Screen.Width + 180,
			57,
			37,
			22
		},
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
		name = "set rng",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.SET_RNG],
		box = {
			Drawing.Screen.Width + 5,
			480,
			90,
			23
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.SET_RNG == true
		end,
		onclick = function(self)
			if (Settings.Layout.Button.SET_RNG == true) then
				Settings.Layout.Button.SET_RNG = false
			else
				Settings.Layout.Button.SET_RNG = true
			end
		end
	},
	{
		name = "use value",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.USE_VALUE],
		box = {
			Drawing.Screen.Width + 97,
			480,
			17,
			23
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.set_rng_mode.value == true
		end,
		onclick = function(self)
			if (Settings.Layout.Button.set_rng_mode.value == true) then
				Settings.Layout.Button.set_rng_mode.value = false
			else
				Settings.Layout.Button.set_rng_mode.value = true
				Settings.Layout.Button.set_rng_mode.index = false
			end
		end
	},
	{
		name = "use index",
		type = ButtonType.button,
		text = Settings.Layout.Button.items[Settings.Layout.Button.USE_INDEX],
		box = {
			Drawing.Screen.Width + 117,
			480,
			17,
			23
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.set_rng_mode.index == true
		end,
		onclick = function(self)
			if (Settings.Layout.Button.set_rng_mode.index == true) then
				Settings.Layout.Button.set_rng_mode.index = false
			else
				Settings.Layout.Button.set_rng_mode.index = true
				Settings.Layout.Button.set_rng_mode.value = false
			end
		end
	},
	{
		name = "set rng input",
		type = ButtonType.textArea,
		inputSize = 5,
		box = {
			Drawing.Screen.Width + 137,
			480,
			78,
			23
		},
		value = function()
			return Settings.setRNG
		end,
		enabled = function()
			return Settings.Layout.Button.SET_RNG == true
		end,
		editing = function()
			return Settings.Layout.TextArea.selectedItem == Settings.Layout.TextArea.RNG
		end,
		onclick = function(self, char)
			if (Settings.Layout.TextArea.selectedItem ~= Settings.Layout.TextArea.RNG) then
				Settings.Layout.TextArea.selectedItem = Settings.Layout.TextArea.RNG
				Settings.Layout.TextArea.selectedChar = 1 -- on first click set to leading digit
			else
				Settings.Layout.TextArea.selectedChar = char
			end
			Settings.Layout.TextArea.blinkTimer = 0
			Settings.Layout.TextArea.showUnderscore = true
		end,
		onkeypress = function(self, key)
			local rng = Settings.setRNG or 0
			local oldkey = math.floor(rng / math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)) % 10
			rng = rng + (key - oldkey) * math.pow(10, self.inputSize - Settings.Layout.TextArea.selectedChar)
			Settings.Layout.TextArea.selectedChar = Settings.Layout.TextArea.selectedChar + 1
			if Settings.Layout.TextArea.selectedChar > self.inputSize then
				Settings.Layout.TextArea.selectedItem = 0
			end
			Settings.setRNG = rng
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
				local oldkey = getDigit(Settings.setRNG, self.inputSize)
				Settings.setRNG = updateDigit(Settings.setRNG, self.inputSize, oldkey + 1)
				Settings.Layout.TextArea.showUnderscore = true
			elseif (key == "down") then
				local oldkey = getDigit(Settings.setRNG, self.inputSize)
				Settings.setRNG = updateDigit(Settings.setRNG, self.inputSize, oldkey - 1)
				Settings.Layout.TextArea.showUnderscore = true
			end
			Settings.Layout.TextArea.blinkTimer = -1
		end
	},
	{
		name = "record ghost",
		type = ButtonType.button,
		text = "Record Ghost",
		box = {
			Drawing.Screen.Width + 5,
			530,
			Drawing.WIDTH_OFFSET - 10,
			21
		},
		enabled = function()
			return true
		end,
		pressed = function()
			return Settings.Layout.Button.RECORD_GHOST == true
		end,
		onclick = function(self)
			i = 0
			if (Settings.Layout.Button.RECORD_GHOST == true) then
                self.text = "Start ghost recording"
				Settings.Layout.Button.RECORD_GHOST = false
				recording_ghost = false
				if (i == 0) then
					Ghost.write_file()
					i = i + 1
				end
			else
                self.text = "Stop ghost recording"
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