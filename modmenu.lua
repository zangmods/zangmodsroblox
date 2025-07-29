local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Test

-- Set theme:
--WindUI:SetTheme("Light")

function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
    end

    return result
end

local Window = WindUI:CreateWindow({
    Title = "ZangMods Hub",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "Ink Game Beta v",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = false, -- <- Desabilitado para remover nome anonymous
        Callback = function() print("clicked") end, -- <- optional
        Anonymous = true -- <- or true
    },
    SideBarWidth = 200,
    -- HideSearchBar = true, -- hides searchbar
    ScrollBarEnabled = true, -- enables scrollbar
    -- Background = "rbxassetid://13511292247", -- rbxassetid only
})


-- Window:SetBackgroundImage("rbxassetid://13511292247")
-- Window:SetBackgroundImageTransparency(0.9)


-- TopBar Edit

-- Disable Topbar Buttons
-- Window:DisableTopbarButtons({
--     "Close", 
--     "Minimize", 
--     "Fullscreen",
-- })

-- Botões customizados removidos - mantendo apenas os padrão (minimizar, expandir, fechar)

Window:EditOpenButton({
    Title = "Open ZangMods Hub",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    --Enabled = false,
    Draggable = true,
})

-- ===== SISTEMA GLOBAL DE FUNÇÕES (SEMPRE ATIVAS) =====
local GlobalSystem = {
    Active = true, -- Sistema sempre ativo
    Functions = {}, -- Funções registradas
    Connections = {}, -- Conexões ativas
}

-- Função para registrar uma função no sistema global
function GlobalSystem:RegisterFunction(name, func, autoStart)
    self.Functions[name] = {
        func = func,
        active = autoStart or false,
        connection = nil
    }
    if autoStart then
        self:StartFunction(name)
    end
end

-- Função para iniciar uma função
function GlobalSystem:StartFunction(name)
    if self.Functions[name] and not self.Functions[name].active then
        self.Functions[name].active = true
        if self.Functions[name].func then
            self.Functions[name].connection = self.Functions[name].func()
        end
        print("Função " .. name .. " iniciada (SEMPRE ATIVA)")
    end
end

-- Função para parar uma função
function GlobalSystem:StopFunction(name)
    if self.Functions[name] and self.Functions[name].active then
        self.Functions[name].active = false
        if self.Functions[name].connection then
            if typeof(self.Functions[name].connection) == "RBXScriptConnection" then
                self.Functions[name].connection:Disconnect()
            elseif type(self.Functions[name].connection) == "table" then
                -- Para múltiplas conexões
                for _, conn in pairs(self.Functions[name].connection) do
                    if typeof(conn) == "RBXScriptConnection" then
                        conn:Disconnect()
                    end
                end
            end
            self.Functions[name].connection = nil
        end
        print("Função " .. name .. " parada")
    end
end

-- Função para limpar todas as funções (apenas ao fechar completamente)
function GlobalSystem:ClearAll()
    for name, _ in pairs(self.Functions) do
        self:StopFunction(name)
    end
    self.Functions = {}
    print("Sistema Global limpo completamente")
end

-- ===== VARIÁVEIS GLOBAIS =====
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ===== SISTEMA DE VELOCIDADE (SEMPRE ATIVO) =====
local SpeedSettings = {
    Enabled = false,
    CurrentSpeed = 16,
}

local function CreateSpeedSystem()
    local connections = {}
    
    -- Função para aplicar velocidade
    local function applySpeed()
        pcall(function()
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                local humanoid = Player.Character.Humanoid
                if SpeedSettings.Enabled and humanoid.WalkSpeed ~= SpeedSettings.CurrentSpeed then
                    humanoid.WalkSpeed = SpeedSettings.CurrentSpeed
                elseif not SpeedSettings.Enabled and humanoid.WalkSpeed ~= 16 then
                    humanoid.WalkSpeed = 16
                end
            end
        end)
    end
    
    -- Monitoramento contínuo
    connections.heartbeat = RunService.Heartbeat:Connect(applySpeed)
    
    -- Aplicar ao respawnar
    connections.characterAdded = Player.CharacterAdded:Connect(function()
        wait(1)
        applySpeed()
    end)
    
    -- Aplicar se já há personagem
    if Player.Character then
        applySpeed()
    end
    
    return connections
end

-- Registrar sistema de velocidade
GlobalSystem:RegisterFunction("SpeedSystem", CreateSpeedSystem)

-- ===== SISTEMA ESP (SEMPRE ATIVO) =====
local ESPSettings = {
    NameEnabled = false,
    HealthEnabled = false,
}

