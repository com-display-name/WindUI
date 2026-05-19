local WindUI = {
    Window = nil,
    Theme = nil,
    Creator = require("./modules/Creator"),
    LocalizationModule = require("./modules/Localization"),
    NotificationModule = require("./components/Notification"),
    Themes = nil,
    Transparent = false,
    
    TransparencyValue = .15,
    
    UIScale = 1,
    
    Version = "0.0.0",
    
    OnThemeChangeFunction = nil,
    
    cloneref = nil,
    UIScaleObj = nil,
}


local cloneref = (cloneref or clonereference or function(instance) return instance end)

WindUI.cloneref = cloneref

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui= cloneref(game:GetService("CoreGui"))

local LocalPlayer = Players.LocalPlayer or nil

local ServicesModule = WindUI.Services


local Creator = WindUI.Creator

local New = Creator.New
local Tween = Creator.Tween


local Acrylic = require("./utils/Acrylic/Init")

local GUIParent = LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")) or CoreGui

local UIScaleObj = New("UIScale", {
    Scale = WindUI.UIScale,
})

WindUI.UIScaleObj = UIScaleObj

WindUI.ScreenGui = New("ScreenGui", {
    Name = "WindUI",
    Parent = GUIParent,
    IgnoreGuiInset = true,
    ScreenInsets = "None",
}, {
    
    New("Folder", {
        Name = "Window"
    }),
    -- New("Folder", {
    --     Name = "Notifications"
    -- }),
    -- New("Folder", {
    --     Name = "Dropdowns"
    -- }),
    -- New("Folder", {
    --    Name = "KeySystem"
    -- }),
    New("Folder", {
        Name = "Popups"
    }),
    New("Folder", {
        Name = "ToolTips"
    })
})

WindUI.NotificationGui = New("ScreenGui", {
    Name = "WindUI/Notifications",
    Parent = GUIParent,
    IgnoreGuiInset = true,
})
WindUI.DropdownGui = New("ScreenGui", {
    Name = "WindUI/Dropdowns",
    Parent = GUIParent,
    IgnoreGuiInset = true,
})
WindUI.TooltipGui = New("ScreenGui", {
    Name = "WindUI/Tooltips",
    Parent = GUIParent,
    IgnoreGuiInset = true,
})

Creator.Init(WindUI)


function WindUI:SetParent(parent)
    WindUI.ScreenGui.Parent = parent
    WindUI.NotificationGui.Parent = parent
    WindUI.DropdownGui.Parent = parent
    WindUI.TooltipGui.Parent = parent
end
math.clamp(WindUI.TransparencyValue, 0, 1)

local Holder = WindUI.NotificationModule.Init(WindUI.NotificationGui)

function WindUI:Notify(Config)
    Config.Holder = Holder.Frame
    Config.Window = WindUI.Window
    --Config.WindUI = WindUI
    return WindUI.NotificationModule.New(Config)
end

function WindUI:SetNotificationLower(Val)
    Holder.SetLower(Val)
end

function WindUI:SetFont(FontId)
    Creator.UpdateFont(FontId)
end

function WindUI:OnThemeChange(func)
    WindUI.OnThemeChangeFunction = func
end

function WindUI:AddTheme(LTheme)
    WindUI.Themes[LTheme.Name] = LTheme
    return LTheme
end

function WindUI:SetTheme(Value)
    if WindUI.Themes[Value] then
        WindUI.Theme = WindUI.Themes[Value]
        Creator.SetTheme(WindUI.Themes[Value])
        
        if WindUI.OnThemeChangeFunction then
            WindUI.OnThemeChangeFunction(Value)
        end
        --Creator.UpdateTheme()
        
        return WindUI.Themes[Value]
    end
    return nil
end

function WindUI:GetThemes()
    return WindUI.Themes
end
function WindUI:GetCurrentTheme()
    return WindUI.Theme.Name
end
function WindUI:GetTransparency()
    return WindUI.Transparent or false
end
function WindUI:GetWindowSize()
    return WindUI.Window and WindUI.Window.UIElements.Main.Size or nil
end
function WindUI:Localization(LocalizationConfig)
    return WindUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function WindUI:SetLanguage(Value)
    if Creator.Localization then
        return Creator.SetLanguage(Value)
    end
    return false
end

function WindUI:ToggleAcrylic(Value)
	if WindUI.Window and WindUI.Window.AcrylicPaint and WindUI.Window.AcrylicPaint.Model then
		WindUI.Window.Acrylic = Value
		WindUI.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end



function WindUI:Gradient(stops, props)
    local colorSequence = {}
    local transparencySequence = {}

    for posStr, stop in next, stops do
        local position = tonumber(posStr)
        if position then
            position = math.clamp(position / 100, 0, 1)
            table.insert(colorSequence, ColorSequenceKeypoint.new(position, stop.Color))
            table.insert(transparencySequence, NumberSequenceKeypoint.new(position, stop.Transparency or 0))
        end
    end

    table.sort(colorSequence, function(a, b) return a.Time < b.Time end)
    table.sort(transparencySequence, function(a, b) return a.Time < b.Time end)


    if #colorSequence < 2 then
        error("ColorSequence requires at least 2 keypoints")
    end


    local gradientData = {
        Color = ColorSequence.new(colorSequence),
        Transparency = NumberSequence.new(transparencySequence),
    }

    if props then
        for k, v in pairs(props) do
            gradientData[k] = v
        end
    end

    return gradientData
end


function WindUI:Popup(PopupConfig)
    PopupConfig.WindUI = WindUI
    return require("./components/popup/Init").new(PopupConfig)
end


WindUI.Themes = require("./themes/Init")(WindUI)

Creator.Themes = WindUI.Themes


WindUI:SetTheme("Dark")
WindUI:SetLanguage(Creator.Language)


function WindUI:CreateWindow(Config)
    Config = Config or {}

    local CreateWindow = require("./components/window/Init")
    
    Config.WindUI = WindUI
    Config.Parent = WindUI.ScreenGui.Window
    
    if WindUI.Window then
        warn("You cannot create more than one window")
        return
    end
    
    local CanLoadWindow = true
    
    local Theme = WindUI.Themes[Config.Theme or "Dark"]
    
    --WindUI.Theme = Theme
    Creator.SetTheme(Theme)
    
    
    local hwid = gethwid or function()
        return Players.LocalPlayer.UserId
    end

    local Window = CreateWindow(Config)

    WindUI.Transparent = Config.Transparent
    WindUI.Window = Window
    
    if Config.Acrylic then
        Acrylic.init()
    end

    return Window
end

return WindUI
