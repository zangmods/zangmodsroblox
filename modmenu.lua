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
    Title = "ZangModffs Hub",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "Ink Game alfaff",
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

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ===== VARIÁVEIS GLOBAIS =====
local EspHighlights = {}
local TeamEspHighlights = {}
local TeamEspConnection = nil
local BabyEspConnection = nil
local BabyEspGuis = {}

-- ===== FUNÇÕES DOS JOGOS =====
local function CreateExitDoorsESP()
    -- Limpar highlights existentes
    for _, highlight in pairs(EspHighlights) do
        if highlight then highlight:Destroy() end
    end
    EspHighlights = {}
    
    -- Criar highlights para as portas de saída
    pcall(function()
        local exitDoors = workspace.Map.HideNSeek.Elements.ExitDoors:GetChildren()
        for i, door in pairs(exitDoors) do
            if door and (door:IsA("Model") or door:IsA("Part")) then
                local highlight = Instance.new("Highlight")
                highlight.Parent = door
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Verde
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Branco
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = door
                
                table.insert(EspHighlights, highlight)
                print("ESP aplicado na porta de saída " .. i)
            end
        end
    end)
    print("ESP ExitDoors ativado!")
end

local function RemoveExitDoorsESP()
    for _, highlight in pairs(EspHighlights) do
        if highlight then highlight:Destroy() end
    end
    EspHighlights = {}
    print("ESP ExitDoors desativado!")
end

local function TeleportToRedLightEnd()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            local safeZone = workspace.Map.RedLightGreenLight.SafeZone.Main
            if safeZone then
                local position = safeZone.Position
                hrp.CFrame = CFrame.new(position.X, position.Y + 5, position.Z)
                print("Teleportado para o fim do Red Light!")
            else
                warn("SafeZone não encontrada!")
            end
        end)
    else
        warn("Erro: HumanoidRootPart não encontrado.")
    end
end

local function CreateTeamESP()
    -- Limpar highlights existentes
    for _, highlight in pairs(TeamEspHighlights) do
        if highlight then highlight:Destroy() end
    end
    TeamEspHighlights = {}
    
    local function addHighlightToPlayer(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local vestRed = player.Character:FindFirstChild("Vest_red")
            local vestBlue = player.Character:FindFirstChild("Vest_blue")
            
            if vestRed or vestBlue then
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.Adornee = player.Character
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                
                if vestRed then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Vermelho
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    print("ESP aplicado no jogador " .. player.Name .. " (Team Red)")
                elseif vestBlue then
                    highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Azul
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    print("ESP aplicado no jogador " .. player.Name .. " (Team Blue)")
                end
                
                table.insert(TeamEspHighlights, highlight)
            end
        end
    end
    
    -- Aplicar ESP em todos os jogadores atuais
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player then
            pcall(function()
                addHighlightToPlayer(player)
            end)
        end
    end
    
    -- Monitorar novos jogadores
    TeamEspConnection = game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(2) -- Aguardar o personagem carregar completamente
            pcall(function()
                addHighlightToPlayer(player)
            end)
        end)
    end)
    
    print("ESP Teams ativado!")
end

local function RemoveTeamESP()
    for _, highlight in pairs(TeamEspHighlights) do
        if highlight then highlight:Destroy() end
    end
    TeamEspHighlights = {}
    
    if TeamEspConnection then
        TeamEspConnection:Disconnect()
        TeamEspConnection = nil
    end
    
    print("ESP Teams desativado!")
end

local function RemoveJumpRope()
    pcall(function()
        local rope = workspace.Map.JumpRope.Rope
        if rope then
            rope:Destroy()
            print("Jump Rope removida!")
        else
            warn("Rope não encontrada!")
        end
    end)
end

