local StoppedUI = {}
StoppedUI.__index = StoppedUI
StoppedUI.Version = "5.1.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Layout Modes
StoppedUI.LayoutModes = {
    Compact = "Compact",
    Normal = "Normal",
    Expanded = "Expanded"
}

-- Responsive Breakpoints
StoppedUI.Breakpoints = {
    Mobile = 480,
    Tablet = 700,
    Desktop = 1200
}

-- ========================================
-- THEME SYSTEM (Modular & Customizable)
-- ========================================
StoppedUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(17, 17, 18),
        Card = Color3.fromRGB(28, 29, 31),
        Secondary = Color3.fromRGB(35, 35, 37),
        Accent = Color3.fromRGB(82, 171, 255),
        Text = Color3.fromRGB(220, 220, 220),
        TextDim = Color3.fromRGB(156, 156, 156),
        Border = Color3.fromRGB(50, 50, 52),
        Success = Color3.fromRGB(100, 255, 100),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100),
        Radius = 8
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 242),
        Card = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(248, 248, 250),
        Accent = Color3.fromRGB(0, 122, 255),
        Text = Color3.fromRGB(30, 30, 30),
        TextDim = Color3.fromRGB(120, 120, 120),
        Border = Color3.fromRGB(200, 200, 205),
        Success = Color3.fromRGB(40, 200, 40),
        Warning = Color3.fromRGB(255, 150, 0),
        Error = Color3.fromRGB(255, 60, 60),
        Radius = 8
    }
}

-- ========================================
-- TRANSLATION SYSTEM (Disabled by default - Dev can enable)
-- ========================================
StoppedUI.TranslationEnabled = false  -- Dev must enable explicitly

StoppedUI.Translations = {
    en = {
        Close = "Close",
        Preview = "Preview",
        Mode = "Mode:",
        Players = "Players",
        Vehicles = "Vehicles",
        Username = "User:",
        Seatbelt = "Press 'C' to put on or remove seatbelt.",
        ConfigSaved = "Configuration saved successfully!",
        ConfigLoaded = "Configuration loaded successfully!",
        ConfigInvalid = "Invalid configuration code!",
        ConfigCopied = "Configuration code copied to clipboard!",
        ConfigTab = "Configs",
        SaveConfig = "Save Config",
        LoadConfig = "Load Config",
        ConfigName = "Config Name",
        ConfigCode = "Config Code",
        PasteCode = "Paste Code Here",
        Language = "Language",
        ShowPreview = "Show Preview",
        ErrorOccurred = "An error occurred:",
        InvalidKey = "Invalid key:",
        KeyConflict = "Keybind conflict! Key already in use by:",
        ClipboardEmpty = "Clipboard is empty!",
        ClipboardNotSupported = "getclipboard() not supported",
    },
    pt = {
        Close = "Fechar",
        Preview = "Visualização",
        Mode = "Modo:",
        Players = "Jogadores",
        Vehicles = "Veículos",
        Username = "Usuário:",
        Seatbelt = "Pressione 'C' para colocar ou tirar o cinto de segurança.",
        ConfigSaved = "Configuração salva com sucesso!",
        ConfigLoaded = "Configuração carregada com sucesso!",
        ConfigInvalid = "Código de configuração inválido!",
        ConfigCopied = "Código de configuração copiado!",
        ConfigTab = "Configurações",
        SaveConfig = "Salvar Config",
        LoadConfig = "Carregar Config",
        ConfigName = "Nome da Config",
        ConfigCode = "Código da Config",
        PasteCode = "Cole o Código Aqui",
        Language = "Idioma",
        ShowPreview = "Mostrar Visualização",
        ErrorOccurred = "Ocorreu um erro:",
        InvalidKey = "Tecla inválida:",
        KeyConflict = "Conflito de tecla! Tecla já está em uso por:",
        ClipboardEmpty = "Área de transferência vazia!",
        ClipboardNotSupported = "getclipboard() não suportado",
    }
}

-- ========================================
-- UI HELPERS (Centralized Utilities)
-- ========================================
local UIHelpers = {}

function UIHelpers.SafeConnect(signal, fn, connTable)
    local conn = signal:Connect(function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            warn("[StoppedUI] SafeConnect error:", err)
        end
    end)
    if connTable then
        table.insert(connTable, conn)
    end
    return conn
end

function UIHelpers.CleanupConnections(list)
    for _, c in ipairs(list) do
        if c and typeof(c) == "RBXScriptConnection" then
            pcall(function() c:Disconnect() end)
        end
    end
    table.clear(list)
end

function UIHelpers.Tween(obj, props, duration)
    if not obj or not obj.Parent then return end
    duration = duration or 0.3
    local tween = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint), props)
    tween:Play()
    return tween
end

function UIHelpers.CreateRound(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

function UIHelpers.CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(50, 50, 50)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

function UIHelpers.CreatePadding(parent, all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all or 5)
    padding.PaddingBottom = UDim.new(0, all or 5)
    padding.PaddingLeft = UDim.new(0, all or 5)
    padding.PaddingRight = UDim.new(0, all or 5)
    padding.Parent = parent
    return padding
end

function UIHelpers.CenterLabelPixelPerfect(label, parent, connTable)
    local function recalc()
        if not label.Parent then return end
        local maxW = parent and parent.AbsoluteSize.X or 2000
        local size = TextService:GetTextSize(
            label.Text,
            label.TextSize,
            label.Font,
            Vector2.new(maxW, 10000)
        )
        label.Size = UDim2.new(0, math.ceil(size.X), 0, math.ceil(size.Y))
        label.Position = UDim2.new(0.5, -math.ceil(size.X)/2, 0.5, -math.ceil(size.Y)/2)
    end

    UIHelpers.SafeConnect(label:GetPropertyChangedSignal("Text"), recalc, connTable)
    UIHelpers.SafeConnect(label:GetPropertyChangedSignal("TextSize"), recalc, connTable)
    UIHelpers.SafeConnect(label:GetPropertyChangedSignal("Font"), recalc, connTable)
    if parent then
        UIHelpers.SafeConnect(parent:GetPropertyChangedSignal("AbsoluteSize"), recalc, connTable)
    end

    recalc()
end

function UIHelpers.Clamp(n, lo, hi)
    return math.max(lo, math.min(hi, n))
end

function UIHelpers.SnapToEdge(position, size, viewport, snapDistance)
    snapDistance = snapDistance or 10
    local x, y = position.X, position.Y
    
    -- Snap to left
    if x < snapDistance then
        x = 0
    end
    
    -- Snap to right
    if viewport.X - (x + size.X) < snapDistance then
        x = viewport.X - size.X
    end
    
    -- Snap to top
    if y < snapDistance then
        y = 0
    end
    
    -- Snap to bottom
    if viewport.Y - (y + size.Y) < snapDistance then
        y = viewport.Y - size.Y
    end
    
    return Vector2.new(x, y)
end

function UIHelpers.GetResponsiveBreakpoint(viewportX)
    if viewportX < 480 then
        return "Mobile"
    elseif viewportX < 700 then
        return "Tablet"
    elseif viewportX < 1200 then
        return "Desktop"
    else
        return "Wide"
    end
end

function UIHelpers.ResolveImage(img)
    if not img or img == "" then
        return "rbxassetid://3944680095"  -- Default fallback
    end
    
    local imgStr = tostring(img)
    
    -- Already has rbxassetid prefix
    if imgStr:match("^rbxassetid://") then
        return imgStr
    end
    
    -- Pure number (asset ID)
    if imgStr:match("^%d+$") then
        return "rbxassetid://" .. imgStr
    end
    
    -- HTTP(S) URL - try to use directly (works in exploit environments)
    if imgStr:match("^https?://") then
        return imgStr
    end
    
    -- Imgur hash (try to construct URL)
    if imgStr:match("^%w+$") and #imgStr >= 5 then
        return "https://i.imgur.com/" .. imgStr .. ".png"
    end
    
    -- Fallback
    return "rbxassetid://3944680095"
end

-- ========================================
-- SLIDER COMPONENT (Enhanced & Modular)
-- ========================================
local SliderComponent = {}
SliderComponent.__index = SliderComponent

function SliderComponent.new(parent, opts, connTable)
    opts = opts or {}
    local min = opts.Min or 0
    local max = opts.Max or 100
    local initial = UIHelpers.Clamp(opts.Value or min, min, max)
    local accent = opts.Accent or Color3.fromRGB(82, 171, 255)
    local bgColor = opts.BackgroundColor or Color3.fromRGB(45, 45, 47)
    local height = opts.Height or 6
    local callback = opts.Callback

    -- Container
    local container = Instance.new("Frame")
    container.Name = "StoppedSlider"
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = opts.Size or UDim2.new(1, 0, 0, 32)
    container.AnchorPoint = opts.AnchorPoint or Vector2.new(0, 0)
    container.LayoutOrder = opts.LayoutOrder or 0

    -- Label
    local label
    if opts.Label then
        label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Parent = container
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 0, 0, 0)
        label.Size = UDim2.new(0.7, 0, 0, 14)
        label.Font = opts.Font or Enum.Font.Gotham
        label.Text = tostring(opts.Label)
        label.TextSize = opts.TextSize or 12
        label.TextColor3 = opts.TextColor or Color3.fromRGB(220, 220, 220)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
    end

    -- Value Display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Parent = container
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.Size = UDim2.new(0.3, 0, 0, 14)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(math.floor(initial * 10) / 10)
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- Track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Parent = container
    track.BackgroundColor3 = bgColor
    track.Size = UDim2.new(1, -8, 0, height)
    track.Position = UDim2.new(0, 4, 0, 18)
    UIHelpers.CreateRound(track, height / 2)
    UIHelpers.CreateStroke(track, Color3.fromRGB(60, 60, 62), 1, 0.85)

    -- Fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Parent = track
    fill.BackgroundColor3 = accent
    fill.Size = UDim2.new((initial - min) / math.max(1, (max - min)), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BorderSizePixel = 0
    UIHelpers.CreateRound(fill, height / 2)

    -- Gradient on fill
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, accent),
        ColorSequenceKeypoint.new(1, accent:Lerp(Color3.new(1, 1, 1), 0.1))
    })
    gradient.Rotation = 0
    gradient.Parent = fill

    -- Knob
    local knobSize = math.max(height * 2.5, 14)
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Parent = container
    knob.BackgroundColor3 = accent
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0, 18 + height / 2)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    UIHelpers.CreateRound(knob, knobSize / 2)
    UIHelpers.CreateStroke(knob, Color3.fromRGB(255, 255, 255), 2, 0.7)

    -- Knob glow
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Parent = knob
    glow.Size = UDim2.new(2, 0, 2, 0)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://3570695787"
    glow.ImageColor3 = accent
    glow.ImageTransparency = 0.85
    glow.ZIndex = 4

    -- Self object
    local self = setmetatable({
        Container = container,
        Track = track,
        Fill = fill,
        Knob = knob,
        ValueLabel = valueLabel,
        Min = min,
        Max = max,
        Value = initial,
        Callback = callback,
        OnChanged = Instance.new("BindableEvent"),
        _connections = {}
    }, SliderComponent)

    -- Set value function
    local function setValue(v, noCallback)
        v = UIHelpers.Clamp(v, self.Min, self.Max)
        self.Value = v
        
        -- Round for display
        local displayValue = math.floor(v * 10) / 10
        valueLabel.Text = tostring(displayValue)
        
        local frac = (v - self.Min) / math.max(1, (self.Max - self.Min))
        
        -- Animate fill
        UIHelpers.Tween(fill, {Size = UDim2.new(frac, 0, 1, 0)}, 0.12)
        
        -- Animate knob
        UIHelpers.Tween(knob, {Position = UDim2.new(frac, 0, 0, 18 + height / 2)}, 0.12)
        
        if not noCallback then
            self.OnChanged:Fire(v)
            if self.Callback then
                pcall(self.Callback, v)
            end
        end
    end

    -- Initial layout update
    UIHelpers.SafeConnect(track:GetPropertyChangedSignal("AbsoluteSize"), function()
        setValue(self.Value, true)
    end, self._connections)

    -- Input handling
    local dragging = false
    
    local function updateFromInput(inputPosX)
        local startX = track.AbsolutePosition.X
        local width = track.AbsoluteSize.X
        local localX = UIHelpers.Clamp(inputPosX - startX, 0, width)
        local frac = localX / math.max(1, width)
        local v = self.Min + frac * (self.Max - self.Min)
        setValue(v)
    end

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            -- Scale up knob
            UIHelpers.Tween(knob, {Size = UDim2.new(0, knobSize * 1.15, 0, knobSize * 1.15)}, 0.1)
            UIHelpers.Tween(glow, {ImageTransparency = 0.7}, 0.1)
            updateFromInput(input.Position.X)
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            -- Scale down knob
            UIHelpers.Tween(knob, {Size = UDim2.new(0, knobSize, 0, knobSize)}, 0.15)
            UIHelpers.Tween(glow, {ImageTransparency = 0.85}, 0.15)
        end
    end

    UIHelpers.SafeConnect(container.InputBegan, onInputBegan, self._connections)
    UIHelpers.SafeConnect(container.InputEnded, onInputEnded, self._connections)
    UIHelpers.SafeConnect(knob.InputBegan, onInputBegan, self._connections)
    UIHelpers.SafeConnect(knob.InputEnded, onInputEnded, self._connections)

    -- Drag update
    UIHelpers.SafeConnect(RunService.RenderStepped, function()
        if dragging then
            local mouse = game.Players.LocalPlayer:GetMouse()
            updateFromInput(mouse.X)
        end
    end, self._connections)

    -- Public methods
    function self:SetValue(v)
        setValue(v, true)
    end

    function self:GetValue()
        return self.Value
    end

    function self:Destroy()
        UIHelpers.CleanupConnections(self._connections)
        if self.OnChanged then
            self.OnChanged:Destroy()
        end
        container:Destroy()
    end

    -- Add to parent connections if provided
    if connTable then
        for _, conn in ipairs(self._connections) do
            table.insert(connTable, conn)
        end
    end

    return self
end

-- ========================================
-- MAIN UI CREATION
-- ========================================
function StoppedUI:Create(config)
    local self = setmetatable({}, StoppedUI)
    
    config = config or {}
    self.Name = config.Name or "StoppedUI"
    self.Theme = config.Theme and StoppedUI.Themes[config.Theme] or StoppedUI.Themes.Dark
    self.DefaultNotificationDuration = config.DefaultNotificationDuration or 5
    self.MaxNotifications = config.MaxNotifications or 6
    self.NotificationBellImgurHash = config.NotificationBellImgurHash or "3926305904"
    self.Locale = config.Locale or "en"
    self.ShowPreview = config.ShowPreview == nil and false or config.ShowPreview
    self.ConfigEnabled = config.ConfigEnabled or false
    self.TranslationEnabled = config.TranslationEnabled or false
    self.DevMode = config.DevMode or false
    self.LayoutMode = config.LayoutMode or StoppedUI.LayoutModes.Normal
    self.EnableSplitter = config.EnableSplitter == nil and true or config.EnableSplitter
    self.SnapToEdges = config.SnapToEdges == nil and true or config.SnapToEdges
    self.SnapDistance = config.SnapDistance or 10
    
    self._imgCache = {}
    self._keybinds = {}
    self._notificationPool = {}
    self._recentNotif = {}
    self._allConnections = {}
    self._translatedElements = {}
    self._sliders = {}
    self._elements = {}
    self._leftPaneWidth = 0.42  -- Fluid width (42% of container)
    self._minLeftPaneWidth = 280
    self._maxLeftPaneWidth = 600
    self._commandPaletteVisible = false

    if not self.FallbackImages then
        self.FallbackImages = {"https://i.imgur.com/placeholder.png"}
    end
    
    -- Config System (Hook-based, not automatic)
    self.Config = {
        Enabled = self.ConfigEnabled,
        OnRequestSave = Instance.new("BindableEvent"),
        OnRequestLoad = Instance.new("BindableEvent"),
        GetState = function()
            return self:GetConfigState()
        end,
        SetState = function(state)
            return self:SetConfigState(state)
        end
    }
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "StoppedUI_" .. math.random(1000, 9999)
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        self.ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = game:GetService("CoreGui")
    else
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    self:CreateNotificationBell()
    self:CreateMainContainer()
    self:SetupResponsiveness()
    
    -- Initialize new systems
    self:EnhanceNotificationSystem()
    self:CreateThemeStore()
    self:CreateHotkeyCustomizer()
    self:CreateNotificationHistory()
    self:CreateQuickActionsBar()
    
    if self.DevMode then
        self:CreateProfilerPane()
    end
    
    -- Opening animation
    self.Container.Size = UDim2.new(0, 0, 0, 0)
    self.Container.BackgroundTransparency = 1
    UIHelpers.Tween(self.Container, {Size = UDim2.new(0, 800, 0, 550)}, 0.5)
    UIHelpers.Tween(self.Container, {BackgroundTransparency = 0}, 0.4)
    
    return self
