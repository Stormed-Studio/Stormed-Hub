-- main.lua

local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Visuals = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua"))()

local Window = Library:CreateWindow({
    Title = "Stormed Hub | Prison Life",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
})

local Tabs = {
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
    Movement = Window:AddTab("Movement"),
    Misc = Window:AddTab("Misc"),
    Settings = Window:AddTab("Settings"),
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    if Method == "FindPartOnRayWithIgnoreList" and Library.Flags.SilentAim and Library.Flags.SilentMode then
        local target = Visuals:GetClosestInFOV(Library.Flags.FOVRadius or 150, Library.Flags.TargetGuards or false, Library.Flags.TargetInmates or false, Library.Flags.TargetCriminals or false, Library.Flags.TargetNeutral or false)
        if target then
            Args[1] = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 1000)
        end
    end
    return oldNamecall(Self, unpack(Args))
end)
setreadonly(mt, true)

local function applyACSMods(tool)
    pcall(function()
        if tool:FindFirstChild("ACS_Client") and tool.ACS_Client:FindFirstChild("ACSRequire") then
            local engine = require(tool.ACS_Client.ACSRequire)
            engine.Settings.Recoil = 0
            engine.Settings.Spread = 0
            engine.Settings.FireRate = 0.01
            engine.Settings.Ammo = math.huge
            engine.Settings.ReloadTime = 0
        end
    end)
end

local function updateGunStates()
    if Library.Flags.InfAmmo or Library.Flags.GunMods then
        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("GunStates") then
                pcall(function()
                    local states = require(item.GunStates)
                    if Library.Flags.InfAmmo then
                        states.MaxAmmo = math.huge
                        states.CurrentAmmo = math.huge
                        states.StoredAmmo = math.huge
                    end
                    if Library.Flags.GunMods then
                        states.FireRate = 0.01
                        states.Spread = 0
                        states.ReloadTime = 0
                        states.Bullets = 10
                        states.Range = math.huge
                        states.Damage = math.huge
                    end
                end)
            end
        end
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("GunStates") then
                pcall(function()
                    local states = require(tool.GunStates)
                    if Library.Flags.InfAmmo then
                        states.MaxAmmo = math.huge
                        states.CurrentAmmo = math.huge
                        states.StoredAmmo = math.huge
                    end
                    if Library.Flags.GunMods then
                        states.FireRate = 0.01
                        states.Spread = 0
                        states.ReloadTime = 0
                        states.Bullets = 10
                        states.Range = math.huge
                        states.Damage = math.huge
                    end
                end)
            end
            if tool then
                applyACSMods(tool)
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    char.Humanoid.WalkSpeed = Library.Flags.WalkSpeed or 16
    updateGunStates()
end)

if LocalPlayer.Character then
    LocalPlayer.Character.Humanoid.WalkSpeed = Library.Flags.WalkSpeed or 16
    updateGunStates()
end

RunService.RenderStepped:Connect(function()
    Visuals:UpdateFOV(Library.Flags.FOVRadius or 150, Library.Flags.SilentAim)
    if Library.Flags.ESPEnabled then
        Visuals:UpdateESP(Library.Flags.ESPBoxes, Library.Flags.ESPNames, Library.Flags.ESPHealth, Library.Flags.ESPTracers)
    end
    if Library.Flags.Aimbot and not Library.Flags.SilentMode then
        local target = Visuals:GetClosestInFOV(Library.Flags.FOVRadius or 150, Library.Flags.TargetGuards or false, Library.Flags.TargetInmates or false, Library.Flags.TargetCriminals or false, Library.Flags.TargetNeutral or false)
        if target then
            local predicted = target.Position + (target.AssemblyLinearVelocity * 0.1)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, predicted), 0.15)
        end
    end
    updateGunStates()
end)

