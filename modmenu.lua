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

local GlobalSystem = { Functions = {} }
function GlobalSystem:RegisterFunction(name, func, autoStart)
    self.Functions[name] = { func = func, active = false, connection = nil }
    if autoStart then self:StartFunction(name) end
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
    for name in pairs(self.Functions) do self:StopFunction(name) end
    self.Functions = {}
    print("Sistema Global limpo completamente")
end

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

GlobalSystem:RegisterFunction("DashSystem", CreateDashSystem, false)

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

-- ABAS DOS JOGOS (agora diretas na janela)
Tabs.RedLight = Window:Tab({ Title = "Red Light", Icon = "alert-octagon" })
Tabs.Dalgona = Window:Tab({ Title = "Dalgona", Icon = "circle" })
Tabs.TugOfWar = Window:Tab({ Title = "Tug of War", Icon = "git-merge" })
Tabs.HideAndSeek = Window:Tab({ Title = "Hide and Seek", Icon = "eye-off" })
Tabs.JumpRope = Window:Tab({ Title = "Jump Rope", Icon = "move" })
Tabs.GlassBridge = Window:Tab({ Title = "Glass Bridge", Icon = "square" })
Tabs.Mingle = Window:Tab({ Title = "Mingle", Icon = "users" })
Tabs.Final = Window:Tab({ Title = "Final", Icon = "flag" })

-- ===== SISTEMA DE DASH =====
local DashSettings = { Enabled = false }

local function CreateDashSystem()
    local connections = {}
    connections.heartbeat = RunService.Heartbeat:Connect(function()
        if DashSettings.Enabled then
            local success, err = pcall(function()
                local fasterSprint = game:GetService("Players").LocalPlayer.Boosts["Faster Sprint"]
                if fasterSprint and fasterSprint.Value ~= 5 then
                    fasterSprint.Value = 5
                end
            end)
            if not success then
                warn("Erro ao definir Faster Sprint:", err)
            end
        end
    end)
    return connections
end

-- ===== ABA MAIN =====
Tabs.Main:Toggle({
    Title = "Desbloquear Dash",
    Description = "Habilita função de dash",
    Value = false,
    Callback = function(state)
        DashSettings.Enabled = state
        if state then
            -- Ativar dash
            local success, err = pcall(function()
                game:GetService("Players").LocalPlayer.Boosts["Faster Sprint"].Value = 5
            end)
            if success then
                print("Desbloquear Dash: ATIVADO - Value definido para 5")
                GlobalSystem:StartFunction("DashSystem")
            else
                warn("Erro ao ativar dash:", err)
            end
        else
            -- Desativar dash
            GlobalSystem:StopFunction("DashSystem")
            local success, err = pcall(function()
                game:GetService("Players").LocalPlayer.Boosts["Faster Sprint"].Value = 0
            end)
            if success then
                print("Desbloquear Dash: DESATIVADO - Value definido para 0")
            else
                warn("Erro ao desativar dash:", err)
            end
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

-- ===== OUTRAS ABAS =====
for name, tab in pairs(Tabs) do
    if name ~= "Mingle" and name ~= "RedLight" and name ~= "Dalgona" and name ~= "Main" then
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
    print("UI fechada completamente - limpando sistemas...")
    GlobalSystem:ClearAll()
    print("Todos os sistemas foram limpos.")
end)

print("ZangMods Hub carregado!")
print("Sistema de speed removido completamente!")
print("Aba Main adicionada com função Desbloquear Dash!")
print("Abas dos jogos agora estão diretamente na janela!")
