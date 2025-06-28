local Types = require(game:GetService("ReplicatedStorage").RCS.Types)
local FX = game:GetService("ReplicatedStorage").RCS:WaitForChild("FX")

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
	object: BasePart
): {
	raycastResult: RaycastResult,
	thickness: number,
}?
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = { object }

	local dir = startDirection * 9999

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

return Utilities
