local Debris = game:GetService("Debris")
local Engine = game.ReplicatedStorage:WaitForChild("RCS")
local HolesSource = Engine:WaitForChild("FX"):WaitForChild("Holes")
-- local Projectile = require(Engine.Modules.Projectile)
local ProjectileV2 = require(Engine.Modules.ProjectileV2)

local Hitmarker = {}
local RicoSounds = {
	"253951210",
	"253951228",
	"253951272",
	"253951309",
	"253951341",
}

local ACS_Storage = workspace:WaitForChild("RCS_Workspace")
local BulletModel = ACS_Storage.Server

function TypesCache(Source)
	if not Source then
		return nil
	end

	local Profile = {}
	local Types = Source:GetChildren()
	for i, Type in ipairs(Types) do
		Profile[Type.Name] = Type:GetChildren()
	end

	return Profile
end

function MakeCache(Source)
	local Target = {}
	for i, folder in ipairs(HolesSource:GetChildren()) do
		local Profile = {}

		Profile.Holes = TypesCache(folder:FindFirstChild("Holes"))
		Profile.FlashDecals = TypesCache(folder:FindFirstChild("FlashDecals"))
		Profile.Particles = TypesCache(folder:FindFirstChild("Particles"))
		local Sounds = folder:FindFirstChild("Sounds")
		if Sounds then
			Profile.Sounds = Sounds:GetChildren()
		end

		Profile.Flash = folder:FindFirstChild("Flash")
		Profile.HoleSize = folder:FindFirstChild("HoleSize")

		local DontRecolor = folder:FindFirstChild("DontRecolor")
		if DontRecolor and DontRecolor.Value then
			Profile.DontRecolor = true
		end

		Target[folder.Name] = Profile
	end

	return Target
end

local Holes = MakeCache(HolesSource)

local holescopy = {
	WoodPlanks = "Wood",
	LeafyGrass = "Grass",
	Snow = "Mud",
	DiamondPlate = "Metal",
	["Name:Leaf"] = "Name:Leaves",
	["Name:Bush"] = "Name:Leaves",
	["Name:Sandbag"] = "Sand",
}

for v1, v2 in pairs(holescopy) do
	Holes[v1] = Holes[v2]
end

local BodyParts = {
	Head = 1,
	["Left Leg"] = 1,
	["Right Leg"] = 1,
	Torso = 1,
	HumanoidRootPart = 1,
	["Left Arm"] = 1,
	["Right Arm"] = 1,
}

