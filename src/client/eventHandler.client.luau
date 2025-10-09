local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Engine = game:GetService("ReplicatedStorage"):WaitForChild("RCS")

local Modules = Engine:WaitForChild("Modules")

local ClientNetwork = require(Engine:WaitForChild("ClientNetwork"))
local Config = require(Engine:WaitForChild("RCS_Config"))
local Types = require(Engine:WaitForChild("Types"))

local Utilities = require(Modules:WaitForChild("Utilities"))
local Hitmarker = require(Modules:WaitForChild("Hitmarker"))
local ProjectileV2 = require(Modules:WaitForChild("ProjectileV2"))
local Supression = require(Modules:WaitForChild("Supression"))
local Stance = require(Modules:WaitForChild("Stance"))

local NeckCFrames = {}

function ProjectileV2:ProjectileHit(raycastResult, projectile, velocity)
	if
		not Config.ServersideProjectiles
		and projectile.bulletId
		and projectile.owner == Players.LocalPlayer
	then
		ClientNetwork.WeaponEvents.ProjectileHit.fire({
			hitPart = raycastResult.Instance,
			hitCFrame = CFrame.new(
				raycastResult.Position,
				raycastResult.Position + raycastResult.Normal
			),
			projectileSpeed = velocity.Magnitude,
			id = projectile.bulletId,
			penetration = false,
		})
	end

	Hitmarker.HitEffect(
		{},
		raycastResult.Instance,
		Utilities:ConvertHitToCF(
			raycastResult.Instance :: BasePart,
			raycastResult.Position,
			raycastResult.Normal
		),
		raycastResult.Material,
		projectile,
		"Hit"
	)
end

function ProjectileV2:ProjectileRicochet(raycastResult, projectile, velocity)
	if
		not Config.ServersideProjectiles
		and projectile.bulletId
		and projectile.owner == Players.LocalPlayer
	then
		ClientNetwork.WeaponEvents.ProjectileHit.fire({
			hitPart = raycastResult.Instance,
			hitCFrame = CFrame.new(
				raycastResult.Position,
				raycastResult.Position + raycastResult.Normal
			),
			projectileSpeed = velocity.Magnitude,
			id = projectile.bulletId,
			penetration = true,
		})
	end

	Hitmarker.HitEffect(
		{},
		raycastResult.Instance,
		Utilities:ConvertHitToCF(
			raycastResult.Instance :: BasePart,
			raycastResult.Position,
			raycastResult.Normal
		),
		raycastResult.Material,
		projectile,
		"Rico"
	)
end

function ProjectileV2:ProjectilePenetration(
	raycastResult,
	exitRaycastResult,
	projectile,
	velocity
)
	if
		not Config.ServersideProjectiles
		and projectile.bulletId
		and projectile.owner == Players.LocalPlayer
	then
		ClientNetwork.WeaponEvents.ProjectileHit.fire({
			hitPart = raycastResult.Instance,
			hitCFrame = CFrame.new(
				raycastResult.Position,
				raycastResult.Position + raycastResult.Normal
			),
			projectileSpeed = velocity.Magnitude,
			id = projectile.bulletId,
			penetration = true,
		})
	end

	Hitmarker.HitEffect(
		{},
		raycastResult.Instance,
		Utilities:ConvertHitToCF(
			raycastResult.Instance :: BasePart,
			raycastResult.Position,
			raycastResult.Normal
		),
		raycastResult.Material,
		projectile,
		"In"
	)
	Hitmarker.HitEffect(
		{},
		raycastResult.Instance,
		Utilities:ConvertHitToCF(
			raycastResult.Instance :: BasePart,
			exitRaycastResult.Position,
			exitRaycastResult.Normal
		),
		raycastResult.Material,
		projectile,
		"Out"
	)
end

ClientNetwork.WeaponEvents.Shoot_STC.on(function(owner, data)
	if owner and owner.Character and data.tool then
		ProjectileV2:Spawn(
			data.position,
			data.tool:GetAttribute("Caliber"),
			owner
		)
	end
end)

ClientNetwork.WeaponEvents.MuzzleEffect_STC.on(function(data)
	local weaponModel = (data.tool.Parent :: Model):FindFirstChild(
		"S_" .. data.tool.Name
	) :: Types.WeaponInHand
	Utilities:MuzzleEffect(
		weaponModel.Handle,
		data.playSemiSound,
		data.indoorSound
	)
end)

