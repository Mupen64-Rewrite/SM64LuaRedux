-- mupen-lua-ugui-ext 1.1.0
-- https://github.com/Aurumaker72/mupen-lua-ugui-ext

Mupen_lua_ugui_ext = {
    spread = function(template)
        local result = {}
        for key, value in pairs(template) do
            result[key] = value
        end

        return function(table)
            for key, value in pairs(table) do
                result[key] = value
            end
            return result
        end
    end,
    internal = {
        rt_lut = {},
        get_digit = function(value, length, index)
            return math.floor(value / math.pow(10, length - index)) % 10
        end,
        set_digit = function(value, length, digit_value, index)
            local old_digit_value = Mupen_lua_ugui_ext.internal.get_digit(value, length, index)
            local new_value = value + (digit_value - old_digit_value) * math.pow(10, length - index)
            local max = math.pow(10, length)
            return (new_value + max) % max
        end,
        rectangle_to_key = function(rectangle)
            return rectangle.x .. rectangle.y .. rectangle.width .. rectangle.height
        end,
        cached_draw = function(type, rectangle, visual_state, draw)
            local key = type .. visual_state .. Mupen_lua_ugui_ext.internal.rectangle_to_key(rectangle)
            if not Mupen_lua_ugui_ext.internal.rt_lut[key] then
                local render_target = d2d.create_render_target(rectangle.width, rectangle.height)
                d2d.begin_render_target(render_target)
                draw({
                    x = 0,
                    y = 0,
                    width = rectangle.width,
                    height = rectangle.height,
                })
                d2d.end_render_target(render_target)

                Mupen_lua_ugui_ext.internal.rt_lut[key] = render_target
            end
            -- bitmap has same key as render_target
            d2d.draw_image(rectangle.x, rectangle.y,
                rectangle.x + rectangle.width,
                rectangle.y + rectangle.height,
                0, 0, rectangle.width,
                rectangle.height, Mupen_lua_ugui_ext.internal.rt_lut[key], 1, 0)
        end,

        -- applies a text drawing hook to breitbandgraphics which speeds up text drawing
        -- TODO: fix this, as it currently doesnt work lol
        apply_text_hook = function()
            BreitbandGraphics.uncached_draw_text = BreitbandGraphics.draw_text
            BreitbandGraphics.draw_text = function(rectangle, horizontal_alignment, vertical_alignment, style, color,
                                                   font_size, font_name,
                                                   text)
                local key = Mupen_lua_ugui_ext.internal.rectangle_to_key(rectangle)
                key = key .. horizontal_alignment
                key = key .. vertical_alignment
                key = key .. (style.clip and tostring(style.clip) or "")
                key = key .. color.r
                key = key .. color.g
                key = key .. color.b
                key = key .. (color.a and color.a or "")
                key = key .. font_size
                key = key .. font_name
                key = key .. (text and text or "")

                if not Mupen_lua_ugui_ext.internal.rt_lut[key] then
                    local render_target = d2d.create_render_target(rectangle.width, rectangle.height)
                    d2d.begin_render_target(render_target)
                    BreitbandGraphics.uncached_draw_text({
                        x = 0,
                        y = 0,
                        width = rectangle.width,
                        height = rectangle.height,
                    }, "center", "center", style, color, font_size, font_name, text)
                    d2d.end_render_target(render_target)

                    Mupen_lua_ugui_ext.internal.rt_lut[key] = render_target
                end
                -- bitmap has same key as render_target
                d2d.draw_image(rectangle.x, rectangle.y,
                    rectangle.x + rectangle.width,
                    rectangle.y + rectangle.height,
                    0, 0, rectangle.width,
                    rectangle.height, Mupen_lua_ugui_ext.internal.rt_lut[key], 1, 0)
            end
        end,

        purge_lut = function()
            -- invalidate LUT and destroy contents
            if d2d.destroy_render_target then
                for i = 1, #Mupen_lua_ugui_ext.internal.rt_lut, 1 do
                    d2d.destroy_render_target(Mupen_lua_ugui_ext.internal.rt_lut[i])
                end
            end
            Mupen_lua_ugui_ext.internal.rt_lut = {}
            print("Purged render target cache")
        end,
    }
}