local ESPObjects = {}
local ESPConnections = {}
local HealthConnections = {}

-- Função para limpar ESP de um jogador específico
local function clearPlayerESP(playerName, espType)
    if ESPObjects[playerName] and ESPObjects[playerName][espType] then
        ESPObjects[playerName][espType]:Destroy()
        ESPObjects[playerName][espType] = nil
    end
    
    if ESPConnections[playerName] and ESPConnections[playerName][espType] then
        ESPConnections[playerName][espType]:Disconnect()
        ESPConnections[playerName][espType] = nil
    end
    
    if espType == "Health" and HealthConnections[playerName] and HealthConnections[playerName].HealthChanged then
        HealthConnections[playerName].HealthChanged:Disconnect()
        HealthConnections[playerName].HealthChanged = nil
    end
end

-- Função para limpar todos os ESP de um tipo
local function clearAllESP(espType)
    for playerName, _ in pairs(ESPObjects) do
        clearPlayerESP(playerName, espType)
    end
end

-- Função para criar ESP Name
local function createESPName(player)
    if player == Player then return end
    
    local function addESPName()
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Head") then
                -- Remove ESP existente
                clearPlayerESP(player.Name, "Name")
                
                local head = player.Character.Head
                local billboard = Instance.new("BillboardGui")
                local nameLabel = Instance.new("TextLabel")
                
                billboard.Name = "ESP_Name_" .. player.Name
                billboard.Parent = head
                billboard.Size = UDim2.new(0, 200, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                
                nameLabel.Parent = billboard
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextScaled = true
                nameLabel.TextStrokeTransparency = 0
                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                nameLabel.Font = Enum.Font.SourceSansBold
                
                if not ESPObjects[player.Name] then
                    ESPObjects[player.Name] = {}
                end
                ESPObjects[player.Name].Name = billboard
            end
        end)
    end
    
    if player.Character then
        addESPName()
    end
    
    if not ESPConnections[player.Name] then
        ESPConnections[player.Name] = {}
    end
    
    if ESPConnections[player.Name].Name then
        ESPConnections[player.Name].Name:Disconnect()
    end
    ESPConnections[player.Name].Name = player.CharacterAdded:Connect(addESPName)
end

-- Função para criar ESP Health
local function createESPHealth(player)
    if player == Player then return end
    
    local function addESPHealth()
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
                -- Remove ESP existente
                clearPlayerESP(player.Name, "Health")
                
                local head = player.Character.Head
                local humanoid = player.Character.Humanoid
                local billboard = Instance.new("BillboardGui")
                local healthFrame = Instance.new("Frame")
                local healthBar = Instance.new("Frame")
                local healthText = Instance.new("TextLabel")
                
                billboard.Name = "ESP_Health_" .. player.Name
                billboard.Parent = head
                billboard.Size = UDim2.new(0, 100, 0, 20)
                billboard.StudsOffset = Vector3.new(0, 1.5, 0)
                billboard.AlwaysOnTop = true
                
                -- Frame de fundo
                healthFrame.Parent = billboard
                healthFrame.Size = UDim2.new(1, 0, 0.7, 0)
                healthFrame.Position = UDim2.new(0, 0, 0, 0)
                healthFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                healthFrame.BorderSizePixel = 1
                healthFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
                
                -- Barra de vida
                healthBar.Parent = healthFrame
                healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                healthBar.Position = UDim2.new(0, 0, 0, 0)
                healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                healthBar.BorderSizePixel = 0
                
                -- Texto da vida
                healthText.Parent = billboard
                healthText.Size = UDim2.new(1, 0, 0.3, 0)
                healthText.Position = UDim2.new(0, 0, 0.7, 0)
                healthText.BackgroundTransparency = 1
                healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
                healthText.TextScaled = true
                healthText.TextStrokeTransparency = 0
                healthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                healthText.Font = Enum.Font.SourceSans
                
                -- Atualizar barra de vida
                local function updateHealth()
                    pcall(function()
                        if healthBar and healthText and humanoid then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                            
                            if healthPercent > 0.6 then
                                healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                            elseif healthPercent > 0.3 then
                                healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                            else
                                healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            end
                            
                            healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        end
                    end)
                end
                
                if not HealthConnections[player.Name] then
                    HealthConnections[player.Name] = {}
                end
                
                if HealthConnections[player.Name].HealthChanged then
                    HealthConnections[player.Name].HealthChanged:Disconnect()
                end
                HealthConnections[player.Name].HealthChanged = humanoid.HealthChanged:Connect(updateHealth)
                
                if not ESPObjects[player.Name] then
                    ESPObjects[player.Name] = {}
                end
                ESPObjects[player.Name].Health = billboard
            end
        end)
    end
    
    if player.Character then
        addESPHealth()
    end
    
    if not ESPConnections[player.Name] then
        ESPConnections[player.Name] = {}
    end
    
    if ESPConnections[player.Name].Health then
        ESPConnections[player.Name].Health:Disconnect()
    end
    ESPConnections[player.Name].Health = player.CharacterAdded:Connect(addESPHealth)
