if emu.set_renderer then
    -- Specify D2D renderer
    emu.set_renderer(2)
end

if d2d and d2d.create_render_target then
    error('BreitbandGraphics: mupen64-rr-lua 1.1.7 or newer is required to use BreitbandGraphics.')
end

---@class Color
---@field public r integer The red channel in the range 0 - 255.
---@field public g integer The green channel in the range 0 - 255.
---@field public b integer The blue channel in the range 0 - 255.
---@field public a integer? The alpha channel in the range 0 - 255. If nil, 255 is assumed.

---@class FloatColor
---@field public r number The red channel in the range 0.0 - 1.0.
---@field public g number The green channel in the range 0.0 - 1.0.
---@field public b number The blue channel in the range 0.0 - 1.0.
---@field public a number? The alpha channel in the range 0.0 - 1.0. If nil, 1.0 is assumed.

---@class Vector2
---@field public x number The X component.
---@field public y number The Y component.

---@class Size
---@field public width number The width.
---@field public height number The height.

---@class Rectangle
---@field public x number The X coordinate.
---@field public y number The Y coordinate.
---@field public width number The width.
---@field public height number The height.

---@class TextStyle
---@field public is_bold boolean? Whether the text is bold. If nil, false is assumed.
---@field public is_italic boolean? Whether the text is italic. If nil, false is assumed.
---@field public clip boolean? Whether the text should be clipped to the bounding rectangle. If nil, false is assumed.
---@field public grayscale boolean? Whether the text should be drawn in grayscale. If nil, false is assumed.
---@field public aliased boolean? Whether the text should be drawn with no text filtering. If nil, false is assumed.
---@field public fit boolean? Whether the text should be resized to fit the bounding rectangle. If nil, false is assumed.

---@class DrawTextParams
---@field public text string? The text. If nil, no text will be drawn.
---@field public rectangle Rectangle The text's bounding rectangle.
---@field public color Color The text color.
---@field public font_name string The font name.
---@field public font_size number The font size.
---@field public align_x Alignment? The text's horizontal alignment inside the bounding rectangle. If nil, Alignment.center is assumed.
---@field public align_y Alignment? The text's vertical alignment inside the bounding rectangle. If nil, Alignment.center is assumed.
---@field public is_bold boolean? Whether the text is bold. If nil, false is assumed.
---@field public is_italic boolean? Whether the text is italic. If nil, false is assumed.
---@field public clip boolean? Whether the text should be clipped to the bounding rectangle. If nil, false is assumed.
---@field public grayscale boolean? Whether the text should be drawn in grayscale. If nil, false is assumed.
---@field public aliased boolean? Whether the text should be drawn with no text filtering. If nil, false is assumed.
---@field public fit boolean? Whether the text should be resized to fit the bounding rectangle. If nil, false is assumed.

