local Types = require(game:GetService("ReplicatedStorage").RCS.Types)
local TS = game:GetService("TweenService")
local self = {} :: Types.AnimationConfig

self.MainCFrame = CFrame.new(0.5, -0.65, -0.45)

self.GunModelFixed = true
self.GunCFrame = CFrame.new(0.11, -0.2, 1)
	* CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))
self.LArmCFrame = (CFrame.new(0.639, -0.049, -0.042) * (CFrame.Angles(
	0,
	math.rad(82.774),
	0
) * CFrame.Angles(math.rad(-69.066), 0, math.rad(-117.912)))):Inverse()
self.RArmCFrame = CFrame.new(0, -0.15, 0)
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
		TweenInfo.new(0.65, Enum.EasingStyle.Sine),
		{ C1 = self.RArmCFrame:Inverse() }
	):Play()
	TS:Create(
		objs[2],
		TweenInfo.new(0.65, Enum.EasingStyle.Sine),
		{ C1 = self.LArmCFrame:Inverse() }
	):Play()
end

self.LowReady = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0, -0.15, 0.1) * CFrame.Angles(
			math.rad(70),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.55, -0.45, 0) * CFrame.Angles(
			math.rad(75),
			math.rad(25),
			math.rad(15)
		)):Inverse(),
	}):Play()
	wait(0.25)
end

self.HighReady = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0.15, -0.1, 0.5) * CFrame.Angles(
			math.rad(145),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.2, -0.25, 0) * CFrame.Angles(
			math.rad(155),
			math.rad(55),
			math.rad(15)
		)):Inverse(),
	}):Play()
	wait(0.25)
end

self.Patrol = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0, -0.15, 0.5) * CFrame.Angles(
			math.rad(55),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.55, -0.45, 0.4) * CFrame.Angles(
			math.rad(60),
			math.rad(25),
			math.rad(15)
		)):Inverse(),
	}):Play()
	wait(0.25)
end

self.SprintAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0, -0.15, 0.1) * CFrame.Angles(
			math.rad(70),
			math.rad(0),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.55, -0.45, 0) * CFrame.Angles(
			math.rad(75),
			math.rad(25),
			math.rad(15)
		)):Inverse(),
	}):Play()
	wait(0.25)
end

self.ReloadAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0, -0.15, 0) * CFrame.Angles(
			math.rad(90),
			math.rad(-25),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.6, -0.3, 0) * CFrame.Angles(
			math.rad(60),
			math.rad(50),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.3)

	TS:Create(objs[1], TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		C1 = (CFrame.new(0, -0.15, 0) * CFrame.Angles(
			math.rad(85),
			math.rad(-15),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-1.5, -0.5, 0.75) * CFrame.Angles(
			math.rad(0),
			math.rad(50),
			math.rad(15)
		)):Inverse(),
	}):Play()
	wait(0.05)
	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1
	wait(0.5)
	objs[4].Handle.AimUp:Play()
	wait(0.75)
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.6, -0.3, 0) * CFrame.Angles(
			math.rad(60),
			math.rad(50),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.25)
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[1], TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0, -0.15, 0) * CFrame.Angles(
			math.rad(90),
			math.rad(-25),
			math.rad(0)
		)):Inverse(),
	}):Play()
	objs[4].Mag.Transparency = 0
	wait(0.15)
end

self.TacticalReloadAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		C1 = (CFrame.new(0, -0.15, 0) * CFrame.Angles(
			math.rad(95),
			math.rad(45),
			math.rad(0)
		)):Inverse(),
	}):Play()
	TS:Create(objs[2], TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-1.5, -1, 1) * CFrame.Angles(
			math.rad(0),
			math.rad(50),
			math.rad(15)
		)):Inverse(),
	}):Play()
	wait(0.2)
	TS:Create(objs[1], TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		C1 = (CFrame.new(0, -0.15, 0) * CFrame.Angles(
			math.rad(85),
			math.rad(-25),
			math.rad(0)
		)):Inverse(),
	}):Play()

	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1

	local FakeMag = objs[4]:WaitForChild("Mag"):Clone()
	FakeMag:ClearAllChildren()
	FakeMag.Transparency = 0
	FakeMag.Parent = objs[4]
	FakeMag.Anchored = false
	FakeMag.RotVelocity = Vector3.new(0, 0, 0)
	FakeMag:ApplyImpulse(FakeMag.CFrame.RightVector * 1) --FakeMag.CFrame.LookVector * 15

	wait(0.5)
	objs[4].Handle.AimUp:Play()
	wait(0.25)
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.6, -0.3, 0) * CFrame.Angles(
			math.rad(60),
			math.rad(50),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.25)
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[1], TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(0, -0.15, 0) * CFrame.Angles(
			math.rad(90),
			math.rad(-25),
			math.rad(0)
		)):Inverse(),
	}):Play()
	objs[4].Mag.Transparency = 0
	wait(0.25)
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(
		objs[4].Handle.Slide,
		TweenInfo.new(0.05, Enum.EasingStyle.Linear),
		{ C0 = CFrame.new():Inverse() }
	):Play()
	wait(0.1)
