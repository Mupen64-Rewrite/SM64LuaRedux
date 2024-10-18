UID = dofile(views_path .. "PianoRoll/UID.lua")

---constants---

local ModeTexts = { "-", "D", "M", "Y", "R", "A" }
local Buttons = {
    {input = 'A', text = 'A'},
    {input = 'B', text = 'B'},
    {input = 'Z', text = 'Z'},
    {input = 'start', text = 'S'},
    {input = 'Cup', text = '^'},
    {input = 'Cleft', text = '<'},
    {input = 'Cright', text = '>'},
    {input = 'Cdown', text = 'v'},
    {input = 'L', text = 'L'},
    {input = 'R', text = 'R'},
    {input = 'up', text = '^'},
    {input = 'left', text = '<'},
    {input = 'right', text = '>'},
    {input = 'v', text = 'v'},
}

local col0 = 0.0
local col1 = 1.0
local col2 = 1.5
local col3 = 2.0
local col4 = 2.5
local col5 = 3.2
local col6 = 4.15
local col_1 = 8.0

local row0 = -0.25
local row1 = 0.125
local row2 = 0.5
local row3 = 0.75
local row4 = 1.35

local small = 0.25

local scrollOffset = 0

local buttonColors = {
    {background={r=000, g=000, b=255, a=100}, button={r=000, g=000, b=190, a=255}},
    {background={r=000, g=177, b=022, a=100}, button={r=000, g=230, b=044, a=255}},
    {background={r=111, g=111, b=111, a=100}, button={r=200, g=200, b=200, a=255}},
    {background={r=200, g=000, b=000, a=100}, button={r=255, g=000, b=000, a=255}},
    {background={r=200, g=200, b=000, a=100}, button={r=255, g=255, b=000, a=255}}, -- 4 C Buttons
    {background={r=111, g=111, b=111, a=100}, button={r=200, g=200, b=200, a=255}}, -- L + R Buttons
    {background={r=055, g=055, b=055, a=100}, button={r=035, g=035, b=035, a=255}}, -- 4 DPad Buttons
}

---logic---

local lastInput = {}

local function NewSelection(state, globalTimer)
    return {
        state = state,
        startGT = globalTimer,
        endGT = globalTimer,
        min = function(self) return math.min(self.startGT, self.endGT) end,
        max = function(self) return math.max(self.startGT, self.endGT) end,
    }
end

local function NumDisplayFrames() return math.min(PianoRollContext.current:numFrames(), PianoRollContext.maxDisplayedFrames) end

local function UpdateScroll()
    local maxScroll = PianoRollContext.current:numFrames() - PianoRollContext.maxDisplayedFrames
    scrollOffset = math.max(0, math.min(maxScroll, scrollOffset - uguiInputContext.wheel))
end

local function DrawFactory(theme)
    return {
        foregroundColor = BreitbandGraphics.invert_color(theme.background_color),
        fontSize = theme.font_size * Drawing.scale * 0.75,
        style = { aliased = theme.pixelated_text },

        text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text(rect, horizontal_alignment, "center", self.style, self.foregroundColor, self.fontSize, "Consolas", text)
        end,

        small_text = function(self, rect, horizontal_alignment, text)
            BreitbandGraphics.draw_text(rect, horizontal_alignment, "center", self.style, self.foregroundColor, self.fontSize * 0.75, "Consolas", text)
        end
    }
end

local function DrawHeaders(draw, buttonDrawData)
    BreitbandGraphics.fill_rectangle(grid_rect(0, row0, col_1, row4 - row0), {r=211, g=211, b=211})

    draw:text(grid_rect(0, row0, 2, 1), "start", "Start: " .. PianoRollContext.current.startGT)

    draw:small_text(grid_rect(2, row0, 4, 1), "start", "Name")
    PianoRollContext.current.name = ugui.textbox({
        uid = UID.PianoRollName,
        is_enabled = true,
        rectangle = grid_rect(2, row2 - 0.15, 4, 0.45), -- guessing values to look alright
        text = PianoRollContext.current.name
    })

    draw:text(grid_rect(col0, row2, col1 - col0, 1), "start", "Frame")
    draw:text(grid_rect(col1, row2, col6 - col1, 1), "start", "Joystick")
    draw:text(grid_rect(col6, row2, col_1 - col6, 1), "start", "Buttons")

    local rect = grid_rect(0, row3 + 0.35, 0.333, 0.333)
    for i, v in ipairs(Buttons) do
        rect.x = buttonDrawData[i].x
        draw:small_text(rect, "center", v.text)
    end
