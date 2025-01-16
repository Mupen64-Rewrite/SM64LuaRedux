WorldVisualizer = {}

-- original by madghostek, adapted to redux model

local camera_depth = 0
local camera_yaw = 0
local camera_pitch = 0

gObjlist = 0x8033D488
objsize = 0x260

--gets all active slots and returns vec3 array of positions
local function get_objects()
    local objects = {}
    local i = 0
    while true do
        if memory.readdword(gObjlist + i * objsize) == 0 then break end

        objects[#objects + 1] = {
            x = memory.readfloat(gObjlist + 0xA0 + i * objsize),
            y = memory.readfloat(gObjlist + 0xA4 + i * objsize),
            z = memory.readfloat(gObjlist + 0xA8 + i * objsize),
            ptr = gObjlist + i * objsize,
            far = 5000,
            close = 50
        }
        i = i + 1
    end
    return objects
end


local function project(vec3)
    local p = ugui.internal.deep_clone(vec3)

    --cam to origin, move point relatively
    p.x = p.x - Memory.current.camera_x
    p.y = p.y - Memory.current.camera_y
    p.z = p.z - Memory.current.camera_z

    --rotate point based on cam yaw
    local t = p.x * math.cos(math.rad(camera_yaw)) - p.z * math.sin(math.rad(camera_yaw))
    p.z = p.x * math.sin(math.rad(camera_yaw)) + p.z * math.cos(math.rad(camera_yaw))
    p.x = t

    --now on cam pitch
    t = p.z * math.cos(math.rad(360 - camera_pitch)) -
        p.y * math.sin(math.rad(360 - camera_pitch))
    p.y = p.z * math.sin(math.rad(360 - camera_pitch)) +
        p.y * math.cos(math.rad(360 - camera_pitch))
    p.z = t
    p.x = -p.x * camera_depth / p.z --apparently x is reversed too
    p.y = -p.y * camera_depth / p.z

    --move to center of screen
    p.x = p.x + Drawing.initial_size.width / 2
    p.y = p.y + Drawing.initial_size.height / 2
    p.z = p.z

    return p
end

local function draw_moved_dist_start_marker(rect)
    local text = "Moved Dist Start"
    local theme = Styles.theme()
    local foreground_color = BreitbandGraphics.invert_color(theme.background_color)
    local text_scale = math.max(1.25, 20 / rect.width)

    local size = BreitbandGraphics.get_text_size(text, theme.font_size * Drawing.scale * text_scale,
        theme.font_name)

    local padding = ugui.standard_styler.params.textbox.padding.x

    size.width = size.width + padding
    size.height = size.height + padding


    local container_rect = {
        x = rect.x - size.width / 2,
        y = rect.y - size.height / 2,
        width = rect.width + size.width,
        height = rect.height + size.height
    }
    BreitbandGraphics.fill_rectangle(container_rect, theme.background_color)

    BreitbandGraphics.fill_ellipse(rect, { r = 0, g = 0, b = 255, a = 128 })

    BreitbandGraphics.draw_text(
        container_rect,
        "center",
        "center",
        { aliased = not theme.cleartype },
        foreground_color,
        theme.font_size * Drawing.scale * text_scale,
        theme.font_name,
        text)
end

WorldVisualizer.draw = function()
    if not Settings.worldviz_enabled then
        return
    end



    camera_depth = (Drawing.initial_size.height - 29) / (2 * math.tan(math.rad(Memory.current.camera_fov / 2)))
    camera_yaw = Memory.current.camera_yaw / 182.04
    camera_pitch = Memory.current.camera_pitch / 182.04


    local objects = get_objects()

    objects[#objects + 1] = {
        x = Settings.moved_distance_axis.x,
        y = Settings.moved_distance_axis.y,
        z = Settings.moved_distance_axis.z,
        close = 50,
        far = 5000,
        draw = draw_moved_dist_start_marker,
    }

    for _, o in pairs(objects) do
        local p = project(o);

        if p.z < o.close or p.z > o.far then
            goto continue
        end

        local offset = 30000 / p.z

        local rect = {
            x = math.floor(p.x - offset / 2),
            y = math.floor(p.y - offset / 2),
            width = math.floor(offset),
            height = math.floor(offset),
        }

        if o.draw then
            o.draw(rect)
        else
            BreitbandGraphics.draw_rectangle(rect, o.color or BreitbandGraphics.colors.red, 1)
        end

        ::continue::
    end
end