RunService.Stepped:Connect(function()
    if Library.Flags.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Space and Library.Flags.InfiniteJump then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local CombatLeft = Tabs.Combat:AddLeftGroupbox("Aimbot & Silent Aim")
CombatLeft:AddToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function() end
})
CombatLeft:AddToggle({
    Name = "Visible Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function() end
})
CombatLeft:AddToggle({
    Name = "Silent Mode",
    CurrentValue = true,
    Flag = "SilentMode",
    Callback = function() end
})
CombatLeft:AddSlider({
    Name = "FOV Radius",
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 1,
    Flag = "FOVRadius",
    Callback = function() end
})

local TeamFilters = Tabs.Combat:AddRightGroupbox("Team Targets")
TeamFilters:AddToggle({
    Name = "Guards",
    CurrentValue = false,
    Flag = "TargetGuards",
    Callback = function() end
})
TeamFilters:AddToggle({
    Name = "Inmates",
    CurrentValue = true,
    Flag = "TargetInmates",
    Callback = function() end
})
TeamFilters:AddToggle({
    Name = "Criminals",
    CurrentValue = true,
    Flag = "TargetCriminals",
    Callback = function() end
})
TeamFilters:AddToggle({
    Name = "Neutral",
    CurrentValue = false,
    Flag = "TargetNeutral",
    Callback = function() end
})
TeamFilters:AddButton({
    Name = "Auto Target Enemies",
    Callback = function()
        pcall(function()
            Library.Flags.TargetGuards = LocalPlayer.Team ~= game.Teams.Guards
            Library.Flags.TargetInmates = LocalPlayer.Team ~= game.Teams.Inmates
            Library.Flags.TargetCriminals = LocalPlayer.Team ~= game.Teams.Criminals
            Library.Flags.TargetNeutral = LocalPlayer.Team ~= game.Teams.Neutral
        end)
        Library:Notify("Targets updated based on your team!")
    end
})

local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP")
ESPGroup:AddToggle({
    Name = "Enabled",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        if not Value then
            Visuals:ClearESP()
        end
    end
})
ESPGroup:AddToggle({
    Name = "Boxes",
    CurrentValue = true,
    Flag = "ESPBoxes",
    Callback = function() end
})
ESPGroup:AddToggle({
    Name = "Names",
    CurrentValue = true,
    Flag = "ESPNames",
    Callback = function() end
})
ESPGroup:AddToggle({
    Name = "Health",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function() end
})
ESPGroup:AddToggle({
    Name = "Tracers",
    CurrentValue = true,
    Flag = "ESPTracers",
    Callback = function() end
})

local MovementGroup = Tabs.Movement:AddLeftGroupbox("Movement")
MovementGroup:AddSlider({
    Name = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 50,
    Rounding = 0,
    Flag = "WalkSpeed",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})
MovementGroup:AddToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function() end
})
MovementGroup:AddToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function() end
})

local MiscGroup = Tabs.Misc:AddLeftGroupbox("Weapons & Misc")
MiscGroup:AddToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Flag = "InfAmmo",
    Callback = function() end
})
MiscGroup:AddToggle({
    Name = "Gun Mods (No Spread/Recoil)",
    CurrentValue = false,
    Flag = "GunMods",
    Callback = function() end
})
MiscGroup:AddButton({
    Name = "Arrest All Prisoners",
    Callback = function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local oldCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 and (player.Team == game.Teams.Inmates or player.Team == game.Teams.Criminals) then
                for i = 1, 3 do
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    ReplicatedStorage.meleeEvent:FireServer(player)
                    task.wait(0.05)
                end
            end
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = oldCFrame
        Library:Notify("Arrested all targets!")
    end
})

ThemeManager:SetLibrary(Library)
ThemeManager:BuildConfigSection(Tabs.Settings)
SaveManager:SetLibrary(Library)
SaveManager:SetIgnoreIndexes({ "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor" })
SaveManager:SetConfig("StormedHubPrisonLife")
SaveManager:BuildConfigSection(Tabs.Settings)

Library:SetWatermark("Stormed Hub | Prison Life v1.0")

Library:OnUnload(function()
    Visuals:ClearESP()
    Visuals:ClearFOV()
end)

Library:Notify("Stormed Hub loaded successfully!")
