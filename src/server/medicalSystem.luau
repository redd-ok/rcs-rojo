local RCS = game:GetService("ReplicatedStorage").RCS

local Types = require(RCS.Types)
local Config = require(RCS.RCS_Config)
local Ragdoll = require(RCS.Modules.Ragdoll)
local Utilities = require(RCS.Modules.Utilities)
local ServerNetwork = require(script.Parent.ServerNetwork)

type CharacterHealthInfo = Types.CharacterHealthInfo

local medicalSystem = {}
medicalSystem.characterInfos = {} :: { [Model]: CharacterHealthInfo? }
local defaultCharacterInfo: CharacterHealthInfo = {
	Dead = false,
	Conscious = false,

	Blood = Config.MedicalSystem.MaxBlood,

	Bleeding = 0,
	Pain = 0,

	Fractured = {
		Leg = {
			["Left Leg"] = false,
			["Right Leg"] = false,
		},
		Arm = {
			["Left Arm"] = false,
			["Right Arm"] = false,
		},
	},

	Tourniquet = false,

	Humanoid = nil,

	_lastPosition = nil,
	_lastUpdate = nil,
	_collectiveDamage = 0,
	_lastDamage = 0,
}

function medicalSystem.characterHit(
	self: typeof(medicalSystem),
	hitPart: BasePart,
	character: Model,
	caliber: Types.Caliber
)
	local healthInfo = self.characterInfos[character]
	if not healthInfo then
		if Config.MedicalSystem.Enabled then
			warn(
				`Medical System: Character ({character:GetFullName()}) is not registerd`
			)
		end
		return
	end
	local humanoid = healthInfo.Humanoid
	self:updateCharacter(healthInfo)

	local damage
	if hitPart.Name == "Torso" then
		damage =
			Utilities:Random(caliber.Damage.Torso.Min, caliber.Damage.Torso.Max)
	elseif hitPart.Name == "Head" then
		damage =
			Utilities:Random(caliber.Damage.Head.Min, caliber.Damage.Head.Max)
	else
		damage =
			Utilities:Random(caliber.Damage.Limb.Min, caliber.Damage.Limb.Max)
	end

	if tick() - healthInfo._lastDamage < 1 then
		healthInfo._collectiveDamage += damage
	else
		healthInfo._collectiveDamage = damage
	end

	if hitPart.Name:find("Arm") then
		if
			(healthInfo._collectiveDamage * Utilities:Random(0.7, 0.9))
			> Config.MedicalSystem.DamageForArmFracture
		then
			healthInfo.Fractured.Arm[hitPart.Name] = true
		end
	elseif hitPart.Name:find("Leg") then
		if
			(healthInfo._collectiveDamage * Utilities:Random(0.7, 0.9))
			> Config.MedicalSystem.DamageForLegFracture
		then
			healthInfo.Fractured.Leg[hitPart.Name] = true
		end
	end

	if healthInfo._collectiveDamage > 55 then
		healthInfo.Bleeding = 3
	elseif healthInfo._collectiveDamage > 35 then
		if healthInfo.Bleeding < 2 then
			healthInfo.Bleeding = 2
		end
	elseif healthInfo._collectiveDamage > 15 then
		if healthInfo.Bleeding < 1 then
			healthInfo.Bleeding = 1
		end
	end

	humanoid:TakeDamage(damage)
	healthInfo._lastDamage = tick()
end

function medicalSystem.registerCharacter(
	self: typeof(medicalSystem),
	character: Model
)
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		warn("could not find humanoid")
		return
	end
	humanoid.MaxHealth = Config.MedicalSystem.MaxHealth
	humanoid.Health = Config.MedicalSystem.MaxHealth
	local healthInfo = table.clone(defaultCharacterInfo)
	healthInfo.Humanoid = humanoid
	healthInfo._lastUpdate = tick()
	healthInfo._lastPosition = humanoid.RootPart.Position

	-- local torso = character:FindFirstChild("Torso") :: BasePart
	-- torso.Anchored = true
	-- task.delay(0.1, function()
	-- 	torso.Anchored = false
	-- end)

	self.characterInfos[character] = healthInfo
	character.AncestryChanged:Connect(function(child, parent)
		if not parent then
			self.characterInfos[character] = nil
		end
	end)
end

function medicalSystem.updateCharacter(
	self: typeof(medicalSystem),
	healthInfo: CharacterHealthInfo
)
	if
		not healthInfo.Humanoid.RootPart
		or not healthInfo.Humanoid.RootPart.Parent
	then
		return
	elseif healthInfo.Humanoid.Health <= 0 then
		return
	end

	local deltaTime = tick() - healthInfo._lastUpdate
	local studsMoved = (
		healthInfo._lastPosition - healthInfo.Humanoid.RootPart.Position
	).Magnitude

	local Pain = 0
	local BloodLoss = 0
	if healthInfo.Bleeding > 0 then
		BloodLoss += Config.MedicalSystem.BleedingRates[if healthInfo.Bleeding
				>= 2
			then "Heavy"
			elseif healthInfo.Bleeding >= 1 then "Medium"
			else "Light"] * (1 + (studsMoved / 15)) * deltaTime
		Pain += healthInfo.Bleeding * (1 + (studsMoved / 15)) * 2
		-- print(healthInfo.Blood, healthInfo.Bleeding)
	end
	healthInfo.Blood -= BloodLoss
	if healthInfo.Blood <= 0 then
		healthInfo.Humanoid.Health = 0
		return
	end

	if Config.MedicalSystem.EnableUnconsciousenss then
		if healthInfo.Blood <= Config.MedicalSystem.UnconsiousAt then
			if healthInfo.Conscious then
				Ragdoll:Ragdoll(healthInfo.Humanoid.RootPart.Parent :: Model)
				healthInfo.Conscious = false
			end
		elseif not healthInfo.Conscious then
			healthInfo.Conscious = true
			Ragdoll:Unragdoll(healthInfo.Humanoid.RootPart.Parent :: Model)
		end
	end

	for i, v in healthInfo.Fractured.Arm do
		if v then
			Pain += 1.25
		end
	end
	for i, v in healthInfo.Fractured.Leg do
		Pain += 1.25 * (1 + (studsMoved / 15))
	end
	healthInfo.Pain =
		Utilities:SmoothLerp(healthInfo.Pain, Pain, 0.5, deltaTime)

	healthInfo._lastUpdate = tick()
	healthInfo._lastPosition = healthInfo.Humanoid.RootPart.Position

	local player = game:GetService("Players")
		:GetPlayerFromCharacter(healthInfo.Humanoid.Parent :: Model)
	if player then
		ServerNetwork.MedicalUpdate.fire(player, healthInfo)
	end
end

function medicalSystem.update(self: typeof(medicalSystem))
	for i, v in self.characterInfos do
		self:updateCharacter(v)
	end
end

return medicalSystem
