Memory = {
	current = {},
	previous = {},
}

function Memory.update()
	Memory.current.camera_fov = memory.readfloat(Settings.offsets.camera_fov)
	Memory.current.camera_angle = memory.readword(Settings.offsets.camera_angle)
	Memory.current.camera_transition_type = memory.readbyte(Settings.offsets.camera_transition_type)
	Memory.current.camera_transition_progress = memory.readbyte(Settings.offsets.camera_transition_progress)
	Memory.current.camera_x = memory.readfloat(Settings.offsets.camera_x)
	Memory.current.camera_y = memory.readfloat(Settings.offsets.camera_y)
	Memory.current.camera_z = memory.readfloat(Settings.offsets.camera_z)
	Memory.current.camera_yaw = memory.readword(Settings.offsets.camera_yaw)
	Memory.current.camera_pitch = memory.readword(Settings.offsets.camera_pitch)
	Memory.current.holp_x = memory.readfloat(Settings.offsets.holp_x)
	Memory.current.holp_y = memory.readfloat(Settings.offsets.holp_y)
	Memory.current.holp_z = memory.readfloat(Settings.offsets.holp_z)
	Memory.current.mario_facing_yaw = memory.readword(Settings.offsets.mario_facing_yaw)
	Memory.current.mario_intended_yaw = memory.readword(Settings.offsets.mario_intended_yaw)
	Memory.current.mario_h_speed = memory.readdword(Settings.offsets.mario_h_speed)
	Memory.current.mario_v_speed = memory.readdword(Settings.offsets.mario_v_speed)
	Memory.current.mario_x_sliding_speed = memory.readdword(Settings.offsets.mario_x_sliding_speed)
	Memory.current.mario_z_sliding_sped = memory.readdword(Settings.offsets.mario_z_sliding_speed)
	Memory.current.mario_x = memory.readdword(Settings.offsets.mario_x)
	Memory.current.mario_y = memory.readdword(Settings.offsets.mario_y)
	Memory.current.mario_z = memory.readdword(Settings.offsets.mario_z)
	Memory.current.mario_object_pointer = memory.readdword(Settings.offsets.mario_object_pointer)
	Memory.current.mario_object_effective = memory.readdword(Settings.offsets.mario_object_effective)
	Memory.current.mario_action = memory.readdword(Settings.offsets.mario_action)
	Memory.current.mario_action_arg = memory.readdword(Settings.offsets.mario_action_arg)
	Memory.current.mario_f_speed = memory.readfloat(Settings.offsets.mario_f_speed)
	Memory.current.mario_buffered = memory.readbyte(Settings.offsets.mario_buffered)
	Memory.current.mario_global_timer = memory.readdword(Settings.offsets.global_timer)
	Memory.current.rng_value = memory.readword(Settings.offsets.rng_value)
	Memory.current.mario_animation = memory.readword(Settings.offsets.mario_animation)
end

function Memory.update_previous()
	-- update previous values
	Memory.previous = Mupen_lua_ugui.internal.deep_clone(Memory.current)
end

function Memory.initialize()
	Memory.update()
	Memory.update_previous()
end

function Memory.load_offsets_from_map(map)

end