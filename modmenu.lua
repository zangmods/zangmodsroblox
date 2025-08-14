--[[
    Script: Squid Game X
    Autor: ZangMods
    Descrição: Hub de utilidades para o jogo.
    Status: BETA
]]

-- Carregar a biblioteca da interface
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Criar a janela principal
local Window = WindUI:CreateWindow({
    Title = "Squid Game X",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "ZangMods",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 480), -- Aumentei um pouco a altura para o aviso
    Transparent = true,
    Theme = "Dark",
})

-- Configurar o botão para abrir/fechar a UI
Window:EditOpenButton({
    Title = "Open ZangMods Hub",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"),
        Color3.fromHex("F89B29")
    ),
    Draggable = true,
})

-- Serviços e variáveis do Roblox
local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- ===== VARIÁVEIS GLOBAIS PARA AS FUNÇÕES =====
local EspHighlights = {}
local TeamEspHighlights = {}
local TeamEspConnection = nil
local BabyEspGuis = {}
local BabyEspConnection = nil
local GlassEspHighlights = {}
local SafeZonePart = nil
local OriginalPosition = nil
local KillAuraConnection = nil
local KillAuraTarget = nil
local WalkConnection = nil -- Conexão para a caminhada automática

-- ===== FUNÇÕES DE UTILIDADE =====

local function cleanupConnections()
    -- Função para limpar todas as conexões ativas ao fechar a UI ou mudar de função
    if TeamEspConnection then TeamEspConnection:Disconnect() end
    if BabyEspConnection then BabyEspConnection:Disconnect() end
    if KillAuraConnection then KillAuraConnection:Disconnect() end
    if WalkConnection then WalkConnection:Disconnect() end
    TeamEspConnection, BabyEspConnection, KillAuraConnection, WalkConnection = nil, nil, nil, nil
end

local function cleanupHighlights(tbl)
    for _, highlight in pairs(tbl) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    return {}
end

local function cleanupGuis(tbl)
    for _, gui in pairs(tbl) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    return {}
end

-- ===== FUNÇÕES DOS JOGOS =====

local function CreateExitDoorsESP()
    EspHighlights = cleanupHighlights(EspHighlights)
    pcall(function()
        for _, door in ipairs(Workspace.Map.HideNSeek.Elements.ExitDoors:GetChildren()) do
            if door and (door:IsA("Model") or door:IsA("Part")) then
                local highlight = Instance.new("Highlight", door)
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.Adornee = door
                table.insert(EspHighlights, highlight)
            end
        end
    end)
end

local function WalkToRedLightEnd()
    local char = Player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    pcall(function()
        local safeZone = Workspace.Map.RedLightGreenLight.SafeZone.Main
        if safeZone then
            humanoid:MoveTo(safeZone.Position)
            -- Para caso o jogador seja parado por algum motivo, ele tenta continuar
            if WalkConnection then WalkConnection:Disconnect() end
            WalkConnection = humanoid.MoveToFinished:Connect(function(reached)
                if not reached then
                    task.wait(0.5)
                    humanoid:MoveTo(safeZone.Position)
                else
                    WalkConnection:Disconnect()
                    WalkConnection = nil
                end
            end)
        end
    end)
end

local function CreateTeamESP()
    TeamEspHighlights = cleanupHighlights(TeamEspHighlights)
    if TeamEspConnection then TeamEspConnection:Disconnect() TeamEspConnection = nil end

    local function addHighlightToPlayer(plr)
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local isRed = plr.Character:FindFirstChild("Vest_red")
            local isBlue = plr.Character:FindFirstChild("Vest_blue")
            if isRed or isBlue then
                local highlight = Instance.new("Highlight", plr.Character)
                highlight.Adornee = plr.Character
                highlight.FillTransparency = 0.5
                highlight.FillColor = isRed and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                table.insert(TeamEspHighlights, highlight)
            end
        end
    end

    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= Player then pcall(addHighlightToPlayer, p) end
    end

    TeamEspConnection = game:GetService("Players").PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function() task.wait(2) pcall(addHighlightToPlayer, p) end)
    end)
end

local function RemoveJumpRope()
    pcall(function()
        local rope = Workspace.Map.JumpRope.Rope
        if rope then rope:Destroy() end
    end)
end

