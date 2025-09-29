local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RCS = ReplicatedStorage.RCS

local FX = RCS:WaitForChild("FX")

local Config = require(RCS.RCS_Config)
local Types = require(RCS.Types)
local Calibers = require(RCS.Calibers)

local CurrentCamera = workspace.CurrentCamera

local Utilities = {}

function Utilities:Random2(Min: number, Max: number, Accuracy: number): number
	local Inverse = 1 / (Accuracy or 1)
	return (math.random(Min * Inverse, Max * Inverse) / Inverse)
end

function Utilities:Random<T>(Min: T, Max: T): T
	local value = math.random()
			* (((Max :: any) :: number) - ((Min :: any) :: number))
		+ (Min :: any) :: number
	return value :: T
end

function Utilities:Weld(
	p1: BasePart,
	p2: BasePart,
	c0: CFrame?,
	c1: CFrame?
): Motor6D
	local w = Instance.new("Motor6D", p1)
	w.Part0 = p1
	w.Part1 = p2
	w.Name = p2.Name
	w.C0 = c0 or p1.CFrame:Inverse() * p2.CFrame
	w.C1 = c1 or CFrame.new()
	return w
end

function Utilities:Lerp<T>(start: T, goal: T, alpha: number): T
	if typeof(start) == "number" then
		return start + (goal - start) * alpha
	end

	return (
		((start :: any) :: Vector3):Lerp((goal :: any) :: Vector3, alpha) :: any
	) :: T
end

function Utilities:SmoothLerp<T>(
	variableA: T,
	variableB: T,
	fraction: number,
	deltaTime: number
): T
	local f = 1.0 - math.pow(1.0 - fraction, deltaTime)

	if type(variableA) == "number" then
		return ((1 - f) * variableA) + (variableB * f)
	end

	return (
		((variableA :: any) :: Vector3):Lerp(
			(variableB :: any) :: Vector3,
			f
		) :: any
	) :: T
end

function Utilities:OffsetFromPivot(
	cframe: CFrame,
	pivot: CFrame,
	offset: CFrame
)
	local pivotToCFrameOffset = pivot:ToObjectSpace(cframe)

	pivot *= offset
	return pivot * pivotToCFrameOffset
end

function Utilities:WeldComplex(x: BasePart, y: BasePart, Name: string)
	local W = Instance.new("Motor6D")
	W.Name = Name
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:Inverse() * CJ
	local C1 = y.CFrame:Inverse() * CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
	return W
end

function Utilities:CheckForHumanoid(search: Instance): (boolean, Humanoid?)
	local result = false
	local humanoid = nil
	if search and search.Parent then
		if search.Parent:FindFirstChild("Humanoid") then
			result = true
			humanoid = search.Parent:FindFirstChild("Humanoid")
		elseif
			search.Parent.Parent
			and search.Parent.Parent:FindFirstChild("Humanoid")
		then
			result = true
			humanoid = search.Parent.Parent:FindFirstChild("Humanoid")
		end
	end
	return result, humanoid
end

function Utilities:ConvertHitToCF(
	HitPart: BasePart,
	Pos: Vector3,
	Norm: Vector3,
	Dir: Vector3?
): CFrame
	local cfw = CFrame.new(Pos, Pos + Norm)
	local off = (HitPart == workspace.Terrain) and cfw
		or HitPart.CFrame:Inverse() * cfw

	if Dir then
		local ang2 = Norm:Angle(Dir.Unit) - math.pi / 2 -- angle between norm and incoming bullet

		local dir2 = CFrame.fromAxisAngle(Norm:Cross(Dir), -ang2) * Dir -- I don't know how I did this, but it works when you need to flatten a vector to a plane

		local ang = cfw.UpVector:Angle(dir2.Unit, Norm) -- measure angle between bullet hole up-direction and impact direction

		off = off * CFrame.fromAxisAngle(-Vector3.zAxis, ang) -- weird rotation axis, also works.... using offset CFrame (relative only to part, NOT WORLD)
	else
		off = off
			* CFrame.fromAxisAngle(
				-Vector3.zAxis,
				Utilities:Random(-math.pi, math.pi)
			)
	end

	return off
end

function Utilities:FindExitPoint(
	startPosition: Vector3,
	startDirection: Vector3,
	object: BasePart,
	maxDistance: number?
): {
	raycastResult: RaycastResult,
	thickness: number,
}?
	maxDistance = maxDistance or 9999

	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params:AddToFilter(object)

	local dir = startDirection * (maxDistance :: number)

	local rayResult = workspace:Raycast(startPosition + dir, -dir * 1.1, Params)

	if rayResult then
		return {
			raycastResult = rayResult,
			thickness = (startPosition - rayResult.Position).Magnitude,
		}
	end

	return -- why the hell do i have to add this? stupid lsp...
