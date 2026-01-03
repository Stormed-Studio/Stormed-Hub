-- main.lua loader + slider logic

-- Load the visuals
loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local gui = player.PlayerGui:WaitForChild("StormedHubGui")
local sliderBack = gui:WaitForChild("SliderBack")
local sliderFill = gui:WaitForChild("SliderFill")
local speedValueText = gui:WaitForChild("SpeedValueText")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local draggingSlider = false

-- Mouse down on slider
sliderBack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
	end
end)

-- Mouse up
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

-- Move slider fill
UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		local posX = math.clamp(input.Position.X - sliderBack.AbsolutePosition.X, 0, sliderBack.AbsoluteSize.X)
		local percentage = posX / sliderBack.AbsoluteSize.X
		sliderFill.Size = UDim2.new(percentage, 0, 1, 0)

		local speed = math.floor(percentage * 100)
		speedValueText.Text = tostring(speed)

		-- Apply speed safely
		humanoid.WalkSpeed = speed
	end
end)

-- Keep speed on respawn
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	local fillSize = sliderFill.Size.X.Offset
	local speed = math.floor((fillSize / sliderBack.AbsoluteSize.X) * 100)
	humanoid.WalkSpeed = speed
end)