local function CreateBabyESP()
    -- Limpar ESPs existentes
    for _, gui in pairs(BabyEspGuis) do
        if gui then gui:Destroy() end
    end
    BabyEspGuis = {}
    
    local function addBabyESP(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("BabyBack") then
            -- Criar BillboardGui
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Parent = player.Character.HumanoidRootPart
            billboardGui.Size = UDim2.new(0, 100, 0, 50)
            billboardGui.StudsOffset = Vector3.new(0, 3, 0)
            billboardGui.AlwaysOnTop = true
            
            -- Criar TextLabel
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = billboardGui
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "BABY"
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Amarelo
            textLabel.TextScaled = true
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Contorno preto
            textLabel.Font = Enum.Font.SourceSansBold
            
            table.insert(BabyEspGuis, billboardGui)
            print("ESP Baby aplicado no jogador " .. player.Name)
        end
    end
    
    -- Verificar todos os jogadores atuais
    for _, player in pairs(game.Players:GetPlayers()) do
        pcall(function()
            addBabyESP(player)
        end)
    end
    
    -- Monitorar mudanças nos jogadores
    BabyEspConnection = RunService.Heartbeat:Connect(function()
        -- Limpar ESPs antigos
        for i = #BabyEspGuis, 1, -1 do
            local gui = BabyEspGuis[i]
            if not gui or not gui.Parent or not gui.Parent.Parent or not gui.Parent.Parent:FindFirstChild("BabyBack") then
                if gui then gui:Destroy() end
                table.remove(BabyEspGuis, i)
            end
        end
        
        -- Adicionar novos ESPs
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("BabyBack") then
                local hasESP = false
                for _, gui in pairs(BabyEspGuis) do
                    if gui and gui.Parent and gui.Parent.Parent == player.Character then
                        hasESP = true
                        break
                    end
                end
                
                if not hasESP then
                    pcall(function()
                        addBabyESP(player)
                    end)
                end
            end
        end
    end)
    
    print("ESP Baby ativado!")
end

local function RemoveBabyESP()
    for _, gui in pairs(BabyEspGuis) do
        if gui then gui:Destroy() end
    end
    BabyEspGuis = {}
    
    if BabyEspConnection then
        BabyEspConnection:Disconnect()
        BabyEspConnection = nil
    end
    
    print("ESP Baby desativado!")
end

local Tabs = {}

-- ABA MAIN
Tabs.Main = Window:Tab({ Title = "Main", Icon = "home" })

-- ===== INTERFACE - ABAS DIRETAS =====
Tabs.RedLight = Window:Tab({ Title = "Red Light", Icon = "alert-octagon" })
Tabs.Dalgona = Window:Tab({ Title = "Dalgona", Icon = "circle" })
Tabs.TugOfWar = Window:Tab({ Title = "Tug of War", Icon = "git-merge" })
Tabs.HideAndSeek = Window:Tab({ Title = "Hide and Seek", Icon = "eye-off" })
Tabs.JumpRope = Window:Tab({ Title = "Jump Rope", Icon = "move" })
Tabs.GlassBridge = Window:Tab({ Title = "Glass Bridge", Icon = "square" })
Tabs.Mingle = Window:Tab({ Title = "Mingle", Icon = "users" })
Tabs.Final = Window:Tab({ Title = "Final", Icon = "flag" })

-- ===== ABA MAIN =====
Tabs.Main:Toggle({
    Title = "Esp Baby",
    Description = "Mostra texto 'BABY' em cima do jogador que tem BabyBack",
    Value = false,
    Callback = function(state)
        if state then
            CreateBabyESP()
        else
            RemoveBabyESP()
        end
    end
})

Tabs.Main:Toggle({
    Title = "Ativar",
    Description = "Toggle de exemplo",
    Value = false,
    Callback = function(state)
        print("Main: " .. tostring(state))
    end
})

-- ===== ABA RED LIGHT =====
Tabs.RedLight:Button({
    Title = "Teleportar pro Fim",
    Description = "Teleporta para cima da SafeZone",
    Callback = function()
        TeleportToRedLightEnd()
    end
})

Tabs.RedLight:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Red Light: " .. tostring(state))
    end
})

-- ===== ABA DALGONA =====
Tabs.Dalgona:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Dalgona: " .. tostring(state))
    end
})

-- ===== ABA TUG OF WAR =====
Tabs.TugOfWar:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Tug of War: " .. tostring(state))
    end
})

-- ===== ABA HIDE AND SEEK =====
Tabs.HideAndSeek:Toggle({
    Title = "Esp ExitDoors",
    Description = "Mostra highlight verde nas portas de saída",
    Value = false,
    Callback = function(state)
        if state then
            CreateExitDoorsESP()
        else
            RemoveExitDoorsESP()
        end
    end
})

Tabs.HideAndSeek:Toggle({
    Title = "Esp Teams",
    Description = "Mostra highlight nos jogadores com Vest_red (vermelho) e Vest_blue (azul)",
    Value = false,
    Callback = function(state)
        if state then
            CreateTeamESP()
        else
            RemoveTeamESP()
        end
    end
})

Tabs.HideAndSeek:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Hide and Seek: " .. tostring(state))
    end
})

-- ===== ABA JUMP ROPE =====
Tabs.JumpRope:Toggle({
    Title = "Remove Rope",
    Description = "Remove a corda do Jump Rope",
    Value = false,
    Callback = function(state)
        if state then
            RemoveJumpRope()
        end
    end
})

Tabs.JumpRope:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Jump Rope: " .. tostring(state))
    end
})

-- ===== ABA GLASS BRIDGE =====
Tabs.GlassBridge:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Glass Bridge: " .. tostring(state))
    end
})

-- ===== ABA MINGLE =====
Tabs.Mingle:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Mingle: " .. tostring(state))
    end
})

-- ===== ABA FINAL =====
Tabs.Final:Toggle({
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Final: " .. tostring(state))
    end
})

Window:SelectTab(1)
Window:OnClose(function()
    print("UI fechada.")
end)

print("ZangMods Hub carregado!")
print("Script base limpo - Pronto para novo jogo!")
