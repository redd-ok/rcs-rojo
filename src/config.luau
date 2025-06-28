return {
	Serverside_EquipRate = 1 / 7, -- how often should guns be equipped serverside

	Replication_HeadRotationRate = 1 / 25, -- how often should other player's head be rotated (will be interpolated)

	ProjectileAllocation = 2000, -- how many projectiles should be allocated upon game start
	ProjectileActorAllocation = 64, -- how many actors to allocate to the projectile system

	ProjectileMaximumDistance = 5000, -- how far can a projectile travel before getting removed
	ProjectileMaximumLifetime = 30, -- how long can a projectile exist before getting removed

	Debug = true,
	DebugGUI = Enum.KeyCode.RightShift,

	AntiTeamKill = false,

	ToggleAim = false,
	ToggleLean = false,

	Stamina = {
		MaxStamina = 100,
		MaxArmStamina = 100,

		-- rate is per second
		StaminaGainSprinting = -5,
		StaminaGainMovingMultiplier = 0.5,
		StaminaGainStanding = 6,
		StaminaGainCrouched = 7,
		StaminaGainProned = 7.5,

		ArmStaminaGainAimming = -2.5,
		ArmStaminaGainNormal = 5,
		ArmStaminaGainLowReady = 6.5,
		ArmStaminaGainHighReady = 6.5,
		ArmStaminaGainPatrol = 7.5,
		ArmStaminaGainNoGun = 9,
	},

	Suppression = {
		Enabled = true,
		MaxSuppression = 10,
		VignetteIntensity = 1,
		BlurIntensity = 15,

		DissipationRate = 3,
		DissipationDelay = 1.5,

		CameraShake = true,
		CameraShakeIntensity = 1.5,
		CameraShakeSpeed = 1,
		CameraShakeKick = 1,
	},

	MedicalSystem = {
		Enabled = true,
		UpdateRate = 1 / 10,

		MaxBlood = 1000,
		MaxHealth = 150,

		-- per second
		BleedingRates = {
			Light = 2,
			Medium = 7,
			Heavy = 22,
		},

		DamageForLegFracture = 40,
		DamageForArmFracture = 50,

		EnableUnconsciousenss = true,
		UnconsiousAt = 400, -- when blood reaches below this number, player will be unconscious

		EnableVisualEffects = true,
	},

	Speeds = {
		Sprint = 20,
		Walking = 12,
		SlowPace = 8,
		Leaning = 10,
		Crouch = 8,
		CrouchLeaning = 6,
		Prone = 4,

		FracturedMovementMultiplier = 0.75,
	},

	Keybinds = {
		Aim = Enum.UserInputType.MouseButton2,
		Shoot = Enum.UserInputType.MouseButton1,
		Scroll = Enum.UserInputType.MouseWheel,

		CycleFiremode = Enum.KeyCode.V,
		CycleZoomMode = Enum.KeyCode.Y,
		CycleAimpart = Enum.KeyCode.T,

		ToggleLaser = Enum.KeyCode.H,
		ToggleFlashlight = Enum.KeyCode.J,

		Reload = Enum.KeyCode.R,
		Bolt = Enum.KeyCode.F,

		Sprint = Enum.KeyCode.LeftShift,
		LeanLeft = Enum.KeyCode.Q,
		LeanRight = Enum.KeyCode.E,
		Crouch = Enum.KeyCode.C,
		Stand = Enum.KeyCode.X,
	},

	Sounds = {
		Whizzes = {
			"rbxassetid://15690855368",
			"rbxassetid://15690855509",
			"rbxassetid://15690855257",
		},

		Cracks = {
			Close = {
				"rbxassetid://15686377931",
				"rbxassetid://15686377695",
				"rbxassetid://15686377489",
			},
			Medium = {
				"rbxassetid://15686352208",
				"rbxassetid://15686352443",
				"rbxassetid://15686352082",
			},
		},
	},
}
