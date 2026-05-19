--- VideoFrame is not working with custom video on exploits

local Creator = require("../modules/Creator")
local New = Creator.New

local Element = {}

local function ParseAspectRatio(aspectRatio)
    if type(aspectRatio) == "string" then
        local width, height = aspectRatio:match("(%d+):(%d+)")
        if width and height then
            return tonumber(width) / tonumber(height)
        end
    elseif type(aspectRatio) == "number" then
        return aspectRatio
    end
    return nil
end


function Element:New(Config)
    local VideoModule = {
        __type = "Video",
        Video = Config.Video or "",
        AspectRatio = Config.AspectRatio or "16:9",
        Radius = Config.Radius or Config.Window.ElementConfig.UICorner,
    }
    
    local MainVideo
    
    if VideoModule.Video then
        local BGVideo
        if Creator.IsHttpUrl(VideoModule.Video) then
            warn("[ WindUI.Video ] Remote video URLs are not supported in Roblox Studio/client contexts. Use an uploaded video asset instead: " .. VideoModule.Video)
            return VideoModule.__type, VideoModule
        else
            BGVideo = VideoModule.Video
        end
        
        MainVideo = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Video = BGVideo,
            Looped = false,
            Volume = 0,
            Parent = Config.Parent
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,VideoModule.Radius)
            }),
        })
        MainVideo:Play()
        
        
        local aspectRatio = ParseAspectRatio(VideoModule.AspectRatio)
        local aspectRatioConstraint = nil
        
        if aspectRatio then
            aspectRatioConstraint = New("UIAspectRatioConstraint", {
                Parent = MainVideo,
                AspectRatio = aspectRatio,
                AspectType = "ScaleWithParentSize",
                DominantAxis = "Width"
            })
        end
    end
    
    
    function VideoModule:Destroy()
        if MainVideo then MainVideo:Destroy() end
    end
    
    return VideoModule.__type, VideoModule
end

return Element
