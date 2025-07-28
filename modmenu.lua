-- ZangMods UI - Simples Mod Menu com Abas e No Clip
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZangModsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Botão ícone
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Image = "rbxassetid://8569322835" -- Ícone
ToggleButton.BackgroundTransparency = 1
ToggleButton.Parent = ScreenGui

-- Janela principal
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 250)
Frame.Position = UDim2.new(0, 70, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Visible = false
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 8)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "ZangMods"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = Frame

-- Abas (lateral esquerda)
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 80, 1, -30)
TabsFrame.Position = UDim2.new(0, 0, 0, 30)
TabsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = Frame

local TabsCorner = Instance.new("UICorner", TabsFrame)
TabsCorner.CornerRadius = UDim.new(0, 6)

-- Conteúdo principal
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -80, 1, -30)
ContentFrame.Position = UDim2.new(0, 80, 0, 30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = Frame

local ContentCorner = Instance.new("UICorner", ContentFrame)
ContentCorner.CornerRadius = UDim.new(0, 6)

-- Botões das abas
local function createTabButton(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Position = UDim2.new(0, 0, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = TabsFrame

	local btnCorner = Instance.new("UICorner", btn)
	btnCorner.CornerRadius = UDim.new(0, 4)

	return btn
end

local mainTab = createTabButton("Main", 0)
local espTab = createTabButton("ESP", 35)

-- Conteúdo da aba "Main"
local NoClipButton = Instance.new("TextButton")
NoClipButton.Size = UDim2.new(0, 150, 0, 30)
NoClipButton.Position = UDim2.new(0, 20, 0, 20)
NoClipButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NoClipButton.TextColor3 = Color3.new(1, 1, 1)
NoClipButton.Text = "No Clip: OFF"
NoClipButton.Font = Enum.Font.Gotham
NoClipButton.TextSize = 14
NoClipButton.Parent = ContentFrame

local NoClipCorner = Instance.new("UICorner", NoClipButton)
NoClipCorner.CornerRadius = UDim.new(0, 6)

-- Mostrar/ocultar menu
ToggleButton.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
	ToggleButton.Visible = not Frame.Visible
end)

-- Função de No Clip
local noclipActive = false

NoClipButton.MouseButton1Click:Connect(function()
	noclipActive = not noclipActive
	NoClipButton.Text = "No Clip: " .. (noclipActive and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
	if noclipActive and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)

-- Alternância entre abas (futura expansão)
mainTab.MouseButton1Click:Connect(function()
	ContentFrame:ClearAllChildren()
	NoClipButton.Parent = ContentFrame
end)

espTab.MouseButton1Click:Connect(function()
	ContentFrame:ClearAllChildren()
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = "ESP ainda não implementado."
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.Parent = ContentFrame
end)
