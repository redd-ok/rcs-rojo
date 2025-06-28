export type Spring<T> = {
	damp: number,
	damper: number,
	speed: number,
	d: number,
	s: number,

	accelerate: (self: Spring<T>, acceleration: T) -> nil,
	acceleration: T,
	a: T,

	target: T,
	t: T,

	velocity: T,
	v: T,

	value: T,
	position: T,
	p: T,

	magnitude: number,
	m: number,
}

local Spring = {}

function Spring.new<T>(Initial: T, d: number?, s: number?): Spring<T>
	local t0 = tick()
	local p0 = Initial or 0
	local v0 = Initial and 0 * ((Initial :: any) :: number) or 0
	local t = Initial or 0

	local damp = d or 1
	local speed = s or 1

	local function positionVelocity(Tick: number)
		local x = Tick - t0
		local c0 = p0 - t

		if speed == 0 then
			return p0, 0
		elseif damp < 1 then
			local c = math.sqrt(1 - damp ^ 2)
			local c1 = (v0 / speed + damp * c0) / c
			local co = math.cos(c * speed * x)
			local si = math.sin(c * speed * x)
			local e = math.exp(damp * speed * x)

			return t + (c0 * co + c1 * si) / e,
				speed
					* ((c * c1 - damp * c0) * co - (c * c0 + damp * c1) * si)
					/ e
		else
			local c1 = v0 / speed + c0
			local e = math.exp(speed * x)

			return t + (c0 + c1 * speed * x) / e,
				speed * (c1 - c0 - c1 * speed * x) / e
		end
	end

	local mt = setmetatable({
		accelerate = function(_, acceleration)
			local T = tick()
			local p, v = positionVelocity(T)
			p0 = p
			v0 = v + acceleration
			t0 = T
		end,
	}, {
		__index = function(_, index)
			if index == "value" or index == "position" or index == "p" then
				local p, _ = positionVelocity(tick())
				return p
			elseif index == "velocity" or index == "v" then
				local _, v = positionVelocity(tick())
				return v
			elseif index == "acceleration" or index == "a" then
				local x = tick() - t0
				local c0 = p0 - t
				if speed == 0 then
					return 0
				elseif damp < 1 then
					local c = math.sqrt(1 - damp ^ 2)
					local c1 = (v0 / speed + damp * c0) / c
					local cs = (c0 * damp ^ 2 - 2 * c * damp * c1 - c0 * c ^ 2)
						* math.cos(c * speed * x)
					local sn = (c1 * damp ^ 2 + 2 * c * damp * c0 - c1 * c ^ 2)
						* math.sin(c * speed * x)
					return speed ^ 2 * (cs + sn) / math.exp(damp * speed * x)
				else
					local c1 = v0 / speed + c0
					return speed ^ 2
						* (c0 - 2 * c1 + c1 * speed * x)
						/ math.exp(speed * x)
				end
			elseif index == "target" or index == "t" then
				return t
			elseif index == "damper" or index == "damp" or index == "d" then
				return damp
			elseif index == "speed" or index == "s" then
				return speed
			elseif index == "magnitude" or index == "m" then
				local p, _ = positionVelocity(tick())
				return p.magnitude
			else
				error(index .. " is not a valid member of spring", 0)
			end
		end,

		__newindex = function(_, index, value)
			local T = tick()

			if index == "value" or index == "position" or index == "p" then
				local _, v = positionVelocity(T)
				p0, v0 = value, v
			elseif index == "velocity" or index == "v" then
				local p = positionVelocity(T)
				p0, v0 = p, value
			elseif index == "acceleration" or index == "a" then
				local p, v = positionVelocity(T)
				p0, v0 = p, v + value
			elseif index == "target" or index == "t" then
				p0, v0 = positionVelocity(T)
				t = value
			elseif index == "damper" or index == "damp" or index == "d" then
				p0, v0 = positionVelocity(T)
				damp = value < 0 and 0 or value < 1 and value or 1
			elseif index == "speed" or index == "s" then
				p0, v0 = positionVelocity(T)
				speed = value < 0 and 0 or value
			else
				error(index .. " is not a valid member of spring", 0)
			end

			t0 = T
		end,
	})

	return mt :: Spring<T>
end

return Spring