if not d2d.create_render_target then
    print("Falling back to uncached nineslice rendering. Please update to 1.1.5")
    Mupen_lua_ugui_ext.internal.cached_draw = function(type, rectangle, visual_state, draw)
        draw(rectangle)
    end
end
if not d2d.purge_text_layout_cache then
    print("Using uncached text rendering. Please update to 1.1.6")
end

---Places a Spinner, or NumericUpDown control
---
---Additional fields in the `control` table:
---
--- `value` — `number` The spinner's numerical value
--- `minimum_value` — `number` The spinner's minimum numerical value
--- `maximum_value` — `number` The spinner's maximum numerical value
---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
---@return _ number The new value
Mupen_lua_ugui.spinner = function(control)
    if not Mupen_lua_ugui.standard_styler.spinner_button_thickness then
        Mupen_lua_ugui.standard_styler.spinner_button_thickness = 15
    end

    local value = control.value

    local new_text = Mupen_lua_ugui.textbox({
        uid = control.uid,
        is_enabled = true,
        rectangle = {
            x = control.rectangle.x,
            y = control.rectangle.y,
            width = control.rectangle.width - Mupen_lua_ugui.standard_styler.spinner_button_thickness * 2,
            height = control.rectangle.height,
        },
        text = tostring(value),
    })

    if tonumber(new_text) then
        value = tonumber(new_text)
    end

    if control.is_horizontal then
        if (Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = not (value == control.minimum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        Mupen_lua_ugui.standard_styler.spinner_button_thickness * 2,
                    y = control.rectangle.y,
                    width = Mupen_lua_ugui.standard_styler.spinner_button_thickness,
                    height = control.rectangle.height,
                },
                text = "-",
            }))
        then
            value = value - 1
        end

        if (Mupen_lua_ugui.button({
                uid = control.uid + 2,
                is_enabled = not (value == control.maximum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        Mupen_lua_ugui.standard_styler.spinner_button_thickness,
                    y = control.rectangle.y,
                    width = Mupen_lua_ugui.standard_styler.spinner_button_thickness,
                    height = control.rectangle.height,
                },
                text = "+",
            }))
        then
            value = value + 1
        end
    else
        if (Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = not (value == control.maximum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        Mupen_lua_ugui.standard_styler.spinner_button_thickness * 2,
                    y = control.rectangle.y,
                    width = Mupen_lua_ugui.standard_styler.spinner_button_thickness * 2,
                    height = control.rectangle.height / 2,
                },
                text = "+",
            }))
        then
            value = value + 1
        end

        if (Mupen_lua_ugui.button({
                uid = control.uid + 2,
                is_enabled = not (value == control.minimum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        Mupen_lua_ugui.standard_styler.spinner_button_thickness * 2,
                    y = control.rectangle.y + control.rectangle.height / 2,
                    width = Mupen_lua_ugui.standard_styler.spinner_button_thickness * 2,
                    height = control.rectangle.height / 2,
                },
                text = "-",
            }))
        then
            value = value - 1
        end
    end

    value = Mupen_lua_ugui.internal.clamp(value, control.minimum_value, control.maximum_value)

    return value
end

