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
self.ShootRate = 700
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
	camRecoilUp = { 11, 14 },
	camRecoilTilt = { 5, 6 },
	camRecoilLeft = { 8, 11 },
	camRecoilRight = { 8, 11 },
}

self.gunRecoil = {
	gunRecoilUp = { 9, 11 },
	gunRecoilTilt = { 6, 11 },
	gunRecoilLeft = { 7, 22 },
	gunRecoilRight = { 8, 22 },
}
self.gunKick = 1.8

self.MinRecoilPower = 0.5
self.MaxRecoilPower = 1.5
self.RecoilPowerStepAmount = 0.1

self.MinSpread = 0.75
self.MaxSpread = 100

self.Chambered = true

return self
