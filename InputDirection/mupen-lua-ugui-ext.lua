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
                uid = control.uid + 2,
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
                uid = control.uid + 2,
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

    value = math.min(value, control.maximum_value)
    value = math.max(value, control.minimum_value)

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

        local width = BreitbandGraphics.renderers.d2d.get_text_size(item, Mupen_lua_ugui.stylers.windows_10.font_size,
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