local function CreateBabyESP()
    BabyEspGuis = cleanupGuis(BabyEspGuis)
    if BabyEspConnection then BabyEspConnection:Disconnect() BabyEspConnection = nil end

    local function addBabyESP(plr)
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("BabyBack") then
            local gui = Instance.new("BillboardGui", char.HumanoidRootPart)
            gui.Size = UDim2.new(0, 100, 0, 50)
            gui.StudsOffset = Vector3.new(0, 3, 0)
            gui.AlwaysOnTop = true
            local text = Instance.new("TextLabel", gui)
            text.Size = UDim2.fromScale(1, 1)
            text.BackgroundTransparency = 1
            text.Text = "BABY"
            text.TextColor3 = Color3.fromRGB(255, 255, 0)
            text.TextScaled = true
            text.Font = Enum.Font.SourceSansBold
            table.insert(BabyEspGuis, gui)
        end
    end

    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do pcall(addBabyESP, p) end
    
    BabyEspConnection = RunService.Heartbeat:Connect(function()
        for i = #BabyEspGuis, 1, -1 do
            local gui = BabyEspGuis[i]
            if not (gui and gui.Parent and gui.Parent.Parent and gui.Parent.Parent:FindFirstChild("BabyBack")) then
                if gui then gui:Destroy() end
                table.remove(BabyEspGuis, i)
            end
        end
    end)
end

local function CreateGlassESP()
    GlassEspHighlights = cleanupHighlights(GlassEspHighlights)
    pcall(function()
        for _, glass in ipairs(Workspace.Map.Glass.Glasses:GetChildren()) do
            local partsToHighlight = {}
            if glass:IsA("Model") or glass:IsA("Folder") then
                partsToHighlight = glass:GetChildren()
            elseif glass:IsA("BasePart") then
                table.insert(partsToHighlight, glass)
            end
            for _, part in ipairs(partsToHighlight) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight", part)
                    highlight.Adornee = part
                    highlight.FillTransparency = 0.4
                    highlight.FillColor = (part.CanCollide and part.Transparency < 1) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    table.insert(GlassEspHighlights, highlight)
                end
            end
        end
    end)
end

local function EnlargeHoneycombParts(state)
    pcall(function()
        for _, shape in ipairs(Workspace.Map.Honeycomb.Shapes:GetChildren()) do
            if shape:FindFirstChild("Path") then
                for _, part in ipairs(shape.Path:GetChildren()) do
                    if part:IsA("BasePart") then
                        if state and not part:GetAttribute("OriginalSize") then
                            part:SetAttribute("OriginalSize", part.Size)
                        end
                        part.Size = state and part:GetAttribute("OriginalSize") * 3 or part:GetAttribute("OriginalSize")
                        if not state then part:SetAttribute("OriginalSize", nil) end
                    end
                end
            end
        end
    end)
end

local function CreateSafeZone()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    OriginalPosition = hrp.CFrame
    pcall(function()
        SafeZonePart = Instance.new("Part", Workspace)
        SafeZonePart.Name = "ZangModsSafeZone"
        SafeZonePart.Size = Vector3.new(10, 1, 10)
        SafeZonePart.Position = Vector3.new(0, 2000, 0)
        SafeZonePart.Anchored = true
        SafeZonePart.Material = Enum.Material.ForceField
        SafeZonePart.Color = Color3.fromRGB(0, 128, 255)
        SafeZonePart.Transparency = 0.5
        hrp.CFrame = SafeZonePart.CFrame * CFrame.new(0, 5, 0)
    end)
end

local function RemoveSafeZone()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and OriginalPosition then
        Player.Character.HumanoidRootPart.CFrame = OriginalPosition
    end
    if SafeZonePart then SafeZonePart:Destroy() SafeZonePart = nil end
    OriginalPosition = nil
end

local function StartKillAura()
    if KillAuraConnection then KillAuraConnection:Disconnect() KillAuraConnection = nil end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myTeam = char:FindFirstChild("Vest_red") and "red" or (char:FindFirstChild("Vest_blue") and "blue" or nil)
    if not myTeam then return end

    local function findNearestEnemy()
        local nearest, shortest = nil, math.huge
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local isEnemy = (myTeam == "red" and p.Character:FindFirstChild("Vest_blue")) or (myTeam == "blue" and p.Character:FindFirstChild("Vest_red"))
                if isEnemy then
                    local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortest then shortest, nearest = dist, p end
                end
            end
        end
        return nearest
    end

    KillAuraConnection = RunService.Heartbeat:Connect(function()
        if not (KillAuraTarget and KillAuraTarget.Character and KillAuraTarget.Character:FindFirstChildOfClass("Humanoid") and KillAuraTarget.Character:FindFirstChildOfClass("Humanoid").Health > 0) then
            KillAuraTarget = findNearestEnemy()
        end
        if KillAuraTarget and KillAuraTarget.Character and KillAuraTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = KillAuraTarget.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(math.random(-2,2), 0.5, math.random(-2,2)), targetHrp.Position)
        else
            -- Se não há mais alvos, para a função
            if KillAuraConnection then KillAuraConnection:Disconnect() KillAuraConnection = nil end
            KillAuraTarget = nil
        end
    end)
