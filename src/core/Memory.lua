Memory = {
	current = {
		mario = {},
		camera = {},
		rng_value = 0,
	},

	previous = {}
}

local sources = {
	dofile(res_path .. "addresses_usa.lua"),
	dofile(res_path .. "addresses_japan.lua"),
}
local source = nil

function Memory.update()

	-- update previous values
	local current = Mupen_lua_ugui.internal.deep_clone(Memory.current)
	Memory.previous = current

	Memory.current.camera_angle = memory.readword(source.camera_angle)
	Memory.current.camera_transition_type = memory.readbyte(source.camera_transition_type)
	Memory.current.camera_transition_progress = memory.readbyte(source.camera_transition_progress)
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

function Memory.initialize()
	-- do the pattern checks and find best candidate
	for i = 1, #sources, 1 do
		local element = sources[i]
		if memory.readdword(element.match_sequence.address) == element.match_sequence.value then
			print("Memory source " .. element.name)
			source = element
			break
		end
	end

	if source == nil then
		error("No memory source found for rom")
	end
end
