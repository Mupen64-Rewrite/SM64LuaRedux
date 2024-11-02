local UID = dofile(views_path .. "PianoRoll/UID.lua")

local shown = false

local page = 1

local title = "Piano Roll Help"

local headers = {
    "About",
    "Getting started",
    "Managing sheets",
    "Caveats",
}

local explanations = {
-- About
[[
This page lets you play back a sequence of TAS inputs starting from a specific "base frame" with immediate effect.

The purpose of this is to quickly iterate over the effects of small changes "in the past" in order to more efficiently iterate over different implementations of the same strategy.

Click "next" to learn more about how to use this tool.
]],

-- Getting started
[[
Press the [+] Button in the bottom right corner to create a new "Piano Roll" sheet.
This will create a new "Piano Roll sheet" starting at the current frame, identified by the game's global timer value.
Frame advance a couple times and optionally make some inputs with TASinput as usual to get some frames to mess with.
(You will likely be using this page exclusively from there on anyways.)

Click the "Frame" column to select a frame to preview.
Whenever you make any change to any inputs (e.g. change any button inputs), the game is going to be replayed to the preview frame (highlighted in red) from the start of the sheet with the new inputs.

You can select a range of joystick inputs to edit by leftclicking and dragging over the mini-joysticks in the desired range.
Then use the joystick controls at the bottom to decide how those frames should be treated.
]],

-- Managing sheets
[[
You can add as many piano roll sheets as you want.
Note the textbox in the top right that allows you to assign them names.

You can also save and load piano roll sheets.
There are some caveats regarding global timer shenanigans and savestates that have yet to be worked out.

You can always cycle to "Off" to disable Piano Rolls entirely.
]]
}

return {
    Render = function()
        local theme = Presets.styles[Settings.active_style_index].theme
        local foregroundColor = theme.listbox.text_colors[1]
        local top = 14.5
        local buttonPosition = grid_rect(0, top, 1.2, 0.5)
        if ugui.button(
            {
                uid = UID.ToggleHelp,

                rectangle = buttonPosition,
                text = shown and "Exit" or "What?",
            }
        ) then
            shown = not shown
        end
        if shown then
            BreitbandGraphics.draw_text(grid_rect(0, 0.1, 8, 1), "start", "start", {}, foregroundColor, theme.font_size * 1.2 * Drawing.scale, theme.font_name, title)
            BreitbandGraphics.draw_text(grid_rect(0, 0.666, 8, 1), "start", "start", {}, foregroundColor, theme.font_size * 2 * Drawing.scale, theme.font_name, headers[page])
            BreitbandGraphics.draw_text(grid_rect(0, 1.5, 8, 1), "start", "start", {}, foregroundColor, theme.font_size * Drawing.scale, theme.font_name, explanations[page])

            if ugui.button(
                {
                    uid = UID.HelpBack,

                    rectangle = grid_rect(6, top, 1, 0.5),
                    text = "back",
                    is_enabled = page > 1
                }
            ) then
                page = page - 1
            end

            if ugui.button(
                {
                    uid = UID.HelpNext,

                    rectangle = grid_rect(7, top, 1, 0.5),
                    text = "next",
                    is_enabled = page < #explanations
                }
            ) then
                page = page + 1
            end
        end

        return shown
    end,
}