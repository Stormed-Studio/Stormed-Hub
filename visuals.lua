-- visuals.lua
-- Modern Roblox Hub GUI with tabs/folders

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "StormedHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(450, 300)
frame.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(225, 150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Draggable top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

-- Logo
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(36, 36)
logo.Position = UDim2.fromOffset(12, 7)
logo.Text = "ΣΤ"
logo.Font = Enum.Font.GothamBold
logo.TextColor3 = Color3.fromRGB(180, 0, 255)
logo.TextScaled = true
logo.BackgroundTransparency = 1
logo.Parent = topBar

-- Name
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.fromOffset(200, 36)
nameLabel.Position = UDim2.fromOffset(56, 7)
nameLabel.Text = "Stormed Hub"
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
nameLabel.TextScaled = true
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.BackgroundTransparency = 1
nameLabel.Parent = topBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 11)
closeBtn.BackgroundColor3 = Color3.fromRGB(115, 115, 115)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Drag functionality
local dragging = false
local dragStart, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
topBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Left tab buttons frame
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.fromOffset(120, 240)
tabsFrame.Position = UDim2.fromOffset(10, 60)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

-- Tab buttons
local tabNames = {"Main", "Visuals", "Character"}
local tabButtons = {}
local folderFrames = {}

for i, name in ipairs(tabNames) do
	-- Button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(100, 30)
	btn.Position = UDim2.fromOffset(10, (i-1)*40)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(245, 245, 245)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BorderSizePixel = 0
	btn.Parent = tabsFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	tabButtons[name] = btn

	-- Folder frame
	local folder = Instance.new("Frame")
	folder.Size = UDim2.new(1, -140, 1, -70)
	folder.Position = UDim2.fromOffset(130, 60)
	folder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	folder.BorderSizePixel = 0
	folder.Visible = false
	folder.Parent = frame

	local folderCorner = Instance.new("UICorner")
	folderCorner.CornerRadius = UDim.new(0, 8)
	folderCorner.Parent = folder

	folderFrames[name] = folder
end

-- Show first tab by default
folderFrames["Main"].Visible = true

-- Tab button click handling with tween fade
for name, btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		for fname, fframe in pairs(folderFrames) do
			if fname == name then
				-- Tween in
				fframe.Visible = true
				fframe.BackgroundTransparency = 1
				TweenService:Create(fframe, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
			else
				fframe.Visible = false
			end
		end
	end)
end

-- Expose folder frames for main logic
gui.Folders = folderFrames
