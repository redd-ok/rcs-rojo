local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RCS = ReplicatedStorage.RCS

local Types = require(RCS:WaitForChild("Types"))

local Stance = {}

function Stance:AnimateCharacterStance(
	character: Model,
	characterStance: Types.CharacterStance,
	leaningState: Types.LeaningState,
	sprinting: boolean,
	gunStance: Types.GunStance?
): ()
	character:SetAttribute("REPL_Sprinting", sprinting)
	local lastCharacterStance = character:GetAttribute("REPL_LastCharStance")

	if lastCharacterStance ~= characterStance .. "&" .. leaningState then
		character:SetAttribute(characterStance .. "&" .. leaningState)
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
				:Create(RootJoint, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					C1 = CFrame.new(0, 1.5, 2.45)
						* CFrame.Angles(math.rad(0), math.rad(0), math.rad(180)),
				})
				:Play()
			TweenService
				:Create(RH, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					C1 = CFrame.new(0.5, 1, 0)
						* CFrame.Angles(math.rad(-5), math.rad(90), math.rad(0)),
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
				TweenService
					:Create(
						RootJoint,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{
							C1 = CFrame.new(-1, -0, 0) * CFrame.Angles(
								math.rad(-90),
								math.rad(-15),
								math.rad(-180)
							),
						}
					)
					:Play()
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
							C1 = CFrame.new(-1, 0.75, 0.25) * CFrame.Angles(
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
				TweenService
					:Create(
						RootJoint,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{
							C1 = CFrame.new(1, 0, 0) * CFrame.Angles(
								math.rad(-90),
								math.rad(15),
								math.rad(180)
							),
						}
					)
					:Play()
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
				TweenService
					:Create(
						RootJoint,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{
							C1 = CFrame.new(0, 0, 0) * CFrame.Angles(
								math.rad(-90),
								math.rad(0),
								math.rad(180)
							),
						}
					)
					:Play()
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
							C1 = CFrame.new(0, 1, 0.25) * CFrame.Angles(
								math.rad(-80),
								math.rad(0),
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
		end
	end
end

return Stance
