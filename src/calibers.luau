local Engine = game:GetService("ReplicatedStorage").RCS

local Types = require(Engine.Types)

local Calibers = {
	["7.62x39mm"] = {
		["57-N-231"] = {
			InitialVelocity = 718,
			Mass = 0.0163,

			ImpactEnergy = 3.47,
			HoleSize = 0.792,

			SuppressionAmount = 0.85,

			Tracer = false,
			TracerColor = Color3.fromRGB(0, 255, 0),
			TracerSize = 0.2,

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
		["57-N-231P"] = {
			InitialVelocity = 718,
			Mass = 0.0161,

			ImpactEnergy = 3.47,
			HoleSize = 0.792,

			SuppressionAmount = 0.85,

			Tracer = true,
			TracerColor = Color3.fromRGB(0, 255, 0),
			TracerSize = 0.2,

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
	},

	["5.45x39mm"] = {
		["7N6M"] = {
			InitialVelocity = 880,
			Mass = 0.0139,

			ImpactEnergy = 1.755,
			HoleSize = 0.56,

			SuppressionAmount = 0.7,

			Tracer = false,
			TracerColor = Color3.fromRGB(0, 255, 0),
			TracerSize = 0.2,

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
		["7T3"] = {
			InitialVelocity = 880,
			Mass = 0.0139,

			ImpactEnergy = 1.755,
			HoleSize = 0.56,

			SuppressionAmount = 0.7,

			Tracer = true,
			TracerColor = Color3.fromRGB(0, 255, 0),
			TracerSize = 0.2,

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
	},
	["5.56x45mm"] = {
		["M855A1"] = {
			InitialVelocity = 961,
			Mass = 0.0163,

			ImpactEnergy = 1.755,
			HoleSize = 0.56,

			SuppressionAmount = 0.7,

			Tracer = false,
			TracerColor = Color3.fromRGB(255, 0, 0),
			TracerSize = 0.2,

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
		["M856A1"] = {
			InitialVelocity = 961,
			Mass = 0.0159,

			ImpactEnergy = 1.755,
			HoleSize = 0.56,

			SuppressionAmount = 0.7,

			Tracer = true,
			TracerColor = Color3.fromRGB(255, 0, 0),
			TracerSize = 0.2,

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
	},

	["9x19mm"] = {
		["FMJ"] = {
			InitialVelocity = 352,
			Mass = 0.0075,

			ImpactEnergy = 0.418,
			HoleSize = 0.901,

			Tracer = false,
			TracerColor = Color3.fromRGB(0, 255, 0),
			TracerSize = 0.03,

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
	},
	["9x18mm"] = {
		["7N25"] = {
			InitialVelocity = 352,
			Mass = 0.0075,

			ImpactEnergy = 0.418,
			HoleSize = 0.901,

			Tracer = false,
			TracerColor = Color3.fromRGB(0, 255, 0),
			TracerSize = 0.03,

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
	},
	[".45 ACP"] = {
		["FMJ"] = {
			InitialVelocity = 255,
			Mass = 0.015,

			ImpactEnergy = 0.418,
			HoleSize = 0.901,

			Tracer = false,
			TracerColor = Color3.fromRGB(0, 255, 0),
			TracerSize = 0.03,

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
	},
}

return Calibers
