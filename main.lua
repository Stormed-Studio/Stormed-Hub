-- main.lua
-- Stormed Hub - Logic (character + visuals)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Load GUI (remote)
local gui = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua"))()
-- For local testing: local gui = require(path.to.visuals)

local frame = gui.Frame
local closeBtn = gui.CloseButton
local shared = gui.Shared
local characterSliders = shared.CharacterSliders
local visualToggles = shared.VisualToggles
local visualSliders = shared.VisualSliders

-- === State ===
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultFOV = (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70

local connections = {}
local highlights = {} -- [Player] = Highlight
local lines = {}      -- [Player] = Drawing line
local renderConnection

local toggleStates = {
    PlayerHighlight = false,
    TeamHighlight = false,
    PlayerLines = false
}

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function disconnectAll()
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}
    if renderConnection then
        pcall(function() renderConnection:Disconnect() end)
        renderConnection = nil
    end
end

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function applyCharacterDefaults()
    local ok, hum = pcall(getHumanoid)
    if ok and hum then
        hum.WalkSpeed = defaultWalkSpeed
        hum.JumpPower = defaultJumpPower
    end
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = defaultFOV
    end
end

-- === Highlights logic ===
local function clearHighlights()
    for plr, h in pairs(highlights) do
        if h and h.Parent then
            pcall(function() h:Destroy() end)
        end
        highlights[plr] = nil
    end
end

local function createOrUpdateHighlight(plr)
    if not (toggleStates.PlayerHighlight or toggleStates.TeamHighlight) then
        return
    end
    local char = plr.Character
    if not char or not char.Parent then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local h = highlights[plr]
    if not h or not h.Parent then
        h = Instance.new("Highlight")
        h.Name = "StormedHubHighlight"
        h.FillTransparency = 0.7
        h.OutlineTransparency = 0
        h.Adornee = char
        h.Parent = char
        highlights[plr] = h
    end

    if toggleStates.TeamHighlight and plr.Team and player.Team and plr.Team == player.Team then
        h.FillColor = Color3.fromRGB(0, 170, 0)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
    else
        h.FillColor = Color3.fromRGB(180, 0, 255)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
    end
end

local function refreshHighlights()
    clearHighlights()
    if not (toggleStates.PlayerHighlight or toggleStates.TeamHighlight) then
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            createOrUpdateHighlight(plr)
        end
    end
end

-- === Lines (ESP) logic ===
local function clearLines()
    for plr, line in pairs(lines) do
        if line then
            pcall(function() line:Remove() end)
        end
        lines[plr] = nil
    end
end

local function ensureLine(plr)
    if not toggleStates.PlayerLines then return nil end
    local line = lines[plr]
    if not line then
        if not (Drawing and Drawing.new) then
            return nil
        end
        line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Transparency = 1
        line.Color = Color3.fromRGB(180, 0, 255)
        line.Visible = false
        lines[plr] = line
    end
    return line
end

local function updateLines()
    if not toggleStates.PlayerLines then
        for _, line in pairs(lines) do
            if line then line.Visible = false end
        end
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local line = ensureLine(plr)

            if hrp and line then
                local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    line.From = screenCenter
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            elseif line then
                line.Visible = false
            end
        end
    end
end

local function startRenderLoop()
    if renderConnection then
        renderConnection:Disconnect()
    end
    renderConnection = RunService.RenderStepped:Connect(function()
        if toggleStates.PlayerLines then
            updateLines()
        end
    end)
end

-- === Global visual refresh ===
local function refreshAllVisuals()
    refreshHighlights()
    updateLines()
end

-- === Slider logic ===
local function attachSlider(sliderInfo, onValueChanged)
    local bg = sliderInfo.BG
    local fill = sliderInfo.Fill
    local label = sliderInfo.ValueLabel
    local min, max = sliderInfo.Min, sliderInfo.Max
    local dragging = false

    local function applyFromInput(input)
        local absX = bg.AbsolutePosition.X
        local sizeX = bg.AbsoluteSize.X
        if sizeX <= 0 then return end

        local posX = math.clamp(input.Position.X - absX, 0, sizeX)
        local ratio = posX / sizeX
        local value = math.floor(min + (max - min) * ratio + 0.5)

        local normalized = (value - min) / (max - min)
        fill.Size = UDim2.new(normalized, 0, 1, 0)
        label.Text = tostring(value)
        onValueChanged(value)
    end

    connect(bg.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            applyFromInput(input)
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            applyFromInput(input)
        end
    end)

    -- Initialize default
    local defaultVal = sliderInfo.Default
    local norm = (defaultVal - min) / (max - min)
    fill.Size = UDim2.new(norm, 0, 1, 0)
    label.Text = tostring(defaultVal)
    onValueChanged(defaultVal)
end

-- === Toggle logic ===
local function attachToggle(toggleInfo, keyName)
    local btn = toggleInfo.Button

    local function updateVisual()
        btn.Text = toggleStates[keyName] and "✔" or ""
    end

    connect(btn.MouseButton1Click, function()
        toggleStates[keyName] = not toggleStates[keyName]
        updateVisual()
        refreshAllVisuals()
    end)

    updateVisual()
end

-- === Hook sliders ===
attachSlider(characterSliders.Speed, function(value)
    local hum = getHumanoid()
    hum.WalkSpeed = value
end)

attachSlider(characterSliders.Jump, function(value)
    local hum = getHumanoid()
    hum.JumpPower = value
end)

attachSlider(visualSliders.FOV, function(value)
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = value
    end
end)

-- === Hook toggles ===
attachToggle(visualToggles.PlayerHighlight, "PlayerHighlight")
attachToggle(visualToggles.TeamHighlight, "TeamHighlight")
attachToggle(visualToggles.PlayerLines, "PlayerLines")

-- === Player events for visuals ===
connect(Players.PlayerAdded, function(plr)
    connect(plr.CharacterAdded, function()
        task.wait(0.1)
        refreshHighlights()
    end)
    refreshHighlights()
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then
        connect(plr.CharacterAdded, function()
            task.wait(0.1)
            refreshHighlights()
        end)
    end
end

startRenderLoop()

-- === Shutdown / close ===
local shuttingDown = false

local function shutdown()
    if shuttingDown then return end
    shuttingDown = true

    TweenService:Create(
        frame,
        TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.fromScale(0.5, 1.3)}
    ):Play()

    task.delay(0.2, function()
        applyCharacterDefaults()
        clearHighlights()
        clearLines()
        disconnectAll()

        task.wait(0.15)
        pcall(function()
            gui:Destroy()
        end)
    end)
end

connect(closeBtn.MouseButton1Click, shutdown)

-- Optional keybind to close (RightShift)
connect(UserInputService.InputBegan, function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        shutdown()
    end
end)
