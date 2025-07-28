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
    Title = "WindUI Library",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "Example UI",
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

    -- remove it below if you don't want to use the key system in your script.
    KeySystem = { -- <- keysystem enabled
        Key = { "1234", "5678" },
        Note = "Example Key System. \n\nThe Key is '1234' or '5678",
        -- Thumbnail = {
        --     Image = "rbxassetid://18220445082", -- rbxassetid only
        --     Title = "Thumbnail"
        -- },
        URL = "link-to-linkvertise-or-discord-or-idk", -- remove this if the key is not obtained from the link.
        SaveKey = true, -- saves key : optional
    },
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
    Title = "Open Example UI",
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

-- Funções da aba Extra (SEM DUPLICAÇÃO)
local SpeedEnabled = false
local CurrentSpeed = 16
local Player = game.Players.LocalPlayer
local Humanoid = nil

local function updateHumanoid()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Humanoid = Player.Character.Humanoid
    end
end

local function setSpeed(speed)
    updateHumanoid()
    if Humanoid then
        Humanoid.WalkSpeed = speed
    end
end

-- Atualiza referência do Humanoid quando o personagem spawna
Player.CharacterAdded:Connect(function()
    updateHumanoid()
    if SpeedEnabled then
        wait(1) -- Aguarda carregamento
        setSpeed(CurrentSpeed)
    end
end)

-- Inicializa Humanoid
updateHumanoid()

-- Toggle para ativar/desativar alteração de velocidade
Tabs.Extra:Toggle({
    Title = "Alterar Velocidade",
    Value = false,
    Callback = function(state)
        SpeedEnabled = state
        if state then
            setSpeed(CurrentSpeed)
            print("Velocidade ativada: " .. CurrentSpeed)
        else
            setSpeed(16) -- Velocidade padrão do Roblox
            print("Velocidade desativada (padrão: 16)")
        end
    end
})

-- Slider para escolher a velocidade
Tabs.Extra:Slider({
    Title = "Velocidade do Personagem",
    Value = {
        Min = 1,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        CurrentSpeed = value
        if SpeedEnabled then
            setSpeed(CurrentSpeed)
        end
        print("Velocidade definida para: " .. value)
    end
})

-- Funções da aba ESP
local ESPEnabled = false
local ESPConnections = {}
local ESPObjects = {}

-- Função para criar ESP Name
local function createESP(player)
    if player == Player then return end -- Não criar ESP para si mesmo
    
    local function addESP()
        if player.Character and player.Character:FindFirstChild("Head") then
            -- Remove ESP existente se houver
            if ESPObjects[player.Name] then
                ESPObjects[player.Name]:Destroy()
                ESPObjects[player.Name] = nil
            end
            
            local head = player.Character.Head
            local billboard = Instance.new("BillboardGui")
            local nameLabel = Instance.new("TextLabel")
            
            billboard.Name = "ESP_" .. player.Name
            billboard.Parent = head
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
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
            
            ESPObjects[player.Name] = billboard
        end
    end
    
    if player.Character then
        addESP()
    end
    
    ESPConnections[player.Name] = player.CharacterAdded:Connect(addESP)
end

-- Função para remover ESP
local function removeESP(player)
    if ESPObjects[player.Name] then
        ESPObjects[player.Name]:Destroy()
        ESPObjects[player.Name] = nil
    end
    
    if ESPConnections[player.Name] then
        ESPConnections[player.Name]:Disconnect()
        ESPConnections[player.Name] = nil
    end
end

-- Função para ativar/desativar ESP para todos os jogadores
local function toggleESP(enabled)
    ESPEnabled = enabled
    
    if enabled then
        -- Adiciona ESP para todos os jogadores atuais
        for _, player in pairs(game.Players:GetPlayers()) do
            createESP(player)
        end
        
        -- Conecta evento para novos jogadores
        ESPConnections.PlayerAdded = game.Players.PlayerAdded:Connect(createESP)
        ESPConnections.PlayerRemoving = game.Players.PlayerRemoving:Connect(removeESP)
    else
        -- Remove ESP de todos os jogadores
        for _, player in pairs(game.Players:GetPlayers()) do
            removeESP(player)
        end
        
        -- Desconecta eventos
        if ESPConnections.PlayerAdded then
            ESPConnections.PlayerAdded:Disconnect()
            ESPConnections.PlayerAdded = nil
        end
        if ESPConnections.PlayerRemoving then
            ESPConnections.PlayerRemoving:Disconnect()
            ESPConnections.PlayerRemoving = nil
        end
    end
end

-- Toggle ESP Name na aba ESP
Tabs.ESP:Toggle({
    Title = "ESP Name",
    Value = false,
    Callback = function(state)
        toggleESP(state)
        print("ESP Name: " .. tostring(state))
    end
})

-- Função para Red Light - Teleportar 500 passos à frente
local function teleportForward(distance)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        local currentPosition = humanoidRootPart.Position
        local lookDirection = humanoidRootPart.CFrame.LookVector
        local newPosition = currentPosition + (lookDirection * distance)
        
        humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + lookDirection)
        print("Teleportado " .. distance .. " passos à frente!")
    else
        print("Erro: Personagem não encontrado!")
    end
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
                print(tab.Title .. ": " .. tostring(state))
            end
        })
    end
end

-- Aba Mingle com função especial de atravessar paredes
local NoClipEnabled = false
local Character = Player.Character or Player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local NoClipConnection

local function toggleNoClip(enabled)
    if enabled then
        NoClipConnection = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
        end
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
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
        NoClipEnabled = state
        toggleNoClip(state)
        print("NoClip: " .. tostring(state))
    end
})

-- Reconectar NoClip quando o personagem respawnar
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    if NoClipEnabled then
        wait(1) -- Aguarda um pouco para o personagem carregar completamente
        toggleNoClip(true)
    end
end)

-- Seleciona a primeira aba
Window:SelectTab(1)

-- function :OnClose()
Window:OnClose(function()
    print("UI closed.")
    -- Limpa ESP ao fechar
    toggleESP(false)
end)
