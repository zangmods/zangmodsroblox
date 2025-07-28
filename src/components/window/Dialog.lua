local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local DialogModule = {
    Holder = nil,
    Window = nil,
    Parent = nil,
}

function DialogModule.Init(Window, Parent)
    DialogModule.Window = Window
    DialogModule.Parent = Parent
    return DialogModule
end

function DialogModule.Create(Key)
    local Dialog = {
        UICorner = 32,
        UIPadding = 12,
        UIElements = {}
    }
    
    if Key then Dialog.UIPadding = 0 end -- 16
    if Key then Dialog.UICorner  = 26 end
    
    if not Key then
        Dialog.UIElements.FullScreen = New("Frame", {
            ZIndex = 999,
            BackgroundTransparency = 1, -- 0.3
            BackgroundColor3 = Color3.fromHex("#000000"),
            Size = UDim2.new(1,0,1,0),
            Active = false, -- true
            Visible = false, -- true
            Parent = DialogModule.Parent or (DialogModule.Window and DialogModule.Window.UIElements and DialogModule.Window.UIElements.Main and DialogModule.Window.UIElements.Main.Main)
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,DialogModule.Window.UICorner)
            })
        })
    end
    
    Dialog.UIElements.Main = New("Frame", {
        Size = UDim2.new(0,280,0,0),
        ThemeTag = {
            BackgroundColor3 = "Dialog",
        },
        AutomaticSize = "Y",
        BackgroundTransparency = 1, -- .7
        Visible = false,
        ZIndex = 99999,
    }, {
        New("UIPadding", {
            PaddingTop = UDim.new(0, Dialog.UIPadding),
            PaddingLeft = UDim.new(0, Dialog.UIPadding),
            PaddingRight = UDim.new(0, Dialog.UIPadding),
            PaddingBottom = UDim.new(0, Dialog.UIPadding),
        })
    })
    
    Dialog.UIElements.MainContainer = Creator.NewRoundFrame(Dialog.UICorner, "Squircle", {
        Visible = false, -- true
        --GroupTransparency = 1, -- 0
        ImageTransparency = Key and 0.15 or 0, 
        Parent = Key and DialogModule.Parent or Dialog.UIElements.FullScreen,
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        AutomaticSize = "XY",
        ThemeTag = {
            ImageColor3 = "Dialog"
        },
        ZIndex = 9999,
    }, {
        -- Creator.NewRoundFrame(Dialog.UICorner, "Squircle", {
        --     ImageColor3 = Color3.new(0,0,0),
        --     ImageTransparency = .8,
        --     Size = UDim2.new(1,0,1,0)
        -- }),
        Dialog.UIElements.Main,
        -- New("UIScale", {
        --     Scale = .9
        -- }),
        Creator.NewRoundFrame(Dialog.UICorner, "SquircleOutline2", {
            Size = UDim2.new(1,0,1,0),
            ImageTransparency = .85,
            ThemeTag = {
                ImageColor3 = "Outline",
            },
        }, {
            New("UIGradient", {
                Rotation = 45,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.55),
                    NumberSequenceKeypoint.new(0.5, 0.8),
                    NumberSequenceKeypoint.new(1, 0.6)
                })
            })
        })
    })

    function Dialog:Open()
        if not Key then
            Dialog.UIElements.FullScreen.Visible = true
            Dialog.UIElements.FullScreen.Active = true
        end
        
        task.spawn(function()
            Dialog.UIElements.MainContainer.Visible = true
            
            if not Key then
                Tween(Dialog.UIElements.FullScreen, 0.1, {BackgroundTransparency = .3}):Play()
            end
            Tween(Dialog.UIElements.MainContainer, 0.1, {ImageTransparency = 0}):Play()
            --Tween(Dialog.UIElements.MainContainer.UIScale, 0.1, {Scale = 1}):Play()
            --Tween(Dialog.UIElements.MainContainer.UIStroke, 0.1, {Transparency = 1}):Play()
            task.spawn(function()
                task.wait(0.05)
                Dialog.UIElements.Main.Visible = true
            end)
        end)
    end
    function Dialog:Close()
        if not Key then
            Tween(Dialog.UIElements.FullScreen, 0.1, {BackgroundTransparency = 1}):Play()
            Dialog.UIElements.FullScreen.Active = false
            task.spawn(function()
                task.wait(.1)
                Dialog.UIElements.FullScreen.Visible = false
            end)
        end
        Dialog.UIElements.Main.Visible = false
        
        Tween(Dialog.UIElements.MainContainer, 0.1, {ImageTransparency = 1}):Play()
        --Tween(Dialog.UIElements.MainContainer.UIScale, 0.1, {Scale = .9}):Play()
        --Tween(Dialog.UIElements.MainContainer.UIStroke, 0.1, {Transparency = 1}):Play()
        
        task.spawn(function()
            task.wait(.1)
            if not Key then
                Dialog.UIElements.FullScreen:Destroy()
            else
                Dialog.UIElements.MainContainer:Destroy()
            end
        end)
        
        return function() end
    end
    
    --Dialog:Open()
    return Dialog
end

return DialogModule