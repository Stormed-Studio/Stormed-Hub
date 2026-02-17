-- main.lua

local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Visuals = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua"))()

local Window = Library:CreateWindow({
    Title = 'Stormed Hub | Prison Life',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Movement = Window:AddTab('Movement'),
    Misc = Window:AddTab('Misc'),
}

local Flags = {
    SilentAim = false,
    Aimbot = false,
    SilentSwitch = true, -- true for silent, false for visible
    HitGuards = false,
    HitInmates = true,
    HitCriminals = true,
    HitNeutral = false,
    FOVSize = 150,
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPTracers = true,
    Speed = 16,
    Noclip = false,
    InfJump = false,
    InfAmmo = false,
    GunMods = false,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FindPartOnRayWithIgnoreList" and Flags.SilentAim and Flags.SilentSwitch then
        local target = Visuals:GetClosestInFOV(Flags.FOVSize, Flags.HitGuards, Flags.HitInmates, Flags.HitCriminals, Flags.HitNeutral)
        if target then
            args[1] = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 1000)
        end
    end
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

local function applyGunMods(tool)
    if tool:FindFirstChild("ACS_Client") and tool.ACS_Client:FindFirstChild("ACSRequire") then
        local engine = require(tool.ACS_Client.ACSRequire)
        engine.Settings.Recoil = 0
        engine.Settings.Spread = 0
        engine.Settings.FireRate = 0.01
        engine.Settings.Ammo = math.huge
        engine.Settings.ReloadTime = 0
    end
end

local function updateGuns()
    if Flags.GunMods or Flags.InfAmmo then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("GunStates") then
                local states = require(item.GunStates)
                if Flags.InfAmmo then
                    states.MaxAmmo = math.huge
                    states.CurrentAmmo = math.huge
                    states.StoredAmmo = math.huge
                end
                if Flags.GunMods then
                    states.FireRate = 0.01
                    states.Spread = 0
                    states.ReloadTime = 0
                    states.Bullets = 10
                    states.Range = math.huge
                    states.Damage = math.huge
                end
            end
        end
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("GunStates") then
                local states = require(tool.GunStates)
                if Flags.InfAmmo then
                    states.MaxAmmo = math.huge
                    states.CurrentAmmo = math.huge
                    states.StoredAmmo = math.huge
                end
                if Flags.GunMods then
                    states.FireRate = 0.01
                    states.Spread = 0
                    states.ReloadTime = 0
                    states.Bullets = 10
                    states.Range = math.huge
                    states.Damage = math.huge
                end
            end
            if tool then
                applyGunMods(tool)
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if Flags.Speed > 16 then
        char.Humanoid.WalkSpeed = Flags.Speed
    end
    updateGuns()
end)

if LocalPlayer.Character then
    if Flags.Speed > 16 then
        LocalPlayer.Character.Humanoid.WalkSpeed = Flags.Speed
    end
    updateGuns()
end

RunService.RenderStepped:Connect(function()
    Visuals:UpdateFOV(Flags.FOVSize, Flags.SilentAim)
    if Flags.ESPEnabled then
        Visuals:UpdateESP(Flags.ESPBoxes, Flags.ESPNames, Flags.ESPHealth, Flags.ESPTracers)
    end
    if Flags.Aimbot and not Flags.SilentSwitch then
        local target = Visuals:GetClosestInFOV(Flags.FOVSize, Flags.HitGuards, Flags.HitInmates, Flags.HitCriminals, Flags.HitNeutral)
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end
    updateGuns()
end)

