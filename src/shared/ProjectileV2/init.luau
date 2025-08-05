local Engine = game:GetService("ReplicatedStorage").RCS

local Config = require(Engine.RCS_Config)

local Modules = Engine.Modules

local Utilities = require(Modules:WaitForChild("Utilities"))
local MultiThread = require(Modules:WaitForChild("MultiThread"))
local ProjectileClass = require(script:WaitForChild("projectile"))
export type Projectile = ProjectileClass.Projectile

local Projectile = {}
Projectile._counter = 0
Projectile._maxProjectiles = Config.ProjectileAllocation
	- (Config.ProjectileActorAllocation * 2)
Projectile.activeProjectiles = 0

function Projectile:ProjectileDestroying(
	projectile: ProjectileClass.Projectile
)
end
function Projectile:ProjectileHit(
	raycastResult: RaycastResult,
	projectile: ProjectileClass.Projectile,
	projectileVelocity: Vector3
)
end

Projectile.MultiThread = MultiThread.new(
	script:WaitForChild("projectileMultiThread"),
	function(msg: string, ...)
		if msg == "destroying" then
			Projectile.activeProjectiles -= 1
			local projectile = ...
			Projectile:ProjectileDestroying(
				setmetatable(projectile, { __index = ProjectileClass })
			)
		elseif msg == "hit" then
			local raycastResult, projectile, velocity = ...
			Projectile:ProjectileHit(
				raycastResult,
				setmetatable(projectile, { __index = ProjectileClass }),
				velocity
			)
		elseif msg == "suppress" then
			_G.Suppress(...)
		end
	end
)
Projectile.MultiThread:AllocateActors(Config.ProjectileActorAllocation)

function Projectile:GetId()
	Projectile._counter += 1
	if Projectile._counter > 2 ^ 16 - 1 then
		Projectile._counter = 0
	end
	return Projectile._counter
end

function Projectile:Spawn(
	startCFrame: CFrame,
	caliberName: string,
	owner: Player?,
	bulletId: number?
)
	if Projectile.activeProjectiles > Projectile._maxProjectiles then
		warn(
			`Allocating {2 * #Projectile.MultiThread.Actors} more projectiles (2 projectile per actor)`
		)
		Projectile._maxProjectiles += 2 * #Projectile.MultiThread.Actors
		Projectile.MultiThread:SendMessageAll("allocateProjectiles", 2)
	end
	Projectile.activeProjectiles += 1
	Projectile.MultiThread:SendMessage(
		"spawn",
		startCFrame,
		Utilities:FindProjectileConfig(caliberName),
		bulletId,
		owner
	)
end

return Projectile
