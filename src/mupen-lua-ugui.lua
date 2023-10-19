-- mupen-lua-ugui 1.2.2

if not emu.set_renderer then
    print('BreitbandGraphics requires mupen64-rr-lua 1.1.4 or above\r\n')
end

-- Specify D2D renderer
emu.set_renderer(2)

BreitbandGraphics = {
    --- Converts a color value to its corresponding hexadecimal representation
    --- @param color table The color value to convert
    --- @return _ string The hexadecimal representation of the color
    color_to_hex = function(color)
        return string.format('#%06X',
            (color.r * 0x10000) + (color.g * 0x100) + color.b)
    end,
    --- Converts a color's hexadecimal representation into a color table
    --- @param hex string The hexadecimal color to convert
    --- @return _ table The color
    hex_to_color = function(hex)
        return
        {
            r = tonumber(hex:sub(2, 3), 16),
            g = tonumber(hex:sub(4, 5), 16),
            b = tonumber(hex:sub(6, 7), 16),
        }
    end,
    --- Creates a color with the red, green and blue channels assigned to the specified value
    --- @param value number The value to be used for the red, green and blue channels
    --- @return _ table The color with the red, green and blue channels set to the specified value
    repeated_to_color = function(value)
        return
        {
            r = value,
            g = value,
            b = value,
        }
    end,
    ---Inverts a color
    ---@param value table The color value to invert, with byte-range channels (0-255)
    ---@return _ table The inverted color
    invert_color = function(value)
        return {
            r = 255 - value.r,
            g = 255 - value.r,
            b = 255 - value.r,
            a = value.a,
        }
    end,
    --- A collection of common colors as tables with red, green and blue channels channels ranging from `0` to `255`
    colors = {
        white = {
            r = 255,
            g = 255,
            b = 255,
        },
        black = {
            r = 0,
            g = 0,
            b = 0,
        },
        red = {
            r = 255,
            g = 0,
            b = 0,
        },
        green = {
            r = 0,
            g = 255,
            b = 0,
        },
        blue = {
            r = 0,
            g = 0,
            b = 255,
        },
        yellow = {
            r = 255,
            g = 255,
            b = 0,
        },
        orange = {
            r = 255,
            g = 128,
            b = 0,
        },
        magenta = {
            r = 255,
            g = 0,
            b = 255,
        },
    },

    ---Whether a point is inside a rectangle
    ---@param point table `{x, y}`
    ---@param rectangle table `{x, y, width, height}`
    is_point_inside_rectangle = function(point, rectangle)
        return point.x > rectangle.x and
            point.y > rectangle.y and
            point.x < rectangle.x + rectangle.width and
            point.y < rectangle.y + rectangle.height;
    end,

    ---Whether a point is inside any of the rectangles
    ---@param point table `{x, y}`
    ---@param rectangles table[] `{{x, y, width, height}}`
    is_point_inside_any_rectangle = function(point, rectangles)
        for i = 1, #rectangles, 1 do
            if BreitbandGraphics.is_point_inside_rectangle(point, rectangles[i]) then
                return true
            end
        end
        return false
    end,

    --- Creates a rectangle inflated around its center by the specified amount
    --- @param rectangle table The rectangle to be inflated
    --- @param amount number The amount to inflate the rectangle by
    --- @return _ table The inflated rectangle
    inflate_rectangle = function(rectangle, amount)
        return {
            x = rectangle.x - amount,
            y = rectangle.y - amount,
            width = rectangle.width + amount * 2,
            height = rectangle.height + amount * 2,
        }
    end,

    --- Maps a color's byte-range channels `0-255` to `0-1`
    --- @param color table The color to be converted
    --- @return _ table The color with remapped channels
    color_to_float = function(color)
        return {
            r = (color.r and (color.r / 255.0) or 0.0),
            g = (color.g and (color.g / 255.0) or 0.0),
            b = (color.b and (color.b / 255.0) or 0.0),
            a = (color.a and (color.a / 255.0) or 1.0),
        }
    end,

    bitmap_cache = {},
    ---Measures the size of a string
    ---@param text string The string to be measured
    ---@param font_size number The font size
    ---@param font_name string The font name
    ---@return _ table The text's bounding box as `{x, y}`
    get_text_size = function(text, font_size, font_name)
        return d2d.get_text_size(text, font_name, font_size, 99999999, 99999999);
    end,
    ---Draws a rectangle's outline
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param thickness number The outline's thickness
    draw_rectangle = function(rectangle, color, thickness)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_rectangle(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, float_color.r, float_color.g, float_color.b, 1.0, thickness)
    end,
    ---Draws a rectangle
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    fill_rectangle = function(rectangle, color)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.fill_rectangle(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, float_color.r, float_color.g, float_color.b, 1.0)
    end,
    ---Draws a rounded rectangle's outline
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param radii table The corner radii as `{x, y}`
    ---@param thickness number The outline's thickness
    draw_rounded_rectangle = function(rectangle, color, radii, thickness)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_rounded_rectangle(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, radii.x, radii.y, float_color.r, float_color.g, float_color.b, 1.0,
            thickness)
    end,
    ---Fills a rounded rectangle
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param radii table The corner radii as `{x, y}`
    fill_rounded_rectangle = function(rectangle, color, radii)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.fill_rounded_rectangle(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, radii.x, radii.y, float_color.r, float_color.g, float_color.b, 1.0)
    end,
    ---Draws an ellipse's outline
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param thickness number The outline's thickness
    draw_ellipse = function(rectangle, color, thickness)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_ellipse(rectangle.x + rectangle.width / 2, rectangle.y + rectangle.height / 2,
            rectangle.width / 2, rectangle.height / 2, float_color.r, float_color.g, float_color.b, 1.0,
            thickness)
    end,
    ---Draws an ellipse
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    fill_ellipse = function(rectangle, color)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.fill_ellipse(rectangle.x + rectangle.width / 2, rectangle.y + rectangle.height / 2,
            rectangle.width / 2, rectangle.height / 2, float_color.r, float_color.g, float_color.b, 1.0)
    end,
    ---Draws text
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param horizontal_alignment string The text's horizontal alignment inside the bounding rectangle. `center` | `start` | `end` | `stretch`
    ---@param vertical_alignment string The text's vertical alignment inside the bounding rectangle. `center` | `start` | `end` | `stretch`
    ---@param style table The miscellaneous text styling as `{is_bold, is_italic, clip, grayscale, aliased}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param font_size number The font size
    ---@param font_name string The font name
    ---@param text string The text
    draw_text = function(rectangle, horizontal_alignment, vertical_alignment, style, color, font_size, font_name,
                         text)
        if text == nil then
            text = ''
        end

        local d_horizontal_alignment = 0
        local d_vertical_alignment = 0
        local d_style = 0
        local d_weight = 400
        local d_options = 0
        local d_text_antialias_mode = 1

        if horizontal_alignment == 'center' then
            d_horizontal_alignment = 2
        elseif horizontal_alignment == 'start' then
            d_horizontal_alignment = 0
        elseif horizontal_alignment == 'end' then
            d_horizontal_alignment = 1
        elseif horizontal_alignment == 'stretch' then
            d_horizontal_alignment = 3
        end

        if vertical_alignment == 'center' then
            d_vertical_alignment = 2
        elseif vertical_alignment == 'start' then
            d_vertical_alignment = 0
        elseif vertical_alignment == 'end' then
            d_vertical_alignment = 1
        end

        if style.is_bold then
            d_weight = 700
        end
        if style.is_italic then
            d_style = 2
        end
        if style.clip then
            d_options = d_options | 0x00000002
        end
        if style.grayscale then
            d_text_antialias_mode = 2
        end
        if style.aliased then
            d_text_antialias_mode = 3
        end
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.set_text_antialias_mode(d_text_antialias_mode)
        d2d.draw_text(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, float_color.r, float_color.g, float_color.b, 1.0, text, font_name,
            font_size, d_weight, d_style, d_horizontal_alignment, d_vertical_alignment, d_options)
    end,
    ---Draws a line
    ---@param from table The start point as `{x, y}`
    ---@param to table The end point as `{x, y}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param thickness number The line's thickness
    draw_line = function(from, to, color, thickness)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_line(from.x, from.y, to.x, to.y, float_color.r, float_color.g, float_color.b, 1.0,
            thickness)
    end,
    ---Pushes a clip layer to the clip stack
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    push_clip = function(rectangle)
        d2d.push_clip(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height)
    end,
    --- Removes the topmost clip layer from the clip stack
    pop_clip = function()
        d2d.pop_clip()
    end,
    ---Draws an image
    ---@param destination_rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param source_rectangle table The rectangle from the source image as `{x, y, width, height}`
    ---@param path string The image's absolute path on disk
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param filter string The texture filter to be used while drawing the image. `nearest` | `linear`
    draw_image = function(destination_rectangle, source_rectangle, path, color, filter)
        if not BreitbandGraphics.bitmap_cache[path] then
            print('Loaded image from ' .. path)
            d2d.load_image(path, path)
            BreitbandGraphics.bitmap_cache[path] = path
        end
        if not filter then
            filter = 'nearest'
        end
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_image(destination_rectangle.x, destination_rectangle.y,
            destination_rectangle.x + destination_rectangle.width,
            destination_rectangle.y + destination_rectangle.height,
            source_rectangle.x, source_rectangle.y, source_rectangle.x + source_rectangle.width,
            source_rectangle.y + source_rectangle.height, path, float_color.a, filter == 'nearest' and 0 or 1)
    end,
    ---Gets an image's metadata
    ---@param path string The image's absolute path on disk
    get_image_info = function(path)
        if not BreitbandGraphics.bitmap_cache[path] then
            print('Loaded image from ' .. path)
            d2d.load_image(path, path)
            BreitbandGraphics.bitmap_cache[path] = path
        end
        return d2d.get_image_info(path)
    end,
}

