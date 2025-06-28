local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RCS = ReplicatedStorage.RCS

local Types = require(RCS.Types)

local variables: {
	WeaponInHand: Types.WeaponInHand?,
	WeaponTool: Tool?,
	WeaponData: Types.GunConfig?,
	AnimData: Types.AnimationConfig?,

	Viewmodel: Model?,
	AnimPart: Part?,

	LArmWeld: Motor6D?,
	LArm: BasePart?,
	RArmWeld: Motor6D?,
	RArm: BasePart?,

	GunWeld: Motor6D?,

	MainCF: CFrame,

	WalkTime: number,
	SensTextTimeLeft: number,
} =
	{
		MainCF = CFrame.new(),
		WalkTime = 0,
		SensTextTimeLeft = 0,
	}

return variables
