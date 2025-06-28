--!native
--!optimize 2

local isServer = game:GetService("RunService"):IsServer()

local actorContainer = Instance.new("Folder")
actorContainer.Name = "ACTOR_CONTAINER"
actorContainer.Parent = if isServer
	then game:GetService("ServerScriptService")
	else game:GetService("ReplicatedFirst")

local actorTemplate = Instance.new("Actor")
actorTemplate:SetAttribute("used", 0)
actorTemplate.Parent = script

local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "callback"
bindableEvent.Parent = actorTemplate

local controller = (if isServer
	then script.serverActorController
	else script.clientActorController):Clone()
controller.Name = "controller"
controller.Parent = actorTemplate

type DispatcherProps = {
	Module: ModuleScript,
	Actors: { Actor },
}
type DispatcherProto = {
	Callback: (...any) -> (),
	AllocateActors: (self: Dispatcher, amount: number) -> (),
	SendMessage: (self: Dispatcher, message: string, ...any) -> (),
	SendMessageAll: (self: Dispatcher, message: string, ...any) -> (),
}
type Dispatcher = typeof(setmetatable({} :: DispatcherProps, {
	__index = {} :: DispatcherProto,
}))

local Dispatcher = {}
Dispatcher.__index = Dispatcher

function Dispatcher.new(
	module: ModuleScript,
	callback: (...any) -> ()
): Dispatcher
	return setmetatable({
		Module = module,
		Callback = callback,
		Actors = {},
	}, Dispatcher)
end

function Dispatcher:AllocateActors(amount: number)
	local actors = {}

	for i = 1, amount do
		local actor = actorTemplate:Clone()
		actor.Parent = actorContainer
		actor.Name = `Actor{#self.Actors + i}`
		actor.controller.Enabled = true;
		(actor:FindFirstChild("callback") :: BindableEvent).Event:Connect(
			self.Callback
		)

		table.insert(actors, actor)
	end

	game:GetService("RunService").Heartbeat:Wait()

	for i, v in actors do
		v:SendMessage("INIT", self.Module)
	end

	table.move(actors, 1, #actors, #self.Actors + 1, self.Actors)
end

function Dispatcher:SendMessage(message: string, ...: any)
	local actor: Actor?, used: number = nil, math.huge
	for i, v in actorContainer:GetChildren() do
		if v:GetAttribute("used") < used then
			actor = v
			used = v:GetAttribute("used")
		end
	end

	if actor then
		if not actor:GetAttribute("ready") then
			print("not ready")
			while true do
				local attribute = actor.AttributeChanged:Wait()
				if attribute == "ready" then
					break
				end
			end
		end

		actor:SetAttribute("used", used + 1)
		actor:SendMessage(message, ...)
	end
end

function Dispatcher:SendMessageAll(message: string, ...: any)
	for _, actor in self.Actors do
		if not actor:GetAttribute("ready") then
			while true do
				local attribute = actor.AttributeChanged:Wait()
				if attribute == "ready" then
					break
				end
			end
		end

		actor:SendMessage(message, ...)
	end
end

return Dispatcher