end

self.BoltAnim = function(objs)
	TS:Create(
		objs[1],
		TweenInfo.new(0.25, Enum.EasingStyle.Sine),
		{ C1 = self.RArmCFrame:Inverse() }
	):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.8, 0.1, 0) * CFrame.Angles(
			math.rad(115),
			math.rad(-25),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.25)
	objs[4].Bolt.SlidePull:Play()
	TS:Create(
		objs[4].Handle.Slide,
		TweenInfo.new(0.25, Enum.EasingStyle.Sine),
		{ C0 = CFrame.new(0, 0, -0.4):Inverse() }
	):Play()
	TS:Create(objs[2], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		C1 = (CFrame.new(-0.8, 0.1, 0.4) * CFrame.Angles(
			math.rad(115),
			math.rad(-25),
			math.rad(30)
		)):Inverse(),
	}):Play()
	wait(0.35)
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(
		objs[4].Handle.Slide,
		TweenInfo.new(0.05, Enum.EasingStyle.Linear),
		{ C0 = CFrame.new():Inverse() }
	):Play()
end

self.PumpAnim = function(objs) end

self.MagCheck = function(objs)
	objs[4].Handle.AimUp:Play()
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
	objs[4].Handle.AimDown:Play()
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
	objs[4].Handle.AimUp:Play()
end

self.meleeAttack = function(objs) end

self.GrenadeReady = function(objs) end

self.GrenadeThrow = function(objs) end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--//Server Animations
------//Idle Position
self.SV_GunPos = CFrame.new(-0.3, -1, -0.4)
	* CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))

self.SV_RightArmPos = CFrame.new(-0.575, 0.65, -1.185)
	* CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
self.SV_LeftArmPos = CFrame.new(1.15, -0.1, -1.65)
	* CFrame.Angles(math.rad(-120), math.rad(20), math.rad(-25))

------//High Ready Animations
self.RightHighReady = CFrame.new(-1, -0.5, -1.25)
	* CFrame.Angles(math.rad(-160), math.rad(0), math.rad(0))
self.LeftHighReady = CFrame.new(0.85, -0.35, -1.15)
	* CFrame.Angles(math.rad(-170), math.rad(60), math.rad(15))

------//Low Ready Animations
self.RightLowReady = CFrame.new(-1, 0.85, -1.15)
	* CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0))
self.LeftLowReady = CFrame.new(0.95, 0.75, -1.35)
	* CFrame.Angles(math.rad(-60), math.rad(35), math.rad(-25))

------//Patrol Animations
self.RightPatrol = CFrame.new(-1, 1.5, -0.45)
	* CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0))
self.LeftPatrol = CFrame.new(1, 1.35, -0.75)
	* CFrame.Angles(math.rad(-30), math.rad(35), math.rad(-25))

------//Aim Animations
self.RightAim = CFrame.new(-0.575, 1, -0.65)
	* CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
self.LeftAim = CFrame.new(1.3, 0.35, -1.45)
	* CFrame.Angles(math.rad(-120), math.rad(35), math.rad(-25))

------//Sprinting Animations
self.RightSprint = CFrame.new(-1, 1.5, -0.45)
	* CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0))
self.LeftSprint = CFrame.new(1, 1.35, -0.75)
	* CFrame.Angles(math.rad(-30), math.rad(35), math.rad(-25))

return self