end

-- Sistema ESP Name (CORRIGIDO)
local function CreateESPNameSystem()
    local connections = {}
    
    connections.playerAdded = game.Players.PlayerAdded:Connect(function(player)
        if ESPSettings.NameEnabled then
            createESPName(player)
        end
    end)
    
    connections.playerRemoving = game.Players.PlayerRemoving:Connect(function(player)
        clearPlayerESP(player.Name, "Name")
    end)
    
    -- Verificação contínua apenas se ESP estiver ativo
    connections.heartbeat = RunService.Heartbeat:Connect(function()
        if ESPSettings.NameEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Head") then
                    if not ESPObjects[player.Name] or not ESPObjects[player.Name].Name or not ESPObjects[player.Name].Name.Parent then
                        createESPName(player)
                    end
                end
            end
        end
    end)
    
    -- Aplicar ESP inicial se estiver ativo
    if ESPSettings.NameEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            createESPName(player)
        end
    end
    
    return connections
end

-- Sistema ESP Health (CORRIGIDO)
local function CreateESPHealthSystem()
    local connections = {}
    
    connections.playerAdded = game.Players.PlayerAdded:Connect(function(player)
        if ESPSettings.HealthEnabled then
            createESPHealth(player)
        end
    end)
    
    connections.playerRemoving = game.Players.PlayerRemoving:Connect(function(player)
        clearPlayerESP(player.Name, "Health")
    end)
    
    -- Verificação contínua apenas se ESP estiver ativo
    connections.heartbeat = RunService.Heartbeat:Connect(function()
        if ESPSettings.HealthEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
                    if not ESPObjects[player.Name] or not ESPObjects[player.Name].Health or not ESPObjects[player.Name].Health.Parent then
                        createESPHealth(player)
                    end
                end
            end
        end
    end)
    
    -- Aplicar ESP inicial se estiver ativo
    if ESPSettings.HealthEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            createESPHealth(player)
        end
    end
    
    return connections
end

-- Registrar sistemas ESP
GlobalSystem:RegisterFunction("ESPNameSystem", CreateESPNameSystem, true)
GlobalSystem:RegisterFunction("ESPHealthSystem", CreateESPHealthSystem, true)

-- ===== SISTEMA NOCLIP (SEMPRE ATIVO) =====
local NoClipSettings = {
    Enabled = false,
}

