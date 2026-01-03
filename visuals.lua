-- visuals.lua
-- Professional Roblox hub GUI (Stormed Hub)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "StormedHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- === Greeting ΣΤ ===
local greeting = Instance.new("TextLabel")
greeting.Size = UDim2.fromScale(1, 1)
greeting.BackgroundTransparency = 1
greeting.Text = "ΣΤ"
greeting.Font = Enum.Font.GothamBold
greeting.TextColor3 = Color3.fromRGB(180, 0, 255)
greeting.TextScaled = true
greeting.TextTransparency = 1
greeting.TextStrokeTransparency = 1
greeting.Parent = gui

TweenService:Create(greeting, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    TextTransparency = 0
}):Play()
task.wait(0.8)
TweenService:Create(greeting, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
    TextTransparency = 1
}):Play()
task.wait(0.55)
greeting:Destroy()

-- === Main frame ===
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(430, 290)
frame.Position = UDim2.fromScale(0.5, 1.3) -- start off-screen bottom
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 6)
frameCorner.Parent = frame

-- Smooth slide-in
TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = UDim2.fromScale(0.5, 0.5)
}):Play()

-- === Top bar ===
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 6)
topCorner.Parent = topBar

local topBarMask = Instance.new("Frame")
topBarMask.Size = UDim2.new(1, 0, 0, 6)
topBarMask.Position = UDim2.new(0, 0, 1, -6)
topBarMask.BackgroundColor3 = topBar.BackgroundColor3
topBarMask.BorderSizePixel = 0
topBarMask.Parent = topBar

-- Logo
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(26, 26)
logo.Position = UDim2.fromOffset(10, 6)
logo.BackgroundTransparency = 1
logo.Text = "ΣΤ"
logo.Font = Enum.Font.GothamBold
logo.TextColor3 = Color3.fromRGB(180, 0, 255)
logo.TextScaled = true
logo.Parent = topBar

-- Name
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.fromOffset(200, 26)
nameLabel.Position = UDim2.fromOffset(40, 6)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Stormed Hub"
nameLabel.Font = Enum.Font.GothamSemibold
nameLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextScaled = true
nameLabel.Parent = topBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- === Tabs ===
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.fromOffset(110, 230)
tabsFrame.Position = UDim2.fromOffset(12, 50)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

local tabNames = {"Main", "Visuals", "Character"}
local tabButtons = {}
local folderFrames = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(92, 26)
    btn.Position = UDim2.fromOffset(0, (i - 1) * 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Parent = tabsFrame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn

    tabButtons[name] = btn

    local folder = Instance.new("Frame")
    folder.Size = UDim2.new(1, -140, 1, -64)
    folder.Position = UDim2.fromOffset(130, 50)
    folder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    folder.BorderSizePixel = 0
    folder.Visible = false
    folder.Parent = frame

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 6)
    fCorner.Parent = folder

    folderFrames[name] = folder
end

folderFrames["Main"].Visible = true

-- Tab switching (with subtle fade)
for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for fname, fframe in pairs(folderFrames) do
            if fname == name then
                fframe.Visible = true
                fframe.BackgroundTransparency = 1
                TweenService:Create(
                    fframe,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0}
                ):Play()
            else
                fframe.Visible = false
            end
        end
    end)
end

-- === DRAGGING ===
do
    local dragging = false
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- === HELPERS TO BUILD CONTROLS (UI ONLY) ===

local function createSlider(parent, labelText, yPos, min, max, default)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(160, 18)
    label.Position = UDim2.fromOffset(10, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(235, 235, 235)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromOffset(220, 10)
    bg.Position = UDim2.fromOffset(10, yPos + 20)
    bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    bg.BorderSizePixel = 0
    bg.Parent = parent

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 5)
    bgCorner.Parent = bg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = fill

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.fromOffset(60, 18)
    valueLabel.Position = UDim2.fromOffset(240, yPos + 16)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Text = tostring(default)
    valueLabel.Parent = parent

    return {
        BG = bg,
        Fill = fill,
        ValueLabel = valueLabel,
        Min = min,
        Max = max,
        Default = default,
        Label = label
    }
end

local function createToggle(parent, labelText, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(170, 18)
    label.Position = UDim2.fromOffset(10, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(235, 235, 235)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(18, 18)
    button.Position = UDim2.fromOffset(190, yPos)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(180, 0, 255)
    button.Text = ""
    button.TextScaled = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button

    return {
        Button = button,
        Label = label
    }
end

-- === CHARACTER FOLDER CONTENT ===
local characterFolder = folderFrames["Character"]
local characterSliders = {}

characterSliders.Speed = createSlider(characterFolder, "Speed", 10, 0, 100, 16)
characterSliders.Jump = createSlider(characterFolder, "JumpPower", 70, 0, 200, 50)

-- === VISUALS FOLDER CONTENT ===
local visualsFolder = folderFrames["Visuals"]
local visualsToggles = {}
local visualsSliders = {}

visualsToggles.PlayerHighlight = createToggle(visualsFolder, "Player Highlight", 10)
visualsToggles.TeamHighlight = createToggle(visualsFolder, "Team Highlight", 46)
visualsToggles.PlayerLines     = createToggle(visualsFolder, "Player Lines", 82)

visualsSliders.FOV = createSlider(visualsFolder, "Camera FOV", 130, 60, 120, 70)

-- === EXPOSE TO main.lua ===
gui.Frame = frame
gui.TopBar = topBar
gui.CloseButton = closeBtn
gui.Folders = folderFrames

gui.Shared = {
    CharacterSliders = characterSliders,
    VisualToggles = visualsToggles,
    VisualSliders = visualsSliders
}

return gui
