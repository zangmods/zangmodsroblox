local UserInputService = game:GetService("UserInputService")

local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {
    UICorner = 6,
    UIPadding = 8,
}

local CreateLabel = require("../components/ui/Label").New

function Element:New(Config)
    local Keybind = {
        __type = "Keybind",
        Title = Config.Title or "Keybind",
        Desc = Config.Desc or nil,
        Locked = Config.Locked or false,
        Value = Config.Value or "F",
        Callback = Config.Callback or function() end,
        CanChange = Config.CanChange or true,
        Picking = false,
        UIElements = {},
    }
    
    local CanCallback = true
    
    Keybind.KeybindFrame = require("../components/window/Element")({
        Title = Keybind.Title,
        Desc = Keybind.Desc,
        Parent = Config.Parent,
        TextOffset = 85,
        Hover = Keybind.CanChange,
    })
    
    Keybind.UIElements.Keybind = CreateLabel(Keybind.Value, nil, Keybind.KeybindFrame.UIElements.Main)
    
    Keybind.UIElements.Keybind.Size = UDim2.new(
            0,
            12+12+Keybind.UIElements.Keybind.Frame.Frame.TextLabel.TextBounds.X,
            0,
            42
        )
    Keybind.UIElements.Keybind.AnchorPoint = Vector2.new(1,0.5)
    Keybind.UIElements.Keybind.Position = UDim2.new(1,0,0.5,0)

    New("UIScale", {
        Parent = Keybind.UIElements.Keybind,
        Scale = .85,
    })

    Creator.AddSignal(Keybind.UIElements.Keybind.Frame.Frame.TextLabel:GetPropertyChangedSignal("TextBounds"), function()
        Keybind.UIElements.Keybind.Size = UDim2.new(
            0,
            12+12+Keybind.UIElements.Keybind.Frame.Frame.TextLabel.TextBounds.X,
            0,
            42
        )
    end)

    function Keybind:Lock()
        CanCallback = false
        return Keybind.KeybindFrame:Lock()
    end
    function Keybind:Unlock()
        CanCallback = true
        return Keybind.KeybindFrame:Unlock()
    end
    
    function Keybind:Set(v)
        Keybind.Value = v
        Keybind.UIElements.Keybind.Frame.Frame.TextLabel.Text = v
    end
    
    if Keybind.Locked then
        Keybind:Lock()
    end

    Creator.AddSignal(Keybind.KeybindFrame.UIElements.Main.MouseButton1Click, function()
        if CanCallback then
            if Keybind.CanChange then
                Keybind.Picking = true
                Keybind.UIElements.Keybind.Frame.Frame.TextLabel.Text = "..."
                
                task.wait(0.2)
                
                local Event
                Event = UserInputService.InputBegan:Connect(function(Input)
                    local Key
            
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
	                    Key = Input.KeyCode.Name
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
	                    Key = "MouseLeft"
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
	                    Key = "MouseRight"
                    end
            
                    local EndedEvent
                    EndedEvent = UserInputService.InputEnded:Connect(function(Input)
	                    if Input.KeyCode.Name == Key or Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1 or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2 then
		                    Keybind.Picking = false
		    
		                    Keybind.UIElements.Keybind.Frame.Frame.TextLabel.Text = Key
		                    Keybind.Value = Key
		
		                    Event:Disconnect()
		                    EndedEvent:Disconnect()
	                    end
                    end)
                end)
            end
        end
    end) 
    Creator.AddSignal(UserInputService.InputBegan, function(input)
        if CanCallback then
            if input.KeyCode.Name == Keybind.Value then
                Creator.SafeCallback(Keybind.Callback, input.KeyCode.Name)
            end
        end
    end)
    return Keybind.__type, Keybind
end

return Element