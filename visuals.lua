local Visuals = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESPBoxes = {}
local ESPConnection

local LocalPlayer = Players.LocalPlayer

function Visuals:Init(tab)
    local ESPGroup = tab:AddLeftGroupbox("Player ESP")

    ESPGroup:AddToggle("ESP", {
        Text = "Boxes",
        Default = false,
        Callback = function(Value)
            if Value then
                ESPConnection = RunService.RenderStepped:Connect(function()
                    for player, box in pairs(ESPBoxes) do
                        box.Visible = false
                    end

                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            local humanoid = player.Character:FindFirstChild("Humanoid")
                            if humanoidRootPart and humanoid and humanoid.Health > 0 then
                                local rootPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                                if onScreen then
                                    local head = player.Character:FindFirstChild("Head")
                                    local lowerTorso = player.Character:FindFirstChild("LowerTorso") or player.Character:FindFirstChild("Torso")
                                    if head and lowerTorso then
                                        local headPos = Camera:WorldToViewportPoint(head.Position)
                                        local lowerPos = Camera:WorldToViewportPoint(lowerTorso.Position)
                                        local boxHeight = math.abs(headPos.Y - lowerPos.Y)
                                        local boxWidth = boxHeight * 0.4

                                        local box = ESPBoxes[player]
                                        if not box then
                                            box = Drawing.new("Square")
                                            box.Color = Color3.fromRGB(255, 0, 0)
                                            box.Thickness = 2
                                            box.Transparency = 1
                                            box.Filled = false
                                            ESPBoxes[player] = box
                                        end

                                        box.Size = Vector2.new(boxWidth, boxHeight)
                                        box.Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight)
                                        box.Visible = true
                                    end
                                end
                            end
                        end
                    end
                end)
            else
                if ESPConnection then
                    ESPConnection:Disconnect()
                    ESPConnection = nil
                end
                for _, box in pairs(ESPBoxes) do
                    box:Remove()
                end
                ESPBoxes = {}
            end
        end
    })

    Players.PlayerRemoving:Connect(function(player)
        local box = ESPBoxes[player]
        if box then
            box:Remove()
            ESPBoxes[player] = nil
        end
    end)
end

return Visuals
