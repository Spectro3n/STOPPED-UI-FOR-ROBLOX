local StoppedUI = {}
StoppedUI.__index = StoppedUI
StoppedUI.Version = "4.0.1"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Theme System
StoppedUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 20),
        Secondary = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(100, 200, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(160, 160, 160),
        Border = Color3.fromRGB(50, 50, 50),
        Success = Color3.fromRGB(100, 255, 100),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100)
    }
}

-- Translation System
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

-- Utility Functions
local function Tween(obj, props, duration)
    duration = duration or 0.3
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint), props):Play()
end

local function CreateRound(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(50, 50, 50)
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all or 5)
    padding.PaddingBottom = UDim.new(0, all or 5)
    padding.PaddingLeft = UDim.new(0, all or 5)
    padding.PaddingRight = UDim.new(0, all or 5)
    padding.Parent = parent
    return padding
end

local function Clamp(n, lo, hi)
    return math.max(lo, math.min(hi, n))
end

-- Translation Helper
function StoppedUI:Tr(key)
    local locale = self.Locale or "en"
    if self.Translations[locale] and self.Translations[locale][key] then
        return self.Translations[locale][key]
    end
    return key
end

-- Imgur Image Loader
function StoppedUI:LoadImgurImage(hash)
    if self._imgCache[hash] then
        return self._imgCache[hash]
    end
    
    local candidates = {
        string.format("https://i.imgur.com/%s.png", hash),
        string.format("https://i.imgur.com/%s.jpg", hash),
        string.format("https://i.imgur.com/%s.gif", hash)
    }
    
    local chosen = candidates[1]
    
    if request then
        for _, url in ipairs(candidates) do
            local ok, resp = pcall(function()
                return request({Url = url, Method = "HEAD", Timeout = 3})
            end)
            if ok and resp and (resp.StatusCode == 200 or resp.StatusCode == 0) then
                chosen = url
                break
            end
        end
    end
    
    self._imgCache[hash] = chosen
    return chosen
end

-- SetImageFromImgur
function StoppedUI:SetImageFromImgur(target, hashOrUrl, preferredFallback)
    if not target then return end
    
    local function chooseFallback()
        if preferredFallback and type(preferredFallback) == "string" then
            return preferredFallback
        end
        if self.FallbackImages and #self.FallbackImages > 0 then
            return self.FallbackImages[1]
        end
        return nil
    end
    
    local function applyUrl(url)
        if not url then
            target.Image = ""
            target.ImageTransparency = 1
            return
        end
        if not url:match("^https?://") then
            local final = self:LoadImgurImage(url) or ("https://i.imgur.com/" .. url .. ".png")
            target.Image = final
        else
            target.Image = url
        end
    end
    
    local function validateAndApply(urls)
        for _, u in ipairs(urls) do
            if request then
                local ok, resp = pcall(function()
                    return request({Url = u, Method = "HEAD", Timeout = 4})
                end)
                if ok and resp and (resp.StatusCode == 200 or resp.StatusCode == 0) then
                    applyUrl(u)
                    return
                end
            else
                applyUrl(u)
                return
            end
        end
        applyUrl(chooseFallback())
    end
    
    if not hashOrUrl or hashOrUrl == "" then
        applyUrl(chooseFallback())
        return
    end
    
    if hashOrUrl:match("^https?://") then
        validateAndApply({hashOrUrl})
    else
        local cands = {
            string.format("https://i.imgur.com/%s.png", hashOrUrl),
            string.format("https://i.imgur.com/%s.jpg", hashOrUrl),
            string.format("https://i.imgur.com/%s.gif", hashOrUrl)
        }
        validateAndApply(cands)
    end
end

