local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Squid Game X",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "ZangMods",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
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

-- ===== FUNÇÕES DOS JOGOS =====
local function CreateExitDoorsESP()
    for _, highlight in pairs(EspHighlights) do
        if highlight then highlight:Destroy() end
    end
    EspHighlights = {}
    
    pcall(function()
        local exitDoors = workspace.Map.HideNSeek.Elements.ExitDoors:GetChildren()
        for i, door in pairs(exitDoors) do
            if door and (door:IsA("Model") or door:IsA("Part")) then
                local highlight = Instance.new("Highlight")
                highlight.Parent = door
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = door
                table.insert(EspHighlights, highlight)
            end
        end
    end)
end

local function RemoveExitDoorsESP()
    for _, highlight in pairs(EspHighlights) do
        if highlight then highlight:Destroy() end
    end
    EspHighlights = {}
end

local function WalkToRedLightEnd()
    local char = Player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            local safeZone = workspace.Map.RedLightGreenLight.SafeZone.Main
            if safeZone then
                humanoid:MoveTo(safeZone.Position)
            end
        end)
    end
end

local function CreateTeamESP()
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
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                elseif vestBlue then
                    highlight.FillColor = Color3.fromRGB(0, 0, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                
                table.insert(TeamEspHighlights, highlight)
            end
        end
    end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player then
            pcall(function() addHighlightToPlayer(player) end)
        end
    end
    
    TeamEspConnection = game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(2)
            pcall(function() addHighlightToPlayer(player) end)
        end)
    end)
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
end

local function RemoveJumpRope()
    pcall(function()
        local rope = workspace.Map.JumpRope.Rope
        if rope then rope:Destroy() end
    end)
end

