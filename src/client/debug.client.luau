local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Engine = game:GetService("ReplicatedStorage"):WaitForChild("RCS")

local Config = require(Engine:WaitForChild("RCS_Config"))
if not Config.Debug then
	script:Destroy()
	return
end

local Modules = Engine:WaitForChild("Modules")

local Iris = require(Modules:WaitForChild("Iris"))
local ProjectileV2 = require(Modules:WaitForChild("ProjectileV2"))

local windowOpen = Iris.State(false)
UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
	if gameProcessed then
		return
	end

	if inputObject.KeyCode == Config.DebugGUI then
		windowOpen:set(not windowOpen:get())
		if
			not windowOpen:get()
			and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
			and LocalPlayer.Character
				:FindFirstChildWhichIsA("Tool")
				:FindFirstChild("RCS_Settings")
		then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		end
	end
end)
local projectileVisualizer = Iris.VariableState(false, function(newValue)
	ProjectileV2.MultiThread:SendMessageAll("setdebug", newValue)
end)
local projectileGravity = Iris.VariableState(true, function(newValue)
	workspace:SetAttribute("DISABLE_PROJECTILE_GRAVITY", not newValue)
end)
local projectileLifetimeDecay = Iris.VariableState(true, function(newValue)
	workspace:SetAttribute("DISABLE_PROJECTILE_LIFETIME_DECAY", not newValue)
end)
local projectileDistanceDecay = Iris.VariableState(true, function(newValue)
	workspace:SetAttribute("DISABLE_PROJECTILE_DISTANCE_DECAY", not newValue)
end)
local projectileVisibility = Iris.VariableState(false, function(newValue)
	for i, v in
		(workspace.RCS_Workspace.Client:FindFirstChild(
			"__PROJECTILES_CONTAINER"
		) :: Folder):GetChildren()
	do
		v.Transparency = if newValue then 0 else 1
	end
end)
local projectileTimeScale = Iris.VariableState(1, function(newValue)
	workspace:SetAttribute("PROJECTILE_SIMULATION_TIME_SCALE", newValue)
end)
local projectileTimeScaleToggle = Iris.VariableState(false, function(newValue)
	if not newValue then
		workspace:SetAttribute("PROJECTILE_SIMULATION_TIME_SCALE", nil)
	else
		workspace:SetAttribute(
			"PROJECTILE_SIMULATION_TIME_SCALE",
			projectileTimeScale:get()
		)
	end
end)
local freezeViewmodel = Iris.VariableState(false, function(newValue)
	workspace:SetAttribute("FREEZE_VIEWMODEL", newValue)
end)

Iris.Init()
Iris:Connect(function()
	Iris.Window({ "Debug Window" }, { isOpened = windowOpen })

	if windowOpen:get() then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		local tree = Iris.Tree({ "Projectiles" })

		if not tree.collapsed() then
			local multithreadingTree = Iris.Tree({ "Multithreading" })
			if not multithreadingTree.collapsed() then
				Iris.Text(
					`Amount of actors active: {#ProjectileV2.MultiThread.Actors}`
				)
				local amountSlider = Iris.SliderNum({ "Amount", 1, 0, 64 })
				if Iris.Button("Spawn actors").clicked() then
					task.spawn(function()
						ProjectileV2.MultiThread:AllocateActors(
							amountSlider.state.number:get()
						)
						ProjectileV2.MultiThread:SendMessageAll(
							"setdebug",
							projectileVisualizer:get()
						)
					end)
				end
				if Iris.Button("Remove actors").clicked() then
					local amount = amountSlider.state.number:get() - 1
					for i = #ProjectileV2.MultiThread.Actors - amount, #ProjectileV2.MultiThread.Actors do
						ProjectileV2.MultiThread.Actors[i]:Destroy()
						ProjectileV2.MultiThread.Actors[i] = nil
					end
				end
			end
			Iris.End()

			Iris.Text(
				`Active: {ProjectileV2.activeProjectiles} / {ProjectileV2._maxProjectiles}`
			)
			Iris.Checkbox("Gravity", { isChecked = projectileGravity })
			Iris.Checkbox(
				"Simulation time scale",
				{ isChecked = projectileTimeScaleToggle }
			)
			if projectileTimeScaleToggle:get() then
				Iris.SliderNum(
					{ nil, 0.1, 0.1, 10 },
					{ number = projectileTimeScale }
				)
			end
			Iris.Checkbox(
				"Lifetime decay",
				{ isChecked = projectileLifetimeDecay }
			)
			Iris.Checkbox(
				"Distance decay",
				{ isChecked = projectileDistanceDecay }
			)
			Iris.Checkbox("Visible parts", { isChecked = projectileVisibility })
			Iris.Checkbox("Visualizer", { isChecked = projectileVisualizer })
			if Iris.Button("Cleanup").clicked() then
				local container = workspace.RCS_Workspace.Client:FindFirstChild(
					"__DEBUG_CONTAINER"
				)
				if container then
					container:ClearAllChildren()
				end
			end
		end
		Iris.End()

		Iris.Checkbox("Freeze viewmodel", {
			isChecked = freezeViewmodel,
		})
	end
	Iris.End()
end)