-- Main UI Creation
function StoppedUI:Create(config)
    local self = setmetatable({}, StoppedUI)
    
    config = config or {}
    self.Name = config.Name or "StoppedUI"
    self.Theme = StoppedUI.Themes[config.Theme or "Dark"]
    self.DefaultNotificationDuration = config.DefaultNotificationDuration or 5
    self.MaxNotifications = config.MaxNotifications or 6
    self.NotificationBellImgurHash = config.NotificationBellImgurHash or "3926305904"
    self.Locale = config.Locale or "en"
    self.ShowPreview = config.ShowPreview == nil and true or config.ShowPreview
    
    self._imgCache = {}
    self._keybinds = {}
    self._notificationPool = {}
    self._configs = {}
    self._configCallbacks = {}
    self._dropdownRenderConnections = {}
    self._notificationPanelConn = nil
    self._recentNotif = {}
    self._allConnections = {}
    
    if not self.FallbackImages then
        self.FallbackImages = {"https://i.imgur.com/placeholder.png"}
    end
    
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
    
    -- Main Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "MainContainer"
    self.Container.Size = UDim2.new(0, 800, 0, 550)
    self.Container.Position = UDim2.new(0, 200, 0, 150)
    self.Container.AnchorPoint = Vector2.new(0, 0)
    self.Container.BackgroundColor3 = self.Theme.Background
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.Parent = self.ScreenGui
    CreateRound(self.Container, 12)
    CreateStroke(self.Container, self.Theme.Border, 2)
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = -1
    shadow.Parent = self.Container
    
    -- Topbar
    self.Topbar = Instance.new("Frame")
    self.Topbar.Name = "Topbar"
    self.Topbar.Size = UDim2.new(1, 0, 0, 50)
    self.Topbar.BackgroundColor3 = self.Theme.Secondary
    self.Topbar.BorderSizePixel = 0
    self.Topbar.Parent = self.Container
    CreateRound(self.Topbar, 12)
    
    local topbarBorder = Instance.new("Frame")
    topbarBorder.Size = UDim2.new(1, 0, 0, 2)
    topbarBorder.Position = UDim2.new(0, 0, 1, 0)
    topbarBorder.BackgroundColor3 = self.Theme.Accent
    topbarBorder.BorderSizePixel = 0
    topbarBorder.Parent = self.Topbar
    
    -- Title
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
    self.Title.Parent = self.Topbar
    
    -- Logo
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0, 15, 0.5, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.ImageColor3 = self.Theme.Accent
    logo.Parent = self.Topbar
    CreateRound(logo, 6)
    self.Logo = logo
    
    if config.Logo then
        self:SetImageFromImgur(logo, config.Logo, "3944680095")
    else
        logo.Image = "rbxassetid://3944680095"
    end
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = self.Theme.Secondary
    closeBtn.Text = "×"
    closeBtn.TextColor3 = self.Theme.Text
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = self.Topbar
    CreateRound(closeBtn, 8)
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = self.Theme.Error}, 0.2)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = self.Theme.Secondary}, 0.2)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Tween(self.Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.35)
        Tween(self.Container, {BackgroundTransparency = 1}, 0.35)
        task.delay(0.36, function()
            if self and self.ScreenGui then
                self.ScreenGui.Enabled = false
                self.Container.Size = UDim2.new(0, 800, 0, 550)
                self.Container.BackgroundTransparency = 0
            end
        end)
    end)
    
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
    
    -- Left Pane
    self.LeftPane = Instance.new("ScrollingFrame")
    self.LeftPane.Name = "LeftPane"
    self.LeftPane.Size = UDim2.new(0, 350, 1, -70)
    self.LeftPane.Position = UDim2.new(0, 10, 0, 70)
    self.LeftPane.BackgroundTransparency = 1
    self.LeftPane.BorderSizePixel = 0
    self.LeftPane.ScrollBarThickness = 4
    self.LeftPane.ScrollBarImageColor3 = self.Theme.Accent
    self.LeftPane.Parent = self.Content
    CreatePadding(self.LeftPane, 5)
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 10)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = self.LeftPane
    
    -- Preview Pane
    self.PreviewPane = Instance.new("Frame")
    self.PreviewPane.Name = "PreviewPane"
    self.PreviewPane.Size = UDim2.new(1, -380, 1, -70)
    self.PreviewPane.Position = UDim2.new(0, 370, 0, 70)
    self.PreviewPane.BackgroundColor3 = self.Theme.Background
    self.PreviewPane.BorderSizePixel = 0
    self.PreviewPane.Visible = self.ShowPreview
    self.PreviewPane.Parent = self.Content
    CreateRound(self.PreviewPane, 8)
    CreateStroke(self.PreviewPane, self.Theme.Border)
    
    local previewCanvas = Instance.new("Frame")
    previewCanvas.Name = "PreviewCanvas"
    previewCanvas.Size = UDim2.new(1, -20, 1, -60)
    previewCanvas.Position = UDim2.new(0, 10, 0, 10)
    previewCanvas.BackgroundTransparency = 1
    previewCanvas.ClipsDescendants = true
    previewCanvas.Parent = self.PreviewPane
    
    local previewLabel = Instance.new("TextLabel")
    previewLabel.Name = "PreviewLabel"
    previewLabel.Size = UDim2.new(1, 0, 0, 20)
    previewLabel.Position = UDim2.new(0, 10, 0, 10)
    previewLabel.BackgroundTransparency = 1
    previewLabel.Text = self:Tr("Preview")
    previewLabel.TextColor3 = self.Theme.TextDim
    previewLabel.Font = Enum.Font.Gotham
    previewLabel.TextSize = 12
    previewLabel.TextXAlignment = Enum.TextXAlignment.Left
    previewLabel.Parent = previewCanvas
    
    self.PreviewCanvas = previewCanvas
    
    local previewFooter = Instance.new("Frame")
    previewFooter.Size = UDim2.new(1, -20, 0, 40)
    previewFooter.Position = UDim2.new(0, 10, 1, -50)
    previewFooter.BackgroundColor3 = self.Theme.Secondary
    previewFooter.BorderSizePixel = 0
    previewFooter.Parent = self.PreviewPane
    CreateRound(previewFooter, 6)
    
    local previewModeLabel = Instance.new("TextLabel")
    previewModeLabel.Size = UDim2.new(0, 80, 1, 0)
    previewModeLabel.Position = UDim2.new(0, 10, 0, 0)
    previewModeLabel.BackgroundTransparency = 1
    previewModeLabel.Text = self:Tr("Mode")
    previewModeLabel.TextColor3 = self.Theme.TextDim
    previewModeLabel.Font = Enum.Font.Gotham
    previewModeLabel.TextSize = 12
    previewModeLabel.TextXAlignment = Enum.TextXAlignment.Left
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
    CreateRound(previewModeBtn, 6)
    
    self.PreviewMode = "Players"
    previewModeBtn.MouseButton1Click:Connect(function()
        self.PreviewMode = (self.PreviewMode == "Players") and "Vehicles" or "Players"
        previewModeBtn.Text = self:Tr(self.PreviewMode)
    end)
    
    -- Footer
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, -20, 0, 38)
    footer.Position = UDim2.new(0, 10, 1, -50)
    footer.BackgroundColor3 = self.Theme.Secondary
    footer.BorderSizePixel = 0
    footer.Parent = self.Container
    CreateRound(footer, 8)
    CreatePadding(footer, 10)
    
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, 0, 1, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = self:Tr("Username") .. " " .. LocalPlayer.Name
    usernameLabel.TextColor3 = self.Theme.TextDim
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 13
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = footer
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.Notifications = {}
    
    self:CreateConfigTab()
    self:MakeDraggable()
    self:SetupResponsiveness()
    
    self.Container.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Container, {Size = UDim2.new(0, 800, 0, 550)}, 0.5)
    
    return self
end

