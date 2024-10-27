-- mupen-lua-ugui 1.7.0
-- https://github.com/Aurumaker72/mupen-lua-ugui

local function folder(file)
    local s = debug.getinfo(2, 'S').source:sub(2)
    local p = file:gsub('[%(%)%%%.%+%-%*%?%^%$]', '%%%0'):gsub('[\\/]', '[\\/]') .. '$'
    return s:gsub(p, '')
end

dofile(folder('mupen-lua-ugui.lua') .. 'breitbandgraphics.lua')

ugui = {

    internal = {
        -- per-uid library-side data, such as scroll position
        control_data = {},

        -- the current input state
        environment = nil,

        -- the last frame's input state
        previous_environment = nil,

        -- the position of the mouse at the last click
        mouse_down_position = {x = 0, y = 0},

        -- uid of the currently active control
        active_control = nil,

        -- whether the active control will be cleared after the mouse is released
        clear_active_control_after_mouse_up = true,

        -- rectangles which are excluded from hittesting (e.g.: the popped up list of a combobox)
        hittest_free_rects = {},

        -- array of functions which will be called at the end of the frame
        late_callbacks = {},

        -- Map of uids used in an active section (between begin_frame and end_frame)
        used_uids = {},

        ---Validates the structure of a control and registers its uid. Must be called in every control function.
        ---@param control table A control which may or may not abide by the mupen-lua-ugui control contract
        validate_and_register_control = function(control)
            if not control.uid
                or not control.rectangle
                or not control.rectangle.x
                or not control.rectangle.y
                or not control.rectangle.width
                or not control.rectangle.height
            then
                error('Attempted to show a malformed control.\r\n' .. debug.traceback())
            end
            if ugui.internal.used_uids[control.uid] then
                error(string.format('Attempted to show a control with uid %d, which is already in use! Note that some controls reserve more than one uid slot after them.', control.uid))
            end
            ugui.internal.used_uids[control.uid] = control.uid
        end,
        deep_clone = function(obj, seen)
            if type(obj) ~= 'table' then return obj end
            if seen and seen[obj] then return seen[obj] end
            local s = seen or {}
            local res = setmetatable({}, getmetatable(obj))
            s[obj] = res
            for k, v in pairs(obj) do
                res[ugui.internal.deep_clone(k, s)] = ugui.internal.deep_clone(
                    v, s)
            end
            return res
        end,
        remove_range = function(string, start_index, end_index)
            if start_index > end_index then
                start_index, end_index = end_index, start_index
            end
            return string.sub(string, 1, start_index - 1) .. string.sub(string, end_index)
        end,
        is_mouse_just_down = function()
            return ugui.internal.environment.is_primary_down and
                not ugui.internal.previous_environment.is_primary_down
        end,
        is_mouse_just_up = function()
            return not ugui.internal.environment.is_primary_down and
                ugui.internal.previous_environment.is_primary_down
        end,
        is_mouse_wheel_up = function()
            return ugui.internal.environment.wheel == 1
        end,
        is_mouse_wheel_down = function()
            return ugui.internal.environment.wheel == -1
        end,
        remove_at = function(string, index)
            if index == 0 then
                return string
            end
            return string:sub(1, index - 1) .. string:sub(index + 1, string:len())
        end,
        insert_at = function(string, string2, index)
            return string:sub(1, index) .. string2 .. string:sub(index + string2:len(), string:len())
        end,
        remap = function(value, from1, to1, from2, to2)
            return (value - from1) / (to1 - from1) * (to2 - from2) + from2
        end,
        clamp = function(value, min, max)
            if value == nil then
                return value
            end
            return math.max(math.min(value, max), min)
        end,
        get_just_pressed_keys = function()
            local keys = {}
            for key, _ in pairs(ugui.internal.environment.held_keys) do
                if not ugui.internal.previous_environment.held_keys[key] then
                    keys[key] = 1
                end
            end
            return keys
        end,
        process_push = function(control)
            if control.is_enabled == false then
                return false
            end

            if ugui.internal.environment.is_primary_down and not ugui.internal.previous_environment.is_primary_down then
                if BreitbandGraphics.is_point_inside_rectangle(ugui.internal.mouse_down_position,
                        control.rectangle) then
                    if not control.topmost and BreitbandGraphics.is_point_inside_any_rectangle(ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects) then
                        return false
                    end

                    ugui.internal.active_control = control.uid
                    ugui.internal.clear_active_control_after_mouse_up = true
                    return true
                end
            end
            return false
        end,
        get_caret_index = function(text, relative_x)
            local positions = {}
            for i = 1, #text, 1 do
                local width = BreitbandGraphics.get_text_size(text:sub(1, i),
                    ugui.standard_styler.font_size,
                    ugui.standard_styler.font_name).width

                positions[#positions + 1] = width
            end

            for i = #positions, 1, -1 do
                if relative_x > positions[i] then
                    return ugui.internal.clamp(i + 1, 1, #positions + 1)
                end
            end

            return 1
        end,
        handle_special_key = function(key, has_selection, text, selection_start, selection_end, caret_index)
            local sel_lo = math.min(selection_start, selection_end)
            local sel_hi = math.max(selection_start, selection_end)

            if key == 'left' then
                if has_selection then
                    -- nuke the selection and set caret index to lower (left)
                    local lower_selection = sel_lo
                    selection_start = lower_selection
                    selection_end = lower_selection
                    caret_index = lower_selection
                else
                    caret_index = caret_index - 1
                end
            elseif key == 'right' then
                if has_selection then
                    -- nuke the selection and set caret index to higher (right)
                    local higher_selection = sel_hi
                    selection_start = higher_selection
                    selection_end = higher_selection
                    caret_index = higher_selection
                else
                    caret_index = caret_index + 1
                end
            elseif key == 'space' then
                if has_selection then
                    -- replace selection contents by one space
                    local lower_selection = sel_lo
                    text = ugui.internal.remove_range(text, sel_lo, sel_hi)
                    caret_index = lower_selection
                    selection_start = lower_selection
                    selection_end = lower_selection
                    text = ugui.internal.insert_at(text, ' ', caret_index - 1)
                    caret_index = caret_index + 1
                else
                    text = ugui.internal.insert_at(text, ' ', caret_index - 1)
                    caret_index = caret_index + 1
                end
            elseif key == 'backspace' then
                if has_selection then
                    local lower_selection = sel_lo
                    text = ugui.internal.remove_range(text, lower_selection, sel_hi)
                    caret_index = lower_selection
                    selection_start = lower_selection
                    selection_end = lower_selection
                else
                    text = ugui.internal.remove_at(text,
                        caret_index - 1)
                    caret_index = caret_index - 1
                end
            else
                return {
                    handled = false,
                }
            end
            return {
                handled = true,
                text = text,
                selection_start = selection_start,
                selection_end = selection_end,
                caret_index = caret_index,
            }
        end,
    },
    -- The possible states of a control, which are used by the styler
    visual_states = {
        --- The control doesn't accept user interactions
        disabled = 0,
        --- The control isn't being interacted with
        normal = 1,
        --- The mouse is over the control
        hovered = 2,
        --- The primary mouse button is pushed on the control or the control is currently capturing inputs
        active = 3,
    },
    ---Gets the basic visual state of a control
    ---@param control table The control
    ---@return _ integer The visual state
    get_visual_state = function(control)
        if control.is_enabled == false then
            return ugui.visual_states.disabled
        end

        if ugui.internal.active_control ~= nil and ugui.internal.active_control == control.uid then
            return ugui.visual_states.active
        end

        local now_inside = BreitbandGraphics.is_point_inside_rectangle(
                ugui.internal.environment.mouse_position,
                control.rectangle)
            and
            not BreitbandGraphics.is_point_inside_any_rectangle(ugui.internal.environment.mouse_position,
                ugui.internal.hittest_free_rects)

        local down_inside = BreitbandGraphics.is_point_inside_rectangle(
                ugui.internal.mouse_down_position, control.rectangle)
            and
            not BreitbandGraphics.is_point_inside_any_rectangle(ugui.internal.mouse_down_position,
                ugui.internal.hittest_free_rects)

        if now_inside and not ugui.internal.environment.is_primary_down then
            return ugui.visual_states.hovered
        end

        if down_inside and ugui.internal.environment.is_primary_down and not now_inside then
            return ugui.visual_states.hovered
        end

        if now_inside and down_inside and ugui.internal.environment.is_primary_down then
            return ugui.visual_states.active
        end

        return ugui.visual_states.normal
    end,

    --- A collection of stylers, which are responsible for drawing the UI
    standard_styler = {
        textbox_padding = 2,
        track_thickness = 2,
        bar_width = 6,
        bar_height = 16,
        item_height = 15,
        menu_item_height = 22,
        menu_overlap_size = 3,
        menu_item_left_padding = 32,
        menu_item_right_padding = 32,
        font_size = 12,
        cleartype = true,
        scrollbar_thickness = 17,
        joystick_tip_size = 8,
        icon_size = 12,
        font_name = 'MS Shell Dlg 2',
        raised_frame_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#E1E1E1'),
            [2] = BreitbandGraphics.hex_to_color('#E5F1FB'),
            [3] = BreitbandGraphics.hex_to_color('#CCE4F7'),
            [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
        },
        raised_frame_border_colors = {
            [1] = BreitbandGraphics.hex_to_color('#ADADAD'),
            [2] = BreitbandGraphics.hex_to_color('#0078D7'),
            [3] = BreitbandGraphics.hex_to_color('#005499'),
            [0] = BreitbandGraphics.hex_to_color('#BFBFBF'),
        },
        edit_frame_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
        },
        edit_frame_border_colors = {
            [1] = BreitbandGraphics.hex_to_color('#7A7A7A'),
            [2] = BreitbandGraphics.hex_to_color('#171717'),
            [3] = BreitbandGraphics.hex_to_color('#0078D7'),
            [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
        },
        list_frame_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
        },
        list_frame_border_colors = {
            [1] = BreitbandGraphics.hex_to_color('#7A7A7A'),
            [2] = BreitbandGraphics.hex_to_color('#7A7A7A'),
            [3] = BreitbandGraphics.hex_to_color('#7A7A7A'),
            [0] = BreitbandGraphics.hex_to_color('#7A7A7A'),
        },
        menu_frame_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#F2F2F2'),
            [2] = BreitbandGraphics.hex_to_color('#F2F2F2'),
            [3] = BreitbandGraphics.hex_to_color('#F2F2F2'),
            [0] = BreitbandGraphics.hex_to_color('#F2F2F2'),
        },
        menu_frame_border_colors = {
            [1] = BreitbandGraphics.hex_to_color('#CCCCCC'),
            [2] = BreitbandGraphics.hex_to_color('#CCCCCC'),
            [3] = BreitbandGraphics.hex_to_color('#CCCCCC'),
            [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
        },
        menu_item_text_colors = {
            [1] = BreitbandGraphics.hex_to_color('#000000'),
            [2] = BreitbandGraphics.hex_to_color('#000000'),
            [3] = BreitbandGraphics.hex_to_color('#000000'),
            [0] = BreitbandGraphics.hex_to_color('#6D6D6D'),
        },
        menu_item_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#00000000'),
            [2] = BreitbandGraphics.hex_to_color('#91C9F7'),
            [3] = BreitbandGraphics.hex_to_color('#91C9F7'),
            [0] = BreitbandGraphics.hex_to_color('#00000000'),
        },
        raised_frame_text_colors = {
            [1] = BreitbandGraphics.colors.black,
            [2] = BreitbandGraphics.colors.black,
            [3] = BreitbandGraphics.colors.black,
            [0] = BreitbandGraphics.repeated_to_color(160),
        },
        edit_frame_text_colors = {
            [1] = BreitbandGraphics.colors.black,
            [2] = BreitbandGraphics.colors.black,
            [3] = BreitbandGraphics.colors.black,
            [0] = BreitbandGraphics.repeated_to_color(160),
        },
        list_text_colors = {
            [1] = BreitbandGraphics.colors.black,
            [2] = BreitbandGraphics.colors.black,
            [3] = BreitbandGraphics.colors.white,
            [0] = BreitbandGraphics.repeated_to_color(160),
        },
        list_item_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [3] = BreitbandGraphics.hex_to_color('#0078D7'),
            [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
        },
        joystick_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [2] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [3] = BreitbandGraphics.hex_to_color('#FFFFFF'),
            [0] = BreitbandGraphics.hex_to_color('#FFFFFF'),
        },
        joystick_outline_colors = {
            [1] = BreitbandGraphics.hex_to_color('#000000'),
            [2] = BreitbandGraphics.hex_to_color('#000000'),
            [3] = BreitbandGraphics.hex_to_color('#000000'),
            [0] = BreitbandGraphics.hex_to_color('#000000'),
        },
        joystick_tip_colors = {
            [1] = BreitbandGraphics.hex_to_color('#FF0000'),
            [2] = BreitbandGraphics.hex_to_color('#FF0000'),
            [3] = BreitbandGraphics.hex_to_color('#FF0000'),
            [0] = BreitbandGraphics.hex_to_color('#FF8080'),
        },
        joystick_line_colors = {
            [1] = BreitbandGraphics.hex_to_color('#0000FF'),
            [2] = BreitbandGraphics.hex_to_color('#0000FF'),
            [3] = BreitbandGraphics.hex_to_color('#0000FF'),
            [0] = BreitbandGraphics.hex_to_color('#8080FF'),
        },
        joystick_inner_mag_colors = {
            [1] = BreitbandGraphics.hex_to_color('#FF000022'),
            [2] = BreitbandGraphics.hex_to_color('#FF000022'),
            [3] = BreitbandGraphics.hex_to_color('#FF000022'),
            [0] = BreitbandGraphics.hex_to_color('#00000000'),
        },
        joystick_outer_mag_colors = {
            [1] = BreitbandGraphics.hex_to_color('#FF0000'),
            [2] = BreitbandGraphics.hex_to_color('#FF0000'),
            [3] = BreitbandGraphics.hex_to_color('#FF0000'),
            [0] = BreitbandGraphics.hex_to_color('#FF8080'),
        },
        joystick_mag_thicknesses = {
            [1] = 2,
            [2] = 2,
            [3] = 2,
            [0] = 2,
        },
        scrollbar_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#F0F0F0'),
            [2] = BreitbandGraphics.hex_to_color('#F0F0F0'),
            [3] = BreitbandGraphics.hex_to_color('#F0F0F0'),
            [0] = BreitbandGraphics.hex_to_color('#F0F0F0'),
        },
        scrollbar_thumb_colors = {
            [1] = BreitbandGraphics.hex_to_color('#CDCDCD'),
            [2] = BreitbandGraphics.hex_to_color('#A6A6A6'),
            [3] = BreitbandGraphics.hex_to_color('#606060'),
            [0] = BreitbandGraphics.hex_to_color('#C0C0C0'),
        },
        trackbar_back_colors = {
            [1] = BreitbandGraphics.hex_to_color('#E7EAEA'),
            [2] = BreitbandGraphics.hex_to_color('#E7EAEA'),
            [3] = BreitbandGraphics.hex_to_color('#E7EAEA'),
            [0] = BreitbandGraphics.hex_to_color('#E7EAEA'),
        },
        trackbar_border_colors = {
            [1] = BreitbandGraphics.hex_to_color('#D6D6D6'),
            [2] = BreitbandGraphics.hex_to_color('#D6D6D6'),
            [3] = BreitbandGraphics.hex_to_color('#D6D6D6'),
            [0] = BreitbandGraphics.hex_to_color('#D6D6D6'),
        },
        trackbar_thumb_colors = {
            [1] = BreitbandGraphics.hex_to_color('#007AD9'),
            [2] = BreitbandGraphics.hex_to_color('#171717'),
            [3] = BreitbandGraphics.hex_to_color('#CCCCCC'),
            [0] = BreitbandGraphics.hex_to_color('#CCCCCC'),
        },

        ---Draws an icon with the specified parameters
        ---The draw_icon implementation may choose to use either the color or visual_state parameter to determine the icon's appearance.
        ---Therefore, the caller must provide either a color or a visual state, or both.
        draw_icon = function(rectangle, color, visual_state, key)
            if not color and visual_state then
                BreitbandGraphics.fill_rectangle(rectangle, BreitbandGraphics.colors.red)
                return
            end

            if key == 'arrow_left' then
                BreitbandGraphics.draw_text(rectangle,
                    'center',
                    'center',
                    {aliased = not ugui.standard_styler.cleartype},
                    color,
                    ugui.standard_styler.font_size,
                    'Segoe UI Mono',
                    '<')
            elseif key == 'arrow_right' then
                BreitbandGraphics.draw_text(rectangle,
                    'center',
                    'center',
                    {aliased = not ugui.standard_styler.cleartype},
                    color,
                    ugui.standard_styler.font_size,
                    'Segoe UI Mono',
                    '>')
            elseif key == 'arrow_up' then
                BreitbandGraphics.draw_text(rectangle,
                    'center',
                    'center',
                    {aliased = not ugui.standard_styler.cleartype},
                    color,
                    ugui.standard_styler.font_size,
                    'Segoe UI Mono',
                    '^')
            elseif key == 'arrow_down' then
                BreitbandGraphics.draw_text(rectangle,
                    'center',
                    'center',
                    {aliased = not ugui.standard_styler.cleartype},
                    color,
                    ugui.standard_styler.font_size,
                    'Segoe UI Mono',
                    'v')
            elseif key == 'checkmark' then
                local connection_point = {x = rectangle.x + rectangle.width * 0.3, y = rectangle.y + rectangle.height}
                BreitbandGraphics.draw_line({x = rectangle.x, y = rectangle.y + rectangle.height / 2}, connection_point, color, 1)
                BreitbandGraphics.draw_line(connection_point, {x = rectangle.x + rectangle.width, y = rectangle.y}, color, 1)
            else
                -- Unknown icon, probably a good idea to nag the user
                BreitbandGraphics.fill_rectangle(rectangle, BreitbandGraphics.colors.red)
            end
        end,

        draw_raised_frame = function(control, visual_state)
            BreitbandGraphics.fill_rectangle(control.rectangle,
                ugui.standard_styler.raised_frame_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                ugui.standard_styler.raised_frame_back_colors[visual_state])
        end,
        draw_edit_frame = function(control, rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(control.rectangle,
                ugui.standard_styler.edit_frame_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                ugui.standard_styler.edit_frame_back_colors[visual_state])
        end,
        draw_list_frame = function(rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(rectangle,
                ugui.standard_styler.list_frame_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                ugui.standard_styler.list_frame_back_colors[visual_state])
        end,
        draw_joystick_inner = function(rectangle, visual_state, position)
            local back_color = ugui.standard_styler.joystick_back_colors[visual_state]
            local outline_color = ugui.standard_styler.joystick_outline_colors[visual_state]
            local tip_color = ugui.standard_styler.joystick_tip_colors[visual_state]
            local line_color = ugui.standard_styler.joystick_line_colors[visual_state]
            local inner_mag_color = ugui.standard_styler.joystick_inner_mag_colors[visual_state]
            local outer_mag_color = ugui.standard_styler.joystick_outer_mag_colors[visual_state]
            local mag_thickness = ugui.standard_styler.joystick_mag_thicknesses[visual_state]

            BreitbandGraphics.fill_ellipse(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                back_color)
            BreitbandGraphics.draw_ellipse(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                outline_color, 1)
            BreitbandGraphics.draw_line({
                x = rectangle.x + rectangle.width / 2,
                y = rectangle.y,
            }, {
                x = rectangle.x + rectangle.width / 2,
                y = rectangle.y + rectangle.height,
            }, outline_color, 1)
            BreitbandGraphics.draw_line({
                x = rectangle.x,
                y = rectangle.y + rectangle.height / 2,
            }, {
                x = rectangle.x + rectangle.width,
                y = rectangle.y + rectangle.height / 2,
            }, outline_color, 1)


            local r = position.r - mag_thickness
            if r > 0 then
                BreitbandGraphics.fill_ellipse({
                    x = rectangle.x + rectangle.width / 2 - r / 2,
                    y = rectangle.y + rectangle.height / 2 - r / 2,
                    width = r,
                    height = r,
                }, inner_mag_color)
                r = position.r

                BreitbandGraphics.draw_ellipse({
                    x = rectangle.x + rectangle.width / 2 - r / 2,
                    y = rectangle.y + rectangle.height / 2 - r / 2,
                    width = r,
                    height = r,
                }, outer_mag_color, mag_thickness)
            end


            BreitbandGraphics.draw_line({
                x = rectangle.x + rectangle.width / 2,
                y = rectangle.y + rectangle.height / 2,
            }, {
                x = position.x,
                y = position.y,
            }, line_color, 3)

            BreitbandGraphics.fill_ellipse({
                x = position.x - ugui.standard_styler.joystick_tip_size / 2,
                y = position.y - ugui.standard_styler.joystick_tip_size / 2,
                width = ugui.standard_styler.joystick_tip_size,
                height = ugui.standard_styler.joystick_tip_size,
            }, tip_color)
        end,
        draw_scrollbar = function(container_rectangle, thumb_rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(container_rectangle,
                ugui.standard_styler.scrollbar_back_colors[visual_state])
            BreitbandGraphics.fill_rectangle(thumb_rectangle,
                ugui.standard_styler.scrollbar_thumb_colors[visual_state])
        end,
        draw_list_item = function(item, rectangle, visual_state)
            if not item then
                return
            end
            BreitbandGraphics.fill_rectangle(rectangle,
                ugui.standard_styler.list_item_back_colors[visual_state])

            local size = BreitbandGraphics.get_text_size(item, ugui.standard_styler.font_size,
                ugui.standard_styler.font_name)
            BreitbandGraphics.draw_text({
                    x = rectangle.x + 2,
                    y = rectangle.y,
                    width = size.width * 2,
                    height = rectangle.height,
                }, 'start', 'center', {aliased = not ugui.standard_styler.cleartype},
                ugui.standard_styler.list_text_colors[visual_state],
                ugui.standard_styler.font_size,
                ugui.standard_styler.font_name,
                item)
        end,
        draw_list = function(control, rectangle)
            local visual_state = ugui.get_visual_state(control)
            ugui.standard_styler.draw_list_frame(rectangle, visual_state)

            local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)
            -- item y position:
            -- y = (20 * (i - 1)) - (scroll_y * ((20 * #control.items) - control.rectangle.height))
            local scroll_x = ugui.internal.control_data[control.uid].scroll_x and
                ugui.internal.control_data[control.uid].scroll_x or 0
            local scroll_y = ugui.internal.control_data[control.uid].scroll_y and
                ugui.internal.control_data[control.uid].scroll_y or 0

            local index_begin = (scroll_y *
                    (content_bounds.height - rectangle.height)) /
                ugui.standard_styler.item_height

            local index_end = (rectangle.height + (scroll_y *
                    (content_bounds.height - rectangle.height))) /
                ugui.standard_styler.item_height

            index_begin = ugui.internal.clamp(math.floor(index_begin), 1, #control.items)
            index_end = ugui.internal.clamp(math.ceil(index_end), 1, #control.items)

            local x_offset = math.max((content_bounds.width - control.rectangle.width) * scroll_x, 0)

            BreitbandGraphics.push_clip(BreitbandGraphics.inflate_rectangle(rectangle, -1))

            for i = index_begin, index_end, 1 do
                local y_offset = (ugui.standard_styler.item_height * (i - 1)) -
                    (scroll_y * (content_bounds.height - rectangle.height))

                local item_visual_state = ugui.visual_states.normal
                if control.is_enabled == false then
                    item_visual_state = ugui.visual_states.disabled
                end

                if control.selected_index == i then
                    item_visual_state = ugui.visual_states.active
                end

                ugui.standard_styler.draw_list_item(control.items[i], {
                    x = rectangle.x - x_offset,
                    y = rectangle.y + y_offset,
                    width = math.max(content_bounds.width, control.rectangle.width),
                    height = ugui.standard_styler.item_height,
                }, item_visual_state)
            end

            BreitbandGraphics.pop_clip()
        end,
        draw_menu_frame = function(rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(rectangle,
                ugui.standard_styler.menu_frame_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                ugui.standard_styler.menu_frame_back_colors[visual_state])
        end,
        draw_menu_item = function(item, rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(rectangle,
                ugui.standard_styler.menu_item_back_colors[visual_state])
            BreitbandGraphics.push_clip({
                x = rectangle.x,
                y = rectangle.y,
                width = rectangle.width,
                height = rectangle.height,
            })

            if item.checked then
                local icon_rect = BreitbandGraphics.inflate_rectangle({
                    x = rectangle.x + (ugui.standard_styler.menu_item_left_padding - rectangle.height) * 0.5,
                    y = rectangle.y,
                    width = rectangle.height,
                    height = rectangle.height,
                }, -7)
                ugui.standard_styler.draw_icon(icon_rect, ugui.standard_styler.menu_item_text_colors[visual_state], nil, 'checkmark')
            end

            if item.items then
                local icon_rect = BreitbandGraphics.inflate_rectangle({
                    x = rectangle.x + rectangle.width - (ugui.standard_styler.menu_item_right_padding),
                    y = rectangle.y,
                    width = ugui.standard_styler.menu_item_right_padding,
                    height = rectangle.height,
                }, -7)
                ugui.standard_styler.draw_icon(icon_rect, ugui.standard_styler.menu_item_text_colors[visual_state], nil, 'arrow_right')
            end

            BreitbandGraphics.draw_text({
                    x = rectangle.x + ugui.standard_styler.menu_item_left_padding,
                    y = rectangle.y,
                    width = 9999999,
                    height = rectangle.height,
                }, 'start', 'center', {aliased = not ugui.standard_styler.cleartype},
                ugui.standard_styler.menu_item_text_colors[visual_state],
                ugui.standard_styler.font_size,
                ugui.standard_styler.font_name,
                item.text)
            BreitbandGraphics.pop_clip()
        end,
        draw_menu = function(control, rectangle)
            local visual_state = ugui.get_visual_state(control)
            ugui.standard_styler.draw_menu_frame(rectangle, visual_state)

            local y = rectangle.y

            for i, item in pairs(control.items) do
                local rectangle = BreitbandGraphics.inflate_rectangle({
                    x = rectangle.x,
                    y = y,
                    width = rectangle.width,
                    height = ugui.standard_styler.menu_item_height,
                }, -1)

                local visual_state = ugui.visual_states.normal
                if ugui.internal.control_data[control.uid].hovered_index and ugui.internal.control_data[control.uid].hovered_index == i then
                    visual_state = ugui.visual_states.hovered
                end
                if item.enabled == false then
                    visual_state = ugui.visual_states.disabled
                end
                ugui.standard_styler.draw_menu_item(item, rectangle, visual_state)

                y = y + ugui.standard_styler.menu_item_height
            end
        end,
        draw_button = function(control)
            local visual_state = ugui.get_visual_state(control)

            -- override for toggle_button
            if control.is_checked and control.is_enabled ~= false then
                visual_state = ugui.visual_states.active
            end

            ugui.standard_styler.draw_raised_frame(control, visual_state)

            BreitbandGraphics.draw_text(control.rectangle, 'center', 'center',
                {clip = true, aliased = not ugui.standard_styler.cleartype},
                ugui.standard_styler.raised_frame_text_colors[visual_state],
                ugui.standard_styler.font_size,
                ugui.standard_styler.font_name, control.text)
        end,
        draw_togglebutton = function(control)
            ugui.standard_styler.draw_button(control)
        end,
        draw_carrousel_button = function(control)
            -- add a "fake" text field
            local copy = ugui.internal.deep_clone(control)
            copy.text = control.items and control.items[control.selected_index] or ''
            ugui.standard_styler.draw_button(copy)

            local visual_state = ugui.get_visual_state(control)

            -- draw the arrows
            ugui.standard_styler.draw_icon({
                x = control.rectangle.x + ugui.standard_styler.textbox_padding,
                y = control.rectangle.y,
                width = ugui.standard_styler.icon_size,
                height = control.rectangle.height,
            }, ugui.standard_styler.raised_frame_text_colors[visual_state], visual_state, 'arrow_left')
            ugui.standard_styler.draw_icon({
                x = control.rectangle.x + control.rectangle.width - ugui.standard_styler.textbox_padding -
                    ugui.standard_styler.icon_size,
                y = control.rectangle.y,
                width = ugui.standard_styler.icon_size,
                height = control.rectangle.height,
            }, ugui.standard_styler.raised_frame_text_colors[visual_state], visual_state, 'arrow_right')
        end,
        draw_textbox = function(control)
            local visual_state = ugui.get_visual_state(control)
            local text = control.text or ''

            if ugui.internal.active_control == control.uid and control.is_enabled ~= false then
                visual_state = ugui.visual_states.active
            end

            ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

            local should_visualize_selection = not (ugui.internal.control_data[control.uid].selection_start == nil) and
                not (ugui.internal.control_data[control.uid].selection_end == nil) and
                control.is_enabled ~= false and
                not (ugui.internal.control_data[control.uid].selection_start == ugui.internal.control_data[control.uid].selection_end)

            if should_visualize_selection then
                local string_to_selection_start = text:sub(1,
                    ugui.internal.control_data[control.uid].selection_start - 1)
                local string_to_selection_end = text:sub(1,
                    ugui.internal.control_data[control.uid].selection_end - 1)

                BreitbandGraphics.fill_rectangle({
                        x = control.rectangle.x +
                            BreitbandGraphics.get_text_size(string_to_selection_start,
                                ugui.standard_styler.font_size,
                                ugui.standard_styler.font_name)
                            .width + ugui.standard_styler.textbox_padding,
                        y = control.rectangle.y,
                        width = BreitbandGraphics.get_text_size(string_to_selection_end,
                                ugui.standard_styler.font_size,
                                ugui.standard_styler.font_name)
                            .width -
                            BreitbandGraphics.get_text_size(string_to_selection_start,
                                ugui.standard_styler.font_size,
                                ugui.standard_styler.font_name)
                            .width,
                        height = control.rectangle.height,
                    },
                    BreitbandGraphics.hex_to_color('#0078D7'))
            end

            BreitbandGraphics.draw_text({
                    x = control.rectangle.x + ugui.standard_styler.textbox_padding,
                    y = control.rectangle.y,
                    width = control.rectangle.width - ugui.standard_styler.textbox_padding * 2,
                    height = control.rectangle.height,
                }, 'start', 'start', {clip = true, aliased = not ugui.standard_styler.cleartype},
                ugui.standard_styler.edit_frame_text_colors[visual_state],
                ugui.standard_styler.font_size,
                ugui.standard_styler.font_name, text)

            if should_visualize_selection then
                local lower = ugui.internal.control_data[control.uid].selection_start
                local higher = ugui.internal.control_data[control.uid].selection_end
                if ugui.internal.control_data[control.uid].selection_start > ugui.internal.control_data[control.uid].selection_end then
                    lower = ugui.internal.control_data[control.uid].selection_end
                    higher = ugui.internal.control_data[control.uid].selection_start
                end

                local string_to_selection_start = text:sub(1,
                    lower - 1)
                local string_to_selection_end = text:sub(1,
                    higher - 1)

                local selection_start_x = control.rectangle.x +
                    BreitbandGraphics.get_text_size(string_to_selection_start,
                        ugui.standard_styler.font_size,
                        ugui.standard_styler.font_name).width +
                    ugui.standard_styler.textbox_padding

                local selection_end_x = control.rectangle.x +
                    BreitbandGraphics.get_text_size(string_to_selection_end,
                        ugui.standard_styler.font_size,
                        ugui.standard_styler.font_name).width +
                    ugui.standard_styler.textbox_padding

                BreitbandGraphics.push_clip({
                    x = selection_start_x,
                    y = control.rectangle.y,
                    width = selection_end_x - selection_start_x,
                    height = control.rectangle.height,
                })
                BreitbandGraphics.draw_text({
                        x = control.rectangle.x + ugui.standard_styler.textbox_padding,
                        y = control.rectangle.y,
                        width = control.rectangle.width - ugui.standard_styler.textbox_padding * 2,
                        height = control.rectangle.height,
                    }, 'start', 'start', {clip = true, aliased = not ugui.standard_styler.cleartype},
                    BreitbandGraphics.invert_color(ugui.standard_styler.edit_frame_text_colors
                        [visual_state]),
                    ugui.standard_styler.font_size,
                    ugui.standard_styler.font_name, text)
                BreitbandGraphics.pop_clip()
            end


            local string_to_caret = text:sub(1, ugui.internal.control_data[control.uid].caret_index - 1)
            local caret_x = BreitbandGraphics.get_text_size(string_to_caret,
                    ugui.standard_styler.font_size,
                    ugui.standard_styler.font_name).width +
                ugui.standard_styler.textbox_padding

            if visual_state == ugui.visual_states.active and math.floor(os.clock() * 2) % 2 == 0 and not should_visualize_selection then
                BreitbandGraphics.draw_line({
                    x = control.rectangle.x + caret_x,
                    y = control.rectangle.y + 2,
                }, {
                    x = control.rectangle.x + caret_x,
                    y = control.rectangle.y +
                        math.max(15,
                            BreitbandGraphics.get_text_size(string_to_caret, 12,
                                ugui.standard_styler.font_name)
                            .height), -- TODO: move text measurement into BreitbandGraphics
                }, {
                    r = 0,
                    g = 0,
                    b = 0,
                }, 1)
            end
        end,
        draw_joystick = function(control)
            local visual_state = ugui.get_visual_state(control)
            local x = control.position and control.position.x or 0
            local y = control.position and control.position.y or 0
            local mag = control.mag or 0

            -- joystick has no hover or active states
            if not (visual_state == ugui.visual_states.disabled) then
                visual_state = ugui.visual_states.normal
            end

            ugui.standard_styler.draw_raised_frame(control, visual_state)
            ugui.standard_styler.draw_joystick_inner(control.rectangle, visual_state, {
                x = ugui.internal.remap(ugui.internal.clamp(x, -128, 128), -128, 128,
                    control.rectangle.x, control.rectangle.x + control.rectangle.width),
                y = ugui.internal.remap(ugui.internal.clamp(y, -128, 128), -128, 128,
                    control.rectangle.y, control.rectangle.y + control.rectangle.height),
                r = ugui.internal.remap(ugui.internal.clamp(mag, 0, 128), 0, 128, 0,
                    math.min(control.rectangle.width, control.rectangle.height)),
            })
        end,
        draw_track = function(control, visual_state, is_horizontal)
            local track_rectangle = {}
            if not is_horizontal then
                track_rectangle = {
                    x = control.rectangle.x + control.rectangle.width / 2 -
                        ugui.standard_styler.track_thickness / 2,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.track_thickness,
                    height = control.rectangle.height,
                }
            else
                track_rectangle = {
                    x = control.rectangle.x,
                    y = control.rectangle.y + control.rectangle.height / 2 -
                        ugui.standard_styler.track_thickness / 2,
                    width = control.rectangle.width,
                    height = ugui.standard_styler.track_thickness,
                }
            end

            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(track_rectangle, 1),
                ugui.standard_styler.trackbar_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(track_rectangle,
                ugui.standard_styler.trackbar_back_colors[visual_state])
        end,
        draw_thumb = function(control, visual_state, is_horizontal, value)
            local head_rectangle = {}
            local effective_bar_height = math.min(
                (is_horizontal and control.rectangle.height or control.rectangle.width) * 2,
                ugui.standard_styler.bar_height)
            if not is_horizontal then
                head_rectangle = {
                    x = control.rectangle.x + control.rectangle.width / 2 -
                        effective_bar_height / 2,
                    y = control.rectangle.y + (value * control.rectangle.height) -
                        ugui.standard_styler.bar_width / 2,
                    width = effective_bar_height,
                    height = ugui.standard_styler.bar_width,
                }
            else
                head_rectangle = {
                    x = control.rectangle.x + (value * control.rectangle.width) -
                        ugui.standard_styler.bar_width / 2,
                    y = control.rectangle.y + control.rectangle.height / 2 -
                        effective_bar_height / 2,
                    width = ugui.standard_styler.bar_width,
                    height = effective_bar_height,
                }
            end
            BreitbandGraphics.fill_rectangle(head_rectangle,
                ugui.standard_styler.trackbar_thumb_colors[visual_state])
        end,
        draw_trackbar = function(control)
            local visual_state = ugui.get_visual_state(control)

            if ugui.internal.active_control == control.uid and control.is_enabled ~= false then
                visual_state = ugui.visual_states.active
            end

            local is_horizontal = control.rectangle.width > control.rectangle.height

            ugui.standard_styler.draw_track(control, visual_state, is_horizontal)
            ugui.standard_styler.draw_thumb(control, visual_state, is_horizontal, control
                .value)
        end,
        draw_combobox = function(control)
            local visual_state = ugui.get_visual_state(control)
            local selected_item = control.items and (control.selected_index and control.items[control.selected_index] or '') or ''

            if ugui.internal.control_data[control.uid].is_open and control.is_enabled ~= false then
                visual_state = ugui.visual_states.active
            end

            ugui.standard_styler.draw_raised_frame(control, visual_state)

            local text_color = ugui.standard_styler.raised_frame_text_colors[visual_state]

            BreitbandGraphics.draw_text({
                    x = control.rectangle.x + ugui.standard_styler.textbox_padding * 2,
                    y = control.rectangle.y,
                    width = control.rectangle.width,
                    height = control.rectangle.height,
                }, 'start', 'center', {clip = true, aliased = not ugui.standard_styler.cleartype}, text_color,
                ugui.standard_styler.font_size,
                ugui.standard_styler.font_name,
                selected_item)

            ugui.standard_styler.draw_icon({
                x = control.rectangle.x + control.rectangle.width - ugui.standard_styler.icon_size - ugui.standard_styler.textbox_padding * 2,
                y = control.rectangle.y,
                width = ugui.standard_styler.icon_size,
                height = control.rectangle.height,
            }, text_color, visual_state, 'arrow_down')
        end,

        draw_listbox = function(control)
            ugui.standard_styler.draw_list(control, control.rectangle)
        end,

        ---Gets the desired bounds of a listbox's content.
        ---@param control table A table abiding by the mupen-lua-ugui control contract
        ---@return _ table A rectangle specifying the desired bounds of the content as `{x = 0, y = 0, width: number, height: number}`.
        get_desired_listbox_content_bounds = function(control)
            -- Since horizontal content bounds measuring is expensive, we only do this if explicitly enabled.
            local max_width = 0
            if control.horizontal_scroll == true then
                for _, value in pairs(control.items) do
                    local width = BreitbandGraphics.get_text_size(value, ugui.standard_styler.font_size,
                        ugui.standard_styler.font_name).width

                    if width > max_width then
                        max_width = width
                    end
                end
            end

            return {
                x = 0,
                y = 0,
                width = max_width,
                height = ugui.standard_styler.item_height * (control.items and #control.items or 0),
            }
        end,
    },

    ---Begins a new frame
    ---@param environment table A table describing the state of the environment as `{ mouse_position = {x, y}, wheel, is_primary_down, held_keys, window_size = {x, y} }`
    begin_frame = function(environment)
        if not ugui.internal.environment then
            ugui.internal.environment = environment
        end
        if not environment.window_size then
            -- Assume unbounded window size if user is too lazy to provide one
            environment.window_size = {x = math.maxinteger, y = math.maxinteger}
        end
        ugui.internal.previous_environment = ugui.internal.deep_clone(ugui.internal
            .environment)
        ugui.internal.environment = ugui.internal.deep_clone(environment)

        if ugui.internal.is_mouse_just_down() then
            ugui.internal.mouse_down_position = ugui.internal.environment.mouse_position
        end
    end,

    --- Ends a frame
    end_frame = function()
        for i = 1, #ugui.internal.late_callbacks, 1 do
            ugui.internal.late_callbacks[i]()
        end

        ugui.internal.late_callbacks = {}
        ugui.internal.hittest_free_rects = {}
        ugui.internal.used_uids = {}

        if not ugui.internal.environment.is_primary_down and ugui.internal.clear_active_control_after_mouse_up then
            ugui.internal.active_control = nil
        end
    end,

    ---Places a Button
    ---
    ---Additional fields in the `control` table:
    ---
    --- `text` — `string` The button's text
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ boolean Whether the button has been pressed this frame
    button = function(control)
        ugui.internal.validate_and_register_control(control)

        local pushed = ugui.internal.process_push(control)
        ugui.standard_styler.draw_button(control)

        return pushed
    end,
    ---Places a toggleable Button, which acts like a CheckBox
    ---
    ---Additional fields in the `control` table:
    ---
    --- `text` — `string` The button's text
    --- `is_checked` — `boolean` Whether the button is checked
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ boolean Whether the button is checked
    toggle_button = function(control)
        ugui.internal.validate_and_register_control(control)

        local pushed = ugui.internal.process_push(control)
        ugui.standard_styler.draw_togglebutton(control)

        if pushed then
            return not control.is_checked
        end

        return control.is_checked
    end,
    ---Places a Carrousel Button
    ---
    ---Additional fields in the `control` table:
    ---
    --- `items` — `string[]` The items
    --- `selected_index` — `number` The selected index into `items`
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ number The new selected index
    carrousel_button = function(control)
        ugui.internal.validate_and_register_control(control)

        local pushed = ugui.internal.process_push(control)
        local selected_index = control.selected_index

        if pushed then
            local relative_x = ugui.internal.environment.mouse_position.x - control.rectangle.x
            if relative_x > control.rectangle.width / 2 then
                selected_index = selected_index + 1
                if selected_index > #control.items then
                    selected_index = 1
                end
            else
                selected_index = selected_index - 1
                if selected_index < 1 then
                    selected_index = #control.items
                end
            end
        end

        ugui.standard_styler.draw_carrousel_button(control)

        return control.items and ugui.internal.clamp(selected_index, 1, #control.items) or nil
    end,
    ---Places a TextBox
    ---
    ---Additional fields in the `control` table:
    ---
    --- `text` — `string` The textbox's text
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ string The textbox's text
    textbox = function(control)
        ugui.internal.validate_and_register_control(control)

        if not ugui.internal.control_data[control.uid] then
            ugui.internal.control_data[control.uid] = {
                caret_index = 1,
                selection_start = nil,
                selection_end = nil,
            }
        end

        local pushed = ugui.internal.process_push(control)
        local text = control.text or ''

        if pushed then
            ugui.internal.clear_active_control_after_mouse_up = false
        end

        -- if active and user clicks elsewhere, deactivate
        if ugui.internal.active_control == control.uid
            and not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
            if ugui.internal.is_mouse_just_down() then
                -- deactivate, then clear selection
                ugui.internal.active_control = nil
                ugui.internal.control_data[control.uid].selection_start = nil
                ugui.internal.control_data[control.uid].selection_end = nil
            end
        end


        local function sel_hi()
            return math.max(ugui.internal.control_data[control.uid].selection_start,
                ugui.internal.control_data[control.uid].selection_end)
        end

        local function sel_lo()
            return math.min(ugui.internal.control_data[control.uid].selection_start,
                ugui.internal.control_data[control.uid].selection_end)
        end


        if ugui.internal.active_control == control.uid and control.is_enabled ~= false then
            local theoretical_caret_index = ugui.internal.get_caret_index(text,
                ugui.internal.environment.mouse_position.x - control.rectangle.x)

            -- start a new selection
            if ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                ugui.internal.control_data[control.uid].caret_index = theoretical_caret_index
                ugui.internal.control_data[control.uid].selection_start = theoretical_caret_index
            end

            -- already has selection, move end to appropriate index
            if ugui.internal.environment.is_primary_down and BreitbandGraphics.is_point_inside_rectangle(ugui.internal.mouse_down_position, control.rectangle) then
                ugui.internal.control_data[control.uid].selection_end = theoretical_caret_index
            end

            local just_pressed_keys = ugui.internal.get_just_pressed_keys()
            local has_selection = ugui.internal.control_data[control.uid].selection_start ~=
                ugui.internal.control_data[control.uid].selection_end

            for key, _ in pairs(just_pressed_keys) do
                local result = ugui.internal.handle_special_key(key, has_selection, control.text,
                    ugui.internal.control_data[control.uid].selection_start,
                    ugui.internal.control_data[control.uid].selection_end,
                    ugui.internal.control_data[control.uid].caret_index)


                -- special key press wasn't handled, we proceed to just insert the pressed character (or replace the selection)
                if not result.handled then
                    if #key ~= 1 then
                        goto continue
                    end

                    if has_selection then
                        local lower_selection = sel_lo()
                        text = ugui.internal.remove_range(text, sel_lo(), sel_hi())
                        ugui.internal.control_data[control.uid].caret_index = lower_selection
                        ugui.internal.control_data[control.uid].selection_start = lower_selection
                        ugui.internal.control_data[control.uid].selection_end = lower_selection
                        text = ugui.internal.insert_at(text, key,
                            ugui.internal.control_data[control.uid].caret_index - 1)
                        ugui.internal.control_data[control.uid].caret_index = ugui.internal
                            .control_data[control.uid]
                            .caret_index + 1
                    else
                        text = ugui.internal.insert_at(text, key,
                            ugui.internal.control_data[control.uid].caret_index - 1)
                        ugui.internal.control_data[control.uid].caret_index = ugui.internal
                            .control_data[control.uid]
                            .caret_index + 1
                    end

                    goto continue
                end

                ugui.internal.control_data[control.uid].caret_index = result.caret_index
                ugui.internal.control_data[control.uid].selection_start = result.selection_start
                ugui.internal.control_data[control.uid].selection_end = result.selection_end
                text = result.text

                ::continue::
            end
        end

        ugui.internal.control_data[control.uid].caret_index = ugui.internal.clamp(
            ugui.internal.control_data[control.uid].caret_index, 1, #text + 1)

        ugui.standard_styler.draw_textbox(control)
        return text
    end,

    ---Places a Joystick
    ---
    ---Additional fields in the `control` table:
    ---
    --- `position` — `table` The joystick's position as `{x, y}` with the range `0-128`
    --- `mag` - `number?` The joystick's magnitude with the range `0-128`
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ `table` The joystick's new position as `{x, y}` with the range `0-128`
    joystick = function(control)
        ugui.internal.validate_and_register_control(control)

        ugui.standard_styler.draw_joystick(control)

        local position = control.position and ugui.internal.deep_clone(control.position) or {x = 0, y = 0}

        local pushed = ugui.internal.process_push(control)
        local ignored = BreitbandGraphics.is_point_inside_any_rectangle(
                ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects) and
            not control.topmost

        if ugui.internal.active_control == control.uid and not ignored then
            position.x = ugui.internal.clamp(
                ugui.internal.remap(ugui.internal.environment.mouse_position.x - control.rectangle.x, 0,
                    control.rectangle.width, -128, 128), -128, 128)
            position.y = ugui.internal.clamp(
                ugui.internal.remap(ugui.internal.environment.mouse_position.y - control.rectangle.y, 0,
                    control.rectangle.height, -128, 128), -128, 128)
        end

        return position
    end,

    ---Places a Trackbar/Slider
    ---
    ---Additional fields in the `control` table:
    ---
    --- `values` — `number` The trackbar's value with the range `0-1`
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ number The trackbar's value
    trackbar = function(control)
        ugui.internal.validate_and_register_control(control)

        if not ugui.internal.control_data[control.uid] then
            ugui.internal.control_data[control.uid] = {
                active = false,
            }
        end

        local pushed = ugui.internal.process_push(control)
        local value = control.value

        if ugui.internal.active_control == control.uid then
            if control.rectangle.width > control.rectangle.height then
                value = ugui.internal.clamp(
                    (ugui.internal.environment.mouse_position.x - control.rectangle.x) /
                    control.rectangle.width,
                    0, 1)
            else
                value = ugui.internal.clamp(
                    (ugui.internal.environment.mouse_position.y - control.rectangle.y) /
                    control.rectangle.height,
                    0, 1)
            end
        end

        ugui.standard_styler.draw_trackbar(control)

        return value
    end,

    ---Places a ComboBox/DropDownMenu
    ---
    ---Additional fields in the `control` table:
    ---
    --- `items` — `string[]` The items contained in the dropdown
    --- `selected_index` — `number` The selected index in the `items` array
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ number The selected index in the `items` array
    combobox = function(control)
        ugui.internal.validate_and_register_control(control)

        if not ugui.internal.control_data[control.uid] then
            ugui.internal.control_data[control.uid] = {
                is_open = false,
                hovered_index = control.selected_index,
            }
        end

        if control.is_enabled == false then
            ugui.internal.control_data[control.uid].is_open = false
        end

        if ugui.internal.is_mouse_just_down() and control.is_enabled ~= false then
            if BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                ugui.internal.control_data[control.uid].is_open = not ugui.internal.control_data
                    [control.uid].is_open
            else
                local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)
                if not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, {
                        x = control.rectangle.x,
                        y = control.rectangle.y + control.rectangle.height,
                        width = control.rectangle.width,
                        height = content_bounds.height,
                    }) then
                    ugui.internal.control_data[control.uid].is_open = false
                end
            end
        end

        local selected_index = control.selected_index

        if ugui.internal.control_data[control.uid].is_open and control.is_enabled ~= false then
            local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(control)

            local list_rect = {
                x = control.rectangle.x,
                y = control.rectangle.y + control.rectangle.height,
                width = control.rectangle.width,
                height = content_bounds.height,
            }
            ugui.internal.hittest_free_rects[#ugui.internal.hittest_free_rects + 1] = list_rect

            selected_index = ugui.listbox({
                uid = control.uid + 1,
                -- we tell the listbox to paint itself at the end of the frame, because we need it on top of all other controls
                topmost = true,
                rectangle = list_rect,
                items = control.items,
                selected_index = selected_index,
            })
        end

        ugui.standard_styler.draw_combobox(control)

        return selected_index
    end,
    ---Places a ListBox
    ---
    ---Additional fields in the `control` table:
    ---
    --- `items` — `string[]` The items contained in the dropdown
    --- `selected_index` — `number` The selected index in the `items` array
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ number The selected index in the `items` array
    listbox = function(_control)
        ugui.internal.validate_and_register_control(_control)

        if not ugui.internal.control_data[_control.uid] then
            ugui.internal.control_data[_control.uid] = {
                scroll_x = 0,
                scroll_y = 0,
            }
        end
        if not ugui.internal.control_data[_control.uid].scroll_x then
            ugui.internal.control_data[_control.uid].scroll_x = 0
        end
        if not ugui.internal.control_data[_control.uid].scroll_y then
            ugui.internal.control_data[_control.uid].scroll_y = 0
        end

        local content_bounds = ugui.standard_styler.get_desired_listbox_content_bounds(_control)
        local x_overflow = content_bounds.width > _control.rectangle.width
        local y_overflow = content_bounds.height > _control.rectangle.height

        local new_rectangle = ugui.internal.deep_clone(_control.rectangle)
        if x_overflow then
            new_rectangle.height = new_rectangle.height - ugui.standard_styler.scrollbar_thickness
        end
        if y_overflow then
            new_rectangle.width = new_rectangle.width - ugui.standard_styler.scrollbar_thickness
        end

        -- we need to adjust rectangle to fit scrollbars
        local control = ugui.internal.deep_clone(_control)
        control.rectangle = new_rectangle

        local pushed = ugui.internal.process_push(control)
        local ignored = BreitbandGraphics.is_point_inside_any_rectangle(
                ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects) and
            not control.topmost

        if ugui.internal.active_control == control.uid and not ignored then
            local relative_y = ugui.internal.environment.mouse_position.y - control.rectangle.y
            local new_index = math.ceil((relative_y + (ugui.internal.control_data[control.uid].scroll_y *
                    ((ugui.standard_styler.item_height * #control.items) - control.rectangle.height))) /
                ugui.standard_styler.item_height)
            -- we only assign the new index if it's within bounds, as
            -- this emulates windows commctl behaviour
            if new_index <= #control.items then
                control.selected_index = ugui.internal.clamp(new_index, 1, #control.items)
            end
        end

        if not ignored
            and (BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle)
                or ugui.internal.active_control == control.uid) then
            for key, _ in pairs(ugui.internal.get_just_pressed_keys()) do
                if key == 'up' then
                    control.selected_index = ugui.internal.clamp(control.selected_index - 1, 1, #control.items)
                end
                if key == 'down' then
                    control.selected_index = ugui.internal.clamp(control.selected_index + 1, 1, #control.items)
                end
                if not y_overflow then
                    if key == 'pageup' or key == 'home' then
                        control.selected_index = 1
                    end
                    if key == 'pagedown' or key == 'end' then
                        control.selected_index = #control.items
                    end
                end
            end
        end

        if not ignored
            and y_overflow
            and (BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle)
                or ugui.internal.active_control == control.uid) then
            local inc = 0
            if ugui.internal.is_mouse_wheel_up() then
                inc = -1 / #control.items
            end
            if ugui.internal.is_mouse_wheel_down() then
                inc = 1 / #control.items
            end

            for key, _ in pairs(ugui.internal.get_just_pressed_keys()) do
                if key == 'pageup' then
                    inc = -math.floor(control.rectangle.height / ugui.standard_styler.item_height) / #control.items
                end
                if key == 'pagedown' then
                    inc = math.floor(control.rectangle.height / ugui.standard_styler.item_height) / #control.items
                end
                if key == 'home' then
                    inc = -1
                end
                if key == 'end' then
                    inc = 1
                end
            end

            ugui.internal.control_data[control.uid].scroll_y = ugui.internal.clamp(
                ugui.internal.control_data[control.uid].scroll_y + inc, 0, 1)
        end


        if x_overflow then
            ugui.internal.control_data[control.uid].scroll_x = ugui.scrollbar({
                uid = control.uid + 1,
                is_enabled = control.is_enabled,
                rectangle = {
                    x = control.rectangle.x,
                    y = control.rectangle.y + control.rectangle.height,
                    width = control.rectangle.width,
                    height = ugui.standard_styler.scrollbar_thickness,
                },
                value = ugui.internal.control_data[control.uid].scroll_x,
                ratio = 1 / (content_bounds.width / control.rectangle.width),
            })
        end

        if y_overflow then
            ugui.internal.control_data[control.uid].scroll_y = ugui.scrollbar({
                uid = control.uid + 2,
                is_enabled = control.is_enabled,
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.scrollbar_thickness,
                    height = control.rectangle.height,
                },
                value = ugui.internal.control_data[control.uid].scroll_y,
                ratio = 1 / (content_bounds.height / control.rectangle.height),
            })
        end

        if control.topmost then
            ugui.internal.late_callbacks[#ugui.internal.late_callbacks + 1] = function()
                ugui.standard_styler.draw_listbox(control)
            end
        else
            ugui.standard_styler.draw_listbox(control)
        end


        return control.selected_index
    end,
    ---Places a ScrollBar
    ---
    ---Additional fields in the `control` table:
    ---
    --- `value` — `number` The items contained in the dropdown
    --- `ratio` — `number` The overscroll ratio
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ number The new value
    scrollbar = function(control)
        ugui.internal.validate_and_register_control(control)

        local pushed = ugui.internal.process_push(control)
        local is_horizontal = control.rectangle.width > control.rectangle.height

        -- if active and user clicks elsewhere, deactivate
        if ugui.internal.active_control == control.uid then
            if not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
                if ugui.internal.is_mouse_just_down() then
                    -- deactivate, then clear selection
                    ugui.internal.active_control = nil
                end
            end
        end

        if ugui.internal.active_control == control.uid and control.is_enabled ~= false and ugui.internal.environment.is_primary_down then
            local relative_mouse = {
                x = ugui.internal.environment.mouse_position.x - control.rectangle.x,
                y = ugui.internal.environment.mouse_position.y - control.rectangle.y,
            }
            local relative_mouse_down = {
                x = ugui.internal.mouse_down_position.x - control.rectangle.x,
                y = ugui.internal.mouse_down_position.y - control.rectangle.y,
            }
            local current
            local start
            if is_horizontal then
                current = relative_mouse.x / control.rectangle.width
                start = relative_mouse_down.x / control.rectangle.width
            else
                current = relative_mouse.y / control.rectangle.height
                start = relative_mouse_down.y / control.rectangle.height
            end
            control.value = ugui.internal.clamp(start + (current - start), 0, 1)
        end

        local thumb_rectangle
        -- we center the scrollbar around the translation value, and shrink it accordingly
        if is_horizontal then
            local scrollbar_width = control.rectangle.width * control.ratio
            local scrollbar_x = ugui.internal.remap(control.value, 0, 1, 0, control.rectangle.width - scrollbar_width)
            thumb_rectangle = {
                x = control.rectangle.x + scrollbar_x,
                y = control.rectangle.y,
                width = scrollbar_width,
                height = control.rectangle.height,
            }
        else
            local scrollbar_height = control.rectangle.height * control.ratio
            local scrollbar_y = ugui.internal.remap(control.value, 0, 1, 0, control.rectangle.height - scrollbar_height)
            thumb_rectangle = {
                x = control.rectangle.x,
                y = control.rectangle.y + scrollbar_y,
                width = control.rectangle.width,
                height = scrollbar_height,
            }
        end

        local visual_state = ugui.get_visual_state(control)
        if ugui.internal.active_control == control.uid and control.is_enabled ~= false and ugui.internal.environment.is_primary_down then
            visual_state = ugui.visual_states.active
        end
        ugui.standard_styler.draw_scrollbar(control.rectangle, thumb_rectangle, visual_state)

        return control.value
    end,

    ---Places a Menu
    ---
    ---Additional fields in the `control` table:
    ---
    --- `items` — `table[]` The items contained in the dropdown as (`{ enabled: boolean | nil, checked: boolean | nil, text: string }`)
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ table The interaction result as (`{ item: table | nil, dismissed: boolean }`). The `item` field is nil if no item was clicked.
    menu = function(control)

        -- Avoid tripping the control validation... it's going to be overwritten anyway
        if control.rectangle and not control.rectangle.width then
            control.rectangle.width = 0
        end
        if control.rectangle and not control.rectangle.height then
            control.rectangle.height = 0
        end

        ugui.internal.validate_and_register_control(control)

        if not ugui.internal.control_data[control.uid] then
            print("Top-level menu")
            ugui.internal.control_data[control.uid] = {
                hovered_index = nil,
                parent_rectangle = nil,
            }
        end

        -- We adjust the dimensions with what should fit the content
        local max_text_width = 0
        for _, item in pairs(control.items) do
            local size = BreitbandGraphics.get_text_size(item.text, ugui.standard_styler.font_size, ugui.standard_styler.font_name)
            if size.width > max_text_width then
                max_text_width = size.width
            end
        end

        control.rectangle.width = max_text_width + ugui.standard_styler.menu_item_left_padding + ugui.standard_styler.menu_item_right_padding
        control.rectangle.height = #control.items * ugui.standard_styler.menu_item_height

        -- Overflow avoidance: shift the X/Y position to avoid going out of bounds
        if control.rectangle.x + control.rectangle.width > ugui.internal.environment.window_size.x then
            local parent_rect = ugui.internal.control_data[control.uid].parent_rectangle
            -- If the menu has a parent and there's an overflow on the X axis, try snaking out of the situation by moving left of the menu
            if parent_rect then
                control.rectangle.x = parent_rect.x - control.rectangle.width + ugui.standard_styler.menu_overlap_size
            else
                control.rectangle.x = control.rectangle.x - (control.rectangle.x + control.rectangle.width - ugui.internal.environment.window_size.x)
            end
        end
        if control.rectangle.y + control.rectangle.height > ugui.internal.environment.window_size.y then
            control.rectangle.y = control.rectangle.y - (control.rectangle.y + control.rectangle.height - ugui.internal.environment.window_size.y)
        end

        local result = {
            item = nil,
            dismissed = false,
        }

        local mouse_inside_control = BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle)

        if control.is_enabled ~= false then
            ugui.internal.hittest_free_rects[#ugui.internal.hittest_free_rects + 1] = control.rectangle

            if ugui.internal.is_mouse_just_down() and not mouse_inside_control then
                -- This path is also reached when a subitem is clicked, so we'll delay clearing the hover indicies until the submenu has also given a result
                result.dismissed = true
            end

            if mouse_inside_control then
                local i = math.floor((ugui.internal.environment.mouse_position.y - control.rectangle.y) / ugui.standard_styler.menu_item_height) + 1
                local item = control.items[i]

                ugui.internal.control_data[control.uid].hovered_index = i

                if ugui.internal.is_mouse_just_up() then
                    if (item.enabled == nil or item.enabled == true) and (item.items == nil or #item.items == 0) then
                        result.item = item
                    end
                end
            end

            if ugui.internal.control_data[control.uid].hovered_index ~= nil then
                local i = ugui.internal.control_data[control.uid].hovered_index
                local item = control.items[i]
                if item.items and (item.enabled == nil or item.enabled == true) then
                    local submenu_uid = control.uid + 1

                    if not ugui.internal.control_data[submenu_uid] then
                        ugui.internal.control_data[submenu_uid] = {
                            hovered_index = nil,
                            parent_rectangle = ugui.internal.deep_clone(control.rectangle),
                        }
                    end

                    local submenu_result = ugui.menu({
                        uid = submenu_uid,
                        rectangle = {
                            x = control.rectangle.x + control.rectangle.width - ugui.standard_styler.menu_overlap_size,
                            y = control.rectangle.y + ((i - 1) * ugui.standard_styler.menu_item_height),
                        },
                        items = item.items,
                    })

                    if submenu_result.item then
                        result.dismissed = false
                        result.item = submenu_result.item
                    end
                end
            end
        end

        if result.dismissed or result.item then
            -- We need to clear the hover index or all menus in this tree, which means a massively annoying tree traversal
            local function clear_hover_index_for_menu(uid, items)
                if ugui.internal.control_data[uid] and ugui.internal.control_data[uid].hovered_index then
                    ugui.internal.control_data[uid].hovered_index = nil
                end
                for _, item in pairs(items) do
                    if item.items then
                        clear_hover_index_for_menu(uid + 1, item.items)
                    end
                end
            end
            clear_hover_index_for_menu(control.uid, control.items)
        end

        -- Menus are late-drawn, but in reverse order since submenus must overlap and draw over the parent
        table.insert(ugui.internal.late_callbacks, 1, function()
            ugui.standard_styler.draw_menu(control, control.rectangle)
        end)

        return result
    end,
}