BreitbandGraphics = {
    internal = {
        ---@type table<string, integer>
        ---Map of color keys to brush handles.
        brushes = {},

        ---@type table<string, integer>
        ---Map of image paths to image handles.
        images = {},

        ---Gets a brush from a color value, creating one and caching it if it doesn't already exist in the cache.
        ---@param color Color The color value to create a brush from.
        ---@return integer # The brush handle.
        brush_from_color = function(color)
            local key = (color.r << 24) | (color.g << 16) | (color.b << 8) | (color.a and color.a or 255)
            if not BreitbandGraphics.internal.brushes[key] then
                local float_color = BreitbandGraphics.color_to_float(color)
                BreitbandGraphics.internal.brushes[key] = d2d.create_brush(float_color.r, float_color.g, float_color.b,
                    float_color.a)
            end
            return BreitbandGraphics.internal.brushes[key]
        end,

        ---Gets an image from a path, creating one and caching it if it doesn't already exist in the cache.
        ---@param path string The path to the image.
        ---@return integer # The image handle.
        image_from_path = function(path)
            if not BreitbandGraphics.internal.images[path] then
                BreitbandGraphics.internal.images[path] = d2d.load_image(path)
            end
            return BreitbandGraphics.internal.images[path]
        end,
    },

    ---@enum Alignment
    --- The alignment inside a container.
    alignment = {
        --- The item is aligned to the start of the container.
        start = 1,
        --- The item is aligned to the center of the container.
        center = 2,
        --- The item is aligned to the end of the container.
        ['end'] = 3,
        --- The item is stretched to fill the container.
        stretch = 4,
    },

    --- Converts a color value to its corresponding hexadecimal representation.
    --- @param color Color The color value to convert.
    --- @returns string # The hexadecimal representation of the color.
    color_to_hex = function(color)
        return string.format('#%06X',
            (color.r * 0x10000) + (color.g * 0x100) + color.b)
    end,

    --- Converts a color's hexadecimal representation into a color table.
    --- @param hex string The hexadecimal color to convert.
    --- @return Color # The color.
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

    --- Creates a color with the red, green and blue channels assigned to the specified value.
    --- @param value number The value to be used for the red, green and blue channels.
    --- @return Color # The color with the red, green and blue channels set to the specified value.
    repeated_to_color = function(value)
        return
        {
            r = value,
            g = value,
            b = value,
        }
    end,

    ---Inverts a color.
    ---@param value Color The color value to invert.
    ---@return Color # The new inverted color.
    invert_color = function(value)
        return {
            r = 255 - value.r,
            g = 255 - value.r,
            b = 255 - value.r,
            a = value.a,
        }
    end,

    ---@enum StandardColors
    --- A table of standard colors.
    colors = {
        --- The color white.
        white = {
            r = 255,
            g = 255,
            b = 255,
        },

        --- The color black.
        black = {
            r = 0,
            g = 0,
            b = 0,
        },

        --- The color red.
        red = {
            r = 255,
            g = 0,
            b = 0,
        },

        --- The color green.
        green = {
            r = 0,
            g = 255,
            b = 0,
        },

        --- The color blue.
        blue = {
            r = 0,
            g = 0,
            b = 255,
        },

        --- The color yellow.
        yellow = {
            r = 255,
            g = 255,
            b = 0,
        },

        --- The color orange.
        orange = {
            r = 255,
            g = 128,
            b = 0,
        },

        --- The color magenta.
        magenta = {
            r = 255,
            g = 0,
            b = 255,
        },
    },

    ---Checks whether a point is inside a rectangle.
    ---@param point Vector2 The point.
    ---@param rectangle Rectangle The rectangle.
    ---@return boolean # Whether the point is inside the rectangle.
    is_point_inside_rectangle = function(point, rectangle)
        return point.x > rectangle.x and
            point.y > rectangle.y and
            point.x < rectangle.x + rectangle.width and
            point.y < rectangle.y + rectangle.height
    end,

    ---Checks whether a point is inside any of the rectangles.
    ---@param point Vector2 The point.
    ---@param rectangles Rectangle[] The rectangles.
    ---@return boolean # Whether the point is inside any of the rectangles.
    is_point_inside_any_rectangle = function(point, rectangles)
        for i = 1, #rectangles, 1 do
            if BreitbandGraphics.is_point_inside_rectangle(point, rectangles[i]) then
                return true
            end
        end
        return false
    end,

    --- Creates a rectangle inflated around its center by the specified amount.
    --- @param rectangle Rectangle The rectangle to be inflated.
    --- @param amount number The amount to inflate the rectangle by.
    --- @return Rectangle # The inflated rectangle.
    inflate_rectangle = function(rectangle, amount)
        return {
            x = rectangle.x - amount,
            y = rectangle.y - amount,
            width = rectangle.width + amount * 2,
            height = rectangle.height + amount * 2,
        }
    end,

    --- Creates a FloatColor from a Color.
    --- Channels with nil values will be converted to `0.0`, unless they are the alpha channel, in which case it will be converted to `1.0`.
    --- @param color Color The color to be converted.
    --- @return FloatColor # The color with remapped channels.
    color_to_float = function(color)
        return {
            r = (color.r and (color.r / 255.0) or 0.0),
            g = (color.g and (color.g / 255.0) or 0.0),
            b = (color.b and (color.b / 255.0) or 0.0),
            a = (color.a and (color.a / 255.0) or 1.0),
        }
    end,

    ---Computes the bounding box of a text string given a font size and font name.
    ---@param text string The string to be measured.
    ---@param font_size number The font size.
    ---@param font_name string The font name.
    ---@return Size # The text's bounding box.
    get_text_size = function(text, font_size, font_name)
        return d2d.get_text_size(text, font_name, font_size, 99999999, 99999999)
    end,

    ---Draws a rectangle's outline.
    ---@param rectangle Rectangle The shape's bounding rectangle.
    ---@param color Color The outline's color.
    ---@param thickness number The outline's thickness.
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

    ---Draws a filled-in rectangle.
    ---@param rectangle Rectangle The shape's bounding rectangle.
    ---@param color Color The fill color.
    fill_rectangle = function(rectangle, color)
        local brush = BreitbandGraphics.internal.brush_from_color(color)
        d2d.fill_rectangle(
            rectangle.x,
            rectangle.y,
            rectangle.x + rectangle.width,
            rectangle.y + rectangle.height,
            brush)
    end,

    ---Draws a rounded rectangle's outline.
    ---@param rectangle Rectangle The shape's bounding rectangle.
    ---@param color Color The outline's color.
    ---@param radii Vector2 The corner radii.
    ---@param thickness number The outline's thickness.
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

    ---Draws a filled-in rounded rectangle.
    ---@param rectangle Rectangle The shape's bounding rectangle.
    ---@param color Color The fill color.
    ---@param radii Vector2 The corner radii.
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

    ---Draws an ellipse's outline.
    ---@param rectangle Rectangle The shape's bounding rectangle.
    ---@param color Color The outline's color.
    ---@param thickness number The outline's thickness.
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

    ---Draws a filled-in ellipse.
    ---@param rectangle Rectangle The shape's bounding rectangle.
    ---@param color Color The fill color.
    fill_ellipse = function(rectangle, color)
        local brush = BreitbandGraphics.internal.brush_from_color(color)
        d2d.fill_ellipse(
            rectangle.x + rectangle.width / 2,
            rectangle.y + rectangle.height / 2,
            rectangle.width / 2,
            rectangle.height / 2,
            brush)
    end,

    ---Draws text with the specified parameters.
    ---Deprecated, use `draw_text2` instead.
    ---@param rectangle Rectangle The text's bounding rectangle.
    ---@param horizontal_alignment "center"|"start"|"end"|"stretch" The text's horizontal alignment inside the bounding rectangle.
    ---@param vertical_alignment "center"|"start"|"end"|"stretch" The text's vertical alignment inside the bounding rectangle.
    ---@param style TextStyle The text style options.
    ---@param color Color The text color.
    ---@param font_size number The font size.
    ---@param font_name string The font name.
    ---@param text string The text.
    ---@deprecated
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

    ---Draws text with the specified parameters.
    ---@param params DrawTextParams The text drawing parameters.
    draw_text2 = function(params)
        if not params.text then
            return
        end

        local internal_alignment_to_d2d_alignment_map = {
            [BreitbandGraphics.alignment.start] = 0,
            [BreitbandGraphics.alignment.center] = 2,
            [BreitbandGraphics.alignment['end']] = 1,
            [BreitbandGraphics.alignment.stretch] = 3,
        }

        local rect_x = params.rectangle.x
        local rect_y = params.rectangle.y
        local rect_w = params.rectangle.width
        local rect_h = params.rectangle.height
        local brush = BreitbandGraphics.internal.brush_from_color(params.color)
        local d_horizontal_alignment = params.align_x and internal_alignment_to_d2d_alignment_map[params.align_x] or internal_alignment_to_d2d_alignment_map[BreitbandGraphics.alignment.center]
        local d_vertical_alignment = params.align_y and internal_alignment_to_d2d_alignment_map[params.align_y] or internal_alignment_to_d2d_alignment_map[BreitbandGraphics.alignment.center]
        local d_style = 0
        local d_weight = 400
        local d_options = 0
        local d_text_antialias_mode = 1
        local font_size = params.font_size

        if params.is_bold then
            d_weight = 700
        end
        if params.is_italic then
            d_style = 2
        end
        if params.clip then
            d_options = d_options | 0x00000002
        end
        if params.grayscale then
            d_text_antialias_mode = 2
        end
        if params.aliased then
            d_text_antialias_mode = 3
        end
        if params.fit then
            -- Try to fit the text into the specified rectangle by reducing the font size
            local text_size = d2d.get_text_size(params.text, params.font_name, params.font_size, math.maxinteger, math.maxinteger)

            if text_size.width > params.rectangle.width then
                font_size = font_size / math.max(0.01, (text_size.width / params.rectangle.width))
            end
            if text_size.height > params.rectangle.height then
                font_size = font_size / math.max(0.01, (text_size.height / params.rectangle.height))
            end

            local text_size = d2d.get_text_size(params.text, params.font_name, font_size, math.maxinteger, math.maxinteger)

            -- Since the rect stays the same, the text will want to wrap.
            -- We solve that by recomputing the rect and alignments
            if params.align_x == BreitbandGraphics.alignment.center or params.align_x == BreitbandGraphics.alignment.stretch then
                rect_x = rect_x + rect_w / 2 - text_size.width / 2
            elseif params.align_x == BreitbandGraphics.alignment.start then
                rect_x = rect_x
            elseif params.align_x == BreitbandGraphics.alignment['end'] then
                rect_x = rect_x + rect_w - text_size.width
            end

            if params.align_y == BreitbandGraphics.alignment.center or params.align_y == BreitbandGraphics.alignment.stretch then
                rect_y = rect_y + rect_h / 2 - text_size.height / 2
            elseif params.align_y == BreitbandGraphics.alignment.start then
                rect_y = rect_y
            elseif params.align_y == BreitbandGraphics.alignment['end'] then
                rect_y = rect_y + rect_h - text_size.height
            end

            d_horizontal_alignment = 0
            d_vertical_alignment = 0

            rect_w = text_size.width + 1
            rect_h = text_size.height + 1
        end


        d2d.set_text_antialias_mode(d_text_antialias_mode)
        d2d.draw_text(
            rect_x,
            rect_y,
            rect_x + rect_w,
            rect_y + rect_h,
            params.text,
            params.font_name,
            font_size,
            d_weight,
            d_style,
            d_horizontal_alignment,
            d_vertical_alignment,
            d_options,
            brush)
    end,

    ---Draws a line between two points.
    ---@param from Vector2 The start point.
    ---@param to Vector2 The end point.
    ---@param color Color The line's color.
    ---@param thickness number The line's thickness.
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

    ---Pushes a clip layer to the clip stack.
    ---@param rectangle Rectangle The clip bounds.
    push_clip = function(rectangle)
        d2d.push_clip(rectangle.x, rectangle.y, rectangle.x + rectangle.width,
            rectangle.y + rectangle.height)
    end,

    --- Removes the topmost clip layer from the clip stack.
    pop_clip = function()
        d2d.pop_clip()
    end,

    ---Draws an image with the specified parameters.
    ---@param destination_rectangle Rectangle The destination rectangle on the screen.
    ---@param source_rectangle Rectangle The source rectangle from the image.
    ---@param path string The image's absolute path on disk.
    ---@param color Color The color filter applied to the image. If white, the image is drawn as-is.
    ---@param filter "nearest" | "linear" The texture filter applied to the image.
    ---TODO: Make source_rectangle optional and default to the whole image.
    ---TODO: Make color optional and default to white.
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

    ---Draws a nineslice-scalable image with the specified parameters.
    ---@param destination_rectangle Rectangle The destination rectangle on the screen.
    ---@param source_rectangle Rectangle The source rectangle from the image.
    ---@param source_rectangle_center Rectangle The source rectangle for the center of the image.
    ---@param path string The image's absolute path on disk.
    ---@param color Color The color filter applied to the image. If white, the image is drawn as-is.
    ---@param filter "nearest" | "linear" The texture filter applied to the image.
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

    ---Gets an image's metadata.
    ---@param path string The image's absolute path on disk.
    ---FIXME: Undefined API surface, what is this?!!!!
    get_image_info = function(path)
        local image = BreitbandGraphics.internal.image_from_path(path)
        return d2d.get_image_info(image)
    end,

    ---Releases allocated resources.
    ---Must be called before stopping the Lua environment.
    free = function()
        for key, value in pairs(BreitbandGraphics.internal.brushes) do
            d2d.free_brush(value)
        end
        for key, value in pairs(BreitbandGraphics.internal.images) do
            d2d.free_image(value)
        end
    end,
}