---Places a tab control for navigation
---
---Additional fields in the `control` table:
---
--- `items` — `string[]` The tab headers
--- `selected_index` — `number` The selected index into the `items` array
---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
---@return _ table A table structured as follows: { selected_index, rectangle }
Mupen_lua_ugui.tabcontrol = function(control)
    if not Mupen_lua_ugui.standard_styler.tab_control_rail_thickness then
        Mupen_lua_ugui.standard_styler.tab_control_rail_thickness = 17
    end
    Mupen_lua_ugui.internal.control_data[control.uid] = {
        y_translation = 0
    }

    local clone = Mupen_lua_ugui.internal.deep_clone(control)
    clone.items = {}
    Mupen_lua_ugui.standard_styler.draw_list(clone, clone.rectangle, nil)

    local x = 0
    local y = 0
    local selected_index = control.selected_index

    for i = 1, #control.items, 1 do
        local item = control.items[i]

        local width = BreitbandGraphics.get_text_size(item, Mupen_lua_ugui.standard_styler.font_size,
            Mupen_lua_ugui.standard_styler.font_name).width + 10

        -- if it would overflow, we wrap onto a new line
        if x + width > control.rectangle.width then
            x = 0
            y = y + Mupen_lua_ugui.standard_styler.tab_control_rail_thickness
        end

        local previous = selected_index == i
        local new = Mupen_lua_ugui.toggle_button({
            uid = control.uid + i,
            is_enabled = control.is_enabled,
            rectangle = {
                x = control.rectangle.x + x,
                y = control.rectangle.y + y,
                width = width,
                height = Mupen_lua_ugui.standard_styler.tab_control_rail_thickness,
            },
            text = control.items[i],
            is_checked = selected_index == i
        })

        if not previous == new then
            selected_index = i
        end

        x = x + width
    end

    return {
        selected_index = selected_index,
        rectangle = {
            x = control.rectangle.x,
            y = control.rectangle.y + Mupen_lua_ugui.standard_styler.tab_control_rail_thickness + y,
            width = control.rectangle.width,
            height = control.rectangle.height - y - Mupen_lua_ugui.standard_styler.tab_control_rail_thickness
        }
    }
end