end

local function DrawColorCodes()
    local offset = 0

    local width = small * 1.1
    local rect = grid_rect(col6 + offset, row4, width, 0.5)
    local height = rect.height * NumDisplayFrames()

    local i = 1
    local colorIndex = 1
    local buttonDrawData = {}

    local function DrawNext(amount)
        for k = 0, amount - 1, 1 do
            buttonDrawData[i] = {x = rect.x + k * rect.width, colorIndex = colorIndex}
            i = i + 1
        end
        BreitbandGraphics.fill_rectangle(
            {x = rect.x, y = rect.y, width = rect.width * amount, height = height},
            buttonColors[colorIndex].background
        )
        rect.x = rect.x + rect.width * amount
        colorIndex = colorIndex + 1
    end

    DrawNext(1)
    DrawNext(1)
    DrawNext(1)
    DrawNext(1)
    DrawNext(4)
    DrawNext(2)
    DrawNext(4)

    return buttonDrawData
end

local placing = false
local function PlaceAndUnplaceButtons(frameRect, currentInput, pressed, buttonDrawData)
    local mouseX = uguiInputContext.mouse_position.x
    local relativeY = uguiInputContext.mouse_position.y - frameRect.y
    local inRange = mouseX >= frameRect.x and mouseX <= frameRect.x + frameRect.width and relativeY >= 0
    local frameIndex = math.floor(relativeY / frameRect.height)
    local hoveringGlobalTimer = frameIndex + scrollOffset + PianoRollContext.current.startGT
    local frame = PianoRollContext.current.frames[hoveringGlobalTimer]
    local anyChange = false
    inRange = inRange and frameIndex <= PianoRollContext.maxDisplayedFrames
    if inRange then UpdateScroll() end

    if inRange and frame ~= nil then
        for buttonIndex, v in ipairs(Buttons) do
            local inRangeX = mouseX >= buttonDrawData[buttonIndex].x and mouseX < (buttonDrawData[buttonIndex + 1] or {x=9999999}).x
            if pressed.leftclick and inRangeX then
                placing = not frame.joy[v.input]
                frame.joy[v.input] = placing
                anyChange = true
            elseif currentInput.leftclick and inRangeX then
                anyChange = frame.joy[v.input] ~= placing
                frame.joy[v.input] = placing
            end
        end
    end
    return anyChange
end