local function CreateNoClipSystem()
    local connections = {}
    
    connections.stepped = RunService.Stepped:Connect(function()
        if NoClipSettings.Enabled then
            pcall(function()
                if Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)
    
    connections.characterAdded = Player.CharacterAdded:Connect(function()
        wait(1)
        if NoClipSettings.Enabled then
            pcall(function()
                if Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)
    
    return connections
end

-- Registrar sistema NoClip
GlobalSystem:RegisterFunction("NoClipSystem", CreateNoClipSystem, true)

-- ===== INTERFACE DO USUÁRIO =====
local Tabs = {}

-- Seções
local SectionGames = Window:Section({
    Title = "Jogos",
    Opened = true,
})

local SectionExtra = Window:Section({
    Title = "Funções Extras",
    Opened = true,
})

-- Abas dos jogos
Tabs.RedLight = SectionGames:Tab({ Title = "Red Light", Icon = "alert-octagon" })
Tabs.Dalgona = SectionGames:Tab({ Title = "Dalgona", Icon = "circle" })
Tabs.TugOfWar = SectionGames:Tab({ Title = "Tug of War", Icon = "git-merge" })
Tabs.HideAndSeek = SectionGames:Tab({ Title = "Hide and Seek", Icon = "eye-off" })
Tabs.JumpRope = SectionGames:Tab({ Title = "Jump Rope", Icon = "move" })
Tabs.GlassBridge = SectionGames:Tab({ Title = "Glass Bridge", Icon = "square" })
Tabs.Mingle = SectionGames:Tab({ Title = "Mingle", Icon = "users" })
Tabs.Final = SectionGames:Tab({ Title = "Final", Icon = "flag" })

-- Abas de funções extras
Tabs.Extra = SectionExtra:Tab({ Title = "Funções Extra", Icon = "wand" })
Tabs.ESP = SectionExtra:Tab({ Title = "ESP", Icon = "eye" })

-- ===== CONTROLES DA INTERFACE (CORRIGIDOS) =====

-- Toggle Speed
Tabs.Extra:Toggle({
    Title = "Alterar Velocidade",
    Value = false,
    Callback = function(state)
        SpeedSettings.Enabled = state
        print("Velocidade: " .. tostring(state) .. " - SEMPRE ATIVO!")
    end
})

-- Slider Speed
Tabs.Extra:Slider({
    Title = "Velocidade do Personagem",
    Value = {
        Min = 1,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        SpeedSettings.CurrentSpeed = value
        print("Velocidade definida para: " .. value .. " - SEMPRE ATIVO!")
    end
})

-- Toggle ESP Name (CORRIGIDO)
Tabs.ESP:Toggle({
    Title = "ESP Name",
    Value = false,
    Callback = function(state)
        ESPSettings.NameEnabled = state
        
        if state then
            -- Ativar ESP Name para todos os jogadores
            for _, player in pairs(game.Players:GetPlayers()) do
                createESPName(player)
            end
            print("ESP Name ATIVADO - SEMPRE ATIVO!")
        else
            -- Desativar ESP Name e limpar todos
            clearAllESP("Name")
            print("ESP Name DESATIVADO - Todos os ESP Names removidos!")
        end
    end
})

-- Toggle ESP Health (CORRIGIDO)
Tabs.ESP:Toggle({
    Title = "ESP Health",
    Value = false,
    Callback = function(state)
        ESPSettings.HealthEnabled = state
        
        if state then
            -- Ativar ESP Health para todos os jogadores
            for _, player in pairs(game.Players:GetPlayers()) do
                createESPHealth(player)
            end
            print("ESP Health ATIVADO - SEMPRE ATIVO!")
        else
            -- Desativar ESP Health e limpar todos
            clearAllESP("Health")
            print("ESP Health DESATIVADO - Todos os ESP Health removidos!")
        end
    end
})

-- Função para Red Light - Teleportar 500 passos à frente
local function teleportForward(distance)
    pcall(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = Player.Character.HumanoidRootPart
            local currentPosition = humanoidRootPart.Position
            local lookDirection = humanoidRootPart.CFrame.LookVector
            local newPosition = currentPosition + (lookDirection * distance)
            
            humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + lookDirection)
            print("Teleportado " .. distance .. " passos à frente!")
        else
            print("Erro: Personagem não encontrado!")
        end
    end)
end

-- Red Light - Toggle e Teleport
Tabs.RedLight:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Red Light: " .. tostring(state))
    end
})

Tabs.RedLight:Button({
    Title = "Teleportar 500 Passos à Frente",
    Callback = function()
        teleportForward(500)
    end
})

-- Switch simples nas outras abas (exceto Mingle, RedLight, Extra e ESP)
for name, tab in pairs(Tabs) do
    if name ~= "Mingle" and name ~= "RedLight" and name ~= "Extra" and name ~= "ESP" then
        tab:Toggle({
            Title = "Ativar",
            Value = false,
            Callback = function(state)
                print(name .. ": " .. tostring(state))
            end
        })
    end
end

-- Aba Mingle com NoClip (CORRIGIDO)
Tabs.Mingle:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Mingle: " .. tostring(state))
    end
})

Tabs.Mingle:Toggle({
    Title = "Atravessar Paredes (NoClip)",
    Value = false,
    Callback = function(state)
        NoClipSettings.Enabled = state
        
        if not state then
            -- Restaura colisão quando desativado
            pcall(function()
                if Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end)
        end
        
        print("NoClip: " .. tostring(state) .. " - SEMPRE ATIVO!")
    end
})

-- Seleciona a primeira aba
Window:SelectTab(1)

-- Função OnClose - APENAS quando fechar completamente a UI
Window:OnClose(function()
    print("UI fechada completamente - limpando sistemas...")
    
    -- Limpar todos os ESP
    clearAllESP("Name")
    clearAllESP("Health")
    
    -- Restaurar velocidade normal
    SpeedSettings.Enabled = false
    pcall(function()
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = 16
        end
    end)
    
    -- Restaurar colisão
    NoClipSettings.Enabled = false
    pcall(function()
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)
    
    GlobalSystem:ClearAll()
    print("Todos os sistemas foram limpos.")
end)

print("ZangMods Hub carregado com sistemas SEMPRE ATIVOS!")
print("As funções continuarão funcionando mesmo com a UI minimizada!")
print("CORREÇÕES APLICADAS: ESP agora liga/desliga corretamente!")
