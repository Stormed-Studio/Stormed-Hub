-- Load the GUI first
loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua"))()

-- Then set up toggles
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Example speed toggle
local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.fromOffset(120, 50)
toggleFrame.Position = UDim2.fromOffset(10, 50)
toggleFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleFrame.BorderSizePixel = 0
toggleFrame.Parent = player.PlayerGui:WaitForChild("VisualsGui"):WaitForChild("Frame")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.Text = "Speed Toggle"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleButton.Parent = toggleFrame

local speedEnabled = false

toggleButton.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	humanoid.WalkSpeed = 16
	toggleButton.Text = "Speed: 16"
end)

player.CharacterAdded:Connect(function(char)
	humanoid = char:WaitForChild("Humanoid")
	if speedEnabled then
		humanoid.WalkSpeed = 40
	end
end)
