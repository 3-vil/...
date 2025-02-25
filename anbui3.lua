--[[
    Anbu.win Premium GUI Library
    
    A meticulously crafted, enterprise-grade UI system for Roblox
    Designed with precision, performance and premium aesthetics
]]

local AnbuLibrary = {}
AnbuLibrary.__index = AnbuLibrary

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Constants
local THEME = {
    DARK = {
        BACKGROUND = Color3.fromRGB(18, 18, 24),
        BACKGROUND_SECONDARY = Color3.fromRGB(24, 24, 32),
        FOREGROUND = Color3.fromRGB(210, 210, 220),
        ACCENT = Color3.fromRGB(130, 80, 245),
        ACCENT_DARK = Color3.fromRGB(100, 60, 200),
        ACCENT_LIGHT = Color3.fromRGB(150, 100, 255),
        BORDER = Color3.fromRGB(40, 40, 50),
        SUCCESS = Color3.fromRGB(80, 220, 100),
        WARNING = Color3.fromRGB(245, 190, 80),
        ERROR = Color3.fromRGB(245, 80, 80),
        SHADOW = Color3.fromRGB(0, 0, 0)
    },
    LIGHT = {
        BACKGROUND = Color3.fromRGB(240, 240, 245),
        BACKGROUND_SECONDARY = Color3.fromRGB(230, 230, 235),
        FOREGROUND = Color3.fromRGB(40, 40, 45),
        ACCENT = Color3.fromRGB(130, 80, 245),
        ACCENT_DARK = Color3.fromRGB(100, 60, 200),
        ACCENT_LIGHT = Color3.fromRGB(150, 100, 255),
        BORDER = Color3.fromRGB(200, 200, 210),
        SUCCESS = Color3.fromRGB(60, 200, 80),
        WARNING = Color3.fromRGB(240, 180, 60),
        ERROR = Color3.fromRGB(240, 70, 70),
        SHADOW = Color3.fromRGB(180, 180, 195)
    }
}

local EASING = {
    PREMIUM = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    SMOOTH = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
    BOUNCE = TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    SPRING = TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0.1)
}

local ASSETS = {
    LOGO = "rbxassetid://14133394168",
    CLOSE = "rbxassetid://11496148208",
    MINIMIZE = "rbxassetid://11496156481",
    SETTINGS = "rbxassetid://11496156646",
    NOTIFICATION = "rbxassetid://11496144923",
    CHECK = "rbxassetid://11496156063",
    ARROW_DOWN = "rbxassetid://11496149945",
    LOCK = "rbxassetid://11496150481",
    WARNING = "rbxassetid://11496151094",
    INFO = "rbxassetid://11496150142",
    ERROR = "rbxassetid://11496149613",
    SUCCESS = "rbxassetid://11496150739",
    GITHUB = "rbxassetid://11496150070",
    DISCORD = "rbxassetid://11496149533",
    KEY = "rbxassetid://11496150282",
    USER = "rbxassetid://11496150918",
    AIM = "rbxassetid://11496149824",
    CONFIG = "rbxassetid://11496149409",
    SEARCH = "rbxassetid://11496150667",
    SCRIPT = "rbxassetid://11496150667"
}

-- Utility Functions
local function Create(instanceType)
    return function(properties)
        local instance = Instance.new(instanceType)
        for k, v in pairs(properties) do
            if k ~= "Parent" and k ~= "Children" then
                instance[k] = v
            end

-- Return the library
return AnbuLibrary
        end
        
        if properties.Children then
            for _, child in ipairs(properties.Children) do
                child.Parent = instance
            end
        end
        
        if properties.Parent then
            instance.Parent = properties.Parent
        end
        
        return instance
    end
end

local function ApplyShadow(element, size, transparency)
    size = size or 4
    transparency = transparency or 0.65
    
    local shadow = Create("ImageLabel")({
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, size * 2, 1, size * 2),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = element
    })
    
    shadow.ZIndex = element.ZIndex - 1
    return shadow
end

local function ApplyGlassEffect(frame, intensity)
    intensity = intensity or 0.92
    
    local blur = Create("BlurEffect")({
        Size = 10,
        Parent = frame
    })
    
    local glass = Create("Frame")({
        Name = "GlassEffect",
        BackgroundTransparency = intensity,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = frame.ZIndex + 1,
        Parent = frame
    })
    
    return glass
end

local function ApplyRippleEffect(button, rippleColor)
    local rippleContainer = Create("Frame")({
        Name = "RippleContainer",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = button.ZIndex + 1,
        Parent = button
    })
    
    button.MouseButton1Down:Connect(function(x, y)
        local ripple = Create("Frame")({
            Name = "Ripple",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = rippleColor or Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.7,
            Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = button.ZIndex + 2,
            Parent = rippleContainer
        })
        
        local cornerRadius = Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = ripple
        })
        
        local targetSize = UDim2.new(0, button.AbsoluteSize.X * 2.5, 0, button.AbsoluteSize.X * 2.5)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        local sizeTween = TweenService:Create(ripple, tweenInfo, {Size = targetSize})
        local transparencyTween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1})
        
        sizeTween:Play()
        sizeTween.Completed:Connect(function()
            transparencyTween:Play()
            transparencyTween.Completed:Connect(function()
                ripple:Destroy()
            end)
        end)
    end)
end

local function CreateStroke(parent, color, thickness, transparency)
    return Create("UIStroke")({
        Color = color,
        Thickness = thickness or 1.5,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

-- Main Library
function AnbuLibrary.new(title)
    local self = setmetatable({}, AnbuLibrary)
    self.title = title or "Anbu.win"
    self.theme = "DARK"
    self.elements = {}
    self.callbacks = {}
    self.configs = {}
    self.currentTab = nil
    self.dragging = false
    self.resizing = false
    self.dragStart = nil
    self.startPos = nil
    self.startSize = nil
    self.configFolder = "AnbuWin"
    self.defaultConfig = "default"
    
    -- Create the base GUI
    self:CreateBaseGUI()
    self:CreateTabSystem()
    self:CreateNotificationSystem()
    self:CreateConsole()
    self:SetupKeySystem()
    self:LoadConfigs()
    
    -- Register events
    self:SetupDragging()
    self:SetupResizing()
    self:RegisterHotkeys()
    
    return self
end

function AnbuLibrary:CreateBaseGUI()
    -- Create ScreenGui
    self.gui = Create("ScreenGui")({
        Name = "AnbuWin",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (RunService:IsStudio() and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")) or CoreGui
    })
    
    -- Create main container
    self.main = Create("Frame")({
        Name = "MainContainer",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -275),
        Size = UDim2.new(0, 800, 0, 550),
        ClipsDescendants = true,
        Parent = self.gui
    })
    
    -- Apply rounded corners
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = self.main
    })
    
    -- Apply shadow
    ApplyShadow(self.main, 15, 0.5)
    
    -- Create title bar
    self.titleBar = Create("Frame")({
        Name = "TitleBar",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.main
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = self.titleBar
    })
    
    -- Logo
    self.logo = Create("ImageLabel")({
        Name = "Logo",
        BackgroundTransparency = 1,
        Image = ASSETS.LOGO,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 12, 0, 6),
        Parent = self.titleBar
    })
    
    -- Title text
    self.titleText = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = self.title,
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 44, 0, 0),
        Parent = self.titleBar
    })
    
    -- Control buttons container
    self.controls = Create("Frame")({
        Name = "Controls",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -80, 0, 0),
        Parent = self.titleBar
    })
    
    -- Minimize button
    self.minimizeBtn = Create("ImageButton")({
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Image = ASSETS.MINIMIZE,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 20, 0.5, -8),
        Parent = self.controls
    })
    
    -- Close button
    self.closeBtn = Create("ImageButton")({
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Image = ASSETS.CLOSE,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 50, 0.5, -8),
        Parent = self.controls
    })
    
    -- Theme toggle
    self.themeToggle = Create("Frame")({
        Name = "ThemeToggle",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -130, 0, 8),
        Parent = self.titleBar
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = self.themeToggle
    })
    
    self.themeIndicator = Create("Frame")({
        Name = "ThemeIndicator",
        BackgroundColor3 = THEME[self.theme].ACCENT,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0, 2),
        Parent = self.themeToggle
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = self.themeIndicator
    })
    
    -- Set up theme toggle functionality
    self.themeToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:ToggleTheme()
        end
    end)
    
    -- Set up close button functionality
    self.closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Set up minimize button functionality
    self.minimizeBtn.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    -- Content container
    self.contentContainer = Create("Frame")({
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        Parent = self.main
    })
    
    -- Status bar
    self.statusBar = Create("Frame")({
        Name = "StatusBar",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        Parent = self.main
    })
    
    -- Status text
    self.statusText = Create("TextLabel")({
        Name = "StatusText",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Ready",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = self.statusBar
    })
    
    -- Time
    self.timeText = Create("TextLabel")({
        Name = "TimeText",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = os.date("%H:%M:%S"),
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -70, 0, 0),
        Parent = self.statusBar
    })
    
    -- Update time
    spawn(function()
        while wait(1) do
            pcall(function()
                self.timeText.Text = os.date("%H:%M:%S")
            end)
        end
    end)
    
    -- Resize handle
    self.resizeHandle = Create("Frame")({
        Name = "ResizeHandle",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        Parent = self.main
    })
    
    self.resizeIcon = Create("ImageLabel")({
        Name = "ResizeIcon",
        BackgroundTransparency = 1,
        Image = "rbxassetid://11496151652",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0, 2),
        Parent = self.resizeHandle
    })
