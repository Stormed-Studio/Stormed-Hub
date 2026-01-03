-- main.lua loader + speed slider in Character folder

-- Load visuals (GUI + tabs)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local gui = player.PlayerGui:WaitForChild("StormedHubGui")
local characterFolder = gui.Folders["Character"]

-- Speed label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.fromOffset(100, 24)
speedLabel.Position = UDim2.fromOffset(10, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed"
speedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 20
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = characterFolder

-- Slider bar
local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.fromOffset(250, 14)
sliderBack.Position = UDim2.fromOffset(10, 50)
sliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
sliderBack.BorderSizePixel = 0
sliderBack.Parent = characterFolder

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 7)
sliderCorner.Parent = sliderBack

-- Slider fill
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 10, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 7)
fillCorner.Parent = sliderFill

-- Speed value
local speedValueText = Instance.new("TextLabel")
speedValueText.Size = UDim2.fromOffset(50, 24)
speedValueText.Position = UDim2.fromOffset(270, 46)
speedValueText.BackgroundTransparency = 1
speedValueText.Text = "16"
speedValueText.Font = Enum.Font.GothamBold
speedValueText.TextColor3 = Color3.fromRGB(240, 240, 240)
speedValueText.TextSize = 20
speedValueText.TextXAlignment = Enum.TextXAlignment.Left
speedValueText.Parent = characterFolder

-- Connect slider to humanoid
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local draggingSlider = false

sliderBack.InputBegan:Connect(function(input)
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
		local posX = math.clamp(input.Position.X - sliderBack.AbsolutePosition.X, 0, sliderBack.AbsoluteSize.X)
		local percentage = posX / sliderBack.AbsoluteSize.X
		sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
		local speed = math.floor(percentage * 100)
		speedValueText.Text = tostring(speed)
		humanoid.WalkSpeed = speed
	end
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	local fillSize = sliderFill.Size.X.Offset
	local speed = math.floor((fillSize / sliderBack.AbsoluteSize.X) * 100)
	humanoid.WalkSpeed = speed
end)