RunService.Stepped:Connect(function()
    if Flags.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and Flags.InfJump then
        if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local CombatLeftGroup = Tabs.Combat:AddLeftGroupbox('Aimbot & Silent Aim')

CombatLeftGroup:AddToggle('SilentAimToggle', {
    Text = 'Silent Aim',
    Default = false,
    Callback = function(Value)
        Flags.SilentAim = Value
    end
})

CombatLeftGroup:AddToggle('AimbotToggle', {
    Text = 'Visible Aimbot',
    Default = false,
    Callback = function(Value)
        Flags.Aimbot = Value
    end
})

CombatLeftGroup:AddToggle('SilentSwitchToggle', {
    Text = 'Silent Mode (vs Visible)',
    Default = true,
    Callback = function(Value)
        Flags.SilentSwitch = Value
    end
})

CombatLeftGroup:AddSlider('FOVSlider', {
    Text = 'FOV Size',
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Flags.FOVSize = Value
    end
})

local TeamFilters = Tabs.Combat:AddRightGroupbox('Team Filters')

TeamFilters:AddToggle('HitGuards', {
    Text = 'Hit Guards',
    Default = false,
    Callback = function(Value)
        Flags.HitGuards = Value
    end
})

TeamFilters:AddToggle('HitInmates', {
    Text = 'Hit Inmates',
    Default = true,
    Callback = function(Value)
        Flags.HitInmates = Value
    end
})

TeamFilters:AddToggle('HitCriminals', {
    Text = 'Hit Criminals',
    Default = true,
    Callback = function(Value)
        Flags.HitCriminals = Value
    end
})

TeamFilters:AddToggle('HitNeutral', {
    Text = 'Hit Neutral',
    Default = false,
    Callback = function(Value)
        Flags.HitNeutral = Value
    end
})

TeamFilters:AddButton({
    Text = 'Auto Scan Enemies',
    Func = function()
        Flags.HitGuards = LocalPlayer.Team ~= game.Teams.Guards
        Flags.HitInmates = LocalPlayer.Team ~= game.Teams.Inmates
        Flags.HitCriminals = LocalPlayer.Team ~= game.Teams.Criminals
        Flags.HitNeutral = LocalPlayer.Team ~= game.Teams.Neutral
        Library:Notify('Auto scanned enemies based on your team.')
    end
})

local VisualsLeftGroup = Tabs.Visuals:AddLeftGroupbox('ESP Options')

VisualsLeftGroup:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        Flags.ESPEnabled = Value
        if not Value then
            Visuals:ClearESP()
        end
    end
})

VisualsLeftGroup:AddToggle('ESPBoxes', {
    Text = 'Boxes',
    Default = true,
    Callback = function(Value)
        Flags.ESPBoxes = Value
    end
})

VisualsLeftGroup:AddToggle('ESPNames', {
    Text = 'Names',
    Default = true,
    Callback = function(Value)
        Flags.ESPNames = Value
    end
})

VisualsLeftGroup:AddToggle('ESPHealth', {
    Text = 'Health Bars',
    Default = true,
    Callback = function(Value)
        Flags.ESPHealth = Value
    end
})

VisualsLeftGroup:AddToggle('ESPTracers', {
    Text = 'Tracers',
    Default = true,
    Callback = function(Value)
        Flags.ESPTracers = Value
    end
})

local MovementLeftGroup = Tabs.Movement:AddLeftGroupbox('Movement Hacks')

MovementLeftGroup:AddSlider('SpeedSlider', {
    Text = 'Walk Speed',
    Default = 16,
    Min = 16,
    Max = 50, -- Sneaky max to avoid detection
    Rounding = 0,
    Callback = function(Value)
        Flags.Speed = Value
        if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

MovementLeftGroup:AddToggle('NoclipToggle', {
    Text = 'Noclip',
    Default = false,
    Callback = function(Value)
        Flags.Noclip = Value
    end
})

MovementLeftGroup:AddToggle('InfJumpToggle', {
    Text = 'Infinite Jump',
    Default = false,
    Callback = function(Value)
        Flags.InfJump = Value
    end
})

local MiscLeftGroup = Tabs.Misc:AddLeftGroupbox('Misc Features')

MiscLeftGroup:AddToggle('InfAmmoToggle', {
    Text = 'Infinite Ammo',
    Default = false,
    Callback = function(Value)
        Flags.InfAmmo = Value
    end
})

MiscLeftGroup:AddToggle('GunModsToggle', {
    Text = 'OP Gun Mods',
    Default = false,
    Callback = function(Value)
        Flags.GunMods = Value
    end
})

MiscLeftGroup:AddButton({
    Text = 'Arrest All Criminals/Inmates',
    Func = function()
        local oldPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (p.Team == game.Teams.Inmates or p.Team == game.Teams.Criminals) and p.Character and p.Character.Humanoid.Health > 0 then
                for i = 1, 5 do
                    LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
                    game:GetService("ReplicatedStorage").meleeEvent:FireServer(p)
                    task.wait(0.1)
                end
            end
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
        Library:Notify('Attempted to arrest all.')
    end
})

Library:SetWatermark('Stormed Hub | Prison Life | v1.0')

Library:OnUnload(function()
    Visuals:ClearESP()
    Visuals:ClearFOV()
    print('Unloaded Stormed Hub')
end)

Library:Notify('Loaded Stormed Hub! Enjoy.')
