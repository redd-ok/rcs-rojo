local Types = require(game:GetService("ReplicatedStorage").RCS.Types)
local TS = game:GetService("TweenService")
local self = {} :: Types.AnimationConfig

self.MainCFrame = CFrame.new(0.5, -0.85, -0.75)

self.GunModelFixed = true
self.GunCFrame = CFrame.new(0.15, -0.2, 0.85)
	* CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))
self.LArmCFrame = (CFrame.new(0.829, 0.494, 0.014) * (CFrame.Angles(
	0,
	math.rad(116.901),
	0
) * CFrame.Angles(math.rad(-61.759), 0, math.rad(-150.998)))):Inverse()
self.RArmCFrame = CFrame.new(0.05, -0.15, 1)
	* CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))

self.EquipAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		C1 = (CFrame.new(1, -1, 1) * CFrame.Angles(
			math.rad(0),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		C1 = (CFrame.new(-1, -1, 1) * CFrame.Angles(
			math.rad(0),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	wait(0.25)
	TS:Create(
		objs[1],
		TweenInfo.new(0.35, Enum.EasingStyle.Sine),
		{ C1 = self.RArmCFrame:Inverse() }
	):Play()
	TS:Create(
		objs[2],
		TweenInfo.new(0.35, Enum.EasingStyle.Sine),
		{ C1 = self.LArmCFrame:Inverse() }
	):Play()
	wait(0.35)
end

self.IdleAnim = function(objs)
	TS:Create(
		objs[1],
		TweenInfo.new(0.4, Enum.EasingStyle.Sine),
		{ C1 = self.RArmCFrame:Inverse() }
	):Play()
	TS:Create(
		objs[2],
		TweenInfo.new(0.4, Enum.EasingStyle.Sine),
		{ C1 = self.LArmCFrame:Inverse() }
	):Play()
end

self.LowReady = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		C1 = CFrame.new(-0.088, -1.349, -0.697) * (CFrame.Angles(
			0,
			math.rad(-27.179),
			0
		) * CFrame.Angles(math.rad(-73.38), 0, math.rad(7.872))),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		C1 = CFrame.new(1.02, -0.138, 0.228) * (CFrame.Angles(
			0,
			math.rad(21.674),
			0
		) * CFrame.Angles(math.rad(-46.383), 0, math.rad(-67.02))),
	}):Play()
	wait(0.3)
end

self.HighReady = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		C1 = CFrame.new(-0.008, -1.319, -0.34) * (CFrame.Angles(
			0,
			math.rad(-172.099),
			0
		) * CFrame.Angles(math.rad(-75.521), 0, math.rad(162.341))),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		C1 = CFrame.new(0.928, 0.111, 0.115) * (CFrame.Angles(
			0,
			math.rad(115.087),
			0
		) * CFrame.Angles(math.rad(-50.969), 0, math.rad(-152.813))),
	}):Play()
	wait(0.3)
end

self.Patrol = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.75, -0.15, 0) * CFrame.Angles(
			math.rad(90),
			math.rad(20),
			math.rad(-75)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-1.15, -0.75, 0.4) * CFrame.Angles(
			math.rad(90),
			math.rad(20),
			math.rad(25)
		)):Inverse(),
	}):Play()
	wait(0.25)
end

self.SprintAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.45, Enum.EasingStyle.Sine), {
		C1 = CFrame.new(0.238, -1.051, -0.63) * (CFrame.Angles(
			0,
			math.rad(-86.454),
			0
		) * CFrame.Angles(math.rad(-58.44), 0, math.rad(68.407))),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.45, Enum.EasingStyle.Sine), {
		C1 = CFrame.new(1.331, 0.014, -0.338) * (CFrame.Angles(
			0,
			math.rad(179.671),
			0
		) * CFrame.Angles(math.rad(-74.062), 0, math.rad(149.779))),
	}):Play()
	wait(0.45)
end

