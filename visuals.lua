-- visuals.lua
-- Modern clean Stormed Hub UI (slider only)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "StormedHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(380, 200)
frame.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(190, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 44)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 10)
topBarCorner.Parent = topBar

-- Logo
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(36, 36)
logo.Position = UDim2.fromOffset(12, 4)
logo.Text = "ΣΤ"
logo.Font = Enum.Font.GothamBold
logo.TextColor3 = Color3.fromRGB(180, 0, 255)  -- purple only here
logo.TextScaled = true
logo.BackgroundTransparency = 1
logo.Parent = topBar

-- Name
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.fromOffset(200, 36)
nameLabel.Position = UDim2.fromOffset(56, 4)
nameLabel.Text = "Stormed Hub"
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextColor3 = Color3.fromRGB(245, 245, 245)  -- white
nameLabel.TextScaled = true
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.BackgroundTransparency = 1
nameLabel.Parent = topBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 8)
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

-- Drag behavior
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

-- Body area
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -24, 1, -60)
body.Position = UDim2.fromOffset(12, 52)
body.BackgroundTransparency = 1
body.Parent = frame

-- Speed label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.fromOffset(200, 24)
speedLabel.Position = UDim2.fromOffset(0, 8)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
speedLabel.Text = "Speed"
speedLabel.TextSize = 20
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = body

-- Slider bar background
local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.fromOffset(300, 14)
sliderBack.Position = UDim2.fromOffset(0, 42)
sliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
sliderBack.BorderSizePixel = 0
sliderBack.Parent = body

local sliderBackCorner = Instance.new("UICorner")
sliderBackCorner.CornerRadius = UDim.new(0, 7)
sliderBackCorner.Parent = sliderBack

-- Slider fill (purple)
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(180, 0, 255)  -- purple
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBack

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 7)
sliderFillCorner.Parent = sliderFill

-- Speed value text
local speedValueText = Instance.new("TextLabel")
speedValueText.Size = UDim2.fromOffset(50, 24)
speedValueText.Position = UDim2.fromOffset(310, 34)
speedValueText.BackgroundTransparency = 1
speedValueText.Font = Enum.Font.GothamBold
speedValueText.TextColor3 = Color3.fromRGB(240, 240, 240)
speedValueText.Text = "16"
speedValueText.TextSize = 20
speedValueText.TextXAlignment = Enum.TextXAlignment.Left
speedValueText.Parent = body

-- Expose slider objects for main logic
gui.SliderBack = sliderBack
gui.SliderFill = sliderFill
gui.SpeedValueText = speedValueText
