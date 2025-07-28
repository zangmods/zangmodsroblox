local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local window = WindUI:CreateWindow({
    Title = "Squid Game Mod Menu",
    Size = UDim2.fromOffset(450, 300),
    Theme = "Dark"
})

-- Função de exemplo
local function exemplo()
    print("Switch ativado")
end

-- Abas e switches
local redlight = window:CreateTab("Red Light")
redlight:AddSwitch("Ativar Modo", exemplo)

local dalgona = window:CreateTab("Dalgona")
dalgona:AddSwitch("Modo Dalgona", exemplo)

local tugofwar = window:CreateTab("Tug of War")
tugofwar:AddSwitch("Auto Puxar", exemplo)

local hidenseek = window:CreateTab("Hide and Seek")
hidenseek:AddSwitch("Auto Esconder", exemplo)

local jumprope = window:CreateTab("Jump Rope")
jumprope:AddSwitch("Pular Automaticamente", exemplo)

local glassbridge = window:CreateTab("Glass Bridge")
glassbridge:AddSwitch("Ver Plataforma Segura", exemplo)

local mingle = window:CreateTab("Mingle")
mingle:AddSwitch("Detectar Inimigos", exemplo)

local final = window:CreateTab("Final")
final:AddSwitch("Modo Final", exemplo)

local extras = window:CreateTab("Funções Extra")
extras:AddSwitch("Velocidade Boost", exemplo)
