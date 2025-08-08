local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local Engine = game:GetService("ReplicatedStorage").RCS

local Config = require(Engine.RCS_Config)
local Types = require(Engine.Types)

local ServerNetwork = require(script.ServerNetwork)

local Modules = Engine.Modules
local GunModels = Engine.GunModels
local Animations = Engine.Animations

local Utilities = require(Modules.Utilities)
local RagdollModule = require(Modules.Ragdoll)
local ProjectileV2 = require(Modules.ProjectileV2)

local MedicalSystem = require(script.medicalSystem)

local EquipTries: {
	[Player]: {
		Equip: false,
	} | {
		Equip: true,
		Tool: Tool,
	},
} =
	{}
local ActiveClientProjectiles: {
	[number]: {
		Owner: Player,
		CaliberData: Types.Caliber,
		DespawnThread: thread,
	}?,
} =
	{}

ServerNetwork.WeaponEvents.Equip.on(function(player, tool)
	if
		not tool
		or tool.Parent ~= player.Character
			and tool.Parent ~= player.Backpack
	then
		player:Kick("Foolish person...")
		return
	end

	if tool.Parent == player.Backpack then
		return
	end

	EquipTries[player] = {
		Equip = true,
		Tool = tool,
	}
end)

ServerNetwork.WeaponEvents.Unequip.on(function(player)
	EquipTries[player] = {
		Equip = false,
	}
end)

ServerNetwork.WeaponEvents.Shoot_CTS.on(function(player, data)
	if Config.ServersideProjectiles then
		ProjectileV2:Spawn(
			data.position,
			data.tool:GetAttribute("Caliber"),
			player
		)
	else
		ActiveClientProjectiles[data.id] = {
			Owner = player,
			CaliberData = Utilities:FindProjectileConfig(
				data.tool:GetAttribute("Caliber")
			),
			DespawnThread = task.delay(
				Config.ProjectileMaximumLifetime + 5,
				function()
					if ActiveClientProjectiles[data.id] then
						ActiveClientProjectiles[data.id] = nil
					end
				end
			),
		}
	end

	ServerNetwork.WeaponEvents.Shoot_STC.fireExcept(player, player, {
		id = data.id,
		position = data.position,
		tool = data.tool,
		playSemiSound = data.playSemiSound,
		indoorSound = data.indoorSound,
	})
end)

local function ProjectileHit(
	owner: Player,
	hitPart: BasePart,
	hitCFrame: CFrame,
	caliberData: Types.Caliber,
	projectileSpeed: number
)
	local initialKineticEnergy = 0.5
		* caliberData.Mass
		* caliberData.InitialVelocity ^ 2
	local kineticEnergy = 0.5 * caliberData.Mass * projectileSpeed ^ 2
	local damageModifier = if Config.DamageFallOff
		then math.min(kineticEnergy, initialKineticEnergy) / initialKineticEnergy
		else 0

	local humanoid = hitPart.Parent
			and hitPart.Parent:FindFirstChildWhichIsA("Humanoid")
		or hitPart.Parent
			and hitPart.Parent.Parent
			and hitPart.Parent.Parent:FindFirstChildWhichIsA("Humanoid")

	if humanoid and humanoid.Health > 0 then
		local hitPlayer = Players:GetPlayerFromCharacter(humanoid.Parent)

		if Config.AntiTeamKill then
			if hitPlayer and hitPlayer.Team == owner.Team then
				return
			end
		end

		if Config.MedicalSystem.Enabled then
			MedicalSystem:characterHit(hitPart, humanoid.Parent, caliberData)
		else
			if hitPart.Name == "Torso" then
				humanoid:TakeDamage(
					Utilities:Random(
						caliberData.Damage.Torso.Min,
						caliberData.Damage.Torso.Max
					) * damageModifier
				)
			elseif hitPart.Name == "Head" then
				humanoid:TakeDamage(
					Utilities:Random(
						caliberData.Damage.Head.Min,
						caliberData.Damage.Head.Max
					) * damageModifier
				)
			else
				humanoid:TakeDamage(
					Utilities:Random(
						caliberData.Damage.Limb.Min,
						caliberData.Damage.Limb.Max
					) * damageModifier
				)
			end
		end

		if humanoid:FindFirstChild("creator") then
			humanoid.creator:Destroy()
		end
		local creator = Instance.new("ObjectValue")
		creator.Value = owner
		creator.Parent = humanoid
		task.delay(5, function()
			creator:Destroy()
		end)

		if humanoid and (humanoid.Health <= 0 or math.random() < 0.65) then
			Utilities:BloodSplatter(hitCFrame, caliberData, humanoid.Parent)
		end

		if not hitPlayer and humanoid.Health <= 0 and Config.EnableRagdoll then
			RagdollModule:Ragdoll(humanoid.Parent)
		end
	elseif humanoid and math.random() < 0.25 then
		Utilities:BloodSplatter(hitCFrame, caliberData, humanoid.Parent)
	end
