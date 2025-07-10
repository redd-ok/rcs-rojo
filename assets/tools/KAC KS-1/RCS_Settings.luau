local TS = game:GetService('TweenService')
local self = {}

self.Type = "Rifle"

self.SlideEx 		= CFrame.new(0,0,-0.4)
self.SlideLock 		= true

self.canAim 		= true
self.Aimparts = {
	[1] = {
		FOV = 60,
		AimPartName = "AimPart1",

		VisOnAim = {},
		InvisOnAim = {},
		ResetTransparency = {}
	},
	[2] = {
		FOV = 60,
		AimPartName = "AimPart2",

		VisOnAim = {},
		InvisOnAim = {},
		ResetTransparency = {}
	}
}

self.Ammo 			= 30
self.StoredAmmo 	= 90
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 210
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 800
self.Bullets 		= 1
self.BurstShot 		= 3
self.Firemode 		= 3				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.Firemodes = {
	ChangeFiremode = true;		
	Semi = true;
	Burst = false;
	Auto = true;
}

self.LimbDamage 	= {35,40}
self.TorsoDamage 	= {57,62} 
self.HeadDamage 	= {150,150} 
self.DamageFallOf 	= 1
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 72

self.camRecoil = {
	camRecoilUp 	= {20,35}
	,camRecoilTilt 	= {15,25}
	,camRecoilLeft 	= {11,24}
	,camRecoilRight = {11,24}
}

self.gunRecoil = {
	gunRecoilUp 	= {12,15}
	,gunRecoilTilt 	= {4,14}
	,gunRecoilLeft 	= {7,11}
	,gunRecoilRight = {7,11}
}
self.gunKick = 1.8

self.MinRecoilPower 			= .5
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 0.75
self.MaxSpread 					= 100					
self.AimInaccuracyStepAmount 	= 0.75
self.AimInaccuracyDecrease 		= .25
self.WalkMult 					= 0

self.BulletType 				= "5.56x45mm"
self.MuzzleVelocity 			= 1500 --m/s
self.BulletDrop 				= .25 --Between 0 - 1
self.Tracer						= true
self.BulletFlare 				= false
self.TracerColor				= Color3.fromRGB(255,255,255)
self.RandomTracer				= {
	Enabled = false
	,Chance = 25 -- 0-100%
}
self.TracerEveryXShots			= 3

self.Chambered = true

return self