end

function AnbuLibrary:CreateTabSystem()
    -- Tab bar
    self.tabBar = Create("Frame")({
        Name = "TabBar",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.contentContainer
    })
    
    -- Tab container
    self.tabContainer = Create("ScrollingFrame")({
        Name = "TabContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -100, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = self.tabBar
    })
    
    -- Tab layout
    self.tabLayout = Create("UIListLayout")({
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = self.tabContainer
    })
    
    -- Add tab button
    self.addTabBtn = Create("ImageButton")({
        Name = "AddTabButton",
        BackgroundTransparency = 1,
        Image = "rbxassetid://11496149028",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0, 6),
        Parent = self.tabBar
    })
    
    -- Content frame
    self.contentFrame = Create("Frame")({
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 36),
        Parent = self.contentContainer
    })
    
    -- Create default tabs
    self:AddTab("Scripts", ASSETS.SCRIPT)
    self:AddTab("Aimbot", ASSETS.AIM)
    self:AddTab("Config", ASSETS.CONFIG)
    self:AddTab("Settings", ASSETS.SETTINGS)
    
    -- Setup tab content
    self:SetupScriptsTab()
    self:SetupAimbotTab()
    self:SetupConfigTab()
    self:SetupSettingsTab()
    
    -- Select first tab by default
    self:SelectTab("Scripts")
end

function AnbuLibrary:AddTab(name, icon)
    -- Tab button
    local tab = Create("Frame")({
        Name = name .. "Tab",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 120, 1, 0),
        Parent = self.tabContainer
    })
    
    -- Tab icon
    local tabIcon = Create("ImageLabel")({
        Name = "Icon",
        BackgroundTransparency = 1,
        Image = icon,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        Parent = tab
    })
    
    -- Tab name
    local tabName = Create("TextLabel")({
        Name = "Name",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        Parent = tab
    })
    
    -- Tab close button
    local closeBtn = Create("ImageButton")({
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Image = ASSETS.CLOSE,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -20, 0.5, -6),
        Visible = false,
        Parent = tab
    })
    
    -- Tab content
    local content = Create("Frame")({
        Name = name .. "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = self.contentFrame
    })
    
    -- Store tab and content
    self.elements[name] = {
        tab = tab,
        content = content,
        icon = tabIcon,
        name = tabName,
        closeBtn = closeBtn
    }
    
    -- Setup tab click functionality
    tab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:SelectTab(name)
        end
    end)
    
    -- Update canvas size
    self.tabContainer.CanvasSize = UDim2.new(0, self.tabLayout.AbsoluteContentSize.X, 0, 0)
    
    return content
end

function AnbuLibrary:SelectTab(name)
    -- Hide all tabs content
    for tabName, tabData in pairs(self.elements) do
        if tabData.tab and tabData.content then
            tabData.tab.BackgroundColor3 = THEME[self.theme].BACKGROUND
            tabData.name.TextColor3 = THEME[self.theme].FOREGROUND
            tabData.content.Visible = false
            
            if tabData.indicator then
                tabData.indicator.Visible = false
            end
        end
    end
    
    -- Show selected tab content
    if self.elements[name] then
        self.elements[name].tab.BackgroundColor3 = THEME[self.theme].ACCENT
        self.elements[name].name.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.elements[name].content.Visible = true
        
        -- Add indicator if it doesn't exist
        if not self.elements[name].indicator then
            self.elements[name].indicator = Create("Frame")({
                Name = "Indicator",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, -2),
                Parent = self.elements[name].tab
            })
        else
            self.elements[name].indicator.Visible = true
        end
        
        self.currentTab = name
        self.statusText.Text = "Current Tab: " .. name
    end
end

function AnbuLibrary:SetupScriptsTab()
    local content = self.elements["Scripts"].content
    
    -- Game selection
    local gameSelectFrame = Create("Frame")({
        Name = "GameSelection",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(0, 200, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = gameSelectFrame
    })
    
    local gameSelectTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Game Selection",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = gameSelectFrame
    })
    
    local gameSelectList = Create("ScrollingFrame")({
        Name = "GameList",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 40),
        CanvasSize = UDim2.new(0, 0, 0, 400),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = THEME[self.theme].ACCENT,
        Parent = gameSelectFrame
    })
    
    local gameListLayout = Create("UIListLayout")({
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = gameSelectList
    })
    
    local games = {
        {name = "Universal", icon = "rbxassetid://11496151831"},
        {name = "RIOTFALL", icon = "rbxassetid://11496151476"},
        {name = "Bad Business", icon = "rbxassetid://11496149140"},
        {name = "Rivals", icon = "rbxassetid://11496151388"},
        {name = "Frontlines", icon = "rbxassetid://11496149730"},
        {name = "Arsenal", icon = "rbxassetid://11496149027"},
        {name = "State of Anarchy", icon = "rbxassetid://11496150739"},
        {name = "Deadline", icon = "rbxassetid://11496149489"}
    }
    
    -- Add game buttons
    for i, game in ipairs(games) do
        local gameBtn = Create("Frame")({
            Name = game.name .. "Button",
            BackgroundColor3 = THEME[self.theme].BACKGROUND,
            Size = UDim2.new(0.9, 0, 0, 40),
            LayoutOrder = i,
            Parent = gameSelectList
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(0, 4),
            Parent = gameBtn
        })
        
        local gameIcon = Create("ImageLabel")({
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = game.icon,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 10, 0.5, -12),
            Parent = gameBtn
        })
        
        local gameName = Create("TextLabel")({
            Name = "Name",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = game.name,
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 44, 0, 0),
            Parent = gameBtn
        })
        
        -- Make button interactive
        gameBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:SelectGame(game.name)
            end
        end)
        
        ApplyRippleEffect(gameBtn, THEME[self.theme].ACCENT_LIGHT)
    end
    
    -- Script options
    local scriptOptionsFrame = Create("Frame")({
        Name = "ScriptOptions",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(1, -230, 1, -20),
        Position = UDim2.new(0, 220, 0, 10),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = scriptOptionsFrame
    })
    
    local scriptOptionsTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Script Options",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = scriptOptionsFrame
    })
    
    -- Options container
    local optionsContainer = Create("ScrollingFrame")({
        Name = "OptionsContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -100),
        Position = UDim2.new(0, 0, 0, 40),
        CanvasSize = UDim2.new(0, 0, 0, 600),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = THEME[self.theme].ACCENT,
        Parent = scriptOptionsFrame
    })
    
    local optionsLayout = Create("UIListLayout")({
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = optionsContainer
    })
    
    -- Execute button
    local executeBtn = Create("TextButton")({
        Name = "ExecuteButton",
        BackgroundColor3 = THEME[self.theme].ACCENT,
        Font = Enum.Font.GothamBold,
        Text = "EXECUTE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Size = UDim2.new(0.7, 0, 0, 40),
        Position = UDim2.new(0.15, 0, 1, -50),
        Parent = scriptOptionsFrame
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = executeBtn
    })
    
    -- Add some sample script options
    for i = 1, 8 do
        local optionSection = Create("Frame")({
            Name = "OptionSection" .. i,
            BackgroundColor3 = THEME[self.theme].BACKGROUND,
            Size = UDim2.new(0.9, 0, 0, 120),
            LayoutOrder = i,
            Parent = optionsContainer
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(0, 4),
            Parent = optionSection
        })
        
        local sectionTitle = Create("TextLabel")({
            Name = "Title",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "Option Category " .. i,
            TextColor3 = THEME[self.theme].ACCENT,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 0),
            Parent = optionSection
        })
        
        -- Add toggles
        for j = 1, 3 do
            local toggle = self:CreateToggle(
                optionSection,
                "Option " .. i .. "." .. j,
                UDim2.new(0.95, 0, 0, 24),
                UDim2.new(0.025, 0, 0, 30 + ((j-1) * 30))
            )
        end
    end
    
    ApplyRippleEffect(executeBtn, Color3.fromRGB(255, 255, 255))
    executeBtn.MouseButton1Click:Connect(function()
        self:ExecuteScript()
    end)
    
    -- Update canvas size
    optionsContainer.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 20)
end

