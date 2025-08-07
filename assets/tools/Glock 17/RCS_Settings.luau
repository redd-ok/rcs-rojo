local self = {}

self.Type = "Pistol"

self.SlideEx = CFrame.new(0, 0, -0.4)
self.SlideLock = true

self.canAim = true
self.Aimparts = {
	[1] = {
		FOV = 65,
		AimPartName = "AimPart1",

		VisOnAim = {},
		InvisOnAim = {},
		ResetTransparency = {},
	},
	[2] = {
		FOV = 60,
		AimPartName = "AimPart2",

		VisOnAim = {},
		InvisOnAim = {},
		ResetTransparency = {},
	},
}

self.Ammo = 17
self.StoredAmmo = 17 * 3
self.AmmoInGun = self.Ammo
self.MaxStoredAmmo = 17 * 6
self.CanCheckMag = true
self.MagCount = true
self.ShellInsert = false
self.ShootRate = 800
self.Bullets = 1
self.BurstShot = 3
self.Firemode = 1 --[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.Firemodes = {
	ChangeFiremode = false,
	Semi = true,
	Burst = false,
	Auto = false,
}

self.camRecoil = {
	camRecoilUp = { 12, 15 },
	camRecoilTilt = { 10, 15 },
	camRecoilLeft = { 7, 10 },
	camRecoilRight = { 6, 9 },
}

self.gunRecoil = {
	gunRecoilUp = { 35, 55 },
	gunRecoilTilt = { 33, 44 },
	gunRecoilLeft = { 12, 17 },
	gunRecoilRight = { 12, 17 },
}
self.gunKick = 3

self.MinRecoilPower = 0.5
self.MaxRecoilPower = 1.5
self.RecoilPowerStepAmount = 0.1

self.MinSpread = 0.75
self.MaxSpread = 100

self.Chambered = true

return self
