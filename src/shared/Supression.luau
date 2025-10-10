local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RCS = ReplicatedStorage.RCS
local Modules = RCS.Modules

local CurrentCamera = workspace.CurrentCamera

local Config = require(RCS:WaitForChild("RCS_Config"))
local Spring = require(Modules:WaitForChild("Spring"))

local Hud = Players.LocalPlayer.PlayerGui:WaitForChild("RCS_Hud")

local Suppression = {}

Suppression.Spring = Spring.new(Vector2.new(), 42, 0.6)
Suppression.State = {
	current = 0,
	last = 0,
	disorientation = 0,
}

function Suppression:Supress(intensity: number, origin: Vector3)
	if not Config.Suppression then
		return
	end

	if Config.Suppression.CameraShake then
		local cframe = CFrame.new(CurrentCamera.CFrame.Position, origin)
		local rX, rY, _rZ = cframe:ToOrientation()
		local a = -Vector2.new(rX, rY).Unit * intensity

		CurrentCamera.CFrame *= CFrame.Angles(
			0,
			(-a.Y / 100) * Config.Suppression.CameraShakeKick,
			0
		) * CFrame.Angles(
			(-a.X / 100) * Config.Suppression.CameraShakeKick,
			0,
			0
		)

		Suppression.Spring.a = (-a / 7) * Config.Suppression.CameraShakeKick
		task.delay(0.1, function()
			Suppression.Spring.a = (a / 7) * Config.Suppression.CameraShakeKick
		end)
	end

	Suppression.State.current = math.min(
		Suppression.State.current + intensity,
		Config.Suppression.MaxSuppression
	)
	Suppression.State.last = tick()
end

function Suppression:Update(deltaTime: number)
	if not Config.Suppression.Enabled then
		return
	end

	if Config.Suppression.CameraShake then
		local springPosition = Suppression.Spring.position / 88

		CurrentCamera.CFrame *= CFrame.Angles(0, springPosition.Y, 0) * CFrame.Angles(
			springPosition.X,
			0,
			0
		)
	end

	local transp = 1
		- (
			(Suppression.State.current / Config.Suppression.MaxSuppression)
			* Config.Suppression.VignetteIntensity
		)

	Lighting.SuppressionBlur.Size = (
		Suppression.State.current / Config.Suppression.MaxSuppression
	) * Config.Suppression.BlurIntensity

	local instances = Hud.SuppressionVignettes:GetChildren()
	for i, v: ImageLabel in instances do
		v.ImageTransparency = transp
	end

	if
		Suppression.State.current > 0
		and tick() - Suppression.State.last
			> Config.Suppression.DissipationDelay
	then
		Suppression.State.current = math.max(
			Suppression.State.current
				- (Config.Suppression.DissipationRate * deltaTime),
			0
		)
	end
end

return Suppression
