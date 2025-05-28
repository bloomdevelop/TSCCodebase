-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local cs = game:GetService("CollectionService")

local remotesFolder = rst.Remotes

local plr = game.Players.LocalPlayer

local mouse = plr:GetMouse()

local ui = script.Parent

local canvas = ui.Canvas
local difficultySelect = ui.DifficultySelect
local practiceResults = ui.PracticeResults

local grid = {}

local difficulties = {
	[0] = {GridSize = 1, CellSize = 50, Mines = 0, Hints = 99},
	{GridSize = 6, CellSize = 25, Mines = 3, Hints = 5},
	{GridSize = 8, CellSize = 25, Mines = 8, Hints = 5},
	{GridSize = 9, CellSize = 22, Mines = 12, Hints = 4},
	{GridSize = 16, CellSize = 20, Mines = 50, Hints = 3},
	{GridSize = 30, CellSize = 16, Mines = 270, Hints = 2}
}

local firstClick = false

local currentDoor = nil
local currentDifficultyLevel = nil

local practicing = false

local hintsLeft = 0
local hintEquipped = false

local hackBeganTimestamp = os.clock()

local rng = Random.new()

local function make2DArray(columns, rows)
	local array = {}
	for i=1,columns do
		array[i] = {}
	end

	return array
end

function checkForWin()
	for x=1,#grid do
		local column = grid[x]
		for y=1, #column do
			local cell = column[y]
			if cell.HasMine == false and cell.Revealed == false then
				return false
			end
		end
	end

	return true
end

function equipHint()
	canvas.Hints.Instructions.Visible = true
	canvas.Hints.Container.Button.ImageTransparency = 1
	hintEquipped = true

	ui.HintEquipped.Visible = true
end

function unequipHint()
	canvas.Hints.Instructions.Visible = false
	canvas.Hints.Container.Button.ImageTransparency = 0
	hintEquipped = false

	ui.HintEquipped.Visible = false
end

function updateHints()
	canvas.Hints.HintsLeft.Text = hintsLeft.." hints available"
	if hintsLeft == 0 then
		canvas.Hints.HintsLeft.TextTransparency = 0.5
		canvas.Hints.Container.Visible = false
	else
		canvas.Hints.HintsLeft.TextTransparency = 0
		canvas.Hints.Container.Visible = true
	end
end

local cell = {}
cell.__index = cell

function cell.new(x, y, cellSize)
	local self = setmetatable({}, cell)

	self.X = x
	self.Y = y

	self.HasMine = false
	self.Revealed = false
	self.Locked = false

	self.UI = script.Cell:Clone()

	self.UI.Size = UDim2.new(0, cellSize, 0, cellSize)
	self.UI.Position = UDim2.new(0, (x-1)*cellSize, 0, (y-1)*cellSize)
	self.UI.Hidden.Visible = true

	self.UI.Parent = canvas

	local lastM1Down = 0
	local lastM2Down = 0

	local M1IsDown = false
	local M2IsDown = false

	self.Flagged = false

	self.UI.Button.MouseButton1Down:Connect(function()
		M1IsDown = true
		lastM1Down = os.clock()
	end)

	self.UI.Button.MouseButton2Down:Connect(function()
		M2IsDown = true
		lastM2Down = os.clock()
	end)

	self.UI.Button.MouseLeave:Connect(function()
		M1IsDown = false
		M2IsDown = false
	end)

	self.UI.Button.MouseButton1Up:Connect(function()
		if M1IsDown == false then return end
		M1IsDown = false

		if self.Locked == true then return end

		local m1HeldDuration = os.clock() - lastM1Down
		local m2HeldDuration = os.clock() - lastM2Down

		if hintEquipped == true then
			if self.Revealed == false then
				-- Using hint
				self.Locked = true

				if self.HasMine == true then
					self:flag()
				else
					self:reveal()
				end

				self.UI.BackgroundColor3 = Color3.new(0.854902, 0.764706, 0.494118)
				self.UI.BorderColor3 = Color3.new(0.505882, 0.45098, 0.290196)

				self.UI.Hidden.BackgroundColor3 = Color3.new(1, 0.894118, 0.576471)
				self.UI.Hidden.BorderColor3 = Color3.new(0.639216, 0.592157, 0.364706)

				hintsLeft = hintsLeft-1

				unequipHint()
				updateHints()
			end
		elseif m1HeldDuration < 0.5 then
			-- M1 short click
			if self.Revealed == false and self.Flagged == false then
				-- Reveal cell
				self:reveal()
			elseif self.Revealed == true and m2HeldDuration < 0.5 then
				-- M1 and M2 were both clicked
				-- Attempt to chord
				self:chord()
			end
		else
			-- M1 long click
			if self.Revealed == false then
				self:flag()
			else
				-- Attempt to chord
				self:chord()
			end
		end
	end)

	self.UI.Button.MouseButton2Up:Connect(function()
		if M2IsDown == false then return end
		M2IsDown = false

		local m1HeldDuration = os.clock() - lastM1Down
		local m2HeldDuration = os.clock() - lastM2Down

		if self.Revealed == false and self.Locked == false then
			self:flag()
		elseif m1HeldDuration < 0.5 and m2HeldDuration < 0.5 then
			-- Attempt to chord
			self:chord()
		end
	end)

	return self
