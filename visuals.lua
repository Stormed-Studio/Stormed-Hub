local Visuals = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ActiveESPs = {}

local Settings = {
    Box_Color = Color3.fromRGB(255, 255, 255),
    Tracer_Color = Color3.fromRGB(255, 255, 255),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom",
    Tracer_FollowMouse = false,
    Tracers = true,
    Boxes = true,
    Names = true,
    Skeleton = true,
    Health = true,
    Rainbow = false,
    TeamCheck = false,
    UseTeamColor = true
}
local Team_Check = {
    TeamCheck = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}

local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0,0)
    quad.PointB = Vector2.new(0,0)
    quad.PointC = Vector2.new(0,0)
    quad.PointD = Vector2.new(0,0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color 
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function NewText(color)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Position = Vector2.new(0, 0)
    text.Text = ""
    text.Color = color
    text.Size = 13
    text.Outline = true
    text.Center = true
    text.Font = 1
    text.Transparency = 1
    return text
end

local function Visibility(state, lib)
    for _, x in pairs(lib) do
        x.Visible = state
    end
end

local function Remove(lib)
    for _, x in pairs(lib) do
        x:Remove()
    end
end

local skeletonConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function ESP(plr)
    local library = {
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        healthbar = NewLine(3, Color3.fromRGB(0,0,0)),
        greenhealth = NewLine(1.5, Color3.fromRGB(0,255,0)),
        name = NewText(Settings.Box_Color),
        skeleton = {}
    }

    for _, conn in pairs(skeletonConnections) do
        library.skeleton[conn[1].."_"..conn[2]] = NewLine(1, Settings.Box_Color)
    end

    ActiveESPs[plr] = {library = library, connection = nil}

    local function Colorize(color)
        library.tracer.Color = color
        library.box.Color = color
        library.name.Color = color
        for _, line in pairs(library.skeleton) do
            line.Color = color
        end
    end

    local function Updater()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if Settings.Rainbow then
                local hue = tick() % 5 / 5
                local color = Color3.fromHSV(hue, 1, 1)
                Colorize(color)
            end

            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") ~= nil then
                local HumPos, OnScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local head = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local lower = Camera:WorldToViewportPoint(plr.Character.LowerTorso.Position)
                    local boxHeight = math.abs(head.Y - lower.Y)
                    local boxWidth = boxHeight * 0.4

                    if Settings.Boxes then
                        library.box.Size = Vector2.new(boxWidth, boxHeight)
                        library.box.Position = Vector2.new(HumPos.X - boxWidth / 2, HumPos.Y - boxHeight / 2)
                        library.box.Visible = true
                    else
                        library.box.Visible = false
                    end

                    if Settings.Tracers then
                        if Settings.Tracer_Origin == "Middle" then
                            library.tracer.From = Camera.ViewportSize * 0.5
                        elseif Settings.Tracer_Origin == "Bottom" then
                            library.tracer.From = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
                        elseif Settings.Tracer_Origin == "Top" then
                            library.tracer.From = Vector2.new(Camera.ViewportSize.X * 0.5, 0)
                        end
                        if Settings.Tracer_FollowMouse then
                            library.tracer.From = UserInputService:GetMouseLocation()
                        end
                        library.tracer.To = Vector2.new(HumPos.X, HumPos.Y + boxHeight / 2)
                        library.tracer.Visible = true
                    else
                        library.tracer.Visible = false
                    end

                    if Settings.Health then
                        local d = math.clamp(boxHeight, 0, math.huge)
                        local healthoffset = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * d

                        library.greenhealth.From = Vector2.new(HumPos.X - boxWidth / 2 - 4, HumPos.Y + boxHeight / 2)
                        library.greenhealth.To = Vector2.new(HumPos.X - boxWidth / 2 - 4, HumPos.Y + boxHeight / 2 - healthoffset)

                        library.healthbar.From = Vector2.new(HumPos.X - boxWidth / 2 - 4, HumPos.Y + boxHeight / 2)
                        library.healthbar.To = Vector2.new(HumPos.X - boxWidth / 2 - 4, HumPos.Y - boxHeight / 2)

                        local green = Color3.fromRGB(0, 255, 0)
                        local red = Color3.fromRGB(255, 0, 0)

                        library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
                        library.greenhealth.Visible = true
                        library.healthbar.Visible = true
                    else
                        library.greenhealth.Visible = false
                        library.healthbar.Visible = false
                    end

                    if Settings.Names then
                        library.name.Text = plr.Name
                        library.name.Position = Vector2.new(HumPos.X, HumPos.Y - boxHeight / 2 - library.name.TextBounds.Y / 2 - 2)
                        library.name.Visible = true
                    else
                        library.name.Visible = false
                    end

                    if Settings.Skeleton then
                        for _, conn in pairs(skeletonConnections) do
                            local part1 = plr.Character:FindFirstChild(conn[1])
                            local part2 = plr.Character:FindFirstChild(conn[2])
                            if part1 and part2 then
                                local pos1, on1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, on2 = Camera:WorldToViewportPoint(part2.Position)
                                if on1 and on2 then
                                    local line = library.skeleton[conn[1].."_"..conn[2]]
                                    line.From = Vector2.new(pos1.X, pos1.Y)
                                    line.To = Vector2.new(pos2.X, pos2.Y)
                                    line.Visible = true
                                else
                                    library.skeleton[conn[1].."_"..conn[2]].Visible = false
                                end
                            end
                        end
                    else
                        for _, line in pairs(library.skeleton) do
                            line.Visible = false
                        end
                    end

                    if Settings.TeamCheck then
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            Colorize(Team_Check.Green)
                        else 
                            Colorize(Team_Check.Red)
                        end
                    elseif Settings.UseTeamColor then
                        Colorize(plr.TeamColor.Color)
                    else
                        Colorize(Settings.Box_Color)
                    end
                else 
                    Visibility(false, library)
                    for _, line in pairs(library.skeleton) do
                        line.Visible = false
                    end
                end
            else 
                Visibility(false, library)
                for _, line in pairs(library.skeleton) do
                    line.Visible = false
                end
                if not Players:FindFirstChild(plr.Name) then
                    connection:Disconnect()
                end
            end
        end)
        ActiveESPs[plr].connection = connection
    end
    coroutine.wrap(Updater)()
