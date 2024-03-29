-- mupen-lua-ugui 1.6.0

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
    ---@return _ table The text's bounding box as `{x, y}`
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
        if type(text) ~= 'string' then
            text = tostring(text)
        end
        d2d.set_text_antialias_mode(d_text_antialias_mode)
        d2d.draw_text(
            rectangle.x,
            rectangle.y,
            rectangle.x + rectangle.width,
            rectangle.y + rectangle.height,
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
    print("BreitbandGraphics: Using 1.1.5 - 1.1.6 shim. Please update to mupen64-rr-lua 1.1.7")
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
    ---@param style table The miscellaneous text styling as `{is_bold, is_italic, clip, grayscale, aliased}`
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
        if type(text) ~= 'string' then
            text = tostring(text)
        end
        local float_color = BreitbandGraphics.color_to_float(color)
        d2d.set_text_antialias_mode(d_text_antialias_mode)
        d2d.draw_text(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height, float_color.r, float_color.g, float_color.b, 1.0, text, font_name,
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

        -- uid of the currently active control
        active_control = nil,

        -- whether the active control will be cleared after the mouse is released
        clear_active_control_after_mouse_up = true,

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
            for k, v in pairs(obj) do
                res[Mupen_lua_ugui.internal.deep_clone(k, s)] = Mupen_lua_ugui.internal.deep_clone(
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
            return Mupen_lua_ugui.internal.input_state.is_primary_down and
                not Mupen_lua_ugui.internal.previous_input_state.is_primary_down
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
            if value == nil then
                return value
            end
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
        process_push = function(control)
            if control.is_enabled == false then
                return false
            end

            if Mupen_lua_ugui.internal.input_state.is_primary_down and not Mupen_lua_ugui.internal.previous_input_state.is_primary_down then
                if BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.mouse_down_position,
                        control.rectangle) then
                    if not control.topmost and BreitbandGraphics.is_point_inside_any_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, Mupen_lua_ugui.internal.hittest_free_rects) then
                        return false
                    end

                    Mupen_lua_ugui.internal.active_control = control.uid
                    Mupen_lua_ugui.internal.clear_active_control_after_mouse_up = true
                    return true
                end
            end
            return false
        end,
        get_caret_index = function(text, relative_x)
            local positions = {}
            for i = 1, #text, 1 do
                local width = BreitbandGraphics.get_text_size(text:sub(1, i),
                    Mupen_lua_ugui.standard_styler.font_size,
                    Mupen_lua_ugui.standard_styler.font_name).width

                positions[#positions + 1] = width
            end

            for i = #positions, 1, -1 do
                if relative_x > positions[i] then
                    return Mupen_lua_ugui.internal.clamp(i + 1, 1, #positions + 1)
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
                    text = Mupen_lua_ugui.internal.remove_range(text, sel_lo, sel_hi)
                    caret_index = lower_selection
                    selection_start = lower_selection
                    selection_end = lower_selection
                    text = Mupen_lua_ugui.internal.insert_at(text, ' ', caret_index - 1)
                    caret_index = caret_index + 1
                else
                    text = Mupen_lua_ugui.internal.insert_at(text, ' ', caret_index - 1)
                    caret_index = caret_index + 1
                end
            elseif key == 'backspace' then
                if has_selection then
                    local lower_selection = sel_lo
                    text = Mupen_lua_ugui.internal.remove_range(text, lower_selection, sel_hi)
                    caret_index = lower_selection
                    selection_start = lower_selection
                    selection_end = lower_selection
                else
                    text = Mupen_lua_ugui.internal.remove_at(text,
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
            return Mupen_lua_ugui.visual_states.disabled
        end

        if Mupen_lua_ugui.internal.active_control ~= nil and Mupen_lua_ugui.internal.active_control == control.uid then
            return Mupen_lua_ugui.visual_states.active
        end

        local now_inside = BreitbandGraphics.is_point_inside_rectangle(
                Mupen_lua_ugui.internal.input_state.mouse_position,
                control.rectangle)
            and
            not BreitbandGraphics.is_point_inside_any_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position,
                Mupen_lua_ugui.internal.hittest_free_rects)

        local down_inside = BreitbandGraphics.is_point_inside_rectangle(
                Mupen_lua_ugui.internal.mouse_down_position, control.rectangle)
            and
            not BreitbandGraphics.is_point_inside_any_rectangle(Mupen_lua_ugui.internal.mouse_down_position,
                Mupen_lua_ugui.internal.hittest_free_rects)

        if now_inside and not Mupen_lua_ugui.internal.input_state.is_primary_down then
            return Mupen_lua_ugui.visual_states.hovered
        end

        if down_inside and Mupen_lua_ugui.internal.input_state.is_primary_down and not now_inside then
            return Mupen_lua_ugui.visual_states.hovered
        end

        if now_inside and down_inside and Mupen_lua_ugui.internal.input_state.is_primary_down then
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
        cleartype = true,
        scrollbar_thickness = 17,
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
        draw_raised_frame = function(control, visual_state)
            BreitbandGraphics.fill_rectangle(control.rectangle,
                Mupen_lua_ugui.standard_styler.raised_frame_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                Mupen_lua_ugui.standard_styler.raised_frame_back_colors[visual_state])
        end,
        draw_edit_frame = function(control, rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(control.rectangle,
                Mupen_lua_ugui.standard_styler.edit_frame_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(control.rectangle, -1),
                Mupen_lua_ugui.standard_styler.edit_frame_back_colors[visual_state])
        end,
        draw_list_frame = function(rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(rectangle,
                Mupen_lua_ugui.standard_styler.list_frame_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(BreitbandGraphics.inflate_rectangle(rectangle, -1),
                Mupen_lua_ugui.standard_styler.list_frame_back_colors[visual_state])
        end,
        draw_joystick_inner = function(rectangle, visual_state, position)
            local back_color = Mupen_lua_ugui.standard_styler.joystick_back_colors[visual_state]
            local outline_color = Mupen_lua_ugui.standard_styler.joystick_outline_colors[visual_state]
            local tip_color = Mupen_lua_ugui.standard_styler.joystick_tip_colors[visual_state]
            local line_color = Mupen_lua_ugui.standard_styler.joystick_line_colors[visual_state]
            local inner_mag_color = Mupen_lua_ugui.standard_styler.joystick_inner_mag_colors[visual_state]
            local outer_mag_color = Mupen_lua_ugui.standard_styler.joystick_outer_mag_colors[visual_state]
            local mag_thickness = Mupen_lua_ugui.standard_styler.joystick_mag_thicknesses[visual_state]

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
                    height = r
                }, inner_mag_color)
                r = position.r

                BreitbandGraphics.draw_ellipse({
                    x = rectangle.x + rectangle.width / 2 - r / 2,
                    y = rectangle.y + rectangle.height / 2 - r / 2,
                    width = r,
                    height = r
                }, outer_mag_color, mag_thickness)
            end


            BreitbandGraphics.draw_line({
                x = rectangle.x + rectangle.width / 2,
                y = rectangle.y + rectangle.height / 2,
            }, {
                x = position.x,
                y = position.y,
            }, line_color, 3)
            local tip_size = 8
            BreitbandGraphics.fill_ellipse({
                x = position.x - tip_size / 2,
                y = position.y - tip_size / 2,
                width = tip_size,
                height = tip_size,
            }, tip_color)
        end,
        draw_list_item = function(item, rectangle, visual_state)
            if not item then
                return
            end
            BreitbandGraphics.fill_rectangle(rectangle,
                Mupen_lua_ugui.standard_styler.list_item_back_colors[visual_state])

            local size = BreitbandGraphics.get_text_size(item, Mupen_lua_ugui.standard_styler.font_size,
                Mupen_lua_ugui.standard_styler.font_name)
            BreitbandGraphics.draw_text({
                    x = rectangle.x + 2,
                    y = rectangle.y,
                    width = size.width * 2,
                    height = rectangle.height,
                }, 'start', 'center', { aliased = not Mupen_lua_ugui.standard_styler.cleartype },
                Mupen_lua_ugui.standard_styler.list_text_colors[visual_state],
                Mupen_lua_ugui.standard_styler.font_size,
                Mupen_lua_ugui.standard_styler.font_name,
                item)
        end,
        draw_scrollbar = function(container_rectangle, thumb_rectangle, visual_state)
            BreitbandGraphics.fill_rectangle(container_rectangle,
                Mupen_lua_ugui.standard_styler.scrollbar_back_colors[visual_state])
            BreitbandGraphics.fill_rectangle(thumb_rectangle,
                Mupen_lua_ugui.standard_styler.scrollbar_thumb_colors[visual_state])
        end,
        draw_list = function(control, rectangle)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)
            Mupen_lua_ugui.standard_styler.draw_list_frame(rectangle, visual_state)

            local content_bounds = Mupen_lua_ugui.standard_styler.get_listbox_content_bounds(control)
            -- item y position:
            -- y = (20 * (i - 1)) - (scroll_y * ((20 * #control.items) - control.rectangle.height))
            local scroll_x = Mupen_lua_ugui.internal.control_data[control.uid].scroll_x and
                Mupen_lua_ugui.internal.control_data[control.uid].scroll_x or 0
            local scroll_y = Mupen_lua_ugui.internal.control_data[control.uid].scroll_y and
                Mupen_lua_ugui.internal.control_data[control.uid].scroll_y or 0

            local index_begin = (scroll_y *
                    (content_bounds.height - rectangle.height)) /
                Mupen_lua_ugui.standard_styler.item_height

            local index_end = (rectangle.height + (scroll_y *
                    (content_bounds.height - rectangle.height))) /
                Mupen_lua_ugui.standard_styler.item_height

            index_begin = Mupen_lua_ugui.internal.clamp(math.floor(index_begin), 1, #control.items)
            index_end = Mupen_lua_ugui.internal.clamp(math.ceil(index_end), 1, #control.items)

            local x_offset = math.max((content_bounds.width - control.rectangle.width) * scroll_x, 0)

            BreitbandGraphics.push_clip(BreitbandGraphics.inflate_rectangle(rectangle, -1))

            for i = index_begin, index_end, 1 do
                local y_offset = (Mupen_lua_ugui.standard_styler.item_height * (i - 1)) -
                    (scroll_y * (content_bounds.height - rectangle.height))

                local item_visual_state = Mupen_lua_ugui.visual_states.normal
                if control.is_enabled == false then
                    item_visual_state = Mupen_lua_ugui.visual_states.disabled
                end

                if control.selected_index == i then
                    item_visual_state = Mupen_lua_ugui.visual_states.active
                end

                Mupen_lua_ugui.standard_styler.draw_list_item(control.items[i], {
                    x = rectangle.x - x_offset,
                    y = rectangle.y + y_offset,
                    width = math.max(content_bounds.width, control.rectangle.width),
                    height = Mupen_lua_ugui.standard_styler.item_height,
                }, item_visual_state)
            end

            BreitbandGraphics.pop_clip()
        end,
        draw_button = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            -- override for toggle_button
            if control.is_checked and control.is_enabled ~= false then
                visual_state = Mupen_lua_ugui.visual_states.active
            end

            Mupen_lua_ugui.standard_styler.draw_raised_frame(control, visual_state)

            BreitbandGraphics.draw_text(control.rectangle, 'center', 'center',
                { clip = true, aliased = not Mupen_lua_ugui.standard_styler.cleartype },
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
                }, 'start', 'center', { aliased = not Mupen_lua_ugui.standard_styler.cleartype },
                Mupen_lua_ugui.standard_styler.raised_frame_text_colors[visual_state],
                Mupen_lua_ugui.standard_styler.font_size,
                'Segoe UI Mono', '<')
            BreitbandGraphics.draw_text({
                    x = control.rectangle.x + Mupen_lua_ugui.standard_styler.textbox_padding,
                    y = control.rectangle.y,
                    width = control.rectangle.width - Mupen_lua_ugui.standard_styler.textbox_padding * 2,
                    height = control.rectangle.height,
                }, 'end', 'center', { aliased = not Mupen_lua_ugui.standard_styler.cleartype },
                Mupen_lua_ugui.standard_styler.raised_frame_text_colors[visual_state],
                Mupen_lua_ugui.standard_styler.font_size,
                'Segoe UI Mono', '>')
        end,
        draw_textbox = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            if Mupen_lua_ugui.internal.active_control == control.uid and control.is_enabled ~= false then
                visual_state = Mupen_lua_ugui.visual_states.active
            end

            Mupen_lua_ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

            local should_visualize_selection = not (Mupen_lua_ugui.internal.control_data[control.uid].selection_start == nil) and
                not (Mupen_lua_ugui.internal.control_data[control.uid].selection_end == nil) and
                control.is_enabled ~= false and
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
                }, 'start', 'start', { clip = true, aliased = not Mupen_lua_ugui.standard_styler.cleartype },
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
                    }, 'start', 'start', { clip = true, aliased = not Mupen_lua_ugui.standard_styler.cleartype },
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

            Mupen_lua_ugui.standard_styler.draw_raised_frame(control, visual_state)
            Mupen_lua_ugui.standard_styler.draw_joystick_inner(control.rectangle, visual_state, {
                x = Mupen_lua_ugui.internal.remap(control.position.x, 0, 1, control.rectangle.x,
                    control.rectangle.x + control.rectangle.width),
                y = Mupen_lua_ugui.internal.remap(control.position.y, 0, 1, control.rectangle.y,
                    control.rectangle.y + control.rectangle.height),
                r = Mupen_lua_ugui.internal.remap(Mupen_lua_ugui.internal.clamp(control.mag, 0, 1), 0, 1, 0,
                    math.min(control.rectangle.width, control.rectangle.height))
            })
        end,
        draw_track = function(control, visual_state, is_horizontal)
            local track_rectangle = {}
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
                Mupen_lua_ugui.standard_styler.trackbar_border_colors[visual_state])
            BreitbandGraphics.fill_rectangle(track_rectangle,
                Mupen_lua_ugui.standard_styler.trackbar_back_colors[visual_state])
        end,
        draw_thumb = function(control, visual_state, is_horizontal, value)
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
            BreitbandGraphics.fill_rectangle(head_rectangle,
                Mupen_lua_ugui.standard_styler.trackbar_thumb_colors[visual_state])
        end,
        draw_trackbar = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            if Mupen_lua_ugui.internal.active_control == control.uid and control.is_enabled ~= false then
                visual_state = Mupen_lua_ugui.visual_states.active
            end

            local is_horizontal = control.rectangle.width > control.rectangle.height

            Mupen_lua_ugui.standard_styler.draw_track(control, visual_state, is_horizontal)
            Mupen_lua_ugui.standard_styler.draw_thumb(control, visual_state, is_horizontal, control
                .value)
        end,
        draw_combobox = function(control)
            local visual_state = Mupen_lua_ugui.get_visual_state(control)

            if Mupen_lua_ugui.internal.control_data[control.uid].is_open and control.is_enabled ~= false then
                visual_state = Mupen_lua_ugui.visual_states.active
            end

            Mupen_lua_ugui.standard_styler.draw_raised_frame(control, visual_state)

            local text_color = Mupen_lua_ugui.standard_styler.raised_frame_text_colors[visual_state]

            BreitbandGraphics.draw_text({
                    x = control.rectangle.x + Mupen_lua_ugui.standard_styler.textbox_padding * 2,
                    y = control.rectangle.y,
                    width = control.rectangle.width,
                    height = control.rectangle.height,
                }, 'start', 'center', { clip = true, aliased = not Mupen_lua_ugui.standard_styler.cleartype }, text_color,
                Mupen_lua_ugui.standard_styler.font_size,
                Mupen_lua_ugui.standard_styler.font_name,
                control.items[control.selected_index])

            BreitbandGraphics.draw_text({
                    x = control.rectangle.x,
                    y = control.rectangle.y,
                    width = control.rectangle.width - Mupen_lua_ugui.standard_styler.textbox_padding * 4,
                    height = control.rectangle.height,
                }, 'end', 'center', { clip = true, aliased = not Mupen_lua_ugui.standard_styler.cleartype }, text_color,
                Mupen_lua_ugui.standard_styler.font_size,
                'Segoe UI Mono', 'v')
        end,

        draw_listbox = function(control)
            Mupen_lua_ugui.standard_styler.draw_list(control, control.rectangle)
        end,

        get_listbox_content_bounds = function(control)
            local max_width = 0
            if control.horizontal_scroll == true then
                for _, value in pairs(control.items) do
                    local width = BreitbandGraphics.get_text_size(value, Mupen_lua_ugui.standard_styler.font_size,
                        Mupen_lua_ugui.standard_styler.font_name).width

                    if width > max_width then
                        max_width = width
                    end
                end
            end

            return {
                x = 0,
                y = 0,
                width = max_width,
                height = Mupen_lua_ugui.standard_styler.item_height * #control.items,
            }
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

        if not Mupen_lua_ugui.internal.input_state.is_primary_down and Mupen_lua_ugui.internal.clear_active_control_after_mouse_up then
            Mupen_lua_ugui.internal.active_control = nil
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
        local pushed = Mupen_lua_ugui.internal.process_push(control)
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
        local pushed = Mupen_lua_ugui.internal.process_push(control)
        Mupen_lua_ugui.standard_styler.draw_togglebutton(control)

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
        local pushed = Mupen_lua_ugui.internal.process_push(control)
        local selected_index = control.selected_index

        if pushed then
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

        local pushed = Mupen_lua_ugui.internal.process_push(control)
        local text = control.text

        if pushed then
            Mupen_lua_ugui.internal.clear_active_control_after_mouse_up = false
        end

        -- if active and user clicks elsewhere, deactivate
        if Mupen_lua_ugui.internal.active_control == control.uid
            and not BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) then
            if Mupen_lua_ugui.internal.is_mouse_just_down() then
                -- deactivate, then clear selection
                Mupen_lua_ugui.internal.active_control = nil
                Mupen_lua_ugui.internal.control_data[control.uid].selection_start = nil
                Mupen_lua_ugui.internal.control_data[control.uid].selection_end = nil
            end
        end


        local function sel_hi()
            return math.max(Mupen_lua_ugui.internal.control_data[control.uid].selection_start,
                Mupen_lua_ugui.internal.control_data[control.uid].selection_end)
        end

        local function sel_lo()
            return math.min(Mupen_lua_ugui.internal.control_data[control.uid].selection_start,
                Mupen_lua_ugui.internal.control_data[control.uid].selection_end)
        end


        if Mupen_lua_ugui.internal.active_control == control.uid and control.is_enabled ~= false then
            local theoretical_caret_index = Mupen_lua_ugui.internal.get_caret_index(text,
                Mupen_lua_ugui.internal.input_state.mouse_position.x - control.rectangle.x)

            -- start a new selection
            if Mupen_lua_ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) then
                Mupen_lua_ugui.internal.control_data[control.uid].caret_index = theoretical_caret_index
                Mupen_lua_ugui.internal.control_data[control.uid].selection_start = theoretical_caret_index
            end

            -- already has selection, move end to appropriate index
            if Mupen_lua_ugui.internal.input_state.is_primary_down and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.mouse_down_position, control.rectangle) then
                Mupen_lua_ugui.internal.control_data[control.uid].selection_end = theoretical_caret_index
            end

            local just_pressed_keys = Mupen_lua_ugui.internal.get_just_pressed_keys()
            local has_selection = Mupen_lua_ugui.internal.control_data[control.uid].selection_start ~=
                Mupen_lua_ugui.internal.control_data[control.uid].selection_end

            for key, _ in pairs(just_pressed_keys) do
                local result = Mupen_lua_ugui.internal.handle_special_key(key, has_selection, control.text,
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_start,
                    Mupen_lua_ugui.internal.control_data[control.uid].selection_end,
                    Mupen_lua_ugui.internal.control_data[control.uid].caret_index)


                -- special key press wasn't handled, we proceed to just insert the pressed character (or replace the selection)
                if not result.handled then
                    if #key ~= 1 then
                        goto continue
                    end

                    if has_selection then
                        local lower_selection = sel_lo()
                        text = Mupen_lua_ugui.internal.remove_range(text, sel_lo(), sel_hi())
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

                    goto continue
                end

                Mupen_lua_ugui.internal.control_data[control.uid].caret_index = result.caret_index
                Mupen_lua_ugui.internal.control_data[control.uid].selection_start = result.selection_start
                Mupen_lua_ugui.internal.control_data[control.uid].selection_end = result.selection_end
                text = result.text

                ::continue::
            end
        end

        Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.clamp(
            Mupen_lua_ugui.internal.control_data[control.uid].caret_index, 1, #text + 1)

        Mupen_lua_ugui.standard_styler.draw_textbox(control)
        return text
    end,

    ---Places a Joystick
    ---
    ---Additional fields in the `control` table:
    ---
    --- `position` — `table` The joystick's position as `{x, y}` with the range `0-1`
    --- `mag` - `number` The joystick's magnitude with the range `0-1`
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
        if not Mupen_lua_ugui.internal.control_data[control.uid] then
            Mupen_lua_ugui.internal.control_data[control.uid] = {
                active = false,
            }
        end

        local pushed = Mupen_lua_ugui.internal.process_push(control)
        local value = control.value

        if Mupen_lua_ugui.internal.active_control == control.uid then
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

        if control.is_enabled == false then
            Mupen_lua_ugui.internal.control_data[control.uid].is_open = false
        end

        if Mupen_lua_ugui.internal.is_mouse_just_down() and control.is_enabled ~= false then
            if BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) then
                Mupen_lua_ugui.internal.control_data[control.uid].is_open = not Mupen_lua_ugui.internal.control_data
                    [control.uid].is_open
            else
                local content_bounds = Mupen_lua_ugui.standard_styler.get_listbox_content_bounds(control)
                if not BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, {
                        x = control.rectangle.x,
                        y = control.rectangle.y + control.rectangle.height,
                        width = control.rectangle.width,
                        height = content_bounds.height,
                    }) then
                    Mupen_lua_ugui.internal.control_data[control.uid].is_open = false
                end
            end
        end

        local selected_index = control.selected_index

        if Mupen_lua_ugui.internal.control_data[control.uid].is_open and control.is_enabled ~= false then
            local content_bounds = Mupen_lua_ugui.standard_styler.get_listbox_content_bounds(control)

            local list_rect = {
                x = control.rectangle.x,
                y = control.rectangle.y + control.rectangle.height,
                width = control.rectangle.width,
                height = content_bounds.height,
            }
            Mupen_lua_ugui.internal.hittest_free_rects[#Mupen_lua_ugui.internal.hittest_free_rects + 1] = list_rect

            selected_index = Mupen_lua_ugui.listbox({
                uid = control.uid + 1,
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
    listbox = function(_control)
        if not Mupen_lua_ugui.internal.control_data[_control.uid] then
            Mupen_lua_ugui.internal.control_data[_control.uid] = {
                scroll_x = 0,
                scroll_y = 0,
            }
        end
        if not Mupen_lua_ugui.internal.control_data[_control.uid].scroll_x then
            Mupen_lua_ugui.internal.control_data[_control.uid].scroll_x = 0
        end
        if not Mupen_lua_ugui.internal.control_data[_control.uid].scroll_y then
            Mupen_lua_ugui.internal.control_data[_control.uid].scroll_y = 0
        end

        local content_bounds = Mupen_lua_ugui.standard_styler.get_listbox_content_bounds(_control)
        local x_overflow = content_bounds.width > _control.rectangle.width
        local y_overflow = content_bounds.height > _control.rectangle.height

        local new_rectangle = Mupen_lua_ugui.internal.deep_clone(_control.rectangle)
        if x_overflow then
            new_rectangle.height = new_rectangle.height - Mupen_lua_ugui.standard_styler.scrollbar_thickness
        end
        if y_overflow then
            new_rectangle.width = new_rectangle.width - Mupen_lua_ugui.standard_styler.scrollbar_thickness
        end

        -- we need to adjust rectangle to fit scrollbars
        local control = Mupen_lua_ugui.internal.deep_clone(_control)
        control.rectangle = new_rectangle

        local pushed = Mupen_lua_ugui.internal.process_push(control)
        local ignored = BreitbandGraphics.is_point_inside_any_rectangle(
                Mupen_lua_ugui.internal.input_state.mouse_position, Mupen_lua_ugui.internal.hittest_free_rects) and
            not control.topmost

        if Mupen_lua_ugui.internal.active_control == control.uid and not ignored then
            local relative_y = Mupen_lua_ugui.internal.input_state.mouse_position.y - control.rectangle.y
            local new_index = math.ceil((relative_y + (Mupen_lua_ugui.internal.control_data[control.uid].scroll_y *
                    ((Mupen_lua_ugui.standard_styler.item_height * #control.items) - control.rectangle.height))) /
                Mupen_lua_ugui.standard_styler.item_height)
            -- we only assign the new index if it's within bounds, as
            -- this emulates windows commctl behaviour
            if new_index <= #control.items then
                control.selected_index = Mupen_lua_ugui.internal.clamp(new_index, 1, #control.items)
            end
        end

        if not ignored
            and y_overflow
            and (BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle)
                or Mupen_lua_ugui.internal.active_control == control.uid) then
            local inc = 0
            if Mupen_lua_ugui.internal.is_mouse_wheel_up() then
                inc = -1 / #control.items
            end
            if Mupen_lua_ugui.internal.is_mouse_wheel_down() then
                inc = 1 / #control.items
            end
            Mupen_lua_ugui.internal.control_data[control.uid].scroll_y = Mupen_lua_ugui.internal.control_data
                [control.uid]
                .scroll_y + inc
        end


        if x_overflow then
            Mupen_lua_ugui.internal.control_data[control.uid].scroll_x = Mupen_lua_ugui.scrollbar({
                uid = control.uid + 1,
                is_enabled = control.is_enabled,
                rectangle = {
                    x = control.rectangle.x,
                    y = control.rectangle.y + control.rectangle.height,
                    width = control.rectangle.width,
                    height = Mupen_lua_ugui.standard_styler.scrollbar_thickness,
                },
                value = Mupen_lua_ugui.internal.control_data[control.uid].scroll_x,
                ratio = 1 / (content_bounds.width / control.rectangle.width),
            })
        end

        if y_overflow then
            Mupen_lua_ugui.internal.control_data[control.uid].scroll_y = Mupen_lua_ugui.scrollbar({
                uid = control.uid + 2,
                is_enabled = control.is_enabled,
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width,
                    y = control.rectangle.y,
                    width = Mupen_lua_ugui.standard_styler.scrollbar_thickness,
                    height = control.rectangle.height,
                },
                value = Mupen_lua_ugui.internal.control_data[control.uid].scroll_y,
                ratio = 1 / (content_bounds.height / control.rectangle.height),
            })
        end

        if control.topmost then
            Mupen_lua_ugui.internal.late_callbacks[#Mupen_lua_ugui.internal.late_callbacks + 1] = function()
                Mupen_lua_ugui.standard_styler.draw_listbox(control)
            end
        else
            Mupen_lua_ugui.standard_styler.draw_listbox(control)
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
        if not Mupen_lua_ugui.internal.control_data[control.uid] then
            Mupen_lua_ugui.internal.control_data[control.uid] = {
                start_value = 0,
            }
        end

        local pushed = Mupen_lua_ugui.internal.process_push(control)
        local is_horizontal = control.rectangle.width > control.rectangle.height

        -- if active and user clicks elsewhere, deactivate
        if Mupen_lua_ugui.internal.active_control == control.uid then
            if not BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) then
                if Mupen_lua_ugui.internal.is_mouse_just_down() then
                    -- deactivate, then clear selection
                    Mupen_lua_ugui.internal.active_control = nil
                end
            end
        end

        -- new activation via direct click
        if pushed then
            Mupen_lua_ugui.internal.control_data[control.uid].start_value = control.value
        end

        -- figure out basic bounds of thumb
        local thumb_bounds = {
            width = control.rectangle.width * control.ratio,
            height = control.rectangle.height * control.ratio,
        }

        local thumb_rectangle

        -- we center the scrollbar around the translation value, and shrink it accordingly
        if is_horizontal then
            local scrollbar_x = Mupen_lua_ugui.internal.remap(control.value, 0, 1, 0,
                control.rectangle.width - thumb_bounds.width)

            thumb_rectangle = {
                x = control.rectangle.x + scrollbar_x,
                y = control.rectangle.y,
                width = thumb_bounds.width,
                height = control.rectangle.height,
            }
            if Mupen_lua_ugui.internal.active_control == control.uid and control.is_enabled ~= false and Mupen_lua_ugui.internal.input_state.is_primary_down then
                local v_current = (Mupen_lua_ugui.internal.input_state.mouse_position.x - control.rectangle.x) /
                    control.rectangle.width
                control.value = Mupen_lua_ugui.internal.control_data[control.uid].start_value +
                    (v_current - Mupen_lua_ugui.internal.control_data[control.uid].start_value)
            end
        else
            local scrollbar_y = Mupen_lua_ugui.internal.remap(control.value, 0, 1, 0,
                control.rectangle.height - thumb_bounds.height)

            thumb_rectangle = {
                x = control.rectangle.x,
                y = control.rectangle.y + scrollbar_y,
                width = control.rectangle.width,
                height = thumb_bounds.height,
            }
            if Mupen_lua_ugui.internal.active_control == control.uid and control.is_enabled ~= false and Mupen_lua_ugui.internal.input_state.is_primary_down then
                local v_current = (Mupen_lua_ugui.internal.input_state.mouse_position.y - control.rectangle.y) /
                    control.rectangle.height
                control.value = Mupen_lua_ugui.internal.control_data[control.uid].start_value +
                    (v_current - Mupen_lua_ugui.internal.control_data[control.uid].start_value)
            end
        end

        local visual_state = Mupen_lua_ugui.get_visual_state(control)
        if Mupen_lua_ugui.internal.active_control == control.uid and control.is_enabled ~= false and Mupen_lua_ugui.internal.input_state.is_primary_down then
            visual_state = Mupen_lua_ugui.visual_states.active
        end
        Mupen_lua_ugui.standard_styler.draw_scrollbar(control.rectangle, thumb_rectangle, visual_state)

        return Mupen_lua_ugui.internal.clamp(control.value, 0, 1)
    end,
}
