-- ZANGMODS UI Estilo RINGTA (feito por ChatGPT + klausmodder)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Criar GUI
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "ZangModsRingtaStyle"
gui.ResetOnSpawn = false

-- Botão ícone para abrir o menu
local IconButton = Instance.new("ImageButton")
IconButton.Size = UDim2.new(0, 50, 0, 50)
IconButton.Position = UDim2.new(0, 10, 0, 10)
IconButton.BackgroundTransparency = 1
IconButton.Image = "rbxassetid://8569322835" -- ícone visual
IconButton.Parent = gui

-- Janela principal
local MainFrame = Instance.new("Frame", gui)
MainFrame.Size = UDim2.new(0, 600, 0, 330)
MainFrame.Position = UDim2.new(0, 70, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Header do menu
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Text = "⭐ ZAbbNGMODS\n<discord.gg/zang>"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 16
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.TextYAlignment = Enum.TextYAlignment.Top
Header.Position = UDim2.new(0, 15, 0, 8)

-- Menu lateral
local SideMenu = Instance.new("Frame", MainFrame)
SideMenu.Size = UDim2.new(0, 180, 1, -60)
SideMenu.Position = UDim2.new(0, 0, 0, 60)
SideMenu.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SideMenu.BorderSizePixel = 0

local SideCorner = Instance.new("UICorner", SideMenu)
SideCorner.CornerRadius = UDim.new(0, 8)

-- Conteúdo da aba
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -190, 1, -60)
Content.Position = UDim2.new(0, 190, 0, 60)
Content.BackgroundColor3 = Color3.fromRGB(32, 32, 32)

local ContentCorner = Instance.new("UICorner", Content)
ContentCorner.CornerRadius = UDim.new(0, 8)

-- Tabela de abas
local tabs = {
    {name = "Main", icon = "💡"},
    {name = "ESP", icon = "🕵️"},
    {name = "Teleport", icon = "🧭"},
    {name = "Config", icon = "⚙️"},
    {name = "Sobre", icon = "📜"},
}

local activeTab = nil
local tabButtons = {}

-- Criar botões laterais com ícones
for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton", SideMenu)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 40)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    btn.Text = tab.icon .. "  " .. tab.name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14

    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    tabButtons[tab.name] = btn

    btn.MouseButton1Click:Connect(function()
        activeTab = tab.name
        for _, child in pairs(Content:GetChildren()) do
            if not child:IsA("UICorner") then
                child:Destroy()
            end
        end

        if activeTab == "Main" then
            local btnNoClip = Instance.new("TextButton", Content)
            btnNoClip.Size = UDim2.new(0, 200, 0, 35)
            btnNoClip.Position = UDim2.new(0, 20, 0, 20)
            btnNoClip.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btnNoClip.Text = "No Clip: OFF"
            btnNoClip.TextColor3 = Color3.new(1,1,1)
            btnNoClip.Font = Enum.Font.Gotham
            btnNoClip.TextSize = 14

            local on = false
            btnNoClip.MouseButton1Click:Connect(function()
                on = not on
                btnNoClip.Text = "No Clip: " .. (on and "ON" or "OFF")
            end)

            local corner = Instance.new("UICorner", btnNoClip)
            corner.CornerRadius = UDim.new(0, 6)

            RunService.Stepped:Connect(function()
                if on and LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            local label = Instance.new("TextLabel", Content)
            label.Size = UDim2.new(1, -20, 1, -20)
            label.Position = UDim2.new(0, 10, 0, 10)
            label.Text = "Aba \"" .. activeTab .. "\" ainda está vazia."
            label.TextColor3 = Color3.new(1,1,1)
            label.Font = Enum.Font.Gotham
            label.TextSize = 16
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
        end
    end)
end

-- Abre com aba Main ativada
tabButtons["Main"]:MouseButton1Click()

-- Função de abrir/fechar o menu
IconButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
