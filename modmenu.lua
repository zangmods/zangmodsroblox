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
    Title = "Squid Game X",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "ZangMods",
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
local GlassEspHighlights = {}
local SafeZonePart = nil
local OriginalPosition = nil
local KillAuraConnection = nil
local KillAuraTarget = nil
local KillAuraClickConnection = nil
local FlingConnection = nil
local FlingEnabled = false

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

-- MODIFICADO: Agora anda até o local em vez de teleportar
local function WalkToRedLightEnd()
    local char = Player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            local safeZone = workspace.Map.RedLightGreenLight.SafeZone.Main
            if safeZone then
                local destination = safeZone.Position
                humanoid:MoveTo(destination)
                print("Andando até o fim do Red Light!")
            else
                warn("SafeZone não encontrada!")
            end
        end)
    else
        warn("Erro: Humanoid não encontrado.")
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

local function CreateGlassESP()
    -- Limpar highlights existentes
    for _, highlight in pairs(GlassEspHighlights) do
        if highlight then highlight:Destroy() end
    end
    GlassEspHighlights = {}
    
    pcall(function()
        local glassFolder = workspace.Map.Glass.Glasses
        local glasses = glassFolder:GetChildren()
        
        for _, glass in pairs(glasses) do
            if glass:IsA("Model") or glass:IsA("Folder") then
                -- Procurar por partes do vidro dentro do modelo/pasta
                local glassParts = glass:GetChildren()
                for _, part in pairs(glassParts) do
                    if part:IsA("BasePart") then
                        local highlight = Instance.new("Highlight")
                        highlight.Parent = part
                        highlight.Adornee = part
                        highlight.FillTransparency = 0.3
                        highlight.OutlineTransparency = 0
                        
                        -- Verificar propriedades para determinar se é seguro
                        if part.CanCollide == true and part.Transparency < 1 then
                            -- Vidro seguro - verde
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        else
                            -- Vidro perigoso - vermelho
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        end
                        
                        table.insert(GlassEspHighlights, highlight)
                    end
                end
            elseif glass:IsA("BasePart") then
                -- Se for uma parte direta
                local highlight = Instance.new("Highlight")
                highlight.Parent = glass
                highlight.Adornee = glass
                highlight.FillTransparency = 0.3
                highlight.OutlineTransparency = 0
                
                if glass.CanCollide == true and glass.Transparency < 1 then
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                
                table.insert(GlassEspHighlights, highlight)
            end
        end
    end)
    
    print("ESP Glass ativado! Verde = Seguro, Vermelho = Perigoso")
end

local function RemoveGlassESP()
    for _, highlight in pairs(GlassEspHighlights) do
        if highlight then highlight:Destroy() end
    end
    GlassEspHighlights = {}
    print("ESP Glass desativado!")
end

local function EnlargeHoneycombParts()
    pcall(function()
        local shapesFolder = workspace.Map.Honeycomb.Shapes
        local shapes = shapesFolder:GetChildren()
        
        print("Aumentando levemente as parts do Honeycomb...")
        
        for _, shape in pairs(shapes) do
            if shape:FindFirstChild("Path") then
                local pathParts = shape.Path:GetChildren()
                for i, part in pairs(pathParts) do
                    if part:IsA("BasePart") then
                        -- Salvar tamanho original
                        if not part:GetAttribute("OriginalSize") then
                            part:SetAttribute("OriginalSizeX", part.Size.X)
                            part:SetAttribute("OriginalSizeY", part.Size.Y)  
                            part:SetAttribute("OriginalSizeZ", part.Size.Z)
                        end
                        
                        -- Aumentar moderadamente para facilitar o clique (multiplicar por 3x)
                        local currentSize = part.Size
                        part.Size = Vector3.new(
                            currentSize.X * 3,
                            currentSize.Y * 3,
                            currentSize.Z * 3
                        )
                    end
                end
            end
        end
        
        print("Parts aumentadas! Agora deve ser mais fácil desenhar!")
    end)
end

local function RestoreHoneycombParts()
    pcall(function()
        local shapesFolder = workspace.Map.Honeycomb.Shapes
        local shapes = shapesFolder:GetChildren()
        
        print("Restaurando tamanhos originais...")
        
        for _, shape in pairs(shapes) do
            if shape:FindFirstChild("Path") then
                local pathParts = shape.Path:GetChildren()
                
                for i, part in pairs(pathParts) do
                    if part:IsA("BasePart") then
                        if part:GetAttribute("OriginalSizeX") then
                            -- Restaurar tamanho original
                            part.Size = Vector3.new(
                                part:GetAttribute("OriginalSizeX"),
                                part:GetAttribute("OriginalSizeY"),
                                part:GetAttribute("OriginalSizeZ")
                            )
                            
                            -- Remover atributos salvos
                            part:SetAttribute("OriginalSizeX", nil)
                            part:SetAttribute("OriginalSizeY", nil)
                            part:SetAttribute("OriginalSizeZ", nil)
                        end
                    end
                end
            end
        end
        
        print("Tamanhos originais restaurados!")
    end)
