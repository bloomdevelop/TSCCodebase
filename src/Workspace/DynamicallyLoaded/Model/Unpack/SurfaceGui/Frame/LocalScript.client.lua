local pageData, currentPage = {}, 1
local pageCount = 100

pageData[67] = "They're trying to find the golden coffee mug. They can't be serious. Unless they know where to look. An order is necessary."

local ScreenPart = script.Parent.Parent.Adornee

if ScreenPart == nil then
	repeat
		task.wait(10)
		ScreenPart = script.Parent.Parent.Adornee
	until ScreenPart ~= nil
end

local RemoteEvent = ScreenPart:WaitForChild("PlaySound")
local noteBook = script.Parent.Frame
local pageControls = noteBook.PageCntrls

local function UpdatePageCount()
	pageData[currentPage] = pageData[currentPage] or ""
	noteBook.TextBox.Text = pageData[currentPage]
	pageControls.PageCount.Text = currentPage
end

noteBook.TextBox:GetPropertyChangedSignal("Text"):Connect(function() RemoteEvent:FireServer() end)

pageControls.PreviousPage.Activated:Connect(function()
	pageData[currentPage] = noteBook.TextBox.Text
	currentPage -= 1
	if currentPage < 1 then currentPage = pageCount end
	UpdatePageCount()
end)

pageControls.NextPage.Activated:Connect(function()
	pageData[currentPage] = noteBook.TextBox.Text
	currentPage += 1
	if currentPage > pageCount then currentPage = 1 end
	UpdatePageCount()
end)