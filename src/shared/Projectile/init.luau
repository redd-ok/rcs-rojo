local Players = game:GetService("Players")
local Engine = game:GetService("ReplicatedStorage").RCS

local Types = require(Engine.Types)
local Config = require(Engine.RCS_Config)

local Calibers = require(script:WaitForChild("Calibers"))
local Utilities = require(script.Parent:WaitForChild("Utilities"))

local VERY_FAR_CFRAME = CFrame.new(2 ^ 24, 2 ^ 24, 2 ^ 24)

export type ActiveProjectile = {
	caliber: Types.Caliber,
	currentPosition: Vector3,
	distanceTravelled: number,
	timeCreated: number,
	currentVelocity: Vector3,
	hitFunction: HitFunction,
	id: number,
	ignoreList: { Instance },
	attributes: { [any]: unknown },
	cframe: CFrame,
	soundsPlaying: { Sound },
	isTracer: boolean,
}

export type HitFunction = (
	proj: ActiveProjectile,
	raycastResult: RaycastResult,
	params: RaycastParams
) -> (boolean, boolean)

local Projectile = {}
Projectile._activeProjectiles = {}
Projectile._instances = {}

Projectile._dummyProjectile = Instance.new("Part")
Projectile._dummyProjectile.Size = Vector3.new(0.5, 0.5, 5)
Projectile._dummyProjectile.CFrame = VERY_FAR_CFRAME
Projectile._dummyProjectile.Anchored = true
Projectile._dummyProjectile.CanCollide = false
Projectile._dummyProjectile.CanQuery = false
Projectile._dummyProjectile.CanTouch = false
Projectile._dummyProjectile.Transparency = 1
Projectile._dummyProjectile.Parent = workspace.RCS_Workspace.Client

Projectile.SimulationSpeed = 1

function Projectile:AllocateProjectiles(amount: number)
	for i = 1, amount do
		local duplicate = Projectile._dummyProjectile:Clone()
		duplicate.Parent = workspace.RCS_Workspace.Client
		table.insert(Projectile._instances, duplicate)
	end
end

function Projectile:GetCaliber(caliber: string): Types.Caliber?
	return Calibers[caliber]
end

function Projectile:SimulateProjectile(
	activeProjectile: ActiveProjectile,
	deltaTime: number,
	part: BasePart
): (boolean, CFrame?, boolean)
	local oldPos = activeProjectile.currentPosition

	activeProjectile.currentVelocity = Utilities:CalculateDragGravity(
		(activeProjectile.caliber.InitialVelocity / 0.28)
			* activeProjectile.cframe.LookVector,
		activeProjectile.caliber,
		tick() - activeProjectile.timeCreated
	)

	activeProjectile.currentPosition += activeProjectile.currentVelocity * deltaTime
	activeProjectile.distanceTravelled += activeProjectile.currentVelocity.Magnitude * deltaTime

	if
		activeProjectile.distanceTravelled
			> Config.ProjectileMaximumDistance
		or tick() - activeProjectile.timeCreated
			> Config.ProjectileMaximumLifetime
	then
		return true, VERY_FAR_CFRAME, true
	else
		local RayParams = RaycastParams.new()
		RayParams.FilterDescendantsInstances = activeProjectile.ignoreList
		RayParams.RespectCanCollide = false
		RayParams.FilterType = Enum.RaycastFilterType.Exclude

		local pass, recast = true, false
		local raycastResult = workspace:Raycast(
			oldPos,
			activeProjectile.currentPosition - oldPos,
			RayParams
		)

		if raycastResult then
			pass, recast =
				activeProjectile:hitFunction(raycastResult, RayParams)

			if recast then
				while recast do
					raycastResult = workspace:Raycast(
						oldPos,
						activeProjectile.currentPosition - oldPos,
						RayParams
					)
					if not raycastResult then
						-- pass = true
						break
					end
					pass, recast =
						activeProjectile:hitFunction(raycastResult, RayParams)
				end
			end
		end

		if not pass and not recast then
			return true, VERY_FAR_CFRAME, true
		end

		for i, v in activeProjectile.soundsPlaying do
			v.Parent = part
		end

		local cameraPos = workspace.CurrentCamera.CFrame.Position
		local distFromCamera = (
			workspace.CurrentCamera.CFrame.Position - oldPos
		).Magnitude
		if activeProjectile.currentVelocity.Magnitude > 343 / 0.28 then
			if distFromCamera < 130 then
				local d = (cameraPos - oldPos):Dot(
					activeProjectile.currentVelocity
				) / activeProjectile.currentVelocity:Dot(
					activeProjectile.currentVelocity
				)

				if d > 0 and d < 1 then
					if
						distFromCamera < 15
						and (activeProjectile.attributes.lastWhizz == nil)
					then
						if activeProjectile.attributes.lastWhizz then
							print(
								tick()
									- activeProjectile.attributes.lastWhizz :: number
							)
						end
						activeProjectile.attributes.lastWhizz = tick()

						Projectile:PlaySound(
							activeProjectile,
							Config.Sounds.Whizzes[math.random(
								1,
								#Config.Sounds.Whizzes
							)],
							{
								Volume = 10,
								RollOffMinDistance = 1000,
								RollOffMaxDistance = 10000,
							}
						)
						_G.Suppress(
							activeProjectile.caliber.SuppressionAmount,
							oldPos
						)
					end

					if
						distFromCamera < 55
						and activeProjectile.attributes.lastCloseWhizz
							== nil
					then
						activeProjectile.attributes.lastCloseWhizz = tick()
						activeProjectile.attributes.lastMedWhizz = tick()
						print("close crack")

						Projectile:PlaySound(
							activeProjectile,
							Config.Sounds.Cracks.Close[math.random(
								1,
								#Config.Sounds.Cracks.Close
							)],
							{
								Volume = 7,
								RollOffMinDistance = 1000,
								RollOffMaxDistance = 10000,
							}
						)
					elseif
						distFromCamera < 106
						and (activeProjectile.attributes.lastMedWhizz == nil)
					then
						activeProjectile.attributes.lastMedWhizz = tick()
						print("med crack")

						Projectile:PlaySound(
							activeProjectile,
							Config.Sounds.Cracks.Medium[math.random(
								1,
								#Config.Sounds.Cracks.Medium
							)],
							{
								Volume = 3,
								RollOffMinDistance = 1000,
								RollOffMaxDistance = 10000,
							}
						)
					end
				else
					activeProjectile.attributes.lastWhizz = nil
					activeProjectile.attributes.lastCloseWhizz = nil
					activeProjectile.attributes.lastMedWhizz = nil
				end
			end
		end

		-- if
		--     distFromCamera > 200
		--     and not activeProjectile.isTracer
		-- then
		--     if activeProjectile.attributes.AlreadyMoved then
		--         return false, VERY_FAR_CFRAME, false
		--     else
		--         activeProjectile.attributes.AlreadyMoved =
		--             true
		--         return false, VERY_FAR_CFRAME, true
		--     end
		-- end
		-- if activeProjectile.attributes.AlreadyMoved then
		--     activeProjectile.attributes.AlreadyMoved = false
		-- end

		return false, CFrame.new(oldPos, activeProjectile.currentPosition), true
	end