function StoppedUI:CreateNotificationBell()
    local bellContainer = Instance.new("Frame")
    bellContainer.Name = "NotificationBellContainer"
    bellContainer.Size = UDim2.new(0, 60, 0, 60)
    bellContainer.AnchorPoint = Vector2.new(1, 0)
    bellContainer.Position = UDim2.new(1, -15, 0, 15)
    bellContainer.BackgroundColor3 = self.Theme.Secondary
    bellContainer.BorderSizePixel = 0
    bellContainer.ZIndex = 1000
    bellContainer.Parent = self.ScreenGui
    CreateRound(bellContainer, 10)
    CreateStroke(bellContainer, self.Theme.Border, 2)
    
    local bell = Instance.new("ImageButton")
    bell.Size = UDim2.new(0, 32, 0, 32)
    bell.Position = UDim2.new(0.5, 0, 0.5, 0)
    bell.AnchorPoint = Vector2.new(0.5, 0.5)
    bell.BackgroundTransparency = 1
    bell.ImageColor3 = self.Theme.TextDim
    bell.Parent = bellContainer
    
    self:SetImageFromImgur(bell, self.NotificationBellImgurHash)
    
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
    CreateRound(badge, 10)
    
    self.NotificationBadge = badge
    self.NotificationBell = bell
    self.NotificationBellContainer = bellContainer
    
    bell.MouseEnter:Connect(function()
        Tween(bell, {ImageColor3 = self.Theme.Accent}, 0.2)
        Tween(bellContainer, {BackgroundColor3 = self.Theme.Background}, 0.2)
    end)
    
    bell.MouseLeave:Connect(function()
        Tween(bell, {ImageColor3 = self.Theme.TextDim}, 0.2)
        Tween(bellContainer, {BackgroundColor3 = self.Theme.Secondary}, 0.2)
    end)
    
    local panel = Instance.new("ScrollingFrame")
    panel.Name = "NotificationPanel"
    panel.Size = UDim2.new(0, 360, 0, 0)
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -15, 0, 80)
    panel.BackgroundColor3 = self.Theme.Secondary
    panel.BorderSizePixel = 0
    panel.ScrollBarThickness = 6
    panel.ScrollBarImageColor3 = self.Theme.Accent
    panel.Visible = false
    panel.ZIndex = 1000
    panel.ClipsDescendants = true
    panel.Parent = self.ScreenGui
    CreateRound(panel, 8)
    CreateStroke(panel, self.Theme.Border)
    CreatePadding(panel, 6)
    
    local panelList = Instance.new("UIListLayout")
    panelList.Padding = UDim.new(0, 6)
    panelList.SortOrder = Enum.SortOrder.LayoutOrder
    panelList.Parent = panel
    
    self.NotificationPanel = panel
    self.NotificationPanelList = panelList
    
    local posConn = RunService.RenderStepped:Connect(function()
        if panel and panel.Parent and panel.Visible then
            local contentHeight = panelList.AbsoluteContentSize.Y + 16
            local maxHeight = math.min(450, workspace.CurrentCamera.ViewportSize.Y * 0.7)
            panel.Size = UDim2.new(0, 360, 0, math.min(maxHeight, contentHeight))
            panel.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        end
    end)
    self._notificationPanelConn = posConn
    table.insert(self._allConnections, posConn)
    
    bell.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
        if panel.Visible then
            local contentHeight = panelList.AbsoluteContentSize.Y + 16
            local maxHeight = math.min(450, workspace.CurrentCamera.ViewportSize.Y * 0.7)
            Tween(panel, {Size = UDim2.new(0, 360, 0, math.min(maxHeight, contentHeight))}, 0.28)
        else
            Tween(panel, {Size = UDim2.new(0, 360, 0, 0)}, 0.22)
        end
    end)
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
    
    local window = 3
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
        self._recentNotif[options.Key] = { t = tick(), count = 1 }
    end
    
    if #self.Notifications >= self.MaxNotifications then
        local oldest = table.remove(self.Notifications, 1)
        if oldest and oldest.Parent then
            oldest.Parent = nil
            table.insert(self._notificationPool, oldest)
        end
    end
    
    local notif = table.remove(self._notificationPool) or Instance.new("Frame")
    notif.Size = UDim2.new(1, -10, 0, 0)
    notif.AutomaticSize = Enum.AutomaticSize.Y
    notif.BackgroundColor3 = self.Theme.Background
    notif.BorderSizePixel = 0
    notif.LayoutOrder = #self.Notifications + 1
    notif.Parent = self.NotificationPanel
    
    if not notif:FindFirstChild("UICorner") then
        CreateRound(notif, 6)
        CreatePadding(notif, 10)
    end
    
    local img = notif:FindFirstChild("NotifImage") or Instance.new("ImageLabel")
    img.Name = "NotifImage"
    img.Size = UDim2.new(0, 48, 0, 48)
    img.Position = UDim2.new(0, 0, 0, 0)
    img.BackgroundTransparency = 1
    img.ImageColor3 = colors[type] or self.Theme.Accent
    img.Parent = notif
    CreateRound(img, 6)
    
    self:SetImageFromImgur(img, imgHash, "3944680095")
    
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
    
    notif.BackgroundTransparency = 1
    label.TextTransparency = 1
    img.ImageTransparency = 1
    Tween(notif, {BackgroundTransparency = 0}, 0.3)
    Tween(label, {TextTransparency = 0}, 0.3)
    Tween(img, {ImageTransparency = 0}, 0.3)
    if subText ~= "" then
        subLabel.TextTransparency = 1
        Tween(subLabel, {TextTransparency = 0}, 0.3)
    end
    
    table.insert(self.Notifications, notif)
    
    if options.Key then
        self._recentNotif[options.Key].notif = notif
    end
    
    self.NotificationBadge.Text = tostring(#self.Notifications)
    self.NotificationBadge.Visible = true
    
    task.spawn(function()
        Tween(self.NotificationBadge, {Size = UDim2.new(0, 24, 0, 24)}, 0.2)
        task.wait(0.2)
        Tween(self.NotificationBadge, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
    end)
    
    task.spawn(function()
        local t0 = tick()
        local t1 = t0 + duration
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if tick() >= t1 or not progress.Parent then
                progress.Size = UDim2.new(0, 0, 0, 3)
                if conn then conn:Disconnect() end
                return
            end
            local pct = 1 - ((tick() - t0) / duration)
            progress.Size = UDim2.new(pct, 0, 0, 3)
        end)
    end)
    
    task.delay(duration, function()
        if not notif.Parent then return end
        
        Tween(notif, {BackgroundTransparency = 1}, 0.3)
        Tween(label, {TextTransparency = 1}, 0.3)
        Tween(img, {ImageTransparency = 1}, 0.3)
        if subText ~= "" then
            Tween(subLabel, {TextTransparency = 1}, 0.3)
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

function StoppedUI:SetupResponsiveness()
    local camera = workspace.CurrentCamera
    
    local function updateResponsive()
        local viewportSize = camera.ViewportSize
        
        local function computeBadgeSize(viewportY)
            local base = 60
            local scale = math.clamp(viewportY / 720, 0.8, 1.5)
            return math.floor(base * scale)
        end
        
        local bellSize = computeBadgeSize(viewportSize.Y)
        self.NotificationBellContainer.Size = UDim2.new(0, bellSize, 0, bellSize)
        
        if self.NotificationPanel then
            local maxHeight = math.min(450, viewportSize.Y * 0.7)
            if self.NotificationPanel.Visible then
                local contentHeight = self.NotificationPanelList.AbsoluteContentSize.Y + 16
                self.NotificationPanel.Size = UDim2.new(0, 360, 0, math.min(maxHeight, contentHeight))
            end
        end
        
        local containerSize = self.Container.AbsoluteSize
        local containerPos = self.Container.AbsolutePosition
        
        if containerPos.X + containerSize.X > viewportSize.X then
            self.Container.Position = UDim2.new(0, viewportSize.X - containerSize.X - 10, 0, self.Container.Position.Y.Offset)
        end
        
        if containerPos.Y + containerSize.Y > viewportSize.Y then
            self.Container.Position = UDim2.new(0, self.Container.Position.X.Offset, 0, viewportSize.Y - containerSize.Y - 10)
        end
    end
    
    local conn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive)
    table.insert(self._allConnections, conn)
end

function StoppedUI:Toggle()
    if not self.ScreenGui then return end
    if self.ScreenGui.Enabled then
        Tween(self.Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
        task.wait(0.26)
        self.ScreenGui.Enabled = false
    else
        self.ScreenGui.Enabled = true
        self.Container.Size = UDim2.new(0, 0, 0, 0)
        Tween(self.Container, {Size = UDim2.new(0, 800, 0, 550)}, 0.4)
    end
end

function StoppedUI:MakeDraggable()
    local dragging = false
    local dragStartPos = Vector2.new(0, 0)
    local startWindowPos = Vector2.new(0, 0)
    local dragConn

    local function stopDrag()
        dragging = false
        if dragConn then
            dragConn:Disconnect()
            dragConn = nil
        end
    end

    local conn1 = self.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = input.Position
            startWindowPos = self.Container.AbsolutePosition

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    stopDrag()
                end
            end)

            dragConn = RunService.RenderStepped:Connect(function()
                if not dragging then return end
                local mousePos = UserInputService:GetMouseLocation()
                local delta = mousePos - dragStartPos
                local newPos = startWindowPos + delta

                local viewport = workspace.CurrentCamera.ViewportSize
                local cs = self.Container.AbsoluteSize
                newPos = Vector2.new(
                    math.clamp(newPos.X, 0, math.max(0, viewport.X - cs.X)),
                    math.clamp(newPos.Y, 0, math.max(0, viewport.Y - cs.Y))
                )

                self.Container.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
            end)
            table.insert(self._allConnections, dragConn)
        end
    end)
    
    table.insert(self._allConnections, conn1)

    local conn2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stopDrag()
        end
    end)
    
    table.insert(self._allConnections, conn2)
