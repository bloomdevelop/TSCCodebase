--Made by M0RGOTH

--Please don't edit the script unless you know what you are doing.
--Read the Instructions script for details on how to use!

local giver = script.Parent
local setup = giver.Setup
local clicker = giver.Clicker.ClickDetector

function setUpGui(gui)
	gui.Box.ToolName.Text = setup.ToolName.Value
	if setup.Stat1.Value ~= "" and setup.Stat1Value.Value ~= "" then
		gui.Box.Stat1.Text = setup.Stat1.Value..":"
		gui.Box.Stat1Value.Text = setup.Stat1Value.Value
	else
		gui.Box.Stat1.Visible = false
		gui.Box.Stat1Value.Visible = false
	end
	if setup.Stat2.Value ~= "" and setup.Stat2Value.Value ~= "" then
		gui.Box.Stat2.Text = setup.Stat2.Value..":"
		gui.Box.Stat2Value.Text = setup.Stat2Value.Value
	else
		gui.Box.Stat2.Visible = false
		gui.Box.Stat2Value.Visible = false
	end
	if setup.Stat3.Value ~= "" and setup.Stat3Value.Value ~= "" then
		gui.Box.Stat3.Text = setup.Stat3.Value..":"
		gui.Box.Stat3Value.Text = setup.Stat3Value.Value
	else
		gui.Box.Stat3.Visible = false
		gui.Box.Stat3Value.Visible = false
	end
end

function getGuiSize(gui)
	size = UDim2.new(0,200,0,45)
	if setup.Stat1.Value ~= "" and setup.Stat1Value.Value ~= "" then
		size = UDim2.new(0,200,0,60)
	end
	if setup.Stat2.Value ~= "" and setup.Stat2Value.Value ~= "" then
		size = UDim2.new(0,200,0,75)
	end
	if setup.Stat3.Value ~= "" and setup.Stat3Value.Value ~= "" then
		size = UDim2.new(0,200,0,95)
	end
	return size
end

function	setTransparentObjects(gui)
	local children = gui:getChildren()
	for i = 1, #children do
		if children[i].TextTransparency == 0 then
			children[i].TextTransparency = 1
		else
			children[i].TextTransparency = 0
		end
	end
end

function giveMessage(message, player, duration)
	if not player.PlayerGui:findFirstChild("Notice") then
		local gui = script.Notice:Clone()
		gui.Box.Message.Text = message

		gui.Parent = player.PlayerGui

		local size = UDim2.new(0,250,0,27)
		gui.Box:TweenSize(size, Out, Linear, .5, false, nil )

		wait(.5)

		setTransparentObjects(gui.Box)

		wait(duration)

		setTransparentObjects(gui.Box)

		size = UDim2.new(0,0,0,0)
		gui.Box:TweenSize(size, Out, Linear, .5, false, nil )

		wait(.5)
		gui:Remove()
	end
end

function boxPopUp(player)
	if not player.PlayerGui:findFirstChDestroy()er") and setup.PopUpWindow.Value == true then
		local gui = script.Hover:Clone()
		setUpGui(gui)
		gui.Parent = player.PlayerGui

		local size = getGuiSize(gui)
		local pos = UDim2.new(.5, -100, .5, 50)

		setTransparentObjects(gui.Box)

		gui.Box:TweenSizeAndPosition(size, pos, Out, Linear, .5, false, nil )
		wait(.5)
		setTransparentObjects(gui.Box)
	end
end

function boxPopDown(player)
	if player.PlayerGui:findFirstChild("Hover") and setup.PopUpWindow.Value == true then
		local gui = player.PlayerGui:findFirstChild("Hover")

		local size = UDim2.new(0,0,0,0)
		local pos = UDim2.new(.5, -100, .5, 50)

		setTransparentObjects(gui.Box)

		gui.Box:TweenSizeAndPosition(size, pos, In, Linear, .5, false, nil )
		wait(.5)
		gui:Remove()
	end
end

function pickUpTool(player)
	local tool = game.Lighting:findFirstChild(setup.ToolName.Value)	
Destroy()Tool = player.Backpack:findFirstChild(setup.ToolName.Value)
	if tool and not pTool then
		tool:Clone().Parent = player.Backpack
		giveMessage("Picked up "..setup.ToolName.Value, player, 1)
	elseif tool and pTool then
		giveMessage("You already have this tool!", player, 2)
	else
		giveMessage("We cannot find the tool!", player, 2)
	end
end

clicker.MouseHoverEnter:connect(boxPopUp)
clicker.MouseHoverLeave:connect(boxPopDown)
clicker.MouseClick:connect(pickUpTool)