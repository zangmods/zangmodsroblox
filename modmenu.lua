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
local DashConnection = nil
local EspConnection = nil
local EspHighlights = {}
local SafezoneEnabled = false
local SavedPosition = nil
local SafezonePart = nil

-- ===== FUNÇÕES DOS JOGOS =====
local function teleportForward(distance)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos, dir = hrp.Position, hrp.CFrame.LookVector
        local newPos = pos + (dir * distance)
        hrp.CFrame = CFrame.new(newPos, newPos + dir)
        print("Teleportado " .. distance .. " passos à frente!")
    else
        print("Erro: Personagem não encontrado!")
    end
end

local function CreateExitDoorsESP()
    -- Limpar highlights existentes
    for _, highlight in pairs(EspHighlights) do
        if highlight then highlight:Destroy() end
    end
    EspHighlights = {}
    
    -- Criar highlights para as portas de saída
    for floor = 1, 3 do
        local floorPath = workspace.HideAndSeekMap.NEWFIXEDDOORS["Floor" .. floor].EXITDOORS
        pcall(function()
            local doors = floorPath:GetChildren()
            for i, door in pairs(doors) do
                if door and door:IsA("Model") or door:IsA("Part") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = door
                    highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Verde
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Branco
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = door
                    
                    table.insert(EspHighlights, highlight)
                    print("ESP aplicado na porta Floor" .. floor .. " - Porta " .. i)
                end
            end
        end)
    end
    print("ESP ExitDoors ativado para todos os andares!")
end

local function RemoveExitDoorsESP()
    for _, highlight in pairs(EspHighlights) do
        if highlight then highlight:Destroy() end
    end
    EspHighlights = {}
    print("ESP ExitDoors desativado!")
end

local function CreateSafezone()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        warn("Erro: HumanoidRootPart não encontrado.")
        return false
    end
    
    -- Salvar posição atual
    SavedPosition = hrp.CFrame
    
    -- Criar o chão de vidro
    SafezonePart = Instance.new("Part")
    SafezonePart.Name = "ZangMods"
    SafezonePart.Size = Vector3.new(10, 1, 10)
    SafezonePart.Material = Enum.Material.Glass
    SafezonePart.BrickColor = BrickColor.new("Bright blue")
    SafezonePart.Transparency = 0.3
    SafezonePart.Anchored = true
    SafezonePart.CanCollide = true
    SafezonePart.Parent = workspace
    
    -- Posição bem alta (baseada na coordenada fixa + altura)
    local safezonePosition = Vector3.new(-45.805057525634766, 1524.711669921875, 135.66622924804688) -- 500 blocos mais alto
    SafezonePart.Position = safezonePosition
    
    -- Teleportar player para cima do chão
    hrp.CFrame = CFrame.new(safezonePosition + Vector3.new(0, 5, 0))
    
    print("Safezone ativado! Teleportado para área segura.")
    return true
end

local function RemoveSafezone()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Remover o chão de vidro
    if SafezonePart then
        SafezonePart:Destroy()
        SafezonePart = nil
    end
    
    -- Voltar para posição salva
    if hrp and SavedPosition then
        hrp.CFrame = SavedPosition
        print("Safezone desativado! Voltou para posição original.")
    else
        warn("Erro: Não foi possível voltar para posição original.")
    end
    
    SavedPosition = nil
end

local function CompleteDalgona()
    local DalgonaClientModule = game.ReplicatedStorage.Modules.Games.DalgonaClient

    for _, Value in ipairs(getreg()) do
        if typeof(Value) == "function" and islclosure(Value) then
            if getfenv(Value).script == DalgonaClientModule then
                if debug.getinfo(Value).nups == 73 then
                    setupvalue(Value, 31, 9e9)  
                    print("Dalgona completed!")
                    break
                end
            end
        end
    end
end

-- ===== INTERFACE - ABAS DIRETAS =====
local Tabs = {}

-- ABA MAIN
Tabs.Main = Window:Tab({ Title = "Main", Icon = "home" })

-- ABAS DOS JOGOS
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
    Title = "Desbloquear Dash",
    Description = "Habilita função de dash",
    Value = false,
    Callback = function(state)
        if state then
            -- Ativar dash
            pcall(function()
                Player.Boosts["Faster Sprint"].Value = 5
            end)
            
            -- Criar loop para manter o valor
            DashConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if Player.Boosts["Faster Sprint"].Value ~= 5 then
                        Player.Boosts["Faster Sprint"].Value = 5
                    end
                end)
            end)
            
            print("Dash ativado!")
        else
            -- Desativar dash
            if DashConnection then
                DashConnection:Disconnect()
                DashConnection = nil
            end
            
            pcall(function()
                Player.Boosts["Faster Sprint"].Value = 0
            end)
            
            print("Dash desativado!")
        end
    end
})

Tabs.Main:Toggle({
    Title = "Safezone",
    Description = "Teleporta para área segura no céu",
    Value = false,
    Callback = function(state)
        SafezoneEnabled = state
        if state then
            if not CreateSafezone() then
                -- Se falhou, desativar o toggle
                SafezoneEnabled = false
            end
        else
            RemoveSafezone()
        end
    end
})

-- ===== ABA RED LIGHT =====
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
Tabs.RedLight:Button({
    Title = "Teleportar para Coordenadas Fixas",
    Callback = function()
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(-45.805057525634766, 1024.711669921875, 135.66622924804688)
            print("Teleportado para a posição fixa com sucesso!")
        else
            warn("Erro: HumanoidRootPart não encontrado.")
        end
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
Tabs.Dalgona:Button({
    Title = "Completar Dalgona",
    Callback = function()
        CompleteDalgona()
    end
})

-- ===== ABA HIDE AND SEEK =====
Tabs.HideAndSeek:Toggle({
    Title = "Esp ExitDoors",
    Description = "Mostra highlight nas portas de saída",
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
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Hide and Seek: " .. tostring(state))
    end
})

-- ===== OUTRAS ABAS =====
for name, tab in pairs(Tabs) do
    if name ~= "Mingle" and name ~= "RedLight" and name ~= "Dalgona" and name ~= "Main" and name ~= "HideAndSeek" then
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

Window:SelectTab(1)
Window:OnClose(function()
    print("UI fechada.")
end)

print("ZangMods Hub carregado!")
print("Script otimizado - GlobalSystem removido!")
