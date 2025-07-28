local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local CreateToggle = require("../components/ui/Toggle").New
local CreateCheckbox = require("../components/ui/Checkbox").New

local Element = {}

function Element:New(Config)
    local Toggle = {
        __type = "Toggle",
        Title = Config.Title or "Toggle",
        Desc = Config.Desc or nil,
        Value = Config.Value,
        Icon = Config.Icon or nil,
        Type = Config.Type or "Toggle",
        Callback = Config.Callback or function() end,
        UIElements = {}
    }
    Toggle.ToggleFrame = require("../components/window/Element")({
        Title = Toggle.Title,
        Desc = Toggle.Desc,
        -- Image = Config.Image,
        -- ImageSize = Config.ImageSize,  
        -- Thumbnail = Config.Thumbnail,
        -- ThumbnailSize = Config.ThumbnailSize,
        Window = Config.Window,
        Parent = Config.Parent,
        TextOffset = 44,
        Hover = false,
    })
    
    local CanCallback = true
    
    if Toggle.Value == nil then
        Toggle.Value = false
    end
    
    

    function Toggle:Lock()
        CanCallback = false
        return Toggle.ToggleFrame:Lock()
    end
    function Toggle:Unlock()
        CanCallback = true
        return Toggle.ToggleFrame:Unlock()
    end
    
    if Toggle.Locked then
        Toggle:Lock()
    end

    local Toggled = Toggle.Value
    
    local ToggleFrame, ToggleFunc
    if Toggle.Type == "Toggle" then
        ToggleFrame, ToggleFunc = CreateToggle(Toggled, Toggle.Icon, Toggle.ToggleFrame.UIElements.Main, Toggle.Callback)
    elseif Toggle.Type == "Checkbox" then
        ToggleFrame, ToggleFunc = CreateCheckbox(Toggled, Toggle.Icon, Toggle.ToggleFrame.UIElements.Main, Toggle.Callback)
    else
        error("Unknown Toggle Type: " .. tostring(Toggle.Type))
    end

    ToggleFrame.AnchorPoint = Vector2.new(1,0.5)
    ToggleFrame.Position = UDim2.new(1,0,0.5,0)
        
    function Toggle:Set(v)
        if CanCallback then
            ToggleFunc:Set(v)
            Toggled = v
            Toggle.Value = v
        end
    end

    Toggle:Set(Toggled)

    Creator.AddSignal(Toggle.ToggleFrame.UIElements.Main.MouseButton1Click, function()
        Toggle:Set(not Toggled)
    end)
    
    return Toggle.__type, Toggle
end

return Element