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
                        -- Vidros seguros geralmente têm CanCollide = true
                        -- Vidros falsos podem ter CanCollide = false ou outras propriedades diferentes
                        if part.CanCollide == true and part.Transparency < 1 then
                            -- Vidro seguro - verde
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            print("Vidro seguro detectado: " .. glass.Name)
                        else
                            -- Vidro perigoso - vermelho
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            print("Vidro perigoso detectado: " .. glass.Name)
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
                    print("Vidro seguro detectado: " .. glass.Name)
                else
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    print("Vidro perigoso detectado: " .. glass.Name)
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
                print("Forma: " .. shape.Name .. " - processando " .. #pathParts .. " parts")
                
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
                            currentSize.X * 3,  -- X aumenta 3x
                            currentSize.Y * 3,  -- Y aumenta 3x  
                            currentSize.Z * 3   -- Z aumenta 3x
                        )
                        
                        print("Part " .. i .. ": " .. 
                              string.format("%.3f,%.3f,%.3f", currentSize.X, currentSize.Y, currentSize.Z) .. 
                              " → " .. 
                              string.format("%.3f,%.3f,%.3f", part.Size.X, part.Size.Y, part.Size.Z))
                    end
                end
                
                print("Forma " .. shape.Name .. " processada!")
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
                            
                            print("Part " .. i .. " restaurada!")
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

-- ===== FLING PLAYERS =====
local function StartFling()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then
        warn("HumanoidRootPart ou Humanoid não encontrado!")
        return
    end

    FlingEnabled = true
    print("🚀 Fling Players ativado! Encoste nos jogadores para jogá-los longe!")

    -- Método "detached part" para Fling REAL server-side
    -- Cria uma part invisível, MASSIVA, Weldada no seu HRP, e gira ela rapidamente para empurrar fisicamente os outros players
    local FlingPart = Instance.new("Part")
    FlingPart.Name = "ZangFlingPart"
    FlingPart.Size = Vector3.new(7, 7, 7)
    FlingPart.Transparency = 1
    FlingPart.Anchored = false
    FlingPart.CanCollide = true
    FlingPart.CanQuery = false
    FlingPart.CanTouch = true
    FlingPart.Massless = false
    FlingPart.Parent = workspace
    FlingPart.Position = hrp.Position + Vector3.new(0, 4, 0)
    FlingPart.Velocity = Vector3.new(0,0,0)

    -- Weld (Attachment) para seguir o HRP
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = FlingPart
    weld.Parent = FlingPart

    -- Torna a parte super pesada para garantir força (impede anticheat de te "prender", pois o HRP é o master)
    FlingPart.CustomPhysicalProperties = PhysicalProperties.new(100000,0.3,0.5)

    -- Rotação rápida para causar Fling físico real
    local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
    BodyAngularVelocity.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
    BodyAngularVelocity.AngularVelocity = Vector3.new(0, 50, 0) -- Vira MUITO RÁPIDO
    BodyAngularVelocity.P = 1e6
    BodyAngularVelocity.Parent = FlingPart

    -- Desativa PlatformStand (anti freeze)
    humanoid.PlatformStand = false
    hrp.Anchored = false

    -- Se morrer ou respawnar, limpa
    local diedConn, charConn
    diedConn = humanoid.Died:Connect(function()
        StopFling()
    end)
    charConn = Player.CharacterAdded:Connect(function()
        StopFling()
    end)

    -- Protege contra freeze do anticheat (seta a velocidade do HRP para normal)
    local lastTick = tick()
    FlingConnection = RunService.Heartbeat:Connect(function()
        if not FlingEnabled or not char or not char:IsDescendantOf(workspace) or not hrp or not humanoid then return end
        humanoid.PlatformStand = false
        hrp.Anchored = false
        -- Garante que a parte está Weldada e perto do HRP
        if not FlingPart or not FlingPart.Parent then
            StopFling()
            return
        end
        FlingPart.Position = hrp.Position + Vector3.new(0, 4, 0)
        -- Reseta velocidade do HRP caso tente prender
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        -- Pequeno pulo a cada 2seg (anti stuck)
        if tick() - lastTick > 2 then
            hrp.Velocity = Vector3.new(0, 40, 0)
            lastTick = tick()
        end
    end)

    -- Limpa tudo ao chamar StopFling
    function StopFling()
        FlingEnabled = false
        if FlingConnection then FlingConnection:Disconnect() FlingConnection = nil end
        if FlingPart and FlingPart.Parent then pcall(function() FlingPart:Destroy() end) end
        if weld then pcall(function() weld:Destroy() end) end
        if BodyAngularVelocity then pcall(function() BodyAngularVelocity:Destroy() end) end
        if diedConn then diedConn:Disconnect() end
        if charConn then charConn:Disconnect() end
        print("❌ Fling Players desativado!")
    end