function AnbuLibrary:SelectGame(gameName)
    for _, child in pairs(self.elements["Scripts"].content.GameSelection.GameList:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("Button") then
            child.BackgroundColor3 = THEME[self.theme].BACKGROUND
        end
    end
    
    local selectedBtn = self.elements["Scripts"].content.GameSelection.GameList:FindFirstChild(gameName .. "Button")
    if selectedBtn then
        selectedBtn.BackgroundColor3 = THEME[self.theme].ACCENT
        self:Notify("Game Selected", "Loaded script options for " .. gameName, "info", 3)
        self.statusText.Text = "Selected Game: " .. gameName
    end
end

function AnbuLibrary:ExecuteScript()
    self:Notify("Executing Script", "Executing selected options for the current game...", "success", 3)
    self:AddConsoleMessage("Executing script...", "system")
    wait(0.5)
    self:AddConsoleMessage("Script executed successfully!", "success")
end

function AnbuLibrary:SetupAimbotTab()
    local content = self.elements["Aimbot"].content
    
    -- Aimbot configuration panel
    local configPanel = Create("Frame")({
        Name = "ConfigPanel",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = configPanel
    })
    
    local configTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Aimbot Configuration",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = configPanel
    })
    
    -- Config options
    local configOptions = Create("Frame")({
        Name = "ConfigOptions",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 40),
        Parent = configPanel
    })
    
    -- Toggle aimbot
    local aimbotToggle = self:CreateToggle(
        configOptions,
        "Enable Aimbot",
        UDim2.new(0.9, 0, 0, 30),
        UDim2.new(0.05, 0, 0, 10)
    )
    
    -- Aimbot key selector
    local keyLabel = Create("TextLabel")({
        Name = "KeyLabel",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Aimbot Key:",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.4, 0, 0, 30),
        Position = UDim2.new(0.05, 0, 0, 50),
        Parent = configOptions
    })
    
    local keySelector = Create("TextButton")({
        Name = "KeySelector",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        Font = Enum.Font.Gotham,
        Text = "Mouse Button 2",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        Size = UDim2.new(0.45, 0, 0, 30),
        Position = UDim2.new(0.5, 0, 0, 50),
        Parent = configOptions
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = keySelector
    })
    
    CreateStroke(keySelector, THEME[self.theme].BORDER, 1.5)
    
    -- Sliders
    local sliderLabels = {"Smoothness", "FOV", "Distance", "Prediction"}
    local sliderValues = {50, 100, 1000, 2}
    local sliderMaxValues = {100, 500, 2000, 10}
    
    for i, label in ipairs(sliderLabels) do
        local sliderContainer = Create("Frame")({
            Name = label .. "Container",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0, 40),
            Position = UDim2.new(0.05, 0, 0, 90 + ((i-1) * 50)),
            Parent = configOptions
        })
        
        local sliderLabel = Create("TextLabel")({
            Name = "Label",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = label .. ":",
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = sliderContainer
        })
        
        local sliderTrack = Create("Frame")({
            Name = "Track",
            BackgroundColor3 = THEME[self.theme].BACKGROUND,
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 0, 30),
            Parent = sliderContainer
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = sliderTrack
        })
        
        local sliderFill = Create("Frame")({
            Name = "Fill",
            BackgroundColor3 = THEME[self.theme].ACCENT,
            Size = UDim2.new(sliderValues[i]/sliderMaxValues[i], 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Parent = sliderTrack
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = sliderFill
        })
        
        local sliderThumb = Create("Frame")({
            Name = "Thumb",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(sliderValues[i]/sliderMaxValues[i], -8, 0, -5),
            Parent = sliderTrack
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = sliderThumb
        })
        
        local valueLabel = Create("TextLabel")({
            Name = "Value",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = tostring(sliderValues[i]),
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 0, 0, 0),
            Parent = sliderContainer
        })
        
        -- Enable slider dragging
        local dragging = false
        
        sliderThumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local position = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                sliderFill.Size = UDim2.new(position, 0, 1, 0)
                sliderThumb.Position = UDim2.new(position, -8, 0, -5)
                local value = math.floor(position * sliderMaxValues[i])
                valueLabel.Text = tostring(value)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local position = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                sliderFill.Size = UDim2.new(position, 0, 1, 0)
                sliderThumb.Position = UDim2.new(position, -8, 0, -5)
                local value = math.floor(position * sliderMaxValues[i])
                valueLabel.Text = tostring(value)
            end
        end)
    end
    
    -- Target selection
    local targetSection = Create("Frame")({
        Name = "TargetSection",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0, 30),
        Position = UDim2.new(0.05, 0, 0, 300),
        Parent = configOptions
    })
    
    local targetLabel = Create("TextLabel")({
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Target Selection:",
        TextColor3 = THEME[self.theme].ACCENT,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = targetSection
    })
    
    local targetOptions = {"Head", "Torso", "Closest Part", "Random Part"}
    
    for i, option in ipairs(targetOptions) do
        local targetToggle = self:CreateToggle(
            configOptions,
            option,
            UDim2.new(0.9, 0, 0, 24),
            UDim2.new(0.05, 0, 0, 340 + ((i-1) * 30)),
            i == 1  -- Make Head selected by default
        )
    end
    
    -- Aimbot preview
    local previewPanel = Create("Frame")({
        Name = "PreviewPanel",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(1, -320, 1, -20),
        Position = UDim2.new(0, 320, 0, 10),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = previewPanel
    })
    
    local previewTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Aimbot Preview",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = previewPanel
    })
    
    -- Preview viewport
    local viewport = Create("ViewportFrame")({
        Name = "Viewport",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 50),
        Parent = previewPanel
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = viewport
    })
    
    -- Add a dummy character to the viewport
    local dummy = Create("Part")({
        Name = "Dummy",
        Anchored = true,
        Size = Vector3.new(2, 5, 1),
        Position = Vector3.new(0, 2.5, 0),
        Parent = viewport
    })
    
    local head = Create("Part")({
        Name = "Head",
        Anchored = true,
        Size = Vector3.new(1, 1, 1),
        Position = Vector3.new(0, 5.5, 0),
        Parent = viewport
    })
    
    local camera = Create("Camera")({
        Parent = viewport
    })
    
    viewport.CurrentCamera = camera
    camera.CFrame = CFrame.new(Vector3.new(5, 3, 10), Vector3.new(0, 3, 0))
    
    -- Add FOV circle
    local fovCircle = Create("ImageLabel")({
        Name = "FOVCircle",
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = THEME[self.theme].ACCENT,
        ImageTransparency = 0.7,
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = viewport
    })
    
    -- Add target hitbox
    local hitbox = Create("Frame")({
        Name = "Hitbox",
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0.5, 0, 0.3, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = viewport
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = hitbox
    })
end

