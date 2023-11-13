local use_memory_autodetect = false
local default_memory_source = "addresses_usa.lua"

Memory = {
	current = {},
	previous = {},
}

local sources = {
	dofile(res_path .. "addresses_usa.lua"),
	dofile(res_path .. "addresses_japan.lua"),
}
local source = nil

function Memory.update()
	Memory.current.current_area_ptr = memory.readdword(source.current_area_ptr)
	Memory.current.graph_node_root = memory.readdword(source.graph_node_root)
	Memory.current.camera_node = memory.readdword(source.camera_node)
	Memory.current.frustum_node = memory.readdword(source.frustum_node)
	Memory.current.camera_fov = memory.readfloat(source.camera_fov)
	Memory.current.camera_angle = memory.readword(source.camera_angle)
	Memory.current.camera_transition_type = memory.readbyte(source.camera_transition_type)
	Memory.current.camera_transition_progress = memory.readbyte(source.camera_transition_progress)
	Memory.current.camera_x = memory.readfloat(source.camera_x)
	Memory.current.camera_y = memory.readfloat(source.camera_y)
	Memory.current.camera_z = memory.readfloat(source.camera_z)
	Memory.current.camera_yaw = memory.readword(source.camera_yaw)
	Memory.current.camera_pitch = memory.readword(source.camera_pitch)
	Memory.current.holp_x = memory.readfloat(source.holp_x)
	Memory.current.holp_y = memory.readfloat(source.holp_y)
	Memory.current.holp_z = memory.readfloat(source.holp_z)
	Memory.current.mario_facing_yaw = memory.readword(source.mario_facing_yaw)
	Memory.current.mario_intended_yaw = memory.readword(source.mario_intended_yaw)
	Memory.current.mario_h_speed = memory.readdword(source.mario_h_speed)
	Memory.current.mario_v_speed = memory.readdword(source.mario_v_speed)
	Memory.current.mario_x_sliding_speed = memory.readdword(source.mario_x_sliding_speed)
	Memory.current.mario_z_sliding_sped = memory.readdword(source.mario_z_sliding_speed)
	Memory.current.mario_x = memory.readdword(source.mario_x)
	Memory.current.mario_y = memory.readdword(source.mario_y)
	Memory.current.mario_z = memory.readdword(source.mario_z)
	Memory.current.mario_object_pointer = memory.readdword(source.mario_object_pointer)
	Memory.current.mario_object_effective = memory.readdword(source.mario_object_effective)
	Memory.current.mario_action = memory.readdword(source.mario_action)
	Memory.current.mario_action_arg = memory.readdword(source.mario_action_arg)
	Memory.current.mario_f_speed = memory.readfloat(source.mario_f_speed)
	Memory.current.mario_buffered = memory.readbyte(source.mario_buffered)
	Memory.current.mario_global_timer = memory.readdword(source.global_timer)
	Memory.current.rng_value = memory.readword(source.rng_value)
	Memory.current.mario_animation = memory.readword(source.mario_animation)
end

function Memory.update_previous()
	-- update previous values
	Memory.previous = Mupen_lua_ugui.internal.deep_clone(Memory.current)
end

function Memory.initialize()
	if source then
		return
	end

	if use_memory_autodetect then
		-- do the pattern checks and find best candidate
		-- BUG: if we restart the rom, we get bogus data on first frame here
		for i = 1, #sources, 1 do
			local element = sources[i]
			if memory.readdword(element.match_sequence.address) == element.match_sequence.value then
				source = element
				break
			end
		end

		if source == nil then
			print("Rom pattern match failed, falling back to " .. default_memory_source)
			source = sources[1]
		end
	else
		source = dofile(res_path .. default_memory_source)
	end

	print("Memory source: " .. source.name)

	Memory.update()
	Memory.update_previous()
end
