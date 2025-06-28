local engine = game:GetService("ReplicatedStorage"):WaitForChild("RCS")
local footsteps = engine:WaitForChild("Footsteps")
local utilities =
	require(engine:WaitForChild("Modules"):WaitForChild("Utilities"))
local network = require(engine:WaitForChild("ClientNetwork"))

local character = script.Parent
local humanoid: Humanoid = (script.Parent :: Instance):WaitForChild(
		"Humanoid"
	) :: Humanoid

local walkFootstepRate = 0.415
local runFootstepRate = 0.285

local leftFoot = false

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

local function playFootstep(pace, volume, material)
	pace = footsteps:FindFirstChild(pace or "Walk") or footsteps.Walk
	material = pace:FindFirstChild(material[materialsSimplified] or material)
		or pace.Asphalt

	local sounds: { Sound } = material:GetChildren()
	local sound = sounds[math.random(1, #sounds)]
	local duplicate = sound:Clone()
	duplicate.Parent = if leftFoot
		then character["Left Leg"]
		else character["Right Leg"]
	duplicate.Volume = volume * 2.5 * utilities:Random(0.8, 1.2)
	duplicate.PlaybackSpeed = utilities:Random(0.8, 1.2)
	duplicate.RollOffMinDistance = 15
	duplicate.RollOffMaxDistance = volume * 12
	duplicate.RollOffMode = Enum.RollOffMode.InverseTapered
	duplicate:Play()
	task.delay(duplicate.TimeLength / duplicate.PlaybackSpeed, function()
		duplicate:Destroy()
	end)

	leftFoot = not leftFoot
end

local materials = Enum.Material:GetEnumItems()

local timePassed = 0
game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	if
		humanoid.MoveDirection.Magnitude > 0
		and humanoid.FloorMaterial ~= Enum.Material.Air
	then
		timePassed += deltaTime

		local isRunning = humanoid.WalkSpeed > 12

		if isRunning then
			if timePassed > runFootstepRate then
				playFootstep("Running", 3.75, humanoid.FloorMaterial.Name)
				--network.Events.Footstep_CTS:ser(network.Client, humanoid.FloorMaterial)
				network.CharacterEvents.Footstep_CTS.fire(
					table.find(materials, humanoid.FloorMaterial) :: number
				)
				timePassed = 0
			end
		else
			if timePassed > walkFootstepRate then
				playFootstep("Walk", 2.5, humanoid.FloorMaterial.Name)
				network.CharacterEvents.Footstep_CTS.fire(
					table.find(materials, humanoid.FloorMaterial) :: number
				)
				timePassed = 0
			end
		end
	else
		timePassed = 0
		leftFoot = false
	end
end)
