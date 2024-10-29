-- mupen-lua-ugui-ext 1.3.0
-- https://github.com/Aurumaker72/mupen-lua-ugui

if not ugui then
    error("ugui must be present in the global scope prior to executing ugui-ext", 0)
    return
end

ugui_ext = {
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
    get_digit = function(value, length, index)
        return math.floor(value / math.pow(10, length - index)) % 10
    end,
    set_digit = function(value, length, digit_value, index)
        local old_digit_value = ugui_ext.get_digit(value, length, index)
        local new_value = value + (digit_value - old_digit_value) * math.pow(10, length - index)
        local max = math.pow(10, length)
        return (new_value + max) % max
    end,
    internal = {
        drawings = {},
        -- 1.1.5 - 1.1.6
        rt_lut = {},
        rectangle_to_key = function(rectangle)
            return rectangle.x .. rectangle.y .. rectangle.width .. rectangle.height
        end,
        params_to_key = function(type, rectangle, visual_state)
            return type .. visual_state .. ugui_ext.internal.rectangle_to_key(rectangle)
        end,
        cached_draw = function(key, rectangle, draw_callback)
            if not ugui_ext.internal.rt_lut[key] then
                local render_target = d2d.create_render_target(rectangle.width, rectangle.height)
                d2d.begin_render_target(render_target)
                draw_callback({
                    x = 0,
                    y = 0,
                    width = rectangle.width,
                    height = rectangle.height,
                })
                d2d.end_render_target(render_target)

                ugui_ext.internal.rt_lut[key] = render_target
            end
            -- bitmap has same key as render_target
            d2d.draw_image(rectangle.x, rectangle.y,
                rectangle.x + rectangle.width,
                rectangle.y + rectangle.height,
                0, 0, rectangle.width,
                rectangle.height, ugui_ext.internal.rt_lut[key], 1, 0)
        end,

    },
    free = function()
        if d2d and d2d.destroy_render_target then
            for i = 1, #ugui_ext.internal.rt_lut, 1 do
                d2d.destroy_render_target(ugui_ext.internal.rt_lut[i])
            end
        end
        ugui_ext.internal.rt_lut = {}
        print("Purged render target cache")
    end,
}


if d2d.draw_to_image then
    print("Using 1.1.7 cached drawing")

    ugui_ext.internal.cached_draw = function(key, rectangle, draw_callback)
        if not ugui_ext.internal.drawings[key] then
            ugui_ext.internal.drawings[key] = d2d.draw_to_image(rectangle.width, rectangle.height, function()
                draw_callback({
                    x = 0,
                    y = 0,
                    width = math.floor(rectangle.width),
                    height = math.floor(rectangle.height),
                })
            end)
        end
        d2d.draw_image(
            math.floor(rectangle.x),
            math.floor(rectangle.y),
            math.floor(rectangle.x + rectangle.width),
            math.floor(rectangle.y + rectangle.height),
            0,
            0,
            math.floor(rectangle.width),
            math.floor(rectangle.height), 1, 0, ugui_ext.internal.drawings[key])
    end
    ugui_ext.free = function()
        for key, value in pairs(ugui_ext.internal.drawings) do
            d2d.free_image(value)
        end
        ugui_ext.internal.drawings = {}
    end
end

if not d2d.create_render_target and not d2d.draw_to_image then
    print(
        "Falling back to uncached nineslice rendering, this will severely degrade performance. Please update to mupen64-rr-lua 1.1.5")
    ugui_ext.internal.cached_draw = function(key, rectangle, draw_callback)
        draw_callback(rectangle)
    end
end

