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
    Title = "Ativar",
    Description = "Toggle de exemplo",
    Value = false,
    Callback = function(state)
        print("Main: " .. tostring(state))
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
    Title = "Ativar",
    Value = false,
    Callback = function(state)
        print("Hide and Seek: " .. tostring(state))
    end
})

-- ===== ABA JUMP ROPE =====
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
    -- Limpar ESP highlights
    RemoveExitDoorsESP()
    
    print("UI fechada.")
end)

print("ZangMods Hub carregado!")
print("Script base limpo - Pronto para novo jogo!")
