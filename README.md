# SM64 Input Direction Lua

The all-in-one lua script that lets you precisely control your inputs - regardless of camera angles! Simply download these files and [mupen64-rr-lua](https://github.com/mkdasher/mupen64-rr-lua-/releases), then run `InputDirection_dev.lua` to get started.

![MatchYawDemo](https://cdn.discordapp.com/attachments/832779512738873444/1001993954096590919/new_new_new_input_direction_gif.gif)

- Match Yaw
  - holds the joystick input that most closely corresponds to Mario's facing angle
- Reverse Angle
  - same as `Match Yaw` but for the opposite direction
- Match Angle
  - holds the joystick in the direction of the specified angle
- .99
  - hold a joystick angle that makes Mario's speed go to 31.99 or 47.99 speed for 1 frame (when possible)
- Always
  - constantly `.99` strain
- Dyaw
  - makes `Match Yaw` hold an offset from Mario's facing angle
- Atanstrain
  - Strains over `N` frames in a way to gain more distance. If `Match Angle` is enabled it will use the input field instead (including `Dyaw`)
- I
  - With `AtanStrain` enabled it does the inputs in reverse order
- E
  - Changes the power of 10 step for `R` `N` `D` and `S`
- R
  - Ratio of forwards movement over sideways movement
- D
  - Displacement (offset)
- N
  - Amount of frames to arcotan strain (can use .25 increments for quarter steps)
- S
  - Frame to start arcotan straining
- Left/Right
  - determines the direction of the `.99` strain, `Dyaw` and `Atanstrain`
- Swim
  - repeatedly presses A or B to swim optimally
  - to change which button is pressed, replace the string inside the main script
- Record Ghost
  - starts/stops recording a ghost for use with [Frame's STROOP refactor](https://github.com/chaosBrick/STROOP) (`tmp.ghost` is saved in `InputDirection_dev` folder by
    default)
- Magnitude Control
  - set a maximum magnitude to input
  - `Speedkick` is a shortcut for a magnitude of 48
  - `High Mag` prioritizes magnitude over angle
  - `Reset Mag` removes the the cap
- Set RNG
  - `V` and `I` denote whether you're entering a value or index, respectively. To use, click the Set RNG button and enter your value/index into the text field. It is updated in the game on the current frame, but due to the fact that the Lua is only redrawn at every VI, you won't see your updated RNG in the displayed variables. Frame advancing, however, will show the next value/index in the RNG function, demonstrating that your RNG was indeed set on the previous frame.
- Get Dist Moved
  - once enabled, saves Mario's position and displays the distance from that point
  - `Ignore Y` ignores the vertical distance

As an example: if Mario is facing angle 54600 and `Match Angle` set to 2000, with `Dyaw` and `Right` selected, it will hold the input coresponding to angle 52600.

You can add your own colour schemes, or adjust the existing ones in `Settings.lua`. To switch to dark mode, put `Settings.Theme = Settings.Themes.Dark` inside the main script.

![DarkTheme](https://cdn.discordapp.com/attachments/196442189604192256/825851592141307955/InputLuaDarkTheme.png)

