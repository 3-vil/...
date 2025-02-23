local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local Utility = { DefaultLighting = {} }

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local Request = request or (http and http.request)
local SetIdentity = setthreadidentity

do -- PluginManager hook
    local OldPluginManager, Message = nil, nil

    task.spawn(function()
        SetIdentity(2)
        local Success, Error = pcall(getrenv().PluginManager)
        Message = Error
    end)

    OldPluginManager = hookfunction(getrenv().PluginManager, function()
        return error(Message)
    end)
end

repeat task.wait() until Stats.Network:FindFirstChild("ServerStatsItem")
local Ping = Stats.Network.ServerStatsItem["Data Ping"]

repeat task.wait() until Workspace:FindFirstChildOfClass("Terrain")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local XZVector, YVector = Vector3.new(1, 0, 1), Vector3.new(0, 1, 0)
local Movement = { Forward = 0, Backward = 0, Right = 0, Left = 0, Up = 0, Down = 0 }
local function GetFlatVector(CF) return CF.LookVector * XZVector, CF.RightVector * XZVector end
local function GetUnit(Vector) if Vector.Magnitude == 0 then return Vector end return Vector.Unit end

local function MovementBind(ActionName, InputState)
    Movement[ActionName] = InputState == Enum.UserInputState.Begin and 1 or 0
    return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("Forward", MovementBind, false, Enum.KeyCode.W)
ContextActionService:BindAction("Backward", MovementBind, false, Enum.KeyCode.S)
ContextActionService:BindAction("Left", MovementBind, false, Enum.KeyCode.A)
ContextActionService:BindAction("Right", MovementBind, false, Enum.KeyCode.D)
ContextActionService:BindAction("Up", MovementBind, false, Enum.KeyCode.Space)
ContextActionService:BindAction("Down", MovementBind, false, Enum.KeyCode.LeftShift)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

function Utility.SetupFPS()
    local StartTime, TimeTable, LastTime = os.clock(), {}, nil
    return function()
        LastTime = os.clock()
        for Index = #TimeTable, 1, -1 do
            TimeTable[Index + 1] = TimeTable[Index] >= LastTime - 1 and TimeTable[Index] or nil
        end
        TimeTable[1] = LastTime
        return os.clock() - StartTime >= 1 and #TimeTable or #TimeTable / (os.clock() - StartTime)
    end
end

function Utility.MovementToDirection()
    local LookVector, RightVector = GetFlatVector(Camera.CFrame)
    local ZMovement = LookVector * (Movement.Forward - Movement.Backward)
    local XMovement = RightVector * (Movement.Right - Movement.Left)
    local YMovement = YVector * (Movement.Up - Movement.Down)
    return GetUnit(ZMovement + XMovement + YMovement)
end

function Utility.MakeBeam(Origin, Position, Color)
    local OriginAttachment = Instance.new("Attachment")
    OriginAttachment.CFrame = CFrame.new(Origin)
    OriginAttachment.Name = "OriginAttachment"
    OriginAttachment.Parent = Terrain

    local PositionAttachment = Instance.new("Attachment")
    PositionAttachment.CFrame = CFrame.new(Position)
    PositionAttachment.Name = "PositionAttachment"
    PositionAttachment.Parent = Terrain

    local Beam = Instance.new("Beam")
    Beam.Name = "Beam"
    Beam.Color = ColorSequence.new(Color[6])
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Transparency = NumberSequence.new(0)
    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = 0.1
    Beam.Width1 = 0.1
    Beam.Parent = Terrain

    task.spawn(function()
        local Time = 1 * 60
        for Index = 1, Time do
            RunService.Heartbeat:Wait()
            Beam.Transparency = NumberSequence.new(Index / Time)
            Beam.Color = ColorSequence.new(Color[6])
        end
        OriginAttachment:Destroy()
        PositionAttachment:Destroy()
        Beam:Destroy()
    end)

    return Beam
end

function Utility.NewThreadLoop(Wait, Function)
    task.spawn(function()
        while true do
            local Delta = task.wait(Wait)
            local Success, Error = pcall(Function, Delta)
            if not Success then
                warn("thread error " .. Error)
            elseif Error == "break" then
                break
            end
        end
    end)
end

function Utility.FixUpValue(fn, hook, gvar)
    if gvar then
        old = hookfunction(fn, function(...)
            return hook(old, ...)
        end)
    else
        local old = nil
        old = hookfunction(fn, function(...)
            return hook(old, ...)
        end)
    end
end

function Utility.ReJoin()
    if #PlayerService:GetPlayers() <= 1 then
        LocalPlayer:Kick("\nAnbu.win\nRejoining...")
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
end

function Utility.ServerHop()
    local DataDecoded, Servers = HttpService:JSONDecode(game:HttpGet(
        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=2&excludeFullGames=true&limit=100"
    )).data, {}

    for Index, ServerData in ipairs(DataDecoded) do
        if type(ServerData) == "table" and ServerData.id ~= game.JobId then
            table.insert(Servers, ServerData.id)
        end
    end

    if #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Servers[math.random(#Servers)])
    else
        Bracket:Push({
            Title = "Anbu.win",
            Description = "Couldn't find a server",
            Duration = 5
        })
    end
end

function Utility.JoinDiscord()
    Request({
        ["Url"] = "http://localhost:6463/rpc?v=1",
        ["Method"] = "POST",
        ["Headers"] = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        ["Body"] = HttpService:JSONEncode({
            ["cmd"] = "INVITE_BROWSER",
            ["nonce"] = string.lower(HttpService:GenerateGUID(false)),
            ["args"] = {
                ["code"] = "sYqDpbPYb7"
            }
        })
    })
end

function Utility.InitAutoLoad(Window)
    Window:AutoLoadConfig("Parvus")
    Window:SetValue("UI/Enabled", true) -- Autoload enabled by default
end

function Utility.SetupWatermark(Self, Window)
    local GetFPS = Self:SetupFPS()

    RunService.Heartbeat:Connect(function()
        if Window.Watermark.Enabled then
            Window.Watermark.Title = string.format(
                "Anbu.win    %s    %i FPS    %i MS",
                os.date("%X"), GetFPS(), math.round(Ping:GetValue())
            )
        end
    end)
end

function Utility.SettingsSection(Self, Window, UIKeybind, CustomMouse)
    local MenuSection = Window:Section({Name = "Menu", Side = "Left"}) do
        local UIToggle = MenuSection:Toggle({
            Name = "UI Enabled",
            Flag = "UI/Enabled",
            IgnoreFlag = true,
            Value = true, -- Default to true for autoload
            Callback = function(Bool)
                Window.Enabled = Bool
            end
        })
        UIToggle:Keybind({
            Value = Enum.KeyCode.Insert, -- Default to Insert
            Flag = "UI/Keybind",
            IgnoreList = true,
            DoNotClear = true
        })
    end

    Window:KeybindList({Enabled = false})
    Window:Watermark({Enabled = false})
