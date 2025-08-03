-- UPVALUE SCANNER GUI - FERRAMENTA COMPLETA
-- Criado para análise e modificação de upvalues em jogos Roblox

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove GUI anterior se existir
if playerGui:FindFirstChild("UpvalueScanner") then
    playerGui.UpvalueScanner:Destroy()
end

-- Criar GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UpvalueScanner"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 800, 0, 600)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Bordas arredondadas
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleLabel.Text = "🔍 UPVALUE SCANNER - FERRAMENTA COMPLETA"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

-- Botão fechar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleLabel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

-- Seção de seleção de módulos
local moduleSection = Instance.new("Frame")
moduleSection.Name = "ModuleSection"
moduleSection.Size = UDim2.new(1, -20, 0, 100)
moduleSection.Position = UDim2.new(0, 10, 0, 50)
moduleSection.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
moduleSection.BorderSizePixel = 0
moduleSection.Parent = mainFrame

local moduleSectionCorner = Instance.new("UICorner")
moduleSectionCorner.CornerRadius = UDim.new(0, 8)
moduleSectionCorner.Parent = moduleSection

local moduleLabel = Instance.new("TextLabel")
moduleLabel.Size = UDim2.new(1, 0, 0, 25)
moduleLabel.Position = UDim2.new(0, 0, 0, 5)
moduleLabel.BackgroundTransparency = 1
moduleLabel.Text = "📁 SELECIONAR MÓDULO/SCRIPT:"
moduleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
moduleLabel.TextSize = 12
moduleLabel.Font = Enum.Font.Gotham
moduleLabel.TextXAlignment = Enum.TextXAlignment.Left
moduleLabel.Parent = moduleSection

-- Dropdown de módulos
local moduleDropdown = Instance.new("TextButton")
moduleDropdown.Name = "ModuleDropdown"
moduleDropdown.Size = UDim2.new(1, -20, 0, 35)
moduleDropdown.Position = UDim2.new(0, 10, 0, 30)
moduleDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
moduleDropdown.Text = "🔽 Clique para selecionar módulo..."
moduleDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
moduleDropdown.TextSize = 11
moduleDropdown.Font = Enum.Font.Gotham
moduleDropdown.TextXAlignment = Enum.TextXAlignment.Left
moduleDropdown.Parent = moduleSection

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 5)
dropdownCorner.Parent = moduleDropdown

-- Botão scan
local scanButton = Instance.new("TextButton")
scanButton.Name = "ScanButton"
scanButton.Size = UDim2.new(0, 100, 0, 35)
scanButton.Position = UDim2.new(1, -110, 0, 30)
scanButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
scanButton.Text = "🔍 SCAN"
scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
scanButton.TextSize = 12
scanButton.Font = Enum.Font.GothamBold
scanButton.Parent = moduleSection

local scanCorner = Instance.new("UICorner")
scanCorner.CornerRadius = UDim.new(0, 5)
scanCorner.Parent = scanButton

-- Lista de funções
local functionsSection = Instance.new("Frame")
functionsSection.Name = "FunctionsSection"
functionsSection.Size = UDim2.new(0.5, -15, 1, -170)
functionsSection.Position = UDim2.new(0, 10, 0, 160)
functionsSection.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
functionsSection.BorderSizePixel = 0
functionsSection.Parent = mainFrame

local functionsSectionCorner = Instance.new("UICorner")
functionsSectionCorner.CornerRadius = UDim.new(0, 8)
functionsSectionCorner.Parent = functionsSection

local functionsLabel = Instance.new("TextLabel")
functionsLabel.Size = UDim2.new(1, 0, 0, 25)
functionsLabel.Position = UDim2.new(0, 0, 0, 5)
functionsLabel.BackgroundTransparency = 1
functionsLabel.Text = "⚙️ FUNÇÕES ENCONTRADAS:"
functionsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
functionsLabel.TextSize = 12
functionsLabel.Font = Enum.Font.Gotham
functionsLabel.TextXAlignment = Enum.TextXAlignment.Left
functionsLabel.Parent = functionsSection

local functionsScrollFrame = Instance.new("ScrollingFrame")
functionsScrollFrame.Name = "FunctionsScrollFrame"
functionsScrollFrame.Size = UDim2.new(1, -10, 1, -35)
functionsScrollFrame.Position = UDim2.new(0, 5, 0, 30)
functionsScrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
functionsScrollFrame.BorderSizePixel = 0
functionsScrollFrame.ScrollBarThickness = 6
functionsScrollFrame.Parent = functionsSection

local functionsScrollCorner = Instance.new("UICorner")
functionsScrollCorner.CornerRadius = UDim.new(0, 5)
functionsScrollCorner.Parent = functionsScrollFrame

