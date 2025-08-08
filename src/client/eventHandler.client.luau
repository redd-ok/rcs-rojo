local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Engine = game:GetService("ReplicatedStorage"):WaitForChild("RCS")

local Modules = Engine:WaitForChild("Modules")

local ClientNetwork = require(Engine:WaitForChild("ClientNetwork"))
local Config = require(Engine:WaitForChild("RCS_Config"))
local Types = require(Engine:WaitForChild("Types"))

local Utilities = require(Modules:WaitForChild("Utilities"))
local Hitmarker = require(Modules:WaitForChild("Hitmarker"))
local Spring = require(Modules:WaitForChild("Spring"))
local ProjectileV2 = require(Modules:WaitForChild("ProjectileV2"))

local Hud = Players.LocalPlayer.PlayerGui:WaitForChild("RCS_Hud")

local SuppressionSpring = Spring.new(Vector2.new(), 42, 0.6)

local NeckCFrames = {}

local function MuzzleFX(
	WeaponInHand: Types.WeaponInHand,
	playSemiSound: boolean,
	indoorSound: boolean
)
	local Handle = WeaponInHand.Handle
	local Tool = WeaponInHand.Parent
		and WeaponInHand.Parent:FindFirstChildOfClass("Tool")
	local Muzzle = Handle.Muzzle :: BasePart & {
		Indoor: Sound,
		Fire: Sound,
	}

	if not Tool then
		return
	end

	if playSemiSound then
		if indoorSound then
			Muzzle.Indoor:Play()
		else
			Muzzle.Fire:Play()
		end
	end

	for i, v in Muzzle:GetChildren() do
		if v:IsA("ParticleEmitter") and v.Name ~= "OverHeat" then
			v:Emit(
				v:FindFirstChild("EmitCount") and v.EmitCount.Value
					or math.random(4, 6)
			)
		elseif v:IsA("Light") then
			v.Enabled = true
			task.delay(Utilities:Random(0.01, 0.06) * 1.35, function()
				v.Enabled = false
			end)
		end
	end
end

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

		MuzzleFX(
			(data.tool.Parent :: Model):FindFirstChild(
					"S_" .. data.tool.Name
				) :: Types.WeaponInHand,
			data.playSemiSound,
			data.indoorSound
		)
	end
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

local function stanceUpdate(
	player: Player,
	characterStance: Types.CharacterStance,
	leaningState: Types.LeaningState,
	gunStance: Types.GunStance?,
	sprinting: boolean
): ()
	local character = player.Character
	if character then
		character:SetAttribute("REPL_Sprinting", sprinting)
		local lastCharStance = character:GetAttribute("REPL_LastCharStance")

		if lastCharStance ~= characterStance .. "&" .. leaningState then
			character:SetAttribute(characterStance .. "&" .. leaningState)

			local RootPart = character:FindFirstChild("HumanoidRootPart")
			local Torso = character:FindFirstChild("Torso")

			local RootJoint = RootPart:FindFirstChild("RootJoint")
			local _RS = Torso:FindFirstChild("Right Shoulder")
			local _LS = Torso:FindFirstChild("Left Shoulder")
			local RH = Torso:FindFirstChild("Right Hip")
			local LH = Torso:FindFirstChild("Left Hip")

			if characterStance == "Prone" then
				TweenService
					:Create(
						RootJoint,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{
							C1 = CFrame.new(0, 1.5, 2.45) * CFrame.Angles(
								math.rad(0),
								math.rad(0),
								math.rad(180)
							),
						}
					)
					:Play()
				TweenService
					:Create(RH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(
							math.rad(-5),
							math.rad(90),
							math.rad(0)
						),
					})
					:Play()
				TweenService
					:Create(LH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(
							math.rad(-5),
							math.rad(-90),
							math.rad(0)
						),
					})
					:Play()
			end

			if leaningState == "Right" then
				if characterStance == "Standing" then
					TweenService:Create(
						RootJoint,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{
							C1 = CFrame.new(-1, -0, 0) * CFrame.Angles(
								math.rad(-90),
								math.rad(-15),
								math.rad(-180)
							),
						}
					):Play()
					TweenService
						:Create(RH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(
								math.rad(0),
								math.rad(90),
								math.rad(0)
							),
						})
						:Play()
					TweenService
						:Create(LH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(
								math.rad(0),
								math.rad(-90),
								math.rad(0)
							),
						})
						:Play()
				elseif characterStance == "Crouched" then
					TweenService
						:Create(
							RootJoint,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine),
							{
								C1 = CFrame.new(-1, 0.75, 0.25)
									* CFrame.Angles(
										math.rad(-80),
										math.rad(-15),
										math.rad(-180)
									),
							}
						)
						:Play()
					TweenService
						:Create(RH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(0.5, 0, 0.4) * CFrame.Angles(
								math.rad(20),
								math.rad(90),
								math.rad(0)
							),
						})
						:Play()
					TweenService
						:Create(LH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(-0.5, 0, 0.4) * CFrame.Angles(
								math.rad(20),
								math.rad(-90),
								math.rad(0)
							),
						})
						:Play()
				end
			elseif leaningState == "Left" then
				if characterStance == "Standing" then
					TweenService:Create(
						RootJoint,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{
							C1 = CFrame.new(1, 0, 0) * CFrame.Angles(
								math.rad(-90),
								math.rad(15),
								math.rad(180)
							),
						}
					):Play()
					TweenService
						:Create(RH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(
								math.rad(0),
								math.rad(90),
								math.rad(0)
							),
						})
						:Play()
					TweenService
						:Create(LH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(
								math.rad(0),
								math.rad(-90),
								math.rad(0)
							),
						})
						:Play()
				elseif characterStance == "Crouched" then
					TweenService
						:Create(
							RootJoint,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine),
							{
								C1 = CFrame.new(1, 0.75, 0.25) * CFrame.Angles(
									math.rad(-80),
									math.rad(15),
									math.rad(180)
								),
							}
						)
						:Play()
					TweenService
						:Create(RH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(0.5, 0, 0.4) * CFrame.Angles(
								math.rad(20),
								math.rad(90),
								math.rad(0)
							),
						})
						:Play()
					TweenService
						:Create(LH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(-0.5, 0, 0.4) * CFrame.Angles(
								math.rad(20),
								math.rad(-90),
								math.rad(0)
							),
						})
						:Play()
				end
			elseif leaningState == "NotLeaning" then
				if characterStance == "Standing" then
					TweenService:Create(
						RootJoint,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{
							C1 = CFrame.new(0, 0, 0) * CFrame.Angles(
								math.rad(-90),
								math.rad(0),
								math.rad(180)
							),
						}
					):Play()
					TweenService
						:Create(RH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(
								math.rad(0),
								math.rad(90),
								math.rad(0)
							),
						})
						:Play()
					TweenService
						:Create(LH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(
								math.rad(0),
								math.rad(-90),
								math.rad(0)
							),
						})
						:Play()
				elseif characterStance == "Crouched" then
					TweenService:Create(
						RootJoint,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{
							C1 = CFrame.new(0, 1, 0.25) * CFrame.Angles(
								math.rad(-80),
								math.rad(0),
								math.rad(180)
							),
						}
					):Play()
					TweenService
						:Create(RH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(0.5, 0, 0.4) * CFrame.Angles(
								math.rad(20),
								math.rad(90),
								math.rad(0)
							),
						})
						:Play()
					TweenService
						:Create(LH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							C1 = CFrame.new(-0.5, 0, 0.4) * CFrame.Angles(
								math.rad(20),
								math.rad(-90),
								math.rad(0)
							),
						})
						:Play()
				end
			end
		end
	end