end

function StoppedUI:CreateTab(config)
    config = config or {}
    local tabName = config.Name or "Tab"
    local icon = config.Icon
    
    local tab = {
        Name = tabName,
        Elements = {},
        Container = nil
    }
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName
    tabBtn.Size = UDim2.new(0, 120, 1, 0)
    tabBtn.BackgroundColor3 = self.Theme.Background
    tabBtn.Text = ""
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.TabButtonContainer
    CreateRound(tabBtn, 8)
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, icon and -30 or -10, 1, 0)
    tabLabel.Position = UDim2.new(0, icon and 30 or 10, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = tabName
    tabLabel.TextColor3 = self.Theme.TextDim
    tabLabel.TextSize = 13
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = tabBtn
    
    if icon then
        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.Position = UDim2.new(0, 8, 0.5, 0)
        iconImg.AnchorPoint = Vector2.new(0, 0.5)
        iconImg.BackgroundTransparency = 1
        iconImg.ImageColor3 = self.Theme.TextDim
        iconImg.Parent = tabBtn
        
        self:SetImageFromImgur(iconImg, icon, "3944680095")
        tab.Icon = iconImg
    end
    
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
    
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tabBtn, {BackgroundColor3 = self.Theme.Secondary}, 0.2)
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tabBtn, {BackgroundColor3 = self.Theme.Background}, 0.2)
        end
    end)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Container.Visible = false
            local btn = self.TabButtonContainer:FindFirstChild(t.Name)
            if btn then
                Tween(btn, {BackgroundColor3 = self.Theme.Background}, 0.2)
                local lbl = btn:FindFirstChildOfClass("TextLabel")
                if lbl then
                    Tween(lbl, {TextColor3 = self.Theme.TextDim}, 0.2)
                end
                if t.Icon then
                    Tween(t.Icon, {ImageColor3 = self.Theme.TextDim}, 0.2)
                end
            end
        end
        
        content.Visible = true
        Tween(tabBtn, {BackgroundColor3 = self.Theme.Accent}, 0.2)
        Tween(tabLabel, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
        if tab.Icon then
            Tween(tab.Icon, {ImageColor3 = Color3.fromRGB(255,255,255)}, 0.2)
        end
        self.CurrentTab = tab
    end)
    
    if #self.Tabs == 1 then
        tabBtn.BackgroundColor3 = self.Theme.Accent
        tabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        if tab.Icon then
            tab.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
        content.Visible = true
        self.CurrentTab = tab
    end
    
    table.insert(self.Tabs, tab)
    
    tab.CreateToggle = function(_, opts) return self:CreateToggle(tab, opts) end
    tab.CreateSlider = function(_, opts) return self:CreateSlider(tab, opts) end
    tab.CreateButton = function(_, opts) return self:CreateButton(tab, opts) end
    tab.CreateKeybind = function(_, opts) return self:CreateKeybind(tab, opts) end
    tab.CreateDropdown = function(_, opts) return self:CreateDropdown(tab, opts) end
    tab.CreateLabel = function(_, opts) return self:CreateLabel(tab, opts) end
    
    return tab
