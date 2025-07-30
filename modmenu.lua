local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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
    Title = "ZangMods fizHub",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "Ink Game alfa",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = false,
        Callback = function() print("clicked") end,
        Anonymous = true
    },
    SideBarWidth = 200,
    ScrollBarEnabled = true,
})

Window:EditOpenButton({
    Title = "Open ZangMods Hub",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"),
        Color3.fromHex("F89B29")
    ),
    Draggable = true,
})

-- ===== SISTEMA GLOBAL DE FUNÇÕES (SEMPRE ATIVO) =====
local GlobalSystem = {
    Functions = {},
}

function GlobalSystem:RegisterFunction(name, func, autoStart)
    self.Functions[name] = {
        func = func,
        active = false,
        connection = nil
    }
    if autoStart then
        self:StartFunction(name)
    end
end

function GlobalSystem:StartFunction(name)
    local fn = self.Functions[name]
    if fn and not fn.active then
        fn.active = true
        fn.connection = fn.func()
        print("Função " .. name .. " iniciada (SEMPRE ATIVO)")
    end
end

function GlobalSystem:StopFunction(name)
    local fn = self.Functions[name]
    if fn and fn.active then
        fn.active = false
        if fn.connection then
            if typeof(fn.connection) == "RBXScriptConnection" then
                fn.connection:Disconnect()
            elseif type(fn.connection) == "table" then
                for _, conn in pairs(fn.connection) do
                    if typeof(conn) == "RBXScriptConnection" then
                        conn:Disconnect()
                    end
                end
            end
        end
        fn.connection = nil
        print("Função " .. name .. " parada")
    end
end

function GlobalSystem:ClearAll()
    for name in pairs(self.Functions) do
        self:StopFunction(name)
    end
    self.Functions = {}
    print("Sistema Global limpo completamente")
end

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ===== SISTEMA DE VELOCIDADE CORRIGIDO =====
local SpeedSettings = {
    Enabled = false,
    CurrentSpeed = 16,
}
local function SetWalkSpeed(speed)
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local humanoid = Player.Character.Humanoid
        humanoid.WalkSpeed = speed
    end
end

local function CreateSpeedSystem()
    local connections = {}
    connections.heartbeat = RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            if SpeedSettings.Enabled then
                SetWalkSpeed(SpeedSettings.CurrentSpeed)
            else
                SetWalkSpeed(16)
            end
        end
    end)
    connections.characterAdded = Player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid", 5)
        RunService.Heartbeat:Wait()
        if SpeedSettings.Enabled then
            SetWalkSpeed(SpeedSettings.CurrentSpeed)
        else
            SetWalkSpeed(16)
        end
    end)
    -- Adicionado monitor para garantir funcionamento mesmo se algum script do jogo tentar resetar
    connections.humanoidChanged = nil
    local function setupHumanoidMonitor(char)
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if connections.humanoidChanged then
                connections.humanoidChanged:Disconnect()
            end
            connections.humanoidChanged = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if SpeedSettings.Enabled then
                    -- Força o valor definido, se o jogo tentar mudar
                    if hum.WalkSpeed ~= SpeedSettings.CurrentSpeed then
                        hum.WalkSpeed = SpeedSettings.CurrentSpeed
                    end
                else
                    if hum.WalkSpeed ~= 16 then
                        hum.WalkSpeed = 16
                    end
                end
            end)
        end
    end
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        setupHumanoidMonitor(Player.Character)
    end
    Player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid", 5)
        setupHumanoidMonitor(char)
    end)
    return connections
end
GlobalSystem:RegisterFunction("SpeedSystem", CreateSpeedSystem, true)

-- ===== SISTEMA ESP =====
local ESPSettings = {
    NameEnabled = false,
    HealthEnabled = false,
}
local ESPObjects, ESPConnections, HealthConnections = {}, {}, {}

local function createESPName(player)
    if player == Player then return end
    if player.Character and player.Character:FindFirstChild("Head") then
        if ESPObjects[player.Name] and ESPObjects[player.Name].Name then
            ESPObjects[player.Name].Name:Destroy()
        end
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
        ESPObjects[player.Name] = ESPObjects[player.Name] or {}
        ESPObjects[player.Name].Name = billboard
    end
end
local function removeESPName(player)
    if ESPObjects[player.Name] and ESPObjects[player.Name].Name then
        ESPObjects[player.Name].Name:Destroy()
        ESPObjects[player.Name].Name = nil
    end
end
local function removeAllESPName()
    for playerName, objects in pairs(ESPObjects) do
        if objects.Name then
            objects.Name:Destroy()
            objects.Name = nil
        end
    end
end