-- Lista de upvalues
local upvaluesSection = Instance.new("Frame")
upvaluesSection.Name = "UpvaluesSection"
upvaluesSection.Size = UDim2.new(0.5, -15, 1, -170)
upvaluesSection.Position = UDim2.new(0.5, 5, 0, 160)
upvaluesSection.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
upvaluesSection.BorderSizePixel = 0
upvaluesSection.Parent = mainFrame

local upvaluesSectionCorner = Instance.new("UICorner")
upvaluesSectionCorner.CornerRadius = UDim.new(0, 8)
upvaluesSectionCorner.Parent = upvaluesSection

local upvaluesLabel = Instance.new("TextLabel")
upvaluesLabel.Size = UDim2.new(1, 0, 0, 25)
upvaluesLabel.Position = UDim2.new(0, 0, 0, 5)
upvaluesLabel.BackgroundTransparency = 1
upvaluesLabel.Text = "🎯 UPVALUES DA FUNÇÃO SELECIONADA:"
upvaluesLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
upvaluesLabel.TextSize = 12
upvaluesLabel.Font = Enum.Font.Gotham
upvaluesLabel.TextXAlignment = Enum.TextXAlignment.Left
upvaluesLabel.Parent = upvaluesSection

local upvaluesScrollFrame = Instance.new("ScrollingFrame")
upvaluesScrollFrame.Name = "UpvaluesScrollFrame"
upvaluesScrollFrame.Size = UDim2.new(1, -10, 1, -35)
upvaluesScrollFrame.Position = UDim2.new(0, 5, 0, 30)
upvaluesScrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
upvaluesScrollFrame.BorderSizePixel = 0
upvaluesScrollFrame.ScrollBarThickness = 6
upvaluesScrollFrame.Parent = upvaluesSection

local upvaluesScrollCorner = Instance.new("UICorner")
upvaluesScrollCorner.CornerRadius = UDim.new(0, 5)
upvaluesScrollCorner.Parent = upvaluesScrollFrame

-- Variáveis globais
local selectedModule = nil
local selectedFunction = nil
local foundFunctions = {}
local modules = {}

