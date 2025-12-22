# StoppedUI 5.1.0 - Complete Documentation

## 📋 Table of Contents
1. [What's New in 5.1.0](#whats-new-in-510)
2. [Installation & Basic Usage](#installation--basic-usage)
3. [Splitter Drag-Resize](#splitter-drag-resize)
4. [Command Palette](#command-palette-ctrlk)
5. [Dev Mode Inspector](#dev-mode-inspector)
6. [Responsive Breakpoints](#responsive-breakpoints)
7. [Layout Modes](#layout-modes)
8. [Snap to Edges](#snap-to-edges)
9. [Translation System](#translation-system)
10. [Config System](#config-system-hook-based)
11. [Theme System](#theme-system)
12. [API Reference](#api-reference)
13. [Extension Guide](#extension-guide)
14. [Examples](#examples)

---

## 🆕 What's New in 5.1.0

### 🎯 Major Features Added

#### ✨ Drag-Resize Splitter
- **Visual splitter** between LeftPane and PreviewPane
- **Drag to resize** panels in real-time
- **Fluid layout** with percentage-based widths
- **Min/Max constraints** (280px - 600px for left pane)
- **Glow effect** on hover and drag
- **Smooth animations** during resize

#### ⌨️ Command Palette (Ctrl+K)
- **Quick command access** - press Ctrl+K anywhere
- **Fuzzy search** through all registered commands
- **Extensible** - developers can register custom commands
- **Beautiful UI** with smooth animations
- **Keyboard navigation** ready

#### 🔧 Dev Mode Inspector
- **Real-time element inspection** on hover
- **Shows**: Name, Class, Size, Position, LayoutOrder, ZIndex
- **Toggle** via Command Palette or config option
- **Non-intrusive** overlay with transparency

#### 📱 Advanced Responsive Breakpoints
- **Mobile** (< 480px): Single column, vertical stack
- **Tablet** (480-700px): Vertical stack with better spacing
- **Desktop** (700-1200px): Side-by-side with splitter
- **Wide** (> 1200px): Full side-by-side layout
- **Smooth transitions** between layouts

#### 🎨 Layout Modes
- **Compact**: Smaller padding (6px), font (11px), height (32px)
- **Normal**: Standard padding (10px), font (13px), height (40px)
- **Expanded**: Larger padding (14px), font (14px), height (50px)
- **Toggle programmatically** or via commands

#### 🧲 Snap to Edges
- **Magnetic snapping** when dragging window near edges
- **Ghost preview** shows snap target position
- **Configurable snap distance** (default 10px)
- **Smooth snap animation** on release

#### 🌐 Translation System Improvements
- **Disabled by default** - no overhead if not used
- **TranslationEnabled** flag in config
- **Developer must explicitly enable** translations
- **Zero impact** when disabled

#### 🎯 Animated Tab Indicators
- **Accent bar** slides under active tab
- **Smooth animation** with Tween
- **Better visual feedback** for current tab
- **Matches theme accent color**

### 📊 Configuration Improvements

#### New Config Options
```lua
{
    TranslationEnabled = false,  -- Enable translations (default: off)
    DevMode = false,              -- Enable developer inspector
    LayoutMode = "Normal",        -- "Compact" | "Normal" | "Expanded"
    EnableSplitter = true,        -- Enable resize splitter
    SnapToEdges = true,           -- Snap window to screen edges
    SnapDistance = 10             -- Snap trigger distance in pixels
}
```

### 🚀 Performance & Code Quality

#### Better Memory Management
- All connections tracked in `_allConnections`
- Proper cleanup in `Destroy()` method
- No memory leaks from orphaned connections

#### Centralized Utilities
- `UIHelpers` module with all utility functions
- `SafeConnect()` with error handling
- `CleanupConnections()` for batch cleanup
- Snap, breakpoint, and clamp utilities

#### Fluid Layouts
- Percentage-based widths instead of fixed pixels
- Calculated responsive positioning
- Min/max constraints for consistency
- Smooth transitions between layout modes

---

## 🚀 Installation & Basic Usage

### Basic Setup with New Features

```lua
local StoppedUI = require(script.StoppedUI)

-- Create with all new features enabled
local window = StoppedUI:Create({
    Name = "My Application",
    Theme = "Dark",
    ShowPreview = true,
    
    -- NEW: Translation control
    TranslationEnabled = false,  -- Disabled by default
    
    -- NEW: Dev tools
    DevMode = false,  -- Enable for development
    
    -- NEW: Layout options
    LayoutMode = "Normal",  -- or "Compact", "Expanded"
    
    -- NEW: Splitter control
    EnableSplitter = true,  -- Drag-resize panes
    
    -- NEW: Snap behavior
    SnapToEdges = true,
    SnapDistance = 10,
    
    -- Config system
    ConfigEnabled = true
})

-- NEW: Register custom commands for Command Palette
window:RegisterCommand("Refresh Data", "Reload all data from server", function()
    refreshData()
end)

window:RegisterCommand("Export Settings", "Export config to file", function()
    exportSettings()
end)

-- Create tabs and elements
local mainTab = window:CreateTab({Name = "Main"})

window:AddSlider(mainTab, {
    Label = "Speed",
    Min = 0,
    Max = 100,
    Value = 50,
    Callback = function(v)
        print("Speed:", v)
    end
})
```

### Quick Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Ctrl+K** | Open Command Palette |
| **Escape** | Close Command Palette |
| **Drag Topbar** | Move window |
| **Drag Splitter** | Resize panes |

---

## 🎚️ Splitter Drag-Resize

### Overview

The splitter allows users to adjust the width of LeftPane and PreviewPane by dragging a vertical bar between them.

### Features

- **Visual indicator**: Thin accent-colored bar between panes
- **Hover glow**: Highlights on mouse over
- **Drag glow**: Intensifies during drag
- **Fluid resize**: Updates layout in real-time
- **Constraints**: Respects min (280px) and max (600px) widths
- **Smooth animations**: 80ms tween for natural feel
- **Auto-hide on mobile**: Disabled on screens < 700px

### Usage

```lua
-- Enable/disable splitter
local window = StoppedUI:Create({
    EnableSplitter = true,  -- default: true
    ShowPreview = true      -- splitter only shows if preview is visible
})

-- Programmatically update pane layout
window._leftPaneWidth = 0.35  -- 35% of container width
window:UpdatePaneLayout(true)  -- true = animate
```

### Technical Details

```lua
-- Splitter state is stored in:
window._leftPaneWidth  -- Fraction (0-1) of container width
window._minLeftPaneWidth  -- 280px minimum
window._maxLeftPaneWidth  -- 600px maximum

-- Update method:
window:UpdatePaneLayout(animate)
-- animate: boolean - whether to tween (true) or instantly update (false)
```

### Customization

```lua
-- Change constraints
window._minLeftPaneWidth = 250
window._maxLeftPaneWidth = 700

-- Disable splitter
window.EnableSplitter = false
window.Splitter.Visible = false

-- Change splitter color
window.Splitter.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
```

---

## ⌨️ Command Palette (Ctrl+K)

### Overview

The Command Palette provides a quick, keyboard-driven way to access any function in your application.

### Built-in Commands

| Command | Description |
|---------|-------------|
| Toggle UI | Hide/Show the main window |
| Save Config | Save current configuration |
| Load Config | Load saved configuration |
| Toggle Preview | Show/Hide preview pane |
| Toggle Dev Mode | Enable/Disable developer mode |

### Registering Custom Commands

```lua
window:RegisterCommand(name, description, callback)

-- Examples:
window:RegisterCommand("Reset All", "Reset all settings to default", function()
    resetAllSettings()
    window:Notify({Text = "Settings reset!", Type = "Success"})
end)

window:RegisterCommand("Toggle Compact Mode", "Switch to compact layout", function()
    window:SetLayoutMode("Compact")
end)

window:RegisterCommand("Export Log", "Export debug log to file", function()
    exportDebugLog()
end)
```

### Search Functionality

The palette automatically filters commands as you type:
- **Name matching**: Searches command names
- **Description matching**: Searches descriptions
- **Case-insensitive**: "toggle" matches "Toggle UI"
- **Instant results**: No delay

### Programmatic Control

```lua
-- Toggle palette programmatically
window:ToggleCommandPalette()

-- Access palette data
local commands = window.CommandPalette.Commands

-- Clear search
window.CommandPalette.SearchBox.Text = ""

-- Trigger specific command
for _, cmd in ipairs(commands) do
    if cmd.Name == "Toggle UI" then
        cmd.Callback()
        break
    end
end
```

### Styling

```lua
-- Customize palette appearance
local palette = window.CommandPalette.Container
palette.Size = UDim2.new(0, 600, 0, 500)  -- Larger size

-- Change colors
palette.BackgroundColor3 = window.Theme.Background
```

---

## 🔧 Dev Mode Inspector

### Overview

Dev Mode provides a real-time inspector that shows technical details about UI elements as you hover over them.

### Enabling Dev Mode

```lua
-- Method 1: In config
local window = StoppedUI:Create({
    DevMode = true
})

-- Method 2: Via Command Palette
-- Press Ctrl+K → type "dev" → select "Toggle Dev Mode"

-- Method 3: Programmatically
window:ToggleDevMode()
```

### Displayed Information

When hovering over any GUI element:
- **Name**: Element's name property
- **Class**: GuiObject class (Frame, TextButton, etc.)
- **Size**: UDim2 size value
- **Position**: UDim2 position value
- **LayoutOrder**: Sort order in layouts
- **ZIndex**: Display layer

### Inspector Window

- **Location**: Top-right corner of main container
- **Size**: 280x200 pixels
- **Style**: Black transparent background with red border
- **Always on top**: ZIndex 999
- **Non-blocking**: Transparent to clicks

### Use Cases

1. **Debugging layouts**: See why elements aren't positioned correctly
2. **Inspecting sizes**: Check actual pixel sizes
3. **Z-order issues**: Verify ZIndex values
4. **Layout debugging**: Check LayoutOrder sequence

### Customization

```lua
-- Access inspector
local inspector = window.DevModeInspector

-- Change position
inspector.Container.Position = UDim2.new(0, 10, 0, 10)  -- Top-left

-- Change size
inspector.Container.Size = UDim2.new(0, 350, 0, 250)

-- Custom styling
inspector.Container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
```

---

## 📱 Responsive Breakpoints

### Overview

StoppedUI automatically adjusts its layout based on viewport width using four responsive breakpoints.

### Breakpoints

```lua
StoppedUI.Breakpoints = {
    Mobile = 480,   -- < 480px
    Tablet = 700,   -- 480px - 700px
    Desktop = 1200  -- 700px - 1200px
    -- Wide = > 1200px (implied)
}
```

### Behavior Per Breakpoint

#### Mobile (< 480px)
- **Layout**: Single column, vertical stack
- **LeftPane**: Takes top 50% of height
- **PreviewPane**: Takes bottom 50% of height
- **Splitter**: Hidden
- **Best for**: Phones in portrait mode

```lua
-- Mobile layout applied automatically:
LeftPane.Size = UDim2.new(1, -20, 0.5, -40)
LeftPane.Position = UDim2.new(0, 10, 0, 70)

PreviewPane.Size = UDim2.new(1, -20, 0.5, -40)
PreviewPane.Position = UDim2.new(0, 10, 0.5, 30)
```

#### Tablet (480-700px)
- **Layout**: Vertical stack with better proportions
- **LeftPane**: Takes 55% of height
- **PreviewPane**: Takes 45% of height
- **Splitter**: Hidden
- **Best for**: Tablets, small laptop screens

#### Desktop (700-1200px)
- **Layout**: Side-by-side columns
- **LeftPane**: Fluid width (default 42%)
- **PreviewPane**: Remaining width
- **Splitter**: Visible and functional
- **Best for**: Standard monitors

#### Wide (> 1200px)
- **Layout**: Side-by-side with optimal spacing
- **Splitter**: Fully functional
- **Best for**: Large monitors, ultrawide displays

### Manual Breakpoint Checking

```lua
local breakpoint = UIHelpers.GetResponsiveBreakpoint(viewportWidth)
-- Returns: "Mobile" | "Tablet" | "Desktop" | "Wide"

if breakpoint == "Mobile" then
    -- Adjust UI for mobile
elseif breakpoint == "Desktop" then
    -- Desktop-specific features
end
```

### Smooth Transitions

All layout changes are animated with 0.3s tweens:
```lua
UIHelpers.Tween(element, {Size = newSize}, 0.3)
```

---

## 🎨 Layout Modes

### Overview

Layout Modes allow dynamic adjustment of spacing, font sizes, and element heights across the entire UI.

### Available Modes

#### Compact Mode
```lua
window:SetLayoutMode("Compact")

-- Properties:
padding = 6
fontSize = 11
elementHeight = 32

-- Use case: Maximize content density, small screens
```

#### Normal Mode (Default)
```lua
window:SetLayoutMode("Normal")

-- Properties:
padding = 10
fontSize = 13
elementHeight = 40

-- Use case: Balanced layout for most use cases
```

#### Expanded Mode
```lua
window:SetLayoutMode("Expanded")

-- Properties:
padding = 14
fontSize = 14
elementHeight = 50

-- Use case: Better readability, accessibility, large screens
```

### Setting Layout Mode

```lua
-- Method 1: In config
local window = StoppedUI:Create({
    LayoutMode = "Compact"  -- or "Normal", "Expanded"
})

-- Method 2: Programmatically
window:SetLayoutMode("Expanded")

-- Method 3: Via Command (register it first)
window:RegisterCommand("Compact Layout", "Switch to compact mode", function()
    window:SetLayoutMode("Compact")
end)
```

### What Changes

- **Padding**: UIPadding on LeftPane and containers
- **Font sizes**: All text elements (future enhancement)
- **Element heights**: Buttons, toggles, sliders (future enhancement)
- **Spacing**: UIListLayout padding values

### Custom Layout Modes

```lua
-- Add custom mode
StoppedUI.LayoutModes.Tiny = "Tiny"

-- Modify ApplyLayoutMode function:
function StoppedUI:ApplyLayoutMode()
    local padding, fontSize, elementHeight
    
    if self.LayoutMode == "Tiny" then
        padding = 4
        fontSize = 10
        elementHeight = 28
    -- ... existing modes ...
    end
    
    -- Apply settings
end
```

---

## 🧲 Snap to Edges

### Overview

Snap to Edges provides magnetic window snapping when dragging near screen edges, similar to Windows Aero Snap.

### Features

- **Automatic snapping**: Window snaps to edges within snap distance
- **Ghost preview**: Semi-transparent preview shows snap target
- **Smooth animation**: 0.2s tween when snapping on release
- **Configurable distance**: Adjust sensitivity

### Configuration

```lua
local window = StoppedUI:Create({
    SnapToEdges = true,     -- Enable/disable (default: true)
    SnapDistance = 10       -- Pixels from edge to trigger (default: 10)
})

-- Change at runtime
window.SnapToEdges = false  -- Disable snapping
window.SnapDistance = 20    -- More sensitivefiring

**Solution**:
1. Set `ConfigEnabled = true` in Create()
2. Connect to `window.Config.OnRequestSave.Event`
3. Call `window:RequestSave()` explicitly
4. Check for errors in your save logic

### Memory Leaks

**Problem**: Connections not cleaning up

**Solution**: Always call `window:Destroy()` when done:
```lua
-- Cleanup on script unload
game:BindToClose(function()
    if window then
        window:Destroy()
    end
end)
```

---

## 📝 Migration from 4.x

### Breaking Changes

1. **Config system is no longer automatic**
   - Old: Auto-saved on close
   - New: Developer must implement via hooks

2. **Slider appearance changed**
   - Old: Thick bar (10-12px)
   - New: Thin bar (6px default)

3. **UIHelpers required**
   - Old: Functions scattered
   - New: Centralized in UIHelpers

### Migration Steps

1. Update config system:
```lua
-- Old (4.x)
-- Nothing needed, auto-saved

-- New (5.0)
window.Config.OnRequestSave.Event:Connect(function()
    -- YOUR SAVE LOGIC
end)
```

2. Update slider calls (if custom Height was used):
```lua
-- Old
window:AddSlider(tab, {Height = 10, ...})

-- New (default is now 6)
window:AddSlider(tab, {Height = 6, ...})  -- or omit for default
```

3. No other changes needed - API is backward compatible!

---

## 🎉 Credits

**StoppedUI 5.0** - Enhanced by Spectro3n

Based on original StoppedUI library with major improvements:
- Modern slider component
- Fixed text centralization
- Hook-based config system
- Enhanced responsiveness
- Better code architecture

---

## 📄 License

Free to use and modify. Credit appreciated but not required.