if emu.set_renderer then
    -- Specify D2D renderer
    emu.set_renderer(2)
end

BreitbandGraphics = {
    internal = {
        brushes = {},
        images = {},
        brush_from_color = function(color)
            local key = (color.r << 24) | (color.g << 16) | (color.b << 8) | (color.a and color.a or 255)
            if not BreitbandGraphics.internal.brushes[key] then
                local float_color = BreitbandGraphics.color_to_float(color)
                BreitbandGraphics.internal.brushes[key] = d2d.create_brush(float_color.r, float_color.g, float_color.b,
                    float_color.a)
            end
            return BreitbandGraphics.internal.brushes[key]
        end,
        image_from_path = function(path)
            if not BreitbandGraphics.internal.images[path] then
                BreitbandGraphics.internal.images[path] = d2d.load_image(path)
            end
            return BreitbandGraphics.internal.images[path]
        end,
    },

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
        if #hex > 7 then
            return
            {
                r = tonumber(hex:sub(2, 3), 16),
                g = tonumber(hex:sub(4, 5), 16),
                b = tonumber(hex:sub(6, 7), 16),
                a = tonumber(hex:sub(8, 9), 16),
            }
        end
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
            point.y < rectangle.y + rectangle.height
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

    ---Measures the size of a string
    ---@param text string The string to be measured
    ---@param font_size number The font size
    ---@param font_name string The font name
    ---@return _ table The text's bounding box as `{width, height}`
    get_text_size = function(text, font_size, font_name)
        return d2d.get_text_size(text, font_name, font_size, 99999999, 99999999)
    end,
    ---Draws a rectangle's outline
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param thickness number The outline's thickness
    draw_rectangle = function(rectangle, color, thickness)
        local brush = BreitbandGraphics.internal.brush_from_color(color)
        d2d.draw_rectangle(
            rectangle.x,
            rectangle.y,
            rectangle.x + rectangle.width,
            rectangle.y + rectangle.height,
            thickness,
            brush)
    end,
    ---Draws a rectangle
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    fill_rectangle = function(rectangle, color)
        local brush = BreitbandGraphics.internal.brush_from_color(color)
        d2d.fill_rectangle(
            rectangle.x,
            rectangle.y,
            rectangle.x + rectangle.width,
            rectangle.y + rectangle.height,
            brush)
    end,
    ---Draws a rounded rectangle's outline
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param radii table The corner radii as `{x, y}`
    ---@param thickness number The outline's thickness
    draw_rounded_rectangle = function(rectangle, color, radii, thickness)
        local brush = BreitbandGraphics.internal.brush_from_color(color)
        d2d.draw_rounded_rectangle(
            rectangle.x,
            rectangle.y,
            rectangle.x + rectangle.width,
            rectangle.y + rectangle.height,
            radii.x,
            radii.y,
            thickness,
            brush)
    end,
    ---Fills a rounded rectangle
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param radii table The corner radii as `{x, y}`
    fill_rounded_rectangle = function(rectangle, color, radii)
        local brush = BreitbandGraphics.internal.brush_from_color(color)
        d2d.fill_rounded_rectangle(
            rectangle.x,
            rectangle.y,
            rectangle.x + rectangle.width,
            rectangle.y + rectangle.height,
            radii.x,
            radii.y,
            brush)
    end,
    ---Draws an ellipse's outline
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param thickness number The outline's thickness
    draw_ellipse = function(rectangle, color, thickness)
        local brush = BreitbandGraphics.internal.brush_from_color(color)
        d2d.draw_ellipse(
            rectangle.x + rectangle.width / 2,
            rectangle.y + rectangle.height / 2,
            rectangle.width / 2,
            rectangle.height / 2,
            thickness,
            brush)
    end,
    ---Draws an ellipse
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    fill_ellipse = function(rectangle, color)
        local brush = BreitbandGraphics.internal.brush_from_color(color)
        d2d.fill_ellipse(
            rectangle.x + rectangle.width / 2,
            rectangle.y + rectangle.height / 2,
            rectangle.width / 2,
            rectangle.height / 2,
            brush)
    end,
    ---Draws text
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param horizontal_alignment string The text's horizontal alignment inside the bounding rectangle. `center` | `start` | `end` | `stretch`
    ---@param vertical_alignment string The text's vertical alignment inside the bounding rectangle. `center` | `start` | `end` | `stretch`
    ---@param style table The miscellaneous text styling as `{is_bold, is_italic, clip, grayscale, aliased, fit}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param font_size number The font size
    ---@param font_name string The font name
    ---@param text string The text
    draw_text = function(rectangle, horizontal_alignment, vertical_alignment, style, color, font_size, font_name,
        text)
        if text == nil then
            text = ''
        end

        local rect_x = rectangle.x
        local rect_y = rectangle.y
        local rect_w = rectangle.width
        local rect_h = rectangle.height
        local brush = BreitbandGraphics.internal.brush_from_color(color)
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
        if style.fit then
            -- Try to fit the text into the specified rectangle by reducing the font size
            local text_size = d2d.get_text_size(text, font_name, font_size, math.maxinteger, math.maxinteger)

            if text_size.width > rectangle.width then
                font_size = font_size / math.max(0.01, (text_size.width / rectangle.width))
            end
            if text_size.height > rectangle.height then
                font_size = font_size / math.max(0.01, (text_size.height / rectangle.height))
            end

            local text_size = d2d.get_text_size(text, font_name, font_size, math.maxinteger, math.maxinteger)

            -- Since the rect stays the same, the text will want to wrap.
            -- We solve that by recomputing the rect and alignments
            if horizontal_alignment == 'center' or horizontal_alignment == 'stretch' then
                rect_x = rect_x + rect_w / 2 - text_size.width / 2
            elseif horizontal_alignment == 'start' then
                rect_x = rect_x
            elseif horizontal_alignment == 'end' then
                rect_x = rect_x + rect_w - text_size.width
            end

            if vertical_alignment == 'center' or vertical_alignment == 'stretch' then
                rect_y = rect_y + rect_h / 2 - text_size.height / 2
            elseif vertical_alignment == 'start' then
                rect_y = rect_y
            elseif vertical_alignment == 'end' then
                rect_y = rect_y + rect_h - text_size.height
            end

            d_horizontal_alignment = 0
            d_vertical_alignment = 0

            rect_w = text_size.width + 1
            rect_h = text_size.height + 1
        end
        if type(text) ~= 'string' then
            text = tostring(text)
        end
        d2d.set_text_antialias_mode(d_text_antialias_mode)
        d2d.draw_text(
            rect_x,
            rect_y,
            rect_x + rect_w,
            rect_y + rect_h,
            text,
            font_name,
            font_size,
            d_weight,
            d_style,
            d_horizontal_alignment,
            d_vertical_alignment,
            d_options,
            brush)
    end,
    ---Draws a line
    ---@param from table The start point as `{x, y}`
    ---@param to table The end point as `{x, y}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param thickness number The line's thickness
    draw_line = function(from, to, color, thickness)
        local brush = BreitbandGraphics.internal.brush_from_color(color)

        d2d.draw_line(
            from.x,
            from.y,
            to.x,
            to.y,
            thickness,
            brush)
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
        if not filter then
            filter = 'nearest'
        end
        local float_color = BreitbandGraphics.color_to_float(color)
        local image = BreitbandGraphics.internal.image_from_path(path)
        local interpolation = filter == 'nearest' and 0 or 1

        d2d.draw_image(
            destination_rectangle.x,
            destination_rectangle.y,
            destination_rectangle.x + destination_rectangle.width,
            destination_rectangle.y + destination_rectangle.height,
            source_rectangle.x,
            source_rectangle.y,
            source_rectangle.x + source_rectangle.width,
            source_rectangle.y + source_rectangle.height,
            float_color.a,
            interpolation,
            image)
    end,
    ---Draws a nineslice-scalable image
    ---@param destination_rectangle table The destination rectangle as `{x, y, width, height}`
    ---@param source_rectangle table The source rectangle as `{x, y, width, height}`
    ---@param source_rectangle_center table The source rectangle's center part as `{x, y, width, height}`
    ---@param path string The image's absolute path on disk
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param filter string The texture filter to be used while drawing the image. `nearest` | `linear`
    draw_image_nineslice = function(destination_rectangle, source_rectangle, source_rectangle_center, path,
        color, filter)
        destination_rectangle = {
            x = math.floor(destination_rectangle.x),
            y = math.floor(destination_rectangle.y),
            width = math.ceil(destination_rectangle.width),
            height = math.ceil(destination_rectangle.height),
        }
        source_rectangle = {
            x = math.floor(source_rectangle.x),
            y = math.floor(source_rectangle.y),
            width = math.ceil(source_rectangle.width),
            height = math.ceil(source_rectangle.height),
        }
        local corner_size = {
            x = math.abs(source_rectangle_center.x - source_rectangle.x),
            y = math.abs(source_rectangle_center.y - source_rectangle.y),
        }


        local top_left = {
            x = source_rectangle.x,
            y = source_rectangle.y,
            width = corner_size.x,
            height = corner_size.y,
        }
        local bottom_left = {
            x = source_rectangle.x,
            y = source_rectangle_center.y + source_rectangle_center.height,
            width = corner_size.x,
            height = corner_size.y,
        }
        local left = {
            x = source_rectangle.x,
            y = source_rectangle_center.y,
            width = corner_size.x,
            height = source_rectangle.height - corner_size.y * 2,
        }
        local top_right = {
            x = source_rectangle.x + source_rectangle.width - corner_size.x,
            y = source_rectangle.y,
            width = corner_size.x,
            height = corner_size.y,
        }
        local bottom_right = {
            x = source_rectangle.x + source_rectangle.width - corner_size.x,
            y = source_rectangle_center.y + source_rectangle_center.height,
            width = corner_size.x,
            height = corner_size.y,
        }
        local top = {
            x = source_rectangle_center.x,
            y = source_rectangle.y,
            width = source_rectangle.width - corner_size.x * 2,
            height = corner_size.y,
        }
        local right = {
            x = source_rectangle.x + source_rectangle.width - corner_size.x,
            y = source_rectangle_center.y,
            width = corner_size.x,
            height = source_rectangle.height - corner_size.y * 2,
        }
        local bottom = {
            x = source_rectangle_center.x,
            y = source_rectangle.y + source_rectangle.height - corner_size.y,
            width = source_rectangle.width - corner_size.x * 2,
            height = corner_size.y,
        }

        BreitbandGraphics.draw_image({
            x = destination_rectangle.x,
            y = destination_rectangle.y,
            width = top_left.width,
            height = top_left.height,
        }, top_left, path, color, filter)
        BreitbandGraphics.draw_image({
            x = destination_rectangle.x + destination_rectangle.width - top_right.width,
            y = destination_rectangle.y,
            width = top_right.width,
            height = top_right.height,
        }, top_right, path, color, filter)
        BreitbandGraphics.draw_image({
            x = destination_rectangle.x,
            y = destination_rectangle.y + destination_rectangle.height - bottom_left.height,
            width = bottom_left.width,
            height = bottom_left.height,
        }, bottom_left, path, color, filter)
        BreitbandGraphics.draw_image({
            x = destination_rectangle.x + destination_rectangle.width - bottom_right.width,
            y = destination_rectangle.y + destination_rectangle.height - bottom_right.height,
            width = bottom_right.width,
            height = bottom_right.height,
        }, bottom_right, path, color, filter)
        BreitbandGraphics.draw_image({
            x = destination_rectangle.x + top_left.width,
            y = destination_rectangle.y + top_left.height,
            width = destination_rectangle.width - bottom_right.width * 2,
            height = destination_rectangle.height - bottom_right.height * 2,
        }, source_rectangle_center, path, color, filter)
        BreitbandGraphics.draw_image({
            x = destination_rectangle.x,
            y = destination_rectangle.y + top_left.height,
            width = left.width,
            height = destination_rectangle.height - bottom_left.height * 2,
        }, left, path, color, filter)
        BreitbandGraphics.draw_image({
            x = destination_rectangle.x + destination_rectangle.width - top_right.width,
            y = destination_rectangle.y + top_right.height,
            width = left.width,
            height = destination_rectangle.height - bottom_right.height * 2,
        }, right, path, color, filter)
        BreitbandGraphics.draw_image({
            x = destination_rectangle.x + top_left.width,
            y = destination_rectangle.y,
            width = destination_rectangle.width - top_right.width * 2,
            height = top.height,
        }, top, path, color, filter)
        BreitbandGraphics.draw_image({
            x = destination_rectangle.x + top_left.width,
            y = destination_rectangle.y + destination_rectangle.height - bottom.height,
            width = destination_rectangle.width - bottom_right.width * 2,
            height = bottom.height,
        }, bottom, path, color, filter)
    end,
    ---Gets an image's metadata
    ---@param path string The image's absolute path on disk
    get_image_info = function(path)
        local image = BreitbandGraphics.internal.image_from_path(path)
        return d2d.get_image_info(image)
    end,
    ---Releases allocated resources
    ---Must be called before stopping script
    free = function()
        for key, value in pairs(BreitbandGraphics.internal.brushes) do
            d2d.free_brush(value)
        end
        for key, value in pairs(BreitbandGraphics.internal.images) do
            d2d.free_image(value)
        end
    end,
}



