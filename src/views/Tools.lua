local RNG_ROW = 1
local AUTO_GRIND_ROW = 3
local LOOKAHEAD_ROW = 5
local DUMPING_ROW = 7
local GHOST_ROW = 9
local EXPERIMENTS_ROW = 11

return {
    name = "Tools",
    draw = function()
        local theme = Presets.styles[Settings.active_style_index].theme
        local foreground_color = BreitbandGraphics.invert_color(theme.background_color)

        BreitbandGraphics.draw_text(
            grid_rect(0, RNG_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = theme.pixelated_text },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            "RNG")

        Settings.override_rng = ugui.toggle_button({
            uid = 55,
            rectangle = grid_rect(0, RNG_ROW, 2, 1),
            text = "Lock to",
            is_checked = Settings.override_rng,
        })
        Settings.override_rng_use_index = ugui.toggle_button({
            uid = 60,
            is_enabled = Settings.override_rng,
            rectangle = grid_rect(6, RNG_ROW, 2, 1),
            text = "Use Index",
            is_checked = Settings.override_rng_use_index,
        })
        Settings.override_rng_value = math.floor(ugui.spinner({
            uid = 65,
            is_enabled = Settings.override_rng,
            rectangle = grid_rect(2, RNG_ROW, 4, 1),
            value = Settings.override_rng_value,
            minimum_value = math.mininteger,
            maximum_value = math.maxinteger
        }))

        BreitbandGraphics.draw_text(
            grid_rect(0, AUTO_GRIND_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = theme.pixelated_text },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            "Auto-Grind")
        if ugui.button({
                uid = 0,
                rectangle = grid_rect(0, AUTO_GRIND_ROW, 3, 1),
                text = Settings.grind and "Stop" or "Start",
            }) then
            Settings.grind = not Settings.grind
            if Settings.grind then
                Grind.start()
            end
        end

        Settings.grind_left = ugui.toggle_button({
            uid = 5,
            rectangle = grid_rect(6, AUTO_GRIND_ROW, 1, 1),
            text = "<",
            is_checked = Settings.grind_left
        })
        Settings.grind_left = not ugui.toggle_button({
            uid = 10,
            rectangle = grid_rect(7, AUTO_GRIND_ROW, 1, 1),
            text = ">",
            is_checked = not Settings.grind_left
        })
        Settings.grind_divisor = math.abs(ugui.numberbox({
            uid = 15,
            rectangle = grid_rect(3, AUTO_GRIND_ROW, 3, 1),
            value = Settings.grind_divisor,
            places = 2,
        }))

        BreitbandGraphics.draw_text(
            grid_rect(0, LOOKAHEAD_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = theme.pixelated_text },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            "Lookahead")
        local lookahead = ugui.toggle_button({
            uid = 20,
            rectangle = grid_rect(0, LOOKAHEAD_ROW, 3, 1),
            text = "Enable",
            is_checked = Settings.lookahead
        })
        if not Settings.lookahead and lookahead then
            Lookahead.start()
        end
        Settings.lookahead = lookahead

        Settings.lookahead_length = math.abs(ugui.numberbox({
            uid = 25,
            rectangle = grid_rect(3, LOOKAHEAD_ROW, 2, 1),
            value = Settings.lookahead_length,
            places = 1,
        }))

        BreitbandGraphics.draw_text(
            grid_rect(0, DUMPING_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = theme.pixelated_text },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            "Dumping")

        local previous_dump_enabled = Settings.dump_enabled
        local now_dump_enabled = ugui.toggle_button({
            uid = 50,
            rectangle = grid_rect(0, DUMPING_ROW, 4, 1),
            text = Settings.dump_enabled and 'Stop' or 'Start',
            is_checked = previous_dump_enabled
        })

        if now_dump_enabled and not previous_dump_enabled then
            Dumping.start()
        end

        if not now_dump_enabled and previous_dump_enabled then
            Dumping.stop()
        end


        BreitbandGraphics.draw_text(
            grid_rect(0, GHOST_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = theme.pixelated_text },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            "Ghost")

        if ugui.button({
                uid = 100,
                rectangle = grid_rect(0, GHOST_ROW, 4, 1),
                text = Ghost.is_recording and "Stop Recording" or "Start Recording",
            }) then
            Ghost.toggle_recording()
        end

        BreitbandGraphics.draw_text(
            grid_rect(0, EXPERIMENTS_ROW - 1, 8, 1),
            "start",
            "center",
            { aliased = theme.pixelated_text },
            foreground_color,
            theme.font_size * Drawing.scale * 1.25,
            theme.font_name,
            "Experiments")

        Settings.visualize_objects = ugui.toggle_button({
            uid = 30,
            rectangle = grid_rect(0, EXPERIMENTS_ROW + 2, 4, 1),
            text = "Object Visualizer",
            is_checked = Settings.visualize_objects
        })
        Settings.auto_firsties = ugui.toggle_button({
            uid = 35,
            rectangle = grid_rect(3, EXPERIMENTS_ROW + 1, 3, 1),
            text = "Auto-firsties",
            is_checked = Settings.auto_firsties
        })
        Settings.mini_visualizer = ugui.toggle_button({
            uid = 36,
            rectangle = grid_rect(0, EXPERIMENTS_ROW + 1, 3, 1),
            text = "Input Overlay",
            is_checked = Settings.mini_visualizer
        })
        local previous_track_moved_distance = Settings.track_moved_distance
        Settings.track_moved_distance = ugui.toggle_button({
            uid = 40,
            rectangle = grid_rect(0, EXPERIMENTS_ROW, 3, 1),
            text = 'Moved Dist',
            is_checked = Settings.track_moved_distance
        })
        if Settings.track_moved_distance and not previous_track_moved_distance then
            Settings.moved_distance_axis.x = Memory.current.mario_x
            Settings.moved_distance_axis.y = Memory.current.mario_y
            Settings.moved_distance_axis.z = Memory.current.mario_z
        end
        if not Settings.track_moved_distance and previous_track_moved_distance then
            Settings.moved_distance = Engine.GetTotalDistMoved()
        end
        Settings.moved_distance_ignore_y = ugui.toggle_button({
            uid = 45,
            rectangle = grid_rect(3, EXPERIMENTS_ROW, 2, 1),
            text = 'Ignore Y',
            is_checked = Settings.moved_distance_ignore_y
        })
    end
}