---Places a Spinner, or NumericUpDown control
---
---Additional fields in the `control` table:
---
--- `value` — `number` The spinner's numerical value
--- `minimum_value` — `number` The spinner's minimum numerical value
--- `maximum_value` — `number` The spinner's maximum numerical value
--- `increment` — `number` The increment applied when the + or - buttons are clicked
---@param control table A table abiding by the mupen-lua-ugui control contract (`{ uid, is_enabled, rectangle }`)
---@return _ number The new value
ugui.spinner = function(control)
    ugui.internal.validate_control(control)

    if not ugui.standard_styler.spinner_button_thickness then
        ugui.standard_styler.spinner_button_thickness = 15
    end
    local increment = control.increment or 1

    local value = control.value

    local textbox_rect = {
        x = control.rectangle.x,
        y = control.rectangle.y,
        width = control.rectangle.width - ugui.standard_styler.spinner_button_thickness * 2,
        height = control.rectangle.height,
    }

    local new_text = ugui.textbox({
        uid = control.uid,
        rectangle = textbox_rect,
        text = tostring(value),
    })

    if tonumber(new_text) then
        value = tonumber(new_text)
    end

    local ignored = BreitbandGraphics.is_point_inside_any_rectangle(
        ugui.internal.environment.mouse_position, ugui.internal.hittest_free_rects)

    if control.is_enabled ~= false
        and not ignored
        and (BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, textbox_rect) or ugui.internal.active_control == control.uid) 
        then
        if ugui.internal.is_mouse_wheel_up() then
            value = value + 1
        end
        if ugui.internal.is_mouse_wheel_down() then
            value = value - 1
        end
    end

    value = ugui.internal.clamp(value, control.minimum_value, control.maximum_value)

    if control.is_horizontal then
        if (ugui.button({
                uid = control.uid + 1,
                is_enabled = not (value == control.minimum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        ugui.standard_styler.spinner_button_thickness * 2,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.spinner_button_thickness,
                    height = control.rectangle.height,
                },
                text = "-",
            }))
        then
            value = value - increment
        end

        if (ugui.button({
                uid = control.uid + 2,
                is_enabled = not (value == control.maximum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        ugui.standard_styler.spinner_button_thickness,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.spinner_button_thickness,
                    height = control.rectangle.height,
                },
                text = "+",
            }))
        then
            value = value + increment
        end
    else
        if (ugui.button({
                uid = control.uid + 1,
                is_enabled = not (value == control.maximum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        ugui.standard_styler.spinner_button_thickness * 2,
                    y = control.rectangle.y,
                    width = ugui.standard_styler.spinner_button_thickness * 2,
                    height = control.rectangle.height / 2,
                },
                text = "+",
            }))
        then
            value = value + increment
        end

        if (ugui.button({
                uid = control.uid + 2,
                is_enabled = not (value == control.minimum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        ugui.standard_styler.spinner_button_thickness * 2,
                    y = control.rectangle.y + control.rectangle.height / 2,
                    width = ugui.standard_styler.spinner_button_thickness * 2,
                    height = control.rectangle.height / 2,
                },
                text = "-",
            }))
        then
            value = value - increment
        end
    end

    value = ugui.internal.clamp(value, control.minimum_value, control.maximum_value)

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
ugui.tabcontrol = function(control)
    ugui.internal.validate_and_register_control(control)

    if not ugui.standard_styler.tab_control_rail_thickness then
        ugui.standard_styler.tab_control_rail_thickness = 17
    end
    if ugui.standard_styler.tab_control_draw_frame == nil then
        ugui.standard_styler.tab_control_draw_frame = true
    end
    if ugui.standard_styler.tab_control_gap_x == nil then
        ugui.standard_styler.tab_control_gap_x = 0
    end
    if ugui.standard_styler.tab_control_gap_y == nil then
        ugui.standard_styler.tab_control_gap_y = 0
    end

    ugui.internal.control_data[control.uid] = {
        y_translation = 0
    }

    if ugui.standard_styler.tab_control_draw_frame then
        local clone = ugui.internal.deep_clone(control)
        clone.items = {}
        ugui.standard_styler.draw_list(clone, clone.rectangle)
    end

    local x = 0
    local y = 0
    local selected_index = control.selected_index

    for i = 1, #control.items, 1 do
        local item = control.items[i]

        local width = BreitbandGraphics.get_text_size(item, ugui.standard_styler.font_size,
            ugui.standard_styler.font_name).width + 10

        -- if it would overflow, we wrap onto a new line
        if x + width > control.rectangle.width then
            x = 0
            y = y + ugui.standard_styler.tab_control_rail_thickness + ugui.standard_styler.tab_control_gap_y
        end

        local previous = selected_index == i
        local new = ugui.toggle_button({
            uid = control.uid + i,
            is_enabled = control.is_enabled,
            rectangle = {
                x = control.rectangle.x + x,
                y = control.rectangle.y + y,
                width = width,
                height = ugui.standard_styler.tab_control_rail_thickness,
            },
            text = control.items[i],
            is_checked = selected_index == i
        })

        if not previous == new then
            selected_index = i
        end

        x = x + width + ugui.standard_styler.tab_control_gap_x
    end

    return {
        selected_index = selected_index,
        rectangle = {
            x = control.rectangle.x,
            y = control.rectangle.y + ugui.standard_styler.tab_control_rail_thickness + y,
            width = control.rectangle.width,
            height = control.rectangle.height - y - ugui.standard_styler.tab_control_rail_thickness
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
ugui.numberbox = function(control)
    ugui.internal.validate_and_register_control(control)

    if not ugui.internal.control_data[control.uid] then
        ugui.internal.control_data[control.uid] = {
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
        if ugui.button({
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

    local pushed = ugui.internal.process_push(control)

    if pushed then
        ugui.internal.clear_active_control_after_mouse_up = false
    end

    -- if active and user clicks elsewhere, deactivate
    if ugui.internal.active_control == control.uid then
        if not BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
            if ugui.internal.is_mouse_just_down() then
                -- deactivate, then clear selection
                ugui.internal.active_control = nil
                ugui.internal.control_data[control.uid].selection_start = nil
                ugui.internal.control_data[control.uid].selection_end = nil
            end
        end
    end

    local font_size = control.font_size and control.font_size or ugui.standard_styler.font_size * 1.5
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
                return ugui.internal.clamp(i + 1, 1, #positions)
            end
        end
        return 1
    end

    local function increment_digit(index, value)
        control.value = ugui_ext.set_digit(control.value, control.places,
            ugui_ext.get_digit(control.value, control.places,
                index) + value,
            index)
    end

    local visual_state = ugui.get_visual_state(control)
    if ugui.internal.active_control == control.uid and control.is_enabled then
        visual_state = ugui.visual_states.active
    end
    ugui.standard_styler.draw_edit_frame(control, control.rectangle, visual_state)

    local text = string.format("%0" .. tostring(control.places) .. "d", control.value)

    BreitbandGraphics.draw_text(control.rectangle, "center", "center",
        { aliased = not ugui.standard_styler.cleartype },
        ugui.standard_styler.edit_frame_text_colors[visual_state],
        font_size,
        font_name, text)


    -- compute the selected char's rect
    local width
    if ugui.internal.control_data[control.uid].caret_index == control.places then
        width = BreitbandGraphics.get_text_size(
                text:sub(1, ugui.internal.control_data[control.uid].caret_index),
                font_size,
                font_name).width -
            BreitbandGraphics.get_text_size(
                text:sub(1, ugui.internal.control_data[control.uid].caret_index - 1),
                font_size,
                font_name).width
    else
        width = BreitbandGraphics.get_text_size(
                text:sub(1, ugui.internal.control_data[control.uid].caret_index + 1),
                font_size,
                font_name).width -
            BreitbandGraphics.get_text_size(text:sub(1, ugui.internal.control_data[control.uid].caret_index),
                font_size,
                font_name).width
    end

    local full_width = BreitbandGraphics.get_text_size(text,
        font_size,
        font_name).width
    local left = control.rectangle.width / 2 - full_width / 2
    local selected_char_rect = {
        x = (control.rectangle.x + left) + width * (ugui.internal.control_data[control.uid].caret_index - 1),
        y = control.rectangle.y,
        width = width,
        height = control.rectangle.height
    }

    if ugui.internal.active_control == control.uid then
        -- find the clicked number, change caret index
        if ugui.internal.is_mouse_just_down() and BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, control.rectangle) then
            ugui.internal.control_data[control.uid].caret_index = get_caret_index_at_relative_x(text,
                ugui.internal.environment.mouse_position.x - control.rectangle.x)
        end

        -- handle number key press
        for key, _ in pairs(ugui.internal.get_just_pressed_keys()) do
            local num_1 = tonumber(key)
            local num_2 = tonumber(key:sub(7))
            local value = num_1 and num_1 or num_2

            if value then
                local oldkey = math.floor(control.value /
                    math.pow(10, control.places - ugui.internal.control_data[control.uid].caret_index)) % 10
                control.value = control.value +
                    (value - oldkey) *
                    math.pow(10, control.places - ugui.internal.control_data[control.uid].caret_index)
                ugui.internal.control_data[control.uid].caret_index = ugui.internal.control_data
                    [control.uid]
                    .caret_index + 1
            end

            if key == "left" then
                ugui.internal.control_data[control.uid].caret_index = ugui.internal.control_data
                    [control.uid]
                    .caret_index - 1
            end
            if key == "right" then
                ugui.internal.control_data[control.uid].caret_index = ugui.internal.control_data
                    [control.uid]
                    .caret_index + 1
            end
            if key == "up" then
                increment_digit(ugui.internal.control_data[control.uid].caret_index, 1)
            end
            if key == "down" then
                increment_digit(ugui.internal.control_data[control.uid].caret_index, -1)
            end
        end

        if ugui.internal.is_mouse_wheel_up() then
            increment_digit(ugui.internal.control_data[control.uid].caret_index, 1)
        end
        if ugui.internal.is_mouse_wheel_down() then
            increment_digit(ugui.internal.control_data[control.uid].caret_index, -1)
        end
        -- draw the char at caret index in inverted color
        BreitbandGraphics.fill_rectangle(selected_char_rect, BreitbandGraphics.hex_to_color('#0078D7'))
        BreitbandGraphics.push_clip(selected_char_rect)
        BreitbandGraphics.draw_text(control.rectangle, "center", "center",
            { aliased = not ugui.standard_styler.cleartype },
            BreitbandGraphics.invert_color(ugui.standard_styler.edit_frame_text_colors[visual_state]),
            font_size,
            font_name, text)
        BreitbandGraphics.pop_clip()
    end



    ugui.internal.control_data[control.uid].caret_index = ugui.internal.clamp(
        ugui.internal.control_data[control.uid].caret_index, 1,
        control.places)

    return math.floor(control.value) * (is_positive and 1 or -1)
end


ugui_ext.apply_nineslice = function(style)
    if not d2d then
        print("No D2D available, falling back to unchanged standard styler to avoid performance issues")
        return
    end
    ugui_ext.free()
    ugui.standard_styler.draw_raised_frame = function(control, visual_state)
        local key = ugui_ext.internal.params_to_key("raised_frame", control.rectangle, visual_state)

        ugui_ext.internal.cached_draw(key, control.rectangle, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.button.states[visual_state].source,
                style.button.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, "nearest")
        end)
    end
    ugui.standard_styler.draw_edit_frame = function(control, rectangle,
                                                    visual_state)
        local key = ugui_ext.internal.params_to_key("edit_frame", rectangle, visual_state)

        ugui_ext.internal.cached_draw(key, rectangle, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.textbox.states[visual_state].source,
                style.textbox.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, "nearest")
        end)
    end
    ugui.standard_styler.draw_list_frame = function(rectangle, visual_state)
        local key = ugui_ext.internal.params_to_key("list_frame", rectangle, visual_state)

        ugui_ext.internal.cached_draw(key, rectangle, function(eff_rectangle)
            BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                style.listbox.states[visual_state].source,
                style.listbox.states[visual_state].center,
                style.path, BreitbandGraphics.colors.white, "nearest")
        end)
    end
    ugui.standard_styler.draw_list_item = function(item, rectangle, visual_state)
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
                x = rectangle.x + 2,
                y = rectangle.y,
                width = rectangle.width,
                height = rectangle.height,
            }, 'start', 'center', { clip = true, aliased = not ugui.standard_styler.cleartype },
            ugui.standard_styler.list_text_colors[visual_state],
            ugui.standard_styler.font_size,
            ugui.standard_styler.font_name,
            item)
    end
    ugui.standard_styler.draw_scrollbar = function(container_rectangle, thumb_rectangle, visual_state)
        BreitbandGraphics.draw_image(container_rectangle,
            style.scrollbar_rail,
            style.path, BreitbandGraphics.colors.white, "nearest")

        local key = ugui_ext.internal.params_to_key("scrollbar_thumb", thumb_rectangle, visual_state)

        ugui_ext.internal.cached_draw(
            key,
            thumb_rectangle,
            function(eff_rectangle)
                BreitbandGraphics.draw_image_nineslice(eff_rectangle,
                    style.scrollbar_thumb.states[visual_state].source,
                    style.scrollbar_thumb.states[visual_state].center,
                    style.path, BreitbandGraphics.colors.white, "nearest")
            end)
    end
    -- TODO: Refactor this into property override mask!!!
    ugui.standard_styler.raised_frame_text_colors = style.button.text_colors
    ugui.standard_styler.edit_frame_text_colors = style.textbox.text_colors
    ugui.standard_styler.font_name = style.font_name
    ugui.standard_styler.font_size = style.font_size
    ugui.standard_styler.item_height = style.item_height
    ugui.standard_styler.list_text_colors = style.listbox.text_colors
    ugui.standard_styler.scrollbar_thickness = style.scrollbar_rail.width
    ugui.standard_styler.cleartype = not style.pixelated_text
    ugui.standard_styler.joystick_tip_size = style.joystick_tip_size
    ugui.standard_styler.joystick_back_colors = style.joystick.back_colors
    ugui.standard_styler.joystick_outline_colors = style.joystick.outline_colors
    ugui.standard_styler.joystick_inner_mag_colors = style.joystick.inner_mag_colors
    ugui.standard_styler.joystick_outer_mag_colors = style.joystick.outer_mag_colors
    ugui.standard_styler.joystick_mag_thicknesses = style.joystick.mag_thicknesses
    ugui.standard_styler.joystick_line_colors = style.joystick.line_colors
    ugui.standard_styler.joystick_tip_colors = style.joystick.tip_colors
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
ugui.treeview = function(control)
    ugui.internal.validate_and_register_control(control)

    -- TODO: scrolling
    if not ugui.internal.control_data[control.uid] then
        ugui.internal.control_data[control.uid] = {
            selected_uid = nil,
        }
    end

    local visual_state = ugui.get_visual_state(control)
    ugui.standard_styler.draw_list_frame(control.rectangle, visual_state)

    local flattened = {}
    flatten(control.items, 0, 0, flattened)

    local margin_left = 0
    local per_depth_margin = ugui.standard_styler.item_height * 2

    for i = 1, #flattened, 1 do
        local item = flattened[i].item
        local meta = flattened[i]

        local item_rectangle = {
            x = control.rectangle.x + (meta.depth * per_depth_margin) + margin_left,
            y = control.rectangle.y + (meta.index * ugui.standard_styler.item_height),
            width = control.rectangle.width - ((meta.depth * per_depth_margin) + margin_left),
            height = ugui.standard_styler.item_height,
        }
        local button_rectangle = {
            x = item_rectangle.x,
            y = item_rectangle.y,
            width = ugui.standard_styler.item_height,
            height = ugui.standard_styler.item_height,
        }
        local text_rectangle = {
            x = button_rectangle.x + button_rectangle.width + margin_left,
            y = item_rectangle.y,
            width = item_rectangle.width - button_rectangle.width,
            height = ugui.standard_styler.item_height,
        }

        -- we dont need buttons for childless nodes
        if #item.children ~= 0 then
            item.open = ugui.toggle_button({
                uid = control.uid + i,
                is_enabled = true,
                is_checked = item.open,
                text = item.open and "-" or "+",
                rectangle = button_rectangle
            })
        end

        local effective_rectangle = #item.children ~= 0 and text_rectangle or item_rectangle

        if BreitbandGraphics.is_point_inside_rectangle(ugui.internal.environment.mouse_position, effective_rectangle) and ugui.internal.is_mouse_just_down() then
            ugui.internal.control_data[control.uid].selected_uid = item.uid
        end


        ugui.standard_styler.draw_list_item(item.content,
            effective_rectangle,
            ugui.internal.control_data[control.uid].selected_uid == item.uid and
            ugui.visual_states.active or
            ugui.visual_states.normal)
    end

    -- return ref to selected item
    for _, value in pairs(flattened) do
        if value.item.uid == ugui.internal.control_data[control.uid].selected_uid then
            return value.item
        end
    end
    return nil
end
