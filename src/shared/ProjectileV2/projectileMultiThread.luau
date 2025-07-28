--!native
--!optimize 2

local Engine = game:GetService("ReplicatedStorage").RCS

local Types = require(Engine.Types)
local Config = require(Engine.RCS_Config)

local Projectile = require(script.Parent.projectile)
type Projectile = Projectile.Projectile

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()

local VERY_FAR_CFRAME = CFrame.new(2 ^ 24, 2 ^ 24, 2 ^ 24)

local DebugContainer
if IsClient then
	DebugContainer = workspace
		:FindFirstChild("RCS_Workspace").Client
		:FindFirstChild("__DEBUG_CONTAINER")
	if not DebugContainer then
		DebugContainer = Instance.new("Folder", workspace.RCS_Workspace.Client)
		DebugContainer.Name = "__DEBUG_CONTAINER"
	end
end

local ProjectilesContainer
local TracerCache
if IsClient then
	ProjectilesContainer =
		workspace.RCS_Workspace.Client:FindFirstChild("__PROJECTILES_CONTAINER")
	TracerCache = {}
	if not ProjectilesContainer then
		ProjectilesContainer =
			Instance.new("Folder", workspace.RCS_Workspace.Client)
		ProjectilesContainer.Name = "__PROJECTILES_CONTAINER"
	end
end

local projectileMultiThread = {}
projectileMultiThread.activeProjectiles = {}
projectileMultiThread.cachedInstances = {}
projectileMultiThread.actor = (nil :: any) :: Actor

local dummyProjectile

if IsClient then
	dummyProjectile = Instance.new("Part")
	dummyProjectile.Size = Vector3.new(0.5, 0.5, 5)
	dummyProjectile.CFrame = VERY_FAR_CFRAME
	dummyProjectile.Anchored = true
	dummyProjectile.CanCollide = false
	dummyProjectile.CanQuery = false
	dummyProjectile.CanTouch = false
	dummyProjectile.Transparency = 1
	dummyProjectile.Parent = ProjectilesContainer

	for i = 1, math.round(Config.ProjectileAllocation / Config.ProjectileActorAllocation) do
		local duplicate = dummyProjectile:Clone()
		duplicate.Parent = ProjectilesContainer
		projectileMultiThread.cachedInstances[i] = duplicate

		local attach0 = Instance.new("Attachment", workspace.Terrain)
		local attach1 = Instance.new("Attachment", workspace.Terrain)
		attach0.CFrame = VERY_FAR_CFRAME
		attach1.CFrame = VERY_FAR_CFRAME
		local beam = Instance.new("Beam", workspace.Terrain)
		beam.Attachment0 = attach0
		beam.Attachment1 = attach1
		beam.Enabled = true
		beam.Segments = 25
		beam.TextureSpeed = 0
		beam.Transparency = NumberSequence.new(0.2)
		beam.TextureLength = 1
		beam.FaceCamera = true

		beam.Texture = "rbxassetid://91470726703438"
		beam.LightEmission = 0.7
		beam.LightInfluence = 0
		TracerCache[i] = { attach0, attach1, beam }
	end
end

local DEBUG = false

function projectileMultiThread:projectileDestroying(
	projectile: Projectile.Projectile
)
end
function projectileMultiThread:projectileHit(
	raycastResult: RaycastResult,
	projectile: Projectile.Projectile
)
end
function projectileMultiThread.sendMessage(...: any): () end