---Places a number editing box
---
---Additional fields in the `control` table:
---
--- `places` — `number` The amount of places the number is padded to
--- `value` — `number` The current value
---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
---@return _ number The new value
Mupen_lua_ugui.numberbox = function(control)
    if not Mupen_lua_ugui.internal.control_data[control.uid] then
        Mupen_lua_ugui.internal.control_data[control.uid] = {
            active = false,
            caret_index = 1,
        }
    end


    local is_positive = control.value > 0

    -- conditionally visible negative sign button
    if control.show_negative then
        local negative_button_size = control.rectangle.width / 8

        -- NOTE: we clobber the rect ref!!
        control.rectangle = {
            x = control.rectangle.x + negative_button_size,
            y = control.rectangle.y,
            width = control.rectangle.width - negative_button_size,
            height = control.rectangle.height
        }
        if Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = true,
                rectangle = {
                    x = control.rectangle.x - negative_button_size,
                    y = control.rectangle.y,
                    width = negative_button_size,
                    height = control.rectangle.height,
                },
                text = is_positive and "+" or "-"
            }) then
            control.value = -control.value
            is_positive = not is_positive
        end
    end

    -- we dont want sign in display
    control.value = math.abs(control.value)

    local pushed = Mupen_lua_ugui.internal.is_pushed(control)

    -- if active and user clicks elsewhere, deactivate
    if Mupen_lua_ugui.internal.control_data[control.uid].active then
        if not BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) then
            if Mupen_lua_ugui.internal.is_mouse_just_down() then
                -- deactivate, then clear selection
                Mupen_lua_ugui.internal.control_data[control.uid].active = false
                Mupen_lua_ugui.internal.control_data[control.uid].selection_start = nil
                Mupen_lua_ugui.internal.control_data[control.uid].selection_end = nil
            end
        end
    end

    -- new activation via direct click
    if pushed then
        Mupen_lua_ugui.internal.control_data[control.uid].active = true
    end

    local font_size = control.font_size and control.font_size or Mupen_lua_ugui.standard_styler.font_size * 1.5
    local font_name = control.font_name and control.font_name or "Consolas"

    local function get_caret_index_at_relative_x(text, x)
        -- award for most painful basic geometry
        local full_width = BreitbandGraphics.get_text_size(text,
            font_size,
            font_name).width

        local positions = {}
        for i = 1, #text, 1 do
            local width = BreitbandGraphics.get_text_size(text:sub(1, i),
                font_size,
                font_name).width

            local left = control.rectangle.width / 2 - full_width / 2
            positions[#positions + 1] = width + left
        end

        for i = #positions, 1, -1 do
            if x > positions[i] then
                return Mupen_lua_ugui.internal.clamp(i + 1, 1, #positions)
            end
        end
        return 1
    end

    local function increment_digit(index, value)
        control.value = Mupen_lua_ugui_ext.internal.set_digit(control.value, control.places,
            Mupen_lua_ugui_ext.internal.get_digit(control.value, control.places,
                index) + value,
            index)
    end

    local visual_state = Mupen_lua_ugui.get_visual_state(control)
    if Mupen_lua_ugui.internal.control_data[control.uid].active and control.is_enabled then
        visual_state = Mupen_lua_ugui.visual_states.active
    end
    Mupen_lua_ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

    local text = string.format("%0" .. tostring(control.places) .. "d", control.value)

    BreitbandGraphics.draw_text(control.rectangle, "center", "center", {},
        Mupen_lua_ugui.standard_styler.edit_frame_text_colors[visual_state],
        font_size,
        font_name, text)


    -- compute the selected char's rect
    local width
    if Mupen_lua_ugui.internal.control_data[control.uid].caret_index == control.places then
        width = BreitbandGraphics.get_text_size(
                text:sub(1, Mupen_lua_ugui.internal.control_data[control.uid].caret_index),
                font_size,
                font_name).width -
            BreitbandGraphics.get_text_size(
                text:sub(1, Mupen_lua_ugui.internal.control_data[control.uid].caret_index - 1),
                font_size,
                font_name).width
    else
        width = BreitbandGraphics.get_text_size(
                text:sub(1, Mupen_lua_ugui.internal.control_data[control.uid].caret_index + 1),
                font_size,
                font_name).width -
            BreitbandGraphics.get_text_size(text:sub(1, Mupen_lua_ugui.internal.control_data[control.uid].caret_index),
                font_size,
                font_name).width
    end

    local full_width = BreitbandGraphics.get_text_size(text,
        font_size,
        font_name).width
    local left = control.rectangle.width / 2 - full_width / 2
    local selected_char_rect = {
        x = (control.rectangle.x + left) + width * (Mupen_lua_ugui.internal.control_data[control.uid].caret_index - 1),
        y = control.rectangle.y,
        width = width,
        height = control.rectangle.height
    }

    if Mupen_lua_ugui.internal.control_data[control.uid].active then
        -- find the clicked number, change caret index
        if Mupen_lua_ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, control.rectangle) then
            Mupen_lua_ugui.internal.control_data[control.uid].caret_index = get_caret_index_at_relative_x(text,
                Mupen_lua_ugui.internal.input_state.mouse_position.x - control.rectangle.x)
        end

        -- handle number key press
        for key, _ in pairs(Mupen_lua_ugui.internal.get_just_pressed_keys()) do
            local num_1 = tonumber(key)
            local num_2 = tonumber(key:sub(6))
            local value = num_1 and num_1 or num_2

            if value then
                local oldkey = math.floor(control.value /
                    math.pow(10, control.places - Mupen_lua_ugui.internal.control_data[control.uid].caret_index)) % 10
                control.value = control.value +
                    (value - oldkey) *
                    math.pow(10, control.places - Mupen_lua_ugui.internal.control_data[control.uid].caret_index)
                Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.control_data
                    [control.uid]
                    .caret_index + 1
            end

            if key == "left" then
                Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.control_data
                    [control.uid]
                    .caret_index - 1
            end
            if key == "right" then
                Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.control_data
                    [control.uid]
                    .caret_index + 1
            end
            if key == "up" then
                increment_digit(Mupen_lua_ugui.internal.control_data[control.uid].caret_index, 1)
            end
            if key == "down" then
                increment_digit(Mupen_lua_ugui.internal.control_data[control.uid].caret_index, -1)
            end
        end

        if Mupen_lua_ugui.internal.is_mouse_wheel_up() then
            increment_digit(Mupen_lua_ugui.internal.control_data[control.uid].caret_index, 1)
        end
        if Mupen_lua_ugui.internal.is_mouse_wheel_down() then
            increment_digit(Mupen_lua_ugui.internal.control_data[control.uid].caret_index, -1)
        end
        -- draw the char at caret index in inverted color
        BreitbandGraphics.fill_rectangle(selected_char_rect, BreitbandGraphics.hex_to_color('#0078D7'))
        BreitbandGraphics.push_clip(selected_char_rect)
        BreitbandGraphics.draw_text(control.rectangle, "center", "center", {},
            BreitbandGraphics.invert_color(Mupen_lua_ugui.standard_styler.edit_frame_text_colors[visual_state]),
            font_size,
            font_name, text)
        BreitbandGraphics.pop_clip()
    end



    Mupen_lua_ugui.internal.control_data[control.uid].caret_index = Mupen_lua_ugui.internal.clamp(
        Mupen_lua_ugui.internal.control_data[control.uid].caret_index, 1,
        control.places)

    return math.floor(control.value) * (is_positive and 1 or -1)
end

BreitbandGraphics.draw_image_nineslice = function(destination_rectangle, source_rectangle, source_rectangle_center, path,
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
end


Mupen_lua_ugui_ext.apply_nineslice = function(style)
    if d2d.purge_text_layout_cache then
        d2d.purge_text_layout_cache()
    end
    Mupen_lua_ugui_ext.internal.purge_lut()
    Mupen_lua_ugui.standard_styler.draw_raised_frame = function(control, visual_state)
        Mupen_lua_ugui_ext.internal.cached_draw("raised_frame", control.rectangle, visual_state, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.button.states[visual_state].source,
                style.button.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, "nearest")
        end)
    end
    Mupen_lua_ugui.standard_styler.draw_edit_frame = function(control, rectangle,
                                                              visual_state)
        Mupen_lua_ugui_ext.internal.cached_draw("edit_frame", rectangle, visual_state, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.textbox.states[visual_state].source,
                style.textbox.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, "nearest")
        end)
    end
    Mupen_lua_ugui.standard_styler.draw_list_frame = function(rectangle, visual_state)
        Mupen_lua_ugui_ext.internal.cached_draw("list_frame", rectangle, visual_state, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.listbox.states[visual_state].source,
                style.listbox.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, "nearest")
        end)
    end
    Mupen_lua_ugui.standard_styler.draw_list_item = function(item, rectangle, visual_state)
        if not item then
            return
        end

        local rect = BreitbandGraphics.inflate_rectangle(rectangle, -1)

        -- bad idea to cache these
        BreitbandGraphics.draw_image_nineslice(rect,
            style.listbox_item.states[visual_state].source,
            style.listbox_item.states[visual_state].center,
            style.path, BreitbandGraphics.colors.white, "nearest")
        BreitbandGraphics.draw_text({
                x = rect.x + 2,
                y = rect.y,
                width = rect.width,
                height = rect.height,
            }, 'start', 'center', { clip = true },
            Mupen_lua_ugui.standard_styler.list_text_colors[visual_state],
            Mupen_lua_ugui.standard_styler.font_size,
            Mupen_lua_ugui.standard_styler.font_name,
            item)
    end
    Mupen_lua_ugui.standard_styler.draw_scrollbar = function(container_rectangle, thumb_rectangle, visual_state)
        BreitbandGraphics.draw_image(container_rectangle,
            style.scrollbar_rail,
            style.path, BreitbandGraphics.colors.white, "nearest")
        Mupen_lua_ugui_ext.internal.cached_draw(
            "scrollbar_thumb", thumb_rectangle,
            visual_state,
            function(eff_rectangle)
                BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                    style.scrollbar_thumb.states[visual_state].source,
                    style.scrollbar_thumb.states[visual_state].center,
                    style.path, BreitbandGraphics.colors.white, "nearest")
            end)
    end
    Mupen_lua_ugui.standard_styler.raised_frame_text_colors = style.button.text_colors
    Mupen_lua_ugui.standard_styler.edit_frame_text_colors = style.textbox.text_colors
    Mupen_lua_ugui.standard_styler.font_name = style.font_name
    Mupen_lua_ugui.standard_styler.font_size = style.font_size
    Mupen_lua_ugui.standard_styler.list_text_colors = style.listbox.text_colors
    Mupen_lua_ugui.standard_styler.scrollbar_thickness = style.scrollbar_rail.width