function AnbuLibrary:SetupConfigTab()
    local content = self.elements["Config"].content
    
    -- Config list
    local configList = Create("Frame")({
        Name = "ConfigList",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(0, 250, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = configList
    })
    
    local configListTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Saved Configurations",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = configList
    })
    
    local configContainer = Create("ScrollingFrame")({
        Name = "ConfigContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -90),
        Position = UDim2.new(0, 0, 0, 40),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = THEME[self.theme].ACCENT,
        Parent = configList
    })
    
    local configLayout = Create("UIListLayout")({
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = configContainer
    })
    
    -- Add buttons
    local addConfigBtn = Create("TextButton")({
        Name = "AddConfigButton",
        BackgroundColor3 = THEME[self.theme].ACCENT,
        Font = Enum.Font.GothamBold,
        Text = "NEW CONFIG",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Size = UDim2.new(0.9, 0, 0, 36),
        Position = UDim2.new(0.05, 0, 1, -46),
        Parent = configList
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = addConfigBtn
    })
    
    -- Config editor
    local configEditor = Create("Frame")({
        Name = "ConfigEditor",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(1, -270, 1, -20),
        Position = UDim2.new(0, 270, 0, 10),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = configEditor
    })
    
    local configEditorTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Config Editor",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = configEditor
    })
    
    local configNameContainer = Create("Frame")({
        Name = "ConfigNameContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 50),
        Parent = configEditor
    })
    
    local configNameLabel = Create("TextLabel")({
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Config Name:",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.3, 0, 1, 0),
        Parent = configNameContainer
    })
    
    local configNameInput = Create("TextBox")({
        Name = "Input",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        Font = Enum.Font.Gotham,
        PlaceholderText = "Enter config name...",
        Text = "Default",
        TextColor3 = THEME[self.theme].FOREGROUND,
        PlaceholderColor3 = THEME[self.theme].BORDER,
        TextSize = 14,
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0.3, 0, 0, 0),
        ClearTextOnFocus = false,
        Parent = configNameContainer
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = configNameInput
    })
    
    CreateStroke(configNameInput, THEME[self.theme].BORDER, 1.5)
    
    -- Config categories
    local configCategories = {"Aimbot", "ESP", "Movement", "Weapon", "Miscellaneous"}
    local categoryTabsContainer = Create("Frame")({
        Name = "CategoryTabs",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 100),
        Parent = configEditor
    })
    
    local categoryTabs = {}
    for i, category in ipairs(configCategories) do
        local tab = Create("TextButton")({
            Name = category .. "Tab",
            BackgroundColor3 = i == 1 and THEME[self.theme].ACCENT or THEME[self.theme].BACKGROUND,
            Font = Enum.Font.GothamSemibold,
            Text = category,
            TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or THEME[self.theme].FOREGROUND,
            TextSize = 12,
            Size = UDim2.new(1/#configCategories, -4, 1, 0),
            Position = UDim2.new((i-1)/#configCategories, 2, 0, 0),
            Parent = categoryTabsContainer
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(0, 4),
            Parent = tab
        })
        
        categoryTabs[category] = tab
    end
    
    -- Config options container
    local configOptionsContainer = Create("ScrollingFrame")({
        Name = "ConfigOptions",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 1, -190),
        Position = UDim2.new(0, 10, 0, 150),
        CanvasSize = UDim2.new(0, 0, 0, 600),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = THEME[self.theme].ACCENT,
        Parent = configEditor
    })
    
    local optionsLayout = Create("UIListLayout")({
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = configOptionsContainer
    })
    
    -- Add some sample config options
    for i = 1, 8 do
        local optionSection = Create("Frame")({
            Name = "Option" .. i,
            BackgroundColor3 = THEME[self.theme].BACKGROUND,
            Size = UDim2.new(0.95, 0, 0, 60),
            LayoutOrder = i,
            Parent = configOptionsContainer
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(0, 4),
            Parent = optionSection
        })
        
        local optionName = Create("TextLabel")({
            Name = "Name",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = "Option Setting " .. i,
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 0),
            Parent = optionSection
        })
        
        local optionDescription = Create("TextLabel")({
            Name = "Description",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "This is a description for option " .. i,
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextTransparency = 0.5,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.7, 0, 0, 20),
            Position = UDim2.new(0, 10, 0, 30),
            Parent = optionSection
        })
        
        local optionToggle = Create("Frame")({
            Name = "Toggle",
            BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
            Size = UDim2.new(0, 40, 0, 24),
            Position = UDim2.new(1, -50, 0, 18),
            Parent = optionSection
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = optionToggle
        })
        
        local toggleIndicator = Create("Frame")({
            Name = "Indicator",
            BackgroundColor3 = i % 3 == 0 and THEME[self.theme].ACCENT or THEME[self.theme].BORDER,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(i % 3 == 0 and 0.6 or 0.1, 0, 0.5, -8),
            Parent = optionToggle
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = toggleIndicator
        })
        
        -- Make toggle interactive
        optionToggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local isEnabled = toggleIndicator.Position.X.Scale > 0.5
                local targetPos = isEnabled and 0.1 or 0.6
                local targetColor = isEnabled and THEME[self.theme].BORDER or THEME[self.theme].ACCENT
                
                local posTween = TweenService:Create(
                    toggleIndicator,
                    EASING.PREMIUM,
                    {Position = UDim2.new(targetPos, 0, 0.5, -8)}
                )
                
                local colorTween = TweenService:Create(
                    toggleIndicator,
                    EASING.PREMIUM,
                    {BackgroundColor3 = targetColor}
                )
                
                posTween:Play()
                colorTween:Play()
            end
        end)
    end
    
    -- Save/apply buttons
    local saveBtn = Create("TextButton")({
        Name = "SaveButton",
        BackgroundColor3 = THEME[self.theme].ACCENT,
        Font = Enum.Font.GothamBold,
        Text = "SAVE CONFIG",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Size = UDim2.new(0.48, 0, 0, 36),
        Position = UDim2.new(0.01, 0, 1, -46),
        Parent = configEditor
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = saveBtn
    })
    
    local applyBtn = Create("TextButton")({
        Name = "ApplyButton",
        BackgroundColor3 = THEME[self.theme].SUCCESS,
        Font = Enum.Font.GothamBold,
        Text = "APPLY CONFIG",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Size = UDim2.new(0.48, 0, 0, 36),
        Position = UDim2.new(0.51, 0, 1, -46),
        Parent = configEditor
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = applyBtn
    })
    
    -- Add config items
    self:AddConfigItem("Default Config", configContainer, true)
    self:AddConfigItem("Legit Config", configContainer)
    self:AddConfigItem("Rage Config", configContainer)
    
    -- Apply ripple effects
    ApplyRippleEffect(addConfigBtn, Color3.fromRGB(255, 255, 255))
    ApplyRippleEffect(saveBtn, Color3.fromRGB(255, 255, 255))
    ApplyRippleEffect(applyBtn, Color3.fromRGB(255, 255, 255))
    
    -- Update canvas size
    configOptionsContainer.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 20)
    
    -- Add button handlers
    addConfigBtn.MouseButton1Click:Connect(function()
        self:AddConfigItem("New Config " .. os.time() % 1000, configContainer)
        self:Notify("Config Created", "New configuration has been created", "success", 3)
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        self:Notify("Config Saved", "Configuration '" .. configNameInput.Text .. "' has been saved", "success", 3)
        self:AddConsoleMessage("Saved configuration: " .. configNameInput.Text, "system")
    end)
    
    applyBtn.MouseButton1Click:Connect(function()
        self:Notify("Config Applied", "Configuration '" .. configNameInput.Text .. "' has been applied", "info", 3)
        self:AddConsoleMessage("Applied configuration: " .. configNameInput.Text, "system")
    end)
    
    -- Set up category tab switching
    for category, tab in pairs(categoryTabs) do
        tab.MouseButton1Click:Connect(function()
            for c, t in pairs(categoryTabs) do
                t.BackgroundColor3 = THEME[self.theme].BACKGROUND
                t.TextColor3 = THEME[self.theme].FOREGROUND
            end
            
            tab.BackgroundColor3 = THEME[self.theme].ACCENT
            tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
end

function AnbuLibrary:AddConfigItem(name, parent, selected)
    local configItem = Create("Frame")({
        Name = name:gsub(" ", "") .. "Item",
        BackgroundColor3 = selected and THEME[self.theme].ACCENT or THEME[self.theme].BACKGROUND,
        Size = UDim2.new(0.9, 0, 0, 40),
        Parent = parent
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = configItem
    })
    
    local configIcon = Create("ImageLabel")({
        Name = "Icon",
        BackgroundTransparency = 1,
        Image = ASSETS.CONFIG,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        Parent = configItem
    })
    
    local configName = Create("TextLabel")({
        Name = "Name",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = selected and Color3.fromRGB(255, 255, 255) or THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        Parent = configItem
    })
    
    local deleteBtn = Create("ImageButton")({
        Name = "DeleteButton",
        BackgroundTransparency = 1,
        Image = ASSETS.CLOSE,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -26, 0.5, -8),
        Parent = configItem
    })
    
    -- Make item selectable
    configItem.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("Frame") and child.Name:find("Item") then
                    child.BackgroundColor3 = THEME[self.theme].BACKGROUND
                    child.Name.TextColor3 = THEME[self.theme].FOREGROUND
                end
            end
            
            configItem.BackgroundColor3 = THEME[self.theme].ACCENT
            configName.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    
    -- Delete button
    deleteBtn.MouseButton1Click:Connect(function()
        configItem:Destroy()
        self:Notify("Config Deleted", "Configuration '" .. name .. "' has been deleted", "info", 3)
    end)
    
    -- Add ripple effect
    ApplyRippleEffect(configItem, THEME[self.theme].ACCENT_LIGHT)
    
    -- Update canvas size
    local layout = parent:FindFirstChildOfClass("UIListLayout")
    if layout then
        parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
    
    return configItem
end

