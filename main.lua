local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

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

local WalkSpeedConnection
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

local JumpPowerConnection
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

local NoclipConnection
local Exploits = Tabs.Main:AddRightGroupbox("Exploits")
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

local success, Visuals = pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormed-Studio/Stormed-Hub/main/visuals.lua")))
if success then
    Visuals:Init(Tabs.Visuals)
end

local Keybinds = Tabs.Settings:AddRightGroupbox("Keybinds")
Keybinds:AddKeybind("MenuKeybind", {
    Text = "Menu Toggle",
    Default = Enum.KeyCode.RightControl,
    Mode = "Toggle",
    Callback = function(KeyCode)
        Library.ToggleKeybind.Value = KeyCode
    end
})

ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("StormedHub")
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Library.ToggleKeybind.Value = Library.Options.MenuKeybind.Value

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