end

local function clearBoard()
	for x=1, #grid do
		local column = grid[x]
		for y=1, #column do
			local cell = column[y]
			cell.UI:Destroy()

			cell = nil
		end
	end

	grid = {}
end

local function getTool()
	local heldTool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
	if heldTool and heldTool.Name == "Keycard Scrambler" then
		return heldTool
	end

	return nil
end

local function placeMine()
	local columns = #grid
	local rows = columns

	local x = rng:NextInteger(1, columns)
	local y = rng:NextInteger(1, rows)

	local cell = grid[x][y]
	if cell.HasMine == true then
		local xResets = 0
		repeat
			-- Shift right
			x = x+1

			if x > columns then
				-- Reset X to 1
				xResets = xResets+1
				x = 1

				-- Shift up
				y = y+1

				if y > rows then
					-- Reset Y to 1
					y = 1
				end
			end

			-- Get new cell
			cell = grid[x][y]
		until cell.HasMine == false
	end

	cell.HasMine = true
end

function updateFlagCounter()
	local totalFlags = 0

	for x=1, #grid do
		local column = grid[x]
		for y=1, #column do
			local cell = column[y]
			if cell.Flagged == true then
				totalFlags = totalFlags+1
			end
		end
	end

	local unflaggedMines = difficulties[currentDifficultyLevel].Mines - totalFlags

	if unflaggedMines < 0 then
		canvas.MinesLeft.Text = "what are you even doing"
	else
		canvas.MinesLeft.Text = unflaggedMines.." unflagged mines"
	end
end

local function setupBoard(difficultyLevel)
	clearBoard()

	local difficultyData = difficulties[difficultyLevel]

	local columns = difficultyData.GridSize
	local rows = columns
	local cellSize = difficultyData.CellSize

	local mines = difficultyData.Mines

	firstClick = true

	canvas.Size = UDim2.new(0, columns*cellSize, 0, rows*cellSize)

	grid = make2DArray(columns, rows)

	for x=1, columns do
		for y=1, rows do
			grid[x][y] = cell.new(x, y, cellSize)
		end
	end

	for i=1, mines do
		placeMine()
	end

	updateFlagCounter()

	canvas.Visible = true
end

function selectDoor(newDoor : Model, won : boolean, difficultyOverride : number)
	if newDoor ~= nil then
		local char = plr.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then
				local tool = getTool()
				if practicing == true or tool ~= nil then
					local difficultyLevel
					if difficultyOverride == nil then
						local clearanceLevel = newDoor.ClearanceLevel
						if clearanceLevel.Value >= 0 and clearanceLevel.Value <= #difficulties then
							difficultyLevel = clearanceLevel.Value
							if clearanceLevel:FindFirstChild("and") then
								difficultyLevel = math.clamp(difficultyLevel+2, 0, 5)
							end

							if tool.ActiveUpgrades.Difficulty.Value == true then
								difficultyLevel = math.clamp(difficultyLevel-1, 0, 5)
							end
						end
					else
						difficultyLevel = difficultyOverride
					end

					if difficultyLevel ~= nil then
						currentDoor = newDoor
						currentDifficultyLevel = difficultyLevel

						hintsLeft = difficulties[difficultyLevel].Hints
						updateHints()

						setupBoard(difficultyLevel)

						local diedConnection = hum.Died:Connect(function()
							selectDoor(nil)
						end)

						while currentDoor == newDoor do
							task.wait(.03333)
							local char = plr.Character
							if not char then selectDoor(nil) break end

							local root = char:FindFirstChild("HumanoidRootPart")
							if not root then selectDoor(nil) break end

							local distance = (root.Position - newDoor.PrimaryPart.Position).Magnitude
							if distance > 12 then selectDoor(nil) break end
						end

						diedConnection:Disconnect()
					end
				end
			end
		end
	else
		if hintEquipped == true then
			unequipHint()
		end

		currentDoor = nil
		practicing = false
		currentDifficultyLevel = nil

		canvas.Visible = false

		clearBoard()

		remotesFolder.Doors.StopHack:FireServer(won)
	end