function AnbuLibrary:SetupSettingsTab()
    local content = self.elements["Settings"].content
    
    -- Main settings
    local mainSettings = Create("Frame")({
        Name = "MainSettings",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(1, -20, 0, 280),
        Position = UDim2.new(0, 10, 0, 10),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = mainSettings
    })
    
    local mainTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "General Settings",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = mainSettings
    })
    
    -- Settings options
    local settingsOptions = {
        {name = "Auto-Save Configs", description = "Automatically save configuration changes"},
        {name = "Save Keybinds", description = "Remember custom keybind settings between sessions"},
        {name = "Performance Mode", description = "Optimize for performance on lower-end devices"},
        {name = "Streamproof Mode", description = "Hide GUI elements from screen capture software"},
        {name = "Anonymous Mode", description = "Don't send telemetry or analytics data"},
        {name = "Multi-Account Support", description = "Support for multiple Roblox accounts"},
        {name = "Auto-Update", description = "Check for updates automatically"}
    }
    
    for i, option in ipairs(settingsOptions) do
        local setting = Create("Frame")({
            Name = option.name:gsub(" ", "") .. "Setting",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 40 + ((i-1) * 34)),
            Parent = mainSettings
        })
        
        local settingName = Create("TextLabel")({
            Name = "Name",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = option.name,
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.6, 0, 0, 20),
            Position = UDim2.new(0, 14, 0, 0),
            Parent = setting
        })
        
        local settingDescription = Create("TextLabel")({
            Name = "Description",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = option.description,
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextTransparency = 0.5,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.6, 0, 0, 20),
            Position = UDim2.new(0, 14, 0, 20),
            Parent = setting
        })
        
        -- Toggle
        self:CreateToggle(
            setting,
            option.name,
            UDim2.new(0, 40, 0, 24),
            UDim2.new(1, -54, 0, 8),
            i % 2 == 0  -- Alternate defaults
        )
    end
    
    -- Key system
    local keySystem = Create("Frame")({
        Name = "KeySystem",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(0, 300, 0, 180),
        Position = UDim2.new(0, 10, 0, 300),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = keySystem
    })
    
    local keyTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "License Information",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = keySystem
    })
    
    local keyIcon = Create("ImageLabel")({
        Name = "KeyIcon",
        BackgroundTransparency = 1,
        Image = ASSETS.KEY,
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0, 20, 0, 60),
        Parent = keySystem
    })
    
    local keyInfo = Create("Frame")({
        Name = "KeyInfo",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 180, 0, 100),
        Position = UDim2.new(0, 100, 0, 50),
        Parent = keySystem
    })
    
    local keyStatus = Create("TextLabel")({
        Name = "Status",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "PREMIUM",
        TextColor3 = THEME[self.theme].SUCCESS,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = keyInfo
    })
    
    local keyExpiry = Create("TextLabel")({
        Name = "Expiry",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Expires: Never",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 25),
        Parent = keyInfo
    })
    
    local keyUser = Create("TextLabel")({
        Name = "User",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "User: " .. Players.LocalPlayer.Name,
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 50),
        Parent = keyInfo
    })
    
    local renewBtn = Create("TextButton")({
        Name = "RenewButton",
        BackgroundColor3 = THEME[self.theme].ACCENT,
        Font = Enum.Font.GothamBold,
        Text = "MANAGE LICENSE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Size = UDim2.new(0, 140, 0, 24),
        Position = UDim2.new(0, 100, 0, 130),
        Parent = keySystem
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = renewBtn
    })
    
    -- About section
    local aboutSection = Create("Frame")({
        Name = "AboutSection",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(0, 300, 0, 180),
        Position = UDim2.new(1, -310, 0, 300),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = aboutSection
    })
    
    local aboutTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "About Anbu.win",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = aboutSection
    })
    
    local aboutLogo = Create("ImageLabel")({
        Name = "Logo",
        BackgroundTransparency = 1,
        Image = ASSETS.LOGO,
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(0.5, -40, 0, 50),
        Parent = aboutSection
    })
    
    local versionText = Create("TextLabel")({
        Name = "Version",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Version 2.5.0",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 140),
        Parent = aboutSection
    })
    
    -- Social media
    local socialContainer = Create("Frame")({
        Name = "SocialContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 24),
        Position = UDim2.new(0.5, -50, 1, -34),
        Parent = aboutSection
    })
    
    local discordBtn = Create("ImageButton")({
        Name = "DiscordButton",
        BackgroundTransparency = 1,
        Image = ASSETS.DISCORD,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = socialContainer
    })
    
    local githubBtn = Create("ImageButton")({
        Name = "GithubButton",
        BackgroundTransparency = 1,
        Image = ASSETS.GITHUB,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, -12, 0, 0),
        Parent = socialContainer
    })
    
    local webBtn = Create("ImageButton")({
        Name = "WebButton",
        BackgroundTransparency = 1,
        Image = ASSETS.INFO,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -24, 0, 0),
        Parent = socialContainer
    })
    
    -- Theme customization
    local themeCustomization = Create("Frame")({
        Name = "ThemeCustomization",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(1, -320, 0, 280),
        Position = UDim2.new(0, 320, 0, 10),
        Parent = content
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = themeCustomization
    })
    
    local themeTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Theme Customization",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = themeCustomization
    })
    
    -- Theme presets
    local presetContainer = Create("Frame")({
        Name = "PresetContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, 50),
        Parent = themeCustomization
    })
    
    local presetLabel = Create("TextLabel")({
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = "Theme Presets:",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = presetContainer
    })
    
    local presetButtons = Create("Frame")({
        Name = "PresetButtons",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 25),
        Parent = presetContainer
    })
    
    local presets = {"Purple", "Blue", "Green", "Red", "Orange"}
    local presetColors = {
        Purple = Color3.fromRGB(130, 80, 245),
        Blue = Color3.fromRGB(0, 122, 255),
        Green = Color3.fromRGB(52, 199, 89),
        Red = Color3.fromRGB(255, 69, 58),
        Orange = Color3.fromRGB(255, 159, 10)
    }
    
    for i, preset in ipairs(presets) do
        local presetBtn = Create("Frame")({
            Name = preset .. "Button",
            BackgroundColor3 = presetColors[preset],
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, (i-1) * 40, 0, 0),
            Parent = presetButtons
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = presetBtn
        })
        
        -- Make button interactive
        presetBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:ApplyColorTheme(presetColors[preset])
            end
        end)
    end
    
    -- Custom sliders
    local colorSlidersContainer = Create("Frame")({
        Name = "ColorSliders",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 160),
        Position = UDim2.new(0, 10, 0, 120),
        Parent = themeCustomization
    })
    
    local colorSliderLabel = Create("TextLabel")({
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = "Custom Colors:",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = colorSlidersContainer
    })
    
    local sliderLabels = {"Red", "Green", "Blue", "Transparency"}
    local sliderColors = {
        Red = Color3.fromRGB(255, 0, 0),
        Green = Color3.fromRGB(0, 255, 0),
        Blue = Color3.fromRGB(0, 0, 255),
        Transparency = Color3.fromRGB(150, 150, 150)
    }
    
    for i, label in ipairs(sliderLabels) do
        local sliderContainer = Create("Frame")({
            Name = label .. "Container",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 25 + ((i-1) * 35)),
            Parent = colorSlidersContainer
        })
        
        local sliderLabel = Create("TextLabel")({
            Name = "Label",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = label .. ":",
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.15, 0, 1, 0),
            Parent = sliderContainer
        })
        
        local sliderTrack = Create("Frame")({
            Name = "Track",
            BackgroundColor3 = THEME[self.theme].BACKGROUND,
            Size = UDim2.new(0.75, 0, 0, 6),
            Position = UDim2.new(0.2, 0, 0.5, -3),
            Parent = sliderContainer
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = sliderTrack
        })
        
        local sliderFill = Create("Frame")({
            Name = "Fill",
            BackgroundColor3 = sliderColors[label],
            Size = UDim2.new(0.5, 0, 1, 0),
            Parent = sliderTrack
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = sliderFill
        })
        
        local sliderThumb = Create("Frame")({
            Name = "Thumb",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            Parent = sliderTrack
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(1, 0),
            Parent = sliderThumb
        })
        
        local valueLabel = Create("TextLabel")({
            Name = "Value",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "127",
            TextColor3 = THEME[self.theme].FOREGROUND,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            Parent = sliderContainer
        })
        
        -- Enable slider dragging
        local dragging = false
        
        sliderThumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local position = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                sliderFill.Size = UDim2.new(position, 0, 1, 0)
                sliderThumb.Position = UDim2.new(position, -8, 0.5, -8)
                local value = math.floor(position * 255)
                valueLabel.Text = tostring(value)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local position = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                sliderFill.Size = UDim2.new(position, 0, 1, 0)
                sliderThumb.Position = UDim2.new(position, -8, 0.5, -8)
                local value = math.floor(position * 255)
                valueLabel.Text = tostring(value)
            end
        end)
    end
    
    -- Apply theme button
    local applyThemeBtn = Create("TextButton")({
        Name = "ApplyThemeButton",
        BackgroundColor3 = THEME[self.theme].ACCENT,
        Font = Enum.Font.GothamBold,
        Text = "APPLY CUSTOM THEME",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Size = UDim2.new(0.8, 0, 0, 36),
        Position = UDim2.new(0.1, 0, 1, -46),
        Parent = themeCustomization
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = applyThemeBtn
    })
    
    -- Add button handlers
    renewBtn.MouseButton1Click:Connect(function()
        self:OpenKeyRedemptionUI()
    end)
    
    applyThemeBtn.MouseButton1Click:Connect(function()
        local r = tonumber(colorSlidersContainer.RedContainer.Value.Text)
        local g = tonumber(colorSlidersContainer.GreenContainer.Value.Text)
        local b = tonumber(colorSlidersContainer.BlueContainer.Value.Text)
        
        if r and g and b then
            self:ApplyColorTheme(Color3.fromRGB(r, g, b))
            self:Notify("Theme Applied", "Custom theme has been applied", "success", 3)
        end
    end)
    
    -- Add ripple effects
    ApplyRippleEffect(renewBtn, Color3.fromRGB(255, 255, 255))
    ApplyRippleEffect(applyThemeBtn, Color3.fromRGB(255, 255, 255))
end

function AnbuLibrary:ApplyColorTheme(color)
    THEME.DARK.ACCENT = color
    THEME.DARK.ACCENT_DARK = Color3.new(
        math.max(0, color.R - 0.12),
        math.max(0, color.G - 0.12),
        math.max(0, color.B - 0.12)
    )
    THEME.DARK.ACCENT_LIGHT = Color3.new(
        math.min(1, color.R + 0.08),
        math.min(1, color.G + 0.08),
        math.min(1, color.B + 0.08)
    )
    
    THEME.LIGHT.ACCENT = color
    THEME.LIGHT.ACCENT_DARK = Color3.new(
        math.max(0, color.R - 0.12),
        math.max(0, color.G - 0.12),
        math.max(0, color.B - 0.12)
    )
    THEME.LIGHT.ACCENT_LIGHT = Color3.new(
        math.min(1, color.R + 0.08),
        math.min(1, color.G + 0.08),
        math.min(1, color.B + 0.08)
    )
    
    -- Apply theme to existing elements
    self:RefreshTheme()
    
    -- Notify the user
    self:Notify("Theme Updated", "Theme colors have been updated", "info", 3)
end

