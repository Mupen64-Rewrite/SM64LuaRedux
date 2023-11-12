<p align="center">
  <img width="128" align="center" src="https://github.com/Mupen64-Rewrite/SM64LuaRedux/assets/48759429/4c3ac7b9-ba24-401c-b074-9ba364f0295a">
</p>

<h1 align="center">
  SM64 Lua Redux
</h1>

SM64 Lua Redux is an SM64 TASing utility powered by [mupen-lua-ugui](https://github.com/Aurumaker72/mupen-lua-ugui) and  [mupen-lua-ugui-ext](https://github.com/Aurumaker72/mupen-lua-ugui-ext)

# What's new

- Compatible with any mupen version[^1]
- Themes
- Arctan straining
- RNG
- Timer
- Customizable ramwatch
- Dynamic resizing[^2]
- Framewalk
- Multicontroller support
- Presets[^3]
- Divegrind Automation[^4]
- n-Frame Lookahead[^5]
- Customizable formatting[^6]
- Up to 800% better performance on Mupen64 1.1.6

[^1]: Only versions newer than 1.1.3 will support themes
[^2]: The script will resize its elements intelligently to fit, and will thus work on small and huge resolutions
[^3]: A preset saves your current choices (e.g.: Match Yaw with DYaw = 11111), and allow you to change between saved presets for spontaneously testing new strats or reusing older known configurations
[^4]: (WIP) Allows you to automate divegrinds by specifying a yaw divisor and direction, then letting it operate on the current emu state
[^5]: Preview input changes in real-time, with no need for frame advancing manually. Useful for finding angles, testing BLJs and more. The lookahead timeout is, by default, 0 (1 frame lookahead), but can be increased
[^6]: The amount of decimal points values are rounded to can be changed, as well as angles being expressed as degrees or game units

# Quickstart

1. [Download](https://github.com/Mupen64-Rewrite/SM64LuaRedux/archive/refs/heads/master.zip) the latest version
2. Unzip the archive
3. Open a lua console in Mupen64
4. Browse to the `src/SM64Lua.lua` file and select it
5. Run the script

# Showcase

![grafik](https://github.com/Mupen64-Rewrite/SM64LuaRedux/assets/48759429/dc16eb87-6431-4fb1-87e2-8b01158153c4)

