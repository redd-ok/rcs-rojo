local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Engine = game:GetService("ReplicatedStorage"):WaitForChild("RCS")

local CurrentCamera = workspace.CurrentCamera

local Config = require(Engine:WaitForChild("RCS_Config"))

local ClientNetwork = require(Engine:WaitForChild("ClientNetwork"))

local Modules = Engine:WaitForChild("Modules")
local GunModels = Engine:WaitForChild("GunModels")
local Animations = Engine:WaitForChild("Animations")

local Utilities = require(Modules:WaitForChild("Utilities"))
local LFHandler = require(Modules:WaitForChild("LFHandler"))
local Attachments = require(Modules:WaitForChild("Attachments"))

script:WaitForChild("modules")
local States = require(script.modules:WaitForChild("states"))
local Springs = require(script.modules:WaitForChild("springs"))
local Variables = require(script.modules:WaitForChild("variables"))
local Functions = require(script.modules:WaitForChild("misc"))
local Inputs = require(script.modules:WaitForChild("inputs"))

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart: BasePart & { RootJoint: Motor6D } =
	Character:FindFirstChild("HumanoidRootPart")

local Hud = LocalPlayer.PlayerGui.RCS_Hud

local function Equip(Tool: Tool)
	if Humanoid.Health <= 0 then
		return
	end

	UserInputService.MouseIconEnabled = false
	LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

	Variables.WeaponTool = Tool
	Variables.WeaponData = require(Tool:FindFirstChild("RCS_Settings"))
	Variables.AnimData =
		require(Animations:FindFirstChild(Tool:GetAttribute("Animations")))

	-- i love strict luau
	if
		not Variables.AnimData
		or not Variables.WeaponData
		or not Variables.WeaponTool
	then
		warn("how the hellll?")
		return
	end

	Variables.WeaponInHand = GunModels:FindFirstChild(Tool.Name):Clone()
	if not Variables.WeaponInHand then
		warn("how the hell?")
		return
	end
	Variables.WeaponInHand.PrimaryPart = Variables.WeaponInHand.Handle

	Variables.Viewmodel = Engine.Arms:Clone()
	if not Variables.Viewmodel then
		warn("how the hell 2?")
		return
	end
	Variables.Viewmodel.Name = "Viewmodel"

	if Character:FindFirstChildWhichIsA("BodyColors") then
		Character:FindFirstChildWhichIsA("BodyColors"):Clone().Parent =
			Variables.Viewmodel
	end

	if Character:FindFirstChildWhichIsA("Shirt") then
		Character:FindFirstChildWhichIsA("Shirt"):Clone().Parent =
			Variables.Viewmodel
	end

	Variables.AnimPart = Instance.new("Part", Variables.Viewmodel)
	if not Variables.AnimPart then
		warn("how the hell 3?")
		return
	end
	Variables.AnimPart.Size = Vector3.new(0.1, 0.1, 0.1)
	Variables.AnimPart.Anchored = true
	Variables.AnimPart.CanCollide = false
	Variables.AnimPart.CanQuery = false
	Variables.AnimPart.CanTouch = false
	Variables.AnimPart.Transparency = 1

	Variables.Viewmodel.PrimaryPart = Variables.AnimPart

	Variables.LArmWeld = Instance.new("Motor6D", Variables.AnimPart)
	if not Variables.LArmWeld then
		warn("how the hell 4?")
		return
	end
	Variables.LArmWeld.Name = "LeftArm"
	Variables.LArmWeld.Part0 = Variables.AnimPart

	Variables.RArmWeld = Instance.new("Motor6D", Variables.AnimPart)
	if not Variables.RArmWeld then
		warn("how the hell 5?")
		return
	end
	Variables.RArmWeld.Name = "RightArm"
	Variables.RArmWeld.Part0 = Variables.AnimPart

	Variables.GunWeld = Instance.new("Motor6D", Variables.AnimPart)
	if not Variables.GunWeld then
		warn("how the hell 6?")
		return
	end
	Variables.GunWeld.Name = "Handle"

	Variables.Viewmodel.Parent = workspace.CurrentCamera

	Variables.MainCF = Variables.AnimData.MainCFrame

	Variables.LArm = Variables.Viewmodel:FindFirstChild("Left Arm") :: BasePart
	if not Variables.LArm then
		warn("this should be impossible")
		return
	end
	Variables.LArmWeld.Part1 = Variables.LArm
	Variables.LArmWeld.C0 = CFrame.new()
	Variables.LArmWeld.C1 = CFrame.new(1, -1, -5)
		* CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)):Inverse()

	Variables.RArm = Variables.Viewmodel:FindFirstChild("Right Arm") :: BasePart
	if not Variables.RArm then
		warn("this should be impossible x2")
		return
	end
	Variables.RArmWeld.Part1 = Variables.RArm
	Variables.RArmWeld.C0 = CFrame.new()
	Variables.RArmWeld.C1 = CFrame.new(-1, -1, -5)
		* CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)):Inverse()
	Variables.GunWeld.Part0 = Variables.RArm

	Variables.LArm.Anchored = false
	Variables.RArm.Anchored = false

	States.gunState.AmmoInGun = Variables.WeaponData.AmmoInGun
	States.gunState.StoredAmmo = Variables.WeaponData.StoredAmmo
	States.gunState.Aimpart = 1
	States.gunState.Sens = Tool:GetAttribute("Sens") :: number or 50

	if Variables.WeaponInHand:FindFirstChild("AttachmentPoints") then
		local attachmentPoints =
			Variables.WeaponInHand:FindFirstChild("AttachmentPoints")
		for i, v in attachmentPoints:GetChildren() do
			if not v:IsA("BasePart") then
				continue
			end

			Utilities:Weld(Variables.WeaponInHand.Handle, v)
		end

		if Variables.WeaponData.Attachments then
			for attPoint, att in Variables.WeaponData.Attachments do
				if attachmentPoints:FindFirstChild(attPoint) then
					local attachmentPoint =
						attachmentPoints:FindFirstChild(attPoint)

					local model = Attachments:BuildAttachmentModel(att)
					model.Parent = attachmentPoint

					Utilities:Weld(
						attachmentPoint,
						model.PrimaryPart,
						CFrame.new()
					)
				end
			end
		end
	end

	for _, part in Variables.WeaponInHand:GetChildren() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false

			if part.Name == "Handle" or part:GetAttribute("DontWeld") then
				continue
			end

			if
				part.Name ~= "Bolt"
				and part.Name ~= "Lid"
				and part.Name ~= "Slide"
			then
				Utilities:Weld(Variables.WeaponInHand.Handle, part)
			end

			if part.Name == "Bolt" or part.Name == "Slide" then
				Utilities:WeldComplex(
					Variables.WeaponInHand.Handle,
					part,
					part.Name
				)
			end

			if part.Name == "Lid" then
				local lidHinge = Variables.WeaponInHand:FindFirstChild(
					"LidHinge"
				) :: BasePart
				if lidHinge then
					Utilities:Weld(part, lidHinge)
				else
					Utilities:Weld(part, Variables.WeaponInHand.Handle)
				end
			end
		end
	end

	Variables.GunWeld.Part1 = Variables.WeaponInHand.Handle
	Variables.GunWeld.C1 = Variables.AnimData.GunCFrame

	-- Network.Events.Equip:ser(Network.Client, Tool)
	ClientNetwork.WeaponEvents.Equip.fire(Tool)

	Variables.WeaponInHand.Parent = Variables.Viewmodel

	if not Variables.WeaponData.Chambered then
		Variables.WeaponInHand.Handle.Slide.C0 =
			Variables.WeaponData.SlideEx:Inverse()
	end

	States.gunState.LaserActive =
		not not Variables.WeaponTool:GetAttribute("LaserActive")
	States.gunState.FlashlightActive =
		not not Variables.WeaponTool:GetAttribute("FlashlightActive")
	for i, v in Variables.WeaponInHand:GetChildren() do
		if v:HasTag("LaserPart") then
			v:SetAttribute("Active", States.gunState.LaserActive)
		elseif v:HasTag("FlashPart") then
			v:SetAttribute("Active", States.gunState.FlashlightActive)
		end
	end

	if Variables.AnimData.AttachmentToggle then
		task.spawn(
			Variables.AnimData.AttachmentToggle,
			Functions.GetAnimObjs(),
			true,
			false
		)
		task.spawn(
			Variables.AnimData.AttachmentToggle,
			Functions.GetAnimObjs(),
			false,
			false
		)
	end
	if Variables.AnimData.SwitchAimPart then
		task.spawn(
			Variables.AnimData.SwitchAimPart,
			Functions.GetAnimObjs(),
			false
		)
	end
	if Variables.AnimData.VariableZoom then
		task.spawn(
			Variables.AnimData.VariableZoom,
			Functions.GetAnimObjs(),
			false
		)
	end

	ClientNetwork.WeaponEvents.ToggleAttachment.fire({
		laser = true,
		active = States.gunState.LaserActive,
	})
	ClientNetwork.WeaponEvents.ToggleAttachment.fire({
		laser = false,
		active = States.gunState.FlashlightActive,
	})

	Functions.PlaySFX("Equip")
	Functions.PlaySFX(
		if Variables.WeaponData.Type == "Rifle"
			then "RifleFoley"
			else "PistolFoley"
	)
	Variables.AnimData.EquipAnim(Functions.GetAnimObjs())

	Functions.RunCheck()
