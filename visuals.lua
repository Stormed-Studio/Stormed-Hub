-- visuals.lua

local Visuals = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ESPObjects = {}
local fovCircle

local function createESPElements(player)
    if ESPObjects[player] then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Visible = false

    local nameLabel = Drawing.new("Text")
    nameLabel.Size = 16
    nameLabel.Font = 2
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    nameLabel.Outline = true
    nameLabel.Center = true
    nameLabel.Visible = false

    local healthBarBG = Drawing.new("Line")
    healthBarBG.Thickness = 3
    healthBarBG.Color = Color3.fromRGB(50, 50, 50)
    healthBarBG.Transparency = 0.5
    healthBarBG.Visible = false

    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 2
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(255, 255, 255)
    tracer.Transparency = 0.7
    tracer.Visible = false

    ESPObjects[player] = {
        box = box,
        name = nameLabel,
        healthBG = healthBarBG,
        health = healthBar,
        tracer = tracer
    }
end

function Visuals:GetClosestInFOV(fovSize, targetGuards, targetInmates, targetCriminals, targetNeutral)
    local closestTarget = nil
    local shortestDistance = fovSize
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character.Humanoid.Health > 0 then
            local team = player.Team
            local canTarget = false
            if team == game.Teams.Guards and targetGuards then canTarget = true
            elseif team == game.Teams.Inmates and targetInmates then canTarget = true
            elseif team == game.Teams.Criminals and targetCriminals then canTarget = true
            elseif team == game.Teams.Neutral and targetNeutral then canTarget = true
            end
            if canTarget then
                local headPos, visible = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if visible then
                    local distance = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = player.Character.Head
                    end
                end
            end
        end
    end
    return closestTarget
end

function Visuals:UpdateFOV(size, enabled)
    if not fovCircle then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.NumSides = 100
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        fovCircle.Transparency = 0.8
        fovCircle.Filled = false
    end
    fovCircle.Radius = size
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Visible = enabled
end

function Visuals:ClearFOV()
    if fovCircle then
        fovCircle:Remove()
        fovCircle = nil
    end
end

function Visuals:UpdateESP(showBoxes, showNames, showHealth, showTracers)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            createESPElements(player)
            local espData = ESPObjects[player]
            local rootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local head = player.Character.Head

            local rootScreen, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local headScreen = Camera:WorldToViewportPoint(head.Position)
                local footScreen = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 4, 0))

                local boxHeight = math.abs(headScreen.Y - footScreen.Y)
                local boxWidth = boxHeight * 0.4

                if showBoxes then
                    espData.box.Size = Vector2.new(boxWidth, boxHeight)
                    espData.box.Position = Vector2.new(rootScreen.X - boxWidth / 2, rootScreen.Y - boxHeight / 2)
                    espData.box.Visible = true
                else
                    espData.box.Visible = false
                end

                if showNames then
                    espData.name.Text = player.Name
                    espData.name.Position = Vector2.new(rootScreen.X, rootScreen.Y - boxHeight / 2 - 20)
                    espData.name.Visible = true
                else
                    espData.name.Visible = false
                end

                if showHealth then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barHeight = boxHeight * healthPercent
                    espData.healthBG.From = Vector2.new(rootScreen.X - boxWidth / 2 - 6, rootScreen.Y - boxHeight / 2)
                    espData.healthBG.To = Vector2.new(rootScreen.X - boxWidth / 2 - 6, rootScreen.Y + boxHeight / 2)
                    espData.healthBG.Visible = true

                    espData.health.From = Vector2.new(rootScreen.X - boxWidth / 2 - 6, rootScreen.Y + boxHeight / 2)
                    espData.health.To = Vector2.new(rootScreen.X - boxWidth / 2 - 6, rootScreen.Y + boxHeight / 2 - barHeight)
                    espData.health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    espData.health.Visible = true
                else
                    espData.healthBG.Visible = false
                    espData.health.Visible = false
                end

                if showTracers then
                    espData.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    espData.tracer.To = Vector2.new(rootScreen.X, rootScreen.Y)
                    espData.tracer.Visible = true
                else
                    espData.tracer.Visible = false
                end
            else
                espData.box.Visible = false
                espData.name.Visible = false
                espData.healthBG.Visible = false
                espData.health.Visible = false
                espData.tracer.Visible = false
            end
        elseif ESPObjects[player] then
            Visuals:RemoveESP(player)
        end
    end
end

function Visuals:RemoveESP(player)
    if ESPObjects[player] then
        for _, drawingObj in pairs(ESPObjects[player]) do
            drawingObj:Remove()
        end
        ESPObjects[player] = nil
    end
end

function Visuals:ClearESP()
    for player, _ in pairs(ESPObjects) do
        Visuals:RemoveESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
    end)
end)

Players.PlayerRemoving:Connect(Visuals.RemoveESP)

return Visuals
