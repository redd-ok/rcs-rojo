local Players = game:GetService("Players")

local Utilities = require(script.Parent.Utilities)

local RagdollModule = {}

local function _createColliderPart(part: BasePart)
	if not part then
		return
	end
	local rp = Instance.new("Part")
	rp.Name = "ColliderPart"
	rp.Size = part.Size / 1.7
	rp.Massless = true
	rp.CFrame = part.CFrame
	rp.Transparency = 1

	local wc = Instance.new("WeldConstraint")
	wc.Part0 = rp
	wc.Part1 = part

	wc.Parent = rp
	rp.Parent = part
end

function RagdollModule:SetupModel(char: Model)
	local ragdollStuff = Instance.new("Folder")
	ragdollStuff.Name = "RagdollStuff"
	ragdollStuff.Parent = char

	local head = char:FindFirstChild("Head")
	local leftarm = char:FindFirstChild("Left Arm")
	local leftleg = char:FindFirstChild("Left Leg")
	local rightleg = char:FindFirstChild("Right Leg")
	local rightarm = char:FindFirstChild("Right Arm")
	local torso = char:FindFirstChild("Torso")

	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid.BreakJointsOnDeath = false
		humanoid.RequiresNeck = false
	end

	for i, v in char:GetChildren() do
		if v:IsA("BasePart") then
			local d = PhysicalProperties.new(v.Material)

			v.CustomPhysicalProperties = PhysicalProperties.new(
				2,
				2,
				d.Elasticity,
				15,
				d.ElasticityWeight
			)
		end
	end

	local HeadA = Instance.new("Attachment")
	HeadA.Name = "HeadA"
	HeadA.Parent = head
	HeadA.Position = Vector3.new(0, -0.5, 0)
	HeadA.Rotation = Vector3.new(0, 0, -90)
	HeadA.Axis = Vector3.new(0, -1, 0)
	HeadA.SecondaryAxis = Vector3.new(1, 0, 0)

	local LeftArmA = Instance.new("Attachment")
	LeftArmA.Name = "LeftArmA"
	LeftArmA.Parent = leftarm
	LeftArmA.Position = Vector3.new(0.5, 0.6, 0)
	LeftArmA.Rotation = Vector3.new(0, 0, 0)
	LeftArmA.Axis = Vector3.new(1, 0, 0)
	LeftArmA.SecondaryAxis = Vector3.new(0, 1, 0)

	local LeftLegA = Instance.new("Attachment")
	LeftLegA.Name = "LeftLegA"
	LeftLegA.Parent = leftleg
	LeftLegA.Position = Vector3.new(0.1, 1, -0)
	LeftLegA.Rotation = Vector3.new(-0, -0, -90)
	LeftLegA.Axis = Vector3.new(-0, -1, 0)
	LeftLegA.SecondaryAxis = Vector3.new(1, 0, 0)

	local RightArmA = Instance.new("Attachment")
	RightArmA.Name = "RightArmA"
	RightArmA.Parent = rightarm
	RightArmA.Position = Vector3.new(-0.5, 0.6, 0)
	RightArmA.Rotation = Vector3.new(-180, 0, -180)
	RightArmA.Axis = Vector3.new(-1, 0, 0)
	RightArmA.SecondaryAxis = Vector3.new(0, 1, 0)

	local RightLegA = Instance.new("Attachment")
	RightLegA.Name = "RightLegA"
	RightLegA.Parent = rightleg
	RightLegA.Position = Vector3.new(-0.1, 1, 0)
	RightLegA.Rotation = Vector3.new(0, 0, -90)
	RightLegA.Axis = Vector3.new(-0, -1, -0)
	RightLegA.SecondaryAxis = Vector3.new(1, 0, -0)

	local TorsoA = Instance.new("Attachment")
	TorsoA.Name = "TorsoA"
	TorsoA.Parent = torso
	TorsoA.Position = Vector3.new(0.4, -1, 0)
	TorsoA.Rotation = Vector3.new(0, 0, -90)
	TorsoA.Axis = Vector3.new(0, -1, 0)
	TorsoA.SecondaryAxis = Vector3.new(1, 0, 0)

	local TorsoA1 = Instance.new("Attachment")
	TorsoA1.Name = "TorsoA1"
	TorsoA1.Parent = torso
	TorsoA1.Position = Vector3.new(-0.4, -1, 0)
	TorsoA1.Rotation = Vector3.new(0, 0, -90)
	TorsoA1.Axis = Vector3.new(0, -1, 0)
	TorsoA1.SecondaryAxis = Vector3.new(1, 0, 0)

	local TorsoA2 = Instance.new("Attachment")
	TorsoA2.Name = "TorsoA2"
	TorsoA2.Parent = torso
	TorsoA2.Position = Vector3.new(-1, 0.8, 0)
	TorsoA2.Rotation = Vector3.new(-0, 0, -0)
	TorsoA2.Axis = Vector3.new(1, -0, 0)
	TorsoA2.SecondaryAxis = Vector3.new(0, 1, -0)

	local TorsoA3 = Instance.new("Attachment")
	TorsoA3.Name = "TorsoA3"
	TorsoA3.Parent = torso
	TorsoA3.Position = Vector3.new(1, 0.8, 0)
	TorsoA3.Rotation = Vector3.new(180, 0, 180)
	TorsoA3.Axis = Vector3.new(-1, -0, 0)
	TorsoA3.SecondaryAxis = Vector3.new(-0, 1, -0)

	local TorsoA4 = Instance.new("Attachment")
	TorsoA4.Name = "TorsoA4"
	TorsoA4.Parent = torso
	TorsoA4.Position = Vector3.new(-0, 1, 0)
	TorsoA4.Rotation = Vector3.new(0, 0, -90)
	TorsoA4.Axis = Vector3.new(0, -1, 0)
	TorsoA4.SecondaryAxis = Vector3.new(1, 0, 0)

	LeftArmA:AddTag("RagdollAttachment")
	RightArmA:AddTag("RagdollAttachment")
	LeftLegA:AddTag("RagdollAttachment")
	RightLegA:AddTag("RagdollAttachment")
	TorsoA:AddTag("RagdollAttachment")
	TorsoA1:AddTag("RagdollAttachment")
	TorsoA2:AddTag("RagdollAttachment")
	TorsoA3:AddTag("RagdollAttachment")
	TorsoA4:AddTag("RagdollAttachment")
	HeadA:AddTag("RagdollAttachment")

	local HA = Instance.new("BallSocketConstraint")
	HA.Parent = ragdollStuff
	HA.Attachment0 = HeadA
	HA.Attachment1 = TorsoA4
	HA.Enabled = true

	local LAT = Instance.new("BallSocketConstraint")
	LAT.Parent = ragdollStuff
	LAT.Attachment0 = LeftArmA
	LAT.Attachment1 = TorsoA2
	LAT.Enabled = true

	local RAT = Instance.new("BallSocketConstraint")
	RAT.Parent = ragdollStuff
	RAT.Attachment0 = RightArmA
	RAT.Attachment1 = TorsoA3
	RAT.Enabled = true

	local TLL = Instance.new("BallSocketConstraint")
	TLL.Parent = ragdollStuff
	TLL.Attachment0 = TorsoA1
	TLL.Attachment1 = LeftLegA
	TLL.Enabled = true

	local TRL = Instance.new("BallSocketConstraint")
	TRL.Parent = ragdollStuff
	TRL.Attachment0 = TorsoA
	TRL.Attachment1 = RightLegA
	TRL.Enabled = true