end

function StoppedUI:CreateConfigTab()
    local configTab = self:CreateTab({
        Name = self:Tr("ConfigTab"),
        Icon = "7733955511"
    })
    
    -- Language Selector
    local langDropdown = configTab:CreateDropdown({
        Name = self:Tr("Language"),
        Items = {"English", "Português (BR)"},
        Default = self.Locale == "pt" and "Português (BR)" or "English",
        Callback = function(value)
            self.Locale = value == "Português (BR)" and "pt" or "en"
            self:Notify({
                Key = "ConfigSaved",
                ImageHash = "7733955511",
                Duration = 2,
                Type = "Success"
            })
        end
    })
    
    configTab:CreateLabel({ Text = "─────────────────" })
    
    -- Preview Toggle
    local previewToggle = configTab:CreateToggle({
        Name = self:Tr("ShowPreview"),
        Default = self.ShowPreview,
        Callback = function(value)
            self.ShowPreview = value
            if self.PreviewPane then
                self.PreviewPane.Visible = value
            end
        end
    })
    
    configTab:CreateLabel({ Text = "─────────────────" })
    
    -- Save Config Button
    configTab:CreateButton({
        Name = self:Tr("SaveConfig"),
        Callback = function()
            local code = self:SaveConfig("default")
            if code then
                if setclipboard then
                    setclipboard(code)
                    self:Notify({
                        Key = "ConfigCopied",
                        ImageHash = "7733955511",
                        Duration = 3,
                        Type = "Success"
                    })
                else
                    self:Notify({
                        Text = "Config code: " .. code:sub(1, 50) .. "...",
                        ImageHash = "7733955511",
                        Duration = 5,
                        Type = "Info"
                    })
                end
            end
        end
    })
    
    configTab:CreateLabel({ Text = "─────────────────" })
    
    -- Load Config via Code
    configTab:CreateButton({
        Name = self:Tr("LoadConfig"),
        Callback = function()
            if getclipboard then
                local code = getclipboard()
                if code and #code > 0 then
                    local success = self:LoadConfig(code)
                    if not success then
                        self:Notify({
                            Key = "ConfigInvalid",
                            ImageHash = "7733955511",
                            Duration = 3,
                            Type = "Error"
                        })
                    end
                else
                    self:Notify({
                        Key = "ClipboardEmpty",
                        ImageHash = "7733955511",
                        Duration = 3,
                        Type = "Warning"
                    })
                end
            else
                self:Notify({
                    Key = "ClipboardNotSupported",
                    ImageHash = "7733955511",
                    Duration = 3,
                    Type = "Error"
                })
            end
        end
    })
end

-- Adaptive Config System (CONSOLIDADO - ÚNICA VERSÃO)
function StoppedUI:RegisterConfigCallback(identifier, saveFunc, loadFunc)
    self._configCallbacks[identifier] = {
        Save = saveFunc,
        Load = loadFunc
    }
end

function StoppedUI:SaveConfig(name)
    name = name or "default"
    local config = {
        Name = name,
        Version = self.Version,
        Locale = self.Locale,
        ShowPreview = self.ShowPreview,
        Tabs = {},
        Custom = {}
    }
    
    -- Save all tabs and elements
    for _, tab in pairs(self.Tabs) do
        local tabConfig = {
            Name = tab.Name,
            Elements = {}
        }
        
        for _, element in pairs(tab.Elements) do
            if element.Value ~= nil or element.Key ~= nil or element.Color ~= nil then
                table.insert(tabConfig.Elements, {
                    Name = element.Name,
                    Value = element.Value,
                    Key = element.Key,
                    Color = element.Color
                })
            end
        end
        
        table.insert(config.Tabs, tabConfig)
    end
    
    -- Save custom developer data
    for identifier, callbacks in pairs(self._configCallbacks) do
        if callbacks.Save then
            local success, data = pcall(callbacks.Save)
            if success then
                config.Custom[identifier] = data
            else
                warn("[StoppedUI] Config save error for '" .. identifier .. "':", data)
            end
        end
    end
    
    local success, json = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    
    if success then
        self._configs[name] = config
        self:Notify({
            Key = "ConfigSaved",
            ImageHash = "7733955511",
            Duration = 3,
            Type = "Success"
        })
        return json
    else
        self:Notify({
            Text = self:Tr("ErrorOccurred") .. " " .. tostring(json),
            ImageHash = "7733955511",
            Duration = 4,
            Type = "Error"
        })
        return nil
    end
