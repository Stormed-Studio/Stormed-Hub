local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- Silence voice/speaking remote spam warnings
local ReplicatedStorage = game:GetService("ReplicatedStorage")
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and (obj.Name:lower():find("speaking") or obj.Name:lower():find("voice") or obj.Name:lower():find("likely")) then
        pcall(function()
            obj.OnClientEvent:Connect(function() end)  -- empty handler = no log
        end)
    end
end

local Window = Library:CreateWindow({
    Title = "Stormed Hub",
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab("Main"),
    Visuals = Window:AddTab("Visuals"),
    Settings = Window:AddTab("Settings")
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Options = Library.Options

local Movement = Tabs.Main:AddLeftGroupbox("Movement")

Movement:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Min = 16,
    Max = 250,
    Default = 16,
    Rounding = 0,
    Callback = function(v)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end
})

Movement:AddSlider("JumpPower", {
    Text = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Rounding = 0,
    Callback = function(v)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = v
        end
    end
})

local InfiniteJumpConnection
Movement:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(v)
        if v then
            InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if InfiniteJumpConnection then
                InfiniteJumpConnection:Disconnect()
                InfiniteJumpConnection = nil
            end
        end
    end
})

local FlyConnection
local FlyBodyGyro
local FlyBodyVelocity
local FlySpeed = 50
Movement:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(v)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if v then
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyGyro.P = 1000
            FlyBodyGyro.Parent = hrp

            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyVelocity.P = 1000
            FlyBodyVelocity.Parent = hrp

            FlyConnection = RunService.RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * FlySpeed
                end
                FlyBodyVelocity.Velocity = moveDir
                FlyBodyGyro.CFrame = cam.CFrame
            end)
        else
            if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
            if FlyBodyGyro then FlyBodyGyro:Destroy() end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        end
    end
})

Movement:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Min = 10,
    Max = 500,
    Default = 50,
    Rounding = 0,
    Callback = function(v)
        FlySpeed = v
    end
})

local Exploits = Tabs.Main:AddRightGroupbox("Exploits")

local NoclipConnection
Exploits:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(v)
        if v then
            NoclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
        end
    end
})

local AntiFlingConnection
Exploits:AddToggle("AntiFling", {
    Text = "Anti-Fling",
    Default = false,
    Callback = function(v)
        if v then
            AntiFlingConnection = RunService.Heartbeat:Connect(function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        local char = plr.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
                            hrp.Velocity = Vector3.new(0,0,0)
                            hrp.RotVelocity = Vector3.new(0,0,0)
                            hrp.CanCollide = false
                        end
                    end
                end
            end)
        else
            if AntiFlingConnection then
                AntiFlingConnection:Disconnect()
                AntiFlingConnection = nil
            end
        end
    end
})

local FlingTargets = {}
local FlingConnections = {}
Exploits:AddToggle("FlingAll", {
    Text = "Fling All",
    Default = false,
    Callback = function(v)
        if v then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    FlingTargets[plr] = true
                    FlingConnections[plr] = RunService.RenderStepped:Connect(function()
                        SkidFling(plr)
                    end)
                end
            end
        else
            for plr, conn in pairs(FlingConnections) do
                if conn then conn:Disconnect() end
            end
            FlingConnections = {}
            FlingTargets = {}
        end
    end
})

Players.PlayerAdded:Connect(function(plr)
    if Options.FlingAll.Value then
        FlingTargets[plr] = true
        FlingConnections[plr] = RunService.RenderStepped:Connect(function()
            SkidFling(plr)
        end)
    end
})

Players.PlayerRemoving:Connect(function(plr)
    if FlingConnections[plr] then
        FlingConnections[plr]:Disconnect()
        FlingConnections[plr] = nil
    end
    FlingTargets[plr] = nil
end)

function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            OldPos = RootPart.CFrame
        end
        
        if THumanoid and THumanoid.Sit then return end
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        else
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        local FPart = Instance.new("Part")
        FPart.CFrame = RootPart.CFrame
        FPart.Anchored = false
        FPart.CanCollide = false
        FPart.Transparency = 1
        FPart.Parent = Character
        
        local FPartWeld = Instance.new("Weld")
        FPartWeld.Part0 = FPart
        FPartWeld.Part1 = RootPart
        FPartWeld.Parent = FPart
        
        local BV = Instance.new("BodyVelocity")
        BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.Parent = FPart
        
        for _, v in ipairs(Character:GetChildren()) do
            if v:IsA("BasePart") then
                v.Velocity = Vector3.new(0, 0, 0)
                v.CanCollide = false
            end
        end
        
        task.wait(0.1)
        FPart.Position = TRootPart.Position + Vector3.new(0, 1, 0)
        task.wait(0.1)
        FPart.Position = TRootPart.Position + Vector3.new(0, 2, 0)
        task.wait(0.1)
        
        BV.Velocity = Vector3.new(0, 500, 0)
        
        task.wait(0.15)
        
        FPart:Destroy()
        
        RootPart.CFrame = OldPos
        if not getgenv().NoCamera then
            workspace.CurrentCamera.CameraSubject = Humanoid
        end
    end
end

local success, Visuals = pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua")))
if success then
    Visuals:Init(Tabs.Visuals)
end

local Keybinds = Tabs.Settings:AddRightGroupbox("Keybinds")
Keybinds:AddKeybind("MenuKeybind", {
    Text = "Menu Toggle",
    Default = Enum.KeyCode.RightControl,
    Mode = "Toggle",
    Callback = function(Key)
        Library.ToggleKeybind = Key
    end
})

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("StormedHub")
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("StormedHub")
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Library.ToggleKeybind = Options.MenuKeybind.Value

for _, option in pairs(Library.Options) do
    pcall(function()
        if option.Callback then
            option.Callback(option.Value)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    if Options.WalkSpeed.Value ~= 16 then
        char.Humanoid.WalkSpeed = Options.WalkSpeed.Value
    end
    if Options.JumpPower.Value ~= 50 then
        char.Humanoid.JumpPower = Options.JumpPower.Value
    end
end)