end

local function CreateSafeZone()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        warn("HumanoidRootPart não encontrado!")
        return
    end
    
    -- Salvar posição original
    OriginalPosition = hrp.CFrame
    
    pcall(function()
        -- Criar parte do Safe Zone bem alto
        SafeZonePart = Instance.new("Part")
        SafeZonePart.Name = "ZangModsSafeZone"
        SafeZonePart.Size = Vector3.new(10, 1, 10)
        SafeZonePart.Position = Vector3.new(0, 2000, 0) -- Bem alto no céu
        SafeZonePart.Anchored = true
        SafeZonePart.CanCollide = true
        SafeZonePart.CanQuery = false
        SafeZonePart.Material = Enum.Material.ForceField
        SafeZonePart.BrickColor = BrickColor.new("Bright blue")
        SafeZonePart.Transparency = 0.3
        SafeZonePart.Parent = workspace
        
        -- Criar texto "ZangMods" na parte
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Parent = SafeZonePart
        surfaceGui.Face = Enum.NormalId.Top
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = surfaceGui
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "ZangMods"
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextScaled = true
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.Font = Enum.Font.SourceSansBold
        
        -- Teleportar para o Safe Zone
        hrp.CFrame = CFrame.new(SafeZonePart.Position + Vector3.new(0, 5, 0))
        
        print("Safe Zone criado! Você está seguro no ZangMods Safe Zone!")
    end)
end

local function RemoveSafeZone()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Teleportar de volta para posição original
    if hrp and OriginalPosition then
        hrp.CFrame = OriginalPosition
        print("Voltou para a posição original!")
    end
    
    -- Remover parte do Safe Zone
    if SafeZonePart then
        SafeZonePart:Destroy()
        SafeZonePart = nil
        print("Safe Zone removido!")
    end
    
    OriginalPosition = nil
end

local function StartKillAura()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        warn("HumanoidRootPart não encontrado!")
        return
    end
    
    local myTeam = nil
    if char:FindFirstChild("Vest_red") then
        myTeam = "red"
        print("Você é do time VERMELHO - atacando jogadores AZUIS")
    elseif char:FindFirstChild("Vest_blue") then
        myTeam = "blue"
        print("Você é do time AZUL - atacando jogadores VERMELHOS")
    else
        warn("Você não está em nenhum time! Kill Aura cancelado.")
        return
    end
    
    local function findNearestEnemy()
        local nearestEnemy = nil
        local shortestDistance = math.huge
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                local isEnemy = false
                
                if humanoid.Health > 0 then
                    if myTeam == "red" and player.Character:FindFirstChild("Vest_blue") then
                        isEnemy = true
                    elseif myTeam == "blue" and player.Character:FindFirstChild("Vest_red") then
                        isEnemy = true
                    end
                    
                    if isEnemy then
                        local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            nearestEnemy = player
                        end
                    end
                end
            end
        end
        
        return nearestEnemy
    end
    
    KillAuraTarget = findNearestEnemy()
    if not KillAuraTarget then
        warn("Nenhum jogador inimigo encontrado!")
        return
    end
    
    local enemyTeam = KillAuraTarget.Character:FindFirstChild("Vest_red") and "VERMELHO" or "AZUL"
    print("Kill Aura ativado - Alvo: " .. KillAuraTarget.Name .. " (Team " .. enemyTeam .. ")")
    
    KillAuraConnection = RunService.Heartbeat:Connect(function()
        local currentMyTeam = nil
        if char:FindFirstChild("Vest_red") then
            currentMyTeam = "red"
        elseif char:FindFirstChild("Vest_blue") then
            currentMyTeam = "blue"
        end
        
        if currentMyTeam ~= myTeam then
            print("Mudança de time detectada! Reiniciando Kill Aura...")
            StopKillAura()
            StartKillAura()
            return
        end
        
        if KillAuraTarget and KillAuraTarget.Character then
            local targetHrp = KillAuraTarget.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = KillAuraTarget.Character:FindFirstChild("Humanoid")
            
            local targetIsDead = false
            if not targetHumanoid or not targetHrp or targetHumanoid.Health <= 0 or targetHumanoid.PlatformStand == true or targetHrp.Position.Y < -100 then
                targetIsDead = true
            end
            
            if targetIsDead then
                print("🎯 ALVO " .. KillAuraTarget.Name .. " FOI ELIMINADO! Procurando novo inimigo...")
                wait(0.1)
                
                local newTarget = findNearestEnemy()
                if newTarget and newTarget ~= KillAuraTarget then
                    KillAuraTarget = newTarget
                    local newEnemyTeam = KillAuraTarget.Character:FindFirstChild("Vest_red") and "VERMELHO" or "AZUL"
                    print("🔄 NOVO ALVO: " .. KillAuraTarget.Name .. " (Team " .. newEnemyTeam .. ")")
                    
                    local newTargetHrp = KillAuraTarget.Character.HumanoidRootPart
                    if newTargetHrp then
                        local offset = Vector3.new(math.random(-3, 3), 1, math.random(-3, 3))
                        hrp.CFrame = CFrame.new(newTargetHrp.Position + offset, newTargetHrp.Position)
                        print("⚡ TELEPORTADO PARA NOVO ALVO!")
                    end
                else
                    print("❌ Nenhum inimigo restante! Kill Aura pausado.")
                    KillAuraTarget = nil
                end
                return
            end
            
            if targetHrp and targetHumanoid.Health > 0 then
                local offset = Vector3.new(math.random(-2, 2), 0.5, math.random(-2, 2))
                hrp.CFrame = CFrame.new(targetHrp.Position + offset, targetHrp.Position)
            end
            
        else
            print("🔍 Alvo perdido! Procurando novo inimigo...")
            KillAuraTarget = findNearestEnemy()
            if KillAuraTarget then
                local newEnemyTeam = KillAuraTarget.Character:FindFirstChild("Vest_red") and "VERMELHO" or "AZUL"
                print("✅ Novo alvo encontrado: " .. KillAuraTarget.Name .. " (Team " .. newEnemyTeam .. ")")
                
                local newTargetHrp = KillAuraTarget.Character.HumanoidRootPart
                if newTargetHrp then
                    local offset = Vector3.new(math.random(-3, 3), 1, math.random(-3, 3))
                    hrp.CFrame = CFrame.new(newTargetHrp.Position + offset, newTargetHrp.Position)
                end
            else
                print("❌ Nenhum inimigo disponível!")
            end
        end
    end)
