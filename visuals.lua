-- visuals.lua
-- Professional Roblox Hub GUI with folders and options

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "StormedHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- === Main frame ===
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(420, 280)
frame.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(210, 140)
frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 6)
frameCorner.Parent = frame

-- === Top Bar ===
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,40)
topBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 6)
topCorner.Parent = topBar

-- Logo
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(28,28)
logo.Position = UDim2.fromOffset(10,6)
logo.Text = "ΣΤ"
logo.Font = Enum.Font.GothamBold
logo.TextColor3 = Color3.fromRGB(180,0,255)
logo.TextScaled = true
logo.BackgroundTransparency = 1
logo.Parent = topBar

-- Name
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.fromOffset(180,28)
nameLabel.Position = UDim2.fromOffset(40,6)
nameLabel.Text = "Stormed Hub"
nameLabel.Font = Enum.Font.GothamSemibold
nameLabel.TextColor3 = Color3.fromRGB(245,245,245)
nameLabel.TextScaled = true
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.BackgroundTransparency = 1
nameLabel.Parent = topBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28,28)
closeBtn.Position = UDim2.new(1,-36,0,6)
closeBtn.BackgroundColor3 = Color3.fromRGB(115,115,115)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0,4)
closeCorner.Parent = closeBtn

-- Tabs container
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.fromOffset(110,200)
tabsFrame.Position = UDim2.fromOffset(10,50)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

-- Folder setup
local tabNames = {"Main","Visuals","Character"}
local tabButtons = {}
local folderFrames = {}

for i,name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(90,28)
	btn.Position = UDim2.fromOffset(10,(i-1)*38)
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(245,245,245)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	btn.Parent = tabsFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,4)
	corner.Parent = btn
	tabButtons[name] = btn

	local folder = Instance.new("Frame")
	folder.Size = UDim2.new(1,-130,1,-60)
	folder.Position = UDim2.fromOffset(120,50)
	folder.BackgroundColor3 = Color3.fromRGB(35,35,35)
	folder.BorderSizePixel = 0
	folder.Visible = false
	folder.Parent = frame
	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0,6)
	fCorner.Parent = folder
	folderFrames[name] = folder
end

folderFrames["Main"].Visible = true

-- Tab click logic with fade tween
for name,btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		for fname,fframe in pairs(folderFrames) do
			if fname==name then
				fframe.Visible = true
				fframe.BackgroundTransparency=1
				game:GetService("TweenService"):Create(fframe,TweenInfo.new(0.25),{BackgroundTransparency=0}):Play()
			else
				fframe.Visible=false
			end
		end
	end)
end

-- === Character folder setup ===
local characterFolder = folderFrames["Character"]

-- === Visuals folder setup (checkboxes) ===
local visualsFolder = folderFrames["Visuals"]

local function createCheck(parent,labelText,yPos)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromOffset(120,20)
	lbl.Position = UDim2.fromOffset(10,yPos)
	lbl.BackgroundTransparency = 1
	lbl.Text=labelText
	lbl.TextColor3=Color3.fromRGB(245,245,245)
	lbl.Font=Enum.Font.Gotham
	lbl.TextSize=16
	lbl.TextXAlignment=Enum.TextXAlignment.Left
	lbl.Parent = parent

	local checkBtn = Instance.new("TextButton")
	checkBtn.Size = UDim2.fromOffset(18,18)
	checkBtn.Position = UDim2.fromOffset(140,yPos)
	checkBtn.BackgroundColor3=Color3.fromRGB(45,45,45)
	checkBtn.Text=""
	checkBtn.Font = Enum.Font.GothamBold
	checkBtn.TextScaled=true
	checkBtn.TextColor3=Color3.fromRGB(180,0,255)
	checkBtn.BorderSizePixel=0
	checkBtn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,4)
	corner.Parent = checkBtn

	local enabled=false
	checkBtn.MouseButton1Click:Connect(function()
		enabled = not enabled
		checkBtn.Text = enabled and "✔" or ""
	end)
	return checkBtn
end

-- Visuals options
createCheck(visualsFolder,"Player Highlight",10)
createCheck(visualsFolder,"Team Highlight",50)
createCheck(visualsFolder,"Player Lines",90)

-- === Expose frames and gui for main.lua ===
gui.Folders = folderFrames
gui.TopBar = topBar
gui.Frame = frame
gui.CloseBtn = closeBtn