local function DrawFramesGui(draw, buttonDrawData)

    local currentInput = input.get()
    local pressed = input.diff(currentInput, lastInput)
    local released = input.diff(lastInput, currentInput)
    lastInput = currentInput;

    if released.leftclick and PianoRollContext.selection ~= nil then
        PianoRollContext.current:edit(PianoRollContext.selection.endGT)
    end

    local frameRect = grid_rect(col0, row4, col_1 - col0, 0.5)
    local anyChange = PlaceAndUnplaceButtons(frameRect, currentInput, pressed, buttonDrawData)

    local function span(x1, x2, height)
        local r = grid_rect(x1, 0, x2 - x1, height)
        return {x = r.x, y = frameRect.y, width = r.width, height = height and r.height or frameRect.height}
    end

    local globalTimerValue = GetGlobalTimer()
    for i = 0, PianoRollContext.current:numFrames() - 1, 1 do
        local frameNumber = i + scrollOffset
        local globalTimer = PianoRollContext.current.startGT + frameNumber
        local shade = globalTimer % 2 == 0 and 123 or 80
        local blueMultiplier = globalTimer < globalTimerValue and 2 or 1

        if i >= PianoRollContext.maxDisplayedFrames then
            local extraFrames = PianoRollContext.current.endGT - globalTimer
            if extraFrames > 0 then
                BreitbandGraphics.fill_rectangle(frameRect, {r=138, g=148, b=138, a=66})
                draw:text(span(col1, col_1), "start", "+ " .. extraFrames .. " frames")
            end
            break
        end

        local input = PianoRollContext.current.frames[globalTimer]
        if input == nil then
            input = {}
            local previous = PianoRollContext.current.frames[globalTimer - 1]
            if previous == nil then
                RecordPianoRollInput(input)
            else
                CloneInto(input, previous)
                input.joy = {}
                CloneInto(input.joy, previous.joy)
             end
            PianoRollContext.current.frames[globalTimer] = input
        end

        local uidBase = UID.UIDCOUNT + i * 20
        local frameBox = span(col0 + 0.25, col1)
        draw:text(frameBox, "end", frameNumber .. ":")

        if pressed.leftclick and BreitbandGraphics.is_point_inside_rectangle(uguiInputContext.mouse_position, frameBox) then
            PianoRollContext.current:jumpTo(globalTimer)
        end

        ugui.joystick({
            uid = uidBase + 1,
            rectangle = span(col1, col2, 0.5),
            position = {x = Engine.stick_for_input_x(input), y = -Engine.stick_for_input_y(input)},
        })

        local joystickBox = span(col1, col2)
        BreitbandGraphics.fill_rectangle(span(0, col_1), {r=shade, g=shade, b=shade * blueMultiplier, a=66})

        if BreitbandGraphics.is_point_inside_rectangle(uguiInputContext.mouse_position, joystickBox) then
            if pressed.leftclick  then
                PianoRollContext.selection = NewSelection(input.goal_angle, globalTimer)
            elseif PianoRollContext.selection ~= nil and currentInput.leftclick then
                PianoRollContext.selection.endGT = globalTimer
            end
        end
        if PianoRollContext.selection ~= nil and PianoRollContext.selection:min() <= globalTimer and PianoRollContext.selection:max() >= globalTimer then
            BreitbandGraphics.fill_rectangle(joystickBox, {r = 0, g = 200, b = 0, a = 100})
        end

        draw:text(span(col2, col3, 0.5), "center", ModeTexts[input.movement_mode + 1])

        if input.movement_mode == MovementModes.match_angle then
            draw:text(span(col4, col5, 0.5), "end", tostring(input.goal_angle))
            draw:text(span(col5, col6, 0.5), "end", input.strain_left and '<' or (input.strain_right and '>' or '-'))
        end

        local sz = 0.22 * Settings.grid_size * Drawing.scale
        local rect = {x = 0, y = frameRect.y + 0.11 * Settings.grid_size * Drawing.scale, width = sz, height = sz}
        for buttonIndex, v in ipairs(Buttons) do
            rect.x = buttonDrawData[buttonIndex].x + Drawing.scale * 1
            if input.joy[v.input] then
                BreitbandGraphics.fill_ellipse(rect, buttonColors[buttonDrawData[buttonIndex].colorIndex].button)
            end
            BreitbandGraphics.draw_ellipse(rect, {r=0, g=0, b=0, a=input.joy[v.input] and 255 or 80}, 1)
        end

        if (globalTimer == PianoRollContext.current.previewGT) then
            BreitbandGraphics.draw_rectangle(frameRect, {r=255, g=0, b=0}, 1)
        end

        if (globalTimer == PianoRollContext.current.editingGT) then
            BreitbandGraphics.draw_rectangle(frameRect, {r=100, g=255, b=100}, 1)
        end

        frameRect.y = frameRect.y + frameRect.height
    end

    return anyChange
end

---@class LuaGui
local __clsLuaGui = {}

--- Renders the piano roll, indicating whether an update by the user has been made that should cause a rerun
function __clsLuaGui.Render() end

---@type LuaGui
return {
    Render = function()
        -- hack to get a denser UI
        local previousGridGap = Settings.grid_gap
        Settings.grid_gap = 0

        local draw = DrawFactory(Presets.styles[Settings.active_style_index].theme)
        local buttonDrawData = DrawColorCodes()
        DrawHeaders(draw, buttonDrawData)

        local prev_joystick_tip_size = ugui.standard_styler.joystick_tip_size
        ugui.standard_styler.joystick_tip_size = 4 * Drawing.scale
        local anyChange = DrawFramesGui(draw, buttonDrawData)
        ugui.standard_styler.joystick_tip_size = prev_joystick_tip_size

        Settings.grid_gap = previousGridGap

        return anyChange
    end,
}