local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Engine = ReplicatedStorage.RCS

local Config = require(Engine.RCS_Config)

local ClientNetwork = require(Engine:WaitForChild("ClientNetwork"))

local States = require(script.Parent.states)
local Springs = require(script.Parent.springs)
local Variables = require(script.Parent.variables)
local Misc = require(script.Parent.misc)

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

local Hud = LocalPlayer.PlayerGui:WaitForChild("RCS_Hud")

local Inputs: {
	[string]: (
		inputObject: InputObject,
		inputState: "began" | "ended" | "changed"
	) -> nil,
} =
	{
		Aim = function(inputObject, inputState)
			if
				not Variables.Viewmodel
				or not Variables.WeaponInHand
				or not Variables.WeaponData
				or States.characterState.Running
				or inputState == "changed"
				or Config.ToggleAim and inputState == "ended"
				or States.gunState.GunStance == "Patrol"
			then
				return
			end

			States.gunState.GunStance = "Normal"
			Misc.RunCheck()

			Misc.PlaySFX(
				if Variables.WeaponData.Type == "Rifle"
					then "RifleFoley"
					else "PistolFoley"
			)
			if inputState == "began" then
				Misc.PlaySFX("Equip")
			else
				Misc.PlaySFX("Unequip")
			end

			States.gunState.Aiming = if Config.ToggleAim
				then not States.gunState.Aiming
				else inputState == "began"
			Misc.ADSMesh()
			Misc.Shake(0.8)

			if States.gunState.Aiming then
				UserInputService.MouseDeltaSensitivity = States.gunState.Sens
					/ 100
			else
				UserInputService.MouseDeltaSensitivity = 1
			end

			Springs.AimTime.p = 0
			Springs.AimTime.t = if inputState == "began" then 0.52 else 0
		end,
		Shoot = function(inputObject, inputState)
			if
				not Variables.Viewmodel
				or not Variables.WeaponInHand
				or not Variables.WeaponData
				or States.characterState.Running
				or States.gunState.Reloading
				or inputState == "changed"
				or States.gunState.GunStance ~= "Normal"
			then
				return
			end

			if States.gunState.ShootDelay and inputState == "began" then
				return
			elseif not Variables.WeaponData.Chambered then
				if inputState == "began" then
					Misc.Shake(2)
					Misc.PlaySFX("Trigger")
				end
				return
			end

			if Variables.WeaponData.Firemode == 3 then
				local Shots = 0
				States.gunState.Shooting = inputState == "began"
				Misc.LoopingSounds(States.gunState.Shooting)

				while
					States.gunState.Shooting and Variables.WeaponData.Chambered
				do
					Shots += 1
					ClientNetwork.WeaponEvents.SetShots.fire(Shots)
					Misc.doShoot()
				end

				if
					States.gunState.Shooting
					and not Variables.WeaponData.Chambered
				then
					Misc.LoopingSounds(false)
				end

				States.gunState.Shooting = false
				Misc.Shake(1)
			elseif
				Variables.WeaponData.Firemode == 2 and inputState == "began"
			then
				local Shots = 0
				Misc.LoopingSounds(true)
				for _ = 1, Variables.WeaponData.BurstShot do
					Shots += 1
					ClientNetwork.WeaponEvents.SetShots.fire(Shots)
					Misc.doShoot()
				end
					Misc.LoopingSounds(false)
			elseif inputState == "began" then
				Misc.LoopingSounds(true)
				task.delay((60 / Variables.WeaponData.ShootRate), function()
					Misc.LoopingSounds(false)
				end)
				Misc.doShoot()
				ClientNetwork.WeaponEvents.SetShots.fire(1)
				-- Misc.LoopingSounds(false)
			end
		end,

		CycleFiremode = function(inputObject, inputState)
			if
				not Variables.Viewmodel
				or not Variables.WeaponInHand
				or not Variables.WeaponData
				or inputState ~= "began"
				or States.gunState.Shooting
			then
				return
			end

			if Variables.WeaponData.Firemodes.ChangeFiremode then
				if Variables.WeaponData.Firemode == 1 then
					if Variables.WeaponData.Firemodes.Burst then
						Variables.WeaponData.Firemode = 2
					elseif Variables.WeaponData.Firemodes.Auto then
						Variables.WeaponData.Firemode = 3
					end
				elseif Variables.WeaponData.Firemode == 2 then
					if Variables.WeaponData.Firemodes.Auto then
						Variables.WeaponData.Firemode = 3
					elseif Variables.WeaponData.Firemodes.Semi then
						Variables.WeaponData.Firemode = 1
					end
				elseif Variables.WeaponData.Firemode == 3 then
					if Variables.WeaponData.Firemodes.Semi then
						Variables.WeaponData.Firemode = 1
					end
				end
				Misc.Shake(1.5)
				Misc.PlaySFX("FireSelector")
			end
		end,
		CycleZoomMode = function(inputObject, inputState)
			if
				not Variables.Viewmodel
				or not Variables.WeaponInHand
				or not Variables.WeaponData
				or not Variables.AnimData
				or inputState ~= "began"
			then
				return
			end

			local aimPart =
				Variables.WeaponData.Aimparts[States.gunState.Aimpart]
			if aimPart.VariableZoom then
				if aimPart.ZoomModes[aimPart.CurrentZoom + 1] then
					aimPart.CurrentZoom += 1

					Misc.Shake(0.8)
					Misc.PlaySFX("TacticalSwitch")
					Misc.PlaySFX(
						if Variables.WeaponData.Type == "Rifle"
							then "RifleFoley"
							else "PistolFoley"
					)
					if Variables.AnimData.VariableZoom then
						Variables.AnimData.VariableZoom(
							Misc.GetAnimObjs(),
							true
						)
					end
				else
					aimPart.CurrentZoom = 1

					Misc.Shake(0.8)
					Misc.PlaySFX("TacticalSwitch")
					Misc.PlaySFX(
						if Variables.WeaponData.Type == "Rifle"
							then "RifleFoley"
							else "PistolFoley"
					)
					if Variables.AnimData.VariableZoom then
						Variables.AnimData.VariableZoom(
							Misc.GetAnimObjs(),
							true
						)
					end
				end
			end
		end,
		CycleAimpart = function(inputObject, inputState)
			if
				not Variables.Viewmodel
				or not Variables.WeaponInHand
				or not Variables.WeaponData
				or not Variables.AnimData
				or inputState ~= "began"
			then
				return
			end

			if Variables.WeaponData.Aimparts[States.gunState.Aimpart + 1] then
				States.gunState.Aimpart += 1
				Springs.AimTime.p = 0
				Misc.Shake(0.8)

				Misc.PlaySFX(
					if Variables.WeaponData.Type == "Rifle"
						then "RifleFoley"
						else "PistolFoley"
				)

				Misc.ADSMesh()
				if Variables.AnimData.SwitchAimPart then
					Variables.AnimData.SwitchAimPart(Misc.GetAnimObjs(), true)
				end
			elseif States.gunState.Aimpart ~= 1 then
				States.gunState.Aimpart = 1
				Springs.AimTime.p = 0
				Misc.Shake(0.8)

				Misc.PlaySFX(
					if Variables.WeaponData.Type == "Rifle"
						then "RifleFoley"
						else "PistolFoley"
				)
				Misc.ADSMesh()
				if Variables.AnimData.SwitchAimPart then
					Variables.AnimData.SwitchAimPart(Misc.GetAnimObjs(), true)
				end
			end
		end,

		ToggleLaser = function(inputObject, inputState)
			if
				Variables.Viewmodel
				and Variables.WeaponInHand
				and Variables.WeaponData
				and Variables.AnimData
				and inputState == "began"
			then
				local partsExist = false

				for i, v in Variables.WeaponInHand:GetChildren() do
					if v:HasTag("LaserPart") then
						v:SetAttribute(
							"Active",
							not States.gunState.LaserActive
						)
						partsExist = true
					end
				end

				if partsExist then
					States.gunState.LaserActive =
						not States.gunState.LaserActive
					ClientNetwork.WeaponEvents.ToggleAttachment.fire({
						laser = true,
						active = States.gunState.LaserActive,
					})

					Misc.Shake(0.8)
					Misc.PlaySFX("TacticalSwitch")
					Misc.PlaySFX(
						if Variables.WeaponData.Type == "Rifle"
							then "RifleFoley"
							else "PistolFoley"
					)
					if Variables.AnimData.AttachmentToggle then
						Variables.AnimData.AttachmentToggle(
							Misc.GetAnimObjs(),
							true,
							true
						)
					end
				end
			end
		end,
		ToggleFlashlight = function(inputObject, inputState)
			if
				Variables.Viewmodel
				and Variables.WeaponInHand
				and Variables.WeaponData
				and Variables.AnimData
				and inputState == "began"
			then
				local partsExist = false

				for i, v in Variables.WeaponInHand:GetChildren() do
					if v:HasTag("FlashPart") then
						v:SetAttribute(
							"Active",
							not States.gunState.FlashlightActive
						)
						partsExist = true
					end
				end

				if partsExist then
					States.gunState.FlashlightActive =
						not States.gunState.FlashlightActive
					ClientNetwork.WeaponEvents.ToggleAttachment.fire({
						laser = false,
						active = States.gunState.FlashlightActive,
					})

					Misc.Shake(0.8)
					Misc.PlaySFX("TacticalSwitch")
					Misc.PlaySFX(
						if Variables.WeaponData.Type == "Rifle"
							then "RifleFoley"
							else "PistolFoley"
					)
					if Variables.AnimData.AttachmentToggle then
						Variables.AnimData.AttachmentToggle(
							Misc.GetAnimObjs(),
							false,
							true
						)
					end
				end
			end
		end,

		Reload = function(inputObject, inputState)
			if
				not Variables.Viewmodel
				or not Variables.WeaponInHand
				or not Variables.WeaponData
				or not Variables.AnimData
				or inputState ~= "began"
				or States.characterState.Running
				or States.gunState.Reloading
				or States.gunState.Shooting
				or States.gunState.GunStance ~= "Normal"
				or Variables.WeaponData.AmmoInGun >= Variables.WeaponData.Ammo
				or Variables.WeaponData.StoredAmmo <= 0
			then
				return
			end

			States.gunState.Reloading = true
			if not Variables.WeaponData.Chambered then
				Variables.AnimData.TacticalReloadAnim(Misc.GetAnimObjs())
				Variables.WeaponData.Chambered = true
			else
				Variables.AnimData.ReloadAnim(Misc.GetAnimObjs())
			end

			Misc.PlaySFX(
				if Variables.WeaponData.Type == "Rifle"
					then "RifleFoley"
					else "PistolFoley"
			)

			local c = math.min(
				Variables.WeaponData.StoredAmmo,
				Variables.WeaponData.Ammo
			) - Variables.WeaponData.AmmoInGun
			Variables.WeaponData.AmmoInGun += c
			Variables.WeaponData.StoredAmmo -= c

			States.gunState.Reloading = false
			Misc.RunCheck()
		end,
		Bolt = function(inputObject, inputState)
			if
				not Variables.Viewmodel
				or not Variables.WeaponInHand
				or not Variables.WeaponData
				or not Variables.AnimData
				or inputState ~= "began"
				or States.characterState.Running
				or States.gunState.Reloading
				or States.gunState.Shooting
				or States.gunState.GunStance ~= "Normal"
			then
				return
			end

			Variables.AnimData.BoltAnim(Misc.GetAnimObjs())
			if Variables.WeaponData.AmmoInGun > 0 then
				Variables.WeaponData.Chambered = true
				Variables.WeaponData.AmmoInGun -= 1
			end
			Misc.RunCheck()
		end,

		Sprint = function(inputObject, inputState)
			if
				Variables.WeaponData and States.gunState.Aiming
				or inputState == "changed"
				or States.characterState.Stance == "Prone"
			then
				return
			end

			States.characterState.Stance = "Standing"
			States.characterState.LeaningState = "NotLeaning"
			States.characterState.Running = inputState == "began"

			Misc.UpdateServerStance()

			Humanoid.WalkSpeed = if inputState == "began"
				then Config.Speeds.Sprint
				else Config.Speeds.Walking

			if
				Variables.Viewmodel
				and Variables.WeaponInHand
				and Variables.WeaponData
			then
				Misc.PlaySFX(
					if Variables.WeaponData.Type == "Rifle"
						then "RifleFoley"
						else "PistolFoley"
				)
			end

			Misc.RunCheck()
		end,
		LeanLeft = function(inputObject, inputState)
			if
				inputState ~= "began" and Config.ToggleLean
				or States.characterState.Stance == "Prone"
				or States.characterState.Running
			then
				return
			end

			if
				States.characterState.LeaningState == "Left"
					and Config.ToggleLean
				or not Config.ToggleLean and inputState == "ended"
			then
				States.characterState.LeaningState = "NotLeaning"
			else
				States.characterState.LeaningState = "Left"
			end

			if States.characterState.Stance == "Crouched" then
				Humanoid.WalkSpeed = if States.characterState.LeaningState
						~= "NotLeaning"
					then Config.Speeds.CrouchLeaning
					else Config.Speeds.Crouch
			else
				Humanoid.WalkSpeed = if States.characterState.LeaningState
						~= "NotLeaning"
					then Config.Speeds.Leaning
					else Config.Speeds.Walking
			end

			if
				Variables.Viewmodel
				and Variables.WeaponInHand
				and Variables.WeaponData
			then
				Misc.Shake(0.5)
				Misc.PlaySFX(
					if Variables.WeaponData.Type == "Rifle"
						then "RifleFoley"
						else "PistolFoley"
				)
			end

			Misc.UpdateServerStance()
		end,
		LeanRight = function(inputObject, inputState)
			if
				inputState ~= "began" and Config.ToggleLean
				or States.characterState.Stance == "Prone"
				or States.characterState.Running
			then
				return
			end

			if
				States.characterState.LeaningState == "Right"
					and Config.ToggleLean
				or not Config.ToggleLean and inputState == "ended"
			then
				States.characterState.LeaningState = "NotLeaning"
			else
				States.characterState.LeaningState = "Right"
			end

			if States.characterState.Stance == "Crouched" then
				Humanoid.WalkSpeed = if States.characterState.LeaningState
						~= "NotLeaning"
					then Config.Speeds.CrouchLeaning
					else Config.Speeds.Crouch
			else
				Humanoid.WalkSpeed = if States.characterState.LeaningState
						~= "NotLeaning"
					then Config.Speeds.Leaning
					else Config.Speeds.Walking
			end

			if
				Variables.Viewmodel
				and Variables.WeaponInHand
				and Variables.WeaponData
			then
				Misc.Shake(0.5)
				Misc.PlaySFX(
					if Variables.WeaponData.Type == "Rifle"
						then "RifleFoley"
						else "PistolFoley"
				)
			end

			Misc.UpdateServerStance()
		end,
		Crouch = function(inputObject, inputState)
			if
				inputState ~= "began"
				or States.characterState.Running
				or States.characterState.Stance == "Prone"
			then
				return
			end

			if States.characterState.Stance == "Standing" then
				States.characterState.Stance = "Crouched"
				Humanoid.WalkSpeed = if States.characterState.LeaningState
						~= "NotLeaning"
					then Config.Speeds.CrouchLeaning
					else Config.Speeds.Crouch
			elseif States.characterState.Stance == "Crouched" then
				States.characterState.Stance = "Prone"
				States.characterState.LeaningState = "NotLeaning"
				Humanoid.WalkSpeed = Config.Speeds.Prone
			end

			if
				Variables.Viewmodel
				and Variables.WeaponInHand
				and Variables.WeaponData
			then
				Misc.Shake(0.65)
				Misc.PlaySFX(
					if Variables.WeaponData.Type == "Rifle"
						then "RifleFoley"
						else "PistolFoley"
				)
			end

			Misc.UpdateServerStance()
		end,
		Stand = function(inputObject, inputState)
			if
				inputState ~= "began"
				or States.characterState.Stance == "Standing"
			then
				return
			end

			if States.characterState.Stance == "Prone" then
				States.characterState.Stance = "Crouched"
				Humanoid.WalkSpeed = if States.characterState.LeaningState
						~= "NotLeaning"
					then Config.Speeds.CrouchLeaning
					else Config.Speeds.Crouch
			elseif States.characterState.Stance == "Crouched" then
				States.characterState.Stance = "Standing"
				Humanoid.WalkSpeed = if States.characterState.LeaningState
						~= "NotLeaning"
					then Config.Speeds.Leaning
					else Config.Speeds.Walking
			end

			if
				Variables.Viewmodel
				and Variables.WeaponInHand
				and Variables.WeaponData
			then
				Misc.Shake(-0.7)
				Misc.PlaySFX(
					if Variables.WeaponData.Type == "Rifle"
						then "RifleFoley"
						else "PistolFoley"
				)
			end

			Misc.UpdateServerStance()
		end,

		Scroll = function(inputObject, inputState)
			if inputState == "changed" then
				if States.gunState.Aiming and Variables.WeaponInHand then
					States.gunState.Sens += inputObject.Position.Z * 10
					States.gunState.Sens =
						math.clamp(States.gunState.Sens, 5, 100)

					UserInputService.MouseDeltaSensitivity = States.gunState.Sens
						/ 100

					Hud.GunUI.Sens.Text = "Sens: " .. States.gunState.Sens

					TweenService:Create(
						Hud.GunUI.Sens,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.In
						),
						{
							TextTransparency = 0,
						}
					):Play()
					Variables.SensTextTimeLeft = 2
				elseif
					Variables.WeaponInHand
					and Variables.AnimData
					and Variables.WeaponData
					and not States.gunState.Reloading
				then
					if inputObject.Position.Z > 0 then
						if States.gunState.GunStance == "Normal" then
							States.gunState.GunStance = "HighReady"
							Variables.AnimData.HighReady(Misc.GetAnimObjs())
						elseif States.gunState.GunStance == "LowReady" then
							States.gunState.GunStance = "Normal"
							Misc.RunCheck()
						elseif States.gunState.GunStance == "Patrol" then
							States.gunState.GunStance = "LowReady"
							Variables.AnimData.LowReady(Misc.GetAnimObjs())
						else
							return
						end

						Misc.PlaySFX(
							if Variables.WeaponData.Type == "Rifle"
								then "RifleFoley"
								else "PistolFoley"
						)
					elseif inputObject.Position.Z < 0 then
						if States.gunState.GunStance == "Normal" then
							States.gunState.GunStance = "LowReady"
							Variables.AnimData.LowReady(Misc.GetAnimObjs())
						elseif States.gunState.GunStance == "LowReady" then
							States.gunState.GunStance = "Patrol"
							Variables.AnimData.Patrol(Misc.GetAnimObjs())
						elseif States.gunState.GunStance == "HighReady" then
							States.gunState.GunStance = "Normal"
							Misc.RunCheck()
						else
							return
						end

						Misc.PlaySFX(
							if Variables.WeaponData.Type == "Rifle"
								then "RifleFoley"
								else "PistolFoley"
						)
					end
				end
			end
		end,
	}

return Inputs
