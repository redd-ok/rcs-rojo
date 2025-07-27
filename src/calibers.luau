local Engine = game:GetService("ReplicatedStorage").RCS

local Types = require(Engine.Types)

local Calibers = {
	["7.62x39mm"] = {
		InitialVelocity = 730,
		Mass = 0.0356,
		PenetrationPower = 14,

		ImpactEnergy = 3.47,
		HoleSize = 0.792,

		SuppressionAmount = 0.85,

		Damage = {
			Limb = {
				Min = 22,
				Max = 35,
			},

			Torso = {
				Min = 39,
				Max = 57,
			},

			Head = {
				Min = 150,
				Max = 150,
			},
		},
	} :: Types.Caliber,
	["5.56x39mm"] = {
		InitialVelocity = 993,
		Mass = 0.0356,
		PenetrationPower = 17,

		ImpactEnergy = 1.755,
		HoleSize = 0.56,

		SuppressionAmount = 0.7,

		Damage = {
			Limb = {
				Min = 22,
				Max = 35,
			},

			Torso = {
				Min = 39,
				Max = 57,
			},

			Head = {
				Min = 150,
				Max = 150,
			},
		},
	},

	["5.56x45mm"] = {
		InitialVelocity = 993,
		Mass = 0.0356,
		PenetrationPower = 17,

		ImpactEnergy = 1.755,
		HoleSize = 0.56,

		SuppressionAmount = 0.7,

		Damage = {
			Limb = {
				Min = 22,
				Max = 35,
			},

			Torso = {
				Min = 39,
				Max = 57,
			},

			Head = {
				Min = 150,
				Max = 150,
			},
		},
	} :: Types.Caliber,

	["9x19mm"] = {
		InitialVelocity = 360,
		Mass = 0.0804,
		PenetrationPower = 3.5,

		ImpactEnergy = 0.418,
		HoleSize = 0.901,

		SuppressionAmount = 0.25,

		Damage = {
			Limb = {
				Min = 19,
				Max = 26,
			},

			Torso = {
				Min = 31,
				Max = 41,
			},

			Head = {
				Min = 111,
				Max = 111,
			},
		},
	} :: Types.Caliber,
}

return Calibers
