local self = {}

self.Type = "Rifle"

self.SlideEx = CFrame.new(0, 0, -0.4)
self.SlideLock = true

self.canAim = true
self.Aimparts = {
	[1] = {
		FOV = 60,
		AimPartName = "AimPart1",

		VisOnAim = {},
		InvisOnAim = {},
		ResetTransparency = {},
	},
	[2] = {
		FOV = 45,
		AimPartName = "AimPart2",

		VisOnAim = {},
		InvisOnAim = {},
		ResetTransparency = {},
	},
}

self.Ammo = 30
self.StoredAmmo = 90
self.AmmoInGun = self.Ammo
self.MaxStoredAmmo = 210
self.CanCheckMag = true
self.MagCount = true
self.ShellInsert = false
self.ShootRate = 600
self.Bullets = 1
self.BurstShot = 3
self.Firemode = 3 --[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.Firemodes = {
	ChangeFiremode = true,
	Semi = true,
	Burst = false,
	Auto = true,
}

self.camRecoil = {
	camRecoilUp = { 55, 65 },
	camRecoilTilt = { 44, 44 },
	camRecoilLeft = { 24, 35 },
	camRecoilRight = { 24, 35 },
}
self.gunRecoil = {
	gunRecoilUp = { 22, 35 },
	gunRecoilTilt = { 11, 25 },
	gunRecoilLeft = { 22, 35 },
	gunRecoilRight = { 22, 35 },
}
self.gunKick = 5

self.MinRecoilPower = 0.5
self.MaxRecoilPower = 1.5
self.RecoilPowerStepAmount = 0.1

self.MinSpread = 0.75
self.MaxSpread = 100

self.Chambered = true

return self