end

function StopFling()
    FlingEnabled = false
    if FlingConnection then FlingConnection:Disconnect() FlingConnection = nil end
    -- Remove qualquer Part/Weld/AngularVelocity deixado para trás
    local char = Player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Part") and obj.Name == "ZangFlingPart" then
                    pcall(function() obj:Destroy() end)
                end
            end
            for _, obj in pairs(hrp:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyAngularVelocity") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
    print("❌ Fling Players desativado!")
end

-- ===== KILL AURA MELHORADO =====
local function StartKillAura()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        warn("HumanoidRootPart não encontrado!")
        return
    end
    
    -- Detectar meu time
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
    
    -- Encontrar jogador inimigo mais próximo (independente da distância)
    local function findNearestEnemy()
        local nearestEnemy = nil
        local shortestDistance = math.huge
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                local isEnemy = false
                
                -- Verificar se está vivo E se é inimigo
                if humanoid.Health > 0 then
                    if myTeam == "red" and player.Character:FindFirstChild("Vest_blue") then
                        isEnemy = true -- Sou vermelho, ele é azul = inimigo
                    elseif myTeam == "blue" and player.Character:FindFirstChild("Vest_red") then
                        isEnemy = true -- Sou azul, ele é vermelho = inimigo
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
    
    -- Sistema de auto click MELHORADO - só clica quando necessário
    local function autoClick()
        -- Removido - usuário vai clicar manualmente
    end
    
    -- Selecionar primeiro alvo
    KillAuraTarget = findNearestEnemy()
    if not KillAuraTarget then
        warn("Nenhum jogador inimigo encontrado!")
        return
    end
    
    local enemyTeam = KillAuraTarget.Character:FindFirstChild("Vest_red") and "VERMELHO" or "AZUL"
    print("Kill Aura ativado - Alvo: " .. KillAuraTarget.Name .. " (Team " .. enemyTeam .. ")")
    
    -- Variável para controlar última vida do alvo
    local lastTargetHealth = KillAuraTarget.Character.Humanoid.Health
    
    -- Sistema de clique automático com controle
    KillAuraClickConnection = RunService.Heartbeat:Connect(function()
        if KillAuraTarget and KillAuraTarget.Character and KillAuraTarget.Character:FindFirstChild("Humanoid") then
            local targetHumanoid = KillAuraTarget.Character.Humanoid
            if targetHumanoid.Health > 0 then
                -- Só clica se o alvo estiver realmente vivo e válido
                autoClick()
            end
        end
    end)
    
    -- Loop principal de teleport e controle de alvos
    KillAuraConnection = RunService.Heartbeat:Connect(function()
        -- Verificar se ainda estou no mesmo time
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
            
            -- Verificação MELHORADA se o alvo morreu
            local targetIsDead = false
            if not targetHumanoid or not targetHrp then
                targetIsDead = true
            elseif targetHumanoid.Health <= 0 then
                targetIsDead = true
            elseif targetHumanoid.PlatformStand == true then
                targetIsDead = true -- Jogador caído/morto
            elseif targetHrp.Position.Y < -100 then
                targetIsDead = true -- Caiu do mapa
            end
            
            if targetIsDead then
                print("🎯 ALVO " .. KillAuraTarget.Name .. " FOI ELIMINADO! Procurando novo inimigo...")
                
                -- Aguardar um pouco para garantir que o alvo foi processado
                wait(0.1)
                
                -- Procurar próximo alvo instantaneamente
                local newTarget = findNearestEnemy()
                if newTarget and newTarget ~= KillAuraTarget then
                    KillAuraTarget = newTarget
                    local newEnemyTeam = KillAuraTarget.Character:FindFirstChild("Vest_red") and "VERMELHO" or "AZUL"
                    print("🔄 NOVO ALVO: " .. KillAuraTarget.Name .. " (Team " .. newEnemyTeam .. ")")
                    
                    -- Teleportar IMEDIATAMENTE para o novo alvo
                    local newTargetHrp = KillAuraTarget.Character.HumanoidRootPart
                    if newTargetHrp then
                        local offset = Vector3.new(
                            math.random(-3, 3),
                            1,
                            math.random(-3, 3)
                        )
                        hrp.CFrame = CFrame.new(newTargetHrp.Position + offset, newTargetHrp.Position)
                        print("⚡ TELEPORTADO PARA NOVO ALVO!")
                        lastTargetHealth = KillAuraTarget.Character.Humanoid.Health
                    end
                else
                    print("❌ Nenhum inimigo restante! Kill Aura pausado.")
                    KillAuraTarget = nil
                end
                return
            end
            
            -- Se o alvo ainda está vivo, continuar grudando nele
            if targetHrp and targetHumanoid.Health > 0 then
                local offset = Vector3.new(
                    math.random(-2, 2),
                    0.5,
                    math.random(-2, 2)
                )
                hrp.CFrame = CFrame.new(targetHrp.Position + offset, targetHrp.Position)
            end
            
        else
            -- Alvo perdido completamente, procurar novo
            print("🔍 Alvo perdido! Procurando novo inimigo...")
            KillAuraTarget = findNearestEnemy()
            if KillAuraTarget then
                local newEnemyTeam = KillAuraTarget.Character:FindFirstChild("Vest_red") and "VERMELHO" or "AZUL"
                print("✅ Novo alvo encontrado: " .. KillAuraTarget.Name .. " (Team " .. newEnemyTeam .. ")")
                
                -- Teleportar imediatamente
                local newTargetHrp = KillAuraTarget.Character.HumanoidRootPart
                if newTargetHrp then
                    local offset = Vector3.new(
                        math.random(-3, 3),
                        1,
                        math.random(-3, 3)
                    )
                    hrp.CFrame = CFrame.new(newTargetHrp.Position + offset, newTargetHrp.Position)
                    lastTargetHealth = KillAuraTarget.Character.Humanoid.Health
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
    Title = "Safe Zone",
    Description = "Teleporta para zona segura no céu com plataforma ZangMods",
    Value = false,
    Callback = function(state)
        if state then
            CreateSafeZone()
        else
            RemoveSafeZone()
        end
    end
})

Tabs.Main:Toggle({
    Title = "Fling Players",
    Description = "Quando encosta em outro jogador, joga ele longe!",
    Value = false,
    Callback = function(state)
        if state then
            StartFling()
        else
            StopFling()
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
    Title = "Dalgona Helper",
    Description = "Aumenta as parts (3x) quando ativado, restaura quando desativado",
    Value = false,
    Callback = function(state)
        if state then
            EnlargeHoneycombParts()
        else
            RestoreHoneycombParts()
        end
    end
})

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
    Title = "Kill Aura",
    Description = "Teleporta automaticamente para inimigos - Você clica para atacar!",
    Value = false,
    Callback = function(state)
        if state then
            StartKillAura()
        else
            StopKillAura()
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