self.ReloadAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(110),
			math.rad(-15),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.75, -0.15, 0.5) * CFrame.Angles(
			math.rad(110),
			math.rad(-15),
			math.rad(30)
		)):Inverse(),
	}):Play()
	objs.PlaySFX("HandOff")
	wait(0.3)

	TS:Create(objs[1], TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(100),
			math.rad(-5),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		C1 = (CFrame.new(-0.75, -0.15, 0.5) * CFrame.Angles(
			math.rad(60),
			math.rad(-5),
			math.rad(15)
		)):Inverse(),
	}):Play()
	wait(0.05)
	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1
	wait(0.5)
	objs.PlaySFX("RifleFoley")
	wait(0.75)
	TS:Create(objs[2], TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.75, -0.5, 0.25) * CFrame.Angles(
			math.rad(110),
			math.rad(-15),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.25)
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[1], TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(101),
			math.rad(-6),
			math.rad(0)
		)):Inverse(),
	}):Play()
	objs[4].Mag.Transparency = 0
	wait(0.2)
	objs.PlaySFX("RifleFoley")
	TS:Create(objs[2], TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.75, -0.5, 0.25) * CFrame.Angles(
			math.rad(60),
			math.rad(-15),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.25)
	TS:Create(objs[2], TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.75, -0.5, 0.25) * CFrame.Angles(
			math.rad(100),
			math.rad(-15),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.05)
	TS:Create(objs[1], TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(105),
			math.rad(-5),
			math.rad(0)
		)):Inverse(),
	}):Play()
	wait(0.1)
end

