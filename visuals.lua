-- visuals.lua
-- Modern Stormed Hub GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "VisualsGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(350, 220)
frame.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(175, 110)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)  -- dark black but not pure
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

-- Logo + Name
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(40, 40)
logo.Position = UDim2.new(1, -180, 0, 0)
logo.Text = "ΣΤ"
logo.Font = Enum.Font.GothamBold
logo.TextColor3 = Color3.fromRGB(180, 0, 255)
logo.TextScaled = true
logo.BackgroundTransparency = 1
logo.Parent = topBar

local name = Instance.new("TextLabel")
name.Size = UDim2.fromOffset(120, 40)
name.Position = UDim2.new(1, -140, 0, 0)
name.Text = "Stormed Hub"
name.Font = Enum.Font.GothamBold
name.TextColor3 = Color3.fromRGB(180, 180, 255)
name.TextScaled = true
name.BackgroundTransparency = 1
name.TextXAlignment = Enum.TextXAlignment.Left
name.Parent = topBar

-- Close button
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 35)
close.Position = UDim2.new(1, -40, 0, 2)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1, 1, 1)
close.TextScaled = true
close.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
close.BorderSizePixel = 0
close.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = close

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Draggable frame
local dragging = false
local dragStart
local startPos

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

-- Body frame for content
local bodyFrame = Instance.new("Frame")
bodyFrame.Size = UDim2.new(1, -20, 1, -50)
bodyFrame.Position = UDim2.fromOffset(10, 45)
bodyFrame.BackgroundTransparency = 1
bodyFrame.Parent = frame

-- Rounded slider for speed
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.fromOffset(300, 25)
sliderLabel.Position = UDim2.fromOffset(10, 10)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Speed: 16"
sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
sliderLabel.Font = Enum.Font.GothamBold
sliderLabel.TextScaled = true
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = bodyFrame

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.fromOffset(300, 20)
sliderFrame.Position = UDim2.fromOffset(10, 45)
sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = bodyFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 8)
sliderCorner.Parent = sliderFrame

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0, 10, 1, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = sliderFrame

local sliderBarCorner = Instance.new("UICorner")
sliderBarCorner.CornerRadius = UDim.new(0, 8)
sliderBarCorner.Parent = sliderBar

-- Slider functionality
local draggingSlider = false
local playerChar = player.Character or player.CharacterAdded:Wait()
local humanoid = playerChar:WaitForChild("Humanoid")

sliderBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		local relative = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
		sliderBar.Size = UDim2.new(0, relative, 1, 0)
		local value = math.floor((relative / sliderFrame.AbsoluteSize.X) * 100)
		sliderLabel.Text = "Speed: " .. tostring(value)
		humanoid.WalkSpeed = math.max(0, value)
	end
end)

-- Ensure slider applies on respawn
player.CharacterAdded:Connect(function(char)
	humanoid = char:WaitForChild("Humanoid")
	local relative = sliderBar.AbsoluteSize.X
	local value = math.floor((relative / sliderFrame.AbsoluteSize.X) * 100)
	humanoid.WalkSpeed = math.max(0, value)
end)
