-- Simple Mod Menu with No Clip | por klausmodder

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleModMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Botão do ícone (Toggle)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Image = "rbxassetid://8569322835" -- ícone do menu
ToggleButton.BackgroundTransparency = 1
ToggleButton.Parent = ScreenGui

-- Janela do Mod Menu
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 70, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- Botão No Clip
local NoclipButton = Instance.new("TextButton")
NoclipButton.Size = UDim2.new(1, -20, 0, 30)
NoclipButton.Position = UDim2.new(0, 10, 0, 10)
NoclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NoclipButton.TextColor3 = Color3.new(1, 1, 1)
NoclipButton.Text = "No Clip: OFF"
NoclipButton.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 6)
UICorner2.Parent = NoclipButton

-- Toggle do menu
ToggleButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- No Clip
local noclipActive = false

NoclipButton.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    NoclipButton.Text = "No Clip: " .. (noclipActive and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    if noclipActive then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)