end

function Unequip()
	if
		not Variables.WeaponTool
		or not Variables.Viewmodel
		or not Variables.WeaponData
	then
		warn("wth?? tried unequipping twice?")
		return
	end
	Variables.WeaponTool:SetAttribute("Sens", States.gunState.Sens)
	Variables.WeaponTool:SetAttribute("ZoomMode", States.gunState.ZoomMode)
	Variables.WeaponTool:SetAttribute(
		"LaserActive",
		States.gunState.LaserActive
	)
	Variables.WeaponTool:SetAttribute(
		"FlashlightActive",
		States.gunState.FlashlightActive
	)

	States.gunState = table.clone(States.defaultGunState)

	UserInputService.MouseIconEnabled = true
	LocalPlayer.CameraMode = Enum.CameraMode.Classic
	CurrentCamera.FieldOfView = 70
	UserInputService.MouseDeltaSensitivity = 1

	Variables.Viewmodel:Destroy()

	Variables.Viewmodel = nil
	Variables.WeaponInHand = nil
	Variables.AnimPart = nil
	Variables.LArmWeld = nil
	Variables.LArm = nil
	Variables.RArmWeld = nil
	Variables.RArm = nil
	Variables.GunWeld = nil

	Functions.PlaySFX("Unequip")
	Functions.PlaySFX(
		if Variables.WeaponData.Type == "Rifle"
			then "RifleFoley"
			else "PistolFoley"
	)

	ClientNetwork.WeaponEvents.Unequip.fire()
