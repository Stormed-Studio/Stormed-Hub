-- visuals.lua
-- Professional Roblox Hub GUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "StormedHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- === Greeting ===
local greeting = Instance.new("TextLabel")
greeting.Size = UDim2.fromScale(1, 1)
greeting.BackgroundTransparency = 1
greeting.Text = "ΣΤ"
greeting.Font = Enum.Font.GothamBold
greeting.TextColor3 = Color3.fromRGB(180, 0, 255)
greeting.TextScaled = true
greeting.TextTransparency = 1
greeting.TextStrokeTransparency = 0
greeting.Parent = gui

-- Fade in
TweenService:Create(greeting, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
wait(0.8)
-- Fade out
TweenService:Create(greeting, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
wait(0.5)
greeting:Destroy()

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

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- === Dragging ===
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
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- === Tabs ===
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.fromOffset(110,200)
tabsFrame.Position = UDim2.fromOffset(10,50)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

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

-- Tab clicks
local TweenService = game:GetService("TweenService")
for name,btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		for fname,fframe in pairs(folderFrames) do
			if fname==name then
				fframe.Visible = true
				fframe.BackgroundTransparency=1
				TweenService:Create(fframe,TweenInfo.new(0.25),{BackgroundTransparency=0}):Play()
			else
				fframe.Visible=false
			end
		end
	end)
end

-- === Character folder sliders ===
local characterFolder = folderFrames["Character"]

local function createSlider(parent, labelText, yPos, min,max,default)
	local lbl = Instance.new("TextLabel")
	lbl.Size=UDim2.fromOffset(100,20)
	lbl.Position=UDim2.fromOffset(10,yPos)
	lbl.BackgroundTransparency=1
	lbl.Text=labelText
	lbl.TextColor3=Color3.fromRGB(245,245,245)
	lbl.Font=Enum.Font.Gotham
	lbl.TextSize=16
	lbl.TextXAlignment=Enum.TextXAlignment.Left
	lbl.Parent=parent

	local sliderBG = Instance.new("Frame")
	sliderBG.Size=UDim2.fromOffset(220,12)
	sliderBG.Position=UDim2.fromOffset(10,yPos+22)
	sliderBG.BackgroundColor3=Color3.fromRGB(50,50,50)
	sliderBG.BorderSizePixel=0
	sliderBG.Parent=parent

	local sliderCorner = Instance.new("UICorner")
	sliderCorner.CornerRadius=UDim.new(0,6)
	sliderCorner.Parent=sliderBG

	local sliderFill = Instance.new("Frame")
	sliderFill.Size=UDim2.new(default/(max-min),0,1,0)
	sliderFill.BackgroundColor3=Color3.fromRGB(180,0,255)
	sliderFill.BorderSizePixel=0
	sliderFill.Parent=sliderBG

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius=UDim.new(0,6)
	fillCorner.Parent=sliderFill

	local valueText = Instance.new("TextLabel")
	valueText.Size=UDim2.fromOffset(50,20)
	valueText.Position=UDim2.fromOffset(240,yPos+20)
	valueText.BackgroundTransparency=1
	valueText.Font=Enum.Font.GothamSemibold
	valueText.TextSize=16
	valueText.TextColor3=Color3.fromRGB(245,245,245)
	valueText.Text = tostring(default)
	valueText.TextXAlignment=Enum.TextXAlignment.Left
	valueText.Parent = parent

	return sliderBG, sliderFill, valueText
end

-- Speed slider
local speedBG, speedFill, speedText = createSlider(characterFolder,"Speed",10,0,100,16)
-- JumpPower slider
local jumpBG, jumpFill, jumpText = createSlider(characterFolder,"JumpPower",60,0,200,50)

-- Expose for main.lua logic
gui.CharacterSliders = {
	speed={BG=speedBG,Fill=speedFill,Text=speedText,min=0,max=100},
	jump={BG=jumpBG,Fill=jumpFill,Text=jumpText,min=0,max=200}
}

-- === Visuals folder checkmarks ===
local visualsFolder = folderFrames["Visuals"]
local function createCheck(parent,nameText,yPos)
	local lbl = Instance.new("TextLabel")
	lbl.Size=UDim2.fromOffset(120,20)
	lbl.Position=UDim2.fromOffset(10,yPos)
	lbl.BackgroundTransparency=1
	lbl.Text=nameText
	lbl.TextColor3=Color3.fromRGB(245,245,245)
	lbl.Font=Enum.Font.Gotham
	lbl.TextSize=16
	lbl.TextXAlignment=Enum.TextXAlignment.Left
	lbl.Parent=parent

	local checkBtn = Instance.new("TextButton")
	checkBtn.Size=UDim2.fromOffset(18,18)
	checkBtn.Position=UDim2.fromOffset(140,yPos)
	checkBtn.BackgroundColor3=Color3.fromRGB(45,45,45)
	checkBtn.Text=""
	checkBtn.Font=Enum.Font.GothamBold
	checkBtn.TextScaled=true
	checkBtn.TextColor3=Color3.fromRGB(180,0,255)
	checkBtn.BorderSizePixel=0
	checkBtn.Parent=parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,4)
	corner.Parent=checkBtn

	local enabled=false
	checkBtn.MouseButton1Click:Connect(function()
		enabled = not enabled
		checkBtn.Text=enabled and "✔" or ""
	end)
	return checkBtn
end

createCheck(visualsFolder,"Player Highlight",10)
createCheck(visualsFolder,"Team Highlight",50)
