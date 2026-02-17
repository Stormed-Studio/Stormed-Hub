-- visuals.lua

local Visuals = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ESPObjects = {}
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Visible = false

function Visuals:GetClosestInFOV(fov, hitGuards, hitInmates, hitCriminals, hitNeutral)
    local closest, distance = nil, fov
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character.Humanoid.Health > 0 then
            local team = player.Team
            local canHit = false
            if team == game.Teams.Guards and hitGuards then canHit = true end
            if team == game.Teams.Inmates and hitInmates then canHit = true end
            if team == game.Teams.Criminals and hitCriminals then canHit = true end
            if team == game.Teams.Neutral and hitNeutral then canHit = true end
            if canHit then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                    if mag < distance then
                        distance = mag
                        closest = player.Character.Head
                    end
                end
            end
        end
    end
    return closest
end

function Visuals:UpdateFOV(size, enabled)
    fovCircle.Radius = size
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Visible = enabled
end

function Visuals:ClearFOV()
    fovCircle.Visible = false
    fovCircle:Remove()
end

local function createESP(player)
    if ESPObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Visible = false
    
    local name = Drawing.new("Text")
    name.Size = 16
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Center = true
    name.Outline = true
    name.Visible = false
    
    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 2
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Visible = false
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(255, 255, 255)
    tracer.Visible = false
    
    ESPObjects[player] = {box = box, name = name, health = healthBar, tracer = tracer}
end

function Visuals:UpdateESP(boxes, names, health, tracers)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
            createESP(player)
            local esp = ESPObjects[player]
            local root = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid
            local head = player.Character.Head
            
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                
                local height = (headPos.Y - legPos.Y) / 2
                local width = height / 2
                
                if boxes then
                    esp.box.Size = Vector2.new(width, height * 2)
                    esp.box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height)
                    esp.box.Visible = true
                else
                    esp.box.Visible = false
                end
                
                if names then
                    esp.name.Text = player.Name
                    esp.name.Position = Vector2.new(rootPos.X, rootPos.Y - height - 16)
                    esp.name.Visible = true
                else
                    esp.name.Visible = false
                end
                
                if health then
                    local healthY = height * 2 * (hum.Health / hum.MaxHealth)
                    esp.health.From = Vector2.new(rootPos.X - width / 2 - 4, rootPos.Y + height)
                    esp.health.To = Vector2.new(rootPos.X - width / 2 - 4, rootPos.Y + height - healthY)
                    esp.health.Visible = true
                    esp.health.Color = Color3.fromHSV((hum.Health / hum.MaxHealth) * 0.3, 1, 1)
                else
                    esp.health.Visible = false
                end
                
                if tracers then
                    esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y + height)
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            else
                esp.box.Visible = false
                esp.name.Visible = false
                esp.health.Visible = false
                esp.tracer.Visible = false
            end
        elseif ESPObjects[player] then
            Visuals:RemoveESP(player)
        end
    end
end

function Visuals:RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
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
    createESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

return Visuals
