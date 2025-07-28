
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local CurrentCamera = workspace.CurrentCamera

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

--local UIComponents = require("../Components/UI.lua")
local CreateLabel = require("../ui/Label").New
local CreateButton = require("../ui/Button").New
local CreateScrollSlider = require("../ui/ScrollSlider").New

local ConfigManager = require("../../config/Init")

local Notified = false

return function(Config)
    local Window = {
        Title = Config.Title or "UI Library",
        Author = Config.Author,
        Icon = Config.Icon,
        IconThemed = Config.IconThemed,
        Folder = Config.Folder,
        Resizable = Config.Resizable,
        Background = Config.Background,
        BackgroundImageTransparency = Config.BackgroundImageTransparency or 0,
        User = Config.User or {},
        Size = Config.Size and UDim2.new(
                    0, math.clamp(Config.Size.X.Offset, 480, 700),
                    0, math.clamp(Config.Size.Y.Offset, 350, 520)) or UDim2.new(0,580,0,460),
        ToggleKey = Config.ToggleKey or Enum.KeyCode.G,
        Transparent = Config.Transparent or false,
        HideSearchBar = Config.HideSearchBar,
        ScrollBarEnabled = Config.ScrollBarEnabled or false,
		SideBarWidth = Config.SideBarWidth or 200,
        
        Position = UDim2.new(0.5, 0,0.5, 0),
		UICorner = 16,
		UIPadding = 14,
		UIElements = {},
		CanDropdown = true,
		Closed = false,
		Parent = Config.Parent,
		Destroyed = false,
		IsFullscreen = false,
		CanResize = false,
		IsOpenButtonEnabled = true,

        ConfigManager = nil,
		CurrentTab = nil,
		TabModule = nil,
		
		OnCloseCallback   = nil,
		OnDestroyCallback = nil,
        
        TopBarButtons = {},
        
    } -- wtf 
    
    if Window.HideSearchBar ~= false then
        Window.HideSearchBar = true
    end
    if Window.Resizable ~= false then
        Window.CanResize = true
        Window.Resizable = true
    end
    
    if Window.Folder then
        makefolder("WindUI/" .. Window.Folder)
    end
    
    local UICorner = New("UICorner", {
        CornerRadius = UDim.new(0,Window.UICorner)
    })

    Window.ConfigManager = ConfigManager:Init(Window)
    
    

    local ResizeHandle = New("Frame", {
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(1,0,1,0),
        AnchorPoint = Vector2.new(.5,.5),
        BackgroundTransparency = 1,
        ZIndex = 99,
        Active = true
    }, {
        New("ImageLabel", {
            Size = UDim2.new(0,48*2,0,48*2),
            BackgroundTransparency = 1,
            Image = "rbxassetid://120997033468887",
            Position = UDim2.new(0.5,-16,0.5,-16),
            AnchorPoint = Vector2.new(0.5,0.5),
            ImageTransparency = 1, -- .8; .35
        })
    })
    local FullScreenIcon = Creator.NewRoundFrame(Window.UICorner, "Squircle", {
        Size = UDim2.new(1,0,1,0),
        ImageTransparency = 1, -- .65
        ImageColor3 = Color3.new(0,0,0),
        ZIndex = 98,
        Active = false, -- true
    }, {
        New("ImageLabel", {
            Size = UDim2.new(0,70,0,70),
            Image = Creator.Icon("expand")[1],
            ImageRectOffset = Creator.Icon("expand")[2].ImageRectPosition,
            ImageRectSize = Creator.Icon("expand")[2].ImageRectSize,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ImageTransparency = 1,
        }),
    })

    local FullScreenBlur = Creator.NewRoundFrame(Window.UICorner, "Squircle", {
        Size = UDim2.new(1,0,1,0),
        ImageTransparency = 1, -- .65
        ImageColor3 = Color3.new(0,0,0),
        ZIndex = 999,
        Active = false, -- true
    })

    
    -- local TabHighlight = Creator.NewRoundFrame(Window.UICorner-(Window.UIPadding/2), "Squircle", {
    --     Size = UDim2.new(1,0,0,0),
    --     ImageTransparency = .95,
    --     ThemeTag = {
    --         ImageColor3 = "Text",
    --     }
    -- })

    Window.UIElements.SideBar = New("ScrollingFrame", {
        Size = UDim2.new(
            1,
            Window.ScrollBarEnabled and -3-(Window.UIPadding/2) or 0,
            1, 
            not Window.HideSearchBar and -39-6 or 0
        ),
        Position = UDim2.new(0,0,1,0),
        AnchorPoint = Vector2.new(0,1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ElasticBehavior = "Never",
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        ClipsDescendants = true,
        VerticalScrollBarPosition = "Left",
    }, {
        New("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = "Y",
            Size = UDim2.new(1,0,0,0),
            Name = "Frame",
        }, {
            New("UIPadding", {
                PaddingTop = UDim.new(0,Window.UIPadding/2),
                --PaddingLeft = UDim.new(0,4+(Window.UIPadding/2)),
                --PaddingRight = UDim.new(0,4+(Window.UIPadding/2)),
                PaddingBottom = UDim.new(0,Window.UIPadding/2),
            }),
            New("UIListLayout", {
                SortOrder = "LayoutOrder",
                Padding = UDim.new(0,0)
            })
        }),
        New("UIPadding", {
            --PaddingTop = UDim.new(0,4),
            PaddingLeft = UDim.new(0,Window.UIPadding/2),
            PaddingRight = UDim.new(0,Window.UIPadding/2),
            --PaddingBottom = UDim.new(0,Window.UIPadding),
        }),
        --TabHighlight
    })
    
    Window.UIElements.SideBarContainer = New("Frame", {
        Size = UDim2.new(0,Window.SideBarWidth,1,Window.User.Enabled and -52 -42 -(Window.UIPadding*2) or -52 ),
        Position = UDim2.new(0,0,0,52),
        BackgroundTransparency = 1,
        Visible = true,
    }, {
        New("Frame", {
            Name = "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(
                1,
                0,
                1, 
                not Window.HideSearchBar and -39-6-Window.UIPadding/2 or 0
            ),
            Position = UDim2.new(0,0,1,0),
            AnchorPoint = Vector2.new(0,1),
        }),
        Window.UIElements.SideBar,
    })
    
    if Window.ScrollBarEnabled then
        CreateScrollSlider(Window.UIElements.SideBar, Window.UIElements.SideBarContainer.Content, Window, 3)
    end
    

    Window.UIElements.MainBar = New("Frame", {
        Size = UDim2.new(1,-Window.UIElements.SideBarContainer.AbsoluteSize.X,1,-52),
        Position = UDim2.new(1,0,1,0),
        AnchorPoint = Vector2.new(1,1),
        BackgroundTransparency = 1,
    }, {
        Creator.NewRoundFrame(Window.UICorner-(Window.UIPadding/2), "Squircle", {
            Size = UDim2.new(1,0,1,0),
            ImageColor3 = Color3.new(1,1,1),
            ZIndex = 3,
            ImageTransparency = .95,
            Name = "Background",
        }),
        New("UIPadding", {
            PaddingTop = UDim.new(0,Window.UIPadding/2),
            PaddingLeft = UDim.new(0,Window.UIPadding/2),
            PaddingRight = UDim.new(0,Window.UIPadding/2),
            PaddingBottom = UDim.new(0,Window.UIPadding/2),
        })
    })
    
    local Blur = New("ImageLabel", {
        Image = "rbxassetid://8992230677",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 1, -- 0.7
        Size = UDim2.new(1,120,1,116),
        Position = UDim2.new(0,-120/2,0,-116/2),
        ScaleType = "Slice",
        SliceCenter = Rect.new(99,99,99,99),
        BackgroundTransparency = 1,
        ZIndex = -999999999999999,
        Name = "Blur",
    })

    local IsPC

    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        IsPC = false
    elseif UserInputService.KeyboardEnabled then
        IsPC = true
    else
        IsPC = nil
    end
    
    
    
    
    -- local OpenButtonContainer = nil
    -- local OpenButton = nil
    -- local OpenButtonIcon = nil
    
    
    local UserIcon
    if Window.User.Enabled then
        local ImageId, _ = game.Players:GetUserThumbnailAsync(
            Window.User.Anonymous and 1 or game.Players.LocalPlayer.UserId, 
            Enum.ThumbnailType.HeadShot, 
            Enum.ThumbnailSize.Size420x420
        )
        
        UserIcon = New("TextButton", {
            Size = UDim2.new(0,
                (Window.UIElements.SideBarContainer.AbsoluteSize.X)-(Window.UIPadding/2),
                0,
                42+(Window.UIPadding)
            ),
            Position = UDim2.new(0,Window.UIPadding/2,1,-(Window.UIPadding/2)),
            AnchorPoint = Vector2.new(0,1),
            BackgroundTransparency = 1,
        }, {
            Creator.NewRoundFrame(Window.UICorner-(Window.UIPadding/2), "SquircleOutline", {
                Size = UDim2.new(1,0,1,0),
                ThemeTag = {
                    ImageColor3 = "Text",
                },
                ImageTransparency = 1, -- .85
                Name = "Outline"
            }, {
                New("UIGradient", {
                    Rotation = 78,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0.0, 0.1),
                        NumberSequenceKeypoint.new(0.5, 1),
                        NumberSequenceKeypoint.new(1.0, 0.1),
                    })
                }),
            }),
            Creator.NewRoundFrame(Window.UICorner-(Window.UIPadding/2), "Squircle", {
                Size = UDim2.new(1,0,1,0),
                ThemeTag = {
                    ImageColor3 = "Text",
                },
                ImageTransparency = 1, -- .95
                Name = "UserIcon",
            }, {
                New("ImageLabel", {
                    Image = ImageId,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0,42,0,42),
                    ThemeTag = {
                        BackgroundColor3 = "Text",
                    },
                    BackgroundTransparency = .93,
                }, {
                    New("UICorner", {
                        CornerRadius = UDim.new(1,0)
                    })
                }),
                New("Frame", {
                    AutomaticSize = "XY",
                    BackgroundTransparency = 1,
                }, {
                    New("TextLabel", {
                        Text = Window.User.Anonymous and "Anonymous" or game.Players.LocalPlayer.DisplayName,
                        TextSize = 17,
                        ThemeTag = {
                            TextColor3 = "Text",
                        },
                        FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
                        AutomaticSize = "Y",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1,-(42/2)-6,0,0),
                        TextTruncate = "AtEnd",
                        TextXAlignment = "Left",
                    }),
                    New("TextLabel", {
                        Text = Window.User.Anonymous and "@anonymous" or "@" .. game.Players.LocalPlayer.Name,
                        TextSize = 15,
                        TextTransparency = .6,
                        ThemeTag = {
                            TextColor3 = "Text",
                        },
                        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                        AutomaticSize = "Y",
                        BackgroundTransparency = 1, 
                        Size = UDim2.new(1,-(42/2)-6,0,0),
                        TextTruncate = "AtEnd",
                        TextXAlignment = "Left",
                    }),
                    New("UIListLayout", {
                        Padding = UDim.new(0,4),
                        HorizontalAlignment = "Left",
                    })
                }),
                New("UIListLayout", {
                    Padding = UDim.new(0,Window.UIPadding),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center",
                }),
                New("UIPadding", {
                    PaddingLeft = UDim.new(0,Window.UIPadding/2),
                    PaddingRight = UDim.new(0,Window.UIPadding/2),
                })
            })
        })
        
        if Window.User.Callback then
            Creator.AddSignal(UserIcon.MouseButton1Click, function()
                Window.User.Callback()
            end)
            Creator.AddSignal(UserIcon.MouseEnter, function()
                Tween(UserIcon.UserIcon, 0.04, {ImageTransparency = .95}):Play()
                Tween(UserIcon.Outline, 0.04, {ImageTransparency = .85}):Play()
            end)
            Creator.AddSignal(UserIcon.InputEnded, function()
                Tween(UserIcon.UserIcon, 0.04, {ImageTransparency = 1}):Play()
                Tween(UserIcon.Outline, 0.04, {ImageTransparency = 1}):Play()
            end)
        end
    end
    
    local Outline1
    local Outline2
    
    
    local BottomDragFrame = Creator.NewRoundFrame(99, "Squircle", {
        ImageTransparency = .8,
        ImageColor3 = Color3.new(1,1,1),
        Size = UDim2.new(0,0,0,4), -- 200
        Position = UDim2.new(0.5,0,1,4),
        AnchorPoint = Vector2.new(0.5,0),
    }, {
        New("Frame", {
            Size = UDim2.new(1,12,1,12),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            Active = true,
            ZIndex = 99,
        })
    })

    local WindowTitle = New("TextLabel", {
        Text = Window.Title,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
        Name = "Title",
        TextXAlignment = "Left",
        TextSize = 16,
        ThemeTag = {
            TextColor3 = "Text"
        }
    })
    
    Window.UIElements.Main = New("Frame", {
        Size = Window.Size,
        Position = Window.Position,
        BackgroundTransparency = 1,
        Parent = Config.Parent,
        AnchorPoint = Vector2.new(0.5,0.5),
        Active = true,
    }, {
        Blur,
        Creator.NewRoundFrame(Window.UICorner, "Squircle", {
            ImageTransparency = 1, -- Window.Transparent and 0.25 or 0
            Size = UDim2.new(1,0,1,-240),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            Name = "Background",
            ThemeTag = {
                ImageColor3 = "Background"
            },
            --ZIndex = -9999,
        }, {
            New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Image = Window.Background,
                ImageTransparency = 1,
                ScaleType = "Crop",
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0,Window.UICorner)
                }),
            }),
            BottomDragFrame,
            ResizeHandle,
            -- New("UIScale", {
            --     Scale = 0.95,
            -- }),
        }),
        UIStroke,
        UICorner,
        FullScreenIcon,
        FullScreenBlur,
        New("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Name = "Main",
            --GroupTransparency = 1,
            Visible = false,
            ZIndex = 97,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,Window.UICorner)
            }),
            Window.UIElements.SideBarContainer,
            Window.UIElements.MainBar,
            
            UserIcon,
            
            Outline2,
            New("Frame", { -- Topbar
                Size = UDim2.new(1,0,0,52),
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.fromRGB(50,50,50),
                Name = "Topbar"
            }, {
                Outline1,
                --[[New("Frame", { -- Outline
                    Size = UDim2.new(1,Window.UIPadding*2, 0, 1),
                    Position = UDim2.new(0,-Window.UIPadding, 1,Window.UIPadding-2),
                    BackgroundTransparency = 0.9,
                    BackgroundColor3 = Color3.fromHex(Config.Theme.Outline),
                }),]]
                New("Frame", { -- Topbar Left Side
                    AutomaticSize = "X",
                    Size = UDim2.new(0,0,1,0),
                    BackgroundTransparency = 1,
                    Name = "Left"
                }, {
                    New("UIListLayout", {
                        Padding = UDim.new(0,Window.UIPadding+4),
                        SortOrder = "LayoutOrder",
                        FillDirection = "Horizontal",
                        VerticalAlignment = "Center",
                    }),
                    New("Frame", {
                        AutomaticSize = "XY",
                        BackgroundTransparency = 1,
                        Name = "Title",
                        Size = UDim2.new(0,0,1,0),
                        LayoutOrder= 2,
                    }, {
                        New("UIListLayout", {
                            Padding = UDim.new(0,0),
                            SortOrder = "LayoutOrder",
                            FillDirection = "Vertical",
                            VerticalAlignment = "Top",
                        }),
                        WindowTitle,
                    }),
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0,4)
                    })
                }),
                New("Frame", { -- Topbar Right Side -- Window.UIElements.Main.Main.Topbar.Right
                    AutomaticSize = "XY",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1,0,0.5,0),
                    AnchorPoint = Vector2.new(1,0.5),
                    Name = "Right",
                }, {
                    New("UIListLayout", {
                        Padding = UDim.new(0,9),
                        FillDirection = "Horizontal",
                        SortOrder = "LayoutOrder",
                    }),
                    
                }),
                New("UIPadding", {
                    PaddingTop = UDim.new(0,Window.UIPadding),
                    PaddingLeft = UDim.new(0,Window.UIPadding),
                    PaddingRight = UDim.new(0,8),
                    PaddingBottom = UDim.new(0,Window.UIPadding),
                })
            })
        })
    })

    
    function Window:CreateTopbarButton(Name, Icon, Callback, LayoutOrder, IconThemed)
        local IconFrame = Creator.Image(
            Icon,
            Icon,
            0,
            Window.Folder,
            "TopbarIcon",
            true,
            IconThemed
        )
        IconFrame.Size = UDim2.new(0,16,0,16)
        IconFrame.AnchorPoint = Vector2.new(0.5,0.5)
        IconFrame.Position = UDim2.new(0.5,0,0.5,0)
        
        local Button = Creator.NewRoundFrame(9, "Squircle", {
            Size = UDim2.new(0,36,0,36),
            LayoutOrder = LayoutOrder or 999,
            Parent = Window.UIElements.Main.Main.Topbar.Right,
            --Active = true,
            ZIndex = 9999,
            ThemeTag = {
                ImageColor3 = "Text"
            },
            ImageTransparency = 1 -- .93
        }, {
            Creator.NewRoundFrame(9, "SquircleOutline", {
                Size = UDim2.new(1,0,1,0),
                ThemeTag = {
                    ImageColor3 = "Text",
                },
                ImageTransparency = 1, -- .75  
                Name = "Outline"
            }, {
                New("UIGradient", {
                    Rotation = 45,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0.0, 0.1),
                        NumberSequenceKeypoint.new(0.5, 1),
                        NumberSequenceKeypoint.new(1.0, 0.1),
                    })
                }),
            }),
            IconFrame
        }, true)
    
        -- shhh
        
        Window.TopBarButtons[100-LayoutOrder] = {
            Name = Name,
            Object = Button
        }
        
        Creator.AddSignal(Button.MouseButton1Click, function()
            Callback()
        end)
        Creator.AddSignal(Button.MouseEnter, function()
            Tween(Button, .15, {ImageTransparency = .93}):Play()
            Tween(Button.Outline, .15, {ImageTransparency = .75}):Play()
            --Tween(IconFrame.ImageLabel, .15, {ImageTransparency = 0}):Play()
        end)
        Creator.AddSignal(Button.MouseLeave, function()
            Tween(Button, .1, {ImageTransparency = 1}):Play()
            Tween(Button.Outline, .1, {ImageTransparency = 1}):Play()
            --Tween(IconFrame.ImageLabel, .1, {ImageTransparency = .2}):Play()
        end)
        
        return Button
    end

    -- local Dragged = false

    local WindowDragModule = Creator.Drag(
        Window.UIElements.Main, 
        {Window.UIElements.Main.Main.Topbar, BottomDragFrame.Frame}, 
        function(dragging, frame) -- On drag
            if not Window.Closed then
                if dragging and frame == BottomDragFrame.Frame then
                    Tween(BottomDragFrame, .1, {ImageTransparency = .35}):Play()
                else
                    Tween(BottomDragFrame, .2, {ImageTransparency = .8}):Play()
                end
            end
        end
    )
    
    -- local blur = require("../Blur")
    
    -- blur.new(Window.UIElements.Main.Background, {
    --     Corner = Window.UICorner
    -- })
    
    --Creator.Blur(Window.UIElements.Main.Background)
    -- local OpenButtonDragModule
    
    -- if not IsPC then
    --     OpenButtonDragModule = Creator.Drag(OpenButtonContainer)
    -- end
    
    if Window.Author then
        local Author = New("TextLabel", {
            Text = Window.Author,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            BackgroundTransparency = 1,
            TextTransparency = 0.4,
            AutomaticSize = "XY",
            Parent = Window.UIElements.Main.Main.Topbar.Left.Title,
            TextXAlignment = "Left",
            TextSize = 13,
            LayoutOrder = 2,
            ThemeTag = {
                TextColor3 = "Text"
            }
        })
        
    end
    
    local OpenButtonMain = require("./Openbutton").New(Window)

    
    task.spawn(function()
        if Window.Icon then
            
            local ImageFrame = Creator.Image(
                Window.Icon,
                Window.Title,
                0,
                Window.Folder,
                "Window",
                true,
                Window.IconThemed
            )
            ImageFrame.Parent = Window.UIElements.Main.Main.Topbar.Left
            ImageFrame.Size = UDim2.new(0,22,0,22)
            
            OpenButtonMain:SetIcon(Window.Icon)
            
            -- if Creator.Icon(tostring(Window.Icon)) and Creator.Icon(tostring(Window.Icon))[1] then
            --     -- ImageLabel.Image = Creator.Icon(Window.Icon)[1]
            --     -- ImageLabel.ImageRectOffset = Creator.Icon(Window.Icon)[2].ImageRectPosition
            --     -- ImageLabel.ImageRectSize = Creator.Icon(Window.Icon)[2].ImageRectSize
            --     -- OpenButtonIcon.Image = Creator.Icon(Window.Icon)[1]
            --     -- OpenButtonIcon.ImageRectOffset = Creator.Icon(Window.Icon)[2].ImageRectPosition
            --     -- OpenButtonIcon.ImageRectSize = Creator.Icon(Window.Icon)[2].ImageRectSize
                
            -- end
            -- end
        else
            OpenButtonMain:SetIcon(Window.Icon)
            OpenButtonIcon.Visible = false
        end
    end)
    
    function Window:SetToggleKey(keycode)
        Window.ToggleKey = keycode
    end
    
    function Window:SetBackgroundImage(id)
        Window.UIElements.Main.Background.ImageLabel.Image = id
    end
    function Window:SetBackgroundImageTransparency(v)
        Window.UIElements.Main.Background.ImageLabel.ImageTransparency = v
        Window.BackgroundImageTransparency = v
    end
    
    local CurrentPos
    local CurrentSize
    local iconCopy = Creator.Icon("minimize")
    local iconSquare = Creator.Icon("maximize")
    
    local FullscreenButton = Window:CreateTopbarButton("Fullscreen", "maximize", function() 
        Window:ToggleFullscreen()
    end, 998)
    
    function Window:ToggleFullscreen()
        local isFullscreen = Window.IsFullscreen
        -- Creator.SetDraggable(isFullscreen)
        WindowDragModule:Set(isFullscreen)
    
        if not isFullscreen then
            CurrentPos = Window.UIElements.Main.Position
            CurrentSize = Window.UIElements.Main.Size
            
            Window.CanResize = false
        else
            if Window.Resizable then
                Window.CanResize = true
            end
        end
        
        Tween(Window.UIElements.Main, 0.45, {Size = isFullscreen and CurrentSize or UDim2.new(1,-20,1,-20-52)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    
        Tween(Window.UIElements.Main, 0.45, {Position = isFullscreen and CurrentPos or UDim2.new(0.5,0,0.5,52/2)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        -- delay(0, function()
        -- end)
        
        Window.IsFullscreen = not isFullscreen
    end
    
    
    Window:CreateTopbarButton("Minimize", "minus", function() 
        Window:Close()
        task.spawn(function()
            task.wait(.3)
            if not IsPC and Window.IsOpenButtonEnabled then
                -- OpenButtonContainer.Visible = true
                OpenButtonMain:Visible(true)
            end
        end)
        
        local NotifiedText = IsPC and "Press " .. Window.ToggleKey.Name .. " to open the Window" or "Click the Button to open the Window"
        
        if not Window.IsOpenButtonEnabled then
            Notified = true
        end
        if not Notified then
            Notified = not Notified
            Config.WindUI:Notify({
                Title = "Minimize",
                Content = "You've closed the Window. " .. NotifiedText,
                Icon = "eye-off",
                Duration = 5,
            })
        end
    end, 997)
    
    function Window:OnClose(func)
        Window.OnCloseCallback = func
    end
    function Window:OnDestroy(func)
        Window.OnDestroyCallback = func
    end

    function Window:Open()
        task.spawn(function()
            task.wait(.06)
            Window.Closed = false
            
            Tween(Window.UIElements.Main.Background, 0.2, {
                ImageTransparency = Window.Transparent and Config.WindUI.TransparencyValue or 0,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        
            Tween(Window.UIElements.Main.Background, 0.4, {
                Size = UDim2.new(1,0,1,0),
            }, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        
            Tween(Window.UIElements.Main.Background.ImageLabel, 0.2, {ImageTransparency = Window.BackgroundImageTransparency}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            --Tween(Window.UIElements.Main.Background.UIScale, 0.2, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
            Tween(Blur, 0.25, {ImageTransparency = .7}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            if UIStroke then
                Tween(UIStroke, 0.25, {Transparency = .8}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            end
            
            task.spawn(function()
                task.wait(.5)
                Tween(BottomDragFrame, .45, {Size = UDim2.new(0,200,0,4), ImageTransparency = .8}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
                task.wait(.45)
                WindowDragModule:Set(true)
                if Window.Resizable then
                    Tween(ResizeHandle.ImageLabel, .45, {ImageTransparency = .8}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
                    Window.CanResize = true
                end
            end)
        
            
            Window.CanDropdown = true
            
            Window.UIElements.Main.Visible = true
            task.spawn(function()
                task.wait(.05)
                Window.UIElements.Main.Main.Visible = true
            end)
        end)
    end
    function Window:Close()
        local Close = {}
        
        if Window.OnCloseCallback then
            task.spawn(function()
                Creator.SafeCallback(Window.OnCloseCallback)
            end)
        end
        
        Window.UIElements.Main.Main.Visible = false
        Window.CanDropdown = false
        Window.Closed = true
        
        Tween(Window.UIElements.Main.Background, 0.32, {
            ImageTransparency = 1,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
    
        Tween(Window.UIElements.Main.Background, 0.4, {
            Size = UDim2.new(1,0,1,-240),
        }, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut):Play()
    
        --Tween(Window.UIElements.Main.Background.UIScale, 0.19, {Scale = .95}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(Window.UIElements.Main.Background.ImageLabel, 0.2, {ImageTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(Blur, 0.25, {ImageTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        if UIStroke then
            Tween(UIStroke, 0.25, {Transparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        end
        
        Tween(BottomDragFrame, .3, {Size = UDim2.new(0,0,0,4), ImageTransparency = 1}, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut):Play()
        Tween(ResizeHandle.ImageLabel, .3, {ImageTransparency = 1}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        WindowDragModule:Set(false)
        Window.CanResize = false
        
        task.spawn(function()
            task.wait(0.4)
            Window.UIElements.Main.Visible = false
        end)
        
        function Close:Destroy()
            if Window.OnDestroyCallback then
                task.spawn(function()
                    Creator.SafeCallback(Window.OnDestroyCallback)
                end)
            end
            Window.Destroyed = true
            task.wait(0.4)
            Config.Parent.Parent:Destroy()
            
            --Creator.DisconnectAll()
        end
        
        return Close
    end
    
    function Window:ToggleTransparency(Value)
        -- Config.Transparent = Value
        Window.Transparent = Value
        Config.WindUI.Transparent = Value
        
        Window.UIElements.Main.Background.ImageTransparency = Value and Config.WindUI.TransparencyValue or 0
        -- Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and Config.WindUI.TransparencyValue or 0
        Window.UIElements.MainBar.Background.ImageTransparency = Value and 0.97 or 0.95
        
    end


    function Window:SetUIScale(v)
        Config.WindUI.UIScale = v
        Tween(Config.WindUI.ScreenGui.UIScale, .2, {Scale = v}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    
    do
        local Margin = 40
        if (CurrentCamera.ViewportSize.X - 40 < Window.UIElements.Main.AbsoluteSize.X) 
        or (CurrentCamera.ViewportSize.Y - 40 < Window.UIElements.Main.AbsoluteSize.Y) then
            if not Window.IsFullscreen then
                Window:SetUIScale(.9)
            end
        end
    end

    if not IsPC and Window.IsOpenButtonEnabled then
        Creator.AddSignal(OpenButtonMain.Button.TextButton.MouseButton1Click, function()
            -- OpenButtonContainer.Visible = false
            OpenButtonMain:Visible(false)
            Window:Open()
        end)
    end
    
    Creator.AddSignal(UserInputService.InputBegan, function(input, isProcessed)
        if isProcessed then return end
        
        if input.KeyCode == Window.ToggleKey then
            if Window.Closed then
                Window:Open()
            else
                Window:Close()
            end
        end
    end)
    
    task.spawn(function()
        --task.wait(1.38583)
        Window:Open()
    end)
    
    function Window:EditOpenButton(OpenButtonConfig)
        return OpenButtonMain:Edit(OpenButtonConfig)
    end
    
    
    local TabModuleMain = require("./Tab")
    local SectionModule = require("./Section")
    local TabModule = TabModuleMain.Init(Window, Config.WindUI, Config.Parent.Parent.ToolTips)
    TabModule:OnChange(function(t) Window.CurrentTab = t end)
    
    Window.TabModule = TabModuleMain
    
    function Window:Tab(TabConfig)
        TabConfig.Parent = Window.UIElements.SideBar.Frame
        return TabModule.New(TabConfig)
    end
    
    function Window:SelectTab(Tab)
        TabModule:SelectTab(Tab)
    end
    
    function Window:Section(SectionConfig)
        return SectionModule.New(SectionConfig, Window.UIElements.SideBar.Frame, Window.Folder, Config.WindUI.UIScale)
    end
    
    function Window:IsResizable(v)
        Window.Resizable = v
        Window.CanResize = v
    end
    
    function Window:Divider()
        local Divider = New("Frame", {
            Size = UDim2.new(1,0,0,1),
            Position = UDim2.new(0.5,0,0,0),
            AnchorPoint = Vector2.new(0.5,0),
            BackgroundTransparency = .9,
            ThemeTag = {
                BackgroundColor3 = "Text"
            }
        })
        local MainDivider = New("Frame", {
            Parent = Window.UIElements.SideBar.Frame,
            --AutomaticSize = "Y",
            Size = UDim2.new(1,-7,0,5),
            BackgroundTransparency = 1,
        }, {
            Divider
        })
        
        return MainDivider
    end
    
    local DialogModule = require("./Dialog").Init(Window, nil)
    function Window:Dialog(DialogConfig)
        local DialogTable = {
            Title = DialogConfig.Title or "Dialog",
            Width = DialogConfig.Width or 320,
            Content = DialogConfig.Content,
            Buttons = DialogConfig.Buttons or {},
            
            TextPadding = 10,
        }
        local Dialog = DialogModule.Create(false)
        
        Dialog.UIElements.Main.Size = UDim2.new(0,DialogTable.Width,0,0)
        
        local DialogTopFrame = New("Frame", {
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = "Y",
            BackgroundTransparency = 1,
            Parent = Dialog.UIElements.Main
        }, {
            New("UIListLayout", {
                FillDirection = "Horizontal",
                Padding = UDim.new(0,Dialog.UIPadding),
                VerticalAlignment = "Center"
            }),
            New("UIPadding", {
                PaddingTop = UDim.new(0, DialogTable.TextPadding),
                PaddingLeft = UDim.new(0, DialogTable.TextPadding),
                PaddingRight = UDim.new(0, DialogTable.TextPadding),
            })
        })
        
        local Icon
        if DialogConfig.Icon then
            Icon = Creator.Image(
                DialogConfig.Icon,
                DialogTable.Title .. ":" .. DialogConfig.Icon,
                0,
                Window,
                "Dialog",
                true,
                DialogConfig.IconThemed
            )
            Icon.Size = UDim2.new(0,22,0,22)
            Icon.Parent = DialogTopFrame
        end
        
        Dialog.UIElements.UIListLayout = New("UIListLayout", {
            Padding = UDim.new(0,12),
            FillDirection = "Vertical",
            HorizontalAlignment = "Left",
            Parent = Dialog.UIElements.Main
        })
    
        New("UISizeConstraint", {
			MinSize = Vector2.new(180, 20),
			MaxSize = Vector2.new(400, math.huge),
			Parent = Dialog.UIElements.Main,
		})
        

        Dialog.UIElements.Title = New("TextLabel", {
            Text = DialogTable.Title,
            TextSize = 20,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
            TextXAlignment = "Left",
            TextWrapped = true,
            RichText = true,
            Size = UDim2.new(1,Icon and -26-Dialog.UIPadding or 0,0,0),
            AutomaticSize = "Y",
            ThemeTag = {
                TextColor3 = "Text"
            },
            BackgroundTransparency = 1,
            Parent = DialogTopFrame
        })
        if DialogTable.Content then
            local Content = New("TextLabel", {
                Text = DialogTable.Content,
                TextSize = 18,
                TextTransparency = .4,
                TextWrapped = true,
                RichText = true,
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                TextXAlignment = "Left",
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = "Y",
                LayoutOrder = 2,
                ThemeTag = {
                    TextColor3 = "Text"
                },
                BackgroundTransparency = 1,
                Parent = Dialog.UIElements.Main
            }, {
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, DialogTable.TextPadding),
                    PaddingRight = UDim.new(0, DialogTable.TextPadding),
                    PaddingBottom = UDim.new(0, DialogTable.TextPadding),
                })
            })
        end
        
        local ButtonsLayout = New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = "Horizontal",
            HorizontalAlignment = "Right",
        })
        
        local ButtonsContent = New("Frame", {
            Size = UDim2.new(1,0,0,40),
            AutomaticSize = "None",
            BackgroundTransparency = 1,
            Parent = Dialog.UIElements.Main,
            LayoutOrder = 4,
        }, {
            ButtonsLayout,
        })
        
        
        local Buttons = {}

        for _,Button in next, DialogTable.Buttons do
            local ButtonFrame = CreateButton(Button.Title, Button.Icon, Button.Callback, Button.Variant, ButtonsContent, Dialog, true)
            table.insert(Buttons, ButtonFrame)
        end
        
        local function CheckButtonsOverflow()
            ButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
            ButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            ButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            ButtonsContent.AutomaticSize = Enum.AutomaticSize.None
            
            for _, button in ipairs(Buttons) do
                button.Size = UDim2.new(0, 0, 1, 0)
                button.AutomaticSize = Enum.AutomaticSize.X
            end
            
            wait()
            
            local totalWidth = ButtonsLayout.AbsoluteContentSize.X
            local parentWidth = ButtonsContent.AbsoluteSize.X
            
            if totalWidth > parentWidth then
                ButtonsLayout.FillDirection = Enum.FillDirection.Vertical
                ButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                ButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
                ButtonsContent.AutomaticSize = Enum.AutomaticSize.Y
                
                for _, button in ipairs(Buttons) do
                    button.Size = UDim2.new(1, 0, 0, 40)
                    button.AutomaticSize = Enum.AutomaticSize.None
                end
            else
                local availableSpace = parentWidth - totalWidth
                if availableSpace > 0 then
                    local smallestButton = nil
                    local smallestWidth = math.huge
                    
                    for _, button in ipairs(Buttons) do
                        local buttonWidth = button.AbsoluteSize.X
                        if buttonWidth < smallestWidth then
                            smallestWidth = buttonWidth
                            smallestButton = button
                        end
                    end
                    
                    if smallestButton then
                        smallestButton.Size = UDim2.new(0, smallestWidth + availableSpace, 1, 0)
                        smallestButton.AutomaticSize = Enum.AutomaticSize.None
                    end
                end
            end
        end

        Creator.AddSignal(Dialog.UIElements.Main:GetPropertyChangedSignal("AbsoluteSize"), CheckButtonsOverflow)
        CheckButtonsOverflow()
        
        wait()
        Dialog:Open()
        
        return Dialog
    end
    
    Window:CreateTopbarButton("Close", "x", function()
        Tween(Window.UIElements.Main, 0.35, {Position = UDim2.new(0.5,0,0.5,0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Window:Dialog({
            --Icon = "trash-2",
            Title = "Close Window",
            Content = "Do you want to close this window? You will not be able to open it again.",
            Buttons = {
                {
                    Title = "Cancel",
                    --Icon = "chevron-left",
                    Callback = function() end,
                    Variant = "Secondary",
                },
                {
                    Title = "Close Window",
                    --Icon = "chevron-down",
                    Callback = function() Window:Close():Destroy() end,
                    Variant = "Primary",
                }
            }
        })
    end, 999)
    

    local function startResizing(input)
        if Window.CanResize then
            isResizing = true
            FullScreenIcon.Active = true
            initialSize = Window.UIElements.Main.Size
            initialInputPosition = input.Position
            Tween(FullScreenIcon, 0.12, {ImageTransparency = .65}):Play()
            Tween(FullScreenIcon.ImageLabel, 0.12, {ImageTransparency = 0}):Play()
            Tween(ResizeHandle.ImageLabel, 0.1, {ImageTransparency = .35}):Play()
        
            Creator.AddSignal(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                    FullScreenIcon.Active = false
                    Tween(FullScreenIcon, 0.2, {ImageTransparency = 1}):Play()
                    Tween(FullScreenIcon.ImageLabel, 0.17, {ImageTransparency = 1}):Play()
                    Tween(ResizeHandle.ImageLabel, 0.17, {ImageTransparency = .8}):Play()
                end
            end)
        end
    end
    
    Creator.AddSignal(ResizeHandle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Window.CanResize then
                startResizing(input)
            end
        end
    end)
    
    Creator.AddSignal(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if isResizing and Window.CanResize then
                local delta = input.Position - initialInputPosition
                local newSize = UDim2.new(0, initialSize.X.Offset + delta.X*2, 0, initialSize.Y.Offset + delta.Y*2)
                
                Tween(Window.UIElements.Main, 0, {
                    Size = UDim2.new(
                    0, math.clamp(newSize.X.Offset, 480, 700),
                    0, math.clamp(newSize.Y.Offset, 350, 520)
                )}):Play()
            end
        end
    end)
    
    
    -- / Search Bar /
    
    if not Window.HideSearchBar then
        local SearchBar = require("../search/Init")
        local IsOpen = false
        local CurrentSearchBar
    
        -- local SearchButton
        -- SearchButton = Window:CreateTopbarButton("search", function() 
        --     if IsOpen then return end
            
        --     SearchBar.new(Window.TabModule, Window.UIElements.Main, function()
        --         -- OnClose
        --         IsOpen = false
        --         Window.CanResize = true
                
        --         Tween(FullScreenBlur, 0.1, {ImageTransparency = 1}):Play()
        --         FullScreenBlur.Active = false
        --     end)
        --     Tween(FullScreenBlur, 0.1, {ImageTransparency = .65}):Play()
        --     FullScreenBlur.Active = true
            
        --     IsOpen = true
        --     Window.CanResize = false
        -- end, 996)
        
        local SearchLabel = CreateLabel("Search", "search", Window.UIElements.SideBarContainer)
        SearchLabel.Size = UDim2.new(1,-Window.UIPadding/2,0,39)
        SearchLabel.Position = UDim2.new(0,Window.UIPadding/2,0,Window.UIPadding/2)
        
        Creator.AddSignal(SearchLabel.MouseButton1Click, function()
            if IsOpen then return end
            
            SearchBar.new(Window.TabModule, Window.UIElements.Main, function()
                -- OnClose
                IsOpen = false
                if Window.Resizable then
                    Window.CanResize = true
                end
                
                Tween(FullScreenBlur, 0.1, {ImageTransparency = 1}):Play()
                FullScreenBlur.Active = false
            end)
            Tween(FullScreenBlur, 0.1, {ImageTransparency = .65}):Play()
            FullScreenBlur.Active = true
            
            IsOpen = true
            Window.CanResize = false
        end)
    end


    -- / TopBar Edit /
    
    function Window:DisableTopbarButtons(btns)
        for _,b in next, btns do
            for _,i in next, Window.TopBarButtons do
                if i.Name == b then
                    i.Object.Visible = false
                end
            end
        end
    end

    return Window
end