end

function StoppedUI:LoadConfig(nameOrJson)
    nameOrJson = nameOrJson or "default"
    local config
    
    if self._configs[nameOrJson] then
        config = self._configs[nameOrJson]
    else
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(nameOrJson)
        end)
        
        if success then
            config = decoded
        else
            self:Notify({
                Key = "ConfigInvalid",
                ImageHash = "7733955511",
                Duration = 4,
                Type = "Error"
            })
            return false
        end
    end
    
    -- Load locale
    if config.Locale then
        self.Locale = config.Locale
    end
    
    -- Load ShowPreview
    if config.ShowPreview ~= nil then
        self.ShowPreview = config.ShowPreview
        if self.PreviewPane then
            self.PreviewPane.Visible = config.ShowPreview
        end
    end
    
    -- Load tabs and elements
    for _, tabConfig in pairs(config.Tabs or {}) do
        local tab = nil
        for _, t in pairs(self.Tabs) do
            if t.Name == tabConfig.Name then
                tab = t
                break
            end
        end
        
        if tab then
            for _, elementConfig in pairs(tabConfig.Elements or {}) do
                for _, element in pairs(tab.Elements) do
                    if element.Name == elementConfig.Name then
                        if element.Set and elementConfig.Value ~= nil then
                            element:Set(elementConfig.Value)
                        elseif element.Set and elementConfig.Key ~= nil then
                            element:Set(elementConfig.Key)
                        elseif element.Set and elementConfig.Color ~= nil then
                            element:Set(elementConfig.Color)
                        end
                    end
                end
            end
        end
    end
    
    -- Load custom developer data
    for identifier, data in pairs(config.Custom or {}) do
        if self._configCallbacks[identifier] and self._configCallbacks[identifier].Load then
            local success, err = pcall(self._configCallbacks[identifier].Load, data)
            if not success then
                warn("[StoppedUI] Config load error for '" .. identifier .. "':", err)
            end
        end
    end
    
    self:Notify({
        Key = "ConfigLoaded",
        ImageHash = "7733955511",
        Duration = 3,
        Type = "Success"
    })
    
    return true
end

-- Preview Draw Function (MELHORADO)
function StoppedUI:PreviewDraw(lines)
    local canvas = self.PreviewCanvas
    
    for _, child in pairs(canvas:GetChildren()) do
        if child.Name ~= "PreviewLabel" and not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    for i, line in ipairs(lines or {}) do
        if line.type == "line" then
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0, line.width or 2, 0, line.height or 120)
            bar.Position = UDim2.new(0, line.x or 10, 0, line.y or 40)
            bar.BackgroundColor3 = line.color or self.Theme.Success
            bar.BorderSizePixel = 0
            bar.Parent = canvas
            
        elseif line.type == "text" then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, line.width or 100, 0, line.height or 20)
            label.Position = UDim2.new(0, line.x or 10, 0, line.y or 10)
            label.BackgroundTransparency = 1
            label.Text = line.text or ""
            label.TextColor3 = line.color or self.Theme.Success
            label.Font = Enum.Font.Gotham
            label.TextSize = line.textSize or 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = canvas
            
        elseif line.type == "box" then
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, line.width or 100, 0, line.height or 100)
            box.Position = UDim2.new(0, line.x or 10, 0, line.y or 40)
            box.BackgroundTransparency = 1
            box.BorderSizePixel = 0
            box.Parent = canvas
            CreateStroke(box, line.color or self.Theme.Success, line.thickness or 2)
        end
    end
end