Mupen_lua_ugui = {

    internal = {
        -- per-uid library-side data, such as scroll position
        control_data = {},

        -- the current input state
        input_state = nil,

        -- the last frame's input state
        previous_input_state = nil,

        -- the position of the mouse at the last click
        mouse_down_position = { x = 0, y = 0 },

        -- the currently active control's uid
        -- TODO: maybe merge into control_data(?)
        active_control_uid = nil,

        -- rectangles which are excluded from hittesting (e.g.: the popped up list of a combobox)
        hittest_free_rects = {},

        -- array of functions which will be called at the end of the frame
        late_callbacks = {},

        deep_clone = function(obj, seen)
            if type(obj) ~= 'table' then return obj end
            if seen and seen[obj] then return seen[obj] end
            local s = seen or {}
            local res = setmetatable({}, getmetatable(obj))
            s[obj] = res
            for k, v in pairs(obj) do res[Mupen_lua_ugui.internal.deep_clone(k, s)] = Mupen_lua_ugui.internal.deep_clone(
                v, s) end
            return res
        end,
        remove_range = function(string, start_index, end_index)
            if start_index > end_index then
                start_index, end_index = end_index, start_index
            end
            return string.sub(string, 1, start_index - 1) .. string.sub(string, end_index)
        end,
        is_mouse_just_down = function()
            return Mupen_lua_ugui.internal.input_state.is_primary_down and
                not Mupen_lua_ugui.internal.previous_input_state.is_primary_down;
        end,
        is_mouse_wheel_up = function()
            return Mupen_lua_ugui.internal.input_state.wheel == 1
        end,
        is_mouse_wheel_down = function()
            return Mupen_lua_ugui.internal.input_state.wheel == -1
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
            return math.max(math.min(value, max), min)
        end,
        get_just_pressed_keys = function()
            local keys = {}
            for key, _ in pairs(Mupen_lua_ugui.internal.input_state.held_keys) do
                if not Mupen_lua_ugui.internal.previous_input_state.held_keys[key] then
                    keys[key] = 1
                end
            end
            return keys
        end,
        is_pushed = function(control)
            local base = Mupen_lua_ugui.internal.is_mouse_just_down()
                and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position,
                    control.rectangle)
                and control.is_enabled

            if not control.topmost and BreitbandGraphics.is_point_inside_any_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, Mupen_lua_ugui.internal.hittest_free_rects) then
                base = false
            end
            return base
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
        if not control.is_enabled then
            return Mupen_lua_ugui.visual_states.disabled
        end

        local is_inside = BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position,
                control.rectangle)
            and
            not BreitbandGraphics.is_point_inside_any_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position,
                Mupen_lua_ugui.internal.hittest_free_rects)

        local mouse_down_inside = BreitbandGraphics.is_point_inside_rectangle(
            Mupen_lua_ugui.internal.mouse_down_position, control.rectangle)
            and
            not BreitbandGraphics.is_point_inside_any_rectangle(Mupen_lua_ugui.internal.mouse_down_position,
                Mupen_lua_ugui.internal.hittest_free_rects)

        if is_inside and not Mupen_lua_ugui.internal.input_state.is_primary_down then
            return Mupen_lua_ugui.visual_states.hovered
        end

        if mouse_down_inside and Mupen_lua_ugui.internal.input_state.is_primary_down and not is_inside then
            return Mupen_lua_ugui.visual_states.hovered
        end

        if is_inside and Mupen_lua_ugui.internal.input_state.is_primary_down then
            return Mupen_lua_ugui.visual_states.active
        end

        return Mupen_lua_ugui.visual_states.normal
    end,

    --- A collection of stylers, which are responsible for drawing the UI
    standard_styler = {
        textbox_padding = 2,
        track_thickness = 2,
        bar_width = 6,
        bar_height = 16,
        item_height = 15,
        font_size = 12,
        scrollbar_thickness = 17,
        font_name = 'MS Shell Dlg 2',
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
        draw_raised_frame = function(control, visual_state)
            local back_color = BreitbandGraphics.repeated_to_color(225)
            local border_color = BreitbandGraphics.repeated_to_color(173)

            if visual_state == Mupen_lua_ugui.visual_states.active then
                back_color = {
                    r = 204,
                    g = 228,
                    b = 247,
                }
                border_color = {
                    r = 0,
                    g = 84,
                    b = 153,
                }
            elseif visual_state == Mupen_lua_ugui.visual_states.hovered then
                back_color = {
                    r = 229,
                    g = 241,
                    b = 251,
                }
                border_color = {
                    r = 0,
                    g = 120,
                    b = 215,
                }
            elseif visual_state == Mupen_lua_ugui.visual_states.disabled then
                back_color = BreitbandGraphics.repeated_to_color(204)
                border_color = BreitbandGraphics.repeated_to_color(191)
            end

            BreitbandGraphics.fill_rectangle(control.rectangle,
                border_color)
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                back_color)
        end,
        draw_edit_frame = function(control, rectangle, visual_state)
            local back_color = BreitbandGraphics.colors.white
            local border_color = BreitbandGraphics.repeated_to_color(122)


            if visual_state == Mupen_lua_ugui.visual_states.hovered then
                border_color = BreitbandGraphics.repeated_to_color(23)
            elseif visual_state == Mupen_lua_ugui.visual_states.active then
                border_color = {
                    r = 0,
                    g = 84,
                    b = 153,
                }
            elseif visual_state == Mupen_lua_ugui.visual_states.disabled then
                back_color = BreitbandGraphics.repeated_to_color(240)
                border_color = BreitbandGraphics.repeated_to_color(204)
            end
            BreitbandGraphics.fill_rectangle(rectangle,
                border_color)
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                back_color)
        end,
        draw_list_frame = function(rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(rectangle, 1), {
                r = 130,
                g = 135,
                b = 144,
            })
            BreitbandGraphics.fill_rectangle(rectangle, {
                r = 255,
                g = 255,
                b = 255,
            })
        end,
        draw_list_item = function(item, rectangle, visual_state)
            if visual_state == Mupen_lua_ugui.visual_states.active then
                local accent_color = {
                    r = 0,
                    g = 120,
                    b = 215,
                }

                if visual_state == Mupen_lua_ugui.visual_states.disabled then
                    accent_color = BreitbandGraphics.repeated_to_color(204)
                end


                BreitbandGraphics.fill_rectangle(rectangle, accent_color)
            end


            BreitbandGraphics.draw_text({
                    x = rectangle.x + 2,
                    y = rectangle.y,
                    width = rectangle.width,
                    height = rectangle.height,
                }, 'start', 'center', { clip = true },
                Mupen_lua_ugui.standard_styler.list_text_colors[visual_state],
                Mupen_lua_ugui.standard_styler.font_size,
                Mupen_lua_ugui.standard_styler.font_name,
                item)
        end,
        draw_scrollbar = function(container_rectangle, thumb_rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(container_rectangle, BreitbandGraphics.repeated_to_color(240))
            BreitbandGraphics.fill_rectangle(thumb_rectangle, BreitbandGraphics.repeated_to_color(204))
        end,
        draw_list = function(control, rectangle, selected_index)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)
            Mupen_lua_ugui.standard_styler.draw_list_frame(rectangle, visual_state)

            -- item y position:
            -- y = (20 * (i - 1)) - (y_translation * ((20 * #control.items) - control.rectangle.height))
            local y_translation = Mupen_lua_ugui.internal.control_data[control.uid].y_translation and
                Mupen_lua_ugui.internal.control_data[control.uid].y_translation or 0

            local index_begin = (y_translation *
                    ((Mupen_lua_ugui.standard_styler.item_height * #control.items) - rectangle.height)) /
                Mupen_lua_ugui.standard_styler.item_height

            local index_end = (rectangle.height + (y_translation *
                    ((Mupen_lua_ugui.standard_styler.item_height * #control.items) - rectangle.height))) /
                Mupen_lua_ugui.standard_styler.item_height

            index_begin = math.max(index_begin, 0)
            index_end = math.min(index_end, #control.items)

            BreitbandGraphics.push_clip(rectangle)

            for i = math.floor(index_begin), math.ceil(index_end), 1 do
                local y = (Mupen_lua_ugui.standard_styler.item_height * (i - 1)) -
                    (y_translation * ((Mupen_lua_ugui.standard_styler.item_height * #control.items) - rectangle.height))

                local item_visual_state = Mupen_lua_ugui.visual_states.normal
                if not control.is_enabled then
                    item_visual_state = Mupen_lua_ugui.visual_states.disabled
                end

                if selected_index == i then
                    item_visual_state = Mupen_lua_ugui.visual_states.active
                end

                Mupen_lua_ugui.standard_styler.draw_list_item(control.items[i], {
                    x = rectangle.x,
                    y = rectangle.y + y,
                    width = rectangle.width,
                    height = Mupen_lua_ugui.standard_styler.item_height,
                }, item_visual_state)
            end


            if #control.items * Mupen_lua_ugui.standard_styler.item_height > rectangle.height then
                local scrollbar_y = y_translation * rectangle
                    .height
                local scrollbar_height = 2 * Mupen_lua_ugui.standard_styler.item_height *
                    (rectangle.height / (Mupen_lua_ugui.standard_styler.item_height * #control.items))
                -- we center the scrollbar around the translation value

                scrollbar_y = scrollbar_y - scrollbar_height / 2
                scrollbar_y = Mupen_lua_ugui.internal.clamp(scrollbar_y, 0, rectangle.height - scrollbar_height)

                local container_rectangle = {
                    x = rectangle.x + rectangle.width - Mupen_lua_ugui.standard_styler.scrollbar_thickness,
                    y = rectangle.y,
                    width = Mupen_lua_ugui.standard_styler.scrollbar_thickness,
                    height = rectangle.height,
                }
                local thumb_rectangle = {
                    x = rectangle.x + rectangle.width - Mupen_lua_ugui.standard_styler.scrollbar_thickness,
                    y = rectangle.y + scrollbar_y,
                    width = Mupen_lua_ugui.standard_styler.scrollbar_thickness,
                    height = scrollbar_height,
                }
                Mupen_lua_ugui.standard_styler.draw_scrollbar(container_rectangle, thumb_rectangle, visual_state)
            end

            BreitbandGraphics.pop_clip()
        end,
        draw_button = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            -- override for toggle_button
            if control.is_checked and control.is_enabled then
                visual_state = Mupen_lua_ugui.visual_states.active
            end

            Mupen_lua_ugui.standard_styler.draw_raised_frame(control, visual_state)

            BreitbandGraphics.draw_text(control.rectangle, 'center', 'center',
                { clip = true },
                Mupen_lua_ugui.standard_styler.raised_frame_text_colors[visual_state],
                Mupen_lua_ugui.standard_styler.font_size,
                Mupen_lua_ugui.standard_styler.font_name, control.text)
        end,
        draw_togglebutton = function(control)
            Mupen_lua_ugui.standard_styler.draw_button(control)
        end,
        draw_carrousel_button = function(control)
            -- add a "fake" text field
            local copy = Mupen_lua_ugui.internal.deep_clone(control)
            copy.text = control.items[control.selected_index]
            Mupen_lua_ugui.standard_styler.draw_button(copy)

            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            -- draw the arrows
            BreitbandGraphics.draw_text({
                    x = control.rectangle.x + Mupen_lua_ugui.standard_styler.textbox_padding,
                    y = control.rectangle.y,
                    width = control.rectangle.width - Mupen_lua_ugui.standard_styler.textbox_padding * 2,
                    height = control.rectangle.height,
                }, 'start', 'center', {}, Mupen_lua_ugui.standard_styler.raised_frame_text_colors[visual_state],
                Mupen_lua_ugui.standard_styler.font_size,
                'Segoe UI Mono', '<')
            BreitbandGraphics.draw_text({
                    x = control.rectangle.x + Mupen_lua_ugui.standard_styler.textbox_padding,
                    y = control.rectangle.y,
                    width = control.rectangle.width - Mupen_lua_ugui.standard_styler.textbox_padding * 2,
                    height = control.rectangle.height,
                }, 'end', 'center', {}, Mupen_lua_ugui.standard_styler.raised_frame_text_colors[visual_state],
                Mupen_lua_ugui.standard_styler.font_size,
                'Segoe UI Mono', '>')
        end,
        draw_textbox = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            if Mupen_lua_ugui.internal.active_control_uid == control.uid and control.is_enabled then
                visual_state = Mupen_lua_ugui.visual_states.active
            end
            Mupen_lua_ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

            local should_visualize_selection = not (Mupen_lua_ugui.internal.control_data[control.uid].selection_start == nil) and
                not (Mupen_lua_ugui.internal.control_data[control.uid].selection_end == nil) and control.is_enabled and
                not (Mupen_lua_ugui.internal.control_data[control.uid].selection_start == Mupen_lua_ugui.internal.control_data[control.uid].selection_end)

            if should_visualize_selection then
                local string_to_selection_start = control.text:sub(1,
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_start - 1)
                local string_to_selection_end = control.text:sub(1,
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_end - 1)

                BreitbandGraphics.fill_rectangle({
                        x = control.rectangle.x +
                            BreitbandGraphics.get_text_size(string_to_selection_start,
                                Mupen_lua_ugui.standard_styler.font_size,
                                Mupen_lua_ugui.standard_styler.font_name)
                            .width + Mupen_lua_ugui.standard_styler.textbox_padding,
                        y = control.rectangle.y,
                        width = BreitbandGraphics.get_text_size(string_to_selection_end,
                                Mupen_lua_ugui.standard_styler.font_size,
                                Mupen_lua_ugui.standard_styler.font_name)
                            .width -
                            BreitbandGraphics.get_text_size(string_to_selection_start,
                                Mupen_lua_ugui.standard_styler.font_size,
                                Mupen_lua_ugui.standard_styler.font_name)
                            .width,
                        height = control.rectangle.height,
                    },
                    BreitbandGraphics.hex_to_color('#0078D7'))
            end

            BreitbandGraphics.draw_text({
                    x = control.rectangle.x + Mupen_lua_ugui.standard_styler.textbox_padding,
                    y = control.rectangle.y,
                    width = control.rectangle.width - Mupen_lua_ugui.standard_styler.textbox_padding * 2,
                    height = control.rectangle.height,
                }, 'start', 'start', { clip = true },
                Mupen_lua_ugui.standard_styler.edit_frame_text_colors[visual_state],
                Mupen_lua_ugui.standard_styler.font_size,
                Mupen_lua_ugui.standard_styler.font_name, control.text)

            if should_visualize_selection then
                local lower = Mupen_lua_ugui.internal.control_data[control.uid].selection_start
                local higher = Mupen_lua_ugui.internal.control_data[control.uid].selection_end
                if Mupen_lua_ugui.internal.control_data[control.uid].selection_start > Mupen_lua_ugui.internal.control_data[control.uid].selection_end then
                    lower = Mupen_lua_ugui.internal.control_data[control.uid].selection_end
                    higher = Mupen_lua_ugui.internal.control_data[control.uid].selection_start
                end

                local string_to_selection_start = control.text:sub(1,
                    lower - 1)
                local string_to_selection_end = control.text:sub(1,
                    higher - 1)

                local selection_start_x = control.rectangle.x +
                    BreitbandGraphics.get_text_size(string_to_selection_start,
                        Mupen_lua_ugui.standard_styler.font_size,
                        Mupen_lua_ugui.standard_styler.font_name).width +
                    Mupen_lua_ugui.standard_styler.textbox_padding

                local selection_end_x = control.rectangle.x +
                    BreitbandGraphics.get_text_size(string_to_selection_end,
                        Mupen_lua_ugui.standard_styler.font_size,
                        Mupen_lua_ugui.standard_styler.font_name).width +
                    Mupen_lua_ugui.standard_styler.textbox_padding

                BreitbandGraphics.push_clip({
                    x = selection_start_x,
                    y = control.rectangle.y,
                    width = selection_end_x - selection_start_x,
                    height = control.rectangle.height,
                })
                BreitbandGraphics.draw_text({
                        x = control.rectangle.x + Mupen_lua_ugui.standard_styler.textbox_padding,
                        y = control.rectangle.y,
                        width = control.rectangle.width - Mupen_lua_ugui.standard_styler.textbox_padding * 2,
                        height = control.rectangle.height,
                    }, 'start', 'start', { clip = true },
                    BreitbandGraphics.invert_color(Mupen_lua_ugui.standard_styler.edit_frame_text_colors
                        [visual_state]),
                    Mupen_lua_ugui.standard_styler.font_size,
                    Mupen_lua_ugui.standard_styler.font_name, control.text)
                BreitbandGraphics.pop_clip()
            end


            local string_to_caret = control.text:sub(1, Mupen_lua_ugui.internal.control_data[control.uid].caret_index - 1)
            local caret_x = BreitbandGraphics.get_text_size(string_to_caret,
                    Mupen_lua_ugui.standard_styler.font_size,
                    Mupen_lua_ugui.standard_styler.font_name).width +
                Mupen_lua_ugui.standard_styler.textbox_padding

            if visual_state == Mupen_lua_ugui.visual_states.active and math.floor(os.clock() * 2) % 2 == 0 and not should_visualize_selection then
                BreitbandGraphics.draw_line({
                    x = control.rectangle.x + caret_x,
                    y = control.rectangle.y + 2,
                }, {
                    x = control.rectangle.x + caret_x,
                    y = control.rectangle.y +
                        math.max(15,
                            BreitbandGraphics.get_text_size(string_to_caret, 12,
                                Mupen_lua_ugui.standard_styler.font_name)
                            .height), -- TODO: move text measurement into BreitbandGraphics
                }, {
                    r = 0,
                    g = 0,
                    b = 0,
                }, 1)
            end
        end,
        draw_joystick = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            -- joystick has no hover or active states
            if not (visual_state == Mupen_lua_ugui.visual_states.disabled) then
                visual_state = Mupen_lua_ugui.visual_states.normal
            end

            local back_color = BreitbandGraphics.colors.white
            local outline_color = BreitbandGraphics.colors.black
            local tip_color = {
                r = 255,
                g = 0,
                b = 0,
            }
            local line_color = {
                r = 0,
                g = 0,
                b = 255,
            }

            if visual_state == Mupen_lua_ugui.visual_states.disabled then
                outline_color = BreitbandGraphics.repeated_to_color(191)
                tip_color = {
                    r = 255,
                    g = 128,
                    b = 128,
                }
                line_color = {
                    r = 128,
                    g = 128,
                    b = 255,
                }
            end

            local stick_position = {
                x = Mupen_lua_ugui.internal.remap(control.position.x, 0, 1, control.rectangle.x,
                    control.rectangle.x + control.rectangle.width),
                y = Mupen_lua_ugui.internal.remap(control.position.y, 0, 1, control.rectangle.y,
                    control.rectangle.y + control.rectangle.height),
            }
            Mupen_lua_ugui.standard_styler.draw_raised_frame(control, visual_state)
            BreitbandGraphics.fill_ellipse(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                back_color)
            BreitbandGraphics.draw_ellipse(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                outline_color, 1)
            BreitbandGraphics.draw_line({
                x = control.rectangle.x + control.rectangle.width / 2,
                y = control.rectangle.y,
            }, {
                x = control.rectangle.x + control.rectangle.width / 2,
                y = control.rectangle.y + control.rectangle.height,
            }, outline_color, 1)
            BreitbandGraphics.draw_line({
                x = control.rectangle.x,
                y = control.rectangle.y + control.rectangle.height / 2,
            }, {
                x = control.rectangle.x + control.rectangle.width,
                y = control.rectangle.y + control.rectangle.height / 2,
            }, outline_color, 1)

            BreitbandGraphics.draw_line({
                x = control.rectangle.x + control.rectangle.width / 2,
                y = control.rectangle.y + control.rectangle.height / 2,
            }, {
                x = stick_position.x,
                y = stick_position.y,
            }, line_color, 3)
            local tip_size = 8
            BreitbandGraphics.fill_ellipse({
                x = stick_position.x - tip_size / 2,
                y = stick_position.y - tip_size / 2,
                width = tip_size,
                height = tip_size,
            }, tip_color)
        end,
        draw_track = function(control, visual_state, is_horizontal)
            local track_color = {
                r = 231,
                g = 234,
                b = 234,
            }
            local track_rectangle = {}
            local track_border_color = BreitbandGraphics.repeated_to_color(214)
            if not is_horizontal then
                track_rectangle = {
                    x = control.rectangle.x + control.rectangle.width / 2 -
                        Mupen_lua_ugui.standard_styler.track_thickness / 2,
                    y = control.rectangle.y,
                    width = Mupen_lua_ugui.standard_styler.track_thickness,
                    height = control.rectangle.height,
                }
            else
                track_rectangle = {
                    x = control.rectangle.x,
                    y = control.rectangle.y + control.rectangle.height / 2 -
                        Mupen_lua_ugui.standard_styler.track_thickness / 2,
                    width = control.rectangle.width,
                    height = Mupen_lua_ugui.standard_styler.track_thickness,
                }
            end

            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(track_rectangle, 1),
                track_border_color)
            BreitbandGraphics.fill_rectangle(track_rectangle, track_color)
        end,
        draw_thumb = function(control, visual_state, is_horizontal, value)
            local head_color = {
                r = 0,
                g = 122,
                b = 217,
            }
            if visual_state == Mupen_lua_ugui.visual_states.hovered then
                head_color = BreitbandGraphics.repeated_to_color(23)
            elseif visual_state == Mupen_lua_ugui.visual_states.active or visual_state == Mupen_lua_ugui.visual_states.disabled then
                head_color = BreitbandGraphics.repeated_to_color(204)
            end

            local head_rectangle = {}
            local effective_bar_height = math.min(
                (is_horizontal and control.rectangle.height or control.rectangle.width) * 2,
                Mupen_lua_ugui.standard_styler.bar_height)
            if not is_horizontal then
                head_rectangle = {
                    x = control.rectangle.x + control.rectangle.width / 2 -
                        effective_bar_height / 2,
                    y = control.rectangle.y + (value * control.rectangle.height) -
                        Mupen_lua_ugui.standard_styler.bar_width / 2,
                    width = effective_bar_height,
                    height = Mupen_lua_ugui.standard_styler.bar_width,
                }
            else
                head_rectangle = {
                    x = control.rectangle.x + (value * control.rectangle.width) -
                        Mupen_lua_ugui.standard_styler.bar_width / 2,
                    y = control.rectangle.y + control.rectangle.height / 2 -
                        effective_bar_height / 2,
                    width = Mupen_lua_ugui.standard_styler.bar_width,
                    height = effective_bar_height,
                }
            end
            BreitbandGraphics.fill_rectangle(head_rectangle, head_color)
        end,
        draw_trackbar = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            if Mupen_lua_ugui.internal.active_control_uid == control.uid and control.is_enabled then
                visual_state = Mupen_lua_ugui.visual_states.active
            end

            local is_horizontal = control.rectangle.width > control.rectangle.height

            Mupen_lua_ugui.standard_styler.draw_track(control, visual_state, is_horizontal)
            Mupen_lua_ugui.standard_styler.draw_thumb(control, visual_state, is_horizontal, control
                .value)
        end,
        draw_combobox = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            if Mupen_lua_ugui.internal.control_data[control.uid].is_open and control.is_enabled then
                visual_state = Mupen_lua_ugui.visual_states.active
            end

            Mupen_lua_ugui.standard_styler.draw_raised_frame(control, visual_state)

            local text_color = Mupen_lua_ugui.standard_styler.raised_frame_text_colors[visual_state]

            BreitbandGraphics.draw_text({
                    x = control.rectangle.x + Mupen_lua_ugui.standard_styler.textbox_padding * 2,
                    y = control.rectangle.y,
                    width = control.rectangle.width,
                    height = control.rectangle.height,
                }, 'start', 'center', { clip = true }, text_color, Mupen_lua_ugui.standard_styler.font_size,
                Mupen_lua_ugui.standard_styler.font_name,
                control.items[control.selected_index])

            BreitbandGraphics.draw_text({
                    x = control.rectangle.x,
                    y = control.rectangle.y,
                    width = control.rectangle.width - Mupen_lua_ugui.standard_styler.textbox_padding * 4,
                    height = control.rectangle.height,
                }, 'end', 'center', { clip = true }, text_color, Mupen_lua_ugui.standard_styler.font_size,
                'Segoe UI Mono', 'v')
        end,

        draw_listbox = function(control)
            Mupen_lua_ugui.standard_styler.draw_list(control, control.rectangle, control.selected_index)
        end,
    },

    ---Begins a new frame
    ---@param input_state table A table describing the state of the user's input devices as `{ mouse_position = {x, y}, wheel, is_primary_down, held_keys }`
    begin_frame = function(input_state)
        if not Mupen_lua_ugui.internal.input_state then
            Mupen_lua_ugui.internal.input_state = input_state
        end
        Mupen_lua_ugui.internal.previous_input_state = Mupen_lua_ugui.internal.deep_clone(Mupen_lua_ugui.internal
        .input_state)
        Mupen_lua_ugui.internal.input_state = Mupen_lua_ugui.internal.deep_clone(input_state)

        if Mupen_lua_ugui.internal.is_mouse_just_down() then
            Mupen_lua_ugui.internal.mouse_down_position = Mupen_lua_ugui.internal.input_state.mouse_position
        end
    end,

    --- Ends a frame
    end_frame = function()
        for i = 1, #Mupen_lua_ugui.internal.late_callbacks, 1 do
            Mupen_lua_ugui.internal.late_callbacks[i]()
        end

        Mupen_lua_ugui.internal.late_callbacks = {}
        Mupen_lua_ugui.internal.hittest_free_rects = {}
    end,

    ---Places a Button
    ---
    ---Additional fields in the `control` table:
    ---
    --- `text` — `string` The button's text
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ boolean Whether the button has been pressed this frame
    button = function(control)
        local pushed = Mupen_lua_ugui.internal.is_pushed(control)
        if pushed then
            Mupen_lua_ugui.internal.active_control_uid = control.uid
        end

        Mupen_lua_ugui.standard_styler.draw_button(control)

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
        local pushed = Mupen_lua_ugui.internal.is_pushed(control)
        local is_checked = control.is_checked

        if pushed and control.is_enabled then
            Mupen_lua_ugui.internal.active_control_uid = control.uid
            is_checked = not is_checked
        end

        Mupen_lua_ugui.standard_styler.draw_togglebutton(control)

        return is_checked
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
        local pushed = Mupen_lua_ugui.internal.is_pushed(control)
        local selected_index = control.selected_index

        if pushed then
            Mupen_lua_ugui.internal.active_control_uid = control.uid

            local relative_x = Mupen_lua_ugui.internal.input_state.mouse_position.x - control.rectangle.x
            if relative_x > control.rectangle.width / 2 then
                selected_index = selected_index + 1
            else
                selected_index = selected_index - 1
            end
        end

        Mupen_lua_ugui.standard_styler.draw_carrousel_button(control)

        return Mupen_lua_ugui.internal.clamp(selected_index, 1, #control.items)
    end,
    ---Places a TextBox
    ---
    ---Additional fields in the `control` table:
    ---
    --- `text` — `string` The textbox's text
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ string The textbox's text
    textbox = function(control)
        if not Mupen_lua_ugui.internal.control_data[control.uid] then
            Mupen_lua_ugui.internal.control_data[control.uid] = {
                caret_index = 1,
                selection_start = nil,
                selection_end = nil,
            }
        end

        local pushed = Mupen_lua_ugui.internal.is_pushed(control)
        local text = control.text

        if pushed and control.is_enabled then
            Mupen_lua_ugui.internal.active_control_uid = control.uid
        end

        if not (Mupen_lua_ugui.internal.active_control_uid == control.uid) then
            Mupen_lua_ugui.internal.control_data[control.uid].selection_start = nil
            Mupen_lua_ugui.internal.control_data[control.uid].selection_end = nil
        end

        local function get_caret_index_at_relative_position(position)
            local x = (position.x - control.rectangle.x) + Mupen_lua_ugui.standard_styler.textbox_padding
            local lowest_distance = 9999999999
            local lowest_distance_index = -1

            if x > BreitbandGraphics.get_text_size(control.text,
                    Mupen_lua_ugui.standard_styler.font_size,
                    Mupen_lua_ugui.standard_styler.font_name).width then
                return #control.text + 1
            end

            for i = 1, #control.text, 1 do
                local dist = math.abs(BreitbandGraphics.get_text_size(control.text:sub(1, i),
                    Mupen_lua_ugui.standard_styler.font_size,
                    Mupen_lua_ugui.standard_styler.font_name).width - x)
                if dist < lowest_distance then
                    lowest_distance = dist
                    lowest_distance_index = i
                end
            end

            return lowest_distance_index
        end

        local function get_higher_selection()
            if Mupen_lua_ugui.internal.control_data[control.uid].selection_start > Mupen_lua_ugui.internal.control_data[control.uid].selection_end then
                return Mupen_lua_ugui.internal.control_data[control.uid].selection_start
            end
            return Mupen_lua_ugui.internal.control_data[control.uid].selection_end
        end

        local function get_lower_selection()
            if Mupen_lua_ugui.internal.control_data[control.uid].selection_start > Mupen_lua_ugui.internal.control_data[control.uid].selection_end then
                return Mupen_lua_ugui.internal.control_data[control.uid].selection_end
            end
            return Mupen_lua_ugui.internal.control_data[control.uid].selection_start
        end

        local function handle_special_keys(keys)
            local has_selection = not (Mupen_lua_ugui.internal.control_data[control.uid].selection_start == Mupen_lua_ugui.internal.control_data[control.uid].selection_end)


            if keys.left then
                if has_selection then
                    -- nuke the selection and set it to the caret index
                    local lower_selection = get_lower_selection()
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_start = lower_selection
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_end = lower_selection
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = lower_selection
                else
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.control_data
                        [control.uid]
                        .caret_index - 1
                end
            elseif keys.right then
                if has_selection then
                    -- move the caret to the selection end index and nuke the selection
                    local higher_selection = get_higher_selection()
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = higher_selection
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_start = higher_selection
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_end = higher_selection
                else
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.control_data
                        [control.uid]
                        .caret_index + 1
                end
            elseif keys.space then
                if has_selection then
                    local lower_selection = get_lower_selection()
                    text = Mupen_lua_ugui.internal.remove_range(text, get_lower_selection(), get_higher_selection())
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = lower_selection
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_start = lower_selection
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_end = lower_selection
                    text = Mupen_lua_ugui.internal.insert_at(text, ' ',
                        Mupen_lua_ugui.internal.control_data[control.uid].caret_index - 1)
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.control_data
                        [control.uid]
                        .caret_index + 1
                else
                    text = Mupen_lua_ugui.internal.insert_at(text, ' ',
                        Mupen_lua_ugui.internal.control_data[control.uid].caret_index - 1)
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.control_data
                        [control.uid]
                        .caret_index + 1
                end
            elseif keys.backspace then
                if has_selection then
                    local lower_selection = get_lower_selection()
                    text = Mupen_lua_ugui.internal.remove_range(text, lower_selection, get_higher_selection())
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = lower_selection
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_start = lower_selection
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_end = lower_selection
                else
                    text = Mupen_lua_ugui.internal.remove_at(text,
                        Mupen_lua_ugui.internal.control_data[control.uid].caret_index - 1)
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.control_data
                        [control.uid]
                        .caret_index - 1
                end
            else
                return false
            end
            return true
        end


        if Mupen_lua_ugui.internal.active_control_uid == control.uid and control.is_enabled then
            -- start the new selection
            if Mupen_lua_ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) then
                Mupen_lua_ugui.internal.control_data[control.uid].caret_index = get_caret_index_at_relative_position(
                    Mupen_lua_ugui.internal.input_state.mouse_position)
                Mupen_lua_ugui.internal.control_data[control.uid].selection_start = get_caret_index_at_relative_position(
                    Mupen_lua_ugui.internal.input_state.mouse_position)
            end

            if Mupen_lua_ugui.internal.input_state.is_primary_down and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.mouse_down_position, control.rectangle) then
                Mupen_lua_ugui.internal.control_data[control.uid].selection_end = get_caret_index_at_relative_position(
                    Mupen_lua_ugui.internal.input_state.mouse_position)
            end

            local just_pressed_keys = Mupen_lua_ugui.internal.get_just_pressed_keys();
            local has_selection = not (Mupen_lua_ugui.internal.control_data[control.uid].selection_start == Mupen_lua_ugui.internal.control_data[control.uid].selection_end)

            if not handle_special_keys(just_pressed_keys) then
                for key, _ in pairs(just_pressed_keys) do
                    if not (#key == 1) then
                        goto continue
                    end

                    if has_selection then
                        local lower_selection = get_lower_selection()
                        text = Mupen_lua_ugui.internal.remove_range(text, get_lower_selection(), get_higher_selection())
                        Mupen_lua_ugui.internal.control_data[control.uid].caret_index = lower_selection
                        Mupen_lua_ugui.internal.control_data[control.uid].selection_start = lower_selection
                        Mupen_lua_ugui.internal.control_data[control.uid].selection_end = lower_selection
                        text = Mupen_lua_ugui.internal.insert_at(text, key,
                            Mupen_lua_ugui.internal.control_data[control.uid].caret_index - 1)
                        Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal
                            .control_data[control.uid]
                            .caret_index + 1
                    else
                        text = Mupen_lua_ugui.internal.insert_at(text, key,
                            Mupen_lua_ugui.internal.control_data[control.uid].caret_index - 1)
                        Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal
                            .control_data[control.uid]
                            .caret_index + 1
                    end

                    ::continue::
                end
            end

            Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.clamp(
                Mupen_lua_ugui.internal.control_data[control.uid].caret_index, 1, #text + 1)
        end


        Mupen_lua_ugui.standard_styler.draw_textbox(control)

        return text
    end,

    ---Places a Joystick
    ---
    ---Additional fields in the `control` table:
    ---
    --- `position` — `table` The joystick's position as `{x, y}` with the range `0-1`
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    joystick = function(control)
        Mupen_lua_ugui.standard_styler.draw_joystick(control)

        return control.position
    end,

    ---Places a Trackbar/Slider
    ---
    ---Additional fields in the `control` table:
    ---
    --- `values` — `number` The trackbar's value with the range `0-1`
    ---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
    ---@return _ number The trackbar's value
    trackbar = function(control)
        local value = control.value

        local pushed = Mupen_lua_ugui.internal.is_pushed(control)
        if pushed and control.is_enabled then
            Mupen_lua_ugui.internal.active_control_uid = control.uid
        end

        -- we instantly deactivate this control after releasing our mouse to emulate windows behaviour
        if Mupen_lua_ugui.internal.active_control_uid == control.uid and not Mupen_lua_ugui.internal.input_state.is_primary_down and control.is_enabled then
            Mupen_lua_ugui.internal.active_control_uid = nil
        end

        if Mupen_lua_ugui.internal.active_control_uid == control.uid and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.mouse_down_position, control.rectangle) and Mupen_lua_ugui.internal.input_state.is_primary_down then
            if control.rectangle.width > control.rectangle.height then
                value = Mupen_lua_ugui.internal.clamp(
                    (Mupen_lua_ugui.internal.input_state.mouse_position.x - control.rectangle.x) /
                    control.rectangle.width,
                    0, 1)
            else
                value = Mupen_lua_ugui.internal.clamp(
                    (Mupen_lua_ugui.internal.input_state.mouse_position.y - control.rectangle.y) /
                    control.rectangle.height,
                    0, 1)
            end
        end

        Mupen_lua_ugui.standard_styler.draw_trackbar(control)

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
        if not Mupen_lua_ugui.internal.control_data[control.uid] then
            Mupen_lua_ugui.internal.control_data[control.uid] = {
                is_open = false,
                hovered_index = control.selected_index,
            }
        end

        if not control.is_enabled then
            Mupen_lua_ugui.internal.control_data[control.uid].is_open = false
        end

        if Mupen_lua_ugui.internal.is_mouse_just_down() and control.is_enabled then
            if BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) then
                Mupen_lua_ugui.internal.control_data[control.uid].is_open = not Mupen_lua_ugui.internal.control_data
                [control.uid].is_open
            else
                if not BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, {
                        x = control.rectangle.x,
                        y = control.rectangle.y + control.rectangle.height,
                        width = control.rectangle.width,
                        height = Mupen_lua_ugui.standard_styler.item_height * #control.items,
                    }) then
                    Mupen_lua_ugui.internal.control_data[control.uid].is_open = false
                end
            end
        end

        local selected_index = control.selected_index

        if Mupen_lua_ugui.internal.control_data[control.uid].is_open and control.is_enabled then
            local list_rect = {
                x = control.rectangle.x,
                y = control.rectangle.y + control.rectangle.height,
                width = control.rectangle.width,
                height = Mupen_lua_ugui.standard_styler.item_height * #control.items + 2,
            }
            Mupen_lua_ugui.internal.hittest_free_rects[#Mupen_lua_ugui.internal.hittest_free_rects + 1] = list_rect

            selected_index = Mupen_lua_ugui.listbox({
                uid = control.uid + 1,
                is_enabled = true,
                -- we tell the listbox to paint itself at the end of the frame, because we need it on top of all other controls
                topmost = true,
                rectangle = list_rect,
                items = control.items,
                selected_index = selected_index,
            })
        end

        Mupen_lua_ugui.standard_styler.draw_combobox(control)

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
    listbox = function(control)
        if not Mupen_lua_ugui.internal.control_data[control.uid] then
            Mupen_lua_ugui.internal.control_data[control.uid] = {
                y_translation = 0,
            }
        end

        local scrollbar_rect = {
            x = control.rectangle.x + control.rectangle.width - Mupen_lua_ugui.standard_styler.scrollbar_thickness,
            y = control.rectangle.y,
            width = Mupen_lua_ugui.standard_styler.scrollbar_thickness,
            height = control.rectangle.height,
        }

        -- we instantly deactivate this control after releasing our mouse to emulate windows behaviour
        if Mupen_lua_ugui.internal.active_control_uid == control.uid and not Mupen_lua_ugui.internal.input_state.is_primary_down then
            Mupen_lua_ugui.internal.active_control_uid = nil
        end

        local selected_index = control.selected_index

        -- topmost controls don't care about hittest free rects
        local ignored = BreitbandGraphics.is_point_inside_any_rectangle(
        Mupen_lua_ugui.internal.input_state.mouse_position, Mupen_lua_ugui.internal.hittest_free_rects) and
        not control.topmost

        if control.is_enabled and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) and not
            ignored then
            if Mupen_lua_ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, scrollbar_rect) then
                Mupen_lua_ugui.internal.active_control_uid = control.uid
            end
            if Mupen_lua_ugui.internal.input_state.is_primary_down and not BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, scrollbar_rect) and not BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.mouse_down_position, scrollbar_rect) then
                local relative_y = Mupen_lua_ugui.internal.input_state.mouse_position.y - control.rectangle.y;
                local new_index = math.ceil((relative_y + (Mupen_lua_ugui.internal.control_data[control.uid].y_translation *
                        ((Mupen_lua_ugui.standard_styler.item_height * #control.items) - control.rectangle.height))) /
                    Mupen_lua_ugui.standard_styler.item_height)
                -- we only assign the new index if it's within bounds, as
                -- this emulates windows commctl behaviour
                if new_index <= #control.items then
                    selected_index = new_index
                end
            end

            local inc = 0
            if Mupen_lua_ugui.internal.is_mouse_wheel_up() then
                inc = -1 / #control.items
            end
            if Mupen_lua_ugui.internal.is_mouse_wheel_down() then
                inc = 1 / #control.items
            end
            Mupen_lua_ugui.internal.control_data[control.uid].y_translation = Mupen_lua_ugui.internal.control_data
                [control.uid]
                .y_translation + inc
        end


        if Mupen_lua_ugui.internal.active_control_uid == control.uid then
            -- only allow translation if content overflows

            if #control.items * Mupen_lua_ugui.standard_styler.item_height > control.rectangle.height then
                local v = (Mupen_lua_ugui.internal.input_state.mouse_position.y - control.rectangle.y) /
                    control.rectangle.height
                Mupen_lua_ugui.internal.control_data[control.uid].y_translation = v
            end
        end

        Mupen_lua_ugui.internal.control_data[control.uid].y_translation = Mupen_lua_ugui.internal.clamp(
            Mupen_lua_ugui.internal.control_data[control.uid].y_translation, 0, 1)

        if control.topmost then
            Mupen_lua_ugui.internal.late_callbacks[#Mupen_lua_ugui.internal.late_callbacks + 1] = function()
                Mupen_lua_ugui.standard_styler.draw_listbox(control)
            end
        else
            Mupen_lua_ugui.standard_styler.draw_listbox(control)
        end

        return selected_index
    end,
}
