local actor = script.Parent
local connection: RBXScriptConnection
connection = actor:BindToMessage("INIT", function(module: ModuleScript)
	local m = module:Clone()
	m.Parent = module.Parent
	require(m):init(actor, function(...)
		(script.Parent:FindFirstChild("callback") :: BindableEvent):Fire(...)
	end)

	connection:Disconnect()
	actor:SetAttribute("ready", true)
end)