-- Toggle Element
function StoppedUI:CreateToggle(tab, options)
    options = options or {}
    local name = options.Name or "Toggle"
    local default = options.Default or false
    local callback = options.Callback or function() end
    
    local toggle = {
        Name = name,
        Value = default
    }
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 45)
    container.BackgroundColor3 = self.Theme.Secondary
    container.BorderSizePixel = 0
    container.Parent = tab.Container
    CreateRound(container, 8)
    CreatePadding(container, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 22)
    switch.Position = UDim2.new(1, -50, 0.5, 0)
    switch.AnchorPoint = Vector2.new(0, 0.5)
    switch.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Border
    switch.BorderSizePixel = 0
    switch.Parent = container
    CreateRound(switch, 11)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    CreateRound(knob, 9)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container
    
    btn.MouseButton1Click:Connect(function()
        toggle.Value = not toggle.Value
        
        Tween(switch, {BackgroundColor3 = toggle.Value and self.Theme.Accent or self.Theme.Border})
        Tween(knob, {Position = toggle.Value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
        
        local success, err = pcall(callback, toggle.Value)
        if not success then
            self:Notify({
                Text = self:Tr("ErrorOccurred") .. " " .. name .. "\n" .. tostring(err),
                Type = "Error",
                Duration = 4
            })
        end
    end)
    
    function toggle:Set(value)
        toggle.Value = value
        Tween(switch, {BackgroundColor3 = value and self.Theme.Accent or self.Theme.Border})
        Tween(knob, {Position = value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
        pcall(callback, value)
    end
    
    table.insert(tab.Elements, toggle)
    return toggle
end

-- Slider Element
function StoppedUI:CreateSlider(tab, options)
    options = options or {}
    local name = options.Name or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local callback = options.Callback or function() end
    
    local slider = {
        Name = name,
        Value = default
    }
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 60)
    container.BackgroundColor3 = self.Theme.Secondary
    container.BorderSizePixel = 0
    container.Parent = tab.Container
    CreateRound(container, 8)
    CreatePadding(container, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.Theme.Accent
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 1, -16)
    track.BackgroundColor3 = self.Theme.Background
    track.BorderSizePixel = 0
    track.Parent = container
    CreateRound(track, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    CreateRound(fill, 3)
    
    local dragging = false
    local lastUpdate = tick()
    local debounceDelay = 0.05
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    local conn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    table.insert(self._allConnections, conn)
    
    local conn2 = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            if tick() - lastUpdate < debounceDelay then return end
            lastUpdate = tick()
            
            local pos = Clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            
            slider.Value = value
            valueLabel.Text = tostring(value)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            
            pcall(callback, value)
        end
    end)
    table.insert(self._allConnections, conn2)
    
    function slider:Set(value)
        slider.Value = Clamp(value, min, max)
        valueLabel.Text = tostring(slider.Value)
        local pos = (slider.Value - min) / (max - min)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        pcall(callback, slider.Value)
    end
    
    table.insert(tab.Elements, slider)
    return slider
end

-- Button Element
function StoppedUI:CreateButton(tab, options)
    options = options or {}
    local name = options.Name or "Button"
    local callback = options.Callback or function() end
    
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(1, -10, 0, 45)
    container.BackgroundColor3 = self.Theme.Accent
    container.BorderSizePixel = 0
    container.Text = name
    container.TextColor3 = Color3.fromRGB(255, 255, 255)
    container.TextSize = 14
    container.Font = Enum.Font.GothamBold
    container.AutoButtonColor = false
    container.Parent = tab.Container
    CreateRound(container, 8)
    
    container.MouseEnter:Connect(function()
        Tween(container, {BackgroundColor3 = Color3.fromRGB(
            math.min(self.Theme.Accent.R * 255 * 1.2, 255) / 255,
            math.min(self.Theme.Accent.G * 255 * 1.2, 255) / 255,
            math.min(self.Theme.Accent.B * 255 * 1.2, 255) / 255
        )}, 0.2)
    end)
    
    container.MouseLeave:Connect(function()
        Tween(container, {BackgroundColor3 = self.Theme.Accent}, 0.2)
    end)
    
    container.MouseButton1Click:Connect(function()
        Tween(container, {Size = UDim2.new(1, -12, 0, 43)}, 0.1)
        task.wait(0.1)
        Tween(container, {Size = UDim2.new(1, -10, 0, 45)}, 0.1)
        
        pcall(callback)
    end)
    
    return container
end

-- Keybind Element (COM DETECÇÃO DE CONFLITO)
function StoppedUI:CreateKeybind(tab, options)
    options = options or {}
    local name = options.Name or "Keybind"
    local default = options.Default or Enum.KeyCode.E
    local callback = options.Callback or function() end
    
    local keybind = {
        Name = name,
        Key = default,
        Listening = false
    }
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 45)
    container.BackgroundColor3 = self.Theme.Secondary
    container.BorderSizePixel = 0
    container.Parent = tab.Container
    CreateRound(container, 8)
    CreatePadding(container, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -110, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local keyBox = Instance.new("TextButton")
    keyBox.Size = UDim2.new(0, 90, 0, 30)
    keyBox.Position = UDim2.new(1, -100, 0.5, 0)
    keyBox.AnchorPoint = Vector2.new(0, 0.5)
    keyBox.BackgroundColor3 = self.Theme.Background
    keyBox.Text = string.upper(tostring(default.Name))
    keyBox.TextColor3 = self.Theme.Accent
    keyBox.TextSize = 12
    keyBox.Font = Enum.Font.GothamBold
    keyBox.BorderSizePixel = 0
    keyBox.AutoButtonColor = false
    keyBox.Parent = container
    CreateRound(keyBox, 6)
    CreateStroke(keyBox, self.Theme.Border)
    
    keyBox.MouseEnter:Connect(function()
        if not keybind.Listening then
            Tween(keyBox, {BackgroundColor3 = self.Theme.Secondary}, 0.2)
        end
    end)
    
    keyBox.MouseLeave:Connect(function()
        if not keybind.Listening then
            Tween(keyBox, {BackgroundColor3 = self.Theme.Background}, 0.2)
        end
    end)
    
    keyBox.MouseButton1Click:Connect(function()
        keybind.Listening = true
        keyBox.Text = "..."
        Tween(keyBox, {TextColor3 = self.Theme.Warning}, 0.2)
        Tween(keyBox, {BackgroundColor3 = self.Theme.Warning:Lerp(self.Theme.Background, 0.8)}, 0.2)
    end)
    
    local conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            local newKeyName = string.upper(tostring(input.KeyCode.Name))
            
            -- Verificar conflitos (NOVO)
            local conflictName = nil
            for bindName, bind in pairs(self._keybinds) do
                if bind.Key == input.KeyCode and bindName ~= name then
                    conflictName = bindName
                    break
                end
            end
            
            if conflictName then
                self:Notify({
                    Text = self:Tr("KeyConflict") .. " " .. conflictName,
                    Type = "Warning",
                    Duration = 4
                })
            end
            
            keybind.Key = input.KeyCode
            keyBox.Text = newKeyName
            self._keybinds[name] = keybind
            
            Tween(keyBox, {TextColor3 = self.Theme.Accent}, 0.2)
            Tween(keyBox, {BackgroundColor3 = self.Theme.Background}, 0.2)
            keybind.Listening = false
            
        elseif not gpe and not keybind.Listening and input.KeyCode == keybind.Key then
            pcall(callback, keybind.Key)
        end
    end)
    table.insert(self._allConnections, conn)
    
    function keybind:Set(key)
        keybind.Key = key
        keyBox.Text = string.upper(tostring(key.Name))
        self._keybinds[name] = keybind
    end
    
    self._keybinds[name] = keybind
    table.insert(tab.Elements, keybind)
    return keybind
end

-- Dropdown Element (CORRIGIDO)
function StoppedUI:CreateDropdown(tab, options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local items = options.Items or {"Option 1", "Option 2", "Option 3"}
    local default = options.Default or items[1]
    local callback = options.Callback or function() end
    
    local dropdown = {
        Name = name,
        Value = default,
        Items = items
    }
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 45)
    container.BackgroundColor3 = self.Theme.Secondary
    container.BorderSizePixel = 0
    container.Parent = tab.Container
    CreateRound(container, 8)
    CreatePadding(container, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 110, 0, 30)
    button.Position = UDim2.new(1, -120, 0.5, 0)
    button.AnchorPoint = Vector2.new(0, 0.5)
    button.BackgroundColor3 = self.Theme.Background
    button.Text = default .. " ▼"
    button.TextColor3 = self.Theme.Accent
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = container
    CreateRound(button, 6)
    CreateStroke(button, self.Theme.Border)
    
    -- listFrame é filho de ScreenGui, não container (CORRIGIDO)
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0, 110, 0, #items * 35)
    listFrame.BackgroundColor3 = self.Theme.Secondary
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 1005
    listFrame.ClipsDescendants = true
    listFrame.Parent = self.ScreenGui
    CreateRound(listFrame, 6)
    CreateStroke(listFrame, self.Theme.Border)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame
    
    -- atualizar posição via RenderStepped (CORRIGIDO)
    local function updateListPosition()
        local absPos = button.AbsolutePosition
        local absSize = button.AbsoluteSize
        local x = absPos.X
        local y = absPos.Y + absSize.Y + 4
        listFrame.Position = UDim2.new(0, x, 0, y)
    end
    
    local posConn
    local function startTracking()
        if posConn then posConn:Disconnect() end
        posConn = RunService.RenderStepped:Connect(function()
            if listFrame.Visible then
                updateListPosition()
            end
        end)
        table.insert(self._dropdownRenderConnections, posConn)
        table.insert(self._allConnections, posConn)
    end
    
    for _, item in ipairs(items) do
        local itemBtn = Instance.new("TextButton")
        itemBtn.Size = UDim2.new(1, -4, 0, 33)
        itemBtn.BackgroundColor3 = self.Theme.Background
        itemBtn.Text = item
        itemBtn.TextColor3 = self.Theme.Text
        itemBtn.TextSize = 12
        itemBtn.Font = Enum.Font.Gotham
        itemBtn.BorderSizePixel = 0
        itemBtn.AutoButtonColor = false
        itemBtn.Parent = listFrame
        CreateRound(itemBtn, 4)
        
        itemBtn.MouseEnter:Connect(function()
            Tween(itemBtn, {BackgroundColor3 = self.Theme.Accent}, 0.15)
        end)
        
        itemBtn.MouseLeave:Connect(function()
            Tween(itemBtn, {BackgroundColor3 = self.Theme.Background}, 0.15)
        end)
        
        itemBtn.MouseButton1Click:Connect(function()
            dropdown.Value = item
            button.Text = item .. " ▼"
            listFrame.Visible = false
            pcall(callback, item)
        end)
    end
    
    button.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then
            startTracking()
            updateListPosition()
        end
    end)
    
    -- fechar ao clicar fora (CORRIGIDO)
    local clickConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and listFrame.Visible then
            local mouse = UserInputService:GetMouseLocation()
            local inList = (mouse.X >= listFrame.AbsolutePosition.X and 
                           mouse.X <= listFrame.AbsolutePosition.X + listFrame.AbsoluteSize.X and
                           mouse.Y >= listFrame.AbsolutePosition.Y and 
                           mouse.Y <= listFrame.AbsolutePosition.Y + listFrame.AbsoluteSize.Y)
            
            local inBtn = (mouse.X >= button.AbsolutePosition.X and 
                          mouse.X <= button.AbsolutePosition.X + button.AbsoluteSize.X and
                          mouse.Y >= button.AbsolutePosition.Y and 
                          mouse.Y <= button.AbsolutePosition.Y + button.AbsoluteSize.Y)
            
            if not inList and not inBtn then
                listFrame.Visible = false
            end
        end
    end)
    table.insert(self._allConnections, clickConn)
    
    function dropdown:Set(value)
        dropdown.Value = value
        button.Text = value .. " ▼"
        pcall(callback, value)
    end
    
    table.insert(tab.Elements, dropdown)
    return dropdown
