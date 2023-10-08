Mupen_lua_ugui_ext = {}
local function deep_clone(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[deep_clone(k, s)] = deep_clone(v, s) end
    return res
end

local function clamp(value, min, max)
    return math.max(math.min(value, max), min)
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
    if not Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness then
        Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness = 15
    end

    local value = control.value

    local new_text = Mupen_lua_ugui.textbox({
        uid = control.uid,
        is_enabled = true,
        rectangle = {
            x = control.rectangle.x,
            y = control.rectangle.y,
            width = control.rectangle.width - Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness * 2,
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
                        Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness * 2,
                    y = control.rectangle.y,
                    width = Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness,
                    height = control.rectangle.height,
                },
                text = "-",
            }))
        then
            value = value - 1
        end

        if (Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = not (value == control.maximum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness,
                    y = control.rectangle.y,
                    width = Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness,
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
                        Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness * 2,
                    y = control.rectangle.y,
                    width = Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness * 2,
                    height = control.rectangle.height / 2,
                },
                text = "+",
            }))
        then
            value = value + 1
        end

        if (Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = not (value == control.minimum_value),
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width -
                        Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness * 2,
                    y = control.rectangle.y + control.rectangle.height / 2,
                    width = Mupen_lua_ugui.stylers.windows_10.spinner_button_thickness * 2,
                    height = control.rectangle.height / 2,
                },
                text = "-",
            }))
        then
            value = value - 1
        end
    end

    value = clamp(value, control.minimum_value, control.maximum_value)

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
    if not Mupen_lua_ugui.stylers.windows_10.tab_control_rail_thickness then
        Mupen_lua_ugui.stylers.windows_10.tab_control_rail_thickness = 17
    end
    Mupen_lua_ugui.control_data[control.uid] = {
        y_translation = 0
    }

    local clone = deep_clone(control)
    clone.items = {}
    Mupen_lua_ugui.stylers.windows_10.draw_list(clone, clone.rectangle, nil)

    local x = 0
    local y = 0
    local selected_index = control.selected_index

    for i = 1, #control.items, 1 do
        local item = control.items[i]

        local width = BreitbandGraphics.get_text_size(item, Mupen_lua_ugui.stylers.windows_10.font_size,
            Mupen_lua_ugui.stylers.windows_10.font_name).width + 10

        -- if it would overflow, we wrap onto a new line
        if x + width > control.rectangle.width then
            x = 0
            y = y + Mupen_lua_ugui.stylers.windows_10.tab_control_rail_thickness
        end

        local previous = selected_index == i
        local new = Mupen_lua_ugui.toggle_button({
            uid = control.uid + i,
            is_enabled = control.is_enabled,
            rectangle = {
                x = control.rectangle.x + x,
                y = control.rectangle.y + y,
                width = width,
                height = Mupen_lua_ugui.stylers.windows_10.tab_control_rail_thickness,
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
            y = control.rectangle.y + Mupen_lua_ugui.stylers.windows_10.tab_control_rail_thickness + y,
            width = control.rectangle.width,
            height = control.rectangle.height - y - Mupen_lua_ugui.stylers.windows_10.tab_control_rail_thickness
        }
    }
end


BreitbandGraphics.draw_image_nineslice = function(destination_rectangle, source_rectangle, source_rectangle_center, path,
                                                  color, filter)
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
    Mupen_lua_ugui.stylers.windows_10.draw_raised_frame = function(control, visual_state)
        BreitbandGraphics.draw_image_nineslice(control.rectangle,
            style.button.states[visual_state].source,
            style.button.states[visual_state].center,
            style.path, BreitbandGraphics.colors.white, "nearest")
    end
    Mupen_lua_ugui.stylers.windows_10.draw_edit_frame = function(control, rectangle,
                                                                 visual_state)
        BreitbandGraphics.draw_image_nineslice(rectangle,
            style.textbox.states[visual_state].source,
            style.textbox.states[visual_state].center,
            style.path, BreitbandGraphics.colors.white, "nearest")
    end
    Mupen_lua_ugui.stylers.windows_10.draw_list_frame = function(rectangle, visual_state)
        BreitbandGraphics.draw_image_nineslice(rectangle,
            style.listbox.states[visual_state].source,
            style.listbox.states[visual_state].center,
            style.path, BreitbandGraphics.colors.white, "nearest")
    end
    Mupen_lua_ugui.stylers.windows_10.draw_list_item = function(item, rectangle, visual_state)
        BreitbandGraphics.draw_image_nineslice(rectangle,
            style.listbox_item.states[visual_state].source,
            style.listbox_item.states[visual_state].center,
            style.path, BreitbandGraphics.colors.white, "nearest")
        Mupen_lua_ugui.renderer.draw_text({
                x = rectangle.x + 2,
                y = rectangle.y,
                width = rectangle.width,
                height = rectangle.height,
            }, 'start', 'center', { clip = true },
            Mupen_lua_ugui.stylers.windows_10.list_text_colors[visual_state],
            Mupen_lua_ugui.stylers.windows_10.font_size,
            Mupen_lua_ugui.stylers.windows_10.font_name,
            item)
    end

    Mupen_lua_ugui.stylers.windows_10.raised_frame_text_colors = style.button.text_colors
    Mupen_lua_ugui.stylers.windows_10.edit_frame_text_colors = style.textbox.text_colors
    Mupen_lua_ugui.stylers.windows_10.font_name = style.font_name
    Mupen_lua_ugui.stylers.windows_10.font_size = style.font_size
    Mupen_lua_ugui.stylers.windows_10.list_text_colors = style.listbox.text_colors
end
