local actor = script:GetActor()
local connection: RBXScriptConnection
connection = actor:BindToMessage("INIT", function(module: ModuleScript)
	require(module):init(actor, function(...)
		(script.Parent:FindFirstChild("callback") :: BindableEvent):Fire(...)
	end)

	connection:Disconnect()
	actor:SetAttribute("ready", true)
end)
