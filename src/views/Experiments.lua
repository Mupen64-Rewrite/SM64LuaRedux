return {
    name = "Experiments",
    draw = function()
        if ugui.button({
                uid = 0,

                rectangle = grid_rect(0, 0, 3, 1),
                text = Settings.grind and "Stop" or "Start",
            }) then
            Settings.grind = not Settings.grind
            if Settings.grind then
                Grind.start()
            end
        end
        Settings.grind_left = ugui.toggle_button({
            uid = 5,

            rectangle = grid_rect(6, 0, 1, 1),
            text = "<",
            is_checked = Settings.grind_left
        })
        Settings.grind_left = not ugui.toggle_button({
            uid = 10,

            rectangle = grid_rect(7, 0, 1, 1),
            text = ">",
            is_checked = not Settings.grind_left
        })
        Settings.grind_divisor = math.abs(ugui.numberbox({
            uid = 15,

            rectangle = grid_rect(3, 0, 3, 1),
            value = Settings.grind_divisor,
            places = 2,
        }))

        local lookahead = ugui.toggle_button({
            uid = 20,
            rectangle = grid_rect(0, 1, 3, 1),
            text = "Lookahead",
            is_checked = Settings.lookahead
        })
        if not Settings.lookahead and lookahead then
            Lookahead.start()
        end
        Settings.lookahead = lookahead

        Settings.lookahead_length = math.abs(ugui.numberbox({
            uid = 25,
            rectangle = grid_rect(3, 1, 3, 1),
            value = Settings.lookahead_length,
            places = 1,
        }))
        Settings.visualize_objects = ugui.toggle_button({
            uid = 30,
            rectangle = grid_rect(0, 2, 4, 1),
            text = "Visualize Objects",
            is_checked = Settings.visualize_objects
        })
        Settings.auto_firsties = ugui.toggle_button({
            uid = 35,
            rectangle = grid_rect(0, 3, 4, 1),
            text = "Auto-firsties",
            is_checked = Settings.auto_firsties
        })
        Settings.mini_visualizer = ugui.toggle_button({
            uid = 36,
            rectangle = grid_rect(0, 4, 4, 1),
            text = "Minivisualizer",
            is_checked = Settings.mini_visualizer
        })
        local previous_track_moved_distance = Settings.track_moved_distance
        Settings.track_moved_distance = ugui.toggle_button({
            uid = 40,

            rectangle = grid_rect(0, 14, 4, 1),
            text = 'Moved Distance',
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
            rectangle = grid_rect(4, 14, 2, 1),
            text = 'Ignore Y',
            is_checked = Settings.moved_distance_ignore_y
        })

        local previous_dump_enabled = Settings.dump_enabled
        local now_dump_enabled = ugui.toggle_button({
            uid = 50,
            rectangle = grid_rect(0, 5, 4, 1),
            text = 'Logging',
            is_checked = previous_dump_enabled
        })

        if now_dump_enabled and not previous_dump_enabled then
            Dumping.start()
        end

        if not now_dump_enabled and previous_dump_enabled then
            Dumping.stop()
        end
    end
}