end

function Projectile:Step(deltaTime: number)
	deltaTime *= Projectile.SimulationSpeed

	local cframes = {}
	local parts = {}

	-- for i = 1, #cframes do
	--     parts[i] = Projectile._instances[i]
	-- end

	local index = 1
	while index <= #Projectile._activeProjectiles do
		local activeProjectile: ActiveProjectile =
			Projectile._activeProjectiles[index]

		local shouldRemove, renderCFrame, shouldRender =
			Projectile:SimulateProjectile(
				activeProjectile,
				deltaTime,
				Projectile._instances[index]
			)
		if shouldRender then
			table.insert(parts, Projectile._instances[index])

			cframes[#parts] = renderCFrame
		end

		if shouldRemove then
			table.remove(Projectile._activeProjectiles, index)
		else
			index += 1
		end
	end

	if #parts > 0 then
		workspace:BulkMoveTo(
			parts,
			cframes,
			Enum.BulkMoveMode.FireCFrameChanged
		)
	end

	-- Players.LocalPlayer.PlayerGui.RCS_Hud.ActiveBullets.Text = "Active Bullets: "
	-- 	.. index
end

function Projectile:NewProjectile(
	caliber: Types.Caliber,
	cframe: CFrame,
	id: number,
	hitFunction: HitFunction,
	ignoreList: { Instance },
	isTracer: boolean?
)
	local newProjectile: ActiveProjectile = {
		caliber = caliber,
		currentPosition = cframe.Position,
		distanceTravelled = 0,
		timeCreated = tick(),
		currentVelocity = (caliber.InitialVelocity / 0.28) * cframe.LookVector,
		hitFunction = hitFunction,
		id = id,
		ignoreList = ignoreList,
		attributes = {},
		cframe = cframe,
		soundsPlaying = {},
		isTracer = not not isTracer,
	}

	table.insert(Projectile._activeProjectiles, newProjectile)
	if #Projectile._activeProjectiles > #Projectile._instances then
		warn("Reached projectile limit, allocating more")
		Projectile:AllocateProjectiles(15)
	end
end

function Projectile:PlaySound(
	activeProjectile: ActiveProjectile,
	soundId: string,
	properties: { [string]: unknown }?
)
	local soundInst = Instance.new("Sound")
	soundInst.SoundId = soundId

	if properties then
		for i, v in properties do
			soundInst[i] = v
		end
	end

	table.insert(activeProjectile.soundsPlaying, soundInst)
	soundInst.Ended:Connect(function()
		table.remove(
			activeProjectile.soundsPlaying,
			table.find(activeProjectile.soundsPlaying, soundInst)
		)
		soundInst:Destroy()
	end)
	soundInst:Play()
end

return Projectile