end

function ProjectileV2:ProjectileHit(
	raycastResult,
	projectile,
	projectileVelocity
)
	if
		not raycastResult.Instance
		or not raycastResult.Instance.Parent
		or not Config.ServersideProjectiles
	then
		return
	end

	ProjectileHit(
		projectile.owner,
		raycastResult.Instance,
		CFrame.new(
			raycastResult.Position,
			raycastResult.Position - raycastResult.Normal
		),
		projectile.caliberData,
		projectileVelocity.Magnitude
	)
end

function ProjectileV2:ProjectileRicochet(
	raycastResult,
	projectile,
	projectileVelocity
)
	if
		not raycastResult.Instance
		or not raycastResult.Instance.Parent
		or not Config.ServersideProjectiles
	then
		return
	end

	ProjectileHit(
		projectile.owner,
		raycastResult.Instance,
		CFrame.new(
			raycastResult.Position,
			raycastResult.Position - raycastResult.Normal
		),
		projectile.caliberData,
		projectileVelocity.Magnitude
	)
end

function ProjectileV2:ProjectilePenetration(
	raycastResult,
	exitRaycastResult,
	projectile,
	projectileVelocity
)
	if
		not raycastResult.Instance
		or not raycastResult.Instance.Parent
		or not Config.ServersideProjectiles
	then
		return
	end

	ProjectileHit(
		projectile.owner,
		raycastResult.Instance,
		CFrame.new(
			raycastResult.Position,
			raycastResult.Position - raycastResult.Normal
		),
		projectile.caliberData,
		projectileVelocity.Magnitude
	)
end

ServerNetwork.WeaponEvents.ProjectileHit.on(function(player, data)
	if Config.ServersideProjectiles or not data.hitPart:IsA("BasePart") then
		player:Kick("nice try pal")
		return
	end

	local activeClientProjectile = ActiveClientProjectiles[data.id]
	if not activeClientProjectile then
		return
	end

	if not data.penetration then
		ActiveClientProjectiles[data.id] = nil
		task.cancel(activeClientProjectile.DespawnThread)
	end
	ProjectileHit(
		activeClientProjectile.Owner,
		data.hitPart,
		data.hitCFrame,
		activeClientProjectile.CaliberData,
		data.projectileSpeed
	)
end)

ServerNetwork.CharacterEvents.HeadReplication_CTS.on(
	function(player, neckCFrame)
		ServerNetwork.CharacterEvents.HeadReplication_STC.fireExcept(
			player,
			player,
			neckCFrame
		)
	end
)

ServerNetwork.CharacterEvents.Stance_CTS.on(function(player, data)
	ServerNetwork.CharacterEvents.Stance_STC.fireExcept(player, player, data)
end)

ServerNetwork.CharacterEvents.Footstep_CTS.on(function(player, matId)
	if not player.Character or not player.Character.PrimaryPart then
		return
	end
	local PrimaryPart = player.Character.PrimaryPart

	local list = {}
	for i, v in Players:GetPlayers() do
		if v ~= player and v.Character and v.Character.PrimaryPart then
			local TargetPrimaryPart = v.Character.PrimaryPart

			if
				(TargetPrimaryPart.Position - PrimaryPart.Position).Magnitude
				< 65
			then
				list[#list + 1] = v
			end
		end
	end
	ServerNetwork.CharacterEvents.Footstep_STC.fireList(list, player, matId)
end)

ServerNetwork.WeaponEvents.ToggleAttachment.on(function(player, data)
	if not player.Character then
		return
	end

	local tool = player.Character:FindFirstChildWhichIsA("Tool")
	if not tool then
		return
	end

	local model = player.Character:FindFirstChild("S_" .. tool.Name)
	if not model then
		return
	end

	for _, part in model:GetChildren() do
		if
			part:HasTag("LaserPart") and data.laser
			or part:HasTag("FlashPart") and not data.laser
		then
			part:SetAttribute("Active", data.active)
		end
	end
end)

ServerNetwork.WeaponEvents.LoopingSounds_CTS.on(function(player, start)
	ServerNetwork.WeaponEvents.LoopingSounds_STC.fireExcept(
		player,
		player,
		start
	)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		if Config.EnableRagdoll then
			for _, v in char:GetDescendants() do
				if v:IsA("BasePart") then
					v.CollisionGroup = "Characters"
				end
			end

			RagdollModule:SetupModel(char)

			char:WaitForChild("Humanoid").Died:Connect(function()
				RagdollModule:Ragdoll(char)
			end)
		end

		if Config.MedicalSystem.Enabled then
			MedicalSystem:registerCharacter(char)
		end
	end)
end)

