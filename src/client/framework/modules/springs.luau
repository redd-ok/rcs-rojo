local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RCS = ReplicatedStorage.RCS

local Spring = require(RCS.Modules:WaitForChild("Spring"))

local Springs = {
	SwaySpring = Spring.new(Vector2.new()),
	StaminaSwaySpring = Spring.new(Vector2.new()),
	DeadzoneSpring = Spring.new(Vector2.new()),

	RecoilX = Spring.new(0),
	RecoilY = Spring.new(0),
	RecoilZ = Spring.new(0),
	RecoilKick = Spring.new(0),

	CamRecoil = Spring.new(Vector3.new()),

	Speed = Spring.new(0),

	GunShake = Spring.new(Vector3.new()),

	AimTime = Spring.new(0),
}

Springs.SwaySpring.d = 0.6
Springs.SwaySpring.s = 24
Springs.StaminaSwaySpring.d = 0.2
Springs.StaminaSwaySpring.s = 6
Springs.DeadzoneSpring.d = 0.3
Springs.DeadzoneSpring.s = 64
Springs.Speed.d = 0.8
Springs.Speed.s = 8
Springs.AimTime.d = 0.5
Springs.AimTime.s = 32
Springs.GunShake.d = 0.5
Springs.GunShake.s = 14

Springs.RecoilX.d = 0.6
Springs.RecoilX.s = 34
Springs.RecoilY.d = 0.6
Springs.RecoilY.s = 34
Springs.RecoilZ.d = 0.2
Springs.RecoilZ.s = 55
Springs.RecoilKick.d = 0.8
Springs.RecoilKick.s = 28
Springs.CamRecoil.d = 0.5
Springs.CamRecoil.s = 22

return Springs