end

Character.ChildAdded:Connect(function(ch)
	if
		ch:IsA("Tool")
		and ch:FindFirstChild("RCS_Settings")
		and Humanoid.Health > 0
		and not Character:HasTag("RagdolledBody")
	then
		task.spawn(Equip, ch)

		while ch.AncestryChanged:Wait() do
			if
				ch.Parent ~= Character
				and Variables.WeaponInHand
				and Variables.Viewmodel
			then
				Unequip()
				break
			end
		end
	end
end)

Humanoid.Died:Connect(function()
	if Variables.WeaponInHand and Variables.Viewmodel then
		Unequip()
	end
end)

UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
	if not gameProcessed then
		for i, v in Config.Keybinds do
			if inputObject.KeyCode == v or inputObject.UserInputType == v then
				Inputs[i](inputObject, "began")
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(inputObject, gameProcessed)
	if not gameProcessed then
		for i, v in Config.Keybinds do
			if inputObject.KeyCode == v or inputObject.UserInputType == v then
				Inputs[i](inputObject, "ended")
			end
		end
	end
end)

UserInputService.InputChanged:Connect(function(inputObject, gameProcessed)
	if not gameProcessed then
		for i, v in Config.Keybinds do
			if inputObject.KeyCode == v or inputObject.UserInputType == v then
				Inputs[i](inputObject, "changed")
			end
		end
	end
end)