function projectileMultiThread:spawnProjectile(
	initialCFrame: CFrame,
	caliberData: Types.Caliber,
	owner: Player?,
	bulletId: number?,
	tracerColor: Color3?
)
	local index = 1
	while true do
		if not projectileMultiThread.activeProjectiles[index] then
			if IsClient and index > #projectileMultiThread.cachedInstances then
				warn("ran out of allocated projectiles, allocating more")
				for i = 0, 4 do
					local duplicate = dummyProjectile:Clone()
					duplicate.Parent = ProjectilesContainer
					projectileMultiThread.cachedInstances[index + i] = duplicate
				end
			end
			projectileMultiThread.activeProjectiles[index] = Projectile.new(
				initialCFrame,
				caliberData,
				bulletId,
				index,
				owner,
				tracerColor
			)
			if IsClient and tracerColor then
				local projectile =
					projectileMultiThread.activeProjectiles[index]

				local tracerInstances = TracerCache[index]
				tracerInstances[3].Color = ColorSequence.new(tracerColor)

				projectile.attributes.BulletParticleData = {
					T0 = nil,
					P0 = nil,
					V0 = nil,
					T1 = tick(),
					P1 = workspace.CurrentCamera.CFrame:PointToObjectSpace(
						initialCFrame.Position
					),
					V1 = nil,
					Attachment0 = tracerInstances[1],
					Attachment1 = tracerInstances[2],
					Effects = { tracerInstances[3] },
					SetTo = {},
					MotionBlur = true,
					BulletSize = 0.7,
					BulletBloom = 0.006,
					BulletBrightness = 400,
				}
			end
			break
		end

		index += 1
	end
end

