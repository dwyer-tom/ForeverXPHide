local ADDON_NAME = ...

local DEFAULTS = {
    enabled = true,
}

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ForeverXPHide|r: " .. message)
end

local function GetExperienceBar()
    if not StatusTrackingBarManager
        or not StatusTrackingBarManager.barContainers
        or not StatusTrackingBarInfo
        or not StatusTrackingBarInfo.BarsEnum
        or not StatusTrackingBarInfo.BarsEnum.Experience then
        return nil
    end

    local container = StatusTrackingBarManager.barContainers[1]
    if not container or not container.bars then
        return nil
    end

    local experienceBar = container.bars[StatusTrackingBarInfo.BarsEnum.Experience]
    if not experienceBar or not experienceBar.StatusBar then
        return nil
    end

    local statusBarParent = experienceBar.StatusBar:GetParent()
    if not statusBarParent then
        return nil
    end

    return statusBarParent:GetParent()
end

local function ApplyPreference()
    if not ForeverXPHideDB or not ForeverXPHideDB.enabled then
        return false
    end

    local frame = GetExperienceBar()
    if not frame then
        return false
    end

    frame:Hide()
    return true
end

local function SetEnabled(enabled)
    ForeverXPHideDB.enabled = enabled and true or false

    if ForeverXPHideDB.enabled then
        local applied = ApplyPreference()
        Print(applied and "XP bar hidden." or "Preference saved; waiting for the XP bar to load.")
    else
        local frame = GetExperienceBar()
        if frame then
            frame:Show()
        end
        Print("XP bar shown. Your preference has been saved.")
    end
end

local function InitializeDatabase()
    if type(ForeverXPHideDB) ~= "table" then
        ForeverXPHideDB = {}
    end

    if ForeverXPHideDB.enabled == nil then
        ForeverXPHideDB.enabled = DEFAULTS.enabled
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    InitializeDatabase()

    local attempts = 0
    local tickerFrame = CreateFrame("Frame")
    tickerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    tickerFrame:SetScript("OnEvent", function(self)
        attempts = 0
        self:SetScript("OnUpdate", function(updateFrame, elapsed)
            attempts = attempts + elapsed
            if attempts < 0.25 then
                return
            end
            attempts = 0

            if ApplyPreference() then
                updateFrame:SetScript("OnUpdate", nil)
                updateFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            end
        end)
    end)

    SLASH_FOREVERXPHIDE1 = "/xphide"
    SLASH_FOREVERXPHIDE2 = "/foreverxphide"
    SlashCmdList.FOREVERXPHIDE = function(message)
        local command = (message or ""):lower():match("^%s*(.-)%s*$")

        if command == "on" then
            SetEnabled(true)
        elseif command == "off" then
            SetEnabled(false)
        elseif command == "toggle" or command == "" then
            SetEnabled(not ForeverXPHideDB.enabled)
        elseif command == "status" then
            Print("XP bar hiding is " .. (ForeverXPHideDB.enabled and "enabled." or "disabled."))
        elseif command == "help" then
            Print("/xphide on - hide the XP bar")
            Print("/xphide off - show the XP bar")
            Print("/xphide toggle - toggle the setting")
            Print("/xphide status - show the current setting")
        else
            Print("Unknown command. Use /xphide help.")
        end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnAddonLoaded)
