local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "Stormed Hub - Anticheat Test",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main"),
    Settings = Window:AddTab("Settings")
}

local Toggles = {}
local Options = Library.Options

local Movement = Tabs.Main:AddLeftGroupbox("Movement")

Movement:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Min = 16,
    Max = 250,
    Default = 16,
    Rounding = 0,
    Suffix = "",
    Callback = function(v)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

Movement:AddSlider("JumpPower", {
    Text = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Rounding = 0,
    Suffix = "",
    Callback = function(v)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})

Movement:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false
})

Toggles.InfiniteJump = Options.InfiniteJump

local UIS = game:GetService("UserInputService")
local connection
Toggles.InfiniteJump:OnChanged(function(v)
    if v then
        connection = UIS.JumpRequest:Connect(function()
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
        end)
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if Options.WalkSpeed.Value ~= 16 then
        char.Humanoid.WalkSpeed = Options.WalkSpeed.Value
    end
    if Options.JumpPower.Value ~= 50 then
        char.Humanoid.JumpPower = Options.JumpPower.Value
    end
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:SetFolder("StormedHub")
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