local function createESPHealth(player)
    if player == Player then return end
    if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
        if ESPObjects[player.Name] and ESPObjects[player.Name].Health then
            ESPObjects[player.Name].Health:Destroy()
        end
        local head = player.Character.Head
        local humanoid = player.Character.Humanoid
        local billboard = Instance.new("BillboardGui")
        local frame = Instance.new("Frame")
        local bar = Instance.new("Frame")
        local text = Instance.new("TextLabel")
        billboard.Name = "ESP_Health_" .. player.Name
        billboard.Parent = head
        billboard.Size = UDim2.new(0, 100, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 1.5, 0)
        billboard.AlwaysOnTop = true
        frame.Parent = billboard
        frame.Size = UDim2.new(1, 0, 0.7, 0)
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(255,255,255)
        bar.Parent = frame
        bar.Size = UDim2.new(humanoid.Health/humanoid.MaxHealth,0,1,0)
        bar.Position = UDim2.new(0,0,0,0)
        bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
        text.Parent = billboard
        text.Size = UDim2.new(1,0,0.3,0)
        text.Position = UDim2.new(0,0,0.7,0)
        text.BackgroundTransparency = 1
        text.Text = math.floor(humanoid.Health).."/"..math.floor(humanoid.MaxHealth)
        text.TextColor3 = Color3.fromRGB(255,255,255)
        text.TextScaled = true
        text.TextStrokeTransparency = 0
        text.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        text.Font = Enum.Font.SourceSans
        local function updateHealth()
            if bar and text and humanoid then
                local pct = humanoid.Health/humanoid.MaxHealth
                bar.Size = UDim2.new(pct,0,1,0)
                bar.BackgroundColor3 = pct>0.6 and Color3.fromRGB(0,255,0) or (pct>0.3 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
                text.Text = math.floor(humanoid.Health).."/"..math.floor(humanoid.MaxHealth)
            end
        end
        if HealthConnections[player.Name] and HealthConnections[player.Name].HealthChanged then
            HealthConnections[player.Name].HealthChanged:Disconnect()
        end
        HealthConnections[player.Name] = HealthConnections[player.Name] or {}
        HealthConnections[player.Name].HealthChanged = humanoid.HealthChanged:Connect(updateHealth)
        ESPObjects[player.Name] = ESPObjects[player.Name] or {}
        ESPObjects[player.Name].Health = billboard
    end
end
local function removeESPHealth(player)
    if ESPObjects[player.Name] and ESPObjects[player.Name].Health then
        ESPObjects[player.Name].Health:Destroy()
        ESPObjects[player.Name].Health = nil
    end
    if HealthConnections[player.Name] and HealthConnections[player.Name].HealthChanged then
        HealthConnections[player.Name].HealthChanged:Disconnect()
        HealthConnections[player.Name].HealthChanged = nil
    end
end
local function removeAllESPHealth()
    for playerName, objects in pairs(ESPObjects) do
        if objects.Health then
            objects.Health:Destroy()
            objects.Health = nil
        end
    end
    for playerName, conns in pairs(HealthConnections) do
        if conns.HealthChanged then
            conns.HealthChanged:Disconnect()
            conns.HealthChanged = nil
        end
    end
end

local function ESPUpdater()
    local connections = {}
    connections.playerAdded = game.Players.PlayerAdded:Connect(function(player)
        if ESPSettings.NameEnabled then createESPName(player) end
        if ESPSettings.HealthEnabled then createESPHealth(player) end
    end)
    connections.playerRemoving = game.Players.PlayerRemoving:Connect(function(player)
        removeESPName(player)
        removeESPHealth(player)
    end)
    connections.heartbeat = RunService.Heartbeat:Connect(function()
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= Player and player.Character then
                if ESPSettings.NameEnabled then
                    if not ESPObjects[player.Name] or not ESPObjects[player.Name].Name or not ESPObjects[player.Name].Name.Parent then
                        createESPName(player)
                    end
                end
                if ESPSettings.HealthEnabled then
                    if not ESPObjects[player.Name] or not ESPObjects[player.Name].Health or not ESPObjects[player.Name].Health.Parent then
                        createESPHealth(player)
                    end
                end
            end
        end
    end)
    return connections
end
GlobalSystem:RegisterFunction("ESPSystem", ESPUpdater, true)

-- ===== SISTEMA NOCLIP CORRIGIDO =====
local NoClipSettings = { Enabled = false }
local function SetNoClipEnabled(enabled)
    if Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
end

local function CreateNoClipSystem()
    local connections = {}
    connections.stepped = RunService.Stepped:Connect(function()
        if NoClipSettings.Enabled and Player.Character then
            -- Força repetidamente para garantir que não volta
            SetNoClipEnabled(true)
        end
    end)
    connections.characterAdded = Player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid", 5)
        RunService.Heartbeat:Wait()
        if NoClipSettings.Enabled then
            SetNoClipEnabled(true)
        else
            SetNoClipEnabled(false)
        end
        -- Adiciona monitor para garantir que partes novas fiquem sem colisão
        char.DescendantAdded:Connect(function(desc)
            if NoClipSettings.Enabled and desc:IsA("BasePart") then
                desc.CanCollide = false
            end
        end)
    end)
    -- Monitor para garantir que partes novas fiquem sem colisão mesmo em personagem já existente
    if Player.Character then
        Player.Character.DescendantAdded:Connect(function(desc)
            if NoClipSettings.Enabled and desc:IsA("BasePart") then
                desc.CanCollide = false
            end
        end)
    end
    return connections