end

function StoppedUI:CreateMainContainer()
    -- Calculate responsive initial position
    local viewport = workspace.CurrentCamera.ViewportSize
    local initialX = UIHelpers.Clamp(viewport.X * 0.06, 16, 300)
    local initialY = UIHelpers.Clamp(viewport.Y * 0.12, 16, 250)
    
    -- Main Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "MainContainer"
    self.Container.Size = UDim2.new(0, 800, 0, 550)
    self.Container.Position = UDim2.new(0, initialX, 0, initialY)
    self.Container.AnchorPoint = Vector2.new(0, 0)
    self.Container.BackgroundColor3 = self.Theme.Background
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.Parent = self.ScreenGui
    UIHelpers.CreateRound(self.Container, self.Theme.Radius + 4)
    UIHelpers.CreateStroke(self.Container, self.Theme.Border, 2, 0.3)
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.4
    shadow.ZIndex = -1
    shadow.Parent = self.Container
    
    self:CreateTopbar()
    self:CreateContent()
    self:CreateFooter()
    self:MakeDraggable()
    
    self.Tabs = {}
    self.CurrentTab = nil
end

function StoppedUI:CreateTopbar()
    -- Topbar
    self.Topbar = Instance.new("Frame")
    self.Topbar.Name = "Topbar"
    self.Topbar.Size = UDim2.new(1, 0, 0, 50)
    self.Topbar.BackgroundColor3 = self.Theme.Card
    self.Topbar.BorderSizePixel = 0
    self.Topbar.Parent = self.Container
    UIHelpers.CreateRound(self.Topbar, self.Theme.Radius + 4)
    
    local topbarBorder = Instance.new("Frame")
    topbarBorder.Size = UDim2.new(1, 0, 0, 2)
    topbarBorder.Position = UDim2.new(0, 0, 1, 0)
    topbarBorder.BackgroundColor3 = self.Theme.Accent
    topbarBorder.BorderSizePixel = 0
    topbarBorder.Parent = self.Topbar
    
    -- Title (Centered)
    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.Size = UDim2.new(0, 200, 1, 0)
    self.Title.Position = UDim2.new(0, 60, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = self.Name
    self.Title.TextColor3 = self.Theme.Text
    self.Title.TextSize = 18
    self.Title.Font = Enum.Font.GothamBold
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.TextYAlignment = Enum.TextYAlignment.Center
    self.Title.Parent = self.Topbar
    
    -- Logo
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0, 15, 0.5, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.ImageColor3 = self.Theme.Accent
    logo.Parent = self.Topbar
    UIHelpers.CreateRound(logo, 6)
    self.Logo = logo
    
    -- if config.Logo then
    --     logo.Image = UIHelpers.ResolveImage(config.Logo)
    -- else
    --     logo.Image = "N"
    -- end
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = self.Theme.Card
    closeBtn.Text = "×"
    closeBtn.TextColor3 = self.Theme.Text
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = self.Topbar
    UIHelpers.CreateRound(closeBtn, self.Theme.Radius)
    
    UIHelpers.SafeConnect(closeBtn.MouseEnter, function()
        UIHelpers.Tween(closeBtn, {BackgroundColor3 = self.Theme.Error}, 0.2)
    end, self._allConnections)
    
    UIHelpers.SafeConnect(closeBtn.MouseLeave, function()
        UIHelpers.Tween(closeBtn, {BackgroundColor3 = self.Theme.Card}, 0.2)
    end, self._allConnections)
    
    UIHelpers.SafeConnect(closeBtn.MouseButton1Click, function()
        self:Hide()
    end, self._allConnections)
end

function StoppedUI:CreateContent()
    -- Content Container
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -20, 1, -110)
    self.Content.Position = UDim2.new(0, 10, 0, 60)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Container
    
    -- Top Tab Bar
    self.TopTabBar = Instance.new("Frame")
    self.TopTabBar.Size = UDim2.new(1, -20, 0, 50)
    self.TopTabBar.Position = UDim2.new(0, 10, 0, 10)
    self.TopTabBar.BackgroundTransparency = 1
    self.TopTabBar.Parent = self.Content
    
    local tabsRow = Instance.new("Frame")
    tabsRow.Size = UDim2.new(1, 0, 1, 0)
    tabsRow.BackgroundTransparency = 1
    tabsRow.Parent = self.TopTabBar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.Parent = tabsRow
    
    self.TabButtonContainer = tabsRow
    
    -- Left Pane (Scrollable) - FLUID WIDTH
    self.LeftPane = Instance.new("ScrollingFrame")
    self.LeftPane.Name = "LeftPane"
    self.LeftPane.Size = UDim2.new(self._leftPaneWidth, 0, 1, -70)
    self.LeftPane.Position = UDim2.new(0, 10, 0, 70)
    self.LeftPane.BackgroundTransparency = 1
    self.LeftPane.BorderSizePixel = 0
    self.LeftPane.ScrollBarThickness = 4
    self.LeftPane.ScrollBarImageColor3 = self.Theme.Accent
    self.LeftPane.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.LeftPane.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.LeftPane.Parent = self.Content
    UIHelpers.CreatePadding(self.LeftPane, 5)
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 10)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = self.LeftPane
    
    -- Create Splitter (if enabled)
    if self.EnableSplitter and self.ShowPreview then
        self:CreateSplitter()
    end
    
    -- Preview Pane
    self:CreatePreviewPane()
    
    -- Command Palette
    self:CreateCommandPalette()
    
    -- Dev Mode Inspector (if enabled)
    if self.DevMode then
        self:CreateDevModeInspector()
    end
end

function StoppedUI:CreatePreviewPane()
    self.PreviewPane = Instance.new("Frame")
    self.PreviewPane.Name = "PreviewPane"
    self.PreviewPane.Size = UDim2.new(1 - self._leftPaneWidth, -30, 1, -70)
    self.PreviewPane.Position = UDim2.new(self._leftPaneWidth, 20, 0, 70)
    self.PreviewPane.BackgroundColor3 = self.Theme.Card
    self.PreviewPane.BorderSizePixel = 0
    self.PreviewPane.Visible = self.ShowPreview
    self.PreviewPane.Parent = self.Content
    UIHelpers.CreateRound(self.PreviewPane, self.Theme.Radius)
    UIHelpers.CreateStroke(self.PreviewPane, self.Theme.Border, 1, 0.85)
    
    local previewCanvas = Instance.new("Frame")
    previewCanvas.Name = "PreviewCanvas"
    previewCanvas.Size = UDim2.new(1, -20, 1, -60)
    previewCanvas.Position = UDim2.new(0, 10, 0, 10)
    previewCanvas.BackgroundTransparency = 1
    previewCanvas.ClipsDescendants = true
    previewCanvas.Parent = self.PreviewPane
    
    -- Preview Label (CENTERED)
    local previewLabel = Instance.new("TextLabel")
    previewLabel.Name = "PreviewLabel"
    previewLabel.Size = UDim2.new(1, -20, 0, 24)
    previewLabel.Position = UDim2.new(0.5, 0, 0, 10)
    previewLabel.AnchorPoint = Vector2.new(0.5, 0)
    previewLabel.BackgroundTransparency = 1
    previewLabel.Text = self:Tr("Preview")
    previewLabel.TextColor3 = self.Theme.TextDim
    previewLabel.Font = Enum.Font.Gotham
    previewLabel.TextSize = 12
    previewLabel.TextXAlignment = Enum.TextXAlignment.Center
    previewLabel.TextYAlignment = Enum.TextYAlignment.Center
    previewLabel.TextWrapped = false
    previewLabel.Parent = previewCanvas
    
    self.PreviewCanvas = previewCanvas
    
    -- Preview Footer
    local previewFooter = Instance.new("Frame")
    previewFooter.Size = UDim2.new(1, -20, 0, 40)
    previewFooter.Position = UDim2.new(0, 10, 1, -50)
    previewFooter.BackgroundColor3 = self.Theme.Secondary
    previewFooter.BorderSizePixel = 0
    previewFooter.Parent = self.PreviewPane
    UIHelpers.CreateRound(previewFooter, self.Theme.Radius - 2)
    
    local previewModeLabel = Instance.new("TextLabel")
    previewModeLabel.Size = UDim2.new(0, 80, 1, 0)
    previewModeLabel.Position = UDim2.new(0, 10, 0, 0)
    previewModeLabel.BackgroundTransparency = 1
    previewModeLabel.Text = self:Tr("Mode")
    previewModeLabel.TextColor3 = self.Theme.TextDim
    previewModeLabel.Font = Enum.Font.Gotham
    previewModeLabel.TextSize = 12
    previewModeLabel.TextXAlignment = Enum.TextXAlignment.Left
    previewModeLabel.TextYAlignment = Enum.TextYAlignment.Center
    previewModeLabel.Parent = previewFooter
    
    local previewModeBtn = Instance.new("TextButton")
    previewModeBtn.Size = UDim2.new(0, 100, 0, 28)
    previewModeBtn.Position = UDim2.new(0, 90, 0, 6)
    previewModeBtn.BackgroundColor3 = self.Theme.Accent
    previewModeBtn.Text = self:Tr("Players")
    previewModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    previewModeBtn.Font = Enum.Font.GothamBold
    previewModeBtn.TextSize = 12
    previewModeBtn.BorderSizePixel = 0
    previewModeBtn.Parent = previewFooter
    UIHelpers.CreateRound(previewModeBtn, self.Theme.Radius - 2)
    
    self.PreviewMode = "Players"
    UIHelpers.SafeConnect(previewModeBtn.MouseButton1Click, function()
        self.PreviewMode = (self.PreviewMode == "Players") and "Vehicles" or "Players"
        previewModeBtn.Text = self:Tr(self.PreviewMode)
    end, self._allConnections)
end

-- ========================================
-- SPLITTER (Drag-Resize)
-- ========================================
function StoppedUI:CreateSplitter()
    local splitter = Instance.new("Frame")
    splitter.Name = "Splitter"
    splitter.Size = UDim2.new(0, 6, 1, -70)
    splitter.Position = UDim2.new(self._leftPaneWidth, 10, 0, 70)
    splitter.BackgroundColor3 = self.Theme.Accent
    splitter.BackgroundTransparency = 0.92
    splitter.BorderSizePixel = 0
    splitter.ZIndex = 10
    splitter.Parent = self.Content
    UIHelpers.CreateRound(splitter, 3)
    
    -- Glow effect on hover
    local splitterGlow = Instance.new("Frame")
    splitterGlow.Name = "Glow"
    splitterGlow.Size = UDim2.new(1, 4, 1, 0)
    splitterGlow.Position = UDim2.new(0.5, 0, 0, 0)
    splitterGlow.AnchorPoint = Vector2.new(0.5, 0)
    splitterGlow.BackgroundColor3 = self.Theme.Accent
    splitterGlow.BackgroundTransparency = 1
    splitterGlow.BorderSizePixel = 0
    splitterGlow.ZIndex = 9
    splitterGlow.Parent = splitter
    UIHelpers.CreateRound(splitterGlow, 4)
    
    self.Splitter = splitter
    
    -- Hover effects
    UIHelpers.SafeConnect(splitter.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            UIHelpers.Tween(splitter, {BackgroundTransparency = 0.7}, 0.2)
            UIHelpers.Tween(splitterGlow, {BackgroundTransparency = 0.85}, 0.2)
        end
    end, self._allConnections)
    
    UIHelpers.SafeConnect(splitter.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            UIHelpers.Tween(splitter, {BackgroundTransparency = 0.92}, 0.2)
            UIHelpers.Tween(splitterGlow, {BackgroundTransparency = 1}, 0.2)
        end
    end, self._allConnections)
    
    -- Drag logic
    local dragging = false
    local dragConn
    
    UIHelpers.SafeConnect(splitter.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            
            -- Enhanced glow during drag
            UIHelpers.Tween(splitter, {BackgroundTransparency = 0.5}, 0.15)
            UIHelpers.Tween(splitterGlow, {BackgroundTransparency = 0.7}, 0.15)
            
            dragConn = UIHelpers.SafeConnect(RunService.RenderStepped, function()
                if not dragging then return end
                
                local mouse = game.Players.LocalPlayer:GetMouse()
                local containerPos = self.Content.AbsolutePosition.X
                local containerWidth = self.Content.AbsoluteSize.X
                local relativeX = mouse.X - containerPos
                
                -- Calculate fraction
                local frac = relativeX / containerWidth
                
                -- Calculate absolute left pane width
                local leftWidth = frac * containerWidth
                
                -- Clamp to min/max
                leftWidth = UIHelpers.Clamp(leftWidth, self._minLeftPaneWidth, math.min(self._maxLeftPaneWidth, containerWidth - 100))
                
                -- Update fraction
                self._leftPaneWidth = leftWidth / containerWidth
                
                -- Update layouts with smooth transition
                self:UpdatePaneLayout(true)
            end, self._allConnections)
        end
    end, self._allConnections)
    
    UIHelpers.SafeConnect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            
            -- Reset glow
            UIHelpers.Tween(splitter, {BackgroundTransparency = 0.92}, 0.2)
            UIHelpers.Tween(splitterGlow, {BackgroundTransparency = 1}, 0.2)
            
            if dragConn then
                dragConn:Disconnect()
                dragConn = nil
            end
        end
    end, self._allConnections)
end

function StoppedUI:UpdatePaneLayout(animate)
    if not self.LeftPane or not self.PreviewPane or not self.Splitter then return end
    
    local duration = animate and 0.08 or 0
    
    -- Update LeftPane
    UIHelpers.Tween(self.LeftPane, {Size = UDim2.new(self._leftPaneWidth, 0, 1, -70)}, duration)
    
    -- Update Splitter
    UIHelpers.Tween(self.Splitter, {Position = UDim2.new(self._leftPaneWidth, 10, 0, 70)}, duration)
    
    -- Update PreviewPane
    UIHelpers.Tween(self.PreviewPane, {
        Size = UDim2.new(1 - self._leftPaneWidth, -30, 1, -70),
        Position = UDim2.new(self._leftPaneWidth, 20, 0, 70)
    }, duration)
end

