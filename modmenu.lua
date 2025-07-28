-- ZANGMODS UI Inspirado em Ringta UI
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "ZangModsModern"

-- Main container
local MainFrame = Instance.new("Frame", gui)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0, 100, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Text = "⭐ ZANGMODS\ndiscord.gg/zang"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.TextYAlignment = Enum.TextYAlignment.Top
Header.Position = UDim2.new(0, 10, 0, 5)

-- Menu lateral
local SideMenu = Instance.new("Frame", MainFrame)
SideMenu.Size = UDim2.new(0, 140, 1, -40)
SideMenu.Position = UDim2.new(0, 0, 0, 40)
SideMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local SideCorner = Instance.new("UICorner", SideMenu)
SideCorner.CornerRadius = UDim.new(0, 6)

local tabs = {"Main", "ESP", "Teleport", "Config"}
local tabButtons = {}
local activeTab = nil

-- Conteúdo da aba
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -150, 1, -40)
ContentFrame.Position = UDim2.new(0, 150, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local ContentCorner = Instance.new("UICorner", ContentFrame)
ContentCorner.CornerRadius = UDim.new(0, 6)

-- Função para criar tab
local function createTabButton(name, posY)
	local btn = Instance.new("TextButton", SideMenu)
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = name
	btn.Font = Enum.Font.Gotham
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextSize = 14

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 4)

	tabButtons[name] = btn
end

for i, name in pairs(tabs) do
	createTabButton(name, (i - 1) * 35)
end

-- Botões de exemplo
local function createButton(text, parent, y)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0, 180, 0, 30)
	btn.Position = UDim2.new(0, 20, 0, y)
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 6)
end

-- Toggle de exemplo
local function createToggle(text, parent, y)
	local label = Instance.new("TextLabel", parent)
	label.Size = UDim2.new(0, 200, 0, 30)
	label.Position = UDim2.new(0, 20, 0, y)
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = Instance.new("TextButton", parent)
	toggle.Size = UDim2.new(0, 40, 0, 20)
	toggle.Position = UDim2.new(0, 220, 0, y + 5)
	toggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	toggle.Text = "OFF"
	toggle.Font = Enum.Font.Gotham
	toggle.TextColor3 = Color3.new(1, 1, 1)
	toggle.TextSize = 12

	local corner = Instance.new("UICorner", toggle)
	corner.CornerRadius = UDim.new(0, 10)

	local on = false
	toggle.MouseButton1Click:Connect(function()
		on = not on
		toggle.Text = on and "ON" or "OFF"
		toggle.BackgroundColor3 = on and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 0, 0)
	end)
end

-- Exibir conteúdo da aba
local function showTab(name)
	for _, child in pairs(ContentFrame:GetChildren()) do
		if not child:IsA("UICorner") then
			child:Destroy()
		end
	end

	if name == "Main" then
		createButton("Teleport to End", ContentFrame, 10)
		createButton("Remove Injury", ContentFrame, 50)
		createButton("Help Player", ContentFrame, 90)
		createToggle("Help Player LOOP TILL OFF", ContentFrame, 130)
	elseif name == "ESP" then
		createButton("Enable ESP", ContentFrame, 10)
	end
end

-- Eventos dos botões
for name, btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		showTab(name)
	end)
end

-- Exibir a primeira aba por padrão
showTab("Main")
