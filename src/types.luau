export type AnimationsObject = {}

export type AnimationConfig = {
	MainCFrame: CFrame,

	GunCFrame: CFrame,
	LArmCFrame: CFrame,
	RArmCFrame: CFrame,

	EquipAnim: (objs: AnimationsObject) -> nil,
	IdleAnim: (objs: AnimationsObject) -> nil,
	LowReady: (objs: AnimationsObject) -> nil,
	HighReady: (objs: AnimationsObject) -> nil,
	Patrol: (objs: AnimationsObject) -> nil,
	SprintAnim: (objs: AnimationsObject) -> nil,
	ReloadAnim: (objs: AnimationsObject) -> nil,
	TacticalReloadAnim: (objs: AnimationsObject) -> nil,
	BoltAnim: (objs: AnimationsObject) -> nil,
	PumpAnim: (objs: AnimationsObject) -> nil,
	MagCheck: (objs: AnimationsObject) -> nil,
	AttachmentToggle: nil | (
		objs: AnimationsObject,
		laser: boolean,
		animate: boolean
	) -> nil,
	SwitchAimPart: nil | (objs: AnimationsObject, animate: boolean) -> nil,
	VariableZoom: nil | (objs: AnimationsObject, animate: boolean) -> nil,
	ShootAnim: nil | (objs: AnimationsObject) -> nil,

	SV_GunPos: CFrame,

	SV_RightArmPos: CFrame,
	SV_LeftArmPos: CFrame,

	RightHighReady: CFrame,
	LeftHighReady: CFrame,

	RightLowReady: CFrame,
	LeftLowReady: CFrame,

	RightPatrol: CFrame,
	LeftPatrol: CFrame,

	RightAnim: CFrame,
	LeftAnim: CFrame,

	RightSprint: CFrame,
	LeftSprint: CFrame,
}

export type AimPart = {
	FOV: number,
	AimPartName: string,

	VariableZoom: boolean,
	Type: nil | "Magnifier" | "LPVO",
	ZoomModes: { number },
	CurrentZoom: number,

	VisOnAim: { string },
	InvisOnAim: { string },
	ResetTransparency: { string },
}

export type GunAttachment = {
	Id: string,
	Attachments: { [string]: GunAttachment }?,
}

export type GunConfig = {
	Type: "Rifle" | "Pistol",

	SlideEx: CFrame,
	SlideLock: boolean,

	canAim: boolean,
	Aimparts: { AimPart },

	Attachments: { [string]: GunAttachment }?,

	Ammo: number,
	StoredAmmo: number,
	AmmoInGun: number,

	CanCheckMag: boolean,
	MagCount: boolean,

	ShellInsert: boolean,

	ShootRate: number,
	Bullets: number,
	BurstShot: number,

	Firemode: number,
	Firemodes: {
		ChangeFiremode: boolean,
		Semi: boolean,
		Burst: boolean,
		Auto: boolean,
	},

	LimbDamage: { number },
	TorsoDamage: { number },

	DamageFallOf: number,
	MinDamage: number,

	IgnoreProtection: boolean,
	BulletPenetration: number,

	camRecoil: {
		camRecoilUp: { number },
		camRecoilTilt: { number },
		camRecoilLeft: { number },
		camRecoilRight: { number },
	},
	gunRecoil: {
		gunRecoilUp: { number },
		gunRecoilTilt: { number },
		gunRecoilLeft: { number },
		gunRecoilRight: { number },
	},
	gunKick: number,

	MinSpread: number,
	MaxSpread: number,

	BulletType: string,

	Tracer: boolean,
	BulletFlare: boolean,
	TracerColor: Color3,
	RandomTracer: {
		Enabled: boolean,
		Chance: number,
	},
	TracerEveryXShots: number,

	Chambered: boolean,
}

export type GunStance = "HighReady" | "LowReady" | "Patrol" | "Normal"
export type CharacterStance = "Standing" | "Crouched" | "Prone"
export type LeaningState = "Left" | "NotLeaning" | "Right"

export type GunState = {
	Aiming: boolean,
	Shooting: boolean,
	ShootDelay: boolean,
	Reloading: boolean,
	AnimDebounce: boolean,
	Safety: boolean,

	LaserActive: boolean,
	FlashlightActive: boolean,

	AmmoInGun: number,
	Ammo: number,
	StoredAmmo: number,

	ShotCounter: number,

	GunStance: GunStance,
	Aimpart: number,

	OverHeat: number,

	Sens: number,
	ZoomMode: number,
}

export type CharacterState = {
	CharacterSpeed: number,

	Stamina: number,
	ArmStamina: number,

	Moving: boolean,
	Running: boolean,
	JumpDebounce: boolean,

	Stance: CharacterStance,
	LeaningState: LeaningState,

	NVG: boolean,
	NVGDebounce: boolean,
}

export type Caliber = {
	InitialVelocity: number,
	Mass: number,
	DragConstant: number,
	PenetrationPower: number,

	ImpactEnergy: number,
	HoleSize: number,

	TracerSize: number,

	SuppressionAmount: number,

	Damage: {
		Limb: {
			Min: number,
			Max: number,
		},

		Torso: {
			Min: number,
			Max: number,
		},

		Head: {
			Min: number,
			Max: number,
		},
	},
}

export type EjectionForce = {
	CalculateForce: (self: EjectionForce?) -> Vector3,
	PhysProperties: PhysicalProperties,
	ForcePoint: Vector3,
}

export type WeaponMuzzle = Attachment & {
	Indoor: Sound,
	Outdoor: Sound,
	Fire: Sound,

	OutdoorLoop: Sound,
	IndoorLoop: Sound,
	Loop: Sound,

	OverHeat: ParticleEmitter,
}
export type WeaponHandle = BasePart & {
	Muzzle: WeaponMuzzle,
	Slide: Motor6D,
}
export type WeaponInHand = Model & {
	PrimaryPart: WeaponHandle,
	Handle: WeaponHandle,
}

export type CharacterHealthInfo = {
	Dead: boolean,
	Conscious: boolean,

	Blood: number,
	Bleeding: number,
	Pain: number,

	Fractured: {
		Leg: {
			["Left Leg"]: boolean,
			["Right Leg"]: boolean,
		},
		Arm: {
			["Left Arm"]: boolean,
			["Right Arm"]: boolean,
		},
	},

	Tourniquet: boolean,

	Humanoid: Humanoid,

	_lastPosition: Vector3,
	_lastUpdate: number,
	_collectiveDamage: number,
	_lastDamage: number,
}

return nil