-- ========================================
-- COMMAND PALETTE (Ctrl+K)
-- ========================================
function StoppedUI:CreateCommandPalette()
    local palette = Instance.new("Frame")
    palette.Name = "CommandPalette"
    palette.Size = UDim2.new(0, 500, 0, 400)
    palette.Position = UDim2.new(0.5, 0, 0.5, 0)
    palette.AnchorPoint = Vector2.new(0.5, 0.5)
    palette.BackgroundColor3 = self.Theme.Card
    palette.BorderSizePixel = 0
    palette.Visible = false
    palette.ZIndex = 1000
    palette.Parent = self.Container
    UIHelpers.CreateRound(palette, self.Theme.Radius)
    UIHelpers.CreateStroke(palette, self.Theme.Accent, 2, 0.5)
    
    -- Shadow
    local paletteShadow = Instance.new("ImageLabel")
    paletteShadow.Size = UDim2.new(1, 30, 1, 30)
    paletteShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    paletteShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    paletteShadow.BackgroundTransparency = 1
    paletteShadow.Image = "rbxassetid://5554236805"
    paletteShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    paletteShadow.ImageTransparency = 0.3
    paletteShadow.ZIndex = 999
    paletteShadow.Parent = palette
    
    -- Header
    local paletteHeader = Instance.new("Frame")
    paletteHeader.Size = UDim2.new(1, 0, 0, 50)
    paletteHeader.BackgroundColor3 = self.Theme.Secondary
    paletteHeader.BorderSizePixel = 0
    paletteHeader.Parent = palette
    UIHelpers.CreateRound(paletteHeader, self.Theme.Radius)
    
    -- Search Box
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20, 1, -10)
    searchBox.Position = UDim2.new(0, 10, 0, 5)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "🔍 Search commands..."
    searchBox.PlaceholderColor3 = self.Theme.TextDim
    searchBox.Text = ""
    searchBox.TextColor3 = self.Theme.Text
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = paletteHeader
    
    -- Results container
    local resultsScroll = Instance.new("ScrollingFrame")
    resultsScroll.Size = UDim2.new(1, -20, 1, -70)
    resultsScroll.Position = UDim2.new(0, 10, 0, 55)
    resultsScroll.BackgroundTransparency = 1
    resultsScroll.BorderSizePixel = 0
    resultsScroll.ScrollBarThickness = 4
    resultsScroll.ScrollBarImageColor3 = self.Theme.Accent
    resultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    resultsScroll.Parent = palette
    
    local resultsList = Instance.new("UIListLayout")
    resultsList.Padding = UDim.new(0, 4)
    resultsList.SortOrder = Enum.SortOrder.LayoutOrder
    resultsList.Parent = resultsScroll
    
    self.CommandPalette = {
        Container = palette,
        SearchBox = searchBox,
        ResultsScroll = resultsScroll,
        Commands = {}
    }
    
    -- Register default commands
    self:RegisterCommand("Toggle UI", "Hide/Show the main window", function()
        self:Toggle()
    end)
    
    self:RegisterCommand("Toggle Preview", "Show/Hide preview pane", function()
        self.ShowPreview = not self.ShowPreview
        self.PreviewPane.Visible = self.ShowPreview
        if self.Splitter then
            self.Splitter.Visible = self.ShowPreview and self.EnableSplitter
        end
    end)
    
    self:RegisterCommand("Toggle Dev Mode", "Enable/Disable developer mode", function()
        self:ToggleDevMode()
    end)
    
    self:RegisterCommand("Open Theme Store", "Browse and apply themes", function()
        self:ToggleThemeStore()
    end)
    
    self:RegisterCommand("Open Hotkey Manager", "Customize keyboard shortcuts", function()
        self:ToggleHotkeyCustomizer()
    end)
    
    self:RegisterCommand("View Notification History", "See all past notifications", function()
        self:ToggleNotificationHistory()
    end)
    
    self:RegisterCommand("Toggle Profiler", "Show/Hide performance profiler", function()
        self:ToggleProfiler()
    end)
    
    self:RegisterCommand("Toggle Quick Actions", "Show/Hide quick action bar", function()
        self:ToggleQuickActions()
    end)
    
    self:RegisterCommand("Compact Layout", "Switch to compact mode", function()
        self:SetLayoutMode("Compact")
    end)
    
    self:RegisterCommand("Normal Layout", "Switch to normal mode", function()
        self:SetLayoutMode("Normal")
    end)
    
    self:RegisterCommand("Expanded Layout", "Switch to expanded mode", function()
        self:SetLayoutMode("Expanded")
    end)
    
    self:RegisterCommand("Center Window", "Move window to screen center", function()
        local viewport = workspace.CurrentCamera.ViewportSize
        self.Container.Position = UDim2.new(
            0, (viewport.X - 800) / 2,
            0, (viewport.Y - 550) / 2
        )
        self:Notify({Text = "Window centered", Type = "Success", Duration = 1.5})
    end)
    
    self:RegisterCommand("List Snippets", "Show all saved snippets", function()
        local snippets = self:ListSnippets()
        if #snippets == 0 then
            self:Notify({Text = "No snippets saved", Type = "Info", Duration = 2})
        else
            local text = "Saved snippets: " .. #snippets
            self:Notify({Text = text, Type = "Info", Duration = 3})
        end
    end)
    
    self:RegisterCommand("Clear Notification History", "Delete all notification history", function()
        self.NotificationHistory = {}
        self:Notify({Text = "History cleared", Type = "Success", Duration = 2})
    end)
    
    -- Only add config commands if enabled
    if self.ConfigEnabled then
        self:RegisterCommand("Save Config", "Save current configuration", function()
            self:RequestSave()
        end)
        
        self:RegisterCommand("Load Config", "Load saved configuration", function()
            self:RequestLoad()
        end)
    end
    
    -- Search functionality
    UIHelpers.SafeConnect(searchBox:GetPropertyChangedSignal("Text"), function()
        self:FilterCommands(searchBox.Text)
    end, self._allConnections)
    
    -- Keyboard shortcut (Ctrl+K)
    UIHelpers.SafeConnect(UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Ctrl+K or Cmd+K
        if (input.KeyCode == Enum.KeyCode.K) and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            self:ToggleCommandPalette()
        end
        
        -- Escape to close
        if input.KeyCode == Enum.KeyCode.Escape and palette.Visible then
            self:ToggleCommandPalette()
        end
    end, self._allConnections)
    
    -- Focus search box when opened
    UIHelpers.SafeConnect(palette:GetPropertyChangedSignal("Visible"), function()
        if palette.Visible then
            task.wait(0.1)
            searchBox:CaptureFocus()
            self:FilterCommands("")
        end
    end, self._allConnections)
end

function StoppedUI:RegisterCommand(name, description, callback)
    table.insert(self.CommandPalette.Commands, {
        Name = name,
        Description = description,
        Callback = callback
    })
end