local recoil = Vector3.new()

local timePassedSinceHeadRotationUpdate = 0
local timePassedSinceIndoorsCheck = 0
local firstRender = true
RunService.RenderStepped:Connect(function(deltaTime)
	timePassedSinceHeadRotationUpdate += deltaTime
	if not HumanoidRootPart:FindFirstChild("RootJoint") then
		return
	end

	local c: CFrame = HumanoidRootPart.RootJoint.C1
	local rX, rY, _rZ = c:ToOrientation()
	local bodyAngle = (rX + (math.pi / 2)) * (rY / (math.pi / 2))

	if
		Variables.Viewmodel
		and Variables.WeaponInHand
		and Variables.WeaponData
		and Variables.AnimPart
		and Variables.AnimData
	then
		local FOV_GunOffset = (70 / CurrentCamera.FieldOfView) ^ (1 / 2)
		-- print(FOV_GunOffset)

		local RecoilXPos = Springs.RecoilX.p / FOV_GunOffset
		local RecoilYPos = Springs.RecoilY.p / FOV_GunOffset
		local RecoilZPos = Springs.RecoilZ.p / FOV_GunOffset
		local RecoilKickPos = Springs.RecoilKick.p / FOV_GunOffset
		local CameraRecoilPos = Springs.CamRecoil.p
			* ((CurrentCamera.FieldOfView / 70) ^ (1 / 2))
		-- / FOV_GunOffset

		local RecoilCFrame
		if Variables.WeaponData.Type == "Rifle" then
			RecoilCFrame = CFrame.new(
				(-RecoilXPos / 1.5),
				(RecoilYPos / 4),
				RecoilKickPos * 1.85
			) * CFrame.Angles(
				(RecoilYPos * 2.5),
				RecoilXPos,
				(RecoilZPos * 2)
			) * CFrame.new(
				-RecoilXPos,
				(RecoilYPos / 4),
				RecoilKickPos * 1.5
			)
		else
			RecoilCFrame = CFrame.new(
				-RecoilXPos,
				(-RecoilYPos / 2),
				RecoilKickPos * 1.5
			) * CFrame.Angles(
				(RecoilYPos * 3),
				(RecoilXPos * 2),
				(RecoilZPos * 1.5)
			) * CFrame.new(
				(-RecoilXPos * 2),
				-RecoilYPos / 2,
				RecoilKickPos * 1.5
			)
		end

		Springs.StaminaSwaySpring.a = Vector2.new(
			Utilities:Random(-1, 1),
			Utilities:Random(-1, 1)
		) * (1 - ((0.4 * (States.characterState.Stamina / 100)) + (0.55 * (States.characterState.ArmStamina / 100))))
		Springs.StaminaSwaySpring.s = 6
			+ 18
				* (1 - ((0.45 * (States.characterState.Stamina / 100)) + (0.55 * (States.characterState.ArmStamina / 100))))
		local StaminaSwaySpringPosition = Springs.StaminaSwaySpring.p
			/ FOV_GunOffset
		local StaminaSway = CFrame.Angles(
			math.rad(StaminaSwaySpringPosition.Y),
			math.rad(StaminaSwaySpringPosition.X),
			0
		)

		local gunShake = Springs.GunShake.p / FOV_GunOffset
		-- if gunShake.Magnitude < 0.1 then
		--     gunShake = Vector3.new()
		-- end
		local CameraRecoil = CFrame.Angles(
			math.rad(gunShake.Y / FOV_GunOffset) / 2,
			math.rad(gunShake.X / FOV_GunOffset) / 2,
			math.rad(gunShake.Z / FOV_GunOffset) / 2
		) * CFrame.Angles(
			CameraRecoilPos.X,
			CameraRecoilPos.Y,
			CameraRecoilPos.Z
		)
		if
			Springs.CamRecoil.v:Abs().Magnitude > 0
			and CameraRecoilPos:Abs().Magnitude > 0
		then
			-- recoil -= CameraRecoilPos
		end

		CurrentCamera.CFrame *= CameraRecoil

		local cframe = CurrentCamera.CFrame
			* CFrame.new(0, 0, 1 - FOV_GunOffset)
			* CFrame.Angles(0, 0, bodyAngle / 2)
			* Variables.MainCF
			* CFrame.Angles(recoil.X, recoil.Y, recoil.Z)
			* StaminaSway
			* CFrame.Angles(
				math.rad(gunShake.Y / FOV_GunOffset) * 2,
				math.rad(gunShake.X / FOV_GunOffset) * 2,
				math.rad(gunShake.Z / FOV_GunOffset) * 2
			)
			* CFrame.new(0, 0, -0.28)

		local handle = Variables.WeaponInHand.Handle
		if not workspace:GetAttribute("FREEZE_VIEWMODEL") or firstRender then
			firstRender = false
			Variables.AnimPart.CFrame = Utilities:OffsetFromPivot(
				cframe,
				CFrame.new(handle.AssemblyCenterOfMass) * handle.CFrame.Rotation,
				RecoilCFrame
			)
		end

		local mouseDelta = UserInputService:GetMouseDelta()
			* Vector2.new(1, 0.77)

		if States.gunState.Aiming then
			Springs.DeadzoneSpring.target = Vector2.new()
			Springs.SwaySpring.a = -mouseDelta * 2
		else
			Springs.DeadzoneSpring.target -= mouseDelta / 2
		end
		local deadzoneTarget = Springs.DeadzoneSpring.target
		if deadzoneTarget.Magnitude > 7 then
			Springs.DeadzoneSpring.target = deadzoneTarget.Unit * 7
			Springs.SwaySpring.a = -mouseDelta * 2
		end
		local deadzonePosition = Springs.DeadzoneSpring.p / FOV_GunOffset
		local deadzone = CFrame.new(
			math.rad(-deadzonePosition.X) / 2,
			math.rad(deadzonePosition.Y) / 2,
			0
		) * CFrame.Angles(
			math.rad(deadzonePosition.Y),
			math.rad(deadzonePosition.X),
			0
		)

		local SwayPos = (Springs.SwaySpring.p / FOV_GunOffset) * 2
		local Sway = CFrame.Angles(math.rad(SwayPos.Y), math.rad(SwayPos.X), 0)

		if Humanoid.MoveDirection.Magnitude > 0.1 then
			Springs.Speed.t = Humanoid.WalkSpeed
				* (if States.gunState.Aiming then 0.7 else 0.9)
			Variables.WalkTime += (deltaTime / 0.1666) * (Springs.Speed.p / 17)
		else
			Springs.Speed.t = 0
			Variables.WalkTime = 0
		end

		local MovingTowards = HumanoidRootPart.CFrame:VectorToObjectSpace(
			HumanoidRootPart.AssemblyLinearVelocity
		)

		local currentSpeed = Springs.Speed.p

		local WalkBobPosition = Vector3.new(
			(
				-math.sin(Variables.WalkTime * 2)
				- 0.25 * math.sin(Variables.WalkTime)
			)
				* (currentSpeed / 225)
				* (if States.gunState.Aiming then 0.7 else 0.9),
			(
				math.sin(Variables.WalkTime * 4)
				- math.cos(Variables.WalkTime * 4) / 2
				- 0.25 * math.cos(Variables.WalkTime)
			)
				* (currentSpeed / 225)
				* (if States.gunState.Aiming then 0.7 else 0.9),
			math.clamp(-MovingTowards.Z, -0.1, 0.1)
		) / FOV_GunOffset
		local WalkBobRotation = Vector3.new(
			math.rad(math.cos(Variables.WalkTime * 4) * (currentSpeed / 8)),
			math.rad(math.sin(Variables.WalkTime * 2) * (currentSpeed / 8))
				+ math.rad(-MovingTowards.X / 8),
			math.rad(math.sin(Variables.WalkTime * 2) * (currentSpeed / 6))
				+ math.rad(-MovingTowards.X / 13)
		) / FOV_GunOffset
		local WalkBob = CFrame.new(WalkBobPosition)
			* CFrame.Angles(
				WalkBobRotation.X,
				WalkBobRotation.Y,
				WalkBobRotation.Z
			)
			* CFrame.Angles(
				math.rad((MovingTowards.Y / FOV_GunOffset) / 1.5),
				math.rad((MovingTowards.X / FOV_GunOffset) / 2.5),
				math.rad((MovingTowards.X / FOV_GunOffset) / 2.5)
			)

		if States.gunState.Shooting then
			local outdoorLoop =
				Variables.WeaponInHand.Handle.Muzzle:FindFirstChild("Loop") :: Sound?
			local indoorLoop =
				Variables.WeaponInHand.Handle.Muzzle:FindFirstChild(
					"IndoorLoop"
				) :: Sound?

			if
				outdoorLoop
				and indoorLoop
				and (outdoorLoop.Playing or indoorLoop.Playing)
			then
				timePassedSinceIndoorsCheck += deltaTime

				if timePassedSinceIndoorsCheck > 1 / 5 then
					timePassedSinceIndoorsCheck = 0

					local isIndoors = Utilities:IsIndoors(
						Variables.WeaponInHand.Handle.Muzzle.WorldPosition,
						{
							Character,
							workspace.CurrentCamera,
						}
					)
					if isIndoors and outdoorLoop.Playing then
						outdoorLoop.Playing = false
						indoorLoop.Playing = true
						indoorLoop.TimePosition = (
							outdoorLoop.TimePosition / outdoorLoop.TimeLength
						) * indoorLoop.TimeLength
					elseif not isIndoors and indoorLoop.Playing then
						outdoorLoop.Playing = true
						indoorLoop.Playing = false
						outdoorLoop.TimePosition = (
							indoorLoop.TimePosition / indoorLoop.TimeLength
						) * outdoorLoop.TimeLength
					end
				end
			elseif timePassedSinceIndoorsCheck ~= 0 then
				timePassedSinceIndoorsCheck = 0
			end
		elseif timePassedSinceIndoorsCheck ~= 0 then
			timePassedSinceIndoorsCheck = 0
		end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.IgnoreWater = true
		params:AddToFilter({
			Character,
			CurrentCamera,
			workspace.RCS_Workspace.Client,
			workspace.RCS_Workspace.Server,
		})

		local totalLength = (handle.Muzzle.WorldPosition - handle.Position).Magnitude
			* 1.5
		local result = workspace:Raycast(
			handle.Position,
			(handle.Muzzle.WorldPosition - handle.Position) * 1.5,
			params
		)
		local pushback = CFrame.new(
			0,
			0,
			if result then ((totalLength - result.Distance) * 1.5) + 0.5 else 0
		)
		if result then
			pushback *= CFrame.Angles(
				math.rad(-(1 - (totalLength / result.Distance)) * 45),
				0,
				0
			)
		end

		if
			States.gunState.Aiming
			and (
				result
					and (result.Distance / totalLength) > (if Variables.WeaponData.Type
							== "Rifle"
						then 0.96
						else 0.85)
				or not result
			)
		then
			local aimPartInst = Variables.WeaponInHand:FindFirstChild(
				Variables.WeaponData.Aimparts[States.gunState.Aimpart].AimPartName
			) :: BasePart
			local aimOffset =
				aimPartInst.CFrame:ToObjectSpace(CurrentCamera.CFrame)

			local aimPart =
				Variables.WeaponData.Aimparts[States.gunState.Aimpart]
			local fov = aimPart.FOV

			if aimPart.VariableZoom then
				fov /= aimPart.ZoomModes[aimPart.CurrentZoom]
			end

			CurrentCamera.FieldOfView = Utilities:SmoothLerp(
				CurrentCamera.FieldOfView,
				fov,
				Springs.AimTime.p,
				deltaTime / 0.12
			)

			Variables.MainCF = Utilities:SmoothLerp(
				Variables.MainCF,
				CFrame.new(0, 0, 1 - FOV_GunOffset)
					* CameraRecoil:Inverse()
					* Variables.MainCF
					* Sway
					* WalkBob
					* StaminaSway
					* deadzone
					--* RecoilCFrame

					* pushback
					* aimOffset
					* CFrame.Angles(0, 0, bodyAngle / 2),
				Springs.AimTime.p,
				deltaTime / 0.12
			)

			States.characterState.ArmStamina += Config.Stamina.ArmStaminaGainAimming * deltaTime
		else
			CurrentCamera.FieldOfView = Utilities:SmoothLerp(
				CurrentCamera.FieldOfView,
				70,
				0.55,
				deltaTime / 0.16
			)

			Variables.MainCF = Utilities:SmoothLerp(
				Variables.MainCF,
				Variables.AnimData.MainCFrame
					* Sway
					* WalkBob
					* deadzone
					* pushback, --* RecoilCFrame,
				0.55,
				deltaTime / 0.16
			)

			if States.gunState.GunStance == "Normal" then
				States.characterState.ArmStamina += Config.Stamina.ArmStaminaGainNormal * deltaTime
			elseif States.gunState.GunStance == "Patrol" then
				States.characterState.ArmStamina += Config.Stamina.ArmStaminaGainPatrol * deltaTime
			else
				States.characterState.ArmStamina += (if States.gunState.GunStance
						== "LowReady"
					then Config.Stamina.ArmStaminaGainLowReady
					else Config.Stamina.ArmStaminaGainHighReady) * deltaTime
			end
		end

		for index, Part in pairs(Variables.WeaponInHand:GetChildren()) do
			if Part:IsA("BasePart") and Part.Name == "SightMark" then
				local dist_scale = Part.CFrame:PointToObjectSpace(
					CurrentCamera.CFrame.Position
				) / Part.Size

				for _, img: Instance in Part.SurfaceGui.Border:GetChildren() do
					if img:IsA("ImageLabel") and img:HasTag("SightImage") then
						if img:HasTag("LPVOImage") then
							local aimPart, zoomMode =
								table.unpack(img.Name:split(":"))
							aimPart, zoomMode =
								tonumber(aimPart), tonumber(zoomMode)
							if
								States.gunState.Aimpart == aimPart
								and Variables.WeaponData.Aimparts[States.gunState.Aimpart].VariableZoom
								and Variables.WeaponData.Aimparts[States.gunState.Aimpart].CurrentZoom
									== zoomMode
							then
								img.Visible = true
							else
								img.Visible = false
							end
						end

						local sens = img:GetAttribute("Sens") or 1

						img.Position = UDim2.new(
							0.5 + (dist_scale.X * sens),
							0,
							0.5 - (dist_scale.Y * sens),
							0
						)

						-- if img:HasTag("DontResize") then
						-- 	continue
						-- end
						-- local partSize = Part.Size
						-- img.Size = UDim2.fromScale(
						-- 	(
						-- 		(
						-- 			dist_scale.Z
						-- 			* (CurrentCamera.FieldOfView / 70)
						-- 		) / 1500
						-- 	) * (partSize.Y / partSize.X),
						-- 	(dist_scale.Z * (CurrentCamera.FieldOfView / 70))
						-- 		/ 1500
						-- )
					end
				end
			end
		end

		if
			States.gunState.OverHeat > 0
			and Variables.WeaponInHand.Handle.Muzzle:FindFirstChild("OverHeat")
		then
			States.gunState.OverHeat -= deltaTime

			if States.gunState.OverHeat > 0 then
				Variables.WeaponInHand.Handle.Muzzle.OverHeat.Enabled = true
			else
				Variables.WeaponInHand.Handle.Muzzle.OverHeat.Enabled = false
			end
		end
	else
		firstRender = true
		States.characterState.ArmStamina += Config.Stamina.ArmStaminaGainNoGun * deltaTime
	end

	if States.characterState.Running then
		States.characterState.Stamina += Config.Stamina.StaminaGainSprinting * deltaTime
	elseif States.characterState.Stance == "Prone" then
		States.characterState.Stamina += Config.Stamina.StaminaGainProned * deltaTime * if States.characterState.Moving
			then Config.Stamina.StaminaGainMovingMultiplier
			else 1
	elseif States.characterState.Stance == "Crouched" then
		States.characterState.Stamina += Config.Stamina.StaminaGainCrouched * deltaTime * if States.characterState.Moving
			then Config.Stamina.StaminaGainMovingMultiplier
			else 1
	elseif States.characterState.Stance == "Standing" then
		States.characterState.Stamina += Config.Stamina.StaminaGainStanding * deltaTime * if States.characterState.Moving
			then Config.Stamina.StaminaGainMovingMultiplier
			else 1
	end

	States.characterState.Stamina =
		math.clamp(States.characterState.Stamina, 0, Config.Stamina.MaxStamina)
	States.characterState.ArmStamina = math.clamp(
		States.characterState.ArmStamina,
		0,
		Config.Stamina.MaxArmStamina
	)

	local Torso = Character:FindFirstChild("Torso")
	if Torso then
		local Neck = Torso:FindFirstChild("Neck")
		local CameraDirection = HumanoidRootPart.CFrame:ToObjectSpace(
			CurrentCamera.CFrame
		).LookVector

		local rotation = CFrame.Angles(
			0,
			math.asin(CameraDirection.x) / 1.15,
			0
		) * CFrame.Angles(
			-math.asin(CurrentCamera.CFrame.LookVector.y)
				+ math.asin(Character.Torso.CFrame.lookVector.Y),
			0,
			0
		) * CFrame.Angles(-math.rad(90), 0, math.rad(180))

		Neck.C1 = CFrame.new(0, -0.5, 0) * rotation

		if
			timePassedSinceHeadRotationUpdate
			> Config.Replication_HeadRotationRate
		then
			timePassedSinceHeadRotationUpdate = 0

			ClientNetwork.CharacterEvents.HeadReplication_CTS.fire(rotation)
		end
	end

	Humanoid.CameraOffset =
		Vector3.new(-bodyAngle * 5, -c.Y - (rX + (math.pi / 2)))
	CurrentCamera.CFrame *= CFrame.Angles(0, 0, bodyAngle)

	LFHandler:Update()

	if Variables.SensTextTimeLeft > 0 then
		Variables.SensTextTimeLeft -= deltaTime

		if Variables.SensTextTimeLeft <= 0 then
			TweenService:Create(
				Hud.GunUI.Sens,
				TweenInfo.new(
					0.5,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out
				),
				{
					TextTransparency = 1,
				}
			):Play()
		end
	end
end)

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