end

function cell:flag()
	self.Flagged = not self.Flagged
	self.UI.Flag.Visible = self.Flagged

	if self.Flagged == true then
		script.Flag:Play()
	else
		script.Unflag:Play()
	end

	updateFlagCounter()
end

local countColors = {
	Color3.new(0, 0, 1),
	Color3.new(0, .4, 0),
	Color3.new(1, 0, 0),
	Color3.new(0, 0, .5),
	Color3.new(.5, 0, 0),
	Color3.new(0, 0.5, 0.5),
	Color3.new(0, 0, 0),
	Color3.new(0.4, 0.4, 0.4),
}

local neighborOffsets = {
	{-1, -1},
	{0, -1},
	{1, -1},

	{-1, 0},
	{1, 0},

	{-1, 1},
	{0, 1},
	{1, 1},
}

function cell:chord()
	local neighboringMines, neighboringFlags = self:countNeighboringMines()

	if neighboringFlags == neighboringMines then
		-- Enough flags to chord
		local cellsRevealed = 0

		-- Reveal all unflagged neighbors
		for i,offset in pairs(neighborOffsets) do
			local neighborX, neighborY = self.X + offset[1], self.Y + offset[2]

			local column = grid[neighborX]
			if column then
				local neighborCell = column[neighborY]
				if neighborCell ~= nil and neighborCell.Locked == false and neighborCell.Flagged == false and neighborCell.Revealed == false then
					local success = neighborCell:reveal(true)
					if success == false then return end

					cellsRevealed = cellsRevealed+1
				end
			end
		end

		if cellsRevealed == 1 then
			script.SingleReveal:Play()
		elseif cellsRevealed > 1 then
			script.MultiReveal:Play()
		end
	end
end

local function add0IfSingleDigit(number)
	if tonumber(number) < 10 then
		return "0"..number
	else
		return number
	end
end

local function formatSeconds(seconds : number)
	local hours = math.floor(seconds/60/60)
	local minutes = math.floor(seconds/60)

	local minutesRemainder =  minutes - (hours*60)
	local secondsRemainder = seconds - (minutes*60)

	secondsRemainder = math.floor(secondsRemainder*100)/100

	local formattedString = ""
	if hours > 0 then
		formattedString = hours..":"..add0IfSingleDigit(minutesRemainder)
	elseif minutesRemainder > 0 then
		formattedString = tostring(minutesRemainder)
	end

	if minutes > 0 then
		formattedString = formattedString..":"..add0IfSingleDigit(secondsRemainder)
	else
		formattedString = secondsRemainder.."s"
	end

	return formattedString
end

function cell:reveal(muted)
	if self.Revealed == true then return true end

	self.Revealed = true

	if firstClick == true then
		hackBeganTimestamp = os.clock()
		firstClick = false

		if self.HasMine == true then
			-- Move mine
			self.HasMine = false
			placeMine()
		end
	end

	self.UI.Hidden.Visible = false

	if self.HasMine == true then
		-- Fail
		if practicing == false then
			script.Fail:Play()
			selectDoor(nil, false)
		else
			-- Player was practicing. Lock the board and reveal all mines.
			script.PracticeFail.TimePosition = 0.08
			script.PracticeFail:Play()

			self.UI.Mine.Visible = true
			self.UI.Hidden.Visible = false

			self.UI.BackgroundColor3 = Color3.new(1, 0, 0)

			for columnIndex,column in pairs(grid) do
				for rowIndex,cell in pairs(column) do
					cell.Locked = true

					if cell.Revealed == false then
						if cell.HasMine == true then
							cell.UI.Mine.Visible = true
							cell.UI.Hidden.Visible = false

							cell.UI.BackgroundColor3 = Color3.new(1, 0, 0)
						elseif cell.HasMine == false and cell.Flagged == true then
							cell.UI.Flag.Wrong.Visible = true
						end
					end
				end
			end
		end

		remotesFolder.Doors.StopHack:FireServer(false)

		return false
	else
		local neighboringMines = self:countNeighboringMines()

		if neighboringMines > 0 then
			self.UI.Number.Text = tostring(neighboringMines)
			self.UI.Number.TextColor3 = countColors[neighboringMines]

			self.UI.Number.Visible = true

			if not muted then
				script.SingleReveal:Play()
			end
		else
			-- Reveal all neighbors
			for i,offset in pairs(neighborOffsets) do
				local neighborX, neighborY = self.X + offset[1], self.Y + offset[2]

				local column = grid[neighborX]
				if column then
					local neighborCell = column[neighborY]
					if neighborCell ~= nil and neighborCell.Revealed == false then
						neighborCell:reveal(true)
					end
				end
			end

			if not muted then
				script.MultiReveal:Play()
			end
		end

		-- Check for win
		local win = checkForWin()
		if win then
			if practicing == false then
				script.Win:Play()
			else
				script.PracticeWin:Play()

				local runTime = os.clock() - hackBeganTimestamp

				practiceResults.Difficulty.Text = "LEVEL "..currentDifficultyLevel.." HACK COMPLETED!"
				practiceResults.Time.Text = "Your time: "..formatSeconds(runTime)

				practiceResults.Visible = true

				task.delay(5, function()
					practiceResults.Visible = false
				end)
			end

			selectDoor(nil, true)
		end

		return true
	end