end


local function flatten(tree, depth, index, result)
    for i = 1, #tree, 1 do
        local item = tree[i]

        result[#result + 1] = {
            -- we need a reference!
            item = item,
            depth = depth,
            index = index
        }
        index = index + 1

        if item.open then
            index = flatten(item.children, depth + 1, index, result)
        end
    end
    return index
end

---Places a treeview
---
---Additional fields in the `control` table:
---
--- `items` — `table` A nested table of items
---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
---@return _ number The new value
Mupen_lua_ugui.treeview = function(control)
    -- TODO: scrolling
    if not Mupen_lua_ugui.internal.control_data[control.uid] then
        Mupen_lua_ugui.internal.control_data[control.uid] = {
            selected_uid = nil,
        }
    end

    local visual_state = Mupen_lua_ugui.get_visual_state(control)
    Mupen_lua_ugui.standard_styler.draw_list_frame(control.rectangle, visual_state)

    local flattened = {}
    flatten(control.items, 0, 0, flattened)

    local margin_left = 0
    local per_depth_margin = Mupen_lua_ugui.standard_styler.item_height * 2

    for i = 1, #flattened, 1 do
        local item = flattened[i].item
        local meta = flattened[i]

        local item_rectangle = {
            x = control.rectangle.x + (meta.depth * per_depth_margin) + margin_left,
            y = control.rectangle.y + (meta.index * Mupen_lua_ugui.standard_styler.item_height),
            width = control.rectangle.width - ((meta.depth * per_depth_margin) + margin_left),
            height = Mupen_lua_ugui.standard_styler.item_height,
        }
        local button_rectangle = {
            x = item_rectangle.x,
            y = item_rectangle.y,
            width = Mupen_lua_ugui.standard_styler.item_height,
            height = Mupen_lua_ugui.standard_styler.item_height,
        }
        local text_rectangle = {
            x = button_rectangle.x + button_rectangle.width + margin_left,
            y = item_rectangle.y,
            width = item_rectangle.width - button_rectangle.width,
            height = Mupen_lua_ugui.standard_styler.item_height,
        }

        -- we dont need buttons for childless nodes
        if #item.children ~= 0 then
            item.open = Mupen_lua_ugui.toggle_button({
                uid = control.uid + i,
                is_enabled = true,
                is_checked = item.open,
                text = item.open and "-" or "+",
                rectangle = button_rectangle
            })
        end

        local effective_rectangle = #item.children ~= 0 and text_rectangle or item_rectangle

        if BreitbandGraphics.is_point_inside_rectangle(Mupen_lua_ugui.internal.input_state.mouse_position, effective_rectangle) and Mupen_lua_ugui.internal.is_mouse_just_down() then
            Mupen_lua_ugui.internal.control_data[control.uid].selected_uid = item.uid
        end


        Mupen_lua_ugui.standard_styler.draw_list_item(item.content,
            effective_rectangle,
            Mupen_lua_ugui.internal.control_data[control.uid].selected_uid == item.uid and
            Mupen_lua_ugui.visual_states.active or
            Mupen_lua_ugui.visual_states.normal)
    end

    -- return ref to selected item
    for _, value in pairs(flattened) do
        if value.item.uid == Mupen_lua_ugui.internal.control_data[control.uid].selected_uid then
            return value.item
        end
    end
    return nil
end
