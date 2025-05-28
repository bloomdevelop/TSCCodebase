local Typing = require(script.Parent.Typing)

return function(Framework: Typing.FrameworkType)
	-- INITIALIZATION
	local UserInput: Typing.UserInputTyping = {
		Mobile = false,
		KeysDown = {},
		BoundInputs = {
			['KeyCode'] = {},
			['UserInputType'] = {},
		},
	}

	-- STRUCTURE
	
	function UserInput.AddInput(self, name: string, inputs: Typing.InputEnumType | { Typing.InputEnumType }, func: (...any) -> (...any), options: Typing.InputOptions): nil
		for _, input: EnumItem in next, (type(inputs) == 'table' and inputs or { inputs }) do
			assert(typeof(input) == 'EnumItem', 'Invalid argument, must provide an enum item')
			assert((input.EnumType == Enum.KeyCode) or (input.EnumType == Enum.UserInputType), 'Invalid argument, must provide a KeyCode or UserInputType enum item')
			assert(typeof(func) == 'function', 'Invalid argument, must provide a function')
			local bounding: Typing.InputList = (input.EnumType == Enum.KeyCode) and UserInput.BoundInputs['KeyCode'] or UserInput.BoundInputs['UserInputType']
			if not bounding[input] then
				bounding[input] = {}
			end
			if not options then
				options = {}
			end
			options.state = options.state or Enum.UserInputState.Begin
			if not bounding[input][options.state] then
				bounding[input][options.state] = {}
			end
			table.insert(bounding[input][options.state], {
				Name = name,
				Enabled = true,
				Function = func,
				CheckText = options.checkText or false
			})
			Framework.Logger.debug('[ USERINPUT / DEBUG ]', string.format('Added input "%s" to %s.%s, with state %s.', name, tostring(input.EnumType), input.Name, options.state.Name))
			table.clear(options)
		end
	end
	
	function UserInput:RemoveInput(name): nil
		for bound, inputList: Typing.InputList in next, UserInput.BoundInputs do
			for inputType: EnumItem, stateList: Typing.StateList in next, inputList do
				for state: EnumItem, array: Typing.InputObjectArray in next, stateList do
					for i, inputObject: Typing.InputObject in next, array do
						if inputObject.Name == name then
							table.remove(array, i)
							Framework.Logger.debug('[ USERINPUT / DEBUG ]', string.format('Removed input "%s" from %s.%s, with state %s.', name, bound, inputType.Name, state.Name))
						end
					end
				end
			end
		end
	end
	
	local function handleInput(io: InputObject, gp: boolean, enabled: boolean)
		if io.UserInputType == Enum.UserInputType.Touch then
			UserInput.Mobile = true
		end
		local input: EnumItem = (io.KeyCode.Name ~= 'Unknown') and io.KeyCode or io.UserInputType
		local inputState: Enum.UserInputState = io.UserInputState
		local inputTable: Typing.InputList = io.UserInputType.Name:find('Gamepad') and UserInput.BoundInputs['UserInputType'] or UserInput.BoundInputs['KeyCode']
		if input.EnumType == Enum.KeyCode then
			UserInput.KeysDown[io.KeyCode] = enabled
		end
		if inputTable[input] and inputTable[input][inputState] then
			for _, obj: Typing.InputObject in next, inputTable[input][inputState] do
				task.spawn(function()
					if obj.Enabled then
						if obj.CheckText then
							local textbox = Framework.Services.UserInputService:GetFocusedTextBox()
							if textbox then
								return
							end
						end
						obj.Function(input, gp)
					end
				end)
			end
		end
	end
	
	-- FINALIZE

	for _, key in next, Enum.KeyCode:GetEnumItems() do
		UserInput.KeysDown[key] = false
	end
	
	Framework.Services.UserInputService.InputBegan:Connect(function(...) handleInput(..., true) end)
	Framework.Services.UserInputService.InputEnded:Connect(function(...) handleInput(..., false) end)

	Framework.Logger.debug('[ USERINPUT / DEBUG ]', 'Initialized user input, listening to inputs.')

	return UserInput
end
