--!native
--!optimize 2
local Engine = game:GetService("ReplicatedStorage").RCS

local Types = require(Engine.Types)

local function GetGravity()
	if workspace:GetAttribute("DISABLE_PROJECTILE_GRAVITY") then
		return 0
	end

	return workspace.Gravity
end

type ProjectileProps = {
	initialCFrame: CFrame,
	currentPosition: Vector3,
	caliberData: Types.Caliber,
	timeCreated: number,
	bulletId: number,
	internalId: number,
	owner: Player?,
	tracerColor: Color3?,
	attributes: { [string]: any },
}
type ProjectileProto = {
	getVelocity: (self: Projectile) -> Vector3,
	getPosition: (self: Projectile) -> Vector3,
	new: (
		initialCFrame: CFrame,
		caliberData: Types.Caliber,
		bulletId: number?,
		internalId: number,
		owner: Player?,
		tracerColor: Color3?
	) -> Projectile,
}
export type Projectile = typeof(setmetatable({} :: ProjectileProps, {
	__index = {} :: ProjectileProto,
}))

local projectile = {} :: ProjectileProto
projectile.__index = projectile

function projectile.new(
	initialCFrame,
	caliberData,
	bulletId,
	internalId,
	owner,
	tracerColor
): Projectile
	return setmetatable({
		initialCFrame = initialCFrame,
		currentPosition = initialCFrame.Position,
		caliberData = caliberData,
		timeCreated = tick(),
		bulletId = bulletId,
		internalId = internalId,
		owner = owner,
		tracerColor = tracerColor,
		attributes = {},
	}, projectile)
end

function projectile:getVelocity(): Vector3
	local initVelocity = (self.caliberData.InitialVelocity / 0.28)
		* self.initialCFrame.LookVector
	return initVelocity
		+ Vector3.new(
			0,
			-GetGravity()
				* (
					(tick() - self.timeCreated)
					* (
						workspace:GetAttribute(
							"PROJECTILE_SIMULATION_TIME_SCALE"
						) or 1
					)
				),
			0
		)
end

function projectile:getPosition(): Vector3
	local timeElapsed = tick() - self.timeCreated
	if workspace:GetAttribute("PROJECTILE_SIMULATION_TIME_SCALE") then
		timeElapsed *= workspace:GetAttribute(
			"PROJECTILE_SIMULATION_TIME_SCALE"
		)
	end
	local force = Vector3.new(0, (-GetGravity() * timeElapsed ^ 2) / 2, 0)
	local initVelocity = (self.caliberData.InitialVelocity / 0.28)
		* self.initialCFrame.LookVector
	return self.initialCFrame.Position + (initVelocity * timeElapsed) + force
end

return projectile