end

-- Label Element
function StoppedUI:CreateLabel(tab, options)
    options = options or {}
    local text = options.Text or "Label"
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = tab.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.TextDim
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = container
    
    return container
end

-- Cleanup and resource management (NOVO)
function StoppedUI:Destroy()
    -- Disconnect notification panel connection
    if self._notificationPanelConn then
        pcall(function() self._notificationPanelConn:Disconnect() end)
        self._notificationPanelConn = nil
    end
    
    -- Disconnect all dropdown render connections
    if self._dropdownRenderConnections and #self._dropdownRenderConnections > 0 then
        for _, conn in ipairs(self._dropdownRenderConnections) do
            pcall(function() conn:Disconnect() end)
        end
        self._dropdownRenderConnections = {}
    end
    
    -- Disconnect all tracked connections
    if self._allConnections and #self._allConnections > 0 then
        for _, conn in ipairs(self._allConnections) do
            pcall(function() conn:Disconnect() end)
        end
        self._allConnections = {}
    end
    
    -- Destroy the ScreenGui and all children
    if self.ScreenGui and self.ScreenGui.Parent then
        pcall(function() self.ScreenGui:Destroy() end)
    end
    
    -- Clear references
    self.ScreenGui = nil
    self.Container = nil
    self.NotificationPanel = nil
    self.NotificationBell = nil
    self.NotificationBellContainer = nil
    self.NotificationBadge = nil
    self._keybinds = {}
    self._configs = {}
    self._configCallbacks = {}
    self._imgCache = {}
end

return StoppedUI