function StoppedUI:FilterCommands(query)
    local resultsScroll = self.CommandPalette.ResultsScroll
    
    -- Clear existing results
    for _, child in ipairs(resultsScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    query = query:lower()
    
    -- Add matching commands
    for _, cmd in ipairs(self.CommandPalette.Commands) do
        if query == "" or cmd.Name:lower():find(query) or cmd.Description:lower():find(query) then
            local cmdButton = Instance.new("TextButton")
            cmdButton.Size = UDim2.new(1, 0, 0, 50)
            cmdButton.BackgroundColor3 = self.Theme.Background
            cmdButton.BorderSizePixel = 0
            cmdButton.Text = ""
            cmdButton.Parent = resultsScroll
            UIHelpers.CreateRound(cmdButton, self.Theme.Radius - 2)
            
            local cmdName = Instance.new("TextLabel")
            cmdName.Size = UDim2.new(1, -16, 0, 20)
            cmdName.Position = UDim2.new(0, 8, 0, 6)
            cmdName.BackgroundTransparency = 1
            cmdName.Text = cmd.Name
            cmdName.TextColor3 = self.Theme.Text
            cmdName.TextSize = 13
            cmdName.Font = Enum.Font.GothamBold
            cmdName.TextXAlignment = Enum.TextXAlignment.Left
            cmdName.Parent = cmdButton
            
            local cmdDesc = Instance.new("TextLabel")
            cmdDesc.Size = UDim2.new(1, -16, 0, 16)
            cmdDesc.Position = UDim2.new(0, 8, 0, 28)
            cmdDesc.BackgroundTransparency = 1
            cmdDesc.Text = cmd.Description
            cmdDesc.TextColor3 = self.Theme.TextDim
            cmdDesc.TextSize = 11
            cmdDesc.Font = Enum.Font.Gotham
            cmdDesc.TextXAlignment = Enum.TextXAlignment.Left
            cmdDesc.Parent = cmdButton
            
            UIHelpers.SafeConnect(cmdButton.MouseEnter, function()
                UIHelpers.Tween(cmdButton, {BackgroundColor3 = self.Theme.Secondary}, 0.15)
            end, self._allConnections)
            
            UIHelpers.SafeConnect(cmdButton.MouseLeave, function()
                UIHelpers.Tween(cmdButton, {BackgroundColor3 = self.Theme.Background}, 0.15)
            end, self._allConnections)
            
            UIHelpers.SafeConnect(cmdButton.MouseButton1Click, function()
                self:ToggleCommandPalette()
                pcall(cmd.Callback)
            end, self._allConnections)
        end
    end
end

function StoppedUI:ToggleCommandPalette()
    local palette = self.CommandPalette.Container
    palette.Visible = not palette.Visible
    
    if palette.Visible then
        palette.Size = UDim2.new(0, 0, 0, 0)
        palette.BackgroundTransparency = 1
        UIHelpers.Tween(palette, {Size = UDim2.new(0, 500, 0, 400)}, 0.25)
        UIHelpers.Tween(palette, {BackgroundTransparency = 0}, 0.2)
    else
        UIHelpers.Tween(palette, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        UIHelpers.Tween(palette, {BackgroundTransparency = 1}, 0.2)
    end
end

-- ========================================
-- THEME STORE & LIVE PREVIEW
-- ========================================
function StoppedUI:CreateThemeStore()
    local themeStore = Instance.new("Frame")
    themeStore.Name = "ThemeStore"
    themeStore.Size = UDim2.new(0, 600, 0, 500)
    themeStore.Position = UDim2.new(0.5, 0, 0.5, 0)
    themeStore.AnchorPoint = Vector2.new(0.5, 0.5)
    themeStore.BackgroundColor3 = self.Theme.Card
    themeStore.BorderSizePixel = 0
    themeStore.Visible = false
    themeStore.ZIndex = 1000
    themeStore.Parent = self.Container
    UIHelpers.CreateRound(themeStore, self.Theme.Radius)
    UIHelpers.CreateStroke(themeStore, self.Theme.Accent, 2, 0.5)
    
    -- Header
    local themeHeader = Instance.new("Frame")
    themeHeader.Size = UDim2.new(1, 0, 0, 50)
    themeHeader.BackgroundColor3 = self.Theme.Secondary
    themeHeader.BorderSizePixel = 0
    themeHeader.Parent = themeStore
    UIHelpers.CreateRound(themeHeader, self.Theme.Radius)
    
    local themeTitle = Instance.new("TextLabel")
    themeTitle.Size = UDim2.new(1, -100, 1, 0)
    themeTitle.Position = UDim2.new(0, 20, 0, 0)
    themeTitle.BackgroundTransparency = 1
    themeTitle.Text = "🎨 Theme Store"
    themeTitle.TextColor3 = self.Theme.Text
    themeTitle.TextSize = 16
    themeTitle.Font = Enum.Font.GothamBold
    themeTitle.TextXAlignment = Enum.TextXAlignment.Left
    themeTitle.TextYAlignment = Enum.TextYAlignment.Center
    themeTitle.Parent = themeHeader
    
    -- Close button
    local closeThemeBtn = Instance.new("TextButton")
    closeThemeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeThemeBtn.Position = UDim2.new(1, -40, 0.5, 0)
    closeThemeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeThemeBtn.BackgroundColor3 = self.Theme.Background
    closeThemeBtn.Text = "×"
    closeThemeBtn.TextColor3 = self.Theme.Text
    closeThemeBtn.TextSize = 20
    closeThemeBtn.Font = Enum.Font.GothamBold
    closeThemeBtn.BorderSizePixel = 0
    closeThemeBtn.Parent = themeHeader
    UIHelpers.CreateRound(closeThemeBtn, 6)
    
    UIHelpers.SafeConnect(closeThemeBtn.MouseButton1Click, function()
        self:ToggleThemeStore()
    end, self._allConnections)
    
    -- Theme grid
    local themeScroll = Instance.new("ScrollingFrame")
    themeScroll.Size = UDim2.new(1, -20, 1, -70)
    themeScroll.Position = UDim2.new(0, 10, 0, 55)
    themeScroll.BackgroundTransparency = 1
    themeScroll.BorderSizePixel = 0
    themeScroll.ScrollBarThickness = 6
    themeScroll.ScrollBarImageColor3 = self.Theme.Accent
    themeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    themeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    themeScroll.Parent = themeStore
    
    local themeGrid = Instance.new("UIGridLayout")
    themeGrid.CellSize = UDim2.new(0, 170, 0, 200)
    themeGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    themeGrid.SortOrder = Enum.SortOrder.LayoutOrder
    themeGrid.Parent = themeScroll
    
    UIHelpers.CreatePadding(themeScroll, 10)
    
    self.ThemeStore = {
        Container = themeStore,
        Scroll = themeScroll
    }
    
    -- Populate with available themes
    self:PopulateThemeStore()
end

function StoppedUI:PopulateThemeStore()
    local scroll = self.ThemeStore.Scroll
    
    for themeName, theme in pairs(StoppedUI.Themes) do
        local themeCard = Instance.new("Frame")
        themeCard.Name = themeName
        themeCard.BackgroundColor3 = theme.Background
        themeCard.BorderSizePixel = 0
        themeCard.Parent = scroll
        UIHelpers.CreateRound(themeCard, self.Theme.Radius)
        UIHelpers.CreateStroke(themeCard, theme.Accent, 2, 0.7)
        
        -- Theme preview
        local previewBg = Instance.new("Frame")
        previewBg.Size = UDim2.new(1, -16, 0, 100)
        previewBg.Position = UDim2.new(0, 8, 0, 8)
        previewBg.BackgroundColor3 = theme.Card
        previewBg.BorderSizePixel = 0
        previewBg.Parent = themeCard
        UIHelpers.CreateRound(previewBg, self.Theme.Radius - 2)
        
        -- Color swatches
        local swatchContainer = Instance.new("Frame")
        swatchContainer.Size = UDim2.new(1, -16, 0, 40)
        swatchContainer.Position = UDim2.new(0, 8, 0, 8)
        swatchContainer.BackgroundTransparency = 1
        swatchContainer.Parent = previewBg
        
        local swatchLayout = Instance.new("UIListLayout")
        swatchLayout.FillDirection = Enum.FillDirection.Horizontal
        swatchLayout.Padding = UDim.new(0, 4)
        swatchLayout.Parent = swatchContainer
        
        local colors = {theme.Accent, theme.Success, theme.Warning, theme.Error}
        for _, color in ipairs(colors) do
            local swatch = Instance.new("Frame")
            swatch.Size = UDim2.new(0, 30, 0, 30)
            swatch.BackgroundColor3 = color
            swatch.BorderSizePixel = 0
            swatch.Parent = swatchContainer
            UIHelpers.CreateRound(swatch, 6)
        end
        
        -- Theme name
        local themeLabelBg = Instance.new("Frame")
        themeLabelBg.Size = UDim2.new(1, -16, 0, 40)
        themeLabelBg.Position = UDim2.new(0, 8, 0, 55)
        themeLabelBg.BackgroundColor3 = theme.Secondary
        themeLabelBg.BorderSizePixel = 0
        themeLabelBg.Parent = previewBg
        UIHelpers.CreateRound(themeLabelBg, self.Theme.Radius - 2)
        
        local themeLabel = Instance.new("TextLabel")
        themeLabel.Size = UDim2.new(1, 0, 1, 0)
        themeLabel.BackgroundTransparency = 1
        themeLabel.Text = themeName
        themeLabel.TextColor3 = theme.Text
        themeLabel.TextSize = 12
        themeLabel.Font = Enum.Font.GothamBold
        themeLabel.TextXAlignment = Enum.TextXAlignment.Center
        themeLabel.TextYAlignment = Enum.TextYAlignment.Center
        themeLabel.Parent = themeLabelBg
        
        -- Apply button
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size = UDim2.new(1, -16, 0, 35)
        applyBtn.Position = UDim2.new(0, 8, 1, -43)
        applyBtn.BackgroundColor3 = theme.Accent
        applyBtn.Text = "Apply"
        applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        applyBtn.TextSize = 13
        applyBtn.Font = Enum.Font.GothamBold
        applyBtn.BorderSizePixel = 0
        applyBtn.Parent = themeCard
        UIHelpers.CreateRound(applyBtn, self.Theme.Radius - 2)
        
        -- Current theme indicator
        local currentIndicator = Instance.new("Frame")
        currentIndicator.Size = UDim2.new(0, 50, 0, 20)
        currentIndicator.Position = UDim2.new(1, -58, 0, 8)
        currentIndicator.BackgroundColor3 = theme.Success
        currentIndicator.BorderSizePixel = 0
        currentIndicator.Visible = (themeName == "Dark")  -- Default
        currentIndicator.Parent = themeCard
        UIHelpers.CreateRound(currentIndicator, 4)
        
        local currentLabel = Instance.new("TextLabel")
        currentLabel.Size = UDim2.new(1, 0, 1, 0)
        currentLabel.BackgroundTransparency = 1
        currentLabel.Text = "✓"
        currentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        currentLabel.TextSize = 12
        currentLabel.Font = Enum.Font.GothamBold
        currentLabel.TextXAlignment = Enum.TextXAlignment.Center
        currentLabel.Parent = currentIndicator
        
        UIHelpers.SafeConnect(applyBtn.MouseButton1Click, function()
            self:ApplyTheme(themeName)
            
            -- Update indicators
            for _, card in ipairs(scroll:GetChildren()) do
                if card:IsA("Frame") then
                    local indicator = card:FindFirstChild("Frame")
                    if indicator and indicator.Name ~= "Frame" then
                        indicator.Visible = (card.Name == themeName)
                    end
                end
            end
        end, self._allConnections)
        
        UIHelpers.SafeConnect(applyBtn.MouseEnter, function()
            UIHelpers.Tween(applyBtn, {Size = UDim2.new(1, -12, 0, 37)}, 0.1)
        end, self._allConnections)
        
        UIHelpers.SafeConnect(applyBtn.MouseLeave, function()
            UIHelpers.Tween(applyBtn, {Size = UDim2.new(1, -16, 0, 35)}, 0.1)
        end, self._allConnections)
    end
end

function StoppedUI:ApplyTheme(themeName)
    if not StoppedUI.Themes[themeName] then return end
    
    self.Theme = StoppedUI.Themes[themeName]
    
    -- Update all UI elements with new theme
    -- Container
    self.Container.BackgroundColor3 = self.Theme.Background
    local containerStroke = self.Container:FindFirstChildOfClass("UIStroke")
    if containerStroke then
        containerStroke.Color = self.Theme.Border
    end
    
    -- Topbar
    self.Topbar.BackgroundColor3 = self.Theme.Card
    self.Title.TextColor3 = self.Theme.Text
    
    if self.Logo then
        self.Logo.ImageColor3 = self.Theme.Accent
    end
    
    -- Update all elements
    self:UpdateThemeForAllElements()
    
    self:Notify({
        Text = "Theme applied: " .. themeName,
        Type = "Success",
        Duration = 2
    })
end

function StoppedUI:UpdateThemeForAllElements()
    -- Update LeftPane, PreviewPane, etc.
    if self.LeftPane then
        self.LeftPane.ScrollBarImageColor3 = self.Theme.Accent
    end
    
    if self.PreviewPane then
        self.PreviewPane.BackgroundColor3 = self.Theme.Card
        local stroke = self.PreviewPane:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = self.Theme.Border end
    end
    
    -- Update all tabs
    for _, tab in ipairs(self.Tabs) do
        for _, element in ipairs(tab.Elements) do
            if element.Container then
                local bg = element.Container:FindFirstChildOfClass("UIStroke")
                if bg then bg.Color = self.Theme.Border end
                
                if element.Type == "Toggle" then
                    -- Update toggle colors if needed
                elseif element.Type == "Slider" then
                    -- Update slider colors
                    if element.Slider then
                        element.Slider.Fill.BackgroundColor3 = self.Theme.Accent
                        element.Slider.Knob.BackgroundColor3 = self.Theme.Accent
                    end
                end
            end
        end
    end
end

function StoppedUI:ToggleThemeStore()
    local store = self.ThemeStore.Container
    store.Visible = not store.Visible
    
    if store.Visible then
        store.Size = UDim2.new(0, 0, 0, 0)
        store.BackgroundTransparency = 1
        UIHelpers.Tween(store, {Size = UDim2.new(0, 600, 0, 500)}, 0.25)
        UIHelpers.Tween(store, {BackgroundTransparency = 0}, 0.2)
    else
        UIHelpers.Tween(store, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        UIHelpers.Tween(store, {BackgroundTransparency = 1}, 0.2)
    end
end

-- ========================================
-- HOTKEY CUSTOMIZER
-- ========================================
function StoppedUI:CreateHotkeyCustomizer()
    local hotkeyPanel = Instance.new("Frame")
    hotkeyPanel.Name = "HotkeyCustomizer"
    hotkeyPanel.Size = UDim2.new(0, 500, 0, 450)
    hotkeyPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    hotkeyPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    hotkeyPanel.BackgroundColor3 = self.Theme.Card
    hotkeyPanel.BorderSizePixel = 0
    hotkeyPanel.Visible = false
    hotkeyPanel.ZIndex = 1000
    hotkeyPanel.Parent = self.Container
    UIHelpers.CreateRound(hotkeyPanel, self.Theme.Radius)
    UIHelpers.CreateStroke(hotkeyPanel, self.Theme.Accent, 2, 0.5)
    
    -- Header
    local hotkeyHeader = Instance.new("Frame")
    hotkeyHeader.Size = UDim2.new(1, 0, 0, 50)
    hotkeyHeader.BackgroundColor3 = self.Theme.Secondary
    hotkeyHeader.BorderSizePixel = 0
    hotkeyHeader.Parent = hotkeyPanel
    UIHelpers.CreateRound(hotkeyHeader, self.Theme.Radius)
    
    local hotkeyTitle = Instance.new("TextLabel")
    hotkeyTitle.Size = UDim2.new(1, -100, 1, 0)
    hotkeyTitle.Position = UDim2.new(0, 20, 0, 0)
    hotkeyTitle.BackgroundTransparency = 1
    hotkeyTitle.Text = "⌨️ Hotkey Manager"
    hotkeyTitle.TextColor3 = self.Theme.Text
    hotkeyTitle.TextSize = 16
    hotkeyTitle.Font = Enum.Font.GothamBold
    hotkeyTitle.TextXAlignment = Enum.TextXAlignment.Left
    hotkeyTitle.TextYAlignment = Enum.TextYAlignment.Center
    hotkeyTitle.Parent = hotkeyHeader
    
    -- Close button
    local closeHotkeyBtn = Instance.new("TextButton")
    closeHotkeyBtn.Size = UDim2.new(0, 30, 0, 30)
    closeHotkeyBtn.Position = UDim2.new(1, -40, 0.5, 0)
    closeHotkeyBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeHotkeyBtn.BackgroundColor3 = self.Theme.Background
    closeHotkeyBtn.Text = "×"
    closeHotkeyBtn.TextColor3 = self.Theme.Text
    closeHotkeyBtn.TextSize = 20
    closeHotkeyBtn.Font = Enum.Font.GothamBold
    closeHotkeyBtn.BorderSizePixel = 0
    closeHotkeyBtn.Parent = hotkeyHeader
    UIHelpers.CreateRound(closeHotkeyBtn, 6)
    
    UIHelpers.SafeConnect(closeHotkeyBtn.MouseButton1Click, function()
        self:ToggleHotkeyCustomizer()
    end, self._allConnections)
    
    -- Hotkey list
    local hotkeyScroll = Instance.new("ScrollingFrame")
    hotkeyScroll.Size = UDim2.new(1, -20, 1, -70)
    hotkeyScroll.Position = UDim2.new(0, 10, 0, 55)
    hotkeyScroll.BackgroundTransparency = 1
    hotkeyScroll.BorderSizePixel = 0
    hotkeyScroll.ScrollBarThickness = 6
    hotkeyScroll.ScrollBarImageColor3 = self.Theme.Accent
    hotkeyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    hotkeyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    hotkeyScroll.Parent = hotkeyPanel
    
    local hotkeyList = Instance.new("UIListLayout")
    hotkeyList.Padding = UDim.new(0, 8)
    hotkeyList.SortOrder = Enum.SortOrder.LayoutOrder
    hotkeyList.Parent = hotkeyScroll
    
    UIHelpers.CreatePadding(hotkeyScroll, 10)
    
    self.HotkeyCustomizer = {
        Container = hotkeyPanel,
        Scroll = hotkeyScroll,
        Hotkeys = {}
    }
    
    -- Add default hotkeys
    self:RegisterHotkey("Toggle UI", Enum.KeyCode.RightShift, function()
        self:Toggle()
    end)
    
    self:RegisterHotkey("Command Palette", Enum.KeyCode.K, function()
        -- Ctrl+K handled elsewhere
    end, {Ctrl = true})
    
    self:PopulateHotkeyList()
end

function StoppedUI:RegisterHotkey(name, keyCode, callback, modifiers)
    modifiers = modifiers or {}
    
    local hotkey = {
        Name = name,
        KeyCode = keyCode,
        Callback = callback,
        Modifiers = modifiers
    }
    
    table.insert(self.HotkeyCustomizer.Hotkeys, hotkey)
    
    -- Setup listener
    UIHelpers.SafeConnect(UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == keyCode then
            local ctrlPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            local shiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            local altPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
            
            if (not modifiers.Ctrl or ctrlPressed) and
               (not modifiers.Shift or shiftPressed) and
               (not modifiers.Alt or altPressed) then
                pcall(callback)
            end
        end
    end, self._allConnections)
end

function StoppedUI:PopulateHotkeyList()
    local scroll = self.HotkeyCustomizer.Scroll
    
    for _, hotkey in ipairs(self.HotkeyCustomizer.Hotkeys) do
        local hotkeyRow = Instance.new("Frame")
        hotkeyRow.Size = UDim2.new(1, 0, 0, 50)
        hotkeyRow.BackgroundColor3 = self.Theme.Background
        hotkeyRow.BorderSizePixel = 0
        hotkeyRow.Parent = scroll
        UIHelpers.CreateRound(hotkeyRow, self.Theme.Radius - 2)
        UIHelpers.CreatePadding(hotkeyRow, 10)
        
        local hotkeyName = Instance.new("TextLabel")
        hotkeyName.Size = UDim2.new(0.6, 0, 1, 0)
        hotkeyName.BackgroundTransparency = 1
        hotkeyName.Text = hotkey.Name
        hotkeyName.TextColor3 = self.Theme.Text
        hotkeyName.TextSize = 13
        hotkeyName.Font = Enum.Font.Gotham
        hotkeyName.TextXAlignment = Enum.TextXAlignment.Left
        hotkeyName.TextYAlignment = Enum.TextYAlignment.Center
        hotkeyName.Parent = hotkeyRow
        
        local hotkeyDisplay = Instance.new("TextButton")
        hotkeyDisplay.Size = UDim2.new(0.35, 0, 0, 30)
        hotkeyDisplay.Position = UDim2.new(0.6, 5, 0.5, 0)
        hotkeyDisplay.AnchorPoint = Vector2.new(0, 0.5)
        hotkeyDisplay.BackgroundColor3 = self.Theme.Secondary
        hotkeyDisplay.Text = hotkey.KeyCode.Name
        hotkeyDisplay.TextColor3 = self.Theme.Accent
        hotkeyDisplay.TextSize = 12
        hotkeyDisplay.Font = Enum.Font.GothamBold
        hotkeyDisplay.BorderSizePixel = 0
        hotkeyDisplay.Parent = hotkeyRow
        UIHelpers.CreateRound(hotkeyDisplay, 6)
        
        -- Click to rebind (TODO: implement rebinding UI)
        UIHelpers.SafeConnect(hotkeyDisplay.MouseButton1Click, function()
            hotkeyDisplay.Text = "Press key..."
            -- Rebinding logic here
        end, self._allConnections)
    end
end

function StoppedUI:ToggleHotkeyCustomizer()
    local panel = self.HotkeyCustomizer.Container
    panel.Visible = not panel.Visible
    
    if panel.Visible then
        panel.Size = UDim2.new(0, 0, 0, 0)
        UIHelpers.Tween(panel, {Size = UDim2.new(0, 500, 0, 450)}, 0.25)
    else
        UIHelpers.Tween(panel, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
    end
end

-- ========================================
-- NOTIFICATION CENTER WITH HISTORY
-- ========================================
function StoppedUI:EnhanceNotificationSystem()
    self.NotificationHistory = {}
    self.MaxHistorySize = 50
    
    -- Always show panel by default
    if self.NotificationPanel then
        self.NotificationPanel.Visible = true
    end
end

function StoppedUI:AddToHistory(notification)
    table.insert(self.NotificationHistory, 1, {
        Text = notification.Text,
        SubText = notification.SubText or "",
        Type = notification.Type or "Info",
        Timestamp = os.date("%H:%M:%S"),
        ImageHash = notification.ImageHash
    })
    
    -- Limit history size
    while #self.NotificationHistory > self.MaxHistorySize do
        table.remove(self.NotificationHistory)
    end
end

function StoppedUI:CreateNotificationHistory()
    local historyPanel = Instance.new("Frame")
    historyPanel.Name = "NotificationHistory"
    historyPanel.Size = UDim2.new(0, 400, 0, 500)
    historyPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    historyPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    historyPanel.BackgroundColor3 = self.Theme.Card
    historyPanel.BorderSizePixel = 0
    historyPanel.Visible = false
    historyPanel.ZIndex = 1000
    historyPanel.Parent = self.Container
    UIHelpers.CreateRound(historyPanel, self.Theme.Radius)
    UIHelpers.CreateStroke(historyPanel, self.Theme.Accent, 2, 0.5)
    
    -- Header
    local historyHeader = Instance.new("Frame")
    historyHeader.Size = UDim2.new(1, 0, 0, 50)
    historyHeader.BackgroundColor3 = self.Theme.Secondary
    historyHeader.BorderSizePixel = 0
    historyHeader.Parent = historyPanel
    UIHelpers.CreateRound(historyHeader, self.Theme.Radius)
    
    local historyTitle = Instance.new("TextLabel")
    historyTitle.Size = UDim2.new(1, -100, 1, 0)
    historyTitle.Position = UDim2.new(0, 20, 0, 0)
    historyTitle.BackgroundTransparency = 1
    historyTitle.Text = "📜 Notification History"
    historyTitle.TextColor3 = self.Theme.Text
    historyTitle.TextSize = 16
    historyTitle.Font = Enum.Font.GothamBold
    historyTitle.TextXAlignment = Enum.TextXAlignment.Left
    historyTitle.TextYAlignment = Enum.TextYAlignment.Center
    historyTitle.Parent = historyHeader
    
    -- Clear button
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 70, 0, 30)
    clearBtn.Position = UDim2.new(1, -150, 0.5, 0)
    clearBtn.AnchorPoint = Vector2.new(0, 0.5)
    clearBtn.BackgroundColor3 = self.Theme.Error
    clearBtn.Text = "Clear"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.TextSize = 12
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = historyHeader
    UIHelpers.CreateRound(clearBtn, 6)
    
    UIHelpers.SafeConnect(clearBtn.MouseButton1Click, function()
        self.NotificationHistory = {}
        self:RefreshHistoryPanel()
        self:Notify({Text = "History cleared", Type = "Info", Duration = 2})
    end, self._allConnections)
    
    -- Close button
    local closeHistoryBtn = Instance.new("TextButton")
    closeHistoryBtn.Size = UDim2.new(0, 30, 0, 30)
    closeHistoryBtn.Position = UDim2.new(1, -40, 0.5, 0)
    closeHistoryBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeHistoryBtn.BackgroundColor3 = self.Theme.Background
    closeHistoryBtn.Text = "×"
    closeHistoryBtn.TextColor3 = self.Theme.Text
    closeHistoryBtn.TextSize = 20
    closeHistoryBtn.Font = Enum.Font.GothamBold
    closeHistoryBtn.BorderSizePixel = 0
    closeHistoryBtn.Parent = historyHeader
    UIHelpers.CreateRound(closeHistoryBtn, 6)
    
    UIHelpers.SafeConnect(closeHistoryBtn.MouseButton1Click, function()
        self:ToggleNotificationHistory()
    end, self._allConnections)
    
    -- History list
    local historyScroll = Instance.new("ScrollingFrame")
    historyScroll.Size = UDim2.new(1, -20, 1, -70)
    historyScroll.Position = UDim2.new(0, 10, 0, 55)
    historyScroll.BackgroundTransparency = 1
    historyScroll.BorderSizePixel = 0
    historyScroll.ScrollBarThickness = 6
    historyScroll.ScrollBarImageColor3 = self.Theme.Accent
    historyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    historyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    historyScroll.Parent = historyPanel
    
    local historyList = Instance.new("UIListLayout")
    historyList.Padding = UDim.new(0, 6)
    historyList.SortOrder = Enum.SortOrder.LayoutOrder
    historyList.Parent = historyScroll
    
    UIHelpers.CreatePadding(historyScroll, 10)
    
    self.NotificationHistoryPanel = {
        Container = historyPanel,
        Scroll = historyScroll
    }
end

function StoppedUI:RefreshHistoryPanel()
    local scroll = self.NotificationHistoryPanel.Scroll
    
    -- Clear existing
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add history items
    for i, notif in ipairs(self.NotificationHistory) do
        local historyItem = Instance.new("Frame")
        historyItem.Size = UDim2.new(1, 0, 0, 70)
        historyItem.BackgroundColor3 = self.Theme.Background
        historyItem.BorderSizePixel = 0
        historyItem.LayoutOrder = i
        historyItem.Parent = scroll
        UIHelpers.CreateRound(historyItem, self.Theme.Radius - 2)
        UIHelpers.CreatePadding(historyItem, 8)
        
        local colors = {
            Info = self.Theme.Accent,
            Success = self.Theme.Success,
            Warning = self.Theme.Warning,
            Error = self.Theme.Error
        }
        
        -- Type indicator
        local typeIndicator = Instance.new("Frame")
        typeIndicator.Size = UDim2.new(0, 4, 1, -16)
        typeIndicator.Position = UDim2.new(0, 0, 0, 8)
        typeIndicator.BackgroundColor3 = colors[notif.Type] or self.Theme.Accent
        typeIndicator.BorderSizePixel = 0
        typeIndicator.Parent = historyItem
        UIHelpers.CreateRound(typeIndicator, 2)
        
        -- Text content
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -70, 0, 20)
        textLabel.Position = UDim2.new(0, 10, 0, 8)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = notif.Text
        textLabel.TextColor3 = self.Theme.Text
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextTruncate = Enum.TextTruncate.AtEnd
        textLabel.Parent = historyItem
        
        local timeLabel = Instance.new("TextLabel")
        timeLabel.Size = UDim2.new(0, 60, 0, 16)
        timeLabel.Position = UDim2.new(1, -68, 0, 8)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Text = notif.Timestamp
        timeLabel.TextColor3 = self.Theme.TextDim
        timeLabel.TextSize = 10
        timeLabel.Font = Enum.Font.Gotham
        timeLabel.TextXAlignment = Enum.TextXAlignment.Right
        timeLabel.Parent = historyItem
        
        if notif.SubText ~= "" then
            local subLabel = Instance.new("TextLabel")
            subLabel.Size = UDim2.new(1, -70, 0, 16)
            subLabel.Position = UDim2.new(0, 10, 0, 30)
            subLabel.BackgroundTransparency = 1
            subLabel.Text = notif.SubText
            subLabel.TextColor3 = self.Theme.TextDim
            subLabel.TextSize = 10
            subLabel.Font = Enum.Font.Gotham
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.TextTruncate = Enum.TextTruncate.AtEnd
            subLabel.Parent = historyItem
        end
    end
end

function StoppedUI:ToggleNotificationHistory()
    local panel = self.NotificationHistoryPanel.Container
    panel.Visible = not panel.Visible
    
    if panel.Visible then
        self:RefreshHistoryPanel()
        panel.Size = UDim2.new(0, 0, 0, 0)
        UIHelpers.Tween(panel, {Size = UDim2.new(0, 400, 0, 500)}, 0.25)
    else
        UIHelpers.Tween(panel, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
    end
end

-- ========================================
-- LIVE DEBUG / PROFILER PANE
-- ========================================
function StoppedUI:CreateProfilerPane()
    local profilerPane = Instance.new("Frame")
    profilerPane.Name = "ProfilerPane"
    profilerPane.Size = UDim2.new(0, 300, 0, 250)
    profilerPane.Position = UDim2.new(0, 10, 1, -260)
    profilerPane.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    profilerPane.BackgroundTransparency = 0.2
    profilerPane.BorderSizePixel = 0
    profilerPane.ZIndex = 999
    profilerPane.Visible = false
    profilerPane.Parent = self.Container
    UIHelpers.CreateRound(profilerPane, self.Theme.Radius)
    UIHelpers.CreateStroke(profilerPane, self.Theme.Accent, 2, 0.6)
    
    local profilerTitle = Instance.new("TextLabel")
    profilerTitle.Size = UDim2.new(1, -20, 0, 30)
    profilerTitle.Position = UDim2.new(0, 10, 0, 5)
    profilerTitle.BackgroundTransparency = 1
    profilerTitle.Text = "📊 Performance Profiler"
    profilerTitle.TextColor3 = self.Theme.Accent
    profilerTitle.TextSize = 14
    profilerTitle.Font = Enum.Font.GothamBold
    profilerTitle.TextXAlignment = Enum.TextXAlignment.Left
    profilerTitle.Parent = profilerPane
    
    local profilerStats = Instance.new("TextLabel")
    profilerStats.Size = UDim2.new(1, -20, 1, -40)
    profilerStats.Position = UDim2.new(0, 10, 0, 35)
    profilerStats.BackgroundTransparency = 1
    profilerStats.Text = "Initializing..."
    profilerStats.TextColor3 = Color3.fromRGB(0, 255, 100)
    profilerStats.TextSize = 11
    profilerStats.Font = Enum.Font.Code
    profilerStats.TextXAlignment = Enum.TextXAlignment.Left
    profilerStats.TextYAlignment = Enum.TextYAlignment.Top
    profilerStats.TextWrapped = true
    profilerStats.Parent = profilerPane
    
    self.ProfilerPane = {
        Container = profilerPane,
        Stats = profilerStats
    }
    
    -- Update profiler stats
    UIHelpers.SafeConnect(RunService.Heartbeat, function()
        if not profilerPane.Visible then return end
        
        local stats = {}
        table.insert(stats, string.format("FPS: %.1f", 1 / RunService.Heartbeat:Wait()))
        table.insert(stats, string.format("Connections: %d", #self._allConnections))
        table.insert(stats, string.format("Tabs: %d", #self.Tabs))
        table.insert(stats, string.format("Notifications: %d", #self.Notifications))
        table.insert(stats, string.format("History: %d", #(self.NotificationHistory or {})))
        table.insert(stats, string.format("Sliders: %d", #self._sliders))
        
        if self.CommandPalette then
            table.insert(stats, string.format("Commands: %d", #self.CommandPalette.Commands))
        end
        
        table.insert(stats, string.format("Theme: %s", self.Theme == StoppedUI.Themes.Dark and "Dark" or "Light"))
        table.insert(stats, string.format("Layout: %s", self.LayoutMode))
        
        profilerStats.Text = table.concat(stats, "\n")
    end, self._allConnections)
end

function StoppedUI:ToggleProfiler()
    if not self.ProfilerPane then
        self:CreateProfilerPane()
    end
    
    local pane = self.ProfilerPane.Container
    pane.Visible = not pane.Visible
    
    if pane.Visible then
        self:Notify({Text = "Profiler enabled", Type = "Info", Duration = 2})
    else
        self:Notify({Text = "Profiler disabled", Type = "Info", Duration = 2})
    end
end

-- ========================================
-- DEV MODE INSPECTOR (Enhanced)
-- ========================================
function StoppedUI:CreateDevModeInspector()
    local inspector = Instance.new("Frame")
    inspector.Name = "DevModeInspector"
    inspector.Size = UDim2.new(0, 280, 0, 200)
    inspector.Position = UDim2.new(1, -290, 0, 10)
    inspector.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    inspector.BackgroundTransparency = 0.3
    inspector.BorderSizePixel = 0
    inspector.ZIndex = 999
    inspector.Parent = self.Container
    UIHelpers.CreateRound(inspector, self.Theme.Radius)
    UIHelpers.CreateStroke(inspector, Color3.fromRGB(255, 100, 100), 2, 0.5)
    
    local inspectorTitle = Instance.new("TextLabel")
    inspectorTitle.Size = UDim2.new(1, 0, 0, 30)
    inspectorTitle.BackgroundTransparency = 1
    inspectorTitle.Text = "🔧 Dev Mode"
    inspectorTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    inspectorTitle.TextSize = 14
    inspectorTitle.Font = Enum.Font.GothamBold
    inspectorTitle.TextXAlignment = Enum.TextXAlignment.Center
    inspectorTitle.Parent = inspector
    
    local inspectorInfo = Instance.new("TextLabel")
    inspectorInfo.Size = UDim2.new(1, -20, 1, -40)
    inspectorInfo.Position = UDim2.new(0, 10, 0, 35)
    inspectorInfo.BackgroundTransparency = 1
    inspectorInfo.Text = "Hover over elements to inspect"
    inspectorInfo.TextColor3 = Color3.fromRGB(220, 220, 220)
    inspectorInfo.TextSize = 11
    inspectorInfo.Font = Enum.Font.Code
    inspectorInfo.TextXAlignment = Enum.TextXAlignment.Left
    inspectorInfo.TextYAlignment = Enum.TextYAlignment.Top
    inspectorInfo.TextWrapped = true
    inspectorInfo.Parent = inspector
    
    self.DevModeInspector = {
        Container = inspector,
        InfoLabel = inspectorInfo
    }
    
    -- Hover detection for all GUI elements
    local function setupInspector(gui)
        for _, descendant in ipairs(gui:GetDescendants()) do
            if descendant:IsA("GuiObject") then
                UIHelpers.SafeConnect(descendant.MouseEnter, function()
                    local info = string.format(
                        "Name: %s\nClass: %s\nSize: %s\nPosition: %s\nLayoutOrder: %d\nZIndex: %d",
                        descendant.Name,
                        descendant.ClassName,
                        tostring(descendant.Size),
                        tostring(descendant.Position),
                        descendant.LayoutOrder,
                        descendant.ZIndex
                    )
                    inspectorInfo.Text = info
                end, self._allConnections)
            end
        end
    end
    
    setupInspector(self.Container)
end

function StoppedUI:ToggleDevMode()
    self.DevMode = not self.DevMode
    
    if self.DevMode then
        if not self.DevModeInspector then
            self:CreateDevModeInspector()
        else
            self.DevModeInspector.Container.Visible = true
        end
        self:Notify({Text = "Dev Mode Enabled", Type = "Info"})
    else
        if self.DevModeInspector then
            self.DevModeInspector.Container.Visible = false
        end
        self:Notify({Text = "Dev Mode Disabled", Type = "Info"})
    end
    self.PreviewPane = Instance.new("Frame")
    self.PreviewPane.Name = "PreviewPane"
    self.PreviewPane.Size = UDim2.new(1, -380, 1, -70)
    self.PreviewPane.Position = UDim2.new(0, 370, 0, 70)
    self.PreviewPane.BackgroundColor3 = self.Theme.Card
    self.PreviewPane.BorderSizePixel = 0
    self.PreviewPane.Visible = self.ShowPreview
    self.PreviewPane.Parent = self.Content
    UIHelpers.CreateRound(self.PreviewPane, self.Theme.Radius)
    UIHelpers.CreateStroke(self.PreviewPane, self.Theme.Border, 1, 0.85)
    
    local previewCanvas = Instance.new("Frame")
    previewCanvas.Name = "PreviewCanvas"
    previewCanvas.Size = UDim2.new(1, -20, 1, -60)
    previewCanvas.Position = UDim2.new(0, 10, 0, 10)
    previewCanvas.BackgroundTransparency = 1
    previewCanvas.ClipsDescendants = true
    previewCanvas.Parent = self.PreviewPane
    
    -- Preview Label (CENTERED)
    local previewLabel = Instance.new("TextLabel")
    previewLabel.Name = "PreviewLabel"
    previewLabel.Size = UDim2.new(1, -20, 0, 24)
    previewLabel.Position = UDim2.new(0.5, 0, 0, 10)
    previewLabel.AnchorPoint = Vector2.new(0.5, 0)
    previewLabel.BackgroundTransparency = 1
    previewLabel.Text = self:Tr("Preview")
    previewLabel.TextColor3 = self.Theme.TextDim
    previewLabel.Font = Enum.Font.Gotham
    previewLabel.TextSize = 12
    previewLabel.TextXAlignment = Enum.TextXAlignment.Center
    previewLabel.TextYAlignment = Enum.TextYAlignment.Center
    previewLabel.TextWrapped = false
    previewLabel.Parent = previewCanvas
    
    self.PreviewCanvas = previewCanvas
    
    -- Preview Footer
    local previewFooter = Instance.new("Frame")
    previewFooter.Size = UDim2.new(1, -20, 0, 40)
    previewFooter.Position = UDim2.new(0, 10, 1, -50)
    previewFooter.BackgroundColor3 = self.Theme.Secondary
    previewFooter.BorderSizePixel = 0
    previewFooter.Parent = self.PreviewPane
    UIHelpers.CreateRound(previewFooter, self.Theme.Radius - 2)
    
    local previewModeLabel = Instance.new("TextLabel")
    previewModeLabel.Size = UDim2.new(0, 80, 1, 0)
    previewModeLabel.Position = UDim2.new(0, 10, 0, 0)
    previewModeLabel.BackgroundTransparency = 1
    previewModeLabel.Text = self:Tr("Mode")
    previewModeLabel.TextColor3 = self.Theme.TextDim
    previewModeLabel.Font = Enum.Font.Gotham
    previewModeLabel.TextSize = 12
    previewModeLabel.TextXAlignment = Enum.TextXAlignment.Left
    previewModeLabel.TextYAlignment = Enum.TextYAlignment.Center
    previewModeLabel.Parent = previewFooter
    
    local previewModeBtn = Instance.new("TextButton")
    previewModeBtn.Size = UDim2.new(0, 100, 0, 28)
    previewModeBtn.Position = UDim2.new(0, 90, 0, 6)
    previewModeBtn.BackgroundColor3 = self.Theme.Accent
    previewModeBtn.Text = self:Tr("Players")
    previewModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    previewModeBtn.Font = Enum.Font.GothamBold
    previewModeBtn.TextSize = 12
    previewModeBtn.BorderSizePixel = 0
    previewModeBtn.Parent = previewFooter
    UIHelpers.CreateRound(previewModeBtn, self.Theme.Radius - 2)
    
    self.PreviewMode = "Players"
    UIHelpers.SafeConnect(previewModeBtn.MouseButton1Click, function()
        self.PreviewMode = (self.PreviewMode == "Players") and "Vehicles" or "Players"
        previewModeBtn.Text = self:Tr(self.PreviewMode)
    end, self._allConnections)
end

function StoppedUI:CreateFooter()
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, -20, 0, 38)
    footer.Position = UDim2.new(0, 10, 1, -50)
    footer.BackgroundColor3 = self.Theme.Card
    footer.BorderSizePixel = 0
    footer.Parent = self.Container
    UIHelpers.CreateRound(footer, self.Theme.Radius)
    UIHelpers.CreatePadding(footer, 10)
    
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, 0, 1, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = self:Tr("Username") .. " " .. LocalPlayer.Name
    usernameLabel.TextColor3 = self.Theme.TextDim
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 13
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.TextYAlignment = Enum.TextYAlignment.Center
    usernameLabel.Parent = footer
end

-- ========================================
-- NOTIFICATION SYSTEM
-- ========================================
function StoppedUI:CreateNotificationBell()
    self.NotifyGui = Instance.new("ScreenGui")
    self.NotifyGui.Name = "StoppedUI_Notify_" .. math.random(1000, 9999)
    self.NotifyGui.ResetOnSpawn = false
    self.NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        self.NotifyGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(self.NotifyGui)
        self.NotifyGui.Parent = game:GetService("CoreGui")
    else
        self.NotifyGui.Parent = game:GetService("CoreGui")
    end

    local bellContainer = Instance.new("Frame")
    bellContainer.Name = "NotificationBellContainer"
    bellContainer.Size = UDim2.new(0, 60, 0, 60)
    bellContainer.AnchorPoint = Vector2.new(1, 0)
    bellContainer.Position = UDim2.new(1, -15, 0, 15)
    bellContainer.BackgroundColor3 = self.Theme.Card
    bellContainer.BorderSizePixel = 0
    bellContainer.ZIndex = 1000
    bellContainer.Parent = self.NotifyGui
    UIHelpers.CreateRound(bellContainer, 10)
    UIHelpers.CreateStroke(bellContainer, self.Theme.Border, 2, 0.3)
    
    local bell = Instance.new("ImageButton")
    bell.Size = UDim2.new(0, 32, 0, 32)
    bell.Position = UDim2.new(0.5, 0, 0.5, 0)
    bell.AnchorPoint = Vector2.new(0.5, 0.5)
    bell.BackgroundTransparency = 1
    bell.ImageColor3 = self.Theme.TextDim
    bell.Image = "rbxassetid://" .. self.NotificationBellImgurHash
    bell.Parent = bellContainer
    
    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 20, 0, 20)
    badge.AnchorPoint = Vector2.new(1, 0)
    badge.Position = UDim2.new(1, -6, 0, -6)
    badge.BackgroundColor3 = self.Theme.Error
    badge.Text = "0"
    badge.TextColor3 = Color3.new(1, 1, 1)
    badge.TextSize = 11
    badge.Font = Enum.Font.GothamBold
    badge.BorderSizePixel = 0
    badge.Visible = false
    badge.ZIndex = 1001
    badge.Parent = bellContainer
    UIHelpers.CreateRound(badge, 10)
    
    self.NotificationBadge = badge
    self.NotificationBell = bell
    self.NotificationBellContainer = bellContainer
    
    UIHelpers.SafeConnect(bell.MouseEnter, function()
        UIHelpers.Tween(bell, {ImageColor3 = self.Theme.Accent}, 0.2)
        UIHelpers.Tween(bellContainer, {BackgroundColor3 = self.Theme.Background}, 0.2)
    end, self._allConnections)
    
    UIHelpers.SafeConnect(bell.MouseLeave, function()
        UIHelpers.Tween(bell, {ImageColor3 = self.Theme.TextDim}, 0.2)
        UIHelpers.Tween(bellContainer, {BackgroundColor3 = self.Theme.Card}, 0.2)
    end, self._allConnections)
    
    self:CreateNotificationPanel()
    
    UIHelpers.SafeConnect(bell.MouseButton1Click, function()
        self:ToggleNotificationPanel()
    end, self._allConnections)
    
    self.Notifications = {}
end

function StoppedUI:CreateNotificationPanel()
    local panel = Instance.new("ScrollingFrame")
    panel.Name = "NotificationPanel"
    panel.Size = UDim2.new(0, 360, 0, 0)
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -15, 0, 80)
    panel.BackgroundColor3 = self.Theme.Card
    panel.BorderSizePixel = 0
    panel.ScrollBarThickness = 6
    panel.ScrollBarImageColor3 = self.Theme.Accent
    panel.Visible = false
    panel.ZIndex = 1000
    panel.ClipsDescendants = true
    panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    panel.Parent = self.NotifyGui
    UIHelpers.CreateRound(panel, self.Theme.Radius)
    UIHelpers.CreateStroke(panel, self.Theme.Border, 1, 0.3)
    UIHelpers.CreatePadding(panel, 6)
    
    local panelList = Instance.new("UIListLayout")
    panelList.Padding = UDim.new(0, 6)
    panelList.SortOrder = Enum.SortOrder.LayoutOrder
    panelList.Parent = panel
    
    self.NotificationPanel = panel
    self.NotificationPanelList = panelList
    
    -- Dynamic sizing
    UIHelpers.SafeConnect(panelList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if panel.Visible then
            local contentHeight = panelList.AbsoluteContentSize.Y + 16
            local maxHeight = math.min(450, workspace.CurrentCamera.ViewportSize.Y * 0.7)
            UIHelpers.Tween(panel, {Size = UDim2.new(0, 360, 0, math.min(maxHeight, contentHeight))}, 0.2)
        end
    end, self._allConnections)
end

function StoppedUI:ToggleNotificationPanel()
    local panel = self.NotificationPanel
    panel.Visible = not panel.Visible
    
    if panel.Visible then
        local contentHeight = self.NotificationPanelList.AbsoluteContentSize.Y + 16
        local maxHeight = math.min(450, workspace.CurrentCamera.ViewportSize.Y * 0.7)
        panel.Size = UDim2.new(0, 360, 0, 0)
        UIHelpers.Tween(panel, {Size = UDim2.new(0, 360, 0, math.min(maxHeight, contentHeight))}, 0.28)
    else
        UIHelpers.Tween(panel, {Size = UDim2.new(0, 360, 0, 0)}, 0.22)
    end
end

function StoppedUI:Notify(options)
    options = options or {}
    
    local text = options.Text
    if options.Key then
        text = self:Tr(options.Key)
    end
    
    text = text or "Notification"
    local subText = options.SubText or ""
    local imgHash = options.ImageHash or "3944680095"
    local type = options.Type or "Info"
    local duration = options.Duration or self.DefaultNotificationDuration
    
    local colors = {
        Info = self.Theme.Accent,
        Success = self.Theme.Success,
        Warning = self.Theme.Warning,
        Error = self.Theme.Error
    }
    
    -- Add to history
    self:AddToHistory({
        Text = text,
        SubText = subText,
        Type = type,
        ImageHash = imgHash
    })
    
    -- Always show notification panel
    if self.NotificationPanel then
        self.NotificationPanel.Visible = true
    end
    
    -- Debounce similar notifications (reduced window for responsiveness)
    local window = 1  -- Reduced from 3 to 1 second
    if options.Key and self._recentNotif[options.Key] then
        local recent = self._recentNotif[options.Key]
        if tick() - recent.t < window then
            recent.count = recent.count + 1
            if recent.notif and recent.notif.Parent then
                local label = recent.notif:FindFirstChild("TextContainer"):FindFirstChild("Label")
                if label then
                    label.Text = text .. " (x" .. recent.count .. ")"
                end
            end
            return
        end
    end
    
    if options.Key then
        self._recentNotif[options.Key] = {t = tick(), count = 1}
    end
    
    -- Max notifications
    if #self.Notifications >= self.MaxNotifications then
        local oldest = table.remove(self.Notifications, 1)
        if oldest and oldest.Parent then
            oldest.Parent = nil
            table.insert(self._notificationPool, oldest)
        end
    end
    
    -- Create or reuse notification
    local notif = table.remove(self._notificationPool) or Instance.new("Frame")
    notif.Size = UDim2.new(1, -10, 0, 0)
    notif.AutomaticSize = Enum.AutomaticSize.Y
    notif.BackgroundColor3 = self.Theme.Background
    notif.BorderSizePixel = 0
    notif.LayoutOrder = #self.Notifications + 1
    notif.Parent = self.NotificationPanel
    
    if not notif:FindFirstChild("UICorner") then
        UIHelpers.CreateRound(notif, self.Theme.Radius - 2)
        UIHelpers.CreatePadding(notif, 10)
    end
    
    local img = notif:FindFirstChild("NotifImage") or Instance.new("ImageLabel")
    img.Name = "NotifImage"
    img.Size = UDim2.new(0, 48, 0, 48)
    img.Position = UDim2.new(0, 0, 0, 0)
    img.BackgroundTransparency = 1
    img.ImageColor3 = colors[type] or self.Theme.Accent
    img.Image = UIHelpers.ResolveImage(imgHash)
    img.Parent = notif
    UIHelpers.CreateRound(img, self.Theme.Radius - 2)
    
    local textContainer = notif:FindFirstChild("TextContainer") or Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.Size = UDim2.new(1, -60, 0, 0)
    textContainer.Position = UDim2.new(0, 60, 0, 0)
    textContainer.AutomaticSize = Enum.AutomaticSize.Y
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = notif
    
    local label = textContainer:FindFirstChild("Label") or Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = textContainer
    
    local subLabel = textContainer:FindFirstChild("SubLabel") or Instance.new("TextLabel")
    subLabel.Name = "SubLabel"
    subLabel.Size = UDim2.new(1, 0, 0, 0)
    subLabel.Position = UDim2.new(0, 0, 0, 18)
    subLabel.AutomaticSize = Enum.AutomaticSize.Y
    subLabel.BackgroundTransparency = 1
    subLabel.Text = subText
    subLabel.TextColor3 = self.Theme.TextDim
    subLabel.TextSize = 11
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextWrapped = true
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.TextYAlignment = Enum.TextYAlignment.Top
    subLabel.Visible = subText ~= ""
    subLabel.Parent = textContainer
    
    local progress = notif:FindFirstChild("Progress") or Instance.new("Frame")
    progress.Name = "Progress"
    progress.Size = UDim2.new(1, 0, 0, 3)
    progress.Position = UDim2.new(0, 0, 1, -3)
    progress.AnchorPoint = Vector2.new(0, 1)
    progress.BackgroundColor3 = colors[type] or self.Theme.Accent
    progress.BorderSizePixel = 0
    progress.Parent = notif
    
    -- Fade in animation
    notif.BackgroundTransparency = 1
    label.TextTransparency = 1
    img.ImageTransparency = 1
    UIHelpers.Tween(notif, {BackgroundTransparency = 0}, 0.3)
    UIHelpers.Tween(label, {TextTransparency = 0}, 0.3)
    UIHelpers.Tween(img, {ImageTransparency = 0}, 0.3)
    if subText ~= "" then
        subLabel.TextTransparency = 1
        UIHelpers.Tween(subLabel, {TextTransparency = 0}, 0.3)
    end
    
    table.insert(self.Notifications, notif)
    
    if options.Key then
        self._recentNotif[options.Key].notif = notif
    end
    
    -- Update badge
    self.NotificationBadge.Text = tostring(#self.Notifications)
    self.NotificationBadge.Visible = true
    
    task.spawn(function()
        UIHelpers.Tween(self.NotificationBadge, {Size = UDim2.new(0, 24, 0, 24)}, 0.2)
        task.wait(0.2)
        UIHelpers.Tween(self.NotificationBadge, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
    end)
    
    -- Progress bar animation
    task.spawn(function()
        local t0 = tick()
        local t1 = t0 + duration
        local conn
        conn = UIHelpers.SafeConnect(RunService.RenderStepped, function()
            if tick() >= t1 or not progress.Parent then
                progress.Size = UDim2.new(0, 0, 0, 3)
                if conn then conn:Disconnect() end
                return
            end
            local pct = 1 - ((tick() - t0) / duration)
            progress.Size = UDim2.new(pct, 0, 0, 3)
        end, nil)
    end)
    
    -- Auto remove
    task.delay(duration, function()
        if not notif.Parent then return end
        
        UIHelpers.Tween(notif, {BackgroundTransparency = 1}, 0.3)
        UIHelpers.Tween(label, {TextTransparency = 1}, 0.3)
        UIHelpers.Tween(img, {ImageTransparency = 1}, 0.3)
        if subText ~= "" then
            UIHelpers.Tween(subLabel, {TextTransparency = 1}, 0.3)
        end
        task.wait(0.3)
        
        if notif.Parent then
            notif.Parent = nil
            table.insert(self._notificationPool, notif)
        end
        
        local index = table.find(self.Notifications, notif)
        if index then
            table.remove(self.Notifications, index)
        end
        
        self.NotificationBadge.Text = tostring(#self.Notifications)
        if #self.Notifications == 0 then
            self.NotificationBadge.Visible = false
        end
    end)
end

function StoppedUI:StatusNotify(name, status, duration)
    duration = duration or 3
    local mapping = {
        Success = {Type = 'Success', Text = name .. ' ✓'},
        Error = {Type = 'Error', Text = name .. ' ✖'},
        Warning = {Type = 'Warning', Text = name .. ' !'},
        Info = {Type = 'Info', Text = name}
    }
    local entry = mapping[status] or mapping.Info
    self:Notify({Text = entry.Text, Type = entry.Type, Duration = duration})
end

-- ========================================
-- TAB SYSTEM (Enhanced with animated indicator)
-- ========================================
function StoppedUI:CreateTab(config)
    config = config or {}
    local tabName = config.Name or "Tab"
    local icon = config.Icon
    
    local tab = {
        Name = tabName,
        Elements = {},
        Container = nil,
        Icon = nil
    }
    
    -- Tab Button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName
    tabBtn.Size = UDim2.new(0, 120, 1, 0)
    tabBtn.BackgroundColor3 = self.Theme.Background
    tabBtn.Text = ""
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.TabButtonContainer
    UIHelpers.CreateRound(tabBtn, self.Theme.Radius)
    
    -- Animated accent bar (indicator)
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 0, 0, 3)
    accentBar.Position = UDim2.new(0, 0, 1, -3)
    accentBar.BackgroundColor3 = self.Theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = tabBtn
    UIHelpers.CreateRound(accentBar, 2)
    
    tab.AccentBar = accentBar
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, icon and -30 or -10, 1, 0)
    tabLabel.Position = UDim2.new(0, icon and 30 or 10, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = tabName
    tabLabel.TextColor3 = self.Theme.TextDim
    tabLabel.TextSize = 13
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.TextYAlignment = Enum.TextYAlignment.Center
    tabLabel.Parent = tabBtn
    
    if icon then
        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.Position = UDim2.new(0, 8, 0.5, 0)
        iconImg.AnchorPoint = Vector2.new(0, 0.5)
        iconImg.BackgroundTransparency = 1
        iconImg.ImageColor3 = self.Theme.TextDim
        iconImg.Image = "rbxassetid://" .. icon
        iconImg.Parent = tabBtn
        tab.Icon = iconImg
    end
    
    -- Tab Content Container
    local content = Instance.new("Frame")
    content.Name = tabName .. "_Content"
    content.Size = UDim2.new(1, -10, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = false
    content.LayoutOrder = #self.Tabs + 1
    content.Parent = self.LeftPane
    
    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 10)
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Parent = content
    
    tab.Container = content
    
    -- Tab hover effects
    UIHelpers.SafeConnect(tabBtn.MouseEnter, function()
        if self.CurrentTab ~= tab then
            UIHelpers.Tween(tabBtn, {BackgroundColor3 = self.Theme.Secondary}, 0.2)
        end
    end, self._allConnections)
    
    UIHelpers.SafeConnect(tabBtn.MouseLeave, function()
        if self.CurrentTab ~= tab then
            UIHelpers.Tween(tabBtn, {BackgroundColor3 = self.Theme.Background}, 0.2)
        end
    end, self._allConnections)
    
    -- Tab click handler
    UIHelpers.SafeConnect(tabBtn.MouseButton1Click, function()
        for _, t in pairs(self.Tabs) do
            t.Container.Visible = false
            local btn = self.TabButtonContainer:FindFirstChild(t.Name)
            if btn then
                UIHelpers.Tween(btn, {BackgroundColor3 = self.Theme.Background}, 0.2)
                local lbl = btn:FindFirstChildOfClass("TextLabel")
                if lbl then
                    UIHelpers.Tween(lbl, {TextColor3 = self.Theme.TextDim}, 0.2)
                end
                if t.Icon then
                    UIHelpers.Tween(t.Icon, {ImageColor3 = self.Theme.TextDim}, 0.2)
                end
                -- Hide accent bar
                if t.AccentBar then
                    UIHelpers.Tween(t.AccentBar, {Size = UDim2.new(0, 0, 0, 3)}, 0.2)
                end
            end
        end
        
        content.Visible = true
        UIHelpers.Tween(tabBtn, {BackgroundColor3 = self.Theme.Accent}, 0.2)
        UIHelpers.Tween(tabLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        if tab.Icon then
            UIHelpers.Tween(tab.Icon, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end
        -- Animate accent bar
        UIHelpers.Tween(accentBar, {Size = UDim2.new(1, 0, 0, 3)}, 0.3)
        
        self.CurrentTab = tab
    end, self._allConnections)
    
    -- Auto-select first tab
    if #self.Tabs == 0 then
        tabBtn.BackgroundColor3 = self.Theme.Accent
        tabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        if tab.Icon then
            tab.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
        accentBar.Size = UDim2.new(1, 0, 0, 3)
        content.Visible = true
        self.CurrentTab = tab
    end
    
    table.insert(self.Tabs, tab)
    return tab
end

-- ========================================
-- UI ELEMENTS (Button, Toggle, Slider, etc)
-- ========================================
function StoppedUI:AddButton(tab, config)
    config = config or {}
    local text = config.Text or "Button"
    local callback = config.Callback
    
    local btnContainer = Instance.new("Frame")
    btnContainer.Name = "ButtonContainer"
    btnContainer.Size = UDim2.new(1, 0, 0, 40)
    btnContainer.BackgroundColor3 = self.Theme.Card
    btnContainer.BorderSizePixel = 0
    btnContainer.LayoutOrder = config.LayoutOrder or (#tab.Elements + 1)
    btnContainer.Parent = tab.Container
    UIHelpers.CreateRound(btnContainer, self.Theme.Radius)
    UIHelpers.CreateStroke(btnContainer, self.Theme.Border, 1, 0.85)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 1, -8)
    btn.Position = UDim2.new(0, 8, 0, 4)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = self.Theme.Text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.Parent = btnContainer
    
    UIHelpers.SafeConnect(btn.MouseEnter, function()
        UIHelpers.Tween(btnContainer, {BackgroundColor3 = self.Theme.Secondary}, 0.2)
        UIHelpers.Tween(btn, {TextColor3 = self.Theme.Accent}, 0.2)
    end, self._allConnections)
    
    UIHelpers.SafeConnect(btn.MouseLeave, function()
        UIHelpers.Tween(btnContainer, {BackgroundColor3 = self.Theme.Card}, 0.2)
        UIHelpers.Tween(btn, {TextColor3 = self.Theme.Text}, 0.2)
    end, self._allConnections)
    
    UIHelpers.SafeConnect(btn.MouseButton1Click, function()
        UIHelpers.Tween(btnContainer, {Size = UDim2.new(1, -4, 0, 38)}, 0.08)
        task.wait(0.08)
        UIHelpers.Tween(btnContainer, {Size = UDim2.new(1, 0, 0, 40)}, 0.08)
        
        if callback then
            pcall(callback)
        end
    end, self._allConnections)
    
    local element = {
        Type = "Button",
        Container = btnContainer,
        Button = btn
    }
    
    table.insert(tab.Elements, element)
    return element
end

function StoppedUI:AddToggle(tab, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback
    
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.Size = UDim2.new(1, 0, 0, 40)
    toggleContainer.BackgroundColor3 = self.Theme.Card
    toggleContainer.BorderSizePixel = 0
    toggleContainer.LayoutOrder = config.LayoutOrder or (#tab.Elements + 1)
    toggleContainer.Parent = tab.Container
    UIHelpers.CreateRound(toggleContainer, self.Theme.Radius)
    UIHelpers.CreateStroke(toggleContainer, self.Theme.Border, 1, 0.85)
    UIHelpers.CreatePadding(toggleContainer, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = toggleContainer
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 46, 0, 24)
    toggleBtn.Position = UDim2.new(1, -46, 0.5, 0)
    toggleBtn.AnchorPoint = Vector2.new(0, 0.5)
    toggleBtn.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Secondary
    toggleBtn.Text = ""
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = toggleContainer
    UIHelpers.CreateRound(toggleBtn, 12)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBtn
    UIHelpers.CreateRound(knob, 9)
    
    local state = default
    
    UIHelpers.SafeConnect(toggleBtn.MouseButton1Click, function()
        state = not state
        
        UIHelpers.Tween(toggleBtn, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Secondary}, 0.2)
        UIHelpers.Tween(knob, {Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.2)
        
        if callback then
            pcall(callback, state)
        end
    end, self._allConnections)
    
    local element = {
        Type = "Toggle",
        Container = toggleContainer,
        State = state,
        SetValue = function(self, value)
            state = value
            UIHelpers.Tween(toggleBtn, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Secondary}, 0.2)
            UIHelpers.Tween(knob, {Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.2)
        end,
        GetValue = function()
            return state
        end
    }
    
    table.insert(tab.Elements, element)
    return element
end

function StoppedUI:AddSlider(tab, config)
    config = config or {}
    config.Accent = self.Theme.Accent
    config.BackgroundColor = self.Theme.Secondary
    config.TextColor = self.Theme.Text
    config.Size = UDim2.new(1, 0, 0, 46)
    config.LayoutOrder = config.LayoutOrder or (#tab.Elements + 1)
    
    local slider = SliderComponent.new(tab.Container, config, self._allConnections)
    
    local element = {
        Type = "Slider",
        Slider = slider,
        Container = slider.Container,
        SetValue = function(self, v) slider:SetValue(v) end,
        GetValue = function() return slider:GetValue() end,
        Destroy = function() slider:Destroy() end
    }
    
    table.insert(tab.Elements, element)
    table.insert(self._sliders, slider)
    return element
end

function StoppedUI:AddLabel(tab, config)
    config = config or {}
    local text = config.Text or "Label"
    local centered = config.Centered or false
    
    local labelContainer = Instance.new("Frame")
    labelContainer.Name = "LabelContainer"
    labelContainer.Size = UDim2.new(1, 0, 0, 0)
    labelContainer.AutomaticSize = Enum.AutomaticSize.Y
    labelContainer.BackgroundTransparency = 1
    labelContainer.LayoutOrder = config.LayoutOrder or (#tab.Elements + 1)
    labelContainer.Parent = tab.Container
    UIHelpers.CreatePadding(labelContainer, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.TextDim
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = labelContainer
    
    if centered then
        label.Position = UDim2.new(0.5, 0, 0, 0)
        label.AnchorPoint = Vector2.new(0.5, 0)
    end
    
    local element = {
        Type = "Label",
        Container = labelContainer,
        Label = label,
        SetText = function(self, newText)
            label.Text = newText
        end
    }
    
    table.insert(tab.Elements, element)
    return element
end

function StoppedUI:AddSection(tab, config)
    config = config or {}
    local text = config.Text or "Section"
    
    local sectionContainer = Instance.new("Frame")
    sectionContainer.Name = "SectionContainer"
    sectionContainer.Size = UDim2.new(1, 0, 0, 30)
    sectionContainer.BackgroundTransparency = 1
    sectionContainer.LayoutOrder = config.LayoutOrder or (#tab.Elements + 1)
    sectionContainer.Parent = tab.Container
    
    local line1 = Instance.new("Frame")
    line1.Size = UDim2.new(0.45, -5, 0, 1)
    line1.Position = UDim2.new(0, 0, 0.5, 0)
    line1.AnchorPoint = Vector2.new(0, 0.5)
    line1.BackgroundColor3 = self.Theme.Border
    line1.BorderSizePixel = 0
    line1.Parent = sectionContainer
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(0.1, 0, 1, 0)
    sectionLabel.Position = UDim2.new(0.5, 0, 0, 0)
    sectionLabel.AnchorPoint = Vector2.new(0.5, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = text
    sectionLabel.TextColor3 = self.Theme.TextDim
    sectionLabel.TextSize = 12
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Center
    sectionLabel.TextYAlignment = Enum.TextYAlignment.Center
    sectionLabel.Parent = sectionContainer
    
    local line2 = Instance.new("Frame")
    line2.Size = UDim2.new(0.45, -5, 0, 1)
    line2.Position = UDim2.new(1, 0, 0.5, 0)
    line2.AnchorPoint = Vector2.new(1, 0.5)
    line2.BackgroundColor3 = self.Theme.Border
    line2.BorderSizePixel = 0
    line2.Parent = sectionContainer
    
    local element = {
        Type = "Section",
        Container = sectionContainer
    }
    
    table.insert(tab.Elements, element)
    return element
end

-- ========================================
-- CONFIG SYSTEM (Hook-based)
-- ========================================
function StoppedUI:GetConfigState()
    local state = {
        Elements = {}
    }
    
    for _, tab in ipairs(self.Tabs) do
        for _, element in ipairs(tab.Elements) do
            if element.Type == "Toggle" then
                state.Elements[element.Container.Name] = element:GetValue()
            elseif element.Type == "Slider" then
                state.Elements[element.Container.Name] = element:GetValue()
            end
        end
    end
    
    return state
end

function StoppedUI:SetConfigState(state)
    if not state or not state.Elements then return false end
    
    for _, tab in ipairs(self.Tabs) do
        for _, element in ipairs(tab.Elements) do
            local savedValue = state.Elements[element.Container.Name]
            if savedValue ~= nil then
                if element.Type == "Toggle" or element.Type == "Slider" then
                    element:SetValue(savedValue)
                end
            end
        end
    end
    
    return true
end

function StoppedUI:RequestSave()
    if self.Config.Enabled then
        self.Config.OnRequestSave:Fire()
    end
end

function StoppedUI:RequestLoad()
    if self.Config.Enabled then
        self.Config.OnRequestLoad:Fire()
    end
end

-- ========================================
-- TRANSLATION SYSTEM (Hook-based, disabled by default)
-- ========================================
function StoppedUI:Tr(key)
    if not self.TranslationEnabled then
        return key
    end
    
    local locale = self.Locale or "en"
    if self.Translations[locale] and self.Translations[locale][key] then
        return self.Translations[locale][key]
    end
    return key
end

function StoppedUI:ApplyTranslations()
    if not self.TranslationEnabled then
        return
    end
    
    for _, entry in pairs(self._translatedElements or {}) do
        local inst = entry.Instance
        local key = entry.Key
        if inst and key and self.Translations[self.Locale] and self.Translations[self.Locale][key] then
            pcall(function() inst.Text = self.Translations[self.Locale][key] end)
        end
    end
end

-- ========================================
-- RESPONSIVENESS & DRAGGING
-- ========================================
function StoppedUI:SetupResponsiveness()
    local camera = workspace.CurrentCamera
    
    local function updateResponsive()
        local viewportSize = camera.ViewportSize
        
        -- Bell size scaling
        local function computeBellSize(viewportY)
            local base = 60
            local scale = math.clamp(viewportY / 720, 0.8, 1.5)
            return math.floor(base * scale)
        end
        
        local bellSize = computeBellSize(viewportSize.Y)
        self.NotificationBellContainer.Size = UDim2.new(0, bellSize, 0, bellSize)
        
        -- Notification panel max height
        if self.NotificationPanel then
            local maxHeight = math.min(450, viewportSize.Y * 0.7)
            if self.NotificationPanel.Visible then
                local contentHeight = self.NotificationPanelList.AbsoluteContentSize.Y + 16
                self.NotificationPanel.Size = UDim2.new(0, 360, 0, math.min(maxHeight, contentHeight))
            end
        end
        
        -- Keep container in bounds
        local containerSize = self.Container.AbsoluteSize
        local containerPos = self.Container.AbsolutePosition
        
        if containerPos.X + containerSize.X > viewportSize.X then
            self.Container.Position = UDim2.new(0, viewportSize.X - containerSize.X - 10, 0, self.Container.Position.Y.Offset)
        end
        
        if containerPos.Y + containerSize.Y > viewportSize.Y then
            self.Container.Position = UDim2.new(0, self.Container.Position.X.Offset, 0, viewportSize.Y - containerSize.Y - 10)
        end
        
        -- Responsive layout (stack vertically on small screens)
        if viewportSize.X < 700 and self.ShowPreview then
            self.LeftPane.Size = UDim2.new(1, -20, 0.5, -40)
            self.PreviewPane.Size = UDim2.new(1, -20, 0.5, -40)
            self.PreviewPane.Position = UDim2.new(0, 10, 0.5, 30)
        else
            self.LeftPane.Size = UDim2.new(0, 350, 1, -70)
            self.PreviewPane.Size = UDim2.new(1, -380, 1, -70)
            self.PreviewPane.Position = UDim2.new(0, 370, 0, 70)
        end
    end
    
    UIHelpers.SafeConnect(camera:GetPropertyChangedSignal("ViewportSize"), updateResponsive, self._allConnections)
    updateResponsive()
end

function StoppedUI:MakeDraggable()
    local dragging = false
    local dragStartPos = Vector2.new(0, 0)
    local startWindowPos = Vector2.new(0, 0)
    local dragConn
    local snapGhost

    local function stopDrag()
        dragging = false
        if dragConn then
            dragConn:Disconnect()
            dragConn = nil
        end
        if snapGhost then
            snapGhost:Destroy()
            snapGhost = nil
        end
    end
    
    -- Create snap ghost (preview of snapped position)
    local function createSnapGhost()
        if snapGhost then return snapGhost end
        
        snapGhost = Instance.new("Frame")
        snapGhost.Size = self.Container.Size
        snapGhost.BackgroundColor3 = self.Theme.Accent
        snapGhost.BackgroundTransparency = 0.85
        snapGhost.BorderSizePixel = 0
        snapGhost.ZIndex = -1
        snapGhost.Visible = false
        snapGhost.Parent = self.ScreenGui
        UIHelpers.CreateRound(snapGhost, self.Theme.Radius + 4)
        UIHelpers.CreateStroke(snapGhost, self.Theme.Accent, 2, 0.6)
        
        return snapGhost
    end

    UIHelpers.SafeConnect(self.Topbar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = input.Position
            startWindowPos = self.Container.AbsolutePosition
            
            if self.SnapToEdges then
                createSnapGhost()
            end

            UIHelpers.SafeConnect(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    stopDrag()
                end
            end, nil)

            dragConn = UIHelpers.SafeConnect(RunService.RenderStepped, function()
                if not dragging then return end
                local mousePos = UserInputService:GetMouseLocation()
                local delta = mousePos - dragStartPos
                local newPos = startWindowPos + delta

                local viewport = workspace.CurrentCamera.ViewportSize
                local cs = self.Container.AbsoluteSize
                
                -- Clamp to viewport
                newPos = Vector2.new(
                    math.clamp(newPos.X, 0, math.max(0, viewport.X - cs.X)),
                    math.clamp(newPos.Y, 0, math.max(0, viewport.Y - cs.Y))
                )
                
                -- Snap to edges with ghost preview
                if self.SnapToEdges then
                    local snappedPos = UIHelpers.SnapToEdge(newPos, cs, viewport, self.SnapDistance)
                    
                    -- Show ghost if snapping would occur
                    if snappedPos ~= newPos and snapGhost then
                        snapGhost.Position = UDim2.new(0, snappedPos.X, 0, snappedPos.Y)
                        snapGhost.Visible = true
                    else
                        if snapGhost then
                            snapGhost.Visible = false
                        end
                    end
                    
                    -- Apply final position
                    self.Container.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
                else
                    self.Container.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
                end
            end, self._allConnections)
        end
    end, self._allConnections)

    UIHelpers.SafeConnect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            -- Apply snap on release
            if self.SnapToEdges then
                local viewport = workspace.CurrentCamera.ViewportSize
                local cs = self.Container.AbsoluteSize
                local currentPos = self.Container.AbsolutePosition
                local snappedPos = UIHelpers.SnapToEdge(currentPos, cs, viewport, self.SnapDistance)
                
                if snappedPos ~= currentPos then
                    UIHelpers.Tween(self.Container, {
                        Position = UDim2.new(0, snappedPos.X, 0, snappedPos.Y)
                    }, 0.2)
                end
            end
            
            stopDrag()
        end
    end, self._allConnections)
end

-- ========================================
-- WINDOW CONTROLS
-- ========================================
function StoppedUI:Toggle()
    if not self.ScreenGui then return end
    if self.ScreenGui.Enabled then
        self:Hide()
    else
        self:Show()
    end
end

function StoppedUI:Show()
    if not self.ScreenGui then return end
    self.ScreenGui.Enabled = true
    self.Container.Size = UDim2.new(0, 0, 0, 0)
    self.Container.BackgroundTransparency = 1
    UIHelpers.Tween(self.Container, {Size = UDim2.new(0, 800, 0, 550)}, 0.4)
    UIHelpers.Tween(self.Container, {BackgroundTransparency = 0}, 0.35)
end

function StoppedUI:Hide()
    if not self.Container then return end
    UIHelpers.Tween(self.Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
    UIHelpers.Tween(self.Container, {BackgroundTransparency = 1}, 0.25)
    task.delay(0.26, function()
        if self and self.ScreenGui then
            self.ScreenGui.Enabled = false
        end
    end)
end

function StoppedUI:Destroy()
    -- Cleanup all connections
    UIHelpers.CleanupConnections(self._allConnections)
    
    -- Destroy all sliders
    for _, slider in ipairs(self._sliders) do
        if slider and slider.Destroy then
            pcall(function() slider:Destroy() end)
        end
    end
    
    -- Destroy config events
    if self.Config then
        if self.Config.OnRequestSave then
            self.Config.OnRequestSave:Destroy()
        end
        if self.Config.OnRequestLoad then
            self.Config.OnRequestLoad:Destroy()
        end
    end
    
    -- Destroy GUIs
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    if self.NotifyGui then
        self.NotifyGui:Destroy()
    end
end

-- ========================================
-- EXTENSION POINTS (For Developer Customization)
-- ========================================

--[[
    EXTENSION GUIDE FOR DEVELOPERS:
    
    1. LAYOUT CUSTOMIZATION:
       - Modify self._leftPaneWidth (0-1 fraction)
       - Call self:UpdatePaneLayout() to apply
       - Use self:SetLayoutMode("Compact"|"Normal"|"Expanded")
    
    2. COMMAND PALETTE:
       - Add commands: self:RegisterCommand(name, description, callback)
       - Commands appear in Ctrl+K palette
       - Example: window:RegisterCommand("My Action", "Does X", function() ... end)
    
    3. CONFIG HOOKS (No Auto-Save):
       - self.Config.OnRequestSave.Event:Connect(function() ... end)
       - self.Config.OnRequestLoad.Event:Connect(function() ... end)
       - Use self.Config.GetState() and self.Config.SetState(state)
       - IMPORTANT: No writefile/readfile inside UI - you implement storage
    
    4. THEME CUSTOMIZATION:
       - Add custom theme to StoppedUI.Themes table
       - StoppedUI.Themes.MyTheme = { Background = ..., Accent = ..., etc }
       - Pass Theme = "MyTheme" in Create()
       - Use Theme Store UI to browse/apply themes
    
    5. TRANSLATIONS (Disabled by Default):
       - Set TranslationEnabled = true in Create()
       - Add custom locale to StoppedUI.Translations
       - Use self:Tr("Key") in your elements
       - Zero overhead when disabled
    
    6. DEV MODE & PROFILER:
       - Enable DevMode = true in Create()
       - Toggle with Ctrl+K → "Toggle Dev Mode"
       - Hover over elements to inspect properties
       - Enable Profiler to see live performance stats
    
    7. RESPONSIVE BREAKPOINTS:
       - Modify StoppedUI.Breakpoints if needed
       - Layouts auto-adjust: Mobile/Tablet/Desktop/Wide
       - Splitter auto-hides on mobile
    
    8. SPLITTER:
       - Enabled by default (EnableSplitter = true)
       - Drag to resize LeftPane/PreviewPane
       - Width fraction saved in self._leftPaneWidth
       - Min/max constraints: 280px - 600px
    
    9. SNAP TO EDGES:
       - Enabled by default (SnapToEdges = true)
       - Adjust SnapDistance for sensitivity (default: 10px)
       - Ghost preview shows snap target
    
    10. NOTIFICATION SYSTEM:
        - Always visible (no manual toggle needed)
        - Automatic history tracking (last 50)
        - View history: Ctrl+K → "View Notification History"
        - Custom types: Info, Success, Warning, Error
    
    11. HOTKEY CUSTOMIZER:
        - Register hotkeys: self:RegisterHotkey(name, keyCode, callback, modifiers)
        - Modifiers: {Ctrl = true, Shift = true, Alt = true}
        - Manage via: Ctrl+K → "Open Hotkey Manager"
    
    12. THEME STORE:
        - Live preview of all themes
        - Apply instantly with one click
        - Automatically updates all UI elements
        - Access via: Ctrl+K → "Open Theme Store"
    
    13. IMAGE HANDLING:
        - Unified system: UIHelpers.ResolveImage(input)
        - Supports: rbxassetid://123, "123", "https://...", imgur hash
        - Auto-fallback to default image
        - Works in exploit environments with URL support
    
    EXAMPLE - Full Customization:
    
    local window = StoppedUI:Create({
        Name = "My App",
        Theme = "Dark",
        TranslationEnabled = false,
        DevMode = false,
        LayoutMode = "Normal",
        EnableSplitter = true,
        SnapToEdges = true,
        SnapDistance = 10,
        ConfigEnabled = true
    })
    
    -- Register custom commands (appear in Ctrl+K)
    window:RegisterCommand("Export Data", "Export to CSV", function()
        exportData()
        window:Notify({Text = "Exported!", Type = "Success"})
    end)
    
    window:RegisterCommand("Import Data", "Import from file", function()
        importData()
    end)
    
    -- Register custom hotkeys
    window:RegisterHotkey("Quick Save", Enum.KeyCode.S, function()
        window:RequestSave()
    end, {Ctrl = true})
    
    -- Hook into config (you implement storage)
    window.Config.OnRequestSave.Event:Connect(function()
        local state = window.Config.GetState()
        state.Meta = {
            SplitterWidth = window._leftPaneWidth,
            LayoutMode = window.LayoutMode
        }
        writefile("config.json", HttpService:JSONEncode(state))
        window:Notify({Text = "Saved!", Type = "Success"})
    end)
    
    window.Config.OnRequestLoad.Event:Connect(function()
        if isfile("config.json") then
            local state = HttpService:JSONDecode(readfile("config.json"))
            
            -- Restore meta settings
            if state.Meta then
                if state.Meta.SplitterWidth then
                    window._leftPaneWidth = state.Meta.SplitterWidth
                    window:UpdatePaneLayout(false)
                end
                if state.Meta.LayoutMode then
                    window:SetLayoutMode(state.Meta.LayoutMode)
                end
            end
            
            -- Apply element states
            window.Config.SetState(state)
            window:Notify({Text = "Loaded!", Type = "Success"})
        end
    end)
    
    -- Add custom theme
    StoppedUI.Themes.Cyberpunk = {
        Background = Color3.fromRGB(10, 10, 20),
        Card = Color3.fromRGB(20, 20, 35),
        Secondary = Color3.fromRGB(30, 30, 45),
        Accent = Color3.fromRGB(255, 0, 150),
        Text = Color3.fromRGB(0, 255, 255),
        TextDim = Color3.fromRGB(100, 200, 200),
        Border = Color3.fromRGB(255, 0, 150),
        Success = Color3.fromRGB(0, 255, 100),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 50),
        Radius = 12
    }
    
    -- Change layout programmatically
    window:SetLayoutMode("Compact")
    
    -- Apply custom theme
    window:ApplyTheme("Cyberpunk")
    
    -- Add tabs and elements
    local tab = window:CreateTab({Name = "Main"})
    window:AddSlider(tab, {
        Label = "Speed",
        Min = 0,
        Max = 100,
        Value = 50,
        Callback = function(v) print(v) end
    })
    
    -- Cleanup on close
    game:BindToClose(function()
        window:Destroy()
    end)
]]

-- ========================================
-- QUICK ACTIONS BAR (Floating Action Buttons)
-- ========================================
function StoppedUI:CreateQuickActionsBar()
    local quickBar = Instance.new("Frame")
    quickBar.Name = "QuickActionsBar"
    quickBar.Size = UDim2.new(0, 60, 0, 300)
    quickBar.Position = UDim2.new(0, 10, 0.5, -150)
    quickBar.AnchorPoint = Vector2.new(0, 0.5)
    quickBar.BackgroundColor3 = self.Theme.Card
    quickBar.BackgroundTransparency = 0.1
    quickBar.BorderSizePixel = 0
    quickBar.ZIndex = 998
    quickBar.Visible = false
    quickBar.Parent = self.Container
    UIHelpers.CreateRound(quickBar, self.Theme.Radius)
    UIHelpers.CreateStroke(quickBar, self.Theme.Accent, 1, 0.8)
    
    local quickLayout = Instance.new("UIListLayout")
    quickLayout.Padding = UDim.new(0, 8)
    quickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    quickLayout.Parent = quickBar
    
    UIHelpers.CreatePadding(quickBar, 8)
    
    self.QuickActionsBar = {
        Container = quickBar,
        Actions = {}
    }
    
    -- Default quick actions
    self:AddQuickAction("🎨", "Themes", function()
        self:ToggleThemeStore()
    end)
    
    self:AddQuickAction("⌨️", "Hotkeys", function()
        self:ToggleHotkeyCustomizer()
    end)
    
    self:AddQuickAction("📜", "History", function()
        self:ToggleNotificationHistory()
    end)
    
    self:AddQuickAction("📊", "Profiler", function()
        self:ToggleProfiler()
    end)
    
    self:AddQuickAction("🔧", "Dev", function()
        self:ToggleDevMode()
    end)
    
    -- Toggle button for quick bar
    local toggleQuickBtn = Instance.new("TextButton")
    toggleQuickBtn.Size = UDim2.new(0, 30, 0, 30)
    toggleQuickBtn.Position = UDim2.new(0, 10, 0.5, -15)
    toggleQuickBtn.BackgroundColor3 = self.Theme.Accent
    toggleQuickBtn.Text = "⚡"
    toggleQuickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleQuickBtn.TextSize = 16
    toggleQuickBtn.Font = Enum.Font.GothamBold
    toggleQuickBtn.BorderSizePixel = 0
    toggleQuickBtn.ZIndex = 999
    toggleQuickBtn.Parent = self.Container
    UIHelpers.CreateRound(toggleQuickBtn, 15)
    
    self.QuickActionsToggle = toggleQuickBtn
    
    UIHelpers.SafeConnect(toggleQuickBtn.MouseButton1Click, function()
        self:ToggleQuickActions()
    end, self._allConnections)
    
    UIHelpers.SafeConnect(toggleQuickBtn.MouseEnter, function()
        UIHelpers.Tween(toggleQuickBtn, {
            Size = UDim2.new(0, 35, 0, 35),
            Rotation = 15
        }, 0.15)
    end, self._allConnections)
    
    UIHelpers.SafeConnect(toggleQuickBtn.MouseLeave, function()
        UIHelpers.Tween(toggleQuickBtn, {
            Size = UDim2.new(0, 30, 0, 30),
            Rotation = 0
        }, 0.15)
    end, self._allConnections)
end

function StoppedUI:AddQuickAction(icon, tooltip, callback)
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 44, 0, 44)
    actionBtn.BackgroundColor3 = self.Theme.Secondary
    actionBtn.Text = icon
    actionBtn.TextColor3 = self.Theme.Text
    actionBtn.TextSize = 20
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.BorderSizePixel = 0
    actionBtn.Parent = self.QuickActionsBar.Container
    UIHelpers.CreateRound(actionBtn, self.Theme.Radius)
    
    -- Tooltip
    local tooltipLabel = Instance.new("TextLabel")
    tooltipLabel.Size = UDim2.new(0, 0, 0, 24)
    tooltipLabel.Position = UDim2.new(1, 8, 0.5, 0)
    tooltipLabel.AnchorPoint = Vector2.new(0, 0.5)
    tooltipLabel.BackgroundColor3 = self.Theme.Background
    tooltipLabel.Text = tooltip
    tooltipLabel.TextColor3 = self.Theme.Text
    tooltipLabel.TextSize = 12
    tooltipLabel.Font = Enum.Font.Gotham
    tooltipLabel.Visible = false
    tooltipLabel.BorderSizePixel = 0
    tooltipLabel.ZIndex = 1000
    tooltipLabel.Parent = actionBtn
    UIHelpers.CreateRound(tooltipLabel, 4)
    UIHelpers.CreatePadding(tooltipLabel, 8)
    
    UIHelpers.SafeConnect(actionBtn.MouseEnter, function()
        UIHelpers.Tween(actionBtn, {BackgroundColor3 = self.Theme.Accent}, 0.15)
        tooltipLabel.Visible = true
        tooltipLabel.Size = UDim2.new(0, 0, 0, 24)
        UIHelpers.Tween(tooltipLabel, {Size = UDim2.new(0, tooltipLabel.TextBounds.X + 16, 0, 24)}, 0.2)
    end, self._allConnections)
    
    UIHelpers.SafeConnect(actionBtn.MouseLeave, function()
        UIHelpers.Tween(actionBtn, {BackgroundColor3 = self.Theme.Secondary}, 0.15)
        UIHelpers.Tween(tooltipLabel, {Size = UDim2.new(0, 0, 0, 24)}, 0.15)
        task.wait(0.15)
        tooltipLabel.Visible = false
    end, self._allConnections)
    
    UIHelpers.SafeConnect(actionBtn.MouseButton1Click, function()
        UIHelpers.Tween(actionBtn, {Size = UDim2.new(0, 40, 0, 40)}, 0.08)
        task.wait(0.08)
        UIHelpers.Tween(actionBtn, {Size = UDim2.new(0, 44, 0, 44)}, 0.08)
        pcall(callback)
    end, self._allConnections)
    
    table.insert(self.QuickActionsBar.Actions, {
        Button = actionBtn,
        Tooltip = tooltip,
        Callback = callback
    })
end

function StoppedUI:ToggleQuickActions()
    local bar = self.QuickActionsBar.Container
    bar.Visible = not bar.Visible
    
    if bar.Visible then
        bar.Size = UDim2.new(0, 0, 0, 300)
        bar.BackgroundTransparency = 1
        UIHelpers.Tween(bar, {Size = UDim2.new(0, 60, 0, 300)}, 0.25)
        UIHelpers.Tween(bar, {BackgroundTransparency = 0.1}, 0.2)
        
        -- Animate toggle button
        UIHelpers.Tween(self.QuickActionsToggle, {Position = UDim2.new(0, 80, 0.5, -15)}, 0.25)
    else
        UIHelpers.Tween(bar, {Size = UDim2.new(0, 0, 0, 300)}, 0.2)
        UIHelpers.Tween(bar, {BackgroundTransparency = 1}, 0.2)
        
        -- Animate toggle button back
        UIHelpers.Tween(self.QuickActionsToggle, {Position = UDim2.new(0, 10, 0.5, -15)}, 0.25)
    end
end

-- ========================================
-- SNIPPET/TEMPLATE SYSTEM
-- ========================================
StoppedUI.Snippets = {}

function StoppedUI:SaveElementAsSnippet(element, snippetName)
    if not element or not snippetName then return false end
    
    local snippet = {
        Type = element.Type,
        Name = snippetName,
        Config = {},
        Timestamp = os.date("%Y-%m-%d %H:%M:%S")
    }
    
    -- Save element-specific config
    if element.Type == "Toggle" then
        snippet.Config = {
            Text = element.Container:FindFirstChildOfClass("TextLabel").Text,
            Default = element:GetValue()
        }
    elseif element.Type == "Slider" then
        snippet.Config = {
            Label = element.Slider.ValueLabel.Text,
            Min = element.Slider.Min,
            Max = element.Slider.Max,
            Value = element.Slider.Value,
            Height = 6
        }
    elseif element.Type == "Button" then
        snippet.Config = {
            Text = element.Button.Text
        }
    end
    
    StoppedUI.Snippets[snippetName] = snippet
    
    self:Notify({
        Text = "Snippet saved: " .. snippetName,
        Type = "Success",
        Duration = 2
    })
    
    return true
end

function StoppedUI:LoadSnippet(tab, snippetName, callback)
    local snippet = StoppedUI.Snippets[snippetName]
    if not snippet then
        self:Notify({
            Text = "Snippet not found: " .. snippetName,
            Type = "Error",
            Duration = 3
        })
        return nil
    end
    
    local element
    
    if snippet.Type == "Toggle" then
        element = self:AddToggle(tab, {
            Text = snippet.Config.Text,
            Default = snippet.Config.Default,
            Callback = callback
        })
    elseif snippet.Type == "Slider" then
        element = self:AddSlider(tab, {
            Label = snippet.Config.Label,
            Min = snippet.Config.Min,
            Max = snippet.Config.Max,
            Value = snippet.Config.Value,
            Height = snippet.Config.Height or 6,
            Callback = callback
        })
    elseif snippet.Type == "Button" then
        element = self:AddButton(tab, {
            Text = snippet.Config.Text,
            Callback = callback
        })
    end
    
    self:Notify({
        Text = "Snippet loaded: " .. snippetName,
        Type = "Success",
        Duration = 2
    })
    
    return element
end

function StoppedUI:ListSnippets()
    local snippets = {}
    for name, snippet in pairs(StoppedUI.Snippets) do
        table.insert(snippets, {
            Name = name,
            Type = snippet.Type,
            Timestamp = snippet.Timestamp
        })
    end
    return snippets
end

function StoppedUI:ExportSnippet(snippetName)
    local snippet = StoppedUI.Snippets[snippetName]
    if not snippet then return nil end
    
    local encoded = HttpService:JSONEncode(snippet)
    
    if setclipboard then
        setclipboard(encoded)
        self:Notify({
            Text = "Snippet copied to clipboard!",
            Type = "Success",
            Duration = 2
        })
    end
    
    return encoded
end

function StoppedUI:ImportSnippet(encoded, snippetName)
    local ok, snippet = pcall(function()
        return HttpService:JSONDecode(encoded)
    end)
    
    if not ok or not snippet then
        self:Notify({
            Text = "Invalid snippet data",
            Type = "Error",
            Duration = 3
        })
        return false
    end
    
    snippetName = snippetName or snippet.Name or "Imported_" .. math.random(1000, 9999)
    StoppedUI.Snippets[snippetName] = snippet
    
    self:Notify({
        Text = "Snippet imported: " .. snippetName,
        Type = "Success",
        Duration = 2
    })
    
    return true
end

return StoppedUI