end

function cell:countNeighboringMines()
	local neighboringMines = 0
	local neighboringFlags = 0

	for i,offset in pairs(neighborOffsets) do
		local neighborX, neighborY = self.X + offset[1], self.Y + offset[2]

		local column = grid[neighborX]
		if column then
			local neighborCell = column[neighborY]
			if neighborCell ~= nil then
				if neighborCell.HasMine == true then
					neighboringMines += 1
				end
				if neighborCell.Flagged == true then
					neighboringFlags += 1
				end
			end
		end
	end

	return neighboringMines, neighboringFlags
end

local function startPractice(cabinet : Model)
	practicing = true

	local selectedDifficulty = nil

	local buttons = {}
	for i=1, #difficulties do
		local button = script.DifficultyButton:Clone()
		local hue = 0.333 - (0.333 * ((i-1)/(#difficulties-1)))

		button.BackgroundColor3 = Color3.fromHSV(hue, .7, .9)
		button.BorderColor3 = Color3.fromHSV(hue, .7, .7)

		button.Text = "Level "..i
		button.LayoutOrder = i

		button.Parent = difficultySelect.Options

		buttons[i] = button

		button.MouseButton1Down:Connect(function()
			selectedDifficulty = i
			difficultySelect.Visible = false
		end)
	end

	difficultySelect.Visible = true

	while selectedDifficulty == nil do
		task.wait(.033333)
		local char = plr.Character
		if not char then break end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then break end

		local distance = (root.Position - cabinet.PrimaryPart.Position).Magnitude
		if distance > 12 then break end
	end

	for i,button in pairs(buttons) do
		button:Destroy()
	end

	if selectedDifficulty ~= nil then
		-- Difficulty selected
		remotesFolder.Doors.StartHack:FireServer(cabinet)
		selectDoor(cabinet, false, selectedDifficulty)
	else
		-- Something else interrupted it
		practicing = false
		difficultySelect.Visible = false
	end
end

local function setUpPracticeCabinet(cabinet : Model)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "MinesweeperCabinetPrompt"

	prompt.ObjectText = "Minesweeper Cabinet"
	prompt.ActionText = "Play"
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = true
	prompt.Style = Enum.ProximityPromptStyle.Custom

	prompt.Parent = cabinet.PrimaryPart

	prompt.Triggered:Connect(function()
		if practicing == false and currentDoor == nil then
			-- Start
			startPractice(cabinet)
		elseif practicing == true and currentDoor ~= nil then
			-- Exit
			selectDoor(nil)
		end
	end)
end

canvas.Hints.Container.Button.MouseButton1Down:Connect(function()
	if hintsLeft > 0 and hintEquipped == false then
		equipHint()
	elseif hintEquipped == true then
		unequipHint()
	end
end)

uis.InputBegan:Connect(function(inputObject, processed)
	if hintEquipped == true and processed == false then
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			if inputObject.UserInputState == Enum.UserInputState.Begin then
				unequipHint()
			end
		end
	end
end)

rs.RenderStepped:Connect(function()
	if hintEquipped == true then
		ui.HintEquipped.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	end
end)

remotesFolder.Doors.StartHack.OnClientEvent:Connect(selectDoor)
remotesFolder.Doors.StopHack.OnClientEvent:Connect(selectDoor)

local practiceCabinets
while true do
	practiceCabinets = cs:GetTagged("MinesweeperCabinet")
	for i,cabinet in pairs(practiceCabinets) do
		if cabinet.PrimaryPart ~= nil and cabinet.PrimaryPart:FindFirstChild("MinesweeperCabinetPrompt") == nil then
			setUpPracticeCabinet(cabinet)
		end
	end

	task.wait(10)
end