end

function Utility.ESPSection(Self, Window, Name, Flag, BoxEnabled, ChamEnabled, HeadEnabled, TracerEnabled, OoVEnabled, LightingEnabled)
    local VisualsTab = Window:Tab({Name = Name}) do
        local GlobalSection = VisualsTab:Section({Name = "Global", Side = "Left"})
        if BoxEnabled then
            local BoxSection = VisualsTab:Section({Name = "Boxes", Side = "Left"}) do
                BoxSection:Toggle({Name = "Box Enabled", Flag = Flag .. "/Box/Enabled", Value = false})
                BoxSection:Toggle({Name = "Healthbar", Flag = Flag .. "/Box/HealthBar", Value = false})
                BoxSection:Toggle({Name = "Filled", Flag = Flag .. "/Box/Filled", Value = false})
                BoxSection:Toggle({Name = "Outline", Flag = Flag .. "/Box/Outline", Value = true})
                BoxSection:Slider({Name = "Thickness", Flag = Flag .. "/Box/Thickness", Min = 1, Max = 19, Value = 1, OnlyOdd = true})
                BoxSection:Slider({Name = "Transparency", Flag = Flag .. "/Box/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
                BoxSection:Slider({Name = "Corner Size", Flag = Flag .. "/Box/CornerSize", Min = 10, Max = 100, Value = 50, Unit = "%"})
                BoxSection:Divider()
                BoxSection:Toggle({Name = "Name Enabled", Flag = Flag .. "/Name/Enabled", Value = false})
                BoxSection:Toggle({Name = "Health Enabled", Flag = Flag .. "/Health/Enabled", Value = false})
                BoxSection:Toggle({Name = "Distance Enabled", Flag = Flag .. "/Distance/Enabled", Value = false})
                BoxSection:Toggle({Name = "Weapon Enabled", Flag = Flag .. "/Weapon/Enabled", Value = false})
                BoxSection:Toggle({Name = "Outline", Flag = Flag .. "/Name/Outline", Value = true})
                BoxSection:Toggle({Name = "Autoscale", Flag = Flag .. "/Name/Autoscale", Value = true})
                BoxSection:Slider({Name = "Size", Flag = Flag .. "/Name/Size", Min = 1, Max = 100, Value = 8})
                BoxSection:Slider({Name = "Transparency", Flag = Flag .. "/Name/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0.25})
            end
        end
        if HeadEnabled then
            local HeadSection = VisualsTab:Section({Name = "Head Dots", Side = "Right"}) do
                HeadSection:Toggle({Name = "Enabled", Flag = Flag .. "/HeadDot/Enabled", Value = false})
                HeadSection:Toggle({Name = "Filled", Flag = Flag .. "/HeadDot/Filled", Value = true})
                HeadSection:Toggle({Name = "Outline", Flag = Flag .. "/HeadDot/Outline", Value = true})
                HeadSection:Toggle({Name = "Autoscale", Flag = Flag .. "/HeadDot/Autoscale", Value = true})
                HeadSection:Slider({Name = "Size", Flag = Flag .. "/HeadDot/Radius", Min = 1, Max = 100, Value = 4})
                HeadSection:Slider({Name = "NumSides", Flag = Flag .. "/HeadDot/NumSides", Min = 3, Max = 100, Value = 4})
                HeadSection:Slider({Name = "Thickness", Flag = Flag .. "/HeadDot/Thickness", Min = 1, Max = 10, Value = 1})
                HeadSection:Slider({Name = "Transparency", Flag = Flag .. "/HeadDot/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
            end
        end
        if TracerEnabled then
            local TracerSection = VisualsTab:Section({Name = "Tracers", Side = "Right"}) do
                TracerSection:Toggle({Name = "Enabled", Flag = Flag .. "/Tracer/Enabled", Value = false})
                TracerSection:Toggle({Name = "Outline", Flag = Flag .. "/Tracer/Outline", Value = true})
                TracerSection:Dropdown({Name = "Mode", Flag = Flag .. "/Tracer/Mode", List = {
                    {Name = "From Bottom", Mode = "Button", Value = true},
                    {Name = "From Mouse", Mode = "Button"}
                }})
                TracerSection:Slider({Name = "Thickness", Flag = Flag .. "/Tracer/Thickness", Min = 1, Max = 10, Value = 1})
                TracerSection:Slider({Name = "Transparency", Flag = Flag .. "/Tracer/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
            end
        end
        if OoVEnabled then
            local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows", Side = "Right"}) do
                OoVSection:Toggle({Name = "Enabled", Flag = Flag .. "/Arrow/Enabled", Value = false})
                OoVSection:Toggle({Name = "Filled", Flag = Flag .. "/Arrow/Filled", Value = true})
                OoVSection:Toggle({Name = "Outline", Flag = Flag .. "/Arrow/Outline", Value = true})
                OoVSection:Slider({Name = "Width", Flag = Flag .. "/Arrow/Width", Min = 14, Max = 28, Value = 14})
                OoVSection:Slider({Name = "Height", Flag = Flag .. "/Arrow/Height", Min = 14, Max = 28, Value = 28})
                OoVSection:Slider({Name = "Distance From Center", Flag = Flag .. "/Arrow/Radius", Min = 80, Max = 200, Value = 150})
                OoVSection:Slider({Name = "Thickness", Flag = Flag .. "/Arrow/Thickness", Min = 1, Max = 10, Value = 1})
                OoVSection:Slider({Name = "Transparency", Flag = Flag .. "/Arrow/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
            end
        end
        if LightingEnabled then
            Self:LightingSection(VisualsTab)
        end

        return GlobalSection
    end
end

function Utility.LightingSection(Self, Tab, Side)
    local LightingSection = Tab:Section({Name = "Lighting", Side = Side or "Right"}) do
        LightingSection:Toggle({Name = "Enabled", Flag = "Lighting/Enabled", Value = false,
            Callback = function(Bool) if not Bool then
                for Property, Value in pairs(Self.DefaultLighting) do
                    Lighting[Property] = Value
                end
            end
        end})
        LightingSection:Colorpicker({Name = "Ambient", Flag = "Lighting/Ambient", Value = {1, 0, 1, 0, false}})
        LightingSection:Slider({Name = "Brightness", Flag = "Lighting/Brightness", Min = 0, Max = 10, Precise = 2, Value = 3})
        LightingSection:Slider({Name = "ClockTime", Flag = "Lighting/ClockTime", Min = 0, Max = 24, Precise = 2, Value = 12})
        LightingSection:Colorpicker({Name = "ColorShift_Bottom", Flag = "Lighting/ColorShift_Bottom", Value = {1, 0, 1, 0, false}})
        LightingSection:Colorpicker({Name = "ColorShift_Top", Flag = "Lighting/ColorShift_Top", Value = {1, 0, 1, 0, false}})
        LightingSection:Slider({Name = "EnvironmentDiffuseScale", Flag = "Lighting/EnvironmentDiffuseScale", Min = 0, Max = 1, Precise = 3, Value = 0})
        LightingSection:Slider({Name = "EnvironmentSpecularScale", Flag = "Lighting/EnvironmentSpecularScale", Min = 0, Max = 1, Precise = 3, Value = 0})
        LightingSection:Slider({Name = "ExposureCompensation", Flag = "Lighting/ExposureCompensation", Min = -3, Max = 3, Precise = 2, Value = 0})
        LightingSection:Colorpicker({Name = "FogColor", Flag = "Lighting/FogColor", Value = {1, 0, 1, 0, false}})
        LightingSection:Slider({Name = "FogEnd", Flag = "Lighting/FogEnd", Min = 0, Max = 100000, Value = 100000})
        LightingSection:Slider({Name = "FogStart", Flag = "Lighting/FogStart", Min = 0, Max = 100000, Value = 0})
        LightingSection:Slider({Name = "GeographicLatitude", Flag = "Lighting/GeographicLatitude", Min = 0, Max = 360, Precise = 1, Value = 23.5})
        LightingSection:Toggle({Name = "GlobalShadows", Flag = "Lighting/GlobalShadows", Value = false})
        LightingSection:Colorpicker({Name = "OutdoorAmbient", Flag = "Lighting/OutdoorAmbient", Value = {1, 0, 1, 0, false}})
        LightingSection:Slider({Name = "ShadowSoftness", Flag = "Lighting/ShadowSoftness", Min = 0, Max = 1, Precise = 2, Value = 0})
        LightingSection:Toggle({Name = "Terrain Decoration", Flag = "Terrain/Decoration", Value = gethiddenproperty(Terrain, "Decoration"),
            Callback = function(Value) sethiddenproperty(Terrain, "Decoration", Value) end})
    end
end

function Utility.SetupLighting(Self, Flags)
    Self.DefaultLighting = {
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        ColorShift_Top = Lighting.ColorShift_Top,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        ExposureCompensation = Lighting.ExposureCompensation,
        FogColor = Lighting.FogColor,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GeographicLatitude = Lighting.GeographicLatitude,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ShadowSoftness = Lighting.ShadowSoftness
    }

    Lighting.Changed:Connect(function(Property)
        if Property == "TimeOfDay" then return end
        local Value = nil
        if not pcall(function() Value = Lighting[Property] end) then return end
        local CustomValue, FormatedValue = Flags["Lighting/" .. Property], Value
        local DefaultValue = Self.DefaultLighting[Property]

        if type(CustomValue) == "table" then
            CustomValue = CustomValue[6]
        end

        if type(FormatedValue) == "number" then
            if Property == "EnvironmentSpecularScale" or Property == "EnvironmentDiffuseScale" then
                FormatedValue = tonumber(string.format("%.3f", FormatedValue))
            else
                FormatedValue = tonumber(string.format("%.2f", FormatedValue))
            end
        end

        if CustomValue ~= FormatedValue and Value ~= DefaultValue then
            Self.DefaultLighting[Property] = Value
        end
    end)

    RunService.Heartbeat:Connect(function()
        if Flags["Lighting/Enabled"] then
            for Property in pairs(Self.DefaultLighting) do
                local CustomValue = Flags["Lighting/" .. Property]
                if type(CustomValue) == "table" then
                    CustomValue = CustomValue[6]
                end
                if Lighting[Property] ~= CustomValue then
                    Lighting[Property] = CustomValue
                end
            end
        end
    end)
end

-- Include the full Bracket UI library here
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local GuiInset = GuiService:GetGuiInset()
local LocalPlayer = PlayerService.LocalPlayer
local Bracket = {IsLocal = not identifyexecutor}

Bracket.Utilities = {
    TableToColor = function(Table)
        if type(Table) ~= "table" then return Table end
        return Color3.fromHSV(Table[1], Table[2], Table[3])
    end,
    ColorToString = function(Color)
        return ("%i, %i, %i"):format(Color.R * 255, Color.G * 255, Color.B * 255)
    end,
    Scale = function(Value, InputMin, InputMax, OutputMin, OutputMax)
        return OutputMin + (Value - InputMin) * (OutputMax - OutputMin) / (InputMax - InputMin)
    end,
    DeepCopy = function(Self, Original)
        local Copy = {}
        for Index, Value in pairs(Original) do
            if type(Value) == "table" then
                Value = Self:DeepCopy(Value)
            end
            Copy[Index] = Value
        end
        return Copy
    end,
    Proxify = function(Table)
        local Proxy, Events = {}, {}
        local ChangedEvent = Instance.new("BindableEvent")
        Table.Changed = ChangedEvent.Event
        Proxy.Internal = Table

        function Table:GetPropertyChangedSignal(Property)
            local PropertyEvent = Instance.new("BindableEvent")
            Events[Property] = Events[Property] or {}
            table.insert(Events[Property], PropertyEvent)
            return PropertyEvent.Event
        end

        setmetatable(Proxy, {
            __index = function(Self, Key)
                return Table[Key]
            end,
            __newindex = function(Self, Key, Value)
                local OldValue = Table[Key]
                Table[Key] = Value
                ChangedEvent:Fire(Key, Value, OldValue)
                if Events[Key] then
                    for Index, Event in ipairs(Events[Key]) do
                        Event:Fire(Value, OldValue)
                    end
                end
            end
        })

        return Proxy
    end,
    GetType = function(Self, Object, Default, Type, UseProxify)
        if typeof(Object) == Type then
            return UseProxify and Self.Proxify(Object) or Object
        end
        return UseProxify and Self.Proxify(Default) or Default
    end,
    GetTextBounds = function(Text, Font, Size)
        return TextService:GetTextSize(Text, Size.Y, Font, Vector2.new(Size.X, 1e6))
    end,
    MakeDraggable = function(Dragger, Object, OnChange, OnEnd)
        local Position, StartPosition = nil, nil

        Dragger.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Position = UserInputService:GetMouseLocation()
                StartPosition = Object.AbsolutePosition
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if StartPosition and Input.UserInputType == Enum.UserInputType.MouseMovement then
                local Mouse = UserInputService:GetMouseLocation()
                local Delta = Mouse - Position
                Position = Mouse
                Delta = Object.Position + UDim2.fromOffset(Delta.X, Delta.Y)
                if OnChange then OnChange(Delta) end
            end
        end)
        Dragger.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if OnEnd then OnEnd(Object.Position, StartPosition) end
                Position, StartPosition = nil, nil
            end
        end)
    end,
    MakeResizeable = function(Dragger, Object, MinSize, MaxSize, OnChange, OnEnd)
        local Position, StartSize = nil, nil

        Dragger.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Position = UserInputService:GetMouseLocation()
                StartSize = Object.AbsoluteSize
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if StartSize and Input.UserInputType == Enum.UserInputType.MouseMovement then
                local Mouse = UserInputService:GetMouseLocation()
                local Delta = Mouse - Position
                local Size = StartSize + Delta

                local SizeX = math.max(MinSize.X, Size.X)
                local SizeY = math.max(MinSize.Y, Size.Y)
                OnChange(UDim2.fromOffset(SizeX, SizeY))
            end
        end)
        Dragger.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if OnEnd then OnEnd(Object.Size, StartSize) end
                Position, StartSize = nil, nil
            end
        end)
    end,
    ClosePopUps = function()
        for Index, Object in pairs(Bracket.Screen:GetChildren()) do
            if Object.Name == "OptionContainer" or Object.Name == "Palette" then
                Object.Visible = false
            end
        end
    end,
    ChooseTab = function(TabButtonAsset, TabAsset)
        for Index, Object in pairs(Bracket.Screen:GetChildren()) do
            if Object.Name == "OptionContainer" or Object.Name == "Palette" then
                Object.Visible = false
            end
        end
        for Index, Object in pairs(Bracket.Screen.Window.TabContainer:GetChildren()) do
            if Object:IsA("ScrollingFrame") then
                Object.Visible = Object == TabAsset
            end
        end
        for Index, Object in pairs(Bracket.Screen.Window.TabButtonContainer:GetChildren()) do
            if Object:IsA("TextButton") then
                Object.Highlight.Visible = Object == TabButtonAsset
            end
        end
    end,
    GetLongestSide = function(TabAsset)
        local LeftSideSize = TabAsset.LeftSide.ListLayout.AbsoluteContentSize
        local RightSideSize = TabAsset.RightSide.ListLayout.AbsoluteContentSize
        return LeftSideSize.Y >= RightSideSize.Y and TabAsset.LeftSide or TabAsset.RightSide
    end,
    GetShortestSide = function(TabAsset)
        local LeftSideSize = TabAsset.LeftSide.ListLayout.AbsoluteContentSize
        local RightSideSize = TabAsset.RightSide.ListLayout.AbsoluteContentSize
        return LeftSideSize.Y <= RightSideSize.Y and TabAsset.LeftSide or TabAsset.RightSide
    end,
    ChooseTabSide = function(Self, TabAsset, Mode)
        if Mode == "Left" then
            return TabAsset.LeftSide
        elseif Mode == "Right" then
            return TabAsset.RightSide
        else
            return Self.GetShortestSide(TabAsset)
        end
    end,
    FindElementByFlag = function(Elements, Flag)
        for Index, Element in pairs(Elements) do
            if Element.Flag == Flag then
                return Element
            end
        end
    end,
    GetConfigs = function(FolderName)
        if not isfolder(FolderName) then makefolder(FolderName) end
        if not isfolder(FolderName .. "\\Configs") then makefolder(FolderName .. "\\Configs") end

        local Configs = {}
        for Index, Config in pairs(listfiles(FolderName .. "\\Configs") or {}) do
            Config = Config:gsub(FolderName .. "\\Configs\\", "")
            Config = Config:gsub(".json", "")
            Configs[#Configs + 1] = Config
        end
        return Configs
    end,
    ConfigsToList = function(FolderName)
        if not isfolder(FolderName) then makefolder(FolderName) end
        if not isfolder(FolderName .. "\\Configs") then makefolder(FolderName .. "\\Configs") end
        if not isfile(FolderName .. "\\AutoLoads.json") then writefile(FolderName .. "\\AutoLoads.json", "[]") end

        local AutoLoads = HttpService:JSONDecode(readfile(FolderName .. "\\AutoLoads.json"))
        local AutoLoad = AutoLoads[tostring(game.GameId)]

        local Configs = {}
        for Index, Config in pairs(listfiles(FolderName .. "\\Configs") or {}) do
            Config = Config:gsub(FolderName .. "\\Configs\\", "")
            Config = Config:gsub(".json", "")
            Configs[#Configs + 1] = {
                Name = Config,
                Mode = "Button",
                Value = Config == AutoLoad
            }
        end
        return Configs
    end
}

Bracket.Assets = {
    Screen = function(Self)
        local Screen = Instance.new("ScreenGui")
        Screen.Name = "Bracket"
        Screen.ResetOnSpawn = false
        Screen.IgnoreGuiInset = true
        Screen.DisplayOrder = Bracket.IsLocal and 0 or 10

        local ToolTip = Instance.new("TextLabel")
        ToolTip.Name = "ToolTip"
        ToolTip.ZIndex = 6
        ToolTip.Visible = false
        ToolTip.AnchorPoint = Vector2.new(0, 1)
        ToolTip.Size = UDim2.new(0, 45, 0, 20)
        ToolTip.BorderColor3 = Color3.fromRGB(63, 63, 63)
        ToolTip.Position = UDim2.new(0, 50, 0, 50)
        ToolTip.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        ToolTip.TextStrokeTransparency = 0.75
        ToolTip.TextSize = 14
        ToolTip.RichText = true
        ToolTip.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToolTip.Text = "ToolTip"
        ToolTip.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
        ToolTip.Parent = Screen

        local Watermark = Instance.new("TextLabel")
        Watermark.Name = "Watermark"
        Watermark.Visible = false
        Watermark.AnchorPoint = Vector2.new(1, 0)
        Watermark.Size = UDim2.new(0, 61, 0, 20)
        Watermark.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Watermark.Position = UDim2.new(1, -20, 0, 20)
        Watermark.BorderSizePixel = 2
        Watermark.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Watermark.TextStrokeTransparency = 0.75
        Watermark.TextSize = 14
        Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
        Watermark.Text = "Watermark"
        Watermark.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
        Watermark.Parent = Screen

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "Stroke"
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.LineJoinMode = Enum.LineJoinMode.Miter
        Stroke.Color = Color3.fromRGB(63, 63, 63)
        Stroke.Parent = Watermark

        local PNContainer = Instance.new("Frame")
        PNContainer.Name = "PNContainer"
        PNContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        PNContainer.Size = UDim2.new(1, 0, 1, 0)
        PNContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        PNContainer.BackgroundTransparency = 1
        PNContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        PNContainer.BorderSizePixel = 0
        PNContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        PNContainer.Parent = Screen

        local PNPadding = Instance.new("UIPadding")
        PNPadding.Name = "Padding"
        PNPadding.PaddingTop = UDim.new(0, 10)
        PNPadding.PaddingBottom = UDim.new(0, 10)
        PNPadding.PaddingLeft = UDim.new(0, 10)
        PNPadding.PaddingRight = UDim.new(0, 10)
        PNPadding.Parent = PNContainer

        local PNListLayout = Instance.new("UIListLayout")
        PNListLayout.Name = "ListLayout"
        PNListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        PNListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        PNListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PNListLayout.Padding = UDim.new(0, 12)
        PNListLayout.Parent = PNContainer

        local TNContainer = Instance.new("Frame")
        TNContainer.Name = "TNContainer"
        TNContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        TNContainer.Size = UDim2.new(1, 0, 1, 0)
        TNContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TNContainer.BackgroundTransparency = 1
        TNContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        TNContainer.BorderSizePixel = 0
        TNContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TNContainer.Parent = Screen

        local TNPadding = Instance.new("UIPadding")
        TNPadding.Name = "Padding"
        TNPadding.PaddingTop = UDim.new(0, 39)
        TNPadding.PaddingBottom = UDim.new(0, 10)
        TNPadding.Parent = TNContainer

        local TNListLayout = Instance.new("UIListLayout")
        TNListLayout.Name = "ListLayout"
        TNListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TNListLayout.Padding = UDim.new(0, 5)
        TNListLayout.Parent = TNContainer

        local KeybindList = Self.KeybindList()
        KeybindList.Parent = Screen

        return Screen
    end,
    Window = function()
        local Window = Instance.new("Frame")
        Window.Name = "Window"
        Window.Size = UDim2.new(0, 496, 0, 496)
        Window.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Window.Position = UDim2.new(0.5, -248, 0.5, -248)
        Window.BorderSizePixel = 2
        Window.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "Stroke"
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.LineJoinMode = Enum.LineJoinMode.Miter
        Stroke.Color = Color3.fromRGB(63, 63, 63)
        Stroke.Parent = Window

        local Drag = Instance.new("Frame")
        Drag.Name = "Drag"
        Drag.AnchorPoint = Vector2.new(0.5, 0)
        Drag.Size = UDim2.new(1, 0, 0, 16)
        Drag.BorderColor3 = Color3.fromRGB(63, 63, 63)
        Drag.Position = UDim2.new(0.5, 0, 0, 0)
        Drag.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Drag.Parent = Window

        local Resize = Instance.new("ImageButton")
        Resize.Name = "Resize"
        Resize.ZIndex = 3
        Resize.AnchorPoint = Vector2.new(1, 1)
        Resize.Size = UDim2.new(0, 10, 0, 10)
        Resize.BorderColor3 = Color3.fromRGB(63, 63, 63)
        Resize.BackgroundTransparency = 1
        Resize.Position = UDim2.new(1, 0, 1, 0)
        Resize.BorderSizePixel = 0
        Resize.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
        Resize.ImageColor3 = Color3.fromRGB(63, 63, 63)
        Resize.ScaleType = Enum.ScaleType.Fit
        Resize.ResampleMode = Enum.ResamplerMode.Pixelated
        Resize.Image = "rbxassetid://7368471234"
        Resize.Parent = Window

        local Snowflake = Instance.new("ImageLabel")
        Snowflake.Name = "Snowflake"
        Snowflake.Visible = false
        Snowflake.AnchorPoint = Vector2.new(0.5, 0)
        Snowflake.Size = UDim2.new(0, 10, 0, 10)
        Snowflake.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Snowflake.BackgroundTransparency = 1
        Snowflake.BorderSizePixel = 0
        Snowflake.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Snowflake.Image = "rbxassetid://242109931"
        Snowflake.Parent = Window

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.AnchorPoint = Vector2.new(0.5, 0)
        Title.Size = UDim2.new(1, -10, 0, 16)
        Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0.5, 0, 0, 0)
        Title.BorderSizePixel = 0
        Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Title.TextStrokeTransparency = 0.75
        Title.TextSize = 14
        Title.RichText = true
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Text = "Window"
        Title.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Window

        local Label = Instance.new("TextLabel")
        Label.Name = "Version"
        Label.AnchorPoint = Vector2.new(0.5, 0)
        Label.Size = UDim2.new(1, -10, 0, 16)
        Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0.5, 0, 0, 0)
        Label.BorderSizePixel = 0
        Label.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Label.TextStrokeTransparency = 0.75
        Label.TextSize = 14
        Label.RichText = true
        Label.TextColor3 = Color3.fromRGB(191, 191, 191)
        Label.Text = ""
        Label.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
        Label.TextXAlignment = Enum.TextXAlignment.Right
        Label.Parent = Window

        local Background = Instance.new("Frame")
        Background.Name = "Background"
        Background.AnchorPoint = Vector2.new(0.5, 0)
        Background.Size = UDim2.new(1, 0, 1, -34)
        Background.ClipsDescendants = true
        Background.BorderColor3 = Color3.fromRGB(63, 63, 63)
        Background.Position = UDim2.new(0.5, 0, 0, 34)
        Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Background.Parent = Window

        local TabContainer = Instance.new("Frame")
        TabContainer.Name = "TabContainer"
        TabContainer.AnchorPoint = Vector2.new(0.5, 0)
        TabContainer.Size = UDim2.new(1, 0, 1, -34)
        TabContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabContainer.BackgroundTransparency = 1
        TabContainer.Position = UDim2.new(0.5, 0, 0, 34)
        TabContainer.BorderSizePixel = 0
        TabContainer.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        TabContainer.Parent = Window

        local TabButtonContainer = Instance.new("ScrollingFrame")
        TabButtonContainer.Name = "TabButtonContainer"
        TabButtonContainer.AnchorPoint = Vector2.new(0.5, 0)
        TabButtonContainer.Size = UDim2.new(1, 0, 0, 17)
        TabButtonContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButtonContainer.BackgroundTransparency = 1
        TabButtonContainer.Position = UDim2.new(0.5, 0, 0, 17)
        TabButtonContainer.Active = true
        TabButtonContainer.BorderSizePixel = 0
        TabButtonContainer.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        TabButtonContainer.ScrollingDirection = Enum.ScrollingDirection.X
        TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabButtonContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        TabButtonContainer.MidImage = "rbxassetid://6432766838"
        TabButtonContainer.ScrollBarThickness = 0
        TabButtonContainer.TopImage = "rbxassetid://6432766838"
        TabButtonContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        TabButtonContainer.BottomImage = "rbxassetid://6432766838"
        TabButtonContainer.Parent = Window

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Name = "ListLayout"
        ListLayout.FillDirection = Enum.FillDirection.Horizontal
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = TabButtonContainer

        return Window
    end,
    PushNotification = function()
        local Notification = Instance.new("Frame")
        Notification.Name = "Notification"
        Notification.Size = UDim2.new(0, 200, 0, 48)
        Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Notification.BorderSizePixel = 2
        Notification.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "Stroke"
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.LineJoinMode = Enum.LineJoinMode.Miter
        Stroke.Color = Color3.fromRGB(63, 63, 63)
        Stroke.Parent = Notification

        local Padding = Instance.new("UIPadding")
        Padding.Name = "Padding"
        Padding.PaddingTop = UDim.new(0, 4)
        Padding.PaddingBottom = UDim.new(0, 4)
        Padding.PaddingLeft = UDim.new(0, 4)
        Padding.PaddingRight = UDim.new(0, 4)
        Padding.Parent = Notification

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Name = "ListLayout"
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 5)
        ListLayout.Parent = Notification

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Size = UDim2.new(1, 0, 0, 14)
        Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title.BorderSizePixel = 0
        Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Title.TextStrokeTransparency = 0.75
        Title.TextSize = 14
        Title.RichText = true
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Text = "Title"
        Title.TextWrapped = true
        Title.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Notification

        local Description = Instance.new("TextLabel")
        Description.Name = "Description"
        Description.LayoutOrder = 2
        Description.Size = UDim2.new(1, 0, 0, 14)
        Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Description.BorderSizePixel = 0
        Description.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Description.TextStrokeTransparency = 0.75
        Description.TextSize = 14
        Description.RichText = true
        Description.TextColor3 = Color3.fromRGB(255, 255, 255)
        Description.Text = "Description"
        Description.TextWrapped = true
        Description.FontFace = Font.fromEnum(Enum.Font.SourceSans)
        Description.TextXAlignment = Enum.TextXAlignment.Left
        Description.Parent = Notification

        local Divider = Instance.new("Frame")
        Divider.Name = "Divider"
        Divider.LayoutOrder = 1
        Divider.Size = UDim2.new(1, -2, 0, 2)
        Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Divider.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
        Divider.Parent = Notification

        local Close = Instance.new("TextButton")
        Close.Name = "Close"
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.Size = UDim2.new(0, 14, 1, 0)
        Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Close.Position = UDim2.new(1, 0, 0.5, 0)
        Close.BorderSizePixel = 0
        Close.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Close.AutoButtonColor = false
        Close.TextStrokeTransparency = 0.75
        Close.TextSize = 14
        Close.TextColor3 = Color3.fromRGB(255, 255, 255)
        Close.Text = "X"
        Close.FontFace = Font.fromEnum(Enum.Font.Nunito)
        Close.Parent = Title

        return Notification
    end,
    ToastNotification = function()
        local Notification = Instance.new("Frame")
        Notification.Name = "Notification"
        Notification.Size = UDim2.new(0, 259, 0, 24)
        Notification.ClipsDescendants = true
        Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Notification.BackgroundTransparency = 1
        Notification.BorderSizePixel = 2
        Notification.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

        local Main = Instance.new("Frame")
        Main.Name = "Main"
        Main.Size = UDim2.new(0, 255, 0, 20)
        Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Main.Position = UDim2.new(0, 2, 0, 2)
        Main.BorderSizePixel = 2
        Main.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Main.Parent = Notification

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "Stroke"
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.LineJoinMode = Enum.LineJoinMode.Miter
        Stroke.Color = Color3.fromRGB(63, 63, 63)
        Stroke.Parent = Main

        local GradientLine = Instance.new("Frame")
        GradientLine.Name = "GradientLine"
        GradientLine.AnchorPoint = Vector2.new(1, 0.5)
        GradientLine.Size = UDim2.new(0, 2, 1, 4)
        GradientLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
        GradientLine.Position = UDim2.new(0, 0, 0.5, 0)
        GradientLine.BorderSizePixel = 0
        GradientLine.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        GradientLine.Parent = Main

        local Gradient = Instance.new("UIGradient")
        Gradient.Name = "Gradient"
        Gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.25, 0),
            NumberSequenceKeypoint.new(0.75, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        Gradient.Rotation = 90
        Gradient.Parent = GradientLine

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.AnchorPoint = Vector2.new(0.5, 0.5)
        Title.Size = UDim2.new(1, -10, 1, 0)
        Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0.5, 0, 0.5, 0)
        Title.BorderSizePixel = 0
        Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Title.TextStrokeTransparency = 0.75
        Title.TextSize = 14
        Title.RichText = true
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Text = "Hit OnlyTwentyCharacters in the Head with AK47"
        Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Main

        return Notification
    end,
    KeybindList = function()
        local KeybindList = Instance.new("Frame")
        KeybindList.Name = "KeybindList"
        KeybindList.ZIndex = 4
        KeybindList.Visible = false
        KeybindList.Size = UDim2.new(0, 121, 0, 246)
        KeybindList.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindList.Position = UDim2.new(0, 10, 0.5, -123)
        KeybindList.BorderSizePixel = 2
        KeybindList.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "Stroke"
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.LineJoinMode = Enum.LineJoinMode.Miter
        Stroke.Color = Color3.fromRGB(63, 63, 63)
        Stroke.Parent = KeybindList

        local Drag = Instance.new("Frame")
        Drag.Name = "Drag"
        Drag.ZIndex = 4
        Drag.AnchorPoint = Vector2.new(0.5, 0)
        Drag.Size = UDim2.new(1, 0, 0, 16)
        Drag.BorderColor3 = Color3.fromRGB(63, 63, 63)
        Drag.Position = UDim2.new(0.5, 0, 0, 0)
        Drag.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Drag.Parent = KeybindList

        local Resize = Instance.new("ImageButton")
        Resize.Name = "Resize"
        Resize.ZIndex = 5
        Resize.AnchorPoint = Vector2.new(1, 1)
        Resize.Size = UDim2.new(0, 10, 0, 10)
        Resize.BorderColor3 = Color3.fromRGB(63, 63, 63)
        Resize.BackgroundTransparency = 1
        Resize.Position = UDim2.new(1, 0, 1, 0)
        Resize.BorderSizePixel = 0
        Resize.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
        Resize.ImageColor3 = Color3.fromRGB(63, 63, 63)
        Resize.ScaleType = Enum.ScaleType.Fit
        Resize.ResampleMode = Enum.ResamplerMode.Pixelated
        Resize.Image = "rbxassetid://7368471234"
        Resize.Parent = KeybindList

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.ZIndex = 4
        Title.AnchorPoint = Vector2.new(0.5, 0)
        Title.Size = UDim2.new(1, -10, 0, 16)
        Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0.5, 0, 0, 0)
        Title.BorderSizePixel = 0
        Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Title.TextStrokeTransparency = 0.75
        Title.TextSize = 14
        Title.RichText = true
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Text = "Keybinds"
        Title.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = KeybindList

        local Background = Instance.new("ImageLabel")
        Background.Name = "Background"
        Background.ZIndex = 4
        Background.AnchorPoint = Vector2.new(0.5, 0)
        Background.Size = UDim2.new(1, 0, 1, -17)
        Background.ClipsDescendants = true
        Background.BorderColor3 = Color3.fromRGB(63, 63, 63)
        Background.Position = UDim2.new(0.5, 0, 0, 17)
        Background.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Background.ScaleType = Enum.ScaleType.Tile
        Background.ImageColor3 = Color3.fromRGB(0, 0, 0)
        Background.TileSize = UDim2.new(0, 74, 0, 74)
        Background.Image = "rbxassetid://5553946656"
        Background.Parent = KeybindList

        local List = Instance.new("ScrollingFrame")
        List.Name = "List"
        List.ZIndex = 4
        List.AnchorPoint = Vector2.new(0.5, 0)
        List.Size = UDim2.new(1, 0, 1, -17)
        List.BorderColor3 = Color3.fromRGB(0, 0, 0)
        List.BackgroundTransparency = 1
        List.Position = UDim2.new(0.5, 0, 0, 17)
        List.Active = true
        List.BorderSizePixel = 0
        List.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        List.ScrollingDirection = Enum.ScrollingDirection.Y
        List.CanvasSize = UDim2.new(0, 0, 0, 0)
        List.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        List.MidImage = "rbxassetid://6432766838"
        List.ScrollBarThickness = 0
        List.TopImage = "rbxassetid://6432766838"
        List.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        List.BottomImage = "rbxassetid://6432766838"
        List.Parent = KeybindList

        local Padding = Instance.new("UIPadding")
        Padding.Name = "Padding"
        Padding.PaddingTop = UDim.new(0, 5)
        Padding.PaddingLeft = UDim.new(0, 5)
        Padding.PaddingRight = UDim.new(0, 5)
        Padding.Parent = List

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Name = "ListLayout"
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 5)
        ListLayout.Parent = List

        return KeybindList
    end,
    KeybindMimic = function()
        local KeybindMimic = Instance.new("Frame")
        KeybindMimic.Name = "KeybindMimic"
        KeybindMimic.ZIndex = 4
        KeybindMimic.Size = UDim2.new(1, 0, 0, 14)
        KeybindMimic.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindMimic.BackgroundTransparency = 1
        KeybindMimic.BorderSizePixel = 0
        KeybindMimic.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.ZIndex = 5
        Title.AnchorPoint = Vector2.new(0, 0.5)
        Title.Size = UDim2.new(1, -14, 1, 0)
        Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 14, 0.5, 0)
        Title.BorderSizePixel = 0
        Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Title.TextStrokeTransparency = 0.75
        Title.TextSize = 14
        Title.RichText = true
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Text = "Toggle"
        Title.TextWrapped = true
        Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = KeybindMimic

        local Tick = Instance.new("Frame")
        Tick.Name = "Tick"
        Tick.ZIndex = 5
        Tick.AnchorPoint = Vector2.new(0, 0.5)
        Tick.Size = UDim2.new(0, 10, 0, 10)
        Tick.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tick.Position = UDim2.new(0, 0, 0.5, 0)
        Tick.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
        Tick.Parent = KeybindMimic

        local Gradient = Instance.new("UIGradient")
        Gradient.Name = "Gradient"
        Gradient.Rotation = 90
        Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
        Gradient.Parent = Tick

        local Layout = Instance.new("Frame")
        Layout.Name = "Layout"
        Layout.ZIndex = 5
        Layout.AnchorPoint = Vector2.new(1, 0.5)
        Layout.Size = UDim2.new(1, -56, 1, 0)
        Layout.ClipsDescendants = true
        Layout.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Layout.BackgroundTransparency = 1
        Layout.Position = UDim2.new(1, 1, 0.5, 0)
        Layout.BorderSizePixel = 0
        Layout.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Layout.Parent = KeybindMimic

        local Padding = Instance.new("UIPadding")
        Padding.Name = "Padding"
        Padding.PaddingRight = UDim.new(0, 1)
        Padding.Parent = Layout

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Name = "ListLayout"
        ListLayout.FillDirection = Enum.FillDirection.Horizontal
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 4)
        ListLayout.Parent = Layout

        local Keybind = Instance.new("TextLabel")
        Keybind.Name = "Keybind"
        Keybind.ZIndex = 5
        Keybind.Size = UDim2.new(0, 42, 1, 0)
        Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Keybind.BackgroundTransparency = 1
        Keybind.BorderSizePixel = 0
        Keybind.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Keybind.TextStrokeTransparency = 0.75
        Keybind.TextSize = 14
        Keybind.RichText = true
        Keybind.TextColor3 = Color3.fromRGB(189, 189, 189)
        Keybind.Text = "[ NONE ]"
        Keybind.FontFace = Font.fromEnum(Enum.Font.SourceSans)
        Keybind.TextXAlignment = Enum.TextXAlignment.Right
        Keybind.Parent = Layout

        return KeybindMimic
    end,
    Tab = function()
        local Tab = Instance.new("ScrollingFrame")
        Tab.Name = "Tab"
        Tab.AnchorPoint = Vector2.new(0.5, 0.5)
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BackgroundTransparency = 1
        Tab.Position = UDim2.new(0.5, 0, 0.5, 0)
        Tab.Active = true
        Tab.BorderSizePixel = 0
        Tab.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        Tab.MidImage = "rbxassetid://6432766838"
        Tab.ScrollBarThickness = 0
        Tab.TopImage = "rbxassetid://6432766838"
        Tab.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        Tab.BottomImage = "rbxassetid://6432766838"

        local LeftSide = Instance.new("Frame")
        LeftSide.Name = "LeftSide"
        LeftSide.Size = UDim2.new(0.5, 0, 1, 0)
        LeftSide.BorderColor3 = Color3.fromRGB(0, 0, 0)
        LeftSide.BackgroundTransparency = 1
        LeftSide.BorderSizePixel = 0
        LeftSide.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        LeftSide.Parent = Tab

        local LeftPadding = Instance.new("UIPadding")
        LeftPadding.Name = "Padding"
        LeftPadding.PaddingTop = UDim.new(0, 11)
        LeftPadding.PaddingLeft = UDim.new(0, 5)
        LeftPadding.PaddingRight = UDim.new(0, 5)
        LeftPadding.Parent = LeftSide

        local LeftListLayout = Instance.new("UIListLayout")
        LeftListLayout.Name = "ListLayout"
        LeftListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        LeftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftListLayout.Padding = UDim.new(0, 10)
        LeftListLayout.Parent = LeftSide

        local RightSide = Instance.new("Frame")
        RightSide.Name = "RightSide"
        RightSide.AnchorPoint = Vector2.new(1, 0)
        RightSide.Size = UDim2.new(0.5, 0, 1, 0)
        RightSide.BorderColor3 = Color3.fromRGB(0, 0, 0)
        RightSide.BackgroundTransparency = 1
        RightSide.Position = UDim2.new(1, 0, 0, 0)
        RightSide.BorderSizePixel = 0
        RightSide.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        RightSide.Parent = Tab

        local RightPadding = Instance.new("UIPadding")
        RightPadding.Name = "Padding"
        RightPadding.PaddingTop = UDim.new(0, 11)
        RightPadding.PaddingLeft = UDim.new(0, 5)
        RightPadding.PaddingRight = UDim.new(0, 5)
        RightPadding.Parent = RightSide

        local RightListLayout = Instance.new("UIListLayout")
        RightListLayout.Name = "ListLayout"
        RightListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        RightListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightListLayout.Padding = UDim.new(0, 10)
        RightListLayout.Parent = RightSide

        return Tab
    end,
    TabButton = function()
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton"
        TabButton.Size = UDim2.new(0, 67, 1, -1)
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        TabButton.AutoButtonColor = false
        TabButton.TextStrokeTransparency = 0.75
        TabButton.TextSize = 14
        TabButton.RichText = true
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Text = "TabButton"
        TabButton.FontFace = Font.fromEnum(Enum.Font.SourceSans)

        local Highlight = Instance.new("Frame")
        Highlight.Name = "Highlight"
        Highlight.Visible = false
        Highlight.AnchorPoint = Vector2.new(0.5, 1)
        Highlight.Size = UDim2.new(1, 0, 0, 1)
        Highlight.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Highlight.Position = UDim2.new(0.5, 0, 1, 1)
        Highlight.BorderSizePixel = 0
        Highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Highlight.Parent = TabButton

        local Gradient = Instance.new("UIGradient")
        Gradient.Name = "Gradient"
        Gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.25, 0),
            NumberSequenceKeypoint.new(0.75, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        Gradient.Parent = Highlight

        return TabButton
    end,
    Section = function()
        local Section = Instance.new("Frame")
        Section.Name = "Section"
        Section.ZIndex = 2
        Section.Size = UDim2.new(1, 0, 0, 10)
        Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Section.BorderSizePixel = 2
        Section.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "Stroke"
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.LineJoinMode = Enum.LineJoinMode.Miter
        Stroke.Color = Color3.fromRGB(63, 63, 63)
        Stroke.Parent = Section

        local Border = Instance.new("Frame")
        Border.Name = "Border"
        Border.Visible = false
        Border.AnchorPoint = Vector2.new(0.5, 0.5)
        Border.Size = UDim2.new(1, 2, 1, 2)
        Border.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Border.Position = UDim2.new(0.5, 0, 0.5, 0)
        Border.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
        Border.Parent = Section

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.ZIndex = 2
        Title.Size = UDim2.new(0, 44, 0, 2)
        Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title.Position = UDim2.new(0, 5, 0, -2)
        Title.BorderSizePixel = 0
        Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Title.TextStrokeTransparency = 0.75
        Title.TextSize = 14
        Title.RichText = true
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Text = "Section"
        Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
        Title.Parent = Section

        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.ZIndex = 2
        Container.AnchorPoint = Vector2.new(0.5, 0)
        Container.Size = UDim2.new(1, 0, 1, -10)
        Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Container.BackgroundTransparency = 1
        Container.BorderSizePixel = 0
        Container.Position = UDim2.new(0.5, 0, 0, 10)
        Container.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Container.Parent = Section

        local Padding = Instance.new("UIPadding")
        Padding.Name = "Padding"
        Padding.PaddingLeft = UDim.new(0, 5)
        Padding.PaddingRight = UDim.new(0, 5)
        Padding.Parent = Container

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Name = "ListLayout"
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 5)
        ListLayout.Parent = Container

        return Section
    end,
    Divider = function()
        local Divider = Instance.new("Frame")
        Divider.Name = "Divider"
        Divider.ZIndex = 2
        Divider.AnchorPoint = Vector2.new(0.5, 0)
        Divider.Size = UDim2.new(1, 0, 0, 14)
        Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Divider.BackgroundTransparency = 1
        Divider.BorderSizePixel = 0
        Divider.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

        local Left = Instance.new("Frame")
        Left.Name = "Left"
        Left.ZIndex = 2
        Left.AnchorPoint = Vector2.new(0, 0.5)
        Left.Size = UDim2.new(0.5, -24, 0, 2)
        Left.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Left.Position = UDim2.new(0, 0, 0.5, 0)
        Left.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
        Left.Parent = Divider

        local Right = Instance.new("Frame")
        Right.Name = "Right"
        Right.ZIndex = 2
        Right.AnchorPoint = Vector2.new(1, 0.5)
        Right.Size = UDim2.new(0.5, -24, 0, 2)
        Right.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Right.Position = UDim2.new(1, 0, 0.5, 0)
        Right.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
        Right.Parent = Divider

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.ZIndex = 2
        Title.AnchorPoint = Vector2.new(0.5, 0.5)
        Title.Size = UDim2.new(1, 0, 1, 0)
        Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0.5, 0, 0.5, 0)
        Title.BorderSizePixel = 0
        Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Title.TextStrokeTransparency = 0.75
        Title.TextSize = 14
        Title.RichText = true
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Text = "Divider"
        Title.TextWrapped = true
        Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
        Title.Parent = Divider

        return Divider
    end,
    Label = function()
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.ZIndex = 2
        Label.Size = UDim2.new(1, 0, 0, 14)
        Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.BorderSizePixel = 0
        Label.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        Label.TextStrokeTransparency = 0.75
        Label.TextSize = 14
        Label.RichText = true
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Text = "Text Label"
        Label.TextWrapped = true
        Label.FontFace = Font.fromEnum(Enum.Font.SourceSans)

        return Label
    end,
    Button = function()
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.ZIndex = 2
        Button.Size = UDim2.new(1, 0, 0, 16)
        Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
        Button.AutoButtonColor = false
        Button.TextStrokeTransparency = 0.75
        Button.TextSize = 14
        Button.RichText = true
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Text = ""
        Button.TextWrapped = true
        Button.FontFace = Font.fromEnum(Enum.Font.SourceSans)

        local Title = Instance.new("TextLabel")
       