-- 1.1.5 - 1.1.6 shim
if d2d and d2d.create_render_target then
    print('BreitbandGraphics: Using 1.1.5 - 1.1.6 shim. Please update to mupen64-rr-lua 1.1.7')
    BreitbandGraphics.bitmap_cache = {}

    BreitbandGraphics.get_text_size = function(text, font_size, font_name)
        return d2d.get_text_size(text, font_name, font_size, 99999999, 99999999)
    end
    BreitbandGraphics.draw_rectangle = function(rectangle, color, thickness)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_rectangle(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, float_color.r, float_color.g, float_color.b, 1.0, thickness)
    end
    BreitbandGraphics.fill_rectangle = function(rectangle, color)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.fill_rectangle(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, float_color.r, float_color.g, float_color.b, 1.0)
    end
    BreitbandGraphics.draw_rounded_rectangle = function(rectangle, color, radii, thickness)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_rounded_rectangle(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, radii.x, radii.y, float_color.r, float_color.g, float_color.b, 1.0,
            thickness)
    end
    BreitbandGraphics.fill_rounded_rectangle = function(rectangle, color, radii)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.fill_rounded_rectangle(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, radii.x, radii.y, float_color.r, float_color.g, float_color.b, 1.0)
    end
    BreitbandGraphics.draw_ellipse = function(rectangle, color, thickness)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_ellipse(rectangle.x + rectangle.width / 2, rectangle.y + rectangle.height / 2,
            rectangle.width / 2, rectangle.height / 2, float_color.r, float_color.g, float_color.b, 1.0,
            thickness)
    end
    ---Draws an ellipse
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    BreitbandGraphics.fill_ellipse = function(rectangle, color)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.fill_ellipse(rectangle.x + rectangle.width / 2, rectangle.y + rectangle.height / 2,
            rectangle.width / 2, rectangle.height / 2, float_color.r, float_color.g, float_color.b, 1.0)
    end
    ---Draws text
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param horizontal_alignment string The text's horizontal alignment inside the bounding rectangle. `center` | `start` | `end` | `stretch`
    ---@param vertical_alignment string The text's vertical alignment inside the bounding rectangle. `center` | `start` | `end` | `stretch`
    ---@param style table The miscellaneous text styling as `{is_bold, is_italic, clip, grayscale, aliased, fit}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param font_size number The font size
    ---@param font_name string The font name
    ---@param text string The text
    BreitbandGraphics.draw_text = function(rectangle, horizontal_alignment, vertical_alignment, style, color, font_size,
        font_name,
        text)
        if text == nil then
            text = ''
        end

        local rect_x = rectangle.x
        local rect_y = rectangle.y
        local rect_w = rectangle.width
        local rect_h = rectangle.height
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
        if style.fit then
            -- Try to fit the text into the specified rectangle by reducing the font size
            local text_size = d2d.get_text_size(text, font_name, font_size, math.maxinteger, math.maxinteger)

            if text_size.width > rectangle.width then
                font_size = font_size / math.max(0.01, (text_size.width / rectangle.width))
            end
            if text_size.height > rectangle.height then
                font_size = font_size / math.max(0.01, (text_size.height / rectangle.height))
            end

            local text_size = d2d.get_text_size(text, font_name, font_size, math.maxinteger, math.maxinteger)

            -- Since the rect stays the same, the text will want to wrap.
            -- We solve that by recomputing the rect and alignments
            if horizontal_alignment == 'center' or horizontal_alignment == 'stretch' then
                rect_x = rect_x + rect_w / 2 - text_size.width / 2
            elseif horizontal_alignment == 'start' then
                rect_x = rect_x
            elseif horizontal_alignment == 'end' then
                rect_x = rect_x + rect_w - text_size.width
            end

            if vertical_alignment == 'center' or vertical_alignment == 'stretch' then
                rect_y = rect_y + rect_h / 2 - text_size.height / 2
            elseif vertical_alignment == 'start' then
                rect_y = rect_y
            elseif vertical_alignment == 'end' then
                rect_y = rect_y + rect_h - text_size.height
            end

            d_horizontal_alignment = 0
            d_vertical_alignment = 0

            rect_w = text_size.width + 1
            rect_h = text_size.height + 1
        end
        if type(text) ~= 'string' then
            text = tostring(text)
        end
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.set_text_antialias_mode(d_text_antialias_mode)
        d2d.draw_text(rect_x, rect_y, rect_w, rect_h, float_color.r, float_color.g, float_color.b, 1.0, text, font_name,
            font_size, d_weight, d_style, d_horizontal_alignment, d_vertical_alignment, d_options)
    end
    ---Draws a line
    ---@param from table The start point as `{x, y}`
    ---@param to table The end point as `{x, y}`
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param thickness number The line's thickness
    BreitbandGraphics.draw_line = function(from, to, color, thickness)
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.draw_line(from.x, from.y, to.x, to.y, float_color.r, float_color.g, float_color.b, 1.0,
            thickness)
    end
    ---Pushes a clip layer to the clip stack
    ---@param rectangle table The bounding rectangle as `{x, y, width, height}`
    BreitbandGraphics.push_clip = function(rectangle)
        d2d.push_clip(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height)
    end
    --- Removes the topmost clip layer from the clip stack
    BreitbandGraphics.pop_clip = function()
        d2d.pop_clip()
    end
    ---Draws an image
    ---@param destination_rectangle table The bounding rectangle as `{x, y, width, height}`
    ---@param source_rectangle table The rectangle from the source image as `{x, y, width, height}`
    ---@param path string The image's absolute path on disk
    ---@param color table The color as `{r, g, b, [optional] a}` with a channel range of `0-255`
    ---@param filter string The texture filter to be used while drawing the image. `nearest` | `linear`
    BreitbandGraphics.draw_image = function(destination_rectangle, source_rectangle, path, color, filter)
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
    end
    ---Gets an image's metadata
    ---@param path string The image's absolute path on disk
    BreitbandGraphics.get_image_info = function(path)
        if not BreitbandGraphics.bitmap_cache[path] then
            print('Loaded image from ' .. path)
            d2d.load_image(path, path)
            BreitbandGraphics.bitmap_cache[path] = path
        end
        return d2d.get_image_info(path)
    end
end
