local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RCS = ReplicatedStorage.RCS

local Types = require(RCS.Types)
local Config = require(RCS.RCS_Config)

local defaultGunState: Types.GunState = {
	Aiming = false,
	Shooting = false,
	ShootDelay = false,
	Reloading = false,
	AnimDebounce = false,
	Safety = false,

	LaserActive = false,
	FlashlightActive = false,

	AmmoInGun = 0,
	Ammo = 0,
	StoredAmmo = 0,

	ShotCounter = 0,

	GunStance = "Normal",
	Aimpart = 1,

	OverHeat = 0,

	Sens = 50,
	ZoomMode = 0,
}

local characterState: Types.CharacterState = {
	CharacterSpeed = 0,

	Stamina = Config.Stamina.MaxStamina,
	ArmStamina = Config.Stamina.MaxArmStamina,

	Moving = false,
	Running = false,
	JumpDebounce = false,

	Stance = "Standing",
	LeaningState = "NotLeaning",

	NVG = false,
	NVGDebounce = false,
}

local states: {
	defaultGunState: Types.GunState,
	gunState: Types.GunState,
	characterState: Types.CharacterState,
} =
	{
		defaultGunState = defaultGunState,

		gunState = table.clone(defaultGunState),
		characterState = characterState,
	}

return states