end

local function StopKillAura()
    if KillAuraConnection then
        KillAuraConnection:Disconnect()
        KillAuraConnection = nil
    end
    
    if KillAuraTarget then
        print("Kill Aura desativado - Alvo: " .. KillAuraTarget.Name .. " liberado!")
        KillAuraTarget = nil
    else
        print("Kill Aura desativado!")
    end
end

local Tabs = {}

-- ===== INTERFACE - ABAS =====
Tabs.Main = Window:Tab({ Title = "Main", Icon = "home" })
Tabs.RedLight = Window:Tab({ Title = "Red Light", Icon = "alert-octagon" })
Tabs.Dalgona = Window:Tab({ Title = "Dalgona", Icon = "circle" })
Tabs.HideAndSeek = Window:Tab({ Title = "Hide and Seek", Icon = "eye-off" })
Tabs.JumpRope = Window:Tab({ Title = "Jump Rope", Icon = "move" })
Tabs.GlassBridge = Window:Tab({ Title = "Glass Bridge", Icon = "square" })

-- ===== ABA MAIN =====
Tabs.Main:Label({
    Title = "AVISO: Este script está em versão BETA.",
    Color = Color3.fromRGB(255, 80, 80) 
})
Tabs.Main:Divider()

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
    Title = "Safe Zone",
    Description = "Teleporta para uma plataforma segura no céu",
    Value = false,
    Callback = function(state)
        if state then
            CreateSafeZone()
        else
            RemoveSafeZone()
        end
    end
})

-- ===== ABA RED LIGHT =====
Tabs.RedLight:Button({
    Title = "Andar até o Fim",
    Description = "Anda automaticamente até a SafeZone",
    Callback = function()
        WalkToRedLightEnd()
    end
})

-- ===== ABA DALGONA =====
Tabs.Dalgona:Toggle({
    Title = "Dalgona Helper",
    Description = "Aumenta as parts do desenho para facilitar o recorte",
    Value = false,
    Callback = function(state)
        if state then
            EnlargeHoneycombParts()
        else
            RestoreHoneycombParts()
        end
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
    Description = "Mostra highlight nos jogadores de cada time",
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
    Title = "Kill Aura",
    Description = "Teleporta automaticamente para inimigos. Você clica para atacar!",
    Value = false,
    Callback = function(state)
        if state then
            StartKillAura()
        else
            StopKillAura()
        end
    end
})

-- ===== ABA JUMP ROPE =====
Tabs.JumpRope:Toggle({
    Title = "Remove Rope",
    Description = "Remove a corda do minigame para não te atrapalhar",
    Value = false,
    Callback = function(state)
        if state then
            RemoveJumpRope()
        end
    end
})

-- ===== ABA GLASS BRIDGE =====
Tabs.GlassBridge:Toggle({
    Title = "Esp Glass",
    Description = "Mostra vidros seguros (verde) e perigosos (vermelho)",
    Value = false,
    Callback = function(state)
        if state then
            CreateGlassESP()
        else
            RemoveGlassESP()
        end
    end
})

Window:SelectTab(1)
Window:OnClose(function()
    print("UI fechada.")
end)

print("Squid Game X by ZangMods Carregado!")