function AnbuLibrary:RefreshTheme()
    -- Update all UI elements with new theme colors
    -- This is called when switching between light/dark mode or changing accent color
    
    -- Update main container
    self.main.BackgroundColor3 = THEME[self.theme].BACKGROUND
    
    -- Update title bar
    self.titleBar.BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY
    self.titleText.TextColor3 = THEME[self.theme].FOREGROUND
    
    -- Update theme toggle
    self.themeToggle.BackgroundColor3 = THEME[self.theme].BACKGROUND
    self.themeIndicator.BackgroundColor3 = THEME[self.theme].ACCENT
    
    -- Update status bar
    self.statusBar.BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY
    self.statusText.TextColor3 = THEME[self.theme].FOREGROUND
    self.timeText.TextColor3 = THEME[self.theme].FOREGROUND
    
    -- Update tab bar
    self.tabBar.BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY
    
    -- Update tabs
    for _, tabData in pairs(self.elements) do
        if tabData.tab then
            if self.currentTab == tabData.tab.Name:sub(1, -4) then
                tabData.tab.BackgroundColor3 = THEME[self.theme].ACCENT
                tabData.name.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                tabData.tab.BackgroundColor3 = THEME[self.theme].BACKGROUND
                tabData.name.TextColor3 = THEME[self.theme].FOREGROUND
            end
        end
    end
    
    -- Update tab content panels
    for _, tabData in pairs(self.elements) do
        if tabData.content then
            for _, child in pairs(tabData.content:GetDescendants()) do
                if child:IsA("Frame") and child.Name:find("Panel") or child.Name:find("Section") or child.Name:find("Container") and not child.Name:find("Toggle") then
                    if child.BackgroundTransparency < 1 then
                        child.BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY
                    end
                elseif child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    if not child:FindFirstAncestor("Toggle") and not child.BackgroundColor3 == THEME[self.theme].ACCENT then
                        child.TextColor3 = THEME[self.theme].FOREGROUND
                    end
                    
                    if child:IsA("TextButton") and child.BackgroundTransparency < 1 and child.BackgroundColor3 ~= THEME[self.theme].ACCENT and child.BackgroundColor3 ~= THEME[self.theme].SUCCESS then
                        child.BackgroundColor3 = THEME[self.theme].BACKGROUND
                    end
                end
            end
        end
    end
    
    -- Update notification frame if it exists
    if self.notificationFrame then
        self.notificationFrame.BackgroundColor3 = THEME[self.theme].BACKGROUND
    end
    
    -- Update console if it exists
    if self.console then
        self.console.Frame.BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY
        self.console.Title.TextColor3 = THEME[self.theme].FOREGROUND
        self.console.Content.BackgroundColor3 = THEME[self.theme].BACKGROUND
    end
    
    -- Update key system if it exists
    if self.keyFrame then
        self.keyFrame.BackgroundColor3 = THEME[self.theme].BACKGROUND
        for _, child in pairs(self.keyFrame:GetDescendants()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = THEME[self.theme].FOREGROUND
            elseif child:IsA("TextBox") then
                child.BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY
                child.TextColor3 = THEME[self.theme].FOREGROUND
            elseif child:IsA("Frame") and child.Name == "Separator" then
                child.BackgroundColor3 = THEME[self.theme].BORDER
            end
        end
    end
end

function AnbuLibrary:ToggleTheme()
    -- Switch between light and dark mode
    self.theme = self.theme == "DARK" and "LIGHT" or "DARK"
    
    -- Update theme indicator position
    local targetPosition = self.theme == "DARK" and UDim2.new(0, 2, 0, 2) or UDim2.new(0, 22, 0, 2)
    local themeTween = TweenService:Create(self.themeIndicator, EASING.PREMIUM, {Position = targetPosition})
    themeTween:Play()
    
    -- Refresh theme colors
    self:RefreshTheme()
    
    -- Notify user
    local themeMessage = self.theme == "DARK" and "Dark mode activated" or "Light mode activated"
    self:Notify("Theme Changed", themeMessage, "info", 3)
end

function AnbuLibrary:CreateToggle(parent, text, size, position, default)
    local toggle = Create("Frame")({
        Name = text:gsub(" ", "") .. "Toggle",
        BackgroundTransparency = 1,
        Size = size,
        Position = position,
        Parent = parent
    })
    
    local toggleLabel = Create("TextLabel")({
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -56, 1, 0),
        Parent = toggle
    })
    
    local toggleBackground = Create("Frame")({
        Name = "Background",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -44, 0.5, -10),
        Parent = toggle
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = toggleBackground
    })
    
    local toggleIndicator = Create("Frame")({
        Name = "Indicator",
        BackgroundColor3 = default and THEME[self.theme].ACCENT or THEME[self.theme].BORDER,
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(0.6, 0, 0.5, -8) or UDim2.new(0.1, 0, 0.5, -8),
        Parent = toggleBackground
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = toggleIndicator
    })
    
    -- Store initial state
    toggle.Value = default or false
    
    -- Make toggle interactive
    toggleBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle.Value = not toggle.Value
            
            local targetPos = toggle.Value and 0.6 or 0.1
            local targetColor = toggle.Value and THEME[self.theme].ACCENT or THEME[self.theme].BORDER
            
            local posTween = TweenService:Create(
                toggleIndicator,
                EASING.PREMIUM,
                {Position = UDim2.new(targetPos, 0, 0.5, -8)}
            )
            
            local colorTween = TweenService:Create(
                toggleIndicator,
                EASING.PREMIUM,
                {BackgroundColor3 = targetColor}
            )
            
            posTween:Play()
            colorTween:Play()
            
            -- Fire event if callback exists
            if self.callbacks[text] then
                self.callbacks[text](toggle.Value)
            end
        end
    end)
    
    -- Register callback function
    function toggle:OnChanged(callback)
        self.Parent.Parent.Parent.Parent.callbacks[text] = callback
        return self
    end
    
    return toggle
end

function AnbuLibrary:CreateNotificationSystem()
    -- Container for all notifications
    self.notificationFrame = Create("Frame")({
        Name = "NotificationFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 280, 1, -40),
        Position = UDim2.new(1, -290, 0, 40),
        Parent = self.gui
    })
    
    -- Layout for notifications
    local notificationLayout = Create("UIListLayout")({
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.notificationFrame
    })
    
    -- Set initial LayoutOrder counter
    self.notificationCount = 0
end

function AnbuLibrary:Notify(title, message, type, duration)
    duration = duration or 5
    type = type or "info" -- info, success, warning, error
    
    -- Increment notification counter
    self.notificationCount = self.notificationCount + 1
    
    -- Create notification
    local notification = Create("Frame")({
        Name = "Notification_" .. self.notificationCount,
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        Size = UDim2.new(1, -20, 0, 80),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(0, 0),
        LayoutOrder = self.notificationCount,
        Parent = self.notificationFrame
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = notification
    })
    
    ApplyShadow(notification, 6, 0.5)
    
    -- Icon based on type
    local iconMap = {
        info = ASSETS.INFO,
        success = ASSETS.SUCCESS,
        warning = ASSETS.WARNING,
        error = ASSETS.ERROR
    }
    
    local colorMap = {
        info = THEME[self.theme].ACCENT,
        success = THEME[self.theme].SUCCESS,
        warning = THEME[self.theme].WARNING,
        error = THEME[self.theme].ERROR
    }
    
    local icon = Create("ImageLabel")({
        Name = "Icon",
        BackgroundTransparency = 1,
        Image = iconMap[type],
        ImageColor3 = colorMap[type],
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 15, 0, 15),
        Parent = notification
    })
    
    -- Color bar
    local colorBar = Create("Frame")({
        Name = "ColorBar",
        BackgroundColor3 = colorMap[type],
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notification
    })
    
    -- Notification title
    local titleLabel = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 55, 0, 15),
        Parent = notification
    })
    
    -- Notification message
    local messageLabel = Create("TextLabel")({
        Name = "Message",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextTransparency = 0.2,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, -70, 0, 30),
        Position = UDim2.new(0, 55, 0, 40),
        Parent = notification
    })
    
    -- Close button
    local closeBtn = Create("ImageButton")({
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Image = ASSETS.CLOSE,
        ImageColor3 = THEME[self.theme].FOREGROUND,
        ImageTransparency = 0.4,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -25, 0, 15),
        Parent = notification
    })
    
    -- Progress bar
    local progressBar = Create("Frame")({
        Name = "ProgressBar",
        BackgroundColor3 = colorMap[type],
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Parent = notification
    })
    
    -- Corner for the progress bar
    Create("UICorner")({
        CornerRadius = UDim.new(0, 2),
        Parent = progressBar
    })
    
    -- Animate notification in
    local inTween = TweenService:Create(
        notification,
        EASING.PREMIUM,
        {Position = UDim2.new(0, 0, 0, 0)}
    )
    
    inTween:Play()
    
    -- Animate progress bar
    local progressTween = TweenService:Create(
        progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )
    
    progressTween:Play()
    
    -- Close notification on click
    closeBtn.MouseButton1Click:Connect(function()
        self:CloseNotification(notification)
    end)
    
    -- Auto close notification after duration
    spawn(function()
        wait(duration)
        self:CloseNotification(notification)
    end)
    
    return notification
end

function AnbuLibrary:CloseNotification(notification)
    -- Ensure notification still exists
    if not notification or not notification.Parent then return end
    
    -- Animate notification out
    local outTween = TweenService:Create(
        notification,
        EASING.PREMIUM,
        {Position = UDim2.new(1, 0, 0, 0), Transparency = 1}
    )
    
    outTween:Play()
    
    outTween.Completed:Connect(function()
        notification:Destroy()
    end)
end

function AnbuLibrary:CreateConsole()
    -- Create console frame
    self.console = {}
    self.console.Frame = Create("Frame")({
        Name = "Console",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 500, 0, 300),
        Position = UDim2.new(0.5, -250, 0.5, -150),
        Visible = false,
        Parent = self.gui
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = self.console.Frame
    })
    
    ApplyShadow(self.console.Frame, 10, 0.5)
    
    -- Console title bar
    self.console.TitleBar = Create("Frame")({
        Name = "TitleBar",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.console.Frame
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = self.console.TitleBar
    })
    
    -- Title
    self.console.Title = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Anbu Console",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = self.console.TitleBar
    })
    
    -- Close button
    self.console.CloseBtn = Create("ImageButton")({
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Image = ASSETS.CLOSE,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -23, 0.5, -8),
        Parent = self.console.TitleBar
    })
    
    -- Console content
    self.console.Content = Create("ScrollingFrame")({
        Name = "Content",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 1, -70),
        Position = UDim2.new(0, 10, 0, 40),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarImageColor3 = THEME[self.theme].ACCENT,
        Parent = self.console.Frame
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = self.console.Content
    })
    
    -- Message layout
    self.console.Layout = Create("UIListLayout")({
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = self.console.Content
    })
    
    -- Console input
    self.console.Input = Create("Frame")({
        Name = "Input",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 1, -40),
        Parent = self.console.Frame
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = self.console.Input
    })
    
    -- Input box
    self.console.InputBox = Create("TextBox")({
        Name = "InputBox",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        PlaceholderText = "Type a command...",
        Text = "",
        TextColor3 = THEME[self.theme].FOREGROUND,
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = self.console.Input
    })
    
    -- Make console draggable
    self:MakeDraggable(self.console.Frame, self.console.TitleBar)
    
    -- Close console on button click
    self.console.CloseBtn.MouseButton1Click:Connect(function()
        self:ToggleConsole(false)
    end)
    
    -- Submit command on enter
    self.console.InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local command = self.console.InputBox.Text
            self:ProcessConsoleCommand(command)
            self.console.InputBox.Text = ""
        end
    end)
    
    -- Auto-scroll to bottom when new message added
    self.console.Content:GetPropertyChangedSignal("CanvasSize"):Connect(function()
        self.console.Content.CanvasPosition = Vector2.new(0, self.console.Content.CanvasSize.Y.Offset)
    end)
    
    -- Console message counter
    self.console.messageCount = 0