-- Função para encontrar todos os módulos
local function findModules()
    modules = {}
    
    -- Buscar em ReplicatedStorage
    for _, obj in pairs(game.ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            table.insert(modules, {
                name = obj.Name,
                path = obj:GetFullName(),
                object = obj
            })
        end
    end
    
    -- Buscar em outros lugares
    for _, service in pairs({game.StarterGui, game.StarterPlayer, game.Workspace}) do
        for _, obj in pairs(service:GetDescendants()) do
            if obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
                table.insert(modules, {
                    name = obj.Name,
                    path = obj:GetFullName(),
                    object = obj
                })
            end
        end
    end
    
    print("🔍 Encontrados", #modules, "módulos/scripts")
end

-- Função para criar dropdown de módulos
local function createModuleDropdown()
    -- Remove dropdown anterior
    if screenGui:FindFirstChild("ModuleDropdownList") then
        screenGui.ModuleDropdownList:Destroy()
    end
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "ModuleDropdownList"
    dropdownList.Size = UDim2.new(0, 500, 0, 200)
    dropdownList.Position = UDim2.new(0, moduleDropdown.AbsolutePosition.X, 0, moduleDropdown.AbsolutePosition.Y + 40)
    dropdownList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = screenGui
    dropdownList.ZIndex = 10
    
    local dropdownListCorner = Instance.new("UICorner")
    dropdownListCorner.CornerRadius = UDim.new(0, 5)
    dropdownListCorner.Parent = dropdownList
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = dropdownList
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.Name
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scrollFrame
    
    for i, module in pairs(modules) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 25)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.Text = "📄 " .. module.name .. " (" .. module.path .. ")"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 10
        button.Font = Enum.Font.Gotham
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = scrollFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 3)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            selectedModule = module.object
            moduleDropdown.Text = "📄 " .. module.name
            dropdownList:Destroy()
            print("✅ Módulo selecionado:", module.name)
        end)
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Função para escanear funções
local function scanFunctions()
    if not selectedModule then
        warn("❌ Selecione um módulo primeiro!")
        return
    end
    
    foundFunctions = {}
    
    -- Limpar lista anterior
    for _, child in pairs(functionsScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    print("🔍 Escaneando funções do módulo:", selectedModule.Name)
    
    for i, func in pairs(getreg()) do
        if typeof(func) == "function" and islclosure(func) then
            pcall(function()
                if getfenv(func).script == selectedModule then
                    local info = debug.getinfo(func)
                    table.insert(foundFunctions, {
                        func = func,
                        nups = info.nups,
                        source = info.source or "Unknown"
                    })
                end
            end)
        end
    end
    
    print("✅ Encontradas", #foundFunctions, "funções")
    
    -- Criar botões para as funções
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.Name
    layout.Padding = UDim.new(0, 3)
    layout.Parent = functionsScrollFrame
    
    for i, funcData in pairs(foundFunctions) do
        local button = Instance.new("TextButton")
        button.Name = "Function" .. i
        button.Size = UDim2.new(1, -10, 0, 35)
        button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        button.Text = "⚙️ Função #" .. i .. " (" .. funcData.nups .. " upvalues)"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 10
        button.Font = Enum.Font.Gotham
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = functionsScrollFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            selectedFunction = funcData
            showUpvalues(funcData)
            
            -- Destacar botão selecionado
            for _, btn in pairs(functionsScrollFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                end
            end
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        end)
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            if selectedFunction ~= funcData then
                button.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
            end
        end)
        
        button.MouseLeave:Connect(function()
            if selectedFunction ~= funcData then
                button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            end
        end)
    end
    
    functionsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Função para mostrar upvalues
function showUpvalues(funcData)
    -- Limpar lista anterior
    for _, child in pairs(upvaluesScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.Name
    layout.Padding = UDim.new(0, 3)
    layout.Parent = upvaluesScrollFrame
    
    print("🎯 Mostrando upvalues da função com", funcData.nups, "upvalues")
    
    for i = 1, funcData.nups do
        pcall(function()
            local name, value = debug.getupvalue(funcData.func, i)
            
            local upvalueFrame = Instance.new("Frame")
            upvalueFrame.Name = "Upvalue" .. i
            upvalueFrame.Size = UDim2.new(1, -10, 0, 60)
            upvalueFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            upvalueFrame.BorderSizePixel = 0
            upvalueFrame.Parent = upvaluesScrollFrame
            
            local upvalueCorner = Instance.new("UICorner")
            upvalueCorner.CornerRadius = UDim.new(0, 5)
            upvalueCorner.Parent = upvalueFrame
            
            local indexLabel = Instance.new("TextLabel")
            indexLabel.Size = UDim2.new(0, 30, 1, 0)
            indexLabel.Position = UDim2.new(0, 5, 0, 0)
            indexLabel.BackgroundTransparency = 1
            indexLabel.Text = "#" .. i
            indexLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            indexLabel.TextSize = 12
            indexLabel.Font = Enum.Font.GothamBold
            indexLabel.Parent = upvalueFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, 100, 0, 20)
            nameLabel.Position = UDim2.new(0, 40, 0, 2)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = "Name: " .. (name or "nil")
            nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            nameLabel.TextSize = 9
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = upvalueFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, -150, 0, 20)
            valueLabel.Position = UDim2.new(0, 40, 0, 18)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = "Value: " .. tostring(value) .. " (" .. typeof(value) .. ")"
            valueLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
            valueLabel.TextSize = 9
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.Parent = upvalueFrame
            
            local modifyButton = Instance.new("TextButton")
            modifyButton.Size = UDim2.new(0, 60, 0, 25)
            modifyButton.Position = UDim2.new(1, -65, 0, 5)
            modifyButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            modifyButton.Text = "EDIT"
            modifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            modifyButton.TextSize = 10
            modifyButton.Font = Enum.Font.GothamBold
            modifyButton.Parent = upvalueFrame
            
            local modifyCorner = Instance.new("UICorner")
            modifyCorner.CornerRadius = UDim.new(0, 3)
            modifyCorner.Parent = modifyButton
            
            local testButton = Instance.new("TextButton")
            testButton.Size = UDim2.new(0, 60, 0, 25)
            testButton.Position = UDim2.new(1, -65, 0, 32)
            testButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            testButton.Text = "TEST"
            testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            testButton.TextSize = 10
            testButton.Font = Enum.Font.GothamBold
            testButton.Parent = upvalueFrame
            
            local testCorner = Instance.new("UICorner")
            testCorner.CornerRadius = UDim.new(0, 3)
            testCorner.Parent = testButton
            
            -- Funcionalidade dos botões
            modifyButton.MouseButton1Click:Connect(function()
                local newValue = game.Players.LocalPlayer.Name -- Placeholder
                pcall(function()
                    setupvalue(funcData.func, i, 9999999) -- Valor padrão para testes
                    print("✅ Upvalue", i, "modificado para:", 9999999)
                    valueLabel.Text = "Value: 9999999 (modified)"
                    valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end)
            end)
            
            testButton.MouseButton1Click:Connect(function()
                pcall(function()
                    setupvalue(funcData.func, i, 999)
                    print("🧪 Testando upvalue", i, "com valor:", 999)
                end)
            end)
        end)
    end
    
    upvaluesScrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Eventos
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

moduleDropdown.MouseButton1Click:Convert(function()
    findModules()
    createModuleDropdown()
end)

scanButton.MouseButton1Click:Connect(function()
    scanFunctions()
end)

-- Tornar a GUI arrastável
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Inicialização
findModules()
print("🚀 Upvalue Scanner GUI carregado com sucesso!")
print("📋 Encontrados", #modules, "módulos disponíveis")
