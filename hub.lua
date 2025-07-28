local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/zangmods/zangmodsroblox/main/libs/windui.lua"))()

local window = WindUI:CreateWindow({
    Title = "Meu Mod Menu",
    Size = UDim2.fromOffset(450, 300),
    Theme = "Dark"
})

local tab = window:Tab({
    Title = "Principal",
    Icon = "home"
})

tab:Button({
    Title = "Ativar Godmode",
    Callback = function()
        print("Godmode ativado!")
    end
})

tab:Toggle({
    Title = "ESP Jogadores",
    Default = false,
    Callback = function(state)
        print("ESP está", state)
    end
})

tab:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})