end

function AnbuLibrary:ToggleConsole(visible)
    if visible == nil then
        visible = not self.console.Frame.Visible
    end
    
    self.console.Frame.Visible = visible
    
    if visible then
        self.console.InputBox:CaptureFocus()
    end
end

function AnbuLibrary:AddConsoleMessage(message, messageType)
    -- Increment message counter
    self.console.messageCount = self.console.messageCount + 1
    
    -- Default message type
    messageType = messageType or "info"
    
    -- Color mapping
    local colorMap = {
        system = Color3.fromRGB(200, 200, 200),
        info = THEME[self.theme].ACCENT,
        success = THEME[self.theme].SUCCESS,
        warning = THEME[self.theme].WARNING,
        error = THEME[self.theme].ERROR,
        command = Color3.fromRGB(255, 255, 255)
    }
    
    -- Prefix mapping
    local prefixMap = {
        system = "[System]",
        info = "[Info]",
        success = "[Success]",
        warning = "[Warning]",
        error = "[Error]",
        command = ">"
    }
    
    -- Create message container
    local messageContainer = Create("Frame")({
        Name = "Message_" .. self.console.messageCount,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        LayoutOrder = self.console.messageCount,
        Parent = self.console.Content
    })
    
    -- Create timestamp
    local timestamp = Create("TextLabel")({
        Name = "Timestamp",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = os.date("%H:%M:%S"),
        TextColor3 = Color3.fromRGB(120, 120, 120),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 60, 1, 0),
        Parent = messageContainer
    })
    
    -- Create prefix
    local prefix = Create("TextLabel")({
        Name = "Prefix",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = prefixMap[messageType],
        TextColor3 = colorMap[messageType],
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0, 70, 1, 0),
        Position = UDim2.new(0, 70, 0, 0),
        Parent = messageContainer
    })
    
    -- Create message text
    local messageText = Create("TextLabel")({
        Name = "Text",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        Parent = messageContainer
    })
    
    -- Resize if message is long
    local textHeight = messageText.TextBounds.Y
    if textHeight > 20 then
        messageContainer.Size = UDim2.new(1, 0, 0, textHeight + 5)
        messageText.Size = UDim2.new(1, -150, 0, textHeight)
    end
    
    -- Scroll to bottom
    self.console.Content.CanvasPosition = Vector2.new(0, self.console.Content.CanvasSize.Y.Offset)
end

function AnbuLibrary:ProcessConsoleCommand(command)
    -- Add command to console history
    self:AddConsoleMessage(command, "command")
    
    -- Process command
    local args = {}
    for arg in command:gmatch("%S+") do
        table.insert(args, arg)
    end
    
    local baseCommand = args[1]:lower()
    
    if baseCommand == "clear" then
        -- Clear console
        for _, child in pairs(self.console.Content:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        self.console.messageCount = 0
        self:AddConsoleMessage("Console cleared", "system")
    elseif baseCommand == "help" then
        -- Show help
        self:AddConsoleMessage("Available commands:", "system")
        self:AddConsoleMessage("clear - Clear the console", "info")
        self:AddConsoleMessage("help - Show this help message", "info")
        self:AddConsoleMessage("theme [dark/light] - Switch theme", "info")
        self:AddConsoleMessage("execute [script] - Execute a script", "info")
        self:AddConsoleMessage("exit - Close the console", "info")
    elseif baseCommand == "theme" then
        if args[2] then
            if args[2]:lower() == "dark" then
                self.theme = "DARK"
                self:RefreshTheme()
                self:AddConsoleMessage("Switched to dark theme", "success")
            elseif args[2]:lower() == "light" then
                self.theme = "LIGHT"
                self:RefreshTheme()
                self:AddConsoleMessage("Switched to light theme", "success")
            else
                self:AddConsoleMessage("Invalid theme. Use 'dark' or 'light'", "error")
            end
        else
            self:AddConsoleMessage("Current theme: " .. self.theme:lower(), "info")
        end
    elseif baseCommand == "execute" then
        if args[2] then
            self:AddConsoleMessage("Executing script: " .. args[2], "system")
            self:AddConsoleMessage("Script executed successfully", "success")
        else
            self:AddConsoleMessage("Please specify a script to execute", "error")
        end
    elseif baseCommand == "exit" then
        self:ToggleConsole(false)
    else
        self:AddConsoleMessage("Unknown command: " .. baseCommand, "error")
    end
end

function AnbuLibrary:SetupKeySystem()
    -- Create key redemption frame
    self.keyFrame = Create("Frame")({
        Name = "KeyFrame",
        BackgroundColor3 = THEME[self.theme].BACKGROUND,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        Visible = false,
        Parent = self.gui
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 8),
        Parent = self.keyFrame
    })
    
    ApplyShadow(self.keyFrame, 15, 0.5)
    
    -- Key title
    local keyTitle = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Anbu.win License Key",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 20,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 20),
        Parent = self.keyFrame
    })
    
    -- Key icon
    local keyIcon = Create("ImageLabel")({
        Name = "KeyIcon",
        BackgroundTransparency = 1,
        Image = ASSETS.KEY,
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(0.5, -40, 0, 60),
        Parent = self.keyFrame
    })
    
    -- Key input label
    local keyInputLabel = Create("TextLabel")({
        Name = "InputLabel",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Enter your license key:",
        TextColor3 = THEME[self.theme].FOREGROUND,
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 150),
        Parent = self.keyFrame
    })
    
    -- Key input
    local keyInput = Create("TextBox")({
        Name = "KeyInput",
        BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY,
        Font = Enum.Font.Code,
        PlaceholderText = "XXXX-XXXX-XXXX-XXXX",
        Text = "",
        TextColor3 = THEME[self.theme].FOREGROUND,
        PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
        TextSize = 16,
        ClearTextOnFocus = false,
        Size = UDim2.new(0.8, 0, 0, 40),
        Position = UDim2.new(0.1, 0, 0, 180),
        Parent = self.keyFrame
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = keyInput
    })
    
    CreateStroke(keyInput, THEME[self.theme].BORDER, 1.5)
    
    -- Redeem button
    local redeemBtn = Create("TextButton")({
        Name = "RedeemButton",
        BackgroundColor3 = THEME[self.theme].ACCENT,
        Font = Enum.Font.GothamBold,
        Text = "REDEEM KEY",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Size = UDim2.new(0.8, 0, 0, 40),
        Position = UDim2.new(0.1, 0, 0, 240),
        Parent = self.keyFrame
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = redeemBtn
    })
    
    -- Close button
    local closeBtn = Create("ImageButton")({
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Image = ASSETS.CLOSE,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -30, 0, 20),
        Parent = self.keyFrame
    })
    
    -- Make key frame draggable
    self:MakeDraggable(self.keyFrame)
    
    -- Button functionality
    redeemBtn.MouseButton1Click:Connect(function()
        self:RedeemKey(keyInput.Text)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:ToggleKeyUI(false)
    end)
    
    -- Add ripple effect
    ApplyRippleEffect(redeemBtn, Color3.fromRGB(255, 255, 255))
end

function AnbuLibrary:OpenKeyRedemptionUI()
    self:ToggleKeyUI(true)
end

function AnbuLibrary:ToggleKeyUI(visible)
    self.keyFrame.Visible = visible
    
    if visible then
        -- Animate in
        self.keyFrame.Position = UDim2.new(0.5, -200, 0.3, -150)
        self.keyFrame.BackgroundTransparency = 1
        
        local posTween = TweenService:Create(
            self.keyFrame,
            EASING.PREMIUM,
            {Position = UDim2.new(0.5, -200, 0.5, -150), BackgroundTransparency = 0}
        )
        
        posTween:Play()
        
        -- Focus input
        self.keyFrame.KeyInput:CaptureFocus()
    end
end

function AnbuLibrary:RedeemKey(key)
    if key and key:len() > 0 then
        -- Simulate key verification
        wait(1)
        
        if key:upper() == "ANBU-PREMIUM" then
            self:Notify("Key Verified", "Premium license activated successfully", "success", 5)
            self:AddConsoleMessage("Premium license activated: " .. key, "success")
            self:ToggleKeyUI(false)
        else
            self:Notify("Invalid Key", "The license key you entered is invalid", "error", 5)
            self:AddConsoleMessage("Invalid license key: " .. key, "error")
            
            -- Shake animation for invalid key
            for i = 1, 5 do
                local offset = i % 2 == 0 and 5 or -5
                local keyShake = TweenService:Create(
                    self.keyFrame.KeyInput,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {Position = UDim2.new(0.1, offset, 0, 180)}
                )
                keyShake:Play()
                wait(0.1)
            end
            
            -- Reset position
            local resetPos = TweenService:Create(
                self.keyFrame.KeyInput,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.1, 0, 0, 180)}
            )
            resetPos:Play()
        end
    else
        self:Notify("Empty Key", "Please enter a license key", "warning", 3)
    end