end

function Utilities:CalculateDragGravity(
	currentVelocity: Vector3,
	caliber: Types.Caliber,
	deltaTime: number
): Vector3
	local k = caliber.DragConstant / (caliber.Mass * 10)
	local dragDecay = math.exp(-k * deltaTime)

	-- local gravity = (
	-- 	-workspace.Gravity * Vector3.new(0, (caliber.Mass * 10), 0)
	-- ) * deltaTime
	local gravity = Vector3.new(0, -workspace.Gravity * (caliber.Mass * 10), 0)

	return (currentVelocity * dragDecay) + gravity
end

function Utilities:ShellEject(Position: CFrame, Caliber: string)
	local Shell = FX.Shells:FindFirstChild(Caliber)
	if not Shell then
		Shell = FX.Shells.Default
	end

	local Casing: BasePart = Shell.Casing
	local ShellSettings: Types.EjectionForce = require(Shell.EjectionForce)
	local CasingDupl = Casing:Clone()
	CasingDupl.Parent = workspace.RCS_Workspace.Client

	CasingDupl.CFrame = Position
	CasingDupl.Anchored = false
	CasingDupl.CanCollide = true
	CasingDupl.CastShadow = false
	CasingDupl.CustomPhysicalProperties = ShellSettings.PhysProperties
	CasingDupl.CollisionGroup = "Casings"

	local Att = Instance.new("Attachment", CasingDupl)
	Att.Position = ShellSettings.ForcePoint
	local ShellForce = Instance.new("VectorForce", CasingDupl)
	ShellForce.Visible = false

	ShellForce.Force = ShellSettings:CalculateForce()
end

function Utilities:HasNightvisionOn()
	return false
end

function Utilities:IsIndoors(
	position: Vector3,
	ignoreList: { Instance },
	roofDistance: number?
)
	roofDistance = roofDistance or 50

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignoreList

	return workspace:Raycast(position, Vector3.new(0, roofDistance, 0), params)
		~= nil
end

