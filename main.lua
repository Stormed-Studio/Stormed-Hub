-- main.lua
-- Hub logic, sliders, and visuals

loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local gui = player.PlayerGui:WaitForChild("StormedHubGui")
local characterFolder = gui.Folders["Character"]
local visualsFolder = gui.Folders["Visuals"]
local frame = gui.Frame

-- Restore defaults when closed
local defaultSpeed = 16
local defaultJump = 50

local function resetCharacter()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		local hum = player.Character.Humanoid
		hum.WalkSpeed = defaultSpeed
		hum.JumpPower = defaultJump
	end
end

-- Smooth open/close
gui.CloseBtn.MouseButton1Click:Connect(function()
	TweenService:Create(frame,TweenInfo.new(0.3),{Position=UDim2.new(0.5,0,1.2,0)}):Play()
	resetCharacter()
end)

-- === Character sliders ===
local function createSliderLogic(slider)
	local dragging=false
	local bg = slider.BG
	local fill = slider.Fill
	local txt = slider.Text
	local min,max = slider.min,slider.max

	bg.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
			local posX = math.clamp(input.Position.X - bg.AbsolutePosition.X,0,bg.AbsoluteSize.X)
			local perc = posX/bg.AbsoluteSize.X
			fill.Size = UDim2.new(perc,0,1,0)
			txt.Text = tostring(math.floor(min + perc*(max-min)))
			-- Apply values
			if slider==gui.CharacterSliders.speed then
				if player.Character and player.Character:FindFirstChild("Humanoid") then
					player.Character.Humanoid.WalkSpeed = tonumber(txt.Text)
				end
			elseif slider==gui.CharacterSliders.jump then
				if player.Character and player.Character:FindFirstChild("Humanoid") then
					player.Character.Humanoid.JumpPower = tonumber(txt.Text)
				end
			end
		end
	end)
end

-- Attach sliders
createSliderLogic(gui.CharacterSliders.speed)
createSliderLogic(gui.CharacterSliders.jump)

-- === Visuals: Highlights and lines ===
local function applyVisuals()
	for _,plr in pairs(Players:GetPlayers()) do
		if plr==player then continue end
		local char = plr.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			if not char:FindFirstChild("Highlight") then
				local highlight = Instance.new("Highlight")
				highlight.Parent = char
				highlight.Adornee = char
				highlight.FillColor = Color3.fromRGB(180,0,255)
				highlight.OutlineColor = Color3.fromRGB(255,255,255)
			end
			-- Line drawing (BillboardGui with line) can be implemented here if needed
		end
	end
end

Players.PlayerAdded:Connect(applyVisuals)
Players.PlayerRemoving:Connect(applyVisuals)