ClientNetwork.CharacterEvents.HeadReplication_STC.on(function(owner, neckCFrame)
	if owner.Character then
		local character = owner.Character
		local torso = character:FindFirstChild("Torso")

		if torso then
			local neck: Motor6D = torso:FindFirstChild("Neck")
			if not neck then
				return
			end

			NeckCFrames[neck] = {
				CFrame.new(0, -0.5, 0) * neckCFrame,
				neck.C1,
				tick(),
			}
		end
	end
end)

ClientNetwork.CharacterEvents.Stance_STC.on(function(owner, data)
	if owner.Character then
		Stance:AnimateCharacterStance(
			owner.Character,
			data.characterStance,
			data.leaningState,
			data.sprinting,
			data.gunStance
		)
	end
end)

local footsteps = Engine:WaitForChild("Footsteps")

local materialsSimplified = {
	Glacier = "Glass",
	LeafyGrass = "Grass",
	Mud = "Ground",
	Pavement = "Concrete",
	Salt = "Gravel",
	Sand = "Soil",
	Sandstone = "Concrete",
	Snow = "Grass",
	WoodPlanks = "Wood",
}

local function playFootstep(pace, volume, material, parent)
	pace = footsteps:FindFirstChild(pace or "Walk") or footsteps.Walk
	material = pace:FindFirstChild(material[materialsSimplified] or material)
		or pace.Asphalt

	local sounds: { Sound } = material:GetChildren()
	local sound = sounds[math.random(1, #sounds)]
	local duplicate = sound:Clone()
	duplicate.Parent = parent
	duplicate.Volume = volume * 2.5 * Utilities:Random(0.8, 1.2)
	duplicate.PlaybackSpeed = Utilities:Random(0.8, 1.2)
	duplicate.RollOffMinDistance = 15
	duplicate.RollOffMaxDistance = volume * 12
	duplicate.RollOffMode = Enum.RollOffMode.InverseTapered
	duplicate:Play()
	task.delay(duplicate.TimeLength / duplicate.PlaybackSpeed, function()
		duplicate:Destroy()
	end)
end

ClientNetwork.CharacterEvents.Footstep_STC.on(function(owner, matId: number)
	local mat = Enum.Material:GetEnumItems()[matId]

	if owner.Character and owner.Character:FindFirstChild("Torso") then
		local running = owner.Character:GetAttribute("REPL_Sprinting")

		playFootstep(
			if running then "Running" else "Walk",
			if running then 3.75 else 2.5,
			mat.Name,
			owner.Character:FindFirstChild("Torso")
		)
	end
end)

ClientNetwork.WeaponEvents.LoopingSounds_STC.on(function(owner, start)
	if not owner.Character then
		return
	end

	local tool = owner.Character:FindFirstChildWhichIsA("Tool")
	if not tool then
		return
	end

	local WeaponInHand =
		owner.Character:FindFirstChild("S_" .. tool.Name) :: Types.WeaponInHand
	if not WeaponInHand then
		return
	end

	local Handle = WeaponInHand.Handle
	local Muzzle = Handle.Muzzle

	Utilities:LoopingSounds(Muzzle, start)
end)

local medInfo
ClientNetwork.MedicalUpdate.on(function(_medInfo)
	medInfo = _medInfo
	_G.medInfo = medInfo
end)

game:GetService("RunService").PostSimulation:Connect(function(deltaTime)
	for neck, data in NeckCFrames do
		local started: number = data[3]

		if neck.Parent ~= nil then
			if (tick() - started) > Config.Replication_HeadRotationRate then
				NeckCFrames[neck] = nil
				continue
			end

			local a = started + Config.Replication_HeadRotationRate
			local b = a - tick()

			neck.C1 = data[2]:Lerp(
				data[1],
				1 - math.clamp(b / Config.Replication_HeadRotationRate, 0, 1)
			)
		else
			NeckCFrames[neck] = nil
		end
	end

	if
		medInfo
		and Players.LocalPlayer.Character
		and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
	then
		Lighting.MedicalColorEffect.Saturation = (
			-1 + (medInfo.Blood / Config.MedicalSystem.MaxBlood) ^ 1.5
		) * 2
		Lighting.MedicalColorEffect.TintColor = Color3.new(
			(medInfo.Blood / Config.MedicalSystem.MaxBlood) ^ 1.1,
			(medInfo.Blood / Config.MedicalSystem.MaxBlood) ^ 1.1,
			(medInfo.Blood / Config.MedicalSystem.MaxBlood) ^ 1.1
		)
		Lighting.MedicalBlurEffect.Size = 12
			* (
				1
				- (
					Players.LocalPlayer.Character:FindFirstChildWhichIsA(
						"Humanoid"
					).Health / Config.MedicalSystem.MaxHealth
				)
			)
	end

	Supression:Update(deltaTime)
end)