end
GlobalSystem:RegisterFunction("NoClipSystem", CreateNoClipSystem, true)

-- ===== INTERFACE DO USUÁRIO =====
local Tabs = {}
local SectionGames = Window:Section({ Title = "Jogos", Opened = true })
local SectionExtra = Window:Section({ Title = "Funções Extras", Opened = true })
Tabs.RedLight = SectionGames:Tab({ Title = "Red Light", Icon = "alert-octagon" })
Tabs.Dalgona = SectionGames:Tab({ Title = "Dalgona", Icon = "circle" })
Tabs.TugOfWar = SectionGames:Tab({ Title = "Tug of War", Icon = "git-merge" })
Tabs.HideAndSeek = SectionGames:Tab({ Title = "Hide and Seek", Icon = "eye-off" })
Tabs.JumpRope = SectionGames:Tab({ Title = "Jump Rope", Icon = "move" })
Tabs.GlassBridge = SectionGames:Tab({ Title = "Glass Bridge", Icon = "square" })
Tabs.Mingle = SectionGames:Tab({ Title = "Mingle", Icon = "users" })
Tabs.Final = SectionGames:Tab({ Title = "Final", Icon = "flag" })
Tabs.Extra = SectionExtra:Tab({ Title = "Funções Extra", Icon = "wand" })
Tabs.ESP = SectionExtra:Tab({ Title = "ESP", Icon = "eye" })

Tabs.Extra:Toggle({
    Title = "Alterar Velocidade",
    Value = false,
    Callback = function(state)
        SpeedSettings.Enabled = state
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = state and SpeedSettings.CurrentSpeed or 16
        end
        print("Velocidade: " .. tostring(state) .. " - SEMPRE ATIVO!")
    end
})
Tabs.Extra:Slider({
    Title = "Velocidade do Personagem",
    Value = { Min = 1, Max = 100, Default = 16 },
    Callback = function(value)
        SpeedSettings.CurrentSpeed = value
        if SpeedSettings.Enabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = value
        end
        print("Velocidade definida para: " .. value .. " - SEMPRE ATIVO!")
    end
})
Tabs.ESP:Toggle({
    Title = "ESP Name",
    Value = false,
    Callback = function(state)
        ESPSettings.NameEnabled = state
        if state then
            for _, player in pairs(game.Players:GetPlayers()) do
                createESPName(player)
            end
        else
            removeAllESPName()
        end
        print("ESP Name: " .. tostring(state) .. " - SEMPRE ATIVO!")
    end
})
Tabs.ESP:Toggle({
    Title = "ESP Health",
    Value = false,
    Callback = function(state)
        ESPSettings.HealthEnabled = state
        if state then
            for _, player in pairs(game.Players:GetPlayers()) do
                createESPHealth(player)
            end
        else
            removeAllESPHealth()
        end
        print("ESP Health: " .. tostring(state) .. " - SEMPRE ATIVO!")
    end
})

local function teleportForward(distance)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character.HumanoidRootPart
        local pos, dir = hrp.Position, hrp.CFrame.LookVector
        local newPos = pos + (dir * distance)
        hrp.CFrame = CFrame.new(newPos, newPos + dir)
        print("Teleportado " .. distance .. " passos à frente!")
    else
        print("Erro: Personagem não encontrado!")
    end
end

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
        SetNoClipEnabled(state)
        print("NoClip: " .. tostring(state) .. " - SEMPRE ATIVO!")
    end
})

Window:SelectTab(1)
Window:OnClose(function()
    print("UI fechada completamente - limpando sistemas...")
    GlobalSystem:ClearAll()
    print("Todos os sistemas foram limpos.")
end)

print("ZangMods Hub carregado com sistemas SEMPRE ATIVOS!")
print("As funções continuam funcionando mesmo minimizando a UI!")
print("CORREÇÃO FINAL: ESP, Speed, NoClip SEMPRE ATIVOS e funcionando!")
