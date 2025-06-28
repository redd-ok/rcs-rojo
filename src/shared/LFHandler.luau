local Camera = workspace.CurrentCamera
local Util = require(game:GetService("ReplicatedStorage").RCS.Modules.Utilities)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local LFHandler = {}

function LFHandler:UpdateBlindness(Attachment: Attachment)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances =
		{ (Attachment.Parent :: BasePart).Parent }
	params.FilterType = Enum.RaycastFilterType.Exclude
	if Attachment:IsDescendantOf(Camera) then
		params:AddToFilter(Players.LocalPlayer.Character)
	end

	for i, v in Attachment:GetChildren() do
		if v:IsA("BillboardGui") and v.Name == "Blind" then
			v.Enabled = v:HasTag("IR") and Util:HasNightvisionOn()
				or not v:HasTag("IR")
			if v:HasTag("IR") and not Util:HasNightvisionOn() then
				return
			end

			local ray = workspace:Raycast(
				Attachment.WorldPosition,
				Camera.CFrame.Position - Attachment.WorldPosition,
				params
			)
			while
				ray
				and ray.Instance.Transparency
						+ ray.Instance.LocalTransparencyModifier
					> 0
			do
				params:AddToFilter(ray.Instance)
				ray = workspace:Raycast(
					Attachment.WorldPosition,
					Camera.CFrame.Position - Attachment.WorldPosition,
					params
				)
			end

			if not ray then
				local anglemax = v.Angle.Value
				local sizemax = v.MaxSize.Value

				local a, b =
					CFrame.new(Attachment.WorldPosition, Camera.CFrame.Position).LookVector,
					Attachment.WorldCFrame.LookVector

				local angle = math.deg(math.acos(a:Dot(b)))

				if angle <= anglemax then
					local sizeuse = Util:Lerp(sizemax, 0, angle / anglemax)

					local distance = (
						Camera.CFrame.Position - Attachment.WorldPosition
					).Magnitude / 2.8
					local intensity = 1 / (distance ^ 2) * 100

					if v:FindFirstChild("IgnoreShrink") then
						intensity = math.max(intensity, 1)
					end

					if v:FindFirstChild("IgnoreGrow") then
						intensity = math.min(intensity, 1)
					end

					v.Size = UDim2.new(
						sizeuse * intensity,
						0,
						sizeuse * intensity,
						0
					)
				else
					v.Size = UDim2.new()
				end
			else
				v.Size = UDim2.new()
			end
		end
	end
end

function LFHandler:UpdateLaser(Part: BasePart, Active: boolean, IR: boolean)
	if Active and IR then
		if not Util:HasNightvisionOn() then
			Active = false
		end
	end

	local Main = Part:FindFirstChild("MainAtt") :: Attachment?
	if Main and Main:FindFirstChild("Blind") and Active then
		LFHandler:UpdateBlindness(Main)
	end

	local Goal = Part:FindFirstChild("GoalAtt") :: Attachment?
	if Main and Goal then
		local MotionBlur = Part:FindFirstChild("MotionBlurBeam") :: Beam?
		if MotionBlur then
			MotionBlur.Enabled = if MotionBlur:HasTag("IR")
				then Util:HasNightvisionOn() and Active
				else Active
		end

		for i, v in Main:GetChildren() do
			if v:IsA("Light") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			elseif v:IsA("Beam") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			elseif v:IsA("ParticleEmitter") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			elseif v:IsA("BillboardGui") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			end
		end

		for i, v in Goal:GetChildren() do
			if v:IsA("Light") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			elseif v:IsA("Beam") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			elseif v:IsA("ParticleEmitter") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			elseif v:IsA("BillboardGui") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			end
		end

		if Active then
			local Params = RaycastParams.new()
			Params.FilterDescendantsInstances = { Main.Parent }
			if Main:IsDescendantOf(Camera) then
				Params:AddToFilter(Players.LocalPlayer.Character)
			end
			Params.FilterType = Enum.RaycastFilterType.Exclude
			local ray = workspace:Raycast(
				Main.WorldPosition,
				Main.WorldCFrame.LookVector * 999,
				Params
			)
			while ray and ray.Instance.Transparency > 0 do
				Params:AddToFilter(ray.Instance)
				ray = workspace:Raycast(
					Main.WorldPosition,
					Main.WorldCFrame.LookVector * 999,
					Params
				)
			end

			if ray then
				local hit = CFrame.new(
					ray.Position - Camera.CFrame.LookVector,
					ray.Position + ray.Normal
				)

				Goal.WorldCFrame = hit
				if MotionBlur then
					local Goal2 = MotionBlur.Attachment1

					if not Goal2:GetAttribute("LastCF") then
						Goal2.WorldCFrame = hit
					else
						Goal2.WorldPosition = Camera.CFrame
							* Goal2:GetAttribute("LastCF")
					end

					Goal2:SetAttribute(
						"LastCF",
						Camera.CFrame:PointToObjectSpace(hit.Position)
					)
				end
			else
				Goal.WorldPosition = Main.WorldPosition
					+ (Main.WorldCFrame.LookVector * 999)

				if MotionBlur then
					local Goal2 = MotionBlur.Attachment1
					Goal2.WorldPosition = Main.WorldPosition
						+ (Main.WorldCFrame.LookVector * 999)

					Goal2:SetAttribute("LastCF", nil)
				end
			end
		else
			Goal.WorldPosition = Vector3.new(9e9, 9e9, 9e9)
			if MotionBlur then
				local Goal2 = MotionBlur.Attachment1
				Goal2.WorldPosition = Vector3.new(9e9, 9e9, 9e9)
			end
		end
	end
end

function LFHandler:UpdateFlashlight(
	Part: BasePart,
	Active: boolean,
	IR: boolean
)
	if Active and IR then
		if not Util:HasNightvisionOn() then
			Active = false
		end
	end

	local Main = Part:FindFirstChild("MainAtt") :: Attachment
	if Main and Main:FindFirstChild("Blind") then
		if Active then
			LFHandler:UpdateBlindness(Main)
		else
			for i, v in Main:GetChildren() do
				if v:IsA("BillboardGui") and v.Name == "Blind" then
					v.Enabled = false
				end
			end
		end
	end

	if Main then
		for i, v in Main:GetChildren() do
			if v:IsA("Light") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			elseif v:IsA("Beam") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			elseif v:IsA("ParticleEmitter") then
				v.Enabled = if v:HasTag("IR")
					then Util:HasNightvisionOn() and Active
					else Active
			end
		end
	end
end

function LFHandler:Update()
	for i, v in CollectionService:GetTagged("LaserPart") do
		if not v:IsDescendantOf(Players.LocalPlayer.Character) then
			LFHandler:UpdateLaser(
				v,
				v:GetAttribute("Active"),
				v:GetAttribute("IR")
			)
		end
	end

	for i, v in CollectionService:GetTagged("FlashPart") do
		if not v:IsDescendantOf(Players.LocalPlayer.Character) then
			LFHandler:UpdateFlashlight(
				v,
				v:GetAttribute("Active"),
				v:GetAttribute("IR")
			)
		end
	end
end

return LFHandler
