Settings = {
    movement_modes = {
        disabled = 1,
        match_yaw = 2,
        reverse_angle = 3,
        match_angle = 4,
    },
    swimming_button = "A",
    controller_index = 1,
    goal_angle = 0,
    goal_mag = 127,
    override_rng = false,
    override_rng_use_index = false,
    override_rng_value = 0,
    show_effective_angles = true,
    ghost_path = folder .. "recording.ghost",
    strain_left = true,
    strain_right = false,
    dyaw = false,
    strain_speed_target = false,
    strain_always = false,
    high_magnitude = false,
    atan_strain = false,
    swim = false,
    grid_size = 35,
    grid_gap = 2,
    movement_mode = 1,
    track_moved_distance = false,
    moved_distance_ignore_y = false,
    moved_distance = 0,
    moved_distance_axis = {
        x = 0,
        y = 0,
        z = 0
    },
    reverse_arc = false,
    atan_start = 0,
    atan_r = 1.0,
    atan_d = 0.0,
    atan_n = 10,
    atan_exp = 0,
    framewalk = false,
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
    },
}