end

function RagdollModule:Ragdoll(char: Model)
	if char ~= nil and not char:HasTag("RagdolledBody") then
		local humanoid = char:FindFirstChild("Humanoid") :: Humanoid
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false

		local plr = Players:GetPlayerFromCharacter(char)

		local Torso = char:FindFirstChild("Torso")
		local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		for i, v in Torso:GetChildren() do
			if v:IsA("Motor6D") or v:IsA("Snap") or v:IsA("Weld") then
				v.Enabled = false
				-- createColliderPart(v.Part1)
			end
		end

		local TempWeld = Utilities:Weld(HumanoidRootPart, Torso, CFrame.new())
		TempWeld.Name = "RAGDOLL_WELD"
		HumanoidRootPart.RootJoint.Enabled = false
		HumanoidRootPart.RootJoint.Enabled = true
		TempWeld:Destroy()

		local Tool = char:FindFirstChildWhichIsA("Tool")
		if Tool then
			Tool.Parent = plr.Backpack
		end

		-- for i, v in char:GetChildren() do
		-- 	if v:IsA("BasePart") then
		-- 		--v.CollisionGroup = "RagdollPart"
		-- 		v.CanCollide = true
		-- 		if plr then
		-- 			-- v:SetNetworkOwner(plr)
		-- 		else
		-- 			-- v:SetNetworkOwner(nil)
		-- 		end
		-- 	end
		-- end
		char:AddTag("RagdolledBody")

		--char.Parent = workspace
	end
end

function RagdollModule:Unragdoll(char: Model)
	if char ~= nil then
		local humanoid = char:FindFirstChild("Humanoid") :: Humanoid
		humanoid.AutoRotate = true
		humanoid.PlatformStand = false

		local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		HumanoidRootPart.RootJoint.Enabled = true
		if HumanoidRootPart:FindFirstChild("RAGDOLL_WELD") then
			HumanoidRootPart:FindFirstChild("RAGDOLL_WELD"):Destroy()
		end

		local Torso = char:FindFirstChild("Torso")
		for i, v in Torso:GetChildren() do
			if v:IsA("Motor6D") or v:IsA("Snap") or v:IsA("Weld") then
				v.Enabled = true
			end
		end

		char:RemoveTag("RagdolledBody")
	end
end

function RagdollModule:Step()
	for i, Character in
		game:GetService("CollectionService"):GetTagged("RagdolledBody")
	do
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
		Humanoid.PlatformStand = true
		Humanoid.AutoRotate = false

		for i, v in Character:GetChildren() do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
				v.CanCollide = false
				v.CanCollide = true
				v.EnableFluidForces = false
			elseif v:IsA("BasePart") then
				v.CanCollide = false
				v.EnableFluidForces = false
			end
		end
	end
end

return RagdollModule