self.TacticalReloadAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(110),
			math.rad(-15),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		C1 = (CFrame.new(-0.75, -0.15, 0.5) * CFrame.Angles(
			math.rad(60),
			math.rad(-5),
			math.rad(15)
		)):Inverse(),
	}):Play()
	wait(0.3)

	TS:Create(objs[1], TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(100),
			math.rad(-5),
			math.rad(0)
		)):Inverse(),
	}):Play()
	wait(0.05)
	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1

	local FakeMag = objs[4]:WaitForChild("Mag"):Clone()
	FakeMag:ClearAllChildren()
	FakeMag.Transparency = 0
	FakeMag.Parent = objs[4]
	FakeMag.Anchored = false
	FakeMag.RotVelocity = Vector3.new(0, 0, 0)
	FakeMag.Velocity = (FakeMag.CFrame.UpVector * 25)

	wait(0.5)
	objs.PlaySFX("RifleFoley")
	wait(0.25)
	TS:Create(objs[2], TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.75, -0.5, 0.25) * CFrame.Angles(
			math.rad(110),
			math.rad(-15),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.25)
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[1], TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(101),
			math.rad(-6),
			math.rad(0)
		)):Inverse(),
	}):Play()
	objs[4].Mag.Transparency = 0
	wait(0.2)
	TS:Create(objs[2], TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.75, -0.5, 0.25) * CFrame.Angles(
			math.rad(60),
			math.rad(-15),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.25)
	TS:Create(objs[2], TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.75, -0.5, 0.25) * CFrame.Angles(
			math.rad(100),
			math.rad(-15),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.05)
	objs.PlaySFX("RifleFoley")
	TS:Create(objs[1], TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(105),
			math.rad(-5),
			math.rad(0)
		)):Inverse(),
	}):Play()
	wait(0.15)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.05, -0.15, 1) * CFrame.Angles(
			math.rad(90),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.85, 0.05, 0.6) * CFrame.Angles(
			math.rad(110),
			math.rad(-15),
			math.rad(25)
		)):Inverse(),
	}):Play()
	wait(0.25)
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(
		objs[4].Handle.Slide,
		TweenInfo.new(0.15, Enum.EasingStyle.Linear),
		{ C0 = CFrame.new():Inverse() }
	):Play()
	TS:Create(objs[2], TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		C1 = (CFrame.new(-0.8, 0.05, 0.6) * CFrame.Angles(
			math.rad(110),
			math.rad(-15),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.15)
end

self.BoltAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.05, -0.15, 0.75) * CFrame.Angles(
			math.rad(90),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.5, -0.35, 0.45) * CFrame.Angles(
			math.rad(160),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	wait(0.25)
	objs.PlaySFX("BoltHandleOut")
	TS:Create(
		objs[4].Handle.Slide,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine),
		{ C0 = CFrame.new(0, 0, -0.4):Inverse() }
	):Play()
	TS:Create(
		objs[4].Handle.Bolt,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine),
		{ C0 = CFrame.new(0, 0, -0.4):Inverse() }
	):Play()
	TS:Create(objs[2], TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.5, -0.35, 0.45) * CFrame.Angles(
			math.rad(180),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	wait(0.3)
	TS:Create(
		objs[4].Handle.Slide,
		TweenInfo.new(0.1, Enum.EasingStyle.Linear),
		{ C0 = CFrame.new():Inverse() }
	):Play()
	TS:Create(
		objs[4].Handle.Bolt,
		TweenInfo.new(0.1, Enum.EasingStyle.Linear),
		{ C0 = CFrame.new():Inverse() }
	):Play()
	objs.PlaySFX("BoltHandleIn")
end

self.PumpAnim = function(objs) end

self.MagCheck = function(objs)
	objs.PlaySFX("RifleFoley")
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.5, -0.15, 0) * CFrame.Angles(
			math.rad(100),
			math.rad(0),
			math.rad(-45)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		C1 = (CFrame.new(-1, -1, 1) * CFrame.Angles(
			math.rad(0),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	wait(2.5)
	objs.PlaySFX("RifleFoley")
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.5, -0.15, 0) * CFrame.Angles(
			math.rad(160),
			math.rad(60),
			math.rad(-45)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		C1 = (CFrame.new(-1, -1, 1) * CFrame.Angles(
			math.rad(0),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	wait(2.5)
	objs.PlaySFX("RifleFoley")
end

self.VariableZoom = function(objs, animate)
	local weaponData: Types.GunConfig = objs[6]
	local aimPart = weaponData.Aimparts[objs.GunState.Aimpart]
	local weaponInHand: Types.WeaponInHand = objs[4]
	if
		aimPart.Type == "Magnifier"
		and weaponInHand.Handle:FindFirstChild("MagnifierPoint")
	then
		local magnifierPointWeld: Motor6D =
			weaponInHand.Handle:FindFirstChild("MagnifierPoint") :: Motor6D
		local magnifierPoint = magnifierPointWeld.Part1

		if aimPart.CurrentZoom == 1 then
			if animate then
				TS:Create(
					magnifierPointWeld,
					TweenInfo.new(0.25, Enum.EasingStyle.Linear),
					{
						C0 = magnifierPoint:GetAttribute("Untoggled"),
					}
				):Play()
			else
				magnifierPointWeld.C0 = magnifierPoint:GetAttribute("Untoggled")
			end

			for i, v: ObjectValue in magnifierPoint.VisOnToggle:GetChildren() do
				(v.Value :: BasePart).Transparency = 0
			end
		else
			if animate then
				TS:Create(
					magnifierPointWeld,
					TweenInfo.new(0.3, Enum.EasingStyle.Linear),
					{
						C0 = magnifierPoint:GetAttribute("Toggled"),
					}
				):Play()
			else
				magnifierPointWeld.C0 = magnifierPoint:GetAttribute("Toggled")
			end

			for i, v: ObjectValue in magnifierPoint.VisOnToggle:GetChildren() do
				(v.Value :: BasePart).Transparency = 1
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--//Server Animations
------//Idle Position
self.SV_GunPos = CFrame.new(-0.3, -1, -0.4)
	* CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))

self.SV_RightArmPos = CFrame.new(-0.85, 0.1, -1.2)
	* CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
self.SV_LeftArmPos = CFrame.new(1.05, 0.9, -1.4)
	* CFrame.Angles(math.rad(-100), math.rad(25), math.rad(-20))

------//High Ready Animations
self.RightHighReady = CFrame.new(-1, -1, -1.5)
	* CFrame.Angles(math.rad(-160), math.rad(0), math.rad(0))
self.LeftHighReady = CFrame.new(0.85, -0.35, -1.15)
	* CFrame.Angles(math.rad(-170), math.rad(60), math.rad(15))

------//Low Ready Animations
self.RightLowReady = CFrame.new(-1, 0.5, -1.25)
	* CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0))
self.LeftLowReady = CFrame.new(1.25, 1.15, -1.35)
	* CFrame.Angles(math.rad(-60), math.rad(35), math.rad(-25))

------//Patrol Animations
self.RightPatrol = CFrame.new(-1, -0.35, -1.5)
	* CFrame.Angles(math.rad(-80), math.rad(-80), math.rad(0))
self.LeftPatrol = CFrame.new(1, 1.25, -0.75)
	* CFrame.Angles(math.rad(-90), math.rad(-45), math.rad(-25))

------//Aim Animations
self.RightAim = CFrame.new(-0.575, 0.1, -1)
	* CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
self.LeftAim = CFrame.new(1.4, 0.25, -1.45)
	* CFrame.Angles(math.rad(-120), math.rad(35), math.rad(-25))

------//Sprinting Animations
self.RightSprint = CFrame.new(-1, 0.5, -1.25)
	* CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0))
self.LeftSprint = CFrame.new(1.25, 1.15, -1.35)
	* CFrame.Angles(math.rad(-60), math.rad(35), math.rad(-25))

return self
