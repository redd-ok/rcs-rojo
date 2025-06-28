local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Engine = ReplicatedStorage.RCS

local ClientNetwork = require(ReplicatedStorage.RCS.ClientNetwork)
local Types = require(Engine.Types)

local Modules = Engine:WaitForChild("Modules")
local FX = Engine:WaitForChild("FX")

local Utilities = require(Modules:WaitForChild("Utilities"))
local Projectile = require(Modules:WaitForChild("Projectile"))
local ProjectileV2 = require(Modules:WaitForChild("ProjectileV2"))

local States = require(script.Parent.states)
local Springs = require(script.Parent.springs)
local Variables = require(script.Parent.variables)

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character

local function PlaySFX(sfx: string, _loudness: number?)
	local loudness = _loudness or 1

	local Sounds: { Sound }
	local SoundsFolder = FX.SFX:FindFirstChild(sfx)
	if not SoundsFolder then
		local Sound: Sound = FX.SFX.Generic:FindFirstChild(sfx)
		if not Sound then
			error(sfx .. " sfx missing", 2)
			return
		end

		local Clone = Sound:Clone()
		Clone.Parent = SoundService
		Clone.PlaybackSpeed = Utilities:Random(0.85, 1.15)
		Clone.Volume += (Clone.Volume * loudness) + (Utilities:Random(-1, 1) * loudness)
		Clone:Play()
		task.delay(Clone.TimeLength / Clone.PlaybackSpeed, function()
			Clone:Destroy()
		end)

		return
	else
		Sounds = SoundsFolder:GetChildren() :: { Sound }
	end

	local Sound: Sound = Sounds[math.random(1, #Sounds)]
	if not Sound then
		return
	end

	local Clone = Sound:Clone()
	Clone.Parent = SoundService
	Clone.PlaybackSpeed = Utilities:Random(0.85, 1.15)
	Clone.Volume = (Clone.Volume * loudness)
		+ (Utilities:Random(-1, 1) * loudness)
	Clone:Play()

	task.delay(Clone.TimeLength / Clone.PlaybackSpeed, function()
		Clone:Destroy()
	end)
end

local function LoopingSounds(start)
	if not Variables.Viewmodel or not Variables.WeaponInHand then
		return
	end

	local Handle = Variables.WeaponInHand.Handle
	local Muzzle = Handle.Muzzle

	if not Muzzle:GetAttribute("LoopingSounds") then
		return
	end

	ClientNetwork.WeaponEvents.LoopingSounds_CTS.fire(start)

	if start then
		if
			Muzzle:GetAttribute("IndoorSounds")
			and Utilities:IsIndoors(Muzzle.WorldPosition, {
				Character,
				workspace.CurrentCamera,
			})
		then
			Muzzle.IndoorLoop.Playing = true
		else
			Muzzle.Loop.Playing = true
		end
	else
		Muzzle.Loop.Playing = false

		if Muzzle:GetAttribute("IndoorSounds") then
			Muzzle.IndoorLoop.Playing = false
			if
				Utilities:IsIndoors(Muzzle.WorldPosition, {
					Character,
					workspace.CurrentCamera,
				})
			then
				Muzzle.IndoorLoopTail:Play()
				return
			end
		end

		Muzzle.LoopTail:Play()
	end
end

local function UpdateServerStance()
	task.spawn(
		_G.StanceUpdate,
		States.characterState.Stance,
		States.characterState.LeaningState,
		States.gunState and States.gunState.GunStance or nil,
		States.characterState.Running
	)

	ClientNetwork.CharacterEvents.Stance_CTS.fire({
		characterStance = States.characterState.Stance,
		leaningState = States.characterState.LeaningState,
		gunStance = Variables.WeaponInHand and States.gunState.GunStance or nil,
		sprinting = States.characterState.Running,
	})
end

local function GetAnimObjs(): Types.AnimationsObject
	return {
		[1] = Variables.RArmWeld,
		[2] = Variables.LArmWeld,
		[3] = Variables.GunWeld,
		[4] = Variables.WeaponInHand,
		[5] = Variables.Viewmodel,
		[6] = Variables.WeaponData,

		GunState = States.gunState,
		CharacterState = States.characterState,
		PlaySFX = PlaySFX,
	}
end

local function RunCheck()
	if
		States.gunState.Reloading
		or not Variables.Viewmodel
		or not Variables.WeaponInHand
		or not Variables.AnimData
	then
		return
	end

	if States.characterState.Running then
		if States.gunState.Shooting then
			LoopingSounds(false)
		end

		States.gunState.Shooting = false
		if States.gunState.GunStance == "Normal" then
			Variables.AnimData.SprintAnim(GetAnimObjs())
		elseif States.gunState.GunStance == "HighReady" then
			Variables.AnimData.HighReady(GetAnimObjs())
		elseif States.gunState.GunStance == "LowReady" then
			Variables.AnimData.LowReady(GetAnimObjs())
		else
			Variables.AnimData.Patrol(GetAnimObjs())
		end
	else
		if States.gunState.GunStance == "Normal" then
			Variables.AnimData.IdleAnim(GetAnimObjs())
		elseif States.gunState.GunStance == "HighReady" then
			Variables.AnimData.HighReady(GetAnimObjs())
		elseif States.gunState.GunStance == "LowReady" then
			Variables.AnimData.LowReady(GetAnimObjs())
		else
			Variables.AnimData.Patrol(GetAnimObjs())
		end
	end
end

local function Shake(Intensity: number)
	Springs.GunShake.a = Vector3.new(2.4, -3.6, 3.2) * Intensity
	task.delay(0.1, function()
		Springs.GunShake.a = Vector3.new(2.4, -3.6, 3.2) * -Intensity
	end)
end

local function Recoil()
	if not Variables.WeaponData then
		return
	end

	local vr = (
		Utilities:Random(
			Variables.WeaponData.camRecoil.camRecoilUp[1],
			Variables.WeaponData.camRecoil.camRecoilUp[2]
		) / 2
	)
	local lr = (
		Utilities:Random(
			Variables.WeaponData.camRecoil.camRecoilLeft[1],
			Variables.WeaponData.camRecoil.camRecoilLeft[2]
		)
	)
	local rr = (
		Utilities:Random(
			Variables.WeaponData.camRecoil.camRecoilRight[1],
			Variables.WeaponData.camRecoil.camRecoilRight[2]
		)
	)
	local hr = (Utilities:Random(-rr, lr) / 2)
	local tr = (
		Utilities:Random(
			Variables.WeaponData.camRecoil.camRecoilTilt[1],
			Variables.WeaponData.camRecoil.camRecoilTilt[2]
		) / 2
	)

	local RecoilX = math.rad(vr * Utilities:Random2(1, 1, 0.1))
	local RecoilY = math.rad(hr * Utilities:Random2(-1, 1, 0.1))
	local RecoilZ = math.rad(tr * Utilities:Random2(-1, 1, 0.1))

	local gvr = (
		Utilities:Random(
			Variables.WeaponData.gunRecoil.gunRecoilUp[1],
			Variables.WeaponData.gunRecoil.gunRecoilUp[2]
		) / 10
	)
	local gdr = (
		Utilities:Random(
			Variables.WeaponData.gunRecoil.gunRecoilTilt[1],
			Variables.WeaponData.gunRecoil.gunRecoilTilt[2]
		) / 10
	)
	local glr = (
		Utilities:Random(
			Variables.WeaponData.gunRecoil.gunRecoilLeft[1],
			Variables.WeaponData.gunRecoil.gunRecoilLeft[2]
		)
	)
	local grr = (
		Utilities:Random(
			Variables.WeaponData.gunRecoil.gunRecoilRight[1],
			Variables.WeaponData.gunRecoil.gunRecoilRight[2]
		)
	)

	local ghr = (Utilities:Random(-grr, glr) / 10)

	Springs.RecoilX.a = ghr
	Springs.RecoilY.a = gvr
	Springs.RecoilZ.a = gdr
	Springs.RecoilKick.a = Variables.WeaponData.gunKick

	Springs.DeadzoneSpring.target += Vector2.new(ghr, gvr) / if Variables.WeaponData.Type
			== "Rifle"
		then 1.5
		else 3
	Springs.DeadzoneSpring.a = Vector2.new(ghr, gvr)

	Springs.CamRecoil.a = Vector3.new(RecoilX, RecoilY, RecoilZ)
	task.delay(0.1, function()
		Springs.CamRecoil.a = -Vector3.new(RecoilX, RecoilY, RecoilZ) * 1
	end)

	PlaySFX(
		if Variables.WeaponData.Type == "Rifle"
			then "RifleFoley"
			else "PistolFoley",
		0.1
	)
end

local function MuzzleFX()
	if not Variables.WeaponInHand or not Variables.WeaponData then
		return
	end
	local Handle = Variables.WeaponInHand.Handle
	local Muzzle = Handle.Muzzle

	if not Muzzle:GetAttribute("LoopingSounds") then
		if
			Muzzle:GetAttribute("IndoorSounds")
			and Utilities:IsIndoors(Muzzle.WorldPosition, {
				Character,
				workspace.CurrentCamera,
			})
		then
			Muzzle.Indoor:Play()
		else
			Muzzle.Fire:Play()
		end
	end

	local isNight = Lighting.ClockTime > 19 or Lighting.ClockTime < 7

	for i, v in Muzzle:GetChildren() do
		if v:IsA("ParticleEmitter") and v.Name ~= "OverHeat" then
			v:Emit(
				v:FindFirstChild("EmitCount") and v.EmitCount.Value
					or math.random(4, 6)
			)
		elseif v:IsA("Light") then
			v.Enabled = true

			task.delay(
				Utilities:Random(0.01, 0.06) * (isNight and 1.45 or 0.7),
				function()
					v.Enabled = false
				end
			)
		end
	end

	for i, v in Handle.Chamber:GetChildren() do
		if v:IsA("ParticleEmitter") and v.Name ~= "OverHeat" then
			v:Emit(
				v:FindFirstChild("EmitCount") and v.EmitCount.Value
					or math.random(4, 6)
			)
		elseif v:IsA("Light") then
			v.Enabled = true

			task.delay(
				Utilities:Random(0.01, 0.06) * (isNight and 1.45 or 0.7),
				function()
					v.Enabled = false
				end
			)
		end
	end

	if Variables.WeaponData.Chambered or not Variables.WeaponData.SlideLock then
		TweenService:Create(
			Variables.WeaponInHand.Handle.Slide,
			TweenInfo.new(
				30 / Variables.WeaponData.ShootRate,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut,
				0,
				true,
				0
			),
			{
				C0 = Variables.WeaponData.SlideEx:Inverse(),
			}
		):Play()
	elseif
		not Variables.WeaponData.Chambered and Variables.WeaponData.SlideLock
	then
		TweenService:Create(
			Variables.WeaponInHand.Handle.Slide,
			TweenInfo.new(
				30 / Variables.WeaponData.ShootRate,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut,
				0,
				false,
				0
			),
			{
				C0 = Variables.WeaponData.SlideEx:Inverse(),
			}
		):Play()
	end

	--Utilities:ShellEject(Handle.Chamber.WorldCFrame, Variables.WeaponTool:GetAttribute("Caliber"))

	States.gunState.OverHeat = 5
end

local function ADSMesh()
	if not Variables.WeaponInHand or not Variables.WeaponData then
		return
	end

	for i, v in Variables.WeaponInHand:GetChildren() do
		if not v:IsA("BasePart") then
			continue
		end

		local AimpartData =
			Variables.WeaponData.Aimparts[States.gunState.Aimpart]

		if table.find(AimpartData.InvisOnAim, v.Name) then
			v.Transparency = if States.gunState.Aiming then 1 else 0
		elseif table.find(AimpartData.VisOnAim, v.Name) then
			v.Transparency = if States.gunState.Aiming then 0 else 1
		elseif AimpartData.ResetTransparency[v.Name] then
			v.Transparency = AimpartData.ResetTransparency[v.Name]
		end
	end
end

local function doShoot()
	if
		not Variables.WeaponInHand
		or not Variables.WeaponData
		or not Variables.AnimData
	then
		return
	end

	States.gunState.ShootDelay = true
	task.spawn(Recoil)
	Shake(0.8)

	local id = ProjectileV2:GetId()
	ProjectileV2:Spawn(
		Variables.WeaponInHand.Handle.Muzzle.WorldCFrame,
		Projectile:GetCaliber(
			(Variables.WeaponTool :: Tool):GetAttribute("Caliber") :: string
		) :: Types.Caliber,
		LocalPlayer,
		id
	)
	ClientNetwork.WeaponEvents.Shoot_CTS.fire({
		id = id,
		position = Variables.WeaponInHand.Handle.Muzzle.WorldCFrame,
		tool = Variables.WeaponTool :: Tool,
	})

	PlaySFX("Trigger")

	Variables.WeaponData.AmmoInGun -= 1
	if Variables.WeaponData.AmmoInGun == 0 then
		Variables.WeaponData.Chambered = false
	end

	MuzzleFX()

	if
		Variables.WeaponData.Firemode == 4
		or Variables.WeaponData.Firemode == 5
	then
		Variables.AnimData.PumpAnim(GetAnimObjs())
	else
		task.wait(60 / Variables.WeaponData.ShootRate)
	end
	States.gunState.ShootDelay = false
end

return {
	PlaySFX = PlaySFX,
	LoopingSounds = LoopingSounds,
	UpdateServerStance = UpdateServerStance,
	GetAnimObjs = GetAnimObjs,
	RunCheck = RunCheck,
	Shake = Shake,
	Recoil = Recoil,
	MuzzleFX = MuzzleFX,
	ADSMesh = ADSMesh,
	doShoot = doShoot,
}
