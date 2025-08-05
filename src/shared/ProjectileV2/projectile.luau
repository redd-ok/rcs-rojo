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
	currentPosition: Vector3,
	currentVelocity: Vector3,
	caliberData: Types.Caliber,
	lastUpdated: number,
	bulletId: number,
	internalId: number,
	owner: Player?,
	tracerColor: Color3?,
	attributes: { [string]: any },
}
type ProjectileProto = {
	getVelocity: (self: Projectile) -> Vector3,
	getPosition: (self: Projectile) -> Vector3,
	setVelocity: (self: Projectile, newVelocity: Vector3) -> (),
	setPosition: (self: Projectile, newPosition: Vector3) -> (),
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
	owner
): Projectile
	return setmetatable({
		currentPosition = initialCFrame.Position,
		currentVelocity = initialCFrame.LookVector
			* caliberData.InitialVelocity,
		caliberData = caliberData,
		lastUpdated = tick(),
		bulletId = bulletId,
		internalId = internalId,
		owner = owner,
		attributes = {},
	}, projectile)
end

function projectile:getVelocity(): Vector3
	local initVelocity = self.currentVelocity.Magnitude
		* self.currentVelocity.Unit

	local timeElapsed = (tick() - self.lastUpdated)
	local timeScale = workspace:GetAttribute("PROJECTILE_SIMULATION_TIME_SCALE")
		or 1
	return initVelocity
		+ Vector3.new(0, -GetGravity() * (timeElapsed * timeScale), 0)
end

function projectile:getPosition(): Vector3
	local timeElapsed = tick() - self.lastUpdated
	if workspace:GetAttribute("PROJECTILE_SIMULATION_TIME_SCALE") then
		timeElapsed *= workspace:GetAttribute(
			"PROJECTILE_SIMULATION_TIME_SCALE"
		)
	end
	local force = Vector3.new(0, (-GetGravity() * timeElapsed ^ 2) / 2, 0)
	local initVelocity = self.currentVelocity.Magnitude
		* self.currentVelocity.Unit
	return self.currentPosition + (initVelocity * timeElapsed) + force
end

function projectile:setVelocity(newVelocity: Vector3)
	self.currentPosition = self:getPosition()
	self.currentVelocity = newVelocity
	self.lastUpdated = tick()
end

function projectile:setPosition(newPosition: Vector3)
	self.currentVelocity = self:getVelocity()
	self.currentPosition = newPosition
	self.lastUpdated = tick()
end

return projectile