end

function Visuals:Init(tab)
    local ESPGroup = tab:AddLeftGroupbox("Player ESP")

    local Enabled = false

    local function EnableESP()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                coroutine.wrap(ESP)(plr)
            end
        end
    end

    local function DisableESP()
        for plr, data in pairs(ActiveESPs) do
            Visibility(false, data.library)
            Remove(data.library)
            if data.connection then
                data.connection:Disconnect()
            end
        end
        ActiveESPs = {}
    end

    ESPGroup:AddToggle("ESPEnabled", {
        Text = "Enabled",
        Default = false,
        Callback = function(Value)
            Enabled = Value
            if Value then
                EnableESP()
            else
                DisableESP()
            end
        end
    })

    ESPGroup:AddToggle("Boxes", {
        Text = "Boxes",
        Default = true,
        Callback = function(v)
            Settings.Boxes = v
        end
    })

    ESPGroup:AddToggle("Tracers", {
        Text = "Tracers",
        Default = true,
        Callback = function(v)
            Settings.Tracers = v
        end
    })

    ESPGroup:AddToggle("Names", {
        Text = "Names",
        Default = true,
        Callback = function(v)
            Settings.Names = v
        end
    })

    ESPGroup:AddToggle("Skeleton", {
        Text = "Skeleton",
        Default = true,
        Callback = function(v)
            Settings.Skeleton = v
        end
    })

    ESPGroup:AddToggle("Health", {
        Text = "Health Bars",
        Default = true,
        Callback = function(v)
            Settings.Health = v
        end
    })

    ESPGroup:AddToggle("Rainbow", {
        Text = "Rainbow Colors",
        Default = false,
        Callback = function(v)
            Settings.Rainbow = v
        end
    })

    ESPGroup:AddToggle("TeamCheck", {
        Text = "Team Check",
        Default = false,
        Callback = function(v)
            Settings.TeamCheck = v
        end
    })

    ESPGroup:AddToggle("UseTeamColor", {
        Text = "Use Team Color",
        Default = true,
        Callback = function(v)
            Settings.UseTeamColor = v
        end
    })

    ESPGroup:AddToggle("TracerFollowMouse", {
        Text = "Tracers Follow Mouse",
        Default = false,
        Callback = function(v)
            Settings.Tracer_FollowMouse = v
        end
    })

    ESPGroup:AddDropdown("TracerOrigin", {
        Text = "Tracer Origin",
        Values = {"Top", "Middle", "Bottom"},
        Default = "Bottom",
        Callback = function(v)
            Settings.Tracer_Origin = v
        end
    })

    ESPGroup:AddColorPicker("BoxColor", {
        Text = "Box Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v)
            Settings.Box_Color = v
        end
    })

    ESPGroup:AddColorPicker("TracerColor", {
        Text = "Tracer Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v)
            Settings.Tracer_Color = v
        end
    })

    Players.PlayerAdded:Connect(function(newplr)
        if Enabled and newplr ~= LocalPlayer then
            coroutine.wrap(ESP)(newplr)
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if ActiveESPs[plr] then
            Visibility(false, ActiveESPs[plr].library)
            Remove(ActiveESPs[plr].library)
            if ActiveESPs[plr].connection then
                ActiveESPs[plr].connection:Disconnect()
            end
            ActiveESPs[plr] = nil
        end
    end)
end

return Visuals