function Utilities:BloodSplatter(hitCF: CFrame, cal: Types.Caliber, char: Model)
	local pos = hitCF.Position
	local dir = (hitCF * CFrame.Angles(
		Utilities:Random(-0.3, 0.3),
		Utilities:Random(-0.3, 0.3),
		Utilities:Random(-0.3, 0.3)
	)).LookVector

	local hit: RaycastResult?
	local vel = dir * (cal.ImpactEnergy ^ (1 / 3.5)) * 2.5

	local params = RaycastParams.new()
	params.RespectCanCollide = true
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = false
	params.FilterDescendantsInstances = {
		char,
		workspace.Terrain,
		workspace.RCS_Workspace.Server,
		workspace.RCS_Workspace.Client,
	}

	for i = 1, 150 do
		hit = workspace:Raycast(pos, vel, params)
		if hit then
			break
		end

		pos += vel
		vel += Vector3.new(0, -(workspace.Gravity * (1 / 60)), 0)
	end

	if hit then
		local splatter = FX.Blood.SplatterMesh:Clone()
		splatter.Size =
			Vector3.new(Utilities:Random(2, 5), 0.001, Utilities:Random(2, 5))
		splatter.CFrame = CFrame.new(
			hit.Position + Vector3.new(0, 0.1, 0),
			hit.Position + hit.Normal
		) * CFrame.Angles(math.rad(-90), 0, 0) * CFrame.Angles(
			0,
			math.rad(Utilities:Random(0, 360)),
			0
		)
		local splatterTextures = FX.Blood.Splatter:GetChildren()
		local splatterTexture =
			splatterTextures[math.random(1, #splatterTextures)]:Clone()
		splatterTexture.Parent = splatter
		splatter.Parent = (workspace.RCS_Workspace[if game
				:GetService("RunService")
				:IsServer()
			then "Server"
			else "Client"] :: Folder):FindFirstChild("Blood")

		game:GetService("Debris"):AddItem(splatter, 30)
	end
end

function Utilities:FindProjectileConfig(projectileName: string): Types.Caliber
	local calibers_flattened: {
		[string]: Types.Caliber,
	} = {}

	for caliber, subcalibers in Calibers do
		for subcaliber, config in subcalibers do
			calibers_flattened[`{caliber} {subcaliber}`] = config
		end
	end

	if not calibers_flattened[projectileName] then
		error(`Could not find config for caliber {projectileName}`)
	end

	return calibers_flattened[projectileName]
end

function Utilities:HasLoopingSounds(muzzle: Attachment)
	local isIndoors = Utilities:IsIndoors(
		muzzle.WorldPosition,
		{ (muzzle :: any).Parent.Parent.Parent }
	)

	return if isIndoors
		then muzzle:FindFirstChild("IndoorLoop") ~= nil or muzzle:FindFirstChild(
			"IndoorLoopDistant"
		) ~= nil
		else muzzle:FindFirstChild("Loop") ~= nil or muzzle:FindFirstChild(
			"LoopDistant"
		) ~= nil
end
function Utilities:HasSingleSounds(muzzle: Attachment)
	local isIndoors = Utilities:IsIndoors(
		muzzle.WorldPosition,
		{ (muzzle :: any).Parent.Parent.Parent }
	)

	return if isIndoors
		then muzzle:FindFirstChild("IndoorLoop") ~= nil or muzzle:FindFirstChild(
			"IndoorDistant"
		) ~= nil
		else muzzle:FindFirstChild("Fire") ~= nil or muzzle:FindFirstChild(
			"Distant"
		) ~= nil
end

function Utilities:PlaySoundAtPosition(
	sound: Sound,
	position: Vector3,
	options: {
		volume: number?,
		useSpeedOfSound: boolean?,
		parent: BasePart?,
	}?
): () -> ()
	local volume = options and options.volume
	local useSpeedOfSound = if options
			and options.useSpeedOfSound ~= nil
		then options.useSpeedOfSound
		else Config.SpeedOfSoundEnabled
	local attachmentParent = options and options.parent or workspace.Terrain

	local soundCloned = sound:Clone()
	local attachment = Instance.new("Attachment")
	attachment.Parent = attachmentParent
	soundCloned.Parent = attachment
	soundCloned.Volume = volume or soundCloned.Volume

	attachment.WorldPosition = position

	if
		useSpeedOfSound ~= nil and useSpeedOfSound
		or useSpeedOfSound == nil and Config.SpeedOfSoundEnabled
	then
		local thread1
		local thread0 = task.delay(
			(CurrentCamera.CFrame.Position - position).Magnitude
				/ Config.SpeedOfSound,
			function()
				soundCloned:Play()
				thread1 = task.delay(
					soundCloned.TimeLength / soundCloned.PlaybackSpeed,
					function()
						attachment:Destroy()
					end
				)
			end
		)

		return function()
			task.cancel(thread1)
			task.cancel(thread0)
			attachment:Destroy()
		end
	else
		soundCloned:Play()
		local thread = task.delay(
			soundCloned.TimeLength / soundCloned.PlaybackSpeed,
			function()
				soundCloned:Destroy()
			end
		)

		return function()
			task.cancel(thread)
			attachment:Destroy()
		end
	end
end

function Utilities:GetDistantWeaponSounds(
	soundContainer: Folder,
	distance: number
)
	local sounds: { [number]: Folder? } = {}

	for _, v in soundContainer:GetChildren() do
		local distanceGroup = tonumber(v.Name)
		assert(distanceGroup, `Invalid name for distant sound group: {v.Name}`)

		sounds[distanceGroup] = v
	end

	local order: { [number]: number } = {}
	for i, _ in sounds do
		order[#order + 1] = i
	end
	table.sort(order, function(a, b)
		return a < b
	end)

	local sound1
	local sound2
	local minDist = -1
	for index, v in sounds do
		if index > minDist and index <= distance then
			minDist = index
			sound1 = v
			local a = table.find(order, tonumber(v.Name) :: number)
			sound2 = sounds[order[a + 1]]
		end
	end

	return sound1, sound2
end

function Utilities:MuzzleEffect(
	Handle: Types.WeaponHandle,
	playSemiSound: boolean,
	indoorSound: boolean
)
	local Muzzle = Handle.Muzzle
	local DistanceFromCaemra = (
		CurrentCamera.CFrame.Position - Muzzle.WorldPosition
	).Magnitude

	if playSemiSound then
		local sound: Sound
		local sound2: Sound
		local soundsFolder: Folder?, sounds2Folder: Folder?
		if indoorSound then
			if Muzzle:FindFirstChild("IndoorDistant") then
				soundsFolder, sounds2Folder = Utilities:GetDistantWeaponSounds(
					Muzzle.IndoorDistant,
					DistanceFromCaemra
				)
			end

			if
				not soundsFolder
				and not sounds2Folder
				and Muzzle:FindFirstChild("Indoor")
			then
				sound = Muzzle.Indoor
			end
		else
			if Muzzle:FindFirstChild("Distant") then
				soundsFolder, sounds2Folder = Utilities:GetDistantWeaponSounds(
					Muzzle.Distant,
					DistanceFromCaemra
				)
			end

			if
				not soundsFolder
				and not sounds2Folder
				and Muzzle:FindFirstChild("Fire")
			then
				sound = Muzzle.Fire
			end
		end

		local soundVolume, sound2Volume
		if soundsFolder or sounds2Folder then
			local sounds, sounds2 =
				soundsFolder and soundsFolder:GetChildren(),
				sounds2Folder and sounds2Folder:GetChildren()

			sound, sound2 =
				sounds and sounds[math.random(1, #sounds)],
				sounds2 and sounds2[math.random(1, #sounds)]

			if sound and sound2 and sounds2Folder then
				soundVolume = sound.Volume
					- sound.Volume
						* math.clamp(
							DistanceFromCaemra / tonumber(sounds2Folder.Name),
							0,
							1
						)
				sound2Volume = sound2.Volume
					* math.clamp(
						DistanceFromCaemra / tonumber(sounds2Folder.Name),
						0,
						1
					)
			end
		end

		if sound then
			Utilities:PlaySoundAtPosition(
				sound,
				Muzzle.WorldPosition,
				{ volume = soundVolume }
			)
		end

		if sound2 then
			Utilities:PlaySoundAtPosition(
				sound2,
				Muzzle.WorldPosition,
				{ volume = sound2Volume }
			)
		end
	end

	local isNight = Lighting.ClockTime > 19 or Lighting.ClockTime < 7

	for i, v in Muzzle:GetChildren() do
		if v:IsA("ParticleEmitter") and v.Name ~= "OverHeat" then
			v:Emit(
				v:FindFirstChild("EmitCount") and v.EmitCount.Value
					or math.random(4, 6)
			)
		elseif v:IsA("Light") then
			v.Enabled = true

			task.delay(
				Utilities:Random(0.01, 0.06) * (isNight and 1.45 or 0.7),
				function()
					v.Enabled = false
				end
			)
		end
	end

	for i, v in Handle.Chamber:GetChildren() do
		if v:IsA("ParticleEmitter") and v.Name ~= "OverHeat" then
			v:Emit(
				v:FindFirstChild("EmitCount") and v.EmitCount.Value
					or math.random(4, 6)
			)
		elseif v:IsA("Light") then
			v.Enabled = true

			task.delay(
				Utilities:Random(0.01, 0.06) * (isNight and 1.45 or 0.7),
				function()
					v.Enabled = false
				end
			)
		end
	end
end

local loopingSoundThreads: { [Types.WeaponMuzzle]: thread } = {}
local loopingSounds: { [Types.WeaponMuzzle]: { () -> () } } = {}
function Utilities:LoopingSounds(Muzzle: Types.WeaponMuzzle, start: boolean)
	if start then
		local DistanceFromCamera = (
			CurrentCamera.CFrame.Position - Muzzle.WorldPosition
		).Magnitude
		print(DistanceFromCamera)

		local sound: Sound? = nil
		local soundsFolder: Folder?, sounds2Folder: Folder?

		if
			(
				Muzzle:FindFirstChild("IndoorLoop")
				or Muzzle:FindFirstChild("IndoorLoopDistant")
			)
			and Utilities:IsIndoors(Muzzle.WorldPosition, {
				Players.LocalPlayer.Character,
				CurrentCamera,
				workspace.RCS_Workspace.Client,
				workspace.RCS_Workspace.Server,
			})
		then
			if Muzzle:FindFirstChild("IndoorLoopDistant") then
				soundsFolder, sounds2Folder = Utilities:GetDistantWeaponSounds(
					Muzzle.IndoorLoopDistant,
					DistanceFromCamera
				)
			end

			if not soundsFolder and not sounds2Folder then
				sound = Muzzle.IndoorLoop
			end
		else
			if Muzzle:FindFirstChild("LoopDistant") then
				soundsFolder, sounds2Folder = Utilities:GetDistantWeaponSounds(
					Muzzle.LoopDistant,
					DistanceFromCamera
				)
			end

			if not soundsFolder and not sounds2Folder then
				sound = Muzzle.Loop
			end
		end

		local sounds, sounds2 =
			soundsFolder and (soundsFolder:GetChildren() :: any) :: { Sound },
			sounds2Folder and (sounds2Folder:GetChildren() :: any) :: { Sound }

		if sounds or sounds2 then
			Muzzle:SetAttribute("PlayingDistantLoopingSound", true)

			local function loopingSound()
				if not Muzzle:GetAttribute("PlayingDistantLoopingSound") then
					loopingSoundThreads[Muzzle] = nil
					return
				end

				DistanceFromCamera = (
					CurrentCamera.CFrame.Position - Muzzle.WorldPosition
				).Magnitude

				local sound, sound2 =
					sounds and sounds[math.random(1, #sounds)],
					sounds2 and sounds2[math.random(1, #sounds)]

				local volumeMultiplier = if sounds2Folder
					then math.clamp(
						DistanceFromCamera / tonumber(sounds2Folder.Name),
						0,
						1
					)
					else 0

				local soundVolume = sound.Volume
					- sound.Volume * volumeMultiplier
				local sound2Volume = sound2 and sound2.Volume * volumeMultiplier

				loopingSounds[Muzzle] = {}

				loopingSounds[Muzzle][1] =
					Utilities:PlaySoundAtPosition(sound, Muzzle.WorldPosition, {
						volume = soundVolume,
						useSpeedOfSound = false,
						parent = Muzzle,
					})
				if sound2 then
					loopingSounds[Muzzle][2] = Utilities:PlaySoundAtPosition(
						sound2,
						Muzzle.WorldPosition,
						{
							volume = sound2Volume,
							useSpeedOfSound = false,
							parent = Muzzle,
						}
					)
				end

				if
					not sound2
					or sound.TimeLength / sound.PlaybackSpeed
						< sound2.TimeLength / sound2.PlaybackSpeed
				then
					loopingSoundThreads[Muzzle] = task.delay(
						(sound.TimeLength / sound.PlaybackSpeed),
						loopingSound
					)
				else
					loopingSoundThreads[Muzzle] = task.delay(
						(sound2.TimeLength / sound2.PlaybackSpeed),
						loopingSound
					)
				end
			end

			if Config.SpeedOfSoundEnabled then
				task.delay(
					DistanceFromCamera / Config.SpeedOfSound,
					loopingSound
				)
			else
				loopingSound()
			end
		elseif sound then
			if Config.SpeedOfSoundEnabled then
				task.delay(DistanceFromCamera / Config.SpeedOfSound, function()
					sound.Playing = true
				end)
			else
				sound.Playing = true
			end
		end
	else
		if Config.SpeedOfSoundEnabled then
			task.delay(
				(CurrentCamera.CFrame.Position - Muzzle.WorldPosition).Magnitude
					/ Config.SpeedOfSound,
				function()
					if Muzzle:FindFirstChild("Loop") then
						Muzzle.Loop.Playing = false
					end

					Muzzle:SetAttribute("PlayingDistantLoopingSound", false)
					if loopingSoundThreads[Muzzle] then
						task.cancel(loopingSoundThreads[Muzzle])
						loopingSoundThreads[Muzzle] = nil
					end
					if loopingSounds[Muzzle] then
						for _, v in loopingSounds[Muzzle] do
							v()
						end

						loopingSounds[Muzzle] = nil
					end

					if Muzzle:FindFirstChild("IndoorLoop") then
						Muzzle.IndoorLoop.Playing = false
					end
				end
			)
		else
			if Muzzle:FindFirstChild("Loop") then
				Muzzle.Loop.Playing = false
			end

			Muzzle:SetAttribute("PlayingDistantLoopingSound", false)
			if loopingSoundThreads[Muzzle] then
				task.cancel(loopingSoundThreads[Muzzle])
				loopingSoundThreads[Muzzle] = nil
			end
			if loopingSounds[Muzzle] then
				for _, v in loopingSounds[Muzzle] do
					v()
				end

				loopingSounds[Muzzle] = nil
			end

			if Muzzle:FindFirstChild("IndoorLoop") then
				Muzzle.IndoorLoop.Playing = false
			end
		end

		if
			Muzzle:FindFirstChild("IndoorLoopTail")
			and Utilities:IsIndoors(Muzzle.WorldPosition, {
				Players.LocalPlayer.Character,
				CurrentCamera,
				workspace.RCS_Workspace.Client,
				workspace.RCS_Workspace.Server,
			})
		then
			Utilities:PlaySoundAtPosition(
				Muzzle.IndoorLoopTail,
				Muzzle.WorldPosition
			)
			return
		end

		if Muzzle:FindFirstChild("LoopTail") then
			Utilities:PlaySoundAtPosition(Muzzle.LoopTail, Muzzle.WorldPosition)
		end
	end
end

return Utilities