end

_G.StanceUpdate = function(...)
	stanceUpdate(game:GetService("Players").LocalPlayer, ...)
end
ClientNetwork.CharacterEvents.Stance_STC.on(function(owner, data)
	stanceUpdate(
		owner,
		data.characterStance,
		data.leaningState,
		data.gunStance,
		data.sprinting
	)
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

	if start then
		if
			Muzzle:FindFirstChild("IndoorLoop")
			and Utilities:IsIndoors(Muzzle.WorldPosition, { owner.Character })
		then
			Muzzle.IndoorLoop.Playing = true
		else
			Muzzle.Loop.Playing = true
		end
	else
		Muzzle.Loop.Playing = false

		if Muzzle:FindFirstChild("IndoorLoop") then
			Muzzle.IndoorLoop.Playing = false
		end

		if
			Muzzle:FindFirstChild("IndoorLoopTail")
			and Utilities:IsIndoors(Muzzle.WorldPosition, {
				owner.Character,
			})
		then
			Muzzle.IndoorLoopTail:Play()
			return
		end

		Muzzle.LoopTail:Play()
	end
end)

local Suppression = {
	current = 0,
	last = 0,
	disorientation = 0,
}

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

			if Config.Suppression.CameraShake then
				local suppressionSpringPos = SuppressionSpring.position / 88

				workspace.CurrentCamera.CFrame *= CFrame.Angles(
					0,
					suppressionSpringPos.Y,
					0
				) * CFrame.Angles(suppressionSpringPos.X, 0, 0)
			end
			-- if data[4] then
			--     data[4].C0 = data[5]:Lerp(
			--         data[6],
			--         1
			--             - math.clamp(
			--                 b
			--                     / Config.Replication_HeadRotationRate,
			--                 0,
			--                 1
			--             )
			--     )
			-- end
		else
			NeckCFrames[neck] = nil
		end
	end

	if Config.Suppression.Enabled then
		local transp = 1
			- (
				(Suppression.current / Config.Suppression.MaxSuppression)
				* Config.Suppression.VignetteIntensity
			)

		Lighting.SuppressionBlur.Size = (
			Suppression.current / Config.Suppression.MaxSuppression
		) * Config.Suppression.BlurIntensity

		local instances = Hud.SuppressionVignettes:GetChildren()
		for i, v: ImageLabel in instances do
			v.ImageTransparency = transp
		end

		if
			Suppression.current > 0
			and tick() - Suppression.last
				> Config.Suppression.DissipationDelay
		then
			Suppression.current = math.max(
				Suppression.current
					- (Config.Suppression.DissipationRate * deltaTime),
				0
			)
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
end)

_G.Suppress = function(amount: number, position: Vector3)
	if not Config.Suppression.Enabled then
		return
	end

	if Config.Suppression.CameraShake then
		local cframe =
			CFrame.new(workspace.CurrentCamera.CFrame.Position, position)
		local rX, rY, _rZ = cframe:ToOrientation()
		local a = -Vector2.new(rX, rY).Unit * amount

		workspace.CurrentCamera.CFrame *= CFrame.Angles(
			0,
			(-a.Y / 100) * Config.Suppression.CameraShakeKick,
			0
		) * CFrame.Angles(
			(-a.X / 100) * Config.Suppression.CameraShakeKick,
			0,
			0
		)

		SuppressionSpring.a = (-a / 7) * Config.Suppression.CameraShakeKick
		task.delay(0.1, function()
			SuppressionSpring.a = (a / 7) * Config.Suppression.CameraShakeKick
		end)
	end

	Suppression.current = math.min(
		Suppression.current + amount,
		Config.Suppression.MaxSuppression
	)
	Suppression.last = tick()
end