end

function AnbuLibrary:LoadConfigs()
    -- Create config folder if it doesn't exist
    pcall(function()
        if not isfolder(self.configFolder) then
            makefolder(self.configFolder)
            self:SaveConfig(self.defaultConfig) -- Save default config
            self:AddConsoleMessage("Created config folder: " .. self.configFolder, "system")
        end
    end)
    
    -- Try to load default config
    pcall(function()
        self:LoadConfig(self.defaultConfig)
    end)
end

function AnbuLibrary:SaveConfig(configName)
    -- Collect all settings from the UI
    local config = {
        theme = self.theme,
        tabs = {},
        settings = {}
    }
    
    -- Add window position and size
    config.position = {
        X = self.main.Position.X.Offset,
        Y = self.main.Position.Y.Offset
    }
    
    config.size = {
        X = self.main.Size.X.Offset,
        Y = self.main.Size.Y.Offset
    }
    
    -- Collect toggle states
    for _, tabData in pairs(self.elements) do
        if tabData.content then
            config.tabs[tabData.tab.Name:sub(1, -4)] = {
                toggles = {}
            }
            
            for _, child in pairs(tabData.content:GetDescendants()) do
                if child:IsA("Frame") and child.Name:find("Toggle") then
                    local toggleName = child.Name:sub(1, -7)
                    config.tabs[tabData.tab.Name:sub(1, -4)].toggles[toggleName] = child.Value
                end
            end
        end
    end
    
    -- General settings
    for _, child in pairs(self.elements["Settings"].content.MainSettings:GetDescendants()) do
        if child:IsA("Frame") and child.Name:find("Setting") then
            local settingName = child.Name:sub(1, -8)
            
            -- Find toggle in the setting
            for _, toggle in pairs(child:GetDescendants()) do
                if toggle:IsA("Frame") and toggle.Name:find("Toggle") then
                    config.settings[settingName] = toggle.Value
                    break
                end
            end
        end
    end
    
    -- Save config to file
    pcall(function()
        writefile(self.configFolder .. "/" .. configName .. ".json", HttpService:JSONEncode(config))
        self:AddConsoleMessage("Config saved: " .. configName, "success")
    end)
    
    return config
end

function AnbuLibrary:LoadConfig(configName)
    local success, config = pcall(function()
        return HttpService:JSONDecode(readfile(self.configFolder .. "/" .. configName .. ".json"))
    end)
    
    if success and config then
        -- Apply theme
        if config.theme then
            self.theme = config.theme
            self:RefreshTheme()
        end
        
        -- Apply position and size if available
        if config.position and config.size then
            self.main.Position = UDim2.new(0, config.position.X, 0, config.position.Y)
            self.main.Size = UDim2.new(0, config.size.X, 0, config.size.Y)
        end
        
        -- Apply toggle states
        for tabName, tabData in pairs(config.tabs) do
            if self.elements[tabName] and tabData.toggles then
                for toggleName, toggleValue in pairs(tabData.toggles) do
                    for _, child in pairs(self.elements[tabName].content:GetDescendants()) do
                        if child:IsA("Frame") and child.Name == toggleName .. "Toggle" then
                            -- Update toggle visual and value
                            child.Value = toggleValue
                            
                            local toggleIndicator = child.Background.Indicator
                            local targetPos = toggleValue and 0.6 or 0.1
                            local targetColor = toggleValue and THEME[self.theme].ACCENT or THEME[self.theme].BORDER
                            
                            toggleIndicator.Position = UDim2.new(targetPos, 0, 0.5, -8)
                            toggleIndicator.BackgroundColor3 = targetColor
                            
                            -- Fire callback if exists
                            if self.callbacks[toggleName] then
                                self.callbacks[toggleName](toggleValue)
                            end
                            
                            break
                        end
                    end
                end
            end
        end
        
        -- Apply settings
        for settingName, settingValue in pairs(config.settings) do
            for _, child in pairs(self.elements["Settings"].content.MainSettings:GetDescendants()) do
                if child:IsA("Frame") and child.Name == settingName .. "Setting" then
                    -- Find toggle in the setting
                    for _, toggle in pairs(child:GetDescendants()) do
                        if toggle:IsA("Frame") and toggle.Name:find("Toggle") then
                            -- Update toggle visual and value
                            toggle.Value = settingValue
                            
                            local toggleIndicator = toggle.Background.Indicator
                            local targetPos = settingValue and 0.6 or 0.1
                            local targetColor = settingValue and THEME[self.theme].ACCENT or THEME[self.theme].BORDER
                            
                            toggleIndicator.Position = UDim2.new(targetPos, 0, 0.5, -8)
                            toggleIndicator.BackgroundColor3 = targetColor
                            
                            break
                        end
                    end
                    
                    break
                end
            end
        end
        
        self:AddConsoleMessage("Config loaded: " .. configName, "success")
        return true
    else
        self:AddConsoleMessage("Failed to load config: " .. configName, "error")
        return false
    end
end

function AnbuLibrary:SetupDragging()
    -- Enable dragging of the main window
    self:MakeDraggable(self.main, self.titleBar)
end

function AnbuLibrary:MakeDraggable(frame, handle)
    handle = handle or frame
    
    local dragStart, startPos
    local dragging = false
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Highlight titlebar during drag
            if handle ~= frame and handle:IsA("Frame") then
                handle.BackgroundColor3 = THEME[self.theme].ACCENT_DARK
            end
            
            -- Prevent input from propagating to other elements
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    
                    -- Reset titlebar color
                    if handle ~= frame and handle:IsA("Frame") then
                        handle.BackgroundColor3 = THEME[self.theme].BACKGROUND_SECONDARY
                    end
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function AnbuLibrary:SetupResizing()
    -- Enable resizing of the main window
    local minSize = Vector2.new(600, 400)
    local maxSize = Vector2.new(1200, 800)
    
    self.resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.resizing = true
            self.dragStart = input.Position
            self.startSize = self.main.Size
            
            -- Highlight resizeHandle during resize
            self.resizeIcon.ImageColor3 = THEME[self.theme].ACCENT
            
            -- Prevent input from propagating to other elements
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.resizing = false
                    self.resizeIcon.ImageColor3 = THEME[self.theme].FOREGROUND
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.dragStart
            local newWidth = math.clamp(self.startSize.X.Offset + delta.X, minSize.X, maxSize.X)
            local newHeight = math.clamp(self.startSize.Y.Offset + delta.Y, minSize.Y, maxSize.Y)
            
            self.main.Size = UDim2.new(0, newWidth, 0, newHeight)
            
            -- Update layout for responsive UI elements
            self:UpdateLayout()
        end
    end)
end

function AnbuLibrary:UpdateLayout()
    -- Update layout for tab container
    self.tabContainer.CanvasSize = UDim2.new(0, self.tabLayout.AbsoluteContentSize.X, 0, 0)
    
    -- Update any other dynamic layouts
    for _, tabData in pairs(self.elements) do
        if tabData.content then
            for _, child in pairs(tabData.content:GetDescendants()) do
                if child:IsA("UIListLayout") then
                    local parent = child.Parent
                    if parent:IsA("ScrollingFrame") then
                        parent.CanvasSize = UDim2.new(0, 0, 0, child.AbsoluteContentSize.Y + 20)
                    end
                end
            end
        end
    end
end

function AnbuLibrary:RegisterHotkeys()
    -- Register global hotkeys
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Ctrl+C to toggle console
            if input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                self:ToggleConsole()
            end
            
            -- Escape to close console and key UI
            if input.KeyCode == Enum.KeyCode.Escape then
                if self.console.Frame.Visible then
                    self:ToggleConsole(false)
                end
                
                if self.keyFrame and self.keyFrame.Visible then
                    self:ToggleKeyUI(false)
                end
            end
        end
    end)
end

function AnbuLibrary:Close()
    -- Save config before closing
    self:SaveConfig(self.defaultConfig)
    
    -- Animate closing
    local closeTween = TweenService:Create(
        self.main,
        EASING.PREMIUM,
        {Size = UDim2.new(0, self.main.Size.X.Offset, 0, 0), Position = UDim2.new(self.main.Position.X.Scale, self.main.Position.X.Offset, self.main.Position.Y.Scale, self.main.Position.Y.Offset + (self.main.Size.Y.Offset/2))}
    )
    
    closeTween:Play()
    
    closeTween.Completed:Connect(function()
        self.gui:Destroy()
    end)
end

function AnbuLibrary:Minimize()
    if self.minimized then
        -- Restore
        local restoreTween = TweenService:Create(
            self.main,
            EASING.PREMIUM,
            {Size = self.originalSize}
        )
        
        restoreTween:Play()
        self.minimized = false
    else
        -- Minimize
        self.originalSize = self.main.Size
        
        local minimizeTween = TweenService:Create(
            self.main,
            EASING.PREMIUM,
            {Size = UDim2.new(0, self.main.Size.X.Offset, 0, 36)}
        )
        
        minimizeTween:Play()
        self.minimized = true
    end
end