function projectileMultiThread:init(actor: Actor, sendMessage: (...any) -> ())
	self.actor = actor
	projectileMultiThread.sendMessage = sendMessage

	local event = if IsClient
		then RunService.RenderStepped
		else RunService.Stepped
	event:ConnectParallel(function(dt)
		projectileMultiThread:parallelStepped(dt)
	end)

	function projectileMultiThread:projectileDestroying(projectile)
		sendMessage("destroying", projectile)
	end
	function projectileMultiThread:projectileHit(raycastResult, projectile)
		sendMessage("hit", raycastResult, projectile)
	end

	actor:BindToMessage(
		"spawn",
		function(
			initialCFrame: CFrame,
			caliberData: Types.Caliber,
			bulletId: number,
			owner: Player?,
			tracerColor: Color3?
		)
			projectileMultiThread:spawnProjectile(
				initialCFrame,
				caliberData,
				owner,
				bulletId,
				tracerColor
			)
		end
	)
	actor:BindToMessage("setdebug", function(b: boolean)
		DEBUG = b
	end)
	actor:BindToMessage("allocateProjectiles", function(am: number?)
		if IsClient then
			am = am or 5
			for i = 1, am :: number do
				local duplicate = dummyProjectile:Clone()
				duplicate.Parent = ProjectilesContainer
				projectileMultiThread.cachedInstances[#projectileMultiThread.cachedInstances + 1] =
					duplicate
			end
		end
	end)
end

function projectileMultiThread:parallelStepProjectile(
	projectile: Projectile,
	index: number
): {
	expired: true,
} | {
	expired: boolean?,
	hit: RaycastResult,
	hitPosition: Vector3,
	bulletPosition: Vector3,
} | {
	expired: false?,
	hit: false,
	oldPosition: Vector3,
	newPosition: Vector3,
}
	if not workspace:GetAttribute("DISABLE_PROJECTILE_LIFETIME_DECAY") then
		if
			tick() - projectile.timeCreated > Config.ProjectileMaximumLifetime
		then
			return {
				expired = true,
			}
		end
	end

	local oldPosition = projectile.currentPosition
	local newPosition = projectile:getPosition()
	projectile.currentPosition = newPosition
	local currentVelocity = projectile:getVelocity()

	if not workspace:GetAttribute("DISABLE_PROJECTILE_DISTANCE_DECAY") then
		if
			(newPosition - projectile.initialCFrame.Position).Magnitude
			> Config.ProjectileMaximumDistance
		then
			return {
				expired = true,
			}
		end
	end

	if IsClient then
		local part = projectileMultiThread.cachedInstances[index]
		local cameraPos = workspace.CurrentCamera.CFrame.Position
		local distFromCamera = (
			workspace.CurrentCamera.CFrame.Position - oldPosition
		).Magnitude

		local shouldDesynchronize = false
		if currentVelocity.Magnitude > 343 / 0.28 then
			if distFromCamera < 130 then
				local d = (cameraPos - oldPosition):Dot(currentVelocity)
					/ currentVelocity:Dot(currentVelocity)

				if d > 0 and d < 1 then
					if
						distFromCamera < 15
						and (projectile.attributes.lastWhizz == nil)
					then
						shouldDesynchronize = true
						task.synchronize()
						projectile.attributes.lastWhizz = tick()

						local sound = Instance.new("Sound", part)
						sound.SoundId = Config.Sounds.Whizzes[math.random(
							1,
							#Config.Sounds.Whizzes
						)]
						sound.Volume = math.random(80, 100) / 10
						sound.RollOffMinDistance = 1000
						sound.RollOffMaxDistance = 10000
						sound.PlaybackSpeed = math.random(9, 11) / 10
						sound:Play()
						sound.Ended:Connect(function()
							sound:Destroy()
						end)

						projectileMultiThread.sendMessage(
							"suppress",
							projectile.caliberData.SuppressionAmount,
							oldPosition
						)
					end
					if
						distFromCamera < 55
						and projectile.attributes.lastCloseWhizz == nil
					then
						shouldDesynchronize = true
						task.synchronize()
						projectile.attributes.lastCloseWhizz = tick()
						projectile.attributes.lastMedWhizz = tick()

						local sound = Instance.new("Sound", part)
						sound.SoundId = Config.Sounds.Whizzes[math.random(
							1,
							#Config.Sounds.Cracks.Close
						)]
						sound.Volume = math.random(80, 90) / 10
						sound.RollOffMinDistance = 1000
						sound.RollOffMaxDistance = 10000
						sound.PlaybackSpeed = math.random(9, 11) / 10
						sound:Play()
						sound.Ended:Connect(function()
							sound:Destroy()
						end)
					elseif
						distFromCamera < 106
						and (projectile.attributes.lastMedWhizz == nil)
					then
						shouldDesynchronize = true
						task.synchronize()
						projectile.attributes.lastMedWhizz = tick()

						local sound = Instance.new("Sound", part)
						sound.SoundId = Config.Sounds.Whizzes[math.random(
							1,
							#Config.Sounds.Cracks.Medium
						)]
						sound.Volume = math.random(40, 50) / 10
						sound.RollOffMinDistance = 1000
						sound.RollOffMaxDistance = 10000
						sound.PlaybackSpeed = math.random(9, 11) / 10
						sound:Play()
						sound.Ended:Connect(function()
							sound:Destroy()
						end)
					end
				else
					projectile.attributes.lastWhizz = nil
					projectile.attributes.lastCloseWhizz = nil
					projectile.attributes.lastMedWhizz = nil
				end
			end
		end

		if projectile.tracerColor then
			local BulletParticleData = projectile.attributes.BulletParticleData
			local T2 = tick()
			local P2 =
				workspace.CurrentCamera.CFrame:PointToObjectSpace(oldPosition)
			local V2
			if BulletParticleData.T0 then
				V2 = 2
						/ (T2 - BulletParticleData.T1)
						* (P2 - BulletParticleData.P1)
					- (P2 - BulletParticleData.P0)
						/ (T2 - BulletParticleData.T0)
			else
				V2 = (P2 - BulletParticleData.P1) / (T2 - BulletParticleData.T1)
				BulletParticleData.V1 = V2
			end
			BulletParticleData.T0, BulletParticleData.V0, BulletParticleData.P0 =
				BulletParticleData.T1,
				BulletParticleData.V1,
				BulletParticleData.P1
			BulletParticleData.T1, BulletParticleData.V1, BulletParticleData.P1 =
				T2, V2, P2
			local Dt = BulletParticleData.T1 - BulletParticleData.T0
			local M0 = BulletParticleData.V0.Magnitude
			local M1 = BulletParticleData.V1.Magnitude

			BulletParticleData.SetTo[BulletParticleData.Attachment0] = {
				WorldPosition = workspace.CurrentCamera.CFrame
					* BulletParticleData.P0,
			}
			BulletParticleData.SetTo[BulletParticleData.Attachment1] = {
				WorldPosition = workspace.CurrentCamera.CFrame
					* BulletParticleData.P1,
			}
			if M0 > 1.0E-8 then
				BulletParticleData.SetTo[BulletParticleData.Attachment0].WorldAxis =
					workspace.CurrentCamera.CFrame:VectorToWorldSpace(
						BulletParticleData.V0 / M0
					)
			end
			if M1 > 1.0E-8 then
				BulletParticleData.SetTo[BulletParticleData.Attachment1].WorldAxis =
					workspace.CurrentCamera.CFrame:VectorToWorldSpace(
						BulletParticleData.V1 / M1
					)
			end

			local Dist0 = -BulletParticleData.P0.Z
			local Dist1 = -BulletParticleData.P1.Z
			if Dist0 < 0 then
				Dist0 = 0
			end
			if Dist1 < 0 then
				Dist1 = 0
			end
			local W0 = BulletParticleData.BulletSize
				+ BulletParticleData.BulletBloom * Dist0
			local W1 = BulletParticleData.BulletSize
				+ BulletParticleData.BulletBloom * Dist1
			local L = (
				(BulletParticleData.P1 - BulletParticleData.P0)
				* Vector3.new(1, 1, 0)
			).Magnitude
			local Tr = 1
				- 4
					* BulletParticleData.BulletSize
					* BulletParticleData.BulletSize
					/ ((W0 + W1) * (2 * L + W0 + W1))
					* BulletParticleData.BulletBrightness
			for _, effect in next, BulletParticleData.Effects do
				BulletParticleData.SetTo[effect] = {
					CurveSize0 = Dt / 3 * M0,
					CurveSize1 = Dt / 3 * M1,
					Width0 = W0,
					Width1 = W1,
					Transparency = NumberSequence.new(Tr),
				}
			end
		end

		if shouldDesynchronize then
			task.desynchronize()
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams:AddToFilter(if IsClient
		then {
			workspace.CurrentCamera,
			workspace.RCS_Workspace.Client,
			workspace.RCS_Workspace.Server,
			if projectile.owner then projectile.owner.Character else nil,
		}
		else {
			workspace.RCS_Workspace.Server,
			if projectile.owner then projectile.owner.Character else nil,
		})

	local raycastResult
	while true do
		raycastResult = workspace:Raycast(
			oldPosition,
			newPosition - oldPosition,
			raycastParams
		)

		if
			raycastResult
			and raycastResult.Instance.Parent
			and (
				raycastResult.Instance.Parent.IsA("Hat")
				or raycastResult.Instance.Parent:IsA("Accessory")
				or (
					raycastResult.Instance.Parent:FindFirstChildWhichIsA(
						"Humanoid"
					)
					and raycastResult.Instance.Name == "HumanoidRootPart"
				)
			)
		then
			raycastParams:AddToFilter(raycastResult.Instance)
		else
			break
		end
	end

	if raycastResult then
		return {
			hit = raycastResult,
			expired = true,
			hitPosition = raycastResult.Position,
			bulletPosition = oldPosition,
			hitInst = raycastResult.Instance,
		}
	end

	return {
		hit = false,
		oldPosition = oldPosition,
		newPosition = newPosition,
	}
end

function projectileMultiThread:parallelStepped(dt: number)
	local instances = {}
	local cframes = {}

	local toRenderDebug = {}
	local expired = {}
	local setTo = {}

	for i, v in projectileMultiThread.activeProjectiles do
		local result = projectileMultiThread:parallelStepProjectile(v, i)

		if IsClient then
			instances[#instances + 1] = projectileMultiThread.cachedInstances[i]
			if v.tracerColor and v.attributes.BulletParticleData then
				setTo[i] = v.attributes.BulletParticleData.SetTo
			end
		end
		if result.hit then
			projectileMultiThread:projectileHit(result.hit, v)
			if DEBUG and IsClient then
				toRenderDebug[#toRenderDebug + 1] = {
					hit = true,
					pos1 = result.bulletPosition,
					pos2 = result.hitPosition,
					inst = result.hitInst,
				}
			end
		end

		if result.expired then
			if IsClient then
				cframes[#cframes + 1] = VERY_FAR_CFRAME

				table.insert(expired, v)

				if v.tracerColor and v.attributes.BulletParticleData then
					setTo[i] = {
						[v.attributes.BulletParticleData.Attachment0] = {
							WorldCFrame = VERY_FAR_CFRAME,
						},
						[v.attributes.BulletParticleData.Attachment1] = {
							WorldCFrame = VERY_FAR_CFRAME,
						},
					}
				end
			end

			projectileMultiThread.activeProjectiles[i] = nil
			projectileMultiThread:projectileDestroying(v)
		elseif IsClient then
			cframes[#cframes + 1] =
				CFrame.new(result.oldPosition, result.newPosition)
			if DEBUG and IsClient then
				toRenderDebug[#toRenderDebug + 1] = {
					hit = false,
					pos1 = result.oldPosition,
					pos2 = result.newPosition,
				}
			end
		end
	end

	if IsClient then
		task.synchronize()

		workspace:BulkMoveTo(
			instances,
			cframes,
			Enum.BulkMoveMode.FireCFrameChanged
		)

		for i, v in expired do
			if v.tracerColor then
				TracerCache[v.internalId][1].CFrame = VERY_FAR_CFRAME
				TracerCache[v.internalId][2].CFrame = VERY_FAR_CFRAME
			end
			projectileMultiThread.cachedInstances[v.internalId]:ClearAllChildren()
		end
		for _, v in setTo do
			for inst: Instance, props in v do
				for prop, val in props do
					inst[prop] = val
				end
			end
		end

		for i, v in toRenderDebug do
			if v.hit then
				local adornment = Instance.new("LineHandleAdornment")
				adornment.AlwaysOnTop = true
				adornment.CFrame = CFrame.new(v.pos1, v.pos2)
				adornment.Length = (v.pos2 - v.pos1).Magnitude
				adornment.Color3 = Color3.new(0, 10, 0)
				adornment.ZIndex = 1
				adornment.Parent = DebugContainer
				adornment.Adornee = workspace.Terrain

				local billboard = Instance.new("BillboardGui")
				billboard.StudsOffsetWorldSpace = v.pos2
				billboard.AlwaysOnTop = true
				billboard.Size = UDim2.new(0, 500, 0, 20)
				billboard.SizeOffset = Vector2.new(0.5, 0)
				local textLabel = Instance.new("TextLabel", billboard)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = string.format(
					"Result: %s(%d, %d, %d)",
					v.inst.Name,
					v.pos2.X,
					v.pos2.Y,
					v.pos2.Z
				)
				textLabel.Font = Enum.Font.RobotoMono
				textLabel.TextColor3 = Color3.new(0, 1, 0)
				textLabel.TextSize = 18
				textLabel.TextXAlignment = Enum.TextXAlignment.Left
				textLabel.Size = UDim2.fromScale(1, 1)
				billboard.Parent = DebugContainer
				billboard.Adornee = workspace.Terrain
			else
				local adornment = Instance.new("LineHandleAdornment")
				adornment.AlwaysOnTop = true
				adornment.CFrame = CFrame.new(v.pos1, v.pos2)
				adornment.Length = (v.pos2 - v.pos1).Magnitude
				adornment.Color3 = Color3.new(10, 0, 0)
				adornment.ZIndex = 1
				adornment.Parent = DebugContainer
				adornment.Adornee = workspace.Terrain
			end
		end
	end
end

return projectileMultiThread