local function CreateBabyESP()
    for _, gui in pairs(BabyEspGuis) do
        if gui then gui:Destroy() end
    end
    BabyEspGuis = {}
    
    local function addBabyESP(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("BabyBack") then
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Parent = player.Character.HumanoidRootPart
            billboardGui.Size = UDim2.new(0, 100, 0, 50)
            billboardGui.StudsOffset = Vector3.new(0, 3, 0)
            billboardGui.AlwaysOnTop = true
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = billboardGui
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "BABY"
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            textLabel.TextScaled = true
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            textLabel.Font = Enum.Font.SourceSansBold
            
            table.insert(BabyEspGuis, billboardGui)
        end
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        pcall(function() addBabyESP(player) end)
    end
    
    BabyEspConnection = RunService.Heartbeat:Connect(function()
        for i = #BabyEspGuis, 1, -1 do
            local gui = BabyEspGuis[i]
            if not gui or not gui.Parent or not gui.Parent.Parent or not gui.Parent.Parent:FindFirstChild("BabyBack") then
                if gui then gui:Destroy() end
                table.remove(BabyEspGuis, i)
            end
        end
        
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
                    pcall(function() addBabyESP(player) end)
                end
            end
        end
    end)
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
end

local function CreateGlassESP()
    for _, highlight in pairs(GlassEspHighlights) do
        if highlight then highlight:Destroy() end
    end
    GlassEspHighlights = {}
    
    pcall(function()
        local glassFolder = workspace.Map.Glass.Glasses
        local glasses = glassFolder:GetChildren()
        
        for _, glass in pairs(glasses) do
            local partsToHighlight = {}
            if glass:IsA("Model") or glass:IsA("Folder") then
                partsToHighlight = glass:GetChildren()
            elseif glass:IsA("BasePart") then
                table.insert(partsToHighlight, glass)
            end

            for _, part in pairs(partsToHighlight) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = part
                    highlight.Adornee = part
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    
                    if part.CanCollide == true and part.Transparency < 1 then
                        highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Verde (Seguro)
                    else
                        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Vermelho (Perigoso)
                    end
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    table.insert(GlassEspHighlights, highlight)
                end
            end
        end
    end)
end

local function RemoveGlassESP()
    for _, highlight in pairs(GlassEspHighlights) do
        if highlight then highlight:Destroy() end
    end
    GlassEspHighlights = {}
end

local function EnlargeHoneycombParts()
    pcall(function()
        local shapesFolder = workspace.Map.Honeycomb.Shapes
        for _, shape in pairs(shapesFolder:GetChildren()) do
            if shape:FindFirstChild("Path") then
                for _, part in pairs(shape.Path:GetChildren()) do
                    if part:IsA("BasePart") then
                        if not part:GetAttribute("OriginalSize") then
                            part:SetAttribute("OriginalSize", part.Size)
                        end
                        part.Size = part:GetAttribute("OriginalSize") * 3
                    end
                end
            end
        end
    end)
end

local function RestoreHoneycombParts()
    pcall(function()
        local shapesFolder = workspace.Map.Honeycomb.Shapes
        for _, shape in pairs(shapesFolder:GetChildren()) do
            if shape:FindFirstChild("Path") then
                for _, part in pairs(shape.Path:GetChildren()) do
                    if part:IsA("BasePart") and part:GetAttribute("OriginalSize") then
                        part.Size = part:GetAttribute("OriginalSize")
                        part:SetAttribute("OriginalSize", nil)
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
        SafeZonePart = Instance.new("Part")
        SafeZonePart.Name = "ZangModsSafeZone"
        SafeZonePart.Size = Vector3.new(10, 1, 10)
        SafeZonePart.Position = Vector3.new(0, 2000, 0)
        SafeZonePart.Anchored = true
        SafeZonePart.CanCollide = true
        SafeZonePart.Material = Enum.Material.ForceField
        SafeZonePart.BrickColor = BrickColor.new("Bright blue")
        SafeZonePart.Transparency = 0.3
        SafeZonePart.Parent = workspace
        
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Parent = SafeZonePart
        surfaceGui.Face = Enum.NormalId.Top
        
        local textLabel = Instance.new("TextLabel", surfaceGui)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "ZangMods"
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
        
        hrp.CFrame = CFrame.new(SafeZonePart.Position + Vector3.new(0, 5, 0))
    end)
end

local function RemoveSafeZone()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and OriginalPosition then
        hrp.CFrame = OriginalPosition
    end
    
    if SafeZonePart then
        SafeZonePart:Destroy()
        SafeZonePart = nil
    end
    OriginalPosition = nil
end

local function StartKillAura()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local myTeam
    if char:FindFirstChild("Vest_red") then myTeam = "red"
    elseif char:FindFirstChild("Vest_blue") then myTeam = "blue"
    else return end
    
    local function findNearestEnemy()
        local nearestEnemy, shortestDistance = nil, math.huge
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local isEnemy = (myTeam == "red" and player.Character:FindFirstChild("Vest_blue")) or (myTeam == "blue" and player.Character:FindFirstChild("Vest_red"))
                if isEnemy then
                    local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance, nearestEnemy = distance, player
                    end
                end
            end
        end
        return nearestEnemy
    end
    
    KillAuraTarget = findNearestEnemy()
    if not KillAuraTarget then return end
    
    KillAuraConnection = RunService.Heartbeat:Connect(function()
        if not (KillAuraTarget and KillAuraTarget.Character and KillAuraTarget.Character:FindFirstChildOfClass("Humanoid") and KillAuraTarget.Character:FindFirstChildOfClass("Humanoid").Health > 0) then
            KillAuraTarget = findNearestEnemy()
            if not KillAuraTarget then return end
        end

        local targetHrp = KillAuraTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then
            local offset = Vector3.new(math.random(-2, 2), 0.5, math.random(-2, 2))
            hrp.CFrame = CFrame.new(targetHrp.Position + offset, targetHrp.Position)
        end
    end)
end

local function StopKillAura()
    if KillAuraConnection then
        KillAuraConnection:Disconnect()
        KillAuraConnection = nil
    end
    KillAuraTarget = nil
end

-- ===== INTERFACE - ABAS =====
local Tabs = {}
Tabs.Main = Window:Tab({ Title = "Main", Icon = "home" })
Tabs.RedLight = Window:Tab({ Title = "Red Light", Icon = "alert-octagon" })
Tabs.Dalgona = Window:Tab({ Title = "Dalgona", Icon = "circle" })
Tabs.HideAndSeek = Window:Tab({ Title = "Hide and Seek", Icon = "eye-off" })
Tabs.JumpRope = Window:Tab({ Title = "Jump Rope", Icon = "move" })
Tabs.GlassBridge = Window:Tab({ Title = "Glass Bridge", Icon = "square" })

-- ===== ABA MAIN =====
Tabs.Main:Label({ Title = "AVISO: Este script está em versão BETA.", Color = Color3.fromRGB(255, 80, 80) })
Tabs.Main:Divider()
Tabs.Main:Toggle({
    Title = "Esp Baby", Description = "Mostra quem é o bebê", Value = false,
    Callback = function(state) if state then CreateBabyESP() else RemoveBabyESP() end end
})
Tabs.Main:Toggle({
    Title = "Safe Zone", Description = "Teleporta para uma plataforma segura no céu", Value = false,
    Callback = function(state) if state then CreateSafeZone() else RemoveSafeZone() end end
})

-- ===== ABA RED LIGHT =====
Tabs.RedLight:Button({
    Title = "Andar até o Fim", Description = "Anda automaticamente até a linha de chegada",
    Callback = function() WalkToRedLightEnd() end
})

-- ===== ABA DALGONA =====
Tabs.Dalgona:Toggle({
    Title = "Dalgona Helper", Description = "Aumenta as parts do desenho para facilitar", Value = false,
    Callback = function(state) if state then EnlargeHoneycombParts() else RestoreHoneycombParts() end end
})

-- ===== ABA HIDE AND SEEK =====
Tabs.HideAndSeek:Toggle({
    Title = "Esp ExitDoors", Description = "Mostra as portas de saída", Value = false,
    Callback = function(state) if state then CreateExitDoorsESP() else RemoveExitDoorsESP() end end
})
Tabs.HideAndSeek:Toggle({
    Title = "Esp Teams", Description = "Mostra os jogadores de cada time", Value = false,
    Callback = function(state) if state then CreateTeamESP() else RemoveTeamESP() end end
})
Tabs.HideAndSeek:Toggle({
    Title = "Kill Aura", Description = "Gruda nos inimigos automaticamente", Value = false,
    Callback = function(state) if state then StartKillAura() else StopKillAura() end end
})

-- ===== ABA JUMP ROPE =====
Tabs.JumpRope:Toggle({
    Title = "Remove Rope", Description = "Remove a corda para não te atrapalhar", Value = false,
    Callback = function(state) if state then RemoveJumpRope() end end
})

-- ===== ABA GLASS BRIDGE =====
Tabs.GlassBridge:Toggle({
    Title = "Esp Glass", Description = "Mostra vidros seguros (verde) e perigosos (vermelho)", Value = false,
    Callback = function(state) if state then CreateGlassESP() else RemoveGlassESP() end end
})

Window:SelectTab(1)