local function rlist(Table)
	return Table[math.random(1, #Table)]
end

local function randf(low, top)
	local diff = math.random() * (top - low)
	return low + diff
end

local function NSMult(
	val: NumberSequence | NumberRange,
	mult: number
): NumberSequence | NumberRange
	if typeof(val) == "NumberSequence" then
		local keypoints = val.Keypoints
		for i, keypoint in pairs(keypoints) do
			keypoints[i] = NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value * mult,
				keypoint.Envelope * mult
			)
		end
		return NumberSequence.new(keypoints)
	else
		return NumberRange.new(val.Min * mult, val.Max * mult)
	end
end

local function OffHitCF(Hit: BasePart, Off: CFrame)
	if Hit == workspace.Terrain then
		return Off
	else
		return Hit.CFrame * Off
	end
end

local function GetMatFolder(MatName: string, Hitpart: BasePart)
	local Name = Holes["Name:" .. Hitpart.Name]
	if Name then
		return Name
	elseif BodyParts[Hitpart.Name] then
		return Holes.Human
	else
		return Holes[MatName] or Holes.Default
	end
end

local function CreateAttachment(HitCF: CFrame)
	local Attachment = Instance.new("Attachment")
	Attachment.CFrame = HitCF
	Attachment.Parent = workspace.Terrain
	return Attachment
end

-- Type: "Hit", "Rico", "In", "Out", available for use
-- "In" = wallbang in, "Out" = wallbang out
-- Additional: "Stab" - stab hits from melee
function Hitmarker.HitEffect(
	Ray_Ignore,
	Hitpart,
	Off,
	Mat,
	Proj: ProjectileV2.Projectile,
	Type: "Hit" | "Rico" | "In" | "Out" | "Stab"
)
	debug.profilebegin("Hit Effect")

	if not Hitpart then
		return
	end
	Type = Type or "Hit"
	local HitCF = OffHitCF(Hitpart, Off)
	local Attachment = CreateAttachment(HitCF)
	local MatFolder = GetMatFolder(Mat.Name, Hitpart)

	local bulletSpeed, initialVelocity =
		Proj:getVelocity().Magnitude, Proj.caliberData.InitialVelocity

	-- bullet hole size per caliber
	local HSMult = Proj.caliberData.HoleSize * (bulletSpeed / initialVelocity)
		or bulletSpeed / initialVelocity

	local EnergyMult = Proj.caliberData.ImpactEnergy
			* (bulletSpeed / initialVelocity)
		or bulletSpeed / initialVelocity
	local EMcrt = EnergyMult ^ (1 / 3)
	local EMsqrt = math.sqrt(EnergyMult)

	-- hitpart color
	local hitpartcolor = Hitpart.Color
	if Hitpart == workspace.Terrain then
		if Mat.Name == "Water" then
			hitpartcolor = Hitpart.WaterColor:lerp(Color3.new(0.5, 1, 1), 0.5)
		else
			hitpartcolor = Hitpart:GetMaterialColor(Mat)
		end
	end
	local hitpartcs = ColorSequence.new(hitpartcolor)

	-- hole decal and part
	if MatFolder.Holes then
		debug.profilebegin("Holes")
		local part = Instance.new("Part")
		part.TopSurface = 0
		part.BottomSurface = 0
		part.Transparency = 1
		part.Color = Color3.new(0, 0, 0)
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Material = Enum.Material.Fabric --Enum.Material.Air

		local hs = MatFolder.HoleSize
		local size = randf(hs.MinValue, hs.MaxValue) * HSMult

		part.Size = Vector3.new(size, 0, size)
		part.CFrame = HitCF
			* CFrame.Angles(math.pi / 2, randf(0, 2) * math.pi, math.pi)

		local Decals = MatFolder.Holes[Type] or MatFolder.Holes.Hit

		local Dec = rlist(Decals):Clone()
		Dec.Face = "Top"
		if not MatFolder.DontRecolor then
			Dec.Color3 = hitpartcolor
		end
		Dec.Parent = part

		local b = Instance.new("WeldConstraint")
		b.Parent = part
		b.Part0 = part
		b.Part1 = Hitpart

		debug.profileend()
		part.Parent = workspace.RCS_Workspace.Client
	end

	-- particles
	if MatFolder.Particles then
		debug.profilebegin("Particles")
		local Particles = MatFolder.Particles[Type] or MatFolder.Particles.Hit

		for _, Particle in pairs(Particles) do
			local NewParticle = Particle:Clone()
			NewParticle.Enabled = false
			NewParticle.Size = NSMult(NewParticle.Size, EMcrt)
			NewParticle.Speed = NSMult(NewParticle.Speed, EMcrt)

			local dur = 0.05
			if NewParticle:FindFirstChild("Duration") then
				dur = NewParticle.Duration.Value
			end
			if NewParticle:FindFirstChild("HitpartColor") then
				NewParticle.Color = hitpartcs
			end

			NewParticle.Parent = Attachment
			NewParticle:Emit(NewParticle.Rate * dur)
			Debris:AddItem(NewParticle, NewParticle.Lifetime.Max)
		end
		debug.profileend()
	end

	-- flash
	if MatFolder.Flash then
		local po = MatFolder.Flash:Clone()
		po.Shadows = true
		po.Range = po.Range * randf(1 / 1.35, 1.35) * EMsqrt
		po.Brightness = po.Brightness * EMsqrt
		po.Enabled = true
		po.Parent = Attachment
		if MatFolder.Flash:FindFirstChild("Duration") then
			Debris:AddItem(po, MatFolder.Flash.Duration.Value)
		else
			Debris:AddItem(po, 0.05)
		end
	end

	-- flash decal
	if MatFolder.FlashDecals then
		debug.profilebegin("Flash Decals")
		local bg = Instance.new("BillboardGui")
		bg.Adornee = Attachment
		bg.Parent = Attachment

		local FlashDecals = MatFolder.FlashDecals[Type]
			or MatFolder.FlashDecals.Hit

		local flash = rlist(FlashDecals):Clone()

		local size = flash:FindFirstChild("Size")
		local flashsize
		if size then
			flashsize = randf(size.MinValue, size.MaxValue) * EMcrt
		else
			flashsize = randf(0.8, 1.25) * EMcrt
		end
		bg.Size = UDim2.new(flashsize, 0, flashsize, 0)

		local trans = flash:FindFirstChild("Trans")
		if trans then
			flash.ImageTransparency = randf(trans.MinValue, trans.MaxValue)
		end

		flash.Visible = true
		flash.Rotation = math.random(0, 360)
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		local dur = 0.07
		if flash:FindFirstChild("Duration") then
			dur = flash.Duration.Value
		end
		flash.Parent = bg

		flash:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", dur * 2)
		Debris:AddItem(bg, dur)
		debug.profileend()
	end

	-- sound
	if Type ~= "Out" and MatFolder.Sounds then
		debug.profilebegin("Sound")
		local Sound = rlist(MatFolder.Sounds):Clone()
		Sound.PlaybackSpeed = randf(0.8, 1.25)
			* Sound.PlaybackSpeed
			/ EMcrt ^ (1 / 3)
		Sound.Volume = Sound.Volume * EnergyMult
		Sound.RollOffMaxDistance = Sound.RollOffMaxDistance * EMcrt
		Sound.Parent = Attachment
		Sound:Play()
		Debris:AddItem(Sound, Sound.TimeLength / Sound.PlaybackSpeed)
		debug.profileend()
	end

	if Type == "Rico" and Mat ~= Enum.Material.Water then
		local Sound = Instance.new("Sound")
		Sound.RollOffMode = Enum.RollOffMode.InverseTapered
		Sound.RollOffMinDistance = 24
		Sound.RollOffMaxDistance = 120
		Sound.SoundId = "rbxassetid://" .. rlist(RicoSounds)
		Sound.Volume = 2
		Sound.Parent = Attachment
		Sound:Play()
		Debris:AddItem(Sound, Sound.TimeLength / Sound.PlaybackSpeed)
	end

	if Hitpart.Name == "Hitmaker" then
		local Marca = Instance.new("Part")
		Marca.Material = Enum.Material.Neon
		Marca.Anchored = true
		Marca.CanCollide = false
		Marca.Color = Color3.fromRGB(
			math.random(0, 255),
			math.random(0, 255),
			math.random(0, 255)
		)
		Marca.Size = Vector3.new(0.2, 0.2, 0.01)
		Marca.Parent = ACS_Storage.Server
		--Marca.CFrame = CFrame.new(Pos, Pos + Norm)
		Marca.CFrame =
			CFrame.new(HitCF.Position, HitCF.Position - HitCF.LookVector)
		table.insert(Ray_Ignore, Marca)
		Debris:AddItem(Attachment, 5)
		Debris:AddItem(Marca, 20)
	elseif Hitpart.Name == "alvo" then
		local Marca = Instance.new("Part")
		Marca.Anchored = true
		Marca.CanCollide = false
		Marca.Transparency = 1
		Marca.Size = Vector3.new(0.2, 0.2, 0.01)
		Marca.Parent = ACS_Storage.Server
		Marca.CFrame = HitCF
		Debris:AddItem(Attachment, 5)
		Debris:AddItem(Marca, 20)
		table.insert(Ray_Ignore, Marca)
		local Dec = Instance.new("Decal")
		Dec.Texture = "rbxassetid://359667865"
		Dec.Parent = Marca
	end

	if not Attachment then
		return
	end
	coroutine.wrap(function()
		repeat
			task.wait(0.1)
		until #Attachment:GetChildren() == 0
		Attachment:Destroy()
	end)()

	debug.profileend()
end

return Hitmarker
