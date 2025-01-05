Settings = {
    swimming_button = "A",
    controller_index = 1,
    override_rng = false,
    override_rng_use_index = false,
    override_rng_value = 0,
    show_effective_angles = true,
    ghost_path = folder .. "recording.ghost",
    grid_size = 35,
    grid_gap = 2,
    track_moved_distance = false,
    moved_distance_ignore_y = false,
    moved_distance = 0,
    moved_distance_axis = {
        x = 0,
        y = 0,
        z = 0
    },
    atan_exp = 0,
    grind = false,
    grind_divisor = 8,
    grind_left = true,
    lookahead = false,
    lookahead_length = 1,
    format_decimal_points = 4,
    format_angles_degrees = false,
    visualize_objects = false,
    truncate_effective_angle = false,
    active_style_index = 1,
    tab_index = 1,
    settings_tab_index = 1,
    autodetect_address = true,
    auto_firsties = false,
    mini_visualizer = false,
    repaint_throttle = 2,
    read_memory_every_vi = false,
    -- Writes memory values, input data, and frame indicies to a buffer each frame
    dump_enabled = false,
    dump_start_frame = 0,
    variables = {
        {
            identifier = "yaw_facing",
            visible = true
        },
        {
            identifier = "yaw_intended",
            visible = true,
        },
        {
            identifier = "h_spd",
            visible = true,
        },
        {
            identifier = "v_spd",
            visible = true,
        },
        {
            identifier = "spd_efficiency",
            visible = true,
        },
        {
            identifier = "position_x",
            visible = true,
        },
        {
            identifier = "position_y",
            visible = true,
        },
        {
            identifier = "position_z",
            visible = true,
        },
        {
            identifier = "pitch",
            visible = true,
        },
        {
            identifier = "yaw_vel",
            visible = false,
        },
        {
            identifier = "pitch_vel",
            visible = false,
        },
        {
            identifier = "xz_movement",
            visible = true,
        },
        {
            identifier = "action",
            visible = true,
        },
        {
            identifier = "rng",
            visible = true,
        },
        {
            identifier = "moved_dist",
            visible = true
        },
        {
            identifier = "atan_basic",
            visible = true,
        },
        {
            identifier = "atan_start_frame",
            visible = true
        },
    },
    hotkeys = {
        {
            identifier = "movement_mode_disabled",
            keys = {
                "control",
                "1",
            },
        },
        {
            identifier = "movement_mode_match_yaw",
            keys = {
                "control",
                "2",
            },
        },
        {
            identifier = "movement_mode_reverse_angle",
            keys = {
                "control",
                "3",
            },
        },
        {
            identifier = "movement_mode_match_angle",
            keys = {
                "control",
                "4",
            },
        },
        {
            identifier = "preset_down",
            keys = {
                "leftbracket",
            },
        },
        {
            identifier = "preset_up",
            keys = {
                "rightbracket",
            },
        },
        {
            identifier = "copy_yaw_facing_to_match_angle",
            keys = {
                "control",
                "comma",
            },
        },
        {
            identifier = "copy_yaw_intended_to_match_angle",
            keys = {
                "control",
                "period",
            },
        },
        {
            identifier = "toggle_auto_firsties",
            keys = {
                "control",
                "I",
            },
        },
    },
    address_source_index = 1,
}