local timePassed = 0
local timePassedMedical = 0
RunService.Heartbeat:Connect(function(deltaTime: number)
	timePassed += deltaTime

	RagdollModule:Step()

	if timePassed >= Config.Serverside_EquipRate then
		timePassed = 0

		for player, var in EquipTries do
			EquipTries[player] = nil

			local character = player.Character
			if not character then
				continue
			end

			local head: BasePart = character.Head
			local torso: BasePart = character.Torso

			local leftArm: BasePart = character:FindFirstChild("Left Arm")
			local rightArm: BasePart = character:FindFirstChild("Right Arm")

			local RS = torso:FindFirstChild("Right Shoulder") :: Motor6D
			local LS = torso:FindFirstChild("Left Shoulder") :: Motor6D

			if not RS or not LS then
				continue
			end

			for i, v in character:GetChildren() do
				if v.Name:sub(0, 2) == "S_" then
					v:Destroy()
				end
			end

			if character:FindFirstChild("AnimBase") then
				character:FindFirstChild("AnimBase"):Destroy()
			end

			if var.Equip then
				local animsName: string? = var.Tool:GetAttribute("Animations")
				if not animsName then
					warn("Tool has no animations attribute: " .. var.Tool.Name)
					continue
				end

				local animsModule: ModuleScript? =
					Animations:FindFirstChild(animsName)
				if not animsModule then
					warn(
						"No animations found for: "
							.. var.Tool.Name
							.. " animations: "
							.. animsName
					)
					continue
				end

				local anims: Types.AnimationConfig = require(animsModule)
				local gunModel = GunModels:FindFirstChild(var.Tool.Name)
				if not gunModel then
					warn("No gun model found for: " .. gunModel)
					continue
				end

				local serverModel = gunModel:Clone()
				serverModel.Name = "S_" .. serverModel.Name

				local animBase = Instance.new("Part", character)
				animBase.CanCollide = false
				animBase.CanQuery = false
				animBase.CanTouch = false
				animBase.Transparency = 1
				animBase.Anchored = false
				animBase.Name = "AnimBase"
				animBase.Size = Vector3.new(0.1, 0.1, 0.1)

				local animBaseW = Instance.new("Motor6D")
				animBaseW.Part0 = head
				animBaseW.Part1 = animBase
				animBaseW.Parent = animBase
				animBaseW.Name = "AnimBaseW"

				local ruaw = Instance.new("Motor6D")
				ruaw.Name = "RAW"
				ruaw.Part0 = rightArm
				ruaw.Part1 = animBase
				ruaw.Parent = animBase
				ruaw.C0 = anims.SV_RightArmPos
				RS.Enabled = false

				local luaw = Instance.new("Motor6D")
				luaw.Name = "LAW"
				luaw.Part0 = leftArm
				luaw.Part1 = animBase
				luaw.Parent = animBase
				luaw.C0 = anims.SV_LeftArmPos
				LS.Enabled = false

				for i, v in serverModel:GetChildren() do
					if v.Name == "SightMark" then
						v:Destroy()
						continue
					end

					if v.Name ~= "Handle" and v:IsA("BasePart") then
						Utilities:WeldComplex(serverModel.Handle, v, v.Name)
					end

					if v:IsA("BasePart") then
						v.CanCollide = false
						v.Anchored = false
					end
				end

				local gunWeld = Instance.new("Motor6D")
				gunWeld.Name = "Handle"
				gunWeld.Parent = animBase
				gunWeld.Part0 = rightArm
				gunWeld.Part1 = serverModel.Handle
				gunWeld.C1 = anims.SV_GunPos:Inverse()

				serverModel.Parent = character
			else
				RS.Enabled = true
				LS.Enabled = true
			end
		end
	end

	if Config.MedicalSystem.Enabled then
		timePassedMedical += deltaTime

		if timePassedMedical > Config.MedicalSystem.UpdateRate then
			timePassedMedical = 0

			MedicalSystem:update()
		end
	end
end)

PhysicsService:RegisterCollisionGroup("RagdollPart")
PhysicsService:CollisionGroupSetCollidable("RagdollPart", "RagdollPart", false)
PhysicsService:CollisionGroupSetCollidable("RagdollPart", "Default", true)

PhysicsService:RegisterCollisionGroup("Casings")
PhysicsService:RegisterCollisionGroup("Characters")
PhysicsService:CollisionGroupSetCollidable("Casings", "Characters", false)
PhysicsService:CollisionGroupSetCollidable("Casings", "Casings", false)
