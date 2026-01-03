-- main.lua
-- Stormed Hub logic (character + visuals)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Load GUI
local gui = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua"))()
-- If you're testing locally, require visuals.lua instead of loadstring.

-- Shortcuts
local frame = gui.Frame
local closeBtn = gui.CloseButton
local shared = gui.Shared
local characterSliders = shared.CharacterSliders
local visualToggles = shared.VisualToggles
local visualSliders = shared.VisualSliders

-- === STATE ===
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultFOV = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70

local connections = {}
local highlights = {}  -- [Player] = Highlight
local lines = {}       -- [Player] = DrawingLine
local renderConnection = nil

local toggleStates = {
    PlayerHighlight = false,
    TeamHighlight = false,
    PlayerLines = false
}

-- === UTIL: SAFE CONNECT ===
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

-- === CHARACTER HELPERS ===
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function applyCharacterDefaults()
    local hum
    pcall(function()
        hum = getHumanoid()
    end)
    if hum then
        hum.WalkSpeed = defaultWalkSpeed
        hum.JumpPower = defaultJumpPower
    end

    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = defaultFOV
    end
end

-- === SLIDER LOGIC ===
local function attachSlider(sliderInfo, onValueChanged)
    local bg = sliderInfo.BG
    local fill = sliderInfo.Fill
    local label = sliderInfo.ValueLabel
    local min, max = sliderInfo.Min, sliderInfo.Max
    local dragging = false

    local function setFromInput(input)
        local absPos = bg.AbsolutePosition.X
        local absSize = bg.AbsoluteSize.X
        local x = math.clamp(input.Position.X - absPos, 0, absSize)
        local ratio = (absSize == 0) and 0 or (x / absSize)
        local value = math.floor(min + (max - min) * ratio + 0.5)

        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = tostring(value)
        onValueChanged(value)
    end

    connect(bg.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromInput(input)
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromInput(input)
        end
    end)

    -- Initialize default
    local defaultVal = sliderInfo.Default
    local ratio = (defaultVal - min) / (max - min)
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    label.Text = tostring(defaultVal)
    onValueChanged(defaultVal)
end

-- === TOGGLE LOGIC ===
local function attachToggle(toggleInfo, keyName)
    local btn = toggleInfo.Button
    local state = false

    local function updateVisual()
        btn.Text = state and "✔" or ""
    end

    connect(btn.MouseButton1Click, function()
        state = not state
        toggleStates[keyName] = state
        updateVisual()
    end)

    updateVisual()
end

-- === HIGHLIGHTS LOGIC ===
local function clearHighlights()
    for plr, h in pairs(highlights) do
        if h and h.Parent then
            pcall(function() h:Destroy() end)
        end
        highlights[plr] = nil
    end
end

local function createOrUpdateHighlight(plr)
    if not toggleStates.PlayerHighlight and not toggleStates.TeamHighlight then
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

    -- Color logic
    if toggleStates.TeamHighlight and plr.Team and player.Team and plr.Team == player.Team then
        h.FillColor = Color3.fromRGB(0, 170, 0) -- teammate green
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
    else
        h.FillColor = Color3.fromRGB(180, 0, 255) -- default purple
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
    end
end

local function refreshHighlights()
    clearHighlights()
    if not toggleStates.PlayerHighlight and not toggleStates.TeamHighlight then
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            createOrUpdateHighlight(plr)
        end
    end
end

-- === LINES (ESP) LOGIC (Drawing API) ===
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
        local drawing = Drawing and Drawing.new and Drawing.new("Line")
        if not drawing then
            return nil -- executor doesn't support Drawing
        end
        drawing.Thickness = 1.5
        drawing.Transparency = 1
        drawing.Color = Color3.fromRGB(180, 0, 255)
        lines[plr] = drawing
        line = drawing
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

    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local line = ensureLine(plr)

            if hrp and line then
                local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    line.From = center
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

-- === GLOBAL REFRESH ===
local function refreshAllVisuals()
    refreshHighlights()
    updateLines()
end

-- === HOOK SLIDERS ===

-- Speed slider
attachSlider(characterSliders.Speed, function(value)
    local hum = getHumanoid()
    hum.WalkSpeed = value
end)

-- Jump slider
attachSlider(characterSliders.Jump, function(value)
    local hum = getHumanoid()
    hum.JumpPower = value
end)

-- FOV slider
attachSlider(visualSliders.FOV, function(value)
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = value
    end
end)

-- === HOOK TOGGLES ===
attachToggle(visualToggles.PlayerHighlight, "PlayerHighlight")
attachToggle(visualToggles.TeamHighlight, "TeamHighlight")
attachToggle(visualToggles.PlayerLines, "PlayerLines")

-- Toggle callbacks: hook into state changes
for key, _ in pairs(toggleStates) do
    toggleStates[key] = false
end

-- Re-wire toggles to refresh visuals on click
local function rebindToggle(toggleInfo, keyName)
    local btn = toggleInfo.Button
    for _, c in ipairs(btn:GetPropertyChangedSignal("Text"):GetConnections() or {}) do
        -- no-op; can't get existing connections safely, we'll just rely on our state table
    end
    btn.MouseButton1Click:Connect(function()
        -- state already flipped in attachToggle, just refresh
        refreshAllVisuals()
    end)
end

rebindToggle(visualToggles.PlayerHighlight, "PlayerHighlight")
rebindToggle(visualToggles.TeamHighlight, "TeamHighlight")
rebindToggle(visualToggles.PlayerLines, "PlayerLines")

-- === PLAYER EVENTS FOR VISUALS ===
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

-- === CLOSE / SHUTDOWN ===
local shuttingDown = false

local function shutdown()
    if shuttingDown then return end
    shuttingDown = true

    -- Smooth slide-out
    TweenService:Create(
        frame,
        TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.fromScale(0.5, 1.3)}
    ):Play()

    -- Reset character and camera after a short delay
    task.delay(0.2, function()
        applyCharacterDefaults()

        clearHighlights()
        clearLines()
        disconnectAll()

        task.wait(0.2)
        pcall(function()
            gui:Destroy()
        end)
    end)
end

connect(closeBtn.MouseButton1Click, shutdown)

-- Optional: keybind to close (RightShift)
connect(UserInputService.InputBegan, function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        shutdown()
    end
end)
