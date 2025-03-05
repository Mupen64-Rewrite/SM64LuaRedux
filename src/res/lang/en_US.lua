return {
    name = "English (US)",
    -- General
    GENERIC_ON = "On",
    GENERIC_OFF = "Off",
    GENERIC_START = "Start",
    GENERIC_STOP = "Stop",
    GENERIC_RESET = "Reset",
    GENERIC_NIL = "nil",
    -- Tab names
    TAS_TAB_NAME = "TAS",
    PIANO_ROLL_TAB_NAME = "Piano Roll",
    SETTINGS_TAB_NAME = "Settings",
    TOOLS_TAB_NAME = "Tools",
    TIMER_TAB_NAME = "Timer",
    TIMER2_TAB_NAME = "Timer 2",
    PRESET = "Preset ",
    -- TAS Tab
    DISABLED = "Disabled",
    MATCH_YAW = "Match Yaw",
    REVERSE_ANGLE = "Reverse Angle",
    MATCH_ANGLE = "Match Angle",
    D99_ALWAYS = "Always",
    D99 = ".99",
    DYAW = "D-Yaw",
    ATAN_STRAIN = "Arctan Strain",
    ATAN_STRAIN_REV = "I",
    MAG_RESET = "R",
    MAG_HI = "H",
    SPDKICK = "Spdkick",
    FRAMEWALK = "Framewalk",
    SWIM = "Swim",
    -- Piano Roll Tab
    PIANO_ROLL_HELP_HEADER_TITLE = "Piano Roll Help",
    PIANO_ROLL_HELP_HEADER_ABOUT = "About",
    PIANO_ROLL_HELP_HEADER_BEGIN = "Getting started",
    PIANO_ROLL_HELP_HEADER_EDIT = "Editing values",
    PIANO_ROLL_HELP_HEADER_MANAGE = "Managing sheets",
    PIANO_ROLL_HELP_HEADER_CAVEATS = "Caveats",
    PIANO_ROLL_HELP_SHOW = "What?",
    PIANO_ROLL_HELP_EXIT = "Exit",
    PIANO_ROLL_HELP_PREV_PAGE = "back",
    PIANO_ROLL_HELP_NEXT_PAGE = "next",
    PIANO_ROLL_SHEET_NO_SHEET = "No piano roll sheets available.\nCreate one to proceed.",
    PIANO_ROLL_SHEET_NO_SELECTED = "No piano roll sheet selected.\nSelect one to proceed.",
    PIANO_ROLL_SHEET_DELETE_CONFIRMATION = "[Confirm deletion]\n\nAre you sure you want to delete \"%s\"?\nThis action cannot be undone.",
    PIANO_ROLL_SHEET_DELETE_YES = "Yes",
    PIANO_ROLL_SHEET_DELETE_NO = "No",
    PIANO_ROLL_FRAMELIST_START = "Start: ",
    PIANO_ROLL_FRAMELIST_NAME = "Name",
    PIANO_ROLL_FRAMELIST_FRAME = "Frame",
    PIANO_ROLL_FRAMELIST_STICK = "Joystick",
    PIANO_ROLL_TOOL_TRIM = "Trim",
    PIANO_ROLL_TOOL_COPY_ENTIRE_STATE = "Copy entire state",
    PIANO_ROLL_TOOL_SAVE = "Save",
    PIANO_ROLL_TOOL_LOAD = "Load",
    PIANO_ROLL_CONTROL_MANUAL = "Manual",
    PIANO_ROLL_CONTROL_MATCH_YAW = "Yaw",
    PIANO_ROLL_CONTROL_MATCH_ANGLE = "Angle",
    PIANO_ROLL_CONTROL_REVERSE_ANGLE = "Reverse",
    PIANO_ROLL_CONTROL_DYAW = "DYaw",
    PIANO_ROLL_CONTROL_MAG = "Magnitude:",
    PIANO_ROLL_CONTROL_SPDKICK = "Spdk",
    PIANO_ROLL_CONTROL_ATAN = "Atan",
    -- Settings Tab
    SETTINGS_VISUALS_TAB_NAME = "Visuals",
    SETTINGS_VARWATCH_TAB_NAME = "Varwatch",
    SETTINGS_MEMORY_TAB_NAME = "Memory",
    SETTINGS_HOTKEYS_TAB_NAME = "Hotkeys",
    SETTINGS_VISUALS_STYLE = "Style",
    SETTINGS_VISUALS_LOCALE = "Locale",
    SETTINGS_VISUALS_NOTIFICATIONS = "Notifications",
    SETTINGS_VISUALS_NOTIFICATIONS_BUBBLE = "Bubble",
    SETTINGS_VISUALS_NOTIFICATIONS_CONSOLE = "Console",
    SETTINGS_VISUALS_FRAMESKIP = "Fast-forward frame skip",
    SETTINGS_VISUALS_FRAMESKIP_TOOLTIP = "Skips every nth frame when fast-forwarding to increase performance.",
    SETTINGS_VISUALS_UPDATE_EVERY_VI = "Update every VI",
    SETTINGS_VISUALS_UPDATE_EVERY_VI_TOOLTIP = "Updates the UI every VI, improving mupen capture sync. Reduces performance.",
    SETTINGS_VARWATCH_DISABLED = "(disabled)",
    SETTINGS_VARWATCH_HIDE = "Hide",
    SETTINGS_VARWATCH_ANGLE_FORMAT = "Angle formatting",
    SETTINGS_VARWATCH_ANGLE_FORMAT_SHORT = "Short",
    SETTINGS_VARWATCH_ANGLE_FORMAT_DEGREE = "Degree",
    SETTINGS_VARWATCH_DECIMAL_POINTS = "Decimal points",
    SETTINGS_VARWATCH_SPD_EFFICIENCY = "Speed Efficiency Visualization",
    SETTINGS_VARWATCH_SPD_EFFICIENCY_PERCENTAGE = "Percentage",
    SETTINGS_VARWATCH_SPD_EFFICIENCY_FRACTION = "Fraction",
    SETTINGS_MEMORY_FILE_SELECT = "Select map file...",
    SETTINGS_MEMORY_DETECT_NOW = "Autodetect now",
    SETTINGS_MEMORY_DETECT_ON_START = "Autodetect on start",
    SETTINGS_HOTKEYS_NOTHING = "(nothing)",
    SETTINGS_HOTKEYS_CONFIRMATION = "Press Enter to confirm",
    SETTINGS_HOTKEYS_CLEAR = "Clear",
    SETTINGS_HOTKEYS_RESET = "Reset",
    SETTINGS_HOTKEYS_ASSIGN = "Assign",
    SETTINGS_HOTKEYS_ACTIVATION = "Hotkey Activation",
    SETTINGS_HOTKEYS_ACTIVATION_ALWAYS = "Always",
    SETTINGS_HOTKEYS_ACTIVATION_WHEN_NO_FOCUS = "When no control in focus",
    -- Tools Tab
    TOOLS_RNG = "RNG",
    TOOLS_RNG_LOCK = "Lock to",
    TOOLS_RNG_USE_INDEX = "Use Index",
    TOOLS_AUTO_GRIND = "Auto-Grind",
    TOOLS_LOOKAHEAD = "Lookahead",
    TOOLS_LOOKAHEAD_ENABLE = "Enable",
    TOOLS_DUMPING = "Dumping",
    TOOLS_GHOST = "Ghost",
    TOOLS_GHOST_START = "Start Recording",
    TOOLS_GHOST_STOP = "Stop Recording",
    TOOLS_EXPERIMENTS = "Experiments",
    TOOLS_MOVED_DIST = "Moved Dist",
    TOOLS_MINI_OVERLAY = "Input Overlay",
    TOOLS_AUTO_FIRSTIES = "Auto-firsties",
    TOOLS_WORLD_VISUALIZER = "World Visualizer",
    -- Timer Tab
    TIMER_START = "Start",
    TIMER_STOP = "Stop",
    TIMER_RESET = "Reset",
    TIMER_MANUAL = "Manual",
    TIMER_AUTO = "Auto",
    -- Timer 2 Tab
    TIMER2_FRAME = "Frame: %s",
    -- Varwatch
    VARWATCH_FACING_YAW = "Facing Yaw: %s (O: %s)",
    VARWATCH_INTENDED_YAW = "Intended Yaw: %s (O: %s)",
    VARWATCH_H_SPEED = "H Spd: %s (S: %s)",
    VARWATCH_H_SLIDING = "H Sliding Spd: %s",
    VARWATCH_Y_SPEED = "Y Spd: %s",
    VARWATCH_SPD_EFFICIENCY_PERCENTAGE = "Spd Efficiency: %s",
    VARWATCH_SPD_EFFICIENCY_FRACTION = "Spd Efficiency: %d/4",
    VARWATCH_POS_X = "X: %s",
    VARWATCH_POS_Y = "Y: %s",
    VARWATCH_POS_Z = "Z: %s",
    VARWATCH_PITCH = "Pitch: %s",
    VARWATCH_YAW_VEL = "Yaw Vel: %s",
    VARWATCH_PITCH_VEL = "Pitch Vel: %s",
    VARWATCH_XZ_MOVEMENT = "XZ Movement: %s",
    VARWATCH_ACTION = "Action: ",
    VARWATCH_UNKNOWN_ACTION = "Unknown action ",
    VARWATCH_RNG = "RNG: ",
    VARWATCH_RNG_INDEX = "Index: ",
    VARWATCH_GLOBAL_TIMER = "Global Timer: %s",
    VARWATCH_DIST_MOVED = "Dist Moved: %s",
    -- Memory addresses
    ADDRESS_USA = "USA",
    ADDRESS_JAPAN = "Japan",
    ADDRESS_SHINDOU = "Shindou",
    ADDRESS_PAL = "Europe",
    -- putting this at the bottom as to not clutter
    PIANO_ROLL_HELP_EXPLANATIONS = {
-- About
[[
This page lets you play back a sequence of TAS inputs starting from a specific "base frame" with immediate effect.

The purpose of this is to quickly iterate over the effects of small changes "in the past" in order to more efficiently iterate over different implementations of the same strategy.

Click "next" to learn more about how to use this tool.
]],

-- Getting started
[[
Press the [+] Button in the bottom right corner to create a new "Piano Roll" sheet.
This new sheet will be starting at the current frame, identified by the game's global timer value.
Frame advance a couple times and optionally make some inputs with TASinput as usual to get some frames to mess with.
(You will likely be using this page exclusively from there on anyways.)

Click the "Frame" column to select a frame to preview.
Whenever you make any change to any inputs (e.g. change any button inputs), the game is going to be replayed to the preview frame (highlighted in red) from the start of the sheet with the new inputs.

You can select a range of joystick inputs to edit by leftclicking and dragging over the mini-joysticks in the desired range.
Then use the joystick controls at the bottom to decide how those frames should be treated.
]],

-- Editing values
[[
The frame highlighted in green is the "active" frame.
Its values will be displayed, and when you make any changes, its values will copied to the selected range.

If the 'Copy entire state' toggle is off, only the changes made to the active frame will be copied to the selected range.

When the active frame and the preview frame are the same, the highlight will become a yellow-ish green.
]],

-- Managing sheets
[[
You can add as many piano roll sheets as you want.
Note the textbox in the top right that allows you to assign them names.
Click the [-] button to delete a sheet. You will be prompted for confirmation to prevent accidental deletions.

You can also save and load piano roll sheets.
When saving a piano roll sheet, a savestate with the same name as the piano roll sheet file will be created, and the sheet will be executed from that savestate.
This allows you to share piano roll sheets in a similar way to .m64 movies.

You can always cycle to "Off" to disable Piano Rolls entirely.
]]
}
}