end

-- ===== CRIAÇÃO DA INTERFACE =====

-- ABA PRINCIPAL (MAIN)
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
MainTab:Label({ Title = "AVISO: Este script é uma versão BETA.", Color = Color3.fromRGB(255, 80, 80) })
MainTab:Divider()
MainTab:Toggle({
    Title = "ESP Bebê", Description = "Mostra quem está carregando o bebê nas costas.", Value = false,
    Callback = function(state) if state then CreateBabyESP() else BabyEspGuis = cleanupGuis(BabyEspGuis); if BabyEspConnection then BabyEspConnection:Disconnect() end end end
})
MainTab:Toggle({
    Title = "Safe Zone", Description = "Teleporta para uma plataforma segura no céu.", Value = false,
    Callback = function(state) if state then CreateSafeZone() else RemoveSafeZone() end end
})

-- ABA RED LIGHT
local RedLightTab = Window:Tab({ Title = "Red Light", Icon = "alert-octagon" })
RedLightTab:Button({
    Title = "Andar até o Fim", Description = "Caminha automaticamente até a linha de chegada.",
    Callback = WalkToRedLightEnd
})

-- ABA DALGONA
local DalgonaTab = Window:Tab({ Title = "Dalgona", Icon = "circle" })
DalgonaTab:Toggle({
    Title = "Dalgona Helper", Description = "Aumenta o tamanho das partes do desenho para facilitar.", Value = false,
    Callback = EnlargeHoneycombParts
})

-- ABA HIDE AND SEEK
local HideAndSeekTab = Window:Tab({ Title = "Hide and Seek", Icon = "eye-off" })
HideAndSeekTab:Toggle({
    Title = "ESP Portas de Saída", Description = "Destaca as portas de saída corretas.", Value = false,
    Callback = function(state) if state then CreateExitDoorsESP() else EspHighlights = cleanupHighlights(EspHighlights) end end
})
HideAndSeekTab:Toggle({
    Title = "ESP Times", Description = "Destaca os jogadores de cada time.", Value = false,
    Callback = function(state) if state then CreateTeamESP() else TeamEspHighlights = cleanupHighlights(TeamEspHighlights); if TeamEspConnection then TeamEspConnection:Disconnect() end end end
})
HideAndSeekTab:Toggle({
    Title = "Kill Aura", Description = "Gruda nos inimigos automaticamente para você atacar.", Value = false,
    Callback = function(state) if state then StartKillAura() else if KillAuraConnection then KillAuraConnection:Disconnect() KillAuraConnection = nil end KillAuraTarget = nil end end
})

-- ABA JUMP ROPE
local JumpRopeTab = Window:Tab({ Title = "Jump Rope", Icon = "move" })
JumpRopeTab:Toggle({
    Title = "Remover Corda", Description = "Remove a corda para não te atrapalhar.", Value = false,
    Callback = function(state) if state then RemoveJumpRope() end -- A corda não volta, então só precisa da ação de remover
})

-- ABA GLASS BRIDGE
local GlassBridgeTab = Window:Tab({ Title = "Glass Bridge", Icon = "square" })
GlassBridgeTab:Toggle({
    Title = "ESP Vidros", Description = "Mostra vidros seguros (verde) e perigosos (vermelho).", Value = false,
    Callback = function(state) if state then CreateGlassESP() else GlassEspHighlights = cleanupHighlights(GlassEspHighlights) end end
})

-- Seleciona a primeira aba para ser exibida
Window:SelectTab(1)

-- Função para limpar tudo ao fechar
Window:OnClose(function()
    cleanupConnections()
    cleanupHighlights(EspHighlights)
    cleanupHighlights(TeamEspHighlights)
    cleanupHighlights(GlassEspHighlights)
    cleanupGuis(BabyEspGuis)
    if SafeZonePart then SafeZonePart:Destroy() SafeZonePart = nil end
end)
