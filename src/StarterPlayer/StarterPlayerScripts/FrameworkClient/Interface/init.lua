Typing = require(script.Parent.Typing)
return function(Framework: Typing.FrameworkType)
	-- INITILAIZATION
	local Interface = {
		UI = Framework.Services.Players.LocalPlayer.PlayerGui:FindFirstChild('InterfaceUI') or Framework.Services.Players.LocalPlayer.PlayerGui:WaitForChild('InterfaceUI'),
		Mobile = nil,
		Container = nil,
		StatsPanel = nil
	}
	
	Interface.Mobile = Interface.UI:FindFirstChild("Mobile") or Interface.UI:WaitForChild("Mobile")
	Interface.Container = Interface.UI:FindFirstChild('Container') or Interface.UI:WaitForChild('Container')
	Interface.StatsPanel = Interface.Container.StatsPanel.Container

	-- STRUCTURE

	require(script.StatsPanel)(Framework, Interface)
	require(script.Mobile)(Framework, Interface)
	require(script.Buttons)(Framework, Interface)

	-- FINALIZE
	
	Interface.UI.Enabled = true
	Framework.Logger.debug('[ INTERFACE / DEBUG ]', 'Initialized interface, processing visuals.')

	return Interface
end