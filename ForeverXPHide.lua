-- ForeverXPHide
-- WoW Forever / Camelot interface 16001
-- Hides the native experience bar without hiding the tracking-bar manager.

local ADDON_NAME = ...
local PREFIX = "|cffd7a64aForever XP Hide:|r "
local eventFrame = CreateFrame("Frame")
local hookedFrame
local retryElapsed = 0
local retryAttempts = 0
local warnedThisSession = false

ForeverXPHideDB = ForeverXPHideDB or {}
if ForeverXPHideDB.enabled == nil then
    ForeverXPHideDB.enabled = true
end

local function Message(text)
    print(PREFIX .. text)
end

local function GetExperienceBarFrame()
    if not StatusTrackingBarManager or not StatusTrackingBarInfo then
        return nil
    end

    local containers = StatusTrackingBarManager.barContainers
    local barsEnum = StatusTrackingBarInfo.BarsEnum
    local experienceID = barsEnum and barsEnum.Experience
    local container = containers and containers[1]
    local bar = container and container.bars and experienceID
        and container.bars[experienceID]
    local statusBar = bar and bar.StatusBar
    local parent = statusBar and statusBar:GetParent()

    -- This is the outer 1192x17 frame verified against the WoW Forever UI.
    return parent and parent:GetParent() or nil
end

local function ApplySetting()
    local frame = GetExperienceBarFrame()
    if not frame then
        return false
    end

    if frame ~= hookedFrame then
        hookedFrame = frame
        frame:HookScript("OnShow", function(self)
            if ForeverXPHideDB.enabled then
                self:Hide()
            end
        end)
    end

    if ForeverXPHideDB.enabled then
        frame:Hide()
    else
        frame:Show()
    end

    return true
end

local function StopRetry()
    eventFrame:SetScript("OnUpdate", nil)
    retryElapsed = 0
    retryAttempts = 0
end

local function StartRetry()
    StopRetry()

    if ApplySetting() then
        return true
    end

    -- Some UI builds finish creating the tracking bar shortly after login.
    -- Retry twice per second for up to ten seconds, then stop completely.
    eventFrame:SetScript("OnUpdate", function(self, elapsed)
        retryElapsed = retryElapsed + elapsed
        if retryElapsed < 0.5 then
            return
        end

        retryElapsed = 0
        retryAttempts = retryAttempts + 1

        if ApplySetting() then
            StopRetry()
            return
        end

        if retryAttempts >= 20 then
            StopRetry()
            if not warnedThisSession then
                warnedThisSession = true
                Message("couldn't find the XP bar. The UI may have changed in a newer client build.")
            end
        end
    end)

    return false
end

local function SetEnabled(enabled, announce)
    ForeverXPHideDB.enabled = enabled and true or false

    if StartRetry() then
        if announce then
            Message(ForeverXPHideDB.enabled and "XP bar hidden." or "XP bar shown.")
        end
    elseif announce then
        Message("waiting for the XP bar to initialise; your setting has been saved.")
    end
end

local function ShowHelp()
    Message("Commands:")
    print("  /xphide       Toggle hiding")
    print("  /xphide on    Hide the XP bar")
    print("  /xphide off   Show the XP bar")
    print("  /xphide status  Show the current setting")
    print("  /xphide help  Show this help")
end

SLASH_FOREVERXPHIDE1 = "/xphide"
SLASH_FOREVERXPHIDE2 = "/fxphide"
SlashCmdList.FOREVERXPHIDE = function(message)
    message = (message or ""):lower():match("^%s*(.-)%s*$")

    if message == "on" then
        SetEnabled(true, true)
    elseif message == "off" then
        SetEnabled(false, true)
    elseif message == "status" then
        Message(ForeverXPHideDB.enabled and "hiding is ON." or "hiding is OFF.")
    elseif message == "help" then
        ShowHelp()
    elseif message == "" or message == "toggle" then
        SetEnabled(not ForeverXPHideDB.enabled, true)
    else
        ShowHelp()
    end
end

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    StartRetry()
end)
